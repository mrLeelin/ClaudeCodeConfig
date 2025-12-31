---
name: unity-standards
description: Unity 游戏开发规范助手。包含架构模式、代码规范、注释规范、项目结构、性能优化等 Unity 开发最佳实践。当处理 Unity 项目、编写或修改 Unity C# 脚本、创建场景或预制体时自动应用此规范。
---

# Unity 开发规范 Skill

## 核心原则

所有 Unity 开发工作必须遵循以下规范，确保代码质量、可维护性和性能。

## 架构与代码结构

### 架构模式
- **遵循 MVC 或 MVP 架构模式**，明确分离数据层、逻辑层和表现层
- **单一职责原则**：每个类只负责一个明确的功能模块
- **业务逻辑与 Unity API 解耦**，提高代码可测试性
- **使用接口和抽象类**提高代码的可扩展性和可替换性
- **Manager 类**使用单例模式或依赖注入管理

### 代码复杂度控制
- **逻辑清晰简洁**：避免嵌套层级超过 3 层
- **方法长度**：单个方法控制在 50 行以内，复杂逻辑必须拆分成多个小方法
- **模块化组织**：相关功能的类放在同一命名空间和文件夹中

## C# 代码规范

### 命名规范
- **类名**：PascalCase（例如：`PlayerController`）
- **方法名**：PascalCase（例如：`InitializePlayer()`）
- **公共属性**：PascalCase（例如：`MaxHealth`）
- **私有字段**：camelCase 或 _camelCase（例如：`playerSpeed` 或 `_playerSpeed`）
- **常量**：UPPER_SNAKE_CASE（例如：`MAX_PLAYER_COUNT`）

### MonoBehaviour 脚本规范
- **必须包含生命周期方法的注释**说明其用途（Awake, Start, Update, FixedUpdate, LateUpdate 等）
- **避免在 Update 中执行高开销操作**，优先使用事件驱动或协程
- **使用 `[SerializeField]` 而不是 public 字段**暴露编辑器属性
- **协程必须添加空引用检查**，防止空对象调用导致崩溃

### 字段与属性
```csharp
// ✅ 推荐：使用 SerializeField 私有字段
[SerializeField] private float moveSpeed = 5f;

// ❌ 不推荐：使用 public 字段
public float moveSpeed = 5f;
```

## 注释规范

### XML 文档注释
- **所有公共类和方法必须添加 XML 文档注释**

```csharp
/// <summary>
/// 玩家控制器，负责处理玩家输入和移动逻辑
/// </summary>
public class PlayerController : MonoBehaviour
{
    /// <summary>
    /// 初始化玩家数据和组件引用
    /// </summary>
    public void InitializePlayer()
    {
        // 实现代码
    }
}
```

### 行内注释
- **复杂算法和业务逻辑**必须添加行内注释说明
- **关键变量声明时注释**其用途和取值范围
- **使用 TODO、FIXME、HACK 标记**时必须说明原因和计划
- **注释使用简体中文**，保持简洁明了
- **避免无意义注释**，代码应具有自解释性

```csharp
// ✅ 有意义的注释
// TODO: 优化路径查找算法，当前时间复杂度为 O(n²)
private List<Vector3> FindPath(Vector3 start, Vector3 end)

// ❌ 无意义的注释
// 这是一个方法
private void DoSomething()
```

## Unity 项目结构

### 文件夹组织
```
Assets/
├── Scenes/              # 所有场景文件
├── Scripts/             # 所有脚本文件
│   ├── UI/              # UI 相关脚本
│   ├── Gameplay/        # 游戏玩法脚本
│   ├── Managers/        # 管理器脚本
│   ├── Utils/           # 工具类脚本
│   └── Data/            # 数据类和 ScriptableObject
├── Prefabs/             # 预制体
├── Materials/           # 材质
├── Textures/            # 贴图
└── Resources/           # 运行时加载资源
```

