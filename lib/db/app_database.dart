import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:intl/intl.dart';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

part 'app_database.g.dart'; // required for Drift codegen

// Notes Table
class Notes extends Table {

  IntColumn get id => integer().autoIncrement()();

  TextColumn get title => text()();

  TextColumn get content => text()();
  TextColumn get day => text()();   // no default, set manually

  TextColumn get date => text()();  // no default, set manually
}

// Database
@DriftDatabase(tables: [Notes])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection()); // <-- semicolon added ✅

  @override
  int get schemaVersion => 1;


  Future<int> insertNote(NotesCompanion note) => into(notes).insert(note);

  Future<List<Note>> getAllNotes() => select(notes).get();


  Future<int> deleteNoteById(int id) {
    return (delete(notes)..where((t) => t.id.equals(id))).go();
  }


  Future<void> updateNote(int id, String title, String content, String day, String date) async {
    await (update(notes)..where((tbl) => tbl.id.equals(id))).write(
      NotesCompanion(
        title: Value(title),
        content: Value(content),
        day: Value(day),
        date: Value(date),
      ),
    );
  }

  Future<void> deleteAllNotes() async {
    await delete(notes).go();
  }




}

// Connection
LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    // Get the app documents directory
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'notes.db'));
    return NativeDatabase.createInBackground(file);
  });
}
