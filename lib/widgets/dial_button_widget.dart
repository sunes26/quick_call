import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:quick_call/models/speed_dial_button.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'dart:math' as math;

class DialButtonWidget extends StatefulWidget {
  final SpeedDialButton button;
  final bool isEditMode;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final VoidCallback onDelete;

  const DialButtonWidget({
    super.key,
    required this.button,
    this.isEditMode = false,
    this.onTap,
    this.onLongPress,
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
    
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _animation = Tween<double>(
      begin: -0.03,
      end: 0.03,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    if (widget.isEditMode) {
      _startWiggle();
    }
  }

  @override
  void didUpdateWidget(DialButtonWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    if (widget.isEditMode != oldWidget.isEditMode) {
      if (widget.isEditMode) {
        _startWiggle();
      } else {
        _stopWiggle();
      }
    }
  }

  void _startWiggle() {
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

  // 🆕 배경색에 따른 텍스트 색상 자동 결정
  Color _getTextColorForBackground(Color backgroundColor) {
    return backgroundColor.computeLuminance() > 0.5 
        ? Colors.black87 
        : Colors.white;
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
              // 메인 버튼
              GestureDetector(
                onTap: widget.onTap,
                onLongPress: !widget.isEditMode && widget.onLongPress != null
                    ? () {
                        HapticFeedback.mediumImpact();
                        widget.onLongPress!();
                      }
                    : null,
                child: Container(
                  width: double.infinity,
                  height: double.infinity,
                  clipBehavior: Clip.hardEdge,
                  decoration: BoxDecoration(
                    color: widget.button.color, // 🆕 색상 배경 적용
                    borderRadius: BorderRadius.circular(16.r),
                    boxShadow: const [
                      BoxShadow(
                        color: Color.fromRGBO(0, 0, 0, 0.1),
                        blurRadius: 10,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 12.h),
                      child: AutoSizeText(
                        widget.button.name,
                        style: TextStyle(
                          fontSize: 22.sp, // 🆕 글자 크기 증가 (15 → 22)
                          fontWeight: FontWeight.bold, // 🆕 굵게
                          color: _getTextColorForBackground(widget.button.color), // 🆕 자동 텍스트 색상
                          height: 1.2,
                        ),
                        maxLines: 3, // 🆕 최대 3줄
                        minFontSize: 12, // 🆕 최소 크기 증가 (10 → 12)
                        maxFontSize: 22, // 🆕 최대 크기 증가 (15 → 22)
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.visible,
                      ),
                    ),
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