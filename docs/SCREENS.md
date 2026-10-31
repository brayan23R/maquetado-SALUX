# SALUX — Catálogo de pantallas (57) y comportamiento

Referencia visual exacta: `prototype/Main.dc.html` (ábrelo en el navegador del lienzo; el panel derecho salta a cualquier pantalla). Conserva textos, orden, jerarquía y colores. Convenciones: **←** = volver (pila de navegación); **tab** = pestaña inferior (reinicia la pila); **hoja** = bottom sheet; **aviso** = toast de 2,2 s.

Pestañas inferiores (5): Inicio `/home`, Módulos `/modules`, Simulacros `/simulations`, Progreso `/progress`, Perfil `/profile`. Visibles en: home, modules, search, exam, topic, simulations, progress, streak, achievements, profile.

Estados globales: `access` = suscripción activa **o** prueba vigente. Si `!access`, abrir examen/tema/simulacro lleva a `/paywall`; las tarjetas muestran candado.

## A. Arranque y cuenta

| # | Ruta | Contenido | Acciones |
|---|---|---|---|
| 1 | `/splash` | Logo SALUX, mascota sticker PNG flotando, lema, barra | Toque o 1,8 s → `/onboarding` |
| 2 | `/onboarding` | 3 pasos (Elige tu examen / Practica con simulacros / No pierdas tu racha), puntos, mascota por paso | Siguiente → paso siguiente; Empezar (último) y Saltar → `/welcome` |
| 3 | `/welcome` | Logo, lema, **mascota sticker PNG**, píldora "3 días gratis", botones Iniciar sesión y Regístrate, "o continúa con" Google / Apple / Correo, aviso legal | Iniciar sesión → `/login`; Regístrate → `/register`; Google/Apple → aviso + `/pick-career`; Correo → `/login`; enlace legal → `/legal` |
| 4 | `/login` | **Mascota sticker PNG**, correo, contraseña con ojo, "¿Olvidaste?", botón, Google/Apple, enlace a registro | ¿Olvidaste? → `/forgot-password`; Iniciar sesión → `/mfa` si MFA activo, si no `/home` (reinicia pila); Regístrate → `/register` |
| 5 | `/register` | Nombre, correo, contraseña con medidor (Débil/Media/Fuerte), switch de términos, Crear cuenta (deshabilitado sin aceptar), Google/Apple | Crear cuenta → `/verify-email` |
| 6 | `/verify-email` | Icono correo, campo de 6 dígitos, Verificar, Reenviar | Verificar → `/pick-career`; Reenviar → aviso |
| 7 | `/forgot-password` | Campo correo + Enviar enlace; luego estado "¡Enlace enviado!" con mascota `cheer` | Enviar → cambia a estado enviado; Volver → `/login` |
| 8 | `/mfa` | Escudo, campo 6 dígitos, switch "confiar 30 días", enlace código de respaldo | Verificar → aviso + `/home`; Usar código de respaldo → aviso |
| 9 | `/mfa-setup` | Paso 1 instalar app, paso 2 QR + clave manual, paso 3 código | Activar → `/backup-codes` |
| 10 | `/backup-codes` | 8 códigos, Copiar, Guardar, Ya los guardé | Ya los guardé o ✕ → aviso "MFA activada" + `/security` |
| 11 | `/pick-career` | "Paso 1 de 2", rejilla 2×4 (Medicina, Enfermería, Obstetricia, Odontología, Psicología, Nutrición, Farmacia, Tecnología Médica); selección con borde violeta | Continuar → `/pick-goal` |
| 12 | `/pick-goal` | "Paso 2 de 2", lista de examen objetivo (ENAM, Essalud, Residencia Médica, ENCAPS), fecha, meta diaria (10/20/30), hora de recordatorio | Continuar → `/trial-start` |
| 13 | `/trial-start` | Mascota `cheer`, "¡Tienes 3 días gratis!", 3 beneficios, nota de pago | Comenzar a estudiar → `/home` (reinicia pila) |

## B. Inicio y módulos

