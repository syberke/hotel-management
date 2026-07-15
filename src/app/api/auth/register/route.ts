import { NextResponse } from "next/server";
import { prisma } from "@/lib/prisma";
import { hashPassword, generateVerificationToken } from "@/lib/auth";
import { sendVerificationEmail } from "@/lib/email";

export async function POST(request: Request) {
  try {
    const body = await request.json();
    const { email, password, firstName, lastName, phone } = body;

    if (!email || !password || !firstName || !lastName) {
      return NextResponse.json(
        { error: "Data tidak lengkap" },
        { status: 400 },
      );
    }

    const existingUser = await prisma.user.findUnique({ where: { email } });
    if (existingUser) {
      return NextResponse.json(
        { error: "Email sudah terdaftar" },
        { status: 400 },
      );
    }

    const hashedPassword = await hashPassword(password);
    const verificationToken = generateVerificationToken();
    const verificationTokenExpiry = new Date(Date.now() + 24 * 60 * 60 * 1000);

    const user = await prisma.user.create({
      data: {
        email,
        password: hashedPassword,
        firstName,
        lastName,
        phone: phone || null,
        verificationToken,
        verificationTokenExpiry,
      },
    });

    const emailResult = await sendVerificationEmail(
      email,
      `${firstName} ${lastName}`,
      verificationToken,
    );

    if (!emailResult.success) {
      console.error("Failed to send verification email:", emailResult.error);
    }

    return NextResponse.json(
      {
        message: "Registrasi berhasil! Silakan cek email untuk verifikasi.",
        userId: user.id,
      },
      { status: 201 },
    );
  } catch (error: any) {
    console.error("Register error:", error);
    return NextResponse.json(
      { error: error.message || "Gagal registrasi" },
      { status: 500 },
    );
  }
}
