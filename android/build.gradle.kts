extra["compileSdkVersion"] = 36
extra["targetSdkVersion"] = 34
extra["minSdkVersion"] = 21

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

subprojects {
    val configureProject = {
        if (project.hasProperty("android")) {
            val android = project.extensions.findByName("android")
            if (android != null) {
                try {
                    val compileSdkProp = android.javaClass.getMethod("setCompileSdk", java.lang.Integer::class.java)
                    compileSdkProp.invoke(android, 36)
                } catch (e: Exception) {
                    try {
                        val compileSdkMethod = android.javaClass.getMethod("compileSdkVersion", Int::class.javaPrimitiveType)
                        compileSdkMethod.invoke(android, 36)
                    } catch (e2: Exception) {}
                }
            }
        }
    }
    if (project.state.executed) {
        configureProject()
    } else {
        project.afterEvaluate { configureProject() }
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
