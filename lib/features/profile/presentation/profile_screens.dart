import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/tokens.dart';
import '../../../core/utils/format.dart';
import '../../../core/widgets/widgets.dart';
import '../../catalog/data/mock_catalog.dart';
import '../../quiz/data/question_repository.dart';
import '../../session/presentation/app_controller.dart';

// ================================================================== /profile

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final app = ref.watch(appProvider);
    final c = context.colors;
    final plan = app.isPremium ? 'Premium' : (app.isTrial ? 'Prueba gratis' : 'Plan gratis');
    final totalQ = app.history.fold<int>(0, (a, r) => a + r.total);

    Widget metric(String v, String l) => Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(color: c.soft, borderRadius: BorderRadius.circular(16)),
            child: Column(children: [
              Text(v, style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18, color: c.primary)),
              Text(l, style: TextStyle(color: c.muted, fontSize: 11)),
            ]),
          ),
        );

    return FadeIn(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 110),
        children: [
          Row(
            children: [
              const Expanded(
                child: Text('Perfil',
                    style: TextStyle(fontSize: 27, fontWeight: FontWeight.w800, letterSpacing: -.5)),
              ),
              RoundIconButton(icon: 'gear', label: 'ConfiguraciÃ³n', onTap: () => context.push('/settings')),
            ],
          ),
          const SizedBox(height: 8),
          Center(
            child: Stack(
              children: [
                ClipOval(
                  child: Image.asset('assets/images/salux_avatar.png',
                      width: 104, height: 104, fit: BoxFit.cover, cacheWidth: 312),
                ),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: RoundIconButton(icon: 'camera', label: 'Cambiar foto', onTap: () => context.push('/edit-profile')),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Center(child: Text(app.name, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 22))),
          Center(child: Text(app.career, style: TextStyle(color: c.muted))),
          const SizedBox(height: 8),
          Center(
            child: InkWell(
              onTap: () => context.push('/subscription'),
              borderRadius: BorderRadius.circular(20),
              child: Padding(
                padding: const EdgeInsets.all(4),
                child: Pill(plan, tone: app.isPremium ? Tone.orange : Tone.mint, icon: 'crown'),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              metric('Nv. ${app.level}', '${app.xp} XP'),
              const SizedBox(width: 8),
              metric('${app.streak}', 'Racha'),
              const SizedBox(width: 8),
              metric('$totalQ', 'Preguntas'),
            ],
          ),
          const SizedBox(height: 16),
          MenuGroup(children: [
            MenuRow(icon: 'note', title: 'Mis notas', onTap: () => context.push('/notes')),
            MenuRow(icon: 'heart', title: 'Temas favoritos', tone: Tone.pink, onTap: () => context.push('/favorites')),
            MenuRow(icon: 'book', title: 'Biblioteca de documentos', tone: Tone.blue, onTap: () => context.push('/docs')),
            MenuRow(icon: 'target', title: 'Mis simulacros', tone: Tone.orange, onTap: () => context.go('/simulations')),
            MenuRow(icon: 'download', title: 'Descargas', tone: Tone.mint, onTap: () => context.push('/downloads')),
            MenuRow(icon: 'history', title: 'Historial', onTap: () => context.push('/history')),
            MenuRow(icon: 'trophy', title: 'Ranking', tone: Tone.orange, onTap: () => context.push('/ranking')),
            MenuRow(icon: 'calendar', title: 'Plan de estudio', tone: Tone.mint, onTap: () => context.push('/study-plan')),
            MenuRow(icon: 'gift', title: 'Invitar amigos', tone: Tone.pink, onTap: () => context.push('/invite')),
            MenuRow(icon: 'crown', title: 'Mi suscripciÃ³n', tone: Tone.orange, onTap: () => context.push('/subscription')),
            MenuRow(icon: 'gear', title: 'ConfiguraciÃ³n', onTap: () => context.push('/settings')),
            MenuRow(icon: 'help', title: 'Ayuda', tone: Tone.blue, onTap: () => context.push('/help')),
          ]),
          const SizedBox(height: 16),
          SaluxCard(
            gradient: SaluxGradients.primary,
            border: Colors.transparent,
            child: Row(
              children: [
                const Expanded(
                  child: Text('PequeÃ±os avances, grandes logros',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 17)),
                ),
                const Mascot(MascotMood.happy, size: 70),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ===================================================================== /notes

class NotesScreen extends ConsumerWidget {
  const NotesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final app = ref.watch(appProvider);
    final c = context.colors;

    Future<void> add() async {
      final ctl = TextEditingController();
      await showSaluxSheet<void>(
        context,
        builder: (ctx) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Nueva nota', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 20)),
            const SizedBox(height: 12),
            SaluxInput(controller: ctl, hint: 'Escribe tu notaâ€¦', maxLines: 4, autofocus: true),
            const SizedBox(height: 14),
            SaluxButton('Guardar', onPressed: () {
              if (ctl.text.trim().isNotEmpty) {
                ref.read(appProvider.notifier).addNote(ctl.text.trim(), 'General');
              }
              Navigator.pop(ctx);
            }),
          ],
        ),
      );
      ctl.dispose();
    }

    return SaluxPage(
      title: 'Mis notas',
      actions: [RoundIconButton(icon: 'plus', label: 'Agregar nota', onTap: add)],
      children: [
        if (app.notes.isEmpty)
          const EmptyState(mood: MascotMood.sleep, title: 'Sin notas', subtitle: 'Toca + para crear tu primera nota.')
        else
          for (final n in app.notes)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: SaluxCard(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Pill(n.tag, tone: Tone.violet),
                          const SizedBox(height: 8),
                          Text(n.text, style: const TextStyle(fontWeight: FontWeight.w600)),
                          const SizedBox(height: 4),
                          Text(longDate(n.at), style: TextStyle(color: c.muted, fontSize: 11)),
                        ],
                      ),
                    ),
                    RoundIconButton(
                      icon: 'trash',
                      label: 'Eliminar nota',
                      color: c.error,
                      onTap: () => ref.read(appProvider.notifier).deleteNote(n.id),
                    ),
                  ],
                ),
              ),
            ),
      ],
    );
  }
}

