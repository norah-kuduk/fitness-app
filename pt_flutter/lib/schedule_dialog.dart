import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

class ScheduleDialog extends StatefulWidget {
  final int routineId;

  const ScheduleDialog({Key? key, required this.routineId}) : super(key: key);

  @override
  _ScheduleDialogState createState() => _ScheduleDialogState();
}

class _ScheduleDialogState extends State<ScheduleDialog> {
  DateTime _selectedDate = DateTime.now();
  bool _isRepeat = false;
  String _repeatFrequency = 'None';
  DateTime? _endDate;

  Future<void> _scheduleRoutine() async {
    DateTime currentDate = _selectedDate;
    while (currentDate
        .isBefore(_endDate ?? _selectedDate.add(const Duration(days: 1)))) {
      final response = await http.post(
        Uri.parse('http://localhost:8080/routine/schedule'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'RoutineID': widget.routineId,
          'ScheduledDate': currentDate.toIso8601String(),
        }),
      );

      if (response.statusCode != 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to schedule routine')),
        );
        return;
      }

      // Calculate next date based on frequency
      switch (_repeatFrequency) {
        case 'Daily':
          currentDate = currentDate.add(const Duration(days: 1));
          break;
        case 'Weekly':
          currentDate = currentDate.add(const Duration(days: 7));
          break;
        case 'Monthly':
          currentDate = DateTime(
              currentDate.year, currentDate.month + 1, currentDate.day);
          break;
        default:
          currentDate = _endDate != null
              ? _endDate!.add(const Duration(days: 1))
              : currentDate;
          break;
      }

      // Stop if there is no repetition set
      if (!_isRepeat) break;
    }

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Schedule Routine'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            title: const Text('Date'),
            subtitle: Text(DateFormat.yMd().format(_selectedDate)),
            trailing: IconButton(
              icon: const Icon(Icons.calendar_today),
              onPressed: () async {
                final selected = await showDatePicker(
                  context: context,
                  initialDate: _selectedDate,
                  firstDate: DateTime.now(),
                  lastDate: DateTime(2100),
                );
                if (selected != null) {
                  setState(() {
                    _selectedDate = selected;
                  });
                }
              },
            ),
          ),
          SwitchListTile(
            title: const Text('Repeat'),
            value: _isRepeat,
            onChanged: (bool value) {
              setState(() {
                _isRepeat = value;
              });
            },
          ),
          if (_isRepeat)
            DropdownButton<String>(
              value: _repeatFrequency,
              items: ['None', 'Daily', 'Weekly', 'Monthly']
                  .map((freq) =>
                      DropdownMenuItem(value: freq, child: Text(freq)))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _repeatFrequency = value!;
                });
              },
            ),
          if (_isRepeat)
            ListTile(
              title: const Text('End Date'),
              subtitle: _endDate != null
                  ? Text(DateFormat.yMd().format(_endDate!))
                  : const Text('No end date'),
              trailing: IconButton(
                icon: const Icon(Icons.calendar_today),
                onPressed: () async {
                  final selected = await showDatePicker(
                    context: context,
                    initialDate: _endDate ?? _selectedDate,
                    firstDate: _selectedDate,
                    lastDate: DateTime(2100),
                  );
                  if (selected != null) {
                    setState(() {
                      _endDate = selected;
                    });
                  }
                },
              ),
            ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: _scheduleRoutine,
          child: const Text('Schedule'),
        ),
      ],
    );
  }
}
