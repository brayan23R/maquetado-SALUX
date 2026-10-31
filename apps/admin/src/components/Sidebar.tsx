'use client';

import Link from 'next/link';
import { usePathname, useRouter } from 'next/navigation';

const ITEMS = [
  { href: '/dashboard', label: 'Dashboard' },
  { href: '/users', label: 'Usuarios' },
  { href: '/content', label: 'Contenido' },
  { href: '/payments', label: 'Pagos' },
  { href: '/notifications', label: 'Notificaciones' },
  { href: '/audit', label: 'Auditoría' },
  { href: '/settings', label: 'Configuración' },
];

export default function Sidebar() {
  const pathname = usePathname();
  const router = useRouter();

  async function logout() {
    await fetch('/api/auth/logout', { method: 'POST' });
    router.replace('/login');
    router.refresh();
  }

  return (
    <aside className="side">
      <div className="brand">
        SALUX
        <small>Panel de administración</small>
      </div>
      <nav aria-label="Principal" style={{ display: 'contents' }}>
        {ITEMS.map((i) => (
          <Link key={i.href} href={i.href} className={`nav${pathname.startsWith(i.href) ? ' active' : ''}`} aria-current={pathname.startsWith(i.href) ? 'page' : undefined}>
            {i.label}
          </Link>
        ))}
      </nav>
      <div className="spacer" />
      <button className="nav" onClick={logout} style={{ background: 'none', border: 0, font: 'inherit', cursor: 'pointer', textAlign: 'left' }}>
        Cerrar sesión
      </button>
    </aside>
  );
}
