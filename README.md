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
- ✅ **색상 커스터마이징**: 버튼별 배경색 지정 가능 (20가지 색상 팔레트)
- ✅ **컴팩트 색상 선택 UI**: 스크롤 없이 20개 색상을 한눈에 확인
- ✅ **큰 텍스트**: 아이콘 없이 이름만 크게 표시 (최대 36sp, 자동 크기 조정)
- ✅ **하이브리드 줄바꿈**: 공백/구분자/패턴 인식으로 의미 단위 자동 줄바꿈
- ✅ **글자수 무제한**: 이름 입력 글자수 제한 없음 (긴 이름도 자동 줄바꿈 처리)
- ✅ **홈 화면 위젯**: 3가지 크기의 위젯 지원 (1×1, 2×3, 3×2)
- ✅ **위젯 전화번호 표시**: 이름과 전화번호를 위젯에 함께 표시 (AutoSize 적용)
- ✅ **연락처 연동**: 기존 연락처에서 전화번호 불러오기
- ✅ **주소록 버튼 위치 개선**: 이름 입력칸 옆에 주소록 불러오기 버튼 배치 (v1.10.0)
- ✅ **그룹 관리**: 가족, 친구, 직장 등 그룹별 분류
- ✅ **그룹 영구 저장**: 빈 그룹도 앱 재시작 후 유지됨 (v1.9.0, DB 그룹 테이블)
- ✅ **그룹 생성**: 우측 하단 FAB 버튼으로 새 그룹 생성
- ✅ **그룹 편집**: 그룹 탭 재클릭으로 그룹 이름 변경 및 삭제 (전체 그룹 제외, 모든 모드에서 동일)
- ✅ **스와이프 탭 전환**: 화면을 좌우로 스와이프하여 그룹 간 자연스럽게 전환 (모든 모드에서 동작)
- ✅ **인라인 버튼 추가**: 각 그룹 마지막에 점선 테두리 + 버튼으로 빠른 추가
- ✅ **그룹별 기본값 자동 선택**: 단축키 추가 시 현재 탭의 그룹이 기본 선택됨 (v1.8.0)
- ✅ **드래그로 그룹 간 이동**: 편집 모드에서 버튼을 가장자리로 드래그하여 다른 그룹으로 이동 (v1.9.0 개선)
- ✅ **드래그 앤 드롭**: 편집 모드에서 순서 변경 가능
- ✅ **검색 기능**: 이름/전화번호로 빠른 검색
- ✅ **다크 모드**: 라이트/다크 테마 지원
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
    │   └── speed_dial_provider.dart  # 단축키 데이터 관리 (그룹 DB 연동)
    │
    ├── screens/                      # 화면 UI
    │   ├── home_screen.dart          # 메인 홈 화면 (정사각형 버튼, 드래그 그룹 이동)
    │   ├── add_button_screen.dart    # 단축키 추가 화면 (주소록 버튼 이름 옆 배치)
    │   ├── edit_button_screen.dart   # 단축키 편집 화면 (주소록 버튼 이름 옆 배치)
    │   └── settings_screen.dart      # 설정 화면
    │
    ├── services/                     # 비즈니스 로직
    │   ├── database_service.dart     # SQLite 데이터베이스 관리 (버전 6, groups 테이블)
    │   ├── phone_service.dart        # 전화 걸기 기능
    │   ├── permission_service.dart   # 권한 관리
    │   ├── widget_service.dart       # 위젯 통신 (color 지원)
    │   └── backup_service.dart       # 백업/복원 기능 (버전 1.1.0, 그룹 포함)
    │
    ├── utils/                        # 유틸리티
    │   ├── phone_formatter.dart      # 전화번호 포맷팅
    │   ├── error_handler.dart        # 에러 처리
    │   └── sort_options.dart         # 정렬 옵션
    │
    └── widgets/                      # 재사용 가능한 위젯
        ├── dial_button_widget.dart       # 단축키 버튼 UI (스마트 폰트 크기, 가중치 기반)
        ├── color_picker_widget.dart      # 색상 선택 위젯 (컴팩트 5x4 그리드)
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
- "전체" 그룹은 가상 그룹으로 DB에 저장되지 않음
- 빈 그룹도 앱 재시작 후 유지됨
- 그룹 순서 커스터마이징 가능 (향후 확장)

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

### 1. 정사각형 버튼 디자인 (v1.10.0)

**기능 설명**:
- 홈 화면의 단축키 버튼이 정사각형으로 표시됨
- 모든 그리드(일반/편집/검색 모드)에서 일관된 버튼 형태

**구현**:
```dart
// home_screen.dart - GridView의 childAspectRatio
gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
  crossAxisCount: 3,
  childAspectRatio: 1.0,  // 정사각형 (이전: 0.85)
  crossAxisSpacing: 12.w,
  mainAxisSpacing: 12.h,
),
```

