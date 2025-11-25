import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:quick_call/providers/settings_provider.dart';
import 'package:quick_call/providers/speed_dial_provider.dart';
import 'package:quick_call/services/backup_service.dart';
import 'package:quick_call/utils/sort_options.dart';
import 'package:quick_call/services/database_service.dart';
import 'package:quick_call/screens/widget_config_screen.dart'; // 🆕 추가

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final BackupService _backupService = BackupService();
  bool _isBackingUp = false;
  bool _isRestoring = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          '설정',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Consumer<SettingsProvider>(
        builder: (context, settings, child) {
          return ListView(
            padding: EdgeInsets.symmetric(vertical: 8.h),
            children: [
              // 🆕 위젯 섹션
              _buildSectionHeader('위젯'),
              _buildWidgetConfigTile(),
              _buildWidgetRefreshTile(),
              
              SizedBox(height: 16.h),
              
              // 화면 설정
              _buildSectionHeader('화면'),
              _buildThemeModeTile(settings),
              
              SizedBox(height: 16.h),
              
              // 정렬 설정
              _buildSectionHeader('정렬'),
              _buildSortOptionTile(),
              _buildShowLastCalledTile(settings),
              
              SizedBox(height: 16.h),
              
              // 백업/복원
              _buildSectionHeader('데이터'),
              _buildAutoBackupTile(settings),
              _buildBackupTile(),
              _buildRestoreTile(),
              _buildBackupListTile(),
              
              SizedBox(height: 16.h),
              
              // 기타
              _buildSectionHeader('기타'),
              _buildDatabaseInfoTile(),
              _buildResetSettingsTile(settings),
              
              SizedBox(height: 16.h),
              
              // 앱 정보
              _buildSectionHeader('정보'),
              _buildAppInfoTile(),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: EdgeInsets.fromLTRB(24.w, 16.h, 24.w, 8.h),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14.sp,
          fontWeight: FontWeight.bold,
          color: Colors.grey[600],
        ),
      ),
    );
  }

  // 🆕 위젯 설정 타일
  Widget _buildWidgetConfigTile() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Consumer<SpeedDialProvider>(
        builder: (context, provider, child) {
          return ListTile(
            leading: Icon(Icons.widgets, color: Colors.purple[700]),
            title: const Text('위젯 버튼 설정'),
            subtitle: Text(
              '위젯에 표시할 버튼 선택 (${provider.widgetButtons.length}/4)',
              style: TextStyle(fontSize: 13.sp),
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const WidgetConfigScreen(),
                ),
              );
            },
          );
        },
      ),
    );
  }

  // 🆕 위젯 새로고침 타일
  Widget _buildWidgetRefreshTile() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: ListTile(
        leading: Icon(Icons.refresh, color: Colors.green[700]),
        title: const Text('위젯 새로고침'),
        subtitle: Text(
          '홈 화면 위젯 수동 업데이트',
          style: TextStyle(fontSize: 13.sp),
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: _refreshWidget,
      ),
    );
  }

  // 🆕 위젯 새로고침 실행
  Future<void> _refreshWidget() async {
    try {
      await context.read<SpeedDialProvider>().initialize();
      
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white, size: 20.sp),
              SizedBox(width: 12.w),
              Expanded(
                child: Text(
                  '위젯이 새로고침되었습니다',
                  style: TextStyle(fontSize: 16.sp),
                ),
              ),
            ],
          ),
          backgroundColor: Colors.green[700],
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '위젯 새로고침 실패: $e',
            style: TextStyle(fontSize: 16.sp),
          ),
          backgroundColor: Colors.red[700],
        ),
      );
    }
  }

  Widget _buildThemeModeTile(SettingsProvider settings) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: ListTile(
        leading: Icon(
          settings.isDarkMode ? Icons.dark_mode : Icons.light_mode,
          color: Colors.blue[700],
        ),
        title: const Text('다크 모드'),
        subtitle: Text(
          settings.isDarkMode ? '어두운 화면' : '밝은 화면',
          style: TextStyle(fontSize: 13.sp),
        ),
        trailing: Switch(
          value: settings.isDarkMode,
          onChanged: (value) => settings.toggleDarkMode(),
          activeThumbColor: Colors.blue[700],
        ),
      ),
    );
  }

  Widget _buildSortOptionTile() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Consumer<SpeedDialProvider>(
        builder: (context, provider, child) {
          return ListTile(
            leading: Icon(Icons.sort, color: Colors.blue[700]),
            title: const Text('기본 정렬'),
            subtitle: Text(
              provider.currentSortOption.displayName,
              style: TextStyle(fontSize: 13.sp),
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showSortOptionsDialog(provider),
          );
        },
      ),
    );
  }

  Widget _buildShowLastCalledTile(SettingsProvider settings) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: ListTile(
        leading: Icon(Icons.phone_callback, color: Colors.blue[700]),
        title: const Text('최근 통화 표시'),
        subtitle: Text(
          '마지막 통화 시간 표시',
          style: TextStyle(fontSize: 13.sp),
        ),
        trailing: Switch(
          value: settings.showLastCalled,
          onChanged: (value) => settings.setShowLastCalled(value),
          activeThumbColor: Colors.blue[700],
        ),
      ),
    );
  }

  Widget _buildAutoBackupTile(SettingsProvider settings) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: ListTile(
        leading: Icon(Icons.cloud_upload, color: Colors.blue[700]),
        title: const Text('자동 백업'),
        subtitle: Text(
          '앱 종료 시 자동으로 백업',
          style: TextStyle(fontSize: 13.sp),
        ),
        trailing: Switch(
          value: settings.autoBackupEnabled,
          onChanged: (value) => settings.setAutoBackup(value),
          activeThumbColor: Colors.blue[700],
        ),
      ),
    );
  }

  Widget _buildBackupTile() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: ListTile(
        leading: Icon(Icons.backup, color: Colors.green[700]),
        title: const Text('지금 백업하기'),
        subtitle: Text(
          '현재 데이터를 백업합니다',
          style: TextStyle(fontSize: 13.sp),
        ),
        trailing: _isBackingUp
            ? SizedBox(
                width: 20.w,
                height: 20.h,
                child: CircularProgressIndicator(strokeWidth: 2.w),
              )
            : const Icon(Icons.chevron_right),
        onTap: _isBackingUp ? null : _performBackup,
      ),
    );
  }

  Widget _buildRestoreTile() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: ListTile(
        leading: Icon(Icons.restore, color: Colors.orange[700]),
        title: const Text('백업에서 복원'),
        subtitle: Text(
          '저장된 백업에서 복원합니다',
          style: TextStyle(fontSize: 13.sp),
        ),
        trailing: _isRestoring
            ? SizedBox(
                width: 20.w,
                height: 20.h,
                child: CircularProgressIndicator(strokeWidth: 2.w),
              )
            : const Icon(Icons.chevron_right),
        onTap: _isRestoring ? null : _showRestoreDialog,
      ),
    );
  }

  Widget _buildBackupListTile() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: ListTile(
        leading: Icon(Icons.folder, color: Colors.blue[700]),
        title: const Text('백업 파일 관리'),
        subtitle: Text(
          '저장된 백업 파일을 관리합니다',
          style: TextStyle(fontSize: 13.sp),
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: _showBackupListDialog,
      ),
    );
  }

  Widget _buildDatabaseInfoTile() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Consumer<SpeedDialProvider>(
        builder: (context, provider, child) {
          return FutureBuilder<int>(
            future: DatabaseService().getButtonCount(),
            builder: (context, snapshot) {
              final count = snapshot.data ?? 0;
              final widgetCount = provider.widgetButtons.length; // 🆕
              
              return ListTile(
                leading: Icon(Icons.info_outline, color: Colors.blue[700]),
                title: const Text('데이터베이스 정보'),
                subtitle: Text(
                  '총 $count개의 단축키 • 위젯 $widgetCount/4개', // 🆕 수정
                  style: TextStyle(fontSize: 13.sp),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildResetSettingsTile(SettingsProvider settings) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: ListTile(
        leading: Icon(Icons.refresh, color: Colors.red[700]),
        title: const Text('설정 초기화'),
        subtitle: Text(
          '모든 설정을 기본값으로',
          style: TextStyle(fontSize: 13.sp),
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => _showResetConfirmDialog(settings),
      ),
    );
  }

  Widget _buildAppInfoTile() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: ListTile(
        leading: Icon(Icons.info, color: Colors.blue[700]),
        title: const Text('앱 정보'),
        subtitle: Text(
          'Quick Call v1.1.0', // 🆕 버전 업데이트 (1.0.0 → 1.1.0)
          style: TextStyle(fontSize: 13.sp),
        ),
      ),
    );
  }

  // 정렬 옵션 다이얼로그
  void _showSortOptionsDialog(SpeedDialProvider provider) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.r),
          ),
          title: Text(
            '정렬 방식 선택',
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: SortOption.values.map((option) {
              final isSelected = provider.currentSortOption == option;
              return ListTile(
                title: Text(option.displayName),
                subtitle: Text(
                  option.description,
                  style: TextStyle(fontSize: 12.sp),
                ),
                trailing: isSelected
                    ? Icon(Icons.check, color: Colors.blue[700])
                    : null,
                selected: isSelected,
                onTap: () {
                  provider.setSortOption(option);
                  Navigator.pop(dialogContext);
                  
                  // SettingsProvider에도 저장 (mounted 체크 추가)
                  if (context.mounted) {
                    context.read<SettingsProvider>().setSortOption(option);
                  }
                },
              );
            }).toList(),
          ),
        );
      },
    );
  }

  // 백업 실행
  Future<void> _performBackup() async {
    setState(() => _isBackingUp = true);

    try {
      await _backupService.createBackup();
      
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white, size: 20.sp),
              SizedBox(width: 12.w),
              Expanded(
                child: Text(
                  '백업이 완료되었습니다',
                  style: TextStyle(fontSize: 16.sp),
                ),
              ),
            ],
          ),
          backgroundColor: Colors.green[700],
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '백업 실패: $e',
            style: TextStyle(fontSize: 16.sp),
          ),
          backgroundColor: Colors.red[700],
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isBackingUp = false);
      }
    }
  }

  // 복원 다이얼로그
  Future<void> _showRestoreDialog() async {
    final backups = await _backupService.getBackupFiles();

    if (!mounted) return;

    if (backups.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '저장된 백업 파일이 없습니다',
            style: TextStyle(fontSize: 16.sp),
          ),
          backgroundColor: Colors.orange[700],
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.r),
          ),
          title: Text(
            '백업 선택',
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: backups.length,
              itemBuilder: (context, index) {
                final backup = backups[index];
                return ListTile(
                  leading: Icon(Icons.backup, color: Colors.blue[700]),
                  title: Text(backup.timestampFormatted),
                  subtitle: Text('${backup.buttonCount}개 단축키'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.pop(dialogContext);
                    _performRestore(backup.path);
                  },
                );
              },
            ),
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

  // 복원 실행
  Future<void> _performRestore(String filePath) async {
    // 확인 다이얼로그
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.r),
          ),
          title: Text(
            '복원 확인',
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            '현재 데이터가 모두 삭제되고\n백업 데이터로 대체됩니다.\n\n계속하시겠습니까?',
            style: TextStyle(fontSize: 16.sp, height: 1.5),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('취소'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange[700],
              ),
              child: const Text('복원'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    setState(() => _isRestoring = true);

    try {
      final count = await _backupService.restoreFromBackup(filePath);
      
      // 프로바이더 다시 로드
      if (!mounted) return;
      await context.read<SpeedDialProvider>().loadButtons();
      await context.read<SpeedDialProvider>().loadGroups();
      
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white, size: 20.sp),
              SizedBox(width: 12.w),
              Expanded(
                child: Text(
                  '복원 완료: $count개 단축키',
                  style: TextStyle(fontSize: 16.sp),
                ),
              ),
            ],
          ),
          backgroundColor: Colors.green[700],
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '복원 실패: $e',
            style: TextStyle(fontSize: 16.sp),
          ),
          backgroundColor: Colors.red[700],
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isRestoring = false);
      }
    }
  }

  // 백업 파일 목록 다이얼로그
  Future<void> _showBackupListDialog() async {
    final backups = await _backupService.getBackupFiles();

    if (!mounted) return;

    if (backups.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '저장된 백업 파일이 없습니다',
            style: TextStyle(fontSize: 16.sp),
          ),
          backgroundColor: Colors.orange[700],
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.r),
          ),
          title: Row(
            children: [
              Icon(Icons.folder, color: Colors.blue[700]),
              SizedBox(width: 12.w),
              Text(
                '백업 파일 관리',
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: backups.length,
              itemBuilder: (context, index) {
                final backup = backups[index];
                return Card(
                  margin: EdgeInsets.symmetric(vertical: 4.h),
                  child: ListTile(
                    leading: Icon(Icons.backup, color: Colors.blue[700]),
                    title: Text(
                      backup.timestampFormatted,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(
                      '${backup.buttonCount}개 단축키 • ${backup.fileSizeFormatted}',
                      style: TextStyle(fontSize: 12.sp),
                    ),
                    trailing: IconButton(
                      icon: Icon(Icons.delete, color: Colors.red[700]),
                      onPressed: () async {
                        final confirmed = await showDialog<bool>(
                          context: dialogContext,
                          builder: (confirmContext) {
                            return AlertDialog(
                              title: const Text('백업 파일 삭제'),
                              content: const Text('이 백업 파일을 삭제하시겠습니까?'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(confirmContext, false),
                                  child: const Text('취소'),
                                ),
                                ElevatedButton(
                                  onPressed: () => Navigator.pop(confirmContext, true),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red[700],
                                  ),
                                  child: const Text('삭제'),
                                ),
                              ],
                            );
                          },
                        );

                        if (confirmed == true) {
                          await _backupService.deleteBackup(backup.path);
                          Navigator.pop(dialogContext);
                          _showBackupListDialog(); // 다시 열기
                        }
                      },
                    ),
                  ),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('닫기'),
            ),
          ],
        );
      },
    );
  }

  // 설정 초기화 확인 다이얼로그
  Future<void> _showResetConfirmDialog(SettingsProvider settings) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.r),
          ),
          title: Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.orange[700]),
              SizedBox(width: 12.w),
              const Text('설정 초기화'),
            ],
          ),
          content: Text(
            '모든 설정을 기본값으로 되돌립니다.\n(단축키 데이터는 삭제되지 않습니다)',
            style: TextStyle(fontSize: 16.sp, height: 1.5),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('취소'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange[700],
              ),
              child: const Text('초기화'),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      await settings.resetAllSettings();
      
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '설정이 초기화되었습니다',
            style: TextStyle(fontSize: 16.sp),
          ),
          backgroundColor: Colors.green[700],
        ),
      );
    }
  }
}