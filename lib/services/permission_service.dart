import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

/// 권한 관리 서비스
/// 
/// 앱에서 필요한 권한(전화, 연락처)을 관리하고
/// 권한 요청 및 상태 확인을 담당합니다.
class PermissionService {
  // 싱글톤 패턴
  static final PermissionService _instance = PermissionService._internal();
  factory PermissionService() => _instance;
  PermissionService._internal();

  /// 전화 권한 확인
  /// 
  /// Returns: 권한이 승인되었으면 true, 아니면 false
  Future<bool> checkPhonePermission() async {
    try {
      final status = await Permission.phone.status;
      debugPrint('전화 권한 상태: $status');
      return status.isGranted;
    } catch (e) {
      debugPrint('전화 권한 확인 오류: $e');
      return false;
    }
  }

  /// 전화 권한 요청
  /// 
  /// Returns: 권한이 승인되었으면 true, 아니면 false
  Future<bool> requestPhonePermission() async {
    try {
      final status = await Permission.phone.request();
      debugPrint('전화 권한 요청 결과: $status');
      
      if (status.isGranted) {
        return true;
      } else if (status.isDenied) {
        debugPrint('전화 권한이 거부되었습니다.');
        return false;
      } else if (status.isPermanentlyDenied) {
        debugPrint('전화 권한이 영구적으로 거부되었습니다.');
        return false;
      }
      
      return false;
    } catch (e) {
      debugPrint('전화 권한 요청 오류: $e');
      return false;
    }
  }

  /// 연락처 권한 확인
  /// 
  /// Returns: 권한이 승인되었으면 true, 아니면 false
  Future<bool> checkContactsPermission() async {
    try {
      final status = await Permission.contacts.status;
      debugPrint('연락처 권한 상태: $status');
      return status.isGranted;
    } catch (e) {
      debugPrint('연락처 권한 확인 오류: $e');
      return false;
    }
  }

  /// 연락처 권한 요청
  /// 
  /// Returns: 권한이 승인되었으면 true, 아니면 false
  Future<bool> requestContactsPermission() async {
    try {
      final status = await Permission.contacts.request();
      debugPrint('연락처 권한 요청 결과: $status');
      
      if (status.isGranted) {
        return true;
      } else if (status.isDenied) {
        debugPrint('연락처 권한이 거부되었습니다.');
        return false;
      } else if (status.isPermanentlyDenied) {
        debugPrint('연락처 권한이 영구적으로 거부되었습니다.');
        return false;
      }
      
      return false;
    } catch (e) {
      debugPrint('연락처 권한 요청 오류: $e');
      return false;
    }
  }

  /// 특정 권한의 상태 확인
  /// 
  /// [permission]: 확인할 권한
  /// Returns: 권한 상태 정보
  Future<PermissionStatus> checkPermission(Permission permission) async {
    try {
      final status = await permission.status;
      debugPrint('${permission.toString()} 권한 상태: $status');
      return status;
    } catch (e) {
      debugPrint('권한 확인 오류: $e');
      return PermissionStatus.denied;
    }
  }

  /// 모든 필요한 권한을 한번에 확인
  /// 
  /// Returns: 각 권한의 승인 여부를 담은 Map
  Future<Map<String, bool>> checkAllPermissions() async {
    final phoneGranted = await checkPhonePermission();
    final contactsGranted = await checkContactsPermission();

    return {
      'phone': phoneGranted,
      'contacts': contactsGranted,
    };
  }

  /// 모든 필요한 권한을 한번에 요청
  /// 
  /// Returns: 각 권한의 승인 여부를 담은 Map
  Future<Map<String, bool>> requestAllPermissions() async {
    final results = <String, bool>{};

    // 전화 권한 요청
    if (!await checkPhonePermission()) {
      results['phone'] = await requestPhonePermission();
    } else {
      results['phone'] = true;
    }

    // 연락처 권한 요청
    if (!await checkContactsPermission()) {
      results['contacts'] = await requestContactsPermission();
    } else {
      results['contacts'] = true;
    }

    return results;
  }

  /// 권한이 영구적으로 거부되었는지 확인
  /// 
  /// [permission]: 확인할 권한
  /// Returns: 영구적으로 거부되었으면 true
  Future<bool> isPermanentlyDenied(Permission permission) async {
    try {
      final status = await permission.status;
      return status.isPermanentlyDenied;
    } catch (e) {
      debugPrint('권한 상태 확인 오류: $e');
      return false;
    }
  }

