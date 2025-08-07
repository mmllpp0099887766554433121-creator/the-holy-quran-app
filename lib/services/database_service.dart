import 'package:hive_flutter/hive_flutter.dart';
// import 'package:path/path.dart' as path;
import '../models/quran_models.dart';

class DatabaseService {
  static DatabaseService? _instance;
  static DatabaseService get instance => _instance ??= DatabaseService._();
  DatabaseService._();

  late Box<Surah> _surahBox;
  late Box<Bookmark> _bookmarkBox;
  late Box<MemorizationProgress> _memorizationBox;
  late Box<ReadingSession> _sessionBox;
  late Box<SpiritualNote> _noteBox;
  late Box<Achievement> _achievementBox;
  late Box<DailyChallenge> _challengeBox;
  late Box _settingsBox;

  Future<void> initialize() async {
    await Hive.initFlutter();
    
    // Register adapters
    Hive.registerAdapter(SurahAdapter());
    Hive.registerAdapter(AyahAdapter());
    Hive.registerAdapter(BookmarkAdapter());
    Hive.registerAdapter(MemorizationProgressAdapter());
    Hive.registerAdapter(ReadingSessionAdapter());
    Hive.registerAdapter(SpiritualNoteAdapter());
    Hive.registerAdapter(AchievementAdapter());
    Hive.registerAdapter(DailyChallengeAdapter());

    // Open boxes
    _surahBox = await Hive.openBox<Surah>('surahs');
    _bookmarkBox = await Hive.openBox<Bookmark>('bookmarks');
    _memorizationBox = await Hive.openBox<MemorizationProgress>('memorization');
    _sessionBox = await Hive.openBox<ReadingSession>('sessions');
    _noteBox = await Hive.openBox<SpiritualNote>('notes');
    _achievementBox = await Hive.openBox<Achievement>('achievements');
    _challengeBox = await Hive.openBox<DailyChallenge>('challenges');
    _settingsBox = await Hive.openBox('settings');

    // Initialize Quran data if not exists
    if (_surahBox.isEmpty) {
      await _initializeQuranData();
    }
  }

  Future<void> _initializeQuranData() async {
    try {
      // Load from JSON file
      final sampleSurahs = _getSampleQuranData();
      
      for (final surah in sampleSurahs) {
        await _surahBox.put(surah.number, surah);
      }
    } catch (e) {
      print('Error initializing Quran data: $e');
      // Fallback to sample data
      final sampleSurahs = _getSampleQuranData();
      for (final surah in sampleSurahs) {
        await _surahBox.put(surah.number, surah);
      }
    }
  }

