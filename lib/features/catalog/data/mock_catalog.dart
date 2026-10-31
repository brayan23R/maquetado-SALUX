import '../../../core/theme/tokens.dart';

/// Catálogo de contenido de demostración (modo mock). En modo `supabase`
/// estos datos vendrán de las tablas `exams`, `topics` y `documents`.

class ModuleItem {
  const ModuleItem({
    required this.id,
    required this.name,
    required this.subtitle,
    required this.icon,
    required this.tone,
    required this.area,
    required this.seedKey,
  });

  final String id;
  final String name;
  final String subtitle;
  final String icon;
  final Tone tone;

  /// Área para los chips de filtro.
  final String area;

  /// Clave del examen en el banco de preguntas.
  final String seedKey;
}

const moduleAreas = ['Todos', 'Exámenes', 'Medicina', 'Enfermería', 'Otras áreas'];

const modules = <ModuleItem>[
  ModuleItem(id: 'ENAM', name: 'ENAM', subtitle: 'Examen Nacional de Medicina', icon: 'file', tone: Tone.violet, area: 'Exámenes', seedKey: 'ENAM'),
  ModuleItem(id: 'ESSALUD', name: 'Essalud', subtitle: 'Proceso de ingreso a Essalud', icon: 'users', tone: Tone.blue, area: 'Exámenes', seedKey: 'ESSALUD'),
  ModuleItem(id: 'RESIDENCIA', name: 'Residencia Médica', subtitle: 'Examen de Residentado Médico', icon: 'pulse', tone: Tone.mint, area: 'Exámenes', seedKey: 'RESIDENCIA'),
  ModuleItem(id: 'ENCAPS', name: 'ENCAPS', subtitle: 'Servicio Rural y Urbano', icon: 'note', tone: Tone.pink, area: 'Exámenes', seedKey: 'ENCAPS'),
  ModuleItem(id: 'MEDGEN', name: 'Medicina General', subtitle: 'Práctica clínica integral', icon: 'pulse', tone: Tone.violet, area: 'Medicina', seedKey: 'ENAM'),
  ModuleItem(id: 'ENFERMERIA', name: 'Enfermería', subtitle: 'Cuidado y gestión del paciente', icon: 'cross', tone: Tone.mint, area: 'Enfermería', seedKey: 'ENCAPS'),
  ModuleItem(id: 'OBSTETRICIA', name: 'Obstetricia', subtitle: 'Salud materna y neonatal', icon: 'heart', tone: Tone.pink, area: 'Otras áreas', seedKey: 'ESSALUD'),
  ModuleItem(id: 'ODONTOLOGIA', name: 'Odontología', subtitle: 'Salud bucal y clínica', icon: 'tooth', tone: Tone.blue, area: 'Otras áreas', seedKey: 'ENAM'),
  ModuleItem(id: 'PSICOLOGIA', name: 'Psicología', subtitle: 'Evaluación e intervención', icon: 'brain', tone: Tone.violet, area: 'Otras áreas', seedKey: 'ENCAPS'),
  ModuleItem(id: 'NUTRICION', name: 'Nutrición', subtitle: 'Dietética y salud pública', icon: 'leaf', tone: Tone.mint, area: 'Otras áreas', seedKey: 'ENAM'),
];

ModuleItem moduleById(String id) =>
    modules.firstWhere((m) => m.id == id.toUpperCase(), orElse: () => modules.first);

class TopicItem {
  const TopicItem(this.id, this.name, this.questions);

  final String id;
  final String name;
  final int questions;
}

const topics = <TopicItem>[
  TopicItem('ciencias-basicas', 'Ciencias Básicas', 120),
  TopicItem('medicina-interna', 'Medicina Interna', 150),
  TopicItem('cirugia-general', 'Cirugía General', 90),
  TopicItem('ginecologia', 'Ginecología y Obstetricia', 80),
  TopicItem('pediatria', 'Pediatría', 90),
  TopicItem('salud-publica', 'Salud Pública', 70),
  TopicItem('emergencias', 'Emergencias', 60),
  TopicItem('imagenes', 'Imágenes y laboratorio', 50),
];

TopicItem topicById(String id) =>
    topics.firstWhere((t) => t.id == id, orElse: () => topics.first);

class DocItem {
  const DocItem(this.id, this.title, this.kind, this.size, this.pages);

  final String id;
  final String title;
  final String kind;
  final String size;
  final int pages;
}

const docFilters = ['Todos', 'PDF', 'Guías', 'Resúmenes'];

const docs = <DocItem>[
  DocItem('d1', 'Guía ENAM 2026: temario oficial', 'Guías', '2,4 MB', 12),
  DocItem('d2', 'Resumen de Medicina Interna', 'Resúmenes', '1,1 MB', 12),
  DocItem('d3', 'Manual de Emergencias', 'PDF', '3,8 MB', 12),
  DocItem('d4', 'Guía de Pediatría', 'Guías', '1,9 MB', 12),
  DocItem('d5', 'Resumen de Salud Pública', 'Resúmenes', '0,9 MB', 12),
  DocItem('d6', 'Casos clínicos resueltos', 'PDF', '2,7 MB', 12),
];

