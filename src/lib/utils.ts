import { clsx, type ClassValue } from "clsx";

export function cn(...inputs: ClassValue[]) {
  return clsx(inputs);
}

export function formatCurrency(amount: number): string {
  return new Intl.NumberFormat("id-ID", {
    style: "currency",
    currency: "IDR",
    minimumFractionDigits: 0,
  }).format(amount);
}

export function formatDate(date: Date | string): string {
  return new Intl.DateTimeFormat("id-ID", {
    day: "numeric",
    month: "long",
    year: "numeric",
  }).format(new Date(date));
}

export function formatDateTime(date: Date | string): string {
  return new Intl.DateTimeFormat("id-ID", {
    day: "numeric",
    month: "short",
    year: "numeric",
    hour: "2-digit",
    minute: "2-digit",
  }).format(new Date(date));
}

export function generateBookingNumber(): string {
  const date = new Date();
  const dateStr = date.toISOString().slice(0, 10).replace(/-/g, "");
  const random = Math.floor(Math.random() * 10000)
    .toString()
    .padStart(4, "0");
  return `BK${dateStr}${random}`;
}

export function generateOrderNumber(type: "RS" | "RM"): string {
  const date = new Date();
  const dateStr = date.toISOString().slice(0, 10).replace(/-/g, "");
  const random = Math.floor(Math.random() * 10000)
    .toString()
    .padStart(4, "0");
  return `${type}${dateStr}${random}`;
}

export function generatePaymentNumber(): string {
  const date = new Date();
  const dateStr = date.toISOString().slice(0, 10).replace(/-/g, "");
  const random = Math.floor(Math.random() * 10000)
    .toString()
    .padStart(4, "0");
  return `PAY${dateStr}${random}`;
}

export function calculateNights(checkIn: Date, checkOut: Date): number {
  const diff = new Date(checkOut).getTime() - new Date(checkIn).getTime();
  return Math.ceil(diff / (1000 * 60 * 60 * 24));
}

export function getStatusColor(status: string): string {
  const colors: Record<string, string> = {
    AVAILABLE: "bg-green-100 text-green-800",
    OCCUPIED: "bg-red-100 text-red-800",
    MAINTENANCE: "bg-orange-100 text-orange-800",
    RESERVED: "bg-blue-100 text-blue-800",
    CLEANING: "bg-yellow-100 text-yellow-800",
    PENDING: "bg-yellow-100 text-yellow-800",
    CONFIRMED: "bg-blue-100 text-blue-800",
    CHECKED_IN: "bg-green-100 text-green-800",
    CHECKED_OUT: "bg-gray-100 text-gray-800",
    CANCELLED: "bg-red-100 text-red-800",
    NO_SHOW: "bg-purple-100 text-purple-800",
    SUCCESS: "bg-green-100 text-green-800",
    FAILED: "bg-red-100 text-red-800",
    PROCESSING: "bg-blue-100 text-blue-800",
    REFUNDED: "bg-purple-100 text-purple-800",
    PREPARING: "bg-orange-100 text-orange-800",
    READY: "bg-blue-100 text-blue-800",
    DELIVERED: "bg-green-100 text-green-800",
    COMPLETED: "bg-green-100 text-green-800",
  };
  return colors[status] || "bg-gray-100 text-gray-800";
}
