import type { Metadata } from "next";
import { Geist_Mono } from "next/font/google";
import "./globals.css";
const mono = Geist_Mono({ subsets: ["latin"], variable: "--font-geist-mono" });
export const metadata: Metadata = {
  title: "PHANTOM — The internet never really dies.",
  description: "A modern resurrection of Bulletin Board Systems. Find your room. Keep the signal alive."
};
export default function RootLayout({ children }: Readonly<{ children: React.ReactNode }>) {
  return <html lang="en"><body className={mono.variable}>{children}</body></html>;
}