import 'dart:io';

import 'package:postgres/postgres.dart';

class DatabaseHelper {
  final connection = PostgreSQLConnection(
    'localhost',
    5432,
    'pt_flutter',
    username: 'postgres',
    password: 'pgpass',
  );

  Future<void> openConnection() async {
    await connection.open();
  }

  Future<void> createTables() async {
    final file = File('./DDL.sql');
    final contents = await file.readAsString();

    // Split the content by semicolon to get individual statements
    final statements =
        contents.split(';').where((statement) => statement.trim().isNotEmpty);

    // Execute each statement
    for (var statement in statements) {
      await connection.execute(statement.trim());
    }
  }
}
