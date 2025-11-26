import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:quick_call/models/speed_dial_button.dart';
import 'package:quick_call/providers/speed_dial_provider.dart';
import 'package:quick_call/widgets/color_picker_widget.dart'; // 🆕 변경
import 'package:quick_call/widgets/contact_picker_widget.dart';
import 'package:quick_call/services/database_service.dart';      
import 'package:quick_call/widgets/duplicate_phone_dialog.dart';

class AddButtonScreen extends StatefulWidget {
  const AddButtonScreen({super.key});

  @override
  State<AddButtonScreen> createState() => _AddButtonScreenState();
}

class _AddButtonScreenState extends State<AddButtonScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _newGroupController = TextEditingController();
  
  Color _selectedColor = const Color(0xFF2196F3); // 🆕 색상 선택 (기본 파란색)
  String? _selectedGroup;
  bool _isAddingNewGroup = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<SpeedDialProvider>();
      if (mounted && _selectedGroup == null) {
        setState(() {
          final availableGroups = provider.groups.where((g) => g != '전체').toList();
          _selectedGroup = availableGroups.isNotEmpty ? availableGroups.first : null;
        });
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _newGroupController.dispose();
    super.dispose();
  }

  // 🆕 색상 선택 모달 열기
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

    if (color != null && mounted) {
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

  // 🆕 텍스트 색상 자동 결정
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

    String finalGroup;
    
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
      finalGroup = newGroupName;
    } else {
      if (_selectedGroup == null) {
        if (!mounted) return;
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text(
              '그룹을 선택해주세요',
              style: TextStyle(fontSize: 16.sp),
            ),
            backgroundColor: Colors.red[700],
          ),
        );
        return;
      }
      finalGroup = _selectedGroup!;
    }

    setState(() => _isSaving = true);

    try {
      if (!mounted) return;

      final dbService = DatabaseService();
      final phoneNumber = _phoneController.text.trim();
      final existingButton = await dbService.findByExactPhoneNumber(phoneNumber);

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
      
      final nextPosition = provider.allButtons.length;

      final button = SpeedDialButton(
        name: _nameController.text.trim(),
        phoneNumber: _phoneController.text.trim(),
        color: _selectedColor, // 🆕 색상 저장
        group: finalGroup,
        position: nextPosition,
      );

      final success = await provider.addButton(button);

      if (!mounted) return;

      if (success) {
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text(
              '${button.name} 단축키가 추가되었습니다',
              style: TextStyle(fontSize: 16.sp),
            ),
            backgroundColor: Colors.green[700],
            duration: const Duration(seconds: 2),
          ),
        );
        if (mounted) {
          navigator.pop();
        }
      } else {
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text(
              '단축키 추가에 실패했습니다',
              style: TextStyle(fontSize: 16.sp),
            ),
            backgroundColor: Colors.red[700],
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      
      scaffoldMessenger.showSnackBar(
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

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 32.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20.r),
          ),
          child: SingleChildScrollView(
            padding: EdgeInsets.all(24.w),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 제목
                  Text(
                    '단축 버튼 추가',
                    style: TextStyle(
                      fontSize: 22.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 24.h),

                  // 🆕 색상 선택 버튼
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

                  // 이름
                  TextFormField(
                    controller: _nameController,
                    maxLength: 10,
                    decoration: InputDecoration(
                      labelText: '이름',
                      hintText: '예: 엄마, 119',
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
                  SizedBox(height: 16.h),

                  // 전화번호 입력 + 연락처 버튼
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(RegExp(r'[0-9+\-\s]')),
                          ],
                          decoration: InputDecoration(
                            labelText: '전화번호',
                            hintText: '010-1234-5678',
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
                  SizedBox(height: 8.h),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      '연락처에서 가져오기 버튼 (시뮬레이션)',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                  SizedBox(height: 16.h),

                  // 그룹 선택
                  Consumer<SpeedDialProvider>(
                    builder: (context, provider, child) {
                      final availableGroups = provider.groups
                          .where((g) => g != '전체')
                          .toList();
                      
                      if (_selectedGroup == null && availableGroups.isNotEmpty && !_isAddingNewGroup) {
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          if (mounted) {
                            setState(() {
                              _selectedGroup = availableGroups.first;
                            });
                          }
                        });
                      }

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          DropdownButtonFormField<String>(
                            value: _isAddingNewGroup ? null : _selectedGroup,
                            decoration: InputDecoration(
                              labelText: '그룹',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                            ),
                            items: [
                              ...availableGroups.map((group) {
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
                  SizedBox(height: 24.h),

                  // 저장 버튼
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isSaving ? null : _saveButton,
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
                  SizedBox(height: 12.h),
                  
                  // 취소 버튼
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: _isSaving ? null : () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 16.h),
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
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}