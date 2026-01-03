# 🚀 NanoMCP SDK: 移动端 AI 适配器

**让移动端 App 能被 AI 识别和调用，成为 AI 的"手"和"眼"。**

## 📖 产品定位

**一句话定义**: 移动端 App 的 AI 适配器 SDK

**支持的平台**:
- ✅ **Android** - 已实现，生产就绪
- 🚧 **iOS** - 计划中
- 🚧 **Flutter** - 计划中
- 🚧 **React Native** - 计划中
- 🚧 **Web** - 计划中

**类比理解**:
- 就像 USB 驱动程序让硬件能被电脑识别
- 就像支付宝 SDK 让 App 能接入支付能力
- 我们让 App 能被 AI 识别和调用

---

## 🌟 为什么选择 NanoMCP？

* **⚡️ 零侵入集成：** 只需在现有函数上加注解，NanoMCP 自动处理 JSON-RPC、Schema 生成和协议握手
* **🔐 本地优先安全：** 数据不离开设备，NanoMCP 作为本地网关运行
* **🛡️ 可选安全验证：** 内置生物识别验证机制，敏感操作可要求指纹/面部识别
* **📦 极致轻量：** Android 版本总体积 < 200KB
* **🌐 跨平台愿景：** 统一的 API 设计，多平台实现（Android 已实现）

---

## 🛠 快速开始（Android）

> ⚠️ **注意**: 当前版本仅支持 Android 平台。iOS、Flutter、React Native、Web 版本正在开发中。

### 1. 添加依赖

将下载的 AAR 和 JAR 文件复制到您的 Android 项目的 `libs` 目录，然后在 `build.gradle.kts` 中添加：

```kotlin
plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android")
    id("com.google.devtools.ksp") version "1.9.22-1.0.17"
}

dependencies {
    // NanoMCP SDK
    // nanomcp-sdk-release.aar 是 Fat AAR，已包含所有核心模块
    implementation(files("libs/nanomcp-sdk-release.aar"))
    ksp(files("libs/mcp-compiler-1.0.0.jar"))
    
    // 必需的 AndroidX 依赖（SDK 需要）
    implementation("androidx.fragment:fragment-ktx:1.6.2")
    implementation("androidx.biometric:biometric:1.1.0")
    
    // 其他 Android 基础库（根据您的项目需要）
    implementation("androidx.core:core-ktx:1.12.0")
    implementation("androidx.appcompat:appcompat:1.6.1")
}
```

> 💡 **提示**: `nanomcp-sdk-release.aar` 是一个 Fat AAR，已经包含了所有必要的模块。

### 2. 定义工具函数

只需在您现有的业务逻辑函数上添加 `@McpTool` 注解。NanoMCP 的 KSP 编译器会自动生成 MCP Schema 和注册代码。

```kotlin
import com.nanomcp.annotations.McpTool
import com.nanomcp.annotations.McpParam

/**
 * 基础工具示例
 */
@McpTool(description = "计算两个整数的和")
fun add(
    @McpParam("第一个数字") a: Int,
    @McpParam("第二个数字") b: Int
): Int {
    return a + b
}

@McpTool(description = "将字符串反转")
fun reverseString(
    @McpParam("要反转的字符串") text: String
): String {
    return text.reversed()
}
```

### 3. 启动 MCP 服务器

NanoMCP 提供两种使用方式：

#### 方式一：应用内直接调用（推荐）

适用于应用内部直接调用工具，无需启动 HTTP 服务器。

```kotlin
import com.nanomcp.core.McpServer

class MainActivity : AppCompatActivity() {
    private lateinit var mcpServer: McpServer
    
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)
        
        // 创建 MCP 服务器（不启用 HTTP 服务器）
        mcpServer = McpServer(enableHttpServer = false)
        mcpServer.registerGeneratedTools()  // 自动注册所有 @McpTool 函数
        
        // 直接调用工具
        val result = mcpServer.callTool("add", mapOf("a" to 10, "b" to 20))
        Log.i("MCP", "Result: $result")  // 输出: 30
    }
}
```

#### 方式二：启用 HTTP 服务器（用于外部 AI 客户端连接）

适用于需要外部 AI 客户端（如 Claude Desktop、Cursor）通过 HTTP 连接调用工具。

```kotlin
import com.nanomcp.core.McpServer

class MainActivity : AppCompatActivity() {
    private lateinit var mcpServer: McpServer
    
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)
        
        // 创建并启动 MCP 服务器（启用 HTTP 服务器）
        mcpServer = McpServer(enableHttpServer = true, port = 8080)
        mcpServer.registerGeneratedTools()  // 自动注册所有 @McpTool 函数
        mcpServer.start()  // 启动 HTTP 服务器
        
        // 显示 Token (用于 AI 连接认证)
        val token = mcpServer.authToken
        Log.i("MCP", "Auth Token: $token")
        // 可以将 Token 显示在 UI 上供用户复制
    }
    
    override fun onDestroy() {
        super.onDestroy()
        mcpServer.stop()  // 停止服务器
    }
}
```

