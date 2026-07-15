# write-code.ps1 - Auto-generate all code files
# Hotel Management System

Write-Host "🏨 Writing all code files..." -ForegroundColor Cyan

# ============================================
# 1. .env
# ============================================
@'
DATABASE_URL="postgresql://hotel_admin:hotel_secret_2024@localhost:5432/hotel_management?schema=public"
NEXT_PUBLIC_APP_NAME="Grand Hotel Management"
NEXT_PUBLIC_APP_URL="http://localhost:3000"
MIDTRANS_SERVER_KEY="your-server-key"
MIDTRANS_CLIENT_KEY="your-client-key"
MIDTRANS_IS_PRODUCTION=false
'@ | Set-Content -Path ".env" -Encoding UTF8
Write-Host "✅ .env" -ForegroundColor Green

# ============================================
# 2. .gitignore
# ============================================
@'
node_modules/
.next/
out/
build/
dist/
*.log
.env
.env*.local
.vercel
*.tsbuildinfo
next-env.d.ts
.vscode/
.idea/
.DS_Store
Thumbs.db
prisma/migrations/
postgres_data/
'@ | Set-Content -Path ".gitignore" -Encoding UTF8
Write-Host "✅ .gitignore" -ForegroundColor Green

# ============================================
# 3. docker-compose.yml
# ============================================
@'
version: '3.8'

services:
  postgres:
    image: postgres:15-alpine
    container_name: hotel_db
    environment:
      POSTGRES_USER: hotel_admin
      POSTGRES_PASSWORD: hotel_secret_2024
      POSTGRES_DB: hotel_management
    ports:
      - "5432:5432"
    volumes:
      - postgres_data:/var/lib/postgresql/data
      - ./init.sql:/docker-entrypoint-initdb.d/init.sql
    networks:
      - hotel_network
    restart: unless-stopped

  pgadmin:
    image: dpage/pgadmin4:latest
    container_name: hotel_pgadmin
    environment:
      PGADMIN_DEFAULT_EMAIL: admin@hotel.com
      PGADMIN_DEFAULT_PASSWORD: admin123
    ports:
      - "5050:80"
    depends_on:
      - postgres
    networks:
      - hotel_network
    restart: unless-stopped

volumes:
  postgres_data:

networks:
  hotel_network:
    driver: bridge
'@ | Set-Content -Path "docker-compose.yml" -Encoding UTF8
Write-Host "✅ docker-compose.yml" -ForegroundColor Green

# ============================================
# 4. init.sql
# ============================================
@'
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
'@ | Set-Content -Path "init.sql" -Encoding UTF8
Write-Host "✅ init.sql" -ForegroundColor Green

# ============================================
# 5. package.json
# ============================================
@'
{
  "name": "hotel-management-system",
  "version": "1.0.0",
  "private": true,
  "scripts": {
    "dev": "next dev",
    "build": "next build",
    "start": "next start",
    "lint": "next lint",
    "db:push": "prisma db push",
    "db:studio": "prisma studio",
    "postinstall": "prisma generate"
  },
  "dependencies": {
    "@prisma/client": "^5.10.0",
    "next": "14.1.0",
    "react": "^18.2.0",
    "react-dom": "^18.2.0",
    "react-icons": "^5.0.1",
    "date-fns": "^3.3.1",
    "clsx": "^2.1.0",
    "sonner": "^1.4.0"
  },
  "devDependencies": {
    "@types/node": "^20",
    "@types/react": "^18",
    "@types/react-dom": "^18",
    "autoprefixer": "^10.4.17",
    "postcss": "^8.4.35",
    "prisma": "^5.10.0",
    "tailwindcss": "^3.4.1",
    "typescript": "^5"
  }
}
'@ | Set-Content -Path "package.json" -Encoding UTF8
Write-Host "✅ package.json" -ForegroundColor Green

# ============================================
# 6. next.config.js
# ============================================
@'
/** @type {import('next').NextConfig} */
const nextConfig = {
  experimental: {
    serverActions: true,
  },
};

module.exports = nextConfig;
'@ | Set-Content -Path "next.config.js" -Encoding UTF8
Write-Host "✅ next.config.js" -ForegroundColor Green

# ============================================
# 7. tailwind.config.ts
# ============================================
@'
import type { Config } from 'tailwindcss';

const config: Config = {
  content: [
    './src/pages/**/*.{js,ts,jsx,tsx,mdx}',
    './src/components/**/*.{js,ts,jsx,tsx,mdx}',
    './src/app/**/*.{js,ts,jsx,tsx,mdx}',
  ],
  theme: {
    extend: {
      colors: {
        hotel: {
          50: '#f0f7ff',
          100: '#e0effe',
          200: '#bae0fd',
          300: '#7cc8fb',
          400: '#36adf6',
          500: '#0c93e7',
          600: '#0074c5',
          700: '#015da0',
          800: '#065084',
          900: '#0b436e',
          950: '#072b49',
        },
        gold: {
          50: '#fdfbea',
          100: '#fbf5c6',
          200: '#f8e98f',
          300: '#f4d64d',
          400: '#efc020',
          500: '#e0a50d',
          600: '#c48008',
          700: '#9e5c0a',
          800: '#834910',
          900: '#6f3c13',
          950: '#401e06',
        },
      },
    },
  },
  plugins: [],
};

export default config;
'@ | Set-Content -Path "tailwind.config.ts" -Encoding UTF8
Write-Host "✅ tailwind.config.ts" -ForegroundColor Green

# ============================================
# 8. tsconfig.json
# ============================================
@'
{
  "compilerOptions": {
    "lib": ["dom", "dom.iterable", "esnext"],
    "allowJs": true,
    "skipLibCheck": true,
    "strict": true,
    "noEmit": true,
    "esModuleInterop": true,
    "module": "esnext",
    "moduleResolution": "bundler",
    "resolveJsonModule": true,
    "isolatedModules": true,
    "jsx": "preserve",
    "incremental": true,
    "plugins": [{ "name": "next" }],
    "paths": {
      "@/*": ["./src/*"]
    }
  },
  "include": ["next-env.d.ts", "**/*.ts", "**/*.tsx", ".next/types/**/*.ts"],
  "exclude": ["node_modules"]
}
'@ | Set-Content -Path "tsconfig.json" -Encoding UTF8
Write-Host "✅ tsconfig.json" -ForegroundColor Green

# ============================================
# 9. postcss.config.js
# ============================================
@'
module.exports = {
  plugins: {
    tailwindcss: {},
    autoprefixer: {},
  },
};
'@ | Set-Content -Path "postcss.config.js" -Encoding UTF8
Write-Host "✅ postcss.config.js" -ForegroundColor Green

# ============================================
# 10. prisma/schema.prisma
# ============================================
@'
generator client {
  provider = "prisma-client-js"
}

datasource db {
  provider = "postgresql"
  url      = env("DATABASE_URL")
}

model Guest {
  id            String   @id @default(uuid())
  firstName     String   @map("first_name")
  lastName      String   @map("last_name")
  email         String   @unique
  phone         String
  idCardNumber  String?  @map("id_card_number")
  nationality   String?
  address       String?
  vipStatus     Boolean  @default(false) @map("vip_status")
  notes         String?
  createdAt     DateTime @default(now()) @map("created_at")
  updatedAt     DateTime @updatedAt @map("updated_at")

  bookings      Booking[]
  orders        Order[]

  @@map("guests")
}

model RoomType {
  id          String   @id @default(uuid())
  name        String
  description String?
  basePrice   Int      @map("base_price")
  capacity    Int
  amenities   String[] @default([])
  isActive    Boolean  @default(true) @map("is_active")
  createdAt   DateTime @default(now()) @map("created_at")

  rooms       Room[]
  bookings    Booking[]

  @@map("room_types")
}

model Room {
  id            String      @id @default(uuid())
  roomNumber    String      @unique @map("room_number")
  roomTypeId    String      @map("room_type_id")
  floor         Int
  status        RoomStatus  @default(AVAILABLE)
  pricePerNight Int         @map("price_per_night")
  notes         String?
  createdAt     DateTime    @default(now()) @map("created_at")
  updatedAt     DateTime    @updatedAt @map("updated_at")

  roomType      RoomType    @relation(fields: [roomTypeId], references: [id])
  bookings      Booking[]

  @@map("rooms")
}

enum RoomStatus {
  AVAILABLE
  OCCUPIED
  MAINTENANCE
  RESERVED
  CLEANING
}

model Booking {
  id              String        @id @default(uuid())
  bookingNumber   String        @unique @map("booking_number")
  guestId         String        @map("guest_id")
  roomId          String        @map("room_id")
  roomTypeId      String        @map("room_type_id")
  checkIn         DateTime      @map("check_in")
  checkOut        DateTime      @map("check_out")
  adults          Int           @default(1)
  children        Int           @default(0)
  totalPrice      Int           @map("total_price")
  status          BookingStatus @default(CONFIRMED)
  specialRequest  String?       @map("special_request")
  createdAt       DateTime      @default(now()) @map("created_at")
  updatedAt       DateTime      @updatedAt @map("updated_at")

  guest           Guest         @relation(fields: [guestId], references: [id])
  room            Room          @relation(fields: [roomId], references: [id])
  roomType        RoomType      @relation(fields: [roomTypeId], references: [id])
  payments        Payment[]

  @@map("bookings")
}

enum BookingStatus {
  PENDING
  CONFIRMED
  CHECKED_IN
  CHECKED_OUT
  CANCELLED
  NO_SHOW
}

model MenuItem {
  id           String       @id @default(uuid())
  name         String
  category     MenuCategory
  price        Int
  description  String?
  image        String?
  isAvailable  Boolean      @default(true) @map("is_available")
  createdAt    DateTime     @default(now()) @map("created_at")

  orderItems   OrderItem[]

  @@map("menu_items")
}

enum MenuCategory {
  MAKANAN
  MINUMAN
  SNACK
  DESSERT
}

model Order {
  id          String      @id @default(uuid())
  orderNumber String      @unique @map("order_number")
  guestId     String?     @map("guest_id")
  roomNumber  String?     @map("room_number")
  orderType   OrderType   @map("order_type")
  totalAmount Int         @map("total_amount")
  status      OrderStatus @default(PENDING)
  notes       String?
  createdAt   DateTime    @default(now()) @map("created_at")
  updatedAt   DateTime    @updatedAt @map("updated_at")

  guest       Guest?      @relation(fields: [guestId], references: [id])
  items       OrderItem[]
  payments    Payment[]

  @@map("orders")
}

enum OrderType {
  RESTAURANT
  ROOM_SERVICE
}

enum OrderStatus {
  PENDING
  PREPARING
  READY
  DELIVERED
  COMPLETED
  CANCELLED
}

model OrderItem {
  id         String  @id @default(uuid())
  orderId    String  @map("order_id")
  menuItemId String  @map("menu_item_id")
  quantity   Int
  price      Int
  notes      String?

  order      Order    @relation(fields: [orderId], references: [id], onDelete: Cascade)
  menuItem   MenuItem @relation(fields: [menuItemId], references: [id])

  @@map("order_items")
}

