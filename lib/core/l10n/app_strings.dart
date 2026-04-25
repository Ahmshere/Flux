enum AppLang { en, de, ru }

class S {
  final AppLang lang;
  const S(this.lang);

  String get appName => 'Flux';

  // ── Tabs ──────────────────────────────────────────────────────────────────
  String get tabConverter => switch (lang) {
    AppLang.en => 'Converter',
    AppLang.de => 'Rechner',
    AppLang.ru => 'Конвертер',
  };
  String get tabAnalytics => switch (lang) {
    AppLang.en => 'Analytics',
    AppLang.de => 'Analyse',
    AppLang.ru => 'Аналитика',
  };
  String get tabFavorites => switch (lang) {
    AppLang.en => 'Favorites',
    AppLang.de => 'Favoriten',
    AppLang.ru => 'Избранное',
  };

  // ── Smart input ───────────────────────────────────────────────────────────
  String get smartInput => switch (lang) {
    AppLang.en => '🧠  Smart input',
    AppLang.de => '🧠  Schnelleingabe',
    AppLang.ru => '🧠  Умный ввод',
  };
  String get smartInputHint => switch (lang) {
    AppLang.en => 'e.g. "100 usd to eur"',
    AppLang.de => 'z.B. "100 usd in eur"',
    AppLang.ru => 'например: "100 usd в eur"',
  };
  String get recognized => switch (lang) {
    AppLang.en => '✓ recognized',
    AppLang.de => '✓ erkannt',
    AppLang.ru => '✓ распознано',
  };

  // ── Rate bar ──────────────────────────────────────────────────────────────
  String get live => switch (lang) {
    AppLang.en => 'Live',
    AppLang.de => 'Aktuell',
    AppLang.ru => 'Онлайн',
  };
  String updatedAt(String time) => switch (lang) {
    AppLang.en => 'Updated $time',
    AppLang.de => 'Aktualisiert $time',
    AppLang.ru => 'Обновлено $time',
  };
  String get tapToCopy => switch (lang) {
    AppLang.en => 'tap to copy',
    AppLang.de => 'tippen zum Kopieren',
    AppLang.ru => 'нажмите чтобы скопировать',
  };
  String get copiedToClipboard => switch (lang) {
    AppLang.en => 'Copied!',
    AppLang.de => 'Kopiert!',
    AppLang.ru => 'Скопировано!',
  };

  // ── Chart ─────────────────────────────────────────────────────────────────
  String get days7 => switch (lang) {
    AppLang.en => '7 days',
    AppLang.de => '7 Tage',
    AppLang.ru => '7 дней',
  };
  String get statMin => switch (lang) {
    AppLang.en => 'Min',
    AppLang.de => 'Min',
    AppLang.ru => 'Мин',
  };
  String get statMax => switch (lang) {
    AppLang.en => 'Max',
    AppLang.de => 'Max',
    AppLang.ru => 'Макс',
  };
  String get statAvg => switch (lang) {
    AppLang.en => 'Avg',
    AppLang.de => 'Ø',
    AppLang.ru => 'Средн.',
  };
  String get stat7d => switch (lang) {
    AppLang.en => '7d',
    AppLang.de => '7T',
    AppLang.ru => '7д',
  };
  String get chartLoading => switch (lang) {
    AppLang.en => 'Loading chart...',
    AppLang.de => 'Lade Diagramm...',
    AppLang.ru => 'Загрузка графика...',
  };

  // ── Loading / Error ───────────────────────────────────────────────────────
  String get loading => switch (lang) {
    AppLang.en => 'Loading rates...',
    AppLang.de => 'Kurse werden geladen...',
    AppLang.ru => 'Загружаем курсы...',
  };
  String get offlineCache => switch (lang) {
    AppLang.en => 'Showing cached data',
    AppLang.de => 'Zeige zwischengespeicherte Daten',
    AppLang.ru => 'Показаны кешированные данные',
  };
  String get retry => switch (lang) {
    AppLang.en => 'Retry',
    AppLang.de => 'Erneut versuchen',
    AppLang.ru => 'Повторить',
  };

  // ── Settings ──────────────────────────────────────────────────────────────
  String get settings => switch (lang) {
    AppLang.en => 'Settings',
    AppLang.de => 'Einstellungen',
    AppLang.ru => 'Настройки',
  };
  String get theme => switch (lang) {
    AppLang.en => 'Theme',
    AppLang.de => 'Design',
    AppLang.ru => 'Тема',
  };
  String get themeDark => switch (lang) {
    AppLang.en => 'Dark',
    AppLang.de => 'Dunkel',
    AppLang.ru => 'Тёмная',
  };
  String get themeLight => switch (lang) {
    AppLang.en => 'Light',
    AppLang.de => 'Hell',
    AppLang.ru => 'Светлая',
  };
  String get language => switch (lang) {
    AppLang.en => 'Language',
    AppLang.de => 'Sprache',
    AppLang.ru => 'Язык',
  };

  // ── Favorites ─────────────────────────────────────────────────────────────
  String get noFavorites => switch (lang) {
    AppLang.en => 'No favorites yet',
    AppLang.de => 'Noch keine Favoriten',
    AppLang.ru => 'Нет избранных пар',
  };
  String get noFavoritesHint => switch (lang) {
    AppLang.en => 'Go to Converter and save your favorite pairs',
    AppLang.de => 'Gehe zum Rechner und speichere deine Lieblingspaare',
    AppLang.ru => 'Перейдите в конвертер и сохраните пары',
  };
  String get savePair => switch (lang) {
    AppLang.en => 'Save pair',
    AppLang.de => 'Paar speichern',
    AppLang.ru => 'Сохранить пару',
  };
  String get saved => switch (lang) {
    AppLang.en => 'Saved',
    AppLang.de => 'Gespeichert',
    AppLang.ru => 'Сохранено',
  };

  // ── Analytics ─────────────────────────────────────────────────────────────
  String get insights => switch (lang) {
    AppLang.en => 'Insights',
    AppLang.de => 'Einblicke',
    AppLang.ru => 'Выводы',
  };
  String get trend => switch (lang) {
    AppLang.en => 'Trend',
    AppLang.de => 'Trend',
    AppLang.ru => 'Тренд',
  };
  String get volatility => switch (lang) {
    AppLang.en => 'Volatility',
    AppLang.de => 'Volatilität',
    AppLang.ru => 'Волатильность',
  };
  String get bestTime => switch (lang) {
    AppLang.en => 'Best time to exchange',
    AppLang.de => 'Bester Zeitpunkt',
    AppLang.ru => 'Лучшее время для обмена',
  };
  String get exchangeNow => switch (lang) {
    AppLang.en => 'Exchange now',
    AppLang.de => 'Jetzt tauschen',
    AppLang.ru => 'Менять сейчас',
  };
  String get considerWaiting => switch (lang) {
    AppLang.en => 'Consider waiting',
    AppLang.de => 'Besser warten',
    AppLang.ru => 'Лучше подождать',
  };
}