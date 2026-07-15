CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

INSERT INTO room_types (id, name, description, base_price, capacity, amenities) VALUES
  (uuid_generate_v4(), 'Standard', 'Kamar standar dengan fasilitas lengkap', 500000, 2, '["AC","TV","WiFi","Hot Water"]'),
  (uuid_generate_v4(), 'Deluxe', 'Kamar deluxe dengan pemandangan kota', 850000, 2, '["AC","TV","WiFi","Hot Water","Mini Bar","City View"]'),
  (uuid_generate_v4(), 'Suite', 'Kamar suite mewah dengan ruang tamu', 1500000, 4, '["AC","TV","WiFi","Hot Water","Mini Bar","Living Room","Ocean View","Bathtub"]'),
  (uuid_generate_v4(), 'Presidential', 'Kamar kepresidenan paling mewah', 5000000, 6, '["AC","TV","WiFi","Hot Water","Mini Bar","Living Room","Dining Room","Ocean View","Jacuzzi","Butler Service"]')
ON CONFLICT DO NOTHING;

INSERT INTO rooms (id, room_number, room_type_id, floor, status, price_per_night)
SELECT 
  uuid_generate_v4(),
  floor_num || '-' || LPAD(room_num::text, 2, '0'),
  rt.id,
  floor_num,
  CASE WHEN random() > 0.3 THEN 'AVAILABLE' ELSE 'OCCUPIED' END,
  rt.base_price
FROM generate_series(1, 4) AS floor_num
CROSS JOIN generate_series(1, 5) AS room_num
CROSS JOIN LATERAL (
  SELECT id, base_price FROM room_types 
  ORDER BY random() LIMIT 1
) rt
ON CONFLICT DO NOTHING;

INSERT INTO menu_items (id, name, category, price, description, is_available) VALUES
  (uuid_generate_v4(), 'Nasi Goreng Spesial', 'MAKANAN', 75000, 'Nasi goreng dengan telur, ayam, dan udang', true),
  (uuid_generate_v4(), 'Mie Goreng Seafood', 'MAKANAN', 85000, 'Mie goreng dengan campuran seafood segar', true),
  (uuid_generate_v4(), 'Ayam Bakar Madu', 'MAKANAN', 95000, 'Ayam bakar dengan saus madu spesial', true),
  (uuid_generate_v4(), 'Steak Sirloin', 'MAKANAN', 185000, 'Steak sirloin premium dengan saus lada hitam', true),
  (uuid_generate_v4(), 'Caesar Salad', 'MAKANAN', 65000, 'Salad segar dengan dressing caesar', true),
  (uuid_generate_v4(), 'Es Teh Manis', 'MINUMAN', 25000, 'Teh manis segar dengan es', true),
  (uuid_generate_v4(), 'Jus Alpukat', 'MINUMAN', 35000, 'Jus alpukat segar dengan susu', true),
  (uuid_generate_v4(), 'Cappuccino', 'MINUMAN', 45000, 'Kopi cappuccino dengan foam lembut', true),
  (uuid_generate_v4(), 'Fresh Orange Juice', 'MINUMAN', 40000, 'Jus jeruk segar tanpa gula', true),
  (uuid_generate_v4(), 'Mineral Water', 'MINUMAN', 15000, 'Air mineral 600ml', true)
ON CONFLICT DO NOTHING;