### 4. （可选）添加安全验证

对于敏感操作（如支付、删除数据），可以要求安全验证。NanoMCP 提供了灵活的验证机制。

#### 4.1 标记需要验证的工具

使用 `@McpSecure` 注解标记需要验证的工具：

```kotlin
import com.nanomcp.annotations.McpTool
import com.nanomcp.annotations.McpParam
import com.nanomcp.api.McpSecure

@McpTool(description = "添加一笔支出记录")
@McpSecure(reason = "此操作会修改您的财务记录")  // 标记需要验证
fun addExpense(
    @McpParam("金额（元）") amount: Double,
    @McpParam("类别") category: String,
    @McpParam("备注") note: String = ""
): String {
    // 保存支出记录
    return "支出记录已添加：¥$amount"
}
```

#### 4.2 验证方式一：使用内置的生物识别验证

SDK 提供了 `BiometricAuthenticationHandler`，支持指纹/面部识别：

```kotlin
import com.nanomcp.core.McpServer
import com.nanomcp.core.BiometricAuthenticationHandler

class MainActivity : AppCompatActivity() {
    private lateinit var mcpServer: McpServer
    
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)
        
        // 使用内置的生物识别验证
        val authHandler = BiometricAuthenticationHandler(this)
        
        mcpServer = McpServer(
            enableHttpServer = false,
            authenticationHandler = authHandler
        )
        mcpServer.registerGeneratedTools()
        
        // 调用带 @McpSecure 注解的工具时，会自动弹出生物识别验证
        val result = mcpServer.callTool("addExpense", mapOf(
            "amount" to 500.0,
            "category" to "餐饮",
            "note" to "午餐"
        ))
    }
}
```

**工作原理**：
- 如果设备支持生物识别，会弹出指纹/面部识别对话框
- 如果设备不支持，会降级为确认对话框
- 对话框会显示工具名称、验证原因和参数信息

#### 4.3 验证方式二：继承并自定义生物识别行为

可以继承 `BiometricAuthenticationHandler` 并重写方法来自定义验证逻辑：

```kotlin
import com.nanomcp.core.BiometricAuthenticationHandler

/**
 * 自定义验证：小额免验证，大额需要生物识别
 */
class SmartAuthHandler(activity: FragmentActivity) : BiometricAuthenticationHandler(activity) {
    override fun authenticate(
        toolName: String, 
        reason: String, 
        arguments: Map<String, Any>
    ): Boolean {
        // 根据金额决定是否需要验证
        val amount = arguments["amount"] as? Double ?: 0.0
        
        if (amount < 100.0) {
            // 小额免验证
            Log.i("Auth", "小额操作，免验证：¥$amount")
            return true
        }
        
        // 大额调用父类的生物识别验证
        Log.i("Auth", "大额操作，需要验证：¥$amount")
        return super.authenticate(toolName, reason, arguments)
    }
}

// 使用自定义验证
val authHandler = SmartAuthHandler(this)
mcpServer = McpServer(
    enableHttpServer = false,
    authenticationHandler = authHandler
)
```

#### 4.4 验证方式三：自定义确认对话框内容

可以重写 `showConfirmationDialog` 方法来自定义对话框内容：

```kotlin
class CustomDialogAuthHandler(activity: FragmentActivity) : BiometricAuthenticationHandler(activity) {
    override fun showConfirmationDialog(
        toolName: String, 
        reason: String,
        arguments: Map<String, Any>
    ): Boolean {
        val latch = CountDownLatch(1)
        var result = false
        
        activity.runOnUiThread {
            // 自定义对话框内容
            val amount = arguments["amount"] as? Double ?: 0.0
            val category = arguments["category"] as? String ?: "未知"
            
            AlertDialog.Builder(activity)
                .setTitle("⚠️ 确认支出")
                .setMessage(
                    "您即将添加一笔支出记录：\n\n" +
                    "💰 金额：¥${String.format("%.2f", amount)}\n" +
                    "📂 类别：$category\n\n" +
                    "是否确认？"
                )
                .setPositiveButton("确认") { _, _ ->
                    result = true
                    latch.countDown()
                }
                .setNegativeButton("取消") { _, _ ->
                    result = false
                    latch.countDown()
                }
                .setOnCancelListener {
                    result = false
                    latch.countDown()
                }
                .show()
        }
        
        latch.await(60, TimeUnit.SECONDS)
        return result
    }
}
```

#### 4.5 验证方式四：完全自定义验证逻辑

