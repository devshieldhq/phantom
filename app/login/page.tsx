"use client";
import { FormEvent, useState } from "react";
import Link from "next/link";
import { createClient } from "@/lib/supabase/client";

export default function LoginPage() {
  const [email, setEmail] = useState("");
  const [busy, setBusy] = useState(false);
  const [message, setMessage] = useState("");
  async function submit(e: FormEvent) {
    e.preventDefault();
    setBusy(true); setMessage("");
    try {
      const supabase = createClient();
      const { error } = await supabase.auth.signInWithOtp({
        email,
        options: { emailRedirectTo: `${window.location.origin}/auth/callback` }
      });
      if (error) throw error;
      setMessage("Check your inbox for your secure sign-in link.");
    } catch (err) {
      setMessage(err instanceof Error ? err.message : "Unable to send sign-in link.");
    } finally { setBusy(false); }
  }
  return <main className="terminal-grid flex min-h-screen items-center justify-center px-5">
    <section className="w-full max-w-md border border-[#24352e] bg-[#101715] p-7">
      <Link href="/" className="font-mono text-sm tracking-[.25em] text-[#9cff6b]">← PHANTOM</Link>
      <p className="mt-10 text-[10px] tracking-[.25em] text-[#81958a]">IDENTITY // AUTHENTICATION</p>
      <h1 className="mt-3 text-3xl font-bold">Reconnect to the network.</h1>
      <p className="mt-3 text-sm leading-6 text-[#9aaba1]">Enter your email. We'll send you a secure sign-in link.</p>
      <form onSubmit={submit} className="mt-7 space-y-3">
        <label htmlFor="email" className="block text-[10px] tracking-widest text-[#9cff6b]">EMAIL ADDRESS</label>
        <input id="email" type="email" required value={email} onChange={e=>setEmail(e.target.value)} placeholder="you@example.com" className="w-full border border-[#24352e] bg-[#090d0c] px-4 py-3 text-sm outline-none focus:border-[#9cff6b]"/>
        <button disabled={busy} className="w-full bg-[#9cff6b] px-4 py-3 text-xs font-black tracking-widest text-[#090d0c] disabled:opacity-50">{busy?"SENDING...":"SEND SIGN-IN LINK →"}</button>
      </form>
      {message && <p role="status" className="mt-4 border border-[#24352e] p-3 text-xs leading-5 text-[#b7c5bc]">{message}</p>}
    </section>
  </main>;
}