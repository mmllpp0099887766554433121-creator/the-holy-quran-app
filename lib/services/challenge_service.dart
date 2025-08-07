import 'dart:math';
import '../models/quran_models.dart';
import 'database_service.dart';

class ChallengeService {
  static ChallengeService? _instance;
  static ChallengeService get instance => _instance ??= ChallengeService._();
  ChallengeService._();

  final DatabaseService _db = DatabaseService.instance;
  final Random _random = Random();

  // Daily challenge types
  static const String CHALLENGE_READ = 'read';
  static const String CHALLENGE_MEMORIZE = 'memorize';
  static const String CHALLENGE_REFLECT = 'reflect';
  static const String CHALLENGE_LISTEN = 'listen';
  static const String CHALLENGE_REVIEW = 'review';
  static const String CHALLENGE_SEARCH = 'search';
  static const String CHALLENGE_DHIKR = 'dhikr';

  Future<DailyChallenge> generateTodayChallenge() async {
    final today = DateTime.now();
    final challengeId = '${today.year}-${today.month}-${today.day}';
    
    // Check if today's challenge already exists
    final existing = _db.getTodayChallenge();
    if (existing != null) {
      return existing;
    }
    
    // Generate new challenge based on user's progress
    final userStats = _db.getReadingStatistics();
    final challenge = _generateChallengeBasedOnProgress(challengeId, today, userStats);
    
    await _db.saveDailyChallenge(challenge);
    return challenge;
  }

  DailyChallenge _generateChallengeBasedOnProgress(String id, DateTime date, Map<String, dynamic> stats) {
    final challenges = <Map<String, dynamic>>[];
    
    // Reading challenges
    challenges.addAll([
      {
        'type': CHALLENGE_READ,
        'title': 'اقرأ صفحة من القرآن',
        'description': 'اقرأ صفحة كاملة من القرآن الكريم بتدبر',
        'parameters': {'pages': 1},
      },
      {
        'type': CHALLENGE_READ,
        'title': 'اقرأ سورة قصيرة',
        'description': 'اقرأ إحدى السور القصيرة من جزء عم',
        'parameters': {'surah_range': [78, 114]},
      },
      {
        'type': CHALLENGE_READ,
        'title': 'اقرأ 10 آيات',
        'description': 'اقرأ 10 آيات من أي سورة تختارها',
        'parameters': {'ayah_count': 10},
      },
    ]);
    
    // Memorization challenges
    if (stats['memorizedAyahs'] < 50) {
      challenges.addAll([
        {
          'type': CHALLENGE_MEMORIZE,
          'title': 'احفظ آية جديدة',
          'description': 'احفظ آية جديدة من السور القصيرة',
          'parameters': {'ayah_count': 1, 'difficulty': 'easy'},
        },
      ]);
    } else {
      challenges.addAll([
        {
          'type': CHALLENGE_MEMORIZE,
          'title': 'احفظ 3 آيات جديدة',
          'description': 'احفظ 3 آيات جديدة من القرآن الكريم',
          'parameters': {'ayah_count': 3, 'difficulty': 'medium'},
        },
      ]);
    }
    
    // Review challenges
    if (stats['memorizedAyahs'] > 10) {
      challenges.addAll([
        {
          'type': CHALLENGE_REVIEW,
          'title': 'راجع الآيات المحفوظة',
          'description': 'راجع 5 آيات من الآيات التي حفظتها سابقاً',
          'parameters': {'review_count': 5},
        },
      ]);
    }
    
    // Reflection challenges
    challenges.addAll([
      {
        'type': CHALLENGE_REFLECT,
        'title': 'تدبر آية',
        'description': 'اختر آية واكتب تأملك الشخصي عليها',
        'parameters': {'reflection_type': 'personal'},
      },
      {
        'type': CHALLENGE_REFLECT,
        'title': 'ابحث عن موضوع',
        'description': 'ابحث عن آيات تتحدث عن الصبر واقرأها',
        'parameters': {'topic': 'الصبر'},
      },
    ]);
    
    // Listening challenges
    challenges.addAll([
      {
        'type': CHALLENGE_LISTEN,
        'title': 'استمع لتلاوة',
        'description': 'استمع لتلاوة سورة كاملة',
        'parameters': {'listen_duration': 10}, // minutes
      },
    ]);
    
    // Search challenges
    challenges.addAll([
      {
        'type': CHALLENGE_SEARCH,
        'title': 'اكتشف آيات جديدة',
        'description': 'ابحث عن آيات تتحدث عن موضوع يهمك',
        'parameters': {'search_count': 3},
      },
    ]);
    
    // Dhikr challenges
    challenges.addAll([
      {
        'type': CHALLENGE_DHIKR,
        'title': 'سبح الله 100 مرة',
        'description': 'قل "سبحان الله" 100 مرة',
        'parameters': {'dhikr': 'سبحان الله', 'count': 100},
      },
      {
        'type': CHALLENGE_DHIKR,
        'title': 'احمد الله 50 مرة',
        'description': 'قل "الحمد لله" 50 مرة',
        'parameters': {'dhikr': 'الحمد لله', 'count': 50},
      },
    ]);
    
    // Select random challenge
    final selectedChallenge = challenges[_random.nextInt(challenges.length)];
    
    return DailyChallenge(
      id: id,
      title: selectedChallenge['title'],
      description: selectedChallenge['description'],
      date: date,
      type: selectedChallenge['type'],
      parameters: Map<String, dynamic>.from(selectedChallenge['parameters']),
    );
  }