| # | Ruta | Contenido | Acciones |
|---|---|---|---|
| 14 | `/home` | Foto de perfil, saludo por hora, píldora de racha, campana con punto, buscador, banner de prueba (días restantes) o de prueba terminada, **hero** "Aprende, practica y avanza" con mascota PNG, tarjeta de meta diaria (anillo + semana L–D con llamas), accesos rápidos (Simulacro, Repaso, Favoritos, Documentos), "Continúa donde lo dejaste" (ENAM · Medicina Interna 65 %), cuenta regresiva del examen, cursos principales 2×2, pregunta del día, tip con mascota `think` | Foto → `/profile`; racha → `/streak`; campana → `/notifications`; buscador → `/search`; banner → `/plans` o `/paywall`; Explorar → `/modules`; Seguir practicando → quiz práctica 10; accesos: Simulacro → `/quiz-setup` (modo simulacro), Repaso → quiz de errores, Favoritos → `/favorites`, Documentos → `/docs`; Continúa → `/exam/ENAM`; cuenta regresiva ›→ `/study-plan`; curso → `/exam/:id`; pregunta del día → quiz de 1 pregunta |
| 15 | `/search` | Campo, búsquedas recientes (chips), resultados filtrados en vivo, vacío con mascota `sad` | ← ; chip rellena el campo; resultado → `/exam/:id` |
| 16 | `/modules` | Título, campana, buscador y botón filtros, chips por área, tarjeta destacada ENAM 2026, lista de 10 módulos (ENAM, Essalud, Residencia Médica, ENCAPS, Medicina General, Enfermería, Obstetricia, Odontología, Psicología, Nutrición) con mosaico degradado, subtítulo, píldora "10 preguntas de ejemplo", candado si `!access` | Buscador → `/search`; filtros → hoja Filtros; chip filtra; módulo/destacado → `/exam/:id` |
| 17 | `/exam/:id` | Cabecera con **PNG ENAM**, título, descripción, métricas (65 %, 43 días, 10 preguntas), barra, pestañas Contenido / Simulacros / Casos / Recursos; Contenido: 8 temas (Ciencias Básicas 120, Medicina Interna 150, Cirugía General 90, Ginecología y Obstetricia 80, Pediatría 90, Salud Pública 70, Emergencias 60, Imágenes y laboratorio 50); botón fijo Iniciar simulacro | ↓ → `/downloads`; tema → `/topic/:id`; simulacro/caso → `/quiz-setup`; Recursos: descargar (aviso) y "Ver biblioteca" → `/docs`; Iniciar simulacro → `/quiz-setup` |
| 18 | `/topic/:id` | Avance 48 %, teoría (12 lecturas), casos (8), tarjetas (40) | ♥ → aviso; Descargar → aviso; Practicar → `/quiz-setup` (práctica) |

## C. Simulacros

| # | Ruta | Contenido | Acciones |
|---|---|---|---|
| 19 | `/simulations` | Tarjeta "Crea tu simulacro", modos (Práctica, Simulacro con tiempo, Repaso de errores), recientes con puntaje | Nuevo → `/quiz-setup`; modo → `/quiz-setup` o quiz de errores; reciente → `/result`; reloj → `/history` |
| 20 | `/quiz-setup` | Modo (3 tarjetas), cantidad (5/10), tiempo (sin límite/15 min, solo simulacro), nota "banco de ejemplo", Comenzar | Comenzar → `/quiz` |
| 21 | `/quiz` | ✕ salir, "Pregunta X de N" + barra, cronómetro (o "Libre"), tarjeta con tema y racha, enunciado, 4 opciones A–D; práctica: tras elegir, correcta en verde, error en rojo y tarjeta de explicación con mascota (`cheer`/`sad`); simulacro: solo selecciona. Acciones: favorito, marcar, nota, navegador, reportar. Botón Siguiente/Finalizar (deshabilitado sin respuesta) | ✕ → hoja Salir; cronómetro → hoja Pausa; ♥ alterna favorito; bandera marca; nota crea nota rápida (aviso); cuadrícula → hoja Navegador; ? → hoja Reportar; Finalizar → `/result` |
| 22 | `/result` | Confeti si ≥ 70 %, mascota según nota, título, anillo de puntaje, Correctas / Incorrectas / Tiempo, "Por tema", meta diaria y mensaje de racha | ✕ → `/home`; compartir → aviso; Revisar → `/review`; Repetir → `/quiz-setup` |
| 23 | `/review` | Por pregunta: etiqueta (Correcta/Incorrecta/Sin responder), enunciado, tu respuesta, **respuesta correcta**, explicación, ♥ | ← ; Volver al inicio → `/home` |

