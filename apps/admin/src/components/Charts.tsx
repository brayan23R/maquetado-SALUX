'use client';

import { Bar, BarChart, CartesianGrid, Line, LineChart, ResponsiveContainer, Tooltip, XAxis, YAxis } from 'recharts';
import type { DayPoint } from '@/lib/data';

const PRIMARY = '#7360f2';
const MINT = '#1a9670';

export function SignupsChart({ data }: { data: DayPoint[] }) {
  return (
    <div style={{ width: '100%', height: 260 }} role="img" aria-label="Registros y usuarios activos por día">
      <ResponsiveContainer>
        <LineChart data={data} margin={{ top: 8, right: 8, left: -16, bottom: 0 }}>
          <CartesianGrid stroke="#8884" strokeDasharray="3 3" />
          <XAxis dataKey="day" tick={{ fontSize: 11 }} interval={4} />
          <YAxis tick={{ fontSize: 11 }} />
          <Tooltip />
          <Line type="monotone" dataKey="active" name="Activos" stroke={PRIMARY} strokeWidth={2.5} dot={false} />
          <Line type="monotone" dataKey="signups" name="Registros" stroke={MINT} strokeWidth={2.5} dot={false} />
        </LineChart>
      </ResponsiveContainer>
    </div>
  );
}

export function RevenueChart({ data }: { data: DayPoint[] }) {
  return (
    <div style={{ width: '100%', height: 260 }} role="img" aria-label="Ingresos por día en soles">
      <ResponsiveContainer>
        <BarChart data={data} margin={{ top: 8, right: 8, left: -16, bottom: 0 }}>
          <CartesianGrid stroke="#8884" strokeDasharray="3 3" vertical={false} />
          <XAxis dataKey="day" tick={{ fontSize: 11 }} interval={4} />
          <YAxis tick={{ fontSize: 11 }} />
          <Tooltip formatter={(v) => [`S/ ${v}`, 'Ingresos']} />
          <Bar dataKey="revenue" name="Ingresos" fill={PRIMARY} radius={[6, 6, 0, 0]} />
        </BarChart>
      </ResponsiveContainer>
    </div>
  );
}
