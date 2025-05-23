import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stress_management/constants/colors.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class DailyReminderScreen extends StatefulWidget {
  @override
  _DailyReminderScreenState createState() => _DailyReminderScreenState();
}

class _DailyReminderScreenState extends State<DailyReminderScreen> {
  TimeOfDay _selectedTime = TimeOfDay.now();
  List<bool> _selectedDays = List.generate(7, (index) => true);
  bool _isReminderEnabled = true;

  final List<String> _weekDays = [
    'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'
  ];

  void _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: kPrimaryGreen,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Color(0xFF1A1A1A),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
  FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    _initializeNotifications();
    _loadSavedReminder();
  }

  Future<void> _initializeNotifications() async {
    // Initialize timezone database with default location
    tz.initializeTimeZones();
    final defaultLocation = tz.getLocation('UTC'); // Use UTC or another default

    // You can replace 'UTC' with a specific timezone like 'America/New_York'
    // if you know the user's timezone in advance
    tz.setLocalLocation(defaultLocation);

    // Initialize notifications
    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    final InitializationSettings initializationSettings =
    InitializationSettings(
      android: initializationSettingsAndroid,
    );

    await _notificationsPlugin.initialize(initializationSettings);
  }

  Future<void> _loadSavedReminder() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isReminderEnabled = prefs.getBool('isReminderEnabled') ?? true;
      final hour = prefs.getInt('reminderHour') ?? _selectedTime.hour;
      final minute = prefs.getInt('reminderMinute') ?? _selectedTime.minute;
      _selectedTime = TimeOfDay(hour: hour, minute: minute);

      for (int i = 0; i < 7; i++) {
        _selectedDays[i] = prefs.getBool('reminderDay_$i') ?? true;
      }
    });
  }

  Future<void> _saveReminder() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isReminderEnabled', _isReminderEnabled);
    await prefs.setInt('reminderHour', _selectedTime.hour);
    await prefs.setInt('reminderMinute', _selectedTime.minute);

    for (int i = 0; i < 7; i++) {
      await prefs.setBool('reminderDay_$i', _selectedDays[i]);
    }

    await _scheduleNotifications();
  }

  Future<void> _scheduleNotifications() async {
    await _notificationsPlugin.cancelAll();

    if (!_isReminderEnabled) return;

    for (int i = 0; i < 7; i++) {
      if (_selectedDays[i]) {
        final now = DateTime.now();
        var scheduledDate = _nextWeekday(now, i + 1);

        scheduledDate = DateTime(
          scheduledDate.year,
          scheduledDate.month,
          scheduledDate.day,
          _selectedTime.hour,
          _selectedTime.minute,
        );

        await _scheduleDailyNotification(
          id: i,
          title: 'Wellness Reminder',
          body: 'Time for your daily wellness activities!',
          scheduledDate: scheduledDate,
          dayOfWeek: i + 1,
        );
      }
    }
  }

  DateTime _nextWeekday(DateTime from, int dayOfWeek) {
    int daysToAdd = (dayOfWeek - from.weekday) % 7;
    if (daysToAdd <= 0) daysToAdd += 7;
    return from.add(Duration(days: daysToAdd));
  }

  Future<void> _scheduleDailyNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    required int dayOfWeek,
  }) async {
    final androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'daily_wellness_channel',
      'Daily Wellness Reminders',
      channelDescription: 'Notifications for daily wellness activities',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: false,
    );

    final platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
    );

    // Convert to local timezone (using the default we set earlier)
    final tz.TZDateTime scheduledDateTZ = tz.TZDateTime.from(
      scheduledDate,
      tz.local,
    );

    await _notificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      scheduledDateTZ,
      platformChannelSpecifics,
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
      UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(
          'Daily Reminder',
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: kPrimaryGreen,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: kPrimaryGreen),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Set Your Wellness Reminder',
              style: GoogleFonts.inter(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1A1A),
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Choose when you would like to receive daily reminders for your wellness activities.',
              style: GoogleFonts.inter(
                fontSize: 16,
                color: Color(0xFF64748B),
                height: 1.5,
              ),
            ),
            SizedBox(height: 32),
            
            // Enable Reminder Switch
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: kPrimaryGreen.withOpacity(0.05),
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Color(0xFFE8FFF5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.notifications_active_outlined,
                      color: kPrimaryGreen,
                      size: 24,
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Enable Reminders',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1A1A1A),
                          ),
                        ),
                        Text(
                          'Get notified daily',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: _isReminderEnabled,
                    onChanged: (value) {
                      setState(() {
                        _isReminderEnabled = value;
                      });
                    },
                    activeColor: kPrimaryGreen,
                    activeTrackColor: kPrimaryGreen.withOpacity(0.2),
                  ),
                ],
              ),
            ),
            SizedBox(height: 24),

            // Time Picker
            if (_isReminderEnabled) ...[
              Text(
                'Reminder Time',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1A1A1A),
                ),
              ),
              SizedBox(height: 12),
              InkWell(
                onTap: _selectTime,
                child: Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: kPrimaryGreen.withOpacity(0.05),
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Color(0xFFE8FFF5),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.access_time,
                          color: kPrimaryGreen,
                          size: 24,
                        ),
                      ),
                      SizedBox(width: 16),
                      Text(
                        _selectedTime.format(context),
                        style: GoogleFonts.inter(
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1A1A1A),
                        ),
                      ),
                      Spacer(),
                      Icon(
                        Icons.arrow_forward_ios,
                        color: Color(0xFF64748B),
                        size: 16,
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 24),

              // Days Selection
              Text(
                'Repeat On',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1A1A1A),
                ),
              ),
              SizedBox(height: 12),
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: kPrimaryGreen.withOpacity(0.05),
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(7, (index) {
                    return InkWell(
                      onTap: () {
                        setState(() {
                          _selectedDays[index] = !_selectedDays[index];
                        });
                      },
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: _selectedDays[index]
                              ? kPrimaryGreen
                              : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _selectedDays[index]
                                ? kPrimaryGreen
                                : Color(0xFFE2E8F0),
                          ),
                        ),
                        child: Center(
                          child: Text(
                            _weekDays[index],
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: _selectedDays[index]
                                  ? Colors.white
                                  : Color(0xFF64748B),
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ],
            SizedBox(height: 32),

            // Save Button
            Container(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isReminderEnabled
                    ? () async {
                  await _saveReminder();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Reminder saved successfully'),
                      backgroundColor: kPrimaryGreen,
                    ),
                  );
                  Navigator.pop(context);
                }
                    : null,
                icon: Icon(Icons.save_outlined),
                label: Text('Save Reminder'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: kPrimaryGreen,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                  disabledBackgroundColor: kPrimaryGreen.withOpacity(0.3),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
