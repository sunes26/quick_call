plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.quick_call"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        // Quick Call 앱의 고유 Application ID
        applicationId = "com.example.quick_call"
        
        // Android 8.0 (Oreo) 이상 지원
        minSdk = 26
        targetSdk = flutter.targetSdkVersion
        
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        
        // MultiDex 지원
        multiDexEnabled = true
    }

    buildTypes {
        release {
            // 릴리스 빌드 최적화
            isMinifyEnabled = true
            isShrinkResources = true
            
            // ProGuard 설정
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
            
            // TODO: 프로덕션 배포 시 아래 주석을 해제하고 자체 서명 키 설정
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
        }
        
        debug {
            // 디버그 빌드 설정
            applicationIdSuffix = ".debug"
            isDebuggable = true
        }
    }
    
    lint {
        disable.add("InvalidPackage")
        checkReleaseBuilds = false
    }
}

flutter {
    source = "../.."
}

dependencies {
    // AndroidX 핵심 라이브러리
    implementation("androidx.core:core-ktx:1.12.0")
    implementation("androidx.lifecycle:lifecycle-runtime-ktx:2.7.0")
    
    // MultiDex 지원
    implementation("androidx.multidex:multidex:2.0.1")
    
    // ✅ RecyclerView 및 UI 컴포넌트 (위젯 설정 화면용)
    implementation("androidx.recyclerview:recyclerview:1.3.2")
    implementation("androidx.cardview:cardview:1.0.0")
}