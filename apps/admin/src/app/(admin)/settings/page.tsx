export default function SettingsPage() {
  const plans = [
    ['Mensual', 'S/ 29', '1 mes'],
    ['Trimestral', 'S/ 69', '3 meses'],
    ['Anual', 'S/ 199', '12 meses'],
  ];
  return (
    <>
      <h1>Configuración</h1>
      <p className="muted">Planes, límites y feature flags (solo lectura en la demo).</p>
      <section className="grid two">
        <div className="card">
          <h2>Planes</h2>
          <table>
            <thead><tr><th>Plan</th><th>Precio</th><th>Duración</th></tr></thead>
            <tbody>{plans.map((p) => <tr key={p[0]}><td>{p[0]}</td><td>{p[1]}</td><td>{p[2]}</td></tr>)}</tbody>
          </table>
        </div>
        <div className="card">
          <h2>Límites y reglas</h2>
          <table>
            <tbody>
              <tr><td>Prueba gratis</td><td>3 días</td></tr>
              <tr><td>Preguntas diarias (plan gratis)</td><td>5</td></tr>
              <tr><td>Metas diarias permitidas</td><td>10 / 20 / 30</td></tr>
              <tr><td>MFA para el panel</td><td><span className="pill ok">Obligatorio</span></td></tr>
            </tbody>
          </table>
        </div>
      </section>
    </>
  );
}
