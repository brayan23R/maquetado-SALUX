# Decisiones de diseño (una línea por decisión)

- La app Flutter vive en la **raíz** del proyecto (ya existía `flutter create` ahí) en vez de `apps/mobile`, para no duplicar carpetas ni assets. El panel va en `apps/admin`.
- Los assets (`assets/`) y el banco (`seed/questions.seed.json`) se declaran directo en `pubspec.yaml`: no hay copias.
- Estado con `flutter_riverpod` (`Notifier`) sin generadores ni `freezed`/`build_runner`: menos piezas para un MVP; los modelos son clases inmutables escritas a mano.
- Textos en español dentro de las pantallas (sin `l10n`/ARB todavía). Pendiente antes de soportar inglés: extraer a `app_es.arb`/`app_en.arb`.
- Linter: `flutter_lints` por defecto (no `very_good_analysis`). Pendiente endurecer.
- Persistencia mock en `shared_preferences` (un solo JSON `salux.state.v1`). Drift/SQLite queda para la fase de sincronización offline con backend.
- `APP_MODE=mock|supabase` existe en `Env`, pero **solo el modo mock está implementado**. `QuestionRepository` ya es la interfaz donde entrará la versión Supabase.
- La prueba gratis de 3 días se calcula en el cliente en modo mock (`trialEndsAt`). Con backend debe decidirla el servidor (`has_access`). La pantalla Suscripción trae botones de demo para vencer/reiniciar la prueba.
- Plan gratis tras la prueba: 5 preguntas por día, aplicado en `launchQuiz`.
- Pagos: flujo 100 % simulado (Yape/Plin/tarjeta). Los datos de tarjeta no se leen ni guardan.
- MFA y códigos de respaldo de la app son simulados (cualquier código de 6 dígitos). El panel admin sí valida TOTP real (RFC 6238) y/o un código demo local.
- Preguntas de módulos sin banco propio (Odontología, Nutrición…) reutilizan el banco de ejemplo de un examen afín.
- Panel admin: Next.js (App Router) + TypeScript + Recharts con CSS propio (sin Tailwind/shadcn) y datos mock en `src/lib/data.ts` detrás de un objeto `repo`; el banco de preguntas se lee del seed real.
- Next.js 16 renombra `middleware` a `proxy.ts`; la protección de rutas del panel usa ese archivo.
- Seguridad del panel: cookies `httpOnly` + `sameSite=strict`, token firmado HMAC, comparaciones en tiempo constante, límite de intentos, cabeceras de seguridad, importación CSV validada y exportación CSV que neutraliza fórmulas. No hay SQL en el panel; con Supabase se usará `supabase-js`/RPC parametrizados.
- Cobro en tiendas (Apple/Google exigen compras propias para suscripciones digitales): decisión pendiente del dueño.
- Android: se usa el AVD ya existente `Pixel_8_API_37` (Pixel 8, Android 37, x86_64 con Google Play) en vez de crear `SALUX_Pixel8`.
