# NanoMCP SDK - Android 移动端 AI 适配器

让任何 Android App 能零门槛接入 MCP (Model Context Protocol) 生态，成为 AI 的"手"和"眼"。

## 产品定位

**一句话定义**: 移动端 App 的 AI 适配器

**类比理解**:
- 就像 USB 驱动程序让硬件能被电脑识别
- 就像支付宝 SDK 让 App 能接入支付能力
- 我们让 App 能被 AI 识别和调用

## ⚠️ 重要提示

**首次使用请先在 Android Studio 中打开项目!**

Android Studio 会自动:
- 下载 Gradle Wrapper
- 同步依赖
- 配置 JDK

详见 [TROUBLESHOOTING.md](TROUBLESHOOTING.md)

## 快速开始

### 1. 添加依赖 (30秒)

在你的 `app/build.gradle.kts` 中添加:

```kotlin
plugins {
    id("com.google.devtools.ksp") version "1.9.22-1.0.17"
}

dependencies {
    implementation(project(":mcp-api"))
    implementation(project(":mcp-core"))
    ksp(project(":mcp-compiler"))
}
```

### 2. 定义工具函数 (5分钟)

```kotlin
import com.nanomcp.api.McpTool
import com.nanomcp.api.McpParam

@McpTool(description = "调节屏幕亮度")
fun setBrightness(@McpParam("亮度 0-100") level: Int) {
    // 你的实现代码
}

@McpTool(description = "发送通知")
fun sendNotification(
    @McpParam("标题") title: String,
    @McpParam("内容") body: String
) {
    // 你的实现代码
}
```

### 3. 启动 SDK (2分钟)

```kotlin
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

## 项目结构

```
NanoMCP/
├── mcp-api/           # 注解定义层 (< 10KB)
├── mcp-core/          # 运行时引擎 (< 150KB)
├── mcp-compiler/      # KSP 编译插件 (不打包进 APK)
└── sample-app/        # 演示应用
```

## 核心特性

### 1. 零侵入
- 只需加注解，不改原有代码
- 无需继承基类或实现接口

### 2. 类型安全
- 编译时验证参数类型
- 运行时无反射，性能卓越

### 3. 极致轻量
- mcp-api: < 10KB
- mcp-core: < 150KB (含 NanoHTTPD)
- 总体积 < 200KB (一张图片的大小)

### 4. 开箱即用
- 3 步接入，10 分钟上手
- 自动生成注册代码

### 5. 安全可控
- Token 认证机制
- 局域网隔离

## 工作原理

```
编译时:
  开发者写 @McpTool 注解
    ↓
  KSP 扫描并生成注册代码
    ↓
  编译进 APK

运行时:
  App 启动 McpServer
    ↓
  监听 8080 端口
    ↓
  AI 发送 JSON-RPC 请求
    ↓
  SDK 解析并调用对应函数
    ↓
  返回结果给 AI
```

## 测试验证

### 编译项目

```bash
./gradlew build
```

### 运行示例 App

```bash
./gradlew :sample-app:installDebug
```

### 测试 API

启动 App 后，使用 curl 测试:

```bash
# 获取工具列表
curl -H "Authorization: Bearer <token>" \
     http://localhost:8080 \
     -d '{"method":"tools/list","params":{}}'

# 调用工具
curl -H "Authorization: Bearer <token>" \
     -H "Content-Type: application/json" \
     http://localhost:8080 \
     -d '{"method":"tools/call","params":{"name":"add","arguments":{"a":10,"b":20}}}'
```

## MVP 限制

- 仅支持基础类型参数 (Int, String, Boolean, Double, Long)
- 仅前台运行 (App 进入后台服务器会停止)
- 无持久化配置 (每次启动生成新 Token)
- 无 WebSocket/SSE 支持 (仅 HTTP)

## 后续扩展

**Phase 2** (1个月后):
- 支持复杂类型 (List, Map, 自定义类)
- Foreground Service 保活
- Token 持久化

**Phase 3** (3个月后):
- WebSocket 双向通信
- 请求日志和监控面板
- 权限细粒度控制

**Phase 4** (6个月后):
- iOS Swift Package 版本
- Flutter/React Native 桥接
- 云端 MCP Hub (可选)

## 技术架构

### 三大核心模块

1. **mcp-api** - "傻瓜开关"
   - 定义注解和接口
   - 零依赖，极轻量

2. **mcp-core** - "嵌入式服务器"
   - NanoHTTPD HTTP Server
   - JSON-RPC 路由
   - Token 认证
   - 工具注册表

3. **mcp-compiler** - "隐形魔法师"
   - KSP 处理器
   - 编译时代码生成
   - JSON Schema 生成

## 许可证

MIT License

## 联系方式

- GitHub: https://github.com/yourusername/nanomcp
- Email: your@email.com

---

**让移动端 App 拥抱 AI 时代！**


