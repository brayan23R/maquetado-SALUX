import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../core/theme/tokens.dart';
import '../../../core/utils/format.dart';
import '../../../core/widgets/widgets.dart';
import '../../session/presentation/app_controller.dart';

/// Selección actual del flujo de pago.
class Checkout {
  const Checkout({this.planKey = 'quarterly', this.method = 'yape'});

  final String planKey;
  final String method;

  Checkout copyWith({String? planKey, String? method}) =>
      Checkout(planKey: planKey ?? this.planKey, method: method ?? this.method);
}

class CheckoutController extends Notifier<Checkout> {
  @override
  Checkout build() => const Checkout();

  void set(Checkout c) => state = c;
}

final checkoutProvider = NotifierProvider<CheckoutController, Checkout>(CheckoutController.new);

String methodLabel(String m) => switch (m) { 'yape' => 'Yape', 'plin' => 'Plin', _ => 'Tarjeta' };

// ===================================================================== /plans

class PlansScreen extends ConsumerWidget {
  const PlansScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final co = ref.watch(checkoutProvider);
    final c = context.colors;
    const benefits = [
      'Simulacros y preguntas ilimitados',
      'Respuestas explicadas',
      'Documentos y descargas sin conexión',
      'Estadísticas y plan de estudio',
    ];
    return SaluxPage(
      title: 'Planes',
      bottom: SaluxButton('Continuar', onPressed: () => context.push('/checkout')),
      children: [
        SaluxCard(
          gradient: SaluxGradients.primary,
          border: Colors.transparent,
          padding: const EdgeInsets.all(18),
          child: Row(children: [
            const Expanded(
              child: Text('SALUX Premium', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w800)),
            ),
            const Mascot(MascotMood.love, size: 100),
          ]),
        ),
        const SizedBox(height: 14),
        for (final b in benefits)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: Row(children: [
              SaluxIcon('check', size: 20, color: c.ok),
              const SizedBox(width: 10),
              Expanded(child: Text(b, style: const TextStyle(fontWeight: FontWeight.w600))),
            ]),
          ),
        const SizedBox(height: 10),
        for (final e in plans.entries)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: SaluxCard(
              border: co.planKey == e.key ? c.primary : null,
              onTap: () => ref.read(checkoutProvider.notifier).set(co.copyWith(planKey: e.key)),
              child: Row(children: [
                Icon(co.planKey == e.key ? Icons.radio_button_checked : Icons.radio_button_off, color: co.planKey == e.key ? c.primary : c.muted),
                const SizedBox(width: 12),
                Expanded(
                  child: Row(children: [
                    Text(e.value.name, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                    if (e.value.badge.isNotEmpty) ...[const SizedBox(width: 8), Pill(e.value.badge, tone: Tone.mint)],
                  ]),
                ),
                Text('S/ ${e.value.price}', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18, color: c.primary)),
              ]),
            ),
          ),
        Text('Precios de ejemplo.', textAlign: TextAlign.center, style: TextStyle(color: c.muted, fontSize: 12)),
      ],
    );
  }
}

// ================================================================== /checkout

class CheckoutScreen extends ConsumerWidget {
  const CheckoutScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final co = ref.watch(checkoutProvider);
    final plan = plans[co.planKey]!;
    final c = context.colors;
    const methods = [('yape', 'Yape', 'qr', Tone.violet), ('plin', 'Plin', 'qr', Tone.blue), ('card', 'Tarjeta Visa/Mastercard', 'card', Tone.orange)];
    return SaluxPage(
      title: 'Pago',
      bottom: SaluxButton('Pagar S/ ${plan.price}', onPressed: () => context.push(co.method == 'card' ? '/pay-card' : '/pay-qr')),
      children: [
        SaluxCard(
          child: Row(children: [
            const IconTile('crown', tone: Tone.orange, size: 46),
            const SizedBox(width: 12),
            Expanded(child: Text('Plan ${plan.name}', style: const TextStyle(fontWeight: FontWeight.w800))),
            Text('S/ ${plan.price}', style: TextStyle(fontWeight: FontWeight.w800, color: c.primary, fontSize: 18)),
          ]),
        ),
        const SectionTitle('Medio de pago'),
        for (final m in methods)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: SaluxCard(
              border: co.method == m.$1 ? c.primary : null,
              onTap: () => ref.read(checkoutProvider.notifier).set(co.copyWith(method: m.$1)),
              child: Row(children: [
                IconTile(m.$3, tone: m.$4, size: 42),
                const SizedBox(width: 12),
                Expanded(child: Text(m.$2, style: const TextStyle(fontWeight: FontWeight.w700))),
                Icon(co.method == m.$1 ? Icons.radio_button_checked : Icons.radio_button_off, color: co.method == m.$1 ? c.primary : c.muted),
              ]),
            ),
          ),
        const SizedBox(height: 8),
        Text('Pagos simulados en esta versión de demostración.', style: TextStyle(color: c.muted, fontSize: 12)),
      ],
    );
  }
}

