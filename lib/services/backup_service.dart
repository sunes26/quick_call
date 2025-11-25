import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:quick_call/models/speed_dial_button.dart';
import 'package:quick_call/services/database_service.dart';
import 'package:intl/intl.dart';

/// 백업/복원 서비스
/// 
/// 사용자 데이터를 JSON 형태로 백업하고 복원합니다.
class BackupService {
  static final BackupService _instance = BackupService._internal();
  factory BackupService() => _instance;
  BackupService._internal();

  final DatabaseService _databaseService = DatabaseService();

  /// 백업 데이터 구조
  static const String _backupVersion = '1.0.0';

  /// 백업 파일 생성
  /// 
  /// Returns: 생성된 파일 경로
  Future<String> createBackup() async {
    try {
      // 모든 버튼 데이터 가져오기
      final buttons = await _databaseService.exportAllData();

      // 백업 데이터 구조
      final backupData = {
        'version': _backupVersion,
        'timestamp': DateTime.now().toIso8601String(),
        'buttonCount': buttons.length,
        'buttons': buttons.map((b) => b.toMap()).toList(),
      };

      // JSON 문자열로 변환
      final jsonString = jsonEncode(backupData);

      // 파일 저장 경로
      final directory = await getApplicationDocumentsDirectory();
      final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final fileName = 'quick_call_backup_$timestamp.json';
      final filePath = '${directory.path}/$fileName';

      // 파일에 쓰기
      final file = File(filePath);
      await file.writeAsString(jsonString);

      debugPrint('백업 완료: $filePath');
      return filePath;
    } catch (e) {
      debugPrint('백업 오류: $e');
      rethrow;
    }
  }

  /// 백업 파일에서 복원
  /// 
  /// [filePath]: 백업 파일 경로
  /// [clearExisting]: 기존 데이터 삭제 여부
  /// Returns: 복원된 버튼 개수
  Future<int> restoreFromBackup(String filePath, {bool clearExisting = true}) async {
    try {
      // 파일 읽기
      final file = File(filePath);
      if (!await file.exists()) {
        throw Exception('백업 파일을 찾을 수 없습니다');
      }

      final jsonString = await file.readAsString();
      final backupData = jsonDecode(jsonString) as Map<String, dynamic>;

      // 버전 확인
      final version = backupData['version'] as String?;
      if (version == null) {
        throw Exception('유효하지 않은 백업 파일입니다');
      }

      // 버튼 데이터 추출
      final buttonsData = backupData['buttons'] as List<dynamic>;
      final buttons = buttonsData
          .map((data) => SpeedDialButton.fromMap(data as Map<String, dynamic>))
          .toList();

      // 데이터베이스에 복원
      final success = await _databaseService.importData(
        buttons,
        clearExisting: clearExisting,
      );

      if (success) {
        debugPrint('복원 완료: ${buttons.length}개 버튼');
        return buttons.length;
      } else {
        throw Exception('데이터 복원에 실패했습니다');
      }
    } catch (e) {
      debugPrint('복원 오류: $e');
      rethrow;
    }
  }

  /// 모든 백업 파일 목록 가져오기
  /// 
  /// Returns: 백업 파일 정보 리스트
  Future<List<BackupFileInfo>> getBackupFiles() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final files = directory
          .listSync()
          .whereType<File>()
          .where((file) => file.path.endsWith('.json') && 
                         file.path.contains('quick_call_backup'))
          .toList();

      final backupFiles = <BackupFileInfo>[];

      for (var file in files) {
        try {
          final jsonString = await file.readAsString();
          final backupData = jsonDecode(jsonString) as Map<String, dynamic>;

          final info = BackupFileInfo(
            path: file.path,
            fileName: file.path.split('/').last,
            timestamp: DateTime.parse(backupData['timestamp'] as String),
            buttonCount: backupData['buttonCount'] as int,
            fileSize: await file.length(),
          );

          backupFiles.add(info);
        } catch (e) {
          debugPrint('백업 파일 정보 읽기 오류: ${file.path}, $e');
        }
      }

      // 최신순으로 정렬
      backupFiles.sort((a, b) => b.timestamp.compareTo(a.timestamp));

      return backupFiles;
    } catch (e) {
      debugPrint('백업 파일 목록 조회 오류: $e');
      return [];
    }
  }

  /// 백업 파일 삭제
  /// 
  /// [filePath]: 삭제할 파일 경로
  Future<bool> deleteBackup(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
        debugPrint('백업 파일 삭제: $filePath');
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('백업 파일 삭제 오류: $e');
      return false;
    }
  }

  /// 자동 백업 (앱 종료 시 등)
  /// 
  /// 최대 5개의 백업만 유지
  Future<void> autoBackup() async {
    try {
      // 새 백업 생성
      await createBackup();

      // 오래된 백업 파일 정리 (최대 5개만 유지)
      final backups = await getBackupFiles();
      if (backups.length > 5) {
        for (var i = 5; i < backups.length; i++) {
          await deleteBackup(backups[i].path);
        }
      }
    } catch (e) {
      debugPrint('자동 백업 오류: $e');
    }
  }

  /// 백업 데이터를 외부 저장소로 내보내기
  /// 
  /// (Downloads 폴더 등)
  Future<String> exportBackupToDownloads() async {
    try {
      // 백업 생성
      final backupPath = await createBackup();
      final backupFile = File(backupPath);

      // Downloads 폴더 경로 (Android)
      const downloadsPath = '/storage/emulated/0/Download';
      final downloadsDir = Directory(downloadsPath);

      if (!await downloadsDir.exists()) {
        throw Exception('Downloads 폴더에 접근할 수 없습니다');
      }

      // 파일명
      final fileName = backupPath.split('/').last;
      final newPath = '$downloadsPath/$fileName';

      // 파일 복사
      await backupFile.copy(newPath);

      debugPrint('백업 파일 내보내기 완료: $newPath');
      return newPath;
    } catch (e) {
      debugPrint('백업 내보내기 오류: $e');
      rethrow;
    }
  }
}

/// 백업 파일 정보
class BackupFileInfo {
  final String path;
  final String fileName;
  final DateTime timestamp;
  final int buttonCount;
  final int fileSize;

  BackupFileInfo({
    required this.path,
    required this.fileName,
    required this.timestamp,
    required this.buttonCount,
    required this.fileSize,
  });

  /// 파일 크기를 사람이 읽기 쉬운 형태로 변환
  String get fileSizeFormatted {
    if (fileSize < 1024) {
      return '$fileSize B';
    } else if (fileSize < 1024 * 1024) {
      return '${(fileSize / 1024).toStringAsFixed(1)} KB';
    } else {
      return '${(fileSize / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
  }

  /// 백업 시간을 포맷팅
  String get timestampFormatted {
    return DateFormat('yyyy-MM-dd HH:mm').format(timestamp);
  }

  /// 백업 파일 설명
  String get description {
    return '$timestampFormatted • $buttonCount개 단축키 • $fileSizeFormatted';
  }
}