# 🚀 NanoMCP SDK: Mobile AI Adapter

**Enable mobile apps to be recognized and invoked by AI, becoming the "hands" and "eyes" of AI.**

## 📖 Product Overview

**One-sentence definition**: AI Adapter SDK for Mobile Apps

**Supported Platforms**:
- ✅ **Android** - Implemented, production-ready
- 🚧 **iOS** - Planned
- 🚧 **Flutter** - Planned
- 🚧 **React Native** - Planned
- 🚧 **Web** - Planned

**Analogy**:
- Like USB drivers that enable hardware to be recognized by computers
- Like Alipay SDK that enables apps to integrate payment capabilities
- We enable apps to be recognized and invoked by AI

---

## 🌟 Why NanoMCP?

* **⚡️ Zero-Intrusion Integration:** Just add annotations to existing functions; NanoMCP handles JSON-RPC, Schema generation, and protocol handshakes automatically
* **🔐 Local-First Security:** Data never leaves the device; NanoMCP runs as a local gateway
* **🛡️ Optional Security Verification:** Built-in biometric verification mechanism; sensitive operations can require fingerprint/face recognition
* **📦 Ultra-Lightweight:** Android version < 200KB total size
* **🌐 Cross-Platform Vision:** Unified API design with multi-platform implementation (Android implemented)

---

## 🛠 Quick Start (Android)

> ⚠️ **Note**: Current version only supports Android platform. iOS, Flutter, React Native, and Web versions are under development.

### 1. Add Dependencies

Copy the downloaded AAR and JAR files to your Android project's `libs` directory, then add to `build.gradle.kts`:

```kotlin
plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android")
    id("com.google.devtools.ksp") version "1.9.22-1.0.17"
}

dependencies {
    // NanoMCP SDK
    // nanomcp-sdk-release.aar is a Fat AAR containing all core modules
    implementation(files("libs/nanomcp-sdk-release.aar"))
    ksp(files("libs/mcp-compiler-1.0.0.jar"))
    
    // Required AndroidX dependencies (needed by SDK)
    implementation("androidx.fragment:fragment-ktx:1.6.2")
    implementation("androidx.biometric:biometric:1.1.0")
    
    // Other Android libraries (as needed by your project)
    implementation("androidx.core:core-ktx:1.12.0")
    implementation("androidx.appcompat:appcompat:1.6.1")
}
```

> 💡 **Tip**: `nanomcp-sdk-release.aar` is a Fat AAR that includes all necessary modules.

### 2. Define Tool Functions

Simply add `@McpTool` annotation to your existing business logic functions. NanoMCP's KSP compiler will automatically generate MCP Schema and registration code.

```kotlin
import com.nanomcp.annotations.McpTool
import com.nanomcp.annotations.McpParam

/**
 * Basic tool examples
 */
@McpTool(description = "Calculate the sum of two integers")
fun add(
    @McpParam("First number") a: Int,
    @McpParam("Second number") b: Int
): Int {
    return a + b
}

@McpTool(description = "Reverse a string")
fun reverseString(
    @McpParam("String to reverse") text: String
): String {
    return text.reversed()
}
```

### 3. Start MCP Server

NanoMCP provides two usage modes:

#### Mode 1: Direct In-App Invocation (Recommended)

Suitable for direct tool invocation within the app, without starting an HTTP server.

```kotlin
import com.nanomcp.core.McpServer

class MainActivity : AppCompatActivity() {
    private lateinit var mcpServer: McpServer
    
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)
        
        // Create MCP server (without HTTP server)
        mcpServer = McpServer(enableHttpServer = false)
        mcpServer.registerGeneratedTools()  // Auto-register all @McpTool functions
        
        // Direct tool invocation
        val result = mcpServer.callTool("add", mapOf("a" to 10, "b" to 20))
        Log.i("MCP", "Result: $result")  // Output: 30
    }
}
```

#### Mode 2: Enable HTTP Server (For External AI Client Connections)

Suitable for external AI clients (like Claude Desktop, Cursor) to invoke tools via HTTP.

```kotlin
import com.nanomcp.core.McpServer

class MainActivity : AppCompatActivity() {
    private lateinit var mcpServer: McpServer
    
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)
        
        // Create and start MCP server (with HTTP server enabled)
        mcpServer = McpServer(enableHttpServer = true, port = 8080)
        mcpServer.registerGeneratedTools()  // Auto-register all @McpTool functions
        mcpServer.start()  // Start HTTP server
        
        // Display Token (for AI connection authentication)
        val token = mcpServer.authToken
        Log.i("MCP", "Auth Token: $token")
        // You can display the Token in UI for users to copy
    }
    
    override fun onDestroy() {
        super.onDestroy()
        mcpServer.stop()  // Stop server
    }
}
```

