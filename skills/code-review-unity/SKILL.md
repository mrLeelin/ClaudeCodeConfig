---
name: code-review-unity
description: Unity 代码审查助手。自动检查 Unity C# 代码是否符合开发规范，包括命名规范、注释完整性、性能问题、安全漏洞等。在代码修改后自动触发审查，生成详细的审查报告。
---

# Unity 代码审查 Skill

## 审查目标

自动化检查 Unity C# 代码质量，确保符合团队开发规范，发现潜在问题并提供修复建议。

## 审查范围

### 1. 命名规范检查

#### 类名检查
- ✅ 类名使用 PascalCase
- ✅ 类名具有描述性，清晰表达类的职责
- ❌ 检测不规范命名：myclass、player_controller

#### 方法名检查
- ✅ 方法名使用 PascalCase
- ✅ 方法名使用动词开头，清晰描述行为
- ❌ 检测不规范命名：getplayer、move_player

#### 字段和属性检查
- ✅ 私有字段使用 camelCase 或 _camelCase
- ✅ 公共属性使用 PascalCase
- ✅ 常量使用 UPPER_SNAKE_CASE
- ❌ 检测不规范命名：public 字段使用小写

### 2. 注释完整性检查

#### XML 文档注释
- ✅ 所有 public 类必须有 `/// <summary>` 注释
- ✅ 所有 public 方法必须有 `/// <summary>` 注释
- ✅ 复杂的 public 方法应包含 `/// <param>` 和 `/// <returns>`
- ❌ 缺少 XML 文档注释的 public 成员

#### 行内注释
- ✅ 复杂算法有清晰的逻辑说明
- ✅ 关键变量声明时说明用途和取值范围
- ✅ TODO/FIXME/HACK 标记说明了原因和计划
- ❌ 注释使用英文而非简体中文
- ❌ 存在无意义的注释（如 `// 这是一个变量`）

#### MonoBehaviour 生命周期注释
- ✅ Awake、Start、Update 等方法有注释说明用途
- ❌ 生命周期方法缺少注释

### 3. 性能问题检查

#### Update/FixedUpdate 性能
- ❌ **严重问题**：在 Update 中使用 `GameObject.Find`
- ❌ **严重问题**：在 Update 中使用 `GetComponent`（未缓存）
- ❌ **严重问题**：在 Update 中使用 `tag == "TagName"`（应使用 CompareTag）
- ❌ **严重问题**：在 Update 中进行字符串拼接或创建新对象
- ❌ 空的 Update/FixedUpdate/LateUpdate 方法（应删除）

#### 组件引用缓存
- ✅ 组件引用在 Awake 或 Start 中缓存
- ❌ 重复调用 GetComponent 未缓存结果

#### 对象池化
- ✅ 频繁实例化的对象（子弹、特效）使用对象池
- ❌ 在循环中使用 Instantiate 创建大量对象

#### 字符串处理
- ✅ 循环中的字符串拼接使用 StringBuilder
- ❌ 循环中使用 string + 运算符拼接

#### 协程管理
- ✅ 协程有空引用检查
- ✅ 停止协程时使用 StopCoroutine
- ❌ 协程可能导致内存泄漏

### 4. 代码结构检查

#### 单一职责原则
- ✅ 每个类只负责一个明确功能
- ❌ 类职责过多，应拆分

#### 方法长度
- ✅ 方法长度不超过 50 行
- ❌ 方法过长，应拆分为多个小方法

#### 嵌套深度
- ✅ 嵌套层级不超过 3 层
- ❌ 嵌套过深，影响可读性

#### 依赖关系
- ✅ 业务逻辑与 Unity API 解耦
- ✅ 使用接口和抽象类提高可扩展性
- ❌ 直接依赖具体实现，耦合度过高

### 5. 序列化和字段检查

#### SerializeField 使用
- ✅ 需要在编辑器中设置的字段使用 `[SerializeField] private`
- ❌ 使用 public 字段而不是 SerializeField

```csharp
// ✅ 推荐
[SerializeField] private float moveSpeed = 5f;

// ❌ 不推荐
public float moveSpeed = 5f;
```

### 6. 安全性检查

#### 常见安全漏洞
- ❌ **严重问题**：直接执行用户输入的命令（命令注入）
- ❌ **严重问题**：未验证的文件路径（路径遍历）
- ❌ 敏感数据以明文序列化
- ❌ 网络通信未加密传输敏感数据
- ❌ SQL 注入风险（如果使用数据库）

### 7. Unity 特定问题检查

