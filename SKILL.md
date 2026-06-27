---
name: harness-builder
description: 将任意项目从 Level 1/2 升级到 Level 3 组织级 Harness，包括三层防护模型、PWR 循环、防护规则、审计系统。触发词：「升级到 Level 3」、「构建组织级 Harness」、「创建防护规则」、「实现审计系统」、「PWR 循环」。
version: 1.0.0
author: OpenClaw Community
license: MIT
---

# Harness Builder Skill

构建组织级 AI Agent Harness 的完整工具链。

---

## 触发条件

当用户提到以下关键词时，使用此 skill：
- "升级到 Level 3"、"组织级 Harness"
- "创建防护规则"、"实现审计系统"
- "PWR 循环"、"Plan Work Review"
- "构建安全 Harness"、"MDM 策略"

---

## 快速开始

### 5 阶段 10 天计划

| 阶段 | 时间 | 任务 |
|------|------|------|
| 阶段 1 | 2 天 | 架构设计与规划 |
| 阶段 2 | 2 天 | MDM 强制策略 |
| 阶段 3 | 2 天 | 审计 Hook 与日志 |
| 阶段 4 | 2 天 | 13 条防护规则 |
| 阶段 5 | 2 天 | PWR 循环实现 |

---

## 工作流程

### Phase 0: Discovery（发现阶段）

**必须先询问用户以下问题（至少 3 个）：**

1. **当前状态**：
   - 项目当前是 Level 1（单 Agent）还是 Level 2（多 Agent）？
   - 现有的安全措施有哪些？

2. **目标**：
   - 是否需要三层防护模型？
   - 是否需要 PWR 循环？
   - 是否需要审计系统？

3. **约束条件**：
   - 项目类型（Web 应用/CLI 工具/API 服务）？
   - 技术栈（Node.js/Python/Go）？
   - 预期完成时间？

4. **成功标准**：
   - 如何验证 Harness 构建成功？
   - 需要达到什么安全级别？

---

### Phase 1: 架构设计（2 天）

#### 任务清单

**文档创建：**
- [ ] 创建 `docs/level3-architecture.md` - 架构设计文档
- [ ] 创建 `docs/openclaw-adaptation.md` - OpenClaw 适配文档
- [ ] 创建 `docs/implementation-roadmap.md` - 实施路线图

**架构设计：**
- [ ] 设计三层防护模型
- [ ] 设计 PWR 循环架构
- [ ] 设计审计日志系统

#### 架构模板

```markdown
# Level 3 组织级 Harness 架构

## 一、三层防护模型

### Layer 1: 系统配置层
- OpenClaw elevated 权限
- 无法绕过的硬性限制

### Layer 2: 行为约束层
- AGENTS.md 项目规约
- SOUL.md 人设约束

### Layer 3: 审计验证层
- 审计日志记录
- 定期审计验证

## 二、PWR 循环

Plan Agent (只读) → Work Agent (隔离) → Review Agent (只读)

## 三、防护规则

R01-R13 规则体系

## 四、审计系统

JSONL 格式审计日志
```

---

### Phase 2: MDM 强制策略（2 天）

#### 任务清单

**配置创建：**
- [ ] 创建 `.openclaw/protected-files.json` - 受保护文件清单
- [ ] 更新 `AGENTS.md` - 添加 MDM 章节
- [ ] 更新 `SOUL.md` - 添加防护规则

**脚本创建：**
- [ ] 创建 `scripts/verify-mdm.ps1` - MDM 验证脚本

**文档创建：**
- [ ] 创建 `docs/mdm-policy.md` - MDM 策略文档

#### MDM 配置模板

```json
{
  "protectedFiles": [
    ".env",
    ".env.*",
    "*.key",
    "*.pem",
    "secrets/",
    "credentials/",
    "config/secrets.*"
  ],
  "protectedPaths": [
    "secrets/",
    "credentials/",
    ".ssh/",
    ".gnupg/"
  ],
  "blockedCommands": [
    "sudo *",
    "rm -rf *",
    "rm -fr *",
    "git push --force *",
    "git reset --hard *",
    "del /s /q *",
    "npm publish *"
  ],
  "networkWhitelist": [
    "*.github.com",
    "registry.npmjs.org",
    "api.anthropic.com"
  ]
}
```

