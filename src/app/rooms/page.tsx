"use client";

import { useEffect, useState } from "react";
import { formatCurrency } from "@/lib/utils";
import { Badge } from "@/components/Badge";
import {
  HiOutlineBuildingOffice2,
  HiOutlineUserGroup,
  HiOutlineWifi,
  HiOutlineTv,
  HiOutlineFire,
} from "react-icons/hi2";
import { toast } from "sonner";

export default function RoomsPage() {
  const [rooms, setRooms] = useState<any[]>([]);
  const [loading, setLoading] = useState(true);
  const [filter, setFilter] = useState("ALL");

  useEffect(() => {
    fetchRooms();
  }, []);

  async function fetchRooms() {
    try {
      const res = await fetch("/api/rooms");
      setRooms(await res.json());
    } catch {
      toast.error("Gagal memuat data kamar");
    } finally {
      setLoading(false);
    }
  }

  async function updateStatus(roomId: string, status: string) {
    try {
      await fetch(`/api/rooms?id=${roomId}`, {
        method: "PATCH",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ status }),
      });
      toast.success("Status kamar diperbarui");
      fetchRooms();
    } catch {
      toast.error("Gagal mengubah status");
    }
  }

  const filtered =
    filter === "ALL" ? rooms : rooms.filter((r) => r.status === filter);
  const filters = [
    { label: "Semua", value: "ALL", count: rooms.length },
    {
      label: "Tersedia",
      value: "AVAILABLE",
      count: rooms.filter((r) => r.status === "AVAILABLE").length,
    },
    {
      label: "Terisi",
      value: "OCCUPIED",
      count: rooms.filter((r) => r.status === "OCCUPIED").length,
    },
    {
      label: "Reserved",
      value: "RESERVED",
      count: rooms.filter((r) => r.status === "RESERVED").length,
    },
    {
      label: "Maintenance",
      value: "MAINTENANCE",
      count: rooms.filter((r) => r.status === "MAINTENANCE").length,
    },
  ];

  if (loading)
    return (
      <div className="flex items-center justify-center h-64">
        <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-hotel-600" />
      </div>
    );

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-3xl font-bold text-gray-900">Kamar</h1>
        <p className="text-gray-500 mt-1">
          Kelola dan pantau status semua kamar hotel
        </p>
      </div>

      <div className="flex flex-wrap gap-2">
        {filters.map((f) => (
          <button
            key={f.value}
            onClick={() => setFilter(f.value)}
            className={`px-4 py-2 rounded-lg text-sm font-medium transition-all ${
              filter === f.value
                ? "bg-hotel-600 text-white shadow-md"
                : "bg-white text-gray-600 hover:bg-gray-100 border border-gray-200"
            }`}
          >
            {f.label} <span className="ml-1 opacity-75">({f.count})</span>
          </button>
        ))}
      </div>

      <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-4">
        {filtered.map((room) => (
          <div
            key={room.id}
            className="card hover:shadow-md transition-all duration-200 group overflow-hidden p-0"
          >
            {/* Gambar Kamar */}
            {room.image && (
              <div className="w-full h-48 overflow-hidden bg-gray-200">
                <img
                  src={room.image}
                  alt={`Kamar ${room.roomNumber}`}
                  className="w-full h-full object-cover hover:scale-105 transition-transform duration-300"
                  onError={(e) => {
                    e.currentTarget.style.display = "none";
                  }}
                />
              </div>
            )}

            <div className="p-6">
              <div className="flex items-start justify-between mb-3">
                <div>
                  <h3 className="text-lg font-bold text-gray-900">
                    Kamar {room.roomNumber}
                  </h3>
                  <p className="text-sm text-gray-500 mt-0.5">
                    Lantai {room.floor}
                  </p>
                </div>
                <Badge status={room.status} />
              </div>

              <div className="space-y-2 mb-4">
                <div className="flex items-center gap-2 text-sm text-gray-600">
                  <HiOutlineBuildingOffice2 className="w-4 h-4" />
                  <span>{room.roomType?.name || "Standard"}</span>
                </div>
                <div className="flex items-center gap-2 text-sm text-gray-600">
                  <HiOutlineUserGroup className="w-4 h-4" />
                  <span>Maks. {room.roomType?.capacity || 2} orang</span>
                </div>
                <div className="flex items-center gap-2 text-sm text-gray-600">
                  <HiOutlineWifi className="w-4 h-4" />
                  <span>WiFi</span>
                  <HiOutlineTv className="w-4 h-4 ml-2" />
                  <span>TV</span>
                  <HiOutlineFire className="w-4 h-4 ml-2" />
                  <span>AC</span>
                </div>
              </div>

              <div className="flex items-center justify-between pt-3 border-t border-gray-100">
                <p className="text-lg font-bold text-hotel-700">
                  {formatCurrency(room.pricePerNight)}
                  <span className="text-xs font-normal text-gray-500">
                    /malam
                  </span>
                </p>
                {room.status === "AVAILABLE" && (
                  <button
                    onClick={() => updateStatus(room.id, "MAINTENANCE")}
                    className="text-xs text-orange-600 hover:text-orange-700 font-medium"
                  >
                    Maintenance
                  </button>
                )}
                {room.status === "MAINTENANCE" && (
                  <button
                    onClick={() => updateStatus(room.id, "AVAILABLE")}
                    className="text-xs text-green-600 hover:text-green-700 font-medium"
                  >
                    Set Available
                  </button>
                )}
              </div>
            </div>
          </div>
        ))}
      </div>
    </div>
  );
}