model Payment {
  id              String        @id @default(uuid())
  paymentNumber   String        @unique @map("payment_number")
  bookingId       String?       @map("booking_id")
  orderId         String?       @map("order_id")
  amount          Int
  paymentMethod   PaymentMethod @map("payment_method")
  paymentStatus   PaymentStatus @default(PENDING) @map("payment_status")
  transactionId   String?       @map("transaction_id")
  paidAt          DateTime?     @map("paid_at")
  notes           String?
  createdAt       DateTime      @default(now()) @map("created_at")

  booking         Booking?      @relation(fields: [bookingId], references: [id])
  order           Order?        @relation(fields: [orderId], references: [id])

  @@map("payments")
}

enum PaymentMethod {
  CASH
  CREDIT_CARD
  DEBIT_CARD
  BANK_TRANSFER
  E_WALLET
  QRIS
}

enum PaymentStatus {
  PENDING
  PROCESSING
  SUCCESS
  FAILED
  REFUNDED
}
'@ | Set-Content -Path "prisma/schema.prisma" -Encoding UTF8
Write-Host "✅ prisma/schema.prisma" -ForegroundColor Green

Write-Host "`n📦 Config files done! Writing source code..." -ForegroundColor Cyan

# ============================================
# 11. src/app/globals.css
# ============================================
@'
@tailwind base;
@tailwind components;
@tailwind utilities;

@layer base {
  body {
    @apply bg-gray-50 text-gray-900 antialiased;
  }
}

@layer components {
  .btn-primary {
    @apply bg-hotel-600 hover:bg-hotel-700 text-white font-medium py-2.5 px-5 rounded-lg 
           transition-all duration-200 shadow-sm hover:shadow-md active:scale-[0.98];
  }

  .btn-secondary {
    @apply bg-white hover:bg-gray-50 text-gray-700 font-medium py-2.5 px-5 rounded-lg 
           border border-gray-300 transition-all duration-200 shadow-sm hover:shadow-md;
  }

  .btn-danger {
    @apply bg-red-600 hover:bg-red-700 text-white font-medium py-2.5 px-5 rounded-lg 
           transition-all duration-200 shadow-sm hover:shadow-md;
  }

  .card {
    @apply bg-white rounded-xl shadow-sm border border-gray-200 p-6;
  }

  .input-field {
    @apply w-full px-4 py-2.5 border border-gray-300 rounded-lg 
           focus:ring-2 focus:ring-hotel-500 focus:border-hotel-500 
           outline-none transition-all duration-200 text-sm;
  }

  .label-field {
    @apply block text-sm font-medium text-gray-700 mb-1.5;
  }

  .table-header {
    @apply px-6 py-3.5 text-left text-xs font-semibold text-gray-600 uppercase tracking-wider bg-gray-50;
  }

  .table-cell {
    @apply px-6 py-4 text-sm text-gray-700 whitespace-nowrap;
  }
}

::-webkit-scrollbar {
  width: 6px;
  height: 6px;
}

::-webkit-scrollbar-track {
  @apply bg-gray-100 rounded-full;
}

::-webkit-scrollbar-thumb {
  @apply bg-gray-300 rounded-full hover:bg-gray-400;
}

@keyframes fadeIn {
  from { opacity: 0; transform: translateY(10px); }
  to { opacity: 1; transform: translateY(0); }
}

.animate-fadeIn {
  animation: fadeIn 0.3s ease-out;
}
'@ | Set-Content -Path "src/app/globals.css" -Encoding UTF8
Write-Host "✅ src/app/globals.css" -ForegroundColor Green

# ============================================
# 12. src/app/layout.tsx
# ============================================
@'
import type { Metadata } from 'next';
import { Inter } from 'next/font/google';
import './globals.css';
import { Sidebar } from '@/components/Sidebar';
import { Toaster } from 'sonner';

const inter = Inter({ subsets: ['latin'] });

export const metadata: Metadata = {
  title: 'Grand Hotel — Management System',
  description: 'Sistem informasi manajemen hotel terpadu',
};

export default function RootLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <html lang="id">
      <body className={inter.className}>
        <div className="flex h-screen overflow-hidden">
          <Sidebar />
          <main className="flex-1 overflow-y-auto">
            <div className="p-6 lg:p-8 animate-fadeIn">
              {children}
            </div>
          </main>
        </div>
        <Toaster position="top-right" richColors />
      </body>
    </html>
  );
}
'@ | Set-Content -Path "src/app/layout.tsx" -Encoding UTF8
Write-Host "✅ src/app/layout.tsx" -ForegroundColor Green

# ============================================
# 13. src/lib/utils.ts
# ============================================
@'
import { clsx, type ClassValue } from 'clsx';

export function cn(...inputs: ClassValue[]) {
  return clsx(inputs);
}

export function formatCurrency(amount: number): string {
  return new Intl.NumberFormat('id-ID', {
    style: 'currency',
    currency: 'IDR',
    minimumFractionDigits: 0,
  }).format(amount);
}

export function formatDate(date: Date | string): string {
  return new Intl.DateTimeFormat('id-ID', {
    day: 'numeric',
    month: 'long',
    year: 'numeric',
  }).format(new Date(date));
}

export function formatDateTime(date: Date | string): string {
  return new Intl.DateTimeFormat('id-ID', {
    day: 'numeric',
    month: 'short',
    year: 'numeric',
    hour: '2-digit',
    minute: '2-digit',
  }).format(new Date(date));
}

export function generateBookingNumber(): string {
  const date = new Date();
  const prefix = 'BK';
  const dateStr = date.toISOString().slice(0, 10).replace(/-/g, '');
  const random = Math.floor(Math.random() * 10000).toString().padStart(4, '0');
  return `${prefix}${dateStr}${random}`;
}

export function generateOrderNumber(type: 'RS' | 'RM'): string {
  const date = new Date();
  const dateStr = date.toISOString().slice(0, 10).replace(/-/g, '');
  const random = Math.floor(Math.random() * 10000).toString().padStart(4, '0');
  return `${type}${dateStr}${random}`;
}

export function generatePaymentNumber(): string {
  const date = new Date();
  const dateStr = date.toISOString().slice(0, 10).replace(/-/g, '');
  const random = Math.floor(Math.random() * 10000).toString().padStart(4, '0');
  return `PAY${dateStr}${random}`;
}

export function calculateNights(checkIn: Date, checkOut: Date): number {
  const diff = new Date(checkOut).getTime() - new Date(checkIn).getTime();
  return Math.ceil(diff / (1000 * 60 * 60 * 24));
}

export function getStatusColor(status: string): string {
  const colors: Record<string, string> = {
    AVAILABLE: 'bg-green-100 text-green-800',
    OCCUPIED: 'bg-red-100 text-red-800',
    MAINTENANCE: 'bg-orange-100 text-orange-800',
    RESERVED: 'bg-blue-100 text-blue-800',
    CLEANING: 'bg-yellow-100 text-yellow-800',
    PENDING: 'bg-yellow-100 text-yellow-800',
    CONFIRMED: 'bg-blue-100 text-blue-800',
    CHECKED_IN: 'bg-green-100 text-green-800',
    CHECKED_OUT: 'bg-gray-100 text-gray-800',
    CANCELLED: 'bg-red-100 text-red-800',
    NO_SHOW: 'bg-purple-100 text-purple-800',
    SUCCESS: 'bg-green-100 text-green-800',
    FAILED: 'bg-red-100 text-red-800',
    PROCESSING: 'bg-blue-100 text-blue-800',
    REFUNDED: 'bg-purple-100 text-purple-800',
    PREPARING: 'bg-orange-100 text-orange-800',
    READY: 'bg-blue-100 text-blue-800',
    DELIVERED: 'bg-green-100 text-green-800',
    COMPLETED: 'bg-green-100 text-green-800',
  };
  return colors[status] || 'bg-gray-100 text-gray-800';
}
'@ | Set-Content -Path "src/lib/utils.ts" -Encoding UTF8
Write-Host "✅ src/lib/utils.ts" -ForegroundColor Green

# ============================================
# 14. src/lib/prisma.ts
# ============================================
@'
import { PrismaClient } from '@prisma/client';

const globalForPrisma = globalThis as unknown as {
  prisma: PrismaClient | undefined;
};

export const prisma =
  globalForPrisma.prisma ??
  new PrismaClient({
    log: process.env.NODE_ENV === 'development' ? ['query', 'error', 'warn'] : ['error'],
  });

if (process.env.NODE_ENV !== 'production') globalForPrisma.prisma = prisma;
'@ | Set-Content -Path "src/lib/prisma.ts" -Encoding UTF8
Write-Host "✅ src/lib/prisma.ts" -ForegroundColor Green

# ============================================
# 15. src/types/index.ts
# ============================================
@'
export interface DashboardStats {
  totalBookings: number;
  totalGuests: number;
  totalRooms: number;
  availableRooms: number;
  occupiedRooms: number;
  todayCheckIns: number;
  todayCheckOuts: number;
  totalRevenue: number;
  pendingPayments: number;
  activeOrders: number;
}

export interface SidebarItem {
  label: string;
  href: string;
  icon: React.ReactNode;
  badge?: number;
}
'@ | Set-Content -Path "src/types/index.ts" -Encoding UTF8
Write-Host "✅ src/types/index.ts" -ForegroundColor Green

# ============================================
# 16. src/components/Badge.tsx
# ============================================
@'
import { cn, getStatusColor } from '@/lib/utils';

interface BadgeProps {
  status: string;
  className?: string;
}

export function Badge({ status, className }: BadgeProps) {
  const label = status.replace(/_/g, ' ');
  return (
    <span className={cn('inline-flex items-center px-2.5 py-1 rounded-full text-xs font-semibold', getStatusColor(status), className)}>
      {label}
    </span>
  );
}
'@ | Set-Content -Path "src/components/Badge.tsx" -Encoding UTF8
Write-Host "✅ src/components/Badge.tsx" -ForegroundColor Green

# ============================================
# 17. src/components/Modal.tsx
# ============================================
@'
'use client';

import { useEffect } from 'react';
import { HiOutlineXMark } from 'react-icons/hi2';

interface ModalProps {
  isOpen: boolean;
  onClose: () => void;
  title: string;
  children: React.ReactNode;
  size?: 'sm' | 'md' | 'lg' | 'xl';
}

const sizeMap = {
  sm: 'max-w-md',
  md: 'max-w-lg',
  lg: 'max-w-2xl',
  xl: 'max-w-4xl',
};

