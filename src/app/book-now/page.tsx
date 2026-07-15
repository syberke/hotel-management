"use client";

import { useEffect, useState } from "react";
import { useRouter } from "next/navigation";
import { formatCurrency } from "@/lib/utils";
import { Modal } from "@/components/Modal";
import {
  HiOutlineCalendar,
  HiOutlineUser,
  HiOutlineBuildingOffice,
  HiOutlineCreditCard,
} from "react-icons/hi2";
import { toast } from "sonner";

interface Room {
  id: string;
  roomNumber: string;
  floor: number;
  pricePerNight: number;
  status: string;
  image?: string | null;
  roomType: {
    id: string;
    name: string;
    capacity: number;
    amenities: string[];
  };
}

interface Guest {
  id: string;
  firstName: string;
  lastName: string;
  email: string;
  phone: string;
}

export default function BookNowPage() {
  const router = useRouter();
  const [rooms, setRooms] = useState<Room[]>([]);
  const [guests, setGuests] = useState<Guest[]>([]);
  const [loading, setLoading] = useState(true);
  const [selectedRoom, setSelectedRoom] = useState<Room | null>(null);
  const [showModal, setShowModal] = useState(false);
  const [checkIn, setCheckIn] = useState("");
  const [checkOut, setCheckOut] = useState("");
  const [adults, setAdults] = useState(2);
  const [children, setChildren] = useState(0);
  const [isExistingGuest, setIsExistingGuest] = useState(false);
  const [selectedGuestId, setSelectedGuestId] = useState("");
  const [guestForm, setGuestForm] = useState({
    firstName: "",
    lastName: "",
    email: "",
    phone: "",
    idCardNumber: "",
    nationality: "Indonesia",
    address: "",
  });

  useEffect(() => {
    fetchData();
    const today = new Date();
    const tomorrow = new Date(today);
    tomorrow.setDate(tomorrow.getDate() + 1);
    setCheckIn(today.toISOString().split("T")[0]);
    setCheckOut(tomorrow.toISOString().split("T")[0]);
  }, []);

  async function fetchData() {
    try {
      const [roomsRes, guestsRes] = await Promise.all([
        fetch("/api/rooms"),
        fetch("/api/guests"),
      ]);
      const roomsData = await roomsRes.json();
      const guestsData = await guestsRes.json();
      setRooms(roomsData.filter((r: Room) => r.status === "AVAILABLE"));
      setGuests(guestsData);
    } catch {
      toast.error("Gagal memuat data");
    } finally {
      setLoading(false);
    }
  }

  function handleBookRoom(room: Room) {
    setSelectedRoom(room);
    setShowModal(true);
  }

  async function handleSubmitBooking(e: React.FormEvent) {
    e.preventDefault();

    if (!selectedRoom || !checkIn || !checkOut) {
      toast.error("Mohon lengkapi data");
      return;
    }

    try {
      let guestId = selectedGuestId;

      if (!isExistingGuest) {
        const guestRes = await fetch("/api/guests", {
          method: "POST",
          headers: { "Content-Type": "application/json" },
          body: JSON.stringify(guestForm),
        });

        if (!guestRes.ok) {
          const error = await guestRes.json();
          throw new Error(error.error || "Gagal membuat data tamu");
        }

        const newGuest = await guestRes.json();
        guestId = newGuest.id;
      }

      const nights = Math.ceil(
        (new Date(checkOut).getTime() - new Date(checkIn).getTime()) /
          (1000 * 60 * 60 * 24),
      );
      if (nights <= 0) {
        toast.error("Tanggal check-out harus setelah check-in");
        return;
      }

      const totalPrice = selectedRoom.pricePerNight * nights;

      const bookingRes = await fetch("/api/bookings", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
          guestId,
          roomId: selectedRoom.id,
          roomTypeId: selectedRoom.roomType.id,
          checkIn,
          checkOut,
          adults,
          children,
          totalPrice,
          specialRequest: "",
        }),
      });

      if (!bookingRes.ok) {
        const error = await bookingRes.json();
        throw new Error(error.error || "Gagal membuat booking");
      }

      const booking = await bookingRes.json();

      toast.success(
        "Booking berhasil! Nomor booking: " + booking.bookingNumber,
      );
      setShowModal(false);
      router.push(`/my-booking?number=${booking.bookingNumber}`);
      fetchData();
    } catch (error: any) {
      toast.error(error.message || "Gagal membuat booking");
    }
  }

  const availableRooms = rooms.filter((r) => r.status === "AVAILABLE");

  if (loading) {
    return (
      <div className="flex items-center justify-center h-64">
        <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-hotel-600" />
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-gradient-to-br from-hotel-50 to-hotel-100 py-12 px-4">
      <div className="max-w-6xl mx-auto">
        <div className="text-center mb-12">
          <div className="flex items-center justify-center gap-3 mb-4">
            <div className="w-12 h-12 bg-gradient-to-br from-gold-400 to-gold-600 rounded-xl flex items-center justify-center shadow-lg">
              <span className="text-hotel-950 font-bold text-xl">G</span>
            </div>
            <h1 className="text-4xl font-bold text-gray-900">Grand Hotel</h1>
          </div>
          <h2 className="text-2xl font-semibold text-gray-700 mb-2">
            Pesan Kamar Sekarang
          </h2>
          <p className="text-gray-600">
            Nikmati pengalaman menginap yang nyaman dan mewah
          </p>
          <div className="mt-6 flex justify-center gap-4">
            <button
              onClick={() => router.push("/")}
              className="text-hotel-600 hover:text-hotel-700 font-medium text-sm"
            >
              ← Login Admin
            </button>
            <button
              onClick={() => router.push("/my-booking")}
              className="text-hotel-600 hover:text-hotel-700 font-medium text-sm"
            >
              Cek Booking Saya →
            </button>
          </div>
        </div>

        <div className="bg-white rounded-xl shadow-md p-6 mb-8">
          <div className="grid grid-cols-1 md:grid-cols-4 gap-4">
            <div>
              <label className="label-field flex items-center gap-2">
                <HiOutlineCalendar className="w-4 h-4" /> Check-in
              </label>
              <input
                type="date"
                value={checkIn}
                onChange={(e) => setCheckIn(e.target.value)}
                className="input-field"
                min={new Date().toISOString().split("T")[0]}
              />
            </div>
            <div>
              <label className="label-field flex items-center gap-2">
                <HiOutlineCalendar className="w-4 h-4" /> Check-out
              </label>
              <input
                type="date"
                value={checkOut}
                onChange={(e) => setCheckOut(e.target.value)}
                className="input-field"
                min={checkIn || new Date().toISOString().split("T")[0]}
              />
            </div>
            <div>
              <label className="label-field flex items-center gap-2">
                <HiOutlineUser className="w-4 h-4" /> Dewasa
              </label>
              <input
                type="number"
                value={adults}
                onChange={(e) => setAdults(parseInt(e.target.value))}
                min={1}
                max={10}
                className="input-field"
              />
            </div>
            <div>
              <label className="label-field flex items-center gap-2">
                <HiOutlineUser className="w-4 h-4" /> Anak-anak
              </label>
              <input
                type="number"
                value={children}
                onChange={(e) => setChildren(parseInt(e.target.value))}
                min={0}
                max={10}
                className="input-field"
              />
            </div>
          </div>
        </div>

        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
          {availableRooms.map((room) => (
            <div
              key={room.id}
              className="bg-white rounded-xl shadow-md overflow-hidden hover:shadow-lg transition-shadow"
            >
              {room.image && (
                <div className="w-full h-48 overflow-hidden bg-gray-200">
                  <img
                    src={room.image}
                    alt={`Kamar ${room.roomNumber}`}
                    className="w-full h-full object-cover"
                  />
                </div>
              )}
              <div className="p-6">
                <div className="flex items-start justify-between mb-3">
                  <div>
                    <h3 className="text-xl font-bold text-gray-900">
                      Kamar {room.roomNumber}
                    </h3>
                    <p className="text-sm text-gray-500 mt-0.5">
                      Lantai {room.floor}
                    </p>
                  </div>
                  <span className="px-3 py-1 bg-green-100 text-green-800 text-xs font-semibold rounded-full">
                    Tersedia
                  </span>
                </div>
                <div className="space-y-2 mb-4">
                  <div className="flex items-center gap-2 text-sm text-gray-600">
                    <HiOutlineBuildingOffice className="w-4 h-4" />
                    <span>{room.roomType.name}</span>
                  </div>
                  <p className="text-sm text-gray-600">
                    Maks. {room.roomType.capacity} orang
                  </p>
                  <div className="flex flex-wrap gap-2 mt-2">
                    {room.roomType.amenities.slice(0, 3).map((amenity) => (
                      <span
                        key={amenity}
                        className="text-xs px-2 py-1 bg-gray-100 text-gray-600 rounded"
                      >
                        {amenity}
                      </span>
                    ))}
                  </div>
                </div>
                <div className="flex items-center justify-between pt-4 border-t border-gray-100">
                  <div>
                    <p className="text-2xl font-bold text-hotel-700">
                      {formatCurrency(room.pricePerNight)}
                    </p>
                    <p className="text-xs text-gray-500">/malam</p>
                  </div>
                  <button
                    onClick={() => handleBookRoom(room)}
                    className="px-6 py-2.5 bg-hotel-600 hover:bg-hotel-700 text-white font-medium rounded-lg transition-colors"
                  >
                    Pesan
                  </button>
                </div>
              </div>
            </div>
          ))}
        </div>

        {availableRooms.length === 0 && (
          <div className="text-center py-12">
            <p className="text-gray-500 text-lg">
              Maaf, tidak ada kamar yang tersedia untuk saat ini.
            </p>
            <p className="text-gray-400 text-sm mt-2">
              Silakan coba tanggal lain atau hubungi kami.
            </p>
          </div>
        )}
      </div>

      <Modal
        isOpen={showModal}
        onClose={() => setShowModal(false)}
        title="Lengkapi Data Booking"
        size="lg"
      >
        <form onSubmit={handleSubmitBooking} className="space-y-4">
          {selectedRoom && (
            <div className="bg-hotel-50 p-4 rounded-lg mb-4">
              <p className="text-sm font-semibold text-hotel-900">
                Kamar {selectedRoom.roomNumber} - {selectedRoom.roomType.name}
              </p>
              <p className="text-sm text-hotel-700">
                {formatCurrency(selectedRoom.pricePerNight)}/malam
              </p>
            </div>
          )}

          <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
            <div>
              <label className="label-field">Check-in</label>
              <input
                type="date"
                value={checkIn}
                onChange={(e) => setCheckIn(e.target.value)}
                className="input-field"
                required
              />
            </div>
            <div>
              <label className="label-field">Check-out</label>
              <input
                type="date"
                value={checkOut}
                onChange={(e) => setCheckOut(e.target.value)}
                className="input-field"
                required
              />
            </div>
            <div>
              <label className="label-field">Dewasa</label>
              <input
                type="number"
                value={adults}
                onChange={(e) => setAdults(parseInt(e.target.value))}
                min={1}
                max={10}
                className="input-field"
                required
              />
            </div>
            <div>
              <label className="label-field">Anak-anak</label>
              <input
                type="number"
                value={children}
                onChange={(e) => setChildren(parseInt(e.target.value))}
                min={0}
                max={10}
                className="input-field"
              />
            </div>
          </div>

          <div className="border-t border-gray-200 pt-4 mt-4">
            <div className="flex items-center gap-2 mb-4">
              <input
                type="checkbox"
                id="existingGuest"
                checked={isExistingGuest}
                onChange={(e) => setIsExistingGuest(e.target.checked)}
                className="w-4 h-4 text-hotel-600 rounded"
              />
              <label
                htmlFor="existingGuest"
                className="text-sm font-medium text-gray-700"
              >
                Saya sudah pernah booking (data tamu tersimpan)
              </label>
            </div>

            {isExistingGuest ? (
              <div>
                <label className="label-field">Pilih Data Tamu</label>
                <select
                  value={selectedGuestId}
                  onChange={(e) => setSelectedGuestId(e.target.value)}
                  className="input-field"
                  required
                >
                  <option value="">-- Pilih Tamu --</option>
                  {guests.map((guest) => (
                    <option key={guest.id} value={guest.id}>
                      {guest.firstName} {guest.lastName} - {guest.email}
                    </option>
                  ))}
                </select>
              </div>
            ) : (
              <div className="space-y-4">
                <p className="text-sm font-semibold text-gray-700">Data Tamu</p>
                <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                  <div>
                    <label className="label-field">Nama Depan</label>
                    <input
                      type="text"
                      value={guestForm.firstName}
                      onChange={(e) =>
                        setGuestForm({
                          ...guestForm,
                          firstName: e.target.value,
                        })
                      }
                      className="input-field"
                      required
                    />
                  </div>
                  <div>
                    <label className="label-field">Nama Belakang</label>
                    <input
                      type="text"
                      value={guestForm.lastName}
                      onChange={(e) =>
                        setGuestForm({ ...guestForm, lastName: e.target.value })
                      }
                      className="input-field"
                      required
                    />
                  </div>
                  <div>
                    <label className="label-field">Email</label>
                    <input
                      type="email"
                      value={guestForm.email}
                      onChange={(e) =>
                        setGuestForm({ ...guestForm, email: e.target.value })
                      }
                      className="input-field"
                      required
                    />
                  </div>
                  <div>
                    <label className="label-field">Telepon</label>
                    <input
                      type="tel"
                      value={guestForm.phone}
                      onChange={(e) =>
                        setGuestForm({ ...guestForm, phone: e.target.value })
                      }
                      className="input-field"
                      required
                    />
                  </div>
                  <div>
                    <label className="label-field">No. KTP/Paspor</label>
                    <input
                      type="text"
                      value={guestForm.idCardNumber}
                      onChange={(e) =>
                        setGuestForm({
                          ...guestForm,
                          idCardNumber: e.target.value,
                        })
                      }
                      className="input-field"
                      required
                    />
                  </div>
                  <div>
                    <label className="label-field">Kebangsaan</label>
                    <input
                      type="text"
                      value={guestForm.nationality}
                      onChange={(e) =>
                        setGuestForm({
                          ...guestForm,
                          nationality: e.target.value,
                        })
                      }
                      className="input-field"
                      required
                    />
                  </div>
                </div>
                <div>
                  <label className="label-field">Alamat</label>
                  <textarea
                    value={guestForm.address}
                    onChange={(e) =>
                      setGuestForm({ ...guestForm, address: e.target.value })
                    }
                    className="input-field"
                    rows={2}
                    required
                  />
                </div>
              </div>
            )}
          </div>

          <div className="flex gap-3 justify-end pt-4 border-t">
            <button
              type="button"
              onClick={() => setShowModal(false)}
              className="btn-secondary"
            >
              Batal
            </button>
            <button type="submit" className="btn-primary">
              <HiOutlineCreditCard className="w-4 h-4 inline mr-2" />
              Lanjutkan Pembayaran
            </button>
          </div>
        </form>
      </Modal>
    </div>
  );
}
