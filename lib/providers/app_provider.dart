import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import '../services/database_service.dart';
import '../services/semantic_search_service.dart';
// import '../services/memorization_service.dart';
// import '../services/audio_recitation_service.dart';
// import '../services/challenge_service.dart';
import '../models/quran_models.dart';

final themeMap = {
  'system': ThemeMode.system,
  'dark': ThemeMode.dark,
  'light': ThemeMode.light,
};

final localeMap = {
  'ar': const Locale('ar', ''),
  'en': const Locale('en', ''),
};

enum Cache {
  theme,
  locale,
  firstOpen,
  fontSize,
  lastReadPosition,
  khatmProgress,
  prayerNotifications,
}

class AppProvider extends ChangeNotifier {
  static AppProvider s(BuildContext context, [bool listen = false]) =>
      Provider.of<AppProvider>(context, listen: false);

  var themeMode = ThemeMode.light;
  var locale = const Locale('ar', '');
  var fontSize = 16.0;
  var fontFamily = 'Amiri';
  var key = const Key('app');
  var firstOpen = false;
  var prayerNotifications = true;
  late Box<dynamic> _cache;
  bool get isDark => themeMode == ThemeMode.dark;
  bool get isArabic => locale.languageCode == 'ar';
  
  ThemeData get themeData {
    if (isDark) {
      return ThemeData.dark().copyWith(
        primaryColor: Color(0xFF1B4332),
        colorScheme: ColorScheme.dark(
          primary: Color(0xFF1B4332),
          secondary: Color(0xFF2D6A4F),
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: Color(0xFF1B4332),
          foregroundColor: Colors.white,
        ),
      );
    } else {
      return ThemeData.light().copyWith(
        primaryColor: Color(0xFF1B4332),
        colorScheme: ColorScheme.light(
          primary: Color(0xFF1B4332),
          secondary: Color(0xFF2D6A4F),
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: Color(0xFF1B4332),
          foregroundColor: Colors.white,
        ),
      );
    }
  }
  
  // New properties for enhanced functionality
  bool _isInitialized = false;
  int _currentIndex = 0;
  bool _isFocusMode = false;
  DateTime? _sessionStartTime;
  int? _currentSurah;
  int? _currentAyah;
  Map<String, dynamic>? _cachedStats;
  DateTime? _lastStatsUpdate;
  
  bool get isInitialized => _isInitialized;
  int get currentIndex => _currentIndex;
  bool get isFocusMode => _isFocusMode;

  AppProvider() {
    _init();
  }

  void _init() async {
    await Hive.openBox('app');
    _cache = Hive.box('app');

    final cachedTheme = _cache.get(Cache.theme.toString());
    themeMode = cachedTheme == null ? themeMode : themeMap[cachedTheme]!;

    final cachedLocale = _cache.get(Cache.locale.toString());
    locale = cachedLocale == null ? locale : localeMap[cachedLocale]!;

    final cachedFontSize = _cache.get(Cache.fontSize.toString());
    fontSize = cachedFontSize ?? fontSize;

    final cachedFontFamily = _cache.get('fontFamily');
    fontFamily = cachedFontFamily ?? fontFamily;

    final cachedNotifications = _cache.get(Cache.prayerNotifications.toString());
    prayerNotifications = cachedNotifications ?? prayerNotifications;

    final hasOpened = _cache.get(Cache.firstOpen.toString());
    firstOpen = hasOpened == null;
    
    // Initialize new services
    await _initializeServices();
    
    notifyListeners();
  }
  
  Future<void> _initializeServices() async {
    try {
      await DatabaseService.instance.initialize();
      SemanticSearchService.instance.initialize();
      // await AudioRecitationService.instance.initialize();
      _isInitialized = true;
    } catch (e) {
      print('Error initializing services: $e');
      // Even if there's an error, mark as initialized to prevent infinite loading
      _isInitialized = true;
    }
  }

  void setTheme(ThemeMode newTheme) {
    if (themeMode == newTheme) return;
    themeMode = newTheme;
    notifyListeners();
    _cache.put(
      Cache.theme.toString(),
      newTheme.toString().split('.').last,
    );
  }

  void setLocale(Locale newLocale) {
    if (locale == newLocale) return;
    locale = newLocale;
    notifyListeners();
    _cache.put(
      Cache.locale.toString(),
      newLocale.languageCode,
    );
  }