export function Modal({ isOpen, onClose, title, children, size = 'md' }: ModalProps) {
  useEffect(() => {
    if (isOpen) {
      document.body.style.overflow = 'hidden';
    } else {
      document.body.style.overflow = '';
    }
    return () => { document.body.style.overflow = ''; };
  }, [isOpen]);

  if (!isOpen) return null;

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center p-4">
      <div
        className="absolute inset-0 bg-black/50 backdrop-blur-sm animate-fadeIn"
        onClick={onClose}
      />

      <div className={`relative w-full ${sizeMap[size]} bg-white rounded-2xl shadow-2xl animate-fadeIn max-h-[90vh] flex flex-col`}>
        <div className="flex items-center justify-between px-6 py-4 border-b border-gray-200">
          <h2 className="text-lg font-bold text-gray-900">{title}</h2>
          <button
            onClick={onClose}
            className="p-2 rounded-lg hover:bg-gray-100 transition-colors"
          >
            <HiOutlineXMark className="w-5 h-5 text-gray-500" />
          </button>
        </div>

        <div className="flex-1 overflow-y-auto p-6">
          {children}
        </div>
      </div>
    </div>
  );
}
'@ | Set-Content -Path "src/components/Modal.tsx" -Encoding UTF8
Write-Host "✅ src/components/Modal.tsx" -ForegroundColor Green

# ============================================
# 18. src/components/DataTable.tsx
# ============================================
@'
interface Column<T> {
  key: string;
  header: string;
  render?: (item: T) => React.ReactNode;
  className?: string;
}

interface DataTableProps<T> {
  columns: Column<T>[];
  data: T[];
  keyExtractor: (item: T) => string;
  emptyMessage?: string;
  onRowClick?: (item: T) => void;
}

