import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:quick_call/providers/speed_dial_provider.dart';
import 'package:quick_call/providers/settings_provider.dart';
import 'package:quick_call/widgets/dial_button_widget.dart';
import 'package:quick_call/widgets/loading_widget.dart';
import 'package:quick_call/widgets/empty_state_widget.dart';
import 'package:quick_call/widgets/group_edit_dialog.dart';
import 'package:quick_call/screens/add_button_screen.dart';
import 'package:quick_call/screens/edit_button_screen.dart';
import 'package:quick_call/screens/settings_screen.dart';
import 'package:quick_call/models/speed_dial_button.dart';
import 'package:quick_call/utils/sort_options.dart';
import 'package:reorderable_grid_view/reorderable_grid_view.dart';
import 'dart:ui';
import 'dart:async';

/// 가장자리 방향
enum EdgeSide { left, right, none }

/// 점선 테두리를 그리는 CustomPainter
class DashedBorderPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double gap;
  final double dashWidth;
  final double borderRadius;

  DashedBorderPainter({
    this.color = Colors.grey,
    this.strokeWidth = 2,
    this.gap = 5,
    this.dashWidth = 5,
    this.borderRadius = 16,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final path = Path()
      ..addRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.width, size.height),
        Radius.circular(borderRadius),
      ));

    // 점선으로 그리기
    final dashPath = Path();
    for (final metric in path.computeMetrics()) {
      double distance = 0;
      while (distance < metric.length) {
        dashPath.addPath(
          metric.extractPath(distance, distance + dashWidth),
          Offset.zero,
        );
        distance += dashWidth + gap;
      }
    }

    canvas.drawPath(dashPath, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  SpeedDialButton? _deletedButton; // Undo를 위한 삭제된 버튼 임시 저장
  
  // 검색 관련
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  // 드래그 & 가장자리 감지 관련
  bool _isDragging = false;
  Offset? _dragStartPosition;
  Timer? _edgeTimer;
  EdgeSide _currentEdge = EdgeSide.none;
  SpeedDialButton? _draggedButton; // 드래그 중인 버튼 객체
  String? _pendingTargetGroup; // 이동 대기 중인 타겟 그룹
  static const double _edgeThreshold = 50.0; // 가장자리 감지 영역 (픽셀)
  static const double _dragThreshold = 20.0; // 드래그 시작 판단 거리
  static const Duration _edgeHoldDuration = Duration(seconds: 1); // 가장자리 유지 시간

  // 가장자리 시각적 피드백
  bool _showLeftEdgeIndicator = false;
  bool _showRightEdgeIndicator = false;

  @override
  void initState() {
    super.initState();
    final provider = context.read<SpeedDialProvider>();
    _tabController = TabController(
      length: provider.groups.length,
      vsync: this,
    );
    
    // 탭 변경 감지
    _tabController.addListener(_onTabChanged);

    // 검색어 변경 리스너
    _searchController.addListener(() {
      context.read<SpeedDialProvider>().setSearchQuery(_searchController.text);
    });
  }

  // 탭 변경 리스너 분리
  void _onTabChanged() {
    if (!_tabController.indexIsChanging) {
      final provider = context.read<SpeedDialProvider>();
      if (_tabController.index < provider.groups.length) {
        provider.selectGroup(provider.groups[_tabController.index]);
      }
    }
  }

  @override
  void dispose() {
    _edgeTimer?.cancel();
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  // TabController 재생성 (그룹 변경 시)
  void _recreateTabController(SpeedDialProvider provider) {
    final currentIndex = provider.groups.indexOf(provider.selectedGroup).clamp(0, provider.groups.length - 1);
    
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    
    _tabController = TabController(
      length: provider.groups.length,
      vsync: this,
      initialIndex: currentIndex,
    );
    
    _tabController.addListener(_onTabChanged);
  }

  // 포인터 다운 처리
  void _onPointerDown(PointerDownEvent event) {
    _dragStartPosition = event.position;
    _isDragging = false;
  }

  // 포인터 이동 처리
  void _onPointerMove(PointerMoveEvent event, SpeedDialProvider provider) {
    if (_dragStartPosition == null) return;

    // 드래그 시작 판단
    final distance = (event.position - _dragStartPosition!).distance;
    if (!_isDragging && distance > _dragThreshold) {
      _isDragging = true;
    }

    // 드래그 중일 때만 가장자리 감지
    if (_isDragging && provider.isEditMode && _draggedButton != null) {
      final screenWidth = MediaQuery.of(context).size.width;
      final x = event.position.dx;

      EdgeSide newEdge = EdgeSide.none;

      if (x < _edgeThreshold) {
        newEdge = EdgeSide.left;
      } else if (x > screenWidth - _edgeThreshold) {
        newEdge = EdgeSide.right;
      }

      // 가장자리 상태 변경
      if (newEdge != _currentEdge) {
        _cancelEdgeTimer();
        _currentEdge = newEdge;

        if (newEdge != EdgeSide.none) {
          _startEdgeTimer(provider, newEdge);
          setState(() {
            _showLeftEdgeIndicator = newEdge == EdgeSide.left;
            _showRightEdgeIndicator = newEdge == EdgeSide.right;
          });
        } else {
          setState(() {
            _showLeftEdgeIndicator = false;
            _showRightEdgeIndicator = false;
          });
        }
      }
    }
  }

  // 포인터 업 처리
  void _onPointerUp(PointerUpEvent event) {
    // 드래그 종료 시 대기 중인 그룹 이동이 있으면 처리
    if (_pendingTargetGroup != null && _draggedButton != null) {
      final targetGroup = _pendingTargetGroup!;
      final buttonToMove = _draggedButton!;
      
      // 상태 먼저 초기화
      _resetDragState();
      
      // 다음 프레임에서 이동 처리 (드래그가 완전히 끝난 후)
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _showMoveConfirmDialog(buttonToMove, targetGroup);
        }
      });
    } else {
      _resetDragState();
    }
  }

  // 포인터 취소 처리
  void _onPointerCancel(PointerCancelEvent event) {
    _resetDragState();
  }

  // 드래그 상태 초기화
  void _resetDragState() {
    _isDragging = false;
    _dragStartPosition = null;
    _draggedButton = null;
    _pendingTargetGroup = null;
    _cancelEdgeTimer();
    _currentEdge = EdgeSide.none;
    if (mounted) {
      setState(() {
        _showLeftEdgeIndicator = false;
        _showRightEdgeIndicator = false;
      });
    }
  }

  // 가장자리 타이머 시작
  void _startEdgeTimer(SpeedDialProvider provider, EdgeSide edge) {
    _edgeTimer = Timer(_edgeHoldDuration, () {
      if (mounted) {
        _prepareGroupMove(provider, edge);
      }
    });
  }

  // 가장자리 타이머 취소
  void _cancelEdgeTimer() {
    _edgeTimer?.cancel();
    _edgeTimer = null;
  }

  // 그룹 이동 준비 (실제 이동은 드래그 종료 시)
  void _prepareGroupMove(SpeedDialProvider provider, EdgeSide edge) {
    final currentIndex = _tabController.index;
    final groups = provider.groups;
    int targetIndex;

    if (edge == EdgeSide.left) {
      targetIndex = currentIndex - 1;
    } else {
      targetIndex = currentIndex + 1;
    }

    // 범위 체크
    if (targetIndex < 0 || targetIndex >= groups.length) {
      _showSnackBar('이동할 수 있는 그룹이 없습니다', Colors.orange[700]!);
      setState(() {
        _showLeftEdgeIndicator = false;
        _showRightEdgeIndicator = false;
      });
      return;
    }

    final targetGroup = groups[targetIndex];

    // "전체" 그룹으로는 이동 불가
    if (targetGroup == '전체') {
      _showSnackBar('"전체" 그룹으로는 이동할 수 없습니다', Colors.orange[700]!);
      setState(() {
        _showLeftEdgeIndicator = false;
        _showRightEdgeIndicator = false;
      });
      return;
    }

    // 타겟 그룹 저장 (드래그 종료 시 처리)
    _pendingTargetGroup = targetGroup;
    
    // 시각적 피드백
    setState(() {
      _showLeftEdgeIndicator = false;
      _showRightEdgeIndicator = false;
    });
    
    _showSnackBar(
      '손을 떼면 "$targetGroup" 그룹으로 이동합니다',
      Colors.blue[700]!,
    );
  }

  // 이동 확인 다이얼로그
  Future<void> _showMoveConfirmDialog(SpeedDialButton button, String targetGroup) async {
    final provider = context.read<SpeedDialProvider>();
    
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.r),
          ),
          title: Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.drive_file_move,
                  color: Colors.blue[600],
                  size: 24.sp,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Text(
                  '그룹 이동',
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          content: Text(
            '"${button.name}"을(를)\n"$targetGroup" 그룹으로 이동하시겠습니까?',
            style: TextStyle(
              fontSize: 16.sp,
              color: Colors.grey[700],
              height: 1.5,
            ),
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
                backgroundColor: Colors.blue[600],
              ),
              child: Text(
                '이동',
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

    if (confirmed == true && mounted) {
      final success = await provider.moveButtonToGroup(button, targetGroup);
      
      if (success) {
        // 타겟 그룹으로 탭 전환
        final targetIndex = provider.groups.indexOf(targetGroup);
        if (targetIndex != -1) {
          _tabController.animateTo(targetIndex);
          provider.selectGroup(targetGroup);
        }
        
        _showSnackBar(
          '"${button.name}"을(를) "$targetGroup" 그룹으로 이동했습니다',
          Colors.green[700]!,
        );
      } else {
        _showSnackBar(
          provider.error ?? '버튼 이동에 실패했습니다',
          Colors.red[700]!,
        );
      }
    }
  }

  // 블러 효과와 함께 다이얼로그 열기
  // initialGroup 파라미터 추가: 현재 선택된 그룹을 AddButtonScreen에 전달
  Future<void> _showAddButtonDialog({String? initialGroup}) async {
    await showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      barrierColor: Colors.transparent,
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) {
        return AddButtonScreen(initialGroup: initialGroup);
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: 5 * animation.value,
            sigmaY: 5 * animation.value,
          ),
          child: FadeTransition(
            opacity: animation,
            child: child,
          ),
        );
      },
    );
  }

  // 그룹 편집 바텀시트 표시
  Future<void> _showGroupEditBottomSheet(
    BuildContext context,
    SpeedDialProvider provider,
    String groupName,
  ) async {
    // "전체" 그룹은 편집 불가
    if (groupName == '전체') {
      return;
    }

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return GroupEditDialog(
          groupName: groupName,
          onCancel: () {
            Navigator.pop(sheetContext);
          },
          onConfirm: (newName) async {
            Navigator.pop(sheetContext);
            
            if (newName.isEmpty) {
              _showSnackBar('그룹 이름을 입력해주세요', Colors.orange[700]!);
              return;
            }
            
            if (newName == groupName) {
              return;
            }
            
            final success = await provider.renameGroup(groupName, newName);
            
            if (!mounted) return;
            
            _showSnackBar(
              success
                  ? '그룹 이름이 "$newName"(으)로 변경되었습니다'
                  : provider.error ?? '그룹 이름 변경에 실패했습니다',
              success ? Colors.green[700]! : Colors.red[700]!,
            );
          },
          onDelete: () {
            Navigator.pop(sheetContext);
            _showDeleteGroupConfirmDialog(context, provider, groupName);
          },
        );
      },
    );
  }

  // 그룹 추가 다이얼로그 (DB에 저장) - 🆕 오버플로우 수정
