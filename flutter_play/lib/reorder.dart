import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Reorderable List Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: ReorderableListExample(),
    );
  }
}

class ReorderableListExample extends StatefulWidget {
  @override
  _ReorderableListExampleState createState() => _ReorderableListExampleState();
}

class _ReorderableListExampleState extends State<ReorderableListExample> {
  final List<String> _items =
      List<String>.generate(10, (index) => 'Item ${index + 1}');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Reorderable List'),
      ),
      body: ReorderableListView.builder(
        onReorder: _onReorder,
        itemCount: _items.length,
        itemBuilder: (context, index) {
          return ListTile(
            key: Key('$index'),
            title: Text(_items[index]),
          );
        },
      ),
    );
  }

  void _onReorder(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) {
        newIndex -= 1;
      }
      final String item = _items.removeAt(oldIndex);
      _items.insert(newIndex, item);
    });
  }
}
