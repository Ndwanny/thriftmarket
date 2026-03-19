-- ============================================================
-- Thrift Market LKS — Seed Data
-- Run in: Supabase Dashboard → SQL Editor → New Query
-- ============================================================

-- Clear existing seed data (safe re-run)
TRUNCATE TABLE products, vendors, categories RESTART IDENTITY CASCADE;

INSERT INTO categories (id, name, slug, icon, sort_order) VALUES
  ('a1000000-0000-0000-0000-000000000001', 'Streetwear & Fashion', 'streetwear-fashion', 'checkroom', 1),
  ('a1000000-0000-0000-0000-000000000002', 'Vintage Cameras', 'vintage-cameras', 'camera_alt', 2),
  ('a1000000-0000-0000-0000-000000000003', 'Sneakers & Footwear', 'sneakers-footwear', 'directions_run', 3),
  ('a1000000-0000-0000-0000-000000000004', 'Jewelry & Rings', 'jewelry-rings', 'diamond', 4),
  ('a1000000-0000-0000-0000-000000000005', 'Perfume & Fragrance', 'perfume-fragrance', 'spa', 5),
  ('a1000000-0000-0000-0000-000000000006', 'Collectables', 'collectables', 'stars', 6),
  ('a1000000-0000-0000-0000-000000000007', 'Vinyl & Music', 'vinyl-music', 'album', 7),
  ('a1000000-0000-0000-0000-000000000008', 'Bags & Accessories', 'bags-accessories', 'shopping_bag', 8);

-- ============================================================
-- VENDORS & PRODUCTS
-- Requires at least one signed-up user. Run AFTER signing up.
-- ============================================================

DO $$
DECLARE
  v_user_id UUID;
  v_vendor1 UUID := 'b1000000-0000-0000-0000-000000000001';
  v_vendor2 UUID := 'b1000000-0000-0000-0000-000000000002';
  v_vendor3 UUID := 'b1000000-0000-0000-0000-000000000003';
  v_vendor4 UUID := 'b1000000-0000-0000-0000-000000000004';
  v_vendor5 UUID := 'b1000000-0000-0000-0000-000000000005';
