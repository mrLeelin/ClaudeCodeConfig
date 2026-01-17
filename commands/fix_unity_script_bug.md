---
name: fix_unity_script_bug
description: Unity 脚本 Bug 修复助手。使用 Unity MCP 诊断编译错误和 Console 日志，定位并修复脚本问题。
---

# Unity Script Bug 修复 Skill

## 用法

```
/fix_unity_script_bug
```

## 执行流程

### 第一步：检查编译错误

使用 Unity MCP 工具检查编译错误：
```
mcp__coplay-mcp__check_compile_errors
```

### 第二步：检查 Console 输出

获取 Unity Editor Console 日志：
```
mcp__coplay-mcp__get_unity_logs
```

参数：
- `show_errors`: true（显示错误）
- `show_warnings`: true（显示警告）
- `show_stack_traces`: true（显示堆栈跟踪）
- `limit`: 100（限制条数）

### 第三步：分析问题

1. **定位错误位置**：
   - 提取文件名和行号
   - 使用 Read 工具读取错误代码
   - 使用 Grep 工具搜索相关代码

2. **分析错误原因**：
   - 空引用异常
   - 类型转换错误
   - 命名空间缺失
   - API 使用错误
   - 逻辑错误

### 第四步：提供修复方案

1. 列出修复计划
2. 说明每个步骤的作用
3. 等待用户确认
4. 执行修复

### 第五步：记录错误

将问题和解决方案记录到 `ReportError` 文件夹：
- 路径：`工程Claude.md同目录下的ReportError文件夹`
- 格式：Markdown 文件
- 命名：`错误描述_日期.md`
- 内容：错误信息、原因分析、解决方案

## 常见错误类型

### 编译错误

| 错误类型 | 常见原因 | 修复方法 |
|---------|---------|---------|
| CS0246 | 类型或命名空间不存在 | 添加 using 引用或检查拼写 |
| CS1061 | 方法/属性不存在 | 检查类型定义或使用反射 |
| CS0122 | 成员不可访问 | 修改访问修饰符 |
| CS0019 | 运算符无法应用于该类型 | 检查类型转换或重载运算符 |
| CS0263 | 部分声明不一致 | 检查 partial 类定义 |

### 运行时错误

| 错误类型 | 常见原因 | 修复方法 |
|---------|---------|---------|
| NullReferenceException | 对象为 null | 添加空引用检查 |
| MissingReferenceException | Unity 对象已销毁 | 检查对象是否存在 |
| MissingComponentException | 组件缺失 | 使用 GetComponent 或 AddComponent |
| IndexOutOfRangeException | 数组索引越界 | 检查数组边界 |

## 修复示例

### 示例 1：空引用异常

**错误信息**：
```
NullReferenceException: Object reference not set to an instance of an object
PlayerController.cs:45
```

**修复步骤**：
1. 读取 PlayerController.cs 第 45 行
2. 添加空引用检查：
   ```csharp
   if (target != null)
   {
       target.Damage();
   }
   ```

### 示例 2：编译错误

**错误信息**：
```
Assets/Scripts/Player.cs(23,17): error CS0246: The type or namespace name 'HealthComponent' could not be found
```

**修复步骤**：
1. 检查命名空间引用
2. 添加 using：
   ```csharp
   using GameComponents;
   ```
3. 或检查类名拼写是否正确

## 注意事项

1. **修改前备份**：重大修改前先创建 Git 分支
2. **测试验证**：修复后运行测试确认问题已解决
3. **代码规范**：修复时遵循项目编码规范
4. **错误记录**：记录到 ReportError 文件夹，避免重复问题
5. **不使用空 Unity 事件方法**：移除空的 Update、FixedUpdate 等

## 相关工具

- Unity MCP 工具集
- Git 版本控制
- Unity Profiler（性能问题）
- Unity Test Runner（单元测试）
