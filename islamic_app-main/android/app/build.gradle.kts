plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
    // START: FlutterFire Configuration
    id("com.google.gms.google-services")
    id("com.google.firebase.crashlytics")
    // END: FlutterFire Configuration
}

android {
    namespace = "com.deenhub.app"
    compileSdk = 36
    ndkVersion = "27.2.12479018"

    signingConfigs {
        create("release") {
            keyAlias = "key0"
            keyPassword = "63Samim63."
            storeFile = rootProject.file("key0.jks")
            storePassword = "63Samim63."
        }
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
//        applicationId = "com.deenhub.app.dev"
        applicationId = "com.deenhub.app"
        minSdk = 24
        targetSdk = 36
        versionCode = 11
        versionName = "1.1.2"
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release")
        }
    }
    buildFeatures {
        viewBinding = true
    }
}

flutter {
    source = "../.."
}

dependencies {
    val work_version = "2.8.1"

    implementation("org.jetbrains.kotlin:kotlin-stdlib-jdk7:2.1.0")

    implementation(platform("com.google.firebase:firebase-bom:33.9.0"))
    implementation("com.google.firebase:firebase-analytics")
    implementation("com.google.firebase:firebase-crashlytics")

    implementation("androidx.work:work-runtime:$work_version")
    implementation("androidx.work:work-runtime-ktx:$work_version")

    implementation("com.google.code.gson:gson:2.11.0")

    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")

    implementation("androidx.window:window:1.0.0")
    implementation("androidx.window:window-java:1.0.0")
    
    // Add androidx.core for edge-to-edge support
    implementation("androidx.core:core:1.12.0")
    implementation("androidx.core:core-ktx:1.12.0")
    
}
