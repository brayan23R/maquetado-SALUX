'use client';

import { useState } from 'react';

const SEGMENTS = ['Todos los usuarios', 'En prueba gratis', 'Premium', 'Racha en riesgo'];

export default function NotificationForm() {
  const [segment, setSegment] = useState(SEGMENTS[0]);
  const [title, setTitle] = useState('');
  const [body, setBody] = useState('');
  const [when, setWhen] = useState('');
  const [queue, setQueue] = useState<{ segment: string; title: string; when: string }[]>([]);

  function submit(e: React.FormEvent) {
    e.preventDefault();
    if (!title.trim() || !body.trim()) return;
    setQueue((q) => [{ segment, title: title.trim(), when: when || 'Inmediato' }, ...q]);
    setTitle('');
    setBody('');
    setWhen('');
  }

  return (
    <div className="grid two">
      <form className="card" onSubmit={submit}>
        <h2>Nueva notificación</h2>
        <label className="field">Segmento
          <select className="input" value={segment} onChange={(e) => setSegment(e.target.value)}>
            {SEGMENTS.map((s) => <option key={s}>{s}</option>)}
          </select>
        </label>
        <label className="field">Título
          <input className="input" maxLength={60} value={title} onChange={(e) => setTitle(e.target.value)} required />
        </label>
        <label className="field">Mensaje
          <textarea className="input" style={{ minHeight: 90, padding: 12 }} maxLength={180} value={body} onChange={(e) => setBody(e.target.value)} required />
        </label>
        <label className="field">Programar (opcional)
          <input className="input" type="datetime-local" value={when} onChange={(e) => setWhen(e.target.value)} />
        </label>
        <button className="btn">Programar envío</button>
      </form>
      <div className="card">
        <h2>Cola de envíos</h2>
        {queue.length === 0 ? <p className="muted">Aún no hay notificaciones programadas.</p> : (
          <ul style={{ paddingLeft: 18 }}>
            {queue.map((n, i) => (
              <li key={i}><strong>{n.title}</strong> → {n.segment} <span className="pill">{n.when}</span></li>
            ))}
          </ul>
        )}
        <p className="muted" style={{ fontSize: 12 }}>Envío push (FCM) pendiente de conectar; hoy solo se simula la cola.</p>
      </div>
    </div>
  );
}
