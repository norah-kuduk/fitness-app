import 'dart:convert';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PT MVP',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
            seedColor: const Color.fromARGB(255, 113, 139, 209)),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'PT Routine Options'),
      routes: {
        '/page1': (context) => const Page1(title: 'Page 1'),
        '/page2': (context) => const Page2(title: 'Page 2'),
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/page1');
              },
              child: const Text('Ed\'s PT Routine'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/page2');
              },
              child: const Text('Norah\'s PT Routine'),
            ),
          ],
        ),
      ),
    );
  }
}

class Page1 extends StatefulWidget {
  const Page1({super.key, required this.title});

  final String title;
  final String exercisesJson = '''
  [
    {
      "name": "Pelvic bridges",
      "reps": 10,
      "hold_time_secs": 5,
      "completed": false
    },
    {
      "name": "Pelvic tilts",
      "reps": 10,
      "hold_time_secs": 5,
      "completed": false
    },
    {
      "name": "Knee squeeze with ball between knees (bottom on ground)",
      "reps": 10,
      "hold_time_secs": 5,
      "completed": false
    },
    {
      "name": "Bridges with ball knee squeeze",
      "reps": 10,
      "hold_time_secs": 5,
      "completed": false
    },
    {
      "name": "Bridges with strap around knees (knees go out)",
      "reps": 10,
      "hold_time_secs": 1,
      "completed": false
    },
    {
      "name": "Bottom flat on ground, strap around knees (each knee going out)",
      "reps": 10,
      "hold_time_secs": 1,
      "completed": false
    },
    {
      "name": "Lay on each side and clam shell",
      "reps": 10,
      "hold_time_secs": 1,
      "completed": false
    },
    {
      "name": "Lay on side and side abductors",
      "reps": 10,
      "hold_time_secs": 1,
      "completed": false
    },
    {
      "name": "Lay on belly and back leg lifts",
      "reps": 10,
      "hold_time_secs": 1,
      "completed": false
    },
    {
      "name": "Standing side leg abductors with strap",
      "reps": 10,
      "hold_time_secs": 1,
      "completed": false
    },
    {
      "name": "Standing back leg abduction with strap",
      "reps": 10,
      "hold_time_secs": 1,
      "completed": false
    },
    {
      "name": "Hamstring stretch",
      "reps": 3,
      "hold_time_secs": 20,
      "completed": false
    },
    {
      "name": "Hanging hip flexor stretch",
      "reps": 3,
      "hold_time_secs": 20,
      "completed": false
    }
  ]
  ''';

  @override
  State<Page1> createState() => _Page1State();
}

class _Page1State extends State<Page1> {
  late List<dynamic> exercises;

  @override
  void initState() {
    super.initState();
    exercises = jsonDecode(widget.exercisesJson);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ed\'s PT Routine'),
      ),
      body: Stack(children: <Widget>[
        ListView.builder(
          itemCount: exercises.length,
          itemBuilder: (context, index) {
            return CheckboxListTile(
              title: Text(
                exercises[index]['name'],
                style: TextStyle(
                  decoration: exercises[index]['completed']
                      ? TextDecoration.lineThrough
                      : TextDecoration.none,
                ),
              ),
              subtitle: Text(
                  'Reps: ${exercises[index]['reps']} \nHold time: ${exercises[index]['hold_time_secs']}s'),
              value: exercises[index]['completed'],
              onChanged: (bool? value) {
                setState(() {
                  exercises[index]['completed'] = value ?? false;
                });
              },
            );
          },
        ),
        Positioned(
          bottom: 16,
          left: 16,
          child: ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Icon(Icons.arrow_back),
          ),
        ),
      ]),
    );
  }
}

class Page2 extends StatefulWidget {
  const Page2({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<Page2> createState() => _Page2State();
}

class _Page2State extends State<Page2> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Page 2'),
      ),
      body: Stack(children: <Widget>[
        Positioned(
          bottom: 16,
          left: 16,
          child: ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Icon(Icons.arrow_back),
          ),
        ),
      ]),
    );
  }
}