export function DataTable<T>({
  columns,
  data,
  keyExtractor,
  emptyMessage = 'Tidak ada data',
  onRowClick,
}: DataTableProps<T>) {
  if (data.length === 0) {
    return (
      <div className="card text-center py-12">
        <div className="text-gray-400 mb-2">
          <svg className="w-16 h-16 mx-auto" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={1.5}
              d="M20 13V6a2 2 0 00-2-2H6a2 2 0 00-2 2v7m16 0v5a2 2 0 01-2 2H6a2 2 0 01-2-2v-5m16 0h-2.586a1 1 0 00-.707.293l-2.414 2.414a1 1 0 01-.707.293h-3.172a1 1 0 01-.707-.293l-2.414-2.414A1 1 0 006.586 13H4" />
          </svg>
        </div>
        <p className="text-gray-500 font-medium">{emptyMessage}</p>
      </div>
    );
  }

  return (
    <div className="card p-0 overflow-hidden">
      <div className="overflow-x-auto">
        <table className="w-full">
          <thead>
            <tr className="border-b border-gray-200">
              {columns.map((col) => (
                <th key={col.key} className={`table-header ${col.className || ''}`}>
                  {col.header}
                </th>
              ))}
            </tr>
          </thead>
          <tbody className="divide-y divide-gray-100">
            {data.map((item) => (
              <tr
                key={keyExtractor(item)}
                onClick={() => onRowClick?.(item)}
                className={`hover:bg-gray-50 transition-colors ${onRowClick ? 'cursor-pointer' : ''}`}
              >
                {columns.map((col) => (
                  <td key={col.key} className={`table-cell ${col.className || ''}`}>
                    {col.render
                      ? col.render(item)
                      : String((item as Record<string, unknown>)[col.key] ?? '')}
                  </td>
                ))}
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </div>
  );
}
'@ | Set-Content -Path "src/components/DataTable.tsx" -Encoding UTF8
Write-Host "✅ src/components/DataTable.tsx" -ForegroundColor Green

# ============================================
# 19. src/components/StatCard.tsx
# ============================================
@'
import { cn } from '@/lib/utils';

interface StatCardProps {
  title: string;
  value: string | number;
  icon: React.ReactNode;
  trend?: { value: number; label: string };
  color?: 'blue' | 'green' | 'orange' | 'purple' | 'gold' | 'red';
}

const colorMap = {
  blue: 'from-blue-500 to-blue-600 shadow-blue-500/25',
  green: 'from-green-500 to-green-600 shadow-green-500/25',
  orange: 'from-orange-500 to-orange-600 shadow-orange-500/25',
  purple: 'from-purple-500 to-purple-600 shadow-purple-500/25',
  gold: 'from-gold-500 to-gold-600 shadow-gold-500/25',
  red: 'from-red-500 to-red-600 shadow-red-500/25',
};

export function StatCard({ title, value, icon, trend, color = 'blue' }: StatCardProps) {
  return (
    <div className="card hover:shadow-md transition-shadow duration-200">
      <div className="flex items-start justify-between">
        <div className="flex-1">
          <p className="text-sm font-medium text-gray-500">{title}</p>
          <p className="mt-2 text-3xl font-bold text-gray-900">{value}</p>
          {trend && (
            <div className="mt-2 flex items-center gap-1">
              <span
                className={cn(
                  'text-xs font-semibold',
                  trend.value >= 0 ? 'text-green-600' : 'text-red-600'
                )}
              >
                {trend.value >= 0 ? '↑' : '↓'} {Math.abs(trend.value)}%
              </span>
              <span className="text-xs text-gray-500">{trend.label}</span>
            </div>
          )}
        </div>
        <div
          className={cn(
            'w-12 h-12 rounded-xl bg-gradient-to-br flex items-center justify-center text-white shadow-lg',
            colorMap[color]
          )}
        >
          {icon}
        </div>
      </div>
    </div>
  );
}
'@ | Set-Content -Path "src/components/StatCard.tsx" -Encoding UTF8
Write-Host "✅ src/components/StatCard.tsx" -ForegroundColor Green

# ============================================
# 20. src/components/Sidebar.tsx
# ============================================
@'
'use client';

import Link from 'next/link';
import { usePathname } from 'next/navigation';
import { cn } from '@/lib/utils';
import {
  HiOutlineHome,
  HiOutlineCalendar,
  HiOutlineUserGroup,
  HiOutlineBuildingOffice2,
  HiOutlineShoppingBag,
  HiOutlineCreditCard,
  HiOutlineArrowRightOnRectangle,
} from 'react-icons/hi2';

const navigation = [
  { label: 'Dashboard', href: '/', icon: <HiOutlineHome className="w-5 h-5" /> },
  { label: 'Booking', href: '/bookings', icon: <HiOutlineCalendar className="w-5 h-5" /> },
  { label: 'Tamu', href: '/guests', icon: <HiOutlineUserGroup className="w-5 h-5" /> },
  { label: 'Kamar', href: '/rooms', icon: <HiOutlineBuildingOffice2 className="w-5 h-5" /> },
  { label: 'Restaurant', href: '/restaurant', icon: <HiOutlineShoppingBag className="w-5 h-5" /> },
  { label: 'Pembayaran', href: '/payments', icon: <HiOutlineCreditCard className="w-5 h-5" /> },
];

export function Sidebar() {
  const pathname = usePathname();

  return (
    <aside className="hidden lg:flex flex-col w-72 bg-hotel-950 text-white">
      <div className="flex items-center gap-3 px-6 py-6 border-b border-hotel-800">
        <div className="w-10 h-10 bg-gradient-to-br from-gold-400 to-gold-600 rounded-xl flex items-center justify-center shadow-lg">
          <span className="text-hotel-950 font-bold text-lg">G</span>
        </div>
        <div>
          <h1 className="font-bold text-lg leading-tight">Grand Hotel</h1>
          <p className="text-hotel-400 text-xs">Management System</p>
        </div>
      </div>

      <nav className="flex-1 px-4 py-6 space-y-1.5 overflow-y-auto">
        <p className="px-3 text-xs font-semibold text-hotel-500 uppercase tracking-wider mb-3">
          Menu Utama
        </p>
        {navigation.map((item) => {
          const isActive = pathname === item.href;
          return (
            <Link
              key={item.href}
              href={item.href}
              className={cn(
                'flex items-center gap-3 px-4 py-3 rounded-xl text-sm font-medium transition-all duration-200',
                isActive
                  ? 'bg-hotel-600 text-white shadow-lg shadow-hotel-600/30'
                  : 'text-hotel-300 hover:bg-hotel-800 hover:text-white'
              )}
            >
              {item.icon}
              {item.label}
            </Link>
          );
        })}
      </nav>

      <div className="px-4 py-4 border-t border-hotel-800">
        <div className="flex items-center gap-3 px-4 py-3 rounded-xl bg-hotel-900">
          <div className="w-9 h-9 bg-hotel-700 rounded-full flex items-center justify-center">
            <span className="text-sm font-bold">AD</span>
          </div>
          <div className="flex-1 min-w-0">
            <p className="text-sm font-medium truncate">Admin Hotel</p>
            <p className="text-xs text-hotel-400 truncate">admin@grandhotel.com</p>
          </div>
          <button className="text-hotel-400 hover:text-white transition-colors">
            <HiOutlineArrowRightOnRectangle className="w-5 h-5" />
          </button>
        </div>
      </div>
    </aside>
  );
}
'@ | Set-Content -Path "src/components/Sidebar.tsx" -Encoding UTF8
Write-Host "✅ src/components/Sidebar.tsx" -ForegroundColor Green

Write-Host "`n📄 Writing page files..." -ForegroundColor Cyan

# ============================================
# 21. src/app/page.tsx (Dashboard)
# ============================================
@'
import { prisma } from '@/lib/prisma';
import { StatCard } from '@/components/StatCard';
import { formatCurrency, formatDate } from '@/lib/utils';
import { Badge } from '@/components/Badge';
import {
  HiOutlineCalendar,
  HiOutlineUserGroup,
  HiOutlineBuildingOffice2,
  HiOutlineCurrencyDollar,
  HiOutlineShoppingBag,
  HiOutlineClock,
} from 'react-icons/hi2';

export const dynamic = 'force-dynamic';

export default async function DashboardPage() {
  const [
    totalBookings,
    totalGuests,
    totalRooms,
    availableRooms,
    occupiedRooms,
    todayCheckIns,
    todayCheckOuts,
    revenueData,
    recentBookings,
    pendingPayments,
    activeOrders,
  ] = await Promise.all([
    prisma.booking.count(),
    prisma.guest.count(),
    prisma.room.count(),
    prisma.room.count({ where: { status: 'AVAILABLE' } }),
    prisma.room.count({ where: { status: 'OCCUPIED' } }),
    prisma.booking.count({
      where: {
        checkIn: { gte: new Date(new Date().setHours(0, 0, 0, 0)) },
        status: { in: ['CONFIRMED', 'CHECKED_IN'] },
      },
    }),
    prisma.booking.count({
      where: {
        checkOut: { gte: new Date(new Date().setHours(0, 0, 0, 0)) },
        status: 'CHECKED_IN',
      },
    }),
    prisma.payment.aggregate({
      _sum: { amount: true },
      where: { paymentStatus: 'SUCCESS' },
    }),
    prisma.booking.findMany({
      take: 5,
      orderBy: { createdAt: 'desc' },
      include: { guest: true, room: true },
    }),
    prisma.payment.count({ where: { paymentStatus: 'PENDING' } }),
    prisma.order.count({ where: { status: { in: ['PENDING', 'PREPARING', 'READY'] } } }),
  ]);

  const totalRevenue = revenueData._sum.amount || 0;
  const occupancyRate = totalRooms > 0 ? Math.round((occupiedRooms / totalRooms) * 100) : 0;

  return (
    <div className="space-y-8">
      <div>
        <h1 className="text-3xl font-bold text-gray-900">Dashboard</h1>
        <p className="text-gray-500 mt-1">
          Selamat datang kembali! Berikut ringkasan hotel hari ini —{' '}
          {formatDate(new Date())}
        </p>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
        <StatCard
          title="Total Booking"
          value={totalBookings}
          icon={<HiOutlineCalendar className="w-6 h-6" />}
          color="blue"
          trend={{ value: 12, label: 'dari bulan lalu' }}
        />
        <StatCard
          title="Total Tamu"
          value={totalGuests}
          icon={<HiOutlineUserGroup className="w-6 h-6" />}
          color="green"
          trend={{ value: 8, label: 'dari bulan lalu' }}
        />
        <StatCard
          title="Kamar Tersedia"
          value={`${availableRooms}/${totalRooms}`}
          icon={<HiOutlineBuildingOffice2 className="w-6 h-6" />}
          color="orange"
        />
        <StatCard
          title="Total Pendapatan"
          value={formatCurrency(totalRevenue)}
          icon={<HiOutlineCurrencyDollar className="w-6 h-6" />}
          color="gold"
          trend={{ value: 15, label: 'dari bulan lalu' }}
        />
      </div>

      <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
        <div className="card flex items-center gap-4">
          <div className="w-12 h-12 bg-blue-100 rounded-xl flex items-center justify-center">
            <HiOutlineCalendar className="w-6 h-6 text-blue-600" />
          </div>
          <div>
            <p className="text-sm text-gray-500">Check-in Hari Ini</p>
            <p className="text-2xl font-bold">{todayCheckIns}</p>
          </div>
        </div>
        <div className="card flex items-center gap-4">
          <div className="w-12 h-12 bg-red-100 rounded-xl flex items-center justify-center">
            <HiOutlineClock className="w-6 h-6 text-red-600" />
          </div>
          <div>
            <p className="text-sm text-gray-500">Check-out Hari Ini</p>
            <p className="text-2xl font-bold">{todayCheckOuts}</p>
          </div>
        </div>
        <div className="card flex items-center gap-4">
          <div className="w-12 h-12 bg-orange-100 rounded-xl flex items-center justify-center">
            <HiOutlineShoppingBag className="w-6 h-6 text-orange-600" />
          </div>
          <div>
            <p className="text-sm text-gray-500">Pesanan Aktif</p>
            <p className="text-2xl font-bold">{activeOrders}</p>
          </div>
        </div>
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
        <div className="card">
          <h3 className="text-lg font-bold text-gray-900 mb-4">Tingkat Hunian</h3>
          <div className="flex items-center justify-center py-6">
            <div className="relative w-40 h-40">
              <svg className="w-full h-full transform -rotate-90" viewBox="0 0 100 100">
                <circle cx="50" cy="50" r="40" stroke="#e5e7eb" strokeWidth="12" fill="none" />
                <circle
                  cx="50" cy="50" r="40"
                  stroke="url(#gradient)"
                  strokeWidth="12"
                  fill="none"
                  strokeLinecap="round"
                  strokeDasharray={`${occupancyRate * 2.51} 251`}
                />
                <defs>
                  <linearGradient id="gradient" x1="0%" y1="0%" x2="100%" y2="0%">
                    <stop offset="0%" stopColor="#0c93e7" />
                    <stop offset="100%" stopColor="#0074c5" />
                  </linearGradient>
                </defs>
              </svg>
              <div className="absolute inset-0 flex flex-col items-center justify-center">
                <span className="text-3xl font-bold text-gray-900">{occupancyRate}%</span>
                <span className="text-xs text-gray-500">terisi</span>
              </div>
            </div>
          </div>
          <div className="grid grid-cols-2 gap-4 mt-4">
            <div className="text-center p-3 bg-green-50 rounded-lg">
              <p className="text-2xl font-bold text-green-600">{availableRooms}</p>
              <p className="text-xs text-green-700">Tersedia</p>
            </div>
            <div className="text-center p-3 bg-red-50 rounded-lg">
              <p className="text-2xl font-bold text-red-600">{occupiedRooms}</p>
              <p className="text-xs text-red-700">Terisi</p>
            </div>
          </div>
        </div>

        <div className="lg:col-span-2 card">
          <div className="flex items-center justify-between mb-4">
            <h3 className="text-lg font-bold text-gray-900">Booking Terbaru</h3>
            <a href="/bookings" className="text-sm text-hotel-600 hover:text-hotel-700 font-medium">
              Lihat Semua →
            </a>
          </div>
          <div className="space-y-3">
            {recentBookings.map((booking) => (
              <div key={booking.id} className="flex items-center gap-4 p-3 rounded-lg hover:bg-gray-50 transition-colors">
                <div className="w-10 h-10 bg-hotel-100 rounded-full flex items-center justify-center">
                  <span className="text-sm font-bold text-hotel-700">
                    {booking.guest.firstName[0]}{booking.guest.lastName[0]}
                  </span>
                </div>
                <div className="flex-1 min-w-0">
                  <p className="text-sm font-semibold text-gray-900 truncate">
                    {booking.guest.firstName} {booking.guest.lastName}
                  </p>
                  <p className="text-xs text-gray-500">
                    Kamar {booking.room.roomNumber} • {formatDate(booking.checkIn)}
                  </p>
                </div>
                <div className="text-right">
                  <p className="text-sm font-bold text-gray-900">{formatCurrency(booking.totalPrice)}</p>
                  <Badge status={booking.status} />
                </div>
              </div>
            ))}
            {recentBookings.length === 0 && (
              <p className="text-center text-gray-500 py-8">Belum ada booking</p>
            )}
          </div>
        </div>
      </div>
    </div>
  );
}
'@ | Set-Content -Path "src/app/page.tsx" -Encoding UTF8
Write-Host "✅ src/app/page.tsx" -ForegroundColor Green

# ============================================
# 22. src/app/bookings/page.tsx
# ============================================
@'
'use client';

import { useEffect, useState } from 'react';
import { formatCurrency, formatDate } from '@/lib/utils';
import { DataTable } from '@/components/DataTable';
import { Badge } from '@/components/Badge';
import { Modal } from '@/components/Modal';
import { HiOutlinePlus, HiOutlineMagnifyingGlass } from 'react-icons/hi2';
import { toast } from 'sonner';

interface Booking {
  id: string;
  bookingNumber: string;
  checkIn: string;
  checkOut: string;
  adults: number;
  children: number;
  totalPrice: number;
  status: string;
  specialRequest: string | null;
  guest: { firstName: string; lastName: string; email: string; phone: string };
  room: { roomNumber: string; roomType: { name: string } };
}

export default function BookingsPage() {
  const [bookings, setBookings] = useState<Booking[]>([]);
  const [loading, setLoading] = useState(true);
  const [showModal, setShowModal] = useState(false);
  const [search, setSearch] = useState('');
  const [formData, setFormData] = useState({
    guestId: '',
    roomId: '',
    checkIn: '',
    checkOut: '',
    adults: 1,
    children: 0,
    specialRequest: '',
  });
  const [guests, setGuests] = useState<{ id: string; name: string }[]>([]);
  const [rooms, setRooms] = useState<{ id: string; roomNumber: string; typeName: string; price: number }[]>([]);

  useEffect(() => {
    fetchBookings();
    fetchGuests();
    fetchRooms();
  }, []);

  async function fetchBookings() {
    try {
      const res = await fetch('/api/bookings');
      const data = await res.json();
      setBookings(data);
    } catch {
      toast.error('Gagal memuat data booking');
    } finally {
      setLoading(false);
    }
  }

  async function fetchGuests() {
    try {
      const res = await fetch('/api/guests');
      const data = await res.json();
      setGuests(data.map((g: any) => ({ id: g.id, name: `${g.firstName} ${g.lastName}` })));
    } catch {}
  }

  async function fetchRooms() {
    try {
      const res = await fetch('/api/rooms');
      const data = await res.json();
      setRooms(data.filter((r: any) => r.status === 'AVAILABLE').map((r: any) => ({
        id: r.id,
        roomNumber: r.roomNumber,
        typeName: r.roomType.name,
        price: r.pricePerNight,
      })));
    } catch {}
  }

  async function handleSubmit(e: React.FormEvent) {
    e.preventDefault();
    try {
      const res = await fetch('/api/bookings', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(formData),
      });
      if (!res.ok) throw new Error();
      toast.success('Booking berhasil dibuat!');
      setShowModal(false);
      fetchBookings();
      setFormData({ guestId: '', roomId: '', checkIn: '', checkOut: '', adults: 1, children: 0, specialRequest: '' });
    } catch {
      toast.error('Gagal membuat booking');
    }
  }

  const filtered = bookings.filter((b) =>
    b.bookingNumber.toLowerCase().includes(search.toLowerCase()) ||
    `${b.guest.firstName} ${b.guest.lastName}`.toLowerCase().includes(search.toLowerCase()) ||
    b.room.roomNumber.toLowerCase().includes(search.toLowerCase())
  );

  const columns = [
    { key: 'bookingNumber', header: 'No. Booking', render: (b: Booking) => (
      <span className="font-mono font-semibold text-hotel-700">{b.bookingNumber}</span>
    )},
    { key: 'guest', header: 'Tamu', render: (b: Booking) => (
      <div>
        <p className="font-medium">{b.guest.firstName} {b.guest.lastName}</p>
        <p className="text-xs text-gray-500">{b.guest.phone}</p>
      </div>
    )},
    { key: 'room', header: 'Kamar', render: (b: Booking) => (
      <div>
        <p className="font-medium">Kamar {b.room.roomNumber}</p>
        <p className="text-xs text-gray-500">{b.room.roomType.name}</p>
      </div>
    )},
    { key: 'dates', header: 'Tanggal', render: (b: Booking) => (
      <div>
        <p className="text-sm">{formatDate(b.checkIn)}</p>
        <p className="text-xs text-gray-500">s/d {formatDate(b.checkOut)}</p>
      </div>
    )},
    { key: 'totalPrice', header: 'Total', render: (b: Booking) => (
      <span className="font-bold">{formatCurrency(b.totalPrice)}</span>
    )},
    { key: 'status', header: 'Status', render: (b: Booking) => <Badge status={b.status} /> },
  ];

  if (loading) {
    return (
      <div className="flex items-center justify-center h-64">
        <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-hotel-600" />
      </div>
    );
  }

  return (
    <div className="space-y-6">
      <div className="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4">
        <div>
          <h1 className="text-3xl font-bold text-gray-900">Booking</h1>
          <p className="text-gray-500 mt-1">Kelola semua pemesanan kamar hotel</p>
        </div>
        <button onClick={() => setShowModal(true)} className="btn-primary flex items-center gap-2 w-fit">
          <HiOutlinePlus className="w-5 h-5" />
          Booking Baru
        </button>
      </div>

      <div className="relative max-w-md">
        <HiOutlineMagnifyingGlass className="absolute left-3 top-1/2 -translate-y-1/2 w-5 h-5 text-gray-400" />
        <input
          type="text"
          placeholder="Cari booking, tamu, atau kamar..."
          value={search}
          onChange={(e) => setSearch(e.target.value)}
          className="input-field pl-10"
        />
      </div>

      <DataTable columns={columns} data={filtered} keyExtractor={(b) => b.id} emptyMessage="Belum ada booking" />

      <Modal isOpen={showModal} onClose={() => setShowModal(false)} title="Booking Baru" size="lg">
        <form onSubmit={handleSubmit} className="space-y-4">
          <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
            <div>
              <label className="label-field">Tamu</label>
              <select
                value={formData.guestId}
                onChange={(e) => setFormData({ ...formData, guestId: e.target.value })}
                className="input-field"
                required
              >
                <option value="">Pilih Tamu</option>
                {guests.map((g) => <option key={g.id} value={g.id}>{g.name}</option>)}
              </select>
            </div>
            <div>
              <label className="label-field">Kamar</label>
              <select
                value={formData.roomId}
                onChange={(e) => setFormData({ ...formData, roomId: e.target.value })}
                className="input-field"
                required
              >
                <option value="">Pilih Kamar</option>
                {rooms.map((r) => (
                  <option key={r.id} value={r.id}>
                    Kamar {r.roomNumber} - {r.typeName} ({formatCurrency(r.price)})
                  </option>
                ))}
              </select>
            </div>
            <div>
              <label className="label-field">Check-in</label>
              <input type="date" value={formData.checkIn}
                onChange={(e) => setFormData({ ...formData, checkIn: e.target.value })}
                className="input-field" required />
            </div>
            <div>
              <label className="label-field">Check-out</label>
              <input type="date" value={formData.checkOut}
                onChange={(e) => setFormData({ ...formData, checkOut: e.target.value })}
                className="input-field" required />
            </div>
            <div>
              <label className="label-field">Dewasa</label>
              <input type="number" min={1} value={formData.adults}
                onChange={(e) => setFormData({ ...formData, adults: +e.target.value })}
                className="input-field" required />
            </div>
            <div>
              <label className="label-field">Anak-anak</label>
              <input type="number" min={0} value={formData.children}
                onChange={(e) => setFormData({ ...formData, children: +e.target.value })}
                className="input-field" />
            </div>
          </div>
          <div>
            <label className="label-field">Permintaan Khusus</label>
            <textarea value={formData.specialRequest}
              onChange={(e) => setFormData({ ...formData, specialRequest: e.target.value })}
              className="input-field" rows={3} placeholder="Contoh: Extra bed, kamar lantai tinggi..." />
          </div>
          <div className="flex gap-3 justify-end pt-4 border-t">
            <button type="button" onClick={() => setShowModal(false)} className="btn-secondary">Batal</button>
            <button type="submit" className="btn-primary">Simpan Booking</button>
          </div>
        </form>
      </Modal>
    </div>
  );
}
'@ | Set-Content -Path "src/app/bookings/page.tsx" -Encoding UTF8
Write-Host "✅ src/app/bookings/page.tsx" -ForegroundColor Green

# ============================================
# 23. src/app/guests/page.tsx
# ============================================
@'
'use client';

import { useEffect, useState } from 'react';
import { DataTable } from '@/components/DataTable';
import { Modal } from '@/components/Modal';
import { HiOutlinePlus, HiOutlineMagnifyingGlass, HiOutlineStar } from 'react-icons/hi2';
import { toast } from 'sonner';

interface Guest {
  id: string;
  firstName: string;
  lastName: string;
  email: string;
  phone: string;
  nationality: string | null;
  vipStatus: boolean;
  createdAt: string;
}

export default function GuestsPage() {
  const [guests, setGuests] = useState<Guest[]>([]);
  const [loading, setLoading] = useState(true);
  const [showModal, setShowModal] = useState(false);
  const [search, setSearch] = useState('');
  const [formData, setFormData] = useState({
    firstName: '', lastName: '', email: '', phone: '',
    idCardNumber: '', nationality: '', address: '', vipStatus: false,
  });

  useEffect(() => { fetchGuests(); }, []);

  async function fetchGuests() {
    try {
      const res = await fetch('/api/guests');
      setGuests(await res.json());
    } catch { toast.error('Gagal memuat data tamu'); }
    finally { setLoading(false); }
  }

  async function handleSubmit(e: React.FormEvent) {
    e.preventDefault();
    try {
      const res = await fetch('/api/guests', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(formData),
      });
      if (!res.ok) throw new Error();
      toast.success('Tamu berhasil ditambahkan!');
      setShowModal(false);
      fetchGuests();
      setFormData({ firstName: '', lastName: '', email: '', phone: '', idCardNumber: '', nationality: '', address: '', vipStatus: false });
    } catch { toast.error('Gagal menambahkan tamu'); }
  }

  const filtered = guests.filter((g) =>
    `${g.firstName} ${g.lastName}`.toLowerCase().includes(search.toLowerCase()) ||
    g.email.toLowerCase().includes(search.toLowerCase()) ||
    g.phone.includes(search)
  );

  const columns = [
    { key: 'name', header: 'Nama', render: (g: Guest) => (
      <div className="flex items-center gap-3">
        <div className="w-10 h-10 bg-hotel-100 rounded-full flex items-center justify-center">
          <span className="text-sm font-bold text-hotel-700">{g.firstName[0]}{g.lastName[0]}</span>
        </div>
        <div>
          <p className="font-semibold flex items-center gap-1">
            {g.firstName} {g.lastName}
            {g.vipStatus && <HiOutlineStar className="w-4 h-4 text-gold-500 fill-gold-500" />}
          </p>
          <p className="text-xs text-gray-500">{g.email}</p>
        </div>
      </div>
    )},
    { key: 'phone', header: 'Telepon' },
    { key: 'nationality', header: 'Kebangsaan', render: (g: Guest) => g.nationality || '-' },
    { key: 'vipStatus', header: 'Status', render: (g: Guest) => (
      g.vipStatus
        ? <span className="inline-flex items-center gap-1 px-2.5 py-1 rounded-full text-xs font-semibold bg-gold-100 text-gold-800">
            <HiOutlineStar className="w-3 h-3 fill-gold-500" /> VIP
          </span>
        : <span className="text-xs text-gray-500">Regular</span>
    )},
  ];

  if (loading) return <div className="flex items-center justify-center h-64"><div className="animate-spin rounded-full h-12 w-12 border-b-2 border-hotel-600" /></div>;

  return (
    <div className="space-y-6">
      <div className="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4">
        <div>
          <h1 className="text-3xl font-bold text-gray-900">Tamu</h1>
          <p className="text-gray-500 mt-1">Kelola data tamu hotel</p>
        </div>
        <button onClick={() => setShowModal(true)} className="btn-primary flex items-center gap-2 w-fit">
          <HiOutlinePlus className="w-5 h-5" /> Tambah Tamu
        </button>
      </div>

      <div className="relative max-w-md">
        <HiOutlineMagnifyingGlass className="absolute left-3 top-1/2 -translate-y-1/2 w-5 h-5 text-gray-400" />
        <input type="text" placeholder="Cari tamu..." value={search}
          onChange={(e) => setSearch(e.target.value)} className="input-field pl-10" />
      </div>

      <DataTable columns={columns} data={filtered} keyExtractor={(g) => g.id} emptyMessage="Belum ada tamu terdaftar" />

      <Modal isOpen={showModal} onClose={() => setShowModal(false)} title="Tambah Tamu Baru" size="lg">
        <form onSubmit={handleSubmit} className="space-y-4">
          <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
            <div>
              <label className="label-field">Nama Depan</label>
              <input type="text" value={formData.firstName}
                onChange={(e) => setFormData({ ...formData, firstName: e.target.value })}
                className="input-field" required />
            </div>
            <div>
              <label className="label-field">Nama Belakang</label>
              <input type="text" value={formData.lastName}
                onChange={(e) => setFormData({ ...formData, lastName: e.target.value })}
                className="input-field" required />
            </div>
            <div>
              <label className="label-field">Email</label>
              <input type="email" value={formData.email}
                onChange={(e) => setFormData({ ...formData, email: e.target.value })}
                className="input-field" required />
            </div>
            <div>
              <label className="label-field">Telepon</label>
              <input type="tel" value={formData.phone}
                onChange={(e) => setFormData({ ...formData, phone: e.target.value })}
                className="input-field" required />
            </div>
            <div>
              <label className="label-field">No. KTP/Paspor</label>
              <input type="text" value={formData.idCardNumber}
                onChange={(e) => setFormData({ ...formData, idCardNumber: e.target.value })}
                className="input-field" />
            </div>
            <div>
              <label className="label-field">Kebangsaan</label>
              <input type="text" value={formData.nationality}
                onChange={(e) => setFormData({ ...formData, nationality: e.target.value })}
                className="input-field" placeholder="Indonesia" />
            </div>
          </div>
          <div>
            <label className="label-field">Alamat</label>
            <textarea value={formData.address}
              onChange={(e) => setFormData({ ...formData, address: e.target.value })}
              className="input-field" rows={2} />
          </div>
          <label className="flex items-center gap-2 cursor-pointer">
            <input type="checkbox" checked={formData.vipStatus}
              onChange={(e) => setFormData({ ...formData, vipStatus: e.target.checked })}
              className="w-4 h-4 text-hotel-600 rounded" />
            <span className="text-sm font-medium">Tandai sebagai VIP</span>
          </label>
          <div className="flex gap-3 justify-end pt-4 border-t">
            <button type="button" onClick={() => setShowModal(false)} className="btn-secondary">Batal</button>
            <button type="submit" className="btn-primary">Simpan</button>
          </div>
        </form>
      </Modal>
    </div>
  );
}
'@ | Set-Content -Path "src/app/guests/page.tsx" -Encoding UTF8
Write-Host "✅ src/app/guests/page.tsx" -ForegroundColor Green

# ============================================
# 24. src/app/rooms/page.tsx
# ============================================
@'
'use client';

import { useEffect, useState } from 'react';
import { formatCurrency } from '@/lib/utils';
import { Badge } from '@/components/Badge';
import { HiOutlineBuildingOffice2, HiOutlineUserGroup } from 'react-icons/hi2';
import { toast } from 'sonner';

interface Room {
  id: string;
  roomNumber: string;
  floor: number;
  status: string;
  pricePerNight: number;
  roomType: { name: string; capacity: number; amenities: string[] };
}

const statusIcons: Record<string, string> = {
  AVAILABLE: '🟢',
  OCCUPIED: '🔴',
  MAINTENANCE: '🔧',
  RESERVED: '🔵',
  CLEANING: '🧹',
};

export default function RoomsPage() {
  const [rooms, setRooms] = useState<Room[]>([]);
  const [loading, setLoading] = useState(true);
  const [filter, setFilter] = useState('ALL');

  useEffect(() => { fetchRooms(); }, []);

  async function fetchRooms() {
    try {
      const res = await fetch('/api/rooms');
      setRooms(await res.json());
    } catch { toast.error('Gagal memuat data kamar'); }
    finally { setLoading(false); }
  }

  async function updateStatus(roomId: string, status: string) {
    try {
      await fetch(`/api/rooms?id=${roomId}`, {
        method: 'PATCH',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ status }),
      });
      toast.success('Status kamar diperbarui');
      fetchRooms();
    } catch { toast.error('Gagal mengubah status'); }
  }

  const filtered = filter === 'ALL' ? rooms : rooms.filter((r) => r.status === filter);
  const filters = [
    { label: 'Semua', value: 'ALL', count: rooms.length },
    { label: 'Tersedia', value: 'AVAILABLE', count: rooms.filter((r) => r.status === 'AVAILABLE').length },
    { label: 'Terisi', value: 'OCCUPIED', count: rooms.filter((r) => r.status === 'OCCUPIED').length },
    { label: 'Reserved', value: 'RESERVED', count: rooms.filter((r) => r.status === 'RESERVED').length },
    { label: 'Maintenance', value: 'MAINTENANCE', count: rooms.filter((r) => r.status === 'MAINTENANCE').length },
  ];

  if (loading) return <div className="flex items-center justify-center h-64"><div className="animate-spin rounded-full h-12 w-12 border-b-2 border-hotel-600" /></div>;

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-3xl font-bold text-gray-900">Kamar</h1>
        <p className="text-gray-500 mt-1">Kelola dan pantau status semua kamar hotel</p>
      </div>

      <div className="flex flex-wrap gap-2">
        {filters.map((f) => (
          <button
            key={f.value}
            onClick={() => setFilter(f.value)}
            className={`px-4 py-2 rounded-lg text-sm font-medium transition-all ${
              filter === f.value
                ? 'bg-hotel-600 text-white shadow-md'
                : 'bg-white text-gray-600 hover:bg-gray-100 border border-gray-200'
            }`}
          >
            {f.label} <span className="ml-1 opacity-75">({f.count})</span>
          </button>
        ))}
      </div>

      <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-4">
        {filtered.map((room) => (
          <div key={room.id} className="card hover:shadow-md transition-all duration-200 group">
            <div className="flex items-start justify-between mb-3">
              <div>
                <div className="flex items-center gap-2">
                  <span className="text-lg">{statusIcons[room.status]}</span>
                  <h3 className="text-xl font-bold text-gray-900">Kamar {room.roomNumber}</h3>
                </div>
                <p className="text-sm text-gray-500 mt-0.5">Lantai {room.floor}</p>
              </div>
              <Badge status={room.status} />
            </div>

            <div className="space-y-2 mb-4">
              <div className="flex items-center gap-2 text-sm text-gray-600">
                <HiOutlineBuildingOffice2 className="w-4 h-4" />
                <span>{room.roomType.name}</span>
              </div>
              <div className="flex items-center gap-2 text-sm text-gray-600">
                <HiOutlineUserGroup className="w-4 h-4" />
                <span>Maks. {room.roomType.capacity} orang</span>
              </div>
              <div className="flex flex-wrap gap-1 mt-2">
                {room.roomType.amenities.slice(0, 3).map((a) => (
                  <span key={a} className="text-xs bg-gray-100 text-gray-600 px-2 py-0.5 rounded">{a}</span>
                ))}
                {room.roomType.amenities.length > 3 && (
                  <span className="text-xs text-gray-500">+{room.roomType.amenities.length - 3}</span>
                )}
              </div>
            </div>

            <div className="flex items-center justify-between pt-3 border-t border-gray-100">
              <p className="text-lg font-bold text-hotel-700">
                {formatCurrency(room.pricePerNight)}
                <span className="text-xs font-normal text-gray-500">/malam</span>
              </p>
              {room.status === 'AVAILABLE' && (
                <button
                  onClick={() => updateStatus(room.id, 'MAINTENANCE')}
                  className="text-xs text-orange-600 hover:text-orange-700 font-medium"
                >
                  Maintenance
                </button>
              )}
              {room.status === 'MAINTENANCE' && (
                <button
                  onClick={() => updateStatus(room.id, 'AVAILABLE')}
                  className="text-xs text-green-600 hover:text-green-700 font-medium"
                >
                  Set Available
                </button>
              )}
            </div>
          </div>
        ))}
      </div>

      {filtered.length === 0 && (
        <div className="card text-center py-12">
          <p className="text-gray-500">Tidak ada kamar dengan status ini</p>
        </div>
      )}
    </div>
  );
}
'@ | Set-Content -Path "src/app/rooms/page.tsx" -Encoding UTF8
Write-Host "✅ src/app/rooms/page.tsx" -ForegroundColor Green

