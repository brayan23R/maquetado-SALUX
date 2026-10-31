# SALUX — Especificación técnica completa

Ruta del proyecto: `C:\ProyectosDev\SALUXPROTOTIPO`

## 1. Producto

App móvil de preparación para exámenes de postulación en salud (Perú). El usuario elige su carrera y examen objetivo; recibe teoría, preguntas por área y simulacros con respuestas correctas, progreso, racha diaria y documentos. Modelo de negocio: **prueba gratis de 3 días** desde el registro; luego suscripción (mensual, trimestral, anual) pagada con **Yape, Plin o tarjeta Visa/Mastercard** mediante pasarela automática; al confirmarse el pago, todo se desbloquea solo. Un **panel admin web** gestiona usuarios, contenido, pagos y métricas.

Marca: nombre SALUX, lema "Tu futuro en salud comienza aquí", mascota robot (6 estados), violeta como color principal, modo claro y oscuro.

## 2. Alcance

| Modo | Qué incluye |
|---|---|
| `APP_MODE=mock` | La app completa con datos locales de `seed/`, sin internet. Es el modo de las pruebas rápidas y de las demostraciones. |
| `APP_MODE=supabase` | La app conectada al backend local (Docker): auth, MFA, preguntas, intentos, racha, pagos simulados, Realtime. |
| Panel admin | Next.js conectado al mismo backend. |

Fuera de alcance por ahora: publicación en tiendas, iOS compilado (el código ya es multiplataforma), pasarela de pago real (dejar adaptador listo).

## 3. Stack

| Capa | Tecnología |
|---|---|
| App | Flutter (última estable) + Dart 3, Riverpod (generator), go_router, freezed + json_serializable, supabase_flutter, drift (SQLite), flutter_secure_storage, local_auth, google_sign_in, sign_in_with_apple, qr_flutter, flutter_svg, share_plus, connectivity_plus, flutter_local_notifications, intl, google_fonts (o fuente en assets), logger |
| Calidad | very_good_analysis, flutter_test, mocktail, integration_test, build_runner |
| Backend | Supabase local: Postgres, Auth (TOTP), RLS, Realtime, Storage, Edge Functions (Deno/TypeScript) |
| Admin | Next.js (App Router) + TypeScript + Tailwind + shadcn/ui + TanStack Query + Recharts + `@supabase/ssr` |
| Infra local | Docker Desktop, Supabase CLI, PowerShell scripts, Android emulator `SALUX_Pixel8` |
| CI/CD | GitHub Actions: analyze, test, build APK (artefacto descargable) |

Usa siempre las últimas versiones estables y fíjalas en `pubspec.lock` / `package-lock.json`.

## 4. Estructura del repositorio y dónde va cada archivo

```
C:\ProyectosDev\SALUXPROTOTIPO\
├─ AGENTS.md                         (instrucciones permanentes de Codex)
├─ README.md                         (cómo ejecutar; lo regeneras al final)
├─ .gitignore  .env.example
├─ docs\                             (SPEC, SCREENS, DESIGN_TOKENS, DECISIONS, PROGRESS)
├─ prototype\                        (referencia visual aprobada; NO se modifica)
├─ assets\                           (fuente original de assets; NO se modifica)
├─ seed\questions.seed.json          (banco de ejemplo)
├─ scripts\                          (00_bootstrap … 06_run_admin .ps1)
├─ .github\workflows\ci.yml
├─ supabase\
│  ├─ config.toml
│  ├─ migrations\0001_init.sql  0002_*.sql …
│  ├─ seed.sql                       (generado desde seed\questions.seed.json)
│  └─ functions\
│     ├─ create_order\index.ts
│     ├─ payment_webhook\index.ts
│     ├─ backup_codes\index.ts       (generar/consumir códigos de respaldo)
│     └─ send_reminders\index.ts     (recordatorios de racha)
├─ apps\
│  ├─ mobile\                        (Flutter)
│  │  ├─ pubspec.yaml  analysis_options.yaml  l10n.yaml
│  │  ├─ assets\
│  │  │  ├─ images\   ← copia de assets\images\*.png
│  │  │  ├─ mascot\   ← copia de assets\mascot\*.svg
│  │  │  ├─ icons\    ← copia de assets\icons\*.svg
│  │  │  └─ seed\questions.seed.json   ← copia de seed\
│  │  ├─ lib\
│  │  │  ├─ main.dart  main_dev.dart  main_prod.dart
│  │  │  ├─ app\       (app.dart, router.dart, bootstrap.dart, env.dart)
│  │  │  ├─ core\
│  │  │  │  ├─ theme\       (tokens.dart, app_theme.dart, theme_controller.dart)
│  │  │  │  ├─ l10n\        (app_es.arb, app_en.arb)
│  │  │  │  ├─ network\     (supabase_client.dart, connectivity.dart)
│  │  │  │  ├─ storage\     (drift_db.dart, secure_store.dart, prefs.dart)
│  │  │  │  ├─ errors\      (failure.dart, result.dart)
│  │  │  │  ├─ utils\       (formatters, time_zone, logger)
│  │  │  │  └─ widgets\     (salux_button, salux_card, icon_tile, mascot, salux_icon,
│  │  │  │                   progress_ring, chip_selector, bottom_sheet, toast, skeleton)
│  │  │  └─ features\
│  │  │     ├─ auth\  onboarding\  home\  modules\  quiz\  progress\  streak\
│  │  │     ├─ profile\  docs\  ranking\  study_plan\  subscription\
│  │  │     ├─ settings\  notifications\  system\   (offline, error, help, legal, about)
│  │  │     └─ (cada una: presentation\  domain\  data\)
│  │  ├─ test\  integration_test\
│  │  └─ android\ ios\                (generados por flutter create)
│  └─ admin\                         (Next.js)
│     ├─ src\app\(auth)\login        ├─ src\app\(admin)\dashboard  users  content
│     │  payments  notifications  audit  settings
│     ├─ src\components\  src\lib\supabase\  src\lib\queries\
│     └─ package.json  .env.example
└─ build\                            (APK generados; ignorado por Git)
```

