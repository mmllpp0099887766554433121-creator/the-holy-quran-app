import 'package:flutter/material.dart';
import '../models/quran_models.dart';
import '../services/challenge_service.dart';

class DailyChallengeCard extends StatefulWidget {
  @override
  _DailyChallengeCardState createState() => _DailyChallengeCardState();
}

class _DailyChallengeCardState extends State<DailyChallengeCard> {
  final ChallengeService _challengeService = ChallengeService.instance;
  DailyChallenge? _todayChallenge;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTodayChallenge();
  }

  Future<void> _loadTodayChallenge() async {
    try {
      final challenge = await _challengeService.generateTodayChallenge();
      setState(() {
        _todayChallenge = challenge;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return _buildLoadingCard();
    }

    if (_todayChallenge == null) {
      return _buildErrorCard();
    }

    return Card(
      elevation: 4,
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: _todayChallenge!.completed
                ? [Colors.green[400]!, Colors.green[600]!]
                : [Colors.blue[400]!, Colors.blue[600]!],
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    _todayChallenge!.completed 
                        ? Icons.check_circle 
                        : Icons.today,
                    color: Colors.white,
                    size: 28,
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'التحدي اليومي',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  if (_todayChallenge!.completed)
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'مكتمل',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
              SizedBox(height: 16),
              Text(
                _todayChallenge!.title,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 8),
              Text(
                _todayChallenge!.description,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 14,
                ),
              ),
              SizedBox(height: 16),
              Row(
                children: [
                  _buildChallengeTypeChip(),
                  Spacer(),
                  if (!_todayChallenge!.completed)
                    ElevatedButton(
                      onPressed: _startChallenge,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.blue[600],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: Text('ابدأ التحدي'),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChallengeTypeChip() {
    final typeInfo = _getChallengeTypeInfo(_todayChallenge!.type);
    
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            typeInfo['icon'],
            color: Colors.white,
            size: 16,
          ),
          SizedBox(width: 4),
          Text(
            typeInfo['label'],
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Map<String, dynamic> _getChallengeTypeInfo(String type) {
    switch (type) {
      case 'read':
        return {'icon': Icons.book, 'label': 'قراءة'};
      case 'memorize':
        return {'icon': Icons.psychology, 'label': 'حفظ'};
      case 'reflect':
        return {'icon': Icons.lightbulb, 'label': 'تدبر'};
      case 'listen':
        return {'icon': Icons.headphones, 'label': 'استماع'};
      case 'review':
        return {'icon': Icons.refresh, 'label': 'مراجعة'};
      case 'search':
        return {'icon': Icons.search, 'label': 'بحث'};
      case 'dhikr':
        return {'icon': Icons.favorite, 'label': 'ذكر'};
      default:
        return {'icon': Icons.star, 'label': 'تحدي'};
    }
  }

  Widget _buildLoadingCard() {
    return Card(
      elevation: 4,
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        height: 150,
        child: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.blue[600]!),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorCard() {
    return Card(
      elevation: 4,
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        height: 150,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, color: Colors.grey[600], size: 48),
              SizedBox(height: 8),
              Text(
                'لا يمكن تحميل التحدي اليومي',
                style: TextStyle(color: Colors.grey[600]),
              ),
              SizedBox(height: 8),
              ElevatedButton(
                onPressed: _loadTodayChallenge,
                child: Text('إعادة المحاولة'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _startChallenge() {
    // Navigate to appropriate screen based on challenge type
    switch (_todayChallenge!.type) {
      case 'read':
        _startReadingChallenge();
        break;
      case 'memorize':
        _startMemorizationChallenge();
        break;
      case 'reflect':
        _startReflectionChallenge();
        break;
      case 'listen':
        _startListeningChallenge();
        break;
      case 'review':
        _startReviewChallenge();
        break;
      case 'search':
        _startSearchChallenge();
        break;
      case 'dhikr':
        _startDhikrChallenge();
        break;
    }
  }

  void _startReadingChallenge() {
    // Navigate to Quran reader
    Navigator.pushNamed(context, '/quran-reader');
  }

  void _startMemorizationChallenge() {
    // Navigate to memorization screen
    Navigator.pushNamed(context, '/memorization');
  }

  void _startReflectionChallenge() {
    // Show reflection dialog
    _showReflectionDialog();
  }

  void _startListeningChallenge() {
    // Navigate to audio player
    Navigator.pushNamed(context, '/audio-player');
  }

  void _startReviewChallenge() {
    // Navigate to review screen
    Navigator.pushNamed(context, '/review');
  }

  void _startSearchChallenge() {
    // Navigate to search screen
    Navigator.pushNamed(context, '/search');
  }

  void _startDhikrChallenge() {
    // Navigate to dhikr counter
    Navigator.pushNamed(context, '/dhikr');
  }

  void _showReflectionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('تأمل يومي'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_todayChallenge!.description),
            SizedBox(height: 16),
            TextField(
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'اكتب تأملك هنا...',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              // Save reflection and mark challenge as complete
              _completeChallenge();
              Navigator.pop(context);
            },
            child: Text('حفظ'),
          ),
        ],
      ),
    );
  }

  Future<void> _completeChallenge() async {
    try {
      await _challengeService.completeChallenge(
        _todayChallenge!.id,
        {'completed': true},
      );
      
      setState(() {
        _todayChallenge = DailyChallenge(
          id: _todayChallenge!.id,
          title: _todayChallenge!.title,
          description: _todayChallenge!.description,
          date: _todayChallenge!.date,
          completed: true,
          type: _todayChallenge!.type,
          parameters: _todayChallenge!.parameters,
        );
      });
      
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('🎉 أحسنت! لقد أكملت التحدي اليومي'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('حدث خطأ أثناء إكمال التحدي'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}