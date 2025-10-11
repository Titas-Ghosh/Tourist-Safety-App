plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
    // Firebase Google Services plugin
    id("com.google.gms.google-services")
}

android {
    namespace = "com.example.test"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
        // ✅ Enable desugaring
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.example.test" // Unique App ID
        minSdk = 23
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    implementation(platform("com.google.firebase:firebase-bom:33.1.2")) // Firebase BOM (keeps versions in sync)

    // Firestore
    implementation("com.google.firebase:firebase-firestore")

    // (Optional but useful) Firebase Auth if you’ll need it later
    // implementation("com.google.firebase:firebase-auth")

    // Play Services Location (needed for geofencing)
    implementation("com.google.android.gms:play-services-location:21.2.0")

    // ✅ Core library desugaring (updated to 2.1.4)
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}
