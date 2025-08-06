import '../models/quran_models.dart';
import 'database_service.dart';

class SemanticSearchService {
  static SemanticSearchService? _instance;
  static SemanticSearchService get instance => _instance ??= SemanticSearchService._();
  SemanticSearchService._();

  final Map<String, List<AyahReference>> _topicIndex = {};
  final Map<String, List<String>> _synonyms = {};

  void initialize() {
    _buildTopicIndex();
    _buildSynonyms();
  }

  void _buildTopicIndex() {
    // Build semantic index for topics
    _topicIndex.addAll({
      'الصبر': [
        AyahReference(surahNumber: 2, ayahNumber: 45),
        AyahReference(surahNumber: 2, ayahNumber: 153),
        AyahReference(surahNumber: 3, ayahNumber: 200),
        AyahReference(surahNumber: 8, ayahNumber: 46),
        AyahReference(surahNumber: 16, ayahNumber: 126),
        AyahReference(surahNumber: 39, ayahNumber: 10),
      ],
      'التقوى': [
        AyahReference(surahNumber: 2, ayahNumber: 2),
        AyahReference(surahNumber: 2, ayahNumber: 21),
        AyahReference(surahNumber: 2, ayahNumber: 183),
        AyahReference(surahNumber: 3, ayahNumber: 102),
        AyahReference(surahNumber: 49, ayahNumber: 13),
      ],
      'الرزق': [
        AyahReference(surahNumber: 2, ayahNumber: 3),
        AyahReference(surahNumber: 2, ayahNumber: 212),
        AyahReference(surahNumber: 11, ayahNumber: 6),
        AyahReference(surahNumber: 17, ayahNumber: 30),
        AyahReference(surahNumber: 29, ayahNumber: 62),
        AyahReference(surahNumber: 51, ayahNumber: 22),
      ],
      'الجنة': [
        AyahReference(surahNumber: 2, ayahNumber: 25),
        AyahReference(surahNumber: 3, ayahNumber: 133),
        AyahReference(surahNumber: 4, ayahNumber: 57),
        AyahReference(surahNumber: 9, ayahNumber: 72),
        AyahReference(surahNumber: 47, ayahNumber: 15),
      ],
      'النار': [
        AyahReference(surahNumber: 2, ayahNumber: 24),
        AyahReference(surahNumber: 3, ayahNumber: 131),
        AyahReference(surahNumber: 4, ayahNumber: 56),
        AyahReference(surahNumber: 9, ayahNumber: 73),
        AyahReference(surahNumber: 104, ayahNumber: 6),
      ],
      'التوبة': [
        AyahReference(surahNumber: 2, ayahNumber: 37),
        AyahReference(surahNumber: 4, ayahNumber: 17),
        AyahReference(surahNumber: 9, ayahNumber: 104),
        AyahReference(surahNumber: 25, ayahNumber: 71),
        AyahReference(surahNumber: 39, ayahNumber: 53),
      ],
      'الدعاء': [
        AyahReference(surahNumber: 2, ayahNumber: 186),
        AyahReference(surahNumber: 7, ayahNumber: 55),
        AyahReference(surahNumber: 40, ayahNumber: 60),
        AyahReference(surahNumber: 17, ayahNumber: 11),
      ],
      'الشكر': [
        AyahReference(surahNumber: 2, ayahNumber: 152),
        AyahReference(surahNumber: 14, ayahNumber: 7),
        AyahReference(surahNumber: 16, ayahNumber: 78),
        AyahReference(surahNumber: 31, ayahNumber: 12),
      ],
      'العلم': [
        AyahReference(surahNumber: 2, ayahNumber: 31),
        AyahReference(surahNumber: 20, ayahNumber: 114),
        AyahReference(surahNumber: 35, ayahNumber: 28),
        AyahReference(surahNumber: 58, ayahNumber: 11),
      ],
      'الإيمان': [
        AyahReference(surahNumber: 2, ayahNumber: 4),
        AyahReference(surahNumber: 3, ayahNumber: 173),
        AyahReference(surahNumber: 8, ayahNumber: 2),
        AyahReference(surahNumber: 49, ayahNumber: 15),
      ],
      'القلق': [
        AyahReference(surahNumber: 2, ayahNumber: 62),
        AyahReference(surahNumber: 13, ayahNumber: 28),
        AyahReference(surahNumber: 39, ayahNumber: 23),
        AyahReference(surahNumber: 94, ayahNumber: 5),
      ],
      'الحزن': [
        AyahReference(surahNumber: 2, ayahNumber: 38),
        AyahReference(surahNumber: 2, ayahNumber: 62),
        AyahReference(surahNumber: 35, ayahNumber: 34),
        AyahReference(surahNumber: 46, ayahNumber: 13),
      ],
      'الفرج': [
        AyahReference(surahNumber: 2, ayahNumber: 214),
        AyahReference(surahNumber: 65, ayahNumber: 2),
        AyahReference(surahNumber: 94, ayahNumber: 5),
      ],
      'العدل': [
        AyahReference(surahNumber: 4, ayahNumber: 58),
        AyahReference(surahNumber: 5, ayahNumber: 8),
        AyahReference(surahNumber: 16, ayahNumber: 90),
        AyahReference(surahNumber: 42, ayahNumber: 15),
      ],
      'الرحمة': [
        AyahReference(surahNumber: 6, ayahNumber: 12),
        AyahReference(surahNumber: 7, ayahNumber: 156),
        AyahReference(surahNumber: 21, ayahNumber: 107),
        AyahReference(surahNumber: 39, ayahNumber: 53),
      ],
      'الحب': [
        AyahReference(surahNumber: 2, ayahNumber: 165),
        AyahReference(surahNumber: 3, ayahNumber: 31),
        AyahReference(surahNumber: 5, ayahNumber: 54),
        AyahReference(surahNumber: 76, ayahNumber: 8),
      ],
      'الأمل': [
        AyahReference(surahNumber: 12, ayahNumber: 87),
        AyahReference(surahNumber: 39, ayahNumber: 53),
        AyahReference(surahNumber: 94, ayahNumber: 5),
      ],
      'الخوف': [
        AyahReference(surahNumber: 2, ayahNumber: 38),
        AyahReference(surahNumber: 2, ayahNumber: 62),
        AyahReference(surahNumber: 10, ayahNumber: 62),
        AyahReference(surahNumber: 41, ayahNumber: 30),
      ],
      'السلام': [
        AyahReference(surahNumber: 2, ayahNumber: 208),
        AyahReference(surahNumber: 6, ayahNumber: 127),
        AyahReference(surahNumber: 10, ayahNumber: 25),
        AyahReference(surahNumber: 36, ayahNumber: 58),
      ],
      'الهداية': [
        AyahReference(surahNumber: 1, ayahNumber: 6),
        AyahReference(surahNumber: 2, ayahNumber: 2),
        AyahReference(surahNumber: 2, ayahNumber: 5),
        AyahReference(surahNumber: 17, ayahNumber: 9),
      ],
    });
  }