**Assets (copiar tal cual, no redibujar):**
- `assets/images/salux_mascota_sticker.png`: personaje oficial del dueño (PNG transparente). Se usa en: splash, bienvenida, iniciar sesión, banner de Inicio, acerca de.
- `assets/images/salux_enam_header.png`: cabecera del detalle de examen.
- `assets/images/salux_avatar.png`: foto de perfil por defecto (circular).
- `assets/mascot/mascota_{happy,cheer,sad,sleep,love,think}.svg`: mascota de apoyo por estado. Reglas: `sad` en errores, sin conexión, pago rechazado, resultado bajo; `cheer` en resultado alto, pago exitoso, prueba iniciada; `sleep` en vacíos y prueba terminada; `love` en planes e invitar; `think` en tips; `happy` por defecto.
- `assets/icons/*.svg`: 69 iconos de trazo (se pintan con `ColorFilter`). Crea un widget `SaluxIcon(name, size, color, duotone)` que los cargue por nombre (duotone = relleno del mismo color con 18 % de opacidad).

## 5. Arquitectura de la app

- **Capas por feature**: `presentation` (pantallas, widgets, controladores Riverpod) → `domain` (entidades, casos de uso, interfaces de repositorio; Dart puro) → `data` (DTOs, repos `Mock`/`Supabase`, fuentes remota y local). Las dependencias solo apuntan hacia `domain`.
- **Inyección**: providers de Riverpod; `repositoryProviders` elige `Mock` o `Supabase` según `Env.appMode`.
- **Navegación**: `go_router` con `ShellRoute` (5 pestañas), guards de sesión (no autenticado → `/welcome`), guard de acceso (sin prueba ni suscripción → `/paywall`), guard de MFA (AAL2 pendiente → `/mfa`). Deep links preparados.
- **Estado**: `AsyncNotifier` por feature; el estado de sesión, tema y acceso son globales.
- **Offline-first**: Drift guarda simulacros descargados, intentos pendientes (cola) y caché de catálogo. `SyncService` envía la cola al volver la conexión (con reintentos exponenciales). Conflictos: gana el servidor; respuestas ya enviadas no se reenvían (id de intento idempotente).
- **Errores**: `Failure` tipados → UI con estados `error`, `offline`, vacío (mascota `sad`/`sleep`) y reintento.
- **Tema**: `ThemeMode.system` por defecto; selector Sistema/Claro/Oscuro guardado en `shared_preferences`. Tokens en `docs/DESIGN_TOKENS.json` → `core/theme/tokens.dart`.
- **Flavors**: `dev` (mock o supabase local) y `prod`. Variables por `--dart-define` (`APP_MODE`, `SUPABASE_URL`, `SUPABASE_ANON_KEY`).
- **Android emulador**: el backend local se alcanza en `http://10.0.2.2:54321`.

## 6. Diseño (resumen; detalle en DESIGN_TOKENS.json y prototype/)

