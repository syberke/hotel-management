import { NextResponse } from "next/server";
import { prisma } from "@/lib/prisma";

export async function GET(request: Request) {
  try {
    const { searchParams } = new URL(request.url);
    const token = searchParams.get("token");

    if (!token) {
      return NextResponse.json({ error: "Token tidak valid" }, { status: 400 });
    }

    const user = await prisma.user.findFirst({
      where: {
        verificationToken: token,
        verificationTokenExpiry: {
          gt: new Date(),
        },
      },
    });

    if (!user) {
      return NextResponse.json(
        { error: "Token tidak valid atau sudah kedaluwarsa" },
        { status: 400 },
      );
    }

    await prisma.user.update({
      where: { id: user.id },
      data: {
        isVerified: true,
        verificationToken: null,
        verificationTokenExpiry: null,
      },
    });

    return NextResponse.json({ message: "Email berhasil diverifikasi!" });
  } catch (error: any) {
    console.error("Verify email error:", error);
    return NextResponse.json(
      { error: error.message || "Gagal verifikasi email" },
      { status: 500 },
    );
  }
}
