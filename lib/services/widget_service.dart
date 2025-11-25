// lib/services/widget_service.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:quick_call/models/speed_dial_button.dart';
import 'dart:convert';

/// 홈 화면 위젯과 Flutter 앱 간 통신을 담당하는 서비스
class WidgetService {
  static const MethodChannel _channel = MethodChannel('com.example.quick_call/widget');
  
  /// 전체 버튼 데이터 저장 (위젯 설정 화면용)
  /// 
  /// [buttons]: 모든 단축키 버튼 목록
  Future<bool> saveAllButtonsData(List<SpeedDialButton> buttons) async {
    try {
      final data = buttons.map((button) => {
        'id': button.id,
        'name': button.name,
        'phoneNumber': button.phoneNumber,
        'iconCodePoint': button.iconData.codePoint,
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
  Future<bool> updateWidgetData(int widgetId, List<SpeedDialButton> buttons) async {
    try {
      final data = buttons.take(4).map((button) => {
        'id': button.id,
        'name': button.name,
        'phoneNumber': button.phoneNumber,
        'iconCodePoint': button.iconData.codePoint,
        'group': button.group,
      }).toList();
      
      final jsonData = jsonEncode(data);
      
      final result = await _channel.invokeMethod('updateWidgetData', {
        'widgetId': widgetId,
        'data': jsonData,
      });
      
      debugPrint('위젯 $widgetId 업데이트 완료: ${buttons.length}개 버튼');
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