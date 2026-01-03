#!/bin/bash

# 准备 GitHub 仓库提交脚本
# 此脚本确保只提交必要文件，不包含源代码

set -e

echo "🚀 准备 GitHub 仓库提交..."
echo ""

# 检查是否已初始化 Git
if [ ! -d ".git" ]; then
    echo "📦 初始化 Git 仓库..."
    git init
fi

# 添加远程仓库
echo "🔗 配置远程仓库..."
git remote remove origin 2>/dev/null || true
git remote add origin https://github.com/pandawengogo/Mobile-MCP-SDK.git
echo "✅ 远程仓库已配置"
echo ""

# 创建 .gitignore 确保源代码不被提交
echo "🔒 检查 .gitignore..."
if ! grep -q "mcp-api/" .gitignore 2>/dev/null; then
    cat >> .gitignore <<EOF

# 源代码目录（不提交到 GitHub）
mcp-api/src/
mcp-core/src/
mcp-client/src/
mcp-compiler/src/
mcp-annotations/src/
nanomcp-sdk/src/
sample-app/src/
sample-app/build/
EOF
    echo "✅ 已更新 .gitignore"
else
    echo "✅ .gitignore 已配置"
fi
echo ""

# 显示将要提交的文件
echo "📋 将要提交的文件列表："
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
git status --short 2>/dev/null || echo "（首次提交）"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# 提示用户
echo "⚠️  重要提示："
echo "   1. 此脚本只会提交以下类型的文件："
echo "      ✅ GitHub 配置文件 (.github/)"
echo "      ✅ 文档文件 (GITHUB_*.md, README.md)"
echo "      ✅ 构建配置 (gradle/, build.gradle.kts, etc.)"
echo "      ✅ 发布脚本 (release-github.sh)"
echo "      ✅ 发布产物 (github-release/)"
echo ""
echo "   2. 源代码目录不会被提交："
echo "      ❌ mcp-api/src/"
echo "      ❌ mcp-core/src/"
echo "      ❌ mcp-compiler/src/"
echo "      ❌ sample-app/src/"
echo ""
echo "📝 下一步操作："
echo "   1. 运行: git add ."
echo "   2. 检查: git status （确认没有源代码文件）"
echo "   3. 提交: git commit -m 'Initial commit: GitHub release setup'"
echo "   4. 推送: git push -u origin main"
echo ""

