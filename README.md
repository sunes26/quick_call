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
- ✅ **색상 커스터마이징**: 버튼별 배경색 지정 가능 (20가지 색상 팔레트)
- ✅ **컴팩트 색상 선택 UI**: 스크롤 없이 20개 색상을 한눈에 확인
- ✅ **큰 텍스트**: 아이콘 없이 이름만 크게 표시 (최대 22sp, 자동 크기 조정)
- ✅ **홈 화면 위젯**: 3가지 크기의 위젯 지원 (1×1, 2×3, 3×2)
- ✅ **위젯 전화번호 표시**: 이름과 전화번호를 위젯에 함께 표시 (AutoSize 적용)
- ✅ **연락처 연동**: 기존 연락처에서 전화번호 불러오기
- ✅ **그룹 관리**: 가족, 친구, 직장 등 그룹별 분류
- ✅ **그룹 생성**: 우측 하단 FAB 버튼으로 새 그룹 생성
- ✅ **그룹 편집**: 그룹 탭 재클릭으로 그룹 이름 변경 및 삭제 (전체 그룹 제외, 모든 모드에서 동일)
- ✅ **스와이프 탭 전환**: 화면을 좌우로 스와이프하여 그룹 간 자연스럽게 전환 (모든 모드에서 동작)
- ✅ **인라인 버튼 추가**: 각 그룹 마지막에 점선 테두리 + 버튼으로 빠른 추가
- ✅ **드래그 앤 드롭**: 편집 모드에서 순서 변경 가능
- ✅ **검색 기능**: 이름/전화번호로 빠른 검색
- ✅ **다크 모드**: 라이트/다크 테마 지원
- ✅ **백업/복원**: JSON 형식으로 데이터 백업 및 복원
- ✅ **위젯 설정 UI**: 3열 그리드 레이아웃, 직관적인 선택 표시

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
    │   └── speed_dial_provider.dart  # 단축키 데이터 관리 (getButtonsForGroup 메서드 포함)
    │
    ├── screens/                      # 화면 UI
    │   ├── home_screen.dart          # 메인 홈 화면 (TabBarView 스와이프, 인라인 추가 버튼, 그룹 생성 FAB)
    │   ├── add_button_screen.dart    # 단축키 추가 화면 (색상 선택)
    │   ├── edit_button_screen.dart   # 단축키 편집 화면 (색상 선택)
    │   └── settings_screen.dart      # 설정 화면
    │
    ├── services/                     # 비즈니스 로직
    │   ├── database_service.dart     # SQLite 데이터베이스 관리 (버전 5)
    │   ├── phone_service.dart        # 전화 걸기 기능
    │   ├── permission_service.dart   # 권한 관리
    │   ├── widget_service.dart       # 위젯 통신 (color 지원)
    │   └── backup_service.dart       # 백업/복원 기능
    │
    ├── utils/                        # 유틸리티
    │   ├── phone_formatter.dart      # 전화번호 포맷팅
    │   ├── error_handler.dart        # 에러 처리
    │   └── sort_options.dart         # 정렬 옵션
    │
    └── widgets/                      # 재사용 가능한 위젯
        ├── dial_button_widget.dart       # 단축키 버튼 UI (색상 배경, 큰 텍스트)
        ├── color_picker_widget.dart      # 색상 선택 위젯 (컴팩트 5x4 그리드)
        ├── contact_picker_widget.dart    # 연락처 선택 위젯
        ├── empty_state_widget.dart       # 빈 상태 UI
        ├── loading_widget.dart           # 로딩 UI
        ├── permission_dialog.dart        # 권한 안내 다이얼로그
        ├── duplicate_phone_dialog.dart   # 중복 전화번호 확인 다이얼로그
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

### speed_dial_buttons 테이블 (버전 5)

| 컬럼 | 타입 | 설명 |
|------|------|------|
| id | INTEGER | 기본 키 (자동 증가) |
| name | TEXT | 버튼 이름 (최대 10자) |
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