// ================================================================== /pay-qr

class PayQrScreen extends ConsumerWidget {
  const PayQrScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final co = ref.watch(checkoutProvider);
    final plan = plans[co.planKey]!;
    final c = context.colors;
    final code = 'SLX-${(co.planKey.hashCode & 0xFFFFF).toRadixString(16).toUpperCase()}';
    return SaluxPage(
      title: 'Paga con ${methodLabel(co.method)}',
      bottom: Column(mainAxisSize: MainAxisSize.min, children: [
        SaluxButton('Simular pago recibido (demo)', onPressed: () => context.push('/pay-processing')),
        const SizedBox(height: 8),
        SaluxButton('Cambiar medio', secondary: true, onPressed: () => safePop(context)),
      ]),
      children: [
        Center(child: Text('S/ ${plan.price}', style: TextStyle(fontSize: 38, fontWeight: FontWeight.w800, color: c.primary))),
        const SizedBox(height: 10),
        Center(
          child: Container(
            color: Colors.white,
            padding: const EdgeInsets.all(12),
            child: QrImageView(data: 'salux-demo-pay:$code:${plan.price}', size: 190),
          ),
        ),
        const SizedBox(height: 10),
        Center(child: Text('Código de pago: $code', style: const TextStyle(fontWeight: FontWeight.w800))),
        Center(child: Text('Vence en 15 minutos', style: TextStyle(color: c.muted, fontSize: 12))),
        const SizedBox(height: 14),
        for (final s in ['Abre ${methodLabel(co.method)} en tu celular', 'Escanea el código QR', 'Confirma el pago y listo'].indexed)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(children: [
              CircleAvatar(radius: 12, backgroundColor: c.soft, child: Text('${s.$1 + 1}', style: TextStyle(color: c.primary, fontWeight: FontWeight.w800, fontSize: 12))),
              const SizedBox(width: 10),
              Expanded(child: Text(s.$2)),
            ]),
          ),
      ],
    );
  }
}

// ================================================================= /pay-card

class PayCardScreen extends StatefulWidget {
  const PayCardScreen({super.key});

  @override
  State<PayCardScreen> createState() => _PayCardScreenState();
}

class _PayCardScreenState extends State<PayCardScreen> {
  final _num = TextEditingController();
  final _exp = TextEditingController();
  final _cvv = TextEditingController();
  final _name = TextEditingController();
  bool _save = false;

