import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../services/memorization_service.dart';
import '../services/database_service.dart';
import '../models/quran_models.dart';

class MemorizationScreen extends StatefulWidget {
  @override
  _MemorizationScreenState createState() => _MemorizationScreenState();
}

class _MemorizationScreenState extends State<MemorizationScreen> {
  List<MemorizationProgress> _progressList = [];
  List<Ayah> _reviewAyahs = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMemorizationData();
  }

  Future<void> _loadMemorizationData() async {
    try {
      final progressList = DatabaseService.instance.getAllMemorizationProgress();
      final reviewAyahs = MemorizationService.instance.getAyahsForReview();
      
      setState(() {
        _progressList = progressList;
        _reviewAyahs = reviewAyahs;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading memorization data: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'الحفظ والمراجعة',
          style: TextStyle(
            fontFamily: 'NotoSansArabic',
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Color(0xFF1B4332),
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Review Section
                  _buildReviewSection(),
                  
                  SizedBox(height: 24),
                  
                  // Progress Section
                  _buildProgressSection(),
                  
                  SizedBox(height: 24),
                  
                  // Statistics Section
                  _buildStatisticsSection(),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddMemorizationDialog(),
        backgroundColor: Color(0xFF1B4332),
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildReviewSection() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.refresh, color: Color(0xFF1B4332)),
                SizedBox(width: 8),
                Text(
                  'مراجعة اليوم',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'NotoSansArabic',
                  ),
                ),
              ],
            ),
            
            SizedBox(height: 16),
            
            if (_reviewAyahs.isEmpty)
              Text(
                'لا توجد آيات للمراجعة اليوم',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                  fontFamily: 'NotoSansArabic',
                ),
              )
            else
              Column(
                children: _reviewAyahs.take(3).map((ayah) => 
                  _buildReviewAyahCard(ayah)
                ).toList(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewAyahCard(Ayah ayah) {
    return Card(
      margin: EdgeInsets.only(bottom: 8),
      child: ListTile(
        title: Text(
          ayah.text,
          style: TextStyle(
            fontSize: 16,
            fontFamily: 'Amiri',
          ),
          textAlign: TextAlign.right,
        ),
        subtitle: Text(
          'سورة ${_getSurahName(ayah.surahNumber)} - آية ${ayah.numberInSurah}',
          style: TextStyle(
            fontFamily: 'NotoSansArabic',
          ),
          textAlign: TextAlign.right,
        ),
        trailing: IconButton(
          icon: Icon(Icons.play_arrow, color: Color(0xFF1B4332)),
          onPressed: () => _startReview(ayah),
        ),
      ),
    );
  }

  Widget _buildProgressSection() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.trending_up, color: Color(0xFF1B4332)),
                SizedBox(width: 8),
                Text(
                  'تقدم الحفظ',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'NotoSansArabic',
                  ),
                ),
              ],
            ),
            
            SizedBox(height: 16),
            
            if (_progressList.isEmpty)
              Text(
                'لم تبدأ بحفظ أي آيات بعد',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                  fontFamily: 'NotoSansArabic',
                ),
              )
            else
              Column(
                children: _progressList.take(5).map((progress) => 
                  _buildProgressCard(progress)
                ).toList(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressCard(MemorizationProgress progress) {
    final levelNames = ['مبتدئ', 'متوسط', 'متقدم', 'محفوظ'];
    final levelColors = [Colors.red, Colors.orange, Colors.blue, Colors.green];
    
    return Card(
      margin: EdgeInsets.only(bottom: 8),
      child: ListTile(
        title: Text(
          'سورة ${_getSurahName(progress.surahNumber)} - آية ${progress.ayahNumber}',
          style: TextStyle(
            fontFamily: 'NotoSansArabic',
          ),
          textAlign: TextAlign.right,
        ),
        subtitle: LinearProgressIndicator(
          value: (progress.level + 1) / 4,
          backgroundColor: Colors.grey[300],
          valueColor: AlwaysStoppedAnimation<Color>(
            levelColors[progress.level.clamp(0, 3)],
          ),
        ),
        trailing: Chip(
          label: Text(
            levelNames[progress.level.clamp(0, 3)],
            style: TextStyle(
              color: Colors.white,
              fontFamily: 'NotoSansArabic',
              fontSize: 12,
            ),
          ),
          backgroundColor: levelColors[progress.level.clamp(0, 3)],
        ),
      ),
    );
  }

  Widget _buildStatisticsSection() {
    final totalAyahs = _progressList.length;
    final memorizedAyahs = _progressList.where((p) => p.level >= 3).length;
    final reviewAyahsCount = _reviewAyahs.length;
    
    return Card(
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.analytics, color: Color(0xFF1B4332)),
                SizedBox(width: 8),
                Text(
                  'إحصائيات الحفظ',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'NotoSansArabic',
                  ),
                ),
              ],
            ),
            
            SizedBox(height: 16),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatCard('إجمالي الآيات', totalAyahs.toString()),
                _buildStatCard('آيات محفوظة', memorizedAyahs.toString()),
                _buildStatCard('للمراجعة اليوم', reviewAyahsCount.toString()),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1B4332),
          ),
        ),
        SizedBox(height: 4),
        Text(
          title,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
            fontFamily: 'NotoSansArabic',
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  String _getSurahName(int surahNumber) {
    // This would normally get the actual surah name from database
    final surahNames = {
      1: 'الفاتحة',
      112: 'الإخلاص',
    };
    return surahNames[surahNumber] ?? 'سورة $surahNumber';
  }

  void _startReview(Ayah ayah) {
    // Navigate to review screen or show review dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'مراجعة الآية',
          style: TextStyle(fontFamily: 'NotoSansArabic'),
          textAlign: TextAlign.right,
        ),
        content: Text(
          ayah.text,
          style: TextStyle(
            fontSize: 18,
            fontFamily: 'Amiri',
          ),
          textAlign: TextAlign.right,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'إغلاق',
              style: TextStyle(fontFamily: 'NotoSansArabic'),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              // Mark as reviewed
              Navigator.pop(context);
              _markAsReviewed(ayah);
            },
            child: Text(
              'تمت المراجعة',
              style: TextStyle(fontFamily: 'NotoSansArabic'),
            ),
          ),
        ],
      ),
    );
  }

  void _markAsReviewed(Ayah ayah) {
    // Update review status
    MemorizationService.instance.updateReviewStatus(
      ayah.surahNumber,
      ayah.numberInSurah,
      true,
    );
    _loadMemorizationData();
  }

  void _showAddMemorizationDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'إضافة آية للحفظ',
          style: TextStyle(fontFamily: 'NotoSansArabic'),
          textAlign: TextAlign.right,
        ),
        content: Text(
          'هذه الميزة قيد التطوير',
          style: TextStyle(fontFamily: 'NotoSansArabic'),
          textAlign: TextAlign.right,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'إغلاق',
              style: TextStyle(fontFamily: 'NotoSansArabic'),
            ),
          ),
        ],
      ),
    );
  }
}