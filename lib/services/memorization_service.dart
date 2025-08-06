import 'dart:math';
import '../models/quran_models.dart';
import 'database_service.dart';

class MemorizationService {
  static MemorizationService? _instance;
  static MemorizationService get instance => _instance ??= MemorizationService._();
  MemorizationService._();

  final DatabaseService _db = DatabaseService.instance;

  // Spaced Repetition Algorithm (similar to Anki)
  DateTime calculateNextReview(int level, int reviewCount, List<int> mistakes) {
    final now = DateTime.now();
    final baseIntervals = [1, 3, 7, 14, 30]; // days
    
    // Adjust interval based on level and mistakes
    int interval = baseIntervals[min(level - 1, baseIntervals.length - 1)];
    
    // Reduce interval if there are recent mistakes
    if (mistakes.isNotEmpty) {
      final recentMistakes = mistakes.where((mistake) => 
          DateTime.fromMillisecondsSinceEpoch(mistake)
              .isAfter(now.subtract(Duration(days: 7)))).length;
      
      if (recentMistakes > 0) {
        interval = (interval * 0.7).round(); // Reduce by 30%
      }
    }
    
    // Add some randomization to avoid clustering
    final randomFactor = 0.8 + (Random().nextDouble() * 0.4); // 0.8 to 1.2
    interval = (interval * randomFactor).round();
    
    return now.add(Duration(days: max(1, interval)));
  }

  Future<void> updateMemorizationLevel(int surahNumber, int ayahNumber, 
      int newLevel, {List<int>? newMistakes}) async {
    
    final existing = _db.getMemorizationProgress(surahNumber, ayahNumber);
    final now = DateTime.now();
    
    final mistakes = newMistakes ?? existing?.mistakes ?? [];
    final reviewCount = (existing?.reviewCount ?? 0) + 1;
    
    final nextReview = calculateNextReview(newLevel, reviewCount, mistakes);
    
    final progress = MemorizationProgress(
      surahNumber: surahNumber,
      ayahNumber: ayahNumber,
      level: newLevel,
      lastReviewed: now,
      nextReview: nextReview,
      reviewCount: reviewCount,
      mistakes: mistakes,
    );
    
    await _db.updateMemorizationProgress(progress);
  }

  List<Ayah> getSuggestedAyahsForMemorization({int? userLevel}) {
    final level = userLevel ?? _getUserMemorizationLevel();
    final suggestions = <Ayah>[];
    
    // Get already memorized ayahs
    final memorized = _db.getAllMemorizationProgress()
        .map((p) => '${p.surahNumber}_${p.ayahNumber}')
        .toSet();
    
    // Suggest based on user level
    if (level == 1) {
      // Beginners: Short surahs and famous ayahs
      suggestions.addAll(_getBeginnerAyahs(memorized));
    } else if (level == 2) {
      // Intermediate: Medium length surahs
      suggestions.addAll(_getIntermediateAyahs(memorized));
    } else {
      // Advanced: Longer surahs and challenging ayahs
      suggestions.addAll(_getAdvancedAyahs(memorized));
    }
    
    return suggestions.take(10).toList();
  }

  List<Ayah> _getBeginnerAyahs(Set<String> memorized) {
    final suggestions = <Ayah>[];
    
    // Short surahs (Juz 30)
    final shortSurahs = [114, 113, 112, 111, 110, 109, 108, 107, 106, 105];
    
    for (final surahNumber in shortSurahs) {
      final surah = _db.getSurah(surahNumber);
      if (surah != null) {
        for (final ayah in surah.ayahs) {
          final key = '${ayah.surahNumber}_${ayah.numberInSurah}';
          if (!memorized.contains(key)) {
            suggestions.add(ayah);
          }
        }
      }
    }
    
    // Famous ayahs
    final famousAyahs = [
      AyahReference(surahNumber: 2, ayahNumber: 255), // Ayat al-Kursi
      AyahReference(surahNumber: 2, ayahNumber: 286), // Last ayah of Baqarah
      AyahReference(surahNumber: 17, ayahNumber: 110), // Say: Call upon Allah
    ];
    
    for (final ref in famousAyahs) {
      final key = '${ref.surahNumber}_${ref.ayahNumber}';
      if (!memorized.contains(key)) {
        final ayah = _db.getAyah(ref.surahNumber, ref.ayahNumber);
        if (ayah != null) {
          suggestions.add(ayah);
        }
      }
    }
    
    return suggestions;
  }

