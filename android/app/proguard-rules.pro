# Add project specific ProGuard rules here.
# You can control the set of applied configuration files using the
# proguardFiles setting in build.gradle.

## Flutter wrapper
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }
-keep class io.flutter.embedding.** { *; }
-keep class io.flutter.embedding.engine.** { *; }

## Google Play Core (Fix for R8 missing classes)
-dontwarn com.google.android.play.core.splitcompat.**
-dontwarn com.google.android.play.core.splitinstall.**
-dontwarn com.google.android.play.core.tasks.**
-keep class com.google.android.play.core.** { *; }

## Gson
-keepattributes Signature
-keepattributes *Annotation*
-dontwarn sun.misc.**
-keep class com.google.gson.** { *; }
-keep class * extends com.google.gson.TypeAdapter
-keep class * implements com.google.gson.TypeAdapterFactory
-keep class * implements com.google.gson.JsonSerializer
-keep class * implements com.google.gson.JsonDeserializer

## OkHttp & Retrofit (used by Dio)
-dontwarn okhttp3.**
-dontwarn okio.**
-keepnames class okhttp3.internal.publicsuffix.PublicSuffixDatabase

## Dio
-keep class io.flutter.plugins.** { *; }

## Geolocator
-keep class com.baseflow.geolocator.** { *; }

## Image Picker
-keep class io.flutter.plugins.imagepicker.** { *; }

## Flutter Secure Storage
-keep class com.it_nomads.fluttersecurestorage.** { *; }

## Shared Preferences
-keep class io.flutter.plugins.sharedpreferences.** { *; }

## URL Launcher
-keep class io.flutter.plugins.urllauncher.** { *; }

## SVG
-keep class com.caverock.androidsvg.** { *; }

## Lottie
-keep class com.airbnb.lottie.** { *; }

## Pusher Channels (WebSocket)
-keep class com.pusher.** { *; }
-dontwarn org.slf4j.impl.StaticLoggerBinder
-dontwarn org.slf4j.**

## General Android
-keep public class * extends android.app.Activity
-keep public class * extends android.app.Application
-keep public class * extends android.app.Service
-keep public class * extends android.content.BroadcastReceiver
-keep public class * extends android.content.ContentProvider

## Remove logging in release
-assumenosideeffects class android.util.Log {
    public static *** d(...);
    public static *** v(...);
    public static *** i(...);
}

## Security: Prevent reverse engineering
-repackageclasses ''
-allowaccessmodification
-optimizations !code/simplification/arithmetic
-keepattributes *Annotation*

## Keep line numbers for crash reports
-keepattributes SourceFile,LineNumberTable
-renamesourcefileattribute SourceFile
