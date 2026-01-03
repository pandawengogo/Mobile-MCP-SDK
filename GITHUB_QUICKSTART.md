# 🚀 GitHub 发布快速指南

## 一键发布流程

### 1. 本地构建并准备产物

```bash
# 运行发布脚本
./release-github.sh 1.0.0
```

这会：
- ✅ 构建所有模块
- ✅ 生成 Fat AAR
- ✅ 创建发布目录
- ✅ 生成 SHA256 校验和
- ✅ 创建发布说明

### 2. 推送到 GitHub

#### 方法 A: 使用 GitHub Actions（自动）

```bash
# 创建并推送标签
git tag v1.0.0
git push origin v1.0.0
```

GitHub Actions 会自动：
- 🔨 构建项目
- 📦 打包产物
- 🚀 创建 Release
- 📤 上传文件

#### 方法 B: 手动创建 Release

1. 访问：https://github.com/pandawengogo/Mobile-MCP-SDK/releases/new
2. 填写信息：
   - Tag: `v1.0.0`
   - Title: `NanoMCP SDK v1.0.0`
   - Description: 复制 `github-release/latest/RELEASE_NOTES.md` 内容
3. 上传文件：
   - `nanomcp-sdk-1.0.0.aar`
   - `mcp-annotations-1.0.0.jar`
   - `mcp-compiler-1.0.0.jar`
   - 所有 `.sha256` 文件
4. 点击 "Publish release"

#### 方法 C: 使用 GitHub CLI

```bash
gh release create v1.0.0 \
  --title "NanoMCP SDK v1.0.0" \
  --notes-file "github-release/latest/RELEASE_NOTES.md" \
  "github-release/latest/*.aar" \
  "github-release/latest/*.jar" \
  "github-release/latest/*.sha256"
```

## 📋 检查清单

发布前确认：

- [ ] 版本号已更新
- [ ] 所有测试通过
- [ ] 产物文件完整（.aar, .jar）
- [ ] SHA256 校验和已生成
- [ ] RELEASE_NOTES.md 已更新
- [ ] 源代码未包含在仓库中

## 🔍 验证发布

1. **检查 Release 页面**：
   - https://github.com/pandawengogo/Mobile-MCP-SDK/releases
   - 确认文件都已上传

2. **验证文件完整性**：
```bash
# 下载文件
wget https://github.com/pandawengogo/Mobile-MCP-SDK/releases/download/v1.0.0/nanomcp-sdk-1.0.0.aar

# 验证 SHA256
shasum -a 256 nanomcp-sdk-1.0.0.aar
# 对比 Release 页面上的 SHA256
```

3. **测试集成**：
   - 创建新项目
   - 下载并集成 SDK
   - 验证功能正常

## 🎯 版本命名规范

使用语义化版本（SemVer）：
- `1.0.0` - 主版本.次版本.修订版本
- `1.0.1` - 修复 bug
- `1.1.0` - 新功能
- `2.0.0` - 重大变更

## 📝 发布说明模板

每次发布应包含：

1. **版本号**
2. **发布日期**
3. **新增功能**
4. **Bug 修复**
5. **破坏性变更**（如有）
6. **升级指南**（如有）

## ⚠️ 重要提醒

1. **永远不要提交源代码到 GitHub**
2. **只发布打包后的产物**
3. **每次发布都要生成校验和**
4. **保持发布说明清晰详细**

---

**快速命令参考**：

```bash
# 构建并准备发布
./release-github.sh 1.0.0

# 查看产物
ls -lh github-release/latest/

# 创建 Git 标签
git tag v1.0.0
git push origin v1.0.0

# 或手动创建 Release（使用 GitHub CLI）
gh release create v1.0.0 --title "NanoMCP SDK v1.0.0" --notes-file "github-release/latest/RELEASE_NOTES.md" github-release/latest/*
```

