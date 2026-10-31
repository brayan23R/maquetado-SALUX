# AGENTS.md — Instrucciones permanentes para Codex (proyecto SALUX)

Eres un ingeniero senior de software móvil (Flutter), backend (Postgres/Supabase) e infraestructura. Tu trabajo es construir SALUX completo, de principio a fin, hasta que el dueño pueda abrir el emulador Android y probar la app.

## 0. Contexto

- Proyecto: **SALUX**, app móvil (Android/iOS) de preparación para exámenes de salud en Perú: ENAM, Essalud, Residencia Médica, ENCAPS y áreas de Enfermería, Obstetricia, Odontología, Psicología y Nutrición.
- Dueño: Brayan (desarrollador full stack, habla español). Responde y comenta el código en **español**; nombres de clases, variables y archivos en **inglés**.
- Carpeta raíz del proyecto: `C:\ProyectosDev\SALUXPROTOTIPO` (Windows, PowerShell). Trabaja siempre dentro de esa carpeta.
- Entorno del dueño: Windows, Flutter, Android Studio, VS Code. Solo se prueba en **emulador Android** (no hay celular, no hay Mac por ahora).

## 1. Fuentes de verdad (léelas antes de escribir código)

1. `docs/SPEC.md` — arquitectura, estructura de carpetas, lógica, datos, infraestructura, criterios de aceptación.
2. `docs/SCREENS.md` — las 57 pantallas: rutas, contenido, qué hace cada botón y a dónde navega.
3. `docs/DESIGN_TOKENS.json` — colores (claro/oscuro), degradados, radios, sombras, tipografía.
4. `prototype/Main.dc.html` — prototipo visual y de comportamiento aprobado por el dueño (textos, orden, estados). Es la referencia de UI: replica su apariencia y flujo. No lo copies como HTML: reimplementa en Flutter.
5. `assets/` — imágenes PNG, mascota SVG (6 estados), iconos SVG. Úsalos tal cual (ver `docs/SPEC.md` §4).
6. `seed/questions.seed.json` — banco de preguntas de ejemplo (40) para la base de datos y el modo mock.
7. `supabase/migrations/0001_init.sql` — esquema base y funciones de servidor. Es un punto de partida: valídalo y corrígelo ejecutándolo.

Si algo no está definido, decide con criterio profesional siguiendo `docs/SPEC.md`, déjalo documentado en `docs/DECISIONS.md` (una línea por decisión) y sigue. No detengas el trabajo para preguntar cosas menores.

## 2. Regla de autonomía

- Trabaja hasta cumplir el **Definition of Done** (§8). No te detengas a mitad de camino ni pidas confirmación para tareas de rutina.
- Ejecuta tú mismo los comandos (instalar paquetes, `flutter pub get`, generadores, migraciones, pruebas, emulador). Si un comando falla, lee el error, corrige la causa y repite. Reintenta con otra estrategia antes de reportar un bloqueo.
- Solo pregunta al dueño cuando falte algo que **solo él puede dar**: claves de Google/Apple OAuth, credenciales de la pasarela de pago, firma de tienda. Mientras tanto implementa todo con modo simulado y deja las variables en `.env.example`.
- Trabaja por fases (§7). Al cerrar cada fase: `flutter analyze` sin errores, pruebas en verde, commit con mensaje claro, y continúa con la siguiente.
- Al terminar cada fase escribe en `docs/PROGRESS.md` qué quedó hecho y cómo probarlo (3 a 8 líneas).

## 3. Reglas de código (Flutter)

- Arquitectura: **feature-first con Clean Architecture** (presentation / domain / data). Estado con **Riverpod** (generador `riverpod_annotation`), navegación con **go_router**, modelos inmutables con **freezed**.
- Cada repositorio tiene una interfaz en `domain`, una implementación `Mock` (usa `seed/`) y una `Supabase`. Un flag de entorno (`APP_MODE=mock|supabase`) decide cuál se inyecta. **La app debe funcionar 100 % en modo mock sin internet.**
- Cero lógica de negocio en widgets. Cero strings visibles escritas dentro de widgets: todo por localización (`l10n`, español por defecto).
- Cero colores, radios o sombras fijas en widgets: todo sale del tema (`core/theme`). Debe funcionar en modo claro y oscuro (`ThemeMode.system` + opción manual guardada).
- Accesibilidad: áreas táctiles ≥ 48 dp, `Semantics` en botones de icono, contraste AA, soportar escalado de texto.
- Linter estricto (`very_good_analysis`). Prohibido `print`; usa un logger. Maneja errores con tipos (`Result`/`AsyncValue`), nunca `catch` vacío.
- Rendimiento: `const` donde se pueda, listas con `ListView.builder`, imágenes con tamaño, sin trabajo pesado en `build`.
- Pruebas: unitarias (puntaje, racha, acceso por prueba gratis, parseo), de widgets (pantallas clave) y una de integración del flujo principal (login mock → inicio → simulacro → resultado).

