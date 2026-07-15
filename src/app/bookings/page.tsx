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
