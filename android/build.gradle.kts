plugins {
    // Usa la versión que Gradle ya cargó (8.9.1) para evitar el conflicto
    id("com.android.application") version "8.9.1" apply false

    // Si tienes un conflicto similar con Kotlin, ajústalo. Si no, déjalo.
    id("org.jetbrains.kotlin.android") version "2.1.0" apply false

    // Este fue el plugin original que faltaba y debe permanecer.
    id("com.google.gms.google-services") version "4.4.1" apply false
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}