**마이그레이션 히스토리**:
- v1-v2: group 컬럼 추가
- v2-v3: isInWidget, widgetPosition 컬럼 추가
- v3-v4: color 컬럼 추가
- v4-v5: iconCodePoint, iconFontFamily, iconFontPackage 컬럼 제거

---

## 🎨 주요 기능 구현

### 1. 색상 커스터마이징 시스템

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

**컴팩트 색상 선택 UI** (v1.5.0):
```
┌─────────────────────────┐
│  버튼 색상 선택  ⚫      │  ← 제목 + 미리보기 한 줄
│                         │
│   ● ● ● ● ●            │
│   ● ● ● ● ●            │  ← 스크롤 없이 한눈에
│   ● ● ● ● ●            │
│   ● ● ● ● ●            │
│                         │
│   [취소]     [확인]     │
└─────────────────────────┘
```

**자동 텍스트 색상 결정**:
- 밝은 배경색(명도 > 0.5): 검은색 텍스트
- 어두운 배경색(명도 ≤ 0.5): 흰색 텍스트
- `Color.computeLuminance()` 사용

### 2. 버튼 UI 개선

**변경 전** (v1.2.0 이전):
```
┌─────────────────┐
│   Spacer(2)     │
│   ┌─────┐       │
│   │ 👤  │ Icon  │
│   └─────┘       │
│   Spacer(1)     │
│   이름 (15sp)   │
│   Spacer(2)     │
└─────────────────┘
```

**변경 후** (v1.3.0):
```
┌─────────────────┐
│   (색상 배경)   │
│                 │
│   이름 (22sp)   │
│   AutoSizeText  │
│   Bold          │
│                 │
└─────────────────┘
```

**텍스트 크기 설정**:
- 기본: 22sp (Bold)
- 최소: 12sp
- 최대: 22sp
- 최대 3줄 표시
- AutoSizeText로 자동 크기 조정

### 3. 버튼 조작 방식

**일반 모드**:
- **클릭(탭)**: 버튼 편집 화면 열기
  - 빠른 정보 수정 및 확인
  - 즉시 접근 가능
- **롱프레스(꾹 누르기)**: 전화 걸기
  - 실수로 전화 걸림 방지
  - 햅틱 피드백(진동)으로 명확한 피드백
  - `HapticFeedback.mediumImpact()` 적용

**편집 모드**:
- **클릭(탭)**: 버튼 편집 화면 열기
- **X 버튼**: 버튼 삭제
- **드래그**: 순서 변경

**구현 위치**:
- `lib/widgets/dial_button_widget.dart`: GestureDetector로 onTap/onLongPress 처리
- `lib/screens/home_screen.dart`: 각 모드별 핸들러 구현

### 4. 스와이프 탭 전환 (v1.5.0)

**기능 설명**:
- 화면을 좌우로 스와이프하여 그룹 탭 간 자연스럽게 전환
- 탭 클릭과 스와이프 모두 지원
- TabBar와 TabBarView 연동으로 부드러운 애니메이션
- **모든 모드(일반/편집)에서 스와이프 가능** (v1.6.0)

**모드별 동작**:
```
일반 모드 & 편집 모드:
[전체] [가족] [친구]     ← 탭 클릭 OR 스와이프로 전환
┌─────────────────┐
│                 │
│  👆 좌우 스와이프 │  ← 자연스럽게 다음 탭으로 전환
│       ←  →      │
└─────────────────┘

검색 모드:
┌─────────────────┐
│                 │
│  검색 결과 표시  │  ← 스와이프 없이 단일 그리드
│                 │
└─────────────────┘
```

**구현 방식**:
- `TabBarView` 위젯 사용
- `TabController`로 탭과 페이지 동기화
- 모든 모드에서 `ClampingScrollPhysics()`로 자연스러운 스와이프

**Provider 추가 메서드**:
```dart
// 특정 그룹의 버튼 목록 반환 (TabBarView용)
List<SpeedDialButton> getButtonsForGroup(String group)
```

### 5. 인라인 버튼 추가 (v1.6.0)

**기능 설명**:
- 각 그룹의 버튼 그리드 마지막에 점선 테두리의 "+" 버튼 표시
- 클릭 시 단축키 추가 화면 열기
- 편집 모드에서는 숨김 처리

