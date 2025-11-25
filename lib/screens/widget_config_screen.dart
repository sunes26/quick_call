import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:quick_call/models/speed_dial_button.dart';
import 'package:quick_call/providers/speed_dial_provider.dart';

/// 위젯에 표시할 버튼을 선택하고 순서를 정하는 화면
class WidgetConfigScreen extends StatefulWidget {
  const WidgetConfigScreen({super.key});

  @override
  State<WidgetConfigScreen> createState() => _WidgetConfigScreenState();
}

class _WidgetConfigScreenState extends State<WidgetConfigScreen> {
  List<SpeedDialButton> _selectedButtons = [];
  bool _hasChanges = false;
  
  @override
  void initState() {
    super.initState();
    _loadSelectedButtons();
  }

  // 현재 위젯에 표시되는 버튼들 로드
  void _loadSelectedButtons() {
    final provider = context.read<SpeedDialProvider>();
    _selectedButtons = provider.widgetButtons.toList();
  }

  // 버튼 선택/해제
  void _toggleButton(SpeedDialButton button) {
    setState(() {
      final index = _selectedButtons.indexWhere((b) => b.id == button.id);
      
      if (index >= 0) {
        // 이미 선택됨 -> 제거
        _selectedButtons.removeAt(index);
      } else {
        // 선택 안됨 -> 추가 (최대 4개)
        if (_selectedButtons.length < 4) {
          _selectedButtons.add(button);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '위젯에는 최대 4개까지만 표시할 수 있습니다',
                style: TextStyle(fontSize: 16.sp),
              ),
              backgroundColor: Colors.orange[700],
            ),
          );
          return;
        }
      }
      
      _hasChanges = true;
    });
  }

  // 선택된 버튼의 순서 변경
  void _reorderSelectedButtons(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) {
        newIndex -= 1;
      }
      final button = _selectedButtons.removeAt(oldIndex);
      _selectedButtons.insert(newIndex, button);
      _hasChanges = true;
    });
  }

  // 저장
  Future<void> _saveWidgetConfig() async {
    final provider = context.read<SpeedDialProvider>();
    
    final success = await provider.updateWidgetButtons(_selectedButtons);
    
    if (!mounted) return;
    
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white, size: 20.sp),
              SizedBox(width: 12.w),
              Text(
                '위젯 설정이 저장되었습니다',
                style: TextStyle(fontSize: 16.sp),
              ),
            ],
          ),
          backgroundColor: Colors.green[700],
        ),
      );
      
      setState(() {
        _hasChanges = false;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '저장 중 오류가 발생했습니다',
            style: TextStyle(fontSize: 16.sp),
          ),
          backgroundColor: Colors.red[700],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_hasChanges) {
          final result = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('변경사항이 있습니다'),
              content: const Text('저장하지 않고 나가시겠습니까?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('취소'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('나가기'),
                ),
              ],
            ),
          );
          return result ?? false;
        }
        return true;
      },
      child: Scaffold(
        backgroundColor: Colors.grey[100],
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.white,
          title: const Text(
            '위젯 버튼 설정',
            style: TextStyle(
              color: Colors.black87,
              fontWeight: FontWeight.bold,
            ),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black87),
            onPressed: () => Navigator.pop(context),
          ),
          actions: [
            if (_hasChanges)
              TextButton(
                onPressed: _saveWidgetConfig,
                child: Text(
                  '저장',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.blue[600],
                  ),
                ),
              ),
          ],
        ),
        body: Consumer<SpeedDialProvider>(
          builder: (context, provider, child) {
            return Column(
              children: [
                // 안내 카드
                Container(
                  margin: EdgeInsets.all(16.w),
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(color: Colors.blue[200]!),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: Colors.blue[700],
                        size: 24.sp,
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '위젯에 표시할 버튼을 선택하세요',
                              style: TextStyle(
                                fontSize: 15.sp,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue[900],
                              ),
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              '최대 4개까지 선택 가능하며, 순서를 변경할 수 있습니다',
                              style: TextStyle(
                                fontSize: 13.sp,
                                color: Colors.blue[700],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // 선택된 버튼 (드래그 가능)
                if (_selectedButtons.isNotEmpty) ...[
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: Row(
                      children: [
                        Icon(
                          Icons.widgets,
                          color: Colors.green[700],
                          size: 20.sp,
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          '위젯에 표시 (${_selectedButtons.length}/4)',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.green[700],
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '드래그하여 순서 변경',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 16.w),
                    padding: EdgeInsets.all(12.w),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(color: Colors.green[200]!),
                    ),
                    child: ReorderableListView(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      onReorder: _reorderSelectedButtons,
                      children: _selectedButtons.asMap().entries.map((entry) {
                        final index = entry.key;
                        final button = entry.value;
                        return _buildSelectedButtonItem(button, index);
                      }).toList(),
                    ),
                  ),
                  SizedBox(height: 16.h),
                ],

                // 구분선
                Divider(thickness: 8.h, color: Colors.grey[200]),

                // 모든 버튼 목록
                Padding(
                  padding: EdgeInsets.all(16.w),
                  child: Row(
                    children: [
                      Icon(
                        Icons.list,
                        color: Colors.grey[700],
                        size: 20.sp,
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        '모든 단축키',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                        ),
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: ListView.builder(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    itemCount: provider.allButtons.length,
                    itemBuilder: (context, index) {
                      final button = provider.allButtons[index];
                      final isSelected = _selectedButtons
                          .any((b) => b.id == button.id);
                      return _buildButtonItem(button, isSelected);
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  // 선택된 버튼 아이템 (드래그 가능)
  Widget _buildSelectedButtonItem(SpeedDialButton button, int index) {
    return Container(
      key: ValueKey(button.id),
      margin: EdgeInsets.only(bottom: 8.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.green[50],
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: Colors.green[300]!),
      ),
      child: Row(
        children: [
          Icon(
            Icons.drag_handle,
            color: Colors.green[700],
            size: 24.sp,
          ),
          SizedBox(width: 12.w),
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Text(
              String.fromCharCode(button.iconData.codePoint),
              style: TextStyle(fontSize: 24.sp),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  button.name,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  button.phoneNumber,
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: Colors.green[700],
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Text(
              '${index + 1}',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          SizedBox(width: 8.w),
          IconButton(
            icon: Icon(
              Icons.close,
              color: Colors.red[700],
              size: 20.sp,
            ),
            onPressed: () => _toggleButton(button),
          ),
        ],
      ),
    );
  }

  // 버튼 아이템
  Widget _buildButtonItem(SpeedDialButton button, bool isSelected) {
    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: isSelected ? Colors.green[300]! : Colors.grey[300]!,
          width: isSelected ? 2 : 1,
        ),
      ),
      child: CheckboxListTile(
        value: isSelected,
        onChanged: (_) => _toggleButton(button),
        secondary: Container(
          padding: EdgeInsets.all(8.w),
          decoration: BoxDecoration(
            color: isSelected ? Colors.green[50] : Colors.grey[100],
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Text(
            String.fromCharCode(button.iconData.codePoint),
            style: TextStyle(fontSize: 24.sp),
          ),
        ),
        title: Text(
          button.name,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              button.phoneNumber,
              style: TextStyle(
                fontSize: 13.sp,
                color: Colors.grey[600],
              ),
            ),
            if (button.group != '일반')
              Container(
                margin: EdgeInsets.only(top: 4.h),
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(4.r),
                ),
                child: Text(
                  button.group,
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: Colors.blue[700],
                  ),
                ),
              ),
          ],
        ),
        activeColor: Colors.green[700],
      ),
    );
  }
}