  List<Ayah> _getIntermediateAyahs(Set<String> memorized) {
    final suggestions = <Ayah>[];
    
    // Medium surahs
    final mediumSurahs = [78, 79, 80, 81, 82, 83, 84, 85, 86, 87];
    
    for (final surahNumber in mediumSurahs) {
      final surah = _db.getSurah(surahNumber);
      if (surah != null) {
        for (final ayah in surah.ayahs) {
          final key = '${ayah.surahNumber}_${ayah.numberInSurah}';
          if (!memorized.contains(key)) {
            suggestions.add(ayah);
          }
        }
      }
    }
    
    return suggestions;
  }

  List<Ayah> _getAdvancedAyahs(Set<String> memorized) {
    final suggestions = <Ayah>[];
    
    // Longer surahs
    final longSurahs = [2, 3, 4, 5, 6, 7, 8, 9, 10];
    
    for (final surahNumber in longSurahs) {
      final surah = _db.getSurah(surahNumber);
      if (surah != null) {
        // Take first few ayahs of each surah
        for (int i = 0; i < min(5, surah.ayahs.length); i++) {
          final ayah = surah.ayahs[i];
          final key = '${ayah.surahNumber}_${ayah.numberInSurah}';
          if (!memorized.contains(key)) {
            suggestions.add(ayah);
          }
        }
      }
    }
    
    return suggestions;
  }

  int _getUserMemorizationLevel() {
    final memorizedCount = _db.getAllMemorizationProgress().length;
    
    if (memorizedCount < 50) return 1; // Beginner
    if (memorizedCount < 200) return 2; // Intermediate
    return 3; // Advanced
  }

  List<MemorizationProgress> getTodayReviews() {
    final today = DateTime.now();
    return _db.getAyahsForReview()
        .where((progress) => 
            progress.nextReview.year == today.year &&
            progress.nextReview.month == today.month &&
            progress.nextReview.day == today.day)
        .toList();
  }

  List<MemorizationProgress> getOverdueReviews() {
    final now = DateTime.now();
    return _db.getAyahsForReview()
        .where((progress) => progress.nextReview.isBefore(now))
        .toList()
        ..sort((a, b) => a.nextReview.compareTo(b.nextReview));
  }

  Map<String, dynamic> getMemorizationStatistics() {
    final allProgress = _db.getAllMemorizationProgress();
    
    final levelCounts = <int, int>{};
    var totalReviews = 0;
    var averageLevel = 0.0;
    
    for (final progress in allProgress) {
      levelCounts[progress.level] = (levelCounts[progress.level] ?? 0) + 1;
      totalReviews += progress.reviewCount;
      averageLevel += progress.level;
    }
    
    if (allProgress.isNotEmpty) {
      averageLevel /= allProgress.length;
    }
    
    final overdueCount = getOverdueReviews().length;
    final todayCount = getTodayReviews().length;
    
    return {
      'totalMemorized': allProgress.length,
      'levelCounts': levelCounts,
      'averageLevel': averageLevel,
      'totalReviews': totalReviews,
      'overdueReviews': overdueCount,
      'todayReviews': todayCount,
    };
  }

  Future<void> recordMistake(int surahNumber, int ayahNumber, String mistakeType) async {
    final existing = _db.getMemorizationProgress(surahNumber, ayahNumber);
    if (existing != null) {
      final mistakes = List<int>.from(existing.mistakes);
      mistakes.add(DateTime.now().millisecondsSinceEpoch);
      
      // Keep only recent mistakes (last 30 days)
      final thirtyDaysAgo = DateTime.now().subtract(Duration(days: 30));
      mistakes.removeWhere((mistake) => 
          DateTime.fromMillisecondsSinceEpoch(mistake).isBefore(thirtyDaysAgo));
      
      await updateMemorizationLevel(
        surahNumber, 
        ayahNumber, 
        max(1, existing.level - 1), // Decrease level on mistake
        newMistakes: mistakes,
      );
    }
  }

