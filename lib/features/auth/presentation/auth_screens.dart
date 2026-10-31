import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../core/theme/tokens.dart';
import '../../../core/utils/format.dart';
import '../../../core/widgets/widgets.dart';
import '../../catalog/data/mock_catalog.dart';
import '../../session/presentation/app_controller.dart';

// ================================================================= /splash

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  Timer? _timer;
  late final AnimationController _float = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 2),
  )..repeat(reverse: true);

  @override
  void initState() {
    super.initState();
    _timer = Timer(const Duration(milliseconds: 1800), _go);
  }

  void _go() {
    if (mounted) context.go('/onboarding');
  }

  @override
  void dispose() {
    _timer?.cancel();
    _float.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _go,
        child: Container(
          decoration: const BoxDecoration(gradient: SaluxGradients.primary),
          child: SafeArea(
            child: Column(
              children: [
                const Spacer(flex: 2),
                AnimatedBuilder(
                  animation: _float,
                  builder: (_, child) => Transform.translate(
                    offset: Offset(0, -10 * _float.value),
                    child: child,
                  ),
                  child: const MascotSticker(height: 250),
                ),
                const SizedBox(height: 18),
                const Text('SALUX',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 54,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -2,
                    )),
                const SizedBox(height: 6),
                const Text('Tu futuro en salud comienza aquí',
                    style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w600)),
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 80),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: const LinearProgressIndicator(
                      minHeight: 6,
                      backgroundColor: Colors.white24,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================== /onboarding

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  int _step = 0;

  static const _steps = <(String, String, MascotMood)>[
    ('Elige tu examen', 'ENAM, Essalud, Residencia Médica, ENCAPS y más áreas de salud.', MascotMood.think),
    ('Practica con simulacros', 'Preguntas con respuestas explicadas y modo con tiempo.', MascotMood.cheer),
    ('No pierdas tu racha', 'Cumple tu meta diaria y mantén tu constancia.', MascotMood.happy),
  ];

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final s = _steps[_step];
    final last = _step == _steps.length - 1;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => context.go('/welcome'),
                  child: Text('Saltar', style: TextStyle(color: c.primary, fontWeight: FontWeight.w700)),
                ),
              ),
              const Spacer(),
              Mascot(s.$3, size: 220),
              const SizedBox(height: 24),
              Text(s.$1,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 27, fontWeight: FontWeight.w800, letterSpacing: -.5)),
              const SizedBox(height: 10),
              Text(s.$2, textAlign: TextAlign.center, style: TextStyle(color: c.muted, fontSize: 16)),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (var i = 0; i < _steps.length; i++)
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: i == _step ? 26 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: i == _step ? c.primary : c.line,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                ],
              ),
              const Spacer(),
              SaluxButton(
                last ? 'Empezar' : 'Siguiente',
                onPressed: () => last ? context.go('/welcome') : setState(() => _step++),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ================================================================= /welcome

class WelcomeScreen extends ConsumerWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const SizedBox(height: 8),
            Center(
              child: Text('SALUX',
                  style: TextStyle(
                      fontSize: 32, fontWeight: FontWeight.w800, color: c.primary, letterSpacing: -1)),
            ),
            const SizedBox(height: 4),
            Center(child: Text('Tu futuro en salud comienza aquí', style: TextStyle(color: c.muted))),
            const SizedBox(height: 8),
            const Center(child: MascotSticker(height: 220)),
            const SizedBox(height: 8),
            const Center(child: Pill('3 días gratis', tone: Tone.mint, icon: 'gift')),
            const SizedBox(height: 18),
            SaluxButton('Iniciar sesión', onPressed: () => context.push('/login')),
            const SizedBox(height: 10),
            SaluxButton('Regístrate', secondary: true, onPressed: () => context.push('/register')),
            const SizedBox(height: 18),
            Center(child: Text('o continúa con', style: TextStyle(color: c.muted))),
            const SizedBox(height: 12),
            const _SocialRow(),
            const SizedBox(height: 16),
            Center(
              child: InkWell(
                onTap: () => context.push('/legal'),
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Text(
                    'Al continuar aceptas los Términos y la Política de privacidad',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: c.muted, fontSize: 12, decoration: TextDecoration.underline),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SocialRow extends ConsumerWidget {
  const _SocialRow();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    void social(String provider) {
      ref.read(appProvider.notifier).signIn(
            email: 'demo@${provider.toLowerCase()}.salux.app',
            name: 'Usuario demo',
          );
      showToast(context, 'Sesión simulada con $provider');
      context.go('/pick-career');
    }

    return Row(
      children: [
        Expanded(child: SaluxButton('Google', secondary: true, icon: 'globe', onPressed: () => social('Google'))),
        const SizedBox(width: 10),
        Expanded(child: SaluxButton('Apple', secondary: true, icon: 'apple', onPressed: () => social('Apple'))),
      ],
    );
  }
}

// =================================================================== /login

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _email = TextEditingController();
  final _pass = TextEditingController();
  bool _show = false;
  String? _error;

  @override
  void dispose() {
    _email.dispose();
    _pass.dispose();
    super.dispose();
  }

  void _submit() {
    if (!isValidEmail(_email.text)) {
      setState(() => _error = 'Ingresa un correo válido');
      return;
    }
    if (_pass.text.length < 6) {
      setState(() => _error = 'La contraseña debe tener al menos 6 caracteres');
      return;
    }
    ref.read(appProvider.notifier).signIn(email: _email.text.trim());
    if (ref.read(appProvider).mfaEnabled) {
      context.push('/mfa');
    } else {
      context.go('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return SaluxPage(
      title: 'Iniciar sesión',
      children: [
        const Center(child: MascotSticker(height: 150)),
        const SizedBox(height: 8),
        const Text('Bienvenido de nuevo',
            style: TextStyle(fontSize: 27, fontWeight: FontWeight.w800, letterSpacing: -.5)),
        Text('Ingresa para seguir con tu preparación.', style: TextStyle(color: c.muted)),
        const FieldLabel('Correo'),
        SaluxInput(controller: _email, hint: 'tucorreo@ejemplo.com', icon: 'mail', keyboard: TextInputType.emailAddress),
        const FieldLabel('Contraseña'),
        SaluxInput(
          controller: _pass,
          hint: '••••••••',
          icon: 'lock',
          obscure: !_show,
          onSubmitted: (_) => _submit(),
          trailing: IconButton(
            tooltip: _show ? 'Ocultar contraseña' : 'Mostrar contraseña',
            onPressed: () => setState(() => _show = !_show),
            icon: SaluxIcon(_show ? 'eyeoff' : 'eye', size: 20, color: c.muted),
          ),
        ),
        if (_error != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(_error!, style: TextStyle(color: c.error, fontWeight: FontWeight.w600)),
          ),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () => context.push('/forgot-password'),
            child: Text('¿Olvidaste tu contraseña?', style: TextStyle(color: c.primary, fontWeight: FontWeight.w700)),
          ),
        ),
        SaluxButton('Iniciar sesión', onPressed: _submit),
        const SizedBox(height: 16),
        const _SocialRow(),
        const SizedBox(height: 12),
        Center(
          child: TextButton(
            onPressed: () => context.pushReplacement('/register'),
            child: Text('¿No tienes cuenta? Regístrate',
                style: TextStyle(color: c.primary, fontWeight: FontWeight.w700)),
          ),
        ),
      ],
    );
  }
}

