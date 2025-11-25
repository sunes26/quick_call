import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:permission_handler/permission_handler.dart';

/// 권한 설명 다이얼로그
/// 
/// 사용자에게 권한이 필요한 이유를 설명하고,
/// 설정으로 이동하거나 나중에 허용할 수 있는 옵션을 제공합니다.
class PermissionDialog extends StatelessWidget {
  final String title;
  final String message;
  final IconData icon;
  final bool isPermanentlyDenied;
  final VoidCallback? onSettingsPressed;
  final VoidCallback? onLaterPressed;

  const PermissionDialog({
    super.key,
    required this.title,
    required this.message,
    this.icon = Icons.lock_outline,
    this.isPermanentlyDenied = false,
    this.onSettingsPressed,
    this.onLaterPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 아이콘
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 48.sp,
                color: Colors.blue[700],
              ),
            ),
            SizedBox(height: 16.h),

            // 제목
            Text(
              title,
              style: TextStyle(
                fontSize: 22.sp,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 12.h),

            // 설명 메시지
            Text(
              message,
              style: TextStyle(
                fontSize: 16.sp,
                color: Colors.grey[700],
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24.h),

            // 버튼들
            if (isPermanentlyDenied)
              _buildPermanentlyDeniedButtons(context)
            else
              _buildNormalButtons(context),
          ],
        ),
      ),
    );
  }

  // 일반 권한 거부 시 버튼
  Widget _buildNormalButtons(BuildContext context) {
    return Column(
      children: [
        // 나중에 버튼
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () {
              Navigator.pop(context);
              onLaterPressed?.call();
            },
            style: OutlinedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 16.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
              side: BorderSide(color: Colors.grey[400]!),
            ),
            child: Text(
              '나중에',
              style: TextStyle(
                fontSize: 16.sp,
                color: Colors.grey[700],
              ),
            ),
          ),
        ),
        SizedBox(height: 12.h),
        // 허용 버튼
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              Navigator.pop(context, true);
            },
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 16.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
              backgroundColor: Colors.blue[700],
            ),
            child: Text(
              '허용하기',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // 영구 거부 시 버튼
  Widget _buildPermanentlyDeniedButtons(BuildContext context) {
    return Column(
      children: [
        // 닫기 버튼
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () {
              Navigator.pop(context);
              onLaterPressed?.call();
            },
            style: OutlinedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 16.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
              side: BorderSide(color: Colors.grey[400]!),
            ),
            child: Text(
              '닫기',
              style: TextStyle(
                fontSize: 16.sp,
                color: Colors.grey[700],
              ),
            ),
          ),
        ),
        SizedBox(height: 12.h),
        // 설정으로 이동 버튼
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () async {
              Navigator.pop(context);
              await openAppSettings();
              onSettingsPressed?.call();
            },
            icon: Icon(Icons.settings, size: 20.sp),
            label: Text(
              '설정으로 이동',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 16.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
              backgroundColor: Colors.blue[700],
              foregroundColor: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  /// 전화 권한 다이얼로그 표시
  static Future<bool?> showPhonePermissionDialog(
    BuildContext context, {
    bool isPermanentlyDenied = false,
  }) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => PermissionDialog(
        title: '전화 권한이 필요합니다',
        message: isPermanentlyDenied
            ? '전화를 걸기 위해서는 전화 권한이 필요합니다.\n\n'
                '설정에서 Quick Call 앱의 전화 권한을 허용해주세요.'
            : '버튼을 눌러 바로 전화를 걸 수 있도록\n전화 권한을 허용해주세요.\n\n'
                '이 권한은 단축 번호로 전화를 걸 때만 사용됩니다.',
        icon: Icons.phone_enabled,
        isPermanentlyDenied: isPermanentlyDenied,
      ),
    );
  }

  /// 연락처 권한 다이얼로그 표시
  static Future<bool?> showContactsPermissionDialog(
    BuildContext context, {
    bool isPermanentlyDenied = false,
  }) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => PermissionDialog(
        title: '연락처 권한이 필요합니다',
        message: isPermanentlyDenied
            ? '연락처에서 전화번호를 선택하려면 연락처 권한이 필요합니다.\n\n'
                '설정에서 Quick Call 앱의 연락처 권한을 허용해주세요.'
            : '저장된 연락처에서 전화번호를 불러오기 위해\n연락처 권한을 허용해주세요.\n\n'
                '이 권한은 연락처를 불러올 때만 사용됩니다.\n'
                '연락처 정보는 휴대폰에만 저장됩니다.',
        icon: Icons.contacts,
        isPermanentlyDenied: isPermanentlyDenied,
      ),
    );
  }

  /// 모든 권한 다이얼로그 표시
  static Future<bool?> showAllPermissionsDialog(
    BuildContext context, {
    bool isPermanentlyDenied = false,
  }) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => PermissionDialog(
        title: '권한이 필요합니다',
        message: isPermanentlyDenied
            ? '앱을 사용하려면 다음 권한이 필요합니다:\n\n'
                '• 전화: 단축 번호로 전화 걸기\n'
                '• 연락처: 연락처에서 번호 불러오기\n\n'
                '설정에서 Quick Call 앱의 권한을 허용해주세요.'
            : '앱을 사용하려면 다음 권한이 필요합니다:\n\n'
                '• 전화: 단축 번호로 전화 걸기\n'
                '• 연락처: 연락처에서 번호 불러오기\n\n'
                '모든 정보는 휴대폰에만 저장되며\n외부로 전송되지 않습니다.',
        icon: Icons.security,
        isPermanentlyDenied: isPermanentlyDenied,
      ),
    );
  }
}

