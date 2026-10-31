import 'server-only';
import { readFileSync } from 'node:fs';
import path from 'node:path';

/**
 * Capa de datos del panel. Hoy es un repositorio MOCK con datos de
 * demostración; en modo Supabase se reemplaza por consultas parametrizadas
 * (supabase-js / RPC `admin_*`), nunca SQL armado con texto.
 */

export type Kpis = {
  totalUsers: number;
  activeToday: number;
  activeWeek: number;
  inTrial: number;
  premium: number;
  conversion: number;
  revenueMonth: number;
  avgStreak: number;
  simulations: number;
};

export type DayPoint = { day: string; signups: number; revenue: number; active: number };

export type UserRow = {
  id: string;
  name: string;
  email: string;
  career: string;
  plan: 'Prueba' | 'Premium' | 'Gratis';
  streak: number;
  joined: string;
  status: 'Activo' | 'Bloqueado';
};

export type PaymentRow = {
  id: string;
  user: string;
  plan: string;
  method: 'Yape' | 'Plin' | 'Tarjeta';
  amount: number;
  status: 'Pagado' | 'Pendiente' | 'Rechazado';
  date: string;
};

export type AuditRow = { id: string; who: string; action: string; target: string; at: string };

export type QuestionRow = {
  id: string;
  exam: string;
  topic: string;
  text: string;
  correct: string;
  status: 'Publicado' | 'Borrador';
};

export type FailedQuestion = { text: string; failRate: number; exam: string };

/** PRNG determinista para que la demo sea estable entre recargas. */
function rng(seed: number) {
  let s = seed;
  return () => {
    s = (s * 1664525 + 1013904223) % 4294967296;
    return s / 4294967296;
  };
}

const NAMES = ['Camila Rojas', 'Diego Mendoza', 'Valeria Soto', 'Andrés Paredes', 'Lucía Herrera', 'Marco Tello', 'Sofía Quispe', 'Renzo Salas', 'Ximena Vega', 'Jorge Ramos', 'Daniela Cruz', 'Mateo Flores', 'Paula Núñez', 'Bruno Castro', 'Ariana Luna', 'Kevin Ortiz', 'Fiorella Díaz', 'Álvaro Peña', 'Milagros Vera', 'Iván Campos', 'Rocío Paz', 'Gonzalo Rey', 'Alexia Mora', 'Hugo Ríos'];
const CAREERS = ['Medicina', 'Enfermería', 'Obstetricia', 'Odontología', 'Psicología', 'Nutrición'];

function isoDay(offset: number): string {
  const d = new Date();
  d.setDate(d.getDate() - offset);
  return d.toISOString().slice(0, 10);
}

export const repo = {
  kpis(): Kpis {
    const users = this.users();
    const premium = users.filter((u) => u.plan === 'Premium').length;
    const trial = users.filter((u) => u.plan === 'Prueba').length;
    return {
      totalUsers: users.length,
      activeToday: Math.round(users.length * 0.42),
      activeWeek: Math.round(users.length * 0.71),
      inTrial: trial,
      premium,
      conversion: Math.round((premium / users.length) * 100),
      revenueMonth: this.payments().filter((p) => p.status === 'Pagado').reduce((a, p) => a + p.amount, 0),
      avgStreak: Math.round(users.reduce((a, u) => a + u.streak, 0) / users.length),
      simulations: 312,
    };
  },

  series(days = 30): DayPoint[] {
    const r = rng(7);
    return Array.from({ length: days }, (_, i) => {
      const day = isoDay(days - 1 - i);
      return {
        day: day.slice(5),
        signups: 2 + Math.round(r() * 8 + i * 0.15),
        revenue: Math.round((r() * 140 + 40) / 10) * 10,
        active: 20 + Math.round(r() * 30 + i * 0.5),
      };
    });
  },

  users(): UserRow[] {
    const r = rng(42);
    return NAMES.map((name, i) => {
      const plan = r() > 0.62 ? 'Premium' : r() > 0.35 ? 'Prueba' : 'Gratis';
      return {
        id: `u${String(i + 1).padStart(3, '0')}`,
        name,
        email: `${name.split(' ')[0].toLowerCase().normalize('NFD').replace(/[̀-ͯ]/g, '')}${i + 1}@correo.demo`,
        career: CAREERS[Math.floor(r() * CAREERS.length)],
        plan,
        streak: Math.floor(r() * 24),
        joined: isoDay(Math.floor(r() * 60)),
        status: i === 5 ? 'Bloqueado' : 'Activo',
      };
    });
  },

  payments(): PaymentRow[] {
    const r = rng(99);
    const plans = [
      ['Mensual', 29],
      ['Trimestral', 69],
      ['Anual', 199],
    ] as const;
    const methods = ['Yape', 'Plin', 'Tarjeta'] as const;
    return Array.from({ length: 16 }, (_, i) => {
      const [plan, amount] = plans[Math.floor(r() * 3)];
      const st = r();
      return {
        id: `ord_${1000 + i}`,
        user: NAMES[Math.floor(r() * NAMES.length)],
        plan,
        method: methods[Math.floor(r() * 3)],
        amount,
        status: st > 0.2 ? 'Pagado' : st > 0.08 ? 'Pendiente' : 'Rechazado',
        date: isoDay(Math.floor(r() * 25)),
      };
    });
  },

  audit(): AuditRow[] {
    return [
      { id: 'a1', who: 'admin@salux.local', action: 'Inició sesión (MFA)', target: 'Panel', at: 'hoy 09:12' },
      { id: 'a2', who: 'admin@salux.local', action: 'Publicó 10 preguntas', target: 'ENAM', at: 'hoy 09:30' },
      { id: 'a3', who: 'soporte@salux.local', action: 'Extendió prueba +2 días', target: 'u007', at: 'ayer 16:45' },
      { id: 'a4', who: 'finanzas@salux.local', action: 'Exportó pagos CSV', target: 'Pagos', at: 'ayer 11:02' },
      { id: 'a5', who: 'admin@salux.local', action: 'Cambió precio plan Anual', target: 'plans', at: 'hace 3 días' },
    ];
  },

  /** Banco real de preguntas: se lee del seed del proyecto (sin duplicarlo). */
  questions(): QuestionRow[] {
    const file = path.resolve(process.cwd(), '..', '..', 'seed', 'questions.seed.json');
    const json = JSON.parse(readFileSync(file, 'utf-8')) as {
      questions: { exam: string; topic: string; text: string; options: { label: string; text: string; is_correct: boolean }[] }[];
    };
    return json.questions.map((q, i) => ({
      id: `q${String(i + 1).padStart(3, '0')}`,
      exam: q.exam,
      topic: q.topic,
      text: q.text,
      correct: q.options.find((o) => o.is_correct)?.text ?? '—',
      status: i % 9 === 8 ? 'Borrador' : 'Publicado',
    }));
  },

  topFailed(): FailedQuestion[] {
    return this.questions()
      .slice(0, 5)
      .map((q, i) => ({ text: q.text.slice(0, 70) + '…', failRate: 68 - i * 7, exam: q.exam }));
  },
};

export const money = (n: number) => `S/ ${n.toLocaleString('es-PE')}`;
