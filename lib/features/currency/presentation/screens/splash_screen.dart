import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

import '../../../../core/theme/app_theme.dart';
import 'home_screen.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigate();
  }

  Future<void> _navigate() async {
    // Ждём пока анимация отыграет
    await Future.delayed(const Duration(milliseconds: 1800));
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const HomeScreen(),
        transitionsBuilder: (_, anim, __, child) => FadeTransition(
          opacity: anim,
          child: child,
        ),
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0F),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Иконка
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppTheme.accent, AppTheme.accentLight],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.accent.withOpacity(0.4),
                    blurRadius: 32,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Center(
                child: Text('💱', style: TextStyle(fontSize: 48)),
              ),
            )
                .animate()
                .scale(
                  duration: 500.ms,
                  curve: Curves.easeOutBack,
                  begin: const Offset(0.5, 0.5),
                  end: const Offset(1, 1),
                )
                .fadeIn(duration: 400.ms),

            const Gap(24),

            // Название
            const Text(
              'Flux',
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                letterSpacing: -1,
              ),
            )
                .animate()
                .fadeIn(delay: 300.ms, duration: 400.ms)
                .slideY(
                  begin: 0.3,
                  end: 0,
                  delay: 300.ms,
                  duration: 400.ms,
                  curve: Curves.easeOut,
                ),

            const Gap(8),

            // Подзаголовок
            Text(
              'Smart Currency Converter',
              style: TextStyle(
                fontSize: 14,
                color: Colors.white.withOpacity(0.45),
                fontWeight: FontWeight.w400,
                letterSpacing: 0.2,
              ),
            )
                .animate()
                .fadeIn(delay: 500.ms, duration: 400.ms),

            const Gap(60),

            // Индикатор загрузки
            SizedBox(
              width: 32,
              height: 2,
              child: LinearProgressIndicator(
                backgroundColor: Colors.white.withOpacity(0.1),
                valueColor: const AlwaysStoppedAnimation<Color>(
                    AppTheme.accent),
                borderRadius: BorderRadius.circular(1),
              ),
            )
                .animate()
                .fadeIn(delay: 700.ms, duration: 300.ms),
          ],
        ),
      ),
    );
  }
}
