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
          className="text-sm text-hotel-600 hover:text-hotel-700 font-medium">Proses â†’</button>
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