#### MDM 验证脚本模板

```powershell
# scripts/verify-mdm.ps1

param(
    [string]$ProjectRoot = "."
)

$configPath = Join-Path $ProjectRoot ".openclaw/protected-files.json"
$config = Get-Content $configPath | ConvertFrom-Json

$tests = @()

# Test 1: Protected files check
$protectedFiles = $config.protectedFiles
foreach ($pattern in $protectedFiles) {
    $files = Get-ChildItem -Path $ProjectRoot -Filter $pattern -Recurse -ErrorAction SilentlyContinue
    if ($files) {
        $tests += @{
            Name = "Protected file: $pattern"
            Result = "PASS"
            Details = "Found $($files.Count) protected file(s)"
        }
    }
}

# Test 2: Blocked commands in history
$historyFile = Join-Path $ProjectRoot ".bash_history"
if (Test-Path $historyFile) {
    $history = Get-Content $historyFile
    $blockedCommands = $config.blockedCommands
    foreach ($cmd in $blockedCommands) {
        if ($history -match $cmd) {
            $tests += @{
                Name = "Blocked command: $cmd"
                Result = "FAIL"
                Details = "Found blocked command in history"
            }
        }
    }
}

# Output results
$tests | ForEach-Object {
    Write-Host "$($_.Result): $($_.Name)"
}

$passed = ($tests | Where-Object { $_.Result -eq "PASS" }).Count
$failed = ($tests | Where-Object { $_.Result -eq "FAIL" }).Count

Write-Host "`nPassed: $passed  Failed: $failed"

if ($failed -eq 0) {
    Write-Host "ALL PASS" -ForegroundColor Green
} else {
    Write-Host "SOME FAILURES" -ForegroundColor Red
}
```

---

### Phase 3: 审计 Hook（2 天）

#### 任务清单

**目录创建：**
- [ ] 创建 `audit/logs/` - 审计日志目录
- [ ] 创建 `audit/reports/` - 审计报告目录

**脚本创建：**
- [ ] 创建 `scripts/audit-utils.psm1` - 审计工具模块
- [ ] 创建 `scripts/generate-audit-report.ps1` - 报告生成脚本

**Skill 创建：**
- [ ] 创建 `skills/audit-monitor/SKILL.md` - 审计监控 Skill

**文档创建：**
- [ ] 创建 `audit/README.md` - 审计日志文档

#### 审计工具模块模板

```powershell
# scripts/audit-utils.psm1

$AuditLogPath = "audit/logs"
$AuditReportPath = "audit/reports"

function Write-AuditLog {
    param(
        [string]$Event,
        [string]$Tool,
        [string]$Input,
        [string]$Result,
        [string]$Reason = ""
    )

    $timestamp = Get-Date -Format "yyyy-MM-ddTHH:mm:ssZ"
    $logFile = Join-Path $AuditLogPath "$(Get-Date -Format 'yyyy-MM-dd').jsonl"

    $entry = @{
        timestamp = $timestamp
        event = $Event
        tool = $Tool
        input = $Input
        result = $Result
        reason = $Reason
    } | ConvertTo-Json -Compress

    Add-Content -Path $logFile -Value $entry
}

function Get-AuditStats {
    param(
        [string]$LogFile
    )

    $logs = Get-Content $LogFile | ConvertFrom-Json

    $stats = @{
        total = $logs.Count
        allowed = ($logs | Where-Object { $_.result -eq "allowed" }).Count
        denied = ($logs | Where-Object { $_.result -eq "denied" }).Count
        warned = ($logs | Where-Object { $_.result -eq "warned" }).Count
        asked = ($logs | Where-Object { $_.result -eq "asked" }).Count
    }

    return $stats
}

