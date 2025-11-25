import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class IconPickerWidget extends StatefulWidget {
  final IconData selectedIcon;

  const IconPickerWidget({
    super.key,
    required this.selectedIcon,
  });

  @override
  State<IconPickerWidget> createState() => _IconPickerWidgetState();
}

class _IconPickerWidgetState extends State<IconPickerWidget> {
  late IconData _selectedIcon;

  // 사용 가능한 아이콘 목록
  static final List<IconData> availableIcons = [
    Icons.person,
    Icons.person_outline,
    Icons.woman,
    Icons.man,
    Icons.wc,
    Icons.people,
    Icons.phone,
    Icons.phone_enabled,
    Icons.business,
    Icons.business_center,
    Icons.local_hospital,
    Icons.medical_services,
    Icons.favorite,
    Icons.favorite_border,
    Icons.star,
    Icons.star_border,
    Icons.home,
    Icons.home_outlined,
    Icons.school,
    Icons.work,
    Icons.car_rental,
    Icons.directions_car,
    Icons.restaurant,
    Icons.local_cafe,
    Icons.local_pizza,
    Icons.emergency,
    Icons.local_police,
    Icons.local_fire_department,
  ];

  @override
  void initState() {
    super.initState();
    _selectedIcon = widget.selectedIcon;
  }

  void _selectIcon(IconData icon) {
    // 햅틱 피드백
    HapticFeedback.mediumImpact();
    
    setState(() {
      _selectedIcon = icon;
    });

    // 짧은 딜레이 후 자동으로 닫기 (시각적 피드백을 위해)
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) {
        Navigator.pop(context, _selectedIcon);
      }
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
            '아이콘 선택',
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8.h),
          
          // 선택된 아이콘 미리보기
          Container(
            padding: EdgeInsets.all(16.w),
            margin: EdgeInsets.symmetric(horizontal: 24.w),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: EdgeInsets.all(12.w),
                      decoration: BoxDecoration(
                        color: Colors.blue[100],
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _selectedIcon,
                        size: 32.sp,
                        color: Colors.blue[700],
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Text(
                      '현재 선택',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.blue[700],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 4.h),
                Text(
                  '아이콘을 탭하면 바로 적용됩니다',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 16.h),

          // 아이콘 그리드 (스크롤 가능)
          Flexible(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  childAspectRatio: 1.0,
                  crossAxisSpacing: 12.w,
                  mainAxisSpacing: 12.h,
                ),
                itemCount: availableIcons.length,
                itemBuilder: (context, index) {
                  final icon = availableIcons[index];
                  final isSelected = icon.codePoint == _selectedIcon.codePoint;

                  return GestureDetector(
                    onTap: () => _selectIcon(icon),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.blue[600] : Colors.grey[100],
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(
                          color: isSelected ? Colors.blue[700]! : Colors.grey[300]!,
                          width: isSelected ? 3 : 1,
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: Colors.blue.withValues(alpha: 0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ]
                            : [],
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Icon(
                            icon,
                            size: 32.sp,
                            color: isSelected ? Colors.white : Colors.grey[700],
                          ),
                          // 선택 체크마크
                          if (isSelected)
                            Positioned(
                              top: 4,
                              right: 4,
                              child: Container(
                                padding: EdgeInsets.all(2.w),
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.check,
                                  size: 12.sp,
                                  color: Colors.blue[700],
                                ),
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
          SizedBox(height: 24.h),
        ],
      ),
    );
  }
}