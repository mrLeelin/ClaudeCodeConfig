- 回答全部使用简体中文
- 每次修改代码前钱不要改代码 先写计划 解释原因 我确认过之后才可以修改代码。
- 每次修改后要自动跑测试
- 每次修改完代码后要给出 diff 并且可以支持回退功能
- 每次必须使用 cto-parallel-orchestrator agent. 不需要我每次提醒（除非是单文件小修复）
## Unity 开发规范

### 架构与代码结构
- 遵循 MVC 或 MVP 架构模式，分离数据、逻辑和表现层
- 使用单一职责原则：每个类只负责一个功能
- 业务逻辑与 Unity API 解耦，便于单元测试
- 使用接口和抽象类提高代码可扩展性
- Manager 类使用单例模式或依赖注入
- 逻辑保持清晰简洁，避免嵌套超过3层
- 方法长度控制在50行以内，复杂逻辑拆分成小方法
- 相关功能的类放在同一命名空间和文件夹中

### 代码规范
- 使用 C# 命名约定：类名用 PascalCase，方法名用 PascalCase，私有字段用 camelCase 或 _camelCase
- MonoBehaviour 脚本必须包含必要的生命周期方法注释（Awake, Start, Update等）
- 避免在 Update 中进行高开销操作，优先使用事件驱动
- 使用序列化字段 [SerializeField] 而不是 public 字段
- 对所有协程添加空引用检查

### 注释规范
- 所有公共类和方法必须添加 XML 文档注释 (/// <summary>)
- 复杂算法和业务逻辑必须添加行内注释说明
- 关键变量声明时注释其用途和取值范围
- TODO、FIXME、HACK 等标记必须说明原因和计划
- 注释使用简体中文，保持简洁明了
- 避免无意义注释，代码应自解释

### Unity 项目结构
- 保持 Assets 文件夹结构清晰：Scripts/, Prefabs/, Materials/, Scenes/, Resources/
- Scripts 按功能分类：UI/, Gameplay/, Managers/, Utils/, Data/
- 场景文件必须保存在 Assets/Scenes/ 目录下
- 预制体修改后必须应用到源预制体
- 材质和贴图应分类存放

### 性能优化
- 对象池化：频繁实例化的对象使用对象池
- 避免在 Update/FixedUpdate 中使用 GameObject.Find 和 GetComponent
- 缓存组件引用：在 Awake/Start 中获取并缓存常用组件
- 使用 CompareTag 而不是 tag == "TagName"
- 字符串拼接使用 StringBuilder，避免在循环中创建新字符串
- 合理使用协程，避免内存泄漏，停止时使用 StopCoroutine
- UGUI 优化：减少 Canvas 重建，合理使用 Canvas 分层
- 避免空 Unity 事件方法（空的 Update、FixedUpdate 等）
- 使用对象禁用而非销毁来提高性能
- 批处理优化：合并材质和网格减少 Draw Call

### 测试与调试
- 每次修改后运行 Play Mode 测试
- 检查 Console 中的警告和错误
- 性能敏感代码使用 Profiler 分析
- 修改脚本后确认没有编译错误

### Unity 特定工具使用
- 优先使用 Unity MCP 工具操作场景和对象
- 修改场景前先保存当前场景
- 使用 get_unity_logs 检查运行时错误
- 大量修改前使用 get_scene_view_screenshot 记录初始状态
- Diff 对比为 代码对比和功能对比两个都要有
- 如果出现错误记录下来放到工程Claude.md同目录下的ReportError文件夹并且新建md文件 下次不要再犯
- 每次修改都要分步骤 等我确认之后才可以继续修改
- 每次给完建议会询问是否写入代码