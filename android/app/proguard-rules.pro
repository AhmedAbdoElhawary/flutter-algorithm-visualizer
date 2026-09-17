# R8 / ProGuard rules for AlgoDive release builds.
#
# R8 removes any class it cannot see a reference to. It reads Java and Kotlin
# call sites, but it cannot see:
#   * classes reached by reflection,
#   * classes reached from native code over JNI,
#   * classes named only in AndroidManifest.xml or in a string.
# Those have to be listed here, or the build succeeds and the app crashes on a
# device with a ClassNotFoundException.
#
# Most of what this app needs is already supplied: AGP reads `consumer-rules`
# shipped inside firebase-*, play-services-* and sentry-android, so their own
# keep rules are applied automatically. What follows is the part that is ours,
# plus a few belts-and-braces entries.

# ---------------------------------------------------------------- Flutter ---
# The embedding is instantiated by name from AndroidManifest.xml
# (`android:name="${applicationName}"`), and the engine calls into these over
# JNI, so R8 sees no Java reference to them at all.
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.embedding.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# This app's own entry point, named in the manifest.
-keep class com.elhawary.algodive.MainActivity { *; }

# The Flutter embedding ships PlayStoreDeferredComponentManager and
# FlutterPlayStoreSplitApplication, which reference the Play Core split-install
# API. That library is only a dependency when an app actually uses deferred
# components; AlgoDive has no `deferred-components:` in pubspec.yaml and no
# `deferred as` imports, so the classes are genuinely absent and the code paths
# referencing them are unreachable.
#
# Without this, R8 stops the build on "Missing class
# com.google.android.play.core.splitinstall.*". If deferred components are ever
# added, remove this line and add the play-core dependency instead.
-dontwarn com.google.android.play.core.**

# --------------------------------------------------------------- Firebase ---
# firebase_auth and cloud_firestore deserialise into model classes through
# reflection, and Firestore reads annotations at runtime to map field names.
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }
-keepattributes Signature
-keepattributes *Annotation*
-keepattributes InnerClasses
-keepattributes EnclosingMethod

# Firestore maps documents onto classes by field name. Renaming a field breaks
# that mapping silently — the document loads with every field null.
-keepclassmembers class * {
    @com.google.firebase.firestore.PropertyName <fields>;
    @com.google.firebase.firestore.PropertyName <methods>;
}

# ----------------------------------------------------------------- Sentry ---
# Sentry walks stack traces and reads class and method names to build an event,
# so the names have to survive for a crash report to be readable.
-keep class io.sentry.** { *; }
-keepattributes SourceFile,LineNumberTable
-keepattributes LineNumberTable,SourceFile

# ------------------------------------------------------------------ misc. ---
# Kotlin coroutines' internals are reached reflectively by the runtime.
-keepclassmembers class kotlinx.coroutines.** { volatile <fields>; }
-dontwarn kotlinx.coroutines.**

# Referenced by some transitive AndroidX/Play dependencies but never shipped.
# Without these, R8 stops on "missing class" warnings for code that is not
# actually reachable at runtime.
-dontwarn javax.annotation.**
-dontwarn org.conscrypt.**
-dontwarn org.bouncycastle.**
-dontwarn org.openjsse.**

# Enum values are looked up by name via valueOf().
-keepclassmembers enum * {
    public static **[] values();
    public static ** valueOf(java.lang.String);
}

# Parcelable CREATOR fields are read reflectively by the framework.
-keepclassmembers class * implements android.os.Parcelable {
    public static final ** CREATOR;
}