  void setFontSize(double newSize) {
    if (fontSize == newSize) return;
    fontSize = newSize;
    notifyListeners();
    _cache.put(Cache.fontSize.toString(), newSize);
  }

  void setFontFamily(String newFontFamily) {
    if (fontFamily == newFontFamily) return;
    fontFamily = newFontFamily;
    _cache.put('fontFamily', fontFamily);
    notifyListeners();
  }

  void setPrayerNotifications(bool enabled) {
    if (prayerNotifications == enabled) return;
    prayerNotifications = enabled;
    notifyListeners();
    _cache.put(Cache.prayerNotifications.toString(), enabled);
  }

  void setLastReadPosition(int chapterNumber, int verseNumber) {
    final position = {'chapter': chapterNumber, 'verse': verseNumber};
    _cache.put(Cache.lastReadPosition.toString(), position);
  }

  Map<String, int>? getLastReadPosition() {
    final position = _cache.get(Cache.lastReadPosition.toString());
    if (position == null) return null;
    return {
      'chapter': position['chapter'],
      'verse': position['verse'],
    };
  }

  void updateKhatmProgress(int chapterNumber) {
    final progress = _cache.get(Cache.khatmProgress.toString()) ?? <int>[];
    if (!progress.contains(chapterNumber)) {
      progress.add(chapterNumber);
      _cache.put(Cache.khatmProgress.toString(), progress);
      notifyListeners();
    }
  }

  List<int> getKhatmProgress() {
    return _cache.get(Cache.khatmProgress.toString()) ?? <int>[];
  }

  void resetKhatmProgress() {
    _cache.put(Cache.khatmProgress.toString(), <int>[]);
    notifyListeners();
  }

  void setFirstOpen() {
    firstOpen = true;
    notifyListeners();
    _cache.put(Cache.firstOpen.toString(), 'true');
  }

  void reset() async {
    firstOpen = true;
    themeMode = ThemeMode.system;
    locale = const Locale('ar', '');
    fontSize = 16.0;
    prayerNotifications = true;
    await _cache.clear();
    key = Key(DateTime.now().toString());
    notifyListeners();
  }

  void resetKey([bool notify = true]) {
    key = Key(DateTime.now().toString());
    if (notify) notifyListeners();
  }
  
  // New enhanced functionality
  void setCurrentIndex(int index) {
    _currentIndex = index;
    notifyListeners();
  }

  void toggleFocusMode() {
    _isFocusMode = !_isFocusMode;
    notifyListeners();
  }

  // Reading session management
  void startReadingSession(int surahNumber, int ayahNumber) {
    _sessionStartTime = DateTime.now();
    _currentSurah = surahNumber;
    _currentAyah = ayahNumber;
    notifyListeners();
  }

  Future<void> endReadingSession() async {
    if (_sessionStartTime != null && _currentSurah != null && _currentAyah != null) {
      final duration = DateTime.now().difference(_sessionStartTime!).inSeconds;
      
      final session = ReadingSession(
        startTime: _sessionStartTime!,
        endTime: DateTime.now(),
        surahNumber: _currentSurah!,
        startAyah: _currentAyah!,
        duration: duration,
      );
      
      await DatabaseService.instance.saveReadingSession(session);
      
      _sessionStartTime = null;
      _currentSurah = null;
      _currentAyah = null;
      notifyListeners();
    }
  }

  bool get isInReadingSession => _sessionStartTime != null;
  
  Duration get currentSessionDuration {
    if (_sessionStartTime == null) return Duration.zero;
    return DateTime.now().difference(_sessionStartTime!);
  }

  // Statistics with caching
  Map<String, dynamic> getStatistics() {
    final now = DateTime.now();
    
    // Cache stats for 5 minutes
    if (_cachedStats != null && 
        _lastStatsUpdate != null && 
        now.difference(_lastStatsUpdate!).inMinutes < 5) {
      return _cachedStats!;
    }
    
    _cachedStats = DatabaseService.instance.getReadingStatistics();
    _lastStatsUpdate = now;
    
    return _cachedStats!;
  }

  void refreshStatistics() {
    _cachedStats = null;
    _lastStatsUpdate = null;
    notifyListeners();
  }
}
