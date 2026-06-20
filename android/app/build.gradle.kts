plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.moonjoin.cloud"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_21
        targetCompatibility = JavaVersion.VERSION_21
        // Required by flutter_local_notifications 17.x: it uses java.time APIs
        // that only exist on Android 26+, so we back-port via desugar.
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_21.toString()
    }

    defaultConfig {
        applicationId = "com.moonjoin.cloud"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName

        // Google Maps API key injected at build time. Pass via:
        //   ./gradlew assembleRelease -PMAPS_API_KEY=<key>
        // or by exporting MAPS_API_KEY in the environment.
        val mapsKey = (project.findProperty("MAPS_API_KEY") as? String)
            ?: System.getenv("MAPS_API_KEY")
            ?: ""
        manifestPlaceholders["MAPS_API_KEY"] = mapsKey
    }

    // -------------------------------------------------------------------
    // Production signing
    // -------------------------------------------------------------------
    // The keystore is NOT committed. Operations team creates `android/key.properties`:
    //
    //   storePassword=<...>
    //   keyPassword=<...>
    //   keyAlias=<...>
    //   storeFile=<absolute path to .jks>
    //
    // Then uncomment the signingConfigs.release block + flip release.signingConfig.
    //
    // val keystorePropertiesFile = rootProject.file("key.properties")
    // val keystoreProperties = java.util.Properties()
    // if (keystorePropertiesFile.exists()) {
    //     keystoreProperties.load(java.io.FileInputStream(keystorePropertiesFile))
    // }
    // signingConfigs {
    //     create("release") {
    //         keyAlias = keystoreProperties["keyAlias"] as String
    //         keyPassword = keystoreProperties["keyPassword"] as String
    //         storeFile = file(keystoreProperties["storeFile"] as String)
    //         storePassword = keystoreProperties["storePassword"] as String
    //     }
    // }

    buildTypes {
        release {
            // TODO(ops): swap to signingConfigs.getByName("release") once key.properties is in place.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

// -------------------------------------------------------------------
// Firebase (FCM + Crashlytics) wiring — uncomment after dropping
// android/app/google-services.json from the new Firebase project.
// -------------------------------------------------------------------
// apply(plugin = "com.google.gms.google-services")
// apply(plugin = "com.google.firebase.crashlytics")

dependencies {
    // Back-ports java.time + other JDK APIs to Android < 26.
    // Required by flutter_local_notifications and any plugin pulling
    // java.time.* (which is most of them on AGP 8+).
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}

flutter {
    source = "../.."
}
