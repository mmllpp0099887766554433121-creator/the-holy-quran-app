import 'package:flutter/material.dart';

class QuickActionsGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'إجراءات سريعة',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            SizedBox(height: 16),
            GridView.count(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              crossAxisCount: 4,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              children: [
                _buildActionItem(
                  context,
                  icon: Icons.book_outlined,
                  label: 'قراءة',
                  color: Colors.blue,
                  onTap: () => Navigator.pushNamed(context, '/quran-reader'),
                ),
                _buildActionItem(
                  context,
                  icon: Icons.psychology_outlined,
                  label: 'حفظ',
                  color: Colors.purple,
                  onTap: () => Navigator.pushNamed(context, '/memorization'),
                ),
                _buildActionItem(
                  context,
                  icon: Icons.search_outlined,
                  label: 'بحث',
                  color: Colors.green,
                  onTap: () => Navigator.pushNamed(context, '/search'),
                ),
                _buildActionItem(
                  context,
                  icon: Icons.headphones_outlined,
                  label: 'استماع',
                  color: Colors.orange,
                  onTap: () => Navigator.pushNamed(context, '/audio-player'),
                ),
                _buildActionItem(
                  context,
                  icon: Icons.bookmark_outline,
                  label: 'مرجعية',
                  color: Colors.red,
                  onTap: () => Navigator.pushNamed(context, '/bookmarks'),
                ),
                _buildActionItem(
                  context,
                  icon: Icons.quiz_outlined,
                  label: 'اختبار',
                  color: Colors.teal,
                  onTap: () => Navigator.pushNamed(context, '/quiz'),
                ),
                _buildActionItem(
                  context,
                  icon: Icons.lightbulb_outline,
                  label: 'تدبر',
                  color: Colors.amber,
                  onTap: () => Navigator.pushNamed(context, '/reflection'),
                ),
                _buildActionItem(
                  context,
                  icon: Icons.favorite_outline,
                  label: 'أذكار',
                  color: Colors.pink,
                  onTap: () => Navigator.pushNamed(context, '/dhikr'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionItem(
    BuildContext context, {
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
            Icon(
              icon,
              color: color,
              size: 28,
            ),
            SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: color,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}