  Future<bool> completeChallenge(String challengeId, Map<String, dynamic> completionData) async {
    final challenge = _db.getTodayChallenge();
    if (challenge == null || challenge.id != challengeId) {
      return false;
    }
    
    // Validate completion based on challenge type
    final isValid = await _validateChallengeCompletion(challenge, completionData);
    
    if (isValid) {
      await _db.completeDailyChallenge(challengeId);
      await _awardChallengePoints(challenge);
      await _checkForAchievements();
      return true;
    }
    
    return false;
  }

  Future<bool> _validateChallengeCompletion(DailyChallenge challenge, Map<String, dynamic> data) async {
    switch (challenge.type) {
      case CHALLENGE_READ:
        return _validateReadingChallenge(challenge, data);
      case CHALLENGE_MEMORIZE:
        return _validateMemorizationChallenge(challenge, data);
      case CHALLENGE_REFLECT:
        return _validateReflectionChallenge(challenge, data);
      case CHALLENGE_LISTEN:
        return _validateListeningChallenge(challenge, data);
      case CHALLENGE_REVIEW:
        return _validateReviewChallenge(challenge, data);
      case CHALLENGE_SEARCH:
        return _validateSearchChallenge(challenge, data);
      case CHALLENGE_DHIKR:
        return _validateDhikrChallenge(challenge, data);
      default:
        return false;
    }
  }

  bool _validateReadingChallenge(DailyChallenge challenge, Map<String, dynamic> data) {
    final requiredPages = challenge.parameters['pages'] as int?;
    final requiredAyahs = challenge.parameters['ayah_count'] as int?;
    
    if (requiredPages != null) {
      return (data['pages_read'] as int? ?? 0) >= requiredPages;
    }
    
    if (requiredAyahs != null) {
      return (data['ayahs_read'] as int? ?? 0) >= requiredAyahs;
    }
    
    return data['surah_completed'] == true;
  }

  bool _validateMemorizationChallenge(DailyChallenge challenge, Map<String, dynamic> data) {
    final requiredCount = challenge.parameters['ayah_count'] as int? ?? 1;
    return (data['ayahs_memorized'] as int? ?? 0) >= requiredCount;
  }

  bool _validateReflectionChallenge(DailyChallenge challenge, Map<String, dynamic> data) {
    final noteText = data['reflection_text'] as String? ?? '';
    return noteText.length >= 50; // Minimum reflection length
  }

  bool _validateListeningChallenge(DailyChallenge challenge, Map<String, dynamic> data) {
    final requiredDuration = challenge.parameters['listen_duration'] as int? ?? 5;
    final actualDuration = data['listen_duration'] as int? ?? 0;
    return actualDuration >= requiredDuration;
  }

