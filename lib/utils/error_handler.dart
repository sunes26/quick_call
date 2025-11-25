import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// 에러 타입 정의
enum ErrorType {
  /// 권한 거부 에러
  permissionDenied,

  /// 전화번호 형식 오류
  invalidPhoneNumber,

  /// 네트워크 오류
  network,

  /// 데이터베이스 오류
  database,

  /// 연락처 접근 오류
  contacts,

  /// 전화 걸기 실패
  phoneCallFailed,

  /// 일반 오류
  general,

  /// 알 수 없는 오류
  unknown,
}

/// 에러 처리 유틸리티 클래스
/// 
/// 앱에서 발생하는 다양한 에러를 처리하고
/// 사용자 친화적인 메시지로 변환하여 표시합니다.
class ErrorHandler {
  /// 에러 타입에 따른 사용자 친화적인 메시지 반환
  /// 
  /// [errorType]: 에러 타입
  /// [details]: 추가 상세 정보 (선택사항)
  /// Returns: 사용자에게 표시할 메시지
  static String getErrorMessage(ErrorType errorType, {String? details}) {
    switch (errorType) {
      case ErrorType.permissionDenied:
        return '권한이 거부되었습니다.\n설정에서 권한을 허용해주세요.';

      case ErrorType.invalidPhoneNumber:
        return '올바르지 않은 전화번호입니다.\n전화번호를 다시 확인해주세요.';

      case ErrorType.network:
        return '네트워크 연결을 확인해주세요.\n인터넷 연결이 필요합니다.';

      case ErrorType.database:
        return '데이터를 저장하는 중 오류가 발생했습니다.\n잠시 후 다시 시도해주세요.';

      case ErrorType.contacts:
        return '연락처를 불러올 수 없습니다.\n연락처 권한을 확인해주세요.';

      case ErrorType.phoneCallFailed:
        return '전화를 걸 수 없습니다.\n전화 권한을 확인하거나\n잠시 후 다시 시도해주세요.';

      case ErrorType.general:
        return details ?? '작업을 완료할 수 없습니다.\n잠시 후 다시 시도해주세요.';

      case ErrorType.unknown:
        return '알 수 없는 오류가 발생했습니다.\n앱을 다시 시작해주세요.';
    }
  }

