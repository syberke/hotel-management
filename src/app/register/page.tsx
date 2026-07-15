"use client";

import { useState } from "react";
import { useRouter } from "next/navigation";
import {
  HiOutlineUser,
  HiOutlineEnvelope,
  HiOutlineLockClosed,
  HiOutlinePhone,
} from "react-icons/hi2";
import { toast } from "sonner";

export default function RegisterPage() {
  const router = useRouter();
  const [loading, setLoading] = useState(false);
  const [formData, setFormData] = useState({
    firstName: "",
    lastName: "",
    email: "",
    phone: "",
    password: "",
    confirmPassword: "",
  });

  async function handleSubmit(e: React.FormEvent) {
    e.preventDefault();

    if (formData.password !== formData.confirmPassword) {
      toast.error("Password tidak cocok");
      return;
    }

    if (formData.password.length < 6) {
      toast.error("Password minimal 6 karakter");
      return;
    }

    setLoading(true);

    try {
      const res = await fetch("/api/auth/register", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
          email: formData.email,
          password: formData.password,
          firstName: formData.firstName,
          lastName: formData.lastName,
          phone: formData.phone,
        }),
      });

      const data = await res.json();

      if (!res.ok) {
        throw new Error(data.error || "Gagal registrasi");
      }

      toast.success("Registrasi berhasil! Silakan cek email untuk verifikasi.");
      router.push("/login");
    } catch (error: any) {
      toast.error(error.message || "Gagal registrasi");
    } finally {
      setLoading(false);
    }
  }

  return (
    <div className="min-h-screen flex items-center justify-center bg-gradient-to-br from-hotel-50 to-hotel-100 p-4">
      <div className="w-full max-w-md bg-white rounded-2xl shadow-xl p-8">
        <div className="text-center mb-8">
          <div className="w-16 h-16 bg-gradient-to-br from-gold-400 to-gold-600 rounded-2xl flex items-center justify-center mx-auto mb-4 shadow-lg">
            <span className="text-hotel-950 font-bold text-2xl">G</span>
          </div>
          <h1 className="text-2xl font-bold text-gray-900">Daftar Akun Baru</h1>
          <p className="text-gray-500 text-sm mt-1">
            Buat akun untuk booking kamar
          </p>
        </div>

        <form onSubmit={handleSubmit} className="space-y-4">
          <div className="grid grid-cols-2 gap-4">
            <div>
              <label className="label-field flex items-center gap-2">
                <HiOutlineUser className="w-4 h-4" /> Nama Depan
              </label>
              <input
                type="text"
                value={formData.firstName}
                onChange={(e) =>
                  setFormData({ ...formData, firstName: e.target.value })
                }
                className="input-field"
                required
              />
            </div>
            <div>
              <label className="label-field">Nama Belakang</label>
              <input
                type="text"
                value={formData.lastName}
                onChange={(e) =>
                  setFormData({ ...formData, lastName: e.target.value })
                }
                className="input-field"
                required
              />
            </div>
          </div>

          <div>
            <label className="label-field flex items-center gap-2">
              <HiOutlineEnvelope className="w-4 h-4" /> Email
            </label>
            <input
              type="email"
              value={formData.email}
              onChange={(e) =>
                setFormData({ ...formData, email: e.target.value })
              }
              className="input-field"
              required
            />
          </div>

          <div>
            <label className="label-field flex items-center gap-2">
              <HiOutlinePhone className="w-4 h-4" /> Telepon
            </label>
            <input
              type="tel"
              value={formData.phone}
              onChange={(e) =>
                setFormData({ ...formData, phone: e.target.value })
              }
              className="input-field"
            />
          </div>

          <div>
            <label className="label-field flex items-center gap-2">
              <HiOutlineLockClosed className="w-4 h-4" /> Password
            </label>
            <input
              type="password"
              value={formData.password}
              onChange={(e) =>
                setFormData({ ...formData, password: e.target.value })
              }
              className="input-field"
              required
              minLength={6}
            />
          </div>

          <div>
            <label className="label-field">Konfirmasi Password</label>
            <input
              type="password"
              value={formData.confirmPassword}
              onChange={(e) =>
                setFormData({ ...formData, confirmPassword: e.target.value })
              }
              className="input-field"
              required
              minLength={6}
            />
          </div>

          <button
            type="submit"
            disabled={loading}
            className="btn-primary w-full py-3 text-base mt-6 disabled:opacity-50"
          >
            {loading ? "Mendaftar..." : "Daftar"}
          </button>
        </form>

        <p className="text-center text-sm text-gray-600 mt-6">
          Sudah punya akun?{" "}
          <button
            onClick={() => router.push("/login")}
            className="text-hotel-600 hover:text-hotel-700 font-medium"
          >
            Login di sini
          </button>
        </p>
      </div>
    </div>
  );
}
