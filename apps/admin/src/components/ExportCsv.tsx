'use client';

/** Exporta filas a CSV neutralizando fórmulas (=,+,-,@) para evitar inyección en Excel. */
function cell(v: string | number): string {
  let s = String(v);
  if (/^[=+\-@\t\r]/.test(s)) s = `'${s}`;
  return `"${s.replace(/"/g, '""')}"`;
}

export default function ExportCsv({ rows, filename }: { rows: (string | number)[][]; filename: string }) {
  function download() {
    const csv = rows.map((r) => r.map(cell).join(',')).join('\n');
    const url = URL.createObjectURL(new Blob(['﻿' + csv], { type: 'text/csv;charset=utf-8' }));
    const a = document.createElement('a');
    a.href = url;
    a.download = filename;
    a.click();
    URL.revokeObjectURL(url);
  }
  return <button className="btn secondary" onClick={download}>Exportar CSV</button>;
}