**UI 변경**:
```
변경 전 (세로로 긴 직사각형):     변경 후 (정사각형):
┌─────┐ ┌─────┐ ┌─────┐          ┌────┐ ┌────┐ ┌────┐
│     │ │     │ │     │          │    │ │    │ │    │
│엄마 │ │아빠 │ │동생 │          │엄마│ │아빠│ │동생│
│     │ │     │ │     │          │    │ │    │ │    │
│     │ │     │ │     │          └────┘ └────┘ └────┘
└─────┘ └─────┘ └─────┘
```

### 2. 스마트 폰트 크기 조절 시스템 (v1.10.0)

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

**예시 계산**:
| 텍스트 | 실제 글자수 | 유효 글자수 | 최대 폰트 |
|--------|------------|-------------|-----------|
| 엄마 | 2 | 2.0 | 36sp |
| 119 | 3 | 1.5 | 36sp |
| Mom | 3 | 1.6 | 36sp |
| ABC마트 | 5 | 3.8 | 30sp |
| Pizza | 5 | 2.6 | 30sp |

**구현**:
```dart
// dial_button_widget.dart
double _getCharWeight(String char) {
  final codeUnit = char.codeUnitAt(0);
  
  if (codeUnit >= 0xAC00 && codeUnit <= 0xD7A3) return 1.0;  // 한글
  if (codeUnit >= 0x41 && codeUnit <= 0x5A) return 0.6;      // 대문자
  if (codeUnit >= 0x61 && codeUnit <= 0x7A) return 0.5;      // 소문자
  if (codeUnit >= 0x30 && codeUnit <= 0x39) return 0.5;      // 숫자
  // ...
}

double _calculateEffectiveLength(String name) {
  double effectiveLength = 0;
  for (int i = 0; i < name.length; i++) {
    effectiveLength += _getCharWeight(name[i]);
  }
  return effectiveLength;
}
```

### 3. 주소록 버튼 위치 개선 (v1.10.0)

**기능 설명**:
- 연락처 불러오기 버튼을 전화번호 입력칸에서 이름 입력칸 옆으로 이동
- 연락처 선택 시 이름과 전화번호가 동시에 채워지므로 더 직관적인 UX

**UI 변경**:
```
변경 전:                          변경 후:
┌────────────────────────┐        ┌────────────────────────┐
│ 이름                   │        │ 이름                   │
│ ┌────────────────────┐ │        │ ┌──────────────┐ ┌──┐ │
│ │ [이름 입력]         │ │        │ │ [이름 입력]   │ │📒│ │
│ └────────────────────┘ │        │ └──────────────┘ └──┘ │
│                        │        │                        │
│ 전화번호               │        │ 전화번호               │
│ ┌──────────────┐ ┌──┐ │        │ ┌────────────────────┐ │
│ │ [전화번호]    │ │📒│ │        │ │ [전화번호]          │ │
│ └──────────────┘ └──┘ │        │ └────────────────────┘ │
└────────────────────────┘        └────────────────────────┘
```

**적용 화면**:
- `add_button_screen.dart`: 단축키 추가 화면
- `edit_button_screen.dart`: 단축키 편집 화면

### 4. 그룹 영구 저장 시스템 (v1.9.0)

**기능 설명**:
- 그룹 정보를 별도 테이블(`groups`)에 저장
- 빈 그룹(버튼이 없는 그룹)도 앱 재시작 후 유지
- 백업/복원 시 그룹 데이터도 함께 처리

**기존 문제**:
```
그룹 생성 → 버튼 없이 앱 종료 → 앱 재시작 → 그룹 사라짐 ❌
```

**해결 후**:
```
그룹 생성 → DB에 저장 → 앱 재시작 → 그룹 유지됨 ✅
```

**구현**:
```dart
// database_service.dart - 그룹 CRUD
Future<int> insertGroup(String groupName) async { ... }
Future<bool> deleteGroup(String groupName) async { ... }
Future<int> renameGroup(String oldName, String newName) async { ... }
Future<bool> groupExists(String groupName) async { ... }
Future<List<String>> getAllGroups() async { ... }

// speed_dial_provider.dart - 그룹 관리
Future<bool> addCustomGroup(String groupName) async {
  // DB에 그룹 추가
  final id = await _databaseService.insertGroup(groupName);
  if (id > 0) {
    await loadGroups();
    return true;
  }
  return false;
}

Future<void> loadGroups() async {
  final dbGroups = await _databaseService.getAllGroups();
  _groups = ['전체', ...dbGroups];  // "전체"는 가상 그룹
  notifyListeners();
}
```

### 5. 그룹별 기본값 자동 선택 (v1.8.0)

