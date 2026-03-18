-- ============================================================
-- Marketplace — Supabase Database Schema
-- Run this in: Supabase Dashboard → SQL Editor → New Query
-- ============================================================

-- ── Extensions ───────────────────────────────────────────────
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ── Profiles (extends auth.users) ────────────────────────────
CREATE TABLE IF NOT EXISTS profiles (
  id            UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  full_name     TEXT,
  phone         TEXT,
  avatar_url    TEXT,
  is_vendor     BOOLEAN DEFAULT FALSE,
  created_at    TIMESTAMPTZ DEFAULT NOW(),
  updated_at    TIMESTAMPTZ DEFAULT NOW()
);

-- Auto-create profile on signup
CREATE OR REPLACE FUNCTION handle_new_user()
RETURNS TRIGGER LANGUAGE plpgsql SECURITY DEFINER AS $$
BEGIN
  INSERT INTO public.profiles (id, full_name, phone)
  VALUES (
    NEW.id,
    NEW.raw_user_meta_data->>'full_name',
    NEW.raw_user_meta_data->>'phone'
  )
  ON CONFLICT (id) DO NOTHING;
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION handle_new_user();

-- ── Categories ───────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS categories (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name        TEXT NOT NULL,
  slug        TEXT UNIQUE,
  icon        TEXT,
  image_url   TEXT,
  parent_id   UUID REFERENCES categories(id),
  sort_order  INT DEFAULT 0,
  created_at  TIMESTAMPTZ DEFAULT NOW()
);

-- ── Vendors ──────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS vendors (
  id               UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id          UUID UNIQUE REFERENCES profiles(id) ON DELETE CASCADE,
  store_name       TEXT NOT NULL,
  description      TEXT,
  logo_url         TEXT,
  banner_url       TEXT,
  phone            TEXT,
  email            TEXT,
  address          JSONB,
  is_approved      BOOLEAN DEFAULT FALSE,
  is_active        BOOLEAN DEFAULT TRUE,
  commission_rate  FLOAT DEFAULT 0.10,
  rating           FLOAT DEFAULT 0,
  review_count     INT DEFAULT 0,
  sales_count      INT DEFAULT 0,
  created_at       TIMESTAMPTZ DEFAULT NOW(),
  updated_at       TIMESTAMPTZ DEFAULT NOW()
);

