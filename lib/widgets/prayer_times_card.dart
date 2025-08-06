import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class PrayerTimesCard extends StatefulWidget {
  @override
  _PrayerTimesCardState createState() => _PrayerTimesCardState();
}

class _PrayerTimesCardState extends State<PrayerTimesCard> {
  final List<Map<String, dynamic>> _prayerTimes = [
    {
      'name': 'الفجر',
      'time': '05:30',
      'icon': Icons.wb_twilight,
      'color': Colors.indigo,
    },
    {
      'name': 'الشروق',
      'time': '06:45',
      'icon': Icons.wb_sunny,
      'color': Colors.orange,
    },
    {
      'name': 'الظهر',
      'time': '12:15',
      'icon': Icons.wb_sunny_outlined,
      'color': Colors.amber,
    },
    {
      'name': 'العصر',
      'time': '15:30',
      'icon': Icons.wb_cloudy,
      'color': Colors.blue,
    },
    {
      'name': 'المغرب',
      'time': '18:00',
      'icon': Icons.wb_twilight,
      'color': Colors.deepOrange,
    },
    {
      'name': 'العشاء',
      'time': '19:30',
      'icon': Icons.nightlight,
      'color': Colors.purple,
    },
  ];

  String? _nextPrayer;
  Duration? _timeToNext;

  @override
  void initState() {
    super.initState();
    _calculateNextPrayer();
    // Update every minute
    Stream.periodic(Duration(minutes: 1)).listen((_) {
      if (mounted) {
        _calculateNextPrayer();
      }
    });
  }

  void _calculateNextPrayer() {
    final now = DateTime.now();
    final currentTime = TimeOfDay.now();
    
    String? nextPrayer;
    Duration? timeToNext;
    
    for (final prayer in _prayerTimes) {
      final prayerTime = _parseTime(prayer['time']);
      
      if (_isTimeAfter(currentTime, prayerTime)) {
        continue;
      }
      
      nextPrayer = prayer['name'];
      timeToNext = _calculateDuration(currentTime, prayerTime);
      break;
    }
    
    // If no prayer found for today, next is Fajr tomorrow
    if (nextPrayer == null) {
      nextPrayer = 'الفجر';
      final fajrTime = _parseTime(_prayerTimes[0]['time']);
      final tomorrow = DateTime(now.year, now.month, now.day + 1);
      final fajrDateTime = DateTime(
        tomorrow.year,
        tomorrow.month,
        tomorrow.day,
        fajrTime.hour,
        fajrTime.minute,
      );
      timeToNext = fajrDateTime.difference(now);
    }
    
    setState(() {
      _nextPrayer = nextPrayer;
      _timeToNext = timeToNext;
    });
  }

  TimeOfDay _parseTime(String timeStr) {
    final parts = timeStr.split(':');
    return TimeOfDay(
      hour: int.parse(parts[0]),
      minute: int.parse(parts[1]),
    );
  }

  bool _isTimeAfter(TimeOfDay current, TimeOfDay target) {
    if (current.hour > target.hour) return true;
    if (current.hour == target.hour && current.minute >= target.minute) return true;
    return false;
  }

  Duration _calculateDuration(TimeOfDay from, TimeOfDay to) {
    final now = DateTime.now();
    final fromDateTime = DateTime(now.year, now.month, now.day, from.hour, from.minute);
    final toDateTime = DateTime(now.year, now.month, now.day, to.hour, to.minute);
    return toDateTime.difference(fromDateTime);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.access_time,
                  color: Colors.indigo[700],
                  size: 28,
                ),
                SizedBox(width: 12),
                Text(
                  'مواقيت الصلاة',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.indigo[700],
                  ),
                ),
                Spacer(),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.indigo[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    DateFormat('dd/MM').format(DateTime.now()),
                    style: TextStyle(
                      color: Colors.indigo[700],
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            if (_nextPrayer != null && _timeToNext != null)
              _buildNextPrayerCard(),
            SizedBox(height: 16),
            _buildPrayerTimesList(),
          ],
        ),
      ),
    );
  }

  Widget _buildNextPrayerCard() {
    final hours = _timeToNext!.inHours;
    final minutes = _timeToNext!.inMinutes % 60;
    
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.indigo[400]!, Colors.indigo[600]!],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            Icons.notifications_active,
            color: Colors.white,
            size: 24,
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'الصلاة القادمة: $_nextPrayer',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'خلال ${hours > 0 ? '$hours ساعة و' : ''}$minutes دقيقة',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrayerTimesList() {
    return Column(
      children: _prayerTimes.map((prayer) {
        final isNext = prayer['name'] == _nextPrayer;
        
        return Container(
          margin: EdgeInsets.symmetric(vertical: 4),
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: isNext ? prayer['color'].withOpacity(0.1) : Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isNext ? prayer['color'].withOpacity(0.3) : Colors.grey[200]!,
            ),
          ),
          child: Row(
            children: [
              Icon(
                prayer['icon'],
                color: prayer['color'],
                size: 24,
              ),
              SizedBox(width: 16),
              Expanded(
                child: Text(
                  prayer['name'],
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: isNext ? FontWeight.bold : FontWeight.w500,
                    color: isNext ? prayer['color'] : Colors.grey[700],
                  ),
                ),
              ),
              Text(
                prayer['time'],
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isNext ? prayer['color'] : Colors.grey[800],
                ),
              ),
              if (isNext) ...[
                SizedBox(width: 8),
                Icon(
                  Icons.arrow_forward_ios,
                  color: prayer['color'],
                  size: 16,
                ),
              ],
            ],
          ),
        );
      }).toList(),
    );
  }
}