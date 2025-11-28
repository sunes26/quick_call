# Quick Call - 전화번호 단축 다이얼 앱

> Android 전용 전화번호 단축 다이얼 앱  
> Flutter 3.0+ / Android 8.0 (API 26) 이상 지원

## 📱 프로젝트 개요

Quick Call은 자주 연락하는 사람에게 빠르게 전화를 걸 수 있도록 도와주는 Android 앱입니다. 홈 화면 위젯을 통해 앱 실행 없이 바로 전화를 걸 수 있습니다.

### 주요 기능

- ✅ **단축 전화번호 관리**: 자주 사용하는 전화번호를 그룹별로 관리
- ✅ **직관적인 버튼 조작**: 
  - **클릭(탭)**: 버튼 편집 화면 열기 (모든 모드)
  - **롱프레스(꾹 누르기)**: 즉시 전화 걸기 (일반 모드, 햅틱 피드백)
- ✅ **정사각형 버튼 디자인**: 홈 화면에서 균일한 정사각형 버튼 표시 (v1.10.0)
- ✅ **스마트 폰트 크기 조절**: 글자수와 문자 유형에 따라 자동으로 폰트 크기 최적화 (v1.10.0)
- ✅ **확장된 색상 팔레트**: 30가지 색상 지원 - 빨주노초파남보검 기본 색상 포함 (v1.13.0)
- ✅ **스마트 색상 자동 적용**: 새 단축키 추가 시 같은 그룹의 마지막 버튼 색상 자동 적용 (v1.13.0)
- ✅ **색상 커스터마이징**: 버튼별 배경색 지정 가능 (30가지 색상 팔레트)
- ✅ **컴팩트 색상 선택 UI**: 스크롤로 30개 색상을 편리하게 선택
- ✅ **큰 텍스트**: 아이콘 없이 이름만 크게 표시 (최대 36sp, 자동 크기 조정)
- ✅ **하이브리드 줄바꿈**: 공백/구분자/패턴 인식으로 의미 단위 자동 줄바꿈
- ✅ **글자수 무제한**: 이름 입력 글자수 제한 없음 (긴 이름도 자동 줄바꿈 처리)
- ✅ **일관된 UI/UX**: 시스템 테마와 관계없이 항상 동일한 라이트 모드 제공 (v1.11.0)
- ✅ **부드러운 사용 경험**: 탭 전환 시 애니메이션 제거로 즉각적인 반응 (v1.13.0)
- ✅ **편집 모드 피드백**: 편집 모드에서 버튼 흔들림 효과로 시각적 피드백 제공 (v1.13.0)
- ✅ **홈 화면 위젯**: 3가지 크기의 위젯 지원 (1×1, 2×3, 3×2)
- ✅ **위젯 전화번호 표시**: 이름과 전화번호를 위젯에 함께 표시 (AutoSize 적용)
- ✅ **연락처 연동**: 기존 연락처에서 전화번호 불러오기
- ✅ **주소록 버튼 위치 개선**: 이름 입력칸 옆에 주소록 불러오기 버튼 배치 (v1.10.0)
- ✅ **그룹 관리**: 가족, 친구, 직장 등 그룹별 분류
- ✅ **그룹 영구 저장**: 빈 그룹도 앱 재시작 후 유지됨 (v1.9.0, DB 그룹 테이블)
- ✅ **그룹 생성**: 우측 하단 FAB 버튼으로 새 그룹 생성
- ✅ **그룹 편집**: 그룹 탭 재클릭으로 그룹 이름 변경 및 삭제 (모든 그룹 편집 가능, v1.12.0)
- ✅ **그룹 탭 드래그 순서 변경**: 편집 모드에서 그룹 탭을 드래그하여 순서 자유롭게 변경 (v1.14.0)
- ✅ **스와이프 탭 전환**: 화면을 좌우로 스와이프하여 그룹 간 자연스럽게 전환 (모든 모드에서 동작)
- ✅ **인라인 버튼 추가**: 각 그룹 마지막에 점선 테두리 + 버튼으로 빠른 추가
- ✅ **그룹별 기본값 자동 선택**: 단축키 추가 시 현재 탭의 그룹이 기본 선택됨 (v1.8.0)
- ✅ **드래그로 그룹 간 이동**: 편집 모드에서 버튼을 가장자리로 드래그하여 다른 그룹으로 이동 (v1.9.0 개선)
- ✅ **드래그 앤 드롭**: 편집 모드에서 순서 변경 가능
- ✅ **검색 기능**: 이름/전화번호로 빠른 검색 (모든 그룹에서 검색)
- ✅ **백업/복원**: JSON 형식으로 데이터 백업 및 복원 (그룹 데이터 포함, v1.9.0)

---