  /// 앱 설정 화면 열기
  /// 
  /// 사용자가 권한을 수동으로 변경할 수 있도록
  /// 시스템 설정 화면으로 이동합니다.
  /// 
  /// Returns: 설정 화면을 성공적으로 열었으면 true
  Future<bool> openAppSettings() async {
    try {
      final opened = await openAppSettings();
      if (opened) {
        debugPrint('앱 설정 화면을 열었습니다.');
      } else {
        debugPrint('앱 설정 화면 열기에 실패했습니다.');
      }
      return opened;
    } catch (e) {
      debugPrint('설정 화면 열기 오류: $e');
      return false;
    }
  }

  /// 권한 상태에 따른 사용자 안내 메시지 반환
  /// 
  /// [permission]: 확인할 권한
  /// [permissionName]: 권한의 한글 이름 (예: "전화", "연락처")
  /// Returns: 사용자에게 표시할 안내 메시지
  Future<String> getPermissionMessage(
    Permission permission,
    String permissionName,
  ) async {
    final status = await checkPermission(permission);

    if (status.isGranted) {
      return '$permissionName 권한이 허용되었습니다.';
    } else if (status.isDenied) {
      return '$permissionName 권한이 필요합니다.\n앱을 사용하려면 권한을 허용해주세요.';
    } else if (status.isPermanentlyDenied) {
      return '$permissionName 권한이 거부되었습니다.\n설정에서 권한을 허용해주세요.';
    } else if (status.isRestricted) {
      return '$permissionName 권한이 제한되었습니다.\n기기 설정을 확인해주세요.';
    } else if (status.isLimited) {
      return '$permissionName 권한이 제한적으로 허용되었습니다.';
    }

    return '$permissionName 권한 상태를 확인할 수 없습니다.';
  }

  /// 전화 권한 전체 플로우 처리
  /// 
  /// 권한 확인 -> 미허용시 요청 -> 영구 거부시 설정 안내
  /// 
  /// [context]: 다이얼로그 표시를 위한 BuildContext
  /// [showDialog]: 다이얼로그 표시 여부 (기본값: true)
  /// Returns: 최종적으로 권한이 허용되었으면 true
  Future<PermissionResult> handlePhonePermission({
    bool showDialog = true,
  }) async {
    // 1. 권한이 이미 허용되어 있는지 확인
    if (await checkPhonePermission()) {
      return PermissionResult(
        isGranted: true,
        message: '전화 권한이 허용되어 있습니다.',
      );
    }

    // 2. 영구 거부 상태 확인
    if (await isPermanentlyDenied(Permission.phone)) {
      return PermissionResult(
        isGranted: false,
        isPermanentlyDenied: true,
        message: '전화 권한이 거부되었습니다.\n설정에서 권한을 허용해주세요.',
      );
    }

    // 3. 권한 요청
    final granted = await requestPhonePermission();
    
    if (granted) {
      return PermissionResult(
        isGranted: true,
        message: '전화 권한이 허용되었습니다.',
      );
    } else {
      return PermissionResult(
        isGranted: false,
        message: '전화 권한이 거부되었습니다.',
      );
    }
  }

  /// 연락처 권한 전체 플로우 처리
  /// 
  /// 권한 확인 -> 미허용시 요청 -> 영구 거부시 설정 안내
  /// 
  /// [context]: 다이얼로그 표시를 위한 BuildContext
  /// [showDialog]: 다이얼로그 표시 여부 (기본값: true)
  /// Returns: 최종적으로 권한이 허용되었으면 true
  Future<PermissionResult> handleContactsPermission({
    bool showDialog = true,
  }) async {
    // 1. 권한이 이미 허용되어 있는지 확인
    if (await checkContactsPermission()) {
      return PermissionResult(
        isGranted: true,
        message: '연락처 권한이 허용되어 있습니다.',
      );
    }

    // 2. 영구 거부 상태 확인
    if (await isPermanentlyDenied(Permission.contacts)) {
      return PermissionResult(
        isGranted: false,
        isPermanentlyDenied: true,
        message: '연락처 권한이 거부되었습니다.\n설정에서 권한을 허용해주세요.',
      );
    }

    // 3. 권한 요청
    final granted = await requestContactsPermission();
    
    if (granted) {
      return PermissionResult(
        isGranted: true,
        message: '연락처 권한이 허용되었습니다.',
      );
    } else {
      return PermissionResult(
        isGranted: false,
        message: '연락처 권한이 거부되었습니다.',
      );
    }
  }
}

/// 권한 처리 결과를 담는 클래스
class PermissionResult {
  final bool isGranted;
  final bool isPermanentlyDenied;
  final String message;

  PermissionResult({
    required this.isGranted,
    this.isPermanentlyDenied = false,
    required this.message,
  });

  @override
  String toString() {
    return 'PermissionResult(isGranted: $isGranted, isPermanentlyDenied: $isPermanentlyDenied, message: $message)';
  }
}