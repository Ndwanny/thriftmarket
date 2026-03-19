// Supabase Edge Function: try-on
// Secure proxy to Google Vertex AI Virtual Try-On API.
// Deploy: npx supabase functions deploy try-on
//
// Required env var (set in Supabase Dashboard → Edge Functions → Secrets):
//   GCP_SERVICE_ACCOUNT_KEY  — full JSON string of your GCP service account key
//   GCP_PROJECT_ID           — your Google Cloud project ID
//
// The service account needs the role: "Vertex AI User"

import { serve } from "https://deno.land/std@0.168.0/http/server.ts";

const CORS = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
};

serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: CORS });
  }

  try {
    const { personImageBase64, garmentImageUrl } = await req.json();

    if (!personImageBase64) {
      return json({ error: "personImageBase64 is required" }, 400);
    }

    const projectId = Deno.env.get("GCP_PROJECT_ID");
    const serviceAccountJson = Deno.env.get("GCP_SERVICE_ACCOUNT_KEY");

    if (!projectId || !serviceAccountJson) {
      return json({ error: "GCP credentials not configured" }, 500);
    }

    const serviceAccount = JSON.parse(serviceAccountJson);

    // ── Get GCP access token via service account JWT ───────────────────────
    const accessToken = await getAccessToken(serviceAccount);

    // ── Fetch and encode garment image ─────────────────────────────────────
    let garmentBase64: string;
    if (garmentImageUrl) {
      const imgRes = await fetch(garmentImageUrl);
      if (!imgRes.ok) throw new Error("Could not fetch garment image");
      const buf = await imgRes.arrayBuffer();
      garmentBase64 = encodeBase64(new Uint8Array(buf));
    } else {
      return json({ error: "garmentImageUrl is required" }, 400);
    }

    // ── Call Vertex AI Virtual Try-On ──────────────────────────────────────
    // Model: imagegeneration@006 with mode=virtual_try_on
    // Docs: https://cloud.google.com/vertex-ai/generative-ai/docs/image/image-generation
    const endpoint =
      `https://us-central1-aiplatform.googleapis.com/v1/projects/${projectId}` +
      `/locations/us-central1/publishers/google/models/imagegeneration@006:predict`;

    const payload = {
      instances: [
        {
          image: { bytesBase64Encoded: personImageBase64 },
          garmentImages: [{ bytesBase64Encoded: garmentBase64 }],
        },
      ],
      parameters: {
        mode: "virtual_try_on",
        sampleCount: 1,
      },
    };

    const apiRes = await fetch(endpoint, {
      method: "POST",
      headers: {
        Authorization: `Bearer ${accessToken}`,
        "Content-Type": "application/json",
      },
      body: JSON.stringify(payload),
    });

    const result = await apiRes.json();

    if (!apiRes.ok) {
      const msg = result?.error?.message ?? `Vertex AI error ${apiRes.status}`;
      return json({ error: msg }, apiRes.status);
    }

    const resultBase64 =
      result?.predictions?.[0]?.bytesBase64Encoded ??
      result?.predictions?.[0]?.imageBase64;

    if (!resultBase64) {
      return json({ error: "No image returned from Vertex AI" }, 500);
    }

    return json({ imageBase64: resultBase64 });
  } catch (e: unknown) {
    const msg = e instanceof Error ? e.message : String(e);
    return json({ error: msg }, 500);
  }
});

// ── Helpers ────────────────────────────────────────────────────────────────

function json(data: unknown, status = 200): Response {
  return new Response(JSON.stringify(data), {
    status,
    headers: { ...CORS, "Content-Type": "application/json" },
  });
}

function encodeBase64(bytes: Uint8Array): string {
  let bin = "";
  bytes.forEach((b) => (bin += String.fromCharCode(b)));
  return btoa(bin);
}

/**
 * Creates a short-lived GCP access token by signing a JWT with the
 * service account private key and exchanging it at the OAuth2 token endpoint.
 */
async function getAccessToken(sa: {
  client_email: string;
  private_key: string;
}): Promise<string> {
  const now = Math.floor(Date.now() / 1000);

  const headerB64 = base64url(JSON.stringify({ alg: "RS256", typ: "JWT" }));
  const claimsB64 = base64url(
    JSON.stringify({
      iss: sa.client_email,
      scope: "https://www.googleapis.com/auth/cloud-platform",
      aud: "https://oauth2.googleapis.com/token",
      iat: now,
      exp: now + 3600,
    })
  );

  const signingInput = `${headerB64}.${claimsB64}`;

  // Strip PEM headers and import the PKCS8 private key
  const pemBody = sa.private_key
    .replace(/-----BEGIN PRIVATE KEY-----|-----END PRIVATE KEY-----|\n/g, "");
  const derBytes = Uint8Array.from(atob(pemBody), (c) => c.charCodeAt(0));

  const cryptoKey = await crypto.subtle.importKey(
    "pkcs8",
    derBytes,
    { name: "RSASSA-PKCS1-v1_5", hash: "SHA-256" },
    false,
    ["sign"]
  );

  const signature = await crypto.subtle.sign(
    "RSASSA-PKCS1-v1_5",
    cryptoKey,
    new TextEncoder().encode(signingInput)
  );

  const jwt = `${signingInput}.${base64url(new Uint8Array(signature))}`;

  // Exchange JWT for access token
  const tokenRes = await fetch("https://oauth2.googleapis.com/token", {
    method: "POST",
    headers: { "Content-Type": "application/x-www-form-urlencoded" },
    body: `grant_type=urn:ietf:params:oauth:grant-type:jwt-bearer&assertion=${jwt}`,
  });

  const tokenData = await tokenRes.json();
  if (!tokenData.access_token) {
    throw new Error(`Failed to get access token: ${JSON.stringify(tokenData)}`);
  }

  return tokenData.access_token;
}

function base64url(input: string | Uint8Array): string {
  let str: string;
  if (typeof input === "string") {
    str = btoa(unescape(encodeURIComponent(input)));
  } else {
    str = encodeBase64(input);
  }
  return str.replace(/\+/g, "-").replace(/\//g, "_").replace(/=+$/, "");
}