  /// SnackBar로 에러 메시지 표시
  /// 
  /// [context]: BuildContext
  /// [errorType]: 에러 타입
  /// [details]: 추가 상세 정보 (선택사항)
  /// [action]: 액션 버튼 (선택사항)
  static void showErrorSnackBar(
    BuildContext context,
    ErrorType errorType, {
    String? details,
    SnackBarAction? action,
    Duration duration = const Duration(seconds: 4),
  }) {
    final message = getErrorMessage(errorType, details: details);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: TextStyle(
            fontSize: 16.sp,
            color: Colors.white,
          ),
        ),
        backgroundColor: _getErrorColor(errorType),
        duration: duration,
        action: action,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
      ),
    );
  }

  /// 에러 다이얼로그 표시
  /// 
  /// [context]: BuildContext
  /// [errorType]: 에러 타입
  /// [details]: 추가 상세 정보 (선택사항)
  /// [title]: 다이얼로그 제목 (선택사항)
  /// [onConfirm]: 확인 버튼 콜백 (선택사항)
  static Future<void> showErrorDialog(
    BuildContext context,
    ErrorType errorType, {
    String? details,
    String? title,
    VoidCallback? onConfirm,
  }) {
    final message = getErrorMessage(errorType, details: details);
    final dialogTitle = title ?? _getErrorTitle(errorType);

    return showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
        icon: Icon(
          _getErrorIcon(errorType),
          size: 48.sp,
          color: _getErrorColor(errorType),
        ),
        title: Text(
          dialogTitle,
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        content: Text(
          message,
          style: TextStyle(
            fontSize: 16.sp,
            color: Colors.grey[700],
            height: 1.5,
          ),
          textAlign: TextAlign.center,
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              onConfirm?.call();
            },
            child: Text(
              '확인',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 에러 타입에 따른 색상 반환
  static Color _getErrorColor(ErrorType errorType) {
    switch (errorType) {
      case ErrorType.permissionDenied:
        return Colors.orange[700]!;
      case ErrorType.invalidPhoneNumber:
        return Colors.red[700]!;
      case ErrorType.network:
        return Colors.blue[700]!;
      case ErrorType.database:
      case ErrorType.contacts:
      case ErrorType.phoneCallFailed:
      case ErrorType.general:
      case ErrorType.unknown:
        return Colors.red[700]!;
    }
  }

  /// 에러 타입에 따른 아이콘 반환
  static IconData _getErrorIcon(ErrorType errorType) {
    switch (errorType) {
      case ErrorType.permissionDenied:
        return Icons.block;
      case ErrorType.invalidPhoneNumber:
        return Icons.phone_disabled;
      case ErrorType.network:
        return Icons.wifi_off;
      case ErrorType.database:
        return Icons.storage;
      case ErrorType.contacts:
        return Icons.contacts;
      case ErrorType.phoneCallFailed:
        return Icons.phone_missed;
      case ErrorType.general:
      case ErrorType.unknown:
        return Icons.error_outline;
    }
  }

  /// 에러 타입에 따른 제목 반환
  static String _getErrorTitle(ErrorType errorType) {
    switch (errorType) {
      case ErrorType.permissionDenied:
        return '권한 오류';
      case ErrorType.invalidPhoneNumber:
        return '전화번호 오류';
      case ErrorType.network:
        return '네트워크 오류';
      case ErrorType.database:
        return '데이터베이스 오류';
      case ErrorType.contacts:
        return '연락처 오류';
      case ErrorType.phoneCallFailed:
        return '통화 연결 실패';
      case ErrorType.general:
        return '오류 발생';
      case ErrorType.unknown:
        return '알 수 없는 오류';
    }
  }

  /// Exception 객체로부터 ErrorType 추론
  /// 
  /// [error]: Exception 객체
  /// Returns: 추론된 ErrorType
  static ErrorType inferErrorType(Object error) {
    final errorString = error.toString().toLowerCase();

    if (errorString.contains('permission')) {
      return ErrorType.permissionDenied;
    } else if (errorString.contains('phone') ||
        errorString.contains('number')) {
      return ErrorType.invalidPhoneNumber;
    } else if (errorString.contains('network') ||
        errorString.contains('internet') ||
        errorString.contains('connection')) {
      return ErrorType.network;
    } else if (errorString.contains('database') ||
        errorString.contains('sqlite') ||
        errorString.contains('sql')) {
      return ErrorType.database;
    } else if (errorString.contains('contact')) {
      return ErrorType.contacts;
    } else {
      return ErrorType.unknown;
    }
  }

  /// 에러를 로깅하고 사용자에게 표시
  /// 
  /// [context]: BuildContext
  /// [error]: 에러 객체
  /// [stackTrace]: 스택 트레이스 (선택사항)
  /// [showDialog]: 다이얼로그로 표시할지 여부 (기본값: false)
  static void handleError(
    BuildContext context,
    Object error, {
    StackTrace? stackTrace,
    bool showDialog = false,
  }) {
    // 디버그 로그 출력
    debugPrint('=== 에러 발생 ===');
    debugPrint('에러: $error');
    if (stackTrace != null) {
      debugPrint('스택 트레이스: $stackTrace');
    }
    debugPrint('================');

    // 에러 타입 추론
    final errorType = inferErrorType(error);

    // 사용자에게 표시
    if (showDialog) {
      showErrorDialog(context, errorType);
    } else {
      showErrorSnackBar(context, errorType);
    }
  }
}

/// 특정 에러 상황에 대한 헬퍼 메서드들
class ErrorHelpers {
  /// 권한 거부 에러 처리
  static void handlePermissionDenied(
    BuildContext context,
    String permissionName,
  ) {
    ErrorHandler.showErrorSnackBar(
      context,
      ErrorType.permissionDenied,
      details: '$permissionName 권한이 거부되었습니다.\n설정에서 권한을 허용해주세요.',
      action: SnackBarAction(
        label: '설정',
        textColor: Colors.white,
        onPressed: () {
          // 설정 화면 열기는 permission_service에서 처리
        },
      ),
    );
  }

  /// 전화번호 형식 오류 처리
  static void handleInvalidPhoneNumber(
    BuildContext context, {
    String? phoneNumber,
  }) {
    String message = '올바르지 않은 전화번호입니다.';
    if (phoneNumber != null) {
      message += '\n입력하신 번호: $phoneNumber';
    }
    message += '\n\n다음 형식으로 입력해주세요:\n'
        '• 010-1234-5678\n'
        '• 02-1234-5678\n'
        '• 1588-1234';

    ErrorHandler.showErrorDialog(
      context,
      ErrorType.invalidPhoneNumber,
      details: message,
      title: '전화번호 확인',
    );
  }

  /// 데이터베이스 에러 처리
  static void handleDatabaseError(
    BuildContext context,
    String operation,
  ) {
    ErrorHandler.showErrorSnackBar(
      context,
      ErrorType.database,
      details: '$operation 중 오류가 발생했습니다.\n잠시 후 다시 시도해주세요.',
    );
  }

  /// 연락처 접근 에러 처리
  static void handleContactsError(
    BuildContext context,
  ) {
    ErrorHandler.showErrorSnackBar(
      context,
      ErrorType.contacts,
      details: '연락처를 불러올 수 없습니다.\n연락처 권한을 확인해주세요.',
      action: SnackBarAction(
        label: '설정',
        textColor: Colors.white,
        onPressed: () {
          // 설정 화면 열기
        },
      ),
    );
  }

  /// 전화 걸기 실패 에러 처리
  static void handlePhoneCallError(
    BuildContext context, {
    String? phoneNumber,
  }) {
    String message = '전화를 걸 수 없습니다.';
    if (phoneNumber != null) {
      message += '\n전화번호: $phoneNumber';
    }
    message += '\n\n다음을 확인해주세요:\n'
        '• 전화 권한이 허용되어 있는지\n'
        '• 전화번호가 올바른지\n'
        '• 휴대폰 통화 기능이 정상인지';

    ErrorHandler.showErrorDialog(
      context,
      ErrorType.phoneCallFailed,
      details: message,
      title: '통화 연결 실패',
    );
  }

  /// 네트워크 에러 처리
  static void handleNetworkError(
    BuildContext context,
  ) {
    ErrorHandler.showErrorSnackBar(
      context,
      ErrorType.network,
      details: '네트워크 연결을 확인해주세요.',
      duration: const Duration(seconds: 3),
    );
  }

  /// 일반 에러 처리 (상세 메시지 포함)
  static void handleGeneralError(
    BuildContext context,
    String message,
  ) {
    ErrorHandler.showErrorSnackBar(
      context,
      ErrorType.general,
      details: message,
    );
  }
}

/// 성공 메시지 표시 헬퍼
class SuccessHandler {
  /// 성공 스낵바 표시
  static void showSuccess(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 2),
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              Icons.check_circle,
              color: Colors.white,
              size: 24.sp,
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  fontSize: 16.sp,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.green[700],
        duration: duration,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
      ),
    );
  }

  /// 작업 완료 메시지
  static void showTaskCompleted(
    BuildContext context,
    String taskName,
  ) {
    showSuccess(context, '$taskName이(가) 완료되었습니다.');
  }

  /// 저장 완료 메시지
  static void showSaveSuccess(BuildContext context) {
    showSuccess(context, '저장되었습니다.');
  }

  /// 삭제 완료 메시지
  static void showDeleteSuccess(BuildContext context, String itemName) {
    showSuccess(context, '$itemName이(가) 삭제되었습니다.');
  }

  /// 업데이트 완료 메시지
  static void showUpdateSuccess(BuildContext context) {
    showSuccess(context, '수정되었습니다.');
  }
}

/// 경고 메시지 표시 헬퍼
class WarningHandler {
  /// 경고 스낵바 표시
  static void showWarning(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 3),
    SnackBarAction? action,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              Icons.warning_amber_rounded,
              color: Colors.white,
              size: 24.sp,
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  fontSize: 16.sp,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.orange[700],
        duration: duration,
        action: action,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
      ),
    );
  }
}