# ============================================
# 25. src/app/restaurant/page.tsx
# ============================================
@'
'use client';

import { useEffect, useState } from 'react';
import { formatCurrency } from '@/lib/utils';
import { DataTable } from '@/components/DataTable';
import { Badge } from '@/components/Badge';
import { Modal } from '@/components/Modal';
import { HiOutlinePlus, HiOutlineShoppingCart } from 'react-icons/hi2';
import { toast } from 'sonner';

interface MenuItem {
  id: string;
  name: string;
  category: string;
  price: number;
  description: string | null;
  isAvailable: boolean;
}

interface CartItem extends MenuItem {
  quantity: number;
}

export default function RestaurantPage() {
  const [menuItems, setMenuItems] = useState<MenuItem[]>([]);
  const [orders, setOrders] = useState<any[]>([]);
  const [loading, setLoading] = useState(true);
  const [activeTab, setActiveTab] = useState<'menu' | 'orders'>('menu');
  const [category, setCategory] = useState('ALL');
  const [cart, setCart] = useState<CartItem[]>([]);
  const [showCart, setShowCart] = useState(false);
  const [orderType, setOrderType] = useState<'RESTAURANT' | 'ROOM_SERVICE'>('RESTAURANT');
  const [roomNumber, setRoomNumber] = useState('');

  useEffect(() => { fetchData(); }, []);

  async function fetchData() {
    try {
      const [menuRes, orderRes] = await Promise.all([
        fetch('/api/restaurant?type=menu'),
        fetch('/api/restaurant?type=orders'),
      ]);
      setMenuItems(await menuRes.json());
      setOrders(await orderRes.json());
    } catch { toast.error('Gagal memuat data'); }
    finally { setLoading(false); }
  }

  function addToCart(item: MenuItem) {
    setCart((prev) => {
      const existing = prev.find((c) => c.id === item.id);
      if (existing) return prev.map((c) => c.id === item.id ? { ...c, quantity: c.quantity + 1 } : c);
      return [...prev, { ...item, quantity: 1 }];
    });
    toast.success(`${item.name} ditambahkan ke keranjang`);
  }

  function removeFromCart(id: string) {
    setCart((prev) => prev.filter((c) => c.id !== id));
  }

  function updateQuantity(id: string, qty: number) {
    if (qty <= 0) return removeFromCart(id);
    setCart((prev) => prev.map((c) => c.id === id ? { ...c, quantity: qty } : c));
  }

  async function submitOrder() {
    if (cart.length === 0) return;
    if (orderType === 'ROOM_SERVICE' && !roomNumber) {
      toast.error('Masukkan nomor kamar');
      return;
    }
    try {
      const res = await fetch('/api/restaurant', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          orderType,
          roomNumber: orderType === 'ROOM_SERVICE' ? roomNumber : null,
          items: cart.map((c) => ({ menuItemId: c.id, quantity: c.quantity, price: c.price })),
        }),
      });
      if (!res.ok) throw new Error();
      toast.success('Pesanan berhasil dibuat!');
      setCart([]);
      setShowCart(false);
      setRoomNumber('');
      fetchData();
    } catch { toast.error('Gagal membuat pesanan'); }
  }

  const categories = ['ALL', 'MAKANAN', 'MINUMAN', 'SNACK', 'DESSERT'];
  const filteredMenu = category === 'ALL' ? menuItems : menuItems.filter((m) => m.category === category);
  const cartTotal = cart.reduce((sum, item) => sum + item.price * item.quantity, 0);
  const cartCount = cart.reduce((sum, item) => sum + item.quantity, 0);

  if (loading) return <div className="flex items-center justify-center h-64"><div className="animate-spin rounded-full h-12 w-12 border-b-2 border-hotel-600" /></div>;

  return (
    <div className="space-y-6">
      <div className="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4">
        <div>
          <h1 className="text-3xl font-bold text-gray-900">Restaurant & Room Service</h1>
          <p className="text-gray-500 mt-1">Kelola pesanan restaurant dan room service</p>
        </div>
        <button onClick={() => setShowCart(true)} className="btn-primary flex items-center gap-2 w-fit relative">
          <HiOutlineShoppingCart className="w-5 h-5" />
          Keranjang
          {cartCount > 0 && (
            <span className="absolute -top-2 -right-2 w-6 h-6 bg-red-500 text-white text-xs rounded-full flex items-center justify-center font-bold">
              {cartCount}
            </span>
          )}
        </button>
      </div>

      <div className="flex gap-2 border-b border-gray-200">
        <button onClick={() => setActiveTab('menu')}
          className={`px-4 py-2 text-sm font-medium border-b-2 transition-colors ${activeTab === 'menu' ? 'border-hotel-600 text-hotel-600' : 'border-transparent text-gray-500 hover:text-gray-700'}`}>
          Menu
        </button>
        <button onClick={() => setActiveTab('orders')}
          className={`px-4 py-2 text-sm font-medium border-b-2 transition-colors ${activeTab === 'orders' ? 'border-hotel-600 text-hotel-600' : 'border-transparent text-gray-500 hover:text-gray-700'}`}>
          Pesanan ({orders.length})
        </button>
      </div>

      {activeTab === 'menu' ? (
        <>
          <div className="flex flex-wrap gap-2">
            {categories.map((c) => (
              <button key={c} onClick={() => setCategory(c)}
                className={`px-4 py-2 rounded-lg text-sm font-medium transition-all ${
                  category === c ? 'bg-hotel-600 text-white' : 'bg-white text-gray-600 hover:bg-gray-100 border border-gray-200'
                }`}>
                {c === 'ALL' ? 'Semua' : c}
              </button>
            ))}
          </div>

          <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-4">
            {filteredMenu.filter((m) => m.isAvailable).map((item) => (
              <div key={item.id} className="card hover:shadow-md transition-all">
                <div className="w-full h-32 bg-gradient-to-br from-hotel-100 to-hotel-200 rounded-lg mb-3 flex items-center justify-center">
                  <span className="text-4xl">
                    {item.category === 'MAKANAN' ? '🍽️' : item.category === 'MINUMAN' ? '🥤' : item.category === 'DESSERT' ? '🍰' : '🍿'}
                  </span>
                </div>
                <span className="text-xs font-medium text-hotel-600 uppercase">{item.category}</span>
                <h3 className="font-bold text-gray-900 mt-1">{item.name}</h3>
                {item.description && <p className="text-xs text-gray-500 mt-1 line-clamp-2">{item.description}</p>}
                <div className="flex items-center justify-between mt-3 pt-3 border-t border-gray-100">
                  <span className="font-bold text-hotel-700">{formatCurrency(item.price)}</span>
                  <button onClick={() => addToCart(item)}
                    className="w-8 h-8 bg-hotel-600 hover:bg-hotel-700 text-white rounded-lg flex items-center justify-center transition-colors">
                    <HiOutlinePlus className="w-4 h-4" />
                  </button>
                </div>
              </div>
            ))}
          </div>
        </>
      ) : (
        <DataTable
          columns={[
            { key: 'orderNumber', header: 'No. Pesanan', render: (o: any) => (
              <span className="font-mono font-semibold text-hotel-700">{o.orderNumber}</span>
            )},
            { key: 'orderType', header: 'Tipe', render: (o: any) => (
              <span className={`text-xs font-semibold px-2 py-1 rounded ${o.orderType === 'ROOM_SERVICE' ? 'bg-purple-100 text-purple-800' : 'bg-blue-100 text-blue-800'}`}>
                {o.orderType === 'ROOM_SERVICE' ? 'Room Service' : 'Restaurant'}
              </span>
            )},
            { key: 'roomNumber', header: 'Kamar', render: (o: any) => o.roomNumber || '-' },
            { key: 'items', header: 'Item', render: (o: any) => (
              <div>
                {o.items?.slice(0, 2).map((i: any) => (
                  <p key={i.id} className="text-sm">{i.quantity}x {i.menuItem.name}</p>
                ))}
                {o.items?.length > 2 && <p className="text-xs text-gray-500">+{o.items.length - 2} lainnya</p>}
              </div>
            )},
            { key: 'totalAmount', header: 'Total', render: (o: any) => (
              <span className="font-bold">{formatCurrency(o.totalAmount)}</span>
            )},
            { key: 'status', header: 'Status', render: (o: any) => <Badge status={o.status} /> },
          ]}
          data={orders}
          keyExtractor={(o: any) => o.id}
          emptyMessage="Belum ada pesanan"
        />
      )}

      <Modal isOpen={showCart} onClose={() => setShowCart(false)} title="Keranjang Pesanan" size="lg">
        {cart.length === 0 ? (
          <p className="text-center text-gray-500 py-8">Keranjang masih kosong</p>
        ) : (
          <div className="space-y-4">
            <div className="flex gap-2">
              <button onClick={() => setOrderType('RESTAURANT')}
                className={`flex-1 py-2.5 rounded-lg text-sm font-medium transition-all ${orderType === 'RESTAURANT' ? 'bg-hotel-600 text-white' : 'bg-gray-100 text-gray-700'}`}>
                🍽️ Dine In
              </button>
              <button onClick={() => setOrderType('ROOM_SERVICE')}
                className={`flex-1 py-2.5 rounded-lg text-sm font-medium transition-all ${orderType === 'ROOM_SERVICE' ? 'bg-hotel-600 text-white' : 'bg-gray-100 text-gray-700'}`}>
                🛎️ Room Service
              </button>
            </div>

            {orderType === 'ROOM_SERVICE' && (
              <div>
                <label className="label-field">Nomor Kamar</label>
                <input type="text" value={roomNumber} onChange={(e) => setRoomNumber(e.target.value)}
                  className="input-field" placeholder="Contoh: 101" required />
              </div>
            )}

            <div className="space-y-3 max-h-64 overflow-y-auto">
              {cart.map((item) => (
                <div key={item.id} className="flex items-center gap-3 p-3 bg-gray-50 rounded-lg">
                  <div className="flex-1">
                    <p className="font-medium text-sm">{item.name}</p>
                    <p className="text-xs text-gray-500">{formatCurrency(item.price)}</p>
                  </div>
                  <div className="flex items-center gap-2">
                    <button onClick={() => updateQuantity(item.id, item.quantity - 1)}
                      className="w-7 h-7 bg-white border rounded flex items-center justify-center text-sm">-</button>
                    <span className="w-8 text-center text-sm font-medium">{item.quantity}</span>
                    <button onClick={() => updateQuantity(item.id, item.quantity + 1)}
                      className="w-7 h-7 bg-white border rounded flex items-center justify-center text-sm">+</button>
                  </div>
                  <p className="font-bold text-sm w-24 text-right">{formatCurrency(item.price * item.quantity)}</p>
                </div>
              ))}
            </div>

            <div className="flex items-center justify-between pt-4 border-t">
              <span className="text-lg font-bold">Total</span>
              <span className="text-xl font-bold text-hotel-700">{formatCurrency(cartTotal)}</span>
            </div>

            <button onClick={submitOrder} className="btn-primary w-full">
              Buat Pesanan
            </button>
          </div>
        )}
      </Modal>
    </div>
  );
}
'@ | Set-Content -Path "src/app/restaurant/page.tsx" -Encoding UTF8
Write-Host "✅ src/app/restaurant/page.tsx" -ForegroundColor Green

