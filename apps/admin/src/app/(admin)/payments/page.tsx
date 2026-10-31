import ExportCsv from '@/components/ExportCsv';
import { money, repo } from '@/lib/data';

export default function PaymentsPage() {
  const pays = repo.payments();
  const csv: (string | number)[][] = [
    ['orden', 'usuario', 'plan', 'medio', 'monto', 'estado', 'fecha'],
    ...pays.map((p) => [p.id, p.user, p.plan, p.method, p.amount, p.status, p.date]),
  ];
  return (
    <>
      <div className="row" style={{ justifyContent: 'space-between' }}>
        <div>
          <h1>Pagos</h1>
          <p className="muted" style={{ marginTop: 0 }}>Órdenes y estados (pasarela simulada).</p>
        </div>
        <ExportCsv rows={csv} filename="pagos.csv" />
      </div>
      <div className="card tablewrap">
        <table>
          <thead><tr><th>Orden</th><th>Usuario</th><th>Plan</th><th>Medio</th><th>Monto</th><th>Estado</th><th>Fecha</th></tr></thead>
          <tbody>
            {pays.map((p) => (
              <tr key={p.id}>
                <td>{p.id}</td><td>{p.user}</td><td>{p.plan}</td><td>{p.method}</td>
                <td>{money(p.amount)}</td>
                <td><span className={`pill ${p.status === 'Pagado' ? 'ok' : p.status === 'Pendiente' ? 'warn' : 'err'}`}>{p.status}</span></td>
                <td>{p.date}</td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </>
  );
}