  bool _validateReviewChallenge(DailyChallenge challenge, Map<String, dynamic> data) {
    final requiredCount = challenge.parameters['review_count'] as int? ?? 5;
    return (data['ayahs_reviewed'] as int? ?? 0) >= requiredCount;
  }

  bool _validateSearchChallenge(DailyChallenge challenge, Map<String, dynamic> data) {
    final requiredCount = challenge.parameters['search_count'] as int? ?? 3;
    return (data['searches_performed'] as int? ?? 0) >= requiredCount;
  }

  bool _validateDhikrChallenge(DailyChallenge challenge, Map<String, dynamic> data) {
    final requiredCount = challenge.parameters['count'] as int? ?? 100;
    return (data['dhikr_count'] as int? ?? 0) >= requiredCount;
  }

  Future<void> _awardChallengePoints(DailyChallenge challenge) async {
    final points = _getChallengePoints(challenge.type);
    
    // Award achievement
    final achievement = Achievement(
      id: 'daily_${challenge.id}',
      title: 'تحدي يومي مكتمل',
      description: 'أكملت تحدي: ${challenge.title}',
      icon: '🏆',
      unlockedAt: DateTime.now(),
      points: points,
    );
    
    await _db.unlockAchievement(achievement);
  }

  int _getChallengePoints(String challengeType) {
    switch (challengeType) {
      case CHALLENGE_READ:
        return 10;
      case CHALLENGE_MEMORIZE:
        return 25;
      case CHALLENGE_REFLECT:
        return 15;
      case CHALLENGE_LISTEN:
        return 10;
      case CHALLENGE_REVIEW:
        return 20;
      case CHALLENGE_SEARCH:
        return 5;
      case CHALLENGE_DHIKR:
        return 5;
      default:
        return 5;
    }
  }

  Future<void> _checkForAchievements() async {
    final stats = _db.getReadingStatistics();
    final achievements = <Achievement>[];
    
    // Reading achievements
    if (stats['totalSessions'] == 1) {
      achievements.add(Achievement(
        id: 'first_reading',
        title: 'أول قراءة',
        description: 'أكملت أول جلسة قراءة في التطبيق',
        icon: '📖',
        unlockedAt: DateTime.now(),
        points: 10,
      ));
    }
    
    if (stats['totalSessions'] == 7) {
      achievements.add(Achievement(
        id: 'week_reader',
        title: 'قارئ الأسبوع',
        description: 'أكملت 7 جلسات قراءة',
        icon: '📚',
        unlockedAt: DateTime.now(),
        points: 50,
      ));
    }
    
    if (stats['totalSessions'] == 30) {
      achievements.add(Achievement(
        id: 'month_reader',
        title: 'قارئ الشهر',
        description: 'أكملت 30 جلسة قراءة',
        icon: '🌟',
        unlockedAt: DateTime.now(),
        points: 100,
      ));
    }
    
    // Memorization achievements
    if (stats['memorizedAyahs'] == 10) {
      achievements.add(Achievement(
        id: 'memorizer_10',
        title: 'حافظ مبتدئ',
        description: 'حفظت 10 آيات من القرآن الكريم',
        icon: '🧠',
        unlockedAt: DateTime.now(),
        points: 50,
      ));
    }
    
    if (stats['memorizedAyahs'] == 50) {
      achievements.add(Achievement(
        id: 'memorizer_50',
        title: 'حافظ متوسط',
        description: 'حفظت 50 آية من القرآن الكريم',
        icon: '💎',
        unlockedAt: DateTime.now(),
        points: 150,
      ));
    }
    
    if (stats['memorizedAyahs'] == 100) {
      achievements.add(Achievement(
        id: 'memorizer_100',
        title: 'حافظ متقدم',
        description: 'حفظت 100 آية من القرآن الكريم',
        icon: '👑',
        unlockedAt: DateTime.now(),
        points: 300,
      ));
    }
    
    // Consistency achievements
    final consecutiveDays = _getConsecutiveDays();
    if (consecutiveDays == 7) {
      achievements.add(Achievement(
        id: 'consistent_week',
        title: 'أسبوع متواصل',
        description: 'قرأت القرآن لمدة أسبوع متواصل',
        icon: '🔥',
        unlockedAt: DateTime.now(),
        points: 75,
      ));
    }
    
    if (consecutiveDays == 30) {
      achievements.add(Achievement(
        id: 'consistent_month',
        title: 'شهر متواصل',
        description: 'قرأت القرآن لمدة شهر متواصل',
        icon: '⭐',
        unlockedAt: DateTime.now(),
        points: 200,
      ));
    }
    
    // Save new achievements
    for (final achievement in achievements) {
      final existing = _db.getUnlockedAchievements()
          .any((a) => a.id == achievement.id);
      
      if (!existing) {
        await _db.unlockAchievement(achievement);
      }
    }
  }