# ============================================
# 26. src/app/payments/page.tsx
# ============================================
@'
'use client';

import { useEffect, useState } from 'react';
import { formatCurrency, formatDateTime } from '@/lib/utils';
import { DataTable } from '@/components/DataTable';
import { Badge } from '@/components/Badge';
import { Modal } from '@/components/Modal';
import { StatCard } from '@/components/StatCard';
import { HiOutlineCreditCard, HiOutlineClock, HiOutlineCheckCircle } from 'react-icons/hi2';
import { toast } from 'sonner';

interface Payment {
  id: string;
  paymentNumber: string;
  amount: number;
  paymentMethod: string;
  paymentStatus: string;
  paidAt: string | null;
  createdAt: string;
  booking?: { bookingNumber: string; guest: { firstName: string; lastName: string } };
  order?: { orderNumber: string; orderType: string };
}

export default function PaymentsPage() {
  const [payments, setPayments] = useState<Payment[]>([]);
  const [loading, setLoading] = useState(true);
  const [showModal, setShowModal] = useState(false);
  const [selectedPayment, setSelectedPayment] = useState<Payment | null>(null);
  const [paymentMethod, setPaymentMethod] = useState('');

  useEffect(() => { fetchPayments(); }, []);

  async function fetchPayments() {
    try {
      const res = await fetch('/api/payments');
      setPayments(await res.json());
    } catch { toast.error('Gagal memuat data pembayaran'); }
    finally { setLoading(false); }
  }

  async function processPayment() {
    if (!selectedPayment || !paymentMethod) return;
    try {
      const res = await fetch(`/api/payments?id=${selectedPayment.id}`, {
        method: 'PATCH',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ paymentMethod, paymentStatus: 'SUCCESS' }),
      });
      if (!res.ok) throw new Error();
      toast.success('Pembayaran berhasil diproses!');
      setShowModal(false);
      setSelectedPayment(null);
      setPaymentMethod('');
      fetchPayments();
    } catch { toast.error('Gagal memproses pembayaran'); }
  }

  const stats = {
    total: payments.length,
    success: payments.filter((p) => p.paymentStatus === 'SUCCESS').length,
    pending: payments.filter((p) => p.paymentStatus === 'PENDING').length,
    totalRevenue: payments.filter((p) => p.paymentStatus === 'SUCCESS').reduce((s, p) => s + p.amount, 0),
  };

  const columns = [
    { key: 'paymentNumber', header: 'No. Pembayaran', render: (p: Payment) => (
      <span className="font-mono font-semibold text-hotel-700">{p.paymentNumber}</span>
    )},
    { key: 'reference', header: 'Referensi', render: (p: Payment) => (
      <div>
        {p.booking ? (
          <><p className="text-sm font-medium">Booking: {p.booking.bookingNumber}</p>
          <p className="text-xs text-gray-500">{p.booking.guest.firstName} {p.booking.guest.lastName}</p></>
        ) : p.order ? (
          <><p className="text-sm font-medium">{p.order.orderType === 'ROOM_SERVICE' ? 'Room Service' : 'Restaurant'}: {p.order.orderNumber}</p></>
        ) : '-'}
      </div>
    )},
    { key: 'amount', header: 'Jumlah', render: (p: Payment) => (
      <span className="font-bold">{formatCurrency(p.amount)}</span>
    )},
    { key: 'paymentMethod', header: 'Metode', render: (p: Payment) => (
      <span className="text-sm">{p.paymentMethod?.replace(/_/g, ' ') || '-'}</span>
    )},
    { key: 'paymentStatus', header: 'Status', render: (p: Payment) => <Badge status={p.paymentStatus} /> },
    { key: 'paidAt', header: 'Tanggal Bayar', render: (p: Payment) => (
      <span className="text-sm">{p.paidAt ? formatDateTime(p.paidAt) : '-'}</span>
    )},
    { key: 'action', header: '', render: (p: Payment) => (
      p.paymentStatus === 'PENDING' ? (
        <button onClick={(e) => { e.stopPropagation(); setSelectedPayment(p); setShowModal(true); }}
          className="text-sm text-hotel-600 hover:text-hotel-700 font-medium">Proses →</button>
      ) : null
    )},
  ];

  if (loading) return <div className="flex items-center justify-center h-64"><div className="animate-spin rounded-full h-12 w-12 border-b-2 border-hotel-600" /></div>;

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-3xl font-bold text-gray-900">Pembayaran</h1>
        <p className="text-gray-500 mt-1">Kelola semua transaksi pembayaran</p>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-4 gap-4">
        <StatCard title="Total Transaksi" value={stats.total} icon={<HiOutlineCreditCard className="w-6 h-6" />} color="blue" />
        <StatCard title="Berhasil" value={stats.success} icon={<HiOutlineCheckCircle className="w-6 h-6" />} color="green" />
        <StatCard title="Pending" value={stats.pending} icon={<HiOutlineClock className="w-6 h-6" />} color="orange" />
        <StatCard title="Total Pendapatan" value={formatCurrency(stats.totalRevenue)} icon={<HiOutlineCreditCard className="w-6 h-6" />} color="gold" />
      </div>

      <DataTable columns={columns} data={payments} keyExtractor={(p) => p.id} emptyMessage="Belum ada transaksi" />

      <Modal isOpen={showModal} onClose={() => { setShowModal(false); setSelectedPayment(null); }} title="Proses Pembayaran">
        {selectedPayment && (
          <div className="space-y-4">
            <div className="bg-gray-50 rounded-lg p-4 space-y-2">
              <div className="flex justify-between">
                <span className="text-sm text-gray-500">No. Pembayaran</span>
                <span className="font-mono font-semibold">{selectedPayment.paymentNumber}</span>
              </div>
              <div className="flex justify-between">
                <span className="text-sm text-gray-500">Jumlah</span>
                <span className="font-bold text-lg text-hotel-700">{formatCurrency(selectedPayment.amount)}</span>
              </div>
            </div>

            <div>
              <label className="label-field">Metode Pembayaran</label>
              <select value={paymentMethod} onChange={(e) => setPaymentMethod(e.target.value)} className="input-field" required>
                <option value="">Pilih Metode</option>
                <option value="CASH">Tunai</option>
                <option value="CREDIT_CARD">Kartu Kredit</option>
                <option value="DEBIT_CARD">Kartu Debit</option>
                <option value="BANK_TRANSFER">Transfer Bank</option>
                <option value="E_WALLET">E-Wallet</option>
                <option value="QRIS">QRIS</option>
              </select>
            </div>

            <div className="flex gap-3 justify-end pt-4 border-t">
              <button onClick={() => { setShowModal(false); setSelectedPayment(null); }} className="btn-secondary">Batal</button>
              <button onClick={processPayment} disabled={!paymentMethod} className="btn-primary disabled:opacity-50">
                Konfirmasi Pembayaran
              </button>
            </div>
          </div>
        )}
      </Modal>
    </div>
  );
}
'@ | Set-Content -Path "src/app/payments/page.tsx" -Encoding UTF8
Write-Host "✅ src/app/payments/page.tsx" -ForegroundColor Green