// ================================================================= /favorites

class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final app = ref.watch(appProvider);
    final all = ref.watch(allQuestionsProvider);
    final c = context.colors;
    return SaluxPage(
      title: 'Favoritos',
      children: all.when(
        loading: () => [const Skeleton(height: 120), const Skeleton(height: 120)],
        error: (_, _) => [EmptyState(mood: MascotMood.sad, title: 'No se pudo cargar', action: () => ref.invalidate(allQuestionsProvider))],
        data: (qs) {
          final favs = qs.where((q) => app.favorites.contains(q.id)).toList();
          if (favs.isEmpty) {
            return const [EmptyState(mood: MascotMood.sleep, title: 'Sin favoritos', subtitle: 'Toca el corazÃ³n en una pregunta para guardarla.')];
          }
          return [
            for (final q in favs)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: SaluxCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        Pill(q.topic, tone: Tone.pink),
                        const Spacer(),
                        RoundIconButton(icon: 'heart', label: 'Quitar de favoritos', color: c.error,
                            onTap: () => ref.read(appProvider.notifier).toggleFavorite(q.id)),
                      ]),
                      Text(q.text, style: const TextStyle(fontWeight: FontWeight.w700)),
                      const SizedBox(height: 8),
                      Text('Respuesta: ${q.options[q.correctIndex].text}',
                          style: TextStyle(color: c.ok, fontWeight: FontWeight.w700)),
                    ],
                  ),
                ),
              ),
          ];
        },
      ),
    );
  }
}

// ================================================================ /downloads