**기능 설명**:
- 단축키 추가 시 현재 활성화된 탭의 그룹이 기본 선택됨
- 사용자가 그룹을 따로 선택할 필요 없이 빠르게 추가 가능

**동작 방식**:
```
"가족" 탭에서 "+" 버튼 클릭
   ↓
AddButtonScreen 열림
   ↓
그룹 선택 드롭다운 기본값: "가족" ✅

"전체" 탭에서 "+" 버튼 클릭
   ↓
AddButtonScreen 열림
   ↓
그룹 선택 드롭다운 기본값: 첫 번째 사용 가능한 그룹
```

### 6. 드래그로 그룹 간 버튼 이동 (v1.9.0 개선)

**기능 설명**:
- 편집 모드에서 버튼을 화면 가장자리로 드래그하여 다른 그룹으로 이동
- 1초 유지 후 손을 떼면 확인 다이얼로그 표시
- "전체" 그룹으로는 이동 불가

**동작 방식**:
```
편집 모드에서 버튼 롱프레스 → 드래그 시작
   ↓
화면 왼쪽/오른쪽 가장자리(50px)로 이동
   ↓
파란색 인디케이터 표시 + 타겟 그룹명
   ↓
1초 유지 → 스낵바: "손을 떼면 'XX' 그룹으로 이동합니다"
   ↓
손을 뗌 (드래그 종료)
   ↓
확인 다이얼로그: "'버튼명'을 'XX' 그룹으로 이동하시겠습니까?"
   ↓
"이동" 클릭 → 버튼 그룹 변경 + 해당 탭으로 전환
```

### 7. 색상 커스터마이징 시스템

**색상 팔레트** (5×4 그리드, 20가지 색상):
```dart
// Row 1 - 진한 색상
빨강(#E53935), 분홍(#D81B60), 보라(#8E24AA), 파랑(#3949AB), 청록(#00ACC1)

// Row 2 - 중간 톤
올리브(#9E9D24), 노랑(#FFB300), 갈색(#6D4C41), 초록(#43A047), 회색(#546E7A)

// Row 3 - 연한 파스텔
연한 빨강(#FFCDD2), 연한 분홍(#F8BBD0), 연한 보라(#E1BEE7), 
연한 파랑(#BBDEFB), 연한 청록(#B2EBF2)

// Row 4 - 더 연한 톤
연한 올리브(#F0F4C3), 연한 노랑(#FFF9C4), 연한 갈색(#D7CCC8), 
연한 초록(#C8E6C9), 연한 회색(#CFD8DC)
```

**자동 텍스트 색상 결정**:
- 밝은 배경색(명도 > 0.5): 검은색 텍스트
- 어두운 배경색(명도 ≤ 0.5): 흰색 텍스트
- `Color.computeLuminance()` 사용

### 8. 하이브리드 줄바꿈 시스템 (v1.7.0)

버튼 이름을 의미 단위로 자동 줄바꿈하여 가독성을 높이는 시스템입니다.

**처리 우선순위**:
```
1. 구분자 체크 (/, |) → 구분자 기준 분리
2. 공백 체크 → 공백 기준 최적 분배
3. 패턴 인식 → 직책/이름/조직/회사 자동 분리
4. Fallback (7글자+) → 균등 분할
5. 짧은 텍스트 (6글자-) → 그대로 1줄
```

### 9. 버튼 조작 방식

**일반 모드**:
- **클릭(탭)**: 버튼 편집 화면 열기
- **롱프레스(꾹 누르기)**: 전화 걸기 (햅틱 피드백)

**편집 모드**:
- **클릭(탭)**: 버튼 편집 화면 열기
- **X 버튼**: 버튼 삭제
- **드래그**: 순서 변경
- **가장자리 드래그**: 다른 그룹으로 이동 (1초 유지 → 손 떼면 확인창)

### 10. 스와이프 탭 전환 (v1.5.0)

- 화면을 좌우로 스와이프하여 그룹 탭 간 자연스럽게 전환
- 탭 클릭과 스와이프 모두 지원
- **모든 모드(일반/편집)에서 스와이프 가능**

### 11. 인라인 버튼 추가 (v1.6.0)

- 각 그룹의 버튼 그리드 마지막에 점선 테두리의 "+" 버튼 표시
- 클릭 시 단축키 추가 화면 열기 (현재 그룹 기본 선택)
- 편집 모드에서는 숨김 처리

### 12. 그룹 관리 시스템

**기본 그룹 정책**:
- **"전체" 그룹만 기본 그룹**으로 존재 (가상 그룹, DB에 저장 안 됨)
- 편집 및 삭제 불가능

