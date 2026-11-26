import type { Config } from "tailwindcss";
const config: Config = {
  content: ["./app/**/*.{js,ts,jsx,tsx,mdx}", "./components/**/*.{js,ts,jsx,tsx,mdx}"],
  theme: { extend: { colors: { phantom: { bg: "#090d0c", panel: "#101715", line: "#24352e", green: "#9cff6b", muted: "#81958a" } }, fontFamily: { mono: ["var(--font-geist-mono)", "monospace"] } } },
  plugins: []
};
export default config;