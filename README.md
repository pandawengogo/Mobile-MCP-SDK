
# 🚀 NanoMCP: The Universal Bridge for Mobile AI Agents

**Transform any iOS/Android App into a Super AI Agent in 3 minutes.**

### Stop building Chatbots. Start building Agents.

**NanoMCP** is the first industrial-grade implementation of the **Model Context Protocol (MCP)** specifically optimized for mobile ecosystems. It allows LLMs (Claude, GPT, Gemini) to securely read, write, and execute functions directly within your native mobile apps—**without sacrificing user privacy or data security.**

---

## 🌟 Why NanoMCP?

The era of "Copy-Paste AI" is over. Users want AI that *acts* on their behalf.

* **⚡️ 3-Minute Integration:** Decorate your existing functions; NanoMCP handles the JSON-RPC, Schema generation, and protocol handshakes.
* **🔐 Local-First Security:** Your data never leaves the device. NanoMCP acts as a local gateway, only sending task-specific metadata to the LLM.
* **🛡️ Biometric Interceptors:** Built-in "Human-in-the-loop" UI. AI cannot trigger sensitive tools (like payments or deletions) without a FaceID/Fingerprint check.
* **📱 Cross-Platform:** Write your logic in Kotlin Multiplatform (KMP) or Swift, and let NanoMCP bridge it to any LLM Host.

---

## 🛠 Quick Start (The "3-Minute" Challenge)

### 1. Define your Tools

Just annotate your existing business logic. NanoMCP's KSP/Swift Macros will generate the MCP Schema automatically.

```kotlin
// Android/KMP Example
class FinanceService : McpServer {
    
    @McpTool(description = "Add a new expense record to the local ledger")
    fun addExpense(amount: Double, category: String, note: String): String {
        db.save(amount, category, note)
        return "Successfully recorded $amount for $category"
    }

    @McpResource(uri = "mcp://finance/summary")
    fun getSummary(): String = db.getMonthlyReport()
}

```

### 2. Initialize the Bridge

Start the local MCP server with a single line.

```kotlin
val mcpBridge = NanoMCP.create(context)
mcpBridge.register(FinanceService())
mcpBridge.start() // Now listening for AI Host connections via Local HTTP/SSE

```

### 3. Connect to any AI Host

Works out-of-the-box with **Claude Desktop**, **Cursor**, or your custom in-app LLM (Gemini Nano/Llama.cpp).

---

## 🏗 Architecture: How it works

NanoMCP creates a **Standardized Interface Layer** between your app's sandboxed environment and the AI model.

1. **Discovery:** The AI Host asks NanoMCP for available capabilities.
2. **Mapping:** NanoMCP returns a JSON-RPC manifest of your `@McpTool` methods.
3. **Execution:** The AI sends a command -> **NanoMCP Interceptor** asks for user permission -> Function is executed locally -> Result is sent back.

---

## 📈 Use Cases

| Industry | The "Super AI" Experience |
| --- | --- |
| **FinTech** | "Analyze my spending on coffee last month and set a budget." |
| **E-Commerce** | "Find the best-selling running shoes in my size and add to cart." |
| **SaaS/OA** | "Summarize the unread approvals and approve those under $500." |
| **Healthcare** | "Check my heart rate trends and alert my doctor if it's abnormal." |

---

## 💰 Pro Version (For Enterprises)

While the core is open-source, we offer **NanoMCP Pro** for high-stakes environments:

* **SQL-Auto-Mapper:** Turn your entire SQLite/Realm DB into an AI-queryable resource instantly.
* **Remote Proxy:** Securely bridge local MCP tools to cloud-based LLMs without exposing public IPs.
* **Audit Logs:** Full traceability for every AI-triggered action.

---

## 🤝 Contributing & Roadmap

We are on a mission to make every app agentic.

* [ ] iOS Swift Macros Support
* [ ] Local LLM (Gemini Nano) Direct Binding
* [ ] Multi-App Inter-process Communication (IPC) Bridge

**Star this repo to join the Mobile AI revolution!** ⭐

---