## 🏗️ 프로젝트 구조
```
quick_call/
├── .flutter-plugins-dependencies     # Flutter 플러그인 의존성 정보
├── .gitignore                        # Git 무시 파일 목록
├── .metadata                         # Flutter 프로젝트 메타데이터
├── analysis_options.yaml             # Dart 정적 분석 설정
├── pubspec.yaml                      # Flutter 패키지 의존성
├── pubspec.lock                      # 의존성 버전 잠금 파일
├── README.md                         # 프로젝트 문서
│
├── android/                          # Android Native 코드
│   ├── .gitignore                    # Android 빌드 무시 파일
│   ├── build.gradle.kts              # 프로젝트 수준 Gradle 설정
│   ├── settings.gradle.kts           # Gradle 설정
│   ├── gradle.properties             # Gradle 속성
│   ├── local.properties              # 로컬 SDK 경로 (gitignore)
│   ├── gradlew                       # Gradle Wrapper (Unix)
│   ├── gradlew.bat                   # Gradle Wrapper (Windows)
│   │
│   ├── gradle/                       # Gradle Wrapper 파일
│   │   └── wrapper/
│   │       ├── gradle-wrapper.jar
│   │       └── gradle-wrapper.properties
│   │
│   └── app/                          # 앱 모듈
│       ├── build.gradle.kts          # 앱 모듈 빌드 설정
│       ├── proguard-rules.pro        # ProGuard 난독화 규칙
│       │
│       └── src/
│           ├── debug/                # 디버그 빌드 설정
│           │   └── AndroidManifest.xml
│           │
│           ├── profile/              # 프로파일 빌드 설정
│           │   └── AndroidManifest.xml
│           │
│           └── main/                 # 메인 소스
│               ├── AndroidManifest.xml   # 앱 매니페스트 (권한, 위젯 등록)
│               │
│               ├── java/             # Java 생성 파일
│               │   └── io/flutter/plugins/
│               │       └── GeneratedPluginRegistrant.java
│               │
│               ├── kotlin/           # Kotlin 네이티브 코드
│               │   └── com/example/quick_call/
│               │       ├── MainActivity.kt                    # Flutter ↔ Native 브릿지
│               │       │
│               │       └── widget/                           # 위젯 관련 코드
│               │           ├── SpeedDialWidgetProvider1x1.kt  # 1×1 위젯
│               │           ├── SpeedDialWidgetProvider2x3.kt  # 2×3 위젯
│               │           ├── SpeedDialWidgetProvider3x2.kt  # 3×2 위젯
│               │           ├── WidgetConfigActivity1x1.kt     # 1×1 위젯 설정 화면
│               │           ├── WidgetConfigActivity2x3.kt     # 2×3 위젯 설정 화면
│               │           ├── WidgetConfigActivity3x2.kt     # 3×2 위젯 설정 화면
│               │           └── WidgetUtils.kt                 # 위젯 공통 유틸리티
│               │
│               └── res/              # Android 리소스
│                   ├── drawable/     # 드로어블 리소스
│                   │   ├── button_outline.xml                # 취소 버튼 스타일
│                   │   ├── button_primary.xml                # 저장 버튼 스타일
│                   │   ├── gradient_header.xml               # 헤더 그라데이션
│                   │   ├── launch_background.xml             # 런처 배경
│                   │   ├── samsung_white_button.xml          # 위젯 버튼 스타일
│                   │   ├── widget_button_unselected.xml      # 미선택 버튼 배경 (회색 테두리)
│                   │   └── widget_button_selected.xml        # 선택 버튼 배경 (파란색 테두리)
│                   │
│                   ├── drawable-v21/  # API 21+ 드로어블
│                   │   └── launch_background.xml
│                   │
│                   ├── layout/       # 레이아웃 XML
│                   │   ├── activity_widget_config_simple.xml  # 위젯 설정 화면
│                   │   ├── item_widget_button_all.xml         # 버튼 선택 아이템 (3열 그리드)
│                   │   ├── widget_speed_dial_1x1.xml          # 1×1 위젯 레이아웃 (전화번호 포함)
│                   │   ├── widget_speed_dial_2x3.xml          # 2×3 위젯 레이아웃 (전화번호 포함)
│                   │   └── widget_speed_dial_3x2.xml          # 3×2 위젯 레이아웃 (전화번호 포함)
│                   │
│                   ├── mipmap-hdpi/      # 앱 아이콘 (hdpi)
│                   │   └── ic_launcher.png
│                   │
│                   ├── mipmap-mdpi/      # 앱 아이콘 (mdpi)
│                   │   └── ic_launcher.png
│                   │
│                   ├── mipmap-xhdpi/     # 앱 아이콘 (xhdpi)
│                   │   └── ic_launcher.png
│                   │
│                   ├── mipmap-xxhdpi/    # 앱 아이콘 (xxhdpi)
│                   │   └── ic_launcher.png
│                   │
│                   ├── mipmap-xxxhdpi/   # 앱 아이콘 (xxxhdpi)
│                   │   └── ic_launcher.png
│                   │
│                   ├── values/       # 기본 리소스 값
│                   │   ├── strings.xml
│                   │   └── styles.xml
│                   │
│                   ├── values-night/  # 다크 모드 리소스
│                   │   └── styles.xml
│                   │
│                   └── xml/          # 위젯 메타데이터
│                       ├── speed_dial_widget_info_1x1.xml
│                       ├── speed_dial_widget_info_2x3.xml
│                       └── speed_dial_widget_info_3x2.xml
│
└── lib/                              # Flutter 코드
    ├── main.dart                     # 앱 진입점
    │
    ├── models/                       # 데이터 모델
    │   └── speed_dial_button.dart    # 단축 버튼 모델 (color 필드 포함)
    │
    ├── providers/                    # 상태 관리 (Provider)
    │   ├── settings_provider.dart    # 앱 설정 관리
    │   └── speed_dial_provider.dart  # 단축키 데이터 관리 (그룹 DB 연동, 전체 탭 제거)
    │
    ├── screens/                      # 화면 UI
    │   ├── home_screen.dart          # 메인 홈 화면 (정사각형 버튼, 애니메이션 제거, 편집 모드 흔들림 유지, 그룹 탭 드래그 순서 변경)
    │   ├── add_button_screen.dart    # 단축키 추가 화면 (스마트 색상 자동 적용, v1.13.0)
    │   ├── edit_button_screen.dart   # 단축키 편집 화면 (주소록 버튼 이름 옆 배치)
    │   └── settings_screen.dart      # 설정 화면
    │
    ├── services/                     # 비즈니스 로직
    │   ├── database_service.dart     # SQLite 데이터베이스 관리 (버전 6, groups 테이블)
    │   ├── phone_service.dart        # 전화 걸기 기능
    │   ├── permission_service.dart   # 권한 관리
    │   ├── widget_service.dart       # 위젯 통신 (color 지원, 채널명 수정)
    │   └── backup_service.dart       # 백업/복원 기능 (버전 1.1.0, 그룹 포함)
    │
    ├── utils/                        # 유틸리티
    │   ├── phone_formatter.dart      # 전화번호 포맷팅
    │   ├── error_handler.dart        # 에러 처리
    │   └── sort_options.dart         # 정렬 옵션
    │
    └── widgets/                      # 재사용 가능한 위젯
        ├── dial_button_widget.dart       # 단축키 버튼 UI (편집 모드 흔들림 유지, v1.13.0)
        ├── color_picker_widget.dart      # 색상 선택 위젯 (30개 색상, 빨주노초파남보검, v1.13.0)
        ├── contact_picker_widget.dart    # 연락처 선택 위젯
        ├── empty_state_widget.dart       # 빈 상태 UI
        ├── loading_widget.dart           # 로딩 UI
        ├── permission_dialog.dart        # 권한 안내 다이얼로그
        ├── duplicate_phone_dialog.dart   # 중복 전화번호 확인 다이얼로그
        ├── icon_picker_widget.dart       # 아이콘 선택 위젯 (레거시, 미사용)
        └── group_edit_dialog.dart        # 그룹 편집 다이얼로그
```

