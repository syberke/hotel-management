import type { MetadataRoute } from "next";

export default function manifest(): MetadataRoute.Manifest {
  return {
    name: "Grand Hotel Management System",
    short_name: "Grand Hotel",
    description: "Sistem informasi manajemen hotel terpadu",
    start_url: "/",
    scope: "/",
    display: "standalone",
    background_color: "#f8fafc",
    theme_color: "#1e3a5f",
    orientation: "any",
    icons: [
      {
        src: "/icons/grand-hotel-icon.svg",
        sizes: "any",
        type: "image/svg+xml",
        purpose: "any",
      },
      {
        src: "/icons/grand-hotel-maskable.svg",
        sizes: "any",
        type: "image/svg+xml",
        purpose: "maskable",
      },
    ],
  };
}
