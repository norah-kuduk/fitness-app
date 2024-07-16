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
  router.get('/routine', (Request request) async {
    final result = await dbHelper.connection.query('SELECT * FROM Routine');
    final routines = result
        .map((row) =>
            {'RoutineID': row[0], 'RoutineName': row[1], 'Description': row[2]})
        .toList();
    return Response.ok(json.encode(routines),
        headers: {..._headers, 'Content-Type': 'application/json'});
  });

  // insert a new routine
  router.post('/routine', (Request request) async {
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
  router.put('/routine/<id>', (Request request) async {
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
  router.delete('/routine/<id>', (Request request) async {
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

  // get all exercises in DB
  router.get('/exercise', (Request request) async {
    final result = await dbHelper.connection
        .query('SELECT * FROM Exercise ORDER BY ExerciseName ASC');
    final exercises = result
        .map((row) => {
              'ExerciseID': row[0],
              'ExerciseName': row[1],
              'Description': row[2],
            })
        .toList();
    return Response.ok(json.encode(exercises),
        headers: {..._headers, 'Content-Type': 'application/json'});
  });

  // Add a new exercise
  router.post('/exercise', (Request request) async {
    final payload = json.decode(await request.readAsString());
    await dbHelper.connection.query(
      'INSERT INTO Exercise (ExerciseName, Description) VALUES (@name, @description)',
      substitutionValues: {
        'name': payload['ExerciseName'],
        'description': payload['Description'],
      },
    );
    return Response.ok('Exercise added', headers: _headers);
  });

  // update a exercise
  router.put('/exercise/<id>', (Request request) async {
    final id = int.parse(request.params['id']!);
    final payload = json.decode(await request.readAsString());
    await dbHelper.connection.execute(
      'UPDATE Exercise SET ExerciseName = @name, Description = @description WHERE ExerciseID = @id',
      substitutionValues: {
        'id': id,
        'name': payload['ExerciseName'],
        'description': payload['Description'],
      },
    );
    return Response.ok('Exercise updated', headers: _headers);
  });

  // delete a exercise
  router.delete('/exercise/<id>', (Request request) async {
    final id = int.parse(request.params['id']!);
    await dbHelper.connection.execute(
      'DELETE FROM Exercise WHERE ExerciseID = @id',
      substitutionValues: {
        'id': id,
      },
    );
    return Response.ok('Routine deleted', headers: _headers);
  });

  // Get exercises for a routine
  router.get('/routine/<id>/exercise', (Request request) async {
    final id = int.parse(request.params['id']!);
    final result = await dbHelper.connection.query(
        'SELECT * FROM RoutineExercise WHERE RoutineID = @id ORDER BY Ord ASC',
        substitutionValues: {'id': id});
    final routineExercises = result
        .map((row) => {
              'RoutineID': row[0],
              'ExerciseID': row[1],
              'Sets': row[2],
              'Reps': row[3],
              'HoldTime': row[4],
              'Ord': row[5],
              'Notes': row[6]
            })
        .toList();
    return Response.ok(json.encode(routineExercises),
        headers: {..._headers, 'Content-Type': 'application/json'});
  });

  // Add exercises to an existing routine
  router.post('/routine/<id>/exercise', (Request request) async {
    final id = int.parse(request.params['id']!);
    final payload = json.decode(await request.readAsString());
    final exercises = payload['Exercises'] as List;

    print('Received routine ID: $id');
    print('Received exercises: $exercises');

    for (final exercise in exercises) {
      await dbHelper.connection.query(
        'INSERT INTO RoutineExercise (RoutineID, ExerciseID, Sets, Reps, HoldTime, Notes, Ord) VALUES (@routineID, @exerciseID, @sets, @reps, @holdTime, @notes, @ord)',
        substitutionValues: {
          'routineID': id,
          'exerciseID': exercise['ExerciseID'],
          'sets': exercise['Sets'],
          'reps': exercise['Reps'],
          'holdTime': exercise['HoldTime'],
          'notes': exercise['Notes'],
          'ord': exercise['Ord'],
        },
      );
    }

    return Response.ok('Exercises added to routine', headers: _headers);
  });

  // Update an exercise in a routine
  router.put('/routine/<routineId>/exercise/<exerciseId>',
      (Request request) async {
    final routineId = int.parse(request.params['routineId']!);
    final exerciseId = int.parse(request.params['exerciseId']!);
    final payload = json.decode(await request.readAsString());

    await dbHelper.connection.query(
      'UPDATE RoutineExercise SET Reps = @reps, HoldTime = @holdTime, Notes = @notes WHERE RoutineID = @routineId AND ExerciseID = @exerciseId',
      substitutionValues: {
        'sets': payload['Sets'],
        'reps': payload['Reps'],
        'holdTime': payload['HoldTime'],
        'notes': payload['Notes'],
        'ord': payload['Ord'], // added 'Ord' to the query
        'routineId': routineId,
        'exerciseId': exerciseId
      },
    );

    return Response.ok('Exercise updated in routine', headers: _headers);
  });

  // update exercises in a routine
  router.put('/routine/<routineId>/exercise', (Request request) async {
    final routineId = int.parse(request.params['routineId']!);
    final payload = json.decode(await request.readAsString());
    final exercises = payload['Exercises'] as List;

    for (final exercise in exercises) {
      await dbHelper.connection.query(
        'UPDATE RoutineExercise SET Sets = @sets, Reps = @reps, HoldTime = @holdTime, Notes = @notes, Ord = @ord WHERE RoutineID = @routineId AND ExerciseID = @exerciseId',
        substitutionValues: {
          'sets': exercise['Sets'],
          'reps': exercise['Reps'],
          'holdTime': exercise['HoldTime'],
          'notes': exercise['Notes'],
          'ord': exercise['Ord'],
          'routineId': routineId,
          'exerciseId': exercise['ExerciseID']
        },
      );
    }

    return Response.ok('Exercises updated in routine', headers: _headers);
  });

  // Delete an exercise from a routine
  router.delete('/routine/<routineId>/exercise/<exerciseId>',
      (Request request) async {
    final routineId = int.parse(request.params['routineId']!);
    final exerciseId = int.parse(request.params['exerciseId']!);

    await dbHelper.connection.query(
      'DELETE FROM RoutineExercise WHERE RoutineID = @routineId AND ExerciseID = @exerciseId',
      substitutionValues: {'routineId': routineId, 'exerciseId': exerciseId},
    );

    return Response.ok('Exercise deleted from routine', headers: _headers);
  });

  // Delete all exercises from a routine
  router.delete('/routine/<id>/exercise', (Request request) async {
    final id = int.parse(request.params['id']!);

    await dbHelper.connection.query(
      'DELETE FROM RoutineExercise WHERE RoutineID = @id',
      substitutionValues: {'id': id},
    );

    return Response.ok('All exercises deleted from routine', headers: _headers);
  });

  // sets up the middleware pipeline for logging requests and handling CORS,
  // and then starts the server.

  final handler = const Pipeline()
      .addMiddleware(logRequests())
      .addMiddleware(corsHeaders())
      .addHandler(router.call);

  final port = int.parse(Platform.environment['PORT'] ?? '8080');
  final server = await io.serve(handler, 'localhost', port);

  print('Server listening on port ${server.port}');
}