-- ── Products ─────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS products (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  vendor_id       UUID REFERENCES vendors(id) ON DELETE CASCADE,
  category_id     UUID REFERENCES categories(id),
  name            TEXT NOT NULL,
  description     TEXT,
  price           FLOAT NOT NULL CHECK (price >= 0),
  original_price  FLOAT,
  stock_quantity  INT DEFAULT 0 CHECK (stock_quantity >= 0),
  images          TEXT[] DEFAULT '{}',
  tags            TEXT[] DEFAULT '{}',
  specifications  JSONB DEFAULT '{}',
  is_active       BOOLEAN DEFAULT TRUE,
  is_featured     BOOLEAN DEFAULT FALSE,
  rating          FLOAT DEFAULT 0,
  review_count    INT DEFAULT 0,
  sales_count     INT DEFAULT 0,
  created_at      TIMESTAMPTZ DEFAULT NOW(),
  updated_at      TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_products_vendor ON products(vendor_id);
CREATE INDEX IF NOT EXISTS idx_products_category ON products(category_id);
CREATE INDEX IF NOT EXISTS idx_products_active ON products(is_active);
CREATE INDEX IF NOT EXISTS idx_products_search ON products USING GIN (to_tsvector('english', name || ' ' || COALESCE(description, '')));

-- ── Cart ─────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS cart_items (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id     UUID REFERENCES profiles(id) ON DELETE CASCADE,
  product_id  UUID REFERENCES products(id) ON DELETE CASCADE,
  quantity    INT NOT NULL DEFAULT 1 CHECK (quantity > 0),
  created_at  TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE (user_id, product_id)
);

-- ── Wishlist ─────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS wishlist (
  user_id     UUID REFERENCES profiles(id) ON DELETE CASCADE,
  product_id  UUID REFERENCES products(id) ON DELETE CASCADE,
  created_at  TIMESTAMPTZ DEFAULT NOW(),
  PRIMARY KEY (user_id, product_id)
);

-- ── Addresses ────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS addresses (
  id           UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id      UUID REFERENCES profiles(id) ON DELETE CASCADE,
  label        TEXT DEFAULT 'Home',
  full_name    TEXT NOT NULL,
  phone        TEXT,
  street       TEXT NOT NULL,
  city         TEXT NOT NULL,
  province     TEXT,
  postal_code  TEXT,
  country      TEXT DEFAULT 'Zambia',
  is_default   BOOLEAN DEFAULT FALSE,
  created_at   TIMESTAMPTZ DEFAULT NOW()
);

-- ── Orders ───────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS orders (
  id                UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id           UUID REFERENCES profiles(id),
  status            TEXT DEFAULT 'pending'
                    CHECK (status IN ('pending','confirmed','processing','shipped','delivered','cancelled','refunded')),
  total_amount      FLOAT NOT NULL,
  shipping_amount   FLOAT DEFAULT 0,
  discount_amount   FLOAT DEFAULT 0,
  shipping_address  JSONB,
  payment_method    TEXT,
  payment_status    TEXT DEFAULT 'pending',
  notes             TEXT,
  created_at        TIMESTAMPTZ DEFAULT NOW(),
  updated_at        TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_orders_user ON orders(user_id);
CREATE INDEX IF NOT EXISTS idx_orders_status ON orders(status);

-- ── Order Items ───────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS order_items (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  order_id    UUID REFERENCES orders(id) ON DELETE CASCADE,
  product_id  UUID REFERENCES products(id),
  vendor_id   UUID REFERENCES vendors(id),
  name        TEXT NOT NULL,
  image_url   TEXT,
  quantity    INT NOT NULL,
  price       FLOAT NOT NULL
);

-- ── Reviews ──────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS reviews (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  product_id  UUID REFERENCES products(id) ON DELETE CASCADE,
  user_id     UUID REFERENCES profiles(id) ON DELETE CASCADE,
  rating      INT NOT NULL CHECK (rating BETWEEN 1 AND 5),
  comment     TEXT,
  images      TEXT[] DEFAULT '{}',
  created_at  TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE (product_id, user_id)
);

-- Auto-update product rating on review insert/update/delete
CREATE OR REPLACE FUNCTION update_product_rating()
RETURNS TRIGGER LANGUAGE plpgsql AS $$
BEGIN
  UPDATE products SET
    rating       = (SELECT AVG(rating)   FROM reviews WHERE product_id = COALESCE(NEW.product_id, OLD.product_id)),
    review_count = (SELECT COUNT(*)      FROM reviews WHERE product_id = COALESCE(NEW.product_id, OLD.product_id))
  WHERE id = COALESCE(NEW.product_id, OLD.product_id);
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_update_product_rating ON reviews;
CREATE TRIGGER trg_update_product_rating
  AFTER INSERT OR UPDATE OR DELETE ON reviews
  FOR EACH ROW EXECUTE FUNCTION update_product_rating();

-- ── Notifications ────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS notifications (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id     UUID REFERENCES profiles(id) ON DELETE CASCADE,
  title       TEXT NOT NULL,
  body        TEXT NOT NULL,
  type        TEXT DEFAULT 'general',
  data        JSONB DEFAULT '{}',
  is_read     BOOLEAN DEFAULT FALSE,
  created_at  TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_notifications_user ON notifications(user_id, is_read);

-- ── Chat ─────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS chat_rooms (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id         UUID REFERENCES profiles(id) ON DELETE CASCADE,
  vendor_id       UUID REFERENCES vendors(id) ON DELETE CASCADE,
  last_message    TEXT,
  last_message_at TIMESTAMPTZ,
  created_at      TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE (user_id, vendor_id)
);

CREATE TABLE IF NOT EXISTS messages (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  room_id     UUID REFERENCES chat_rooms(id) ON DELETE CASCADE,
  sender_id   UUID REFERENCES profiles(id) ON DELETE CASCADE,
  content     TEXT NOT NULL,
  is_read     BOOLEAN DEFAULT FALSE,
  created_at  TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_messages_room ON messages(room_id, created_at);

-- ── Row Level Security ────────────────────────────────────────
ALTER TABLE profiles        ENABLE ROW LEVEL SECURITY;
ALTER TABLE vendors         ENABLE ROW LEVEL SECURITY;
ALTER TABLE products        ENABLE ROW LEVEL SECURITY;
ALTER TABLE cart_items      ENABLE ROW LEVEL SECURITY;
ALTER TABLE wishlist        ENABLE ROW LEVEL SECURITY;
ALTER TABLE addresses       ENABLE ROW LEVEL SECURITY;
ALTER TABLE orders          ENABLE ROW LEVEL SECURITY;
ALTER TABLE order_items     ENABLE ROW LEVEL SECURITY;
ALTER TABLE reviews         ENABLE ROW LEVEL SECURITY;
ALTER TABLE notifications   ENABLE ROW LEVEL SECURITY;
ALTER TABLE chat_rooms      ENABLE ROW LEVEL SECURITY;
ALTER TABLE messages        ENABLE ROW LEVEL SECURITY;

-- Profiles: users can read all, edit only their own
DROP POLICY IF EXISTS "Profiles are viewable by everyone"   ON profiles;
DROP POLICY IF EXISTS "Users can update own profile"        ON profiles;
CREATE POLICY "Profiles are viewable by everyone"   ON profiles FOR SELECT USING (TRUE);
CREATE POLICY "Users can update own profile"        ON profiles FOR UPDATE USING (auth.uid() = id);

-- Products: public read, vendors manage their own
DROP POLICY IF EXISTS "Products are publicly viewable"  ON products;
DROP POLICY IF EXISTS "Vendors can manage own products" ON products;
CREATE POLICY "Products are publicly viewable"      ON products FOR SELECT USING (is_active = TRUE);
CREATE POLICY "Vendors can manage own products"     ON products FOR ALL
  USING (vendor_id IN (SELECT id FROM vendors WHERE user_id = auth.uid()));

-- Categories: public read
DROP POLICY IF EXISTS "Categories are publicly viewable" ON categories;
CREATE POLICY "Categories are publicly viewable"    ON categories FOR SELECT USING (TRUE);

-- Cart: users see only their own
DROP POLICY IF EXISTS "Users manage own cart" ON cart_items;
CREATE POLICY "Users manage own cart"               ON cart_items FOR ALL USING (user_id = auth.uid());

-- Wishlist: users see only their own
DROP POLICY IF EXISTS "Users manage own wishlist" ON wishlist;
CREATE POLICY "Users manage own wishlist"           ON wishlist FOR ALL USING (user_id = auth.uid());

-- Addresses: users see only their own
DROP POLICY IF EXISTS "Users manage own addresses" ON addresses;
CREATE POLICY "Users manage own addresses"          ON addresses FOR ALL USING (user_id = auth.uid());

-- Orders: users see only their own
DROP POLICY IF EXISTS "Users view own orders"               ON orders;
DROP POLICY IF EXISTS "Users create own orders"             ON orders;
DROP POLICY IF EXISTS "Order items viewable by order owner" ON order_items;
CREATE POLICY "Users view own orders"               ON orders FOR SELECT USING (user_id = auth.uid());
CREATE POLICY "Users create own orders"             ON orders FOR INSERT WITH CHECK (user_id = auth.uid());
CREATE POLICY "Order items viewable by order owner" ON order_items FOR SELECT
  USING (order_id IN (SELECT id FROM orders WHERE user_id = auth.uid()));

-- Reviews: public read, users manage own
DROP POLICY IF EXISTS "Reviews are publicly viewable" ON reviews;
DROP POLICY IF EXISTS "Users manage own reviews"      ON reviews;
CREATE POLICY "Reviews are publicly viewable"       ON reviews FOR SELECT USING (TRUE);
CREATE POLICY "Users manage own reviews"            ON reviews FOR ALL USING (user_id = auth.uid());

-- Notifications: users see only their own
DROP POLICY IF EXISTS "Users view own notifications" ON notifications;
CREATE POLICY "Users view own notifications"        ON notifications FOR ALL USING (user_id = auth.uid());

-- Vendors: public read
DROP POLICY IF EXISTS "Vendors are publicly viewable" ON vendors;
DROP POLICY IF EXISTS "Vendors manage own store"      ON vendors;
CREATE POLICY "Vendors are publicly viewable"       ON vendors FOR SELECT USING (is_active = TRUE);
CREATE POLICY "Vendors manage own store"            ON vendors FOR ALL USING (user_id = auth.uid());

-- Chat: users see their own rooms, vendors see rooms for their store
DROP POLICY IF EXISTS "Chat room access" ON chat_rooms;
DROP POLICY IF EXISTS "Message access"   ON messages;
CREATE POLICY "Chat room access"                    ON chat_rooms FOR ALL
  USING (user_id = auth.uid() OR vendor_id IN (SELECT id FROM vendors WHERE user_id = auth.uid()));
CREATE POLICY "Message access"                      ON messages FOR ALL
  USING (room_id IN (
    SELECT id FROM chat_rooms
    WHERE user_id = auth.uid() OR vendor_id IN (SELECT id FROM vendors WHERE user_id = auth.uid())
  ));

-- ── Sample Categories ─────────────────────────────────────────
INSERT INTO categories (name, slug, icon) VALUES
  ('Electronics',    'electronics',     'devices'),
  ('Fashion',        'fashion',         'checkroom'),
  ('Home & Garden',  'home-garden',     'cottage'),
  ('Sports',         'sports',          'sports_soccer'),
  ('Beauty',         'beauty',          'spa'),
  ('Food & Drinks',  'food-drinks',     'restaurant'),
  ('Books',          'books',           'menu_book'),
  ('Toys & Kids',    'toys-kids',       'toys')
ON CONFLICT (slug) DO NOTHING;