Write-Host "`n🔌 Writing API routes..." -ForegroundColor Cyan

# ============================================
# 27. src/app/api/bookings/route.ts
# ============================================
@'
import { prisma } from '@/lib/prisma';
import { NextResponse } from 'next/server';
import { generateBookingNumber, calculateNights } from '@/lib/utils';

export async function GET() {
  try {
    const bookings = await prisma.booking.findMany({
      orderBy: { createdAt: 'desc' },
      include: {
        guest: true,
        room: { include: { roomType: true } },
        payments: true,
      },
    });
    return NextResponse.json(bookings);
  } catch (error) {
    console.error('Error fetching bookings:', error);
    return NextResponse.json({ error: 'Gagal memuat booking' }, { status: 500 });
  }
}

export async function POST(request: Request) {
  try {
    const body = await request.json();
    const { guestId, roomId, checkIn, checkOut, adults, children, specialRequest } = body;

    const room = await prisma.room.findUnique({
      where: { id: roomId },
      include: { roomType: true },
    });

    if (!room) return NextResponse.json({ error: 'Kamar tidak ditemukan' }, { status: 404 });
    if (room.status !== 'AVAILABLE') {
      return NextResponse.json({ error: 'Kamar tidak tersedia' }, { status: 400 });
    }

    const nights = calculateNights(new Date(checkIn), new Date(checkOut));
    if (nights <= 0) return NextResponse.json({ error: 'Tanggal tidak valid' }, { status: 400 });

    const totalPrice = room.pricePerNight * nights;

    const booking = await prisma.$transaction(async (tx) => {
      const newBooking = await tx.booking.create({
        data: {
          bookingNumber: generateBookingNumber(),
          guestId,
          roomId,
          roomTypeId: room.roomTypeId,
          checkIn: new Date(checkIn),
          checkOut: new Date(checkOut),
          adults: adults || 1,
          children: children || 0,
          totalPrice,
          status: 'CONFIRMED',
          specialRequest,
        },
      });

      await tx.room.update({
        where: { id: roomId },
        data: { status: 'RESERVED' },
      });

      return newBooking;
    });

    return NextResponse.json(booking, { status: 201 });
  } catch (error) {
    console.error('Error creating booking:', error);
    return NextResponse.json({ error: 'Gagal membuat booking' }, { status: 500 });
  }
}
'@ | Set-Content -Path "src/app/api/bookings/route.ts" -Encoding UTF8
Write-Host "✅ src/app/api/bookings/route.ts" -ForegroundColor Green