// ================================================================ /register

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _pass = TextEditingController();
  bool _terms = false;
  bool _show = false;
  String? _error;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _pass.dispose();
    super.dispose();
  }

  void _submit() {
    if (_name.text.trim().isEmpty) {
      setState(() => _error = 'Ingresa tu nombre');
    } else if (!isValidEmail(_email.text)) {
      setState(() => _error = 'Ingresa un correo válido');
    } else if (passwordStrength(_pass.text) == 0) {
      setState(() => _error = 'Usa una contraseña más fuerte (8+ caracteres, mayúsculas y números)');
    } else {
      ref.read(appProvider.notifier).register(name: _name.text.trim(), email: _email.text.trim());
      context.push('/verify-email');
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final st = passwordStrength(_pass.text);
    final labels = ['Débil', 'Media', 'Fuerte'];
    final colors = [c.error, c.warn, c.ok];
    return SaluxPage(
      title: 'Crear cuenta',
      children: [
        const Text('Empieza gratis',
            style: TextStyle(fontSize: 27, fontWeight: FontWeight.w800, letterSpacing: -.5)),
        Text('3 días de acceso completo, sin tarjeta.', style: TextStyle(color: c.muted)),
        const FieldLabel('Nombre'),
        SaluxInput(controller: _name, hint: 'Tu nombre', icon: 'user'),
        const FieldLabel('Correo'),
        SaluxInput(controller: _email, hint: 'tucorreo@ejemplo.com', icon: 'mail', keyboard: TextInputType.emailAddress),
        const FieldLabel('Contraseña'),
        SaluxInput(
          controller: _pass,
          hint: 'Mínimo 8 caracteres',
          icon: 'lock',
          obscure: !_show,
          onChanged: (_) => setState(() {}),
          trailing: IconButton(
            tooltip: _show ? 'Ocultar contraseña' : 'Mostrar contraseña',
            onPressed: () => setState(() => _show = !_show),
            icon: SaluxIcon(_show ? 'eyeoff' : 'eye', size: 20, color: c.muted),
          ),
        ),
        if (_pass.text.isNotEmpty) ...[
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: SaluxBar((st + 1) / 3, height: 6, gradient: LinearGradient(colors: [colors[st], colors[st]]))),
              const SizedBox(width: 10),
              Text(labels[st], style: TextStyle(color: colors[st], fontWeight: FontWeight.w700)),
            ],
          ),
        ],
        const SizedBox(height: 14),
        Row(
          children: [
            SaluxSwitch(value: _terms, label: 'Aceptar términos', onChanged: (v) => setState(() => _terms = v)),
            Expanded(
              child: InkWell(
                onTap: () => context.push('/legal'),
                child: Text('Acepto los Términos y la Política de privacidad',
                    style: TextStyle(color: c.muted, fontSize: 13)),
              ),
            ),
          ],
        ),
        if (_error != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(_error!, style: TextStyle(color: c.error, fontWeight: FontWeight.w600)),
          ),
        const SizedBox(height: 8),
        SaluxButton('Crear cuenta', onPressed: _terms ? _submit : null),
        const SizedBox(height: 16),
        const _SocialRow(),
      ],
    );
  }
}

