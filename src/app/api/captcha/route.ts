import { NextResponse } from "next/server";
import { generateCaptcha, verifyCaptcha } from "@/lib/captcha";

export async function GET() {
  const captcha = generateCaptcha();
  return NextResponse.json({
    token: captcha.token,
    question: captcha.question,
  });
}

export async function POST(request: Request) {
  try {
    const body = await request.json();
    const { token, answer } = body;

    const isValid = verifyCaptcha(token, answer);
    return NextResponse.json({ success: isValid });
  } catch {
    return NextResponse.json({ error: "Invalid request" }, { status: 400 });
  }
}
