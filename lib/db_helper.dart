import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  static const int guestUserId = 1;
  static const String guestUsername = 'Guest';

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('smart_water.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    if (kIsWeb) {
      databaseFactory = databaseFactoryFfiWeb;
      return await openDatabase(
        filePath,
        version: 2,
        onCreate: _createDB,
        onUpgrade: _upgradeDB,
      );
    } else if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }

    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 2,
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT UNIQUE NOT NULL,
        password TEXT NOT NULL,
        is_guest INTEGER NOT NULL DEFAULT 0,
        created_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE logs (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        activity TEXT NOT NULL,
        amount REAL NOT NULL,
        timestamp TEXT NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE settings (
        user_id INTEGER PRIMARY KEY,
        daily_goal REAL NOT NULL DEFAULT 60.0
      )
    ''');

    // Seed default guest user
    await db.insert('users', {
      'id': guestUserId,
      'username': guestUsername,
      'password': '',
      'is_guest': 1,
      'created_at': DateTime.now().toIso8601String(),
    });

    await db.insert('settings', {
      'user_id': guestUserId,
      'daily_goal': 60.0,
    });
  }

  Future<void> _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Ensure settings table exists
      await db.execute('''
        CREATE TABLE IF NOT EXISTS settings (
          user_id INTEGER PRIMARY KEY,
          daily_goal REAL NOT NULL DEFAULT 60.0
        )
      ''');

      // Check if guest exists
      final guest = await db.query('users', where: 'id = ?', whereArgs: [guestUserId]);
      if (guest.isEmpty) {
        await db.rawInsert('''
          INSERT OR IGNORE INTO users (id, username, password, is_guest, created_at)
          VALUES (?, ?, '', 1, ?)
        ''', [guestUserId, guestUsername, DateTime.now().toIso8601String()]);
      }

      final guestSetting = await db.query('settings', where: 'user_id = ?', whereArgs: [guestUserId]);
      if (guestSetting.isEmpty) {
        await db.insert('settings', {
          'user_id': guestUserId,
          'daily_goal': 60.0,
        });
      }
    }
  }

  Future<int> registerUser(String username, String password) async {
    final db = await instance.database;
    final userId = await db.insert('users', {
      'username': username,
      'password': password,
      'is_guest': 0,
      'created_at': DateTime.now().toIso8601String(),
    });

    // Default goal for new user
    await db.insert('settings', {
      'user_id': userId,
      'daily_goal': 60.0,
    }, conflictAlgorithm: ConflictAlgorithm.ignore);

    return userId;
  }

  Future<Map<String, dynamic>?> loginUser(String username, String password) async {
    final db = await instance.database;
    final results = await db.query(
      'users',
      where: 'username = ? AND password = ? AND is_guest = 0',
      whereArgs: [username, password],
    );

    if (results.isNotEmpty) {
      return results.first;
    }
    return null;
  }

  Future<Map<String, dynamic>> getGuestUser() async {
    final db = await instance.database;
    final results = await db.query('users', where: 'id = ?', whereArgs: [guestUserId]);
    if (results.isNotEmpty) {
      return results.first;
    }
    // Fallback if missing
    await db.insert('users', {
      'id': guestUserId,
      'username': guestUsername,
      'password': '',
      'is_guest': 1,
      'created_at': DateTime.now().toIso8601String(),
    }, conflictAlgorithm: ConflictAlgorithm.replace);

    return {
      'id': guestUserId,
      'username': guestUsername,
      'is_guest': 1,
    };
  }

  Future<int> insertLog(int userId, String activity, double amount, {DateTime? customTimestamp}) async {
    final db = await instance.database;
    final time = (customTimestamp ?? DateTime.now()).toIso8601String();
    return await db.insert('logs', {
      'user_id': userId,
      'activity': activity,
      'amount': amount,
      'timestamp': time,
    });
  }

  Future<List<Map<String, dynamic>>> fetchLogs(int userId) async {
    final db = await instance.database;
    return await db.query(
      'logs',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'timestamp DESC',
    );
  }

  Future<int> deleteLog(int id) async {
    final db = await instance.database;
    return await db.delete(
      'logs',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> clearUserLogs(int userId) async {
    final db = await instance.database;
    await db.delete('logs', where: 'user_id = ?', whereArgs: [userId]);
  }

  Future<double> getDailyGoal(int userId) async {
    final db = await instance.database;
    final results = await db.query('settings', where: 'user_id = ?', whereArgs: [userId]);
    if (results.isNotEmpty) {
      return (results.first['daily_goal'] as num).toDouble();
    }
    return 60.0;
  }

  Future<void> setDailyGoal(int userId, double goal) async {
    final db = await instance.database;
    await db.insert(
      'settings',
      {'user_id': userId, 'daily_goal': goal},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Migrates guest logs to a newly logged in or registered user
  Future<int> transferGuestLogs(int toUserId) async {
    final db = await instance.database;
    final count = await db.update(
      'logs',
      {'user_id': toUserId},
      where: 'user_id = ?',
      whereArgs: [guestUserId],
    );

    // Also transfer custom goal if set
    final guestGoal = await getDailyGoal(guestUserId);
    if (guestGoal != 60.0) {
      await setDailyGoal(toUserId, guestGoal);
    }

    return count;
  }

  /// Fetches daily consumption grouped by day (YYYY-MM-DD) for analytics
  Future<List<Map<String, dynamic>>> fetchDailyTotals(int userId, {int days = 7}) async {
    final db = await instance.database;

    // Check if there are any logs for this user
    final anyLogs = await db.query(
      'logs',
      where: 'user_id = ?',
      whereArgs: [userId],
      limit: 1,
    );

    if (anyLogs.isEmpty) {
      return [];
    }

    final now = DateTime.now();
    final startDate = now.subtract(Duration(days: days - 1));
    final startDateStr =
        "${startDate.year.toString().padLeft(4, '0')}-${startDate.month.toString().padLeft(2, '0')}-${startDate.day.toString().padLeft(2, '0')}";

    final results = await db.rawQuery('''
      SELECT substr(timestamp, 1, 10) AS date, SUM(amount) AS total
      FROM logs
      WHERE user_id = ? AND substr(timestamp, 1, 10) >= ?
      GROUP BY substr(timestamp, 1, 10)
      ORDER BY date ASC
    ''', [userId, startDateStr]);

    final Map<String, double> map = {};
    for (var row in results) {
      final date = row['date'] as String;
      final total = (row['total'] as num).toDouble();
      map[date] = total;
    }

    final List<Map<String, dynamic>> dailyTotals = [];
    for (int i = days - 1; i >= 0; i--) {
      final d = now.subtract(Duration(days: i));
      final dateStr =
          "${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}";
      dailyTotals.add({
        'date': dateStr,
        'total': map[dateStr] ?? 0.0,
      });
    }

    return dailyTotals;
  }
}