import java.io.FileInputStream
import java.util.Properties

plugins {
    id("com.android.application")
    // START: FlutterFire Configuration
    id("com.google.gms.google-services")
    // END: FlutterFire Configuration
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}
val hasReleaseKeystore = keystorePropertiesFile.exists()

android {
    namespace = "com.elhawary.algodive"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    signingConfigs {
        // Real release key. Only present when key.properties exists (locally, or
        // injected by CI). In CI every flavor's release build is signed with it —
        // each environment injects its own keystore, one per run.
        if (hasReleaseKeystore) {
            create("release") {
                keyAlias = keystoreProperties["keyAlias"] as String?
                keyPassword = keystoreProperties["keyPassword"] as String?
                storeFile = keystoreProperties["storeFile"]?.let { file(it) }
                storePassword = keystoreProperties["storePassword"] as String?
            }
        }
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlin {
        compilerOptions {
            jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_11
        }
    }

    defaultConfig {
        applicationId = "com.elhawary.algodive"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildFeatures {
        // AGP 9 disables resValue by default; the per-flavor app_name needs it.
        resValues = true
    }

    // One dimension is enough: each flavor is a full environment.
    flavorDimensions += "environment"

    productFlavors {
        // No per-flavor signingConfig: every flavor inherits the build type's
        // config, so a `--release` build is signed with `release` when
        // key.properties is present (CI, or a local release build) and falls
        // back to `debug` otherwise. `flutter run --flavor dev` stays on the
        // debug build type and the debug key.
        create("dev") {
            dimension = "environment"
            applicationIdSuffix = ".dev"
            versionNameSuffix = "-dev"
            // Consumed by android:label="@string/app_name" in AndroidManifest.xml.
            resValue("string", "app_name", "AlgoDive Dev")
        }
        create("staging") {
            dimension = "environment"
            applicationIdSuffix = ".staging"
            versionNameSuffix = "-staging"
            resValue("string", "app_name", "AlgoDive Stag")
        }
        create("production") {
            dimension = "environment"
            // No suffix: the real applicationId and version.
            resValue("string", "app_name", "Algo Dive")
        }
    }

    buildTypes {
        release {
            // R8: strips unused Java/Kotlin classes and obfuscates what is left,
            // and shrinkResources drops the resources nothing references. Both
            // were off, so every release shipped the full Firebase, Sentry and
            // Play Services surface plus their unused resources.
            //
            // Anything reached by reflection has to be named in
            // proguard-rules.pro — R8 cannot see those references, and it fails
            // at runtime rather than at build time. Test a real release build,
            // do not trust a green `flutter build`.
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro",
            )

            // Release builds use the injected key when key.properties is present,
            // otherwise fall back to debug so `flutter build apk` still works in
            // environments without it (a fresh clone / PR CI).
            signingConfig = if (hasReleaseKeystore) {
                signingConfigs.getByName("release")
            } else {
                // TODO(ahmed): this is the one path that can produce a
                // debug-signed "release" build. CI catches it with the
                // apksigner check in deploy.yml; a local build only gets this
                // warning, so read the log before uploading anything.
                logger.warn(
                    "AlgoDive: key.properties not found — signing the RELEASE build " +
                        "with the DEBUG key. This artifact cannot be uploaded to Play."
                )
                signingConfigs.getByName("debug")
            }
        }
    }
}

flutter {
    source = "../.."
}
