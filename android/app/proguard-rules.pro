# Quick Call - ProGuard Rules

# Flutter 관련 규칙
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }

# Gson 사용 시 (JSON 직렬화)
-keepattributes Signature
-keepattributes *Annotation*
-dontwarn sun.misc.**
-keep class com.google.gson.** { *; }
-keep class * implements com.google.gson.TypeAdapter
-keep class * implements com.google.gson.TypeAdapterFactory
-keep class * implements com.google.gson.JsonSerializer
-keep class * implements com.google.gson.JsonDeserializer

# SQLite 관련 규칙
-keep class * extends androidx.sqlite.db.SupportSQLiteOpenHelper { *; }
-keep class * extends androidx.room.RoomDatabase { *; }

# AndroidX 관련
-keep class androidx.** { *; }
-keep interface androidx.** { *; }
-dontwarn androidx.**

# Kotlin 관련
-keep class kotlin.** { *; }
-keep class kotlin.Metadata { *; }
-dontwarn kotlin.**
-keepclassmembers class **$WhenMappings {
    <fields>;
}
-keepclassmembers class kotlin.Metadata {
    public <methods>;
}

# Permission Handler 플러그인
-keep class com.baseflow.permissionhandler.** { *; }

# URL Launcher 플러그인
-keep class io.flutter.plugins.urllauncher.** { *; }

# Flutter Contacts 플러그인
-keep class com.github.frappe.contacts.** { *; }

# 앱 데이터 모델 유지
-keep class com.oceancode.quick_call.models.** { *; }
-keepclassmembers class com.oceancode.quick_call.models.** { *; }

# Native 메서드 유지
-keepclasseswithmembernames class * {
    native <methods>;
}

# Enum 클래스 유지
-keepclassmembers enum * {
    public static **[] values();
    public static ** valueOf(java.lang.String);
}

# Serializable 클래스 유지
-keepclassmembers class * implements java.io.Serializable {
    static final long serialVersionUID;
    private static final java.io.ObjectStreamField[] serialPersistentFields;
    private void writeObject(java.io.ObjectOutputStream);
    private void readObject(java.io.ObjectInputStream);
    java.lang.Object writeReplace();
    java.lang.Object readResolve();
}

# Parcelable 구현 유지
-keep class * implements android.os.Parcelable {
    public static final android.os.Parcelable$Creator *;
}

# 디버깅 정보 유지
-keepattributes SourceFile,LineNumberTable
-renamesourcefileattribute SourceFile

# 크래시 리포팅을 위한 스택 트레이스 유지
-keepattributes *Annotation*
-keepattributes EnclosingMethod

# 경고 무시
-dontwarn javax.annotation.**
-dontwarn org.conscrypt.**
-dontwarn org.bouncycastle.**
-dontwarn org.openjsse.**