function New-AuditReport {
    param(
        [string]$Date = (Get-Date -Format "yyyy-MM-dd"),
        [string]$Type = "daily"
    )

    $logFile = Join-Path $AuditLogPath "$Date.jsonl"

    if (-not (Test-Path $logFile)) {
        Write-Warning "No audit log found for $Date"
        return
    }

    $stats = Get-AuditStats -LogFile $logFile

    $report = @"
# $Type Audit Report - $Date

Generated: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')

## Summary

- Total: $($stats.total)
- Allowed: $($stats.allowed)
- Denied: $($stats.denied)
- Warned: $($stats.warned)
- Asked: $($stats.asked)

## Denied Operations

"@

    $logs = Get-Content $logFile | ConvertFrom-Json
    $denied = $logs | Where-Object { $_.result -eq "denied" }

    foreach ($entry in $denied) {
        $report += "- [$($entry.timestamp)] $($entry.tool): $($entry.input) - $($entry.reason)`n"
    }

    $reportFile = Join-Path $AuditReportPath "$Type-$Date.md"
    Set-Content -Path $reportFile -Value $report

    Write-Host "Report generated: $reportFile"
}

Export-ModuleMember -Function Write-AuditLog, Get-AuditStats, New-AuditReport
```

---

### Phase 4: 13 条防护规则（2 天）

#### 任务清单

**文档创建：**
- [ ] 创建 `docs/protection-rules.md` - 完整规则文档
- [ ] 创建 `docs/protection-rules-scenarios.md` - 验证场景
- [ ] 创建 `docs/protection-rules-quickref.md` - 快速参考

**脚本创建：**
- [ ] 创建 `scripts/test-protection-rules.ps1` - 测试脚本

**更新：**
- [ ] 更新 `SOUL.md` - 添加完整规则定义

#### 防护规则模板

```markdown
# 防护规则（R01-R13）

## 配置层（deny - 无法绕过）

### R01: 阻止 sudo 命令
- **触发条件**：Bash 命令以 `sudo` 开头
- **行为**：deny
- **原因**：防止权限提升

### R02: 禁止写入敏感文件
- **触发条件**：Write/Edit 目标文件匹配 `.env`, `.env.*`, `*.key`, `*.pem`, `secrets/*`
- **行为**：deny
- **原因**：防止敏感信息泄露

### R06: 禁止强制推送
- **触发条件**：Bash 命令包含 `git push --force` 或 `git push -f`
- **行为**：deny
- **原因**：防止代码历史丢失

## 行为层（deny - Agent 自检拒绝）

### R03: 禁止删除核心文件
- **触发条件**：删除操作目标匹配 `src/*`, `lib/*`, `core/*`
- **行为**：deny
- **原因**：防止核心代码丢失

### R10: 禁止网络访问非白名单域名
- **触发条件**：网络请求目标不在白名单
- **行为**：deny
- **原因**：防止数据外泄

### R11: 禁止执行非签名脚本
- **触发条件**：执行脚本不在项目目录或未签名
- **行为**：deny
- **原因**：防止恶意代码执行

## 行为层（ask - 询问用户确认）

### R04: 修改核心配置前询问
- **触发条件**：修改 `*.config.*`, `*.json`, `*.yaml`, `*.yml`
- **行为**：ask
- **原因**：确保用户知情

### R05: 删除操作前询问
- **触发条件**：删除文件或目录
- **行为**：ask
- **原因**：防止误删

## 行为层（warn - 发出警告）

### R12: 大文件写入警告
- **触发条件**：写入文件 > 1MB
- **行为**：warn
- **原因**：防止资源耗尽

### R13: 频繁操作警告
- **触发条件**：同一操作 1 分钟内 > 10 次
- **行为**：warn
- **原因**：防止无限循环
```

#### 测试脚本模板

```powershell
# scripts/test-protection-rules.ps1

param(
    [string]$ProjectRoot = "."
)

$tests = @()

# R01: sudo blocked
$tests += @{
    Name = "R01: sudo blocked"
    Test = {
        $cmd = "sudo apt update"
        return $cmd -match "^sudo "
    }
}

# R02: .env protected
$tests += @{
    Name = "R02a: .env protected"
    Test = {
        $file = ".env"
        return $file -match "^\.env$" -or $file -match "^\.env\."
    }
}

# R02: .key protected
$tests += @{
    Name = "R02b: .key protected"
    Test = {
        $file = "private.key"
        return $file -match "\.key$"
    }
}

# R02: .pem protected
$tests += @{
    Name = "R02c: .pem protected"
    Test = {
        $file = "certificate.pem"
        return $file -match "\.pem$"
    }
}

# R06: force push blocked
$tests += @{
    Name = "R06: force push blocked"
    Test = {
        $cmd = "git push --force origin main"
        return $cmd -match "git push (-f|--force)"
    }
}