class DownloadsScreen extends ConsumerWidget {
  const DownloadsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final app = ref.watch(appProvider);
    final c = context.colors;
    return SaluxPage(
      title: 'Descargas',
      children: [
        SaluxCard(
          color: c.soft,
          child: Row(children: [
            SaluxIcon('wifioff', size: 22, color: c.primary),
            const SizedBox(width: 10),
            Expanded(child: Text('Lo descargado funciona sin conexiÃ³n.', style: TextStyle(color: c.muted))),
          ]),
        ),
        const SizedBox(height: 12),
        for (final m in modules.take(4))
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: SaluxCard(
              child: Row(children: [
                IconTile(m.icon, tone: m.tone, size: 44),
                const SizedBox(width: 12),
                Expanded(child: Text('Simulacros ${m.name}', style: const TextStyle(fontWeight: FontWeight.w700))),
                SizedBox(
                  width: 128,
                  child: SaluxButton(
                    app.downloads.contains(m.id) ? 'Descargado' : 'Descargar',
                    secondary: app.downloads.contains(m.id),
                    onPressed: () {
                      ref.read(appProvider.notifier).toggleDownload(m.id);
                      showToast(context, 'Descarga simulada');
                    },
                  ),
                ),
              ]),
            ),
          ),
        const SizedBox(height: 6),
        Row(children: [
          const Expanded(child: Text('Descargar solo con Wiâ€‘Fi', style: TextStyle(fontWeight: FontWeight.w600))),
          SaluxSwitch(
            value: app.wifiOnly,
            label: 'Solo Wiâ€‘Fi',
            onChanged: (v) => ref.read(appProvider.notifier).update((s) => s.copyWith(wifiOnly: v)),
          ),
        ]),
      ],
    );
  }
}

