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

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.75,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 드래그 핸들
          Container(
            margin: EdgeInsets.only(top: 12.h),
            width: 40.w,
            height: 4.h,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),
          SizedBox(height: 16.h),

          // 제목
          Text(
            '버튼 색상 선택',
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8.h),
          
          // 선택된 색상 미리보기
          Container(
            padding: EdgeInsets.all(16.w),
            margin: EdgeInsets.symmetric(horizontal: 24.w),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 56.w,
                      height: 56.w,
                      decoration: BoxDecoration(
                        color: _selectedColor,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.grey[300]!,
                          width: 2,
                        ),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Text(
                      '현재 선택',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[800],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 4.h),
                Text(
                  '색상을 선택한 후 확인을 눌러주세요',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 16.h),

          // 색상 그리드
          Flexible(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 5,
                  childAspectRatio: 1.0,
                  crossAxisSpacing: 12.w,
                  mainAxisSpacing: 12.h,
                ),
                itemCount: colorPalette.length,
                itemBuilder: (context, index) {
                  final color = colorPalette[index];
                  // 🆕 색상 비교를 ARGB 값으로 변경
                  final isSelected = _selectedColor.red == color.red &&
                      _selectedColor.green == color.green &&
                      _selectedColor.blue == color.blue &&
                      _selectedColor.alpha == color.alpha;

                  return GestureDetector(
                    onTap: () => _selectColor(color),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected ? Colors.blue[700]! : Colors.grey[300]!,
                          width: isSelected ? 4 : 2,
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: Colors.blue.withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ]
                            : [],
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // 선택 체크마크
                          if (isSelected)
                            Container(
                              padding: EdgeInsets.all(4.w),
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.check,
                                size: 20.sp,
                                color: Colors.blue[700],
                              ),
                            ),
                        ],
                      ),
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
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      side: BorderSide(color: Colors.grey[300]!),
                    ),
                    child: Text(
                      '취소',
                      style: TextStyle(
                        fontSize: 16.sp,
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
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      backgroundColor: Colors.blue[600],
                    ),
                    child: Text(
                      '확인',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 24.h),
        ],
      ),
    );
  }
}