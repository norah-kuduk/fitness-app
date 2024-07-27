// this create/display the information about each routine and exercise
// have capabilities to add, update, and delete exercises, reps, sets,
// hold time, equipment, notes etc.

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
  List<dynamic> _filteredExercises = [];
  TextEditingController _searchController = TextEditingController();
  bool _showDeleteOptions = false;
  bool _showEditOptions = false;

  @override
  void initState() {
    super.initState(); // initialize
    fetchExercises(); // fetch exercises
    fetchRoutineExercises(); // fetch routine exercises
    _searchController
        .addListener(_filterExercises); // listen to search controller
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // fetch exercises from server
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

  // fetch routine exercises from server
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

  // add exercises to routine
  Future<void> addExercisesToRoutine() async {
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

  // update routine exercise on server
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

  // update all server routine exercises with order
  Future<void> updateExercisesOnServer() async {
    // first delete all current routine exercises
    await http.delete(
      Uri.parse('http://localhost:8080/routine/${widget.routineId}/exercise'),
    );

    // then add all routine exercises in the new order
    if (_routineExercises.isNotEmpty) {
      final response = await http.post(
        Uri.parse('http://localhost:8080/routine/${widget.routineId}/exercise'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'Exercises': _routineExercises,
        }),
      );

      if (response.statusCode == 200) {
        print('Server updated successfully.');
      } else {
        print('Failed to update server. Status code: ${response.statusCode}');
      }
    } else {
      print('No exercises to update on server.');
    }
  }

  // delete a single exercise from a routine
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

  // filter exercises given a search query
  void _filterExercises() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredExercises = _exercises.where((exercise) {
        final exerciseName = exercise['ExerciseName'].toLowerCase();
        return exerciseName.contains(query);
      }).toList();
    });
  }

  // code for selecting exercises to add to routine
  void _showExerciseSelectionDialog() {
    List<Map<String, dynamic>> selectedExercises =
        List.from(_selectedExercises);

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            _searchController.addListener(() {
              setState(() {
                _filteredExercises = _exercises.where((exercise) {
                  final exerciseName = exercise['ExerciseName'].toLowerCase();
                  return exerciseName
                      .contains(_searchController.text.toLowerCase());
                }).toList();
              });
            });
            return AlertDialog(
              title: Text('Select Exercises'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      labelText: 'Search',
                      suffixIcon: Icon(Icons.search),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      width: double.maxFinite,
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: _filteredExercises.length,
                        itemBuilder: (context, index) {
                          final exercise = _filteredExercises[index];
                          return CheckboxListTile(
                            title: Text(exercise['ExerciseName']),
                            value: selectedExercises.any((e) =>
                                e['ExerciseID'] == exercise['ExerciseID']),
                            onChanged: (bool? value) {
                              setState(() {
                                if (value == true) {
                                  selectedExercises.add({
                                    'ExerciseID': exercise['ExerciseID'],
                                    'Sets': 3, // Default value, can be modified
                                    'Reps':
                                        10, // Default value, can be modified
                                    'HoldTime':
                                        30, // Default value, can be modified
                                    'Notes':
                                        '' // Default value, can be modified
                                  });
                                } else {
                                  selectedExercises.removeWhere((e) =>
                                      e['ExerciseID'] ==
                                      exercise['ExerciseID']);
                                }
                              });
                            },
                          );
                        },
                      ),
                    ),
                  ),
                ],
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

  // code for reordering exercises
  void _onReorder(int oldIndex, int newIndex) {
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
      updateExercisesOnServer();
    });
  }

  // code for editing an exercise
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

  // build the routine info screen
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
                      if (_showEditOptions)
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () {
                            _showEditExerciseDialog(routineExercise);
                          },
                        ),
                      if (_showDeleteOptions)
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            deleteRoutineExercise(
                                routineExercise['ExerciseID']);
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
            child: Row(
              children: [
                ElevatedButton(
                  onPressed: _showExerciseSelectionDialog,
                  child: const Icon(Icons.add),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _showDeleteOptions = !_showDeleteOptions;
                    });
                  },
                  child: Icon(_showDeleteOptions ? Icons.check : Icons.delete),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _showEditOptions = !_showEditOptions;
                    });
                  },
                  child: Icon(_showEditOptions ? Icons.check : Icons.edit),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