### 4. (Optional) Add Security Verification

For sensitive operations (like payments, data deletion), you can require security verification. NanoMCP provides a flexible verification mechanism.

#### 4.1 Mark Tools Requiring Verification

Use `@McpSecure` annotation to mark tools that require verification:

```kotlin
import com.nanomcp.annotations.McpTool
import com.nanomcp.annotations.McpParam
import com.nanomcp.api.McpSecure

@McpTool(description = "Add an expense record")
@McpSecure(reason = "This operation will modify your financial records")  // Mark as requiring verification
fun addExpense(
    @McpParam("Amount") amount: Double,
    @McpParam("Category") category: String,
    @McpParam("Note") note: String = ""
): String {
    // Save expense record
    return "Expense added: ¥$amount"
}
```

#### 4.2 Verification Method 1: Use Built-in Biometric Verification

SDK provides `BiometricAuthenticationHandler` with fingerprint/face recognition support:

```kotlin
import com.nanomcp.core.McpServer
import com.nanomcp.core.BiometricAuthenticationHandler

class MainActivity : AppCompatActivity() {
    private lateinit var mcpServer: McpServer
    
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)
        
        // Use built-in biometric verification
        val authHandler = BiometricAuthenticationHandler(this)
        
        mcpServer = McpServer(
            enableHttpServer = false,
            authenticationHandler = authHandler
        )
        mcpServer.registerGeneratedTools()
        
        // Tools with @McpSecure annotation will automatically trigger biometric verification
        val result = mcpServer.callTool("addExpense", mapOf(
            "amount" to 500.0,
            "category" to "Food",
            "note" to "Lunch"
        ))
    }
}
```

**How it works**:
- If device supports biometrics, shows fingerprint/face recognition dialog
- If device doesn't support, falls back to confirmation dialog
- Dialog displays tool name, verification reason, and parameter info

#### 4.3 Verification Method 2: Inherit and Customize Biometric Behavior

Inherit `BiometricAuthenticationHandler` and override methods to customize verification logic:

```kotlin
import com.nanomcp.core.BiometricAuthenticationHandler

/**
 * Custom verification: small amounts skip verification, large amounts require biometrics
 */
class SmartAuthHandler(activity: FragmentActivity) : BiometricAuthenticationHandler(activity) {
    override fun authenticate(
        toolName: String, 
        reason: String, 
        arguments: Map<String, Any>
    ): Boolean {
        // Decide verification based on amount
        val amount = arguments["amount"] as? Double ?: 0.0
        
        if (amount < 100.0) {
            // Skip verification for small amounts
            Log.i("Auth", "Small amount, skip verification: ¥$amount")
            return true
        }
        
        // Large amounts require parent class biometric verification
        Log.i("Auth", "Large amount, verification required: ¥$amount")
        return super.authenticate(toolName, reason, arguments)
    }
}

// Use custom verification
val authHandler = SmartAuthHandler(this)
mcpServer = McpServer(
    enableHttpServer = false,
    authenticationHandler = authHandler
)
```

#### 4.4 Verification Method 3: Customize Confirmation Dialog Content

