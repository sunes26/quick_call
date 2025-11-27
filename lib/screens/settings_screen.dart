import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:quick_call/providers/settings_provider.dart';
import 'package:quick_call/providers/speed_dial_provider.dart';
import 'package:quick_call/services/backup_service.dart';
import 'package:quick_call/utils/sort_options.dart';
import 'dart:io';

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
    // 🆕 다크 모드 대응: Theme에서 색상 가져오기
    final theme = Theme.of(context);
    final cardColor = theme.cardTheme.color ?? theme.cardColor;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor, // 🆕 테마 배경색 사용
      appBar: AppBar(
        // 🆕 backgroundColor 제거 - 테마 기본값 사용
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.appBarTheme.foregroundColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          '설정',
          style: TextStyle(
            color: theme.appBarTheme.foregroundColor, // 🆕 테마 텍스트 색상
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Consumer<SettingsProvider>(
        builder: (context, settings, child) {
          return ListView(
            padding: EdgeInsets.symmetric(vertical: 8.h),
            children: [
              // 화면 설정
              _buildSectionHeader('화면'),
              _buildThemeModeTile(settings, cardColor),
              
              SizedBox(height: 16.h),
              
              // 정렬 설정
              _buildSectionHeader('정렬'),
              _buildSortOptionTile(cardColor),
              
              SizedBox(height: 16.h),
              
              // 백업/복원
              _buildSectionHeader('데이터'),
              _buildBackupTile(cardColor),
              _buildRestoreTile(cardColor),
              _buildBackupListTile(cardColor),
              
              SizedBox(height: 16.h),
              
              // 기타
              _buildSectionHeader('기타'),
              _buildDatabaseInfoTile(cardColor),
              _buildResetSettingsTile(settings, cardColor),
              
              SizedBox(height: 16.h),
              
              // 앱 정보
              _buildSectionHeader('정보'),
              _buildAppInfoTile(cardColor),
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

  Widget _buildThemeModeTile(SettingsProvider settings, Color? cardColor) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      decoration: BoxDecoration(
        color: cardColor, // 🆕 테마 카드 색상
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

  Widget _buildSortOptionTile(Color? cardColor) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      decoration: BoxDecoration(
        color: cardColor, // 🆕 테마 카드 색상
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

  Widget _buildBackupTile(Color? cardColor) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      decoration: BoxDecoration(
        color: cardColor, // 🆕 테마 카드 색상
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: ListTile(
        leading: _isBackingUp
            ? SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.blue[700]!),
                ),
              )
            : Icon(Icons.save_alt, color: Colors.blue[700]),
        title: const Text('백업하기'),
        subtitle: Text(
          '현재 단축키를 파일로 저장',
          style: TextStyle(fontSize: 13.sp),
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: _isBackingUp ? null : _performBackup,
      ),
    );
  }

  Widget _buildRestoreTile(Color? cardColor) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      decoration: BoxDecoration(
        color: cardColor, // 🆕 테마 카드 색상
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: ListTile(
        leading: _isRestoring
            ? SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.orange[700]!),
                ),
              )
            : Icon(Icons.restore, color: Colors.orange[700]),
        title: const Text('복원하기'),
        subtitle: Text(
          '백업 파일에서 복원',
          style: TextStyle(fontSize: 13.sp),
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: _isRestoring ? null : _showRestoreDialog,
      ),
    );
  }

  Widget _buildBackupListTile(Color? cardColor) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      decoration: BoxDecoration(
        color: cardColor, // 🆕 테마 카드 색상
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: ListTile(
        leading: Icon(Icons.folder_open, color: Colors.purple[700]),
        title: const Text('백업 파일 관리'),
        subtitle: Text(
          '저장된 백업 파일 보기',
          style: TextStyle(fontSize: 13.sp),
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: _showBackupListDialog,
      ),
    );
  }

  Widget _buildDatabaseInfoTile(Color? cardColor) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      decoration: BoxDecoration(
        color: cardColor, // 🆕 테마 카드 색상
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Consumer<SpeedDialProvider>(
        builder: (context, provider, child) {
          return ListTile(
            leading: Icon(Icons.storage, color: Colors.blue[700]),
            title: const Text('데이터베이스 정보'),
            subtitle: Text(
              '단축키: ${provider.buttons.length}개 | 그룹: ${provider.groups.length}개',
              style: TextStyle(fontSize: 13.sp),
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: _showDatabaseInfoDialog,
          );
        },
      ),
    );
  }

  Widget _buildResetSettingsTile(SettingsProvider settings, Color? cardColor) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      decoration: BoxDecoration(
        color: cardColor, // 🆕 테마 카드 색상
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: ListTile(
        leading: Icon(Icons.refresh, color: Colors.orange[700]),
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

  Widget _buildAppInfoTile(Color? cardColor) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      decoration: BoxDecoration(
        color: cardColor, // 🆕 테마 카드 색상
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: ListTile(
        leading: Icon(Icons.info_outline, color: Colors.blue[700]),
        title: const Text('앱 정보'),
        subtitle: Text(
          'Quick Call v1.0.0',
          style: TextStyle(fontSize: 13.sp),
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: _showAppInfoDialog,
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
          title: Row(
            children: [
              Icon(Icons.sort, color: Colors.blue[700]),
              SizedBox(width: 12.w),
              Text(
                '정렬 방식',
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: SortOption.values.map((option) {
              final isSelected = provider.currentSortOption == option;
              return ListTile(
                title: Text(option.displayName),
                leading: Icon(
                  isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
                  color: isSelected ? Colors.blue[700] : Colors.grey,
                ),
                selected: isSelected,
                onTap: () {
                  provider.setSortOption(option);
                  Navigator.pop(dialogContext);
                },
              );
            }).toList(),
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

  // 백업 실행
  Future<void> _performBackup() async {
    setState(() => _isBackingUp = true);

    try {
      final file = await _backupService.createBackup();
      
      if (!mounted) return;
      
      // File 객체에서 경로 추출
      String fileName;
      if (file is File) {
        final f = file as File;
        fileName = f.path.split('/').last;
      } else {
        fileName = file.toString().split('/').last;
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white, size: 20.sp),
              SizedBox(width: 12.w),
              Expanded(
                child: Text(
                  '백업 완료: $fileName',
                  style: TextStyle(fontSize: 16.sp),
                ),
              ),
            ],
          ),
          backgroundColor: Colors.green[700],
          duration: const Duration(seconds: 3),
          action: SnackBarAction(
            label: '공유',
            textColor: Colors.white,
            onPressed: () {
              // 파일 공유 기능 (선택사항)
            },
          ),
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
            '복원할 백업 파일이 없습니다',
            style: TextStyle(fontSize: 16.sp),
          ),
          backgroundColor: Colors.orange[700],
        ),
      );
      return;
    }

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.r),
          ),
          title: Row(
            children: [
              Icon(Icons.restore, color: Colors.orange[700]),
              SizedBox(width: 12.w),
              Text(
                '백업 선택',
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
                    onTap: () {
                      Navigator.pop(dialogContext);
                      _performRestore(backup.path);
                    },
                  ),
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
      
      if (!mounted) return;
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
      if (!mounted) return;
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

    if (!mounted) return;

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
                          if (dialogContext.mounted) {
                            Navigator.pop(dialogContext);
                          }
                          if (mounted) {
                            _showBackupListDialog(); // 다시 열기
                          }
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

  // 데이터베이스 정보 다이얼로그
  Future<void> _showDatabaseInfoDialog() async {
    if (!mounted) return;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.r),
          ),
          title: Row(
            children: [
              Icon(Icons.storage, color: Colors.blue[700]),
              SizedBox(width: 12.w),
              const Text('데이터베이스 정보'),
            ],
          ),
          content: Consumer<SpeedDialProvider>(
            builder: (context, provider, child) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '저장된 데이터:',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 12.h),
                  _buildInfoRow('단축키', '${provider.buttons.length}개'),
                  SizedBox(height: 8.h),
                  _buildInfoRow('그룹', '${provider.groups.length}개'),
                  SizedBox(height: 16.h),
                  Text(
                    'SQLite 데이터베이스를 사용하여\n로컬에 안전하게 저장됩니다.',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              );
            },
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

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 14.sp),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.bold,
            color: Colors.blue[700],
          ),
        ),
      ],
    );
  }

  // 앱 정보 다이얼로그
  void _showAppInfoDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.r),
          ),
          title: Row(
            children: [
              Icon(Icons.phone_android, color: Colors.blue[700]),
              SizedBox(width: 12.w),
              const Text('앱 정보'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Quick Call',
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                '버전: 1.0.0',
                style: TextStyle(fontSize: 14.sp),
              ),
              SizedBox(height: 16.h),
              Text(
                '빠른 전화 걸기를 위한 단축 다이얼 앱',
                style: TextStyle(fontSize: 14.sp),
              ),
            ],
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