// ================================================================= /settings

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final app = ref.watch(appProvider);
    final ctl = ref.read(appProvider.notifier);
    final c = context.colors;

    Widget switchRow(String icon, String title, bool v, ValueChanged<bool> on, [Tone tone = Tone.violet]) =>
        MenuRow(icon: icon, title: title, tone: tone, trailing: SaluxSwitch(value: v, label: title, onChanged: on));

    return SaluxPage(
      title: 'ConfiguraciÃ³n',
      children: [
        SaluxCard(
          onTap: () => context.push('/edit-profile'),
          child: Row(children: [
            ClipOval(child: Image.asset('assets/images/salux_avatar.png', width: 52, height: 52, fit: BoxFit.cover, cacheWidth: 156)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(app.name, style: const TextStyle(fontWeight: FontWeight.w800)),
                Text(app.email.isEmpty ? 'Sin correo' : app.email, style: TextStyle(color: c.muted, fontSize: 12)),
              ]),
            ),
            SaluxIcon('chev', size: 16, color: c.muted),
          ]),
        ),
        if (!app.isPremium) ...[
          const SizedBox(height: 12),
          SaluxCard(
            gradient: SaluxGradients.primary,
            border: Colors.transparent,
            onTap: () => context.push('/plans'),
            child: const Row(children: [
              SaluxIcon('crown', size: 26, color: Colors.white),
              SizedBox(width: 10),
              Expanded(child: Text('Hazte Premium', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16))),
              SaluxIcon('chev', size: 18, color: Colors.white),
            ]),
          ),
        ],
        const SectionTitle('Apariencia'),
        Row(
          children: [
            for (final m in [(ThemeMode.system, 'Sistema'), (ThemeMode.light, 'Claro'), (ThemeMode.dark, 'Oscuro')])
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: SaluxChip(m.$2, selected: app.themeMode == m.$1, onTap: () => ctl.setTheme(m.$1)),
              ),
          ],
        ),
        const SectionTitle('Estudio'),
        MenuGroup(children: [
          MenuRow(icon: 'target', title: 'Meta diaria', subtitle: '${app.dailyGoal} preguntas', tone: Tone.orange, onTap: () async {
            await showSaluxSheet<void>(context, builder: (ctx) => Consumer(builder: (ctx, ref, _) {
              final g = ref.watch(appProvider).dailyGoal;
              return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('Meta diaria', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 20)),
                const SizedBox(height: 12),
                Row(children: [
                  for (final n in [10, 20, 30])
                    Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: SaluxChip('$n', selected: g == n, onTap: () => ref.read(appProvider.notifier).update((s) => s.copyWith(dailyGoal: n))),
                    ),
                ]),
                const SizedBox(height: 16),
                SaluxButton('Listo', onPressed: () => Navigator.pop(ctx)),
              ]);
            }));
          }),
          MenuRow(icon: 'calendar', title: 'Plan de estudio', tone: Tone.mint, onTap: () => context.push('/study-plan')),
          MenuRow(icon: 'bell', title: 'Recordatorios', subtitle: app.reminder, onTap: () => context.push('/notification-settings')),
          switchRow('bolt', 'Sonidos', app.sounds, (v) => ctl.update((s) => s.copyWith(sounds: v)), Tone.blue),
          switchRow('phone', 'VibraciÃ³n', app.vibration, (v) => ctl.update((s) => s.copyWith(vibration: v)), Tone.pink),
          MenuRow(icon: 'globe', title: 'Idioma', subtitle: 'EspaÃ±ol', tone: Tone.blue, onTap: () => context.push('/language')),
        ]),
        const SectionTitle('Cuenta'),
        MenuGroup(children: [
          MenuRow(icon: 'shield', title: 'Seguridad', onTap: () => context.push('/security')),
          MenuRow(icon: 'lock', title: 'ContraseÃ±a', tone: Tone.blue, onTap: () => context.push('/change-password')),
          MenuRow(icon: 'crown', title: 'SuscripciÃ³n', tone: Tone.orange, onTap: () => context.push('/subscription')),
          MenuRow(icon: 'download', title: 'Exportar mis datos', tone: Tone.mint, onTap: () => showToast(context, 'Te enviaremos un archivo con tus datos')),
        ]),
        const SectionTitle('Soporte'),
        MenuGroup(children: [
          MenuRow(icon: 'help', title: 'Ayuda', tone: Tone.blue, onTap: () => context.push('/help')),
          MenuRow(icon: 'gift', title: 'Invitar amigos', tone: Tone.pink, onTap: () => context.push('/invite')),
          MenuRow(icon: 'star', title: 'Calificar la app', tone: Tone.orange, onTap: () => showToast(context, 'Â¡Gracias por tu calificaciÃ³n!')),
          MenuRow(icon: 'file', title: 'TÃ©rminos y privacidad', onTap: () => context.push('/legal')),
          MenuRow(icon: 'info', title: 'Acerca de', tone: Tone.mint, onTap: () => context.push('/about')),
        ]),
        const SizedBox(height: 16),
        SaluxButton('Cerrar sesiÃ³n', secondary: true, icon: 'logout', onPressed: () async {
          final ok = await confirmSheet(context,
              mood: MascotMood.sad,
              title: 'Â¿Cerrar sesiÃ³n?',
              message: 'PodrÃ¡s volver a entrar cuando quieras.',
              confirmLabel: 'Cerrar sesiÃ³n');
          if (ok && context.mounted) {
            ctl.signOut();
            context.go('/welcome');
          }
        }),
        const SizedBox(height: 10),
        SaluxButton('Eliminar cuenta', secondary: true, danger: true, icon: 'trash', onPressed: () async {
          final ok = await confirmSheet(context,
              mood: MascotMood.sad,
              title: 'Â¿Eliminar tu cuenta?',
              message: 'Esta acciÃ³n es irreversible y borrarÃ¡ tu progreso.',
              confirmLabel: 'Eliminar cuenta',
              danger: true);
          if (ok && context.mounted) {
            ctl.deleteAccount();
            context.go('/welcome');
          }
        }),
        const SizedBox(height: 14),
        Center(child: Text('SALUX 1.0.0 (MVP)', style: TextStyle(color: c.muted, fontSize: 12))),
      ],
    );
  }
}

// ======================================================= /notification-settings

