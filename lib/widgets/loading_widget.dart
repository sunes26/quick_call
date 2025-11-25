import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// 로딩 상태를 표시하는 위젯
/// 
/// 데이터를 불러오는 중일 때 표시되며,
/// 로딩 시간에 따라 다른 메시지를 보여줍니다.
class LoadingWidget extends StatefulWidget {
  final String? message;
  final String? longLoadingMessage;
  final Duration longLoadingThreshold;

  const LoadingWidget({
    super.key,
    this.message = '불러오는 중...',
    this.longLoadingMessage = '잠시만 기다려주세요...',
    this.longLoadingThreshold = const Duration(seconds: 3),
  });

  @override
  State<LoadingWidget> createState() => _LoadingWidgetState();
}

class _LoadingWidgetState extends State<LoadingWidget> {
  bool _isLongLoading = false;

  @override
  void initState() {
    super.initState();
    
    // 지정된 시간 후 메시지 변경
    Future.delayed(widget.longLoadingThreshold, () {
      if (mounted) {
        setState(() {
          _isLongLoading = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 로딩 인디케이터
          SizedBox(
            width: 48.w,
            height: 48.h,
            child: CircularProgressIndicator(
              strokeWidth: 4.w,
              valueColor: AlwaysStoppedAnimation<Color>(
                Colors.blue[700]!,
              ),
            ),
          ),
          SizedBox(height: 24.h),

          // 로딩 메시지
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: Text(
              _isLongLoading 
                  ? widget.longLoadingMessage! 
                  : widget.message!,
              key: ValueKey<bool>(_isLongLoading),
              style: TextStyle(
                fontSize: 16.sp,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

/// 작은 크기의 로딩 위젯 (인라인 사용)
class SmallLoadingWidget extends StatelessWidget {
  final String? message;
  final double? size;

  const SmallLoadingWidget({
    super.key,
    this.message,
    this.size,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: size ?? 20.w,
          height: size ?? 20.h,
          child: CircularProgressIndicator(
            strokeWidth: 2.w,
            valueColor: AlwaysStoppedAnimation<Color>(
              Colors.blue[700]!,
            ),
          ),
        ),
        if (message != null) ...[
          SizedBox(width: 12.w),
          Text(
            message!,
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.grey[600],
            ),
          ),
        ],
      ],
    );
  }
}