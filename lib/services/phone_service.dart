import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:quick_call/utils/phone_formatter.dart';

class PhoneService {
  // 전화 권한 확인
  Future<bool> checkPhonePermission() async {
    final status = await Permission.phone.status;
    return status.isGranted;
  }

  // 전화 권한 요청
  Future<bool> requestPhonePermission() async {
    final status = await Permission.phone.request();
    return status.isGranted;
  }

  // 연락처 권한 확인
  Future<bool> checkContactsPermission() async {
    final status = await Permission.contacts.status;
    return status.isGranted;
  }

  // 연락처 권한 요청
  Future<bool> requestContactsPermission() async {
    final status = await Permission.contacts.request();
    return status.isGranted;
  }

  // 즉시 전화 걸기 (기본 버전 - bool 반환, 하위 호환성)
  Future<bool> makePhoneCall(String phoneNumber) async {
    try {
      // PhoneFormatter 사용하여 전화번호 정리
      final cleanedNumber = PhoneFormatter.cleanPhoneNumber(phoneNumber);
      
      // 전화번호 유효성 검증
      if (cleanedNumber.isEmpty || !PhoneFormatter.isValid(phoneNumber)) {
        debugPrint('유효하지 않은 전화번호: $phoneNumber');
        return false;
      }
      
      // 전화 권한 확인
      if (!await checkPhonePermission()) {
        final granted = await requestPhonePermission();
        if (!granted) {
          debugPrint('전화 권한이 거부되었습니다.');
          return false;
        }
      }

      // 즉시 전화 걸기
      await FlutterPhoneDirectCaller.callNumber(cleanedNumber);
      return true;
    } catch (e) {
      debugPrint('전화 걸기 오류: $e');
      return false;
    }
  }

  // 전화 걸기 (상세 버전 - PhoneCallResult 반환)
  Future<PhoneCallResult> makePhoneCallDetailed(String phoneNumber) async {
    try {
      // PhoneFormatter 사용하여 전화번호 정리
      final cleanedNumber = PhoneFormatter.cleanPhoneNumber(phoneNumber);
      
      // 전화번호 유효성 검증
      if (cleanedNumber.isEmpty) {
        return PhoneCallResult(
          success: false,
          message: '전화번호를 입력해주세요.',
        );
      }

      if (!PhoneFormatter.isValid(phoneNumber)) {
        return PhoneCallResult(
          success: false,
          message: '올바르지 않은 전화번호 형식입니다.',
        );
      }
      
      // 전화 권한 확인
      if (!await checkPhonePermission()) {
        final granted = await requestPhonePermission();
        if (!granted) {
          final status = await Permission.phone.status;
          if (status.isPermanentlyDenied) {
            return PhoneCallResult(
              success: false,
              message: '전화 권한이 거부되었습니다.\n설정에서 권한을 허용해주세요.',
              needsSettings: true,
            );
          }
          return PhoneCallResult(
            success: false,
            message: '전화 권한이 필요합니다.',
          );
        }
      }

      // 즉시 전화 걸기
      await FlutterPhoneDirectCaller.callNumber(cleanedNumber);
      return PhoneCallResult(success: true);
    } catch (e) {
      debugPrint('전화 걸기 오류: $e');
      return PhoneCallResult(
        success: false,
        message: '전화 연결 중 오류가 발생했습니다.',
      );
    }
  }

  // 모든 필요한 권한 확인 및 요청
  Future<Map<String, bool>> checkAndRequestAllPermissions() async {
    final phoneGranted = await checkPhonePermission() || 
                        await requestPhonePermission();
    
    final contactsGranted = await checkContactsPermission() || 
                           await requestContactsPermission();

    return {
      'phone': phoneGranted,
      'contacts': contactsGranted,
    };
  }

  // 긴급 전화 걸기 (권한 확인 없이 즉시 실행)
  Future<bool> makeEmergencyCall(String emergencyNumber) async {
    if (!PhoneFormatter.isEmergencyNumber(emergencyNumber)) {
      debugPrint('올바른 긴급 전화번호가 아닙니다.');
      return false;
    }

    try {
      final cleaned = PhoneFormatter.cleanPhoneNumber(emergencyNumber);
      await FlutterPhoneDirectCaller.callNumber(cleaned);
      return true;
    } catch (e) {
      debugPrint('긴급 전화 연결 오류: $e');
      return false;
    }
  }

  // 권한 설정 화면으로 이동 (permission_handler 패키지 사용)
  Future<bool> goToAppSettings() async {
    try {
      return await openAppSettings();
    } catch (e) {
      debugPrint('설정 화면 열기 오류: $e');
      return false;
    }
  }
}

// 전화 걸기 상세 결과를 담는 클래스 (선택적으로 사용)
class PhoneCallResult {
  final bool success;
  final String? message;
  final bool needsSettings;

  PhoneCallResult({
    required this.success,
    this.message,
    this.needsSettings = false,
  });

  @override
  String toString() {
    return 'PhoneCallResult(success: $success, message: $message, needsSettings: $needsSettings)';
  }
}