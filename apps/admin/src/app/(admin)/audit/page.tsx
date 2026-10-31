import { repo } from '@/lib/data';

export default function AuditPage() {
  return (
    <>
      <h1>Auditoría</h1>
      <p className="muted">Quién cambió qué y cuándo.</p>
      <div className="card tablewrap">
        <table>
          <thead><tr><th>Quién</th><th>Acción</th><th>Objetivo</th><th>Cuándo</th></tr></thead>
          <tbody>
            {repo.audit().map((a) => (
              <tr key={a.id}><td>{a.who}</td><td>{a.action}</td><td><span className="pill">{a.target}</span></td><td>{a.at}</td></tr>
            ))}
          </tbody>
        </table>
      </div>
    </>
  );
}
