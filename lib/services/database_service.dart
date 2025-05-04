// lib/services/database_service.dart
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/medication.dart';
import 'adherence_page.dart';

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
    print("تم إضافة دواء: ${med.name}");
  }

  Future<void> insertAdherenceLog(
    String medName,
    String scheduledTime,
    DateTime actualTime,
    bool taken,
  ) async {
    final db = await database;
    await db.insert('adherence_logs', {
      'medName': medName,
      'scheduledTime': scheduledTime,
      'actualTime': actualTime.toIso8601String(),
      'taken': taken ? 1 : 0,
    });
    print("تم إضافة سجل الالتزام: $medName في $scheduledTime");
  }

  Future<List<Map<String, dynamic>>> fetchTodayDoses() async {
    final db = await database;
    final now = DateTime.now();
    final todayStr = now.toIso8601String().split('T').first;

    final meds = await db.query('medications');
    List<Map<String, dynamic>> doses = [];

    for (var med in meds) {
      final int dosesPerDay = med['dosesPerDay'] as int;
      final int interval = med['intervalHours'] as int? ?? (24 ~/ dosesPerDay);
      final startTime = DateTime.parse(med['firstDoseTime'] as String);
      final List<int> selectedDays = (med['selectedDays'] as String)
          .split(',')
          .where((e) => e.trim().isNotEmpty)
          .map((e) => int.tryParse(e.trim()) ?? 0)
          .toList();

      for (int i = 0; i < dosesPerDay; i++) {
        final doseTime = startTime.add(Duration(hours: interval * i));
        final scheduledTime = DateTime(
          now.year,
          now.month,
          now.day,
          doseTime.hour,
          doseTime.minute,
        );

        final frequency = med['frequency'];
        final includeToday =
            frequency == 'daily' ||
            (frequency == 'weekly' && selectedDays.contains(now.weekday)) ||
            (frequency == 'monthly' && selectedDays.contains(now.day));

        if (includeToday) {
          doses.add({
            'name': med['name'],
            'time': scheduledTime,
            'status': 'pending',
            'dosage': med['dosage'],
          });
        }
      }
    }

    final logs = await db.query(
      'adherence_logs',
      where: 'scheduledTime LIKE ?',
      whereArgs: ['%$todayStr%'],
    );

    for (var log in logs) {
      final loggedTime = DateTime.parse(log['scheduledTime'] as String);
      final index = doses.indexWhere((d) =>
          d['name'] == log['medName'] &&
          (d['time'] as DateTime).hour == loggedTime.hour &&
          (d['time'] as DateTime).minute == loggedTime.minute);

      if (index != -1) {
        doses[index]['status'] = (log['taken'] as int) == 1 ? 'taken' : 'skipped';
      } else {
        doses.add({
          'name': log['medName'],
          'time': loggedTime,
          'status': (log['taken'] as int) == 1 ? 'taken' : 'skipped',
          'dosage': 'غير محدد',
        });
      }
    }

    doses.sort((a, b) => (a['time'] as DateTime).compareTo(b['time'] as DateTime));
    return doses;
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