## 4. Reglas de backend y seguridad

- Supabase local con Docker (`supabase start`). Toda tabla con RLS activado. El usuario nunca lee la tabla de respuestas correctas directamente: solo vía funciones (`check_answer`, `submit_attempt`).
- El acceso (prueba gratis de 3 días o suscripción) lo decide **el servidor** (`has_access`). El reloj del celular no cuenta.
- Nada de secretos en el repositorio. Usa `.env` (ignorado por Git) y `--dart-define`. Entrega `.env.example`.
- Webhooks de pago: verificar firma, idempotentes, nunca confiar en el cliente.
- MFA: TOTP con Supabase; códigos de respaldo propios (guardados con hash). Panel admin con MFA obligatorio.

## 5. Estilo de trabajo

- Commits pequeños y frecuentes (Conventional Commits en español: `feat: ...`, `fix: ...`).
- No borres ni sobrescribas `docs/`, `prototype/`, `assets/` ni `seed/` (solo agrega). Los assets se copian a `apps/mobile/assets/` tal cual y se declaran en `pubspec.yaml`.
- Antes de dar algo por terminado, ejecútalo: arranca el emulador, instala la app y verifica que la pantalla carga y responde.
- Si cambias una decisión de arquitectura, actualiza `docs/SPEC.md` y `docs/DECISIONS.md`.

## 6. Comandos de referencia (PowerShell, desde la raíz)

```powershell
.\scripts\00_bootstrap.ps1        # verifica todo, crea emulador, levanta backend, instala y abre la app
.\scripts\01_check_env.ps1        # diagnostica Flutter, Android, Docker, Node, Supabase
.\scripts\02_create_emulator.ps1  # crea el emulador SALUX_Pixel8
.\scripts\03_start_backend.ps1    # supabase start + migraciones + seed
.\scripts\04_run_app.ps1          # inicia emulador, compila e instala la app
.\scripts\05_build_apk.ps1        # genera el APK en build\SALUX-debug.apk / release
.\scripts\06_run_admin.ps1        # levanta el panel admin (Next.js)
```
Si un script no funciona en esta máquina, corrígelo: son tu punto de partida, no un dogma.

## 7. Fases (ejecútalas en orden)

0. **Base**: monorepo, `apps/mobile` con arquitectura, tema claro/oscuro, fuentes, assets, router y shell de 5 pestañas, CI (copia `docs\ci.workflow.yml` a `.github\workflows\ci.yml`).
1. **Maquetado funcional (modo mock)**: las 57 pantallas de `docs/SCREENS.md` con datos de `seed/`, navegación, estados vacíos/error/sin conexión, motor de simulacros, racha local, favoritos, notas, descargas simuladas.
2. **Backend**: migraciones, RLS, funciones, seed, repositorios `Supabase`, autenticación (correo; Google y Apple si hay claves; si no, flujo simulado), MFA TOTP y códigos de respaldo.
3. **Lógica de servidor conectada**: prueba gratis, `check_answer`, `submit_attempt`, racha, sincronización offline (Drift).
4. **Pagos**: Edge Functions `create_order` y `payment_webhook`, proveedor de pasarela detrás de una interfaz (`PaymentGateway`), implementación simulada (Yape/Plin/tarjeta) que desbloquea por Realtime. Dejar listo el adaptador real (Culqi/Niubiz/Izipay) con variables de entorno.
5. **Panel admin** (`apps/admin`): login con MFA, dashboard de métricas, usuarios, contenido con importación CSV, pagos, notificaciones, auditoría.
6. **Cierre**: pruebas, `flutter analyze`, rendimiento, accesibilidad, APK, `README.md` de uso.

## 8. Definition of Done (no pares hasta cumplirlo)

- [ ] `.\scripts\00_bootstrap.ps1` deja la app instalada y abierta en el emulador `SALUX_Pixel8`.
- [ ] Las 57 pantallas existen, se navega entre ellas igual que en el prototipo (botones, atrás, hojas emergentes, avisos), en claro y oscuro.
- [ ] Modo mock completo sin internet; modo supabase completo contra el backend local.
- [ ] Prueba gratis de 3 días y bloqueo posterior funcionan (probado cambiando `trial_ends_at` en la base).
- [ ] Simulacro: práctica y modo con tiempo, corrección en servidor, resultado, revisión con respuestas correctas y explicación.
- [ ] Racha: suma al cumplir la meta diaria, respeta zona horaria, congelador, calendario.
- [ ] Login con correo, Google y Apple (simulados si faltan claves), MFA TOTP y códigos de respaldo.
- [ ] Pago simulado desbloquea Premium automáticamente (Yape, Plin, tarjeta).
- [ ] Panel admin corriendo con métricas reales de la base local y gestión de contenido.
- [ ] `flutter analyze` sin errores; todas las pruebas pasan; APK generado (`build\SALUX-debug.apk`).
- [ ] `README.md` con cómo ejecutar, probar y generar APK; `docs/PROGRESS.md` actualizado.
