import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/theme/app_theme.dart';
import 'home_screen.dart';

const _onboardingKey = 'onboarding_done';

/// Проверяем нужно ли показывать онбординг
Future<bool> shouldShowOnboarding() async {
  final prefs = await SharedPreferences.getInstance();
  return !(prefs.getBool(_onboardingKey) ?? false);
}

Future<void> markOnboardingDone() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool(_onboardingKey, true);
}

// ── Данные экранов ────────────────────────────────────────────────────────────
class _OnboardPage {
  final String emoji;
  final String title;
  final String subtitle;
  final String description;
  final Color accent;
  final List<String> bullets;

  const _OnboardPage({
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.accent,
    required this.bullets,
  });
}

const _pages = [
  _OnboardPage(
    emoji: '🧠',
    title: 'Smart Input',
    subtitle: 'Just type naturally',
    description:
    'No need to tap dropdowns or press buttons. '
        'Just type what you mean and Flux understands instantly.',
    accent: Color(0xFF7C6AF7),
    bullets: [
      '"100 usd to eur"',
      '"50 gbp in ils"',
      '"1 btc в доллары"',
    ],
  ),
  _OnboardPage(
    emoji: '📊',
    title: 'Live Analytics',
    subtitle: 'Know when to exchange',
    description:
    'Track currency trends over 7, 14 or 30 days. '
        'See volatility and get smart insights on the best time to exchange.',
    accent: Color(0xFF34D399),
    bullets: [
      '7 / 14 / 30 day charts',
      'Trend & volatility',
      'Best time to exchange',
    ],
  ),
  _OnboardPage(
    emoji: '🔲',
    title: 'Home Screen Widget',
    subtitle: 'Rates always visible',
    description:
    'Add the Flux widget to your home screen and see '
        'live rates without even opening the app.',
    accent: Color(0xFFFBBF24),
    bullets: [
      'Long press home screen',
      'Tap "Widgets"',
      'Find Flux → drag to screen',
    ],
  ),
  _OnboardPage(
    emoji: '⭐',
    title: 'Flux PRO',
    subtitle: 'Unlock everything',
    description:
    'Get the full Flux experience with all currencies, '
        'extended charts, favorites and offline mode.',
    accent: Color(0xFFA594FF),
    bullets: [
      'All 13 currencies + crypto',
      'Favorites & offline mode',
      'Full analytics & insights',
    ],
  ),
];

// ── Экран онбординга ──────────────────────────────────────────────────────────
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _pageController = PageController();
  int _current = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _next() {
    HapticFeedback.selectionClick();
    if (_current < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    } else {
      _finish();
    }
  }

  void _skip() {
    HapticFeedback.lightImpact();
    _finish();
  }

  Future<void> _finish() async {
    await markOnboardingDone();
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const HomeScreen(),
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLast = _current == _pages.length - 1;

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0F),
      body: SafeArea(
        child: Column(children: [
          // ── Skip кнопка ───────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Row(children: [
              const Spacer(),
              if (!isLast)
                TextButton(
                  onPressed: _skip,
                  child: Text('Skip',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.35),
                        fontSize: 14,
                      )),
                ),
            ]),
          ),

          // ── Страницы ──────────────────────────────────────────────────────
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (i) => setState(() => _current = i),
              itemCount: _pages.length,
              itemBuilder: (_, i) => _OnboardPageView(page: _pages[i]),
            ),
          ),

          // ── Индикаторы + кнопка ───────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
            child: Column(children: [
              // Точки
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(_pages.length, (i) {
                  final active = i == _current;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: active ? 24 : 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: active
                          ? _pages[_current].accent
                          : Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  );
                }),
              ),
              const Gap(24),

              // Кнопка
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: _next,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _pages[_current].accent,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  child: Text(
                    isLast ? 'Get Started' : 'Next',
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                ),
              ),

              // На последнем экране — кнопка "Maybe later"
              if (isLast) ...[
                const Gap(12),
                TextButton(
                  onPressed: _finish,
                  child: Text('Maybe later',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.35),
                        fontSize: 13,
                      )),
                ),
              ],
            ]),
          ),
        ]),
      ),
    );
  }
}

// ── Содержимое одной страницы ─────────────────────────────────────────────────
class _OnboardPageView extends StatelessWidget {
  final _OnboardPage page;
  const _OnboardPageView({required this.page});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Иконка с подсветкой
          Container(
            width: 100, height: 100,
            decoration: BoxDecoration(
              color: page.accent.withOpacity(0.12),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: page.accent.withOpacity(0.25),
                  blurRadius: 40,
                  spreadRadius: 10,
                ),
              ],
            ),
            child: Center(
              child: Text(page.emoji,
                  style: const TextStyle(fontSize: 48)),
            ),
          )
              .animate()
              .scale(duration: 500.ms, curve: Curves.easeOutBack)
              .fadeIn(duration: 400.ms),

          const Gap(32),

          // Заголовок
          Text(page.title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: -0.5,
            ),
          )
              .animate()
              .fadeIn(delay: 150.ms, duration: 400.ms)
              .slideY(begin: 0.2, end: 0, delay: 150.ms),

          const Gap(8),

          // Подзаголовок
          Text(page.subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: page.accent,
              fontWeight: FontWeight.w500,
            ),
          )
              .animate()
              .fadeIn(delay: 200.ms, duration: 400.ms),

          const Gap(16),

          // Описание
          Text(page.description,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.55),
              height: 1.6,
            ),
          )
              .animate()
              .fadeIn(delay: 250.ms, duration: 400.ms),

          const Gap(28),

          // Буллеты
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: page.accent.withOpacity(0.08),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                  color: page.accent.withOpacity(0.2)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: page.bullets.asMap().entries.map((e) {
                return Padding(
                  padding: EdgeInsets.only(
                      bottom: e.key < page.bullets.length - 1 ? 10 : 0),
                  child: Row(children: [
                    Container(
                      width: 6, height: 6,
                      decoration: BoxDecoration(
                        color: page.accent,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const Gap(10),
                    Text(e.value,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.8),
                          fontWeight: FontWeight.w500,
                          fontFamily: e.value.startsWith('"')
                              ? 'monospace' : null,
                        )),
                  ]),
                );
              }).toList(),
            ),
          )
              .animate()
              .fadeIn(delay: 350.ms, duration: 400.ms)
              .slideY(begin: 0.15, end: 0, delay: 350.ms),
        ],
      ),
    );
  }
}