**UI 구현**:
```
일반 모드:
┌─────────────────────────────────┐
│ [전체] [가족] [친구]            │
├─────────────────────────────────┤
│                                 │
│  ┌─────┐  ┌─────┐  ┌─────┐     │
│  │ 엄마 │  │ 아빠 │  │ 동생 │     │
│  └─────┘  └─────┘  └─────┘     │
│                                 │
│  ┌─────┐  ┌╌╌╌╌╌┐              │
│  │ 친구 │  ┊  +  ┊  ← 점선 테두리  │
│  └─────┘  └╌╌╌╌╌┘     클릭 시 추가 │
│                                 │
│                         [📁]   │
└─────────────────────────────────┘

편집 모드:
┌─────────────────────────────────┐
│ [전체] [가족] [친구]            │
├─────────────────────────────────┤
│                                 │
│  ┌─────┐  ┌─────┐  ┌─────┐     │
│  │ 엄마 │  │ 아빠 │  │ 동생 │     │
│  └─────┘  └─────┘  └─────┘     │
│                                 │
│  ┌─────┐                       │
│  │ 친구 │  (+ 버튼 숨김)         │
│  └─────┘                       │
│                                 │
└─────────────────────────────────┘
```

**점선 테두리 구현**:
```dart
// DashedBorderPainter - CustomPainter로 구현
class DashedBorderPainter extends CustomPainter {
  final Color color;          // 테두리 색상
  final double strokeWidth;   // 선 두께
  final double gap;           // 점선 간격
  final double dashWidth;     // 점선 길이
  final double borderRadius;  // 모서리 둥글기
}
```

### 6. 그룹 관리 시스템

**기본 그룹 정책**:
- **"전체" 그룹만 기본 그룹**으로 존재
- 모든 버튼을 표시하는 특수 그룹
- 편집 및 삭제 불가능

**사용자 그룹**:
- 사용자가 자유롭게 그룹 생성 가능
- 그룹 이름 변경 가능 (최대 10자)
- 그룹 삭제 시 해당 그룹의 모든 버튼도 함께 삭제

**그룹 생성 방법** (v1.6.0):
```
우측 하단 FAB(📁) 버튼 클릭
→ 그룹 생성 다이얼로그 표시
   ┌─────────────────────────────┐
   │  📁  새 그룹 만들기          │
   │                             │
   │ [📁 그룹 이름_______] (0/10) │
   │                             │
   │       [취소]    [만들기]    │
   └─────────────────────────────┘
```

**그룹 편집 방법** (모든 모드에서 동일):
```
현재 활성화된 그룹 탭을 다시 클릭
→ 그룹 편집 바텀시트 표시
   ┌─────────────────────────────┐
   │   그룹 편집                  │
   │ [가족____________] (10/10)  │
   │                             │
   │ [그룹제거] [취소] [확인]    │
   └─────────────────────────────┘
```

**그룹 편집 UI**:
- 그룹 이름 수정 필드 (TextField)
- 왼쪽: 그룹 제거 버튼 (빨간색)
- 오른쪽: 취소, 확인 버튼
- 바텀시트 형태로 표시
- **일반 모드와 편집 모드 모두에서 동일하게 동작** (v1.6.0)

**구현 위치**:
- `lib/widgets/group_edit_dialog.dart`: 그룹 편집 바텀시트 UI
- `lib/screens/home_screen.dart`: 탭 재클릭 감지, 그룹 생성 FAB, 편집 로직
- `lib/providers/speed_dial_provider.dart`: 그룹 데이터 관리

### 7. 위젯 시스템

**3가지 위젯 크기 지원**:
- **1×1**: 단일 버튼 (긴급 전화 등)
- **2×3**: 세로 방향 6개 버튼
- **3×2**: 가로 방향 6개 버튼

**위젯 UI 개선**:
- 이름과 전화번호를 함께 표시
- Android AutoSizeText 적용으로 텍스트 자동 크기 조정
- 전화번호가 길어도 잘리지 않고 자동으로 글자 크기 축소
- 최소/최대 폰트 크기 설정으로 가독성 보장

