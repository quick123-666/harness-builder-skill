#!/bin/bash
# Release Script for Harness Builder Skill
# Usage: ./scripts/release.sh 1.0.1

set -e

VERSION=$1
if [ -z "$VERSION" ]; then
    echo "错误: 请提供版本号"
    echo "用法: ./scripts/release.sh 1.0.1"
    exit 1
fi

# 验证版本格式
if [[ ! $VERSION =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    echo "错误: 版本格式不正确，应为 X.Y.Z（如 1.0.1）"
    exit 1
fi

TAG="v$VERSION"

echo "=== 准备发布 $TAG ==="

# 检查工作目录状态
if [ -n "$(git status --porcelain)" ]; then
    echo "错误: 工作目录不干净，请先提交所有更改"
    git status --short
    exit 1
fi

# 检查标签是否已存在
if git tag -l | grep -q "^$TAG$"; then
    echo "错误: 标签 $TAG 已存在"
    exit 1
fi

# 更新 README.md 中的版本号
echo "更新版本号..."
sed -i "s/v[0-9]\+\.[0-9]\+\.[0-9]\+/$TAG/g" README.md

# 提交版本更新
git add README.md
git commit -m "chore: bump version to $TAG"

# 创建标签
echo "创建标签 $TAG..."
git tag -a $TAG -m "Release $TAG"

# 推送提交和标签
echo "推送到远程..."
git push origin main
git push origin $TAG

echo ""
echo "✅ 发布成功！"
echo "查看: https://github.com/quick123-666/harness-builder-skill/releases/tag/$TAG"
echo "GitHub Actions 将自动创建 Release 和打包文件"
