import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:quick_call/models/speed_dial_button.dart';
import 'package:quick_call/utils/phone_formatter.dart';

/// 전화번호 중복 다이얼로그
/// 
/// 동일한 전화번호가 이미 존재할 때 사용자에게 선택지를 제공합니다.
class DuplicatePhoneDialog extends StatelessWidget {
  final SpeedDialButton existingButton;
  final String newName;
  final String phoneNumber;

  const DuplicatePhoneDialog({
    super.key,
    required this.existingButton,
    required this.newName,
    required this.phoneNumber,
  });

  // 🆕 배경색에 따른 텍스트 색상 자동 결정
  Color _getTextColorForBackground(Color backgroundColor) {
    return backgroundColor.computeLuminance() > 0.5 
        ? Colors.black87 
        : Colors.white;
  }

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
            // 경고 아이콘
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: Colors.orange[50],
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.warning_amber_rounded,
                size: 48.sp,
                color: Colors.orange[700],
              ),
            ),
            SizedBox(height: 20.h),

            // 제목
            Text(
              '이미 등록된 전화번호입니다',
              style: TextStyle(
                fontSize: 22.sp,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16.h),

            // 🆕 기존 버튼 정보 카드 (색상 기반)
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: existingButton.color, // 🆕 색상 배경
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: Colors.grey[300]!,
                  width: 1,
                ),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      // 🆕 아이콘 대신 색상 원형 표시
                      Container(
                        width: 32.w,
                        height: 32.w,
                        decoration: BoxDecoration(
                          color: _getTextColorForBackground(existingButton.color)
                              .withValues(alpha: 0.3),
                          shape: BoxShape.circle,
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '기존 단축키',
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: _getTextColorForBackground(existingButton.color)
                                    .withValues(alpha: 0.7),
                              ),
                            ),
                            Text(
                              existingButton.name,
                              style: TextStyle(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.bold,
                                color: _getTextColorForBackground(existingButton.color),
                              ),
                            ),
                            Text(
                              PhoneFormatter.format(existingButton.phoneNumber),
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: _getTextColorForBackground(existingButton.color)
                                    .withValues(alpha: 0.9),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 12.h),

            // 안내 메시지
            Text(
              '같은 전화번호로 여러 개의 단축키를\n만들 수도 있습니다.\n(예: 엄마 집, 엄마 휴대폰)',
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.grey[600],
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24.h),

            // 버튼들
            Column(
              children: [
                // 취소 버튼
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context, DuplicateAction.cancel),
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 16.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      side: BorderSide(color: Colors.grey[400]!),
                    ),
                    child: Text(
                      '취소',
                      style: TextStyle(
                        fontSize: 16.sp,
                        color: Colors.grey[700],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 12.h),

                // 중복 허용 버튼
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context, DuplicateAction.allowDuplicate),
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 16.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      backgroundColor: Colors.blue[700],
                    ),
                    child: Text(
                      '중복 허용하고 추가',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// 중복 체크 다이얼로그 표시
  static Future<DuplicateAction?> show(
    BuildContext context, {
    required SpeedDialButton existingButton,
    required String newName,
    required String phoneNumber,
  }) {
    return showDialog<DuplicateAction>(
      context: context,
      barrierDismissible: false,
      builder: (context) => DuplicatePhoneDialog(
        existingButton: existingButton,
        newName: newName,
        phoneNumber: phoneNumber,
      ),
    );
  }
}

/// 중복 전화번호 처리 액션
enum DuplicateAction {
  /// 취소 (추가/수정하지 않음)
  cancel,

  /// 중복 허용 (같은 번호로 여러 개 생성)
  allowDuplicate,
}