**위젯 설정 화면**:
- 3열 그리드 레이아웃으로 한눈에 버튼 확인
- 사람 아이콘(👤)으로 통일된 디자인
- 선택 시 파란색 테두리로 명확한 피드백
- 클릭 영역 최적화로 터치 반응 개선

**위젯 구현 흐름**:
```
1. 사용자가 홈 화면에 위젯 추가
2. WidgetConfigActivity 실행 (네이티브)
3. 3열 그리드에서 버튼 선택 (파란색 테두리로 표시)
4. SharedPreferences에 JSON 저장 (color 값 포함)
5. SpeedDialWidgetProvider가 UI 업데이트
6. 위젯에 이름 + 전화번호 표시 (AutoSize)
7. 버튼 클릭 시 ACTION_CALL Intent 발생
```

**Flutter ↔ Native 통신** (MethodChannel):
```kotlin
// MainActivity.kt
"saveAllButtonsData"  // 전체 버튼 데이터 저장 (color 포함)
"updateWidgetData"    // 특정 위젯 업데이트
"refreshAllWidgets"   // 모든 위젯 새로고침
"getWidgetIds"        // 설치된 위젯 ID 목록
"getWidgetData"       // 위젯 데이터 조회
"clearAllWidgets"     // 모든 위젯 데이터 삭제
```

### 8. 위젯 텍스트 자동 크기 조정

**Android AutoSizeText 적용**:
```xml
<TextView
    android:autoSizeTextType="uniform"
    android:autoSizeMinTextSize="5sp"
    android:autoSizeMaxTextSize="12sp"
    android:autoSizeStepGranularity="1sp"
    android:maxLines="1" />
```

**전화번호 표시 위치**:
- 1×1: 이름 아래, 중앙 정렬
- 2×3, 3×2: 각 버튼 이름 아래, 작은 회색 글씨

### 9. 위젯 설정 UI

**레이아웃 구조**:
```xml
<FrameLayout>  <!-- 클릭 영역 확장 -->
  <LinearLayout>
    <ImageView />  <!-- 👤 아이콘 -->
    <TextView />   <!-- 이름 -->
  </LinearLayout>
</FrameLayout>
```

