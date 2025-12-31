# /review - 代码审查

对指定的代码文件进行详细的代码审查，基于开发规范检查代码质量、性能、安全性等。

## 用法

```
/review <file-path>
```

### 参数

- `<file-path>` - 要审查的文件路径（相对或绝对路径）
  - 示例：`/review Assets/Scripts/Player/PlayerController.cs`
  - 示例：`/review src/utils/helper.ts`

## 功能描述

自动对代码文件进行以下维度的审查：

### 1. **规范合规性检查**
   - 遵循 CLAUDE.md 开发规范
   - 命名约定（PascalCase、camelCase 等）
   - 代码结构和组织
   - 注释和文档完整性

### 2. **代码质量**
   - 单一职责原则
   - 代码复杂度
   - 重复代码检测
   - 可读性评分

### 3. **性能问题**
   - 潜在性能瓶颈
   - 内存泄漏风险
   - 不必要的计算
   - 缓存优化建议

### 4. **安全问题**
   - SQL 注入风险（如适用）
   - XSS 漏洞（前端代码）
   - 访问控制问题
   - 数据验证不足

### 5. **Unity 特定检查** (如适用)
   - MonoBehaviour 生命周期方法
   - 组件缓存和引用
   - Update/FixedUpdate 中的重操作
   - Coroutine 内存泄漏风险
   - Shader 优化

### 6. **最佳实践**
   - 模式匹配（设计模式）
   - 异常处理
   - 配置管理
   - 日志记录

## 输出示例

```
### Code Review for PlayerController.cs

#### 概览
- 文件大小: 245 行
- 复杂度: 中等
- 规范符合度: 85%

#### 发现的问题 (3 个)

1. ⚠️ 性能问题: Update 中使用了 GetComponent
   位置: 第 45 行
   建议: 在 Awake 中缓存组件引用
   严重程度: 高

2. ⚠️ 代码风格: 私有字段使用 public 而非 SerializeField
   位置: 第 12-18 行
   建议: 改用 [SerializeField] private
   严重程度: 中

3. ℹ️ 注释缺失: 公共方法缺少 XML 文档注释
   位置: 第 67-70 行
   建议: 添加 /// <summary> 注释
   严重程度: 低

#### 优势

- ✓ 清晰的方法名称
- ✓ 合理的类职责划分
- ✓ 正确使用协程

#### 改进建议

1. 添加 XML 文档注释到所有公共 API
2. 在 Awake 中缓存常用组件
3. 提取魔数到 const 字段
```

## 与其他功能的关系

- **与 `/optimize-file` 的区别：**
  - `/review` - 发现问题和分析
  - `/optimize-file` - 给出改进代码和修改建议

- **与 Git Commit 的配合：**
  - 审查后可由用户决定是否改进
  - 改进后自动提交到 Git

## 常见用法

### 审查单个文件
```
/review Assets/Scripts/Player/PlayerController.cs
```

### 审查多个文件（需要多次调用）
```
/review Assets/Scripts/Player/PlayerController.cs
/review Assets/Scripts/Enemy/EnemyAI.cs
```

### 在提交前审查
```
# 先审查要提交的代码
/review Assets/Scripts/NewFeature.cs

# 如果通过审查再改进和提交
/optimize-file Assets/Scripts/NewFeature.cs
```

## 备注

- 审查结果仅为参考建议，最终改进由开发者决定
- 遵循项目的 CLAUDE.md 规范进行审查
- 自动检测文件类型（C#、TypeScript、Python 等）并应用相应规范
- 对于 Unity 项目，自动应用 Unity 最佳实践