Hojas del quiz: **Navegador** (rejilla de números; estados actual/respondida/marcada; Finalizar simulacro) · **Pausa** (mascota `sleep`; Continuar / Salir y guardar; detiene el cronómetro) · **Salir** (Salir y guardar → `/simulations` + aviso / Seguir) · **Reportar** (4 motivos, comentario, Enviar → aviso).

## D. Progreso

| # | Ruta | Contenido | Acciones |
|---|---|---|---|
| 24 | `/progress` | 4 métricas (120 temas, 25 simulacros, 85 %, racha), barras de la semana, precisión por tema, tema por reforzar | 🏆 → `/achievements`; racha → `/streak`; Repasar → quiz de errores |
| 25 | `/streak` | Hero naranja con llama y días, calendario del mes (días cumplidos, hoy con borde), congelador, hitos 3/7/30/100 | 🏆 → `/achievements`; Usar congelador → aviso; Ranking → `/ranking`; Practicar → quiz |
| 26 | `/achievements` | Rejilla de 6 insignias (desbloqueadas / bloqueadas con opacidad) | ← |

## E. Perfil y ajustes

| # | Ruta | Contenido | Acciones |
|---|---|---|---|
| 27 | `/profile` | Avatar PNG + botón cámara, nombre, carrera, píldora de plan, nivel/XP, 3 métricas, menú (Mis notas, Temas favoritos, Biblioteca de documentos, Mis simulacros, Descargas, Historial, Ranking, Plan de estudio, Invitar amigos, Mi suscripción, Configuración, Ayuda), tarjeta "Pequeños avances, grandes logros" | engranaje → `/settings`; cámara → `/edit-profile`; píldora → `/subscription`; cada fila a su pantalla |
| 28 | `/notes` | Lista de notas con etiqueta, eliminar, "+" crea nota; vacío con mascota `sleep` | |
| 29 | `/favorites` | Preguntas favoritas con respuesta correcta; quitar con ♥; vacío | |
| 30 | `/history` | Agrupado Hoy / Ayer / Esta semana, con puntaje | Fila → `/result` |
| 31 | `/downloads` | Aviso offline, lista con botón Descargar/Descargado, switch "solo Wi‑Fi" | |
| 32 | `/settings` | Tarjeta de cuenta, banner Premium, Apariencia (Sistema/Claro/Oscuro, cambia al instante), Estudio (meta diaria, plan de estudio, recordatorios, sonidos, vibración, idioma), Cuenta (seguridad, contraseña, suscripción, exportar datos), Soporte (ayuda, invitar, calificar, términos, acerca de), Cerrar sesión, Eliminar cuenta, versión | Cada fila a su pantalla; Cerrar sesión → hoja confirmación → `/welcome`; Eliminar → hoja con aviso de irreversible → `/welcome` |
| 33 | `/notification-settings` | Recordatorio diario + hora, racha en riesgo, nuevos simulacros, ofertas | |
| 34 | `/security` | Switch MFA (activar → `/mfa-setup`, desactivar → aviso), biometría, códigos de respaldo, cambiar contraseña, dispositivos activos (Cerrar), cerrar en todos | |
| 35 | `/notifications` | Lista con puntos de no leído, "Marcar leídas" | Cada ítem navega a su destino |
| 48 | `/edit-profile` | Foto, nombre, correo, universidad, año de estudios (1°–7°), Guardar | Guardar → aviso + ← |
| 49 | `/change-password` | Actual, nueva (medidor), confirmar, requisitos, Actualizar | Actualizar → aviso + ← |
| 50 | `/language` | Español (✓), English, Português | Elegir → aviso |
| 51 | `/legal` | Pestañas Términos / Privacidad (texto de ejemplo; marcar para revisión legal) | |
| 57 | `/about` | Logo, mascota, versión, enlaces | |

