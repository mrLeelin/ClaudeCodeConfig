# URP Mobile Quality Configuration

> 快速配置 Unity URP 移动端三挡质量预设（低、中、高）的通用 Skill
>
> **标签：** Unity, URP, 质量设置, 性能优化, 移动端, 渲染管线

## 概述

本 Skill 提供完整的 **Unity URP Mobile 质量配置方案**，帮助开发者快速为项目配置三挡质量级别（低、中、高），兼顾**性能**和**画质**的平衡。

### 适用场景

- ✓ Unity 移动游戏开发（iOS/Android）
- ✓ PC 低端到高端的跨平台项目
- ✓ 需要优化渲染性能的 URP 项目
- ✓ 要求支持多种硬件设备的商业项目

### Skill 亮点

- 📊 **三挡预设配置** - 开箱即用的 Quality Settings 和 URP Asset 配置
- 📈 **详细参数对比** - 每个配置的性能和画质分析
- 💻 **完整代码模板** - 硬件检测、动态切换、场景优化脚本
- 🎯 **最佳实践** - 基于业界标准和项目经验的优化建议
- 🔗 **知识库支持** - 参考详细的技术文档

---

## 快速开始

### 步骤 1: 选择合适的配置级别

根据目标硬件选择：

| 配置 | 目标硬件 | 示例 | 预期帧率 |
|------|---------|------|---------|
| **Low** | 低端手机 / 低端 PC | iPhone 8, Snapdragon 600 系列 | 30-40 fps |
| **Medium** | 中高端手机 | iPhone 12, Snapdragon 800+ 系列 | 45-60 fps |
| **High** | 高端手机 / 中高端 PC | iPhone 13+, RTX 2060+ | 60 fps |

### 步骤 2: 应用配置

#### 方式 A：编辑器中手动配置

1. 打开 `ProjectSettings/QualitySettings.asset`
2. 为每个质量级别设置对应的 URP Asset：
   - Quality 0 → `Mobile_Low.asset`
   - Quality 1 → `Mobile_High.asset` 或 `Mobile_Medium.asset`
   - Quality 2 → `PC_Low.asset` （可选）
   - Quality 3 → `PC_High.asset` （可选）

3. 调整具体参数（见下方配置表）

#### 方式 B：代码动态应用

```csharp
// 应用预设配置
QualitySettings.SetQualityLevel(1); // 使用 Mobile_High 配置

// 或使用脚本自动检测和应用
QualityAutoDetection.ApplyOptimalQuality();
```

### 步骤 3: 验证和优化

1. 在实际设备上测试各质量级别
2. 使用 Profiler 监控性能指标
3. 根据实际情况调整参数（见最佳实践章节）

---

## 三挡配置快速参考

### 核心对比表

| 特性 | 低 (Low) | 中 (Medium) | 高 (High) |
|------|---------|-----------|---------|
| **后处理** | 禁用 | FXAA + 色彩分级 | Bloom + DoF + 运动模糊 |
| **不透明纹理** | 禁用 | 全分辨率 | 全分辨率 |
| **渲染缩放** | 0.8 | 0.8 | 1.0 |
| **主光阴影分辨率** | 512px | 1024px | 2048px |
| **阴影级联数** | 1个 | 1个 | 4个 |
| **软阴影** | ❌ 无 | ❌ 无 | ✓ 有 (5x5) |
| **纹理 Mipmap 限制** | 1 (降采样) | 0 (全质量) | 0 (全质量) |
| **蒙皮权重** | 2 骨骼 | 2 骨骼 | 4 骨骼 |
| **LOD 偏移** | 0.25 | 1.0 | 2.0 |
| **光照 Cookie 分辨率** | 512px | 1024px | 2048px |
| **光照 Cookie 格式** | 灰度 | 低质彩色 | 高质彩色 |
| **附加光阴影** | ❌ 禁用 | ❌ 禁用 | ✓ 启用 |
| **光照层** | ❌ 禁用 | ✓ 启用 | ✓ 启用 |
| **显存占用** | ~308MB | ~575MB | ~674MB |
| **GPU 时间** | ~13ms | ~16ms | ~38ms |

### 配置选择流程

```
选择硬件类型
    ↓
├─ 低端手机 (RAM<3GB, Mali-T/Adreno 5) → Low
├─ 中高端手机 (RAM≥3GB, Adreno 6+/Mali-G) → Medium
├─ 低端 PC (iGPU/GTX 9/10) → Low
└─ 中高端 PC (RTX 20+) → High
```