**선택 표시**:
- 미선택: 회색 테두리 (2dp, #E0E0E0)
- 선택: 파란색 테두리 (4dp, #2196F3)
- Drawable 리소스로 동적 변경
- CardView elevation 0으로 이중 테두리 방지

### 10. 권한 관리

**필요한 권한**:
- `CALL_PHONE`: 전화 걸기
- `READ_CONTACTS`: 연락처 읽기
- `INTERNET`: 개발 디버깅 (debug 빌드만)

**권한 요청 흐름**:
```dart
1. PermissionService로 권한 상태 확인
2. 미승인 시 요청 다이얼로그 표시
3. 영구 거부 시 설정 화면으로 안내
4. 승인 시 기능 실행
```

### 11. 전화번호 포맷팅

`PhoneFormatter` 유틸리티 지원:
- 한국 전화번호 형식 자동 변환
- 국제 번호 지원 (+82)
- 긴급 전화 감지 (119, 112 등)
- 유효성 검사

**예시**:
```dart
PhoneFormatter.format('01012345678')  // "010-1234-5678"
PhoneFormatter.format('0212345678')   // "02-1234-5678"
PhoneFormatter.isValid('010-1234-5678') // true
PhoneFormatter.isEmergencyNumber('119') // true
```

### 12. 백업/복원

**백업 데이터 구조** (JSON):
```json
{
  "version": "1.0.0",
  "timestamp": "2024-01-01T12:00:00.000Z",
  "buttonCount": 10,
  "buttons": [
    {
      "id": 1,
      "name": "엄마",
      "phoneNumber": "010-1234-5678",
      "color": 4283215695,
      "group": "가족",
      "position": 0,
      "createdAt": "2024-01-01T12:00:00.000Z",
      "lastCalled": null,
      "isInWidget": 1,
      "widgetPosition": 0
    }
  ]
}
```

**백업 파일 저장 위치**:
- 내부: `{ApplicationDocuments}/quick_call_backup_{timestamp}.json`
- 외부 (내보내기): `/storage/emulated/0/Download/quick_call_backup_{timestamp}.json`

---

## 🚀 빌드 및 실행

### 개발 환경 설정

1. **Flutter SDK 설치**
```bash
# Flutter 3.0 이상 필요
flutter --version
```

2. **Android Studio 설정**
   - Android SDK 26 이상 설치
   - Kotlin 플러그인 활성화

3. **의존성 설치**
```bash
flutter pub get
```

### 실행

**디버그 모드**:
```bash
flutter run
```

**릴리스 모드**:
```bash
flutter run --release
```

### 빌드

**APK 생성**:
```bash
flutter build apk --release
```

**App Bundle 생성** (Play Store 배포용):
```bash
flutter build appbundle --release
```

**생성된 파일 위치**:
- APK: `build/app/outputs/flutter-apk/app-release.apk`
- AAB: `build/app/outputs/bundle/release/app-release.aab`

---

## 🔐 보안 및 권한

### ProGuard 설정

릴리스 빌드 시 코드 난독화 적용:
- Flutter 관련 클래스 보호
- Gson, SQLite 클래스 보호
- 플러그인 클래스 보호

### 서명 키 관리

**프로덕션 배포 시 필수**:
```kotlin
// build.gradle.kts의 release 블록에서
signingConfig = signingConfigs.getByName("debug")  // ← 실제 키로 변경
```

---

## 📊 상태 관리 구조

### Provider 패턴 사용

**SpeedDialProvider**: 단축키 데이터 관리
```dart
- buttons: List<SpeedDialButton>       // 현재 표시 중인 버튼 목록
- allButtons: List<SpeedDialButton>    // 전체 버튼 목록
- groups: List<String>                 // 그룹 목록
- selectedGroup: String                // 선택된 그룹
- isEditMode: bool                     // 편집 모드 여부
- searchQuery: String                  // 검색어
- currentSortOption: SortOption        // 정렬 옵션

// 🆕 v1.5.0 추가 메서드
- getButtonsForGroup(String group)     // 특정 그룹의 버튼 목록 반환
- addCustomGroup(String groupName)     // 새 그룹 추가 (메모리)
```

**SettingsProvider**: 앱 설정 관리
```dart
- themeMode: ThemeMode                 // 테마 모드
- sortOption: SortOption               // 기본 정렬
- autoBackupEnabled: bool              // 자동 백업
- showLastCalled: bool                 // 최근 통화 표시
```

---

## 🎯 주요 화면 설명

### HomeScreen
- 단축키 버튼 그리드 표시 (색상 배경, 큰 텍스트)
- 그룹별 탭 네비게이션
- **스와이프 탭 전환**: TabBarView로 좌우 스와이프 지원 (모든 모드)
- **그룹 편집**: 현재 활성화된 그룹 탭 재클릭 시 편집 바텀시트 표시 (모든 모드에서 동일)
- **그룹 생성**: 우측 하단 FAB(📁) 클릭 시 그룹 생성 다이얼로그 표시
- **인라인 추가 버튼**: 각 그룹 마지막에 점선 테두리 + 버튼 (일반 모드만)
- 검색 기능
- 편집 모드 (드래그 앤 드롭)
- 정렬 옵션
- **버튼 조작**:
  - 일반 모드: 클릭(편집), 롱프레스(전화)
  - 편집 모드: 클릭(편집), 드래그(순서변경)

### AddButtonScreen
- 색상 선택 (5×4 그리드, 20가지 색상)
- 이름 입력 (최대 10자)
- 전화번호 입력
- 연락처에서 가져오기
- 그룹 선택 (동적으로 사용 가능한 그룹 표시)
- 새 그룹 추가
- 중복 전화번호 확인

### EditButtonScreen
- 버튼 정보 수정 (색상 변경 포함)
- 삭제 기능
- AddButtonScreen과 동일한 UI

### SettingsScreen
- 테마 모드 변경
- 정렬 옵션 설정
- 백업/복원
- 데이터베이스 정보
- 앱 정보

### WidgetConfigActivity (Native)
- 3열 그리드 레이아웃으로 버튼 표시
- 사람 아이콘(👤) 통일
- 선택 시 파란색 테두리 (4dp)
- 최대 선택 개수 제한 (1×1: 1개, 2×3/3×2: 6개)
- 선택 불가능한 항목은 투명도 50%

### GroupEditDialog (바텀시트)
- 그룹 이름 수정 필드
- 그룹 제거 버튼 (왼쪽)
- 취소/확인 버튼 (오른쪽)
- 부드러운 바텀시트 애니메이션

### ColorPickerWidget (바텀시트)
- **컴팩트 레이아웃**: 제목과 미리보기를 한 줄로 통합
- 5×4 그리드 레이아웃 (20가지 색상)
- **스크롤 없이** 모든 색상 한눈에 확인
- 선택 시 파란색 테두리 + 체크마크
- 취소/확인 버튼
- 햅틱 피드백

---

## 🐛 알려진 이슈 및 제한사항

1. **위젯 업데이트 지연**
   - 위젯 데이터 변경 시 즉시 반영되지 않을 수 있음
   - 해결: 위젯 재배치 또는 앱 재시작

2. **연락처 권한**
   - Android 11 이상에서 연락처 권한 필요
   - 권한 미승인 시 연락처 가져오기 불가

3. **위젯 크기 제약**
   - 홈 런처에 따라 일부 위젯 크기 미지원 가능
   - 삼성 One UI, Pixel Launcher 등에서 테스트 완료

4. **긴 전화번호 표시**
   - 매우 긴 국제번호의 경우 AutoSize로 글자 크기가 작아질 수 있음
   - 최소 폰트 크기(5sp~6sp) 보장으로 가독성 유지

5. **데이터베이스 마이그레이션**
   - v4 이하에서 v5로 업그레이드 시 자동 마이그레이션
   - 기존 iconCodePoint 데이터는 무시되고 기본 색상 적용
   - 마이그레이션 실패 시 앱 데이터 초기화 필요

6. **빈 그룹 영속성**
   - 빈 그룹(버튼이 없는 그룹)은 앱 재시작 시 사라짐
   - 그룹에 버튼을 추가해야 영구 저장됨

---

## 📝 코딩 컨벤션

### Dart
- **네이밍**: camelCase (변수, 함수), PascalCase (클래스)
- **파일명**: snake_case
- **주석**: 공개 API에 문서 주석 사용
- **포맷팅**: `dart format .`

### Kotlin
- **네이밍**: camelCase (변수, 함수), PascalCase (클래스)
- **파일명**: PascalCase
- **Null Safety**: nullable 타입 명시적 처리

### XML
- **리소스 네이밍**: snake_case
- **ID 네이밍**: snake_case with prefix (`button_`, `text_`, etc.)
- **Drawable**: 용도_설명_상태 (예: `widget_button_selected`)

---

## 🤝 기여 가이드

### 버그 리포트
1. 발생 환경 (Android 버전, 기기 모델)
2. 재현 단계
3. 예상 동작 vs 실제 동작
4. 스크린샷 (가능한 경우)

### 기능 제안
1. 제안 배경 및 목적
2. 예상 사용 시나리오
3. UI/UX 스케치 (선택)

---

## 📄 라이선스

이 프로젝트는 개인 프로젝트이며, 별도의 라이선스가 지정되지 않았습니다.

---

## 📞 연락처

프로젝트 관련 문의사항이 있으시면 이슈를 등록해주세요.

---

## ✨ 개발 히스토리

### v1.6.0 (2024-12)
- **그룹 편집 UX 통일**
  - 편집 모드에서 그룹 탭 옆 수정/X 버튼 제거
  - 모든 모드에서 탭 재클릭으로 그룹 편집 (일관된 UX)
- **편집 모드 스와이프 활성화**
  - 편집 모드에서도 좌우 스와이프로 탭 전환 가능
  - 드래그앤드롭과 자연스럽게 공존
- **인라인 버튼 추가 기능**
  - 각 그룹 마지막에 점선 테두리 "+" 버튼 추가
  - 클릭 시 단축키 추가 화면 열기
  - 편집 모드에서는 숨김 처리
  - `DashedBorderPainter` CustomPainter로 점선 테두리 구현
- **그룹 생성 FAB 버튼**
  - 우측 하단 FloatingActionButton → 그룹 생성 버튼으로 변경
  - 아이콘: `Icons.create_new_folder` (흰색)
  - 클릭 시 새 그룹 생성 다이얼로그 표시
  - 생성 후 새 그룹 탭으로 자동 이동

### v1.5.0 (2024-12)
- **스와이프 탭 전환 기능 추가**
  - 화면 좌우 스와이프로 그룹 탭 간 자연스러운 전환
  - TabBarView 적용으로 부드러운 애니메이션
  - 검색 모드에서는 단일 그리드 유지
- **색상 선택 UI 개선**
  - 컴팩트 레이아웃: 제목과 미리보기를 한 줄로 통합
  - 스크롤 없이 20개 색상을 한눈에 확인 가능
  - 불필요한 여백 제거로 UI 간소화
- **Provider 개선**
  - `getButtonsForGroup()` 메서드 추가 (TabBarView용)
  - 그룹별 버튼 필터링 + 검색 + 정렬 통합 지원

### v1.4.0 (2024-12)
- **색상 커스터마이징 시스템 추가**
  - 버튼별 배경색 지정 기능 (20가지 색상 팔레트)
  - 5×4 그리드 레이아웃의 색상 선택 UI
  - 자동 텍스트 색상 결정 (명도 기반)
- **버튼 UI 대폭 개선**
  - 아이콘 제거, 텍스트만 표시
  - 글자 크기 증가 (15sp → 22sp, Bold)
  - 최대 3줄 표시, AutoSizeText 적용
  - 색상 배경으로 시각적 차별화
- **데이터베이스 v5 마이그레이션**
  - iconCodePoint, iconFontFamily, iconFontPackage 컬럼 제거
  - color 컬럼 추가 (INTEGER, ARGB)
  - 기존 데이터 자동 마이그레이션
- **위젯 시스템 업데이트**
  - 색상 정보 전송 지원
  - widget_service.dart 수정

### v1.3.0 (2024-12)
- **그룹 관리 시스템 개선**
  - 기본 그룹을 "전체"만으로 단순화
  - 그룹 탭 재클릭으로 그룹 편집 기능 추가
  - 그룹 이름 변경 및 삭제 기능 구현
  - 깔끔한 바텀시트 UI로 그룹 편집
- **버그 수정**
  - 단축키 추가 화면의 그룹 드롭다운 에러 수정
  - 동적 그룹 선택으로 안정성 향상

### v1.2.0 (2024-12)
- **버튼 조작 방식 개선 (UX 혁신)**
  - 일반 모드: 클릭으로 편집, 롱프레스로 전화 걸기
  - 햅틱 피드백 추가 (롱프레스 시 진동)
  - 실수로 전화 거는 것 방지
  - 빠른 편집 접근성 향상
- **UI 개선**
  - AppBar 타이틀 간소화: "전화번호 단축키" → "단축키"
  - 타이틀 왼쪽 정렬로 깔끔한 레이아웃

### v1.1.0 (2024-12)
- **위젯 UI 대폭 개선**
  - 위젯에 전화번호 표시 기능 추가
  - Android AutoSizeText 적용으로 텍스트 자동 크기 조정
  - 긴 전화번호도 잘리지 않고 완전히 표시
- **위젯 설정 화면 개선**
  - 2열 → 3열 그리드로 변경
  - 사람 아이콘(👤)으로 통일된 디자인
  - 체크박스 → 파란색 테두리로 선택 표시 방식 변경
  - 클릭 영역 최적화 및 터치 반응 개선
  - 이중 테두리 버그 수정

### v1.0.0 (2024)
- 초기 릴리스
- 단축키 관리 기능
- 3종류 위젯 지원 (1×1, 2×3, 3×2)
- 그룹 관리
- 백업/복원
- 다크 모드
- 검색 및 정렬 기능

---

**Made with ❤️ using Flutter**