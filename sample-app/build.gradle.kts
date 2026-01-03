plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android")
    id("com.google.devtools.ksp")
}

android {
    namespace = "com.nanomcp.sample"
    compileSdk = 34

    defaultConfig {
        applicationId = "com.nanomcp.sample"
        minSdk = 21
        targetSdk = 34
        versionCode = 1
        versionName = "1.0"
    }

    buildTypes {
        release {
            isMinifyEnabled = false
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }
    
    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }
    
    kotlinOptions {
        jvmTarget = "17"
    }
    
    buildFeatures {
        viewBinding = true
    }
}

dependencies {
    // NanoMCP SDK（使用项目依赖，依赖会自动传递）
    implementation(project(":nanomcp-sdk"))
    ksp(project(":mcp-compiler"))
    
    // 如果使用 AAR 文件，请改用以下配置：
    // implementation(files("libs/nanomcp-sdk-release.aar"))
    // ksp(files("libs/mcp-compiler-1.0.0.jar"))
    // 并手动添加以下依赖：
    // implementation("androidx.fragment:fragment-ktx:1.6.2")
    // implementation("androidx.biometric:biometric:1.1.0")
    
    // Android 基础库
    implementation("androidx.core:core-ktx:1.12.0")
    implementation("androidx.appcompat:appcompat:1.6.1")
    implementation("com.google.android.material:material:1.11.0")
    implementation("androidx.constraintlayout:constraintlayout:2.1.4")
    
    // OkHttp (sample-app 的 ClaudeClient 需要，用于调用 AI API)
    // 注意：这不是 MCP SDK 的依赖，仅用于演示 AI 集成
    implementation("com.squareup.okhttp3:okhttp:4.12.0")
}