class NotificationSettingsScreen extends ConsumerWidget {
  const NotificationSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final app = ref.watch(appProvider);
    final ctl = ref.read(appProvider.notifier);
    Widget row(String icon, String title, String sub, bool v, ValueChanged<bool> on, Tone t) =>
        MenuRow(icon: icon, title: title, subtitle: sub, tone: t, trailing: SaluxSwitch(value: v, label: title, onChanged: on));
    return SaluxPage(
      title: 'Notificaciones',
      children: [
        MenuGroup(children: [
          row('bell', 'Recordatorio diario', 'Todos los dÃ­as a las ${app.reminder}', app.remindersOn, (v) => ctl.update((s) => s.copyWith(remindersOn: v)), Tone.violet),
          MenuRow(icon: 'clock', title: 'Hora del recordatorio', subtitle: app.reminder, tone: Tone.blue, onTap: () async {
            final p = app.reminder.split(':');
            final t = await showTimePicker(context: context, initialTime: TimeOfDay(hour: int.parse(p[0]), minute: int.parse(p[1])));
            if (t != null) {
              ctl.update((s) => s.copyWith(reminder: '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}'));
            }
          }),
          row('flame', 'Racha en riesgo', 'Te avisamos si estÃ¡s por perderla', app.streakRiskOn, (v) => ctl.update((s) => s.copyWith(streakRiskOn: v)), Tone.orange),
          row('file', 'Nuevos simulacros', 'Cuando haya contenido nuevo', app.newSimsOn, (v) => ctl.update((s) => s.copyWith(newSimsOn: v)), Tone.mint),
          row('gift', 'Ofertas', 'Descuentos y promociones', app.offersOn, (v) => ctl.update((s) => s.copyWith(offersOn: v)), Tone.pink),
        ]),
      ],
    );
  }
}

// ================================================================== /security

class SecurityScreen extends ConsumerWidget {
  const SecurityScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final app = ref.watch(appProvider);
    final ctl = ref.read(appProvider.notifier);
    return SaluxPage(
      title: 'Seguridad',
      children: [
        MenuGroup(children: [
          MenuRow(
            icon: 'shield',
            title: 'VerificaciÃ³n en dos pasos',
            subtitle: app.mfaEnabled ? 'Activada' : 'Desactivada',
            trailing: SaluxSwitch(
              value: app.mfaEnabled,
              label: 'VerificaciÃ³n en dos pasos',
              onChanged: (v) {
                if (v) {
                  context.push('/mfa-setup');
                } else {
                  ctl.update((s) => s.copyWith(mfaEnabled: false));
                  showToast(context, 'MFA desactivada');
                }
              },
            ),
          ),
          MenuRow(
            icon: 'eye',
            title: 'Desbloqueo biomÃ©trico',
            tone: Tone.mint,
            trailing: SaluxSwitch(value: app.biometric, label: 'BiometrÃ­a', onChanged: (v) => ctl.update((s) => s.copyWith(biometric: v))),
          ),
          MenuRow(icon: 'lock', title: 'CÃ³digos de respaldo', tone: Tone.orange, onTap: () => context.push('/backup-codes')),
          MenuRow(icon: 'lock', title: 'Cambiar contraseÃ±a', tone: Tone.blue, onTap: () => context.push('/change-password')),
        ]),
        const SectionTitle('Dispositivos activos'),
        MenuGroup(children: [
          MenuRow(icon: 'phone', title: 'Este dispositivo', subtitle: 'Emulador Android Â· ahora', tone: Tone.mint),
          MenuRow(icon: 'globe', title: 'Navegador web', subtitle: 'Hace 2 dÃ­as', tone: Tone.blue,
              trailing: TextButton(onPressed: () => showToast(context, 'SesiÃ³n cerrada'), child: const Text('Cerrar'))),
        ]),
        const SizedBox(height: 14),
        SaluxButton('Cerrar sesiÃ³n en todos', secondary: true, danger: true, onPressed: () => showToast(context, 'Sesiones cerradas')),
      ],
    );
  }
}

