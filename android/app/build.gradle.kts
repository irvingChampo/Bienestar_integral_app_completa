// android/app/build.gradle.kts

// Plugins que deben aplicarse a la aplicación
plugins {
    id("com.android.application")
    kotlin("android") // Sintaxis recomendada para plugin de Kotlin
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")
}

// Importaciones requeridas para Kotlin DSL para manejo de archivos y propiedades
import java.io.FileInputStream
        import java.util.Properties

// --- BLOQUE 1: CARGA DE PROPIEDADES DE FIRMA (Kotlin DSL) ---
val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")

if (keystorePropertiesFile.exists()) {
    // Uso de 'use' para asegurar el cierre del FileInputStream
    FileInputStream(keystorePropertiesFile).use { input ->
        keystoreProperties.load(input)
    }
}
// ------------------------------------------

android {
    namespace = "com.example.bienestar_integral_app"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_1_8
        targetCompatibility = JavaVersion.VERSION_1_8
    }

    kotlinOptions {
        jvmTarget = "1.8"
    }

    defaultConfig {
        applicationId = "com.example.bienestar_integral_app"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    // --- BLOQUE 2: CONFIGURACIÓN DE FIRMA (Kotlin DSL) ---
    signingConfigs {
        // Usamos 'create' para definir la configuración de firma 'release'
        create("release") {
            // Usamos .getProperty() para acceder a las propiedades cargadas
            keyAlias = keystoreProperties.getProperty("keyAlias")
            keyPassword = keystoreProperties.getProperty("keyPassword")
            storePassword = keystoreProperties.getProperty("storePassword")

            // Lógica condicional de Kotlin (if-else) para storeFile
            val storeFilePath = keystoreProperties.getProperty("storeFile")
            if (storeFilePath != null) {
                storeFile = file(storeFilePath)
            } else {
                storeFile = null // Es explícito en Kotlin
            }
        }
    }
    // ---------------------------------------

    buildTypes {
        // Usamos getByName() para configurar el buildType 'release'
        getByName("release") {
            // --- BLOQUE 3: ACTIVAR FIRMA (Kotlin DSL) ---
            // Accedemos a la configuración de firma creada arriba usando getByName
            signingConfig = signingConfigs.getByName("release")
            isMinifyEnabled = false
            isShrinkResources = false
        }

        // El buildType 'debug' se define implícitamente, pero puedes configurarlo si es necesario:
        // getByName("debug") {}
    }
}

flutter {
    source = "../.."
}

dependencies {
    // Sintaxis corregida para platform() en Kotlin DSL: debe estar envuelto en paréntesis
    implementation(platform("com.google.firebase:firebase-bom:34.6.0"))

    // Aquí puedes añadir otras dependencias de Firebase/Kotlin (ejemplos)
    // implementation("com.google.firebase:firebase-analytics")
    // implementation("org.jetbrains.kotlin:kotlin-stdlib-jdk8")
}