实现 `AuthenticationHandler` 接口，完全自定义验证逻辑：

```kotlin
import com.nanomcp.core.AuthenticationHandler

/**
 * 完全自定义验证：可以实现任何验证方式
 */
class CustomAuthHandler(private val activity: FragmentActivity) : AuthenticationHandler {
    override fun authenticate(
        toolName: String, 
        reason: String,
        arguments: Map<String, Any>
    ): Boolean {
        // 方案 1: 根据工具名称决定验证方式
        return when (toolName) {
            "addExpense" -> {
                val amount = arguments["amount"] as? Double ?: 0.0
                if (amount < 100.0) true else showPinDialog()
            }
            "clearAllTransactions" -> {
                // 删除操作必须验证
                showBiometricOrPin()
            }
            else -> {
                // 其他操作不需要验证
                true
            }
        }
        
        // 方案 2: 调用远程授权服务
        // return callRemoteAuthService(toolName, arguments)
        
        // 方案 3: 使用风险评分系统
        // val riskScore = calculateRiskScore(toolName, arguments)
        // return if (riskScore > 0.7) showBiometric() else true
        
        // 方案 4: 完全不验证
        // return true
    }
    
    private fun showPinDialog(): Boolean {
        // 实现 PIN 码验证
        // ...
        return true
    }
    
    private fun showBiometricOrPin(): Boolean {
        // 实现生物识别或 PIN 码验证
        // ...
        return true
    }
}

// 使用完全自定义验证
val authHandler = CustomAuthHandler(this)
mcpServer = McpServer(
    enableHttpServer = false,
    authenticationHandler = authHandler
)
```

#### 4.6 验证方式五：不使用验证

如果不需要验证，直接不传 `authenticationHandler` 参数即可：

```kotlin
// 不传 authenticationHandler，所有工具都不会验证
mcpServer = McpServer(enableHttpServer = false)
mcpServer.registerGeneratedTools()

// 即使工具有 @McpSecure 注解，也不会弹出验证
val result = mcpServer.callTool("addExpense", mapOf(
    "amount" to 500.0,
    "category" to "餐饮"
))
```

---

## 📦 下载（Android）

