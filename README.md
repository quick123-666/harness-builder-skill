<div align="center">

# 🛡️ Harness Builder Skill

**Build Organizational AI Agent Harness with Enterprise-Grade Security**

[![GitHub release](https://img.shields.io/github/v/release/quick123-666/harness-builder-skill?include_prereleases)](https://github.com/quick123-666/harness-builder-skill/releases)
[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![OpenClaw](https://img.shields.io/badge/OpenClaw-Compatible-green.svg)](https://openclaw.ai)

[Features](#-features) • [Quick Start](#-quick-start) • [Documentation](#-documentation) • [Roadmap](#-roadmap)

</div>

---

## 📖 Overview

Transform your AI agents from **Level 1/2** to **Level 3 Organizational Harness** in just 10 days with enterprise-grade security controls, audit trails, and agent coordination.

```
Level 1 (Personal) → Level 2 (Team) → Level 3 (Organizational)
                                    ↑
                              This Skill Helps
```

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
      │                    │                    │
   Create Plan        Execute Plan         Verify Results
```

### 📊 Audit System

- **JSONL Logs** - Every action recorded
- **Daily Reports** - Automated compliance summaries
- **Monitoring Skill** - Real-time violation alerts

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

### Usage

```
User: Help me upgrade my project to Level 3 organizational harness

Agent (using this skill):
Great! Before we start, I need to understand:

1. Current state: Level 1 or Level 2?
2. Goals: 3-layer protection, PWR cycle, audit system?
3. Constraints: Tech stack, timeline, team size?
4. Success criteria: How to verify?
```

---

## 📋 Implementation Roadmap

| Phase | Duration | Deliverables |
|-------|----------|--------------|
| **Phase 0** | 1 hour | Discovery questions (3+) |
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

## 🎯 Use Cases

### ✅ Ideal For

- Teams upgrading from Level 1/2 to Level 3
- Organizations requiring audit trails
- Projects with sensitive data protection needs
- Multi-agent coordination requirements

### ❌ Not For

- Personal projects (use Level 1)
- Simple automation tasks
- Projects without security requirements

---

## 📊 Architecture

```
┌─────────────────────────────────────────────────────────┐
│                   Level 3 Harness                       │
├─────────────────────────────────────────────────────────┤
│  Layer 1: System Config                                 │
│  ├── Elevated permissions                               │
│  ├── Protected files (env, keys, secrets)               │
│  └── Network whitelist                                  │
├─────────────────────────────────────────────────────────┤
│  Layer 2: Behavior Constraints                          │
│  ├── AGENTS.md (project rules)                          │
│  ├── SOUL.md (agent personality)                        │
│  └── 13 Protection Rules                                │
├─────────────────────────────────────────────────────────┤
│  Layer 3: Audit Verification                           │
│  ├── JSONL logs (audit/logs/)                          │
│  ├── Daily/weekly reports (audit/reports/)             │
│  └── Monitoring Skill (real-time alerts)               │
└─────────────────────────────────────────────────────────┘
```

---

## 🔧 Configuration

### Protected Files

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

### Blocked Commands

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

## 📈 Verification

### MDM Validation

```powershell
# Run MDM verification script
.\scripts\verify-mdm.ps1

# Expected: 10/10 tests passed
```

### Protection Rules Test

```powershell
# Run protection rules test
.\scripts\test-protection-rules.ps1

# Expected: 12/12 rules working
```

---

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

---

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 🙏 Acknowledgments

- OpenClaw Framework
- Harness Engineering methodology
- Community contributors

---

## 📞 Support

- **Documentation:** [GitHub Wiki](https://github.com/quick123-666/harness-builder-skill/wiki)
- **Issues:** [GitHub Issues](https://github.com/quick123-666/harness-builder-skill/issues)
- **Discussions:** [GitHub Discussions](https://github.com/quick123-666/harness-builder-skill/discussions)

---

<div align="center">

**[⬆ Back to Top](#-harness-builder-skill)**

Made with ❤️ by [quick123-666](https://github.com/quick123-666)

</div>
