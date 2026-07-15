-- ============================================
-- SEED DATA LENGKAP (FINAL FIX)
-- ============================================

-- 1. Room Types (TIDAK ADA updated_at)
INSERT INTO room_types (id, name, description, base_price, capacity, amenities, created_at) VALUES
  ('rt-001', 'Standard', 'Kamar standar dengan fasilitas lengkap', 500000, 2, '{"AC","TV","WiFi","Hot Water"}', NOW()),
  ('rt-002', 'Deluxe', 'Kamar deluxe dengan pemandangan kota', 850000, 2, '{"AC","TV","WiFi","Hot Water","Mini Bar","City View"}', NOW()),
  ('rt-003', 'Suite', 'Kamar suite mewah dengan ruang tamu', 1500000, 4, '{"AC","TV","WiFi","Hot Water","Mini Bar","Living Room","Ocean View","Bathtub"}', NOW()),
  ('rt-004', 'Presidential', 'Kamar kepresidenan paling mewah', 5000000, 6, '{"AC","TV","WiFi","Hot Water","Mini Bar","Living Room","Dining Room","Ocean View","Jacuzzi","Butler Service"}', NOW())
ON CONFLICT DO NOTHING;

-- 2. Rooms (20 kamar)
INSERT INTO rooms (id, room_number, room_type_id, floor, status, price_per_night, updated_at) VALUES
  ('r-101', '1-01', 'rt-001', 1, 'AVAILABLE', 500000, NOW()),
  ('r-102', '1-02', 'rt-001', 1, 'AVAILABLE', 500000, NOW()),
  ('r-103', '1-03', 'rt-001', 1, 'OCCUPIED', 500000, NOW()),
  ('r-104', '1-04', 'rt-001', 1, 'AVAILABLE', 500000, NOW()),
  ('r-105', '1-05', 'rt-001', 1, 'MAINTENANCE', 500000, NOW()),
  ('r-201', '2-01', 'rt-002', 2, 'AVAILABLE', 850000, NOW()),
  ('r-202', '2-02', 'rt-002', 2, 'OCCUPIED', 850000, NOW()),
  ('r-203', '2-03', 'rt-002', 2, 'AVAILABLE', 850000, NOW()),
  ('r-204', '2-04', 'rt-002', 2, 'RESERVED', 850000, NOW()),
  ('r-205', '2-05', 'rt-002', 2, 'AVAILABLE', 850000, NOW()),
  ('r-301', '3-01', 'rt-003', 3, 'AVAILABLE', 1500000, NOW()),
  ('r-302', '3-02', 'rt-003', 3, 'OCCUPIED', 1500000, NOW()),
  ('r-303', '3-03', 'rt-003', 3, 'AVAILABLE', 1500000, NOW()),
  ('r-304', '3-04', 'rt-003', 3, 'AVAILABLE', 1500000, NOW()),
  ('r-305', '3-05', 'rt-003', 3, 'CLEANING', 1500000, NOW()),
  ('r-401', '4-01', 'rt-004', 4, 'AVAILABLE', 5000000, NOW()),
  ('r-402', '4-02', 'rt-004', 4, 'OCCUPIED', 5000000, NOW()),
  ('r-403', '4-03', 'rt-004', 4, 'AVAILABLE', 5000000, NOW()),
  ('r-404', '4-04', 'rt-004', 4, 'AVAILABLE', 5000000, NOW()),
  ('r-405', '4-05', 'rt-004', 4, 'AVAILABLE', 5000000, NOW())
ON CONFLICT DO NOTHING;

-- 3. Guests
INSERT INTO guests (id, first_name, last_name, email, phone, id_card_number, nationality, address, vip_status, updated_at) VALUES
  ('g-001', 'Budi', 'Santoso', 'budi.santoso@email.com', '081234567890', '3201012345678901', 'Indonesia', 'Jl. Sudirman No. 123, Jakarta', false, NOW()),
  ('g-002', 'Siti', 'Aminah', 'siti.aminah@email.com', '081234567891', '3201012345678902', 'Indonesia', 'Jl. Thamrin No. 45, Jakarta', true, NOW()),
  ('g-003', 'John', 'Smith', 'john.smith@email.com', '081234567892', 'P1234567', 'USA', '123 Main St, New York', false, NOW()),
  ('g-004', 'Yuki', 'Tanaka', 'yuki.tanaka@email.com', '081234567893', 'AB1234567', 'Japan', '456 Tokyo St, Tokyo', true, NOW()),
  ('g-005', 'Ahmad', 'Rahman', 'ahmad.rahman@email.com', '081234567894', '3201012345678903', 'Indonesia', 'Jl. Gatot Subroto No. 78, Bandung', false, NOW())
ON CONFLICT DO NOTHING;

