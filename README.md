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

### 🏠 위젯 기능
- ✅ **2×2 홈 화면 위젯** (최대 4개 버튼)
- ✅ **위젯별 독립적인 버튼 구성**
  - 위젯 A: 가족 연락처
  - 위젯 B: 직장 연락처
  - 위젯 C: 자주 가는 장소
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

### Backend
- **SQLite** (sqflite)
- **SharedPreferences** (위젯 데이터 저장)

### Android Native
- **Kotlin** 1.x
- **AndroidX RecyclerView** 1.3.2
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

**1. `android/app/build.gradle`에 RecyclerView 의존성 추가:**

```gradle
dependencies {
    implementation "org.jetbrains.kotlin:kotlin-stdlib-jdk7:$kotlin_version"
    
    // RecyclerView 의존성 (필수!)
    implementation 'androidx.recyclerview:recyclerview:1.3.2'
}
```

**2. `AndroidManifest.xml` 확인:**

```xml
<activity
    android:name=".widget.WidgetConfigActivity"
    android:exported="true"
    android:label="위젯 설정">
    <intent-filter>
        <action android:name="android.appwidget.action.APPWIDGET_CONFIGURE" />
    </intent-filter>
</activity>
```

> ⚠️ **중요:** `android:theme` 속성을 사용하지 마세요! Dialog 테마는 레이아웃 인플레이션 에러를 일으킬 수 있습니다.

---

## 📂 프로젝트 구조

```
quick_call/
├── lib/
│   ├── main.dart                          # 앱 진입점
│   ├── models/
│   │   └── speed_dial_button.dart         # 버튼 데이터 모델
│   ├── providers/
│   │   └── speed_dial_provider.dart       # 상태 관리 (Provider)
│   ├── screens/
│   │   ├── home_screen.dart               # 홈 화면
│   │   ├── add_button_screen.dart         # 버튼 추가 화면
│   │   └── widget_config_screen.dart      # 위젯 설정 화면 (Flutter)
│   ├── services/
│   │   ├── database_service.dart          # SQLite 데이터베이스
│   │   └── widget_service.dart            # 위젯 MethodChannel
│   └── widgets/
│       └── speed_dial_button_widget.dart  # 버튼 위젯
│
├── android/
│   └── app/
│       └── src/main/
│           ├── AndroidManifest.xml         # 앱 권한 및 컴포넌트
│           ├── kotlin/com/example/quick_call/
│           │   ├── MainActivity.kt         # Flutter Activity
│           │   └── widget/
│           │       ├── SpeedDialWidgetProvider.kt     # 위젯 Provider
│           │       └── WidgetConfigActivity.kt        # 위젯 설정 Activity ⭐
│           └── res/
│               ├── layout/
│               │   ├── speed_dial_widget.xml          # 위젯 레이아웃
│               │   ├── activity_widget_config.xml     # 설정 화면 레이아웃 ⭐
│               │   ├── item_widget_button_selected.xml # 선택된 버튼 아이템 ⭐
│               │   └── item_widget_button_all.xml      # 전체 버튼 아이템 ⭐
│               ├── xml/
│               │   └── speed_dial_widget_info.xml     # 위젯 메타데이터
│               └── values/
│                   └── strings.xml                    # 문자열 리소스
│
└── pubspec.yaml                            # Flutter 의존성
```

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
   - 전체 버튼 (3열 그리드, 선택 가능)
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
    
    // RecyclerView 어댑터 설정
    private fun setupAdapters() { ... }
    
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
5. **자동으로 설정 화면 표시**
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
theme={...Theme.Material.Light.Dialog...}
```

**근본 원인:**
- `WidgetConfigActivity`가 Dialog 테마를 사용
- 레이아웃 파일이 `selectableItemBackground` 속성 사용
- Dialog 테마는 이 속성을 지원하지 않음

**해결:**
```xml
<!-- AndroidManifest.xml -->
<!-- ❌ 이전 -->
<activity
    android:name=".widget.WidgetConfigActivity"
    android:theme="@android:style/Theme.Material.Light.Dialog">

<!-- ✅ 수정 -->
<activity
    android:name=".widget.WidgetConfigActivity"
    android:label="위젯 설정">
```

```xml
<!-- item_widget_button_all.xml -->
<!-- ❌ 이전 -->
<LinearLayout
    android:background="?android:attr/selectableItemBackground">

<!-- ✅ 수정 -->
<LinearLayout
    android:clickable="true"
    android:focusable="true">
```

### 문제 4: jsonDecode 미정의 에러

**증상:**
```
The method 'jsonDecode' isn't defined for the type 'SpeedDialProvider'
```

**해결:**
```dart
// speed_dial_provider.dart 상단에 추가
import 'dart:convert';
```

### 문제 5: 중복 리소스 에러

**증상:**
```
Found item String/widget_description more than one time
```

**해결:**
- `strings.xml`에서 중복된 항목 제거
- 각 리소스는 한 번만 정의되어야 함

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

### Phase 3: Configuration Activity 구현 ⭐
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

---

## 🔮 향후 계획

- [ ] 3×3, 4×2 등 다양한 위젯 크기 지원
- [ ] 다크/라이트 테마 위젯 스타일
- [ ] 위젯별 배경색 설정
- [ ] Flutter에서 위젯 관리 화면
- [ ] 클라우드 백업 기능
- [ ] iOS 위젯 지원

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