import 'package:flutter/material.dart';
import 'dart:math';

class SpiritualQuoteCard extends StatefulWidget {
  @override
  _SpiritualQuoteCardState createState() => _SpiritualQuoteCardState();
}

class _SpiritualQuoteCardState extends State<SpiritualQuoteCard> {
  final List<Map<String, String>> _quotes = [
    {
      'text': 'وَمَن يَتَّقِ اللَّهَ يَجْعَل لَّهُ مَخْرَجًا',
      'translation': 'ومن يتق الله يجعل له مخرجاً',
      'reference': 'الطلاق: 2',
      'reflection': 'التقوى هي المفتاح لكل مخرج من الضيق والهم',
    },
    {
      'text': 'وَبَشِّرِ الصَّابِرِينَ',
      'translation': 'وبشر الصابرين',
      'reference': 'البقرة: 155',
      'reflection': 'الصبر مفتاح الفرج وطريق إلى رضا الله',
    },
    {
      'text': 'فَإِنَّ مَعَ الْعُسْرِ يُسْرًا',
      'translation': 'فإن مع العسر يسراً',
      'reference': 'الشرح: 5',
      'reflection': 'بعد كل صعوبة تأتي السهولة والفرج من الله',
    },
    {
      'text': 'وَهُوَ مَعَكُمْ أَيْنَ مَا كُنتُمْ',
      'translation': 'وهو معكم أين ما كنتم',
      'reference': 'الحديد: 4',
      'reflection': 'الله معنا في كل مكان وزمان، لا نخاف ولا نحزن',
    },
    {
      'text': 'وَمَن يَتَوَكَّلْ عَلَى اللَّهِ فَهُوَ حَسْبُهُ',
      'translation': 'ومن يتوكل على الله فهو حسبه',
      'reference': 'الطلاق: 3',
      'reflection': 'التوكل على الله كافٍ لكل من يؤمن ويثق به',
    },
    {
      'text': 'وَاللَّهُ غَالِبٌ عَلَىٰ أَمْرِهِ',
      'translation': 'والله غالب على أمره',
      'reference': 'يوسف: 21',
      'reflection': 'أمر الله نافذ وحكمته بالغة في كل شيء',
    },
    {
      'text': 'رَبَّنَا آتِنَا فِي الدُّنْيَا حَسَنَةً وَفِي الْآخِرَةِ حَسَنَةً',
      'translation': 'ربنا آتنا في الدنيا حسنة وفي الآخرة حسنة',
      'reference': 'البقرة: 201',
      'reflection': 'دعاء جامع لخير الدنيا والآخرة',
    },
    {
      'text': 'وَمَا تَوْفِيقِي إِلَّا بِاللَّهِ',
      'translation': 'وما توفيقي إلا بالله',
      'reference': 'هود: 88',
      'reflection': 'كل توفيق ونجاح في الحياة هو من عند الله',
    },
  ];

  late Map<String, String> _currentQuote;

  @override
  void initState() {
    super.initState();
    _selectRandomQuote();
  }

  void _selectRandomQuote() {
    final random = Random();
    _currentQuote = _quotes[random.nextInt(_quotes.length)];
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [
              Colors.teal[50]!,
              Colors.teal[100]!,
            ],
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
                    Icons.format_quote,
                    color: Colors.teal[700],
                    size: 28,
                  ),
                  SizedBox(width: 12),
                  Text(
                    'تأمل يومي',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.teal[700],
                    ),
                  ),
                  Spacer(),
                  IconButton(
                    onPressed: () {
                      setState(() {
                        _selectRandomQuote();
                      });
                    },
                    icon: Icon(
                      Icons.refresh,
                      color: Colors.teal[600],
                    ),
                    tooltip: 'آية جديدة',
                  ),
                ],
              ),
              SizedBox(height: 16),
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.teal[200]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _currentQuote['text']!,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.teal[800],
                        fontFamily: 'Amiri',
                        height: 1.8,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.teal[100],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            _currentQuote['reference']!,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.teal[700],
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 12),
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.teal[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.teal[100]!),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.lightbulb_outline,
                      color: Colors.teal[600],
                      size: 20,
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _currentQuote['reflection']!,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.teal[700],
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        _shareQuote();
                      },
                      icon: Icon(Icons.share, size: 18),
                      label: Text('مشاركة'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal[600],
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        _saveToFavorites();
                      },
                      icon: Icon(Icons.favorite_outline, size: 18),
                      label: Text('حفظ'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.teal[600],
                        side: BorderSide(color: Colors.teal[600]!),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _shareQuote() {
    final text = '''
${_currentQuote['text']}

${_currentQuote['reflection']}

المرجع: ${_currentQuote['reference']}

من تطبيق حسناتي - القرآن الكريم والأذكار
''';
    
    // In a real app, you would use share_plus package
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('تم نسخ النص للمشاركة'),
        backgroundColor: Colors.teal[600],
      ),
    );
  }

  void _saveToFavorites() {
    // Save to favorites in database
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('تم حفظ الآية في المفضلة'),
        backgroundColor: Colors.teal[600],
      ),
    );
  }
}