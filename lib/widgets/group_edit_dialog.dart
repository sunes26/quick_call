import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// 그룹 편집 바텀시트
/// 
/// 그룹 이름 변경, 그룹 삭제 기능 제공
class GroupEditDialog extends StatefulWidget {
  final String groupName;
  final VoidCallback onCancel;
  final Function(String newName) onConfirm;
  final VoidCallback onDelete;

  const GroupEditDialog({
    super.key,
    required this.groupName,
    required this.onCancel,
    required this.onConfirm,
    required this.onDelete,
  });

  @override
  State<GroupEditDialog> createState() => _GroupEditDialogState();
}

class _GroupEditDialogState extends State<GroupEditDialog> {
  late TextEditingController _controller;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.groupName);
    _focusNode = FocusNode();
    
    // 다이얼로그가 열리면 자동으로 포커스
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
      // 텍스트 전체 선택
      _controller.selection = TextSelection(
        baseOffset: 0,
        extentOffset: _controller.text.length,
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(24.r),
        ),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 상단 바 (드래그 인디케이터)
              Center(
                child: Container(
                  width: 40.w,
                  height: 4.h,
                  margin: EdgeInsets.only(bottom: 16.h),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
              ),

              // 타이틀
              Row(
                children: [
                  Icon(
                    Icons.edit,
                    color: Colors.blue[600],
                    size: 24.sp,
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    '그룹 편집',
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),

              SizedBox(height: 20.h),

              // 그룹 이름 입력 필드
              TextField(
                controller: _controller,
                focusNode: _focusNode,
                maxLength: 10,
                decoration: InputDecoration(
                  labelText: '그룹 이름',
                  hintText: '그룹 이름을 입력하세요',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: BorderSide(color: Colors.blue[600]!, width: 2),
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                  counterText: '${_controller.text.length}/10',
                  counterStyle: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.grey[600],
                  ),
                ),
                style: TextStyle(
                  fontSize: 16.sp,
                  color: Colors.black87,
                ),
                onChanged: (value) {
                  setState(() {}); // 글자 수 카운터 업데이트
                },
              ),

              SizedBox(height: 24.h),

              // 하단 버튼들
              Row(
                children: [
                  // 왼쪽: 그룹 제거 버튼
                  Expanded(
                    flex: 2,
                    child: OutlinedButton.icon(
                      onPressed: widget.onDelete,
                      icon: Icon(
                        Icons.delete_outline,
                        size: 20.sp,
                        color: Colors.red[700],
                      ),
                      label: Text(
                        '그룹 제거',
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.red[700],
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 14.h),
                        side: BorderSide(color: Colors.red[700]!, width: 1.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                    ),
                  ),

                  SizedBox(width: 12.w),

                  // 오른쪽: 취소 버튼
                  Expanded(
                    flex: 1,
                    child: OutlinedButton(
                      onPressed: widget.onCancel,
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 14.h),
                        side: BorderSide(color: Colors.grey[400]!, width: 1.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                      child: Text(
                        '취소',
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[700],
                        ),
                      ),
                    ),
                  ),

                  SizedBox(width: 8.w),

                  // 오른쪽: 확인 버튼
                  Expanded(
                    flex: 1,
                    child: ElevatedButton(
                      onPressed: () {
                        final newName = _controller.text.trim();
                        widget.onConfirm(newName);
                      },
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 14.h),
                        backgroundColor: Colors.blue[600],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        elevation: 0,
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
            ],
          ),
        ),
      ),
    );
  }
}