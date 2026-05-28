allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// AGP 8+ requires every Android library to declare a namespace. Some older
// transitive Flutter plugins (flutter_keyboard_visibility 5.x, etc.) still
// rely on the deprecated package= attribute in their AndroidManifest.xml.
// This fallback derives a namespace from the manifest's package attribute
// so we don't have to fork the plugin to ship.
//
// Also forces JVM target consistency. Some old plugins (image_compression_flutter
// 1.0.4) compile Java at 1.8 while Kotlin defaults to the host JDK (21 here),
// which AGP rejects. Pinning both to 17 matches app/build.gradle.kts.
subprojects {
    afterEvaluate {
        if (extensions.findByName("android") != null) {
            val androidExt = extensions.getByName("android") as com.android.build.gradle.BaseExtension
            if (androidExt.namespace == null) {
                val manifest = file("src/main/AndroidManifest.xml")
                if (manifest.exists()) {
                    val pkg = "package=\"([^\"]+)\"".toRegex()
                        .find(manifest.readText())?.groupValues?.get(1)
                    if (!pkg.isNullOrBlank()) {
                        androidExt.namespace = pkg
                    }
                }
            }
            androidExt.compileOptions {
                sourceCompatibility = JavaVersion.VERSION_21
                targetCompatibility = JavaVersion.VERSION_21
            }
            // Match the host app's compileSdk (Flutter default for 3.38: 36)
            // so plugins using newer Android APIs (Thread.threadId() in
            // sqflite_android, etc.) find them on the bootclasspath.
            androidExt.compileSdkVersion(36)
        }
        // sqflite_android 2.4.2+3 uses Thread.threadId() (Java 19+ API). Host
        // JDK is 21; aligning Kotlin + Java targets at 21 avoids the mismatch.
        tasks.withType<org.jetbrains.kotlin.gradle.tasks.KotlinCompile>().configureEach {
            compilerOptions {
                jvmTarget.set(org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_21)
            }
        }
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