访问 [Releases](https://github.com/pandawengogo/Mobile-MCP-SDK/releases) 页面下载最新版本：

- `nanomcp-sdk-{version}.aar` - 主 SDK 库（Fat AAR，包含所有核心模块）
- `mcp-compiler-{version}.jar` - KSP 编译器（编译时依赖，用于代码生成）

所有文件都包含 SHA256 校验和文件（`.sha256`），用于验证文件完整性。

> 💡 **说明**: `nanomcp-sdk-release.aar` 是一个合并了所有模块的 Fat AAR，您只需要这一个 AAR 文件即可。

---

## 🏗 工作原理

NanoMCP 在您的应用和 AI 模型之间创建了一个**标准化接口层**。

### 编译时流程

1. **注解扫描**: KSP 编译器扫描所有带 `@McpTool` 注解的函数
2. **代码生成**: 自动生成工具注册代码（`McpToolRegistry.kt`）
3. **Schema 生成**: 为每个工具生成 JSON Schema 描述

### 运行时流程

**方式一：应用内直接调用**
1. 调用 `mcpServer.callTool(name, args)`
2. NanoMCP 解析参数并调用对应的函数
3. 返回执行结果

**方式二：HTTP 服务器模式**
1. **发现**: AI 主机通过 HTTP 请求获取可用工具列表
2. **调用**: AI 发送 JSON-RPC 请求调用工具
3. **执行**: NanoMCP 解析参数并调用对应的函数
4. **返回**: 将函数返回值转换为 JSON-RPC 响应

---

## ✨ 核心特性

### 已实现功能（Android）

- ✅ **注解驱动开发** - 使用 `@McpTool` 和 `@McpParam` 定义工具
- ✅ **KSP 代码生成** - 编译时自动生成注册代码和 Schema
- ✅ **两种调用方式** - 应用内直接调用 或 HTTP 服务器模式
- ✅ **Token 认证** - HTTP 模式下的 Bearer Token 认证
- ✅ **生物识别验证** - 可选的指纹/面部识别验证（`@McpSecure`）
- ✅ **自定义验证** - 支持自定义 `AuthenticationHandler`
- ✅ **类型安全** - 编译时验证参数类型
- ✅ **超时控制** - 可配置工具执行超时时间
- ✅ **极致轻量** - 总体积 < 200KB

### 支持的数据类型

- `Int`, `Long`, `Double`, `Boolean`, `String`
- 可选参数（带默认值）
- 返回值：基础类型 或 `String`

---

## 📋 系统要求（Android）

- **最低 Android 版本**: API 21 (Android 5.0)
- **目标 Android 版本**: API 34 (Android 14)
- **Kotlin 版本**: 1.9.22+
- **Gradle 版本**: 8.3.0+
- **KSP 版本**: 1.9.22-1.0.17+

---

## 🔧 ProGuard 配置（Android）

如果您的项目启用了混淆，请在 `proguard-rules.pro` 中添加：

```proguard
# NanoMCP SDK
# 保留所有 KSP 生成的工具注册代码
-keep class com.nanomcp.generated.** { *; }

# 保留所有带 @McpTool 注解的函数
-keepclassmembers class * {
    @com.nanomcp.annotations.McpTool *;
}

# 保留所有带 @McpParam 注解的参数
-keepclassmembers class * {
    @com.nanomcp.annotations.McpParam *;
}
```

---

## 📚 示例应用（Android）

查看 `sample-app/` 目录获取完整的使用示例，包括：

- **基础工具**: 计算、字符串处理等简单工具
- **记账工具**: 带生物识别验证的财务记录管理
- **HTTP 服务器**: 启动服务器并通过 curl 测试
- **AI 聊天**: 集成 Claude API 的对话示例

---

## 📈 使用场景

| 行业       | AI 能力示例                                          |
| ---------- | ------------------------------------------------------- |
| **金融科技** | "分析我上个月在咖啡上的支出并设置预算"                 |
| **电商**     | "找到我尺码最畅销的跑鞋并加入购物车"                   |
| **SaaS/OA**  | "总结未读审批并批准低于 500 美元的申请"               |
| **医疗健康** | "检查我的心率趋势，如果异常则提醒我的医生"             |
| **个人助手** | "记录今天的运动数据并同步到健康应用"                   |

---

## 🔍 测试验证（Android）

### 使用 curl 测试 HTTP 服务器

启动 App 后，使用 curl 测试:

```bash
# 获取工具列表
curl -X POST http://localhost:8080 \
  -H "Authorization: Bearer <token>" \
  -H "Content-Type: application/json" \
  -d '{"method":"tools/list","params":{}}'

# 调用工具
curl -X POST http://localhost:8080 \
  -H "Authorization: Bearer <token>" \
  -H "Content-Type: application/json" \
  -d '{"method":"tools/call","params":{"name":"add","arguments":{"a":10,"b":20}}}'
```

---

## 🗺️ 平台支持路线图

### ✅ Android（已实现）

- [x] Kotlin 注解支持
- [x] KSP 代码生成
- [x] HTTP JSON-RPC 服务器
- [x] 应用内直接调用
- [x] 生物识别保护
- [x] Token 认证
- [x] 工具自动注册

### 🚧 iOS（计划中）

- [ ] Swift Macros 支持
- [ ] Swift Package Manager 集成
- [ ] HTTP JSON-RPC 服务器
- [ ] FaceID/TouchID 保护
- [ ] Token 认证
- [ ] 工具自动注册

### 📋 Flutter（计划中）

- [ ] Dart 注解支持
- [ ] 代码生成插件
- [ ] 跨平台 HTTP 服务器
- [ ] 生物识别插件集成
- [ ] Token 认证
- [ ] 工具自动注册

### 📋 React Native（计划中）

- [ ] TypeScript 类型定义
- [ ] 原生模块桥接
- [ ] HTTP JSON-RPC 服务器
- [ ] 生物识别模块集成
- [ ] Token 认证
- [ ] 工具自动注册

### 📋 Web（计划中）

- [ ] TypeScript/JavaScript SDK
- [ ] WebSocket 支持
- [ ] 浏览器安全机制
- [ ] Token 认证
- [ ] 工具自动注册

---

## ⚠️ 当前版本限制（Android）

- 仅支持基础类型参数 (Int, String, Boolean, Double, Long)
- HTTP 服务器模式下仅前台运行 (App 进入后台服务器会停止)
- 无持久化配置 (每次启动生成新 Token)
- 仅支持 HTTP 协议 (无 WebSocket/SSE 支持)

---

## 🗺️ 后续计划

**Phase 2** (Android 增强):
- 支持复杂类型 (List, Map, 自定义类)
- Foreground Service 保活
- Token 持久化

**Phase 3** (跨平台扩展):
- iOS Swift Package 版本
- Flutter Plugin 版本
- React Native Module 版本
- Web JavaScript SDK

**Phase 4** (企业功能):
- 请求日志和监控面板
- 权限细粒度控制
- 云端 MCP Hub (可选)
- 多应用进程间通信 (IPC) 桥接

---

## 💬 技术支持

如有问题或建议，请通过 [GitHub Issues](https://github.com/pandawengogo/Mobile-MCP-SDK/issues) 联系我们。

---

**让移动端 App 拥抱 AI 时代！**

[English](README.md) | [中文文档](README_CN.md)