Future<void> _showAddGroupDialog(
    BuildContext context,
    SpeedDialProvider provider,
  ) async {
    final textController = TextEditingController();

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true, // 키보드에 따라 높이 자동 조정
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return Padding(
          // 🆕 키보드 높이만큼 자동으로 padding 추가
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(sheetContext).viewInsets.bottom,
          ),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(24.r),
              ),
            ),
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
            child: SafeArea(
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

                  // 타이틀 + 아이콘
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(8.w),
                        decoration: BoxDecoration(
                          color: Colors.blue[50],
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.create_new_folder,
                          color: Colors.blue[600],
                          size: 24.sp,
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Text(
                        '새 그룹 만들기',
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
                    controller: textController,
                    autofocus: true,
                    maxLength: 10,
                    decoration: InputDecoration(
                      labelText: '그룹 이름',
                      hintText: '새 그룹 이름을 입력하세요',
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
                      prefixIcon: Icon(
                        Icons.folder_outlined,
                        color: Colors.grey[600],
                      ),
                      counterStyle: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.grey[600],
                      ),
                    ),
                    style: TextStyle(
                      fontSize: 16.sp,
                      color: Colors.black87,
                    ),
                  ),

                  SizedBox(height: 20.h),

                  // 하단 버튼들
                  Row(
                    children: [
                      // 취소 버튼
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(sheetContext),
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
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[700],
                            ),
                          ),
                        ),
                      ),

                      SizedBox(width: 12.w),

                      // 만들기 버튼
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () async {
                            final groupName = textController.text.trim();

                            if (groupName.isEmpty) {
                              Navigator.pop(sheetContext);
                              _showSnackBar('그룹 이름을 입력해주세요', Colors.orange[700]!);
                              return;
                            }

                            // 중복 그룹명 체크
                            if (provider.groups.contains(groupName)) {
                              Navigator.pop(sheetContext);
                              _showSnackBar('이미 존재하는 그룹 이름입니다', Colors.orange[700]!);
                              return;
                            }

                            Navigator.pop(sheetContext);

                            // 그룹 추가 (DB에 저장)
                            final success = await provider.addCustomGroup(groupName);
                            
                            if (success) {
                              _showSnackBar('"$groupName" 그룹이 생성되었습니다', Colors.green[700]!);
                              
                              // 새로 생성된 그룹으로 이동
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                final newIndex = provider.groups.indexOf(groupName);
                                if (newIndex != -1 && mounted) {
                                  _tabController.animateTo(newIndex);
                                  provider.selectGroup(groupName);
                                }
                              });
                            } else {
                              _showSnackBar('그룹 생성에 실패했습니다', Colors.red[700]!);
                            }
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
                            '만들기',
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
                ],
              ),
            ),
          ),
        );
      },
    );
  }
  // 그룹 삭제 확인 다이얼로그
  Future<void> _showDeleteGroupConfirmDialog(
    BuildContext context,
    SpeedDialProvider provider,
    String groupName,
  ) async {
    final buttonCount = provider.buttons.where((b) => b.group == groupName).length;
    
    await showDialog(
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
                  Icons.warning_amber_rounded,
                  size: 40.sp,
                  color: Colors.red[700],
                ),
              ),
              SizedBox(height: 16.h),
              Text(
                '그룹 삭제 확인',
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: Text(
            '"$groupName" 그룹을 삭제하시겠습니까?\n\n'
            '이 그룹에 속한 버튼 $buttonCount개가 모두 삭제됩니다.\n'
            '삭제된 버튼은 복구할 수 없습니다.',
            style: TextStyle(
              fontSize: 16.sp,
              color: Colors.grey[700],
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(
                '취소',
                style: TextStyle(
                  fontSize: 16.sp,
                  color: Colors.grey[600],
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(dialogContext);
                
                final success = await provider.deleteGroup(groupName);
                
                if (!mounted) return;
                
                _showSnackBar(
                  success
                      ? '"$groupName" 그룹이 삭제되었습니다 (버튼 $buttonCount개 삭제됨)'
                      : provider.error ?? '그룹 삭제에 실패했습니다',
                  success ? Colors.orange[700]! : Colors.red[700]!,
                );
              },
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
  }

  // SnackBar 헬퍼 메서드
  void _showSnackBar(String message, Color backgroundColor) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: TextStyle(fontSize: 16.sp),
        ),
        backgroundColor: backgroundColor,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<SpeedDialProvider, SettingsProvider>(
      builder: (context, provider, settings, child) {
        // TabController 길이 업데이트 (그룹이 추가/삭제될 때)
        if (_tabController.length != provider.groups.length) {
          // 다음 프레임에서 TabController 재생성
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              setState(() {
                _recreateTabController(provider);
              });
            }
          });
        }

        return Scaffold(
          backgroundColor: Colors.grey[100],
          appBar: AppBar(
            elevation: 0,
            backgroundColor: Colors.white,
            centerTitle: false,
            titleSpacing: 16.w,
            // 검색 모드에 따라 다른 타이틀 표시
            title: provider.isSearching
                ? TextField(
                    controller: _searchController,
                    focusNode: _searchFocusNode,
                    autofocus: true,
                    decoration: InputDecoration(
                      hintText: '이름 또는 전화번호 검색',
                      border: InputBorder.none,
                      hintStyle: TextStyle(color: Colors.grey[400]),
                    ),
                    style: const TextStyle(
                      color: Colors.black87,
                      fontSize: 18,
                    ),
                  )
                : Text(
                    '단축키',
                    style: TextStyle(
                      color: Colors.black87,
                      fontWeight: FontWeight.bold,
                      fontSize: 20.sp,
                    ),
                  ),
            actions: [
              // 검색 버튼
              if (!provider.isEditMode)
                IconButton(
                  icon: Icon(
                    provider.isSearching ? Icons.close : Icons.search,
                    color: Colors.black87,
                  ),
                  onPressed: () {
                    provider.toggleSearchMode();
                    if (!provider.isSearching) {
                      _searchController.clear();
                    }
                  },
                ),
              
              // 정렬 버튼 (검색 중이 아니고 편집 모드가 아닐 때만)
              if (!provider.isSearching && !provider.isEditMode)
                PopupMenuButton<SortOption>(
                  icon: const Icon(Icons.sort, color: Colors.black87),
                  onSelected: (option) {
                    provider.setSortOption(option);
                    settings.setSortOption(option);
                  },
                  itemBuilder: (context) {
                    return SortOption.values.map((option) {
                      final isSelected = provider.currentSortOption == option;
                      return PopupMenuItem<SortOption>(
                        value: option,
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    option.displayName,
                                    style: TextStyle(
                                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                    ),
                                  ),
                                  Text(
                                    option.description,
                                    style: TextStyle(
                                      fontSize: 11.sp,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (isSelected)
                              Icon(Icons.check, color: Colors.blue[700], size: 20.sp),
                          ],
                        ),
                      );
                    }).toList();
                  },
                ),
              
              // 설정 버튼
              if (!provider.isSearching && !provider.isEditMode)
                IconButton(
                  icon: const Icon(Icons.settings, color: Colors.black87),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SettingsScreen(),
                      ),
                    );
                  },
                ),
              
              // 편집/완료 버튼
              if (!provider.isSearching)
                TextButton(
                  onPressed: () {
                    provider.toggleEditMode();
                  },
                  child: Text(
                    provider.isEditMode ? '완료' : '편집',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: provider.isEditMode ? Colors.green[600] : Colors.blue[600],
                    ),
                  ),
                ),
            ],
            bottom: provider.isSearching
                ? null
                : TabBar(
                    controller: _tabController,
                    isScrollable: true,
                    tabAlignment: TabAlignment.start,
                    indicatorColor: Colors.blue[600],
                    indicatorWeight: 3,
                    labelColor: Colors.blue[600],
                    unselectedLabelColor: Colors.grey[600],
                    labelStyle: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w600,
                    ),
                    unselectedLabelStyle: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w500,
                    ),
                    // 탭 클릭 감지 - 같은 탭 재클릭 시 그룹 편집 (일반/편집 모드 모두)
                    onTap: (index) {
                      final clickedGroup = provider.groups[index];
                      
                      // 현재 선택된 그룹과 클릭된 그룹이 같으면 그룹 편집 바텀시트 표시
                      // "전체" 그룹은 편집 불가
                      if (provider.selectedGroup == clickedGroup && 
                          clickedGroup != '전체') {
                        _showGroupEditBottomSheet(context, provider, clickedGroup);
                      }
                    },
                    // 편집 모드에서도 일반 탭으로 표시 (수정/X 버튼 제거)
                    tabs: provider.groups.map((group) {
                      return Tab(text: group);
                    }).toList(),
                  ),
          ),
          body: _buildBody(context, provider),
          floatingActionButton: !provider.isEditMode && !provider.isSearching
              ? FloatingActionButton(
                  onPressed: () => _showAddGroupDialog(context, provider),
                  backgroundColor: Colors.blue[600],
                  child: const Icon(Icons.create_new_folder, size: 28, color: Colors.white),
                )
              : null,
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, SpeedDialProvider provider) {
    // 로딩 중
    if (provider.isLoading) {
      return const LoadingWidget(
        message: '단축번호를 불러오는 중...',
        longLoadingMessage: '잠시만 기다려주세요...',
      );
    }

    // 에러 발생
    if (provider.error != null) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(24.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64.sp,
                color: Colors.red,
              ),
              SizedBox(height: 16.h),
              Text(
                provider.error!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16.sp,
                  color: Colors.red,
                ),
              ),
              SizedBox(height: 16.h),
              ElevatedButton(
                onPressed: () {
                  provider.clearError();
                  provider.initialize();
                },
                child: const Text('다시 시도'),
              ),
            ],
          ),
        ),
      );
    }

    // 검색 모드: 스와이프 없이 단일 그리드
    if (provider.isSearching) {
      return _buildSearchResultGrid(context, provider);
    }

    // 일반/편집 모드: TabBarView로 스와이프 지원
    return TabBarView(
      controller: _tabController,
      // 모든 모드에서 스와이프 탭 전환 활성화
      physics: const ClampingScrollPhysics(),
      children: provider.groups.map((group) {
        return _buildGroupPage(context, provider, group);
      }).toList(),
    );
  }

  // 검색 결과 그리드 (스와이프 없음)
  Widget _buildSearchResultGrid(BuildContext context, SpeedDialProvider provider) {
    final searchButtons = provider.buttons;

    // 검색 결과 없음
    if (searchButtons.isEmpty && provider.searchQuery.isNotEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(32.w),
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
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                '"${provider.searchQuery}"',
                style: TextStyle(
                  fontSize: 16.sp,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    // 버튼이 없는 경우
    if (searchButtons.isEmpty) {
      return NoSpeedDialsWidget(
        groupName: provider.selectedGroup,
        onAddPressed: () => _showAddButtonDialog(),
      );
    }

    return RefreshIndicator(
      onRefresh: () => provider.loadButtons(),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: GridView.builder(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.only(bottom: 100.h),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            childAspectRatio: 1.0, // 🆕 정사각형으로 변경
            crossAxisSpacing: 12.w,
            mainAxisSpacing: 12.h,
          ),
          itemCount: searchButtons.length,
          itemBuilder: (context, index) {
            final button = searchButtons[index];
            return DialButtonWidget(
              button: button,
              isEditMode: false,
              onTap: () => _handleButtonTap(context, provider, button),
              onLongPress: () => _handleButtonLongPress(context, provider, button),
              onDelete: () => _handleDelete(context, provider, button, index),
            );
          },
        ),
      ),
    );
  }

  // 그룹별 페이지 (TabBarView의 각 페이지)
  Widget _buildGroupPage(BuildContext context, SpeedDialProvider provider, String group) {
    final groupButtons = provider.getButtonsForGroup(group);

    // 버튼이 없는 경우
    if (groupButtons.isEmpty) {
      return NoSpeedDialsWidget(
        groupName: group,
        // 현재 그룹 정보 전달
        onAddPressed: () => _showAddButtonDialog(initialGroup: group),
      );
    }

    // 편집 모드: 드래그 앤 드롭 그리드 (+ 버튼 없음)
    if (provider.isEditMode) {
      return _buildReorderableGrid(context, provider, groupButtons);
    }

    // 일반 모드: 기본 그리드 (애니메이션 + 마지막에 + 버튼 포함)
    return _buildNormalGrid(context, provider, groupButtons, group);
  }

  // 일반 모드 그리드 (애니메이션 포함)
  Widget _buildNormalGrid(
    BuildContext context, 
    SpeedDialProvider provider, 
    List<SpeedDialButton> groupButtons,
    String group,
  ) {
    // 일반 모드에서는 + 버튼 추가
    final itemCount = groupButtons.length + 1;

    return RefreshIndicator(
      onRefresh: () => provider.loadButtons(),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          switchInCurve: Curves.easeInOut,
          switchOutCurve: Curves.easeInOut,
          child: GridView.builder(
            key: ValueKey('normal_${group}_${groupButtons.length}_${provider.searchQuery}_${provider.currentSortOption}'),
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.only(bottom: 100.h),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 1.0, // 🆕 정사각형으로 변경
              crossAxisSpacing: 12.w,
              mainAxisSpacing: 12.h,
            ),
            itemCount: itemCount,
            itemBuilder: (context, index) {
              // 마지막 아이템은 + 버튼
              if (index == groupButtons.length) {
                // 현재 그룹 정보 전달
                return _buildAddButtonPlaceholder(group);
              }

              final button = groupButtons[index];
              return TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: Duration(milliseconds: 300 + (index * 50)),
                curve: Curves.easeOutBack,
                builder: (context, value, child) {
                  return Transform.scale(
                    scale: value,
                    child: Opacity(
                      opacity: value.clamp(0.0, 1.0),
                      child: child,
                    ),
                  );
                },
                child: DialButtonWidget(
                  button: button,
                  isEditMode: false,
                  onTap: () => _handleButtonTap(context, provider, button),
                  onLongPress: () => _handleButtonLongPress(context, provider, button),
                  onDelete: () => _handleDelete(context, provider, button, index),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  // 점선 테두리의 + 버튼 (단축키 추가용)
  // group 파라미터 추가: 현재 그룹 정보를 AddButtonScreen에 전달
  Widget _buildAddButtonPlaceholder(String group) {
    return GestureDetector(
      onTap: () => _showAddButtonDialog(initialGroup: group),
      child: CustomPaint(
        painter: DashedBorderPainter(
          color: Colors.grey[400]!,
          strokeWidth: 2,
          gap: 6,
          dashWidth: 6,
          borderRadius: 16.r,
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.r),
            color: Colors.grey[50],
          ),
          child: Center(
            child: Icon(
              Icons.add,
              size: 40.sp,
              color: Colors.grey[400],
            ),
          ),
        ),
      ),
    );
  }

  // 편집 모드 그리드 (드래그 앤 드롭 + 가장자리 감지)
  Widget _buildReorderableGrid(
    BuildContext context, 
    SpeedDialProvider provider,
    List<SpeedDialButton> groupButtons,
  ) {
    return Stack(
      children: [
        // 메인 그리드
        Listener(
          onPointerDown: _onPointerDown,
          onPointerMove: (event) => _onPointerMove(event, provider),
          onPointerUp: _onPointerUp,
          onPointerCancel: _onPointerCancel,
          child: RefreshIndicator(
            onRefresh: () => provider.loadButtons(),
            child: Padding(
              padding: EdgeInsets.fromLTRB(24.w, 24.h, 24.w, 16.h),
              child: ReorderableGridView.builder(
                clipBehavior: Clip.none,
                key: ValueKey('reorderable_${provider.selectedGroup}_${groupButtons.length}'),
                padding: EdgeInsets.only(bottom: 100.h),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 1.0, // 🆕 정사각형으로 변경
                  crossAxisSpacing: 20.w,
                  mainAxisSpacing: 20.h,
                ),
                itemCount: groupButtons.length,
                onReorder: (oldIndex, newIndex) {
                  // 인덱스 유효성 검사
                  if (oldIndex < 0 || oldIndex >= groupButtons.length ||
                      newIndex < 0 || newIndex >= groupButtons.length) {
                    debugPrint('Invalid reorder index: old=$oldIndex, new=$newIndex, length=${groupButtons.length}');
                    return;
                  }
                  provider.reorderButtons(oldIndex, newIndex);
                },
                dragWidgetBuilder: (index, child) {
                  // 드래그 시작 시 버튼 객체 저장
                  if (index >= 0 && index < groupButtons.length) {
                    _draggedButton = groupButtons[index];
                  }
                  return Material(
                    elevation: 8,
                    borderRadius: BorderRadius.circular(16.r),
                    child: Opacity(
                      opacity: 0.8,
                      child: child,
                    ),
                  );
                },
                itemBuilder: (context, index) {
                  final button = groupButtons[index];
                  return DialButtonWidget(
                    key: ValueKey(button.id),
                    button: button,
                    isEditMode: true,
                    onTap: () => _handleButtonTap(context, provider, button),
                    onLongPress: () => _handleButtonLongPress(context, provider, button),
                    onDelete: () => _handleDelete(context, provider, button, index),
                  );
                },
              ),
            ),
          ),
        ),

        // 왼쪽 가장자리 인디케이터
        if (_showLeftEdgeIndicator)
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            child: _buildEdgeIndicator(EdgeSide.left, provider),
          ),

        // 오른쪽 가장자리 인디케이터
        if (_showRightEdgeIndicator)
          Positioned(
            right: 0,
            top: 0,
            bottom: 0,
            child: _buildEdgeIndicator(EdgeSide.right, provider),
          ),
      ],
    );
  }

  // 가장자리 인디케이터 위젯
  Widget _buildEdgeIndicator(EdgeSide side, SpeedDialProvider provider) {
    final currentIndex = _tabController.index;
    final groups = provider.groups;
    
    int targetIndex = side == EdgeSide.left ? currentIndex - 1 : currentIndex + 1;
    
    // 범위 체크 및 "전체" 그룹 체크
    bool canMove = targetIndex >= 0 && 
                   targetIndex < groups.length && 
                   groups[targetIndex] != '전체';

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: _edgeThreshold,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: side == EdgeSide.left ? Alignment.centerLeft : Alignment.centerRight,
          end: side == EdgeSide.left ? Alignment.centerRight : Alignment.centerLeft,
          colors: [
            canMove 
                ? Colors.blue.withValues(alpha: 0.3)
                : Colors.red.withValues(alpha: 0.3),
            Colors.transparent,
          ],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              side == EdgeSide.left 
                  ? Icons.chevron_left 
                  : Icons.chevron_right,
              color: canMove ? Colors.blue[700] : Colors.red[700],
              size: 32.sp,
            ),
            SizedBox(height: 8.h),
            Text(
              canMove 
                  ? groups[targetIndex]
                  : '이동 불가',
              style: TextStyle(
                fontSize: 12.sp,
                color: canMove ? Colors.blue[700] : Colors.red[700],
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            if (canMove) ...[
              SizedBox(height: 4.h),
              SizedBox(
                width: 40.w,
                height: 2.h,
                child: LinearProgressIndicator(
                  backgroundColor: Colors.blue[200],
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.blue[700]!),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // 버튼 탭 처리 (모든 모드에서 편집 화면 열기)
  Future<void> _handleButtonTap(
    BuildContext context,
    SpeedDialProvider provider,
    SpeedDialButton button,
  ) async {
    // 모든 모드에서 편집 화면으로 이동
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditButtonScreen(button: button),
      ),
    );
  }

  // 버튼 롱프레스 처리 (일반 모드 전용 - 전화 걸기)
  Future<void> _handleButtonLongPress(
    BuildContext context,
    SpeedDialProvider provider,
    SpeedDialButton button,
  ) async {
    if (!provider.isEditMode) {
      // 일반 모드: 전화 걸기
      final scaffoldMessenger = ScaffoldMessenger.of(context);

      try {
        final success = await provider.makeCall(button);

        if (!mounted) return;

        if (!success) {
          scaffoldMessenger.showSnackBar(
            SnackBar(
              content: Text(
                provider.error ?? '전화를 걸 수 없습니다',
                style: TextStyle(fontSize: 16.sp),
              ),
              backgroundColor: Colors.red[700],
              duration: const Duration(seconds: 3),
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
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  // 삭제 처리 - Undo 기능 포함
  void _handleDelete(
    BuildContext context,
    SpeedDialProvider provider,
    SpeedDialButton button,
    int index,
  ) {
    showDialog(
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
            '${button.name} (${button.phoneNumber})\n\n삭제 후 바로 취소할 수 있습니다.',
            style: TextStyle(
              fontSize: 16.sp,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(
                '취소',
                style: TextStyle(
                  fontSize: 16.sp,
                  color: Colors.grey[600],
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(dialogContext);
                
                final scaffoldMessenger = ScaffoldMessenger.of(context);

                if (button.id != null) {
                  _deletedButton = button;
                  
                  final success = await provider.deleteButton(button.id!);

                  if (!mounted) return;

                  if (success) {
                    scaffoldMessenger.showSnackBar(
                      SnackBar(
                        content: Row(
                          children: [
                            Icon(
                              Icons.check_circle,
                              color: Colors.white,
                              size: 20.sp,
                            ),
                            SizedBox(width: 12.w),
                            Expanded(
                              child: Text(
                                '${button.name}이(가) 삭제되었습니다',
                                style: TextStyle(fontSize: 16.sp),
                              ),
                            ),
                          ],
                        ),
                        backgroundColor: Colors.orange[700],
                        duration: const Duration(seconds: 4),
                        action: SnackBarAction(
                          label: '실행 취소',
                          textColor: Colors.white,
                          onPressed: () => _undoDelete(provider),
                        ),
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                    );
                  } else {
                    scaffoldMessenger.showSnackBar(
                      SnackBar(
                        content: const Text('삭제에 실패했습니다'),
                        backgroundColor: Colors.red[700],
                      ),
                    );
                  }
                }
              },
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
  }

  // Undo 기능 - 삭제 취소
  Future<void> _undoDelete(SpeedDialProvider provider) async {
    if (_deletedButton != null) {
      final success = await provider.addButton(_deletedButton!);
      
      if (mounted && success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(
                  Icons.restore,
                  color: Colors.white,
                  size: 20.sp,
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Text(
                    '${_deletedButton!.name}이(가) 복원되었습니다',
                    style: TextStyle(fontSize: 16.sp),
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.green[700],
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
          ),
        );
      }
      
      _deletedButton = null;
    }
  }
}