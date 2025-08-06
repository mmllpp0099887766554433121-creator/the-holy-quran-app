import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../services/semantic_search_service.dart';
import '../services/database_service.dart';
import '../models/quran_models.dart';

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Ayah> _searchResults = [];
  bool _isLoading = false;
  String _selectedCategory = 'all';

  final List<Map<String, String>> _categories = [
    {'key': 'all', 'name': 'الكل'},
    {'key': 'patience', 'name': 'الصبر'},
    {'key': 'prayer', 'name': 'الصلاة'},
    {'key': 'charity', 'name': 'الزكاة'},
    {'key': 'forgiveness', 'name': 'المغفرة'},
    {'key': 'guidance', 'name': 'الهداية'},
    {'key': 'paradise', 'name': 'الجنة'},
    {'key': 'hell', 'name': 'النار'},
    {'key': 'faith', 'name': 'الإيمان'},
    {'key': 'knowledge', 'name': 'العلم'},
  ];

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'البحث في القرآن',
          style: TextStyle(
            fontFamily: 'NotoSansArabic',
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Color(0xFF1B4332),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            padding: EdgeInsets.all(16),
            color: Colors.grey[50],
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  textAlign: TextAlign.right,
                  decoration: InputDecoration(
                    hintText: 'ابحث في القرآن الكريم...',
                    hintStyle: TextStyle(fontFamily: 'NotoSansArabic'),
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  style: TextStyle(fontFamily: 'NotoSansArabic'),
                  onSubmitted: (value) => _performSearch(value),
                ),
                
                SizedBox(height: 12),
                
                // Category Filter
                Container(
                  height: 40,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _categories.length,
                    itemBuilder: (context, index) {
                      final category = _categories[index];
                      final isSelected = _selectedCategory == category['key'];
                      
                      return Padding(
                        padding: EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(
                            category['name']!,
                            style: TextStyle(
                              fontFamily: 'NotoSansArabic',
                              color: isSelected ? Colors.white : Color(0xFF1B4332),
                            ),
                          ),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              _selectedCategory = category['key']!;
                            });
                            if (_searchController.text.isNotEmpty) {
                              _performSearch(_searchController.text);
                            }
                          },
                          selectedColor: Color(0xFF1B4332),
                          backgroundColor: Colors.white,
                          side: BorderSide(color: Color(0xFF1B4332)),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          
          // Search Results
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator())
                : _searchResults.isEmpty
                    ? _buildEmptyState()
                    : _buildSearchResults(),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search,
            size: 64,
            color: Colors.grey[400],
          ),
          SizedBox(height: 16),
          Text(
            'ابحث في القرآن الكريم',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontFamily: 'NotoSansArabic',
            ),
          ),
          SizedBox(height: 8),
          Text(
            'يمكنك البحث بالنص أو بالموضوع',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
              fontFamily: 'NotoSansArabic',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults() {
    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final ayah = _searchResults[index];
        return _buildAyahCard(ayah);
      },
    );
  }

  Widget _buildAyahCard(Ayah ayah) {
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // Ayah Text
            Text(
              ayah.text,
              style: TextStyle(
                fontSize: 18,
                fontFamily: 'Amiri',
                height: 1.8,
              ),
              textAlign: TextAlign.right,
            ),
            
            SizedBox(height: 12),
            
            // Ayah Info
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Action Buttons
                Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.bookmark_border, size: 20),
                      onPressed: () => _bookmarkAyah(ayah),
                      color: Color(0xFF1B4332),
                    ),
                    IconButton(
                      icon: Icon(Icons.share, size: 20),
                      onPressed: () => _shareAyah(ayah),
                      color: Color(0xFF1B4332),
                    ),
                    IconButton(
                      icon: Icon(Icons.play_arrow, size: 20),
                      onPressed: () => _playAyah(ayah),
                      color: Color(0xFF1B4332),
                    ),
                  ],
                ),
                
                // Surah and Ayah Number
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Color(0xFF1B4332),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'سورة ${_getSurahName(ayah.surahNumber)} - آية ${ayah.numberInSurah}',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontFamily: 'NotoSansArabic',
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _performSearch(String query) async {
    if (query.trim().isEmpty) return;
    
    setState(() {
      _isLoading = true;
    });

    try {
      List<Ayah> results;
      
      if (_selectedCategory == 'all') {
        // Text search
        results = SemanticSearchService.instance.searchByText(query);
      } else {
        // Topic search
        results = SemanticSearchService.instance.searchByTopic(_selectedCategory);
      }
      
      setState(() {
        _searchResults = results;
        _isLoading = false;
      });
    } catch (e) {
      print('Search error: $e');
      setState(() {
        _searchResults = [];
        _isLoading = false;
      });
    }
  }

  String _getSurahName(int surahNumber) {
    // This would normally get the actual surah name from database
    final surahNames = {
      1: 'الفاتحة',
      112: 'الإخلاص',
    };
    return surahNames[surahNumber] ?? 'سورة $surahNumber';
  }

  void _bookmarkAyah(Ayah ayah) {
    try {
      final bookmark = Bookmark(
        surahNumber: ayah.surahNumber,
        ayahNumber: ayah.numberInSurah,
        note: '',
        createdAt: DateTime.now(),
      );
      
      DatabaseService.instance.addBookmark(bookmark);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'تمت إضافة الآية للمفضلة',
            style: TextStyle(fontFamily: 'NotoSansArabic'),
          ),
          backgroundColor: Color(0xFF1B4332),
        ),
      );
    } catch (e) {
      print('Bookmark error: $e');
    }
  }

  void _shareAyah(Ayah ayah) {
    // Share functionality would be implemented here
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'ميزة المشاركة قيد التطوير',
          style: TextStyle(fontFamily: 'NotoSansArabic'),
        ),
      ),
    );
  }

  void _playAyah(Ayah ayah) {
    // Audio playback would be implemented here
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'ميزة التشغيل الصوتي قيد التطوير',
          style: TextStyle(fontFamily: 'NotoSansArabic'),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}