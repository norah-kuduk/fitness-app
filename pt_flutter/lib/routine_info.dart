// this create/display the information about each routine and exercise
// have capabilities to add, update, and delete exercises, reps, sets,
// hold time, equipment, notes etc.

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class RoutineInfoScreen extends StatefulWidget {
  final int routineId;
  final String routineName;

  const RoutineInfoScreen(
      {super.key, required this.routineId, required this.routineName});

  @override
  _RoutineInfoScreenState createState() => _RoutineInfoScreenState();
}

class _RoutineInfoScreenState extends State<RoutineInfoScreen> {
  List<dynamic> _exercises = [];
  List<dynamic> _routineExercises = [];
  List<Map<String, dynamic>> _selectedExercises = [];

  @override
  void initState() {
    super.initState();
    fetchExercises();
    fetchRoutineExercises();
  }

  Future<void> fetchExercises() async {
    final response =
        await http.get(Uri.parse('http://localhost:8080/exercise'));

    if (response.statusCode == 200) {
      setState(() {
        _exercises = json.decode(response.body);
      });
    } else {
      throw Exception('Failed to load exercises');
    }
  }

  Future<void> fetchRoutineExercises() async {
    try {
      final response = await http.get(Uri.parse(
          'http://localhost:8080/routine/${widget.routineId}/exercise'));

      if (response.statusCode == 200) {
        setState(() {
          _routineExercises = json.decode(response.body);
        });
      } else {
        throw Exception('Failed to load routine exercises');
      }
    } catch (e) {
      // user message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to load exercises'),
        ),
      );
    }
  }

  Future<void> addExercisesToRoutine() async {
    // Assuming _existingExercises is a List<int> of existing exercise IDs in the routine
    // and _selectedExercises is a List<Map<String, dynamic>> where each exercise has an 'id' key

    // Filter out exercises that are already in the routine
    List exercisesToAdd = _selectedExercises
        .where((exercise) => !_routineExercises.contains(exercise['id']))
        .toList();

    // Proceed only if there are new exercises to add
    if (exercisesToAdd.isNotEmpty) {
      final response = await http.post(
        Uri.parse('http://localhost:8080/routine/${widget.routineId}/exercise'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'Exercises': exercisesToAdd}),
      );

      if (response.statusCode == 200) {
        fetchRoutineExercises();
      } else {
        throw Exception('Failed to add exercises to routine');
      }
    } else {
      print('No new exercises to add');
      // Optionally, handle the case when there are no new exercises to add
    }
  }

  Future<void> updateRoutineExercise(
      int exerciseId, int sets, int reps, int holdTime, String notes) async {
    final response = await http.put(
      Uri.parse(
          'http://localhost:8080/routine/${widget.routineId}/exercise/$exerciseId'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(
          {'Sets': sets, 'Reps': reps, 'HoldTime': holdTime, 'Notes': notes}),
    );

    if (response.statusCode == 200) {
      fetchRoutineExercises();
    } else {
      throw Exception('Failed to update exercise in routine');
    }
  }

  // update server routine exercises with order
  Future<void> updateExercisesOnServer() async {
    final url = Uri.parse(
        'http://localhost:8080/routine/${widget.routineId}/exercise/$exerciseId');
    final response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode({
        'exercises': _routineExercises,
      }),
    );

    if (response.statusCode == 200) {
      print('Server updated successfully.');
    } else {
      print('Failed to update server. Status code: ${response.statusCode}');
    }
  }

  Future<void> deleteRoutineExercise(int exerciseId) async {
    final response = await http.delete(
      Uri.parse(
          'http://localhost:8080/routine/${widget.routineId}/exercise/$exerciseId'),
    );

    if (response.statusCode == 200) {
      fetchRoutineExercises();
    } else {
      throw Exception('Failed to delete exercise from routine');
    }
  }

  void _showExerciseSelectionDialog() {
    List<Map<String, dynamic>> selectedExercises =
        List.from(_selectedExercises);

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Select Exercises'),
              content: SizedBox(
                width: double.maxFinite,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _exercises.length,
                  itemBuilder: (context, index) {
                    final exercise = _exercises[index];
                    return CheckboxListTile(
                      title: Text(exercise['ExerciseName']),
                      value: selectedExercises.any(
                          (e) => e['ExerciseID'] == exercise['ExerciseID']),
                      onChanged: (bool? value) {
                        setState(() {
                          if (value == true) {
                            print('Adding exercise at index $index');
                            int nextOrder = selectedExercises.isNotEmpty
                                ? (selectedExercises
                                        .map<int>((e) => e['Order'])
                                        .reduce(max) +
                                    1)
                                : 0;
                            selectedExercises.add({
                              'ExerciseID': exercise['ExerciseID'],
                              'Sets': 3, // Default value, can be modified
                              'Reps': 10, // Default value, can be modified
                              'HoldTime': 30, // Default value, can be modified
                              'Notes': '', // Default value, can be modified
                              'Ord': nextOrder, // Assign the next order value
                            });
                            print(selectedExercises);
                          } else {
                            print("Removing exercise at index $index");
                            selectedExercises.removeWhere((e) =>
                                e['ExerciseID'] == exercise['ExerciseID']);
                          }
                        });
                      },
                    );
                  },
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    setState(() {
                      _selectedExercises = selectedExercises;
                    });
                    addExercisesToRoutine();
                  },
                  child: const Text('Add'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Cancel'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _onReorder(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) {
        newIndex -= 1;
      }
      final Map<String, dynamic> item = _routineExercises.removeAt(oldIndex);
      _routineExercises.insert(newIndex, item);
    });
  }

  void onReorder(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) {
        newIndex -= 1;
      }
      final item = _routineExercises.removeAt(oldIndex);
      _routineExercises.insert(newIndex, item);

      // Update the order property for each exercise
      for (int i = 0; i < _routineExercises.length; i++) {
        _routineExercises[i]['Ord'] = i;
      }

      // Optionally, save the new order here, either locally or by sending to a backend
      saveExerciseOrder();
    });
  }

  void saveExerciseOrder() async {
    // Assuming _routineExercises is a List<Map<String, dynamic>> of exercises
    // with an 'ExerciseID' key and an 'Order' key

    final List<Map<String, dynamic>> updatedExercises = _routineExercises
        .map((exercise) => {
              'ExerciseID': exercise['ExerciseID'],
              'Ord': exercise['Ord'],
            })
        .toList();

    final response = await http.put(
      Uri.parse('http://localhost:8080/routine/${widget.routineId}/exercise'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(updatedExercises),
    );

    if (response.statusCode == 200) {
      // Optionally, handle the case when the exercise order is saved successfully
    } else {
      throw Exception('Failed to save exercise order');
    }
  }

  void _showEditExerciseDialog(Map<String, dynamic> exercise) {
    final TextEditingController setsController =
        TextEditingController(text: exercise['Sets'].toString());
    final TextEditingController repsController =
        TextEditingController(text: exercise['Reps'].toString());
    final TextEditingController holdTimeController =
        TextEditingController(text: exercise['HoldTime'].toString());
    final TextEditingController notesController =
        TextEditingController(text: exercise['Notes'].toString());

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Exercise'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: setsController,
                decoration: const InputDecoration(labelText: 'Sets'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: repsController,
                decoration: const InputDecoration(labelText: 'Reps'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: holdTimeController,
                decoration:
                    const InputDecoration(labelText: 'Hold Time (seconds)'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: notesController,
                decoration: const InputDecoration(labelText: 'Notes'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                updateRoutineExercise(
                  exercise['ExerciseID'],
                  int.parse(setsController.text),
                  int.parse(repsController.text),
                  int.parse(holdTimeController.text),
                  notesController.text,
                );
                Navigator.of(context).pop();
              },
              child: const Text('Save'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.routineName),
      ),
      body: Column(
        children: [
          Expanded(
            child: ReorderableListView.builder(
              onReorder: _onReorder,
              itemCount: _routineExercises.length,
              itemBuilder: (context, index) {
                final routineExercise = _routineExercises[index];
                final exerciseName = _exercises.firstWhere(
                    (e) => e['ExerciseID'] == routineExercise['ExerciseID'],
                    orElse: () =>
                        {'ExerciseName': 'Unknown Exercise'})['ExerciseName'];
                return ListTile(
                  key: Key('$index'),
                  title: Text(exerciseName),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                          '${routineExercise['Sets']} x ${routineExercise['Reps']}'),
                      Text('Hold Time: ${routineExercise['HoldTime']} sec'),
                      Text('Notes: ${routineExercise['Notes']}'),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () {
                          _showEditExerciseDialog(routineExercise);
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () {
                          deleteRoutineExercise(routineExercise['ExerciseID']);
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: _showExerciseSelectionDialog,
              child: const Text('Add Exercises'),
            ),
          ),
        ],
      ),
    );
  }
}