### 文件管理规则
- **场景文件**必须保存在 `Assets/Scenes/` 目录
- **预制体修改后**必须应用到源预制体（Apply to Prefab）
- **材质和贴图**应按功能或场景分类存放
- **Scripts 按功能分类**，保持目录结构清晰

## 性能优化规范

### 对象管理
- **频繁实例化的对象使用对象池**（子弹、特效、敌人等）
- **避免在 Update/FixedUpdate 中使用 `GameObject.Find`** 和 `GetComponent`
- **组件引用缓存**：在 Awake 或 Start 中获取并缓存常用组件

```csharp
// ✅ 推荐：缓存组件引用
private Rigidbody rb;

void Awake()
{
    rb = GetComponent<Rigidbody>();
}

void Update()
{
    rb.velocity = Vector3.forward * speed;
}

// ❌ 不推荐：每帧重复获取组件
void Update()
{
    GetComponent<Rigidbody>().velocity = Vector3.forward * speed;
}
```

### 字符串和标签优化
- **使用 `CompareTag` 而不是 `tag == "TagName"`**
- **字符串拼接使用 `StringBuilder`**，避免在循环中创建新字符串

### 协程管理
- **合理使用协程**，避免内存泄漏
- **停止协程时使用 `StopCoroutine`**，传入协程引用

### UGUI 优化
- **减少 Canvas 重建**：分离静态和动态 UI 到不同 Canvas
- **合理使用 Canvas 分层**：避免全屏 Canvas 频繁重绘
- **使用 RaycastTarget**：禁用不需要响应点击的 UI 元素的 RaycastTarget

### 空方法检查
- **避免空的 Unity 事件方法**（空的 Update、FixedUpdate 等会产生不必要开销）
- **不使用的生命周期方法应删除**

### 对象禁用 vs 销毁
- **对象池化场景**：使用对象禁用（SetActive(false)）而非销毁
- **一次性对象**：使用 Destroy 销毁

### 批处理优化
- **合并材质**减少 Draw Call
- **使用 GPU Instancing** 渲染大量相同对象
- **合并网格**减少 Batch 数量

## 测试与调试规范

### 测试流程
- **每次修改后必须运行 Play Mode 测试**
- **检查 Console 中的警告和错误**，确保无编译错误
- **性能敏感代码使用 Profiler 分析**
- **修改脚本后确认没有编译错误**才能提交

### 调试最佳实践
- 使用 `Debug.Log` 输出关键信息，但生产环境需移除或使用条件编译
- 使用 `Debug.DrawRay` 和 `Debug.DrawLine` 可视化调试

## Unity 工具使用规范

### MCP 工具优先
- **优先使用 Unity MCP 工具**操作场景和游戏对象
- **修改场景前先保存当前场景**
- **使用 `get_unity_logs` 检查运行时错误**
- **大量修改前使用 `get_scene_view_screenshot` 记录初始状态**

### 版本控制
- **每次修改都要分步骤**，等待确认后才继续修改
- **记录错误到 ReportError 文件夹**，避免重复错误
- **提供代码对比和功能对比**两种 Diff

## 安全性规范

### 常见漏洞防范
- **避免命令注入**：不直接执行用户输入的命令
- **避免路径遍历**：验证文件路径合法性
- **序列化安全**：不序列化敏感数据到明文文件
- **网络通信**：使用加密传输敏感数据

## 应用场景

此 Skill 在以下场景自动应用：
- 创建新的 Unity C# 脚本
- 修改现有 Unity 代码
- 代码审查和重构
- 性能优化分析
- 项目结构调整
- 场景和预制体创建

## 检查清单

每次代码修改后自动检查：
- ✅ 是否遵循命名规范
- ✅ 是否添加必要的 XML 文档注释
- ✅ 是否缓存组件引用
- ✅ 是否避免在 Update 中执行高开销操作
- ✅ 是否使用 SerializeField 而不是 public 字段
- ✅ 是否添加协程空引用检查
- ✅ 是否符合单一职责原则
- ✅ 方法长度是否控制在 50 行以内
- ✅ 嵌套层级是否不超过 3 层
