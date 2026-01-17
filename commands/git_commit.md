---
name: git-commit
description: Git 智能提交助手。自动分析代码变更，生成规范的提交信息。标题简洁明了，描述清晰无歧义。支持 feat/fix/refactor/perf/docs/style/test/chore 等类型前缀。
---

# Git 智能提交 Skill

## 用法

```
/git-commit
```

## 执行流程

### 第一步：分析变更

1. 执行 `git status` 查看变更文件
2. 执行 `git diff --staged` 查看已暂存变更
3. 执行 `git diff` 查看未暂存变更
4. 分析修改内容，理解变更意图

### 第二步：生成提交信息

格式：
```
<类型>: <简短描述>

<详细说明>

Co-Authored-By: Claude Opus 4.5 <noreply@anthropic.com>
```

### 第三步：用户确认

展示提交信息，询问用户是否同意或需要修改。

### 第四步：执行提交

用户确认后执行 `git add` 和 `git commit`，**不执行 git push**。

## 提交类型

| 类型 | 说明 | 示例 |
|------|------|------|
| `feat` | 新功能 | feat: 添加玩家双跳功能 |
| `fix` | 修复 Bug | fix: 修复角色穿墙问题 |
| `refactor` | 重构代码 | refactor: 重构状态机逻辑 |
| `perf` | 性能优化 | perf: 优化对象池内存分配 |
| `style` | 代码格式 | style: 统一缩进格式 |
| `docs` | 文档更新 | docs: 更新 API 注释 |
| `test` | 测试相关 | test: 添加单元测试 |
| `chore` | 构建/工具 | chore: 更新依赖版本 |

## 标题规范

- 使用中文描述
- 长度控制在 50 字符以内
- 动词开头：添加、修复、重构、优化、更新、移除
- 不使用句号结尾

### 好的示例
```
feat: 添加敌人巡逻AI
fix: 修复玩家血量显示错误
refactor: 重构武器系统架构
```

### 不好的示例
```
❌ 修改了一些代码
❌ update
❌ fix bug
```

## 注意事项

- 仅提交到本地，不推送远端
- 敏感文件（.env 等）会发出警告
- 支持选择性暂存文件
