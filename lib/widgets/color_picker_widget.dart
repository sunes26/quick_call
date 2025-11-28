import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ColorPickerWidget extends StatefulWidget {
  final Color selectedColor;

  const ColorPickerWidget({
    super.key,
    required this.selectedColor,
  });

  @override
  State<ColorPickerWidget> createState() => _ColorPickerWidgetState();
}

class _ColorPickerWidgetState extends State<ColorPickerWidget> {
  late Color _selectedColor;

  // 🎨 확장된 색상 팔레트 (5x6 = 30개)
  // 🌈 Row 1-2: 기본 색상 우선 배치 (빨주노초파남보검 + 흰색 + 회색)
  static const List<Color> colorPalette = [
    // Row 1 - 기본 색상 (빨주노초파)
    Color(0xFFF44336), // 빨강 ❤️
    Color(0xFFFF9800), // 주황 🧡
    Color(0xFFFFEB3B), // 노랑 💛
    Color(0xFF4CAF50), // 초록 💚
    Color(0xFF2196F3), // 파랑 💙 (기본색)

    // Row 2 - 기본 색상 (남보검 + 흰회)
    Color(0xFF3F51B5), // 남색 💙
    Color(0xFF9C27B0), // 보라 💜
    Color(0xFF212121), // 검정 🖤
    Color(0xFFFFFFFF), // 흰색 🤍
    Color(0xFF9E9E9E), // 회색 🩶

    // Row 3 - 진한 보조 색상
    Color(0xFFE91E63), // 진한 분홍
    Color(0xFF00BCD4), // 진한 청록
    Color(0xFF827717), // 진한 올리브
    Color(0xFF5D4037), // 진한 갈색
    Color(0xFFD32F2F), // 진한 빨강

    // Row 4 - 중간 보조 색상
    Color(0xFFAD1457), // 딥 핑크
    Color(0xFF6A1B9A), // 딥 퍼플
    Color(0xFF1565C0), // 다크 블루
    Color(0xFF00838F), // 다크 시안
    Color(0xFFEF6C00), // 다크 오렌지

    // Row 5 - 연한 파스텔 톤
    Color(0xFFFFCDD2), // 연한 빨강
    Color(0xFFF8BBD0), // 연한 분홍
    Color(0xFFE1BEE7), // 연한 보라
    Color(0xFFBBDEFB), // 연한 파랑
    Color(0xFFB2EBF2), // 연한 청록

    // Row 6 - 밝은 파스텔 톤
    Color(0xFFF0F4C3), // 연한 올리브
    Color(0xFFFFF9C4), // 연한 노랑
    Color(0xFFD7CCC8), // 연한 갈색
    Color(0xFFC8E6C9), // 연한 초록
    Color(0xFFCFD8DC), // 연한 회색
  ];

  @override
  void initState() {
    super.initState();
    _selectedColor = widget.selectedColor;
  }

  void _selectColor(Color color) {
    // 햅틱 피드백
    HapticFeedback.mediumImpact();
    
    setState(() {
      _selectedColor = color;
    });
  }

  // 두 색상이 같은지 비교하는 헬퍼 메서드
  bool _colorsEqual(Color a, Color b) {
    return (a.r * 255.0).round() == (b.r * 255.0).round() &&
        (a.g * 255.0).round() == (b.g * 255.0).round() &&
        (a.b * 255.0).round() == (b.b * 255.0).round() &&
        (a.a * 255.0).round() == (b.a * 255.0).round();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 드래그 핸들
          Container(
            margin: EdgeInsets.only(top: 10.h),
            width: 40.w,
            height: 4.h,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),
          SizedBox(height: 12.h),

          // 제목 + 현재 선택 색상 (한 줄로 컴팩트하게)
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '버튼 색상 선택',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(width: 12.w),
                Container(
                  width: 32.w,
                  height: 32.w,
                  decoration: BoxDecoration(
                    color: _selectedColor,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.grey[400]!,
                      width: 2,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 12.h),

          // 색상 그리드 (5x6 = 30개, 스크롤 가능)
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: SizedBox(
              height: 270.h, // 스크롤 영역 고정 높이 (오버플로우 방지)
              child: GridView.builder(
                shrinkWrap: true,
                physics: const BouncingScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 5,
                  childAspectRatio: 1.0,
                  crossAxisSpacing: 10.w,
                  mainAxisSpacing: 10.h,
                ),
                itemCount: colorPalette.length,
                itemBuilder: (context, index) {
                  final color = colorPalette[index];
                  final isSelected = _colorsEqual(_selectedColor, color);
                  // 🔧 수정: deprecated Color.value를 toARGB32()로 변경
                  final isWhite = color.toARGB32() == 0xFFFFFFFF; // 흰색 체크

                  return GestureDetector(
                    onTap: () => _selectColor(color),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: Border.all(
                          // 흰색은 항상 진한 테두리, 선택 시에는 파란 테두리
                          color: isSelected 
                              ? Colors.blue[700]!
                              : (isWhite ? Colors.grey[400]! : Colors.grey[300]!),
                          width: isSelected ? 3 : (isWhite ? 2 : 1.5),
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: Colors.blue.withValues(alpha: 0.3),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ]
                            : [],
                      ),
                      child: isSelected
                          ? Center(
                              child: Container(
                                padding: EdgeInsets.all(2.w),
                                decoration: BoxDecoration(
                                  // 흰색/밝은 색은 회색 배경, 어두운 색은 흰색 배경
                                  color: color.computeLuminance() > 0.5
                                      ? Colors.grey[700]
                                      : Colors.white,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.check,
                                  size: 16.sp,
                                  // 체크 아이콘도 배경에 따라 색상 변경
                                  color: color.computeLuminance() > 0.5
                                      ? Colors.white
                                      : Colors.blue[700],
                                ),
                              ),
                            )
                          : null,
                    ),
                  );
                },
              ),
            ),
          ),
          SizedBox(height: 16.h),

          // 버튼들
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Row(
              children: [
                // 취소 버튼
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      side: BorderSide(color: Colors.grey[300]!),
                    ),
                    child: Text(
                      '취소',
                      style: TextStyle(
                        fontSize: 15.sp,
                        color: Colors.grey[700],
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                // 확인 버튼
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      Navigator.pop(context, _selectedColor);
                    },
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      backgroundColor: Colors.blue[600],
                    ),
                    child: Text(
                      '확인',
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 20.h),
        ],
      ),
    );
  }
}