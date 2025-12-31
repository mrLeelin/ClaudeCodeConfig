# Profiler 快速诊断指南

## 目录
1. [Profiler 基础](#profiler-基础)
2. [CPU Profiler 诊断](#cpu-profiler-诊断)
3. [GPU Profiler 诊断](#gpu-profiler-诊断)
4. [Memory Profiler 诊断](#memory-profiler-诊断)
5. [快速诊断流程](#快速诊断流程)
6. [常见问题速查](#常见问题速查)

---

## Profiler 基础

### 如何打开 Profiler

```
Window > Analysis > Profiler
或使用快捷键：Ctrl+7（Windows）/ Cmd+7（Mac）
```

### Profiler 的三种模式

1. **Editor 模式**
   - 在 Unity Editor 中运行游戏
   - 有额外的 Editor 开销，数据不准确
   - **适用于**：快速诊断、定位问题方向
   - **不适用于**：精确的性能数据

2. **Player 模式（开发构建）**
   - 构建 Development Build 并在设备上运行
   - 较为准确的数据，有性能采集开销
   - **适用于**：生产环境数据
   - **需要**：设备和 PC 连接，或远程连接

3. **Profiler Package（分析包）**
   - 最新推荐方式
   - Window > Analysis > Profiler (Advanced)
   - 数据最准确，性能开销最低

### Profiler 的关键概念

```
Frame Time = 这一帧的总时间（ms）
通常目标：
- 30fps：33.3ms/frame
- 60fps：16.7ms/frame

Frame 由多个部分组成：
- CPU 时间：脚本、物理、渲染命令提交等
- GPU 时间：实际渲染
- 其他：内存分配、垃圾回收等
```

---

## CPU Profiler 诊断

### 打开 CPU Profiler

```
Profiler > CPU
或在左上角选择 "CPU"
```

### 关键指标解读

#### 1. Timeline 视图
```
显示每一帧中各个系统的时间占比：

Frame Time = 16.7ms（目标 60fps）
├── Rendering: 8.5ms （51%）
├── Scripts: 5.2ms （31%）
├── Physics: 1.5ms （9%）
└── Others: 1.5ms （9%）

分析方法：
- 如果 Rendering > 10ms，GPU 可能是瓶颈
- 如果 Scripts > 8ms（60fps），脚本开销太高
- 如果 Physics > 3ms（60fps），物理计算过多
```

#### 2. Hierarchical 视图（最重要）
```
显示每个函数/系统的时间占用：

Sample          | GC.Alloc | Time
────────────────┼──────────┼──────────
Rendering       |     0 B  | 8.5 ms
│ ScriptRunner  |   50 KB  | 2.3 ms
│ │ MyScript.Update |   30 KB | 1.8 ms
│ │ Enemy.Update |   20 KB | 0.5 ms
├── Physics     |     0 B  | 1.5 ms
└── ...

分析方法：
1. 找到 GC.Alloc > 0 的项，这会导致 GC
2. 找到 Time 最长的项，这是瓶颈
3. 点击展开，看是哪个函数调用
4. 记下具体的函数名和文件路径
```

#### 3. 常见的 CPU 热点

| 热点 | 症状 | 原因 |
|------|------|------|
| `ScriptRunner` 占比 > 30% | Scripts 耗时 > 10ms | Update 中高开销逻辑 |
| 单个 Update 占比 > 50% | 某个脚本特别卡 | 没有优化的脚本逻辑 |
| `Physics.FixedUpdate` > 3ms | 物理卡顿 | 物理计算过多 |
| 频繁出现同一函数 | 该函数频繁执行 | 高频率重复计算 |
| `GC.Alloc` 频繁出现 | 帧率波动 | 频繁内存分配 |

### CPU Profiler 快速诊断步骤

#### 步骤 1：识别瓶颈
```
1. 打开 CPU Profiler
2. 按 Frame Time 排序（找到最耗时的帧）
3. 在 Hierarchical 视图中查看时间分布
4. 记下前 3 个耗时最多的项
```

#### 步骤 2：定位具体函数
```
1. 双击耗时项，进入详细视图
2. 查看 "Self Time"（函数自身时间）vs "Total Time"（包括子函数）
3. 点击函数名，编辑器会跳转到源代码位置
```

#### 步骤 3：分析原因
```
常见原因：
- Update 中的循环或递归
- 频繁调用 GetComponent、Find
- 频繁的内存分配（List、String 等）
- 物理计算（Physics.OverlapSphere 等）
- UI 更新（Canvas.SendMessage 等）
```

### 常见 CPU 热点的快速判断

```
看到这些，说明问题可能是：

"BillboardGPUVertexCompute" > 1ms
  → 粒子系统太复杂，减少粒子

"Physics.FixedUpdate" > 3ms
  → 物理计算过多，降低物理 Tick

"PlayerInput.GetKey" > 0.5ms
  → Input 轮询过多，考虑事件驱动

"Canvas.SendMessage" > 1ms
  → UI 更新频繁，分离 Canvas

"GetComponent" 频繁出现
  → 没有缓存，在 Awake 时缓存
```

---

## GPU Profiler 诊断

### 打开 GPU Profiler

```
Profiler > GPU
或选择 "GPU" 标签

注意：GPU Profiler 需要在 Editor 中运行，
或在真机上使用 Frame Debugger
```

### 关键指标解读

#### 1. GPU Time
```
总 GPU 时间，应该 < 16.7ms（60fps）

GPU Time = 提交的所有 Draw Call 的渲染时间
         + 同步时间
         + 其他开销
```

#### 2. Batches（批处理）
```
Batches：合并后的批次数
Draw Calls：总的绘制命令数

示例：
Draw Calls: 150
Batches: 45
Saved by Batching: 105 (70% 成功率)

分析：
- 成功率 > 50% 是好的
- 成功率 < 30% 说明材质利用率低
- Dynamic Batching 通常成功率 > 80%
- Static Batching 通常成功率 > 90%
```

#### 3. Overdraw（过度绘制）
```
显示每个像素被重绘的平均次数

目标：< 2.5（手机）
警告：> 3 说明很多像素被多次绘制

可视化查看：
- Profiler > GPU > Show Overdraw
- 红色区域 = 高 Overdraw（>4 倍）
- 黄色区域 = 中等 Overdraw（2-3 倍）
- 绿色区域 = 低 Overdraw（1 倍）
```

#### 4. 详细的 Draw Call 列表
```
Profiler 会显示每个 Draw Call 的详情：

Draw Call | Shader | Vertices | Indices | Instances
───────────┼────────┼──────────┼─────────┼──────────
1 | StandardOpaque | 1000 | 1500 | 1
2 | StandardOpaque | 1000 | 1500 | 1 (Batched)
3 | UI_Image | 4 | 6 | 1
...

分析：
- (Batched) = 成功合并
- (not batched) = 未合并
- (Instanced) = 使用 GPU Instance
```

### GPU Profiler 快速诊断步骤

#### 步骤 1：查看整体指标
```
1. 打开 GPU Profiler
2. 查看 "GPU Time" - 应该 < 16.7ms
3. 查看 "Draw Calls" - 应该 < 100（合批后）
4. 查看 "Batches" 的成功率 - 应该 > 50%
```

#### 步骤 2：识别未合并的 Draw Call
```
在 Draw Call 列表中：
1. 找到标记为 "(not batched)" 的项
2. 检查为什么没有合并：
   - 不同的材质？→ 合并材质或使用 Atlas
   - 不同的 Shader？→ 使用相同 Shader 变体
   - 太复杂的几何体？→ 使用 GPU Instance
```

#### 步骤 3：检查 Overdraw
```
1. 启用 Show Overdraw 可视化
2. 查看红色区域（高 Overdraw）
3. 常见原因：
   - UI 元素重叠
   - 透明度粒子过多
   - 半透明物体叠加
4. 优化：减少透明物体、优化粒子
```

---

## Memory Profiler 诊断

### 打开 Memory Profiler

```
Window > Analysis > Memory
或通过 Package Manager 安装最新的 Memory Profiler

推荐安装高级版本：
Window > Analysis > Memory Profiler (Advanced)
```

### 关键指标解读

#### 1. GC.Alloc（垃圾回收内存分配）
```
关键指标：每帧 GC.Alloc 的大小

目标：
- < 50 KB/frame（最好）
- < 100 KB/frame（可以接受）
- > 100 KB/frame（需要优化）

过高的 GC.Alloc 会导致：
- 频繁的 GC（垃圾回收）
- GC 时的卡顿（最长可能 50-100ms）
- 设备发热（GC 是 CPU 密集操作）
```

#### 2. 堆内存占用
```
Total Allocated Memory：总的堆内存占用

目标：
- 低端设备（2GB 内存）：< 500 MB
- 中端设备（4-6GB 内存）：< 1 GB
- 高端设备（8GB+ 内存）：< 1.5 GB

保持稳定：
- 内存曲线不应该持续上升
- 如果持续上升，说明有内存泄漏
```

#### 3. 内存分布
```
Profiler 显示内存在各个部分的分布：

Memory Category | Size
────────────────┼──────────
Unity Engine | 150 MB
Assets | 400 MB
Managed | 200 MB
Graphics | 100 MB

分析：
- Assets 太大？→ 优化资源
- Managed 太大？→ 缓存对象、使用对象池
- Graphics 太大？→ 降低纹理分辨率
```

### Memory Profiler 快速诊断步骤

#### 步骤 1：识别 GC 压力
```
1. 打开 Memory Profiler
2. 查看 "GC.Alloc" 列
3. 记录下每帧的 GC.Alloc 总量
4. 如果 > 100 KB，需要优化
```

#### 步骤 2：定位 GC 来源
```
在 Profiler 中查看分配来源：

常见的 GC 来源：
- List.Add / Dictionary.Add：使用对象池
- string.Concat / StringBuilder：缓存字符串
- new Object[size]：预分配数组
- Linq 查询：避免在热路径
- GetComponent：缓存引用
```

#### 步骤 3：检查内存泄漏
```
方法 1：观察曲线
- 启动游戏，运行几分钟
- 如果内存曲线持续上升，有内存泄漏

方法 2：对比快照
- 在某个时间点取 Memory Snapshot
- 执行重复操作（如加载/卸载场景）
- 再取一个 Snapshot
- 对比两个快照中的增长
```

---

## 快速诊断流程

### 流程图

```
用户报告：游戏卡顿/发热
    ↓
第一步：数据收集
  □ 启用 CPU Profiler，运行 30-60 秒
  □ 启用 GPU Profiler，查看渲染数据
  □ 启用 Memory Profiler，查看内存
  □ 记录设备型号和测试条件
    ↓
第二步：快速诊断
  □ CPU 时间 > 20ms？→ CPU 是瓶颈
  □ GPU 时间 > 20ms？→ GPU 是瓶颈
  □ GC.Alloc > 100 KB？→ 内存压力
    ↓
第三步：定位具体问题
  ├─→ CPU 瓶颈：
  │     □ 找到耗时最长的函数
  │     □ 检查是否有频繁 GC
  │     □ 检查物理计算
  │
  ├─→ GPU 瓶颈：
  │     □ Draw Call 是否 > 100？
  │     □ Overdraw 是否 > 3？
  │     □ Batching 成功率是否 < 50%？
  │
  └─→ 内存问题：
        □ GC.Alloc 来源是什么？
        □ 是否有内存泄漏？
        □ 资源是否过大？
    ↓
第四步：制定优化方案
  □ 根据瓶颈类型选择优化策略
  □ 优先处理影响最大的问题
  □ 估算预期效果
    ↓
第五步：验证
  □ 实施优化
  □ 再次运行 Profiler
  □ 对比优化前后的数据
```

---

## 常见问题速查

### Q1：Profiler 数据不准确怎么办？

**症状**：Editor 中的 Profiler 数据看起来很好，但真机很卡

**原因**：
- Editor 和真机的 CPU/GPU 性能相差很大
- Editor 中有额外的开销（Inspector、Scene 更新等）
- 构建的游戏经过优化（编译器优化）

**解决**：
1. 在真机上测试（最准确）
2. 构建 Development Build，连接 Profiler
3. 或在 Player Settings 中禁用 "Optimize for target platform"

### Q2：GC.Alloc 频繁出现怎么办？

**常见原因和快速 Fix**：

| 原因 | 症状 | Fix |
|------|------|-----|
| List.Add | 列表增长 | 预分配容量：`new List(capacity)` |
| string 操作 | 文本更新 | 使用 StringBuilder 或缓存 |
| new Array | 临时数组 | 预分配和重用 |
| GetComponent | 频繁查询 | Awake 中缓存 |
| Linq | 查询数据 | 用 foreach 替代 |

### Q3：Draw Call 为什么无法合并？

**诊断流程**：
```
1. 在 GPU Profiler 中找到 "(not batched)" 的 Draw Call
2. 检查相邻的 Draw Call 的材质是否相同
   - 不同材质？→ 合并或使用 Texture Atlas
   - 相同材质？→ 可能顶点数过多或使用了 Light Probe
3. 考虑使用 GPU Instance
```

### Q4：Overdraw 过高怎么办？

**常见原因**：
1. UI 元素重叠太多 → 分离 Canvas 或优化 UI 层级
2. 粒子特效过多 → 减少最大粒子数和发射率
3. 透明度物体叠加 → 使用 Alpha Test 代替 Alpha Blend
4. 后处理特效 → 在低端设备上禁用

### Q5：如何快速对比优化前后的性能？

**方法**：
```
1. 在某个场景中运行 30 秒，记录：
   - 平均 Frame Time
   - 平均 GC.Alloc
   - 最坏 Frame Time（卡顿帧）

2. 实施优化

3. 再运行 30 秒，对比数据：
   - Frame Time 改善：(原时间 - 新时间) / 原时间 * 100%
   - GC.Alloc 改善
   - 卡顿帧数减少
```

### Q6：如何判断是否优化足够？

**性能目标检查清单**：

低端设备（2-3GB）：
- [ ] 30 fps 稳定（不低于 25 fps）
- [ ] GC.Alloc < 100 KB/frame
- [ ] GPU 时间 < 33ms
- [ ] 设备不烫

中端设备（4-6GB）：
- [ ] 60 fps 稳定（不低于 55 fps）
- [ ] GC.Alloc < 100 KB/frame
- [ ] GPU 时间 < 16ms
- [ ] 设备温热但不烫

高端设备（8GB+）：
- [ ] 60 fps 稳定
- [ ] GC.Alloc < 50 KB/frame
- [ ] GPU 时间 < 12ms
- [ ] 设备温度正常

---

## Profiler 数据采集最佳实践

### 采集环境

```
✅ 正确的做法：
- 在目标设备上测试（低端、中端、高端各一个）
- 关闭其他应用
- 保持设备在常温下
- 测试时长至少 30 秒
- 重复 3 次取平均值

❌ 错误的做法：
- 只在 Editor 中测试
- 长时间保持设备高温后立即测试
- 后台运行其他应用
- 测试时间太短（< 10 秒）
```

### 采集内容清单

采集 Profiler 数据时，应该记录：

```
□ 设备信息
  - 设备型号
  - Android 版本 / iOS 版本
  - RAM 大小
  - CPU 型号

□ 场景信息
  - 当前场景名称
  - 主要对象数量
  - 主要活动（战斗/菜单/加载等）

□ 性能数据
  - 平均 Frame Time（ms）
  - 最差 Frame Time（ms）
  - 平均 FPS
  - 最低 FPS
  - CPU Time
  - GPU Time
  - GC.Alloc
  - 堆内存占用

□ 热点信息
  - 前 3 个 CPU 热点
  - 前 3 个 Draw Call
  - GC 主要来源
```

