# /optimize-file - 文件优化

对指定文件进行详细分析和优化，生成改进建议和优化后的代码。

## 用法

```
/optimize-file <file-path>
```

### 参数

- `<file-path>` - 要优化的文件路径
  - 示例：`/optimize-file Assets/Scripts/Player/PlayerController.cs`
  - 示例：`/optimize-file src/components/Button.tsx`

## 功能描述

对文件进行全面优化分析，包括：

### 1. **性能优化**
   - 算法效率改进
   - 内存优化
   - 缓存策略
   - 循环优化
   - 字符串拼接优化（使用 StringBuilder）

### 2. **代码质量提升**
   - 消除代码重复
   - 简化复杂逻辑
   - 提取魔数到常量
   - 改进命名
   - 模块化拆分

### 3. **规范合规**
   - 统一命名风格
   - 添加缺失的注释
   - 修复代码格式
   - 遵循开发规范

### 4. **设计模式应用**
   - 识别适用的设计模式
   - 提议模式优化
   - 改进类结构

### 5. **Unity 特定优化** (如适用)
   - 组件缓存
   - 协程优化
   - 物理计算优化
   - UI 性能优化
   - Shader 优化建议

### 6. **错误处理和安全**
   - 添加异常处理
   - 数据验证
   - 边界检查

## 输出示例

```
### File Optimization Report: PlayerController.cs

#### 分析结果
- 原始大小: 245 行
- 优化后: 198 行 (减少 19%)
- 性能提升: 约 15-25%
- 可读性: 大幅提升

#### 优化项目清单

##### 1. 性能优化 (高优先级)

**问题 1: Update 中频繁调用 GetComponent**
```csharp
// 优化前
void Update() {
    Rigidbody rb = GetComponent<Rigidbody>();
    rb.velocity = moveDirection * speed;
}

// 优化后
private Rigidbody rb;

void Awake() {
    rb = GetComponent<Rigidbody>();
}

void Update() {
    rb.velocity = moveDirection * speed;
}
```
性能收益: 消除每帧反射开销，提升 20-30%

---

**问题 2: 字符串频繁拼接**
```csharp
// 优化前
string message = "";
for (int i = 0; i < items.Count; i++) {
    message += items[i].name + ", ";
}

// 优化后
StringBuilder sb = new StringBuilder();
foreach (var item in items) {
    sb.Append(item.name).Append(", ");
}
string message = sb.ToString();
```
性能收益: 减少 GC 分配，提升 50%+

---

##### 2. 代码质量优化 (中优先级)

**问题 3: 代码重复 - 移动逻辑重复 3 次**
```csharp
// 优化前 - 三处重复代码
void MoveForward() { position += forward * speed; }
void MoveBackward() { position -= forward * speed; }
void MoveRight() { position += right * speed; }

// 优化后 - 提取公共方法
void Move(Vector3 direction) {
    position += direction * speed;
}
```
代码减少: 6 行 → 1 行

---

**问题 4: 魔数硬编码**
```csharp
// 优化前
if (health < 10) { /* 受伤状态 */ }
if (speed > 5) { /* 超速 */ }

// 优化后
private const float LOW_HEALTH_THRESHOLD = 10f;
private const float MAX_SPEED = 5f;

if (health < LOW_HEALTH_THRESHOLD) { }
if (speed > MAX_SPEED) { }
```

---

##### 3. 规范合规 (低优先级)

**问题 5: 缺少 XML 文档注释**
```csharp
// 优化前
public void TakeDamage(int amount) { }

// 优化后
/// <summary>
/// 受到伤害，减少生命值
/// </summary>
/// <param name="amount">伤害数值</param>
public void TakeDamage(int amount) { }
```

---

#### 完整优化后的代码

[附加完整的优化代码文件]

#### 实施建议

**优先级顺序:**
1. 性能优化（高）- 立即实施
2. 代码质量（中）- 下次 Sprint
3. 规范合规（低）- 定期维护

**测试建议:**
- [ ] 单元测试验证功能不变
- [ ] Profiler 确认性能提升
- [ ] 代码审查（/review）验证优化质量

**预期收益:**
- 性能: 提升 15-25%
- 代码行数: 减少 19%
- 可维护性: 大幅提升
- 团队理解度: 提升 30%+
```

## 与其他功能的关系

- **与 `/review` 的区别：**
  - `/review` - 仅审查和发现问题
  - `/optimize-file` - 给出改进代码

- **与 `/optimize-project` 的关系：**
  - `/optimize-file` - 优化单个文件
  - `/optimize-project` - 整体项目优化规划

- **工作流程：**
  ```
  /review 发现问题
    ↓
  /optimize-file 生成改进代码
    ↓
  用户确认并接受改进
    ↓
  自动 Git 提交
  ```

## 常见用法

### 优化单个脚本
```
/optimize-file Assets/Scripts/Player/PlayerController.cs
```

### 优化 UI 脚本
```
/optimize-file Assets/Scripts/UI/MainMenuUI.cs
```

### 优化工具脚本
```
/optimize-file Assets/Editor/Tools/BuildHelper.cs
```

## 输出选项

- **完整报告** - 包含所有优化分析和代码
- **优化代码文件** - 可直接使用的改进代码
- **改进摘要** - 快速总结性能和代码质量收益
- **Diff 对比** - 新旧代码对照

## 备注

- 遵循项目的 CLAUDE.md 开发规范生成优化代码
- 对于 Unity 项目，遵循 Unity 最佳实践
- 生成的代码会保留原有的功能和接口
- 建议在优化后运行测试确保功能正确
- 所有改进都包含明确的注释说明原因