  List<Ayah> getWeakAyahs() {
    final now = DateTime.now();
    final sevenDaysAgo = now.subtract(Duration(days: 7));
    
    return _db.getAllMemorizationProgress()
        .where((progress) {
          // Ayahs with recent mistakes or low level
          final recentMistakes = progress.mistakes.where((mistake) => 
              DateTime.fromMillisecondsSinceEpoch(mistake).isAfter(sevenDaysAgo)).length;
          
          return recentMistakes > 2 || progress.level < 3;
        })
        .map((progress) => _db.getAyah(progress.surahNumber, progress.ayahNumber))
        .where((ayah) => ayah != null)
        .cast<Ayah>()
        .toList();
  }

  Future<void> markAsReviewed(int surahNumber, int ayahNumber, bool successful) async {
    final existing = _db.getMemorizationProgress(surahNumber, ayahNumber);
    if (existing != null) {
      int newLevel = existing.level;
      
      if (successful) {
        newLevel = min(5, existing.level + 1); // Increase level on success
      } else {
        newLevel = max(1, existing.level - 1); // Decrease level on failure
        await recordMistake(surahNumber, ayahNumber, 'review_failure');
      }
      
      await updateMemorizationLevel(surahNumber, ayahNumber, newLevel);
    }
  }

  List<Ayah> getRandomQuizAyahs({int count = 5}) {
    final memorized = _db.getAllMemorizationProgress()
        .where((progress) => progress.level >= 3) // Only well-memorized ayahs
        .toList();
    
    memorized.shuffle();
    
    return memorized
        .take(count)
        .map((progress) => _db.getAyah(progress.surahNumber, progress.ayahNumber))
        .where((ayah) => ayah != null)
        .cast<Ayah>()
        .toList();
  }

  List<Ayah> getAyahsForReview() {
    final reviewList = <Ayah>[];
    final progressList = _db.getAllMemorizationProgress();
    
    for (final progress in progressList) {
      if (_shouldReviewToday(progress)) {
        final ayah = _db.getAyah(progress.surahNumber, progress.ayahNumber);
        if (ayah != null) {
          reviewList.add(ayah);
        }
      }
    }
    
    return reviewList;
  }

  bool _shouldReviewToday(MemorizationProgress progress) {
    final now = DateTime.now();
    final daysSinceLastReview = now.difference(progress.lastReviewed).inDays;
    
    // Review intervals based on level
    final intervals = [1, 3, 7, 14]; // days
    final requiredInterval = intervals[progress.level.clamp(0, 3)];
    
    return daysSinceLastReview >= requiredInterval;
  }

  void updateReviewStatus(int surahNumber, int ayahNumber, bool correct) {
    final progress = _db.getMemorizationProgress(surahNumber, ayahNumber);
    if (progress != null) {
      if (correct) {
        // Increase level if answered correctly
        final newLevel = (progress.level + 1).clamp(0, 4);
        final newProgress = MemorizationProgress(
          surahNumber: progress.surahNumber,
          ayahNumber: progress.ayahNumber,
          level: newLevel,
          lastReviewed: DateTime.now(),
          reviewCount: progress.reviewCount + 1,
          mistakes: progress.mistakes,
          nextReview: DateTime.now().add(Duration(days: newLevel + 1)),
        );
        _db.updateMemorizationProgress(newProgress);
      } else {
        // Decrease level if answered incorrectly
        final newLevel = (progress.level - 1).clamp(0, 4);
        final newProgress = MemorizationProgress(
          surahNumber: progress.surahNumber,
          ayahNumber: progress.ayahNumber,
          level: newLevel,
          lastReviewed: DateTime.now(),
          reviewCount: progress.reviewCount + 1,
          mistakes: progress.mistakes,
          nextReview: DateTime.now().add(Duration(days: newLevel + 1)),
        );
        _db.updateMemorizationProgress(newProgress);
      }
    }
  }
}