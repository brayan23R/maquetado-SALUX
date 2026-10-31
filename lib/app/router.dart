import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/presentation/auth_screens.dart';
import '../features/home/presentation/home_screen.dart';
import '../features/library/presentation/library_screens.dart';
import '../features/modules/presentation/modules_screens.dart';
import '../features/profile/presentation/profile_screens.dart';
import '../features/progress/presentation/progress_screens.dart';
import '../features/quiz/presentation/quiz_screens.dart';
import '../features/session/presentation/app_controller.dart';
import '../features/subscription/presentation/subscription_screens.dart';
import '../features/system/presentation/system_screens.dart';
import 'shell.dart';

/// Rutas accesibles sin sesión.
const _publicRoutes = {
  '/splash', '/onboarding', '/welcome', '/login', '/register', '/verify-email',
  '/forgot-password', '/mfa', '/legal', '/help', '/about', '/offline', '/error',
};

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/splash',
    errorBuilder: (_, state) => ErrorScreen(message: state.error?.toString()),
    redirect: (context, state) {
      final app = ref.read(appProvider);
      final path = state.uri.path;
      if (path == '/splash') return app.loggedIn ? '/home' : null;
      if (!app.loggedIn && !_publicRoutes.contains(path)) return '/welcome';
      // Sin prueba ni suscripción, el contenido premium lleva al paywall.
      if (!app.hasAccess && (path.startsWith('/exam/') || path.startsWith('/topic/'))) {
        return '/paywall';
      }
      return null;
    },
    routes: [
      GoRoute(path: '/splash', builder: (_, _) => const SplashScreen()),
      GoRoute(path: '/onboarding', builder: (_, _) => const OnboardingScreen()),
      GoRoute(path: '/welcome', builder: (_, _) => const WelcomeScreen()),
      GoRoute(path: '/login', builder: (_, _) => const LoginScreen()),
      GoRoute(path: '/register', builder: (_, _) => const RegisterScreen()),
      GoRoute(path: '/verify-email', builder: (_, _) => const VerifyEmailScreen()),
      GoRoute(path: '/forgot-password', builder: (_, _) => const ForgotPasswordScreen()),
      GoRoute(path: '/mfa', builder: (_, _) => const MfaScreen()),
      GoRoute(path: '/mfa-setup', builder: (_, _) => const MfaSetupScreen()),
      GoRoute(path: '/backup-codes', builder: (_, _) => const BackupCodesScreen()),
      GoRoute(path: '/pick-career', builder: (_, _) => const PickCareerScreen()),
      GoRoute(path: '/pick-goal', builder: (_, _) => const PickGoalScreen()),
      GoRoute(path: '/trial-start', builder: (_, _) => const TrialStartScreen()),

      // Pestañas (con barra inferior)
      ShellRoute(
        builder: (_, _, child) => MainShell(child: child),
        routes: [
          GoRoute(path: '/home', builder: (_, _) => const HomeScreen()),
          GoRoute(path: '/search', builder: (_, _) => const SearchScreen()),
          GoRoute(path: '/modules', builder: (_, _) => const ModulesScreen()),
          GoRoute(path: '/exam/:id', builder: (_, s) => ExamScreen(id: s.pathParameters['id']!)),
          GoRoute(path: '/topic/:id', builder: (_, s) => TopicScreen(id: s.pathParameters['id']!)),
          GoRoute(path: '/simulations', builder: (_, _) => const SimulationsScreen()),
          GoRoute(path: '/progress', builder: (_, _) => const ProgressScreen()),
          GoRoute(path: '/streak', builder: (_, _) => const StreakScreen()),
          GoRoute(path: '/achievements', builder: (_, _) => const AchievementsScreen()),
          GoRoute(path: '/profile', builder: (_, _) => const ProfileScreen()),
        ],
      ),

      GoRoute(path: '/quiz-setup', builder: (_, _) => const QuizSetupScreen()),
      GoRoute(path: '/quiz', builder: (_, _) => const QuizScreen()),
      GoRoute(path: '/result', builder: (_, s) => ResultScreen(id: s.uri.queryParameters['id'])),
      GoRoute(path: '/review', builder: (_, s) => ReviewScreen(id: s.uri.queryParameters['id'])),
      GoRoute(path: '/history', builder: (_, _) => const HistoryScreen()),

      GoRoute(path: '/notes', builder: (_, _) => const NotesScreen()),
      GoRoute(path: '/favorites', builder: (_, _) => const FavoritesScreen()),
      GoRoute(path: '/downloads', builder: (_, _) => const DownloadsScreen()),
      GoRoute(path: '/settings', builder: (_, _) => const SettingsScreen()),
      GoRoute(path: '/notification-settings', builder: (_, _) => const NotificationSettingsScreen()),
      GoRoute(path: '/security', builder: (_, _) => const SecurityScreen()),
      GoRoute(path: '/notifications', builder: (_, _) => const NotificationsScreen()),
      GoRoute(path: '/edit-profile', builder: (_, _) => const EditProfileScreen()),
      GoRoute(path: '/change-password', builder: (_, _) => const ChangePasswordScreen()),
      GoRoute(path: '/language', builder: (_, _) => const LanguageScreen()),
      GoRoute(path: '/legal', builder: (_, _) => const LegalScreen()),
      GoRoute(path: '/about', builder: (_, _) => const AboutScreen()),

      GoRoute(path: '/docs', builder: (_, _) => const DocsScreen()),
      GoRoute(path: '/doc/:id', builder: (_, s) => DocReaderScreen(id: s.pathParameters['id']!)),
      GoRoute(path: '/ranking', builder: (_, _) => const RankingScreen()),
      GoRoute(path: '/invite', builder: (_, _) => const InviteScreen()),
      GoRoute(path: '/study-plan', builder: (_, _) => const StudyPlanScreen()),

      GoRoute(path: '/plans', builder: (_, _) => const PlansScreen()),
      GoRoute(path: '/checkout', builder: (_, _) => const CheckoutScreen()),
      GoRoute(path: '/pay-qr', builder: (_, _) => const PayQrScreen()),
      GoRoute(path: '/pay-card', builder: (_, _) => const PayCardScreen()),
      GoRoute(path: '/pay-processing', builder: (_, _) => const PayProcessingScreen()),
      GoRoute(path: '/pay-success', builder: (_, _) => const PaySuccessScreen()),
      GoRoute(path: '/pay-failed', builder: (_, _) => const PayFailedScreen()),
      GoRoute(path: '/subscription', builder: (_, _) => const SubscriptionScreen()),
      GoRoute(path: '/paywall', builder: (_, _) => const PaywallScreen()),

      GoRoute(path: '/help', builder: (_, _) => const HelpScreen()),
      GoRoute(path: '/offline', builder: (_, _) => const OfflineScreen()),
      GoRoute(path: '/error', builder: (_, _) => const ErrorScreen()),
    ],
  );
});
