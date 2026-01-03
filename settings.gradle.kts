pluginManagement {
    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }
}

dependencyResolutionManagement {
    repositoriesMode.set(RepositoriesMode.FAIL_ON_PROJECT_REPOS)
    repositories {
        google()
        mavenCentral()
    }
}

rootProject.name = "NanoMCP"

include(":mcp-annotations")
include(":mcp-api")
include(":mcp-core")
include(":mcp-client")
include(":mcp-compiler")
include(":nanomcp-sdk")
include(":sample-app")


