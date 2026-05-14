/// Supabase project configuration.
/// Keep the anon key here — it is safe to expose in client apps.
/// Never put the service_role key in Flutter code.
class SupabaseConfig {
  SupabaseConfig._();

  static const String projectUrl = 'https://wadscjqpqidtmxnjmxea.supabase.co';
  static const String anonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9'
      '.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6IndhZHNjanFwcWlkdG14bmpteGVhIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Nzg2NTg4ODgsImV4cCI6MjA5NDIzNDg4OH0'
      '.L71cuL7Qbr4P8YzFXzsbzMrOM0d-3P7IQ3_g8VblIf4';
}