Violeta principal `#5B45D6`, degradado primario `#7360F2 → #4B35C9`; tarjetas con radio 22, botones píldora de 56 dp con sombra violeta; mosaicos de icono con degradado por tono (violeta, azul, menta, rosa, naranja); barra inferior flotante redondeada con píldora activa; hojas inferiores con asa; animación de entrada 320 ms (fade + 10 px); confeti en resultados ≥ 70 %. Tipografía Plus Jakarta Sans (400–800). Modo oscuro con fondo `#0C0B18` y superficies `#171530`. Respeta "reducir movimiento".

## 7. Lógica de dominio

### 7.1 Prueba gratis y acceso
- `profiles.trial_ends_at = created_at + interval '3 days'` (trigger al crear el perfil).
- `has_access(uid)` = existe suscripción `status='active'` con `ends_at > now()` **o** `now() < trial_ends_at`.
- La app consulta `my_access()` (RPC) y muestra: banner con días restantes, o paywall si no hay acceso. Preguntas, simulacros y documentos solo se sirven por RPC que valida `has_access`.
- Plan gratis tras la prueba: 5 preguntas por día (`free_daily_limit` configurable en `app_settings`).

### 7.2 Simulacros y corrección
- Modos: **práctica** (feedback inmediato), **simulacro** (cronómetro, sin feedback hasta el final; 15 min o sin límite), **repaso de errores** (preguntas falladas, repetición espaciada tipo Leitner).
- `get_questions(exam_key, n, mode, topic?)`: devuelve preguntas y opciones **sin** la respuesta correcta; crea un `attempt` abierto.
- `check_answer(attempt_id, question_id, option_id)`: solo en práctica; devuelve `{is_correct, correct_option_id, explanation}` y registra la respuesta.
- `submit_attempt(attempt_id, answers[])`: en simulacro; corrige en servidor, cierra el intento, calcula puntaje y desglose por tema, actualiza actividad diaria.
- Navegación entre preguntas, marcar para revisar, favoritos, notas, reportar pregunta (`reports`).

### 7.3 Racha
- `daily_activity(user_id, day, answered, goal_met)`; `day` se calcula con `profiles.timezone` (por defecto `America/Lima`).
- Un día cuenta si `answered >= profiles.daily_goal` (10, 20 o 30).
- `streaks(user_id, current, best, freezes_available, last_goal_day)`. Se actualiza en `register_answers()` y con una tarea diaria (pg_cron o Edge Function) que aplica el congelador (1 por semana, más en Premium) o reinicia.
- Hitos: 3, 7, 30, 100 días → insignias (`achievements`). Tope de respuestas contables por hora para evitar trampas.
- Recordatorio diario (hora configurable) y "racha en riesgo" por notificación local y push.

### 7.4 Autenticación y MFA
- Correo + contraseña (con verificación), Google y Apple (OAuth; si faltan claves, flujo simulado con usuario demo en modo mock).
- MFA TOTP (Supabase): `enroll` → QR (`qr_flutter`) + clave manual → `challengeAndVerify`. Pantallas: `/mfa`, `/mfa-setup`, `/backup-codes`.
- Códigos de respaldo: 8 códigos de un solo uso, guardados con hash (`backup_codes`); Edge Function `backup_codes` los genera y consume. Desbloqueo biométrico local con `local_auth` (no reemplaza MFA).
- Sesión: tokens en almacenamiento seguro; lista de dispositivos y "cerrar en todos".
- Panel admin: MFA obligatorio (AAL2) y rol `admin|editor|support|finance`.

### 7.5 Pagos y suscripciones
1. App → `create_order(plan_key, method)` (Edge Function, autenticada).
2. La función crea `payments(status='pending')` y llama a `PaymentGateway`: devuelve `{qr_payload|checkout_url|card_token_form}`.
3. Usuario paga. Pasarela → `payment_webhook` (verifica firma, idempotente por `provider_event_id`).
4. Webhook marca `payments.status='paid'`, crea/extiende `subscriptions` y escribe `audit_log`.
5. La app escucha Realtime en `subscriptions` y desbloquea sin intervención; muestra `/pay-success`.
- Interfaz `PaymentGateway` con implementaciones `SimulatedGateway` (por defecto: botón "Simular pago recibido" y "rechazado") y adaptador real (Culqi/Niubiz/Izipay) con variables de entorno. Confirmar con la pasarela contratada que soporta Yape y Plin.
- Planes de ejemplo: mensual S/ 29, trimestral S/ 69, anual S/ 199 (en `plans`, editables desde el admin).
- Aviso de tiendas: Apple y Google suelen exigir compras propias para suscripciones digitales; documentar la decisión (cobro dentro de app vs web de checkout) en `docs/DECISIONS.md`.

