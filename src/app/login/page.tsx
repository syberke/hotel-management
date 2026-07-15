"use client";

import { useState, useEffect } from "react";
import { useRouter } from "next/navigation";
import { Captcha } from "@/components/Captcha";
import { toast } from "sonner";

export default function LoginPage() {
  const router = useRouter();
  const [username, setUsername] = useState("");
  const [password, setPassword] = useState("");
  const [captchaToken, setCaptchaToken] = useState("");
  const [captchaQuestion, setCaptchaQuestion] = useState("");
  const [captchaAnswer, setCaptchaAnswer] = useState("");

  useEffect(() => {
    fetchCaptcha();
  }, []);

  async function fetchCaptcha() {
    try {
      const res = await fetch("/api/captcha");
      const data = await res.json();
      setCaptchaToken(data.token);
      setCaptchaQuestion(data.question);
      setCaptchaAnswer("");
    } catch (error) {
      console.error("Failed to fetch captcha:", error);
    }
  }

  async function handleLogin(e: React.FormEvent) {
    e.preventDefault();

    // Verifikasi CAPTCHA
    const captchaRes = await fetch("/api/captcha", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({
        token: captchaToken,
        answer: parseInt(captchaAnswer),
      }),
    });
    const captchaData = await captchaRes.json();

    if (!captchaData.success) {
      toast.error("Jawaban CAPTCHA salah!");
      fetchCaptcha();
      return;
    }

    // Cek Username & Password
    if (username === "admin" && password === "admin123") {
      // Set cookie untuk session (24 jam)
      const expires = new Date();
      expires.setTime(expires.getTime() + 24 * 60 * 60 * 1000);
      document.cookie = `admin_token=true; path=/; expires=${expires.toUTCString()}; SameSite=Strict`;

      toast.success("Login berhasil! Selamat datang, Admin.");
      router.push("/");
    } else {
      toast.error("Username atau password salah!");
      fetchCaptcha();
    }
  }

  return (
    <div className="min-h-screen flex items-center justify-center bg-gradient-to-br from-hotel-50 to-hotel-100 p-4">
      <div className="w-full max-w-md bg-white rounded-2xl shadow-xl p-8 animate-fadeIn">
        <div className="text-center mb-8">
          <div className="w-16 h-16 bg-gradient-to-br from-gold-400 to-gold-600 rounded-2xl flex items-center justify-center mx-auto mb-4 shadow-lg">
            <span className="text-hotel-950 font-bold text-2xl">G</span>
          </div>
          <h1 className="text-2xl font-bold text-gray-900">Grand Hotel</h1>
          <p className="text-gray-500 text-sm mt-1">
            Silakan login untuk melanjutkan
          </p>
        </div>

        <form onSubmit={handleLogin} className="space-y-4">
          <div>
            <label className="label-field">Username</label>
            <input
              type="text"
              value={username}
              onChange={(e) => setUsername(e.target.value)}
              className="input-field"
              placeholder="admin"
              required
              autoFocus
            />
          </div>
          <div>
            <label className="label-field">Password</label>
            <input
              type="password"
              value={password}
              onChange={(e) => setPassword(e.target.value)}
              className="input-field"
              placeholder="admin123"
              required
            />
          </div>

          <div>
            <label className="label-field">Verifikasi Keamanan (CAPTCHA)</label>
            <Captcha
              token={captchaToken}
              question={captchaQuestion}
              onRefresh={fetchCaptcha}
            />
            <input
              type="number"
              value={captchaAnswer}
              onChange={(e) => setCaptchaAnswer(e.target.value)}
              placeholder="Masukkan jawaban"
              className="input-field mt-2"
              required
            />
          </div>

          <button
            type="submit"
            className="btn-primary w-full py-3 text-base mt-6"
          >
            Masuk
          </button>
        </form>

        <div className="mt-6 p-4 bg-gray-50 rounded-lg">
          <p className="text-xs text-gray-600 font-semibold mb-2">
            📝 Info Login:
          </p>
          <p className="text-xs text-gray-500">
            Username: <b className="text-hotel-700">admin</b>
          </p>
          <p className="text-xs text-gray-500">
            Password: <b className="text-hotel-700">admin123</b>
          </p>
        </div>

        {/* Link Daftar Akun Baru */}
        <div className="mt-6 text-center">
          <p className="text-sm text-gray-600">
            Tamu?{" "}
            <button
              onClick={() => router.push("/register")}
              className="text-hotel-600 hover:text-hotel-700 font-semibold"
            >
              Daftar Akun di sini
            </button>
          </p>
        </div>
      </div>
    </div>
  );
}
