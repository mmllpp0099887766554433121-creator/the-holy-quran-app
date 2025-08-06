import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'الإعدادات',
          style: TextStyle(
            fontFamily: 'NotoSansArabic',
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Color(0xFF1B4332),
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          // Theme Settings
          _buildSettingsSection(
            'المظهر',
            [
              _buildThemeSelector(provider),
              _buildFontSizeSlider(provider),
            ],
          ),
          
          SizedBox(height: 24),
          
          // Language Settings
          _buildSettingsSection(
            'اللغة',
            [
              _buildLanguageSelector(provider),
            ],
          ),
          
          SizedBox(height: 24),
          
          // Notification Settings
          _buildSettingsSection(
            'الإشعارات',
            [
              _buildNotificationToggle(provider),
              _buildPrayerNotificationToggle(provider),
            ],
          ),
          
          SizedBox(height: 24),
          
          // Reading Settings
          _buildSettingsSection(
            'إعدادات القراءة',
            [
              _buildAutoScrollToggle(),
              _buildHighlightToggle(),
            ],
          ),
          
          SizedBox(height: 24),
          
          // Data Management
          _buildSettingsSection(
            'إدارة البيانات',
            [
              _buildBackupButton(),
              _buildRestoreButton(),
              _buildClearDataButton(),
            ],
          ),
          
          SizedBox(height: 24),
          
          // About
          _buildSettingsSection(
            'حول التطبيق',
            [
              _buildAboutTile(),
              _buildVersionTile(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsSection(String title, List<Widget> children) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1B4332),
                fontFamily: 'NotoSansArabic',
              ),
            ),
            SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildThemeSelector(AppProvider provider) {
    return ListTile(
      leading: Icon(Icons.palette, color: Color(0xFF1B4332)),
      title: Text(
        'المظهر',
        style: TextStyle(fontFamily: 'NotoSansArabic'),
      ),
      subtitle: Text(
        provider.isDark ? 'الوضع الليلي' : 'الوضع النهاري',
        style: TextStyle(fontFamily: 'NotoSansArabic'),
      ),
      trailing: Switch(
        value: provider.isDark,
        onChanged: (value) {
          provider.setTheme(value ? ThemeMode.dark : ThemeMode.light);
        },
        activeColor: Color(0xFF1B4332),
      ),
    );
  }

  Widget _buildFontSizeSlider(AppProvider provider) {
    return ListTile(
      leading: Icon(Icons.text_fields, color: Color(0xFF1B4332)),
      title: Text(
        'حجم الخط',
        style: TextStyle(fontFamily: 'NotoSansArabic'),
      ),
      subtitle: Slider(
        value: provider.fontSize,
        min: 12.0,
        max: 24.0,
        divisions: 6,
        label: provider.fontSize.round().toString(),
        onChanged: (value) {
          provider.setFontSize(value);
        },
        activeColor: Color(0xFF1B4332),
      ),
    );
  }

  Widget _buildLanguageSelector(AppProvider provider) {
    return ListTile(
      leading: Icon(Icons.language, color: Color(0xFF1B4332)),
      title: Text(
        'اللغة',
        style: TextStyle(fontFamily: 'NotoSansArabic'),
      ),
      subtitle: Text(
        provider.isArabic ? 'العربية' : 'English',
        style: TextStyle(fontFamily: 'NotoSansArabic'),
      ),
      trailing: DropdownButton<String>(
        value: provider.locale.languageCode,
        items: [
          DropdownMenuItem(
            value: 'ar',
            child: Text('العربية', style: TextStyle(fontFamily: 'NotoSansArabic')),
          ),
          DropdownMenuItem(
            value: 'en',
            child: Text('English'),
          ),
        ],
        onChanged: (value) {
          if (value != null) {
            provider.setLocale(Locale(value));
          }
        },
      ),
    );
  }

  Widget _buildNotificationToggle(AppProvider provider) {
    return SwitchListTile(
      secondary: Icon(Icons.notifications, color: Color(0xFF1B4332)),
      title: Text(
        'الإشعارات',
        style: TextStyle(fontFamily: 'NotoSansArabic'),
      ),
      subtitle: Text(
        'تفعيل الإشعارات العامة',
        style: TextStyle(fontFamily: 'NotoSansArabic'),
      ),
      value: true, // This would be from provider
      onChanged: (value) {
        // Implement notification toggle
      },
      activeColor: Color(0xFF1B4332),
    );
  }

  Widget _buildPrayerNotificationToggle(AppProvider provider) {
    return SwitchListTile(
      secondary: Icon(Icons.access_time, color: Color(0xFF1B4332)),
      title: Text(
        'تذكير الصلاة',
        style: TextStyle(fontFamily: 'NotoSansArabic'),
      ),
      subtitle: Text(
        'تذكير بأوقات الصلاة',
        style: TextStyle(fontFamily: 'NotoSansArabic'),
      ),
      value: provider.prayerNotifications,
      onChanged: (value) {
        // Implement prayer notification toggle
      },
      activeColor: Color(0xFF1B4332),
    );
  }

  Widget _buildAutoScrollToggle() {
    return SwitchListTile(
      secondary: Icon(Icons.auto_stories, color: Color(0xFF1B4332)),
      title: Text(
        'التمرير التلقائي',
        style: TextStyle(fontFamily: 'NotoSansArabic'),
      ),
      subtitle: Text(
        'تمرير تلقائي أثناء القراءة',
        style: TextStyle(fontFamily: 'NotoSansArabic'),
      ),
      value: false, // This would be from provider
      onChanged: (value) {
        // Implement auto scroll toggle
      },
      activeColor: Color(0xFF1B4332),
    );
  }

  Widget _buildHighlightToggle() {
    return SwitchListTile(
      secondary: Icon(Icons.highlight, color: Color(0xFF1B4332)),
      title: Text(
        'تمييز الآيات',
        style: TextStyle(fontFamily: 'NotoSansArabic'),
      ),
      subtitle: Text(
        'تمييز الآية الحالية',
        style: TextStyle(fontFamily: 'NotoSansArabic'),
      ),
      value: true, // This would be from provider
      onChanged: (value) {
        // Implement highlight toggle
      },
      activeColor: Color(0xFF1B4332),
    );
  }

  Widget _buildBackupButton() {
    return ListTile(
      leading: Icon(Icons.backup, color: Color(0xFF1B4332)),
      title: Text(
        'نسخ احتياطي',
        style: TextStyle(fontFamily: 'NotoSansArabic'),
      ),
      subtitle: Text(
        'إنشاء نسخة احتياطية من البيانات',
        style: TextStyle(fontFamily: 'NotoSansArabic'),
      ),
      trailing: Icon(Icons.arrow_forward_ios),
      onTap: () {
        _showBackupDialog();
      },
    );
  }

  Widget _buildRestoreButton() {
    return ListTile(
      leading: Icon(Icons.restore, color: Color(0xFF1B4332)),
      title: Text(
        'استعادة البيانات',
        style: TextStyle(fontFamily: 'NotoSansArabic'),
      ),
      subtitle: Text(
        'استعادة من نسخة احتياطية',
        style: TextStyle(fontFamily: 'NotoSansArabic'),
      ),
      trailing: Icon(Icons.arrow_forward_ios),
      onTap: () {
        _showRestoreDialog();
      },
    );
  }

  Widget _buildClearDataButton() {
    return ListTile(
      leading: Icon(Icons.delete_forever, color: Colors.red),
      title: Text(
        'مسح البيانات',
        style: TextStyle(fontFamily: 'NotoSansArabic', color: Colors.red),
      ),
      subtitle: Text(
        'مسح جميع البيانات المحفوظة',
        style: TextStyle(fontFamily: 'NotoSansArabic'),
      ),
      trailing: Icon(Icons.arrow_forward_ios),
      onTap: () {
        _showClearDataDialog();
      },
    );
  }

  Widget _buildAboutTile() {
    return ListTile(
      leading: Icon(Icons.info, color: Color(0xFF1B4332)),
      title: Text(
        'حول التطبيق',
        style: TextStyle(fontFamily: 'NotoSansArabic'),
      ),
      subtitle: Text(
        'معلومات عن التطبيق والمطور',
        style: TextStyle(fontFamily: 'NotoSansArabic'),
      ),
      trailing: Icon(Icons.arrow_forward_ios),
      onTap: () {
        _showAboutDialog();
      },
    );
  }

  Widget _buildVersionTile() {
    return ListTile(
      leading: Icon(Icons.code, color: Color(0xFF1B4332)),
      title: Text(
        'إصدار التطبيق',
        style: TextStyle(fontFamily: 'NotoSansArabic'),
      ),
      subtitle: Text(
        'الإصدار 1.0.0',
        style: TextStyle(fontFamily: 'NotoSansArabic'),
      ),
    );
  }

  void _showBackupDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'نسخ احتياطي',
          style: TextStyle(fontFamily: 'NotoSansArabic'),
        ),
        content: Text(
          'هذه الميزة قيد التطوير',
          style: TextStyle(fontFamily: 'NotoSansArabic'),
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

  void _showRestoreDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'استعادة البيانات',
          style: TextStyle(fontFamily: 'NotoSansArabic'),
        ),
        content: Text(
          'هذه الميزة قيد التطوير',
          style: TextStyle(fontFamily: 'NotoSansArabic'),
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

  void _showClearDataDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'تحذير',
          style: TextStyle(fontFamily: 'NotoSansArabic', color: Colors.red),
        ),
        content: Text(
          'هل أنت متأكد من مسح جميع البيانات؟ لا يمكن التراجع عن هذا الإجراء.',
          style: TextStyle(fontFamily: 'NotoSansArabic'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'إلغاء',
              style: TextStyle(fontFamily: 'NotoSansArabic'),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Implement clear data functionality
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text(
              'مسح البيانات',
              style: TextStyle(fontFamily: 'NotoSansArabic', color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'حول التطبيق',
          style: TextStyle(fontFamily: 'NotoSansArabic'),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'حسناتي - القرآن الكريم والأذكار',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontFamily: 'NotoSansArabic',
              ),
            ),
            SizedBox(height: 8),
            Text(
              'تطبيق شامل للقرآن الكريم مع ميزات متقدمة للحفظ والمراجعة والبحث الدلالي.',
              style: TextStyle(fontFamily: 'NotoSansArabic'),
            ),
            SizedBox(height: 16),
            Text(
              'الميزات:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontFamily: 'NotoSansArabic',
              ),
            ),
            Text(
              '• مساعد ذكي للحفظ\n• البحث الدلالي\n• نظام المراجعة المتباعدة\n• التأمل اليومي\n• الألعاب القرآنية\n• يعمل بدون إنترنت',
              style: TextStyle(fontFamily: 'NotoSansArabic'),
            ),
          ],
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