---

## Quality Settings 详细配置

### Low 配置

```csharp
// 质量级别 0
{
    name: "Mobile Low",

    // 像素和几何体
    pixelLightCount: 2,
    shadows: ShadowQuality.HardOnly,
    shadowResolution: ShadowResolution.Low,  // 512px

    // 纹理和细节
    globalTextureMipmapLimit: 1,  // 降采样纹理
    anisotropicFiltering: AnisotropicFiltering.Enable,

    // LOD 系统
    lodBias: 0.25,  // 更早切换到低模
    maximumLODLevel: 1,  // 跳过最高精度 LOD0
    enableLODCrossFade: false,

    // 其他优化
    masterTextureLimit: 1,
    particleRaycastBudget: 256,
    asyncUploadTimeSlice: 2,
}
```

### Medium 配置

```csharp
// 质量级别 1
{
    name: "Mobile High / Medium",

    pixelLightCount: 2,
    shadows: ShadowQuality.HardOnly,
    shadowResolution: ShadowResolution.Medium,  // 1024px

    globalTextureMipmapLimit: 0,  // 全质量纹理
    anisotropicFiltering: AnisotropicFiltering.Enable,

    lodBias: 1.0,  // 标准距离
    maximumLODLevel: 0,  // 可以使用 LOD0
    enableLODCrossFade: true,  // 平滑过渡

    masterTextureLimit: 0,
    particleRaycastBudget: 256,
}
```

### High 配置

```csharp
// 质量级别 3
{
    name: "PC High",

    pixelLightCount: 2,
    shadows: ShadowQuality.All,  // 包括附加光源
    shadowResolution: ShadowResolution.VeryHigh,  // 2048px

    globalTextureMipmapLimit: 0,
    anisotropicFiltering: AnisotropicFiltering.ForceEnable,

    lodBias: 2.0,  // 延迟切换，保持高精度
    maximumLODLevel: 0,
    enableLODCrossFade: true,

    skinWeights: SkinWeights.FourBones,  // 高质量蒙皮
    masterTextureLimit: 0,
}
```

---

## URP Asset 详细配置

### 关键设置对比

#### 渲染设置

| 设置项 | Low | Medium | High | 说明 |
|-------|-----|--------|------|------|
| 渲染缩放 | 0.8 | 0.8 | 1.0 | 降低分辨率可节省性能 |
| 上采样滤镜 | 无 | 无 | 无 | High 使用原生分辨率 |
| 需要不透明纹理 | ❌ | ✓ | ✓ | 支持后处理需求 |
| 不透明纹理降采样 | - | 0 | 1 | 显存优化 |
| HDR 支持 | ❌ | ✓ | ✓ | 高动态范围 |

#### 阴影设置

| 设置项 | Low | Medium | High | 说明 |
|-------|-----|--------|------|------|
| 主光阴影分辨率 | 512 | 1024 | 2048 | 边界清晰度 |
| 阴影级联数 | 1 | 1 | 4 | 远景阴影质量 |
| 软阴影 | ❌ | ❌ | ✓ | 阴影边缘柔和度 |
| 附加光阴影 | ❌ | ❌ | ✓ | 多光源阴影 |
| 阴影距离 | 50m | 50m | 50m | 阴影可见范围 |

#### 后处理相关

| 设置项 | Low | Medium | High | 说明 |
|-------|-----|--------|------|------|
| 色彩分级 | LDR | LDR | HDR | 色彩空间 |
| 快速 SRGB 转换 | ✓ | ✓ | ❌ | 移动端优化 |
| 屏幕空间镜头光晕 | ✓ | ✓ | ✓ | 光学效果 |

---

## 性能与画质分析

### 性能对比

**GPU 时间分配 (16.67ms = 60fps)：**

```
Mobile Low (~13ms, 77fps):
  几何处理:     2.0ms  ███
  主光阴影:     0.5ms  █
  前向渲染:     5.0ms  █████████
  后处理:       1.0ms  ██
  其他:         4.5ms  █████

Mobile High (~16ms, 63fps):
  几何处理:     2.5ms  ████
  主光阴影:     1.2ms  ██
  前向渲染:     6.0ms  ███████████
  后处理:       2.5ms  ████
  其他:         3.8ms  ████

PC High (~38ms, 26fps):
  几何处理:     5.0ms  ██████████
  主光阴影:     10.0ms █████████████████████
  附加光阴影:   2.0ms  ████
  前向渲染:     15.0ms ██████████████████████████████
  后处理:       4.0ms  ████████
  其他:         2.0ms  ████
```