---

## 🔧 기술 스택

### Flutter
- **Flutter SDK**: 3.0 이상
- **Dart**: 3.0 이상

### 주요 패키지
```yaml
# UI & Utilities
flutter_screenutil: ^5.9.0      # 반응형 UI
auto_size_text: ^3.0.0          # 자동 텍스트 크기 조정
reorderable_grid_view: ^2.2.8   # 드래그 앤 드롭 그리드
intl: ^0.18.1                   # 날짜 포맷팅

# State Management
provider: ^6.1.1                # 상태 관리

# Phone & Contacts
flutter_phone_direct_caller: ^2.1.1  # 즉시 전화 걸기
flutter_contacts: ^1.1.7             # 연락처 접근
permission_handler: ^11.1.0          # 권한 관리
url_launcher: ^6.2.2                 # URL 실행

# Storage
sqflite: ^2.3.0                # SQLite 데이터베이스
shared_preferences: ^2.2.2      # 설정 저장
path_provider: ^2.1.1           # 파일 경로
```

### Android
- **최소 SDK**: API 26 (Android 8.0 Oreo)
- **타겟 SDK**: Flutter의 기본 타겟 SDK
- **언어**: Kotlin
- **빌드 도구**: Gradle 8.12

---

## 📦 데이터베이스 스키마

### speed_dial_buttons 테이블 (버전 6)

| 컬럼 | 타입 | 설명 |
|------|------|------|
| id | INTEGER | 기본 키 (자동 증가) |
| name | TEXT | 버튼 이름 (글자수 제한 없음) |
| phoneNumber | TEXT | 전화번호 |
| color | INTEGER | 버튼 배경색 (ARGB, 기본: 0xFF2196F3) |
| group | TEXT | 그룹명 (기본: "일반") |
| position | INTEGER | 정렬 순서 |
| createdAt | TEXT | 생성 일시 (ISO8601) |
| lastCalled | TEXT | 마지막 통화 일시 (nullable) |
| isInWidget | INTEGER | 위젯 표시 여부 (0/1) |
| widgetPosition | INTEGER | 위젯 내 순서 (-1: 미사용) |

**인덱스**:
- `idx_position`: position 컬럼
- `idx_group`: group 컬럼
- `idx_widget`: (isInWidget, widgetPosition) 복합 인덱스

### groups 테이블 (버전 6, v1.9.0 신규)

| 컬럼 | 타입 | 설명 |
|------|------|------|
| id | INTEGER | 기본 키 (자동 증가) |
| name | TEXT | 그룹 이름 (UNIQUE) |
| position | INTEGER | 탭 순서 |
| createdAt | TEXT | 생성 일시 (ISO8601) |

**인덱스**:
- `idx_group_position`: position 컬럼

**특징**:
- **"전체" 그룹 제거됨** (v1.12.0): 모든 그룹이 사용자 정의 그룹
- 빈 그룹도 앱 재시작 후 유지됨
- 그룹 순서 커스터마이징 가능 (v1.14.0)
- 모든 그룹 편집/삭제 가능

**마이그레이션 히스토리**:
- v1-v2: group 컬럼 추가
- v2-v3: isInWidget, widgetPosition 컬럼 추가
- v3-v4: color 컬럼 추가
- v4-v5: iconCodePoint, iconFontFamily, iconFontPackage 컬럼 제거
- v5-v6: groups 테이블 추가, 기존 버튼의 그룹 정보 자동 마이그레이션

---

## 💾 백업 데이터 구조

### 백업 파일 형식 (버전 1.1.0)

