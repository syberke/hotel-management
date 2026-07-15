"use client";

import Link from "next/link";
import { usePathname, useRouter } from "next/navigation";
import { cn } from "@/lib/utils";
import {
  HiOutlineHome,
  HiOutlineCalendar,
  HiOutlineUserGroup,
  HiOutlineBuildingOffice2,
  HiOutlineShoppingBag,
  HiOutlineCreditCard,
  HiOutlineArrowRightOnRectangle,
} from "react-icons/hi2";
import { toast } from "sonner";

const navigation = [
  {
    label: "Dashboard",
    href: "/",
    icon: <HiOutlineHome className="w-5 h-5" />,
  },
  {
    label: "Booking",
    href: "/bookings",
    icon: <HiOutlineCalendar className="w-5 h-5" />,
  },
  {
    label: "Tamu",
    href: "/guests",
    icon: <HiOutlineUserGroup className="w-5 h-5" />,
  },
  {
    label: "Kamar",
    href: "/rooms",
    icon: <HiOutlineBuildingOffice2 className="w-5 h-5" />,
  },
  {
    label: "Restaurant",
    href: "/restaurant",
    icon: <HiOutlineShoppingBag className="w-5 h-5" />,
  },
  {
    label: "Pembayaran",
    href: "/payments",
    icon: <HiOutlineCreditCard className="w-5 h-5" />,
  },
];

export function Sidebar() {
  const pathname = usePathname();
  const router = useRouter();

  function handleLogout() {
    // Hapus cookie
    document.cookie =
      "admin_token=; path=/; expires=Thu, 01 Jan 1970 00:00:00 GMT";
    toast.success("Logout berhasil!");
    router.push("/login");
  }

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
                "flex items-center gap-3 px-4 py-3 rounded-xl text-sm font-medium transition-all duration-200",
                isActive
                  ? "bg-hotel-600 text-white shadow-lg shadow-hotel-600/30"
                  : "text-hotel-300 hover:bg-hotel-800 hover:text-white",
              )}
            >
              {item.icon}
              {item.label}
            </Link>
          );
        })}
      </nav>

      <div className="px-4 py-4 border-t border-hotel-800">
        <div className="flex items-center gap-3 px-4 py-3 rounded-xl bg-hotel-900 mb-3">
          <div className="w-9 h-9 bg-hotel-700 rounded-full flex items-center justify-center">
            <span className="text-sm font-bold">AD</span>
          </div>
          <div className="flex-1 min-w-0">
            <p className="text-sm font-medium truncate">Admin Hotel</p>
            <p className="text-xs text-hotel-400 truncate">
              admin@grandhotel.com
            </p>
          </div>
        </div>
        <button
          onClick={handleLogout}
          className="w-full flex items-center gap-3 px-4 py-3 rounded-xl text-sm font-medium text-red-400 hover:bg-red-900/20 hover:text-red-300 transition-all duration-200"
        >
          <HiOutlineArrowRightOnRectangle className="w-5 h-5" />
          Logout
        </button>
      </div>
    </aside>
  );
}
