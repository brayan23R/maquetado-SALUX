# Progreso

## Fase 0–1 · Base y maquetado funcional (modo mock) — HECHO
- Tema claro/oscuro desde `DESIGN_TOKENS.json`, widgets base, router con guards, barra inferior flotante de 5 pestañas.
- Las 57 rutas de `SCREENS.md` existen (ver `lib/app/router.dart`), con navegación, hojas, avisos, estados vacíos y modo oscuro.
- Motor de simulacros (práctica / con tiempo / repaso de errores), corrección, resultado con confeti, revisión con explicación.
- Racha por meta diaria, congelador, favoritos, notas, descargas simuladas, historial, plan de estudio, ranking de ejemplo.
- Prueba gratis de 3 días, paywall, planes, checkout simulado (Yape/Plin/tarjeta) que activa Premium.
- Pruebas: `flutter test` (12 pruebas de dominio y seed). `flutter analyze` sin issues.
- Cómo probar: `.\scripts\04_run_app.ps1`.

## Fase 5 · Panel admin — HECHO (con datos de demostración)
- `apps/admin`: login con contraseña + MFA, dashboard con gráficos, usuarios, contenido (+ importación CSV con validación), pagos (+ exportar CSV), notificaciones, auditoría y configuración.
- Cómo probar: `.\scripts\06_run_admin.ps1` y abrir http://localhost:3000. Credenciales en `apps/admin/.env.local`.

## Pendiente
- Fase 2–4: backend Supabase (migraciones, RLS, repos `Supabase`, Auth real, MFA real, pagos con webhook). Requiere Docker y Supabase CLI (no instalados).
- Localización `l10n`, sincronización offline (Drift), notificaciones locales reales, pruebas de widgets/integración.
- Validación profesional del contenido de preguntas y textos legales.