```json
{
  "version": "1.1.0",
  "timestamp": "2024-12-27T10:30:00.000Z",
  "buttonCount": 10,
  "groupCount": 3,
  "buttons": [
    {
      "id": 1,
      "name": "엄마",
      "phoneNumber": "010-1234-5678",
      "color": 4293467747,
      "group": "가족",
      "position": 0,
      "createdAt": "2024-12-01T09:00:00.000Z",
      "lastCalled": "2024-12-26T15:30:00.000Z",
      "isInWidget": 1,
      "widgetPosition": 0
    }
  ],
  "groups": [
    {
      "name": "가족",
      "position": 0,
      "createdAt": "2024-12-01T09:00:00.000Z"
    },
    {
      "name": "친구",
      "position": 1,
      "createdAt": "2024-12-01T09:00:00.000Z"
    }
  ]
}
```

**버전 호환성**:
- v1.0.0 백업 파일: 버튼만 포함 (그룹 정보는 버튼에서 추출하여 자동 생성)
- v1.1.0 백업 파일: 버튼 + 그룹 데이터 모두 포함

---

## 🎨 주요 기능 구현

### 1. 일관된 라이트 모드 UI (v1.11.0)

**기능 설명**:
- 안드로이드 시스템 테마 설정과 관계없이 항상 라이트 모드로 고정
- 모든 사용자에게 동일한 UI/UX 제공
- 텍스트 가시성 문제 완전 해결

**문제 상황**:
```
안드로이드 시스템 다크모드
    ↓
앱이 darkTheme 적용
    ↓
텍스트: 흰색 (다크 테마 기본값)
배경: Colors.white (하드코딩)
    ↓
결과: 흰 배경 + 흰 텍스트 = 안 보임 ❌
```

**해결 방법**:
```dart
// settings_provider.dart
ThemeMode _themeMode = ThemeMode.light;  // 항상 라이트 모드
```

**적용 결과**:
```
시스템 설정        앱 표시
━━━━━━━━━━━━━━   ━━━━━━━━
라이트 모드  →     라이트 모드 ✅
다크 모드    →     라이트 모드 ✅ (강제)
자동        →     라이트 모드 ✅ (강제)
```

### 2. "전체" 탭 제거 (v1.12.0)

**기능 설명**:
- 기존의 "전체" 가상 그룹 제거
- 모든 그룹이 사용자 정의 그룹으로 동일하게 관리
- 그룹이 없을 때 "새 그룹 만들기" 안내 화면 표시

**변경사항**:
```dart
// speed_dial_provider.dart
// 변경 전
List<String> _groups = ['전체'];
_groups = ['전체', ...dbGroups];

// 변경 후
List<String> _groups = [];
_groups = dbGroups;  // DB 그룹만 사용
```

**그룹 없음 상태 UI**:
- 폴더 아이콘 + "그룹이 없습니다" 메시지
- "새 그룹 만들기" 버튼
- FAB 버튼으로도 그룹 생성 가능

### 3. 애니메이션 최적화 (v1.13.0)

**제거된 애니메이션**:
- ❌ 탭 전환 시 버튼 등장 애니메이션 (Scale, Opacity, 순차 딜레이)
- ❌ 그리드 전환 애니메이션 (AnimatedSwitcher)

**유지된 애니메이션**:
- ✅ 편집 모드 버튼 흔들림 효과 (사용자 피드백용)

**이점**:
- 즉각적인 탭 전환으로 반응성 향상
- 불필요한 애니메이션 제거로 깔끔한 UX
- 편집 모드에서는 흔들림으로 시각적 피드백 제공

### 4. 확장된 색상 팔레트 (v1.13.0)

**색상 구성 (5×6 = 30개)**:

**Row 1-2: 기본 색상 (빨주노초파남보검 + 흰회)**
- 🌈 Row 1: 빨강, 주황, 노랑, 초록, 파랑
- 🌈 Row 2: 남색, 보라, 검정, 흰색, 회색

**Row 3-6: 보조 색상 (20개)**
- 진한 톤 (5개): 진한 분홍, 진한 청록, 진한 올리브, 진한 갈색, 진한 빨강
- 중간 톤 (5개): 딥 핑크, 딥 퍼플, 다크 블루, 다크 시안, 다크 오렌지
- 연한 파스텔 (5개): 연한 빨강, 연한 분홍, 연한 보라, 연한 파랑, 연한 청록
- 밝은 파스텔 (5개): 연한 올리브, 연한 노랑, 연한 갈색, 연한 초록, 연한 회색

**UI 개선**:
- 스크롤 가능한 그리드 (높이 270.h)
- 흰색 버튼 가시성 향상 (진한 테두리)
- 밝은 색 선택 시 어두운 체크마크
- 어두운 색 선택 시 밝은 체크마크

### 5. 스마트 색상 자동 적용 (v1.13.0)

