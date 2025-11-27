import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:quick_call/models/speed_dial_button.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'dart:math' as math;

class DialButtonWidget extends StatefulWidget {
  final SpeedDialButton button;
  final bool isEditMode;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final VoidCallback onDelete;

  const DialButtonWidget({
    super.key,
    required this.button,
    this.isEditMode = false,
    this.onTap,
    this.onLongPress,
    required this.onDelete,
  });

  @override
  State<DialButtonWidget> createState() => _DialButtonWidgetState();
}

class _DialButtonWidgetState extends State<DialButtonWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  // ========================================
  // 패턴 사전 정의
  // ========================================
  
  // 직책 (긴 것부터 매칭)
  static const List<String> _positionPatterns = [
    '본부장', '센터장', '지점장', '부사장', '선생님', '대표님',
    '회장', '사장', '전무', '상무', '이사', '부장', '차장',
    '과장', '대리', '주임', '사원', '팀장', '실장', '원장',
    '관장', '교수', '박사', '님', '씨',
  ];

  // 조직 단위 (긴 것부터 매칭)
  static const List<String> _organizationPatterns = [
    '영업팀', '개발팀', '인사팀', '총무팀', '기획팀', '마케팅팀',
    '경영지원팀', '고객지원팀', '연구소', '사업부', '지원팀',
    '본부', '센터', '지점', '팀', '부', '실', '과', '국', '처',
  ];

  // 회사/기관 (긴 것부터 매칭)
  static const List<String> _companyPatterns = [
    '대학교', '고등학교', '중학교', '초등학교', '유치원',
    '물산', '전자', '건설', '증권', '은행', '보험', '카드',
    '병원', '약국', '의원', '치과', '한의원', '정형외과',
    '회사', '그룹', '재단', '공사', '공단', '협회',
  ];

  @override
  void initState() {
    super.initState();
    
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _animation = Tween<double>(
      begin: -0.03,
      end: 0.03,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    if (widget.isEditMode) {
      _startWiggle();
    }
  }

  @override
  void didUpdateWidget(DialButtonWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    if (widget.isEditMode != oldWidget.isEditMode) {
      if (widget.isEditMode) {
        _startWiggle();
      } else {
        _stopWiggle();
      }
    }
  }

  void _startWiggle() {
    final delay = math.Random().nextInt(200);
    Future.delayed(Duration(milliseconds: delay), () {
      if (mounted && widget.isEditMode) {
        _controller.repeat(reverse: true);
      }
    });
  }

  void _stopWiggle() {
    _controller.stop();
    _controller.reset();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // 배경색에 따른 텍스트 색상 자동 결정
  Color _getTextColorForBackground(Color backgroundColor) {
    return backgroundColor.computeLuminance() > 0.5 
        ? Colors.black87 
        : Colors.white;
  }

  // ========================================
  // 🆕 가중치 기반 유효 글자수 계산
  // ========================================
  
  /// 문자별 가중치 반환
  double _getCharWeight(String char) {
    final codeUnit = char.codeUnitAt(0);
    
    // 한글 (가-힣): 0xAC00 ~ 0xD7A3
    if (codeUnit >= 0xAC00 && codeUnit <= 0xD7A3) {
      return 1.0;
    }
    // 한글 자모 (ㄱ-ㅎ, ㅏ-ㅣ): 0x3130 ~ 0x318F
    if (codeUnit >= 0x3130 && codeUnit <= 0x318F) {
      return 0.8;
    }
    // 영문 대문자 (A-Z)
    if (codeUnit >= 0x41 && codeUnit <= 0x5A) {
      return 0.6;
    }
    // 영문 소문자 (a-z)
    if (codeUnit >= 0x61 && codeUnit <= 0x7A) {
      return 0.5;
    }
    // 숫자 (0-9)
    if (codeUnit >= 0x30 && codeUnit <= 0x39) {
      return 0.5;
    }
    // 공백
    if (char == ' ' || char == '\t' || char == '\n') {
      return 0.0; // 공백은 계산에서 제외
    }
    // 특수문자 (-, _, ., 등)
    return 0.4;
  }

  /// 유효 글자수 계산 (가중치 적용)
  double _calculateEffectiveLength(String name) {
    double effectiveLength = 0;
    
    for (int i = 0; i < name.length; i++) {
      effectiveLength += _getCharWeight(name[i]);
    }
    
    return effectiveLength;
  }

  /// 유효 글자수 구간별 최대 폰트 크기 반환
  double _getMaxFontSizeByLength(String name) {
    final effectiveLength = _calculateEffectiveLength(name);
    
    if (effectiveLength <= 2.0) {
      return 36; // 유효 1~2글자: 매우 크게
    } else if (effectiveLength <= 4.0) {
      return 30; // 유효 3~4글자: 크게
    } else if (effectiveLength <= 6.0) {
      return 26; // 유효 5~6글자: 중간
    } else if (effectiveLength <= 8.0) {
      return 22; // 유효 7~8글자: 약간 작게
    } else {
      return 18; // 유효 9글자 이상: 작게
    }
  }

  // ========================================
  // 하이브리드 줄바꿈 로직
  // ========================================

  /// 메인 포맷팅 함수 - 하이브리드 방식
  String _formatNameWithOptimalLineBreaks(String name) {
    final trimmed = name.trim();
    
    if (trimmed.isEmpty) return trimmed;
    
    // 1. 구분자 체크 (/, |)
    if (trimmed.contains('/') || trimmed.contains('|')) {
      final parts = trimmed
          .split(RegExp(r'[/|]'))
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .toList();
      return _applyOptimalDistribution(parts);
    }
    
    // 2. 공백 체크
    if (trimmed.contains(RegExp(r'\s'))) {
      final parts = trimmed
          .split(RegExp(r'\s+'))
          .where((s) => s.isNotEmpty)
          .toList();
      return _applyOptimalDistribution(parts);
    }
    
    // 3. 패턴 인식 (공백/구분자 없는 경우)
    final patternParts = _extractByPatterns(trimmed);
    if (patternParts.length > 1) {
      return _applyOptimalDistribution(patternParts);
    }
    
    // 4. Fallback: 균등 분할 (7글자 이상)
    if (trimmed.length >= 7) {
      return _splitEvenly(trimmed);
    }
    
    // 5. 짧은 텍스트: 그대로
    return trimmed;
  }

  /// 패턴 기반 텍스트 분리
  List<String> _extractByPatterns(String text) {
    List<String> result = [];
    String remaining = text;
    
    // 1. 뒤에서부터 직책 추출
    String? positionMatch = _matchSuffixFromList(remaining, _positionPatterns);
    if (positionMatch != null && positionMatch.length < remaining.length) {
      result.add(positionMatch);
      remaining = remaining.substring(0, remaining.length - positionMatch.length);
    }
    
    // 2. 뒤에서부터 이름 추출 시도 (2-4글자, 직책 제거 후)
    // 한국 이름은 보통 2-4글자
    if (remaining.length > 4) {
      // 이름 후보 추출 (2-4글자)
      for (int nameLen = 3; nameLen >= 2; nameLen--) {
        if (remaining.length > nameLen) {
          String nameCandiate = remaining.substring(remaining.length - nameLen);
          // 이름 후보가 조직/회사 패턴에 매칭되지 않으면 이름으로 간주
          if (!_isOrganizationOrCompany(nameCandiate)) {
            result.insert(0, nameCandiate);
            remaining = remaining.substring(0, remaining.length - nameLen);
            break;
          }
        }
      }
    }
    
    // 3. 뒤에서부터 조직 단위 추출
    String? orgMatch = _matchSuffixFromList(remaining, _organizationPatterns);
    if (orgMatch != null && orgMatch.length < remaining.length) {
      result.insert(0, orgMatch);
      remaining = remaining.substring(0, remaining.length - orgMatch.length);
    }
    
    // 4. 앞에서부터 회사 패턴 확인
    String? companyMatch = _matchCompanyPattern(remaining);
    if (companyMatch != null) {
      result.insert(0, companyMatch);
      remaining = remaining.substring(companyMatch.length);
    }
    
    // 5. 남은 부분이 있으면 맨 앞에 추가
    if (remaining.isNotEmpty) {
      result.insert(0, remaining);
    }
    
    // 빈 요소 제거
    result = result.where((s) => s.isNotEmpty).toList();
    
    // 결과가 원본과 같으면 분리 실패
    if (result.length == 1 && result.first == text) {
      return [text];
    }
    
    return result.isEmpty ? [text] : result;
  }

  /// 리스트에서 suffix 매칭
  String? _matchSuffixFromList(String text, List<String> patterns) {
    for (final pattern in patterns) {
      if (text.endsWith(pattern) && text.length > pattern.length) {
        return pattern;
      }
    }
    return null;
  }

  /// 회사 패턴 매칭 (앞에서부터)
  String? _matchCompanyPattern(String text) {
    for (final pattern in _companyPatterns) {
      int index = text.indexOf(pattern);
      if (index != -1) {
        // 패턴까지 포함한 회사명 반환
        return text.substring(0, index + pattern.length);
      }
    }
    return null;
  }

  /// 조직 또는 회사 패턴인지 확인
  bool _isOrganizationOrCompany(String text) {
    for (final pattern in _organizationPatterns) {
      if (text.endsWith(pattern)) return true;
    }
    for (final pattern in _companyPatterns) {
      if (text.endsWith(pattern)) return true;
    }
    return false;
  }

  /// 단어 리스트를 최적 분배로 줄바꿈 적용
  String _applyOptimalDistribution(List<String> words) {
    if (words.isEmpty) return '';
    if (words.length == 1) return words.first;
    if (words.length == 2) return words.join('\n');
    if (words.length == 3) return words.join('\n');
    
    // 4단어 이상: 최적 분배
    return _findOptimalDistribution(words);
  }

  /// 4단어 이상일 때 최적의 3줄 분배 찾기
  String _findOptimalDistribution(List<String> words) {
    int bestVariance = 999999;
    List<int> bestDistribution = [1, 1, words.length - 2];
    
    for (int line1 = 1; line1 <= words.length - 2; line1++) {
      for (int line2 = 1; line2 <= words.length - line1 - 1; line2++) {
        int line3 = words.length - line1 - line2;
        
        int chars1 = _countChars(words.sublist(0, line1));
        int chars2 = _countChars(words.sublist(line1, line1 + line2));
        int chars3 = _countChars(words.sublist(line1 + line2));
        
        int maxChars = [chars1, chars2, chars3].reduce(math.max);
        int minChars = [chars1, chars2, chars3].reduce(math.min);
        int variance = maxChars - minChars;
        
        if (variance < bestVariance) {
          bestVariance = variance;
          bestDistribution = [line1, line2, line3];
        } else if (variance == bestVariance) {
          if (line1 > bestDistribution[0] || 
              (line1 == bestDistribution[0] && line2 > bestDistribution[1])) {
            bestDistribution = [line1, line2, line3];
          }
        }
      }
    }
    
    int idx1 = bestDistribution[0];
    int idx2 = idx1 + bestDistribution[1];
    
    String line1 = words.sublist(0, idx1).join(' ');
    String line2 = words.sublist(idx1, idx2).join(' ');
    String line3 = words.sublist(idx2).join(' ');
    
    return '$line1\n$line2\n$line3';
  }

  /// 글자 수 균등 분할 (패턴 인식 실패 시 fallback)
  String _splitEvenly(String text) {
    final length = text.length;
    
    if (length <= 6) {
      return text;
    }
    
    // 2줄로 분할 (7-12글자)
    if (length <= 12) {
      final mid = (length / 2).ceil();
      return '${text.substring(0, mid)}\n${text.substring(mid)}';
    }
    
    // 3줄로 균등 분할 (13글자 이상)
    final third = (length / 3).ceil();
    final twoThirds = (length * 2 / 3).ceil();
    
    return '${text.substring(0, third)}\n${text.substring(third, twoThirds)}\n${text.substring(twoThirds)}';
  }

  /// 단어 리스트의 총 글자 수 계산
  int _countChars(List<String> words) {
    return words.fold(0, (sum, word) => sum + word.length);
  }

  // ========================================

  @override
  Widget build(BuildContext context) {
    // 🆕 가중치 기반 유효 글자수로 최대 폰트 크기 계산
    final maxFontSize = _getMaxFontSizeByLength(widget.button.name);
    
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.rotate(
          angle: widget.isEditMode ? _animation.value : 0,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // 메인 버튼
              GestureDetector(
                onTap: widget.onTap,
                onLongPress: !widget.isEditMode && widget.onLongPress != null
                    ? () {
                        HapticFeedback.mediumImpact();
                        widget.onLongPress!();
                      }
                    : null,
                child: Container(
                  width: double.infinity,
                  height: double.infinity,
                  clipBehavior: Clip.hardEdge,
                  decoration: BoxDecoration(
                    color: widget.button.color,
                    borderRadius: BorderRadius.circular(16.r),
                    boxShadow: const [
                      BoxShadow(
                        color: Color.fromRGBO(0, 0, 0, 0.1),
                        blurRadius: 10,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 12.h),
                      child: AutoSizeText(
                        _formatNameWithOptimalLineBreaks(widget.button.name),
                        style: TextStyle(
                          fontSize: maxFontSize.sp,
                          fontWeight: FontWeight.bold,
                          color: _getTextColorForBackground(widget.button.color),
                          height: 1.2,
                        ),
                        maxLines: 3,
                        minFontSize: 12,
                        maxFontSize: maxFontSize,
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ),
              ),

              // 편집 모드: 삭제 버튼
              if (widget.isEditMode)
                Positioned(
                  top: 0,
                  right: 0,
                  child: GestureDetector(
                    onTap: widget.onDelete,
                    child: Container(
                      padding: EdgeInsets.all(4.w),
                      decoration: BoxDecoration(
                        color: Colors.red[500],
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white,
                          width: 2,
                        ),
                        boxShadow: const [
                          BoxShadow(
                            color: Color.fromRGBO(0, 0, 0, 0.2),
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.close,
                        size: 16.sp,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}