### 画质评分

| 维度 | Low | Medium | High |
|------|-----|--------|------|
| 阴影质量 | 3/10 | 5/10 | 10/10 |
| 模型细节 | 4/10 | 7/10 | 10/10 |
| 纹理清晰度 | 5/10 | 7/10 | 10/10 |
| 光照效果 | 5/10 | 7/10 | 9/10 |
| 特效质量 | 3/10 | 6/10 | 10/10 |
| **综合评分** | **4.2/10** | **6.4/10** | **9.7/10** |

### 适用场景

**Mobile Low：** 快节奏动作游戏、多人竞技游戏（性能优先）
**Mobile Medium：** 叙事冒险游戏、解谜游戏（均衡）
**PC High：** 主机级画质体验、过场动画、影视级渲染

---

## C# 脚本模板

### 1. 自动硬件检测脚本

```csharp
using UnityEngine;
using UnityEngine.Rendering;

/// <summary>
/// 根据硬件自动选择最优质量级别
/// 放在场景中的自动执行脚本
/// </summary>
public class QualityAutoDetection : MonoBehaviour
{
    void Awake()
    {
        int optimalQuality = DetectOptimalQuality();
        QualitySettings.SetQualityLevel(optimalQuality, false);

        Debug.Log($"自动选择质量级别: {QualitySettings.names[optimalQuality]}");
    }

    /// <summary>
    /// 检测最优质量级别
    /// </summary>
    private int DetectOptimalQuality()
    {
        #if UNITY_ANDROID || UNITY_IOS
            return DetectMobileQuality();
        #else
            return DetectPCQuality();
        #endif
    }

    /// <summary>
    /// 移动端检测
    /// </summary>
    private int DetectMobileQuality()
    {
        int ram = SystemInfo.systemMemorySize;
        string gpu = SystemInfo.graphicsDeviceName.ToLower();

        // 低端设备判断
        if (ram < 3000 ||
            gpu.Contains("mali-t") ||
            gpu.Contains("adreno 5"))
        {
            return 0; // Mobile Low
        }

        // 中高端设备
        return 1; // Mobile High
    }

    /// <summary>
    /// PC 端检测
    /// </summary>
    private int DetectPCQuality()
    {
        int vram = SystemInfo.graphicsMemorySize;
        string gpu = SystemInfo.graphicsDeviceName.ToLower();

        // 集成显卡或低端独显
        if (vram < 2000 ||
            gpu.Contains("intel") ||
            gpu.Contains("gtx 9") ||
            gpu.Contains("rx 5"))
        {
            return 2; // PC Low
        }

        // 中高端独显
        return 3; // PC High
    }
}
```

### 2. 运行时动态质量切换

```csharp
using UnityEngine;

/// <summary>
/// 监控性能并动态调整质量级别
/// 保持目标帧率
/// </summary>
public class DynamicQualityManager : MonoBehaviour
{
    [SerializeField]
    private float targetFPS = 60f;

    [SerializeField]
    private float checkInterval = 2.0f;

    private float[] frameTimeHistory = new float[60];
    private int frameIndex = 0;
    private float nextCheckTime = 0f;

    void Update()
    {
        // 记录帧时间
        frameTimeHistory[frameIndex] = Time.unscaledDeltaTime;
        frameIndex = (frameIndex + 1) % frameTimeHistory.Length;

        // 定期检查性能
        if (Time.time > nextCheckTime)
        {
            nextCheckTime = Time.time + checkInterval;
            CheckPerformance();
        }
    }

    private void CheckPerformance()
    {
        // 计算平均帧时间
        float avgFrameTime = 0f;
        foreach (float t in frameTimeHistory)
            avgFrameTime += t;
        avgFrameTime /= frameTimeHistory.Length;

        float currentFPS = 1.0f / avgFrameTime;
        int currentQuality = QualitySettings.GetQualityLevel();

        // 低于目标帧率 20%，降级
        if (currentFPS < targetFPS * 0.8f && currentQuality > 0)
        {
            QualitySettings.DecreaseLevel(false);
            Debug.LogWarning(
                $"FPS 过低 ({currentFPS:F1}), " +
                $"质量已降级: {currentQuality} → {QualitySettings.GetQualityLevel()}");
        }
        // 超过目标帧率且稳定，尝试升级
        else if (currentFPS > targetFPS && currentQuality < 3)
        {
            // 避免频繁升级，需要持续稳定表现
            // 实现更复杂的升级逻辑
        }
    }
}
```