  List<Surah> _getSampleQuranData() {
    // Sample data - in a real app, this would be loaded from assets
    return [
      Surah(
        number: 1,
        name: "الفاتحة",
        englishName: "Al-Fatihah",
        englishNameTranslation: "The Opening",
        revelationType: "Meccan",
        numberOfAyahs: 7,
        ayahs: [
          Ayah(
            number: 1,
            text: "بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ",
            surahNumber: 1,
            numberInSurah: 1,
            juz: 1,
            manzil: 1,
            page: 1,
            ruku: 1,
            hizbQuarter: 1,
          ),
          Ayah(
            number: 2,
            text: "الْحَمْدُ لِلَّهِ رَبِّ الْعَالَمِينَ",
            surahNumber: 1,
            numberInSurah: 2,
            juz: 1,
            manzil: 1,
            page: 1,
            ruku: 1,
            hizbQuarter: 1,
          ),
          Ayah(
            number: 3,
            text: "الرَّحْمَٰنِ الرَّحِيمِ",
            surahNumber: 1,
            numberInSurah: 3,
            juz: 1,
            manzil: 1,
            page: 1,
            ruku: 1,
            hizbQuarter: 1,
          ),
          Ayah(
            number: 4,
            text: "مَالِكِ يَوْمِ الدِّينِ",
            surahNumber: 1,
            numberInSurah: 4,
            juz: 1,
            manzil: 1,
            page: 1,
            ruku: 1,
            hizbQuarter: 1,
          ),
          Ayah(
            number: 5,
            text: "إِيَّاكَ نَعْبُدُ وَإِيَّاكَ نَسْتَعِينُ",
            surahNumber: 1,
            numberInSurah: 5,
            juz: 1,
            manzil: 1,
            page: 1,
            ruku: 1,
            hizbQuarter: 1,
          ),
          Ayah(
            number: 6,
            text: "اهْدِنَا الصِّرَاطَ الْمُسْتَقِيمَ",
            surahNumber: 1,
            numberInSurah: 6,
            juz: 1,
            manzil: 1,
            page: 1,
            ruku: 1,
            hizbQuarter: 1,
          ),
          Ayah(
            number: 7,
            text: "صِرَاطَ الَّذِينَ أَنْعَمْتَ عَلَيْهِمْ غَيْرِ الْمَغْضُوبِ عَلَيْهِمْ وَلَا الضَّالِّينَ",
            surahNumber: 1,
            numberInSurah: 7,
            juz: 1,
            manzil: 1,
            page: 1,
            ruku: 1,
            hizbQuarter: 1,
          ),
        ],
      ),
      Surah(
        number: 112,
        name: "الإخلاص",
        englishName: "Al-Ikhlas",
        englishNameTranslation: "The Sincerity",
        revelationType: "Meccan",
        numberOfAyahs: 4,
        ayahs: [
          Ayah(
            number: 6230,
            text: "قُلْ هُوَ اللَّهُ أَحَدٌ",
            surahNumber: 112,
            numberInSurah: 1,
            juz: 30,
            manzil: 7,
            page: 604,
            ruku: 1,
            hizbQuarter: 239,
          ),
          Ayah(
            number: 6231,
            text: "اللَّهُ الصَّمَدُ",
            surahNumber: 112,
            numberInSurah: 2,
            juz: 30,
            manzil: 7,
            page: 604,
            ruku: 1,
            hizbQuarter: 239,
          ),
          Ayah(
            number: 6232,
            text: "لَمْ يَلِدْ وَلَمْ يُولَدْ",
            surahNumber: 112,
            numberInSurah: 3,
            juz: 30,
            manzil: 7,
            page: 604,
            ruku: 1,
            hizbQuarter: 239,
          ),
          Ayah(
            number: 6233,
            text: "وَلَمْ يَكُن لَّهُ كُفُوًا أَحَدٌ",
            surahNumber: 112,
            numberInSurah: 4,
            juz: 30,
            manzil: 7,
            page: 604,
            ruku: 1,
            hizbQuarter: 239,
          ),
        ],
      ),
    ];
  }

  // Surah operations
  List<Surah> getAllSurahs() {
    return _surahBox.values.toList()..sort((a, b) => a.number.compareTo(b.number));
  }

  Surah? getSurah(int number) {
    return _surahBox.get(number);
  }

  List<Ayah> getAyahsBySurah(int surahNumber) {
    final surah = getSurah(surahNumber);
    return surah?.ayahs ?? [];
  }

  Ayah? getAyah(int surahNumber, int ayahNumber) {
    final surah = getSurah(surahNumber);
    if (surah != null && ayahNumber <= surah.ayahs.length) {
      return surah.ayahs[ayahNumber - 1];
    }
    return null;
  }

  // Bookmark operations
  Future<void> addBookmark(Bookmark bookmark) async {
    final key = '${bookmark.surahNumber}_${bookmark.ayahNumber}';
    await _bookmarkBox.put(key, bookmark);
  }

  Future<void> removeBookmark(int surahNumber, int ayahNumber) async {
    final key = '${surahNumber}_$ayahNumber';
    await _bookmarkBox.delete(key);
  }

  List<Bookmark> getAllBookmarks() {
    return _bookmarkBox.values.toList();
  }

  bool isBookmarked(int surahNumber, int ayahNumber) {
    final key = '${surahNumber}_$ayahNumber';
    return _bookmarkBox.containsKey(key);
  }

  // Memorization operations
  Future<void> updateMemorizationProgress(MemorizationProgress progress) async {
    final key = '${progress.surahNumber}_${progress.ayahNumber}';
    await _memorizationBox.put(key, progress);
  }

