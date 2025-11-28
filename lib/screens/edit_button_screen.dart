import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:quick_call/models/speed_dial_button.dart';
import 'package:quick_call/providers/speed_dial_provider.dart';
import 'package:quick_call/widgets/color_picker_widget.dart';
import 'package:quick_call/widgets/contact_picker_widget.dart';
import 'package:quick_call/services/database_service.dart';     
import 'package:quick_call/widgets/duplicate_phone_dialog.dart';

class EditButtonScreen extends StatefulWidget {
  final SpeedDialButton button;

  const EditButtonScreen({
    super.key,
    required this.button,
  });

  @override
  State<EditButtonScreen> createState() => _EditButtonScreenState();
}

class _EditButtonScreenState extends State<EditButtonScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  final _newGroupController = TextEditingController();
  
  late Color _selectedColor;
  late String _selectedGroup;
  bool _isAddingNewGroup = false;
  bool _isSaving = false;
  bool _isDeleting = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.button.name);
    _phoneController = TextEditingController(text: widget.button.phoneNumber);
    _selectedColor = widget.button.color;
    _selectedGroup = widget.button.group;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _newGroupController.dispose();
    super.dispose();
  }

  // 색상 선택 모달 열기
  Future<void> _openColorPicker() async {
    final color = await showModalBottomSheet<Color>(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (context) => ColorPickerWidget(
        selectedColor: _selectedColor,
      ),
    );

    if (color != null) {
      setState(() {
        _selectedColor = color;
      });
    }
  }

  // 연락처 선택
  Future<void> _openContactPicker() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ContactPickerWidget(
          onContactSelected: (name, phoneNumber) {
            setState(() {
              _nameController.text = name;
              _phoneController.text = phoneNumber;
            });
          },
        ),
      ),
    );
  }

  // 텍스트 색상 자동 결정
  Color _getTextColorForBackground(Color backgroundColor) {
    return backgroundColor.computeLuminance() > 0.5 
        ? Colors.black87 
        : Colors.white;
  }

  // 저장
  Future<void> _saveButton() async {
    final navigator = Navigator.of(context);
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final provider = context.read<SpeedDialProvider>();
    
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_isAddingNewGroup) {
      final newGroupName = _newGroupController.text.trim();
      if (newGroupName.isEmpty) {
        if (!mounted) return;
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text(
              '새 그룹 이름을 입력해주세요',
              style: TextStyle(fontSize: 16.sp),
            ),
            backgroundColor: Colors.red[700],
          ),
        );
        return;
      }
      _selectedGroup = newGroupName;
    }

    setState(() => _isSaving = true);

    try {
      if (!mounted) return;
      
      final dbService = DatabaseService();
      final phoneNumber = _phoneController.text.trim();
    
      final existingButton = await dbService.findByExactPhoneNumber(
        phoneNumber,
        excludeId: widget.button.id,
      );

      if (existingButton != null && mounted) {
        final action = await DuplicatePhoneDialog.show(
          context,
          existingButton: existingButton,
          newName: _nameController.text.trim(),
          phoneNumber: phoneNumber,
        );

        if (!mounted) return;

        if (action == DuplicateAction.cancel) {
          setState(() => _isSaving = false);
          return;
        }
      }

      final updatedButton = SpeedDialButton(
        id: widget.button.id,
        name: _nameController.text.trim(),
        phoneNumber: _phoneController.text.trim(),
        color: _selectedColor,
        group: _selectedGroup,
        position: widget.button.position,
        createdAt: widget.button.createdAt,
        lastCalled: widget.button.lastCalled,
      );

      final success = await provider.updateButton(updatedButton);

      if (!mounted) return;

      if (success) {
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text(
              '${updatedButton.name} 단축키가 수정되었습니다',
              style: TextStyle(fontSize: 16.sp),
            ),
            backgroundColor: Colors.green[700],
            duration: const Duration(seconds: 2),
          ),
        );
        navigator.pop();
      } else {
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text(
              '단축키 수정에 실패했습니다',
              style: TextStyle(fontSize: 16.sp),
            ),
            backgroundColor: Colors.red[700],
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '오류가 발생했습니다: $e',
            style: TextStyle(fontSize: 16.sp),
          ),
          backgroundColor: Colors.red[700],
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  // 삭제
  Future<void> _deleteButton() async {
    final provider = context.read<SpeedDialProvider>();
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.r),
          ),
          title: Column(
            children: [
              Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.delete_outline,
                  size: 40.sp,
                  color: Colors.red[700],
                ),
              ),
              SizedBox(height: 16.h),
              Text(
                '정말 삭제하시겠습니까?',
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: Text(
            '${widget.button.name}\n이 작업은 되돌릴 수 없습니다.',
            style: TextStyle(
              fontSize: 16.sp,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: Text(
                '취소',
                style: TextStyle(
                  fontSize: 16.sp,
                  color: Colors.grey[600],
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[700],
              ),
              child: Text(
                '삭제',
                style: TextStyle(
                  fontSize: 16.sp,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    setState(() => _isDeleting = true);

    try {
      if (widget.button.id != null) {
        if (!mounted) return;
        
        final success = await provider.deleteButton(widget.button.id!);

        if (!mounted) return;

        if (success) {
          scaffoldMessenger.showSnackBar(
            SnackBar(
              content: Text(
                '${widget.button.name}이(가) 삭제되었습니다',
                style: TextStyle(fontSize: 16.sp),
              ),
              backgroundColor: Colors.orange[700],
            ),
          );
          navigator.pop();
        } else {
          scaffoldMessenger.showSnackBar(
            SnackBar(
              content: Text(
                '삭제에 실패했습니다',
                style: TextStyle(fontSize: 16.sp),
              ),
              backgroundColor: Colors.red[700],
            ),
          );
        }
      }
    } catch (e) {
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '오류가 발생했습니다: $e',
            style: TextStyle(fontSize: 16.sp),
          ),
          backgroundColor: Colors.red[700],
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isDeleting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // 🆕 다크 모드 대응: Theme에서 색상 가져오기
    final theme = Theme.of(context);
    final cardColor = theme.cardTheme.color ?? theme.cardColor;
    // 🔧 수정: textColor 변수 제거 (미사용)

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor, // 🆕 테마 배경색 사용
      appBar: AppBar(
        // 🆕 backgroundColor 제거 - 테마 기본값 사용
        leading: IconButton(
          icon: Icon(Icons.close, color: theme.appBarTheme.foregroundColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          '단축키 편집',
          style: TextStyle(
            color: theme.appBarTheme.foregroundColor, // 🆕 테마 텍스트 색상
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          TextButton(
            onPressed: _isDeleting ? null : _deleteButton,
            child: Text(
              '삭제',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: _isDeleting ? Colors.grey : Colors.red[700],
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24.w),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // 색상 선택 버튼
              GestureDetector(
                onTap: _openColorPicker,
                child: Container(
                  width: 96.w,
                  height: 96.w,
                  decoration: BoxDecoration(
                    color: _selectedColor,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.grey[300]!,
                      width: 2,
                    ),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Icon(
                        Icons.palette,
                        size: 40.sp,
                        color: _getTextColorForBackground(_selectedColor),
                      ),
                      Positioned(
                        bottom: 8.h,
                        child: Text(
                          '색상 변경',
                          style: TextStyle(
                            fontSize: 11.sp,
                            color: _getTextColorForBackground(_selectedColor),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 24.h),

              // 이름 입력 + 연락처 버튼 (🆕 버튼 위치 변경)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: '이름',
                        hintText: '예: 엄마, 119',
                        filled: true,
                        fillColor: cardColor, // 🆕 테마 카드 색상
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        counterText: '',
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return '이름을 입력해주세요';
                        }
                        return null;
                      },
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Container(
                    height: 56.h,
                    width: 56.w,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: IconButton(
                      icon: Icon(
                        Icons.contact_phone,
                        color: Colors.grey[700],
                        size: 24.sp,
                      ),
                      onPressed: _openContactPicker,
                      tooltip: '연락처에서 가져오기',
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16.h),

              // 전화번호 입력 (🆕 버튼 제거됨)
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9+\-\s]')),
                ],
                decoration: InputDecoration(
                  labelText: '전화번호',
                  hintText: '010-1234-5678',
                  filled: true,
                  fillColor: cardColor, // 🆕 테마 카드 색상
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return '전화번호를 입력해주세요';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.h),

              // 그룹 선택
              Consumer<SpeedDialProvider>(
                builder: (context, provider, child) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      DropdownButtonFormField<String>(
                        initialValue: _isAddingNewGroup ? null : _selectedGroup,
                        decoration: InputDecoration(
                          labelText: '그룹',
                          filled: true,
                          fillColor: cardColor, // 🆕 테마 카드 색상
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                        ),
                        items: [
                          ...provider.groups
                              .where((g) => g != '전체')
                              .map((group) {
                            return DropdownMenuItem(
                              value: group,
                              child: Text(group),
                            );
                          }),
                          const DropdownMenuItem(
                            value: '__new__',
                            child: Text('새 그룹 추가...'),
                          ),
                        ],
                        onChanged: (value) {
                          if (value == '__new__') {
                            setState(() {
                              _isAddingNewGroup = true;
                            });
                          } else {
                            setState(() {
                              _selectedGroup = value!;
                              _isAddingNewGroup = false;
                            });
                          }
                        },
                      ),
                      
                      if (_isAddingNewGroup) ...[
                        SizedBox(height: 16.h),
                        TextFormField(
                          controller: _newGroupController,
                          decoration: InputDecoration(
                            labelText: '새 그룹 이름',
                            hintText: '그룹 이름 입력',
                            filled: true,
                            fillColor: cardColor, // 🆕 테마 카드 색상
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            suffixIcon: IconButton(
                              icon: const Icon(Icons.close),
                              onPressed: () {
                                setState(() {
                                  _isAddingNewGroup = false;
                                  _newGroupController.clear();
                                });
                              },
                            ),
                          ),
                          autofocus: true,
                        ),
                      ],
                    ],
                  );
                },
              ),
              SizedBox(height: 32.h),

              // 저장 버튼
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: (_isSaving || _isDeleting) ? null : _saveButton,
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 16.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    backgroundColor: Colors.blue[600],
                  ),
                  child: Text(
                    _isSaving ? '저장 중...' : '저장',
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
      ),
    );
  }
}