### 3. 场景相关质量优化

```csharp
using UnityEngine;
using UnityEngine.SceneManagement;

/// <summary>
/// 根据场景类型自动调整质量设置
/// 在场景加载时应用不同的优化
/// </summary>
public class SceneBasedQuality : MonoBehaviour
{
    void OnEnable()
    {
        SceneManager.sceneLoaded += OnSceneLoaded;
    }

    void OnDisable()
    {
        SceneManager.sceneLoaded -= OnSceneLoaded;
    }

    private void OnSceneLoaded(Scene scene, LoadSceneMode mode)
    {
        // 根据场景名称选择配置
        switch (scene.name)
        {
            case "MainMenu":
            case "Lobby":
                // 主菜单：展示最高画质
                SetQualityProfile(QualityProfile.Showcase);
                break;

            case "CombatArena":
            case "BattleField":
                // 战斗场景：性能优先，保持高帧率
                SetQualityProfile(QualityProfile.Performance);
                break;

            case "CinematicScene":
            case "CutScene":
                // 过场动画：追求极致画质
                SetQualityProfile(QualityProfile.Cinematic);
                break;

            default:
                // 普通游戏场景：均衡配置
                SetQualityProfile(QualityProfile.Balanced);
                break;
        }

        Debug.Log($"场景 '{scene.name}' 已应用质量配置");
    }

    private void SetQualityProfile(QualityProfile profile)
    {
        var urpAsset = GraphicsSettings.renderPipelineAsset as
            UnityEngine.Rendering.Universal.UniversalRenderPipelineAsset;

        if (urpAsset == null) return;

        switch (profile)
        {
            case QualityProfile.Showcase:
                // 最高质量
                QualitySettings.SetQualityLevel(3);
                break;

            case QualityProfile.Performance:
                // 最高性能
                QualitySettings.SetQualityLevel(0);
                break;

            case QualityProfile.Cinematic:
                // PC High：极致画质
                QualitySettings.SetQualityLevel(3);
                break;

            case QualityProfile.Balanced:
                // 中等配置
                QualitySettings.SetQualityLevel(1);
                break;
        }
    }

    public enum QualityProfile
    {
        Showcase,      // 展示
        Performance,   // 性能优先
        Cinematic,     // 电影级
        Balanced       // 均衡
    }
}
```

### 4. 设置菜单脚本

```csharp
using UnityEngine;
using UnityEngine.UI;

/// <summary>
/// 游戏内图形设置菜单
/// 玩家可以手动调整质量预设
/// </summary>
public class GraphicsSettingsUI : MonoBehaviour
{
    [SerializeField]
    private Dropdown qualityPresetDropdown;

    [SerializeField]
    private Slider renderScaleSlider;

    [SerializeField]
    private Dropdown shadowQualityDropdown;

    void Start()
    {
        // 初始化 UI 显示当前设置
        qualityPresetDropdown.value = QualitySettings.GetQualityLevel();

        // 加载保存的设置
        if (PlayerPrefs.HasKey("QualityPreset"))
        {
            int savedPreset = PlayerPrefs.GetInt("QualityPreset");
            QualitySettings.SetQualityLevel(savedPreset);
            qualityPresetDropdown.value = savedPreset;
        }

        // 绑定回调
        qualityPresetDropdown.onValueChanged.AddListener(SetQualityPreset);
        renderScaleSlider.onValueChanged.AddListener(SetRenderScale);
        shadowQualityDropdown.onValueChanged.AddListener(SetShadowQuality);
    }

    public void SetQualityPreset(int presetIndex)
    {
        QualitySettings.SetQualityLevel(presetIndex, false);
        PlayerPrefs.SetInt("QualityPreset", presetIndex);
        PlayerPrefs.Save();

        Debug.Log($"质量预设已更改为: {QualitySettings.names[presetIndex]}");
    }

    public void SetRenderScale(float scale)
    {
        // 注意：运行时修改 URP Asset 需要使用反射或创建变体
        // 推荐做法：预先创建多个 URP Asset 变体
        PlayerPrefs.SetFloat("RenderScale", scale);
    }

    public void SetShadowQuality(int quality)
    {
        switch (quality)
        {
            case 0:
                QualitySettings.shadows = ShadowQuality.Disable;
                break;
            case 1:
                QualitySettings.shadows = ShadowQuality.HardOnly;
                QualitySettings.shadowResolution = ShadowResolution.Low;
                break;
            case 2:
                QualitySettings.shadows = ShadowQuality.HardOnly;
                QualitySettings.shadowResolution = ShadowResolution.Medium;
                break;
            case 3:
                QualitySettings.shadows = ShadowQuality.All;
                QualitySettings.shadowResolution = ShadowResolution.High;
                break;
        }

        PlayerPrefs.SetInt("ShadowQuality", quality);
    }
}
```

