import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:get/get.dart';

class FullCalendarScreen extends StatefulWidget {
  final DateTime? initialStart;
  final DateTime? initialEnd;
  final bool isRangePicker;

  const FullCalendarScreen({
    super.key,
    this.initialStart,
    this.initialEnd,
    this.isRangePicker = false,
  });

  @override
  State<FullCalendarScreen> createState() => _FullCalendarScreenState();
}

class _FullCalendarScreenState extends State<FullCalendarScreen> {
  DateTime? _rangeStart;
  DateTime? _rangeEnd;
  DateTime? _selectedDay;
  DateTime _focusedDay = DateTime.now();
  @override
  void initState() {
    super.initState();
    _rangeStart = widget.initialStart;
    _rangeEnd = widget.initialEnd;
    _selectedDay = widget.initialStart;
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // AppBar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.black),
                    onPressed: () => Get.back(),
                  ),
                  Expanded(
                    child: Text(
                      widget.isRangePicker ? "Select Range" : "Select Date",
                      style: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(width: 48), // Space to balance close button
                ],
              ),
            ),

            const SizedBox(height: 8),
            _buildWeekdayHeader(),

            // Full screen calendar
            Expanded(
              child: TableCalendar(
                firstDay: DateTime.now(),
                lastDay: DateTime.utc(2030, 12, 31),
                focusedDay: _focusedDay,
                availableGestures: AvailableGestures.all,
                startingDayOfWeek: StartingDayOfWeek.monday,
                headerVisible: true,
                daysOfWeekVisible: false,
                rangeSelectionMode: widget.isRangePicker
                    ? RangeSelectionMode.enforced
                    : RangeSelectionMode.disabled,
                rangeStartDay: _rangeStart,
                rangeEndDay: _rangeEnd,
                selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                onDaySelected: (selected, focused) {
                  if (!widget.isRangePicker) {
                    setState(() {
                      _selectedDay = selected;
                      _focusedDay = focused;
                    });
                  }
                },
                onRangeSelected: (start, end, focused) {
                  if (widget.isRangePicker) {
                    setState(() {
                      _rangeStart = start;
                      _rangeEnd = end;
                      _focusedDay = focused;
                    });
                  }
                },
                headerStyle: const HeaderStyle(
                  formatButtonVisible: false,
                  titleCentered: true,
                  leftChevronVisible: true,
                  rightChevronVisible: true,
                ),
                calendarStyle: CalendarStyle(
                  outsideDaysVisible: false,
                  rangeHighlightColor:
                  Colors.blueAccent.withValues(alpha: 0.2),
                  rangeStartDecoration: const BoxDecoration(
                      color: Color(0xFFD4AF37), shape: BoxShape.circle),
                  rangeEndDecoration: const BoxDecoration(
                      color: Color(0xFFD4AF37), shape: BoxShape.circle),
                  selectedDecoration: const BoxDecoration(
                      color: Color(0xFFD4AF37), shape: BoxShape.circle),
                ),
              ),
            ),

            // Bottom Done button
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.white,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor:Color(0xFFD4AF37),
                  minimumSize: const Size(double.infinity, 55),
                ),
                onPressed: () {
                  if (widget.isRangePicker) {
                    if (_rangeStart != null && _rangeEnd == null) {
                      Get.snackbar(
                        "Return Date Missing",
                        "Please select a return date to continue.",
                        snackPosition: SnackPosition.BOTTOM,
                        backgroundColor: Colors.orangeAccent,
                        colorText: Colors.white,
                        margin: const EdgeInsets.all(15),
                      );
                    } else {
                      Get.back(result: {'start': _rangeStart, 'end': _rangeEnd});
                    }
                  } else {
                    Get.back(result: _selectedDay);
                  }
                },
                child: const Text(
                  "Done",
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeekdayHeader() {
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: days
            .map(
              (d) => Text(
            d,
            style: TextStyle(
              color: (d == 'Sat' || d == 'Sun')
                  ? Color(0xFFD4AF37)
                  : Colors.grey[600],
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        )
            .toList(),
      ),
    );
  }
}
