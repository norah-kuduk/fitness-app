import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'routine_info.dart';

class CalendarScreen extends StatefulWidget {
  @override
  _CalendarScreenState createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  List<dynamic> _routines = [];
  List<dynamic> _availableRoutines = [];

  @override
  void initState() {
    super.initState();
    fetchRoutines();
  }

  // get all possible routines
  Future<void> fetchRoutines() async {
    try {
      final response =
          await http.get(Uri.parse('http://localhost:8080/routine'));

      if (response.statusCode == 200) {
        setState(() {
          _availableRoutines = json.decode(response.body);
        });
      } else {
        throw Exception('Failed to load routines');
      }
    } catch (e) {
      // user message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to load routines'),
        ),
      );
    }
  }

  // Fetch scheduled exercises for the selected day
  Future<void> fetchScheduledRoutines() async {
    try {
      final url =
          'http://localhost:8080/routine/schedule/${_selectedDay!.toIso8601String().split('T').first}';
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        setState(() {
          _routines = json.decode(response.body);
        });
      } else if (response.statusCode == 404) {
        setState(() {
          _routines = [];
        });
        throw Exception('No routines scheduled for the selected day');
      }
    } catch (e) {
      print('Exception: $e');
    }
  }

  void _openScheduleDialog(BuildContext context) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Select a Routine to Schedule'),
          content: _availableRoutines.isNotEmpty
              ? SizedBox(
                  width: double.maxFinite,
                  child: ListView.builder(
                    itemCount: _availableRoutines.length,
                    itemBuilder: (context, index) {
                      final routine = _availableRoutines[index];
                      return ListTile(
                        title: Text(routine['RoutineName']),
                        onTap: () {
                          _scheduleRoutineForDate(
                              _selectedDay!, routine['RoutineID']);
                          Navigator.pop(context);
                        },
                      );
                    },
                  ),
                )
              : const Text('No routines available.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _scheduleRoutineForDate(DateTime date, int routineId) async {
    try {
      final response = await http.post(
        Uri.parse('http://localhost:8080/routine/schedule'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'RoutineID': routineId,
          // Convert the date to a string in the format 'YYYY-MM-DD'
          'ScheduledDate': date.toIso8601String().split('T').first,
        }),
      );

      if (response.statusCode == 200) {
        fetchScheduledRoutines();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Routine scheduled successfully'),
          ),
        );
      } else {
        throw Exception('Failed to schedule routine');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to schedule routine'),
        ),
      );
    }
  }

  Widget buildRoutineList() {
    if (_selectedDay == null) {
      return const SizedBox.shrink();
    }

    if (_routines.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16.0),
        child: Text('No routines scheduled for the selected day'),
      );
    }

    return Expanded(
      child: ListView.builder(
        itemCount: _routines.length,
        itemBuilder: (context, index) {
          final routine = _routines[index];
          final routineName = _availableRoutines.firstWhere(
            (element) => element['RoutineID'] == routine['RoutineID'],
            orElse: () => {'RoutineName': 'Unknown Routine'},
          )['RoutineName'];

          return ListTile(
            title: Text(routineName),
            onTap: () {
              // Navigate to RoutineInfoScreen and pass the routine data
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => RoutineInfoScreen(
                    routineName: routineName,
                    routineId: routine['RoutineID'],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Routine Scheduler'),
      ),
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
              fetchScheduledRoutines();
            },
            calendarFormat: CalendarFormat.month,
          ),
          buildRoutineList(),
        ],
      ),
    );
  }
}
