import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:quick_call/utils/phone_formatter.dart';

class ContactPickerWidget extends StatefulWidget {
  final Function(String name, String phoneNumber) onContactSelected;

  const ContactPickerWidget({
    super.key,
    required this.onContactSelected,
  });

  @override
  State<ContactPickerWidget> createState() => _ContactPickerWidgetState();
}

class _ContactPickerWidgetState extends State<ContactPickerWidget> {
  List<Contact> _contacts = [];
  List<Contact> _filteredContacts = [];
  bool _isLoading = false;
  bool _hasPermission = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _checkPermissionAndLoadContacts();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // 권한 확인 및 연락처 로드
  Future<void> _checkPermissionAndLoadContacts() async {
    setState(() => _isLoading = true);

    try {
      // 권한 확인
      final status = await Permission.contacts.status;
      
      if (status.isDenied) {
        final result = await Permission.contacts.request();
        if (result.isGranted) {
          await _loadContacts();
        } else {
          setState(() {
            _hasPermission = false;
            _isLoading = false;
          });
          return;
        }
      } else if (status.isGranted) {
        await _loadContacts();
      } else if (status.isPermanentlyDenied) {
        setState(() {
          _hasPermission = false;
          _isLoading = false;
        });
        return;
      }
    } catch (e) {
      debugPrint('권한 확인 오류: $e');
      setState(() {
        _hasPermission = false;
        _isLoading = false;
      });
    }
  }

  // 연락처 로드
  Future<void> _loadContacts() async {
    try {
      final contacts = await FlutterContacts.getContacts(
        withProperties: true,
        withPhoto: false,
      );

      // 전화번호가 있는 연락처만 필터링
      final contactsWithPhone = contacts.where((contact) {
        return contact.phones.isNotEmpty;
      }).toList();

      // 이름순 정렬
      contactsWithPhone.sort((a, b) {
        final nameA = a.displayName.toLowerCase();
        final nameB = b.displayName.toLowerCase();
        return nameA.compareTo(nameB);
      });

      setState(() {
        _contacts = contactsWithPhone;
        _filteredContacts = contactsWithPhone;
        _hasPermission = true;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('연락처 로드 오류: $e');
      setState(() {
        _isLoading = false;
        _hasPermission = false;
      });
    }
  }

  // 연락처 검색
  void _searchContacts(String query) {
    if (query.isEmpty) {
      setState(() {
        _filteredContacts = _contacts;
      });
      return;
    }

    final lowercaseQuery = query.toLowerCase();
    setState(() {
      _filteredContacts = _contacts.where((contact) {
        final name = contact.displayName.toLowerCase();
        final phones = contact.phones
            .map((p) => PhoneFormatter.cleanPhoneNumber(p.number))
            .join(' ');
        return name.contains(lowercaseQuery) || phones.contains(lowercaseQuery);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('연락처 선택'),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(60.h),
          child: Padding(
            padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 12.h),
            child: TextField(
              controller: _searchController,
              onChanged: _searchContacts,
              decoration: InputDecoration(
                hintText: '이름 또는 전화번호 검색',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _searchContacts('');
                        },
                      )
                    : null,
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide.none,
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16.w,
                  vertical: 12.h,
                ),
              ),
            ),
          ),
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    // 로딩 중
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue[700]!),
            ),
            SizedBox(height: 16.h),
            Text(
              '연락처를 불러오는 중...',
              style: TextStyle(
                fontSize: 16.sp,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    // 권한 없음
    if (!_hasPermission) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(32.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.contacts,
                size: 80.sp,
                color: Colors.grey[400],
              ),
              SizedBox(height: 24.h),
              Text(
                '연락처 권한이 필요합니다',
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 12.h),
              Text(
                '연락처에서 전화번호를 선택하려면\n연락처 접근 권한이 필요합니다.',
                style: TextStyle(
                  fontSize: 16.sp,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 32.h),
              ElevatedButton.icon(
                onPressed: () async {
                  final status = await Permission.contacts.status;
                  if (status.isPermanentlyDenied) {
                    await openAppSettings();
                  } else {
                    await _checkPermissionAndLoadContacts();
                  }
                },
                icon: const Icon(Icons.settings),
                label: const Text('권한 설정'),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(
                    horizontal: 32.w,
                    vertical: 16.h,
                  ),
                  textStyle: TextStyle(fontSize: 16.sp),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // 연락처 없음
    if (_contacts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.people_outline,
              size: 80.sp,
              color: Colors.grey[400],
            ),
            SizedBox(height: 16.h),
            Text(
              '저장된 연락처가 없습니다',
              style: TextStyle(
                fontSize: 18.sp,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    // 검색 결과 없음
    if (_filteredContacts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 80.sp,
              color: Colors.grey[400],
            ),
            SizedBox(height: 16.h),
            Text(
              '검색 결과가 없습니다',
              style: TextStyle(
                fontSize: 18.sp,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    // 연락처 리스트
    return ListView.separated(
      itemCount: _filteredContacts.length,
      separatorBuilder: (context, index) => Divider(
        height: 1,
        color: Colors.grey[300],
      ),
      itemBuilder: (context, index) {
        final contact = _filteredContacts[index];
        return _buildContactTile(contact);
      },
    );
  }

  Widget _buildContactTile(Contact contact) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(
        horizontal: 16.w,
        vertical: 8.h,
      ),
      leading: CircleAvatar(
        backgroundColor: Colors.blue[100],
        radius: 24.r,
        child: Text(
          contact.displayName.isNotEmpty
              ? contact.displayName[0].toUpperCase()
              : '?',
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
            color: Colors.blue[700],
          ),
        ),
      ),
      title: Text(
        contact.displayName,
        style: TextStyle(
          fontSize: 16.sp,
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: contact.phones.map((phone) {
          return Padding(
            padding: EdgeInsets.only(top: 4.h),
            child: Text(
              PhoneFormatter.format(phone.number),
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.grey[600],
              ),
            ),
          );
        }).toList(),
      ),
      trailing: Icon(
        Icons.chevron_right,
        color: Colors.grey[400],
      ),
      onTap: () {
        if (contact.phones.isNotEmpty) {
          // 전화번호가 여러 개인 경우 선택 다이얼로그 표시
          if (contact.phones.length > 1) {
            _showPhoneSelectionDialog(contact);
          } else {
            // 전화번호가 하나인 경우 바로 선택
            final phoneNumber = contact.phones.first.number;
            widget.onContactSelected(contact.displayName, phoneNumber);
            Navigator.pop(context);
          }
        }
      },
    );
  }

  // 전화번호 선택 다이얼로그
  void _showPhoneSelectionDialog(Contact contact) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(
            '전화번호 선택',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: contact.phones.map((phone) {
              return ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  PhoneFormatter.format(phone.number),
                  style: TextStyle(fontSize: 16.sp),
                ),
                subtitle: phone.label.name.isNotEmpty
                    ? Text(
                        phone.label.name,
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Colors.grey[600],
                        ),
                      )
                    : null,
                onTap: () {
                  Navigator.pop(dialogContext);
                  widget.onContactSelected(contact.displayName, phone.number);
                  Navigator.pop(context);
                },
              );
            }).toList(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('취소'),
            ),
          ],
        );
      },
    );
  }
}