# ============================================
# 28. src/app/api/guests/route.ts
# ============================================
@'
import { prisma } from '@/lib/prisma';
import { NextResponse } from 'next/server';

export async function GET() {
  try {
    const guests = await prisma.guest.findMany({
      orderBy: { createdAt: 'desc' },
      include: { bookings: { take: 1, orderBy: { createdAt: 'desc' } } },
    });
    return NextResponse.json(guests);
  } catch (error) {
    return NextResponse.json({ error: 'Gagal memuat tamu' }, { status: 500 });
  }
}

export async function POST(request: Request) {
  try {
    const body = await request.json();
    const guest = await prisma.guest.create({ data: body });
    return NextResponse.json(guest, { status: 201 });
  } catch (error: any) {
    if (error.code === 'P2002') {
      return NextResponse.json({ error: 'Email sudah terdaftar' }, { status: 400 });
    }
    return NextResponse.json({ error: 'Gagal menambahkan tamu' }, { status: 500 });
  }
}
'@ | Set-Content -Path "src/app/api/guests/route.ts" -Encoding UTF8
Write-Host "✅ src/app/api/guests/route.ts" -ForegroundColor Green

# ============================================
# 29. src/app/api/rooms/route.ts
# ============================================
@'
import { prisma } from '@/lib/prisma';
import { NextResponse } from 'next/server';

export async function GET() {
  try {
    const rooms = await prisma.room.findMany({
      orderBy: [{ floor: 'asc' }, { roomNumber: 'asc' }],
      include: { roomType: true },
    });
    return NextResponse.json(rooms);
  } catch {
    return NextResponse.json({ error: 'Gagal memuat kamar' }, { status: 500 });
  }
}

export async function PATCH(request: Request) {
  try {
    const { searchParams } = new URL(request.url);
    const id = searchParams.get('id');
    const body = await request.json();

    if (!id) return NextResponse.json({ error: 'ID diperlukan' }, { status: 400 });

    const room = await prisma.room.update({
      where: { id },
      data: { status: body.status },
    });
    return NextResponse.json(room);
  } catch {
    return NextResponse.json({ error: 'Gagal mengubah status' }, { status: 500 });
  }
}
'@ | Set-Content -Path "src/app/api/rooms/route.ts" -Encoding UTF8
Write-Host "✅ src/app/api/rooms/route.ts" -ForegroundColor Green

# ============================================
# 30. src/app/api/restaurant/route.ts
# ============================================
@'
import { prisma } from '@/lib/prisma';
import { NextResponse } from 'next/server';
import { generateOrderNumber } from '@/lib/utils';

export async function GET(request: Request) {
  try {
    const { searchParams } = new URL(request.url);
    const type = searchParams.get('type');

    if (type === 'menu') {
      const items = await prisma.menuItem.findMany({ orderBy: { category: 'asc' } });
      return NextResponse.json(items);
    }

    if (type === 'orders') {
      const orders = await prisma.order.findMany({
        orderBy: { createdAt: 'desc' },
        include: { items: { include: { menuItem: true } } },
      });
      return NextResponse.json(orders);
    }

    return NextResponse.json({ error: 'Invalid type' }, { status: 400 });
  } catch {
    return NextResponse.json({ error: 'Gagal memuat data' }, { status: 500 });
  }
}

export async function POST(request: Request) {
  try {
    const body = await request.json();
    const { orderType, roomNumber, items } = body;

    const totalAmount = items.reduce((sum: number, item: any) => sum + item.price * item.quantity, 0);

    const order = await prisma.order.create({
      data: {
        orderNumber: generateOrderNumber(orderType === 'ROOM_SERVICE' ? 'RS' : 'RM'),
        orderType,
        roomNumber,
        totalAmount,
        status: 'PENDING',
        items: {
          create: items.map((item: any) => ({
            menuItemId: item.menuItemId,
            quantity: item.quantity,
            price: item.price,
          })),
        },
      },
      include: { items: { include: { menuItem: true } } },
    });

    return NextResponse.json(order, { status: 201 });
  } catch {
    return NextResponse.json({ error: 'Gagal membuat pesanan' }, { status: 500 });
  }
}
'@ | Set-Content -Path "src/app/api/restaurant/route.ts" -Encoding UTF8
Write-Host "✅ src/app/api/restaurant/route.ts" -ForegroundColor Green

# ============================================
# 31. src/app/api/payments/route.ts
# ============================================
@'
import { prisma } from '@/lib/prisma';
import { NextResponse } from 'next/server';
import { generatePaymentNumber } from '@/lib/utils';

export async function GET() {
  try {
    const payments = await prisma.payment.findMany({
      orderBy: { createdAt: 'desc' },
      include: {
        booking: { include: { guest: true } },
        order: true,
      },
    });
    return NextResponse.json(payments);
  } catch {
    return NextResponse.json({ error: 'Gagal memuat pembayaran' }, { status: 500 });
  }
}

export async function POST(request: Request) {
  try {
    const body = await request.json();
    const { bookingId, orderId, amount, paymentMethod } = body;

    const payment = await prisma.payment.create({
      data: {
        paymentNumber: generatePaymentNumber(),
        bookingId,
        orderId,
        amount,
        paymentMethod,
        paymentStatus: 'PENDING',
      },
    });

    return NextResponse.json(payment, { status: 201 });
  } catch {
    return NextResponse.json({ error: 'Gagal membuat pembayaran' }, { status: 500 });
  }
}

export async function PATCH(request: Request) {
  try {
    const { searchParams } = new URL(request.url);
    const id = searchParams.get('id');
    const body = await request.json();

    if (!id) return NextResponse.json({ error: 'ID diperlukan' }, { status: 400 });

    const payment = await prisma.$transaction(async (tx) => {
      const updated = await tx.payment.update({
        where: { id },
        data: {
          paymentMethod: body.paymentMethod,
          paymentStatus: body.paymentStatus,
          paidAt: body.paymentStatus === 'SUCCESS' ? new Date() : null,
        },
      });

      if (updated.bookingId && body.paymentStatus === 'SUCCESS') {
        await tx.booking.update({
          where: { id: updated.bookingId },
          data: { status: 'CONFIRMED' },
        });
        const booking = await tx.booking.findUnique({ where: { id: updated.bookingId } });
        if (booking) {
          await tx.room.update({
            where: { id: booking.roomId },
            data: { status: 'OCCUPIED' },
          });
        }
      }

      return updated;
    });

    return NextResponse.json(payment);
  } catch {
    return NextResponse.json({ error: 'Gagal memproses pembayaran' }, { status: 500 });
  }
}
'@ | Set-Content -Path "src/app/api/payments/route.ts" -Encoding UTF8
Write-Host "✅ src/app/api/payments/route.ts" -ForegroundColor Green

Write-Host "`n🎉 ALL FILES CREATED SUCCESSFULLY!" -ForegroundColor Green
Write-Host "📋 Next steps:" -ForegroundColor Yellow
Write-Host "  1. docker-compose up -d" -ForegroundColor White
Write-Host "  2. npm install" -ForegroundColor White
Write-Host "  3. npx prisma generate" -ForegroundColor White
Write-Host "  4. npx prisma db push" -ForegroundColor White
Write-Host "  5. npm run dev" -ForegroundColor White