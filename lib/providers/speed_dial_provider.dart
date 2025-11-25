import 'package:flutter/material.dart';
import 'dart:convert'; // 🆕 jsonDecode 사용을 위해 필요
import 'package:quick_call/models/speed_dial_button.dart';
import 'package:quick_call/services/database_service.dart';
import 'package:quick_call/services/phone_service.dart';
import 'package:quick_call/services/widget_service.dart';
import 'package:quick_call/utils/sort_options.dart';

class SpeedDialProvider extends ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService();
  final PhoneService _phoneService = PhoneService();
  final WidgetService _widgetService = WidgetService();
  
  List<SpeedDialButton> _buttons = [];
  List<String> _groups = ['전체'];
  String _selectedGroup = '전체';
  bool _isLoading = false;
  bool _isEditMode = false;
  String? _error;

  String _searchQuery = '';
  bool _isSearching = false;
  SortOption _currentSortOption = SortOption.custom;

  // Getters
  List<SpeedDialButton> get buttons {
    var filteredButtons = _selectedGroup == '전체'
        ? _buttons
        : _buttons.where((b) => b.group == _selectedGroup).toList();

    if (_searchQuery.isNotEmpty) {
      filteredButtons = filteredButtons.where((button) {
        final nameLower = button.name.toLowerCase();
        final phoneLower = button.phoneNumber.replaceAll(RegExp(r'[^\d]'), '');
        final queryLower = _searchQuery.toLowerCase();
        final queryDigits = _searchQuery.replaceAll(RegExp(r'[^\d]'), '');
        
        return nameLower.contains(queryLower) || phoneLower.contains(queryDigits);
      }).toList();
    }

    return _sortButtons(filteredButtons);
  }
  
  List<SpeedDialButton> get allButtons => _buttons;
  List<String> get groups => _groups;
  String get selectedGroup => _selectedGroup;
  bool get isLoading => _isLoading;
  bool get isEditMode => _isEditMode;
  String? get error => _error;
  
  String get searchQuery => _searchQuery;
  bool get isSearching => _isSearching;
  SortOption get currentSortOption => _currentSortOption;

  // 🆕 위젯에 표시되는 버튼들 (기존 단일 위젯용 - 하위 호환성)
  List<SpeedDialButton> get widgetButtons {
    return _buttons
        .where((b) => b.isInWidget)
        .toList()
      ..sort((a, b) => a.widgetPosition.compareTo(b.widgetPosition));
  }

  // 초기화
  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _databaseService.initialize();
      await loadButtons();
      await loadGroups();
      
      // 🆕 위젯 설정 화면을 위해 전체 버튼 데이터 저장
      await _updateAllWidgetsData();
      
      _error = null;
    } catch (e) {
      _error = '초기화 중 오류가 발생했습니다: $e';
      debugPrint(_error);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 모든 버튼 로드
  Future<void> loadButtons() async {
    try {
      _buttons = await _databaseService.getAllButtons();
      _buttons.sort((a, b) => a.position.compareTo(b.position));
      
      // 🆕 전체 버튼 데이터 업데이트
      await _updateAllWidgetsData();
      
      notifyListeners();
    } catch (e) {
      _error = '버튼을 불러오는 중 오류가 발생했습니다: $e';
      debugPrint(_error);
    }
  }

  // 🆕 모든 위젯 데이터 업데이트 (위젯 설정 화면용)
  Future<void> _updateAllWidgetsData() async {
    try {
      // 전체 버튼 데이터를 위젯 설정 화면에서 사용할 수 있도록 저장
      await _widgetService.saveAllButtonsData(_buttons);
      
      // 기존 설치된 위젯들 새로고침
      await _widgetService.refreshAllWidgets();
    } catch (e) {
      debugPrint('위젯 데이터 업데이트 오류: $e');
    }
  }

  // 🆕 기존 단일 위젯 업데이트 (하위 호환성 유지)
  Future<void> _updateWidget() async {
    try {
      // isInWidget이 true인 버튼만 위젯에 전송 (widgetPosition 순으로)
      final widgetButtonsToSend = _buttons
          .where((b) => b.isInWidget)
          .toList()
        ..sort((a, b) => a.widgetPosition.compareTo(b.widgetPosition));
      
      // 기존 방식: 첫 번째 위젯에만 적용 (하위 호환성)
      final widgetIds = await _widgetService.getWidgetIds();
      if (widgetIds.isNotEmpty) {
        await _widgetService.updateWidgetData(widgetIds.first, widgetButtonsToSend);
      }
    } catch (e) {
      debugPrint('위젯 업데이트 오류: $e');
    }
  }

  // 🆕 위젯 버튼 업데이트 (기존 기능 유지)
  Future<bool> updateWidgetButtons(List<SpeedDialButton> selectedButtons) async {
    try {
      final success = await _databaseService.updateWidgetButtons(selectedButtons);
      
      if (success) {
        await loadButtons();
        await _updateWidget();
        return true;
      }
      
      return false;
    } catch (e) {
      _error = '위젯 버튼 업데이트 중 오류가 발생했습니다: $e';
      debugPrint(_error);
      notifyListeners();
      return false;
    }
  }

  // 검색어 설정
  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  // 검색 모드 토글
  void toggleSearchMode() {
    _isSearching = !_isSearching;
    if (!_isSearching) {
      _searchQuery = '';
    }
    notifyListeners();
  }

  // 검색 초기화
  void clearSearch() {
    _searchQuery = '';
    notifyListeners();
  }

  // 정렬 옵션 변경
  void setSortOption(SortOption option) {
    _currentSortOption = option;
    notifyListeners();
  }

  // 정렬 로직
  List<SpeedDialButton> _sortButtons(List<SpeedDialButton> buttons) {
    final sortedButtons = List<SpeedDialButton>.from(buttons);

    switch (_currentSortOption) {
      case SortOption.nameAsc:
        sortedButtons.sort((a, b) => a.name.compareTo(b.name));
        break;

      case SortOption.lastCalledDesc:
        sortedButtons.sort((a, b) {
          if (a.lastCalled == null && b.lastCalled == null) return 0;
          if (a.lastCalled == null) return 1;
          if (b.lastCalled == null) return -1;
          return b.lastCalled!.compareTo(a.lastCalled!);
        });
        break;

      case SortOption.createdAtAsc:
        sortedButtons.sort((a, b) => a.createdAt.compareTo(b.createdAt));
        break;

      case SortOption.createdAtDesc:
        sortedButtons.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;

      case SortOption.custom:
        sortedButtons.sort((a, b) => a.position.compareTo(b.position));
        break;
    }

    return sortedButtons;
  }

  // 그룹 목록 로드
  Future<void> loadGroups() async {
    try {
      final dbGroups = await _databaseService.getAllGroups();
      
      final defaultGroups = ['전체', '일반', '가족', '긴급', '직장', '친구'];
      
      final allGroups = <String>{...defaultGroups};
      for (var group in dbGroups) {
        if (group != '전체') {
          allGroups.add(group);
        }
      }
      
      _groups = allGroups.toList();
      notifyListeners();
    } catch (e) {
      _error = '그룹을 불러오는 중 오류가 발생했습니다: $e';
      debugPrint(_error);
    }
  }

  // 그룹 선택
  void selectGroup(String group) {
    _selectedGroup = group;
    notifyListeners();
  }

  // 편집 모드 토글
  void toggleEditMode() {
    _isEditMode = !_isEditMode;
    if (_isEditMode && _isSearching) {
      toggleSearchMode();
    }
    notifyListeners();
  }

  // 편집 모드 종료
  void exitEditMode() {
    _isEditMode = false;
    notifyListeners();
  }

  // 버튼 추가
  Future<bool> addButton(SpeedDialButton button) async {
    try {
      final id = await _databaseService.insertButton(button);
      if (id > 0) {
        await loadButtons();
        await loadGroups();
        return true;
      }
      return false;
    } catch (e) {
      _error = '버튼 추가 중 오류가 발생했습니다: $e';
      debugPrint(_error);
      notifyListeners();
      return false;
    }
  }

  // 버튼 업데이트
  Future<bool> updateButton(SpeedDialButton button) async {
    try {
      final success = await _databaseService.updateButton(button);
      if (success) {
        await loadButtons();
        await loadGroups();
        return true;
      }
      return false;
    } catch (e) {
      _error = '버튼 업데이트 중 오류가 발생했습니다: $e';
      debugPrint(_error);
      notifyListeners();
      return false;
    }
  }

  // 버튼 삭제
  Future<bool> deleteButton(int id) async {
    try {
      final success = await _databaseService.deleteButtonAndReorder(id);
      if (success) {
        await loadButtons();
        await loadGroups();
        return true;
      }
      return false;
    } catch (e) {
      _error = '버튼 삭제 중 오류가 발생했습니다: $e';
      debugPrint(_error);
      notifyListeners();
      return false;
    }
  }

  // 전화 걸기
  Future<bool> makeCall(SpeedDialButton button) async {
    try {
      final success = await _phoneService.makePhoneCall(button.phoneNumber);
      
      if (success && button.id != null) {
        final updatedButton = button.copyWith(
          lastCalled: DateTime.now(),
        );
        await updateButton(updatedButton);
      }
      
      return success;
    } catch (e) {
      _error = '전화 연결 중 오류가 발생했습니다: $e';
      debugPrint(_error);
      notifyListeners();
      return false;
    }
  }

  // 위치 변경
  Future<void> reorderButtons(int oldIndex, int newIndex) async {
    try {
      final visibleButtons = List<SpeedDialButton>.from(buttons);
      
      if (oldIndex >= visibleButtons.length || newIndex >= visibleButtons.length) {
        debugPrint('Invalid index: oldIndex=$oldIndex, newIndex=$newIndex, length=${visibleButtons.length}');
        return;
      }

      final allButtonsCopy = List<SpeedDialButton>.from(_buttons);
      
      final groupButtonIndices = <int>[];
      for (int i = 0; i < allButtonsCopy.length; i++) {
        if (_selectedGroup == '전체' || allButtonsCopy[i].group == _selectedGroup) {
          groupButtonIndices.add(i);
        }
      }

      final actualOldIndex = groupButtonIndices[oldIndex];
      final actualNewIndex = groupButtonIndices[newIndex];
      
      final buttonToMove = allButtonsCopy.removeAt(actualOldIndex);
      allButtonsCopy.insert(actualNewIndex, buttonToMove);

      _buttons = allButtonsCopy;
      notifyListeners();

      _updateButtonPositionsInBackground(allButtonsCopy);
      
      debugPrint('Reorder UI updated immediately');
    } catch (e) {
      _error = '순서 변경 중 오류가 발생했습니다: $e';
      debugPrint(_error);
      notifyListeners();
    }
  }

  // 백그라운드 DB 업데이트
  Future<void> _updateButtonPositionsInBackground(List<SpeedDialButton> buttons) async {
    try {
      for (int i = 0; i < buttons.length; i++) {
        final updatedButton = buttons[i].copyWith(position: i);
        await _databaseService.updateButton(updatedButton);
        _buttons[i] = updatedButton;
      }
      
      // 🆕 위젯 데이터 업데이트
      await _updateAllWidgetsData();
      
      debugPrint('Background DB update completed');
    } catch (e) {
      debugPrint('Background DB update error: $e');
      await loadButtons();
    }
  }

  // 에러 초기화
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // 그룹별 버튼 개수
  Future<Map<String, int>> getGroupCounts() async {
    final counts = <String, int>{};
    
    for (var group in _groups) {
      if (group == '전체') {
        counts[group] = _buttons.length;
      } else {
        counts[group] = _buttons.where((b) => b.group == group).length;
      }
    }
    
    return counts;
  }

  // 사용자 정의 그룹 추가
  void addCustomGroup(String groupName) {
    if (!_groups.contains(groupName)) {
      _groups.add(groupName);
      notifyListeners();
    }
  }

  // 그룹 이름 변경
  Future<bool> renameGroup(String oldName, String newName) async {
    try {
      final defaultGroups = ['전체', '일반', '가족', '긴급', '직장', '친구'];
      if (defaultGroups.contains(oldName)) {
        _error = '기본 그룹은 이름을 변경할 수 없습니다';
        notifyListeners();
        return false;
      }

      if (_groups.contains(newName)) {
        _error = '이미 존재하는 그룹 이름입니다';
        notifyListeners();
        return false;
      }

      final count = await _databaseService.renameGroup(oldName, newName);
      
      if (count > 0) {
        await loadGroups();
        await loadButtons();
        
        if (_selectedGroup == oldName) {
          _selectedGroup = newName;
        }
        
        return true;
      }
      
      return false;
    } catch (e) {
      _error = '그룹 이름 변경 중 오류가 발생했습니다: $e';
      debugPrint(_error);
      notifyListeners();
      return false;
    }
  }

  // 그룹 삭제
  Future<bool> deleteGroup(String groupName) async {
    try {
      final defaultGroups = ['전체', '일반', '가족', '긴급', '직장', '친구'];
      if (defaultGroups.contains(groupName)) {
        _error = '기본 그룹은 삭제할 수 없습니다';
        notifyListeners();
        return false;
      }

      if (groupName == '전체') {
        _error = '전체 그룹은 삭제할 수 없습니다';
        notifyListeners();
        return false;
      }

      final count = await _databaseService.deleteButtonsByGroup(groupName);
      
      if (count >= 0) {
        await loadGroups();
        await loadButtons();
        
        if (_selectedGroup == groupName) {
          _selectedGroup = '전체';
        }
        
        return true;
      }
      
      return false;
    } catch (e) {
      _error = '그룹 삭제 중 오류가 발생했습니다: $e';
      debugPrint(_error);
      notifyListeners();
      return false;
    }
  }

  // 기본 그룹 확인
  bool isDefaultGroup(String groupName) {
    final defaultGroups = ['전체', '일반', '가족', '긴급', '직장', '친구'];
    return defaultGroups.contains(groupName);
  }

  // 🆕 위젯 관련 추가 메서드들

  /// 설치된 위젯 ID 목록 가져오기
  Future<List<int>> getInstalledWidgetIds() async {
    try {
      return await _widgetService.getWidgetIds();
    } catch (e) {
      debugPrint('위젯 ID 조회 오류: $e');
      return [];
    }
  }

  /// 특정 위젯의 데이터 가져오기
  Future<List<SpeedDialButton>?> getWidgetButtons(int widgetId) async {
    try {
      final jsonData = await _widgetService.getWidgetData(widgetId);
      if (jsonData == null || jsonData.isEmpty) return null;

      // JSON 파싱하여 버튼 목록 반환
      final List<dynamic> jsonList = jsonDecode(jsonData);
      return jsonList.map((json) {
        final id = json['id'] as int;
        return _buttons.firstWhere((b) => b.id == id);
      }).toList();
    } catch (e) {
      debugPrint('위젯 버튼 조회 오류: $e');
      return null;
    }
  }

  /// 특정 위젯의 버튼 업데이트
  Future<bool> updateSpecificWidget(int widgetId, List<SpeedDialButton> buttons) async {
    try {
      return await _widgetService.updateWidgetData(widgetId, buttons);
    } catch (e) {
      debugPrint('특정 위젯 업데이트 오류: $e');
      return false;
    }
  }

  /// 모든 위젯 새로고침
  Future<void> refreshAllWidgets() async {
    try {
      await _updateAllWidgetsData();
    } catch (e) {
      debugPrint('모든 위젯 새로고침 오류: $e');
    }
  }

  /// 위젯 설치 여부 확인
  Future<bool> hasInstalledWidgets() async {
    try {
      return await _widgetService.hasWidgets();
    } catch (e) {
      debugPrint('위젯 확인 오류: $e');
      return false;
    }
  }

  /// 모든 위젯 데이터 삭제
  Future<void> clearAllWidgetData() async {
    try {
      await _widgetService.clearAllWidgets();
    } catch (e) {
      debugPrint('위젯 데이터 삭제 오류: $e');
    }
  }
}