  @override
  void dispose() {
    _num.dispose();
    _exp.dispose();
    _cvv.dispose();
    _name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    // Los datos de tarjeta no se guardan ni se envían: es una pantalla simulada.
    return SaluxPage(
      title: 'Pago con tarjeta',
      bottom: Column(mainAxisSize: MainAxisSize.min, children: [
        SaluxButton('Pagar', onPressed: () => context.push('/pay-processing')),
        const SizedBox(height: 8),
        SaluxButton('Simular rechazado', secondary: true, danger: true, onPressed: () => context.push('/pay-failed')),
      ]),
      children: [
        const FieldLabel('Número de tarjeta'),
        SaluxInput(controller: _num, hint: '0000 0000 0000 0000', icon: 'card', keyboard: TextInputType.number, maxLength: 19),
        Row(children: [
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const FieldLabel('Vence'),
            SaluxInput(controller: _exp, hint: 'MM/AA', keyboard: TextInputType.number, maxLength: 5),
          ])),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const FieldLabel('CVV'),
            SaluxInput(controller: _cvv, hint: '123', keyboard: TextInputType.number, maxLength: 4, obscure: true),
          ])),
        ]),
        const FieldLabel('Nombre en la tarjeta'),
        SaluxInput(controller: _name, hint: 'Como aparece en la tarjeta', icon: 'user'),
        const SizedBox(height: 12),
        Row(children: [
          SaluxSwitch(value: _save, label: 'Guardar tarjeta', onChanged: (v) => setState(() => _save = v)),
          const Expanded(child: Text('Guardar tarjeta para próximos pagos')),
        ]),
        const SizedBox(height: 8),
        SaluxCard(color: c.soft, child: Row(children: [
          SaluxIcon('lock', size: 20, color: c.primary),
          const SizedBox(width: 10),
          Expanded(child: Text('Tus datos viajan cifrados. En producción los procesa la pasarela de pago.', style: TextStyle(color: c.muted, fontSize: 12))),
        ])),
      ],
    );
  }
}

// ========================================================== /pay-processing

class PayProcessingScreen extends ConsumerStatefulWidget {
  const PayProcessingScreen({super.key});

  @override
  ConsumerState<PayProcessingScreen> createState() => _PayProcessingScreenState();
}

class _PayProcessingScreenState extends ConsumerState<PayProcessingScreen> {
  Timer? _t;

  @override
  void initState() {
    super.initState();
    // Simula la confirmación del webhook (en backend llega por Realtime).
    _t = Timer(const Duration(seconds: 2), () {
      if (!mounted) return;
      final co = ref.read(checkoutProvider);
      ref.read(appProvider.notifier).activatePremium(planKey: co.planKey, method: co.method);
      context.go('/pay-success');
    });
  }

  @override
  void dispose() {
    _t?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(mainAxisSize: MainAxisSize.min, children: const [
            CircularProgressIndicator(),
            SizedBox(height: 20),
            Text('Confirmando tu pago…', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
          ]),
        ),
      ),
    );
  }
}

// ============================================================== /pay-success

class PaySuccessScreen extends ConsumerWidget {
  const PaySuccessScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final app = ref.watch(appProvider);
    final c = context.colors;
    final plan = plans[app.planKey ?? 'monthly']!;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(children: [
            const Spacer(),
            const Mascot(MascotMood.cheer, size: 180),
            const Text('¡Pago confirmado!', style: TextStyle(fontSize: 27, fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            Text('Ya eres Premium. Vigente hasta ${app.premiumUntil == null ? '—' : longDate(app.premiumUntil!)}.',
                textAlign: TextAlign.center, style: TextStyle(color: c.muted)),
            const SizedBox(height: 16),
            SaluxCard(child: Column(children: [
              _kv('Plan', plan.name),
              _kv('Medio', methodLabel(app.payMethod ?? 'card')),
              _kv('Monto', 'S/ ${plan.price}'),
              _kv('Comprobante', 'DEMO-${Random(app.premiumUntil?.millisecond ?? 1).nextInt(99999).toString().padLeft(5, '0')}'),
            ])),
            const Spacer(),
            SaluxButton('Ir al inicio', onPressed: () => context.go('/home')),
          ]),
        ),
      ),
    );
  }

  Widget _kv(String k, String v) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(k), Text(v, style: const TextStyle(fontWeight: FontWeight.w800))]),
      );
}

// =============================================================== /pay-failed

class PayFailedScreen extends StatelessWidget {
  const PayFailedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(children: [
            const Spacer(),
            const Mascot(MascotMood.sad, size: 180),
            const Text('No se pudo completar el pago', textAlign: TextAlign.center, style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            Text('Motivo: pago rechazado por el medio de pago.', textAlign: TextAlign.center, style: TextStyle(color: c.muted)),
            const Spacer(),
            SaluxButton('Reintentar', onPressed: () => context.go('/checkout')),
            const SizedBox(height: 10),
            SaluxButton('Usar otro medio', secondary: true, onPressed: () => context.go('/checkout')),
          ]),
        ),
      ),
    );
  }
}

