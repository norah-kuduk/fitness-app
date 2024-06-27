import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'exercises_list_screen.dart';
import 'routine_info.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.title});

  final String title;

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<dynamic> _routines = [];
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  bool _showDeleteOptions = false;
  bool _showEditOptions = false;

  @override
  void initState() {
    super.initState();
    fetchRoutines();
  }

  Future<void> fetchRoutines() async {
    try {
      final response =
          await http.get(Uri.parse('http://localhost:8080/routine'));

      if (response.statusCode == 200) {
        setState(() {
          _routines = json.decode(response.body);
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

  Future<void> addRoutine(String name, String description) async {
    if (name.isEmpty) {
      throw Exception('Name cannot be empty');
    }

    final response = await http.post(
      Uri.parse('http://localhost:8080/routine'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'RoutineName': name, 'Description': description}),
    );

    if (response.statusCode == 200) {
      fetchRoutines();
    } else {
      throw Exception('Failed to add routine');
    }
  }

  Future<void> updateRoutine(int id, String name, String description) async {
    final response = await http.put(
      Uri.parse('http://localhost:8080/routine/$id'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'RoutineName': name, 'Description': description}),
    );

    if (response.statusCode == 200) {
      fetchRoutines();
    } else {
      throw Exception('Failed to update routine');
    }
  }

  Future<void> deleteRoutine(int id) async {
    final response = await http.delete(
      Uri.parse('http://localhost:8080/routine/$id'),
    );

    if (response.statusCode == 200) {
      fetchRoutines();
    } else {
      throw Exception('Failed to delete routine');
    }
  }

  void _showRoutineEditDialog(
      {int? id, String? currentName, String? currentDescription}) {
    _nameController.text = currentName ?? '';
    _descriptionController.text = currentDescription ?? '';
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(id == null ? 'Add Routine' : 'Update Routine'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Routine Name'),
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
                  addRoutine(_nameController.text.toTitleCase(),
                      _descriptionController.text);
                } else {
                  updateRoutine(id, _nameController.text.toTitleCase(),
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
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            const DrawerHeader(
              decoration: BoxDecoration(),
              child: Text(
                'Pages',
                style: TextStyle(
                  color: Color.fromARGB(255, 75, 91, 139),
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.sports_gymnastics),
              title: const Text('Exercises'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const ExerciseScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Settings'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
      body: Column(children: [
        Expanded(
          child: ListView.builder(
            itemCount: _routines.length,
            itemBuilder: (context, index) {
              final routine = _routines[index];
              return ListTile(
                  title: Text(routine['RoutineName']),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => RoutineInfoScreen(
                          routineId: routine['RoutineID'],
                          routineName: routine['RoutineName'],
                        ),
                      ),
                    );
                  },
                  trailing: Row(
                      mainAxisSize:
                          MainAxisSize.min, // Important to avoid overflow
                      children: <Widget>[
                        if (_showDeleteOptions)
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              deleteRoutine(routine['RoutineID']);
                            },
                          ),
                        if (_showEditOptions)
                          IconButton(
                            icon: const Icon(Icons.edit,
                                color: Color.fromARGB(255, 81, 81, 81)),
                            onPressed: () {
                              _showRoutineEditDialog(
                                  id: routine['RoutineID'],
                                  currentName: routine['RoutineName'],
                                  currentDescription: routine['Description']);
                            },
                          ),
                      ]));
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              ElevatedButton(
                onPressed: _showRoutineEditDialog,
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
