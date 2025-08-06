import 'package:hive/hive.dart';

part 'quran_models.g.dart';

@HiveType(typeId: 0)
class Surah extends HiveObject {
  @HiveField(0)
  final int number;
  
  @HiveField(1)
  final String name;
  
  @HiveField(2)
  final String englishName;
  
  @HiveField(3)
  final String englishNameTranslation;
  
  @HiveField(4)
  final String revelationType;
  
  @HiveField(5)
  final int numberOfAyahs;
  
  @HiveField(6)
  final List<Ayah> ayahs;

  Surah({
    required this.number,
    required this.name,
    required this.englishName,
    required this.englishNameTranslation,
    required this.revelationType,
    required this.numberOfAyahs,
    required this.ayahs,
  });
}

@HiveType(typeId: 1)
class Ayah extends HiveObject {
  @HiveField(0)
  final int number;
  
  @HiveField(1)
  final String text;
  
  @HiveField(2)
  final int surahNumber;
  
  @HiveField(3)
  final int numberInSurah;
  
  @HiveField(4)
  final int juz;
  
  @HiveField(5)
  final int manzil;
  
  @HiveField(6)
  final int page;
  
  @HiveField(7)
  final int ruku;
  
  @HiveField(8)
  final int hizbQuarter;
  
  @HiveField(9)
  final bool sajda;

  Ayah({
    required this.number,
    required this.text,
    required this.surahNumber,
    required this.numberInSurah,
    required this.juz,
    required this.manzil,
    required this.page,
    required this.ruku,
    required this.hizbQuarter,
    this.sajda = false,
  });
}

@HiveType(typeId: 2)
class Bookmark extends HiveObject {
  @HiveField(0)
  final int surahNumber;
  
  @HiveField(1)
  final int ayahNumber;
  
  @HiveField(2)
  final String note;
  
  @HiveField(3)
  final DateTime createdAt;

  Bookmark({
    required this.surahNumber,
    required this.ayahNumber,
    required this.note,
    required this.createdAt,
  });
}

@HiveType(typeId: 3)
class MemorizationProgress extends HiveObject {
  @HiveField(0)
  final int surahNumber;
  
  @HiveField(1)
  final int ayahNumber;
  
  @HiveField(2)
  final int level; // 1-5 (1: just started, 5: mastered)
  
  @HiveField(3)
  final DateTime lastReviewed;
  
  @HiveField(4)
  final DateTime nextReview;
  
  @HiveField(5)
  final int reviewCount;
  
  @HiveField(6)
  final List<int> mistakes; // Track common mistakes

  MemorizationProgress({
    required this.surahNumber,
    required this.ayahNumber,
    required this.level,
    required this.lastReviewed,
    required this.nextReview,
    this.reviewCount = 0,
    this.mistakes = const [],
  });
}

@HiveType(typeId: 4)
class ReadingSession extends HiveObject {
  @HiveField(0)
  final DateTime startTime;
  
  @HiveField(1)
  final DateTime? endTime;
  
  @HiveField(2)
  final int surahNumber;
  
  @HiveField(3)
  final int startAyah;
  
  @HiveField(4)
  final int? endAyah;
  
  @HiveField(5)
  final int duration; // in seconds

  ReadingSession({
    required this.startTime,
    this.endTime,
    required this.surahNumber,
    required this.startAyah,
    this.endAyah,
    this.duration = 0,
  });
}

@HiveType(typeId: 5)
class SpiritualNote extends HiveObject {
  @HiveField(0)
  final int surahNumber;
  
  @HiveField(1)
  final int ayahNumber;
  
  @HiveField(2)
  final String note;
  
  @HiveField(3)
  final DateTime createdAt;
  
  @HiveField(4)
  final List<String> tags;

  SpiritualNote({
    required this.surahNumber,
    required this.ayahNumber,
    required this.note,
    required this.createdAt,
    this.tags = const [],
  });
}

@HiveType(typeId: 6)
class Achievement extends HiveObject {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String title;
  
  @HiveField(2)
  final String description;
  
  @HiveField(3)
  final String icon;
  
  @HiveField(4)
  final DateTime unlockedAt;
  
  @HiveField(5)
  final int points;

  Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.unlockedAt,
    required this.points,
  });
}

@HiveType(typeId: 7)
class DailyChallenge extends HiveObject {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String title;
  
  @HiveField(2)
  final String description;
  
  @HiveField(3)
  final DateTime date;
  
  @HiveField(4)
  final bool completed;
  
  @HiveField(5)
  final String type; // read, memorize, reflect, etc.
  
  @HiveField(6)
  final Map<String, dynamic> parameters;

  DailyChallenge({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    this.completed = false,
    required this.type,
    this.parameters = const {},
  });
}

class QuranTopic {
  final String name;
  final String description;
  final List<String> keywords;
  final List<AyahReference> ayahs;

  QuranTopic({
    required this.name,
    required this.description,
    required this.keywords,
    required this.ayahs,
  });
}

class AyahReference {
  final int surahNumber;
  final int ayahNumber;

  AyahReference({
    required this.surahNumber,
    required this.ayahNumber,
  });
}

class QuranStory {
  final String title;
  final String summary;
  final List<AyahReference> relatedAyahs;
  final String prophet;

  QuranStory({
    required this.title,
    required this.summary,
    required this.relatedAyahs,
    required this.prophet,
  });
}