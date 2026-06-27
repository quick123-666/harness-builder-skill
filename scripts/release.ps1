# Release Script for Harness Builder Skill
# Usage: .\scripts\release.ps1 -Version "1.0.1"

param(
    [Parameter(Mandatory=$true)]
    [string]$Version
)

# 验证版本格式
if ($Version -notmatch '^\d+\.\d+\.\d+$') {
    Write-Host "错误: 版本格式不正确，应为 X.Y.Z（如 1.0.1）" -ForegroundColor Red
    exit 1
}

$Tag = "v$Version"

Write-Host "=== 准备发布 $Tag ===" -ForegroundColor Cyan

# 检查工作目录状态
$status = git status --porcelain
if ($status) {
    Write-Host "错误: 工作目录不干净，请先提交所有更改" -ForegroundColor Red
    Write-Host $status
    exit 1
}

# 检查标签是否已存在
$existingTag = git tag -l $Tag
if ($existingTag) {
    Write-Host "错误: 标签 $Tag 已存在" -ForegroundColor Red
    exit 1
}

# 更新 README.md 中的版本号
Write-Host "更新版本号..." -ForegroundColor Yellow
$readmePath = "README.md"
$readme = Get-Content $readmePath -Raw
$readme = $readme -replace 'v\d+\.\d+\.\d+', $Tag
$readme | Set-Content $readmePath -NoNewline

# 提交版本更新
git add README.md
git commit -m "chore: bump version to $Tag"

# 创建标签
Write-Host "创建标签 $Tag..." -ForegroundColor Yellow
git tag -a $Tag -m "Release $Tag"

# 推送提交和标签
Write-Host "推送到远程..." -ForegroundColor Yellow
git push origin main
git push origin $Tag

Write-Host "
✅ 发布成功！" -ForegroundColor Green
Write-Host "查看: https://github.com/quick123-666/harness-builder-skill/releases/tag/$Tag" -ForegroundColor Cyan
Write-Host "GitHub Actions 将自动创建 Release 和打包文件" -ForegroundColor Yellow
