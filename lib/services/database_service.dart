// lib/services/database_service.dart
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/medication.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  static Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDB();
    return _db!;
  }

  Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'medications.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE medications (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT,
            dosage TEXT,
            dosesPerDay INTEGER,
            firstDoseTime TEXT,
            frequency TEXT,
            selectedDays TEXT,
            durationInDays INTEGER,
            isPermanent INTEGER,
            intervalHours INTEGER
          );
        ''');

        await db.execute('''
          CREATE TABLE adherence_logs (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            medName TEXT,
            dosage TEXT,
            scheduledTime TEXT,
            actualTime TEXT,
            taken INTEGER
          );
        ''');
      },
    );
  }

  Future<void> insertMedication(Medication med) async {
    final db = await database;
    await db.insert('medications', {
      'name': med.name,
      'dosage': med.dosage,
      'dosesPerDay': med.dosesPerDay,
      'firstDoseTime': med.firstDoseTime.toIso8601String(),
      'frequency': med.frequency,
      'selectedDays': med.selectedDays.join(','),
      'durationInDays': med.durationInDays,
      'isPermanent': med.isPermanent ? 1 : 0,
      'intervalHours': med.intervalHours ?? 0,
    });
  }

  Future<void> insertAdherenceLog(
  String medName,
  String scheduledTime,
  DateTime actualTime,
  bool taken, [
  String? dosage,
]) async {
    final db = await database;
    final existing = await db.query(
      'adherence_logs',
      where: 'medName = ? AND scheduledTime = ?',
      whereArgs: [medName, scheduledTime],
    );

    if (existing.isNotEmpty) {
      await db.update(
        'adherence_logs',
        {
          'actualTime': actualTime.toIso8601String(),
          'taken': taken ? 1 : 0,
        },
        where: 'medName = ? AND scheduledTime = ?',
        whereArgs: [medName, scheduledTime],
      );
    } else {
      await db.insert('adherence_logs', {
        'medName': medName,
        'dosage': dosage ?? 'غير محدد',
        'scheduledTime': scheduledTime,
        'actualTime': actualTime.toIso8601String(),
        'taken': taken ? 1 : 0,
      });
    }
  }

  Future<List<Map<String, dynamic>>> fetchTodayDoses() async {
    final db = await database;
    final now = DateTime.now();
    final todayStr = now.toIso8601String().split('T').first;

    final logs = await db.query(
      'adherence_logs',
      where: 'scheduledTime LIKE ?',
      whereArgs: ['%$todayStr%'],
      orderBy: 'scheduledTime ASC',
    );

    return logs.map((e) {
      return {
        'name': e['medName'],
        'dosage': e['dosage'] ?? 'غير محدد',
        'time': DateTime.parse(e['scheduledTime'] as String),
        'status': (e['taken'] as int) == 1 ? 'taken' : 'pending',
      };
    }).toList();
  }

  Future<List<Map<String, dynamic>>> getAdherenceLogs() async {
    final db = await database;
    final result = await db.query('adherence_logs');
    return result.map((e) {
      return {
        'name': e['medName'],
        'scheduledTime': e['scheduledTime'],
        'actualTime': e['actualTime'],
        'taken': (e['taken'] as int) == 1,
      };
    }).toList();
  }
}