  void _buildSynonyms() {
    _synonyms.addAll({
      'الصبر': ['صبر', 'صابر', 'اصبر', 'صابرين', 'الصابرين', 'تصبر'],
      'التقوى': ['تقوى', 'اتقوا', 'متقين', 'المتقين', 'تقي', 'اتق'],
      'الرزق': ['رزق', 'ارزق', 'رازق', 'مرزوق', 'رزقنا', 'يرزق'],
      'الجنة': ['جنة', 'جنات', 'الجنات', 'فردوس'],
      'النار': ['نار', 'جهنم', 'سعير', 'حطمة'],
      'التوبة': ['توبة', 'تاب', 'توب', 'تائب', 'التائبين'],
      'الدعاء': ['دعاء', 'ادع', 'دعا', 'يدعو', 'ادعوا'],
      'الشكر': ['شكر', 'اشكر', 'شاكر', 'الشاكرين', 'شكور'],
      'العلم': ['علم', 'اعلم', 'عالم', 'العالمين', 'تعلم', 'علماء'],
      'الإيمان': ['إيمان', 'آمن', 'مؤمن', 'المؤمنين', 'آمنوا'],
      'القلق': ['قلق', 'خوف', 'وجل', 'فزع'],
      'الحزن': ['حزن', 'حزين', 'أحزان', 'كرب', 'هم'],
      'الفرج': ['فرج', 'فرجة', 'مخرج', 'نجاة'],
      'العدل': ['عدل', 'عادل', 'قسط', 'أقسط'],
      'الرحمة': ['رحمة', 'رحيم', 'الرحمن', 'ارحم'],
      'الحب': ['حب', 'محبة', 'أحب', 'يحب', 'حبيب'],
      'الأمل': ['أمل', 'رجاء', 'طمع', 'يرجو'],
      'الخوف': ['خوف', 'خاف', 'يخاف', 'مخافة'],
      'السلام': ['سلام', 'سلم', 'أمن', 'أمان'],
      'الهداية': ['هداية', 'هدى', 'اهد', 'مهتد'],
    });
  }