// ============================================================ /verify-email

class VerifyEmailScreen extends ConsumerStatefulWidget {
  const VerifyEmailScreen({super.key});

  @override
  ConsumerState<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends ConsumerState<VerifyEmailScreen> {
  final _code = TextEditingController();

  @override
  void dispose() {
    _code.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final email = ref.watch(appProvider).email;
    return SaluxPage(
      title: 'Verifica tu correo',
      bottom: SaluxButton('Verificar',
          onPressed: _code.text.length == 6 ? () => context.go('/pick-career') : null),
      children: [
        const SizedBox(height: 12),
        Center(child: IconTile('mail', size: 72, tone: Tone.violet)),
        const SizedBox(height: 16),
        Text('Enviamos un código de 6 dígitos a $email',
            textAlign: TextAlign.center, style: TextStyle(color: c.muted)),
        const SizedBox(height: 18),
        SaluxInput(
          controller: _code,
          hint: '······',
          center: true,
          maxLength: 6,
          keyboard: TextInputType.number,
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 10),
        Center(
          child: TextButton(
            onPressed: () => showToast(context, 'Código reenviado'),
            child: Text('Reenviar código', style: TextStyle(color: c.primary, fontWeight: FontWeight.w700)),
          ),
        ),
        Center(child: Text('Modo demostración: cualquier código de 6 dígitos funciona.', style: TextStyle(color: c.muted, fontSize: 12))),
      ],
    );
  }
}

// ========================================================== /forgot-password

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _email = TextEditingController();
  bool _sent = false;

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    if (_sent) {
      return SaluxPage(
        title: 'Recuperar contraseña',
        bottom: SaluxButton('Volver a iniciar sesión', onPressed: () => context.go('/login')),
        children: [
          const Center(child: Mascot(MascotMood.cheer, size: 150)),
          const Text('¡Enlace enviado!',
              textAlign: TextAlign.center, style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          Text('Revisa tu correo y sigue las instrucciones.',
              textAlign: TextAlign.center, style: TextStyle(color: c.muted)),
        ],
      );
    }
    return SaluxPage(
      title: 'Recuperar contraseña',
      bottom: SaluxButton('Enviar enlace',
          onPressed: isValidEmail(_email.text) ? () => setState(() => _sent = true) : null),
      children: [
        Text('Te enviaremos un enlace para crear una nueva contraseña.', style: TextStyle(color: c.muted)),
        const FieldLabel('Correo'),
        SaluxInput(
          controller: _email,
          hint: 'tucorreo@ejemplo.com',
          icon: 'mail',
          keyboard: TextInputType.emailAddress,
          onChanged: (_) => setState(() {}),
        ),
      ],
    );
  }
}