  MemorizationProgress? getMemorizationProgress(int surahNumber, int ayahNumber) {
    final key = '${surahNumber}_$ayahNumber';
    return _memorizationBox.get(key);
  }

  List<MemorizationProgress> getAllMemorizationProgress() {
    return _memorizationBox.values.toList();
  }

  List<MemorizationProgress> getAyahsForReview() {
    final now = DateTime.now();
    return _memorizationBox.values
        .where((progress) => progress.nextReview.isBefore(now))
        .toList();
  }

  // Reading session operations
  Future<void> saveReadingSession(ReadingSession session) async {
    await _sessionBox.add(session);
  }

  List<ReadingSession> getReadingSessions({int? limit}) {
    final sessions = _sessionBox.values.toList()
      ..sort((a, b) => b.startTime.compareTo(a.startTime));
    
    if (limit != null && sessions.length > limit) {
      return sessions.take(limit).toList();
    }
    return sessions;
  }

  // Spiritual notes operations
  Future<void> addSpiritualNote(SpiritualNote note) async {
    await _noteBox.add(note);
  }

  List<SpiritualNote> getSpiritualNotes(int surahNumber, int ayahNumber) {
    return _noteBox.values
        .where((note) => note.surahNumber == surahNumber && note.ayahNumber == ayahNumber)
        .toList();
  }

  List<SpiritualNote> getAllSpiritualNotes() {
    return _noteBox.values.toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  // Achievement operations
  Future<void> unlockAchievement(Achievement achievement) async {
    await _achievementBox.put(achievement.id, achievement);
  }

  List<Achievement> getUnlockedAchievements() {
    return _achievementBox.values.toList()
      ..sort((a, b) => b.unlockedAt.compareTo(a.unlockedAt));
  }

  // Daily challenge operations
  Future<void> saveDailyChallenge(DailyChallenge challenge) async {
    await _challengeBox.put(challenge.id, challenge);
  }

  DailyChallenge? getTodayChallenge() {
    final today = DateTime.now();
    final todayKey = '${today.year}-${today.month}-${today.day}';
    return _challengeBox.get(todayKey);
  }

  Future<void> completeDailyChallenge(String challengeId) async {
    final challenge = _challengeBox.get(challengeId);
    if (challenge != null) {
      final updatedChallenge = DailyChallenge(
        id: challenge.id,
        title: challenge.title,
        description: challenge.description,
        date: challenge.date,
        completed: true,
        type: challenge.type,
        parameters: challenge.parameters,
      );
      await _challengeBox.put(challengeId, updatedChallenge);
    }
  }

  // Settings operations
  Future<void> setSetting(String key, dynamic value) async {
    await _settingsBox.put(key, value);
  }

  T? getSetting<T>(String key, {T? defaultValue}) {
    return _settingsBox.get(key, defaultValue: defaultValue) as T?;
  }

  // Search operations
  List<Ayah> searchAyahs(String query) {
    final results = <Ayah>[];
    final lowerQuery = query.toLowerCase();
    
    for (final surah in _surahBox.values) {
      for (final ayah in surah.ayahs) {
        if (ayah.text.toLowerCase().contains(lowerQuery)) {
          results.add(ayah);
        }
      }
    }
    
    return results;
  }

  // Statistics
  Map<String, dynamic> getReadingStatistics() {
    final sessions = getReadingSessions();
    final totalSessions = sessions.length;
    final totalDuration = sessions.fold<int>(0, (sum, session) => sum + session.duration);
    final averageDuration = totalSessions > 0 ? totalDuration / totalSessions : 0;
    
    final today = DateTime.now();
    final todaySessions = sessions.where((session) =>
        session.startTime.year == today.year &&
        session.startTime.month == today.month &&
        session.startTime.day == today.day).length;

    return {
      'totalSessions': totalSessions,
      'totalDuration': totalDuration,
      'averageDuration': averageDuration,
      'todaySessions': todaySessions,
      'memorizedAyahs': _memorizationBox.length,
      'bookmarks': _bookmarkBox.length,
      'spiritualNotes': _noteBox.length,
    };
  }
}