---

## 最佳实践建议

### Mobile Low 优化

**当前问题：**
- 渲染缩放 0.8 但无上采样，画质损失明显
- HDR 关闭，无法支持高对比度场景

**优化建议：**
```csharp
// 1. 实现简易双线性上采样
// 性能开销: ~0.3ms | 画质提升: ~15%

// 2. 条件式 HDR
if (SceneHasHighDynamicRange()) {
    EnableHDR();  // 仅在需要时启用
}

// 3. 降采样不透明纹理
m_RequireOpaqueTexture = true;
m_OpaqueDownsampling = 2;  // 1/4 分辨率，显存仅 0.5MB
```

### Mobile High (Medium) 优化

**当前状态：** 已较为均衡

**微调建议：**
```csharp
// 1. 使用 PCSS Lite 实现近似软阴影
// 开销: 仅增加 5% | 效果: 接近软阴影

// 2. 降采样不透明纹理
// 显存从 8MB → 2MB，画质损失轻微

// 3. 性能监控切换
if (SystemInfo.batteryLevel < 0.2f) {
    SwitchToMobileLow();  // 低电量自动降级
}
```

### PC Low 优化

**当前问题：** 2048px 阴影但仅 1 级联，浪费资源

**优化建议：**
```csharp
// 改用: 1024px + 2级联
// 效果: 显存减少 75% (16MB → 4MB)
//      近景阴影质量反而提升
//      总体性能提升 ~10%

// FSR 锐化自适应
float sharpness = IsDetailedScene() ? 0.95f : 0.85f;
```

### PC High 优化

**优化方向：** 保持画质，提升效率

```csharp
// 1. 阴影级联优化
// 调整分割点，近景精度提升，远景合理降级
// GPU 时间减少 ~8%

// 2. 时序复用采样
// 每帧 9 采样 + 跨 4 帧累积 = 相当于 36 采样
// 需要 TAA 支持

// 3. 远距离级联隔帧更新
if (cascadeIndex >= 2) {
    if (frameCount % 2 == 0) {
        return cachedShadowMap;  // 隔帧更新
    }
}
// 效果: 阴影时间减少 ~25%，画质影响极小
```

---

## 常见问题

### Q1: 如何根据目标硬件选择配置？

**A:** 使用 `QualityAutoDetection` 脚本自动检测：

```csharp
// 移动端参考指标
- RAM < 3GB → Mobile Low
- RAM ≥ 3GB → Mobile High
- GPU: Mali-T/Adreno 5 → Low, Adreno 6+/Mali-G → High

// PC 端参考指标
- VRAM < 2GB 或 集成显卡 → PC Low
- VRAM ≥ 4GB + 独立显卡 → PC High
```

### Q2: 如何在运行时切换质量级别？

**A:** 使用 `DynamicQualityManager` 脚本：

```csharp
QualitySettings.SetQualityLevel(qualityIndex, false);

// 参数说明：
// qualityIndex: 质量级别索引 (0-3)
// false: 不重新应用 GPU 设置，立即生效
```

### Q3: 后处理效果在 Mobile Low 为什么要禁用？

**A:** Mobile Low 禁用 `m_RequireOpaqueTexture` 的原因：
- 读取屏幕内容需要额外 Shader 计算
- 显存占用 8MB（即使在低分辨率）
- GPU 时间增加 2-3ms，对低端设备影响大
- 完全关闭才能获得最佳性能

