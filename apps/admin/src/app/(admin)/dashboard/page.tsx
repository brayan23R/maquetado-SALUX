import { RevenueChart, SignupsChart } from '@/components/Charts';
import { money, repo } from '@/lib/data';

export default function DashboardPage() {
  const k = repo.kpis();
  const series = repo.series(30);
  const failed = repo.topFailed();
  const cards: [string, string][] = [
    ['Usuarios totales', String(k.totalUsers)],
    ['Activos hoy', String(k.activeToday)],
    ['Activos 7 días', String(k.activeWeek)],
    ['En prueba gratis', String(k.inTrial)],
    ['Premium', String(k.premium)],
    ['Conversión', `${k.conversion} %`],
    ['Ingresos del mes', money(k.revenueMonth)],
    ['Racha promedio', `${k.avgStreak} días`],
    ['Simulacros realizados', String(k.simulations)],
  ];
  return (
    <>
      <h1>Dashboard</h1>
      <p className="muted">Resumen de la plataforma.</p>
      <p className="note">Datos de demostración generados localmente. Se conectarán a las vistas admin_* de la base cuando exista el backend.</p>
      <section className="grid kpis" aria-label="Indicadores">
        {cards.map(([l, v]) => (
          <div className="card kpi" key={l}>
            <div className="v">{v}</div>
            <div className="l">{l}</div>
          </div>
        ))}
      </section>
      <section className="grid two">
        <div className="card">
          <h2>Registros y activos (30 días)</h2>
          <SignupsChart data={series} />
        </div>
        <div className="card">
          <h2>Ingresos por día</h2>
          <RevenueChart data={series} />
        </div>
      </section>
      <section className="card" style={{ marginTop: 16 }}>
        <h2>Preguntas más falladas</h2>
        <div className="tablewrap">
          <table>
            <thead>
              <tr><th>Pregunta</th><th>Examen</th><th>% de error</th></tr>
            </thead>
            <tbody>
              {failed.map((f) => (
                <tr key={f.text}>
                  <td>{f.text}</td>
                  <td><span className="pill">{f.exam}</span></td>
                  <td><span className="pill err">{f.failRate} %</span></td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </section>
    </>
  );
}
