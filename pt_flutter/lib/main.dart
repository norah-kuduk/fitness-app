// this file creates the home screen for the app

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PT MVP',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
            seedColor: const Color.fromARGB(255, 113, 139, 209)),
        useMaterial3: true,
      ),
      home: const HomeScreen(title: 'PT Routine Options'),
    );
  }
}

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

  @override
  void initState() {
    super.initState();
    fetchRoutines();
  }

  Future<void> fetchRoutines() async {
    final response =
        await http.get(Uri.parse('http://localhost:8080/routines'));

    if (response.statusCode == 200) {
      setState(() {
        _routines = json.decode(response.body);
      });
    } else {
      throw Exception('Failed to load routines');
    }
  }

  Future<void> addRoutine(String name, String description) async {
    final response = await http.post(
      Uri.parse('http://localhost:8080/routines'),
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
      Uri.parse('http://localhost:8080/routines/$id'),
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
      Uri.parse('http://localhost:8080/routines/$id'),
    );

    if (response.statusCode == 200) {
      fetchRoutines();
    } else {
      throw Exception('Failed to delete routine');
    }
  }

  void _showRoutineDialog(
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
                decoration: InputDecoration(labelText: 'Routine Name'),
              ),
              TextField(
                controller: _descriptionController,
                decoration: InputDecoration(labelText: 'Description'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                if (id == null) {
                  addRoutine(_nameController.text, _descriptionController.text);
                } else {
                  updateRoutine(
                      id, _nameController.text, _descriptionController.text);
                }
                Navigator.of(context).pop();
              },
              child: Text(id == null ? 'Add' : 'Update'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
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
      body: ListView.builder(
        itemCount: _routines.length,
        itemBuilder: (context, index) {
          final routine = _routines[index];
          return ListTile(
            title: Text(routine['RoutineName']),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.edit),
                  onPressed: () => _showRoutineDialog(
                    id: routine['RoutineID'],
                    currentName: routine['RoutineName'],
                    currentDescription: routine['Description'],
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () => deleteRoutine(routine['RoutineID']),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showRoutineDialog(),
        child: Icon(Icons.add),
      ),
    );
  }
}