# Run tests
Write-Host "=== Protection Rules Test ===`n" -ForegroundColor Cyan

$passed = 0
$failed = 0

foreach ($test in $tests) {
    $result = & $test.Test
    if ($result) {
        Write-Host "$($test.Name): OK" -ForegroundColor Green
        $passed++
    } else {
        Write-Host "$($test.Name): FAIL" -ForegroundColor Red
        $failed++
    }
}

Write-Host "`n=== Results ===" -ForegroundColor Cyan
Write-Host "Passed: $passed  Failed: $failed"

if ($failed -eq 0) {
    Write-Host "ALL PASS" -ForegroundColor Green
}
```

---

### Phase 5: PWR 循环（2 天）

#### 任务清单

**Skill 创建：**
- [ ] 创建 `skills/plan-agent/SKILL.md` - 规划代理
- [ ] 创建 `skills/work-agent/SKILL.md` - 执行代理
- [ ] 创建 `skills/review-agent/SKILL.md` - 审查代理

**文档创建：**
- [ ] 创建 `docs/pwr-coordinator.md` - PWR 协调器
- [ ] 创建 `docs/pwr-test-scenarios.md` - 测试场景

#### Plan Agent 模板

```markdown
---
name: plan-agent
description: 规划代理，制定详细执行计划。只读权限，不修改文件。
---

# Plan Agent

## 角色
- **权限**：只读（Read / Grep / Glob）
- **职责**：制定详细执行计划

## 工作流程

### Phase 0: Discovery
询问用户至少 2 个问题：
1. 任务优先级？
2. 可接受的风险级别？
3. 预期完成时间？

### Phase 1: Planning
使用严格模板制定计划

## 输出格式（严格模板）

### 1. 任务概述（必填）
- **目标**：（必填）
- **范围**：（必填）
- **约束**：（必填）

### 2. 执行步骤（必填）
每个步骤必须包含：
- 步骤编号
- 描述
- 工具
- 输入
- 风险级别
- 预期输出
- 回滚方案（高风险必填）

### 3. 风险评估（必填）
- 整体风险级别
- 高风险步骤列表
- 缓解措施

### 4. 验收标准（必填）
- 完成定义
- 测试要求

### 5. 依赖关系（必填）
- 前置任务
- 外部依赖

## DO/DON'T

### ✅ DO
- 使用具体的风险评估
- 提供可验证的成功标准
- 明确依赖关系
- 提供回滚方案

### ❌ DON'T
- 跳过 Discovery 阶段
- 忽略风险标注
- 模糊的成功标准
- 缺少回滚方案
```

#### Work Agent 模板

```markdown
---
name: work-agent
description: 执行代理，隔离执行计划。读写权限，遵守防护规则。
---

# Work Agent

## 角色
- **权限**：读写（Read / Write / Edit / Bash）
- **职责**：隔离执行计划

## 工作流程

### Phase 1: 接收计划
从 Plan Agent 接收执行计划

### Phase 2: 检查规则
执行每个步骤前检查防护规则 R01-R13

### Phase 3: 高风险预确认
高风险步骤主动询问用户确认

### Phase 4: 执行
按步骤执行，记录审计日志

### Phase 5: 返回结果
返回执行报告给 Review Agent

## DO/DON'T

### ✅ DO
- 执行前检查防护规则
- 记录详细的执行日志
- 立即停止并报告错误
- 高风险操作主动确认

### ❌ DON'T
- 绕过防护规则
- 自动重试失败操作
- 忽略审计日志
- 跳过用户确认
```

#### Review Agent 模板

```markdown
---
name: review-agent
description: 审查代理，审查执行结果。只读权限，不修改文件。
---

# Review Agent

## 角色
- **权限**：只读（Read / Grep / Glob / Bash for tests）
- **职责**：审查执行结果

## 工作流程

### Phase 1: 接收执行结果
从 Work Agent 接收执行报告

### Phase 2: 代码审查
审查代码质量、安全性、合规性

### Phase 3: 测试验证
运行测试，验证覆盖率

### Phase 4: 输出审查报告
使用严格模板输出审查报告

## 输出格式（严格模板）

### 1. 任务信息（必填）
- Plan ID
- 任务
- 执行结果
- 审查时间

