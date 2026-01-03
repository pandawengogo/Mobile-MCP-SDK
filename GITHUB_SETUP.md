# GitHub 仓库设置指南（仅发布打包产物）

本指南说明如何设置 GitHub 仓库，使其只包含打包产物，不包含源代码。

## 🎯 目标

- ✅ 只发布打包后的 `.aar` 和 `.jar` 文件
- ✅ 不包含任何源代码（`.kt` 文件）
- ✅ 包含必要的文档（README、使用说明）
- ✅ 自动构建和发布流程

## 📋 设置步骤

### 1. 创建新的 GitHub 仓库

```bash
# 在 GitHub 上创建新仓库
# 仓库名: Mobile-MCP-SDK
# 描述: 移动端 AI 适配器 SDK - 仅发布打包产物
# 设置为 Public 或 Private（根据你的需求）
```

### 2. 初始化本地仓库（仅包含必要文件）

```bash
# 创建新的分支用于 GitHub
git checkout -b github-release-only

# 只添加必要的文件
git add .github/workflows/release.yml
git add GITHUB_README.md
git add GITHUB_SETUP.md
git add gradle/
git add gradlew
git add gradlew.bat
git add settings.gradle.kts
git add build.gradle.kts
git add gradle.properties

# 提交
git commit -m "Initial commit: GitHub release setup"
```

### 3. 构建并准备发布产物

```bash
# 运行 GitHub 发布脚本
chmod +x release-github.sh
./release-github.sh 1.0.0

# 检查产物
ls -lh github-release/latest/
```

### 4. 添加发布产物到仓库

```bash
# 将发布产物添加到仓库（但不提交源代码）
git add github-release/
git commit -m "Add release artifacts v1.0.0"
```

### 5. 推送到 GitHub

```bash
# 添加远程仓库
git remote add origin https://github.com/pandawengogo/Mobile-MCP-SDK.git

# 推送
git push -u origin github-release-only

# 或者推送到 main 分支
git checkout -b main
git push -u origin main
```

## 🔄 发布新版本流程

### 方法 1: 使用 GitHub Actions（推荐）

1. **推送标签触发自动构建**：
```bash
# 在本地构建并测试
./release-github.sh 1.0.1

# 创建并推送标签
git tag v1.0.1
git push origin v1.0.1
```

GitHub Actions 会自动：
- 构建所有模块
- 生成打包产物
- 创建 GitHub Release
- 上传所有文件

### 方法 2: 手动发布

1. **本地构建**：
```bash
./release-github.sh 1.0.1
```

2. **创建 GitHub Release**：
   - 访问：https://github.com/pandawengogo/Mobile-MCP-SDK/releases/new
   - Tag: `v1.0.1`
   - Title: `NanoMCP SDK v1.0.1`
   - 上传文件：
     - `nanomcp-sdk-1.0.1.aar`
     - `mcp-annotations-1.0.1.jar`
     - `mcp-compiler-1.0.1.jar`
     - 所有 `.sha256` 文件
     - `RELEASE_NOTES.md`

3. **或使用 GitHub CLI**：
```bash
gh release create v1.0.1 \
  --title "NanoMCP SDK v1.0.1" \
  --notes-file "github-release/latest/RELEASE_NOTES.md" \
  "github-release/latest/*.aar" \
  "github-release/latest/*.jar" \
  "github-release/latest/*.sha256"
```

## 📁 仓库文件结构

GitHub 仓库应该只包含：

```
Mobile-MCP-SDK/
├── .github/
│   └── workflows/
│       └── release.yml          # GitHub Actions 工作流
├── github-release/              # 发布产物目录
│   ├── latest/                  # 最新版本符号链接
│   └── v1.0.0-20240103-120000/  # 版本目录
│       ├── nanomcp-sdk-1.0.0.aar
│       ├── nanomcp-sdk-1.0.0.aar.sha256
│       ├── mcp-annotations-1.0.0.jar
│       ├── mcp-annotations-1.0.0.jar.sha256
│       ├── mcp-compiler-1.0.0.jar
│       ├── mcp-compiler-1.0.0.jar.sha256
│       └── RELEASE_NOTES.md
├── gradle/                      # Gradle Wrapper（必需）
├── GITHUB_README.md            # GitHub 仓库 README
├── GITHUB_SETUP.md             # 本文件
├── gradlew                      # Gradle Wrapper 脚本
├── gradlew.bat
├── settings.gradle.kts          # 项目设置
├── build.gradle.kts            # 根构建文件
└── gradle.properties           # Gradle 配置
```

**不包含**：
- ❌ `mcp-api/`, `mcp-core/`, `mcp-compiler/` 等源代码目录
- ❌ `sample-app/` 示例应用
- ❌ 任何 `.kt` 源代码文件

## 🔒 保护源代码

### 选项 1: 使用 .gitattributes（推荐）

创建 `.gitattributes` 文件：

```gitattributes
# 排除所有源代码目录
mcp-api/ export-ignore
mcp-core/ export-ignore
mcp-client/ export-ignore
mcp-compiler/ export-ignore
mcp-annotations/ export-ignore
nanomcp-sdk/src/ export-ignore
sample-app/ export-ignore

# 排除文档（可选）
*.md export-ignore
!GITHUB_README.md
!GITHUB_SETUP.md
```

### 选项 2: 使用独立的发布分支

```bash
# 创建专门的发布分支
git checkout --orphan release-only
git rm -rf .

# 只添加必要文件
git add .github/ GITHUB_README.md gradle/ gradlew* settings.gradle.kts build.gradle.kts gradle.properties

# 提交并推送
git commit -m "Release-only branch"
git push -u origin release-only
```

## ✅ 验证设置

1. **检查仓库内容**：
   - 访问 GitHub 仓库页面
   - 确认没有源代码文件（`.kt` 文件）
   - 确认有 `github-release/` 目录和产物

2. **测试自动发布**：
   ```bash
   git tag v1.0.0-test
   git push origin v1.0.0-test
   ```
   - 检查 GitHub Actions 是否运行
   - 检查是否创建了 Release

3. **验证产物**：
   - 下载 Release 中的文件
   - 验证 SHA256 校验和
   - 测试集成到新项目

## 🚨 重要提示

1. **永远不要推送源代码**：
   - 源代码应该保留在私有仓库或本地
   - 只推送打包产物和必要配置

2. **使用 GitHub Actions**：
   - 自动构建确保一致性
   - 减少人为错误
   - 可以设置构建密钥保护

3. **版本管理**：
   - 使用语义化版本（Semantic Versioning）
   - 每个版本创建对应的 Git Tag
   - 保留发布历史

4. **文档**：
   - 保持 `GITHUB_README.md` 更新
   - 每个 Release 包含详细的 `RELEASE_NOTES.md`

## 📞 支持

如有问题，请参考：
- GitHub Actions 日志
- Release 说明文档
- 本地构建日志

---

**记住：源代码是商业机密，永远不要提交到公开仓库！**

