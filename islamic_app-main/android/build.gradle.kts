buildscript {
    extra.apply {
        set("compileSdkVersion", 36)
        set("targetSdkVersion", 36)
        set("appCompatVersion", "1.4.2")
    }
}
allprojects {
    repositories {
        google()
        mavenCentral()
//        // [required] background_fetch
//        maven { url = uri(project(":background_fetch").projectDir.toString() + "/libs") }
    }
    subprojects {
        afterEvaluate {
            extensions.findByType<com.android.build.gradle.BaseExtension>()?.apply {
                if (namespace.isNullOrEmpty()) {
                    namespace = project.group.toString()
                }
            
                if (plugins.hasPlugin("com.android.application") ||
                    plugins.hasPlugin("com.android.library")
                ) {
                    compileSdkVersion(36)
                    buildToolsVersion("36.0.0")
                }
            }
        }
    }
}

val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
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