BEGIN
  -- Get the first user profile (the one who signed up)
  SELECT id INTO v_user_id FROM profiles ORDER BY created_at LIMIT 1;

  IF v_user_id IS NULL THEN
    RAISE NOTICE 'No users found. Please sign up first then re-run this script.';
    RETURN;
  END IF;

  -- Insert vendors
  INSERT INTO vendors (id, user_id, store_name, description, logo_url, banner_url, is_approved, is_active, rating, review_count, sales_count)
  VALUES
    (v_vendor1, v_user_id, 'Salaula Kings',
     'Lusaka''s premier vintage streetwear curators. We hunt the best salaula finds so you don''t have to.',
     'https://images.unsplash.com/photo-1531746020798-e6953c6e8e04?w=200&q=80&fit=crop&crop=face',
     'https://images.unsplash.com/photo-1558769132-cb1aea458c5e?w=800&q=80&fit=crop',
     true, true, 4.8, 127, 340),

    (v_vendor2, v_user_id, 'Chibwabwa Vintage',
     'Rare vintage cameras, film equipment and electronics from across the decades.',
     'https://images.unsplash.com/photo-1570295999919-56ceb5ecca61?w=200&q=80&fit=crop&crop=face',
     'https://images.unsplash.com/photo-1516035069371-29a1b244cc32?w=800&q=80&fit=crop',
     true, true, 4.9, 89, 210),

    (v_vendor3, v_user_id, 'Lusaka Drip Co.',
     'Fresh kicks and clean footwear for the streets of Lusaka. Authentic. Always.',
     'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?w=200&q=80&fit=crop&crop=face',
     'https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=800&q=80&fit=crop',
     true, true, 4.7, 203, 520),

    (v_vendor4, v_user_id, 'Ngoma Jewels',
     'Handpicked jewelry, rings and accessories to elevate your aesthetic.',
     'https://images.unsplash.com/photo-1567532939604-b6b5b0db2604?w=200&q=80&fit=crop&crop=face',
     'https://images.unsplash.com/photo-1602173574767-37ac01994b2a?w=800&q=80&fit=crop',
     true, true, 4.6, 74, 180),

    (v_vendor5, v_user_id, 'Kwacha Kollectibles',
     'Vinyl records, vintage radios, collectables and rare cultural artifacts.',
     'https://images.unsplash.com/photo-1499996860823-5214fcc65f8f?w=200&q=80&fit=crop&crop=face',
     'https://images.unsplash.com/photo-1555680202-c86f0e12f086?w=800&q=80&fit=crop',
     true, true, 4.9, 56, 143)
  ON CONFLICT (id) DO NOTHING;

  -- Insert products
  INSERT INTO products (vendor_id, category_id, name, description, price, original_price, stock_quantity, images, is_active, is_featured, rating, review_count)
  VALUES
    -- Streetwear & Fashion
    (v_vendor1, 'a1000000-0000-0000-0000-000000000001',
     'Vintage Denim Jacket — 90s Cut',
     'Classic 90s cut denim jacket, stone washed. Size M. Perfect condition. This is the jacket that started the movement.',
     250.00, 450.00, 3,
     ARRAY['https://images.unsplash.com/photo-1551028719-00167b16eac5?w=600&q=80&fit=crop'],
     true, true, 4.8, 24),

    (v_vendor1, 'a1000000-0000-0000-0000-000000000001',
     'Supreme-Style Box Graphic Tee',
     'Bold graphic tee, heavy cotton 240gsm. Unisex. Size L. Screen printed. Limited run.',
     120.00, NULL, 8,
     ARRAY['https://images.unsplash.com/photo-1576566588028-4147f3842f27?w=600&q=80&fit=crop'],
     true, false, 4.5, 12),

    (v_vendor1, 'a1000000-0000-0000-0000-000000000001',
     'Washed Black Cargo Pants',
     'Vintage cargo trousers, washed black. Multiple utility pockets. Size 32. Street ready.',
     180.00, 280.00, 2,
     ARRAY['https://images.unsplash.com/photo-1582552938357-32b906df40cb?w=600&q=80&fit=crop'],
     true, false, 4.6, 8),

    (v_vendor1, 'a1000000-0000-0000-0000-000000000001',
     'Snapback Cap — Embroidered Logo',
     'Flat brim snapback, adjustable. One size fits all. Mint condition. Classic colorway.',
     85.00, NULL, 15,
     ARRAY['https://images.unsplash.com/photo-1588850561407-ed78c282e89b?w=600&q=80&fit=crop'],
     true, false, 4.3, 19),

    -- Vintage Cameras
    (v_vendor2, 'a1000000-0000-0000-0000-000000000002',
     'Canon AE-1 Film Camera — 1976',
     'Iconic 35mm SLR film camera. Fully functional. Comes with 50mm f/1.8 lens. Film tested and working.',
     1200.00, 1800.00, 1,
     ARRAY['https://images.unsplash.com/photo-1516035069371-29a1b244cc32?w=600&q=80&fit=crop'],
     true, true, 5.0, 7),

    (v_vendor2, 'a1000000-0000-0000-0000-000000000002',
     'Polaroid OneStep Express — Vintage',
     'Classic instant camera. Tested and working. Sold with 1 pack of colour film. Retro styling.',
     650.00, NULL, 2,
     ARRAY['https://images.unsplash.com/photo-1500634245200-36bede1a3f57?w=600&q=80&fit=crop'],
     true, false, 4.9, 11),

    (v_vendor2, 'a1000000-0000-0000-0000-000000000002',
     'Vintage Transistor Radio — 1970s',
     'Working vintage AM/FM radio. Beautiful retro design. Great display piece or functional unit.',
     320.00, NULL, 3,
     ARRAY['https://images.unsplash.com/photo-1572443490709-e57e75f01e23?w=600&q=80&fit=crop'],
     true, false, 4.7, 5),

    -- Sneakers & Footwear
    (v_vendor3, 'a1000000-0000-0000-0000-000000000003',
     'Air Max 90 — Black/White OG',
     'Original Nike Air Max 90 colourway. Size UK 10. 9/10 condition. Lightly used. No box.',
     950.00, 1400.00, 1,
     ARRAY['https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=600&q=80&fit=crop'],
     true, true, 4.8, 33),

    (v_vendor3, 'a1000000-0000-0000-0000-000000000003',
     'New Balance 574 — Heritage Pack',
     'Classic NB 574, suede and mesh upper. Size UK 9. Excellent barely-worn condition.',
     780.00, NULL, 2,
     ARRAY['https://images.unsplash.com/photo-1460353581641-37baddab0fa2?w=600&q=80&fit=crop'],
     true, false, 4.7, 18),

    -- Jewelry & Rings
    (v_vendor4, 'a1000000-0000-0000-0000-000000000004',
     'Sterling Silver Signet Ring',
     'Solid 925 sterling silver signet ring. Size 9. Polished finish. Hallmarked.',
     340.00, 500.00, 6,
     ARRAY['https://images.unsplash.com/photo-1602173574767-37ac01994b2a?w=600&q=80&fit=crop'],
     true, false, 4.9, 22),

    (v_vendor4, 'a1000000-0000-0000-0000-000000000004',
     'Gold-Tone Cuban Link Chain',
     '18K gold plated Cuban link chain, 55cm length, 6mm width. Heavy substantial feel.',
     480.00, NULL, 4,
     ARRAY['https://images.unsplash.com/photo-1611085583191-a3b181a88401?w=600&q=80&fit=crop'],
     true, false, 4.6, 15),

    -- Perfume & Fragrance
    (v_vendor4, 'a1000000-0000-0000-0000-000000000005',
     'Sauvage Dior — 100ml EDP',
     'Authentic Dior Sauvage Eau de Parfum. 100ml, approx 90% remaining. Powerful woody ambery scent.',
     680.00, 950.00, 2,
     ARRAY['https://images.unsplash.com/photo-1541643600914-78b084683702?w=600&q=80&fit=crop'],
     true, true, 4.9, 41),

    -- Collectables
    (v_vendor5, 'a1000000-0000-0000-0000-000000000006',
     'Vintage Rolex Submariner — 1984',
     'Genuine vintage Rolex Submariner ref. 5513. Running movement. Papers not included. Investment piece.',
     18500.00, NULL, 1,
     ARRAY['https://images.unsplash.com/photo-1523275335684-37898b6baf30?w=600&q=80&fit=crop'],
     true, true, 5.0, 3),

    -- Vinyl & Music
    (v_vendor5, 'a1000000-0000-0000-0000-000000000007',
     'Michael Jackson — Thriller LP (1982)',
     'Original first pressing vinyl LP. VG+ play condition, sleeve Near Mint. The world''s best-selling album.',
     420.00, NULL, 1,
     ARRAY['https://images.unsplash.com/photo-1555680202-c86f0e12f086?w=600&q=80&fit=crop'],
     true, false, 4.8, 9),

    -- Bags & Accessories
    (v_vendor1, 'a1000000-0000-0000-0000-000000000008',
     'Vintage Leather Messenger Bag',
     'Full grain leather messenger bag. Beautiful worn-in natural patina. Fits 13" laptop. Brass hardware.',
     550.00, 800.00, 3,
     ARRAY['https://images.unsplash.com/photo-1548036328-c9fa89d128fa?w=600&q=80&fit=crop'],
     true, false, 4.7, 14),

    (v_vendor3, 'a1000000-0000-0000-0000-000000000008',
     'Vintage Wayfarer Sunglasses',
     'Classic wayfarer frame, UV400 polarised lenses. Very good condition. Original hard case included.',
     180.00, NULL, 7,
     ARRAY['https://images.unsplash.com/photo-1572635196237-14b3f281503f?w=600&q=80&fit=crop'],
     true, false, 4.5, 28);

  RAISE NOTICE 'Seed data inserted successfully for user: %', v_user_id;
END $$;
