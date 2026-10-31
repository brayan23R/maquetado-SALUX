import CsvImport from '@/components/CsvImport';
import { repo } from '@/lib/data';

export default function ContentPage() {
  const questions = repo.questions();
  return (
    <>
      <h1>Contenido</h1>
      <p className="muted">Banco de preguntas ({questions.length}) leído de seed/questions.seed.json.</p>
      <div className="card tablewrap">
        <table>
          <thead><tr><th>ID</th><th>Examen</th><th>Tema</th><th>Enunciado</th><th>Correcta</th><th>Estado</th></tr></thead>
          <tbody>
            {questions.map((q) => (
              <tr key={q.id}>
                <td>{q.id}</td>
                <td><span className="pill">{q.exam}</span></td>
                <td>{q.topic}</td>
                <td style={{ minWidth: 280 }}>{q.text}</td>
                <td>{q.correct}</td>
                <td><span className={`pill ${q.status === 'Publicado' ? 'ok' : 'warn'}`}>{q.status}</span></td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
      <CsvImport />
    </>
  );
}
