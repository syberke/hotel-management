import { NextResponse } from "next/server";
import { prisma } from "@/lib/prisma";

export async function POST(request: Request) {
  try {
    const body = await request.json();
    const { paymentId } = body;

    if (!paymentId) {
      return NextResponse.json(
        { error: "Payment ID diperlukan" },
        { status: 400 },
      );
    }

    const payment = await prisma.payment.findUnique({
      where: { id: paymentId },
      include: {
        booking: { include: { guest: true, room: true } },
        order: { include: { guest: true } },
      },
    });

    if (!payment) {
      return NextResponse.json(
        { error: "Pembayaran tidak ditemukan" },
        { status: 404 },
      );
    }

    if (payment.paymentStatus === "SUCCESS") {
      return NextResponse.json(
        { error: "Pembayaran sudah lunas" },
        { status: 400 },
      );
    }

    // Ambil data Midtrans dari .env
    const serverKey = process.env.MIDTRANS_SERVER_KEY;
    const clientKey = process.env.MIDTRANS_CLIENT_KEY;

    if (!serverKey || !clientKey) {
      console.error("Midtrans keys missing:", { serverKey, clientKey });
      return NextResponse.json(
        { error: "Konfigurasi Midtrans tidak lengkap" },
        { status: 500 },
      );
    }

    const isBooking = !!payment.bookingId;
    const guestName = isBooking
      ? `${payment.booking?.guest?.firstName} ${payment.booking?.guest?.lastName}`
      : payment.order?.guest?.firstName || "Customer";
    const guestEmail = isBooking
      ? payment.booking?.guest?.email
      : payment.order?.guest?.email || "customer@example.com";
    const guestPhone = isBooking
      ? payment.booking?.guest?.phone
      : payment.order?.guest?.phone || "08123456789";
    const description = isBooking
      ? `Booking Kamar ${payment.booking?.room?.roomNumber}`
      : `Pesanan ${payment.order?.orderNumber}`;

    // Buat parameter untuk Midtrans Snap API
    const parameter = {
      transaction_details: {
        order_id: payment.paymentNumber,
        gross_amount: payment.amount,
      },
      customer_details: {
        first_name: guestName.split(" ")[0] || "Customer",
        last_name: guestName.split(" ").slice(1).join(" ") || "",
        email: guestEmail,
        phone: guestPhone,
      },
      item_details: [
        {
          id: payment.bookingId || payment.orderId || "0",
          price: payment.amount,
          quantity: 1,
          name: description,
        },
      ],
    };

    console.log("Sending to Midtrans:", JSON.stringify(parameter, null, 2));

    // Call Midtrans Snap API langsung
    const midtransResponse = await fetch(
      "https://app.sandbox.midtrans.com/snap/v1/transactions",
      {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          Authorization:
            "Basic " + Buffer.from(serverKey + ":").toString("base64"),
        },
        body: JSON.stringify(parameter),
      },
    );

    if (!midtransResponse.ok) {
      const errorData = await midtransResponse.json();
      console.error("Midtrans API Error:", errorData);
      return NextResponse.json(
        {
          error: "Gagal membuat transaksi Midtrans",
          details: errorData,
        },
        { status: midtransResponse.status },
      );
    }

    const transaction = await midtransResponse.json();
    console.log("Midtrans Response:", transaction);

    // Update status pembayaran
    await prisma.payment.update({
      where: { id: paymentId },
      data: {
        paymentStatus: "PROCESSING",
        transactionId: transaction.transaction_id || null,
      },
    });

    return NextResponse.json({
      token: transaction.token,
      redirectUrl: transaction.redirect_url,
      transactionId: transaction.transaction_id,
    });
  } catch (error: any) {
    console.error("Payment create error:", error);
    return NextResponse.json(
      {
        error: error.message || "Gagal membuat transaksi",
      },
      { status: 500 },
    );
  }
}
