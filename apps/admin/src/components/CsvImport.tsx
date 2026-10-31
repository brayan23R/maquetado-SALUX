'use client';

import { useState } from 'react';

const COLUMNS = ['examen', 'tema', 'enunciado', 'opcion_a', 'opcion_b', 'opcion_c', 'opcion_d', 'correcta', 'explicacion'] as const;
const MAX_BYTES = 1_000_000;
const MAX_ROWS = 2000;

type Row = Record<(typeof COLUMNS)[number], string> & { line: number; errors: string[] };

/** Lector CSV mínimo con soporte de comillas y comas dentro de campos. */
function parseCsv(text: string): string[][] {
  const rows: string[][] = [];
  let row: string[] = [];
  let cur = '';
  let quoted = false;
  for (let i = 0; i < text.length; i++) {
    const ch = text[i];
    if (quoted) {
      if (ch === '"' && text[i + 1] === '"') { cur += '"'; i++; }
      else if (ch === '"') quoted = false;
      else cur += ch;
    } else if (ch === '"') quoted = true;
    else if (ch === ',') { row.push(cur); cur = ''; }
    else if (ch === '\n' || ch === '\r') {
      if (ch === '\r' && text[i + 1] === '\n') i++;
      row.push(cur); cur = '';
      if (row.some((c) => c.trim() !== '')) rows.push(row);
      row = [];
    } else cur += ch;
  }
  row.push(cur);
  if (row.some((c) => c.trim() !== '')) rows.push(row);
  return rows;
}

function validate(rec: Record<string, string>): string[] {
  const errs: string[] = [];
  for (const c of COLUMNS) {
    if (c !== 'explicacion' && !rec[c]?.trim()) errs.push(`Falta ${c}`);
  }
  if (rec.correcta && !/^[abcd]$/i.test(rec.correcta.trim())) errs.push('correcta debe ser A, B, C o D');
  return errs;
}

export default function CsvImport() {
  const [rows, setRows] = useState<Row[]>([]);
  const [fileError, setFileError] = useState('');
  const [done, setDone] = useState(false);

  async function onFile(e: React.ChangeEvent<HTMLInputElement>) {
    setDone(false);
    setFileError('');
    setRows([]);
    const f = e.target.files?.[0];
    if (!f) return;
    if (!f.name.toLowerCase().endsWith('.csv')) return setFileError('Solo se aceptan archivos .csv');
    if (f.size > MAX_BYTES) return setFileError('El archivo supera 1 MB');
    const table = parseCsv(await f.text());
    if (table.length < 2) return setFileError('El archivo no tiene filas de datos');
    const header = table[0].map((h) => h.trim().toLowerCase());
    const missing = COLUMNS.filter((c) => !header.includes(c));
    if (missing.length) return setFileError(`Faltan columnas: ${missing.join(', ')}`);
    if (table.length - 1 > MAX_ROWS) return setFileError(`Máximo ${MAX_ROWS} filas por importación`);
    setRows(
      table.slice(1).map((cells, i) => {
        const rec: Record<string, string> = {};
        header.forEach((h, idx) => { rec[h] = (cells[idx] ?? '').trim(); });
        return { ...(rec as Row), line: i + 2, errors: validate(rec) };
      }),
    );
  }

  const valid = rows.filter((r) => r.errors.length === 0).length;

  return (
    <section className="card" style={{ marginTop: 16 }}>
      <h2>Importar preguntas (CSV)</h2>
      <p className="muted" style={{ marginTop: 0 }}>Columnas: {COLUMNS.join(', ')}. Se valida antes de guardar.</p>
      <input className="input" type="file" accept=".csv,text/csv" onChange={onFile} aria-label="Archivo CSV" />
      {fileError && <p className="err-text" role="alert">{fileError}</p>}
      {rows.length > 0 && (
        <>
          <p><span className="pill ok">{valid} válidas</span> <span className="pill err">{rows.length - valid} con errores</span></p>
          <div className="tablewrap">
            <table>
              <thead><tr><th>Línea</th><th>Examen</th><th>Tema</th><th>Enunciado</th><th>Correcta</th><th>Estado</th></tr></thead>
              <tbody>
                {rows.slice(0, 50).map((r) => (
                  <tr key={r.line}>
                    <td>{r.line}</td><td>{r.examen}</td><td>{r.tema}</td>
                    <td>{r.enunciado.slice(0, 60)}</td><td>{r.correcta}</td>
                    <td>{r.errors.length ? <span className="pill err">{r.errors.join('; ')}</span> : <span className="pill ok">OK</span>}</td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
          <div className="row" style={{ marginTop: 12 }}>
            <button className="btn" disabled={valid === 0 || done} onClick={() => setDone(true)}>Importar {valid} válidas</button>
            {done && <span className="pill ok">Importación simulada (se guardará en la base cuando exista el backend)</span>}
          </div>
        </>
      )}
    </section>
  );
}
