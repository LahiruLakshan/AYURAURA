import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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
              primary: Color(0xFF047857),
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
            color: Color(0xFF047857),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Color(0xFF047857)),
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
                    color: Color(0xFF047857).withOpacity(0.05),
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
                      color: Color(0xFF047857),
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
                    activeColor: Color(0xFF047857),
                    activeTrackColor: Color(0xFF047857).withOpacity(0.2),
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
                        color: Color(0xFF047857).withOpacity(0.05),
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
                          color: Color(0xFF047857),
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
                      color: Color(0xFF047857).withOpacity(0.05),
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
                              ? Color(0xFF047857)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _selectedDays[index]
                                ? Color(0xFF047857)
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
                    ? () {
                        // TODO: Implement reminder saving logic
                        Navigator.pop(context);
                      }
                    : null,
                icon: Icon(Icons.save_outlined),
                label: Text('Save Reminder'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF047857),
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                  disabledBackgroundColor: Color(0xFF047857).withOpacity(0.3),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