// ====================================================================== /mfa

class MfaScreen extends StatefulWidget {
  const MfaScreen({super.key});

  @override
  State<MfaScreen> createState() => _MfaScreenState();
}

class _MfaScreenState extends State<MfaScreen> {
  final _code = TextEditingController();
  bool _trust = false;

  @override
  void dispose() {
    _code.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return SaluxPage(
      title: 'Verificación en dos pasos',
      bottom: SaluxButton('Verificar', onPressed: _code.text.length == 6
          ? () {
              showToast(context, 'Verificación correcta');
              context.go('/home');
            }
          : null),
      children: [
        const SizedBox(height: 8),
        const Center(child: IconTile('shield', size: 72, tone: Tone.violet)),
        const SizedBox(height: 16),
        Text('Ingresa el código de 6 dígitos de tu app autenticadora.',
            textAlign: TextAlign.center, style: TextStyle(color: c.muted)),
        const SizedBox(height: 16),
        SaluxInput(
          controller: _code,
          hint: '······',
          center: true,
          maxLength: 6,
          keyboard: TextInputType.number,
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            SaluxSwitch(value: _trust, label: 'Confiar 30 días', onChanged: (v) => setState(() => _trust = v)),
            const Expanded(child: Text('Confiar en este dispositivo por 30 días')),
          ],
        ),
        Center(
          child: TextButton(
            onPressed: () => showToast(context, 'Ingresa uno de tus códigos de respaldo'),
            child: Text('Usar código de respaldo', style: TextStyle(color: c.primary, fontWeight: FontWeight.w700)),
          ),
        ),
      ],
    );
  }
}

// ============================================================== /mfa-setup

class MfaSetupScreen extends StatefulWidget {
  const MfaSetupScreen({super.key});

  @override
  State<MfaSetupScreen> createState() => _MfaSetupScreenState();
}

class _MfaSetupScreenState extends State<MfaSetupScreen> {
  static const _secret = 'JBSWY3DPEHPK3PXP';
  final _code = TextEditingController();

  @override
  void dispose() {
    _code.dispose();
    super.dispose();
  }

