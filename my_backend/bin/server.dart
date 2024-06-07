// imports
import 'dart:convert';
import 'dart:io';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_router/shelf_router.dart';
import 'package:shelf_cors_headers/shelf_cors_headers.dart';
import 'package:my_backend/database_helper.dart';

// define headers to allow cross-origin requests
// necessary for Flutter  to communicate with server
final _headers = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'Origin, Content-Type',
  'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS'
};

// entry point of the server application.
Future<void> main() async {
  final dbHelper = DatabaseHelper();
  await dbHelper.openConnection();
  await dbHelper.createTables();

  // router setup
  final router = Router();

  // define routes for handling HTTP requests
  // each route corresponds to a specific CRUD operation on the database

  // get all routines
  router.get('/routines', (Request request) async {
    final result = await dbHelper.connection.query('SELECT * FROM Routine');
    final routines = result
        .map((row) =>
            {'RoutineID': row[0], 'RoutineName': row[1], 'Description': row[2]})
        .toList();
    return Response.ok(json.encode(routines),
        headers: {..._headers, 'Content-Type': 'application/json'});
  });

  // insert a new routine
  router.post('/routines', (Request request) async {
    final payload = json.decode(await request.readAsString());
    await dbHelper.connection.execute(
      'INSERT INTO Routine (RoutineName, Description) VALUES (@name, @description)',
      substitutionValues: {
        'name': payload['RoutineName'],
        'description': payload['Description'],
      },
    );
    return Response.ok('Routine added', headers: _headers);
  });

  // update a routine
  router.put('/routines/<id>', (Request request) async {
    final id = int.parse(request.params['id']!);
    final payload = json.decode(await request.readAsString());
    await dbHelper.connection.execute(
      'UPDATE Routine SET RoutineName = @name, Description = @description WHERE RoutineID = @id',
      substitutionValues: {
        'id': id,
        'name': payload['RoutineName'],
        'description': payload['Description'],
      },
    );
    return Response.ok('Routine updated', headers: _headers);
  });

  // delete a routine
  router.delete('/routines/<id>', (Request request) async {
    final id = int.parse(request.params['id']!);
    await dbHelper.connection.execute(
      'DELETE FROM Routine WHERE RoutineID = @id',
      substitutionValues: {
        'id': id,
      },
    );
    return Response.ok('Routine deleted', headers: _headers);
  });

  //  get a single routine by ID
  router.get('/routine/<id>', (Request request, String id) async {
    // Fetch the routine with the given ID from your data source
    // For example, if you're using a database, you might do something like this:
    var routine = await dbHelper.connection.execute(
      'SELECT * FROM Routine WHERE RoutineID = @id',
      substitutionValues: {
        'id': id,
      },
    );
    // Convert the routine to a JSON string
    var routineJson = jsonEncode(routine);

    // Return the routine as a response
    return Response.ok(routineJson,
        headers: {'Content-Type': 'application/json'});
  });

  // TODO add a route to get all exercises in DB

  // TODO add a route to insert a new exercise to the DB

  // TODO add a route to update an  exercise in the DB

  // TODO add a route to delete an exercise from the DB

  // TODO add a route to get all exercises for a routine

  // TODO add a route to insert an exercise to a routine

  // TODO add a route to delete an exercise from a routine

  // sets up the middleware pipeline for logging requests and handling CORS,
  // and then starts the server.

  final handler = const Pipeline()
      .addMiddleware(logRequests())
      .addMiddleware(corsHeaders())
      .addHandler(router);

  final port = int.parse(Platform.environment['PORT'] ?? '8080');
  final server = await io.serve(handler, 'localhost', port);

  print('Server listening on port ${server.port}');
}
