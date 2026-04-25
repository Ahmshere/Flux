import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'core/theme/app_theme.dart';
import 'features/currency/data/models/rates_model.dart';
import 'features/currency/presentation/screens/splash_screen.dart';
import 'features/currency/presentation/widgets/rate_info_bar.dart';

final themeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.dark);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Статус-бар прозрачный
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));

  // Только портретная ориентация
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Hive
  await Hive.initFlutter();
  Hive.registerAdapter(RatesModelAdapter());

  runApp(const ProviderScope(child: KursoApp()));
}

class KursoApp extends ConsumerWidget {
  const KursoApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp(
      title: 'Flux',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: themeMode,
      // Стартовый экран — splash
      home: const SplashScreen(),
    );
  }
}
