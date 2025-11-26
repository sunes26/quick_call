# Quick Call - 전화번호 단축 다이얼 앱

> Android 전용 전화번호 단축 다이얼 앱  
> Flutter 3.0+ / Android 8.0 (API 26) 이상 지원

## 📱 프로젝트 개요

Quick Call은 자주 연락하는 사람에게 빠르게 전화를 걸 수 있도록 도와주는 Android 앱입니다. 홈 화면 위젯을 통해 앱 실행 없이 바로 전화를 걸 수 있습니다.

### 주요 기능

- ✅ **단축 전화번호 관리**: 자주 사용하는 전화번호를 그룹별로 관리
- ✅ **홈 화면 위젯**: 3가지 크기의 위젯 지원 (1×1, 2×3, 3×2)
- ✅ **위젯 전화번호 표시**: 이름과 전화번호를 위젯에 함께 표시 (AutoSize 적용)
- ✅ **즉시 전화 걸기**: 버튼 클릭 시 바로 전화 연결
- ✅ **연락처 연동**: 기존 연락처에서 전화번호 불러오기
- ✅ **그룹 관리**: 가족, 친구, 직장 등 그룹별 분류
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
    │   └── speed_dial_button.dart    # 단축 버튼 모델
    │
    ├── providers/                    # 상태 관리 (Provider)
    │   ├── settings_provider.dart    # 앱 설정 관리
    │   └── speed_dial_provider.dart  # 단축키 데이터 관리
    │
    ├── screens/                      # 화면 UI
    │   ├── home_screen.dart          # 메인 홈 화면
    │   ├── add_button_screen.dart    # 단축키 추가 화면
    │   ├── edit_button_screen.dart   # 단축키 편집 화면
    │   └── settings_screen.dart      # 설정 화면
    │
    ├── services/                     # 비즈니스 로직
    │   ├── database_service.dart     # SQLite 데이터베이스 관리
    │   ├── phone_service.dart        # 전화 걸기 기능
    │   ├── permission_service.dart   # 권한 관리
    │   ├── widget_service.dart       # 위젯 통신
    │   └── backup_service.dart       # 백업/복원 기능
    │
    ├── utils/                        # 유틸리티
    │   ├── phone_formatter.dart      # 전화번호 포맷팅
    │   ├── error_handler.dart        # 에러 처리
    │   └── sort_options.dart         # 정렬 옵션
    │
    └── widgets/                      # 재사용 가능한 위젯
        ├── dial_button_widget.dart       # 단축키 버튼 UI
        ├── icon_picker_widget.dart       # 아이콘 선택 위젯
        ├── contact_picker_widget.dart    # 연락처 선택 위젯
        ├── empty_state_widget.dart       # 빈 상태 UI
        ├── loading_widget.dart           # 로딩 UI
        ├── permission_dialog.dart        # 권한 안내 다이얼로그
        └── duplicate_phone_dialog.dart   # 중복 전화번호 확인 다이얼로그

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

### speed_dial_buttons 테이블

| 컬럼 | 타입 | 설명 |
|------|------|------|
| id | INTEGER | 기본 키 (자동 증가) |
| name | TEXT | 버튼 이름 (최대 10자) |
| phoneNumber | TEXT | 전화번호 |
| iconCodePoint | INTEGER | 아이콘 코드포인트 |
| iconFontFamily | TEXT | 아이콘 폰트 패밀리 (nullable) |
| iconFontPackage | TEXT | 아이콘 패키지 (nullable) |
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

---

## 🎨 주요 기능 구현

### 1. 위젯 시스템

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
4. SharedPreferences에 JSON 저장
5. SpeedDialWidgetProvider가 UI 업데이트
6. 위젯에 이름 + 전화번호 표시 (AutoSize)
7. 버튼 클릭 시 ACTION_CALL Intent 발생
```

**Flutter ↔ Native 통신** (MethodChannel):
```kotlin
// MainActivity.kt
"saveAllButtonsData"  // 전체 버튼 데이터 저장
"updateWidgetData"    // 특정 위젯 업데이트
"refreshAllWidgets"   // 모든 위젯 새로고침
"getWidgetIds"        // 설치된 위젯 ID 목록
"getWidgetData"       // 위젯 데이터 조회
"clearAllWidgets"     // 모든 위젯 데이터 삭제
```

### 2. 위젯 텍스트 자동 크기 조정

**Android AutoSizeText 적용**:
```xml
<!-- 1×1 위젯 -->
<TextView
    android:autoSizeTextType="uniform"
    android:autoSizeMinTextSize="6sp"
    android:autoSizeMaxTextSize="9sp"
    android:maxLines="1" />

<!-- 2×3, 3×2 위젯 -->
<TextView
    android:autoSizeTextType="uniform"
    android:autoSizeMinTextSize="5sp"
    android:autoSizeMaxTextSize="7sp"
    android:maxLines="1" />
```

**전화번호 표시 위치**:
- 1×1: 이름 아래, 중앙 정렬
- 2×3, 3×2: 각 버튼 이름 아래, 작은 회색 글씨

### 3. 위젯 설정 UI

**레이아웃 구조**:
```xml
<FrameLayout>  <!-- 선택 배경 -->
  <CardView>   <!-- 내부 카드 -->
    <LinearLayout>
      <TextView>👤</TextView>  <!-- 사람 아이콘 -->
      <TextView>이름</TextView>  <!-- AutoSize 적용 -->
    </LinearLayout>
  </CardView>
</FrameLayout>
```

**선택 표시**:
- 미선택: 회색 테두리 (2dp, #E0E0E0)
- 선택: 파란색 테두리 (4dp, #2196F3)
- Drawable 리소스로 동적 변경
- CardView elevation 0으로 이중 테두리 방지

### 4. 권한 관리

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

### 5. 전화번호 포맷팅

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

### 6. 백업/복원

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
      "iconCodePoint": 57805,
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
- 단축키 버튼 그리드 표시
- 그룹별 탭 네비게이션
- 검색 기능
- 편집 모드 (드래그 앤 드롭)
- 정렬 옵션

### AddButtonScreen
- 아이콘 선택
- 이름 입력 (최대 10자)
- 전화번호 입력
- 연락처에서 가져오기
- 그룹 선택
- 중복 전화번호 확인

### EditButtonScreen
- 버튼 정보 수정
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