#!/bin/bash

# 安全提交到 GitHub 的脚本
# 确保只提交必要文件，不包含源代码

set -e

echo "🚀 准备提交到 GitHub 仓库..."
echo ""

# 检查远程仓库
if ! git remote get-url origin &>/dev/null; then
    echo "🔗 添加远程仓库..."
    git remote add origin https://github.com/pandawengogo/Mobile-MCP-SDK.git
fi

# 显示当前状态
echo "📋 当前 Git 状态："
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
git status --short
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# 检查是否有源代码文件被添加
echo "🔍 检查是否有源代码文件..."
SOURCE_FILES=$(git status --short | grep -E "(mcp-.*/src/|sample-app/src/)" || true)
if [ -n "$SOURCE_FILES" ]; then
    echo "⚠️  警告：检测到源代码文件！"
    echo "$SOURCE_FILES"
    echo ""
    echo "❌ 为了安全，这些文件不会被提交。"
    echo "   如果需要提交源代码，请手动确认。"
    echo ""
    read -p "是否继续？(y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "❌ 已取消"
        exit 1
    fi
fi

# 添加文件（排除源代码）
echo "📦 添加文件到暂存区..."
git add .github/
git add GITHUB_*.md
git add README.md 2>/dev/null || true
git add .gitignore
git add .gitattributes
git add gradle/
git add gradlew
git add gradlew.bat
git add settings.gradle.kts
git add build.gradle.kts
git add gradle.properties
git add release-github.sh
git add prepare-github-repo.sh
git add commit-to-github.sh

# 添加发布产物（如果存在）
if [ -d "github-release" ]; then
    git add github-release/
fi

echo "✅ 文件已添加到暂存区"
echo ""

# 显示将要提交的文件
echo "📋 将要提交的文件："
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
git status --short
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# 确认
read -p "确认提交这些文件到 GitHub？(y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "❌ 已取消"
    exit 1
fi

# 提交
COMMIT_MSG=${1:-"Initial commit: GitHub release setup"}
echo "💾 提交更改..."
git commit -m "$COMMIT_MSG"
echo "✅ 已提交"
echo ""

# 设置默认分支为 main
CURRENT_BRANCH=$(git branch --show-current)
if [ "$CURRENT_BRANCH" != "main" ]; then
    echo "🔄 重命名分支为 main..."
    git branch -m main
fi

# 推送
echo "📤 推送到 GitHub..."
echo "   远程仓库: $(git remote get-url origin)"
echo "   分支: main"
echo ""
read -p "确认推送到 GitHub？(y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "❌ 已取消推送"
    echo "   你可以稍后手动运行: git push -u origin main"
    exit 0
fi

git push -u origin main

echo ""
echo "🎉 完成！"
echo ""
echo "📦 仓库地址: https://github.com/pandawengogo/Mobile-MCP-SDK"
echo ""
echo "✅ 已提交的文件："
echo "   - GitHub Actions 工作流"
echo "   - 文档文件"
echo "   - 构建配置"
echo "   - 发布脚本"
echo ""
echo "🔒 未提交的文件（源代码保护）："
echo "   - mcp-api/src/"
echo "   - mcp-core/src/"
echo "   - mcp-compiler/src/"
echo "   - sample-app/src/"
echo ""

