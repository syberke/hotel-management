import type { Config } from "tailwindcss";

const config: Config = {
  content: [
    "./src/pages/**/*.{js,ts,jsx,tsx,mdx}",
    "./src/components/**/*.{js,ts,jsx,tsx,mdx}",
    "./src/app/**/*.{js,ts,jsx,tsx,mdx}",
  ],
  theme: {
    extend: {
      colors: {
        hotel: {
          50: "#f0f7ff",
          100: "#e0effe",
          200: "#bae0fd",
          300: "#7cc8fb",
          400: "#36adf6",
          500: "#0c93e7",
          600: "#0074c5",
          700: "#015da0",
          800: "#065084",
          900: "#0b436e",
          950: "#072b49",
        },
        gold: {
          50: "#fdfbea",
          100: "#fbf5c6",
          200: "#f8e98f",
          300: "#f4d64d",
          400: "#efc020",
          500: "#e0a50d",
          600: "#c48008",
          700: "#9e5c0a",
          800: "#834910",
          900: "#6f3c13",
          950: "#401e06",
        },
      },
    },
  },
  plugins: [],
};

export default config;
