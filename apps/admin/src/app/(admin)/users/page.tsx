import UsersTable from '@/components/UsersTable';
import { repo } from '@/lib/data';

export default function UsersPage() {
  return (
    <>
      <h1>Usuarios</h1>
      <p className="muted">Busca, filtra y gestiona cuentas.</p>
      <UsersTable users={repo.users()} />
    </>
  );
}
