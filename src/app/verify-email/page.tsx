"use client";

import { useEffect, useState } from "react";
import { useSearchParams, useRouter } from "next/navigation";
import { HiOutlineCheckCircle, HiOutlineXCircle } from "react-icons/hi2";

export default function VerifyEmailPage() {
  const searchParams = useSearchParams();
  const router = useRouter();
  const [status, setStatus] = useState<"loading" | "success" | "error">(
    "loading",
  );
  const [message, setMessage] = useState("");

  useEffect(() => {
    const token = searchParams.get("token");

    if (!token) {
      setStatus("error");
      setMessage("Token verifikasi tidak valid");
      return;
    }

    async function verifyEmail() {
      try {
        const res = await fetch(`/api/auth/verify-email?token=${token}`);
        const data = await res.json();

        if (!res.ok) {
          throw new Error(data.error || "Gagal verifikasi email");
        }

        setStatus("success");
        setMessage("Email berhasil diverifikasi! Silakan login.");
      } catch (error: any) {
        setStatus("error");
        setMessage(error.message || "Gagal verifikasi email");
      }
    }

    verifyEmail();
  }, [searchParams]);

  return (
    <div className="min-h-screen flex items-center justify-center bg-gradient-to-br from-hotel-50 to-hotel-100 p-4">
      <div className="w-full max-w-md bg-white rounded-2xl shadow-xl p-8 text-center">
        {status === "loading" && (
          <>
            <div className="animate-spin rounded-full h-16 w-16 border-b-2 border-hotel-600 mx-auto mb-4" />
            <p className="text-gray-600">Memverifikasi email...</p>
          </>
        )}

        {status === "success" && (
          <>
            <HiOutlineCheckCircle className="w-20 h-20 text-green-500 mx-auto mb-4" />
            <h1 className="text-2xl font-bold text-gray-900 mb-2">
              Verifikasi Berhasil!
            </h1>
            <p className="text-gray-600 mb-6">{message}</p>
            <button
              onClick={() => router.push("/login")}
              className="btn-primary w-full"
            >
              Login Sekarang
            </button>
          </>
        )}

        {status === "error" && (
          <>
            <HiOutlineXCircle className="w-20 h-20 text-red-500 mx-auto mb-4" />
            <h1 className="text-2xl font-bold text-gray-900 mb-2">
              Verifikasi Gagal
            </h1>
            <p className="text-gray-600 mb-6">{message}</p>
            <button
              onClick={() => router.push("/register")}
              className="btn-primary w-full"
            >
              Daftar Ulang
            </button>
          </>
        )}
      </div>
    </div>
  );
}