// ============================================================ /subscription

class SubscriptionScreen extends ConsumerWidget {
  const SubscriptionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final app = ref.watch(appProvider);
    final ctl = ref.read(appProvider.notifier);
    final c = context.colors;
    final state = app.isPremium ? 'Premium' : (app.isTrial ? 'Prueba gratis' : 'Plan gratis');
    return SaluxPage(
      title: 'Mi suscripción',
      children: [
        SaluxCard(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Pill(state, tone: app.isPremium ? Tone.orange : Tone.mint, icon: 'crown'),
            const SizedBox(height: 12),
            if (app.isPremium) ...[
              Text('Plan ${plans[app.planKey]!.name}', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
              Text('Medio: ${methodLabel(app.payMethod ?? 'card')}', style: TextStyle(color: c.muted)),
              Text('Vigente hasta ${longDate(app.premiumUntil!)}', style: TextStyle(color: c.muted)),
            ] else if (app.isTrial)
              Text('Te quedan ${app.trialDaysLeft} días de prueba.', style: const TextStyle(fontWeight: FontWeight.w700))
            else
              Text('Tienes 5 preguntas gratis por día.', style: TextStyle(color: c.muted)),
          ]),
        ),
        const SizedBox(height: 14),
        SaluxButton(app.isPremium ? 'Cambiar plan' : 'Ver planes', onPressed: () => context.push('/plans')),
        if (app.isPremium) ...[
          const SizedBox(height: 10),
          SaluxButton('Cancelar suscripción', secondary: true, danger: true, onPressed: () async {
            final ok = await confirmSheet(context,
                mood: MascotMood.sad,
                title: '¿Cancelar suscripción?',
                message: 'Perderás el acceso Premium.',
                confirmLabel: 'Cancelar suscripción',
                cancelLabel: 'Mantener',
                danger: true);
            if (ok && context.mounted) {
              ctl.cancelSubscription();
              showToast(context, 'Suscripción cancelada');
            }
          }),
        ],
        const SectionTitle('Herramientas de demostración'),
        SaluxCard(
          color: c.soft,
          child: Column(children: [
            Text('Simula el estado de la prueba gratis para ver el paywall (en backend lo decide el servidor).', style: TextStyle(color: c.muted, fontSize: 12)),
            const SizedBox(height: 10),
            Row(children: [
              Expanded(child: SaluxButton('Terminar prueba', secondary: true, onPressed: () {
                ctl.expireTrial();
                showToast(context, 'Prueba terminada (demo)');
              })),
              const SizedBox(width: 10),
              Expanded(child: SaluxButton('Reiniciar prueba', secondary: true, onPressed: () {
                ctl.restartTrial();
                showToast(context, 'Prueba reiniciada (demo)');
              })),
            ]),
          ]),
        ),
      ],
    );
  }
}

// ================================================================== /paywall

class PaywallScreen extends ConsumerWidget {
  const PaywallScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final app = ref.watch(appProvider);
    final c = context.colors;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(children: [
            Align(alignment: Alignment.centerLeft, child: RoundIconButton(icon: 'close', label: 'Cerrar', onTap: () => safePop(context))),
            const Spacer(),
            const Mascot(MascotMood.sleep, size: 170),
            const Text('Tu prueba gratis terminó', style: TextStyle(fontSize: 27, fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            Text('Tu racha de ${app.streak} días está en espera. Elige un plan para continuar.', textAlign: TextAlign.center, style: TextStyle(color: c.muted)),
            const Spacer(),
            SaluxButton('Ver planes', onPressed: () => context.push('/plans')),
            const SizedBox(height: 10),
            SaluxButton('Continuar con plan gratis', secondary: true, onPressed: () {
              showToast(context, 'Plan gratis: 5 preguntas por día');
              context.go('/home');
            }),
          ]),
        ),
      ),
    );
  }
}