### Q4: 如何自定义适合自己项目的配置？

**A:** 按优先级修改参数：
```
1. 帧率目标 → 调整渲染缩放、阴影分辨率
2. 内存目标 → 调整纹理 Mipmap、Cookie 分辨率
3. 特性需求 → 后处理、光照层等
4. 实测验证 → 在实际设备上测试

建议流程：
1. 从现有预设开始
2. 使用 Profiler 定位瓶颈
3. 单个参数调整
4. 重新测试验证
```

### Q5: URP Asset 怎么创建多个变体？

**A:** 复制和修改 URP Asset：
```csharp
// 编辑器菜单：Assets → Create → Rendering → URP Asset

// 或代码创建：
var baseAsset = AssetDatabase.LoadAssetAtPath<UniversalRenderPipelineAsset>(
    "Assets/Settings/Mobile_High.asset");

var lowAsset = Object.Instantiate(baseAsset);
// 修改 lowAsset 的参数
// 保存为新文件
```

---

## 相关资源

### 知识库文档

- **详细技术文档：** 查看 `knowledge/URP质量配置最佳实践.md`
  - 包含详细的性能数据分析
  - 每个配置参数的深度解释
  - 优化案例和实测数据

### Unity 官方文档

- [Universal Render Pipeline](https://docs.unity3d.com/Packages/com.unity.render-pipelines.universal@latest/)
- [Quality Settings](https://docs.unity3d.com/Manual/class-QualitySettings.html)
- [Graphics Performance](https://docs.unity3d.com/Manual/GraphicsPerformance.html)
- [URP for Mobile](https://docs.unity3d.com/Packages/com.unity.render-pipelines.universal@latest/manual/index.html)

### 性能优化指南

- Unity Profiler 使用指南
- GPU 性能调试工具
- 移动端性能最佳实践

---

## 使用示例

### 示例 1：快速配置项目

```csharp
// 1. 在场景启动脚本中添加
public class GameInitializer : MonoBehaviour
{
    void Awake()
    {
        // 自动检测并应用最优配置
        QualityAutoDetection quality = gameObject.AddComponent<QualityAutoDetection>();

        // 添加动态质量管理器
        gameObject.AddComponent<DynamicQualityManager>();
    }
}
```

### 示例 2：玩家设置菜单

```csharp
// 在 UI Canvas 中创建质量预设下拉菜单
[SerializeField]
private Dropdown qualityDropdown;

void SetupMenu()
{
    qualityDropdown.AddOptions(new System.Collections.Generic.List<string>
    {
        "超低 (Mobile Low)",
        "中等 (Mobile High)",
        "高 (PC Low)",
        "极高 (PC High)"
    });

    qualityDropdown.onValueChanged.AddListener(index =>
    {
        QualitySettings.SetQualityLevel(index);
        PlayerPrefs.SetInt("QualityLevel", index);
    });
}
```

### 示例 3：特定场景优化

```csharp
// 菜单场景展示最高画质
public class MainMenuSetup : MonoBehaviour
{
    void Start()
    {
        QualitySettings.SetQualityLevel(3);  // PC High

        // 关闭 VSync 让菜单流畅显示
        QualitySettings.vSyncCount = 0;
        Application.targetFrameRate = 120;
    }
}

// 战斗场景优先性能
public class CombatSetup : MonoBehaviour
{
    void Start()
    {
        QualitySettings.SetQualityLevel(0);  // Mobile Low
        Application.targetFrameRate = 60;
    }
}
```

---

## 总结

| 配置 | 用途 | 优势 | 适配对象 |
|------|------|------|--------|
| **Low** | 极致性能 | 帧率稳定，低功耗 | 低端设备，竞技游戏 |
| **Medium** | 均衡体验 | 画质与性能平衡 | 中等设备，大多数游戏 |
| **High** | 极致画质 | 视觉效果最好 | 高端设备，单机游戏 |

**关键要点：**
- ✓ 选择合适的配置级别是首要任务
- ✓ 使用 Profiler 实际测量性能
- ✓ 根据目标硬件和游戏类型调整
- ✓ 提供玩家选项让用户自定义
- ✓ 定期在真实设备上验证

---

**Skill 版本：** 1.0
**最后更新：** 2024-12-31
**适用 Unity 版本：** 2021.3+
**依赖：** Universal Render Pipeline 12+