  Widget _step(BuildContext context, int n, String title, Widget body) {
    final c = context.colors;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: SaluxCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(radius: 14, backgroundColor: c.primary, child: Text('$n', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800))),
                const SizedBox(width: 10),
                Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.w800))),
              ],
            ),
            const SizedBox(height: 10),
            body,
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Consumer(
      builder: (context, ref, _) => SaluxPage(
        title: 'Activar MFA',
        bottom: SaluxButton('Activar', onPressed: _code.text.length == 6
            ? () {
                ref.read(appProvider.notifier).update((s) => s.copyWith(mfaEnabled: true));
                context.pushReplacement('/backup-codes');
              }
            : null),
        children: [
          _step(context, 1, 'Instala una app autenticadora',
              Text('Google Authenticator, Authy o similar.', style: TextStyle(color: c.muted))),
          _step(
            context,
            2,
            'Escanea el código QR',
            Column(
              children: [
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.all(10),
                  child: QrImageView(
                    data: 'otpauth://totp/SALUX:demo?secret=$_secret&issuer=SALUX',
                    size: 170,
                  ),
                ),
                const SizedBox(height: 10),
                SelectableText('Clave manual: $_secret', style: const TextStyle(fontWeight: FontWeight.w700)),
              ],
            ),
          ),
          _step(
            context,
            3,
            'Ingresa el código',
            SaluxInput(
              controller: _code,
              hint: '······',
              center: true,
              maxLength: 6,
              keyboard: TextInputType.number,
              onChanged: (_) => setState(() {}),
            ),
          ),
        ],
      ),
    );
  }
}

// ========================================================== /backup-codes

class BackupCodesScreen extends StatefulWidget {
  const BackupCodesScreen({super.key});

  @override
  State<BackupCodesScreen> createState() => _BackupCodesScreenState();
}

class _BackupCodesScreenState extends State<BackupCodesScreen> {
  late final List<String> _codes = _generate();

  static List<String> _generate() {
    final r = Random.secure();
    String part() => List.generate(4, (_) => r.nextInt(10)).join();
    return List.generate(8, (_) => '${part()}-${part()}');
  }

  void _done() {
    showToast(context, 'MFA activada');
    context.go('/security');
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return SaluxPage(
      title: 'Códigos de respaldo',
      onBack: _done,
      bottom: SaluxButton('Ya los guardé', onPressed: _done),
      children: [
        Text('Guárdalos en un lugar seguro. Cada código sirve una sola vez.', style: TextStyle(color: c.muted)),
        const SizedBox(height: 14),
        SaluxCard(
          child: Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              for (final code in _codes)
                SizedBox(
                  width: 140,
                  child: Text(code, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16, letterSpacing: 1.2)),
                ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: SaluxButton('Copiar', secondary: true, icon: 'copy', onPressed: () async {
                await Clipboard.setData(ClipboardData(text: _codes.join('\n')));
                if (context.mounted) showToast(context, 'Códigos copiados');
              }),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: SaluxButton('Guardar', secondary: true, icon: 'download',
                  onPressed: () => showToast(context, 'Códigos guardados')),
            ),
          ],
        ),
      ],
    );
  }
}

// ============================================================== /pick-career

class PickCareerScreen extends ConsumerWidget {
  const PickCareerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final app = ref.watch(appProvider);
    final c = context.colors;
    return SaluxPage(
      title: 'Tu carrera',
      showBack: false,
      bottom: SaluxButton('Continuar', onPressed: () => context.push('/pick-goal')),
      children: [
        Text('Paso 1 de 2', style: TextStyle(color: c.primary, fontWeight: FontWeight.w700)),
        const SizedBox(height: 4),
        const Text('¿Qué carrera estudias?',
            style: TextStyle(fontSize: 27, fontWeight: FontWeight.w800, letterSpacing: -.5)),
        const SizedBox(height: 16),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.25,
          children: [
            for (final cr in careers)
              SaluxCard(
                border: app.career == cr.$1 ? c.primary : null,
                onTap: () => ref.read(appProvider.notifier).update((s) => s.copyWith(career: cr.$1)),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconTile(cr.$2, tone: cr.$3, size: 44),
                    const SizedBox(height: 8),
                    Text(cr.$1, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
          ],
        ),
      ],
    );
  }
}

// =============================================================== /pick-goal