class Achievement {
  const Achievement(this.id, this.title, this.detail, this.icon, this.tone);

  final String id;
  final String title;
  final String detail;
  final String icon;
  final Tone tone;
}

const achievements = <Achievement>[
  Achievement('first', 'Primer paso', 'Completa tu primer simulacro', 'star', Tone.violet),
  Achievement('streak3', 'Racha de 3', '3 días seguidos cumpliendo tu meta', 'flame', Tone.orange),
  Achievement('streak7', 'Semana perfecta', '7 días seguidos', 'bolt', Tone.blue),
  Achievement('ace', 'Puntería', 'Obtén 90 % o más en un simulacro', 'target', Tone.mint),
  Achievement('fav', 'Coleccionista', 'Guarda 5 preguntas favoritas', 'bookmark', Tone.pink),
  Achievement('streak30', 'Constancia de acero', '30 días seguidos', 'trophy', Tone.orange),
];

const faqs = <(String, String)>[
  ('¿Cómo funciona la prueba gratis?', 'Al registrarte tienes 3 días con acceso completo. Después puedes elegir un plan o continuar con 5 preguntas diarias.'),
  ('¿Cómo se cuenta mi racha?', 'Suma un día cada vez que cumples tu meta diaria de preguntas. El congelador protege un día perdido.'),
  ('¿Puedo estudiar sin conexión?', 'Sí. Descarga simulacros y documentos desde Descargas y úsalos sin internet.'),
  ('¿Con qué medios puedo pagar?', 'Con Yape, Plin o tarjeta Visa/Mastercard. Al confirmarse el pago, tu cuenta se desbloquea sola.'),
];

class AppNotification {
  const AppNotification(this.id, this.title, this.body, this.when, this.route, this.icon);

  final String id;
  final String title;
  final String body;
  final String when;
  final String route;
  final String icon;
}

const notificationItems = <AppNotification>[
  AppNotification('n1', 'Tu racha te espera', 'Responde tus preguntas de hoy para mantenerla.', 'Hoy', '/streak', 'flame'),
  AppNotification('n2', 'Nuevo simulacro disponible', 'ENAM 2026 · Simulacro 5 ya está listo.', 'Ayer', '/quiz-setup', 'file'),
  AppNotification('n3', 'Nuevos documentos', 'Se añadió la Guía de Pediatría a la biblioteca.', 'Hace 2 días', '/docs', 'book'),
];

class RankEntry {
  const RankEntry(this.name, this.points);

  final String name;
  final int points;
}

/// Datos de ejemplo del ranking (el usuario se inserta aparte).
const rankingSample = <RankEntry>[
  RankEntry('Camila R.', 2840),
  RankEntry('Diego M.', 2615),
  RankEntry('Valeria S.', 2390),
  RankEntry('Andrés P.', 2105),
  RankEntry('Lucía H.', 1890),
  RankEntry('Marco T.', 1650),
];

const careers = <(String, String, Tone)>[
  ('Medicina', 'pulse', Tone.violet),
  ('Enfermería', 'cross', Tone.mint),
  ('Obstetricia', 'heart', Tone.pink),
  ('Odontología', 'tooth', Tone.blue),
  ('Psicología', 'brain', Tone.violet),
  ('Nutrición', 'leaf', Tone.mint),
  ('Farmacia', 'pill', Tone.orange),
  ('Tecnología Médica', 'zoom', Tone.blue),
];

const goalExams = <(String, String)>[
  ('ENAM', 'Examen Nacional de Medicina'),
  ('Essalud', 'Proceso de ingreso a Essalud'),
  ('Residencia Médica', 'Examen de Residentado Médico'),
  ('ENCAPS', 'Servicio Rural y Urbano'),
];

const legalTerms = 'TEXTO DE EJEMPLO — pendiente de revisión legal.\n\n'
    '1. Aceptación. Al usar SALUX aceptas estos términos.\n\n'
    '2. Servicio. SALUX ofrece material de preparación para exámenes de salud. '
    'No sustituye la formación profesional.\n\n'
    '3. Prueba y suscripción. La prueba gratis dura 3 días desde el registro. '
    'Luego puedes suscribirte a un plan de pago.\n\n'
    '4. Uso aceptable. No compartas tu cuenta ni redistribuyas el contenido.';

const legalPrivacy = 'TEXTO DE EJEMPLO — pendiente de revisión legal (Ley 29733).\n\n'
    '1. Datos que recopilamos: nombre, correo, progreso de estudio.\n\n'
    '2. Uso: personalizar tu práctica, calcular tu racha y mejorar el servicio.\n\n'
    '3. Tus derechos: puedes exportar o eliminar tu cuenta desde Configuración.\n\n'
    '4. Seguridad: protegemos tu información con cifrado y control de acceso.';
