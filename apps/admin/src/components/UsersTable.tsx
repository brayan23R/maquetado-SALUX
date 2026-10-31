'use client';

import { useMemo, useState } from 'react';
import type { UserRow } from '@/lib/data';

const PLANS = ['Todos', 'Premium', 'Prueba', 'Gratis'] as const;

export default function UsersTable({ users }: { users: UserRow[] }) {
  const [q, setQ] = useState('');
  const [plan, setPlan] = useState<(typeof PLANS)[number]>('Todos');
  const [blocked, setBlocked] = useState<Set<string>>(new Set(users.filter((u) => u.status === 'Bloqueado').map((u) => u.id)));

  const rows = useMemo(() => {
    const t = q.trim().toLowerCase();
    return users.filter((u) => (plan === 'Todos' || u.plan === plan) && (!t || `${u.name} ${u.email} ${u.career}`.toLowerCase().includes(t)));
  }, [users, q, plan]);

  function toggle(id: string) {
    setBlocked((prev) => {
      const next = new Set(prev);
      if (!next.delete(id)) next.add(id);
      return next;
    });
  }

  return (
    <>
      <div className="row" style={{ marginBottom: 14 }}>
        <input className="input" style={{ maxWidth: 320 }} placeholder="Buscar por nombre, correo o carrera" aria-label="Buscar usuarios" value={q} onChange={(e) => setQ(e.target.value)} />
        <select className="input" style={{ maxWidth: 180 }} aria-label="Filtrar por plan" value={plan} onChange={(e) => setPlan(e.target.value as (typeof PLANS)[number])}>
          {PLANS.map((p) => <option key={p}>{p}</option>)}
        </select>
        <span className="muted">{rows.length} usuarios</span>
      </div>
      <div className="card tablewrap">
        <table>
          <thead>
            <tr><th>Usuario</th><th>Carrera</th><th>Plan</th><th>Racha</th><th>Registro</th><th>Estado</th><th /></tr>
          </thead>
          <tbody>
            {rows.map((u) => {
              const isBlocked = blocked.has(u.id);
              return (
                <tr key={u.id}>
                  <td><strong>{u.name}</strong><br /><span className="muted">{u.email}</span></td>
                  <td>{u.career}</td>
                  <td><span className={`pill ${u.plan === 'Premium' ? 'warn' : u.plan === 'Prueba' ? 'ok' : ''}`}>{u.plan}</span></td>
                  <td>{u.streak} d</td>
                  <td>{u.joined}</td>
                  <td><span className={`pill ${isBlocked ? 'err' : 'ok'}`}>{isBlocked ? 'Bloqueado' : 'Activo'}</span></td>
                  <td><button className="btn secondary" style={{ minHeight: 36, padding: '0 14px' }} onClick={() => toggle(u.id)}>{isBlocked ? 'Desbloquear' : 'Bloquear'}</button></td>
                </tr>
              );
            })}
          </tbody>
        </table>
      </div>
      <p className="muted" style={{ fontSize: 12 }}>Las acciones se aplican solo en pantalla (demostración); con el backend quedarán registradas en la auditoría.</p>
    </>
  );
}
