# SALUX · MVP

App móvil (Flutter) de preparación para exámenes de salud en Perú + panel web de administración (Next.js).
Estado actual: **maquetado funcional en modo mock** (sin backend ni internet). Detalle en `docs/PROGRESS.md`.

## Estructura
```
lib\                 App Flutter (feature-first: presentation / domain / data)
assets\  seed\       Imágenes, mascota, iconos y banco de preguntas de ejemplo
apps\admin\          Panel web (Next.js)
docs\                SPEC, SCREENS, DESIGN_TOKENS, DECISIONS, PROGRESS
scripts\             Utilidades PowerShell
supabase\            Esquema SQL base (aún no conectado)
```

## Requisitos (Windows)
Flutter, Android Studio con un emulador, Node.js 20+. **Modo desarrollador de Windows activado** (Configuración → Privacidad y seguridad → Para desarrolladores), necesario para compilar plugins de Flutter.

## App móvil
```powershell
.\scripts\04_run_app.ps1          # abre el emulador, compila, instala y ejecuta
flutter analyze; flutter test     # calidad
.\scripts\05_build_apk.ps1        # APK en build\SALUX-debug.apk
```
Modo `mock`: todo funciona sin internet. El modo `supabase` está previsto, pero no implementado.

## Panel admin
```powershell
.\scripts\06_run_admin.ps1        # http://localhost:3000
```
Copia `apps\admin\.env.example` a `.env.local` y completa los valores. El acceso exige contraseña + código MFA (TOTP). Los datos del panel son de demostración.

## Seguridad
Sin secretos en Git (`.env.local` ignorado). El panel usa cookies httpOnly, límite de intentos y validación de entradas; no ejecuta SQL (con Supabase se usarán consultas parametrizadas/RPC).
