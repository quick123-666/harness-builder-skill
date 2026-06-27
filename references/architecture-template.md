# 架构设计模板

使用本模板创建 Level 3 组织级 Harness 的架构设计文档。

---

## 项目信息

- **项目名称：** [填写项目名]
- **当前级别：** [Level 1 / Level 2]
- **目标级别：** Level 3 组织级 Harness
- **技术栈：** [Node.js / Python / Go / 其他]
- **项目类型：** [Web 应用 / CLI 工具 / API 服务]
- **预期完成时间：** [X 天]

---

## 三层防护模型

### Layer 1: 系统配置层

**OpenClaw elevated 权限：**
- [ ] 配置 `tools.elevated.enabled`
- [ ] 定义受保护文件清单
- [ ] 定义网络白名单

**实现方式：**
```json
{
  "tools": {
    "elevated": {
      "enabled": true,
      "allowFrom": {
        "webchat": ["*"]
      }
    }
  }
}
```

---

### Layer 2: 行为约束层

**AGENTS.md 约束：**
- [ ] 定义项目规约
- [ ] 定义文件访问权限
- [ ] 定义禁止操作

**SOUL.md 约束：**
- [ ] 定义人设
- [ ] 定义行为准则
- [ ] 定义防护规则

**示例：**
```markdown
# AGENTS.md

## 受保护文件
- `.env`, `.env.*`
- `*.key`, `*.pem`
- `secrets/`, `credentials/`

## 禁止操作
- `sudo *`
- `rm -rf *`
- `git push --force *`
```

---

### Layer 3: 审计验证层

**审计日志：**
- [ ] 创建 `audit/logs/` 目录
- [ ] 创建 `audit/reports/` 目录
- [ ] 实现 JSONL 格式日志

**定期验证：**
- [ ] 配置 cron 定期审计
- [ ] 使用 lcm_grep 搜索验证

**示例：**
```json
{
  "timestamp": "2026-06-27T14:00:00Z",
  "event": "tool_use",
  "tool": "Bash",
  "input": "sudo apt update",
  "result": "denied",
  "reason": "R01: sudo blocked"
}
```

---

## MDM 强制策略

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

### 验证脚本

```powershell
# scripts/verify-mdm.ps1
# 运行 MDM 配置验证
```

---

## 防护规则体系

### 配置层（deny - 无法绕过）

| 规则 | 触发条件 | 行为 | 原因 |
|------|----------|------|------|
| R01 | `sudo *` | deny | 防止权限提升 |
| R02 | 写入 `.env`, `*.key` | deny | 防止敏感信息泄露 |
| R06 | `git push --force` | deny | 防止代码历史丢失 |

### 行为层（deny）

| 规则 | 触发条件 | 行为 | 原因 |
|------|----------|------|------|
| R03 | 写入系统目录 | deny | 保护系统安全 |
| R10 | 访问其他项目 | deny | 隔离项目边界 |
| R11 | 网络访问未授权域名 | deny | 防止数据外泄 |

### 行为层（ask）

| 规则 | 触发条件 | 行为 | 原因 |
|------|----------|------|------|
| R04 | 删除文件 | ask | 防止误删 |
| R05 | `rm -rf` | ask | 危险操作确认 |

### 行为层（warn）

| 规则 | 触发条件 | 行为 | 原因 |
|------|----------|------|------|
| R12 | 修改配置文件 | warn | 重要变更提醒 |
| R13 | 执行外部脚本 | warn | 安全风险提醒 |

---

## PWR 循环架构

### Plan Agent（只读）

**角色定义：**
- 权限：只读（Read / Grep / Glob）
- 模型：opus
- 职责：制定详细执行计划

**输出格式：**
```markdown
# 执行计划

## 任务概述
- 目标：
- 范围：
- 约束：

## 执行步骤
1. [步骤描述]
   - 工具：
   - 输入：
   - 风险级别：
   - 预期输出：
   - 回滚方案：

## 验收标准
- 完成定义：
- 测试要求：
```

---

### Work Agent（隔离）

**角色定义：**
- 权限：读写（Read / Write / Edit / Bash）
- 模型：sonnet
- 职责：隔离执行计划

**工作流程：**
1. 接收 Plan Agent 的计划
2. 检查防护规则 R01-R13
3. 高风险操作预确认
4. 执行并记录审计日志
5. 返回执行报告

**OpenClaw 实现：**
```json
{
  "runtime": "subagent",
  "context": "isolated",
  "task": "执行计划..."
}
```

---

### Review Agent（只读）

**角色定义：**
- 权限：只读（Read / Grep / Glob / Bash for tests）
- 模型：opus
- 职责：审查执行结果

**输出格式：**
```markdown
# 审查报告

## 任务信息
- 任务：
- 执行时间：
- 状态：

## 代码审查
- 代码质量：
- 安全性：
- 性能：

## 测试结果
- 单元测试：
- 集成测试：
- 覆盖率：

## 合规性检查
- 规则遵守：
- 审计日志：
- 安全验证：

## 结论
- [ ] 通过
- [ ] 需要修改
- [ ] 需要重新执行
```

---

## 审计系统设计

### 日志格式

```json
{
  "timestamp": "ISO-8601",
  "event": "tool_use | agent_action",
  "tool": "Read | Write | Edit | Bash",
  "input": "操作输入",
  "result": "allowed | denied | asked | warned",
  "reason": "规则编号和描述"
}
```

### 日志存储

- 格式：JSONL（每行一个 JSON）
- 目录：`audit/logs/YYYY-MM-DD.jsonl`
- 保留：至少 30 天

### 审计报告

**每日报告：**
- 总操作数
- 拒绝操作详情
- 警告操作详情
- 合规性评分

**每周报告：**
- 趋势分析
- 异常检测
- 改进建议

---

## 验收标准

### 功能验收

- [ ] 三层防护模型正常工作
- [ ] MDM 验证脚本全部通过
- [ ] 防护规则测试全部通过
- [ ] 审计日志正常记录
- [ ] 审计报告正常生成
- [ ] PWR 循环可以完整执行

### 测试验收

- MDM 验证：X/X 通过
- 防护规则测试：X/X 通过
- 审计日志测试：通过
- PWR 循环测试：通过

---

## 实施路线图

```
Day 1-2:   架构设计
Day 3-4:   MDM 强制策略
Day 5-6:   审计 Hook
Day 7-8:   防护规则
Day 9-10:  PWR 循环
```

---

## 注意事项

1. **先检测后实施** - 确认当前项目级别再开始
2. **分层实施** - 按顺序完成每个阶段
3. **充分测试** - 每个阶段完成后运行验证
4. **记录审计** - 所有操作记录到审计日志
5. **用户确认** - 高风险操作必须用户确认

---

## 参考文档

- OpenClaw 文档：https://docs.openclaw.ai
- Harness Engineering 教程：`harness-engineering-完整教程.md`
- GitHub 仓库：https://github.com/quick123-666/harness-builder-skill
