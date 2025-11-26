import 'package:flutter/material.dart';
import 'package:flutter/services.dart';  // 🆕 햅틱 피드백을 위해 추가
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:quick_call/models/speed_dial_button.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'dart:math' as math;

class DialButtonWidget extends StatefulWidget {
  final SpeedDialButton button;
  final bool isEditMode;
  final VoidCallback? onTap;  // 🆕 편집 모드용 탭
  final VoidCallback? onLongPress;  // 일반 모드용 롱프레스
  final VoidCallback onDelete;

  const DialButtonWidget({
    super.key,
    required this.button,
    this.isEditMode = false,
    this.onTap,  // 편집 모드에서 사용
    this.onLongPress,  // 일반 모드에서 사용
    required this.onDelete,
  });

  @override
  State<DialButtonWidget> createState() => _DialButtonWidgetState();
}

class _DialButtonWidgetState extends State<DialButtonWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    
    // 애니메이션 컨트롤러 설정
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    // 흔들림 애니메이션 (-0.03 ~ 0.03 라디안, 약 -1.7도 ~ 1.7도)
    _animation = Tween<double>(
      begin: -0.03,
      end: 0.03,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    // 편집 모드일 때 애니메이션 시작
    if (widget.isEditMode) {
      _startWiggle();
    }
  }

  @override
  void didUpdateWidget(DialButtonWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // 편집 모드 상태 변경 감지
    if (widget.isEditMode != oldWidget.isEditMode) {
      if (widget.isEditMode) {
        _startWiggle();
      } else {
        _stopWiggle();
      }
    }
  }

  void _startWiggle() {
    // 각 버튼마다 랜덤한 지연 시간으로 시작하여 더 자연스럽게
    final delay = math.Random().nextInt(200);
    Future.delayed(Duration(milliseconds: delay), () {
      if (mounted && widget.isEditMode) {
        _controller.repeat(reverse: true);
      }
    });
  }

  void _stopWiggle() {
    _controller.stop();
    _controller.reset();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.rotate(
          angle: widget.isEditMode ? _animation.value : 0,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // 메인 버튼 - 전체 공간을 채움
              GestureDetector(
                // 🆕 모든 모드: 탭 → 편집 화면, 일반 모드: 롱프레스 → 전화 걸기
                onTap: widget.onTap,  // 모든 모드에서 탭으로 편집 화면 열기
                onLongPress: !widget.isEditMode && widget.onLongPress != null
                    ? () {
                        // 햅틱 피드백 추가 (꾹 눌렀을 때 진동)
                        HapticFeedback.mediumImpact();
                        widget.onLongPress!();
                      }
                    : null,  // 일반 모드에서만 롱프레스로 전화 걸기
                child: Container(
                  width: double.infinity,
                  height: double.infinity,
                  clipBehavior: Clip.hardEdge,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16.r),
                    boxShadow: const [
                      BoxShadow(
                        color: Color.fromRGBO(0, 0, 0, 0.05),
                        blurRadius: 10,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.max, // 전체 높이 사용
                    children: [
                      // 위쪽 여백
                      const Spacer(flex: 2),
                      
                      // 아이콘
                      Container(
                        padding: EdgeInsets.all(14.w),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          widget.button.iconData,
                          size: 32.sp,
                          color: Colors.grey[700],
                        ),
                      ),
                      
                      // 아이콘과 이름 사이 간격
                      const Spacer(flex: 1),

                      // AutoSizeText로 변경 - ...이 절대 나타나지 않음
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8.w),
                        child: AutoSizeText(
                          widget.button.name,
                          style: TextStyle(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                            height: 1.2,
                          ),
                          maxLines: 2,
                          minFontSize: 10,  // 최소 10sp까지만 축소
                          maxFontSize: 15,  // 최대 15sp
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.visible,  // ...이 나타나지 않음
                        ),
                      ),
                      
                      // 아래쪽 여백
                      const Spacer(flex: 2),
                    ],
                  ),
                ),
              ),

              // 편집 모드: 삭제 버튼
              if (widget.isEditMode)
                Positioned(
                  top: 0,
                  right: 0,
                  child: GestureDetector(
                    onTap: widget.onDelete,
                    child: Container(
                      padding: EdgeInsets.all(4.w),
                      decoration: BoxDecoration(
                        color: Colors.red[500],
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white,
                          width: 2,
                        ),
                        boxShadow: const [
                          BoxShadow(
                            color: Color.fromRGBO(0, 0, 0, 0.2),
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.close,
                        size: 16.sp,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}