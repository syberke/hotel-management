"use client";

import { HiOutlineArrowPath } from "react-icons/hi2";

interface CaptchaProps {
  token: string;
  question: string;
  onRefresh: () => void;
}

export function Captcha({ token, question, onRefresh }: CaptchaProps) {
  return (
    <div className="space-y-3">
      <div className="flex items-center gap-2">
        <div className="flex-1 bg-gray-100 border border-gray-300 rounded-lg px-4 py-3 text-center font-mono text-lg font-bold text-gray-700 select-none">
          {question}
        </div>
        <button
          type="button"
          onClick={onRefresh}
          className="p-3 bg-gray-200 hover:bg-gray-300 rounded-lg transition-colors"
          title="Ganti Soal CAPTCHA"
        >
          <HiOutlineArrowPath className="w-5 h-5 text-gray-700" />
        </button>
      </div>
      <input type="hidden" name="captchaToken" value={token} />
    </div>
  );
}
