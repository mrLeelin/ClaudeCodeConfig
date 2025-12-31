# 手机游戏发热优化策略

## 目录
1. [发热基础知识](#发热基础知识)
2. [CPU 发热诊断和优化](#cpu-发热诊断和优化)
3. [GPU 发热诊断和优化](#gpu-发热诊断和优化)
4. [热管理和节流应对](#热管理和节流应对)
5. [不同芯片平台优化](#不同芯片平台优化)
6. [发热优化检查清单](#发热优化检查清单)

---

## 发热基础知识

### 手机发热来源
```
设备发热 = CPU 功耗 + GPU 功耗 + 其他（充电、环境等）
```

### 发热的后果
| 温度范围 | 现象 | 影响 |
|---------|------|------|
| 25-35°C | 正常 | 无影响 |
| 35-40°C | 温热 | 用户感觉烫手 |
| 40-45°C | 烫手 | 可能触发热节流 |
| >45°C | 非常烫 | 强制降频、游戏卡顿 |

### 热节流（Thermal Throttling）
当设备温度过高时：
- **CPU 节流**：降低 CPU 频率，性能下降 30-50%
- **GPU 节流**：降低 GPU 频率，帧率直接下降
- **强制关闭**：极端情况下游戏被系统杀死

---

## CPU 发热诊断和优化

### CPU 发热的常见原因

#### 原因 1：Update/FixedUpdate 中的高开销逻辑
**表现**：CPU Profiler 中脚本占比 > 30%

**优化方案**：
```csharp
// ❌ 差的做法：每帧计算路径
void Update() {
    path = pathfinding.CalculatePath(start, end);  // 高开销
}

// ✅ 好的做法：分散到多帧
private float nextPathTime = 0;
void Update() {
    if (Time.time >= nextPathTime) {
        path = pathfinding.CalculatePath(start, end);
        nextPathTime = Time.time + 0.5f;  // 每 0.5 秒计算一次
    }
}

// ✅ 更好的做法：使用协程
IEnumerator UpdatePathRoutine() {
    while (true) {
        path = pathfinding.CalculatePath(start, end);
        yield return new WaitForSeconds(0.5f);
    }
}
```

**预期效果**：CPU 占比下降 20-40%，设备温度下降 2-5°C

#### 原因 2：频繁的物理计算（Physics.FixedUpdate）
**表现**：CPU Profiler 中 Physics 占比 > 20%，FixedUpdate 耗时 > 5ms

**优化方案**：

```csharp
// 方案 1：降低物理 Tick 频率
// Edit > Project Settings > Physics
// - Default Solver Iterations: 6（默认）改为 4
// - Default Solver Velocity Iterations: 1（默认）改为 1
// - Gravity Scale: 考虑是否需要物理重力

// 方案 2：使用 Kinematic 而非 Dynamic
Rigidbody rb = GetComponent<Rigidbody>();
rb.isKinematic = true;  // 脚本控制位置，不参与物理
rb.velocity = moveDirection * speed;

// 方案 3：禁用不需要的物理碰撞
Physics.IgnoreLayerCollision(layer1, layer2);  // 在 Awake 中调用

// 方案 4：使用 Physics.autoSimulation = false（高级）
// 在主线程的特定时间手动调用 Physics.Simulate(Time.deltaTime)
```

**预期效果**：FixedUpdate 耗时下降 30-50%

#### 原因 3：Update 中频繁使用 GetComponent、Find 等查询
**表现**：Update 中看到大量 GetComponent/Find 调用

**优化方案**：
```csharp
// ❌ 差的做法
void Update() {
    Health health = GetComponent<Health>();
    health.TakeDamage(damage);
}

// ✅ 好的做法：Awake 中缓存
private Health health;
void Awake() {
    health = GetComponent<Health>();
}
void Update() {
    if (health != null) {
        health.TakeDamage(damage);
    }
}
```

**预期效果**：Update 耗时下降 10-30%

#### 原因 4：频繁的 GC 分配导致 GC 发热
**表现**：GC.Alloc > 100KB/frame，频繁 GC 卡顿

**优化方案**：
```csharp
// ❌ 避免每帧分配
void Update() {
    List<Enemy> nearbyEnemies = GetComponent<EnemyDetector>()
        .GetEnemiesInRange(10f);  // 每帧创建新 List
}

// ✅ 使用对象池或预分配
private List<Enemy> nearbyEnemies = new List<Enemy>();
void Update() {
    GetComponent<EnemyDetector>().GetEnemiesInRange(10f, nearbyEnemies);
    // 传入列表，不创建新对象
}

// ❌ 避免 string 拼接
void Update() {
    string message = "Health: " + health + " / " + maxHealth;
}

// ✅ 使用 StringBuilder 或缓存
private StringBuilder sb = new StringBuilder();
void Update() {
    sb.Clear();
    sb.Append("Health: ").Append(health).Append(" / ").Append(maxHealth);
    text.text = sb.ToString();
}
```

**预期效果**：GC.Alloc 下降 50-80%，GC 卡顿消失

### CPU 发热优化优先级
1. **必做**：停止频繁 GC，使用对象池
2. **重要**：降低高开销逻辑的运行频率
3. **可选**：调整物理参数

---

## GPU 发热诊断和优化

### GPU 发热的常见原因

#### 原因 1：填充率过高（Overdraw）
**表现**：
- GPU Profiler 显示 Overdraw 数值 > 3-4
- 复杂场景（特效、透明物体多）GPU 占用高
- 火焰、粒子等特效场景特别烫

**优化方案**：

```csharp
// 方案 1：减少粒子数量和生命周期
ParticleSystem ps = GetComponent<ParticleSystem>();
ParticleSystem.MainModule main = ps.main;
main.maxParticles = 100;  // 减少最大粒子数
main.startLifetime = 0.5f;  // 减少粒子存活时间

// 方案 2：使用烘焙纹理代替动态计算
// 如果可能，将实时计算的特效烘焙成纹理序列

// 方案 3：在低端设备上禁用后处理
if (SystemInfo.graphicsMemorySize < 2048) {
    postProcessing.SetActive(false);
}

// 方案 4：UGUI 优化
// - 减少 Canvas 数量
// - 避免过度嵌套
// - 使用 Canvas Group 控制可见性而非 GameObject.SetActive
```

**预期效果**：GPU 占用下降 20-40%

#### 原因 2：Draw Call 过多或 Batch 失败
**表现**：
- Batches < 50%（GPU Profiler）
- Draw Call > 100（合批后）
- GPU 占用不是特别高，但比较热

**优化方案**：
```csharp
// 方案 1：合并材质（使用 Texture Atlas）
// 在 Shader 中使用 Texture2D 数组或 Atlas 纹理坐标

// 方案 2：使用 GPU Instance
// 在 Shader 中启用 GPU Instancing
// Shader "Custom/MyShader" {
//     Properties { ... }
//     SubShader {
//         Tags { "RenderType"="Opaque" }
//         Pass {
//             CGPROGRAM
//             #pragma multi_compile_instancing
//             ...
//         }
//     }
// }

// 方案 3：禁用不可见物体的渲染
// 使用 Frustum Culling、LOD 系统

// 方案 4：减少动态 Mesh 更新频率
meshFilter.mesh = updatedMesh;  // 只在必要时更新
```

**预期效果**：Draw Call 下降 30-50%，GPU 占用下降 15-25%

#### 原因 3：复杂 Shader 计算
**表现**：
- GPU Profiler 中 Shader 时间占比 > 60%
- 特定材质或 Shader 特别烫

**优化方案**：
```glsl
// ❌ 复杂的像素着色器
fixed4 frag(v2f i) : SV_Target {
    // 复杂的计算
    float4 normal = normalize(tex2D(_NormalMap, i.uv));
    float shadow = CalculateShadow(i.worldPos);
    float3 diffuse = CalculateDiffuse(normal, shadow);
    float3 specular = CalculateSpecular(normal, shadow);
    return fixed4(diffuse + specular, 1);
}

// ✅ 简化：在顶点着色器中计算更多
v2f vert(appdata v) {
    v2f o;
    // ... 将部分计算移到这里
    return o;
}

// ✅ 使用烘焙数据
// 用预计算的 Lightmap 代替实时光照计算
```

**预期效果**：GPU 占用下降 30-50%

### GPU 发热优化优先级
1. **必做**：减少特效和粒子数量
2. **重要**：优化 Draw Call 和 Batch
3. **可选**：简化 Shader 计算

---

## 热管理和节流应对

### 热管理策略

#### 策略 1：动态品质降级
```csharp
public class ThermalManager : MonoBehaviour {
    private float thermalThreshold = 0.85f;  // 设备热度阈值

    void Update() {
        // 获取设备热度（仅 Android）
        float thermalStatus = GetDeviceThermalStatus();

        if (thermalStatus > thermalThreshold) {
            // 降低画质
            QualitySettings.masterTextureLimit = 1;  // 降低纹理分辨率
            ParticleSystem[] particles = FindObjectsOfType<ParticleSystem>();
            foreach (var p in particles) {
                p.main.maxParticles = Mathf.Max(10, p.main.maxParticles / 2);
            }
        }
    }

    float GetDeviceThermalStatus() {
#if UNITY_ANDROID
        // 使用 Android 原生接口获取热度
        // 0 = 正常, 1 = 警告, 2 = 严重
        // 需要 Android 插件支持
#endif
        return 0;
    }
}
```

#### 策略 2：FPS 动态调整
```csharp
public class FrameRateManager : MonoBehaviour {
    private float lastTempCheckTime = 0;
    private float tempCheckInterval = 2f;

    void Update() {
        if (Time.time - lastTempCheckTime > tempCheckInterval) {
            EstimateDeviceTemperature();
            lastTempCheckTime = Time.time;
        }
    }

    void EstimateDeviceTemperature() {
        // 基于 CPU 和 GPU 占用估算温度
        float cpuLoad = GetCPULoad();
        float gpuLoad = GetGPULoad();
        float estimatedTemp = 25 + (cpuLoad + gpuLoad) * 20;

        if (estimatedTemp > 42) {
            // 降低帧率到 30fps
            Application.targetFrameRate = 30;
        } else if (estimatedTemp < 38) {
            // 恢复到 60fps
            Application.targetFrameRate = 60;
        }
    }

    float GetCPULoad() {
        // 可以通过 Profiler 数据估算
        return 0.5f;  // 示例
    }

    float GetGPULoad() {
        return 0.6f;  // 示例
    }
}
```

#### 策略 3：发热警告系统
```csharp
public class HeatWarningUI : MonoBehaviour {
    public GameObject warningPanel;

    void Update() {
        if (IsDeviceTooHot()) {
            warningPanel.SetActive(true);
            // 显示"设备过热"提示
            // 询问用户是否降低画质
        }
    }

    bool IsDeviceTooHot() {
        // 基于帧率稳定性、性能变化判断
        return false;  // 简化版本
    }
}
```

---

## 不同芯片平台优化

### 高通骁龙系列（Android 主流）

**特性**：
- CPU 频率：通常 1.8-3.2 GHz
- GPU：Adreno 系列，对填充率敏感
- 热管理：较为激进，容易触发节流

**优化建议**：
1. **严格控制填充率** - Overdraw < 2.5
2. **减少 Draw Call** - < 80（合批后）
3. **优化内存带宽** - 避免频繁大数据读取
4. **关闭不必要的特性** - 实时阴影、复杂反射等

### 麒麟系列（华为、荣耀等）

**特性**：
- CPU 频率：通常 2.0-3.0 GHz
- GPU：Mali 系列，对三角形面数敏感
- 热管理：相对温和

**优化建议**：
1. **控制三角形数量** - < 1M 三角形/帧
2. **使用 LOD 系统** - 远处模型简化
3. **优化顶点着色器** - Mali 对复杂顶点计算敏感
4. **减少 Overdraw** - 但不如高通那么敏感

### 苹果 A 系列（iOS）

**特性**：
- CPU 频率：3.0+ GHz，多核心优化好
- GPU：PowerVR，对 Tile-Based 优化
- 热管理：相对保守

**优化建议**：
1. **充分利用多核 CPU** - Job System
2. **避免 Alpha Blending** - 特别是 UI
3. **使用 Metal API** 特性 - MSAA、Tile Memory
4. **优化内存分配** - iOS 对内存更敏感

---

## 发热优化检查清单

### 诊断阶段
- [ ] 启用 CPU Profiler，录制 2-3 分钟数据
- [ ] 启用 GPU Profiler，观察 Draw Call 和 Overdraw
- [ ] 启用 Memory Profiler，观察 GC.Alloc 和堆内存
- [ ] 测试目标设备（至少低端、中端、高端各一个）
- [ ] 记录初始的 FPS、内存占用、设备温度

### CPU 发热优化
- [ ] 检查 Update 耗时是否 > 5ms
- [ ] 检查 FixedUpdate 耗时是否 > 3ms
- [ ] 检查是否有频繁的 GetComponent/Find 调用
- [ ] 检查是否有频繁的 GC.Alloc（> 50KB/frame）
- [ ] 使用对象池重用频繁创建的对象
- [ ] 将高开销逻辑分散到多帧
- [ ] 调整物理参数（Solver Iterations 等）

### GPU 发热优化
- [ ] 检查 Overdraw 是否 > 3
- [ ] 检查粒子数量是否过多（> 5000）
- [ ] 检查是否过度使用后处理效果
- [ ] 检查 UGUI Canvas 数量和嵌套深度
- [ ] 优化材质和 Shader（使用 Atlas、GPU Instancing）
- [ ] 启用 LOD 系统，减少远处几何体
- [ ] 禁用不必要的阴影和反射

### 整体发热管理
- [ ] 实施动态品质降级
- [ ] 实施动态帧率调整
- [ ] 添加设备过热提示
- [ ] 在低端设备上禁用高端特性
- [ ] 测试极限情况（连续游戏 1+ 小时）

### 验证阶段
- [ ] 低端设备：30fps 稳定，设备不烫
- [ ] 中端设备：60fps 稳定，设备温热但不烫
- [ ] 高端设备：60fps 稳定，设备温度正常
- [ ] CPU 占比 < 60%（留余量）
- [ ] GPU 占比 < 70%（留余量）
- [ ] GC.Alloc < 100KB/frame
- [ ] 堆内存占用稳定（不持续增长）

---

## 快速参考：常见发热场景的解决方案

| 场景 | 症状 | 主要原因 | 快速 Fix |
|------|------|---------|---------|
| 卡牌游戏滑动卡顿 | UI 流畅度差、卡顿 | UI 重建频繁 | Canvas 分层、缓存计算 |
| ARPG 怪物多场景 | FPS 从 60 降到 30 | Draw Call 过多 | 合并材质、LOD、粒子减少 |
| FPS 爆炸场景 | 帧率直接掉到个位数 | 粒子+Overdraw 叠加 | 限制粒子、简化特效 |
| 长时间游戏发热 | 20 分钟后明显烫手 | GC 压力 + CPU 占用 | 对象池、避免分配 |
| 低端机卡顿+热 | 30fps 目标都卡顿 | 没有品质差异 | 动态品质降级、禁用效果 |