// ============================================================== /notifications

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final app = ref.watch(appProvider);
    final c = context.colors;
    return SaluxPage(
      title: 'Notificaciones',
      actions: [
        TextButton(
          onPressed: () => ref.read(appProvider.notifier).update((s) => s.copyWith(notificationsRead: true)),
          child: Text('Marcar leÃ­das', style: TextStyle(color: c.primary, fontWeight: FontWeight.w700, fontSize: 12)),
        ),
      ],
      children: [
        for (final n in notificationItems)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: SaluxCard(
              onTap: () {
                ref.read(appProvider.notifier).update((s) => s.copyWith(notificationsRead: true));
                context.push(n.route);
              },
              child: Row(children: [
                IconTile(n.icon, tone: Tone.violet, size: 42),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(n.title, style: const TextStyle(fontWeight: FontWeight.w800)),
                    Text(n.body, style: TextStyle(color: c.muted, fontSize: 12)),
                    Text(n.when, style: TextStyle(color: c.muted, fontSize: 11)),
                  ]),
                ),
                if (!app.notificationsRead) Container(width: 10, height: 10, decoration: BoxDecoration(color: c.primary, shape: BoxShape.circle)),
              ]),
            ),
          ),
      ],
    );
  }
}

// =============================================================== /edit-profile

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  late final _name = TextEditingController(text: ref.read(appProvider).name);
  late final _email = TextEditingController(text: ref.read(appProvider).email);
  late final _uni = TextEditingController(text: ref.read(appProvider).university);
  late int _year = ref.read(appProvider).studyYear;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _uni.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SaluxPage(
      title: 'Editar perfil',
      bottom: SaluxButton('Guardar', onPressed: () {
        if (_name.text.trim().isEmpty) {
          showToast(context, 'El nombre es obligatorio');
          return;
        }
        ref.read(appProvider.notifier).update((s) => s.copyWith(
              name: _name.text.trim(),
              email: _email.text.trim(),
              university: _uni.text.trim(),
              studyYear: _year,
            ));
        showToast(context, 'Perfil actualizado');
        safePop(context);
      }),
      children: [
        Center(
          child: ClipOval(child: Image.asset('assets/images/salux_avatar.png', width: 104, height: 104, fit: BoxFit.cover, cacheWidth: 312)),
        ),
        Center(child: TextButton(onPressed: () => showToast(context, 'Cambio de foto disponible con el backend'), child: const Text('Cambiar foto'))),
        const FieldLabel('Nombre'),
        SaluxInput(controller: _name, hint: 'Tu nombre', icon: 'user'),
        const FieldLabel('Correo'),
        SaluxInput(controller: _email, hint: 'tucorreo@ejemplo.com', icon: 'mail', keyboard: TextInputType.emailAddress),
        const FieldLabel('Universidad'),
        SaluxInput(controller: _uni, hint: 'Tu universidad', icon: 'book'),
        const FieldLabel('AÃ±o de estudios'),
        Wrap(spacing: 8, runSpacing: 8, children: [
          for (var y = 1; y <= 7; y++) SaluxChip('$yÂ°', selected: _year == y, onTap: () => setState(() => _year = y)),
        ]),
      ],
    );
  }
}

