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
