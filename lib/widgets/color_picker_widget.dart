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

  // 🎨 색상 팔레트 (5x4 = 20개)
  static const List<Color> colorPalette = [
    // Row 1 - 진한 색상
    Color(0xFFE53935), // 빨강
    Color(0xFFD81B60), // 분홍
    Color(0xFF8E24AA), // 보라
    Color(0xFF3949AB), // 파랑
    Color(0xFF00ACC1), // 청록

    // Row 2 - 중간 톤
    Color(0xFF9E9D24), // 올리브
    Color(0xFFFFB300), // 노랑
    Color(0xFF6D4C41), // 갈색
    Color(0xFF43A047), // 초록
    Color(0xFF546E7A), // 회색

    // Row 3 - 연한 파스텔
    Color(0xFFFFCDD2), // 연한 빨강
    Color(0xFFF8BBD0), // 연한 분홍
    Color(0xFFE1BEE7), // 연한 보라
    Color(0xFFBBDEFB), // 연한 파랑
    Color(0xFFB2EBF2), // 연한 청록

    // Row 4 - 더 연한 톤
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
          SizedBox(height: 16.h),

          // 색상 그리드 (스크롤 없이 한눈에)
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
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

                return GestureDetector(
                  onTap: () => _selectColor(color),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected ? Colors.blue[700]! : Colors.grey[300]!,
                        width: isSelected ? 3 : 1.5,
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
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.check,
                                size: 16.sp,
                                color: Colors.blue[700],
                              ),
                            ),
                          )
                        : null,
                  ),
                );
              },
            ),
          ),
          SizedBox(height: 20.h),

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