### 2. 代码审查（必填）
每个文件必须包含：
- 文件路径
- 变更类型
- 代码风格
- 类型安全
- 安全问题
- TODO 注释

### 3. 测试结果（必填）
- 测试通过率
- 代码覆盖率

### 4. 合规性检查（必填）
- 防护规则遵守
- MDM 策略遵守
- 审计日志完整

### 5. 结论（必填）
- 审查结果（✅/⚠️/❌）
- 是否可发布

## DO/DON'T

### ✅ DO
- 客观审查
- 验证测试结果
- 检查合规性
- 提供可操作的建议

### ❌ DON'T
- 只指出问题不给出建议
- 主观评价
- 忽略安全检查
- 跳过测试验证
```

---

## 质量要求

### ✅ DO（推荐做法）

**使用具体、可衡量的标准：**
- ✅ 正确：测试必须通过（21/21），覆盖率 ≥ 80%
- ❌ 错误：测试通过，覆盖率不错

**提供完整的模板：**
- ✅ 正确：提供完整可运行的脚本模板
- ❌ 错误：只提供概念描述

**记录详细的审计日志：**
- ✅ 正确：记录时间戳、工具、输入、结果、原因
- ❌ 错误：只记录"操作失败"

### ❌ DON'T（避免做法）

1. **跳过发现阶段**：永远不要在没有问至少 3 个问题的情况下开始构建
2. **忽略用户约束**：如果用户没有指定技术栈，标注为 `TBD`
3. **缺少验证步骤**：每个阶段必须有验证脚本或测试
4. **过于乐观**：考虑失败场景和降级方案

---

## 示例：完整构建流程

### 用户请求

```
帮我把我的项目升级到 Level 3 组织级 Harness
```

### Agent 使用此 Skill

```
好的！在开始构建之前，我需要了解几个问题：

1. **当前状态**：
   - 你的项目现在是 Level 1（单 Agent）还是 Level 2（多 Agent）？
   - 现有的安全措施有哪些？

2. **目标**：
   - 是否需要三层防护模型？
   - 是否需要 PWR 循环？
   - 是否需要审计系统？

3. **约束条件**：
   - 项目类型是什么？（Web 应用/CLI 工具/API 服务）
   - 技术栈是什么？（Node.js/Python/Go）
   - 预期完成时间？（5 天 / 10 天 / 2 周）

4. **成功标准**：
   - 如何验证 Harness 构建成功？
   - 需要达到什么安全级别？

请回答这些问题，我会为你制定详细的实施计划。
```

### 用户回答

```
1. 当前是 Level 2，有多 Agent 配置
2. 需要三层防护、PWR 循环、审计系统
3. Node.js 项目，CLI 工具
4. 10 天完成，所有测试通过
```

### Agent 输出计划

```markdown
# Level 3 Harness 构建计划

## 项目信息
- 当前状态：Level 2（多 Agent）
- 目标：Level 3 组织级 Harness
- 技术栈：Node.js
- 项目类型：CLI 工具
- 预期时间：10 天

## 实施路线

### 阶段 1: 架构设计（2 天）
- 创建架构文档
- 设计三层防护模型
- 设计 PWR 循环

### 阶段 2: MDM 强制策略（2 天）
- 创建 protected-files.json
- 创建验证脚本
- 更新 AGENTS.md 和 SOUL.md

### 阶段 3: 审计 Hook（2 天）
- 创建审计目录
- 创建审计工具模块
- 创建审计监控 Skill

### 阶段 4: 防护规则（2 天）
- 创建规则文档
- 创建测试脚本
- 更新 SOUL.md

### 阶段 5: PWR 循环（2 天）
- 创建 Plan/Work/Review Agent
- 创建协调器文档
- 创建测试场景

## 验收标准
- [ ] 所有 MDM 验证通过
- [ ] 所有防护规则测试通过
- [ ] 审计日志系统正常工作
- [ ] PWR 循环可以完整执行
```

---

## 工具集成

此 skill 可以与其他 OpenClaw skills 集成：

- **docx** - 生成 Word 格式的架构文档
- **xlsx** - 生成实施进度跟踪表
- **localgraph-rag** - 查询 Harness 相关知识

---

## 版本历史

- **v1.0.0** (2026-06-27)：初始版本，基于 bendiherness 项目经验
