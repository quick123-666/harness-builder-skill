# Harness Builder Skill

构建组织级 AI Agent Harness 的完整工具链。

---

## 快速开始

```powershell
# 触发 skill
"帮我把我的项目升级到 Level 3 组织级 Harness"
```

---

## 功能

### 1. 三层防护模型

- Layer 1: 系统配置层（elevated 权限）
- Layer 2: 行为约束层（AGENTS.md + SOUL.md）
- Layer 3: 审计验证层（审计日志 + 定期验证）

### 2. MDM 强制策略

- 受保护文件清单
- 阻止命令列表
- 网络白名单
- MDM 验证脚本

### 3. 审计系统

- JSONL 格式审计日志
- 每日/每周审计报告
- 审计监控 Skill

### 4. 防护规则

- R01-R13 规则体系
- 配置层（deny）
- 行为层（deny/ask/warn）

### 5. PWR 循环

- Plan Agent（只读，制定计划）
- Work Agent（隔离，执行计划）
- Review Agent（只读，审查结果）

---

## 实施流程

```
Phase 0: Discovery（发现阶段）
    ↓ 询问用户至少 3 个问题
Phase 1: 架构设计（2 天）
    ↓ 创建架构文档和设计
Phase 2: MDM 强制策略（2 天）
    ↓ 创建 MDM 配置和验证
Phase 3: 审计 Hook（2 天）
    ↓ 创建审计系统和日志
Phase 4: 防护规则（2 天）
    ↓ 创建规则文档和测试
Phase 5: PWR 循环（2 天）
    ↓ 创建 Agent Skills
完成 ✅
```

---

## 目录结构

```
skills/harness-builder/
├── SKILL.md                    # 主文档
├── README.md                   # 本文件
├── templates/
│   ├── architecture-template.md    # 架构设计模板
│   └── checklist.md                # 实施检查清单
└── examples/
    └── complete-example.md         # 完整示例
```

---

## 模板

### 架构设计模板

包含：
- 三层防护模型设计
- PWR 循环架构
- 防护规则体系
- 审计系统设计

### 实施检查清单

包含：
- 5 阶段任务清单
- 每日任务分解
- 最终验收清单
- 交付物清单

---

## 示例

### 完整示例

展示了一个 CLI 项目从 Level 1 升级到 Level 3 的完整过程：

1. Discovery 阶段交互
2. 10 天实施过程
3. 每个阶段的输出
4. 测试结果
5. 最终验收报告

---

## 质量保证

### DO/DON'T 清单

**✅ DO：**
- 使用具体、可衡量的标准
- 提供完整的模板
- 记录详细的审计日志

**❌ DON'T：**
- 跳过发现阶段
- 忽略用户约束
- 缺少验证步骤

---

## 适用场景

- Level 1 → Level 3 升级
- Level 2 → Level 3 升级
- 新建 Level 3 项目
- 安全增强项目

---

## 技术栈支持

- Node.js
- Python
- Go
- 其他（可定制）

---

## 版本历史

- **v1.0.0** (2026-06-27)：初始版本，基于 bendiherness 项目经验