#### 资源管理
- ✅ Resources.Load 的资源在不使用时及时卸载
- ✅ 异步加载资源使用协程或 async/await
- ❌ 资源泄漏风险

#### 场景和预制体
- ✅ 场景文件保存在 Assets/Scenes/
- ✅ 预制体修改后应用到源预制体
- ❌ 预制体嵌套层级过深

#### UI 优化
- ✅ 静态和动态 UI 分离到不同 Canvas
- ✅ 不需要响应点击的 UI 禁用 RaycastTarget
- ❌ Canvas 层级过深导致频繁重建

## 审查流程

### 自动触发场景
1. 代码修改完成后
2. Pull Request 提交前
3. 用户明确要求代码审查时

### 审查报告格式

```markdown
# Unity 代码审查报告

**审查时间**: 2025-12-29
**审查文件**: PlayerController.cs

## 审查结果总结
- ✅ 通过项: 15
- ⚠️ 警告项: 3
- ❌ 错误项: 2
- 🔴 严重问题: 1

## 详细问题列表

### 🔴 严重问题

#### 1. Update 中使用 GameObject.Find [PlayerController.cs:45]
**问题描述**: 在 Update 方法中调用 GameObject.Find，严重影响性能
**当前代码**:
```csharp
void Update()
{
    GameObject player = GameObject.Find("Player");
    player.transform.position += Vector3.forward;
}
```
**建议修复**:
```csharp
private GameObject player;

void Awake()
{
    player = GameObject.Find("Player");
}

void Update()
{
    player.transform.position += Vector3.forward;
}
```

### ❌ 错误项

#### 2. 缺少 XML 文档注释 [PlayerController.cs:12]
**问题描述**: public 类 PlayerController 缺少 XML 文档注释
**建议修复**:
```csharp
/// <summary>
/// 玩家控制器，负责处理玩家输入和移动逻辑
/// </summary>
public class PlayerController : MonoBehaviour
```

### ⚠️ 警告项

#### 3. 方法长度超过 50 行 [PlayerController.cs:78]
**问题描述**: InitializePlayer 方法长度为 68 行，建议拆分
**建议**: 将初始化逻辑拆分为多个职责明确的小方法

## 性能评分
- **整体评分**: 72/100
- **性能优化**: 60/100（存在严重性能问题）
- **代码规范**: 85/100
- **可维护性**: 70/100

## 修复优先级
1. 🔴 立即修复: Update 中的 GameObject.Find
2. ❌ 高优先级: 补充 XML 文档注释
3. ⚠️ 中优先级: 拆分过长方法

## 下一步建议
1. 先修复所有严重问题（🔴）
2. 修复错误项（❌）
3. 根据时间处理警告项（⚠️）
```

## 审查检查清单

每次审查必须检查以下项目：

- [ ] 类名、方法名、字段名符合命名规范
- [ ] public 类和方法有 XML 文档注释
- [ ] 复杂逻辑有行内注释说明
- [ ] MonoBehaviour 生命周期方法有注释
- [ ] Update 中无高开销操作
- [ ] 组件引用已缓存
- [ ] 使用 CompareTag 而不是 tag ==
- [ ] 频繁实例化的对象使用对象池
- [ ] 字符串拼接使用 StringBuilder
- [ ] 协程有空引用检查
- [ ] 使用 SerializeField 而不是 public 字段
- [ ] 方法长度不超过 50 行
- [ ] 嵌套层级不超过 3 层
- [ ] 无明显安全漏洞
- [ ] 无空的 Unity 事件方法
- [ ] 单一职责原则
- [ ] 业务逻辑与 Unity API 解耦

## 特殊场景处理

### 性能敏感代码
- 使用 Unity Profiler 验证性能
- 检查 GC Alloc 是否过高
- 检查 Draw Call 数量

### 第三方库集成
- 检查库的许可证兼容性
- 检查库的性能影响
- 确保库的版本稳定性

### 自动生成代码
- 如果是自动生成代码（如 Input System Wrapper），可跳过部分规范检查
- 但仍需检查性能和安全性

## 报告输出

审查完成后：
1. 生成 Markdown 格式的审查报告
2. 如果有错误或严重问题，询问是否立即修复
3. 记录审查结果到项目日志

## 自动修复

对于以下常见问题，可提供自动修复：
- 添加缺失的 XML 文档注释
- 将 public 字段改为 SerializeField private
- 将 tag == 改为 CompareTag
- 删除空的 Unity 事件方法
- 缓存 GetComponent 调用

## 应用时机

此 Skill 在以下场景自动应用：
- 代码修改完成后
- 用户明确请求代码审查
- Pull Request 创建前
- 每日代码质量检查