class PickGoalScreen extends ConsumerWidget {
  const PickGoalScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final app = ref.watch(appProvider);
    final ctl = ref.read(appProvider.notifier);
    final c = context.colors;
    return SaluxPage(
      title: 'Tu objetivo',
      bottom: SaluxButton('Continuar', onPressed: () => context.push('/trial-start')),
      children: [
        Text('Paso 2 de 2', style: TextStyle(color: c.primary, fontWeight: FontWeight.w700)),
        const SizedBox(height: 4),
        const Text('¿Qué examen rendirás?',
            style: TextStyle(fontSize: 27, fontWeight: FontWeight.w800, letterSpacing: -.5)),
        const SizedBox(height: 12),
        for (final e in goalExams)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: SaluxCard(
              border: app.goalExam == e.$1 ? c.primary : null,
              onTap: () => ctl.update((s) => s.copyWith(goalExam: e.$1)),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(e.$1, style: const TextStyle(fontWeight: FontWeight.w800)),
                        Text(e.$2, style: TextStyle(color: c.muted, fontSize: 12)),
                      ],
                    ),
                  ),
                  Icon(app.goalExam == e.$1 ? Icons.radio_button_checked : Icons.radio_button_off,
                      color: app.goalExam == e.$1 ? c.primary : c.muted),
                ],
              ),
            ),
          ),
        const FieldLabel('Fecha del examen'),
        SaluxCard(
          onTap: () async {
            final d = await showDatePicker(
              context: context,
              initialDate: app.examDate ?? DateTime.now().add(const Duration(days: 43)),
              firstDate: DateTime.now(),
              lastDate: DateTime.now().add(const Duration(days: 730)),
            );
            if (d != null) ctl.update((s) => s.copyWith(examDate: d));
          },
          child: Row(
            children: [
              SaluxIcon('calendar', color: c.primary),
              const SizedBox(width: 10),
              Text(app.examDate == null ? 'Elegir fecha' : longDate(app.examDate!),
                  style: const TextStyle(fontWeight: FontWeight.w700)),
            ],
          ),
        ),
        const FieldLabel('Meta diaria (preguntas)'),
        Row(
          children: [
            for (final n in [10, 20, 30]) ...[
              SaluxChip('$n', selected: app.dailyGoal == n, onTap: () => ctl.update((s) => s.copyWith(dailyGoal: n))),
              const SizedBox(width: 10),
            ],
          ],
        ),
        const FieldLabel('Hora del recordatorio'),
        SaluxCard(
          onTap: () async {
            final parts = app.reminder.split(':');
            final t = await showTimePicker(
              context: context,
              initialTime: TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1])),
            );
            if (t != null) {
              ctl.update((s) => s.copyWith(
                  reminder: '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}'));
            }
          },
          child: Row(
            children: [
              SaluxIcon('bell', color: c.primary),
              const SizedBox(width: 10),
              Text(app.reminder, style: const TextStyle(fontWeight: FontWeight.w700)),
            ],
          ),
        ),
      ],
    );
  }
}

// ============================================================= /trial-start

class TrialStartScreen extends StatelessWidget {
  const TrialStartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    const benefits = [
      ('Simulacros ilimitados', 'file', Tone.violet),
      ('Respuestas explicadas', 'bulb', Tone.orange),
      ('Seguimiento de tu progreso', 'chart', Tone.mint),
    ];
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const Spacer(),
              const Mascot(MascotMood.cheer, size: 180),
              const SizedBox(height: 12),
              const Text('¡Tienes 3 días gratis!',
                  style: TextStyle(fontSize: 27, fontWeight: FontWeight.w800, letterSpacing: -.5)),
              const SizedBox(height: 18),
              for (final b in benefits)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: SaluxCard(
                    child: Row(
                      children: [
                        IconTile(b.$2, tone: b.$3, size: 40),
                        const SizedBox(width: 12),
                        Text(b.$1, style: const TextStyle(fontWeight: FontWeight.w700)),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 4),
              Text('No pedimos tarjeta. Al terminar la prueba podrás elegir un plan.',
                  textAlign: TextAlign.center, style: TextStyle(color: c.muted, fontSize: 12)),
              const Spacer(),
              SaluxButton('Comenzar a estudiar', onPressed: () => context.go('/home')),
            ],
          ),
        ),
      ),
    );
  }
}
