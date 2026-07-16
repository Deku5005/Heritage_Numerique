import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services") // ✅ Uniquement le nom du plugin, pas de version
}

android {
    namespace = "com.mali.heritagenumerique"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    // Signature pour la release (directement avec vos mots de passe)
    signingConfigs {
        create("release") {
            keyAlias = "upload"
            keyPassword = "motdepasse123"
            storeFile = file("upload-keystore.jks") // Assurez-vous que ce fichier est dans android/app/
            storePassword = "motdepasse123"
        }
    }

    defaultConfig {
        applicationId = "com.mali.heritagenumerique"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // Utilise la config release
            signingConfig = signingConfigs.getByName("release")
            isMinifyEnabled = false
            isShrinkResources = false
        }
    }
}

dependencies {
    // Firebase BoM
    implementation(platform("com.google.firebase:firebase-bom:34.16.0"))
    implementation("com.google.firebase:firebase-analytics")
    // Ajoutez ici d'autres dépendances Firebase si besoin
}

flutter {
    source = "../.."
}