-- 4. Bookings
INSERT INTO bookings (id, booking_number, guest_id, room_id, room_type_id, check_in, check_out, adults, children, total_price, status, special_request, updated_at) VALUES
  ('b-001', 'BK20260701001', 'g-001', 'r-103', 'rt-001', '2026-07-01', '2026-07-03', 2, 0, 1000000, 'CHECKED_IN', 'Extra bed', NOW()),
  ('b-002', 'BK20260701002', 'g-002', 'r-202', 'rt-002', '2026-07-01', '2026-07-05', 2, 1, 3400000, 'CHECKED_IN', 'High floor', NOW()),
  ('b-003', 'BK20260701003', 'g-003', 'r-302', 'rt-003', '2026-07-02', '2026-07-06', 2, 0, 6000000, 'CONFIRMED', 'Ocean view room', NOW()),
  ('b-004', 'BK20260701004', 'g-004', 'r-402', 'rt-004', '2026-07-03', '2026-07-07', 4, 2, 20000000, 'CONFIRMED', 'Presidential suite', NOW()),
  ('b-005', 'BK20260701005', 'g-005', 'r-204', 'rt-002', '2026-07-05', '2026-07-08', 1, 0, 2550000, 'PENDING', NULL, NOW())
ON CONFLICT DO NOTHING;

-- 5. Orders (Restaurant)
INSERT INTO orders (id, order_number, guest_id, room_number, order_type, total_amount, status, updated_at) VALUES
  ('o-001', 'RM20260701001', 'g-001', NULL, 'RESTAURANT', 160000, 'COMPLETED', NOW()),
  ('o-002', 'RS20260701002', 'g-002', '2-02', 'ROOM_SERVICE', 220000, 'DELIVERED', NOW()),
  ('o-003', 'RM20260701003', 'g-003', NULL, 'RESTAURANT', 185000, 'PENDING', NOW())
ON CONFLICT DO NOTHING;

-- 6. Order Items
INSERT INTO order_items (id, order_id, menu_item_id, quantity, price) VALUES
  ('oi-001', 'o-001', (SELECT id FROM menu_items WHERE name = 'Nasi Goreng Spesial'), 2, 75000),
  ('oi-002', 'o-001', (SELECT id FROM menu_items WHERE name = 'Es Teh Manis'), 2, 25000),
  ('oi-003', 'o-002', (SELECT id FROM menu_items WHERE name = 'Mie Goreng Seafood'), 1, 85000),
  ('oi-004', 'o-002', (SELECT id FROM menu_items WHERE name = 'Jus Alpukat'), 2, 35000),
  ('oi-005', 'o-002', (SELECT id FROM menu_items WHERE name = 'Mineral Water'), 1, 15000),
  ('oi-006', 'o-003', (SELECT id FROM menu_items WHERE name = 'Steak Sirloin'), 1, 185000)
ON CONFLICT DO NOTHING;

-- 7. Payments
INSERT INTO payments (id, payment_number, booking_id, order_id, amount, payment_method, payment_status, paid_at) VALUES
  ('p-001', 'PAY20260701001', 'b-001', NULL, 1000000, 'CREDIT_CARD', 'SUCCESS', '2026-07-01 10:30:00'),
  ('p-002', 'PAY20260701002', NULL, 'o-001', 160000, 'CASH', 'SUCCESS', '2026-07-01 12:15:00'),
  ('p-003', 'PAY20260701003', NULL, 'o-002', 220000, 'E_WALLET', 'SUCCESS', '2026-07-01 14:20:00'),
  ('p-004', 'PAY20260701004', 'b-002', NULL, 3400000, 'BANK_TRANSFER', 'PENDING', NULL),
  ('p-005', 'PAY20260701005', NULL, 'o-003', 185000, 'QRIS', 'PENDING', NULL)
ON CONFLICT DO NOTHING;

-- 8. Update Menu Items dengan Gambar
UPDATE menu_items SET image = '/images/menu/nasi-goreng.jpg' WHERE name = 'Nasi Goreng Spesial';
UPDATE menu_items SET image = '/images/menu/mie-goreng.jpg' WHERE name = 'Mie Goreng Seafood';
UPDATE menu_items SET image = '/images/menu/ayam-bakar.jpg' WHERE name = 'Ayam Bakar Madu';
UPDATE menu_items SET image = '/images/menu/steak.jpg' WHERE name = 'Steak Sirloin';
UPDATE menu_items SET image = '/images/menu/caesar-salad.jpg' WHERE name = 'Caesar Salad';
UPDATE menu_items SET image = '/images/menu/es-teh.jpg' WHERE name = 'Es Teh Manis';
UPDATE menu_items SET image = '/images/menu/jus-alpukat.jpg' WHERE name = 'Jus Alpukat';
UPDATE menu_items SET image = '/images/menu/cappuccino.jpg' WHERE name = 'Cappuccino';