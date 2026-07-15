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