/// 간단한 권한 안내 다이얼로그
/// 
/// 권한이 왜 필요한지만 간단히 설명하는 다이얼로그
class SimplePermissionDialog extends StatelessWidget {
  final String title;
  final String message;
  final IconData icon;

  const SimplePermissionDialog({
    super.key,
    required this.title,
    required this.message,
    this.icon = Icons.info_outline,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.r),
      ),
      icon: Icon(
        icon,
        size: 48.sp,
        color: Colors.blue[700],
      ),
      title: Text(
        title,
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
          onPressed: () => Navigator.pop(context),
          child: Text(
            '확인',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  /// 권한 안내 다이얼로그 표시
  static Future<void> show(
    BuildContext context, {
    required String title,
    required String message,
    IconData icon = Icons.info_outline,
  }) {
    return showDialog(
      context: context,
      builder: (context) => SimplePermissionDialog(
        title: title,
        message: message,
        icon: icon,
      ),
    );
  }
}

/// 권한 거부 시 안내 스낵바
class PermissionSnackBar {
  /// 전화 권한 거부 스낵바
  static void showPhonePermissionDenied(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '전화 권한이 거부되었습니다.\n전화를 걸려면 권한을 허용해주세요.',
          style: TextStyle(fontSize: 16.sp),
        ),
        backgroundColor: Colors.orange[700],
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: '설정',
          textColor: Colors.white,
          onPressed: () => openAppSettings(),
        ),
      ),
    );
  }

  /// 연락처 권한 거부 스낵바
  static void showContactsPermissionDenied(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '연락처 권한이 거부되었습니다.\n연락처를 불러오려면 권한을 허용해주세요.',
          style: TextStyle(fontSize: 16.sp),
        ),
        backgroundColor: Colors.orange[700],
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: '설정',
          textColor: Colors.white,
          onPressed: () => openAppSettings(),
        ),
      ),
    );
  }

  /// 권한 허용됨 스낵바
  static void showPermissionGranted(
    BuildContext context,
    String permissionName,
  ) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '$permissionName 권한이 허용되었습니다.',
          style: TextStyle(fontSize: 16.sp),
        ),
        backgroundColor: Colors.green[700],
        duration: const Duration(seconds: 2),
      ),
    );
  }
}