  List<Ayah> searchByTopic(String topic) {
    final results = <Ayah>[];
    final normalizedTopic = _normalizeText(topic);
    
    // Direct topic match
    if (_topicIndex.containsKey(normalizedTopic)) {
      for (final ref in _topicIndex[normalizedTopic]!) {
        final ayah = DatabaseService.instance.getAyah(ref.surahNumber, ref.ayahNumber);
        if (ayah != null) {
          results.add(ayah);
        }
      }
    }
    
    // Synonym search
    for (final entry in _synonyms.entries) {
      if (entry.value.any((synonym) => normalizedTopic.contains(synonym))) {
        if (_topicIndex.containsKey(entry.key)) {
          for (final ref in _topicIndex[entry.key]!) {
            final ayah = DatabaseService.instance.getAyah(ref.surahNumber, ref.ayahNumber);
            if (ayah != null && !results.contains(ayah)) {
              results.add(ayah);
            }
          }
        }
      }
    }
    
    // Fallback to text search
    if (results.isEmpty) {
      results.addAll(DatabaseService.instance.searchAyahs(topic));
    }
    
    return results;
  }

  List<Ayah> searchByText(String query) {
    final results = <Ayah>[];
    final allSurahs = DatabaseService.instance.getAllSurahs();
    
    for (final surah in allSurahs) {
      for (final ayah in surah.ayahs) {
        if (ayah.text.contains(query)) {
          results.add(ayah);
        }
      }
    }
    
    return results;
  }

  List<QuranTopic> getTopicsByKeyword(String keyword) {
    final topics = <QuranTopic>[];
    final normalizedKeyword = _normalizeText(keyword);
    
    for (final entry in _topicIndex.entries) {
      final topicName = entry.key;
      final synonyms = _synonyms[topicName] ?? [];
      
      if (topicName.contains(normalizedKeyword) || 
          synonyms.any((synonym) => synonym.contains(normalizedKeyword))) {
        topics.add(QuranTopic(
          name: topicName,
          description: _getTopicDescription(topicName),
          keywords: synonyms,
          ayahs: entry.value,
        ));
      }
    }
    
    return topics;
  }

  List<String> getAllTopics() {
    return _topicIndex.keys.toList()..sort();
  }

  List<Ayah> getAyahsByLifeSituation(String situation) {
    final situationMap = {
      'مريض': ['الصبر', 'الشفاء', 'الدعاء'],
      'حزين': ['الحزن', 'الفرج', 'الأمل'],
      'قلق': ['القلق', 'السلام', 'الطمأنينة'],
      'فقير': ['الرزق', 'الصبر', 'الدعاء'],
      'خائف': ['الخوف', 'الأمان', 'التوكل'],
      'مذنب': ['التوبة', 'الرحمة', 'المغفرة'],
      'ضائع': ['الهداية', 'الطريق', 'النور'],
      'وحيد': ['الصحبة', 'الأنس', 'الله'],
    };
    
    final results = <Ayah>[];
    final normalizedSituation = _normalizeText(situation);
    
    for (final entry in situationMap.entries) {
      if (normalizedSituation.contains(entry.key)) {
        for (final topic in entry.value) {
          results.addAll(searchByTopic(topic));
        }
        break;
      }
    }
    
    return results.take(10).toList(); // Limit results
  }

  String _normalizeText(String text) {
    return text
        .replaceAll('أ', 'ا')
        .replaceAll('إ', 'ا')
        .replaceAll('آ', 'ا')
        .replaceAll('ة', 'ه')
        .replaceAll('ى', 'ي')
        .toLowerCase()
        .trim();
  }

  String _getTopicDescription(String topic) {
    final descriptions = {
      'الصبر': 'الثبات على الطاعة والابتعاد عن المعصية وتحمل البلاء',
      'التقوى': 'خشية الله والعمل بطاعته واجتناب معاصيه',
      'الرزق': 'ما يسوقه الله للعبد من خير ونعمة',
      'الجنة': 'دار النعيم الأبدي للمؤمنين',
      'النار': 'دار العذاب للكافرين والعاصين',
      'التوبة': 'الرجوع إلى الله والندم على الذنب',
      'الدعاء': 'التوجه إلى الله بالسؤال والطلب',
      'الشكر': 'الاعتراف بنعم الله والثناء عليه',
      'العلم': 'المعرفة النافعة التي تقرب إلى الله',
      'الإيمان': 'التصديق بالله ورسله وكتبه',
    };
    
    return descriptions[topic] ?? 'موضوع قرآني مهم';
  }
}