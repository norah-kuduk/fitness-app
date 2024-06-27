// this will have the list of exercises with links to each of their pages
// (probably similar to home screen)
// exercise_screen.dart
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

extension StringExtension on String {
  String toTitleCase() {
    return split(' ')
        .map((word) => word.isNotEmpty
            ? '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}'
            : word)
        .join(' ');
  }
}

class ExerciseScreen extends StatefulWidget {
  const ExerciseScreen({super.key});

  @override
  _ExerciseScreenState createState() => _ExerciseScreenState();
}

class _ExerciseScreenState extends State<ExerciseScreen> {
  List<dynamic> _exercises = [];
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  bool _showDeleteOptions = false;
  bool _showEditOptions = false;

  @override
  void initState() {
    super.initState();
    fetchExercises();
  }

  Future<void> fetchExercises() async {
    try {
      final response =
          await http.get(Uri.parse('http://localhost:8080/exercise'));

      setState(() {
        _exercises = json.decode(response.body);
      });
    } catch (e) {
      // user message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to load exercises'),
        ),
      );
    }
  }

  Future<void> addExercise(String name, String description) async {
    if (name.isEmpty) {
      throw Exception('Name cannot be empty');
    }

    final response = await http.post(
      Uri.parse('http://localhost:8080/exercise'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'ExerciseName': name,
        'Description': description,
      }),
    );

    if (response.statusCode == 200) {
      fetchExercises();
    } else {
      throw Exception('Failed to add exercise');
    }
  }

  Future<void> updateExercise(int id, String name, String description) async {
    final response = await http.put(
      Uri.parse('http://localhost:8080/exercise/$id'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'ExerciseName': name, 'Description': description}),
    );

    if (response.statusCode == 200) {
      fetchExercises();
    } else {
      throw Exception('Failed to update exercise');
    }
  }

  Future<void> deleteExercise(int id) async {
    final response = await http.delete(
      Uri.parse('http://localhost:8080/exercise/$id'),
    );

    if (response.statusCode == 200) {
      fetchExercises();
    } else {
      throw Exception('Failed to delete exercise');
    }
  }

  void _showExerciseEditDialog(
      {int? id, String? currentName, String? currentDescription}) {
    _nameController.text = currentName ?? '';
    _descriptionController.text = currentDescription ?? '';
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(id == null ? 'Add Exercise' : 'Update Exercise'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Exercise Name'),
              ),
              TextField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                if (id == null) {
                  addExercise(_nameController.text.toTitleCase(),
                      _descriptionController.text);
                } else {
                  updateExercise(id, _nameController.text.toTitleCase(),
                      _descriptionController.text);
                }
                Navigator.of(context).pop();
              },
              child: Text(id == null ? 'Add' : 'Update'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    _exercises.sort((a, b) => a['ExerciseName'].compareTo(b['ExerciseName']));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Exercises'),
      ),
      body: Column(children: [
        Expanded(
            child: ListView.builder(
          itemCount: _exercises.length,
          itemBuilder: (context, index) {
            final exercise = _exercises[index];
            return ListTile(
                title: Text(exercise['ExerciseName']),
                // if exercise['Description'] is '' or null, use 'No description'
                subtitle: Text(exercise['Description'] ?? 'No description'),
                trailing: Row(
                    mainAxisSize:
                        MainAxisSize.min, // Important to avoid overflow
                    children: <Widget>[
                      if (_showDeleteOptions)
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            deleteExercise(exercise['ExerciseID']);
                          },
                        ),
                      if (_showEditOptions)
                        IconButton(
                          icon: const Icon(Icons.edit,
                              color: Color.fromARGB(255, 81, 81, 81)),
                          onPressed: () {
                            _showExerciseEditDialog(
                                id: exercise['ExerciseID'],
                                currentName: exercise['ExerciseName'],
                                currentDescription: exercise['Description']);
                          },
                        ),
                    ]));
          },
        )),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              ElevatedButton(
                onPressed: _showExerciseEditDialog,
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
      ]),
    );
  }
}