// ============================================================ /change-password

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _cur = TextEditingController();
  final _new = TextEditingController();
  final _rep = TextEditingController();

  @override
  void dispose() {
    _cur.dispose();
    _new.dispose();
    _rep.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final st = passwordStrength(_new.text);
    final ok = _cur.text.isNotEmpty && st > 0 && _new.text == _rep.text;
    return SaluxPage(
      title: 'Cambiar contraseÃ±a',
      bottom: SaluxButton('Actualizar', onPressed: ok ? () {
        showToast(context, 'ContraseÃ±a actualizada');
        safePop(context);
      } : null),
      children: [
        const FieldLabel('ContraseÃ±a actual'),
        SaluxInput(controller: _cur, hint: 'â€¢â€¢â€¢â€¢â€¢â€¢â€¢â€¢', icon: 'lock', obscure: true, onChanged: (_) => setState(() {})),
        const FieldLabel('Nueva contraseÃ±a'),
        SaluxInput(controller: _new, hint: 'MÃ­nimo 8 caracteres', icon: 'lock', obscure: true, onChanged: (_) => setState(() {})),
        if (_new.text.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(['DÃ©bil', 'Media', 'Fuerte'][st], style: TextStyle(color: [c.error, c.warn, c.ok][st], fontWeight: FontWeight.w700)),
          ),
        const FieldLabel('Confirmar contraseÃ±a'),
        SaluxInput(controller: _rep, hint: 'Repite la contraseÃ±a', icon: 'lock', obscure: true, onChanged: (_) => setState(() {})),
        if (_rep.text.isNotEmpty && _rep.text != _new.text)
          Padding(padding: const EdgeInsets.only(top: 8), child: Text('Las contraseÃ±as no coinciden', style: TextStyle(color: c.error))),
        const SizedBox(height: 14),
        Text('Usa 8+ caracteres con mayÃºsculas, minÃºsculas, nÃºmeros y sÃ­mbolos.', style: TextStyle(color: c.muted, fontSize: 12)),
      ],
    );
  }
}

// =================================================================== /language

class LanguageScreen extends ConsumerWidget {
  const LanguageScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final app = ref.watch(appProvider);
    final c = context.colors;
    const langs = [('es', 'EspaÃ±ol'), ('en', 'English'), ('pt', 'PortuguÃªs')];
    return SaluxPage(
      title: 'Idioma',
      children: [
        MenuGroup(children: [
          for (final l in langs)
            MenuRow(
              icon: 'globe',
              title: l.$2,
              tone: Tone.blue,
              trailing: app.language == l.$1 ? SaluxIcon('check', color: c.primary) : null,
              onTap: () {
                ref.read(appProvider.notifier).update((s) => s.copyWith(language: l.$1));
                showToast(context, l.$1 == 'es' ? 'Idioma: EspaÃ±ol' : 'TraducciÃ³n disponible prÃ³ximamente');
              },
            ),
        ]),
      ],
    );
  }
}

// ===================================================================== /legal

class LegalScreen extends StatefulWidget {
  const LegalScreen({super.key});

  @override
  State<LegalScreen> createState() => _LegalScreenState();
}

class _LegalScreenState extends State<LegalScreen> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    return SaluxPage(
      title: 'Legal',
      children: [
        Row(children: [
          SaluxChip('TÃ©rminos', selected: _tab == 0, onTap: () => setState(() => _tab = 0)),
          const SizedBox(width: 8),
          SaluxChip('Privacidad', selected: _tab == 1, onTap: () => setState(() => _tab = 1)),
        ]),
        const SizedBox(height: 14),
        SaluxCard(child: Text(_tab == 0 ? legalTerms : legalPrivacy, style: const TextStyle(height: 1.5))),
      ],
    );
  }
}

// ===================================================================== /about

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return SaluxPage(
      title: 'Acerca de',
      children: [
        const SizedBox(height: 10),
        Center(child: Text('SALUX', style: TextStyle(fontSize: 38, fontWeight: FontWeight.w800, color: c.primary, letterSpacing: -1))),
        const Center(child: MascotSticker(height: 180)),
        Center(child: Text('VersiÃ³n 1.0.0 (MVP)', style: TextStyle(color: c.muted))),
        const SizedBox(height: 4),
        Center(child: Text('Tu futuro en salud comienza aquÃ­', style: TextStyle(color: c.muted))),
        const SizedBox(height: 18),
        MenuGroup(children: [
          MenuRow(icon: 'file', title: 'TÃ©rminos y privacidad', onTap: () => context.push('/legal')),
          MenuRow(icon: 'help', title: 'Ayuda', tone: Tone.blue, onTap: () => context.push('/help')),
          MenuRow(icon: 'link', title: 'Sitio web', tone: Tone.mint, onTap: () => showToast(context, 'Sitio web prÃ³ximamente')),
        ]),
      ],
    );
  }
}

