import { NextResponse } from "next/server";
import { prisma } from "@/lib/prisma";
import { comparePassword, generateToken } from "@/lib/auth";

export async function POST(request: Request) {
  try {
    const body = await request.json();
    const { email, password } = body;

    if (!email || !password) {
      return NextResponse.json(
        { error: "Email dan password diperlukan" },
        { status: 400 },
      );
    }

    const user = await prisma.user.findUnique({ where: { email } });
    if (!user) {
      return NextResponse.json(
        { error: "Email tidak terdaftar" },
        { status: 401 },
      );
    }

    const isPasswordValid = await comparePassword(password, user.password);
    if (!isPasswordValid) {
      return NextResponse.json({ error: "Password salah" }, { status: 401 });
    }

    if (!user.isVerified) {
      return NextResponse.json(
        {
          error: "Email belum diverifikasi. Silakan cek email Anda.",
          userId: user.id,
        },
        { status: 403 },
      );
    }

    const token = generateToken(user.id);

    return NextResponse.json({
      message: "Login berhasil!",
      token,
      user: {
        id: user.id,
        email: user.email,
        firstName: user.firstName,
        lastName: user.lastName,
      },
    });
  } catch (error: any) {
    console.error("Login error:", error);
    return NextResponse.json(
      { error: error.message || "Gagal login" },
      { status: 500 },
    );
  }
}
