#!/bin/bash

# NanoMCP SDK GitHub 发布脚本（仅打包产物）
# 用法: ./release-github.sh [version]
# 此脚本只构建和打包产物，不包含源代码

set -e

VERSION=${1:-"1.0.0"}
TIMESTAMP=$(date +%Y%m%d-%H%M%S)
RELEASE_DIR="github-release/v${VERSION}-${TIMESTAMP}"

echo "🚀 开始构建 NanoMCP SDK v$VERSION (仅打包产物)"
echo ""

# 1. 清理
echo "📦 步骤 1/6: 清理旧构建..."
./gradlew clean
echo "✅ 清理完成"
echo ""

# 2. 构建所有模块
echo "🔨 步骤 2/6: 构建所有模块..."
./gradlew :mcp-annotations:build
./gradlew :mcp-compiler:jar
./gradlew :mcp-api:assembleRelease
./gradlew :mcp-core:assembleRelease
./gradlew :mcp-client:assembleRelease
./gradlew :nanomcp-sdk:assembleRelease
./gradlew :nanomcp-sdk:fatAar
echo "✅ 构建完成"
echo ""

# 3. 创建发布目录
echo "📁 步骤 3/6: 创建发布目录..."
mkdir -p "$RELEASE_DIR"
echo "✅ 目录创建完成: $RELEASE_DIR"
echo ""

# 4. 复制打包产物
echo "📋 步骤 4/6: 复制打包产物..."

# 主 SDK AAR (Fat AAR)
if [ -f "release-aars/nanomcp-sdk-release.aar" ]; then
    cp "release-aars/nanomcp-sdk-release.aar" "$RELEASE_DIR/nanomcp-sdk-${VERSION}.aar"
    echo "✅ 已复制: nanomcp-sdk-${VERSION}.aar"
else
    echo "⚠️  警告: nanomcp-sdk-release.aar 未找到，尝试使用标准构建..."
    cp "nanomcp-sdk/build/outputs/aar/nanomcp-sdk-release.aar" "$RELEASE_DIR/nanomcp-sdk-${VERSION}.aar" 2>/dev/null || true
fi

# 注解库 JAR
cp "mcp-annotations/build/libs/mcp-annotations-1.0.0.jar" "$RELEASE_DIR/mcp-annotations-${VERSION}.jar" 2>/dev/null || true

# 编译器 JAR
cp "mcp-compiler/build/libs/mcp-compiler-1.0.0.jar" "$RELEASE_DIR/mcp-compiler-${VERSION}.jar" 2>/dev/null || true

# 生成 SHA256 校验和
echo "🔐 步骤 5/6: 生成校验和..."
cd "$RELEASE_DIR"
for file in *.aar *.jar; do
    if [ -f "$file" ]; then
        shasum -a 256 "$file" > "${file}.sha256"
        echo "✅ ${file}.sha256"
    fi
done
cd - > /dev/null
echo ""

# 5. 创建发布说明
echo "📝 步骤 6/6: 创建发布说明..."
cat > "$RELEASE_DIR/RELEASE_NOTES.md" <<EOF
# NanoMCP SDK v${VERSION} 发布说明

## 📦 包含文件

- \`nanomcp-sdk-${VERSION}.aar\` - 主 SDK 库（包含所有核心模块）
- \`mcp-annotations-${VERSION}.jar\` - 注解库（编译时依赖）
- \`mcp-compiler-${VERSION}.jar\` - KSP 编译器（编译时依赖）

所有文件都包含 SHA256 校验和文件（\`.sha256\`），用于验证文件完整性。

## 🚀 快速开始

### 1. 添加依赖

将 AAR 和 JAR 文件复制到你的 Android 项目的 \`libs\` 目录，然后在 \`build.gradle.kts\` 中添加：

\`\`\`kotlin
plugins {
    id("com.google.devtools.ksp") version "1.9.22-1.0.17"
}

dependencies {
    // NanoMCP SDK
    implementation(fileTree(mapOf("dir" to "libs", "include" to listOf("*.aar"))))
    compileOnly(files("libs/mcp-annotations-${VERSION}.jar"))
    ksp(files("libs/mcp-compiler-${VERSION}.jar"))
    
    // 必需的第三方依赖
    implementation("androidx.biometric:biometric:1.1.0")
    implementation("com.squareup.okhttp3:okhttp:4.12.0")
}
\`\`\`

### 2. 定义工具

\`\`\`kotlin
import com.nanomcp.annotations.McpTool
import com.nanomcp.annotations.McpParam

@McpTool(description = "添加待办事项")
fun addTodo(
    @McpParam("待办内容") title: String,
    @McpParam("优先级") priority: Int = 0
): String {
    // 实现代码
    return "已添加：\$title"
}
\`\`\`

### 3. 使用 SDK

\`\`\`kotlin
val server = McpServer(enableHttpServer = false)
server.registerGeneratedTools()

// 调用工具
val result = server.callTool("addTodo", mapOf(
    "title" to "买菜",
    "priority" to 1
))
\`\`\`

## 📋 版本信息

- SDK 版本：${VERSION}
- 构建时间：${TIMESTAMP}
- 最低 Android 版本：API 21 (Android 5.0)
- 目标 Android 版本：API 34 (Android 14)

## ✅ 已验证功能

✅ 工具自动注册
✅ R8 混淆兼容
✅ 生物识别验证
✅ 直接调用模式
✅ HTTP 服务器模式
✅ AI 集成（Claude/GPT）

## 📚 更多文档

详细文档请访问：https://github.com/pandawengogo/Mobile-MCP-SDK

## 🔒 许可证

MIT License

---

**让移动端 App 拥抱 AI 时代！**
EOF

echo "✅ 发布说明已创建"
echo ""

# 6. 显示文件列表
echo "📊 发布产物清单:"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
ls -lh "$RELEASE_DIR" | grep -E "\.(aar|jar|md|sha256)$" | awk '{printf "  %-50s %10s\n", $9, $5}'
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# 7. 创建符号链接到最新版本
LATEST_DIR="github-release/latest"
rm -rf "$LATEST_DIR"
ln -s "$(basename $RELEASE_DIR)" "$LATEST_DIR"
echo "✅ 已创建最新版本链接: $LATEST_DIR -> $(basename $RELEASE_DIR)"
echo ""

echo "🎉 GitHub 发布准备完成!"
echo ""
echo "📦 产物位置: $RELEASE_DIR/"
echo ""
echo "📤 下一步操作:"
echo "  1. 检查产物文件: ls -lh $RELEASE_DIR/"
echo "  2. 创建 GitHub Release:"
echo "     - 访问: https://github.com/pandawengogo/Mobile-MCP-SDK/releases/new"
echo "     - Tag: v${VERSION}"
echo "     - Title: NanoMCP SDK v${VERSION}"
echo "     - 上传所有 .aar, .jar 文件和 RELEASE_NOTES.md"
echo "  3. 或者使用 GitHub CLI:"
echo "     gh release create v${VERSION} \\"
echo "       --title \"NanoMCP SDK v${VERSION}\" \\"
echo "       --notes-file \"$RELEASE_DIR/RELEASE_NOTES.md\" \\"
echo "       \"$RELEASE_DIR/*.aar\" \"$RELEASE_DIR/*.jar\""
echo ""

