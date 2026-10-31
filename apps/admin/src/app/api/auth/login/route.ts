import { NextResponse } from 'next/server';
import { PRE_COOKIE, clearAttempts, rateLimited, safeEqual, signToken } from '@/lib/auth';

export async function POST(req: Request) {
  const ip = req.headers.get('x-forwarded-for') ?? 'local';
  if (rateLimited(`login:${ip}`)) {
    return NextResponse.json({ error: 'Demasiados intentos. Espera unos minutos.' }, { status: 429 });
  }
  let body: { email?: unknown; password?: unknown };
  try {
    body = await req.json();
  } catch {
    return NextResponse.json({ error: 'Solicitud inválida' }, { status: 400 });
  }
  const email = typeof body.email === 'string' ? body.email.trim().toLowerCase() : '';
  const password = typeof body.password === 'string' ? body.password : '';
  const okEmail = safeEqual(email, (process.env.ADMIN_EMAIL ?? '').toLowerCase());
  const okPass = safeEqual(password, process.env.ADMIN_PASSWORD ?? '\u0000');
  if (!okEmail || !okPass) {
    return NextResponse.json({ error: 'Correo o contraseña incorrectos' }, { status: 401 });
  }
  clearAttempts(`login:${ip}`);
  const res = NextResponse.json({ mfa: true });
  res.cookies.set(PRE_COOKIE, signToken('aal1', 300), {
    httpOnly: true,
    sameSite: 'strict',
    path: '/',
    maxAge: 300,
  });
  return res;
}