  int _getConsecutiveDays() {
    final sessions = _db.getReadingSessions();
    if (sessions.isEmpty) return 0;
    
    final today = DateTime.now();
    int consecutiveDays = 0;
    
    for (int i = 0; i < 365; i++) { // Check up to a year
      final checkDate = today.subtract(Duration(days: i));
      final hasSession = sessions.any((session) =>
          session.startTime.year == checkDate.year &&
          session.startTime.month == checkDate.month &&
          session.startTime.day == checkDate.day);
      
      if (hasSession) {
        consecutiveDays++;
      } else {
        break;
      }
    }
    
    return consecutiveDays;
  }

  // 30-day challenge system
  Future<void> start30DayChallenge() async {
    final startDate = DateTime.now();
    
    for (int day = 0; day < 30; day++) {
      final challengeDate = startDate.add(Duration(days: day));
      final challengeId = '30day_${challengeDate.year}_${challengeDate.month}_${challengeDate.day}';
      
      final challenge = _generate30DayChallenge(challengeId, challengeDate, day + 1);
      await _db.saveDailyChallenge(challenge);
    }
  }

  DailyChallenge _generate30DayChallenge(String id, DateTime date, int dayNumber) {
    final challenges30Day = [
      // Week 1: Foundation
      {'title': 'اقرأ سورة الفاتحة 5 مرات', 'type': CHALLENGE_READ, 'params': {'surah': 1, 'repetitions': 5}},
      {'title': 'احفظ آية الكرسي', 'type': CHALLENGE_MEMORIZE, 'params': {'surah': 2, 'ayah': 255}},
      {'title': 'تدبر في معنى البسملة', 'type': CHALLENGE_REFLECT, 'params': {'topic': 'البسملة'}},
      {'title': 'اقرأ سورة الإخلاص 10 مرات', 'type': CHALLENGE_READ, 'params': {'surah': 112, 'repetitions': 10}},
      {'title': 'ابحث عن آيات الرحمة', 'type': CHALLENGE_SEARCH, 'params': {'topic': 'الرحمة'}},
      {'title': 'استمع لسورة البقرة', 'type': CHALLENGE_LISTEN, 'params': {'surah': 2}},
      {'title': 'سبح الله 200 مرة', 'type': CHALLENGE_DHIKR, 'params': {'dhikr': 'سبحان الله', 'count': 200}},
      
      // Week 2: Building habits
      // ... more challenges
    ];
    
    final challengeIndex = (dayNumber - 1) % challenges30Day.length;
    final challengeData = challenges30Day[challengeIndex];
    
    return DailyChallenge(
      id: id,
      title: 'اليوم $dayNumber: ${challengeData['title']}',
      description: 'تحدي الـ30 يوم - ${challengeData['title']}',
      date: date,
      type: challengeData['type'] as String,
      parameters: challengeData['params'] as Map<String, dynamic>,
    );
  }

  Map<String, dynamic> getChallengeStatistics() {
    final today = DateTime.now();
    
    // Get all challenges for this month
    for (int day = 1; day <= today.day; day++) {
      // This would need to be implemented in database service
    }
    
    final completedToday = _db.getTodayChallenge()?.completed ?? false;
    final totalPoints = _db.getUnlockedAchievements()
        .fold<int>(0, (sum, achievement) => sum + achievement.points);
    
    return {
      'completedToday': completedToday,
      'totalPoints': totalPoints,
      'consecutiveDays': _getConsecutiveDays(),
      'totalAchievements': _db.getUnlockedAchievements().length,
    };
  }
}