# 🚀 NanoMCP: 移动端 AI 适配器 SDK

**让任何 Android App 能零门槛接入 MCP (Model Context Protocol) 生态，成为 AI 的"手"和"眼"。**

## 📦 下载

### 最新版本

请访问 [Releases](https://github.com/pandawengogo/Mobile-MCP-SDK/releases) 页面下载最新版本的打包文件：

- `nanomcp-sdk-{version}.aar` - 主 SDK 库
- `mcp-annotations-{version}.jar` - 注解库（编译时依赖）
- `mcp-compiler-{version}.jar` - KSP 编译器（编译时依赖）

所有文件都包含 SHA256 校验和文件（`.sha256`），用于验证文件完整性。

## 🚀 快速开始

### 1. 添加依赖

将下载的 AAR 和 JAR 文件复制到你的 Android 项目的 `libs` 目录，然后在 `build.gradle.kts` 中添加：

```kotlin
plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android")
    id("com.google.devtools.ksp") version "1.9.22-1.0.17"
}

dependencies {
    // NanoMCP SDK
    implementation(fileTree(mapOf("dir" to "libs", "include" to listOf("*.aar"))))
    compileOnly(files("libs/mcp-annotations-{version}.jar"))
    ksp(files("libs/mcp-compiler-{version}.jar"))
    
    // 必需的第三方依赖
    implementation("androidx.biometric:biometric:1.1.0")
    implementation("com.squareup.okhttp3:okhttp:4.12.0")
}
```

### 2. 定义工具函数

```kotlin
import com.nanomcp.annotations.McpTool
import com.nanomcp.annotations.McpParam

@McpTool(description = "添加待办事项")
fun addTodo(
    @McpParam("待办内容") title: String,
    @McpParam("优先级") priority: Int = 0
): String {
    // 你的实现代码
    return "已添加：$title"
}

@McpTool(description = "发送通知")
fun sendNotification(
    @McpParam("标题") title: String,
    @McpParam("内容") body: String
) {
    // 你的实现代码
}
```

### 3. 启动 SDK

```kotlin
import com.nanomcp.core.McpServer

class MainActivity : AppCompatActivity() {
    private lateinit var mcpServer: McpServer
    
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        
        // 初始化并启动
        mcpServer = McpServer(port = 8080)
        mcpServer.registerGeneratedTools()  // 自动生成的扩展函数
        mcpServer.start()
        
        // 显示 Token (用于 AI 连接)
        Log.i("MCP", "Token: ${mcpServer.authToken}")
    }
    
    override fun onDestroy() {
        super.onDestroy()
        mcpServer.stop()
    }
}
```

## ✨ 核心特性

- **⚡️ 零侵入** - 只需加注解，不改原有代码
- **🔒 类型安全** - 编译时验证参数类型，运行时无反射
- **📦 极致轻量** - 总体积 < 200KB（一张图片的大小）
- **🚀 开箱即用** - 3 步接入，10 分钟上手
- **🛡️ 安全可控** - Token 认证机制，局域网隔离

## 📋 系统要求

- **最低 Android 版本**: API 21 (Android 5.0)
- **目标 Android 版本**: API 34 (Android 14)
- **Kotlin 版本**: 1.9.22+
- **Gradle 版本**: 8.3.0+

## 🔧 ProGuard 配置

如果你的项目启用了混淆，请在 `proguard-rules.pro` 中添加：

```proguard
# NanoMCP SDK
-keep class com.nanomcp.generated.** { *; }
-keepclassmembers class * {
    @com.nanomcp.annotations.McpTool *;
}
```

## 📚 更多文档

详细的使用文档和 API 参考请参考每个 Release 中的 `RELEASE_NOTES.md` 文件。

## 🔒 许可证

MIT License

## 💬 技术支持

如有问题或建议，请通过 GitHub Issues 联系我们。

---

**让移动端 App 拥抱 AI 时代！**

