import java.util.Properties
import java.io.File
import java.io.FileInputStream

val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    FileInputStream(keystorePropertiesFile).use { keystoreProperties.load(it) }
}

plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.activeitzone.delivery_app"
    compileSdk = 36
    ndkVersion = "28.2.13676358"

    compileOptions {
        // Enable core library desugaring and use Java 21
        isCoreLibraryDesugaringEnabled = true
        sourceCompatibility = JavaVersion.toVersion(21)
        targetCompatibility = JavaVersion.toVersion(21)
    }

    kotlinOptions {
        jvmTarget = "21"
    }

    defaultConfig {
        applicationId = "com.activeitzone.delivery_app"
        minSdk = flutter.minSdkVersion
        targetSdk = 36
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        multiDexEnabled = true
    }

    // Load properties from local.properties
    val localProperties = Properties().apply {
        load(File(rootDir, "local.properties").inputStream())
    }

    val flutterRoot = localProperties.getProperty("flutter.sdk")
    if (flutterRoot == null) {
        throw GradleException("Flutter SDK not found. Define location with flutter.sdk in the local.properties file.")
    }

    // Load keystore properties
    val keystoreProperties = Properties().apply {
        load(File(rootDir, "key.properties").inputStream())
    }
    signingConfigs {
        create("release") {
            val storeFilePath = keystoreProperties["storeFile"]?.toString()
            if (!storeFilePath.isNullOrBlank()) {
                storeFile = file(storeFilePath)
            }
            storePassword = keystoreProperties["storePassword"]?.toString()
            keyAlias = keystoreProperties["keyAlias"]?.toString()
            keyPassword = keystoreProperties["keyPassword"]?.toString()
        }
    }

    buildTypes {
        getByName("release") {
            signingConfig = signingConfigs.getByName("release")
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )            // proguardFiles(getDefaultProguardFile("proguard-android-optimize.txt"), "proguard-rules.pro")
        }
    }
//    signingConfigs {
//        create("release") {
//            keyAlias = keystoreProperties["keyAlias"] as String
//            keyPassword = keystoreProperties["keyPassword"] as String
//            storeFile = file(keystoreProperties["storeFile"] as String)
//            storePassword = keystoreProperties["storePassword"] as String
//        }
//    }
//
//    buildTypes {
//        release {
//            signingConfig = signingConfigs.getByName("release")
//            isMinifyEnabled = true
//            isShrinkResources = true
//            proguardFiles(
//                getDefaultProguardFile("proguard-android-optimize.txt"),
//                "proguard-rules.pro"
//            )
//        }
//    }
}

flutter {
    source = "../.."
}

dependencies {
    implementation("androidx.multidex:multidex:2.0.1")
    implementation("com.google.android.gms:play-services-auth:20.7.0")
    implementation(files("libs/firebase-messaging-25.0.2.aar"))
    implementation(files("libs/firebase-common-22.0.1.aar"))
    implementation(files("libs/firebase-components-19.0.0.aar"))
    implementation(files("libs/firebase-annotations-17.0.0.jar"))
    implementation(files("libs/firebase-datatransport-18.2.0.aar"))
    implementation(files("libs/firebase-encoders-17.0.0.jar"))
    implementation(files("libs/firebase-encoders-json-18.0.0.aar"))
    implementation(files("libs/firebase-encoders-proto-16.0.0.jar"))
    implementation(files("libs/firebase-iid-interop-17.1.0.aar"))
    implementation(files("libs/firebase-installations-19.1.0.aar"))
    implementation(files("libs/firebase-installations-interop-17.3.0.aar"))
    implementation(files("libs/firebase-measurement-connector-19.0.0.aar"))
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.4")
  
}
