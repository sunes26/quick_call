// lib/services/widget_service.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:quick_call/models/speed_dial_button.dart';
import 'dart:convert';

/// 홈 화면 위젯과 Flutter 앱 간 통신을 담당하는 서비스
/// 다양한 위젯 크기 지원: 2×2(4), 3×2(6), 4×2(8), 3×3(9), 4×3(12), 4×4(16)
class WidgetService {
  // 🔧 수정: 채널명을 MainActivity.kt와 일치시킴
  static const MethodChannel _channel = MethodChannel('com.oceancode.quick_call/widget');
  
  /// 전체 버튼 데이터 저장 (위젯 설정 화면용)
  /// 
  /// [buttons]: 모든 단축키 버튼 목록
  Future<bool> saveAllButtonsData(List<SpeedDialButton> buttons) async {
    try {
      final data = buttons.map((button) => {
        'id': button.id,
        'name': button.name,
        'phoneNumber': button.phoneNumber,
        'color': button.color.toARGB32(), // 🆕 color 추가
        'group': button.group,
      }).toList();
      
      final jsonData = jsonEncode(data);
      
      final result = await _channel.invokeMethod('saveAllButtonsData', {
        'data': jsonData,
      });
      
      debugPrint('전체 버튼 데이터 저장 완료: ${buttons.length}개');
      return result == true;
    } catch (e) {
      debugPrint('전체 버튼 데이터 저장 오류: $e');
      return false;
    }
  }
  
  /// 특정 위젯의 데이터 업데이트
  /// 
  /// [widgetId]: 위젯 ID
  /// [buttons]: 해당 위젯에 표시할 버튼 목록
  /// 
  /// ⚠️ 주의: 위젯 크기에 따라 버튼 개수가 제한됩니다
  /// - 2×2: 최대 4개
  /// - 3×2: 최대 6개
  /// - 4×2: 최대 8개
  /// - 3×3: 최대 9개
  /// - 4×3: 최대 12개
  /// - 4×4: 최대 16개
  Future<bool> updateWidgetData(int widgetId, List<SpeedDialButton> buttons) async {
    try {
      // 위젯 크기에 따라 버튼 개수 제한
      final sizeInfo = await getWidgetSize(widgetId);
      final maxButtons = sizeInfo['maxButtons'] ?? 4;
      
      final limitedButtons = buttons.take(maxButtons).toList();
      
      final data = limitedButtons.map((button) => {
        'id': button.id,
        'name': button.name,
        'phoneNumber': button.phoneNumber,
        'color': button.color.toARGB32(), // 🆕 color 추가
        'group': button.group,
      }).toList();
      
      final jsonData = jsonEncode(data);
      
      final result = await _channel.invokeMethod('updateWidgetData', {
        'widgetId': widgetId,
        'data': jsonData,
      });
      
      debugPrint('위젯 $widgetId 업데이트 완료: ${limitedButtons.length}개 버튼 (최대 $maxButtons개)');
      return result == true;
    } catch (e) {
      debugPrint('위젯 업데이트 오류: $e');
      return false;
    }
  }
  
  /// 모든 위젯 새로고침
  Future<void> refreshAllWidgets() async {
    try {
      await _channel.invokeMethod('refreshAllWidgets');
      debugPrint('모든 위젯 새로고침 완료');
    } catch (e) {
      debugPrint('위젯 새로고침 오류: $e');
    }
  }
  
  /// 설치된 위젯 ID 목록 가져오기
  Future<List<int>> getWidgetIds() async {
    try {
      final result = await _channel.invokeMethod('getWidgetIds');
      if (result is List) {
        return result.cast<int>();
      }
      return [];
    } catch (e) {
      debugPrint('위젯 ID 조회 오류: $e');
      return [];
    }
  }
  
  /// 특정 위젯의 데이터 가져오기
  Future<String?> getWidgetData(int widgetId) async {
    try {
      final result = await _channel.invokeMethod('getWidgetData', {
        'widgetId': widgetId,
      });
      return result as String?;
    } catch (e) {
      debugPrint('위젯 데이터 조회 오류: $e');
      return null;
    }
  }
  
  /// 🆕 특정 위젯의 크기 정보 가져오기
  /// 
  /// 반환값:
  /// - width: 위젯 너비 (dp)
  /// - height: 위젯 높이 (dp)
  /// - maxButtons: 해당 크기에서 지원하는 최대 버튼 개수
  Future<Map<String, int>> getWidgetSize(int widgetId) async {
    try {
      final result = await _channel.invokeMethod('getWidgetSize', {
        'widgetId': widgetId,
      });
      
      if (result is Map) {
        return {
          'width': result['width'] as int? ?? 180,
          'height': result['height'] as int? ?? 180,
          'maxButtons': result['maxButtons'] as int? ?? 4,
        };
      }
      
      return {'width': 180, 'height': 180, 'maxButtons': 4};
    } catch (e) {
      debugPrint('위젯 크기 조회 오류: $e');
      return {'width': 180, 'height': 180, 'maxButtons': 4};
    }
  }
  
  /// 🆕 위젯 크기에 따른 설명 텍스트 가져오기
  String getWidgetSizeDescription(int maxButtons) {
    switch (maxButtons) {
      case 16:
        return '4×4 위젯 (최대 16개 버튼)';
      case 12:
        return '4×3 위젯 (최대 12개 버튼)';
      case 9:
        return '3×3 위젯 (최대 9개 버튼)';
      case 8:
        return '4×2 위젯 (최대 8개 버튼)';
      case 6:
        return '3×2 위젯 (최대 6개 버튼)';
      case 4:
      default:
        return '2×2 위젯 (최대 4개 버튼)';
    }
  }
  
  /// 위젯이 설치되어 있는지 확인
  Future<bool> hasWidgets() async {
    try {
      final result = await _channel.invokeMethod('hasWidgets');
      return result == true;
    } catch (e) {
      debugPrint('위젯 확인 오류: $e');
      return false;
    }
  }
  
  /// 모든 위젯 데이터 삭제
  Future<void> clearAllWidgets() async {
    try {
      await _channel.invokeMethod('clearAllWidgets');
      debugPrint('모든 위젯 데이터 삭제 완료');
    } catch (e) {
      debugPrint('위젯 데이터 삭제 오류: $e');
    }
  }
}