import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// 빈 상태를 표시하는 위젯
/// 
/// 데이터가 없을 때 사용자에게 안내 메시지와
/// 액션 버튼을 제공합니다.
class EmptyStateWidget extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final String? actionButtonText;
  final VoidCallback? onActionPressed;
  final Color? iconColor;

  const EmptyStateWidget({
    super.key,
    this.icon = Icons.inbox_outlined,
    required this.title,
    this.subtitle,
    this.actionButtonText,
    this.onActionPressed,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 아이콘
            Container(
              padding: EdgeInsets.all(24.w),
              decoration: BoxDecoration(
                color: (iconColor ?? Colors.grey[400])!.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 72.sp,
                color: iconColor ?? Colors.grey[400],
              ),
            ),
            SizedBox(height: 24.h),

            // 제목
            Text(
              title,
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
              textAlign: TextAlign.center,
            ),

            // 부제목 (옵션)
            if (subtitle != null) ...[
              SizedBox(height: 12.h),
              Text(
                subtitle!,
                style: TextStyle(
                  fontSize: 16.sp,
                  color: Colors.grey[600],
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
            ],

            // 액션 버튼 (옵션)
            if (actionButtonText != null && onActionPressed != null) ...[
              SizedBox(height: 32.h),
              ElevatedButton.icon(
                onPressed: onActionPressed,
                icon: Icon(Icons.add, size: 24.sp),
                label: Text(
                  actionButtonText!,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[700],
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(
                    horizontal: 32.w,
                    vertical: 16.h,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  elevation: 2,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// 단축키가 없을 때 표시하는 위젯
class NoSpeedDialsWidget extends StatelessWidget {
  final VoidCallback onAddPressed;
  final String? groupName;

  const NoSpeedDialsWidget({
    super.key,
    required this.onAddPressed,
    this.groupName,
  });

  @override
  Widget build(BuildContext context) {
    final isAllGroup = groupName == null || groupName == '전체';
    
    return EmptyStateWidget(
      icon: Icons.phone_disabled,
      iconColor: Colors.blue[300],
      title: isAllGroup
          ? '등록된 단축번호가 없습니다'
          : '$groupName 그룹에\n등록된 단축번호가 없습니다',
      subtitle: '아래 + 버튼을 눌러\n단축번호를 추가하세요',
      actionButtonText: '단축번호 추가',
      onActionPressed: onAddPressed,
    );
  }
}

/// 검색 결과가 없을 때 표시하는 위젯
class NoSearchResultsWidget extends StatelessWidget {
  final String searchQuery;

  const NoSearchResultsWidget({
    super.key,
    required this.searchQuery,
  });

  @override
  Widget build(BuildContext context) {
    return EmptyStateWidget(
      icon: Icons.search_off,
      iconColor: Colors.orange[300],
      title: '검색 결과가 없습니다',
      subtitle: '"$searchQuery"에 대한\n결과를 찾을 수 없습니다',
    );
  }
}

/// 연락처가 없을 때 표시하는 위젯
class NoContactsWidget extends StatelessWidget {
  const NoContactsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return EmptyStateWidget(
      icon: Icons.people_outline,
      iconColor: Colors.purple[300],
      title: '저장된 연락처가 없습니다',
      subtitle: '휴대폰의 연락처 앱에서\n연락처를 추가해주세요',
    );
  }
}