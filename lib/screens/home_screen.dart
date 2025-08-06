import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../services/database_service.dart';
import '../services/challenge_service.dart';
import '../widgets/daily_challenge_card.dart';
import '../widgets/reading_progress_card.dart';
import '../widgets/quick_actions_grid.dart';
import '../widgets/spiritual_quote_card.dart';
import '../widgets/prayer_times_card.dart';
import '../widgets/achievements_preview.dart';
import 'quran_reader_screen.dart';
import 'memorization_screen.dart';
import 'search_screen.dart';
// import 'achievements_screen.dart'; // TODO: Create achievements screen
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final DatabaseService _db = DatabaseService.instance;
  final ChallengeService _challengeService = ChallengeService.instance;
  
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    await _db.initialize();
    await _challengeService.generateTodayChallenge();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _buildAppBar(),
          SliverPadding(
            padding: EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildGreeting(),
                SizedBox(height: 16),
                DailyChallengeCard(),
                SizedBox(height: 16),
                ReadingProgressCard(),
                SizedBox(height: 16),
                QuickActionsGrid(),
                SizedBox(height: 16),
                SpiritualQuoteCard(),
                SizedBox(height: 16),
                PrayerTimesCard(),
                SizedBox(height: 16),
                AchievementsPreview(),
                SizedBox(height: 100), // Bottom padding for navigation
              ]),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNavigation(),
      floatingActionButton: _buildFloatingActionButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 120,
      floating: false,
      pinned: true,
      backgroundColor: Colors.green[700],
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          'حسناتي',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.green[800]!,
                Colors.green[600]!,
              ],
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: 40),
                Icon(
                  Icons.book,
                  color: Colors.white,
                  size: 32,
                ),
                Text(
                  'القرآن الكريم والأذكار',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.search, color: Colors.white),
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => SearchScreen()),
          ),
        ),
        IconButton(
          icon: Icon(Icons.settings, color: Colors.white),
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => SettingsScreen()),
          ),
        ),
      ],
    );
  }

  Widget _buildGreeting() {
    final hour = DateTime.now().hour;
    String greeting;
    
    if (hour < 12) {
      greeting = 'صباح الخير';
    } else if (hour < 17) {
      greeting = 'مساء الخير';
    } else {
      greeting = 'مساء الخير';
    }
    
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green[200]!),
      ),
      child: Row(
        children: [
          Icon(
            Icons.wb_sunny,
            color: Colors.orange,
            size: 32,
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  greeting,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.green[800],
                  ),
                ),
                Text(
                  'بارك الله في يومك',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.green[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigation() {
    return Consumer<AppProvider>(
      builder: (context, provider, child) {
        return BottomAppBar(
          shape: CircularNotchedRectangle(),
          notchMargin: 8,
          child: Container(
            height: 60,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(
                  icon: Icons.home,
                  label: 'الرئيسية',
                  isSelected: provider.currentIndex == 0,
                  onTap: () => provider.setCurrentIndex(0),
                ),
                _buildNavItem(
                  icon: Icons.book,
                  label: 'القرآن',
                  isSelected: provider.currentIndex == 1,
                  onTap: () {
                    provider.setCurrentIndex(1);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => QuranReaderScreen()),
                    );
                  },
                ),
                SizedBox(width: 40), // Space for FAB
                _buildNavItem(
                  icon: Icons.psychology,
                  label: 'الحفظ',
                  isSelected: provider.currentIndex == 2,
                  onTap: () {
                    provider.setCurrentIndex(2);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => MemorizationScreen()),
                    );
                  },
                ),
                _buildNavItem(
                  icon: Icons.emoji_events,
                  label: 'الإنجازات',
                  isSelected: provider.currentIndex == 3,
                  onTap: () {
                    provider.setCurrentIndex(3);
                    // TODO: Navigate to achievements screen
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'شاشة الإنجازات قيد التطوير',
                          style: TextStyle(fontFamily: 'NotoSansArabic'),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.green[700] : Colors.grey[600],
              size: 24,
            ),
            SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: isSelected ? Colors.green[700] : Colors.grey[600],
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return FloatingActionButton(
      onPressed: () {
        _showQuickActionsBottomSheet();
      },
      backgroundColor: Colors.green[700],
      child: Icon(Icons.add, color: Colors.white),
    );
  }

  void _showQuickActionsBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            SizedBox(height: 20),
            Text(
              'إجراءات سريعة',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),
            GridView.count(
              shrinkWrap: true,
              crossAxisCount: 3,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              children: [
                _buildQuickAction(
                  icon: Icons.play_arrow,
                  label: 'تلاوة',
                  color: Colors.blue,
                  onTap: () {
                    Navigator.pop(context);
                    // Navigate to recitation
                  },
                ),
                _buildQuickAction(
                  icon: Icons.bookmark_add,
                  label: 'إشارة مرجعية',
                  color: Colors.orange,
                  onTap: () {
                    Navigator.pop(context);
                    // Add bookmark
                  },
                ),
                _buildQuickAction(
                  icon: Icons.note_add,
                  label: 'تأمل',
                  color: Colors.purple,
                  onTap: () {
                    Navigator.pop(context);
                    // Add reflection
                  },
                ),
                _buildQuickAction(
                  icon: Icons.quiz,
                  label: 'اختبار',
                  color: Colors.red,
                  onTap: () {
                    Navigator.pop(context);
                    // Start quiz
                  },
                ),
                _buildQuickAction(
                  icon: Icons.search,
                  label: 'بحث',
                  color: Colors.green,
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => SearchScreen()),
                    );
                  },
                ),
                _buildQuickAction(
                  icon: Icons.timer,
                  label: 'تأمل يومي',
                  color: Colors.teal,
                  onTap: () {
                    Navigator.pop(context);
                    // Show daily reflection
                  },
                ),
              ],
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickAction({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 32),
            SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: color,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}