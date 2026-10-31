'use client';

import { useState } from 'react';
import { useRouter } from 'next/navigation';

export default function LoginPage() {
  const router = useRouter();
  const [step, setStep] = useState<'password' | 'mfa'>('password');
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [code, setCode] = useState('');
  const [error, setError] = useState('');
  const [busy, setBusy] = useState(false);

  async function post(url: string, body: unknown) {
    setBusy(true);
    setError('');
    try {
      const res = await fetch(url, {
        method: 'POST',
        headers: { 'content-type': 'application/json' },
        body: JSON.stringify(body),
      });
      const data = (await res.json()) as { error?: string };
      if (!res.ok) throw new Error(data.error ?? 'Error inesperado');
      return data;
    } catch (e) {
      setError(e instanceof Error ? e.message : 'Error inesperado');
      return null;
    } finally {
      setBusy(false);
    }
  }

  async function submitPassword(e: React.FormEvent) {
    e.preventDefault();
    if (await post('/api/auth/login', { email, password })) setStep('mfa');
  }

  async function submitCode(e: React.FormEvent) {
    e.preventDefault();
    if (await post('/api/auth/mfa', { code })) {
      router.replace('/dashboard');
      router.refresh();
    }
  }

  return (
    <main className="login">
      <div className="card">
        <div className="brand">SALUX</div>
        <p className="muted" style={{ marginTop: 0 }}>Panel de administración</p>
        {step === 'password' ? (
          <form onSubmit={submitPassword}>
            <label className="field">
              Correo
              <input className="input" type="email" autoComplete="username" required value={email} onChange={(e) => setEmail(e.target.value)} />
            </label>
            <label className="field">
              Contraseña
              <input className="input" type="password" autoComplete="current-password" required value={password} onChange={(e) => setPassword(e.target.value)} />
            </label>
            {error && <p className="err-text" role="alert">{error}</p>}
            <button className="btn" style={{ width: '100%' }} disabled={busy}>Continuar</button>
          </form>
        ) : (
          <form onSubmit={submitCode}>
            <p>Ingresa el código de 6 dígitos de tu app autenticadora.</p>
            <label className="field">
              Código MFA
              <input className="input" inputMode="numeric" pattern="\d{6}" maxLength={6} required autoFocus value={code} onChange={(e) => setCode(e.target.value.replace(/\D/g, ''))} style={{ textAlign: 'center', fontSize: 22, letterSpacing: 6 }} />
            </label>
            {error && <p className="err-text" role="alert">{error}</p>}
            <button className="btn" style={{ width: '100%' }} disabled={busy || code.length !== 6}>Verificar</button>
          </form>
        )}
        <p className="muted" style={{ fontSize: 12, marginBottom: 0 }}>El acceso exige verificación en dos pasos (MFA).</p>
      </div>
    </main>
  );
}
