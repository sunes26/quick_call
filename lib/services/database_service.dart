import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:quick_call/models/speed_dial_button.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, 'quick_call.db');

    return await openDatabase(
      path,
      version: 6, // 🆕 버전 6: groups 테이블 추가
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // speed_dial_buttons 테이블
    await db.execute('''
      CREATE TABLE speed_dial_buttons (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        phoneNumber TEXT NOT NULL,
        color INTEGER DEFAULT 4283215695,
        `group` TEXT DEFAULT '일반',
        position INTEGER NOT NULL,
        createdAt TEXT NOT NULL,
        lastCalled TEXT,
        isInWidget INTEGER DEFAULT 0,
        widgetPosition INTEGER DEFAULT -1
      )
    ''');

    await db.execute('''
      CREATE INDEX idx_position ON speed_dial_buttons(position)
    ''');

    await db.execute('''
      CREATE INDEX idx_group ON speed_dial_buttons(`group`)
    ''');

    await db.execute('''
      CREATE INDEX idx_widget ON speed_dial_buttons(isInWidget, widgetPosition)
    ''');

    // 🆕 groups 테이블
    await db.execute('''
      CREATE TABLE groups (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL UNIQUE,
        position INTEGER NOT NULL,
        createdAt TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE INDEX idx_group_position ON groups(position)
    ''');

    // 🆕 기본 그룹 추가 (전체는 가상 그룹이므로 DB에 저장하지 않음)
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('''
        ALTER TABLE speed_dial_buttons ADD COLUMN `group` TEXT DEFAULT '일반'
      ''');
      
      await db.execute('''
        CREATE INDEX idx_group ON speed_dial_buttons(`group`)
      ''');
    }

    if (oldVersion < 3) {
      await db.execute('''
        ALTER TABLE speed_dial_buttons ADD COLUMN isInWidget INTEGER DEFAULT 0
      ''');
      
      await db.execute('''
        ALTER TABLE speed_dial_buttons ADD COLUMN widgetPosition INTEGER DEFAULT -1
      ''');
      
      await db.execute('''
        CREATE INDEX idx_widget ON speed_dial_buttons(isInWidget, widgetPosition)
      ''');
    }

    if (oldVersion < 4) {
      await db.execute('''
        ALTER TABLE speed_dial_buttons ADD COLUMN color INTEGER DEFAULT 4283215695
      ''');
    }

    // 버전 5: 완전히 새로운 스키마로 마이그레이션
    if (oldVersion < 5) {
      debugPrint('버전 5로 업그레이드: 기존 데이터 마이그레이션 시작');
      
      // 1. 기존 데이터 백업
      final List<Map<String, dynamic>> oldData = await db.query('speed_dial_buttons');
      
      // 2. 기존 테이블 삭제
      await db.execute('DROP TABLE IF EXISTS speed_dial_buttons');
      await db.execute('DROP INDEX IF EXISTS idx_position');
      await db.execute('DROP INDEX IF EXISTS idx_group');
      await db.execute('DROP INDEX IF EXISTS idx_widget');
      
      // 3. 새 테이블 생성
      await db.execute('''
        CREATE TABLE speed_dial_buttons (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL,
          phoneNumber TEXT NOT NULL,
          color INTEGER DEFAULT 4283215695,
          `group` TEXT DEFAULT '일반',
          position INTEGER NOT NULL,
          createdAt TEXT NOT NULL,
          lastCalled TEXT,
          isInWidget INTEGER DEFAULT 0,
          widgetPosition INTEGER DEFAULT -1
        )
      ''');
      
      await db.execute('''
        CREATE INDEX idx_position ON speed_dial_buttons(position)
      ''');
      
      await db.execute('''
        CREATE INDEX idx_group ON speed_dial_buttons(`group`)
      ''');
      
      await db.execute('''
        CREATE INDEX idx_widget ON speed_dial_buttons(isInWidget, widgetPosition)
      ''');
      
      // 4. 기존 데이터 복원
      for (var row in oldData) {
        try {
          await db.insert('speed_dial_buttons', {
            'name': row['name'],
            'phoneNumber': row['phoneNumber'],
            'color': row['color'] ?? 4283215695,
            'group': row['group'] ?? '일반',
            'position': row['position'],
            'createdAt': row['createdAt'],
            'lastCalled': row['lastCalled'],
            'isInWidget': row['isInWidget'] ?? 0,
            'widgetPosition': row['widgetPosition'] ?? -1,
          });
        } catch (e) {
          debugPrint('데이터 복원 오류 (무시): $e');
        }
      }
      
      debugPrint('버전 5로 업그레이드 완료: ${oldData.length}개 데이터 마이그레이션됨');
    }

    // 🆕 버전 6: groups 테이블 추가
    if (oldVersion < 6) {
      debugPrint('버전 6으로 업그레이드: groups 테이블 추가');
      
      // 1. groups 테이블 생성
      await db.execute('''
        CREATE TABLE IF NOT EXISTS groups (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL UNIQUE,
          position INTEGER NOT NULL,
          createdAt TEXT NOT NULL
        )
      ''');

      await db.execute('''
        CREATE INDEX IF NOT EXISTS idx_group_position ON groups(position)
      ''');

      // 2. 기존 버튼들의 그룹을 groups 테이블에 마이그레이션
      final List<Map<String, dynamic>> existingGroups = await db.rawQuery(
        'SELECT DISTINCT `group` FROM speed_dial_buttons ORDER BY `group` ASC'
      );

      int position = 0;
      for (var row in existingGroups) {
        final groupName = row['group'] as String;
        // "전체"는 가상 그룹이므로 저장하지 않음
        if (groupName != '전체') {
          try {
            await db.insert('groups', {
              'name': groupName,
              'position': position,
              'createdAt': DateTime.now().toIso8601String(),
            });
            position++;
          } catch (e) {
            debugPrint('그룹 마이그레이션 오류 (무시): $e');
          }
        }
      }

      debugPrint('버전 6으로 업그레이드 완료: ${existingGroups.length}개 그룹 마이그레이션됨');
    }
  }

  Future<void> initialize() async {
    await database;
  }

  // ==================== 버튼 관련 메서드 ====================

  // 새 버튼 추가
  Future<int> insertButton(SpeedDialButton button) async {
    final db = await database;
    return await db.insert(
      'speed_dial_buttons',
      button.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // 모든 버튼 조회 (position 순으로 정렬)
  Future<List<SpeedDialButton>> getAllButtons() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'speed_dial_buttons',
      orderBy: 'position ASC',
    );

    return List.generate(maps.length, (i) {
      return SpeedDialButton.fromMap(maps[i]);
    });
  }

  // 위젯에 표시되는 버튼만 조회 (widgetPosition 순으로 정렬)
  Future<List<SpeedDialButton>> getWidgetButtons() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'speed_dial_buttons',
      where: 'isInWidget = ?',
      whereArgs: [1],
      orderBy: 'widgetPosition ASC',
    );

    return List.generate(maps.length, (i) {
      return SpeedDialButton.fromMap(maps[i]);
    });
  }

  // 특정 그룹의 버튼들만 조회
  Future<List<SpeedDialButton>> getButtonsByGroup(String group) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'speed_dial_buttons',
      where: '`group` = ?',
      whereArgs: [group],
      orderBy: 'position ASC',
    );

    return List.generate(maps.length, (i) {
      return SpeedDialButton.fromMap(maps[i]);
    });
  }

  // 특정 버튼 조회
  Future<SpeedDialButton?> getButton(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'speed_dial_buttons',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (maps.isEmpty) return null;
    return SpeedDialButton.fromMap(maps.first);
  }

  // 버튼 정보 업데이트
  Future<bool> updateButton(SpeedDialButton button) async {
    final db = await database;
    final count = await db.update(
      'speed_dial_buttons',
      button.toMap(),
      where: 'id = ?',
      whereArgs: [button.id],
    );
    return count > 0;
  }

  // 여러 버튼의 위젯 정보 일괄 업데이트
  Future<bool> updateWidgetButtons(List<SpeedDialButton> buttons) async {
    final db = await database;
    
    try {
      await db.transaction((txn) async {
        // 먼저 모든 버튼의 isInWidget을 false로 설정
        await txn.update(
          'speed_dial_buttons',
          {'isInWidget': 0, 'widgetPosition': -1},
        );
        
        // 선택된 버튼들을 위젯에 추가
        for (int i = 0; i < buttons.length; i++) {
          await txn.update(
            'speed_dial_buttons',
            {
              'isInWidget': 1,
              'widgetPosition': i,
            },
            where: 'id = ?',
            whereArgs: [buttons[i].id],
          );
        }
      });
      
      return true;
    } catch (e) {
      debugPrint('위젯 버튼 업데이트 오류: $e');
      return false;
    }
  }

  // 버튼 삭제
  Future<bool> deleteButton(int id) async {
    final db = await database;
    final count = await db.delete(
      'speed_dial_buttons',
      where: 'id = ?',
      whereArgs: [id],
    );
    return count > 0;
  }

  // 특정 그룹의 모든 버튼 삭제
  Future<int> deleteButtonsByGroup(String group) async {
    final db = await database;
    return await db.delete(
      'speed_dial_buttons',
      where: '`group` = ?',
      whereArgs: [group],
    );
  }

  // 모든 버튼 삭제
  Future<void> deleteAllButtons() async {
    final db = await database;
    await db.delete('speed_dial_buttons');
  }

  // 마지막 통화 시간 업데이트
  Future<bool> updateLastCalled(int id) async {
    final db = await database;
    final count = await db.update(
      'speed_dial_buttons',
      {'lastCalled': DateTime.now().toIso8601String()},
      where: 'id = ?',
      whereArgs: [id],
    );
    return count > 0;
  }

  // 여러 버튼의 position 일괄 업데이트 (드래그 앤 드롭 순서 변경용)
  Future<void> updateButtonPositions(List<SpeedDialButton> buttons) async {
    final db = await database;
    final batch = db.batch();

    for (var button in buttons) {
      batch.update(
        'speed_dial_buttons',
        {'position': button.position},
        where: 'id = ?',
        whereArgs: [button.id],
      );
    }

    await batch.commit(noResult: true);
  }

  // 버튼 개수 조회
  Future<int> getButtonCount() async {
    final db = await database;
    final result = await db.rawQuery('SELECT COUNT(*) FROM speed_dial_buttons');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  // 위젯에 표시되는 버튼 개수 조회
  Future<int> getWidgetButtonCount() async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) FROM speed_dial_buttons WHERE isInWidget = 1'
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  // 특정 그룹의 버튼 개수 조회
  Future<int> getButtonCountByGroup(String group) async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) FROM speed_dial_buttons WHERE `group` = ?',
      [group],
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  // 전화번호로 검색
  Future<List<SpeedDialButton>> searchByPhoneNumber(String phoneNumber) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'speed_dial_buttons',
      where: 'phoneNumber LIKE ?',
      whereArgs: ['%$phoneNumber%'],
    );

    return List.generate(maps.length, (i) {
      return SpeedDialButton.fromMap(maps[i]);
    });
  }

  // 이름으로 검색
  Future<List<SpeedDialButton>> searchByName(String name) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'speed_dial_buttons',
      where: 'name LIKE ?',
      whereArgs: ['%$name%'],
    );

    return List.generate(maps.length, (i) {
      return SpeedDialButton.fromMap(maps[i]);
    });
  }

  // 정확히 일치하는 전화번호로 검색 (숫자만 비교)
  Future<SpeedDialButton?> findByExactPhoneNumber(
    String phoneNumber, {
    int? excludeId,
  }) async {
    final db = await database;
    
    final cleanedInput = phoneNumber.replaceAll(RegExp(r'[^\d]'), '');
    final List<Map<String, dynamic>> maps = await db.query('speed_dial_buttons');
    
    for (var map in maps) {
      final buttonId = map['id'] as int;
      
      if (excludeId != null && buttonId == excludeId) {
        continue;
      }
      
      final buttonPhone = map['phoneNumber'] as String;
      final cleanedButtonPhone = buttonPhone.replaceAll(RegExp(r'[^\d]'), '');
      
      if (cleanedInput == cleanedButtonPhone) {
        return SpeedDialButton.fromMap(map);
      }
    }
    
    return null;
  }

  // ==================== 🆕 그룹 관련 메서드 ====================

  /// 모든 그룹 목록 조회 (position 순으로 정렬)
  Future<List<String>> getAllGroups() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'groups',
      orderBy: 'position ASC',
    );

    return maps.map((map) => map['name'] as String).toList();
  }

  /// 🆕 그룹 추가
  Future<int> insertGroup(String groupName) async {
    final db = await database;
    
    try {
      // 현재 최대 position 조회
      final List<Map<String, dynamic>> maxPosResult = await db.rawQuery(
        'SELECT MAX(position) as maxPos FROM groups'
      );
      final maxPosition = (maxPosResult.first['maxPos'] as int?) ?? -1;

      return await db.insert(
        'groups',
        {
          'name': groupName,
          'position': maxPosition + 1,
          'createdAt': DateTime.now().toIso8601String(),
        },
        conflictAlgorithm: ConflictAlgorithm.ignore, // 중복 무시
      );
    } catch (e) {
      debugPrint('그룹 추가 오류: $e');
      return -1;
    }
  }

  /// 🆕 그룹 삭제
  Future<bool> deleteGroup(String groupName) async {
    final db = await database;
    
    try {
      final count = await db.delete(
        'groups',
        where: 'name = ?',
        whereArgs: [groupName],
      );
      return count > 0;
    } catch (e) {
      debugPrint('그룹 삭제 오류: $e');
      return false;
    }
  }

  /// 🆕 그룹 이름 변경
  Future<int> renameGroup(String oldGroupName, String newGroupName) async {
    final db = await database;
    
    try {
      int updatedCount = 0;
      
      await db.transaction((txn) async {
        // 1. groups 테이블 업데이트
        await txn.update(
          'groups',
          {'name': newGroupName},
          where: 'name = ?',
          whereArgs: [oldGroupName],
        );

        // 2. speed_dial_buttons 테이블의 group 필드 업데이트
        updatedCount = await txn.update(
          'speed_dial_buttons',
          {'group': newGroupName},
          where: '`group` = ?',
          whereArgs: [oldGroupName],
        );
      });
      
      return updatedCount;
    } catch (e) {
      debugPrint('그룹 이름 변경 오류: $e');
      return 0;
    }
  }

  /// 🆕 그룹 존재 여부 확인
  Future<bool> groupExists(String groupName) async {
    final db = await database;
    final result = await db.query(
      'groups',
      where: 'name = ?',
      whereArgs: [groupName],
      limit: 1,
    );
    return result.isNotEmpty;
  }

  /// 🆕 그룹 순서 변경
  Future<bool> updateGroupPositions(List<String> groupNames) async {
    final db = await database;
    
    try {
      await db.transaction((txn) async {
        for (int i = 0; i < groupNames.length; i++) {
          await txn.update(
            'groups',
            {'position': i},
            where: 'name = ?',
            whereArgs: [groupNames[i]],
          );
        }
      });
      return true;
    } catch (e) {
      debugPrint('그룹 순서 변경 오류: $e');
      return false;
    }
  }

  /// 🆕 그룹 개수 조회
  Future<int> getGroupCount() async {
    final db = await database;
    final result = await db.rawQuery('SELECT COUNT(*) FROM groups');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  /// 🆕 모든 그룹 데이터 조회 (백업용)
  Future<List<Map<String, dynamic>>> exportAllGroups() async {
    final db = await database;
    return await db.query('groups', orderBy: 'position ASC');
  }

  /// 🆕 그룹 데이터 복원 (백업 복원용)
  Future<bool> importGroups(List<Map<String, dynamic>> groups, {bool clearExisting = true}) async {
    final db = await database;
    
    try {
      await db.transaction((txn) async {
        if (clearExisting) {
          await txn.delete('groups');
        }
        
        for (var group in groups) {
          await txn.insert(
            'groups',
            {
              'name': group['name'],
              'position': group['position'],
              'createdAt': group['createdAt'] ?? DateTime.now().toIso8601String(),
            },
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
        }
      });
      
      return true;
    } catch (e) {
      debugPrint('그룹 데이터 복원 오류: $e');
      return false;
    }
  }

  // ==================== 트랜잭션 기반 메서드들 ====================

  /// 버튼 삭제 후 position 자동 재정렬 (트랜잭션)
  Future<bool> deleteButtonAndReorder(int id) async {
    final db = await database;
    
    try {
      await db.transaction((txn) async {
        final deleteCount = await txn.delete(
          'speed_dial_buttons',
          where: 'id = ?',
          whereArgs: [id],
        );
        
        if (deleteCount == 0) {
          throw Exception('버튼을 찾을 수 없습니다.');
        }
        
        final List<Map<String, dynamic>> remainingButtons = await txn.query(
          'speed_dial_buttons',
          orderBy: 'position ASC',
        );
        
        for (int i = 0; i < remainingButtons.length; i++) {
          await txn.update(
            'speed_dial_buttons',
            {'position': i},
            where: 'id = ?',
            whereArgs: [remainingButtons[i]['id']],
          );
        }
      });
      
      return true;
    } catch (e) {
      debugPrint('버튼 삭제 및 재정렬 오류: $e');
      return false;
    }
  }

  /// 버튼 순서 변경 (트랜잭션)
  Future<bool> reorderButtonsTransaction(List<SpeedDialButton> buttons) async {
    final db = await database;
    
    try {
      await db.transaction((txn) async {
        for (var button in buttons) {
          await txn.update(
            'speed_dial_buttons',
            button.toMap(),
            where: 'id = ?',
            whereArgs: [button.id],
          );
        }
      });
      
      return true;
    } catch (e) {
      debugPrint('버튼 순서 변경 오류: $e');
      return false;
    }
  }

  /// 🆕 그룹 삭제 및 관련 버튼 삭제 (트랜잭션)
  Future<int> deleteGroupAndButtons(String groupName) async {
    final db = await database;
    
    try {
      int deletedButtonCount = 0;
      
      await db.transaction((txn) async {
        // 1. 해당 그룹의 버튼 삭제
        deletedButtonCount = await txn.delete(
          'speed_dial_buttons',
          where: '`group` = ?',
          whereArgs: [groupName],
        );

        // 2. 그룹 삭제
        await txn.delete(
          'groups',
          where: 'name = ?',
          whereArgs: [groupName],
        );

        // 3. 남은 버튼들 position 재정렬
        final List<Map<String, dynamic>> remainingButtons = await txn.query(
          'speed_dial_buttons',
          orderBy: 'position ASC',
        );
        
        for (int i = 0; i < remainingButtons.length; i++) {
          await txn.update(
            'speed_dial_buttons',
            {'position': i},
            where: 'id = ?',
            whereArgs: [remainingButtons[i]['id']],
          );
        }

        // 4. 남은 그룹들 position 재정렬
        final List<Map<String, dynamic>> remainingGroups = await txn.query(
          'groups',
          orderBy: 'position ASC',
        );
        
        for (int i = 0; i < remainingGroups.length; i++) {
          await txn.update(
            'groups',
            {'position': i},
            where: 'id = ?',
            whereArgs: [remainingGroups[i]['id']],
          );
        }
      });
      
      return deletedButtonCount;
    } catch (e) {
      debugPrint('그룹 및 버튼 삭제 오류: $e');
      return -1;
    }
  }

  /// 모든 데이터 백업
  Future<List<SpeedDialButton>> exportAllData() async {
    final db = await database;
    
    try {
      final List<Map<String, dynamic>> maps = await db.query(
        'speed_dial_buttons',
        orderBy: 'position ASC',
      );
      
      return List.generate(maps.length, (i) {
        return SpeedDialButton.fromMap(maps[i]);
      });
    } catch (e) {
      debugPrint('데이터 백업 오류: $e');
      return [];
    }
  }

  /// 백업 데이터 복원 (트랜잭션)
  Future<bool> importData(
    List<SpeedDialButton> buttons, {
    bool clearExisting = true,
  }) async {
    final db = await database;
    
    try {
      await db.transaction((txn) async {
        if (clearExisting) {
          await txn.delete('speed_dial_buttons');
        }
        
        for (var button in buttons) {
          await txn.insert(
            'speed_dial_buttons',
            button.toMap(),
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
        }
      });
      
      return true;
    } catch (e) {
      debugPrint('데이터 복원 오류: $e');
      return false;
    }
  }

  /// 여러 버튼을 한 번에 삭제 (트랜잭션)
  Future<int> deleteMultipleButtons(List<int> ids) async {
    final db = await database;
    
    try {
      int deletedCount = 0;
      
      await db.transaction((txn) async {
        for (var id in ids) {
          final count = await txn.delete(
            'speed_dial_buttons',
            where: 'id = ?',
            whereArgs: [id],
          );
          deletedCount += count;
        }
        
        final List<Map<String, dynamic>> remainingButtons = await txn.query(
          'speed_dial_buttons',
          orderBy: 'position ASC',
        );
        
        for (int i = 0; i < remainingButtons.length; i++) {
          await txn.update(
            'speed_dial_buttons',
            {'position': i},
            where: 'id = ?',
            whereArgs: [remainingButtons[i]['id']],
          );
        }
      });
      
      return deletedCount;
    } catch (e) {
      debugPrint('여러 버튼 삭제 오류: $e');
      return 0;
    }
  }

  /// 버튼 복제 (트랜잭션)
  Future<int> duplicateButton(int buttonId) async {
    final db = await database;
    
    try {
      int newId = -1;
      
      await db.transaction((txn) async {
        final List<Map<String, dynamic>> maps = await txn.query(
          'speed_dial_buttons',
          where: 'id = ?',
          whereArgs: [buttonId],
          limit: 1,
        );
        
        if (maps.isEmpty) {
          throw Exception('복제할 버튼을 찾을 수 없습니다.');
        }
        
        final List<Map<String, dynamic>> maxPositionResult = await txn.rawQuery(
          'SELECT MAX(position) as maxPos FROM speed_dial_buttons'
        );
        final maxPosition = (maxPositionResult.first['maxPos'] as int?) ?? -1;
        
        final originalButton = SpeedDialButton.fromMap(maps.first);
        final newButton = originalButton.copyWith(
          id: null,
          name: '${originalButton.name} (복사)',
          position: maxPosition + 1,
          createdAt: DateTime.now(),
          lastCalled: null,
          isInWidget: false,
          widgetPosition: -1,
        );
        
        newId = await txn.insert(
          'speed_dial_buttons',
          newButton.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      });
      
      return newId;
    } catch (e) {
      debugPrint('버튼 복제 오류: $e');
      return -1;
    }
  }

  // 데이터베이스 닫기
  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}