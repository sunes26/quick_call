# 📱 Quick Call - Flutter 단축 전화 앱

빠른 전화 걸기를 위한 Flutter 앱과 Android 홈 화면 위젯

## 📋 목차

- [프로젝트 개요](#프로젝트-개요)
- [주요 기능](#주요-기능)
- [프로젝트 구조](#프로젝트-구조)
- [설치 및 실행](#설치-및-실행)
- [위젯 시스템](#위젯-시스템)
- [개발 히스토리](#개발-히스토리)
- [기술 스택](#기술-스택)
- [문제 해결](#문제-해결)

---

## 🎯 프로젝트 개요

Quick Call은 자주 전화하는 연락처를 빠르게 관리하고, Android 홈 화면 위젯으로 원터치 전화 걸기를 가능하게 하는 앱입니다.

### 개발 환경
- **Flutter SDK**: 3.24.5
- **Dart**: 3.5.4
- **Android SDK**: API 21-34
- **IDE**: Visual Studio Code / Android Studio
- **위치**: `C:\Users\User\Documents\coding\quick_call\`

---

## ✨ 주요 기능

### 📱 앱 기능
- ✅ 연락처 추가/편집/삭제
- ✅ 그룹별 관리 (가족, 친구, 회사 등)
- ✅ 커스텀 아이콘 (25가지 이모지)
- ✅ 원터치 전화 걸기
- ✅ 위젯 동기화

### 🏠 위젯 기능
- ✅ **3가지 크기**: 1×1, 2×3, 3×2
- ✅ **독립 위젯 시스템**: 각 크기별 독립 설정
- ✅ **삼성 One UI 스타일**: 흰색 둥근 버튼
- ✅ **이모지 아이콘**: 25가지 아이콘 지원
- ✅ **AutoSizeText**: 자동 텍스트 크기 조정

---

## 📁 프로젝트 구조

```
quick_call/
├── android/
│   ├── app/
│   │   ├── src/
│   │   │   └── main/
│   │   │       ├── kotlin/com/example/quick_call/
│   │   │       │   ├── MainActivity.kt                    # 메인 Activity (3개 위젯 지원)
│   │   │       │   └── widget/
│   │   │       │       ├── WidgetUtils.kt                 # 공통 유틸리티
│   │   │       │       ├── SpeedDialWidgetProvider1x1.kt  # 1×1 위젯 Provider
│   │   │       │       ├── SpeedDialWidgetProvider2x3.kt  # 2×3 위젯 Provider
│   │   │       │       ├── SpeedDialWidgetProvider3x2.kt  # 3×2 위젯 Provider
│   │   │       │       ├── WidgetConfigActivity.kt        # 기존 설정 (사용 안 함)
│   │   │       │       ├── WidgetConfigActivity1x1.kt     # 1×1 위젯 설정
│   │   │       │       ├── WidgetConfigActivity2x3.kt     # 2×3 위젯 설정
│   │   │       │       └── WidgetConfigActivity3x2.kt     # 3×2 위젯 설정
│   │   │       ├── res/
│   │   │       │   ├── drawable/
│   │   │       │   │   ├── samsung_white_button.xml       # 흰색 버튼 배경
│   │   │       │   │   ├── gradient_header.xml            # 헤더 그라데이션
│   │   │       │   │   ├── button_outline.xml             # 아웃라인 버튼
│   │   │       │   │   ├── button_primary.xml             # 프라이머리 버튼
│   │   │       │   │   ├── badge_circle.xml               # 뱃지 원형
│   │   │       │   │   └── widget_button_bg.xml           # 위젯 버튼 배경
│   │   │       │   ├── layout/
│   │   │       │   │   ├── widget_speed_dial_1x1.xml      # 1×1 위젯 레이아웃
│   │   │       │   │   ├── widget_speed_dial_2x3.xml      # 2×3 위젯 레이아웃
│   │   │       │   │   ├── widget_speed_dial_3x2.xml      # 3×2 위젯 레이아웃
│   │   │       │   │   ├── activity_widget_config.xml     # 기존 설정 화면
│   │   │       │   │   ├── activity_widget_config_simple.xml  # 간단한 설정 화면
│   │   │       │   │   ├── item_widget_button_all.xml     # 버튼 아이템
│   │   │       │   │   └── item_widget_button_selected.xml # 선택된 버튼 아이템
│   │   │       │   ├── xml/
│   │   │       │   │   ├── speed_dial_widget_info_1x1.xml # 1×1 위젯 메타데이터
│   │   │       │   │   ├── speed_dial_widget_info_2x3.xml # 2×3 위젯 메타데이터
│   │   │       │   │   └── speed_dial_widget_info_3x2.xml # 3×2 위젯 메타데이터
│   │   │       │   ├── values/
│   │   │       │   │   ├── strings.xml                    # 문자열 리소스
│   │   │       │   │   ├── colors.xml                     # 색상 리소스
│   │   │       │   │   └── styles.xml                     # 스타일 리소스
│   │   │       │   └── mipmap-*/
│   │   │       │       └── ic_launcher.png                # 앱 아이콘
│   │   │       └── AndroidManifest.xml                    # Android 매니페스트
│   │   ├── build.gradle                                   # 앱 빌드 설정
│   │   └── proguard-rules.pro                             # ProGuard 규칙
│   ├── build.gradle                                       # 프로젝트 빌드 설정
│   ├── gradle.properties                                  # Gradle 속성
│   └── settings.gradle                                    # Gradle 설정
├── lib/
│   ├── main.dart                                          # 앱 진입점
│   ├── models/
│   │   ├── speed_dial_button.dart                         # 버튼 모델
│   │   └── button_group.dart                              # 그룹 모델
│   ├── providers/
│   │   └── button_provider.dart                           # 상태 관리
│   ├── screens/
│   │   ├── home_screen.dart                               # 홈 화면
│   │   ├── add_button_screen.dart                         # 버튼 추가 화면
│   │   └── edit_button_screen.dart                        # 버튼 편집 화면
│   ├── widgets/
│   │   ├── button_grid.dart                               # 버튼 그리드
│   │   ├── button_card.dart                               # 버튼 카드
│   │   ├── icon_picker.dart                               # 아이콘 선택기
│   │   └── group_selector.dart                            # 그룹 선택기
│   └── utils/
│       ├── phone_helper.dart                              # 전화 헬퍼
│       └── widget_helper.dart                             # 위젯 헬퍼
├── test/
│   └── widget_test.dart                                   # 위젯 테스트
├── pubspec.yaml                                           # Flutter 의존성
├── pubspec.lock                                           # 의존성 잠금
├── README.md                                              # 프로젝트 문서
└── .gitignore                                             # Git 무시 파일
```

---

## 🚀 설치 및 실행

### 필수 요구사항
- Flutter SDK 3.24.5 이상
- Android Studio 또는 VS Code
- Android SDK (API 21-34)
- 실제 Android 기기 (위젯 테스트용)

### 설치 단계

```bash
# 1. 저장소 클론 (또는 프로젝트 폴더로 이동)
cd C:\Users\User\Documents\coding\quick_call

# 2. 의존성 설치
flutter pub get

# 3. Android 기기 연결 확인
flutter devices

# 4. 앱 실행
flutter run

# 5. 릴리즈 빌드 (APK 생성)
flutter build apk --release
```

### 권한 설정

앱이 다음 권한을 요청합니다:
- `CALL_PHONE`: 전화 걸기
- `READ_CONTACTS`: 연락처 읽기 (선택)

---

## 🏠 위젯 시스템

### 위젯 종류

#### 1. Quick Call 1×1 (단일 버튼)
- **크기**: 1칸 × 1칸
- **버튼 수**: 1개
- **용도**: 가장 자주 사용하는 연락처 1개

#### 2. Quick Call 2×3 (세로형)
- **크기**: 2칸 × 3칸 (가로 2칸, 세로 3칸)
- **버튼 수**: 6개
- **배치**: 2열 × 3행

#### 3. Quick Call 3×2 (가로형)
- **크기**: 3칸 × 2칸 (가로 3칸, 세로 2칸)
- **버튼 수**: 6개
- **배치**: 3열 × 2행

### 위젯 디자인 (삼성 One UI 스타일)

```
특징:
✅ 흰색 단일색 배경 (#FFFFFF)
✅ 둥근 정사각형 (18dp radius)
✅ 가벼운 테두리 (#E0E0E0)
✅ 이모지 아이콘
✅ 검은색 텍스트 (#333333)
✅ 그림자 효과 (elevation 4dp)
```

### 위젯 추가 방법

1. 홈 화면 길게 누르기
2. "위젯" 선택
3. "Quick Call" 찾기
4. 원하는 크기 선택 (1×1, 2×3, 3×2)
5. 홈 화면에 배치
6. 버튼 선택 화면에서 연락처 선택
7. "저장" 버튼 클릭

---

## 📚 개발 히스토리

### Phase 1-7: 기본 앱 개발 (완료)
- ✅ Flutter 앱 기본 구조
- ✅ 버튼 CRUD 기능
- ✅ 그룹 관리
- ✅ 아이콘 선택
- ✅ 전화 걸기 기능
- ✅ SharedPreferences 저장
- ✅ Provider 상태 관리

### Phase 8: 독립 위젯 시스템 (완료)

#### 초기 계획 (변경됨)
- 6가지 크기 지원 (2×2, 3×2, 4×2, 3×3, 4×3, 4×4)
- 동적 크기 감지
- 단일 Provider

#### 최종 구현 (Gmail 스타일)
- **3가지 독립 위젯** (1×1, 2×3, 3×2)
- **각 위젯별 독립 Provider**
- **각 위젯별 독립 설정 화면**
- **고유 SharedPreferences 키**

### 주요 문제 해결

#### 1. 위젯 크기 인식 문제
**문제**: 위젯 크기를 동적으로 감지하는 것이 불안정
**해결**: Gmail 방식 채택 - 위젯 목록에서 크기별로 선택

#### 2. WidgetButton 중복 선언
**문제**: `WidgetConfigActivity.kt`와 `WidgetUtils.kt`에서 중복 선언
**해결**: `WidgetUtils.kt`에만 선언, 다른 곳에서 import

#### 3. MainActivity.kt 오류
**문제**: 기존 `SpeedDialWidgetProvider` 참조
**해결**: 3개 Provider를 모두 import하고 처리

#### 4. 위젯 설정 화면 빈 문제
**문제**: `item_widget_button_all.xml` 누락
**해결**: RecyclerView 아이템 레이아웃 추가

#### 5. disabled_overlay 오류
**문제**: 존재하지 않는 View ID 참조
**해결**: alpha 속성만으로 비활성화 표시

#### 6. 위젯 크기 부정확
**문제**: minWidth/minHeight 값이 너무 커서 실제보다 큰 크기로 표시
**해결**: Android 크기 공식 적용
```
minWidth = (셀 개수 × 70dp) - 30dp
minHeight = (셀 개수 × 70dp) - 30dp
```

#### 7. 디자인 최종 변경
**문제**: 그라데이션 배경이 요구사항과 다름
**해결**: 삼성 One UI 스타일 흰색 버튼으로 변경

---

## 🛠 기술 스택

### Flutter/Dart
```yaml
dependencies:
  flutter:
    sdk: flutter
  provider: ^6.1.1              # 상태 관리
  shared_preferences: ^2.2.2    # 로컬 저장
  url_launcher: ^6.2.2          # 전화 걸기
  permission_handler: ^11.1.0   # 권한 관리
```

### Android (Kotlin)
- **Language**: Kotlin
- **Min SDK**: 21 (Android 5.0 Lollipop)
- **Target SDK**: 34 (Android 14)
- **Compile SDK**: 34

### 주요 Android 컴포넌트
- `AppWidgetProvider`: 위젯 생명주기 관리
- `RemoteViews`: 위젯 UI 업데이트
- `SharedPreferences`: 위젯 데이터 저장
- `PendingIntent`: 버튼 클릭 처리
- `RecyclerView`: 버튼 목록 표시

---

## 🎨 UI/UX 디자인

### 앱 화면
- **Material Design 3** 스타일
- **그라데이션 헤더** (블루 → 인디고)
- **카드 기반 레이아웃**
- **FAB (Floating Action Button)** 추가 버튼

### 위젯 디자인 (삼성 스타일)

#### 1×1 위젯
```
┌──────────────┐
│              │
│   📞 (32sp)  │  ← 이모지 아이콘
│   엄마 (11sp) │  ← 이름
│              │
└──────────────┘
```

#### 2×3 & 3×2 위젯
```
각 버튼:
┌─────────┐
│ 📞 (22sp)│  ← 이모지 아이콘
│ 이름 (9sp)│  ← 이름
└─────────┘

배경: 흰색 (#FFFFFF)
테두리: 연한 회색 (#E0E0E0)
텍스트: 진한 회색 (#333333)
둥근 모서리: 18dp
그림자: elevation 4dp
```

---

## 🐛 문제 해결

### 위젯이 목록에 나타나지 않음

**원인**: AndroidManifest.xml에 receiver가 제대로 등록되지 않음

**해결**:
```xml
<receiver
    android:name=".widget.SpeedDialWidgetProvider1x1"
    android:exported="true"
    android:label="Quick Call 1×1">
    <intent-filter>
        <action android:name="android.appwidget.action.APPWIDGET_UPDATE" />
    </intent-filter>
    <meta-data
        android:name="android.appwidget.provider"
        android:resource="@xml/speed_dial_widget_info_1x1" />
</receiver>
```

3개 위젯 모두 등록 확인 (1x1, 2x3, 3x2)

### 위젯 크기가 이상함

**원인**: 위젯 메타데이터의 minWidth/minHeight 값이 부정확

**해결**: 올바른 크기 공식 적용
```xml
<!-- 1×1 -->
<appwidget-provider
    android:minWidth="40dp"
    android:minHeight="40dp"
    android:targetCellWidth="1"
    android:targetCellHeight="1" />

<!-- 2×3 -->
<appwidget-provider
    android:minWidth="110dp"
    android:minHeight="180dp"
    android:targetCellWidth="2"
    android:targetCellHeight="3" />

<!-- 3×2 -->
<appwidget-provider
    android:minWidth="180dp"
    android:minHeight="110dp"
    android:targetCellWidth="3"
    android:targetCellHeight="2" />
```

### 위젯 설정 화면이 비어있음

**원인**: `item_widget_button_all.xml` 레이아웃 파일 누락

**해결**: RecyclerView 아이템 레이아웃 추가
```
android/app/src/main/res/layout/item_widget_button_all.xml
```

### 전화가 걸리지 않음

**원인**: CALL_PHONE 권한 없음 또는 ACTION이 제대로 등록되지 않음

**해결**:
1. AndroidManifest.xml에 권한 추가
```xml
<uses-permission android:name="android.permission.CALL_PHONE" />
```

2. 각 위젯의 고유 ACTION 확인
```kotlin
// 1×1
const val ACTION_CALL = "com.example.quick_call.ACTION_CALL_1X1"

// 2×3
const val ACTION_CALL = "com.example.quick_call.ACTION_CALL_2X3"

// 3×2
const val ACTION_CALL = "com.example.quick_call.ACTION_CALL_3X2"
```

### 빌드 오류 해결

#### "Unresolved reference: SpeedDialWidgetProvider"
**해결**: 기존 파일 삭제, 3개 Provider로 교체

#### "Unresolved reference: WidgetButton"
**해결**: WidgetUtils.kt에만 선언, 중복 제거

#### "Unresolved reference: disabled_overlay"
**해결**: alpha 속성만으로 비활성화 표시

---

## 📊 데이터 구조

### SharedPreferences 키

```kotlin
// 전체 버튼 데이터 (앱에서 저장)
"all_buttons_data" → JSON 배열

// 위젯별 데이터
"widget_data_1x1_{widgetId}" → JSON 배열 (최대 1개)
"widget_data_2x3_{widgetId}" → JSON 배열 (최대 6개)
"widget_data_3x2_{widgetId}" → JSON 배열 (최대 6개)
```

### JSON 구조

```json
[
  {
    "id": 1,
    "name": "엄마",
    "phoneNumber": "010-1234-5678",
    "iconCodePoint": 57549,
    "group": "가족"
  },
  {
    "id": 2,
    "name": "회사",
    "phoneNumber": "02-1234-5678",
    "iconCodePoint": 59574,
    "group": "회사"
  }
]
```

---

## 🔐 권한

### Android 권한

```xml
<uses-permission android:name="android.permission.CALL_PHONE" />
<uses-permission android:name="android.permission.READ_CONTACTS" />
<uses-permission android:name="android.permission.INTERNET" />
```

### 런타임 권한 요청

앱 실행 시 다음 권한을 요청합니다:
- **전화 걸기** (CALL_PHONE): 필수
- **연락처 읽기** (READ_CONTACTS): 선택

---

## 📈 향후 계획

### 예정된 기능
- [ ] 위젯 배경 색상 커스터마이징
- [ ] 더 많은 아이콘 추가
- [ ] 위젯 크기 조정 (resizable)
- [ ] 다크 모드 지원
- [ ] 백업 및 복원 기능
- [ ] 클라우드 동기화
- [ ] 통화 기록 통계
- [ ] 위젯 테마 선택

### 개선 예정
- [ ] 위젯 미리보기 추가
- [ ] 더 나은 오류 처리
- [ ] 성능 최적화
- [ ] 접근성 개선
- [ ] 다국어 지원

---

## 🤝 기여

이 프로젝트는 개인 프로젝트입니다. 개선 제안이나 버그 리포트는 환영합니다!

---

## 📄 라이선스

이 프로젝트는 개인 용도로 개발되었습니다.

---

## 📞 연락처

프로젝트 관련 문의:
- **프로젝트**: Quick Call
- **개발자**: [Your Name]
- **위치**: Gwangju, Gyeonggi-do, KR

---

## 🙏 감사의 말

- Flutter 팀에게 훌륭한 프레임워크 제공에 감사드립니다
- Material Design 팀에게 디자인 가이드라인 제공에 감사드립니다
- 삼성 One UI 디자인에 영감을 받았습니다

---

## 📝 변경 로그

### v1.0.0 (2024-11-26)
- ✅ 3개 독립 위젯 시스템 구현 (1×1, 2×3, 3×2)
- ✅ 삼성 One UI 스타일 디자인 적용
- ✅ 이모지 아이콘 25가지 지원
- ✅ AutoSizeText 자동 크기 조정
- ✅ 독립 설정 화면 (각 위젯별)
- ✅ 안정적인 데이터 저장/로드
- ✅ 전화 걸기 기능 완성

### 개발 중 해결한 주요 이슈
1. 위젯 크기 인식 → 독립 위젯으로 해결
2. WidgetButton 중복 선언 → WidgetUtils에 통합
3. MainActivity 참조 오류 → 3개 Provider 지원
4. 설정 화면 빈 문제 → 레이아웃 추가
5. 위젯 크기 부정확 → 크기 공식 적용
6. 디자인 요구사항 → 흰색 버튼으로 변경

---

**마지막 업데이트**: 2024-11-26  
**버전**: 1.0.0  
**상태**: ✅ 개발 완료