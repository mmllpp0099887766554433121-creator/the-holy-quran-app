import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:audioplayers/audioplayers.dart';
import '../providers/app_provider.dart';
import '../services/database_service.dart';
import '../services/audio_recitation_service.dart';
import '../models/quran_models.dart';

class QuranReaderScreen extends StatefulWidget {
  @override
  _QuranReaderScreenState createState() => _QuranReaderScreenState();
}

class _QuranReaderScreenState extends State<QuranReaderScreen> {
  final DatabaseService _db = DatabaseService.instance;
  final AudioRecitationService _audioService = AudioRecitationService.instance;
  
  List<Surah> _surahs = [];
  Surah? _currentSurah;
  int _currentAyahIndex = 0;
  bool _isLoading = true;
  bool _showTranslation = false;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _loadSurahs();
    _setupAudioListener();
  }

  Future<void> _loadSurahs() async {
    try {
      final surahs = _db.getAllSurahs();
      setState(() {
        _surahs = surahs;
        if (surahs.isNotEmpty) {
          _currentSurah = surahs[0]; // Start with Al-Fatihah
        }
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _setupAudioListener() {
    _audioService.playerStateStream.listen((state) {
      setState(() {
        _isPlaying = state == PlayerState.playing;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: _buildAppBar(),
      body: _currentSurah == null ? _buildSurahList() : _buildQuranReader(),
      bottomNavigationBar: _currentSurah != null ? _buildBottomControls() : null,
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Text(_currentSurah?.name ?? 'القرآن الكريم'),
      backgroundColor: Colors.green[700],
      foregroundColor: Colors.white,
      actions: [
        if (_currentSurah != null) ...[
          IconButton(
            icon: Icon(_showTranslation ? Icons.translate : Icons.translate_outlined),
            onPressed: () {
              setState(() {
                _showTranslation = !_showTranslation;
              });
            },
          ),
          IconButton(
            icon: Icon(Icons.bookmark_outline),
            onPressed: _addBookmark,
          ),
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () => Navigator.pushNamed(context, '/search'),
          ),
        ],
        PopupMenuButton<String>(
          onSelected: _handleMenuAction,
          itemBuilder: (context) => [
            PopupMenuItem(value: 'font_size', child: Text('حجم الخط')),
            PopupMenuItem(value: 'font_family', child: Text('نوع الخط')),
            PopupMenuItem(value: 'focus_mode', child: Text('وضع التركيز')),
            PopupMenuItem(value: 'night_mode', child: Text('الوضع الليلي')),
          ],
        ),
      ],
    );
  }

  Widget _buildSurahList() {
    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: _surahs.length,
      itemBuilder: (context, index) {
        final surah = _surahs[index];
        return Card(
          margin: EdgeInsets.symmetric(vertical: 4),
          child: ListTile(
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.green[100],
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(
                child: Text(
                  '${surah.number}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.green[700],
                  ),
                ),
              ),
            ),
            title: Text(
              surah.name,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            subtitle: Text(
              '${surah.englishName} • ${surah.numberOfAyahs} آية • ${surah.revelationType == "Meccan" ? "مكية" : "مدنية"}',
              style: TextStyle(fontSize: 12),
            ),
            trailing: Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              setState(() {
                _currentSurah = surah;
                _currentAyahIndex = 0;
              });
              _startReadingSession();
            },
          ),
        );
      },
    );
  }

  Widget _buildQuranReader() {
    final ayahs = _currentSurah!.ayahs;
    
    return Consumer<AppProvider>(
      builder: (context, provider, child) {
        return Container(
          color: provider.isFocusMode ? Colors.black : null,
          child: PageView.builder(
            itemCount: ayahs.length,
            onPageChanged: (index) {
              setState(() {
                _currentAyahIndex = index;
              });
            },
            itemBuilder: (context, index) {
              final ayah = ayahs[index];
              return _buildAyahPage(ayah, provider);
            },
          ),
        );
      },
    );
  }

  Widget _buildAyahPage(Ayah ayah, AppProvider provider) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(24),
      child: Column(
        children: [
          SizedBox(height: 40),
          
          // Ayah number
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.green[100],
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'آية ${ayah.numberInSurah}',
              style: TextStyle(
                color: Colors.green[700],
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          
          SizedBox(height: 40),
          
          // Arabic text
          Container(
            padding: EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: provider.isFocusMode ? Colors.grey[900] : Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            child: Text(
              ayah.text,
              style: TextStyle(
                fontSize: provider.fontSize,
                fontFamily: 'Amiri',
                height: 2.0,
                color: provider.isFocusMode ? Colors.white : Colors.black87,
              ),
              textAlign: TextAlign.center,
              textDirection: TextDirection.rtl,
            ),
          ),
          
          if (_showTranslation) ...[
            SizedBox(height: 20),
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: Text(
                _getAyahTranslation(ayah),
                style: TextStyle(
                  fontSize: provider.fontSize - 2,
                  color: Colors.blue[800],
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
          
          SizedBox(height: 40),
          
          // Action buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildActionButton(
                icon: Icons.play_arrow,
                label: 'تشغيل',
                onPressed: () => _playAyah(ayah),
              ),
              _buildActionButton(
                icon: Icons.bookmark_add,
                label: 'حفظ',
                onPressed: () => _bookmarkAyah(ayah),
              ),
              _buildActionButton(
                icon: Icons.note_add,
                label: 'تأمل',
                onPressed: () => _addReflection(ayah),
              ),
              _buildActionButton(
                icon: Icons.share,
                label: 'مشاركة',
                onPressed: () => _shareAyah(ayah),
              ),
            ],
          ),
          
          SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return Column(
      children: [
        IconButton(
          onPressed: onPressed,
          icon: Icon(icon),
          iconSize: 28,
          style: IconButton.styleFrom(
            backgroundColor: Colors.green[100],
            foregroundColor: Colors.green[700],
          ),
        ),
        SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.green[700],
          ),
        ),
      ],
    );
  }

  Widget _buildBottomControls() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: _previousAyah,
            icon: Icon(Icons.skip_previous),
          ),
          IconButton(
            onPressed: _isPlaying ? _pauseAudio : _playCurrentAyah,
            icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow),
          ),
          IconButton(
            onPressed: _nextAyah,
            icon: Icon(Icons.skip_next),
          ),
          Spacer(),
          Text(
            '${_currentAyahIndex + 1} / ${_currentSurah!.ayahs.length}',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          Spacer(),
          IconButton(
            onPressed: () {
              setState(() {
                _currentSurah = null;
              });
            },
            icon: Icon(Icons.list),
          ),
        ],
      ),
    );
  }

  void _startReadingSession() {
    final provider = Provider.of<AppProvider>(context, listen: false);
    provider.startReadingSession(_currentSurah!.number, _currentAyahIndex + 1);
  }

  void _previousAyah() {
    if (_currentAyahIndex > 0) {
      setState(() {
        _currentAyahIndex--;
      });
    }
  }

  void _nextAyah() {
    if (_currentAyahIndex < _currentSurah!.ayahs.length - 1) {
      setState(() {
        _currentAyahIndex++;
      });
    }
  }

  void _playCurrentAyah() {
    final ayah = _currentSurah!.ayahs[_currentAyahIndex];
    _playAyah(ayah);
  }

  void _playAyah(Ayah ayah) {
    _audioService.playAyah(ayah.surahNumber, ayah.numberInSurah);
  }

  void _pauseAudio() {
    _audioService.pausePlayback();
  }

  void _addBookmark() {
    final ayah = _currentSurah!.ayahs[_currentAyahIndex];
    _bookmarkAyah(ayah);
  }

  void _bookmarkAyah(Ayah ayah) {
    final bookmark = Bookmark(
      surahNumber: ayah.surahNumber,
      ayahNumber: ayah.numberInSurah,
      note: '',
      createdAt: DateTime.now(),
    );
    
    _db.addBookmark(bookmark);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('تم حفظ الآية في الإشارات المرجعية'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _addReflection(Ayah ayah) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('إضافة تأمل'),
        content: TextField(
          maxLines: 4,
          decoration: InputDecoration(
            hintText: 'اكتب تأملك على هذه الآية...',
            border: OutlineInputBorder(),
          ),
          onSubmitted: (text) {
            if (text.isNotEmpty) {
              final note = SpiritualNote(
                surahNumber: ayah.surahNumber,
                ayahNumber: ayah.numberInSurah,
                note: text,
                createdAt: DateTime.now(),
              );
              
              _db.addSpiritualNote(note);
              Navigator.pop(context);
              
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('تم حفظ التأمل'),
                  backgroundColor: Colors.green,
                ),
              );
            }
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('إلغاء'),
          ),
        ],
      ),
    );
  }

  void _shareAyah(Ayah ayah) {
    // Implementation for sharing ayah
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('تم نسخ الآية للمشاركة')),
    );
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'font_size':
        _showFontSizeDialog();
        break;
      case 'font_family':
        _showFontFamilyDialog();
        break;
      case 'focus_mode':
        Provider.of<AppProvider>(context, listen: false).toggleFocusMode();
        break;
      case 'night_mode':
        Provider.of<AppProvider>(context, listen: false).setTheme(
          Provider.of<AppProvider>(context, listen: false).isDark 
            ? ThemeMode.light 
            : ThemeMode.dark
        );
        break;
    }
  }

  void _showFontSizeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('حجم الخط'),
        content: Consumer<AppProvider>(
          builder: (context, provider, child) {
            return Slider(
              value: provider.fontSize,
              min: 14.0,
              max: 32.0,
              divisions: 9,
              label: provider.fontSize.round().toString(),
              onChanged: (value) {
                provider.setFontSize(value);
              },
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('تم'),
          ),
        ],
      ),
    );
  }

  void _showFontFamilyDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('نوع الخط'),
        content: Consumer<AppProvider>(
          builder: (context, provider, child) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                RadioListTile<String>(
                  title: Text('عميري', style: TextStyle(fontFamily: 'Amiri')),
                  value: 'Amiri',
                  groupValue: provider.fontFamily,
                  onChanged: (value) {
                    if (value != null) provider.setFontFamily(value);
                  },
                ),
                RadioListTile<String>(
                  title: Text('شهرزاد', style: TextStyle(fontFamily: 'Scheherazade')),
                  value: 'Scheherazade',
                  groupValue: provider.fontFamily,
                  onChanged: (value) {
                    if (value != null) provider.setFontFamily(value);
                  },
                ),
              ],
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('تم'),
          ),
        ],
      ),
    );
  }

  String _getAyahTranslation(Ayah ayah) {
    // This would normally come from a translation database
    return 'ترجمة الآية ${ayah.numberInSurah} من سورة ${_currentSurah!.name}';
  }

  @override
  void dispose() {
    final provider = Provider.of<AppProvider>(context, listen: false);
    provider.endReadingSession();
    super.dispose();
  }
}