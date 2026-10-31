import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:saluxprototipo/app/app.dart';
import 'package:saluxprototipo/app/router.dart';
import 'package:saluxprototipo/core/theme/app_theme.dart';
import 'package:saluxprototipo/features/quiz/data/question_repository.dart';
import 'package:saluxprototipo/features/session/presentation/app_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<ProviderContainer> _boot(WidgetTester t, {bool loggedIn = true}) async {
  // La fuente de prueba (Ahem) es mucho más ancha que la real: los desbordes
  // horizontales de texto se verifican en el emulador, no aquí.
  final prev = FlutterError.onError;
  FlutterError.onError = (d) {
    if (d.exceptionAsString().contains('overflowed')) return;
    prev?.call(d);
  };
  addTearDown(() => FlutterError.onError = prev);
  AppTheme.useGoogleFonts = false;
  await initializeDateFormatting('es');
  SharedPreferences.setMockInitialValues({});
  final prefs = await SharedPreferences.getInstance();
  final c = ProviderContainer(overrides: [prefsProvider.overrideWithValue(prefs)]);
  if (loggedIn) c.read(appProvider.notifier).signIn(email: 'demo@salux.test');
  t.view.physicalSize = const Size(1080, 2340);
  t.view.devicePixelRatio = 3;
  addTearDown(t.view.reset);
  addTearDown(c.dispose);
  await t.pumpWidget(UncontrolledProviderScope(container: c, child: const SaluxApp()));
  return c;
}

void main() {
  testWidgets('sin sesión, el splash lleva a onboarding y luego a bienvenida', (t) async {
    await _boot(t, loggedIn: false);
    expect(find.text('SALUX'), findsOneWidget);
    await t.pump(const Duration(milliseconds: 2000));
    await t.pumpAndSettle();
    expect(find.text('Elige tu examen'), findsOneWidget);
    await t.tap(find.text('Saltar'));
    await t.pumpAndSettle();
    expect(find.text('Iniciar sesión'), findsOneWidget);
    expect(find.text('3 días gratis'), findsOneWidget);
  });

  testWidgets('con sesión, las pantallas principales se renderizan sin errores', (t) async {
    final c = await _boot(t);
    final router = c.read(routerProvider);
    await t.pumpAndSettle();
    for (final route in [
      '/home', '/modules', '/simulations', '/progress', '/profile', '/streak', '/achievements',
      '/exam/ENAM', '/topic/medicina-interna', '/quiz-setup', '/history', '/notes', '/favorites',
      '/downloads', '/settings', '/notification-settings', '/security', '/notifications',
      '/edit-profile', '/change-password', '/language', '/legal', '/about', '/docs', '/doc/d1',
      '/ranking', '/invite', '/study-plan', '/plans', '/checkout', '/pay-qr', '/pay-card',
      '/subscription', '/paywall', '/help', '/offline', '/error', '/mfa-setup', '/backup-codes',
      '/pick-career', '/pick-goal', '/trial-start', '/search',
    ]) {
      router.go(route);
      await t.pumpAndSettle();
      expect(t.takeException(), isNull, reason: route);
    }
  });

  testWidgets('flujo principal: simulacro con tiempo -> resultado -> revisión', (t) async {
    final c = await _boot(t);
    final router = c.read(routerProvider);
    await t.pumpAndSettle();
    // El banco se lee de assets con E/S real: se precarga fuera del reloj falso.
    await t.runAsync(() => c.read(questionRepositoryProvider).all());
    router.go('/simulations');
    await t.pumpAndSettle();
    await t.tap(find.text('Simulacro con tiempo'));
    await t.pumpAndSettle();
    expect(find.text('Comenzar'), findsOneWidget);
    await t.tap(find.text('5 preguntas'));
    await t.pump();
    await t.tap(find.text('Comenzar'));
    await t.pumpAndSettle();
    expect(find.textContaining('Pregunta 1 de 5'), findsOneWidget);
    for (var i = 0; i < 5; i++) {
      await t.tap(find.bySemanticsLabel(RegExp('^Opción A')).first);
      await t.pump();
      await t.tap(find.text(i == 4 ? 'Finalizar' : 'Siguiente'));
      await t.pumpAndSettle();
    }
    expect(find.text('Revisar'), findsOneWidget);
    expect(c.read(appProvider).history.length, 1);
    expect(c.read(appProvider).answeredToday, 5);
    await t.tap(find.text('Revisar'));
    await t.pumpAndSettle();
    expect(find.text('Revisión'), findsOneWidget);
  });

  testWidgets('prueba vencida: abrir un examen lleva al paywall', (t) async {
    final c = await _boot(t);
    c.read(appProvider.notifier).expireTrial();
    final router = c.read(routerProvider);
    await t.pumpAndSettle();
    router.go('/exam/ENAM');
    await t.pumpAndSettle();
    expect(find.text('Tu prueba gratis terminó'), findsOneWidget);
  });

  testWidgets('pago simulado activa Premium', (t) async {
    final c = await _boot(t);
    final router = c.read(routerProvider);
    await t.pumpAndSettle();
    router.go('/pay-qr');
    await t.pumpAndSettle();
    await t.tap(find.text('Simular pago recibido (demo)'));
    await t.pump();
    await t.pump(const Duration(seconds: 3));
    await t.pumpAndSettle();
    expect(c.read(appProvider).isPremium, isTrue);
    expect(find.text('¡Pago confirmado!'), findsOneWidget);
  });
}
