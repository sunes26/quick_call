# Quick Call ⚡📞

Flutter 기반 전화번호 단축 다이얼 애플리케이션으로, 자주 연락하는 사람들에게 빠르게 전화를 걸 수 있는 홈 화면 위젯을 제공합니다.

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white" />
  <img src="https://img.shields.io/badge/Kotlin-7F52FF?style=for-the-badge&logo=kotlin&logoColor=white" />
  <img src="https://img.shields.io/badge/Android-3DDC84?style=for-the-badge&logo=android&logoColor=white" />
  <img src="https://img.shields.io/badge/SQLite-003B57?style=for-the-badge&logo=sqlite&logoColor=white" />
</p>

---

## 📋 목차

- [주요 기능](#-주요-기능)
- [기술 스택](#-기술-스택)
- [설치 방법](#-설치-방법)
- [프로젝트 구조](#-프로젝트-구조)
- [위젯 구현 상세](#-위젯-구현-상세)
- [사용 방법](#-사용-방법)
- [UI/UX 개선 사항](#-uiux-개선-사항)
- [트러블슈팅](#-트러블슈팅)
- [개발 과정](#-개발-과정)

---

## ✨ 주요 기능

### 📱 앱 기능
- ✅ 단축 다이얼 버튼 생성 및 관리
- ✅ 연락처에서 전화번호 불러오기
- ✅ 그룹별 버튼 분류 (가족, 친구, 직장 등)
- ✅ 커스텀 아이콘 설정
- ✅ 버튼 순서 변경 (드래그 앤 드롭)
- ✅ SQLite 로컬 데이터베이스 저장
- ✅ 다크 모드 지원

### 🏠 위젯 기능
- ✅ **2×2 홈 화면 위젯** (최대 4개 버튼)
- ✅ **위젯별 독립적인 버튼 구성**
  - 위젯 A: 가족 연락처
  - 위젯 B: 직장 연락처
  - 위젯 C: 자주 가는 장소
- ✅ **모던 머티리얼 디자인 설정 화면** 🆕
- ✅ **위젯 추가 시 자동 설정 화면** (Configuration Activity)
- ✅ **버튼 선택 및 순서 변경** (드래그 앤 드롭)
- ✅ **앱 내 버튼 변경 시 위젯 자동 동기화**
- ✅ **여러 위젯 동시 관리**

---

## 🛠️ 기술 스택

### Frontend
- **Flutter** 3.x
- **Dart** 3.x
- **Provider** (상태 관리)
- **flutter_screenutil** (반응형 UI)

### Backend
- **SQLite** (sqflite)
- **SharedPreferences** (위젯 데이터 저장)

### Android Native
- **Kotlin** 1.x
- **AndroidX RecyclerView** 1.3.2
- **AndroidX CardView** 1.0.0
- **AppWidget API**
- **MethodChannel** (Flutter ↔ Native 통신)

### 권한
- `android.permission.CALL_PHONE` - 전화 걸기
- `android.permission.READ_CONTACTS` - 연락처 읽기
- `android.permission.INTERNET` - 네트워크 통신

---

## 📦 설치 방법

### 요구사항
- Flutter SDK 3.0 이상
- Android Studio / VS Code
- Android SDK (API 21 이상)
- Kotlin 1.7 이상

### 빌드 및 실행

```bash
# 1. 의존성 설치
flutter pub get

# 2. 디버그 모드 실행
flutter run

# 3. 릴리즈 APK 빌드
flutter build apk --release

# 4. 앱 완전 재설치
flutter run --uninstall-first
```

### 필수 설정

**1. `android/app/build.gradle`에 의존성 추가:**

```gradle
dependencies {
    implementation "org.jetbrains.kotlin:kotlin-stdlib-jdk7:$kotlin_version"
    
    // RecyclerView & CardView 의존성 (필수!)
    implementation 'androidx.recyclerview:recyclerview:1.3.2'
    implementation 'androidx.cardview:cardview:1.0.0'
}
```

**2. `AndroidManifest.xml` 설정:**

```xml
<activity
    android:name=".widget.WidgetConfigActivity"
    android:exported="true"
    android:label="위젯 설정"
    android:theme="@style/Theme.AppCompat.Light.NoActionBar">
    <intent-filter>
        <action android:name="android.appwidget.action.APPWIDGET_CONFIGURE" />
    </intent-filter>
</activity>
```

> ⚠️ **중요:** `android:theme="@style/Theme.AppCompat.Light.NoActionBar"`를 사용하여 상단 ActionBar를 제거합니다.

---

## 📂 프로젝트 구조

```
quick_call/
├── lib/
│   ├── main.dart                          # 앱 진입점
│   ├── models/
│   │   └── speed_dial_button.dart         # 버튼 데이터 모델
│   ├── providers/
│   │   ├── settings_provider.dart         # 설정 관리
│   │   └── speed_dial_provider.dart       # 상태 관리 (Provider)
│   ├── screens/
│   │   ├── add_button_screen.dart         # 버튼 추가 화면
│   │   ├── edit_button_screen.dart        # 버튼 편집 화면
│   │   ├── home_screen.dart               # 홈 화면
│   │   ├── settings_screen.dart           # 설정 화면 ⭐
│   │   └── widget_config_screen.dart      # 위젯 설정 화면 (Flutter)
│   ├── services/
│   │   ├── backup_service.dart            # 백업/복원 서비스
│   │   ├── database_service.dart          # SQLite 데이터베이스
│   │   ├── permission_service.dart        # 권한 관리 서비스
│   │   ├── phone_service.dart             # 전화 걸기 서비스
│   │   └── widget_service.dart            # 위젯 MethodChannel
│   ├── utils/
│   │   ├── error_handler.dart             # 에러 처리 유틸
│   │   ├── phone_formatter.dart           # 전화번호 포맷팅
│   │   └── sort_options.dart              # 정렬 옵션 Enum
│   └── widgets/
│       ├── contact_picker_widget.dart     # 연락처 선택 위젯
│       ├── dial_button_widget.dart        # 다이얼 버튼 위젯
│       ├── duplicate_phone_dialog.dart    # 중복 전화번호 다이얼로그
│       ├── empty_state_widget.dart        # 빈 상태 위젯
│       ├── icon_picker_widget.dart        # 아이콘 선택 위젯
│       ├── loading_widget.dart            # 로딩 위젯
│       └── permission_dialog.dart         # 권한 요청 다이얼로그
│
├── android/
│   ├── build.gradle.kts                    # Gradle 프로젝트 설정
│   ├── settings.gradle.kts                 # Gradle 모듈 설정
│   └── app/
│       ├── build.gradle.kts                # Android 앱 빌드 설정
│       └── src/main/
│           ├── AndroidManifest.xml         # 앱 권한 및 컴포넌트 ⭐
│           ├── kotlin/com/example/quick_call/
│           │   ├── MainActivity.kt         # Flutter Activity
│           │   └── widget/
│           │       ├── SpeedDialWidgetProvider.kt     # 위젯 Provider
│           │       └── WidgetConfigActivity.kt        # 위젯 설정 Activity ⭐
│           └── res/
│               ├── drawable/
│               │   ├── badge_circle.xml               # 카운터 배지
│               │   ├── button_outline.xml             # 외곽선 버튼
│               │   ├── button_primary.xml             # 주요 버튼 스타일
│               │   ├── checkbox_selector.xml          # 체크박스
│               │   ├── drag_indicator.xml             # 드래그 표시
│               │   ├── group_badge.xml                # 그룹 배지
│               │   ├── icon_circle_background.xml     # 큰 아이콘 배경 (72dp)
│               │   ├── icon_small_background.xml      # 작은 아이콘 배경 (52dp)
│               │   ├── launch_background.xml          # 앱 시작 배경
│               │   ├── remove_button_background.xml   # 삭제 버튼
│               │   ├── selected_indicator.xml         # 선택 표시
│               │   ├── widget_background.xml          # 위젯 배경
│               │   └── widget_button_background.xml   # 위젯 버튼 배경
│               ├── drawable-v21/
│               │   └── launch_background.xml          # API 21+ 시작 배경
│               ├── layout/
│               │   ├── activity_widget_config.xml     # 설정 화면 레이아웃 ⭐
│               │   ├── item_widget_button_all.xml     # 전체 버튼 아이템 ⭐
│               │   ├── item_widget_button_selected.xml # 선택된 버튼 아이템 ⭐
│               │   └── widget_speed_dial.xml          # 위젯 레이아웃
│               ├── mipmap-hdpi/
│               │   └── ic_launcher.png                # 앱 아이콘 (hdpi)
│               ├── mipmap-mdpi/
│               │   └── ic_launcher.png                # 앱 아이콘 (mdpi)
│               ├── mipmap-xhdpi/
│               │   └── ic_launcher.png                # 앱 아이콘 (xhdpi)
│               ├── mipmap-xxhdpi/
│               │   └── ic_launcher.png                # 앱 아이콘 (xxhdpi)
│               ├── mipmap-xxxhdpi/
│               │   └── ic_launcher.png                # 앱 아이콘 (xxxhdpi)
│               ├── values/
│               │   ├── strings.xml                    # 문자열 리소스 ⭐
│               │   └── styles.xml                     # 스타일 정의
│               ├── values-night/
│               │   └── styles.xml                     # 다크 테마 스타일
│               └── xml/
│                   └── speed_dial_widget_info.xml     # 위젯 메타데이터
│
├── pubspec.yaml                            # Flutter 의존성
└── README.md                               # 프로젝트 문서
```

### 📁 주요 디렉토리 설명

#### `/lib` (Flutter 코드)
- **models/** (1개): 데이터 모델 클래스
- **providers/** (2개): Provider 패턴 상태 관리
- **screens/** (5개): 화면 UI 컴포넌트
  - 홈, 추가, 편집, 설정, 위젯 설정 화면
- **services/** (5개): 비즈니스 로직
  - 데이터베이스, 위젯, 백업, 권한, 전화 서비스
- **utils/** (3개): 유틸리티 함수
  - 에러 처리, 전화번호 포맷팅, 정렬 옵션
- **widgets/** (7개): 재사용 가능한 UI 위젯
  - 연락처 선택, 다이얼 버튼, 아이콘 선택, 로딩, 권한 다이얼로그 등

#### `/android/app/src/main/kotlin` (Native 코드)
- **MainActivity.kt**: Flutter 앱 진입점
- **widget/** (2개): 위젯 관련 Kotlin 코드
  - **SpeedDialWidgetProvider.kt**: 위젯 업데이트 및 관리
  - **WidgetConfigActivity.kt**: 위젯 설정 화면 (2열 그리드, 드래그 앤 드롭)

#### `/android/app/src/main/res` (Android 리소스)
- **drawable/** (13개): 벡터 그래픽 및 shape drawable
  - 배지, 버튼, 체크박스, 아이콘 배경, 인디케이터 등
- **drawable-v21/** (1개): API 21+ 전용 drawable
- **layout/** (4개): XML 레이아웃 파일
  - 설정 화면, 버튼 아이템, 위젯 레이아웃
- **mipmap-xxx/** (5개): 다양한 해상도의 앱 아이콘
- **values/** (2개): 문자열, 스타일 리소스
- **values-night/** (1개): 다크 테마 스타일
- **xml/** (1개): 위젯 메타데이터

### 📊 프로젝트 파일 통계
- **Flutter 파일**: 23개 (Dart)
- **Kotlin 파일**: 2개 (Native)
- **XML 레이아웃**: 4개
- **Drawable 리소스**: 14개
- **총 코드 라인**: ~4,000+ lines

---

## 🔧 위젯 구현 상세

### Architecture: Configuration Activity 패턴

위젯 추가 시 사용자가 버튼을 선택할 수 있도록 **Android AppWidget Configuration Activity**를 구현했습니다.

#### 동작 흐름

```
1. 사용자가 홈 화면에서 위젯 드래그
         ↓
2. WidgetConfigActivity 자동 실행
         ↓
3. SharedPreferences에서 전체 버튼 데이터 로드
         ↓
4. RecyclerView로 버튼 목록 표시
   - 선택된 버튼 (2열 그리드, 드래그 가능)
   - 전체 버튼 (2열 그리드, 선택 가능) 🆕
         ↓
5. 사용자가 최대 4개 버튼 선택
         ↓
6. 드래그 앤 드롭으로 순서 변경
         ↓
7. 저장 버튼 클릭
         ↓
8. 위젯 ID별로 데이터 저장
   (widget_data_{appWidgetId})
         ↓
9. SpeedDialWidgetProvider 업데이트
         ↓
10. 위젯에 선택한 버튼 표시
```

### 주요 컴포넌트

#### 1. WidgetConfigActivity.kt

```kotlin
// 위젯 설정 Activity - 위젯 추가 시 자동 실행
class WidgetConfigActivity : Activity() {
    
    private var appWidgetId = AppWidgetManager.INVALID_APPWIDGET_ID
    private val selectedButtons = mutableListOf<WidgetButton>()
    private val allButtons = mutableListOf<WidgetButton>()
    
    // SharedPreferences에서 데이터 로드
    private fun loadAllButtons() { ... }
    
    // RecyclerView 어댑터 설정 (2열 그리드)
    private fun setupAdapters() {
        // 선택된 버튼: 2열 그리드
        recyclerSelected.layoutManager = GridLayoutManager(this, 2)
        
        // 전체 버튼: 2열 그리드 (3열에서 변경) 🆕
        recyclerAll.layoutManager = GridLayoutManager(this, 2)
    }
    
    // 설정 저장
    private fun saveConfiguration() {
        // JSON 변환
        // SharedPreferences 저장
        // 위젯 업데이트
        // RESULT_OK 반환
    }
}
```

#### 2. SpeedDialWidgetProvider.kt

```kotlin
class SpeedDialWidgetProvider : AppWidgetReceiver() {
    
    companion object {
        // 위젯 ID별 데이터 로드
        fun updateAppWidget(
            context: Context,
            appWidgetManager: AppWidgetManager,
            appWidgetId: Int
        ) { ... }
        
        // 모든 위젯 새로고침
        fun updateAllWidgets(context: Context) { ... }
    }
    
    // 위젯 삭제 시 데이터 정리
    override fun onDeleted(context: Context, appWidgetIds: IntArray) { ... }
}
```

#### 3. WidgetService (Flutter ↔ Native)

```dart
class WidgetService {
  static const MethodChannel _channel = MethodChannel('widget_channel');
  
  // 전체 버튼 데이터 저장 (위젯 설정 화면용)
  Future<void> saveAllButtonsData(List<SpeedDialButton> buttons) async { ... }
  
  // 특정 위젯 데이터 업데이트
  Future<void> updateWidgetData(int widgetId, List<SpeedDialButton> buttons) async { ... }
  
  // 모든 위젯 새로고침
  Future<void> refreshAllWidgets() async { ... }
  
  // 위젯 ID 목록 조회
  Future<List<int>> getWidgetIds() async { ... }
}
```

### 데이터 저장 구조

#### SharedPreferences

```kotlin
// 전체 버튼 데이터 (위젯 설정 화면용)
"all_buttons_data" = "[{id:1, name:'엄마', ...}, ...]"

// 위젯별 데이터
"widget_data_13" = "[{id:1, ...}, {id:3, ...}]"  // 위젯 ID 13
"widget_data_14" = "[{id:5, ...}, {id:7, ...}]"  // 위젯 ID 14
```

#### JSON 형식

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
    "name": "아빠",
    "phoneNumber": "010-8765-4321",
    "iconCodePoint": 57549,
    "group": "가족"
  }
]
```

### 위젯별 독립 관리

```
📱 위젯 A (ID: 13)
├─ 엄마 (010-1234-5678)
├─ 아빠 (010-8765-4321)
├─ 119
└─ 112

📱 위젯 B (ID: 14)
├─ 직장 (02-1234-5678)
├─ 동료 (010-1111-2222)
├─ 고객센터 (1588-0000)
└─ 택시 (1577-0000)

📱 위젯 C (ID: 15)
├─ 할머니 (010-9999-8888)
├─ 할아버지 (010-7777-6666)
├─ 이모 (010-5555-4444)
└─ 삼촌 (010-3333-2222)
```

---

## 📖 사용 방법

### 1️⃣ 앱에서 버튼 추가

1. 앱 실행
2. `+` 버튼 클릭
3. 이름, 전화번호, 그룹, 아이콘 입력
4. 저장

### 2️⃣ 위젯 추가

1. 홈 화면 길게 누르기
2. "위젯" 선택
3. "Quick Call" 위젯 찾기
4. 2×2 위젯을 홈 화면에 드래그
5. **자동으로 설정 화면 표시** (모던 디자인)
6. 버튼 선택 (최대 4개)
7. 드래그하여 순서 변경
8. "저장" 버튼 클릭

### 3️⃣ 위젯 재구성

1. 위젯 길게 누르기
2. "재구성" 선택
3. 버튼 다시 선택
4. 저장

### 4️⃣ 앱 내 버튼 변경 시 자동 동기화

- 앱에서 버튼 추가/수정/삭제 시
- 모든 위젯이 자동으로 업데이트됩니다
- 별도 조작 불필요

---

## 🎨 UI/UX 개선 사항

### Phase 6: 모던 디자인 적용 🆕

#### 1. Native 위젯 설정 화면 전면 개선

**설계 원칙:**
- 모던 머티리얼 디자인 3.0
- 카드 기반 레이아웃
- 직관적인 시각적 계층 구조
- 부드러운 애니메이션

**주요 개선 사항:**

##### 🎯 헤더 섹션
- 블루 그라데이션 배경 (#2196F3)
- 명확한 제목과 설명
- Elevation 효과로 부각

##### 📌 선택된 버튼 섹션
- 카드 기반 레이아웃 (16dp corner radius)
- 2열 그리드로 최적화
- 원형 아이콘 배경 (블루 톤 #E3F2FD)
- 빨간색 원형 삭제 버튼 (#F44336)
- 좌측 상단 선택 인디케이터 (그린 #4CAF50)
- 드래그 인디케이터 표시
- 실시간 카운터 배지 (0~4)

##### 📋 전체 버튼 섹션
- **3열 → 2열 그리드로 변경** (가로 공간 50% 증가)
- 원형 아이콘 배경 (그린 톤 #E8F5E9)
- 커스텀 체크박스 디자인
- 4개 초과 시 자동 비활성화 오버레이
- 텍스트 2줄 확보 (긴 이름 완전 표시)
- 아이콘 잘림 방지 (52dp 원형)

##### 🎯 하단 액션 버튼
- 취소 버튼 (외곽선 스타일)
- 저장 버튼 (filled 스타일, 블루 #2196F3)
- 활성화 상태에 따른 스타일 변경

**색상 시스템:**
- Primary: `#2196F3` (블루)
- Success: `#4CAF50` (그린)
- Error: `#F44336` (레드)
- Background: `#FFFFFF` / `#FAFAFA`
- Text: `#212121` / `#757575`

#### 2. ActionBar 제거

**문제:** 중복된 상단 바 (검은색 "위젯 설정" + 파란색 헤더)

**해결:**
```xml
<!-- AndroidManifest.xml -->
<activity
    android:name=".widget.WidgetConfigActivity"
    android:theme="@style/Theme.AppCompat.Light.NoActionBar">
```

#### 3. NestedScrollView 적용

**문제:** 전체 버튼 목록이 일부만 표시됨

**해결:**
- ScrollView → NestedScrollView로 변경
- RecyclerView에 `nestedScrollingEnabled="false"` 추가
- 모든 버튼이 한 번에 표시되고 부모로 스크롤 위임

#### 4. 텍스트 잘림 방지

**개선 사항:**
- `android:minLines="2"` 추가 (항상 2줄 확보)
- 텍스트 크기: 12sp → 13sp
- 행간: 1dp → 2dp
- "중학교 수학학..." → "중학교\n수학학회" (완전 표시)

#### 5. 아이콘 잘림 방지

**개선 사항:**
- 아이콘 배경: 56dp → 52dp
- 아이콘 크기: 32dp → 28dp
- 카드 padding: 12dp → 16dp
- 카드 margin: 4dp → 6dp

#### 6. Flutter 설정 화면 최적화

**삭제된 기능:**
- ❌ 위젯 버튼 설정 타일 (Native 화면에서 처리)
- ❌ 위젯 새로고침 타일 (자동 동기화)

**유지된 기능:**
- ✅ 다크 모드
- ✅ 정렬 설정
- ✅ 백업/복원
- ✅ 데이터베이스 정보
- ✅ 앱 정보

---

## 🐛 트러블슈팅

### 문제 1: RecyclerView 의존성 에러

**증상:**
```
Unresolved reference 'RecyclerView'
Unresolved reference 'GridLayoutManager'
```

**해결:**
```gradle
// android/app/build.gradle
dependencies {
    implementation 'androidx.recyclerview:recyclerview:1.3.2'
    implementation 'androidx.cardview:cardview:1.0.0'
}
```

### 문제 2: XML 파싱 에러

**증상:**
```
[xX][mM][lL]과 일치하는 처리 명령 대상은 허용되지 않습니다
```

**해결:**
- XML 파일 첫 줄이 `<?xml`로 시작하는지 확인
- 앞에 공백이나 BOM(Byte Order Mark) 제거
- UTF-8 인코딩 확인

### 문제 3: 위젯 추가 시 앱 크래시

**증상:**
```
android.view.InflateException: Error inflating class <unknown>
Failed to resolve attribute: selectableItemBackground
```

**해결:**
```xml
<!-- AndroidManifest.xml -->
<activity
    android:name=".widget.WidgetConfigActivity"
    android:theme="@style/Theme.AppCompat.Light.NoActionBar">
```

### 문제 4: supportActionBar 에러

**증상:**
```
Unresolved reference 'supportActionBar'
```

**해결:**
- `supportActionBar?.hide()` 코드 제거
- AndroidManifest.xml의 NoActionBar 테마로 충분

### 문제 5: File.path 타입 에러

**증상:**
```
The getter 'path' isn't defined for the type 'String'
```

**해결:**
```dart
// 명시적 타입 캐스팅
if (file is File) {
  final f = file as File;
  fileName = f.path.split('/').last;
}
```

### 문제 6: RecyclerView가 일부만 보임

**증상:**
전체 버튼 중 3개만 보이고 나머지는 숨겨짐

**해결:**
```xml
<!-- NestedScrollView 사용 -->
<androidx.core.widget.NestedScrollView ...>
    <RecyclerView
        android:nestedScrollingEnabled="false"
        android:layout_height="wrap_content" />
</androidx.core.widget.NestedScrollView>
```

### 문제 7: 아이콘 양옆 잘림

**증상:**
초록색 원형 배경이 카드 밖으로 튀어나옴

**해결:**
- 아이콘 크기 축소: 56dp → 52dp
- 카드 padding 증가: 12dp → 16dp

---

## 📝 개발 과정

### Phase 1: 기본 앱 개발
- ✅ Flutter UI 구현
- ✅ SQLite 데이터베이스 연동
- ✅ 버튼 CRUD 기능
- ✅ 연락처 권한 처리

### Phase 2: 위젯 기본 구현
- ✅ 2×2 위젯 레이아웃
- ✅ SpeedDialWidgetProvider 작성
- ✅ MethodChannel 통신
- ✅ 위젯 클릭 시 전화 걸기

### Phase 3: Configuration Activity 구현
- ✅ WidgetConfigActivity 작성
- ✅ RecyclerView 어댑터 구현
- ✅ 드래그 앤 드롭 기능
- ✅ 위젯별 독립 데이터 관리
- ✅ SharedPreferences 저장

### Phase 4: 에러 해결
- ✅ RecyclerView 의존성 추가
- ✅ XML 파싱 에러 수정
- ✅ Dialog 테마 이슈 해결
- ✅ 레이아웃 속성 호환성 개선

### Phase 5: 자동 동기화
- ✅ 앱 내 버튼 변경 감지
- ✅ 모든 위젯 자동 업데이트
- ✅ 전체 버튼 데이터 실시간 동기화

### Phase 6: 모던 디자인 적용 🆕
- ✅ Native 위젯 설정 화면 전면 개선
  - 모던 머티리얼 디자인 3.0
  - 카드 기반 레이아웃
  - 블루 그라데이션 헤더
  - 원형 아이콘 배경
  - 커스텀 체크박스
  - 드래그 인디케이터
- ✅ ActionBar 제거 (중복 해결)
- ✅ NestedScrollView 적용
- ✅ 그리드 최적화 (3열 → 2열)
- ✅ 아이콘 잘림 방지
- ✅ 텍스트 잘림 방지
- ✅ Flutter 설정 화면 최적화
- ✅ settings_screen.dart 에러 수정
  - File.path 타입 캐스팅
  - BackupFileInfo 속성명 수정
  - BuildContext async 안전성 개선

---

## 🔮 향후 계획

- [ ] 3×3, 4×2 등 다양한 위젯 크기 지원
- [ ] 다크/라이트 테마 위젯 스타일
- [ ] 위젯별 배경색 설정
- [ ] 클라우드 백업 기능
- [ ] iOS 위젯 지원
- [ ] 통화 기록 통계
- [ ] 즐겨찾기 기능

---

## 📊 프로젝트 통계

- **총 개발 기간:** 진행중
- **Flutter 파일:** 23개 (Dart)
  - Models: 1개
  - Providers: 2개
  - Screens: 5개
  - Services: 5개
  - Utils: 3개
  - Widgets: 7개
- **Kotlin 파일:** 2개 (Native)
- **XML 레이아웃:** 4개
- **Drawable 리소스:** 14개
- **총 코드 라인:** ~4,000+ lines
- **개발 단계:** Phase 6 완료

---

## 📄 라이선스

이 프로젝트는 개인 학습 목적으로 제작되었습니다.

---

## 👨‍💻 개발자

Quick Call 개발팀

---

## 📞 연락처

문의사항이나 버그 리포트는 이슈로 남겨주세요.

---

<p align="center">
  Made with ❤️ using Flutter & Kotlin
</p>