### 7.6 Notificaciones
Locales (`flutter_local_notifications`): recordatorio y racha en riesgo. Push (FCM) preparado detrás de interfaz; envío desde admin.

## 8. Modelo de datos (resumen; SQL en supabase/migrations/0001_init.sql)

`profiles` (id, name, role, timezone, daily_goal, trial_ends_at, level, xp, avatar_url) · `exams` · `topics` · `questions` · `question_options` · `question_answers` (protegida) · `attempts` · `attempt_answers` · `daily_activity` · `streaks` · `achievements` / `user_achievements` · `favorites` · `notes` · `documents` / `user_documents` · `plans` · `subscriptions` · `payments` · `backup_codes` · `devices` · `notifications` · `reports` · `audit_log` · `app_settings`.

RLS: cada usuario ve solo sus filas (`auth.uid()`); catálogo (`exams`, `topics`) legible por autenticados; `questions` solo vía RPC con `has_access`; `question_answers` sin acceso directo; el panel usa funciones `is_staff()` y vistas de métricas con rol.

Vistas/funciones del admin: `admin_kpis()`, `admin_active_users(period)`, `admin_signups_by_day()`, `admin_conversion()`, `admin_revenue_by_day()`, `admin_retention()`, `admin_top_failed_questions()`.

## 9. Panel admin (apps/admin)

- Login con MFA (AAL2) y rol; rutas protegidas por middleware.
- **Dashboard**: usuarios totales y activos (día/semana/mes), registros, usuarios en prueba, conversión a Premium, ingresos, retención, racha promedio, simulacros realizados, preguntas más falladas. Gráficos con Recharts (línea para series de tiempo, barras para comparaciones).
- **Usuarios**: búsqueda, filtros, ficha (plan, dispositivos, actividad), bloquear, extender prueba, cerrar sesiones.
- **Contenido**: CRUD de exámenes, temas, preguntas y documentos; **importación CSV/Excel** con vista previa y validación (columnas: examen, tema, enunciado, opcion_a…d, correcta, explicacion); estados borrador/publicado; reportes de usuarios.
- **Pagos**: órdenes, estados, comprobantes por aprobar, reembolsos, exportar CSV.
- **Notificaciones**: segmentar y programar.
- **Auditoría**: quién cambió qué y cuándo. **Configuración**: planes, precios, límites, feature flags.

## 10. Infraestructura local y DevOps

- `scripts\00_bootstrap.ps1`: verifica herramientas → crea emulador → `supabase start` + migraciones + seed → instala dependencias → compila e instala la app en el emulador → abre el panel admin (opcional).
- Puertos: Supabase API 54321, DB 54322, Studio 54323, Inbucket (correos de prueba) 54324, Admin 3000.
- `.env.example` (raíz y apps): `SUPABASE_URL`, `SUPABASE_ANON_KEY`, `SUPABASE_SERVICE_ROLE_KEY` (solo servidor), `APP_MODE`, `PAYMENT_PROVIDER`, `PAYMENT_API_KEY`, `PAYMENT_WEBHOOK_SECRET`, `GOOGLE_CLIENT_ID`, `APPLE_SERVICE_ID`.
- APK: `scripts\05_build_apk.ps1` genera debug (`build\SALUX-debug.apk`) y release firmado si existe `android\key.properties`. Guía de firma en el README (llave con `keytool`, nunca en Git).
- CI (`.github/workflows/ci.yml`): checkout → Flutter → `analyze` → `test` → `build apk` → subir artefacto.

## 11. Seguridad

RLS en todas las tablas; validación de entradas en funciones; rate limiting en Edge Functions; tokens en `flutter_secure_storage`; ofuscación en release (`--obfuscate --split-debug-info`); sin claves en el repo; logs sin datos personales; borrado de cuenta y exportación de datos (Ley 29733; validar con asesor legal). Textos legales del prototipo son de ejemplo.

## 12. Pruebas y calidad

Unitarias: puntaje, desglose por tema, racha (zonas horarias, congelador, offline), acceso por prueba, validación de contraseña, parseo del seed. Widgets: bienvenida, login, pregunta, resultado, planes, ajustes. Integración: login mock → onboarding → inicio → simulacro → resultado → revisión → racha. Backend: pruebas SQL de RLS y funciones (`supabase test db`). Meta de cobertura razonable en dominio (≥ 80 %).

## 13. Criterios de aceptación

Los de `AGENTS.md` §8. Además: arranque en frío < 3 s en el emulador, 60 fps en listas, sin textos cortados con texto al 200 %, ambos temas revisados pantalla por pantalla contra `prototype/Main.dc.html`.
