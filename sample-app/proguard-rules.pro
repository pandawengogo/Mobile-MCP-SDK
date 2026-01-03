# Sample App - ProGuard 混淆规则

# ==================== NanoMCP SDK 规则 ====================

# 【关键】保留所有 KSP 生成的工具注册代码
-keep class com.nanomcp.generated.** { *; }

# 【关键】保留所有带 @McpTool 注解的函数
-keepclassmembers class * {
    @com.nanomcp.annotations.McpTool public *;
}

# 【关键】保留所有带 @McpParam 注解的参数
-keepclassmembers class * {
    @com.nanomcp.annotations.McpParam *;
}

# 保留 sample-app 中的所有工具类（AccountingTools, Tools）
-keep class com.nanomcp.sample.AccountingTools { *; }
-keep class com.nanomcp.sample.** {
    @com.nanomcp.annotations.McpTool *;
}

# ==================== 保留日志（开发阶段）====================

# 保留所有级别的日志（方便调试）
# 生产环境可以注释掉 Debug 和 Verbose 级别
-assumenosideeffects class android.util.Log {
    # public static *** d(...);
    # public static *** v(...);
}


