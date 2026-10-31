import { createHmac, timingSafeEqual } from 'node:crypto';

export const SESSION_COOKIE = 'salux_session';
export const PRE_COOKIE = 'salux_pre';

function secret(): string {
  const s = process.env.SESSION_SECRET;
  if (!s || s.length < 32) throw new Error('SESSION_SECRET no configurado (mínimo 32 caracteres)');
  return s;
}

/** Comparación en tiempo constante. */
export function safeEqual(a: string, b: string): boolean {
  const ha = createHmac('sha256', 'cmp').update(a).digest();
  const hb = createHmac('sha256', 'cmp').update(b).digest();
  return timingSafeEqual(ha, hb);
}

/** Token firmado: `<tipo>.<expira>.<firma>`. `aal1` = solo contraseña, `aal2` = con MFA. */
export function signToken(kind: 'aal1' | 'aal2', ttlSeconds: number): string {
  const exp = Math.floor(Date.now() / 1000) + ttlSeconds;
  const body = `${kind}.${exp}`;
  const sig = createHmac('sha256', secret()).update(body).digest('base64url');
  return `${body}.${sig}`;
}

export function verifyToken(token: string | undefined, kind: 'aal1' | 'aal2'): boolean {
  if (!token) return false;
  const parts = token.split('.');
  if (parts.length !== 3 || parts[0] !== kind) return false;
  const expected = createHmac('sha256', secret()).update(`${parts[0]}.${parts[1]}`).digest('base64url');
  if (!safeEqual(parts[2], expected)) return false;
  return Number(parts[1]) > Math.floor(Date.now() / 1000);
}

// ---------------------------------------------------------------- TOTP (RFC 6238)

const B32 = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ234567';

function base32Decode(input: string): Buffer {
  let bits = '';
  for (const ch of input.replace(/=+$/, '').toUpperCase()) {
    const v = B32.indexOf(ch);
    if (v < 0) throw new Error('Secreto TOTP inválido');
    bits += v.toString(2).padStart(5, '0');
  }
  const bytes: number[] = [];
  for (let i = 0; i + 8 <= bits.length; i += 8) bytes.push(parseInt(bits.slice(i, i + 8), 2));
  return Buffer.from(bytes);
}

function totpAt(secretB32: string, counter: number): string {
  const buf = Buffer.alloc(8);
  buf.writeBigUInt64BE(BigInt(counter));
  const h = createHmac('sha1', base32Decode(secretB32)).update(buf).digest();
  const off = h[h.length - 1] & 0xf;
  const code = ((h[off] & 0x7f) << 24) | (h[off + 1] << 16) | (h[off + 2] << 8) | h[off + 3];
  return String(code % 1_000_000).padStart(6, '0');
}

/** Verifica un código TOTP con tolerancia de ±1 paso (30 s). */
export function verifyTotp(code: string, secretB32: string): boolean {
  if (!/^\d{6}$/.test(code)) return false;
  const step = Math.floor(Date.now() / 30000);
  return [-1, 0, 1].some((d) => safeEqual(totpAt(secretB32, step + d), code));
}

// ------------------------------------------------- Límite de intentos (en memoria)

const attempts = new Map<string, { n: number; reset: number }>();

/** Devuelve true si la clave superó `max` intentos en la ventana. */
export function rateLimited(key: string, max = 5, windowMs = 15 * 60_000): boolean {
  const now = Date.now();
  const cur = attempts.get(key);
  if (!cur || cur.reset < now) {
    attempts.set(key, { n: 1, reset: now + windowMs });
    return false;
  }
  cur.n += 1;
  return cur.n > max;
}

export function clearAttempts(key: string): void {
  attempts.delete(key);
}
