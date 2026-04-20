import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'config/env.dart';
import 'routing/app_router.dart';
import 'services/supabase_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  debugPrint('[twothumbs] main() start');
  debugPrint('[twothumbs] supabaseUrl set=${Env.supabaseUrl.isNotEmpty}');
  debugPrint('[twothumbs] supabaseAnonKey set=${Env.supabaseAnonKey.isNotEmpty}');

  try {
    await SupabaseService.init();
    debugPrint('[twothumbs] Supabase init OK');
    runApp(const ProviderScope(child: TwoThumbsApp()));
  } catch (e, st) {
    debugPrint('[twothumbs] STARTUP ERROR: $e');
    debugPrintStack(stackTrace: st);
    runApp(_StartupErrorApp(error: '$e'));
  }
}

class TwoThumbsApp extends ConsumerWidget {
  const TwoThumbsApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    return MaterialApp.router(
      title: 'TwoThumbs',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.red),
        useMaterial3: true,
      ),
      routerConfig: router,
    );
  }
}

class _StartupErrorApp extends StatelessWidget {
  final String error;
  const _StartupErrorApp({required this.error});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                const Text('Startup failed',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
                const SizedBox(height: 12),
                Text(error,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontFamily: 'monospace')),
                const SizedBox(height: 24),
                const Text(
                  '1. Make sure env.json exists in project root\n'
                  '2. Run: flutter run --dart-define-from-file=env.json\n'
                  '3. Check SUPABASE_URL and SUPABASE_ANON_KEY values',
                  textAlign: TextAlign.left,
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
