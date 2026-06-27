<div align="center">

# 🛡️ Harness Builder Skill

**构建组织级 AI Agent Harness，实现企业级安全防护**

[![GitHub release](https://img.shields.io/github/v/release/quick123-666/harness-builder-skill?include_prereleases)](https://github.com/quick123-666/harness-builder-skill/releases)
[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![OpenClaw](https://img.shields.io/badge/OpenClaw-Compatible-green.svg)](https://openclaw.ai)

[English](#english) | [中文](#中文)

</div>

---

# 中文

## 📖 简介

**10 天升级你的 AI Agent，从 Level 1/2 到 Level 3 组织级 Harness！**

提供三层防护模型、13 条安全规则、PWR 循环协调机制和完整审计系统。

```
Level 1（个人） → Level 2（团队） → Level 3（组织级）
                                      ↑
                                  本 Skill 帮你实现
```

---

## ✨ 核心特性

### 🔐 三层防护模型

| 层级 | 说明 | 实现方式 |
|------|------|----------|
| **系统配置层** | Elevated 权限、受保护文件 | OpenClaw 配置 |
| **行为约束层** | AGENTS.md + SOUL.md 规则 | Markdown 文件 |
| **审计验证层** | JSONL 日志 + 自动报告 | Cron + 监控 |

### 🛡️ 13 条防护规则

**拒绝规则**（无法绕过）：
- `R01` - 阻止 `sudo` 命令
- `R02` - 保护 `.env`、`*.key`、`*.pem` 文件
- `R06` - 阻止 `git push --force`

**询问规则**（需用户确认）：
- `R04` - 确认文件删除
- `R05` - 验证 `rm -rf` 操作

**警告规则**（记录并提醒）：
- `R12` - 标记配置文件修改
- `R13` - 警告外部脚本执行

### 🔄 PWR 循环（Plan → Work → Review）

```
┌─────────────┐      ┌─────────────┐      ┌─────────────┐
│ Plan Agent  │ ───> │ Work Agent  │ ───> │Review Agent │
│  （只读）   │      │  （隔离）   │      │  （只读）   │
└─────────────┘      └─────────────┘      └─────────────┘
      │                    │                    │
    制定计划            执行任务            审查结果
```

### 📊 审计系统

- **JSONL 日志** - 记录每个操作
- **每日报告** - 自动合规摘要
- **监控 Skill** - 实时违规告警

---

## 🚀 快速开始

### 安装

```bash
# 方式 1：克隆仓库
git clone https://github.com/quick123-666/harness-builder-skill.git

# 方式 2：下载 Release
wget https://github.com/quick123-666/harness-builder-skill/releases/download/v1.0.0/harness-builder-skill-v1.0.0.zip

# 安装到 OpenClaw
cp -r harness-builder ~/.qclaw/workspace/skills/
```

### 使用

```
用户：帮我把项目升级到 Level 3 组织级 Harness

Agent（使用此 skill）：
好的！开始前我需要了解：

1. 当前状态：Level 1 还是 Level 2？
2. 目标：需要三层防护、PWR 循环、审计系统吗？
3. 约束：技术栈、时间线、团队规模？
4. 成功标准：如何验证？
```

---

## 📋 实施路线图

| 阶段 | 时长 | 交付物 |
|------|------|--------|
| **阶段 0** | 1 小时 | 发现问题（至少 3 个问题） |
| **阶段 1** | 2 天 | 架构设计 + 文档 |
| **阶段 2** | 2 天 | MDM 强制策略 + 验证 |
| **阶段 3** | 2 天 | 审计 Hook + 日志 |
| **阶段 4** | 2 天 | 防护规则（R01-R13） |
| **阶段 5** | 2 天 | PWR 循环 + 测试 |
| **总计** | **10 天** | Level 3 Harness ✅ |

---

## 📦 包内容

```
harness-builder/
├── SKILL.md                          # 主文档（18.5 KB）
├── README.md                         # 本文件
└── references/
    ├── architecture-template.md      # 架构设计模板
    └── checklist.md                  # 实施检查清单
```

---

## 🎯 适用场景

### ✅ 适合

- 从 Level 1/2 升级到 Level 3 的团队
- 需要审计追踪的组织
- 有敏感数据保护需求的项目
- 多 Agent 协调需求

### ❌ 不适合

- 个人项目（使用 Level 1）
- 简单自动化任务
- 无安全要求的项目

---

## 📊 架构图

```
┌─────────────────────────────────────────────────────────┐
│                   Level 3 Harness                       │
├─────────────────────────────────────────────────────────┤
│  Layer 1: 系统配置层                                     │
│  ├── Elevated 权限                                      │
│  ├── 受保护文件（env, keys, secrets）                   │
│  └── 网络白名单                                         │
├─────────────────────────────────────────────────────────┤
│  Layer 2: 行为约束层                                    │
│  ├── AGENTS.md（项目规则）                              │
│  ├── SOUL.md（Agent 人设）                              │
│  └── 13 条防护规则                                      │
├─────────────────────────────────────────────────────────┤
│  Layer 3: 审计验证层                                    │
│  ├── JSONL 日志（audit/logs/）                          │
│  ├── 每日/每周报告（audit/reports/）                    │
│  └── 监控 Skill（实时告警）                             │
└─────────────────────────────────────────────────────────┘
```

---

## 🔧 配置示例

### 受保护文件

```json
{
  "protectedFiles": [
    ".env",
    ".env.*",
    "*.key",
    "*.pem",
    "secrets/",
    "credentials/"
  ]
}
```

### 阻止命令

```json
{
  "blockedCommands": [
    "sudo *",
    "rm -rf *",
    "git push --force *"
  ]
}
```

---

## 📈 验证

### MDM 验证

```powershell
# 运行 MDM 验证脚本
.\scripts\verify-mdm.ps1

# 预期：10/10 测试通过
```

### 防护规则测试

```powershell
# 运行防护规则测试
.\scripts\test-protection-rules.ps1

# 预期：12/12 规则正常工作
```

---

## 🤝 贡献

欢迎贡献代码！请随时提交 Pull Request。

1. Fork 本仓库
2. 创建特性分支 (`git checkout -b feature/AmazingFeature`)
3. 提交更改 (`git commit -m 'Add some AmazingFeature'`)
4. 推送到分支 (`git push origin feature/AmazingFeature`)
5. 开启 Pull Request

---

## 📝 许可证

本项目采用 MIT 许可证 - 详见 [LICENSE](LICENSE) 文件。

---

## 🙏 致谢

- OpenClaw 框架
- Harness Engineering 方法论
- 社区贡献者

---

## 📞 支持

- **文档：** [GitHub Wiki](https://github.com/quick123-666/harness-builder-skill/wiki)
- **问题：** [GitHub Issues](https://github.com/quick123-666/harness-builder-skill/issues)
- **讨论：** [GitHub Discussions](https://github.com/quick123-666/harness-builder-skill/discussions)

---

<div align="center">

**[⬆ 返回顶部](#-harness-builder-skill)**

Made with ❤️ by [quick123-666](https://github.com/quick123-666)

</div>

---

# English

## 📖 Overview

Transform your AI agents from **Level 1/2** to **Level 3 Organizational Harness** in just 10 days with enterprise-grade security controls, audit trails, and agent coordination.

---

## ✨ Features

### 🔐 Three-Layer Protection Model

| Layer | Description | Implementation |
|-------|-------------|----------------|
| **System Config** | Elevated permissions, protected files | OpenClaw config |
| **Behavior Constraints** | AGENTS.md + SOUL.md rules | Markdown files |
| **Audit Verification** | JSONL logs + automated reports | Cron + monitoring |

### 🛡️ 13 Protection Rules

**Deny Rules** (cannot be bypassed):
- `R01` - Block `sudo` commands
- `R02` - Protect `.env`, `*.key`, `*.pem` files
- `R06` - Prevent `git push --force`

**Ask Rules** (require user confirmation):
- `R04` - Confirm file deletions
- `R05` - Validate `rm -rf` operations

**Warn Rules** (log and alert):
- `R12` - Flag config file changes
- `R13` - Alert on external script execution

### 🔄 PWR Cycle (Plan → Work → Review)

```
┌─────────────┐      ┌─────────────┐      ┌─────────────┐
│ Plan Agent  │ ───> │ Work Agent  │ ───> │Review Agent │
│  (Read-only)│      │ (Isolated)  │      │ (Read-only) │
└─────────────┘      └─────────────┘      └─────────────┘
```

---

## 🚀 Quick Start

### Installation

```bash
# Option 1: Clone repository
git clone https://github.com/quick123-666/harness-builder-skill.git

# Option 2: Download release
wget https://github.com/quick123-666/harness-builder-skill/releases/download/v1.0.0/harness-builder-skill-v1.0.0.zip

# Install to OpenClaw
cp -r harness-builder ~/.qclaw/workspace/skills/
```

---

## 📋 Implementation Roadmap

| Phase | Duration | Deliverables |
|-------|----------|--------------|
| **Phase 1** | 2 days | Architecture design + docs |
| **Phase 2** | 2 days | MDM enforcement + verification |
| **Phase 3** | 2 days | Audit hooks + logging |
| **Phase 4** | 2 days | Protection rules (R01-R13) |
| **Phase 5** | 2 days | PWR cycle + testing |
| **Total** | **10 days** | Level 3 Harness ✅ |

---

## 📦 Package Contents

```
harness-builder/
├── SKILL.md                          # Main documentation (18.5 KB)
├── README.md                         # This file
└── references/
    ├── architecture-template.md      # Architecture design template
    └── checklist.md                  # Implementation checklist
```

---

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

---

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

<div align="center">

**[⬆ Back to Top](#-harness-builder-skill)**

Made with ❤️ by [quick123-666](https://github.com/quick123-666)

</div>
