import type { Metadata, Viewport } from "next";
import { Inter } from "next/font/google";
import "./globals.css";
import { Sidebar } from "@/components/Sidebar";
import { PWARegistration } from "@/components/PWARegistration";
import { Toaster } from "sonner";

const inter = Inter({ subsets: ["latin"] });

export const metadata: Metadata = {
  title: "Grand Hotel - Management System",
  description: "Sistem informasi manajemen hotel terpadu",
  applicationName: "Grand Hotel",
  manifest: "/manifest.webmanifest",
  icons: {
    icon: "/icons/grand-hotel-icon.svg",
    apple: "/icons/grand-hotel-icon.svg",
  },
};

export const viewport: Viewport = {
  width: "device-width",
  initialScale: 1,
  themeColor: "#1e3a5f",
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
            <div className="p-6 lg:p-8 animate-fadeIn">{children}</div>
          </main>
        </div>
        <Toaster position="top-right" richColors />
        <PWARegistration />
      </body>
    </html>
  );
}