**사용자 그룹**:
- 그룹 이름 변경 가능 (최대 10자)
- 그룹 삭제 시 해당 그룹의 모든 버튼도 함께 삭제
- **빈 그룹도 영구 저장** (v1.9.0)

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
- groups: List<String>                 // 그룹 목록 (DB에서 로드)
- selectedGroup: String                // 선택된 그룹
- isEditMode: bool                     // 편집 모드 여부
- searchQuery: String                  // 검색어
- currentSortOption: SortOption        // 정렬 옵션

// 그룹 관련 메서드
- loadGroups()                         // DB에서 그룹 로드
- addCustomGroup(String groupName)     // 새 그룹 추가 (DB 저장)
- renameGroup(oldName, newName)        // 그룹 이름 변경
- deleteGroup(groupName)               // 그룹 삭제 (버튼 포함)

// 버튼 관련 메서드
- getButtonsForGroup(String group)     // 특정 그룹의 버튼 목록 반환
- moveButtonToGroup(button, newGroup)  // 버튼을 다른 그룹으로 이동
```

---

## 🐛 알려진 이슈 및 제한사항

1. **드래그 그룹 이동 제한**
   - "전체" 그룹으로는 버튼 이동 불가 (의도된 동작)
   - 첫 번째/마지막 탭에서 범위 밖으로 이동 불가
   - 드래그 중 탭 전환 불가 (라이브러리 제약, 확인 다이얼로그 방식으로 대체)

2. **위젯 업데이트 지연**
   - 위젯 데이터 변경 시 즉시 반영되지 않을 수 있음
   - 해결: 위젯 재배치 또는 앱 재시작

---

## ✨ 개발 히스토리

### v1.10.0 (2024-12)
- **정사각형 버튼 디자인**
  - `childAspectRatio`를 1.0으로 변경
  - 모든 그리드(일반/편집/검색)에 적용
- **스마트 폰트 크기 조절**
  - 가중치 기반 유효 글자수 계산
  - 한글/영문/숫자별 차등 가중치 적용
  - 유효 글자수 구간별 최대 폰트 크기 설정
- **주소록 버튼 위치 개선**
  - 전화번호 입력칸 → 이름 입력칸 옆으로 이동
  - 추가/편집 화면 모두 적용
- **수정된 파일**
  - `lib/screens/home_screen.dart`: 정사각형 버튼
  - `lib/screens/add_button_screen.dart`: 주소록 버튼 위치
  - `lib/screens/edit_button_screen.dart`: 주소록 버튼 위치
  - `lib/widgets/dial_button_widget.dart`: 스마트 폰트 크기

### v1.9.0 (2024-12)
- **그룹 영구 저장 시스템**
  - `groups` 테이블 추가 (DB 버전 6)
  - 빈 그룹도 앱 재시작 후 유지됨
  - 기존 버튼의 그룹 정보 자동 마이그레이션
- **백업/복원 그룹 지원**
  - 백업 버전 1.1.0으로 업그레이드
  - 백업 파일에 그룹 데이터 포함
  - 구버전(1.0.0) 백업 파일 호환성 유지
- **드래그 그룹 이동 방식 개선**
  - 기존: 드래그 중 즉시 탭 전환 (에러 발생)
  - 변경: 1초 유지 후 손 떼면 확인 다이얼로그 표시
  - `reorderable_grid_view` 라이브러리 unmount 에러 해결

### v1.8.0 (2024-12)
- **그룹별 기본값 자동 선택**
  - `AddButtonScreen`에 `initialGroup` 파라미터 추가
  - 홈 화면에서 "+" 버튼 클릭 시 현재 탭의 그룹이 기본 선택됨
- **드래그로 그룹 간 버튼 이동**
  - 편집 모드에서 버튼을 화면 가장자리(50px)로 드래그
  - 시각적 피드백: 가장자리 인디케이터 (파란색/빨간색)
  - `SpeedDialProvider`에 `moveButtonToGroup()` 메서드 추가

### v1.7.0 (2024-12)
- **하이브리드 줄바꿈 시스템 추가**
- **글자수 제한 제거**
- **패턴 사전 구축**

### v1.6.0 (2024-12)
- **그룹 편집 UX 통일**
- **편집 모드 스와이프 활성화**
- **인라인 버튼 추가 기능**
- **그룹 생성 FAB 버튼**

### v1.5.0 (2024-12)
- **스와이프 탭 전환 기능 추가**
- **색상 선택 UI 개선**
- **Provider 개선**

### v1.4.0 (2024-12)
- **색상 커스터마이징 시스템 추가**
- **버튼 UI 대폭 개선**
- **데이터베이스 v5 마이그레이션**

### v1.3.0 (2024-12)
- **그룹 관리 시스템 개선**

### v1.2.0 (2024-12)
- **버튼 조작 방식 개선 (UX 혁신)**

### v1.1.0 (2024-12)
- **위젯 UI 대폭 개선**

### v1.0.0 (2024)
- 초기 릴리스

---

**Made with ❤️ using Flutter**