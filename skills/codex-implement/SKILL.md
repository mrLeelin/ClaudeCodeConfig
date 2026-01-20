# Codex Implement 代码实现工具

当需要使用 OpenAI Codex CLI 来编写代码、实现功能时，使用此 Skill 调用 Codex 进行代码生成。

## 使用场景

- 实现新功能或新模块
- 根据设计文档编写代码
- 批量创建多个相关文件
- 重构或优化现有代码

## 使用方法

### 1. 基本用法 - 实现功能

```powershell
codex exec --full-auto "你是一个专业的代码实现 Agent。

你的工作方式必须遵循以下原则：
1. 严格按照需求文档/设计方案进行实现
2. 代码必须符合项目现有的编码规范和架构风格
3. 每个文件的修改都要完整，不能有占位符或省略
4. 新建文件时要创建对应的目录结构
5. 修改现有文件时要保持原有代码的完整性
6. 所有代码必须可编译通过

你的输出结构：
【任务理解】
- 简述需要实现的功能

【实现计划】
- 列出需要新建/修改的文件
- 说明每个文件的作用

【代码实现】
- 按顺序创建/修改每个文件
- 提供完整的代码内容

【验证步骤】
- 如何验证实现是否正确

---

请实现以下功能：
<在此处填写需求描述、设计文档、代码规范等>" -o codex_implement.txt
```

### 2. 带项目上下文的实现

```powershell
codex exec --full-auto "你是一个专业的代码实现 Agent。

项目信息：
- 项目类型：Unity C# 项目
- 编码规范：UTF-8 无签名
- 命名规范：类名 PascalCase，私有字段 _camelCase
- 架构模式：MVC/MVP

你的工作方式：
1. 先阅读相关现有代码，理解项目结构和风格
2. 按照项目现有风格编写新代码
3. 确保与现有代码的兼容性
4. 添加必要的中文注释

---

请实现以下功能：
<需求描述>

参考文件：
<相关文件路径列表>" -o codex_implement.txt
```

### 3. 批量文件创建

```powershell
codex exec --full-auto "你是一个专业的代码实现 Agent。

任务：根据设计文档批量创建文件

要求：
1. 按照设计文档中的目录结构创建文件
2. 每个文件必须包含完整的代码
3. 文件之间的引用关系必须正确
4. 命名空间必须与目录结构对应

---

设计文档：
<粘贴设计文档内容>

请创建以下文件：
<文件列表>" -o codex_implement.txt
```

## 工作流程

```
┌─────────────────────────────────────────────────────────────┐
│  用户选择使用 Codex 编写代码                                 │
│                    ↓                                        │
│  Claude Code 调用 /codex-implement skill                    │
│                    ↓                                        │
│  准备详细的实现需求（设计文档、文件列表、代码规范）          │
│                    ↓                                        │
│  执行 codex exec --full-auto 命令                           │
│                    ↓                                        │
│  Codex CLI 生成代码，输出到 codex_implement.txt             │
│                    ↓                                        │
│  Claude Code 读取结果，应用到项目中                         │
│                    ↓                                        │
│  检查编译错误，必要时进行修复                               │
└─────────────────────────────────────────────────────────────┘
```

## 输出文件

- `codex_implement.txt` - Codex 生成的代码和实现说明
- 生成完成后，Claude Code 应读取此文件并将代码应用到项目中

## 完整示例

### 示例：实现技能链系统

```powershell
codex exec --full-auto "你是一个专业的 Unity C# 代码实现 Agent。

项目信息：
- 项目路径：E:\Project\Work\MagicCard\cardex\UnityProject
- 编码规范：UTF-8 无签名，4空格缩进
- 命名规范：类名 PascalCase，私有字段 _camelCase，常量 SCREAMING_SNAKE_CASE
- 注释语言：中文

任务：实现技能链系统（连击/反击）

需要创建的文件：
1. SkillChainType.cs - 枚举定义
2. SkillChainNode.cs - 节点结构体
3. SkillChainCoordinator.cs - 协调器
4. SkillChainManager.cs - 管理器

需要修改的文件：
1. SkillMountable.cs - 添加回调方法
2. SkillLeaderAttack.cs - 添加命中处理
3. BattleContext.cs - 注册管理器

设计要求：
- 根技能暂停时，子技能（连击/反击）串行执行
- 使用队列管理子技能
- 子技能结束后自动播放下一个
- 队列清空后恢复根技能

请生成完整的代码实现。" -o codex_implement.txt

# 查看生成结果
cat codex_implement.txt
```

## 注意事项

1. **提供充分上下文**：Codex 需要了解项目结构、编码规范、相关代码才能生成高质量代码
2. **明确文件路径**：指定每个文件的完整路径
3. **分批处理**：如果文件过多，建议分批生成
4. **验证编译**：生成后务必检查编译错误
5. **代码审查**：Claude Code 应审查 Codex 生成的代码质量

## 与 codex-debug 的区别

| 特性 | codex-implement | codex-debug |
|------|-----------------|-------------|
| 用途 | 编写新代码 | 分析问题 |
| 输出 | 完整代码文件 | 分析报告 |
| 模式 | --full-auto | 可选 |
| 触发条件 | 用户选择 | 修复失败2次后 |