**기능 설명**:
- 새 단축키 추가 시 같은 그룹의 마지막 버튼 색상을 자동으로 가져옴
- 그룹 드롭다운 변경 시 해당 그룹의 마지막 버튼 색상으로 즉시 변경
- 빈 그룹인 경우 기본 파란색(#2196F3) 유지

**동작 시나리오**:

**시나리오 1: + 버튼으로 추가**
```
"가족" 그룹:
┌──────────┐
│ 엄마 (빨강) │ ← 마지막 버튼
└──────────┘
┌──────────┐
│ + 버튼    │ ← 클릭
└──────────┘

→ 추가 화면 열림
→ 색상이 자동으로 빨강색으로 선택됨 ✅
```

**시나리오 2: 그룹 변경**
```
현재: "가족" 선택 (마지막 버튼: 빨강)
→ "친구"로 변경 (마지막 버튼: 파랑)
→ 색상이 자동으로 파랑색으로 변경됨 ✅
```

**시나리오 3: 빈 그룹**
```
"직장" 그룹: (버튼 없음)
→ 기본 파란색(#2196F3) 유지 ✅
```

**구현 위치**:
```dart
// add_button_screen.dart
// 1. initState() - 초기 그룹의 마지막 버튼 색상 가져오기
final groupButtons = provider.getButtonsForGroup(widget.initialGroup!);
if (groupButtons.isNotEmpty) {
  _selectedColor = groupButtons.last.color;
}

// 2. 드롭다운 onChanged - 그룹 변경 시 색상 업데이트
onChanged: (value) {
  final groupButtons = provider.getButtonsForGroup(value);
  if (groupButtons.isNotEmpty) {
    _selectedColor = groupButtons.last.color;
  }
}
```

### 6. 정사각형 버튼 디자인 (v1.10.0)

**기능 설명**:
- 홈 화면의 단축키 버튼이 정사각형으로 표시됨
- 모든 그리드(일반/편집/검색 모드)에서 일관된 버튼 형태

**구현**:
```dart
// home_screen.dart - GridView의 childAspectRatio
gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
  crossAxisCount: 3,
  childAspectRatio: 1.0,  // 정사각형 (이전: 0.85)
  crossAxisSpacing: 26.w,  // 버튼 간격 (v1.12.0 조정)
  mainAxisSpacing: 26.h,
),
```

### 7. 스마트 폰트 크기 조절 시스템 (v1.10.0)

**기능 설명**:
- 글자수에 비례하여 폰트 크기 자동 조절
- 문자 유형별 가중치를 적용하여 영문/숫자도 적절한 크기로 표시

**문자별 가중치**:
| 문자 유형 | 가중치 | 설명 |
|----------|--------|------|
| 한글 (가-힣) | 1.0 | 기준 |
| 한글 자모 (ㄱ-ㅎ) | 0.8 | 약간 좁음 |
| 영문 대문자 (A-Z) | 0.6 | 좁음 |
| 영문 소문자 (a-z) | 0.5 | 더 좁음 |
| 숫자 (0-9) | 0.5 | 더 좁음 |
| 특수문자 | 0.4 | 가장 좁음 |
| 공백 | 0.0 | 제외 |

**유효 글자수 구간별 최대 폰트 크기**:
| 유효 글자수 | 최대 폰트 크기 | 예시 |
|------------|---------------|------|
| 1~2 | 36sp | 엄마, 119, Mom |
| 3~4 | 30sp | 아버지, ABC마트 |
| 5~6 | 26sp | 김철수팀장 |
| 7~8 | 22sp | 삼성전자영업팀 |
| 9+ | 18sp | 한국전력공사본부장 |

### 8. 단축키 버튼 UI 커스터마이징

**파일 위치**: `lib/widgets/dial_button_widget.dart`

**수정 가능한 항목**:
```dart
// 버튼 컨테이너
Container(
  decoration: BoxDecoration(
    color: widget.button.color,              // 배경색
    borderRadius: BorderRadius.circular(16.r), // 둥근 모서리
    boxShadow: [...],                        // 그림자
  ),
)

// 텍스트 스타일
AutoSizeText(
  style: TextStyle(
    fontSize: maxFontSize.sp,    // 폰트 크기
    fontWeight: FontWeight.bold, // 굵기
    color: textColor,            // 색상
    height: 1.2,                 // 줄 간격
  ),
  maxLines: 3,                   // 최대 줄 수
  minFontSize: 12,               // 최소 폰트 크기
)
```

### 9. 단축키 추가 버튼 (+) 커스터마이징

**파일 위치**: `home_screen.dart`의 `_buildAddButtonPlaceholder()` 메서드

**수정 가능한 항목**:
```dart
CustomPaint(
  painter: DashedBorderPainter(
    color: Colors.grey[400]!,    // 점선 테두리 색상
    strokeWidth: 2,              // 점선 두께
    gap: 6,                      // 점선 간격
    dashWidth: 6,                // 점선 길이
    borderRadius: 16.r,          // 둥근 모서리
  ),
  child: Container(
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(16.r),  // 컨테이너 radius
      color: Colors.grey[50],                      // 배경색
    ),
    child: Icon(
      Icons.add,
      size: 40.sp,              // + 아이콘 크기
      color: Colors.grey[400],  // + 아이콘 색상
    ),
  ),
)
```

### 10. 그룹 영구 저장 시스템 (v1.9.0)

**기능 설명**:
- 그룹 정보를 별도 테이블(`groups`)에 저장
- 빈 그룹(버튼이 없는 그룹)도 앱 재시작 후 유지
- 백업/복원 시 그룹 데이터도 함께 처리

### 11. 드래그로 그룹 간 버튼 이동 (v1.9.0 개선)

**기능 설명**:
- 편집 모드에서 버튼을 화면 가장자리로 드래그하여 다른 그룹으로 이동
- 1초 유지 후 손을 떼면 확인 다이얼로그 표시

### 12. 하이브리드 줄바꿈 시스템 (v1.7.0)

버튼 이름을 의미 단위로 자동 줄바꿈하여 가독성을 높이는 시스템입니다.

**처리 우선순위**:
```
1. 구분자 체크 (/, |) → 구분자 기준 분리
2. 공백 체크 → 공백 기준 최적 분배
3. 패턴 인식 → 직책/이름/조직/회사 자동 분리
4. Fallback (7글자+) → 균등 분할
5. 짧은 텍스트 (6글자-) → 그대로 1줄
```

### 13. 버튼 조작 방식

**일반 모드**:
- **클릭(탭)**: 버튼 편집 화면 열기
- **롱프레스(꾹 누르기)**: 전화 걸기 (햅틱 피드백)

**편집 모드**:
- **클릭(탭)**: 버튼 편집 화면 열기
- **X 버튼**: 버튼 삭제
- **드래그**: 순서 변경
- **가장자리 드래그**: 다른 그룹으로 이동 (1초 유지 → 손 떼면 확인창)
- **흔들림 효과**: 편집 가능 상태 시각적 피드백

### 14. 그룹 관리 시스템 (v1.12.0 업데이트)

**그룹 정책**:
- **기본 그룹 없음**: 모든 그룹이 사용자 정의 그룹
- 모든 그룹 편집/삭제 가능
- 빈 그룹도 영구 저장

**사용자 그룹**:
- 그룹 이름 변경 가능 (최대 10자)
- 그룹 삭제 시 해당 그룹의 모든 버튼도 함께 삭제
- 그룹 탭 재클릭으로 편집 바텀시트 표시

### 15. 그룹 탭 드래그 순서 변경 (v1.14.0)

편집 모드에서 그룹 탭의 순서를 직관적으로 변경할 수 있는 기능입니다.

#### 동작 방식

**드래그 타겟**: 탭 **사이의 간격(갭)**을 드래그 타겟으로 사용
- 각 탭 사이에 독립적인 드롭 영역 생성
- 갭 개수 = 탭 개수 + 1

**롱프레스 드래그**:
1. 편집 모드에서 탭을 약 1초간 롱프레스
2. 손을 떼지 말고 좌우로 드래그
3. 원하는 갭(탭 사이 공간) 위로 이동

**실시간 미리보기**:
- 드래그 중 탭들이 실시간으로 재배열되어 표시
- 드래그 중인 탭은 30% 불투명도로 표시
- 최종 배치를 미리 확인 가능

**드롭 인디케이터**:
- 삽입될 위치에 **파란색 세로선(|)** 표시 (4px × 30px)
- 갭에 호버하면 갭이 넓어지며 파란색 세로선 표시
- 드래그 방향에 따라 적절한 위치에 인디케이터 표시

#### 예시

```
초기 상태: |직장|친구|가족|

[시나리오 1] 직장을 친구와 가족 사이로 이동:
1. "직장" 탭을 롱프레스
2. 친구와 가족 사이의 공간으로 드래그
3. 파란색 세로선 표시: |친구| | |가족|
4. 손을 떼면 완료: |친구|직장|가족| ✅

[시나리오 2] 가족을 맨 앞으로 이동:
1. "가족" 탭을 롱프레스
2. 제일 왼쪽 갭으로 드래그
3. 파란색 세로선 표시: | |직장|친구|
4. 손을 떼면 완료: |가족|직장|친구| ✅

[시나리오 3] 친구를 맨 뒤로 이동:
1. "친구" 탭을 롱프레스
2. 제일 오른쪽 갭으로 드래그
3. 파란색 세로선 표시: |직장|가족| |
4. 손을 떼면 완료: |직장|가족|친구| ✅
```

#### 기술 구현

**갭 기반 드래그 구조**:
```dart
// home_screen.dart
Widget _buildDraggableTabBar(SpeedDialProvider provider) {
  return ListView(
    scrollDirection: Axis.horizontal,
    children: [
      for (int i = 0; i <= displayGroups.length; i++) ...[
        _buildDropGap(i, provider, displayGroups),  // 드롭 갭
        if (i < displayGroups.length)
          _buildDraggableTab(i, displayGroups[i], provider),  // 탭
      ],
    ],
  );
}
```

**드롭 갭 위젯**:
```dart
Widget _buildDropGap(int gapIndex, ...) {
  return DragTarget<int>(
    onWillAccept: (draggedIndex) => draggedIndex != null,
    onAccept: (draggedIndex) {
      // 갭 인덱스를 그대로 provider에 전달
      _applyGroupReorder(provider, draggedIndex, gapIndex);
    },
    onMove: (details) {
      setState(() {
        _hoveredTabIndex = gapIndex;
        _updateReorderedGroupsByGap(_draggingTabIndex!, gapIndex);
      });
    },
    builder: (context, candidateData, rejectedData) {
      // 호버 시 파란색 세로선 표시
      return isHovered && _draggingTabIndex != null
          ? Container(width: 4.w, height: 30.h, color: Colors.blue[600])
          : SizedBox(width: 8.w);
    },
  );
}
```

**Provider 순서 변경 로직**:
```dart
// speed_dial_provider.dart
Future<bool> reorderGroups(int oldIndex, int newIndex) async {
  // 유효성 검사: newIndex는 length와 같을 수 있음 (마지막 갭)
  if (newIndex < 0 || newIndex > _groups.length) return false;
  
  final groupsCopy = List<String>.from(_groups);
  final movedGroup = groupsCopy.removeAt(oldIndex);
  
  // 갭 인덱스 조정
  int adjustedNewIndex = newIndex;
  if (oldIndex < newIndex) {
    adjustedNewIndex = newIndex - 1;
  }
  
  groupsCopy.insert(adjustedNewIndex, movedGroup);
  
  // UI 즉시 업데이트
  _groups = groupsCopy;
  notifyListeners();
  
  // DB 저장
  await _databaseService.updateGroupPositions(groupsCopy);
  return true;
}
```

**백업 처리 메커니즘**:
```dart
// onAccept가 호출되지 않은 경우 대비
onDragEnd: (details) {
  if (!_onAcceptCalled && _hoveredTabIndex != null && _draggingTabIndex != null) {
    // 마지막 호버된 갭 위치로 이동
    _applyGroupReorder(provider, _draggingTabIndex!, _hoveredTabIndex!);
  }
  
  // 상태 초기화
  setState(() {
    _draggingTabIndex = null;
    _hoveredTabIndex = null;
    _reorderedGroups = [];
    _onAcceptCalled = false;
  });
}
```

#### 핵심 특징

**갭 기반 드래그**:
- 탭 자체가 아닌 탭 사이의 **공간**을 타겟으로 함
- 직관적: "여기 공간에 놓겠다" → "여기 삽입됨"
- 마지막 위치로도 이동 가능 (마지막 갭)

**실시간 미리보기**:
- 드래그 중 `_reorderedGroups` 상태로 재배열된 탭 표시
- 드래그 중인 탭: 30% 불투명도
- 나머지 탭: 정상 불투명도

**백업 처리**:
- `onAccept` 호출 여부를 `_onAcceptCalled` 플래그로 추적
- `onAccept` 미호출 시 `onDragEnd`에서 `_hoveredTabIndex` 사용하여 처리
- 갭 밖에서 손을 떼도 마지막 호버 위치로 이동

**데이터베이스 저장**:
- `groups` 테이블의 `position` 컬럼에 순서 저장
- `updateGroupPositions(List<String>)` 메서드 사용
- UI 즉시 업데이트 후 백그라운드에서 DB 저장

#### 수정된 파일

**home_screen.dart**:
- `_buildDraggableTabBar()`: 갭 기반 드래그 구조 구현
- `_buildDropGap()`: 드롭 갭 위젯
- `_buildDraggableTab()`: 드래그 가능한 탭 위젯
- `_updateReorderedGroupsByGap()`: 실시간 미리보기 업데이트
- `_applyGroupReorder()`: 순서 변경 적용

**speed_dial_provider.dart**:
- `reorderGroups()`: 유효성 검사 수정 (`newIndex > _groups.length` 허용)
- 갭 인덱스를 받아서 적절한 삽입 인덱스로 변환

---

## 🚀 빌드 및 실행

### 개발 환경 설정

```bash
# Flutter 3.0 이상 필요
flutter --version

# 의존성 설치
flutter pub get
```

### 실행

```bash
# 디버그 모드
flutter run

# 릴리스 모드
flutter run --release
```

### 빌드

```bash
# APK 생성
flutter build apk --release

# App Bundle 생성 (Play Store 배포용)
flutter build appbundle --release
```

---

## 📊 상태 관리 구조

### Provider 패턴 사용

**SpeedDialProvider**: 단축키 데이터 관리
```dart
- buttons: List<SpeedDialButton>       // 현재 표시 중인 버튼 목록
- allButtons: List<SpeedDialButton>    // 전체 버튼 목록
- groups: List<String>                 // 그룹 목록 (DB에서 로드, 전체 탭 없음)
- selectedGroup: String                // 선택된 그룹
- isEditMode: bool                     // 편집 모드 여부
- searchQuery: String                  // 검색어
- currentSortOption: SortOption        // 정렬 옵션

// 그룹 관련 메서드
- loadGroups()                         // DB에서 그룹 로드
- addCustomGroup(String groupName)     // 새 그룹 추가 (DB 저장)
- renameGroup(oldName, newName)        // 그룹 이름 변경
- deleteGroup(groupName)               // 그룹 삭제 (버튼 포함)
- reorderGroups(oldIndex, newIndex)    // 그룹 순서 변경 (v1.14.0)

// 버튼 관련 메서드
- getButtonsForGroup(String group)     // 특정 그룹의 버튼 목록 반환
- moveButtonToGroup(button, newGroup)  // 버튼을 다른 그룹으로 이동
```

**SettingsProvider**: 앱 설정 관리
```dart
- themeMode: ThemeMode                 // 테마 모드 (v1.11.0부터 라이트 모드 고정)
- sortOption: SortOption               // 정렬 옵션
- autoBackupEnabled: bool              // 자동 백업 설정
- showLastCalled: bool                 // 최근 통화 표시 설정
```

---

## 🐛 알려진 이슈 및 제한사항

1. **드래그 그룹 이동 제한**
   - 첫 번째/마지막 탭에서 범위 밖으로 이동 불가
   - 드래그 중 탭 전환 불가 (라이브러리 제약, 확인 다이얼로그 방식으로 대체)

2. **위젯 업데이트 지연**
   - 위젯 데이터 변경 시 즉시 반영되지 않을 수 있음
   - 해결: 위젯 재배치 또는 앱 재시작

---

## ✨ 개발 히스토리

### v1.14.0 (2024-11-29)
- **그룹 탭 드래그 순서 변경 기능**
  - 편집 모드에서 그룹 탭을 드래그하여 순서 변경
  - 갭 기반 드래그: 탭 사이의 공간을 드래그 타겟으로 사용
  - 실시간 미리보기: 드래그 중 탭 재배열 실시간 표시
  - 파란색 드롭 인디케이터로 삽입 위치 시각화
  - 백업 처리: onAccept 미호출 시 onDragEnd에서 처리
  - 마지막 갭 지원: 마지막 위치로도 이동 가능
  - DB 저장: groups 테이블의 position 컬럼에 순서 저장
- **수정된 파일**
  - `lib/screens/home_screen.dart`: 갭 기반 드래그 구조 구현
  - `lib/providers/speed_dial_provider.dart`: reorderGroups 유효성 검사 수정

### v1.13.0 (2024-11-28)
- **애니메이션 최적화**
  - 탭 전환 시 버튼 등장 애니메이션 제거 (즉각적인 반응)
  - 그리드 전환 애니메이션 제거 (부드러운 UX)
  - 편집 모드 버튼 흔들림 효과 유지 (시각적 피드백)
- **확장된 색상 팔레트 (30개)**
  - 기존 20개 → 30개로 확장
  - 빨주노초파남보검 기본 색상 우선 배치
  - 흰색, 검정 추가
  - 진한 톤, 중간 톤, 파스텔 톤 등 다양한 색상
- **스마트 색상 자동 적용**
  - 새 단축키 추가 시 같은 그룹의 마지막 버튼 색상 자동 적용
  - 그룹 변경 시 해당 그룹의 마지막 버튼 색상으로 자동 변경
  - 빈 그룹은 기본 파란색 유지
- **색상 UI 개선**
  - 스크롤 가능한 색상 그리드 (높이 270.h)
  - 흰색 버튼 가시성 향상 (진한 테두리)
  - 밝은 색/어두운 색에 따른 스마트 체크마크 색상
- **수정된 파일**
  - `lib/screens/home_screen.dart`: 버튼 등장 애니메이션 제거
  - `lib/widgets/dial_button_widget.dart`: 편집 모드 흔들림 유지
  - `lib/widgets/color_picker_widget.dart`: 30개 색상, 빨주노초파남보검 추가
  - `lib/screens/add_button_screen.dart`: 스마트 색상 자동 적용

### v1.12.0 (2024-11-28)
- **"전체" 탭 제거**
  - 모든 그룹이 사용자 정의 그룹으로 동일하게 관리
  - 그룹이 없을 때 "새 그룹 만들기" 안내 화면 표시
  - 검색 시 모든 그룹의 버튼에서 검색
- **TabController 동기화 개선**
  - 캐싱된 그룹 목록(`_cachedGroups`) 사용
  - 그룹 추가/삭제 시 발생하던 길이 불일치 오류 해결
  - `RangeError`, `Controller's length property does not match` 오류 수정
- **위젯 통신 채널명 수정**
  - `com.example.quick_call/widget` → `com.oceancode.quick_call/widget`
  - `MissingPluginException` 오류 해결
- **버튼 간격 조정**
  - GridView 간격: 12 → 26 (버튼 크기 감소)
- **수정된 파일**
  - `lib/providers/speed_dial_provider.dart`: 전체 탭 제거, 그룹 로직 수정
  - `lib/screens/home_screen.dart`: TabController 캐싱, 빈 그룹 상태 UI
  - `lib/services/widget_service.dart`: 채널명 수정

### v1.11.0 (2024-11-28)
- **다크모드 호환성 개선**
  - 시스템 테마와 관계없이 항상 라이트 모드로 고정
  - `ThemeMode.system` → `ThemeMode.light`로 기본값 변경
  - 설정 화면에서 다크모드 토글 제거
  - 텍스트 가시성 문제 완전 해결
- **UI 개선**
  - "새 그룹 만들기" AlertDialog → ModalBottomSheet로 변경
  - 키보드 오버플로우 에러 해결 (`isScrollControlled: true` 적용)
  - 키보드 높이에 따른 자동 padding 조정
- **테마 시스템 개선**
  - 하드코딩된 색상을 Theme 기반 색상으로 변경
  - add_button_screen, edit_button_screen, settings_screen 색상 시스템 통일
- **수정된 파일**
  - `lib/providers/settings_provider.dart`: 기본 테마 라이트 모드 고정
  - `lib/screens/settings_screen.dart`: 다크모드 토글 제거
  - `lib/screens/home_screen.dart`: BottomSheet 방식의 그룹 생성 다이얼로그
  - `lib/screens/add_button_screen.dart`: Theme 색상 적용
  - `lib/screens/edit_button_screen.dart`: Theme 색상 적용

### v1.10.0 (2024-12)
- **정사각형 버튼 디자인**
- **스마트 폰트 크기 조절**
- **주소록 버튼 위치 개선**

### v1.9.0 (2024-12)
- **그룹 영구 저장 시스템**
- **백업/복원 그룹 지원**
- **드래그 그룹 이동 방식 개선**

### v1.8.0 (2024-12)
- **그룹별 기본값 자동 선택**
- **드래그로 그룹 간 버튼 이동**

### v1.7.0 (2024-12)
- **하이브리드 줄바꿈 시스템 추가**
- **글자수 제한 제거**

### v1.6.0 (2024-12)
- **그룹 편집 UX 통일**
- **편집 모드 스와이프 활성화**
- **인라인 버튼 추가 기능**

### v1.5.0 (2024-12)
- **스와이프 탭 전환 기능 추가**
- **색상 선택 UI 개선**

### v1.4.0 (2024-12)
- **색상 커스터마이징 시스템 추가**
- **버튼 UI 대폭 개선**

### v1.3.0 (2024-12)
- **그룹 관리 시스템 개선**

### v1.2.0 (2024-12)
- **버튼 조작 방식 개선**

### v1.1.0 (2024-12)
- **위젯 UI 대폭 개선**

### v1.0.0 (2024)
- 초기 릴리스

---

**Made with ❤️ using Flutter**