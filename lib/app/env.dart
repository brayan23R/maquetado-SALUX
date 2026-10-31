enum AppMode { mock, supabase }

/// Variables de entorno de compilación (`--dart-define`).
class Env {
  const Env._();

  static const _mode = String.fromEnvironment('APP_MODE', defaultValue: 'mock');
  static const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  static const supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');

  static AppMode get appMode =>
      _mode == 'supabase' ? AppMode.supabase : AppMode.mock;
}