## F. Documentos, comunidad y plan

| # | Ruta | Contenido | Acciones |
|---|---|---|---|
| 52 | `/docs` | Biblioteca con filtros (Todos, PDF, Guías, Resúmenes), tarjetas con tamaño y botón descargar | Tarjeta → `/doc/:id` |
| 53 | `/doc/:id` | Lector con paginación (1–12), guardar, nota, descargar | |
| 54 | `/ranking` | Pestañas Semana/Mes/General, podio top 3, lista con el usuario resaltado (datos de ejemplo) | |
| 55 | `/invite` | Hero con mascota `love`, código, copiar, compartir, amigos unidos | |
| 56 | `/study-plan` | Barra de avance, horas por día (1–4 h), 7 días con tema y tarea, marcar completado | |

## G. Suscripción y pagos

| # | Ruta | Contenido | Acciones |
|---|---|---|---|
| 36 | `/plans` | Hero Premium (mascota `love`), 4 beneficios, 3 planes (Mensual S/ 29, Trimestral S/ 69 −21 %, Anual S/ 199 −43 %; precios de ejemplo) | Continuar → `/checkout` |
| 37 | `/checkout` | Resumen del plan, medios: Yape, Plin, Tarjeta | Pagar → `/pay-qr` (Yape/Plin) o `/pay-card` |
| 38 | `/pay-qr` | Monto, QR, código de pago, vencimiento, 3 pasos | "Simular pago recibido (demo)" → `/pay-processing`; Cambiar medio → ← |
| 39 | `/pay-card` | Número, vence, CVV, nombre, guardar tarjeta, nota de seguridad | Pagar → `/pay-processing`; "Simular rechazado" → `/pay-failed` |
| 40 | `/pay-processing` | Spinner "Confirmando tu pago…" | Tras ~2 s (o evento Realtime) → `/pay-success` y `premium=true` |
| 41 | `/pay-success` | Mascota `cheer`, "¡Pago confirmado!", vigencia, comprobante | Ir al inicio → `/home` (reinicia) |
| 42 | `/pay-failed` | Mascota `sad`, motivo | Reintentar → `/checkout`; otro medio → `/checkout` |
| 43 | `/subscription` | Estado (Premium / Prueba / Gratis), plan, medio, vigencia; Cambiar plan → `/plans`; Cancelar → hoja confirmación | |
| 44 | `/paywall` | Mascota `sleep`, "Tu prueba gratis terminó", racha en espera | Ver planes → `/plans`; Continuar con plan gratis → aviso (5 preguntas/día) + `/home` |

## H. Sistema

| # | Ruta | Contenido | Acciones |
|---|---|---|---|
| 45 | `/help` | FAQ en acordeón (4), contactar soporte | |
| 46 | `/offline` | Mascota `sad`, icono sin wifi | Ir a descargas → `/downloads`; Reintentar → `/home` |
| 47 | `/error` | Mascota `sad`, "Algo salió mal" | Reintentar → `/home`; Hablar con soporte → `/help` |

Hojas generales: **Filtros** (orden, solo gratis, solo descargados) · **Cerrar sesión** · **Eliminar cuenta** · **Cancelar suscripción**. Todas con asa, fondo oscurecido y cierre al tocar fuera.

## Reglas transversales de UX
- Toda acción confirmable muestra un aviso breve; los avisos aparecen sobre la barra inferior.
- Pantallas de carga con skeletons; estados vacíos con mascota; errores con reintento.
- Los botones de icono tienen etiqueta de accesibilidad. Los switches usan semántica de `switch`.
- Al cambiar de pestaña se reinicia la pila de esa pestaña; ← vuelve al origen real.
