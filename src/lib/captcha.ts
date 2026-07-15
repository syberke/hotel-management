export interface CaptchaChallenge {
  question: string;
  answer: number;
  token: string;
}

const activeCaptchas = new Map<string, number>();

export function generateCaptcha(): CaptchaChallenge {
  const num1 = Math.floor(Math.random() * 10) + 1;
  const num2 = Math.floor(Math.random() * 10) + 1;
  const answer = num1 + num2;
  const token = Math.random().toString(36).substring(2, 15);

  activeCaptchas.set(token, answer);
  setTimeout(() => activeCaptchas.delete(token), 5 * 60 * 1000);

  return {
    question: `Berapa ${num1} + ${num2}?`,
    answer,
    token,
  };
}

export function verifyCaptcha(token: string, answer: number): boolean {
  const correctAnswer = activeCaptchas.get(token);
  if (correctAnswer === undefined) return false;

  activeCaptchas.delete(token);

  return correctAnswer === answer;
}