Override `showConfirmationDialog` method to customize dialog content:

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
            // Customize dialog content
            val amount = arguments["amount"] as? Double ?: 0.0
            val category = arguments["category"] as? String ?: "Unknown"
            
            AlertDialog.Builder(activity)
                .setTitle("⚠️ Confirm Expense")
                .setMessage(
                    "You are about to add an expense record:\n\n" +
                    "💰 Amount: ¥${String.format("%.2f", amount)}\n" +
                    "📂 Category: $category\n\n" +
                    "Confirm?"
                )
                .setPositiveButton("Confirm") { _, _ ->
                    result = true
                    latch.countDown()
                }
                .setNegativeButton("Cancel") { _, _ ->
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

#### 4.5 Verification Method 4: Fully Custom Verification Logic

Implement `AuthenticationHandler` interface for fully custom verification logic:

```kotlin
import com.nanomcp.core.AuthenticationHandler

/**
 * Fully custom verification: implement any verification method
 */
class CustomAuthHandler(private val activity: FragmentActivity) : AuthenticationHandler {
    override fun authenticate(
        toolName: String, 
        reason: String,
        arguments: Map<String, Any>
    ): Boolean {
        // Option 1: Decide verification method based on tool name
        return when (toolName) {
            "addExpense" -> {
                val amount = arguments["amount"] as? Double ?: 0.0
                if (amount < 100.0) true else showPinDialog()
            }
            "clearAllTransactions" -> {
                // Delete operations must verify
                showBiometricOrPin()
            }
            else -> {
                // Other operations don't need verification
                true
            }
        }
        
        // Option 2: Call remote authorization service
        // return callRemoteAuthService(toolName, arguments)
        
        // Option 3: Use risk scoring system
        // val riskScore = calculateRiskScore(toolName, arguments)
        // return if (riskScore > 0.7) showBiometric() else true
        
        // Option 4: No verification at all
        // return true
    }
    
    private fun showPinDialog(): Boolean {
        // Implement PIN verification
        // ...
        return true
    }
    
    private fun showBiometricOrPin(): Boolean {
        // Implement biometric or PIN verification
        // ...
        return true
    }
}

// Use fully custom verification
val authHandler = CustomAuthHandler(this)
mcpServer = McpServer(
    enableHttpServer = false,
    authenticationHandler = authHandler
)
```

#### 4.6 Verification Method 5: No Verification

If verification is not needed, simply don't pass the `authenticationHandler` parameter:

```kotlin
// Don't pass authenticationHandler, no tools will be verified
mcpServer = McpServer(enableHttpServer = false)
mcpServer.registerGeneratedTools()

// Even if tool has @McpSecure annotation, no verification will be triggered
val result = mcpServer.callTool("addExpense", mapOf(
    "amount" to 500.0,
    "category" to "Food"
))
```

---

## 📦 Download (Android)

Visit [Releases](https://github.com/pandawengogo/Mobile-MCP-SDK/releases) page to download the latest version:

- `nanomcp-sdk-{version}.aar` - Main SDK library (Fat AAR containing all core modules)
- `mcp-compiler-{version}.jar` - KSP compiler (compile-time dependency for code generation)

All files include SHA256 checksum files (`.sha256`) for integrity verification.

> 💡 **Note**: `nanomcp-sdk-release.aar` is a Fat AAR that merges all modules; you only need this one AAR file.

---

## 🏗 How It Works

NanoMCP creates a **standardized interface layer** between your app and AI models.

### Compile-Time Flow

1. **Annotation Scanning**: KSP compiler scans all functions with `@McpTool` annotation
2. **Code Generation**: Automatically generates tool registration code (`McpToolRegistry.kt`)
3. **Schema Generation**: Generates JSON Schema description for each tool

### Runtime Flow

**Mode 1: Direct In-App Invocation**
1. Call `mcpServer.callTool(name, args)`
2. NanoMCP parses parameters and invokes corresponding function
3. Returns execution result

**Mode 2: HTTP Server Mode**
1. **Discovery**: AI host requests available tools list via HTTP
2. **Invocation**: AI sends JSON-RPC request to invoke tool
3. **Execution**: NanoMCP parses parameters and invokes corresponding function
4. **Response**: Converts function return value to JSON-RPC response

---

## ✨ Core Features

### Implemented Features (Android)

- ✅ **Annotation-Driven Development** - Define tools using `@McpTool` and `@McpParam`
- ✅ **KSP Code Generation** - Automatically generates registration code and Schema at compile time
- ✅ **Two Invocation Modes** - Direct in-app invocation or HTTP server mode
- ✅ **Token Authentication** - Bearer Token authentication in HTTP mode
- ✅ **Biometric Verification** - Optional fingerprint/face recognition verification (`@McpSecure`)
- ✅ **Custom Verification** - Support custom `AuthenticationHandler`
- ✅ **Type Safety** - Compile-time parameter type validation
- ✅ **Timeout Control** - Configurable tool execution timeout
- ✅ **Ultra-Lightweight** - Total size < 200KB

### Supported Data Types

- `Int`, `Long`, `Double`, `Boolean`, `String`
- Optional parameters (with default values)
- Return values: basic types or `String`

---

## 📋 System Requirements (Android)

- **Minimum Android Version**: API 21 (Android 5.0)
- **Target Android Version**: API 34 (Android 14)
- **Kotlin Version**: 1.9.22+
- **Gradle Version**: 8.3.0+
- **KSP Version**: 1.9.22-1.0.17+

---

## 🔧 ProGuard Configuration (Android)

If your project has obfuscation enabled, add to `proguard-rules.pro`:

```proguard
# NanoMCP SDK
# Keep all KSP-generated tool registration code
-keep class com.nanomcp.generated.** { *; }

# Keep all functions with @McpTool annotation
-keepclassmembers class * {
    @com.nanomcp.annotations.McpTool *;
}

# Keep all parameters with @McpParam annotation
-keepclassmembers class * {
    @com.nanomcp.annotations.McpParam *;
}
```

---

## 📚 Sample Application (Android)

Check the `sample-app/` directory for complete usage examples, including:

- **Basic Tools**: Simple tools like calculations and string processing
- **Accounting Tools**: Financial record management with biometric verification
- **HTTP Server**: Start server and test with curl
- **AI Chat**: Conversation example integrated with Claude API

---

## 📈 Use Cases

| Industry       | AI Capability Examples                                          |
| -------------- | --------------------------------------------------------------- |
| **FinTech**    | "Analyze my coffee spending last month and set a budget"        |
| **E-commerce** | "Find best-selling running shoes in my size and add to cart"    |
| **SaaS/OA**    | "Summarize unread approvals and approve those under $500"       |
| **Healthcare** | "Check my heart rate trends and alert my doctor if abnormal"    |
| **Assistant**  | "Record today's workout data and sync to health app"            |

---

## 🔍 Testing & Verification (Android)

### Test HTTP Server with curl

After starting the app, test with curl:

```bash
# Get tools list
curl -X POST http://localhost:8080 \
  -H "Authorization: Bearer <token>" \
  -H "Content-Type: application/json" \
  -d '{"method":"tools/list","params":{}}'

# Invoke tool
curl -X POST http://localhost:8080 \
  -H "Authorization: Bearer <token>" \
  -H "Content-Type: application/json" \
  -d '{"method":"tools/call","params":{"name":"add","arguments":{"a":10,"b":20}}}'
```

---

## 🗺️ Platform Support Roadmap

### ✅ Android (Implemented)

- [x] Kotlin annotation support
- [x] KSP code generation
- [x] HTTP JSON-RPC server
- [x] Direct in-app invocation
- [x] Biometric protection
- [x] Token authentication
- [x] Automatic tool registration

### 🚧 iOS (Planned)

- [ ] Swift Macros support
- [ ] Swift Package Manager integration
- [ ] HTTP JSON-RPC server
- [ ] FaceID/TouchID protection
- [ ] Token authentication
- [ ] Automatic tool registration

### 📋 Flutter (Planned)

- [ ] Dart annotation support
- [ ] Code generation plugin
- [ ] Cross-platform HTTP server
- [ ] Biometric plugin integration
- [ ] Token authentication
- [ ] Automatic tool registration

### 📋 React Native (Planned)

- [ ] TypeScript type definitions
- [ ] Native module bridging
- [ ] HTTP JSON-RPC server
- [ ] Biometric module integration
- [ ] Token authentication
- [ ] Automatic tool registration

### 📋 Web (Planned)

- [ ] TypeScript/JavaScript SDK
- [ ] WebSocket support
- [ ] Browser security mechanisms
- [ ] Token authentication
- [ ] Automatic tool registration

---

## ⚠️ Current Limitations (Android)

- Only supports basic type parameters (Int, String, Boolean, Double, Long)
- HTTP server mode only runs in foreground (server stops when app goes to background)
- No persistent configuration (generates new Token on each start)
- Only supports HTTP protocol (no WebSocket/SSE support)

---

## 🗺️ Future Plans

**Phase 2** (Android Enhancement):
- Support complex types (List, Map, custom classes)
- Foreground Service keep-alive
- Token persistence

**Phase 3** (Cross-Platform Expansion):
- iOS Swift Package version
- Flutter Plugin version
- React Native Module version
- Web JavaScript SDK

**Phase 4** (Enterprise Features):
- Request logging and monitoring dashboard
- Fine-grained permission control
- Cloud MCP Hub (optional)
- Multi-app inter-process communication (IPC) bridging

---

## 💬 Technical Support

For questions or suggestions, please contact us via [GitHub Issues](https://github.com/pandawengogo/Mobile-MCP-SDK/issues).

---

**Embrace the AI Era for Mobile Apps!**

[English](README.md) | [中文文档](README_CN.md)
