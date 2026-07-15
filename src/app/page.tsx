import { prisma } from "@/lib/prisma";
import { StatCard } from "@/components/StatCard";
import { formatCurrency, formatDate } from "@/lib/utils";
import { Badge } from "@/components/Badge";
import {
  HiOutlineCalendar,
  HiOutlineUserGroup,
  HiOutlineBuildingOffice2,
  HiOutlineCurrencyDollar,
  HiOutlineShoppingBag,
  HiOutlineClock,
} from "react-icons/hi2";
import { redirect } from "next/navigation"; // Optional: redirect to login if needed

export const dynamic = "force-dynamic";

export default async function DashboardPage() {
  const [
    totalBookings,
    totalGuests,
    totalRooms,
    availableRooms,
    occupiedRooms,
    revenueData,
    recentBookings,
  ] = await Promise.all([
    prisma.booking.count(),
    prisma.guest.count(),
    prisma.room.count(),
    prisma.room.count({ where: { status: "AVAILABLE" } }),
    prisma.room.count({ where: { status: "OCCUPIED" } }),
    prisma.payment.aggregate({
      _sum: { amount: true },
      where: { paymentStatus: "SUCCESS" },
    }),
    prisma.booking.findMany({
      take: 5,
      orderBy: { createdAt: "desc" },
      include: { guest: true, room: true },
    }),
  ]);

  const totalRevenue = revenueData._sum.amount || 0;
  const occupancyRate =
    totalRooms > 0 ? Math.round((occupiedRooms / totalRooms) * 100) : 0;

  return (
    <div className="space-y-8">
      <div>
        <h1 className="text-3xl font-bold text-gray-900">Dashboard</h1>
        <p className="text-gray-500 mt-1">
          Ringkasan hotel hari ini — {formatDate(new Date())}
        </p>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
        <StatCard
          title="Total Booking"
          value={totalBookings}
          icon={<HiOutlineCalendar className="w-6 h-6" />}
          color="blue"
          trend={{ value: 12, label: "dari bulan lalu" }}
        />
        <StatCard
          title="Total Tamu"
          value={totalGuests}
          icon={<HiOutlineUserGroup className="w-6 h-6" />}
          color="green"
          trend={{ value: 8, label: "dari bulan lalu" }}
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
          trend={{ value: 15, label: "dari bulan lalu" }}
        />
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
        <div className="card">
          <h3 className="text-lg font-bold text-gray-900 mb-4">
            Tingkat Hunian
          </h3>
          <div className="flex items-center justify-center py-6">
            <div className="relative w-40 h-40">
              <svg
                className="w-full h-full transform -rotate-90"
                viewBox="0 0 100 100"
              >
                <circle
                  cx="50"
                  cy="50"
                  r="40"
                  stroke="#e5e7eb"
                  strokeWidth="12"
                  fill="none"
                />
                <circle
                  cx="50"
                  cy="50"
                  r="40"
                  stroke="url(#gradient)"
                  strokeWidth="12"
                  fill="none"
                  strokeLinecap="round"
                  strokeDasharray={`${occupancyRate * 2.51} 251`}
                />
                <defs>
                  <linearGradient
                    id="gradient"
                    x1="0%"
                    y1="0%"
                    x2="100%"
                    y2="0%"
                  >
                    <stop offset="0%" stopColor="#0c93e7" />
                    <stop offset="100%" stopColor="#0074c5" />
                  </linearGradient>
                </defs>
              </svg>
              <div className="absolute inset-0 flex flex-col items-center justify-center">
                <span className="text-3xl font-bold text-gray-900">
                  {occupancyRate}%
                </span>
                <span className="text-xs text-gray-500">terisi</span>
              </div>
            </div>
          </div>
        </div>

        <div className="lg:col-span-2 card">
          <div className="flex items-center justify-between mb-4">
            <h3 className="text-lg font-bold text-gray-900">Booking Terbaru</h3>
            <a
              href="/bookings"
              className="text-sm text-hotel-600 hover:text-hotel-700 font-medium"
            >
              Lihat Semua →
            </a>
          </div>
          <div className="space-y-3">
            {recentBookings.map((booking) => (
              <div
                key={booking.id}
                className="flex items-center gap-4 p-3 rounded-lg hover:bg-gray-50 transition-colors"
              >
                <div className="w-10 h-10 bg-hotel-100 rounded-full flex items-center justify-center">
                  <span className="text-sm font-bold text-hotel-700">
                    {booking.guest.firstName[0]}
                    {booking.guest.lastName[0]}
                  </span>
                </div>
                <div className="flex-1 min-w-0">
                  <p className="text-sm font-semibold text-gray-900 truncate">
                    {booking.guest.firstName} {booking.guest.lastName}
                  </p>
                  <p className="text-xs text-gray-500">
                    Kamar {booking.room.roomNumber} •{" "}
                    {formatDate(booking.checkIn)}
                  </p>
                </div>
                <div className="text-right">
                  <p className="text-sm font-bold text-gray-900">
                    {formatCurrency(booking.totalPrice)}
                  </p>
                  <Badge status={booking.status} />
                </div>
              </div>
            ))}
            {recentBookings.length === 0 && (
              <p className="text-center text-gray-500 py-8">
                Belum ada booking
              </p>
            )}
          </div>
        </div>
      </div>
    </div>
  );
}
