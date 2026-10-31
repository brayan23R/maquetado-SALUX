import { NextResponse } from 'next/server';
import {
  PRE_COOKIE,
  SESSION_COOKIE,
  clearAttempts,
  rateLimited,
  safeEqual,
  signToken,
  verifyToken,
  verifyTotp,
} from '@/lib/auth';

export async function POST(req: Request) {
  const ip = req.headers.get('x-forwarded-for') ?? 'local';
  if (rateLimited(`mfa:${ip}`)) {
    return NextResponse.json({ error: 'Demasiados intentos. Espera unos minutos.' }, { status: 429 });
  }
  const pre = req.headers.get('cookie')?.match(new RegExp(`${PRE_COOKIE}=([^;]+)`))?.[1];
  if (!verifyToken(pre, 'aal1')) {
    return NextResponse.json({ error: 'Verificación vencida. Inicia sesión otra vez.' }, { status: 401 });
  }
  let body: { code?: unknown };
  try {
    body = await req.json();
  } catch {
    return NextResponse.json({ error: 'Solicitud inválida' }, { status: 400 });
  }
  const code = typeof body.code === 'string' ? body.code.trim() : '';
  const demo = process.env.ADMIN_MFA_DEMO_CODE;
  const ok =
    /^\d{6}$/.test(code) &&
    ((demo ? safeEqual(code, demo) : false) || verifyTotp(code, process.env.ADMIN_TOTP_SECRET ?? 'AAAAAAAA'));
  if (!ok) return NextResponse.json({ error: 'Código incorrecto' }, { status: 401 });

  clearAttempts(`mfa:${ip}`);
  const res = NextResponse.json({ ok: true });
  res.cookies.set(SESSION_COOKIE, signToken('aal2', 8 * 3600), {
    httpOnly: true,
    sameSite: 'strict',
    path: '/',
    maxAge: 8 * 3600,
  });
  res.cookies.delete(PRE_COOKIE);
  return res;
}
