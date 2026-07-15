import { prisma } from "@/lib/prisma";
import { NextResponse } from "next/server";

export async function GET() {
  try {
    const rooms = await prisma.room.findMany({
      orderBy: [{ floor: "asc" }, { roomNumber: "asc" }],
      include: { roomType: true },
    });
    return NextResponse.json(rooms);
  } catch {
    return NextResponse.json({ error: "Gagal memuat kamar" }, { status: 500 });
  }
}

export async function PATCH(request: Request) {
  try {
    const { searchParams } = new URL(request.url);
    const id = searchParams.get("id");
    const body = await request.json();
    if (!id)
      return NextResponse.json({ error: "ID diperlukan" }, { status: 400 });

    const room = await prisma.room.update({
      where: { id },
      data: { status: body.status },
    });
    return NextResponse.json(room);
  } catch {
    return NextResponse.json(
      { error: "Gagal mengubah status" },
      { status: 500 },
    );
  }
}
