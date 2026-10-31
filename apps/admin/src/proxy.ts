import { NextResponse } from 'next/server';
import type { NextRequest } from 'next/server';
import { SESSION_COOKIE, verifyToken } from '@/lib/auth';

/** Protege el panel: exige sesión con MFA (aal2) válida. */
export function proxy(req: NextRequest) {
  const { pathname } = req.nextUrl;
  const logged = verifyToken(req.cookies.get(SESSION_COOKIE)?.value, 'aal2');
  if (pathname === '/login') {
    return logged ? NextResponse.redirect(new URL('/dashboard', req.url)) : NextResponse.next();
  }
  if (!logged) return NextResponse.redirect(new URL('/login', req.url));
  if (pathname === '/') return NextResponse.redirect(new URL('/dashboard', req.url));
  return NextResponse.next();
}

export const config = {
  matcher: ['/((?!api|_next/static|_next/image|favicon.ico).*)'],
};
