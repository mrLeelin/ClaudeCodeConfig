# 手机游戏渲染优化技术

## 目录
1. [Draw Call 优化](#draw-call-优化)
2. [批处理和材质优化](#批处理和材质优化)
3. [填充率和 Overdraw 优化](#填充率和-overdraw-优化)
4. [Shader 优化](#shader-优化)
5. [粒子系统优化](#粒子系统优化)
6. [UGUI 优化](#ugui-优化)
7. [后处理优化](#后处理优化)
8. [场景优化](#场景优化)
9. [渲染优化检查清单](#渲染优化检查清单)

---

## Draw Call 优化

Draw Call 是 GPU 渲染一个模型所需的一次命令，每个 Draw Call 都有 CPU 和 GPU 的开销。目标是减少 Draw Call 数量，同时保持视觉效果。

### 什么是 Batch 和 Draw Call？

```
Draw Call = GPU 的一次绘制命令
Batch = Unity 合并后的 Draw Call（会自动合并相同材质的对象）

目标：
- 总 Draw Call < 100（合批后）
- 批次成功率 > 50%（Dynamic + Static Batch）
```

### 方案 1：静态批处理（Static Batching）

适用于**不动的**物体（建筑、地面、树木等）

```csharp
// 步骤 1：标记为 Static
// 在 Inspector 中，将 GameObject 的 Static 勾选框打开
// 或通过代码：
gameObject.isStatic = true;

// 步骤 2：Unity 会在构建时自动合并
// 或手动执行：
// Window > Rendering > Bake Static Batches

// 步骤 3：注意事项
// ❌ 不要在运行时改变标记为 Static 的物体的位置、旋转或缩放
// ✅ 确保这些物体使用相同的材质（或至少相同的纹理和 Shader）
```

**优势**：合并效果好，可以减少 80-90% 的 Draw Call
**劣势**：只适用于静态物体，占用更多内存

### 方案 2：动态批处理（Dynamic Batching）

适用于**会动的**、小的物体（敌人、NPC、小道具等）

```csharp
// Edit > Project Settings > Graphics > Player Settings

// 设置 Dynamic Batching：
// - 启用 Dynamic Batching：ON
// - 批处理阈值：保留默认（Unity 自动判断）

// 哪些物体会被动态合并：
// 1. 使用相同材质
// 2. 顶点数 < 900（或根据平台调整）
// 3. 没有 Lightmap
// 4. 没有不同的 Light Probe
// 5. 使用相同的着色器变体

// 优化 Tip：
// - 避免有太多顶点的 Mesh
// - 使用相同的材质
// - 避免过度使用 Light Probe
```

**优势**：自动处理动态物体，减少 20-40% 的 Draw Call
**劣势**：合并效果不如静态批处理，对 CPU 有一定开销

### 方案 3：GPU Instance（最高效）

最佳实践：使用 GPU Instance 替代动态批处理

```csharp
// 步骤 1：修改 Shader，启用 GPU Instancing
// Shader "Custom/MyShader" {
//     Properties { ... }
//     SubShader {
//         Tags { "RenderType" = "Opaque" }
//         Pass {
//             CGPROGRAM
//             #pragma vertex vert
//             #pragma fragment frag
//             #pragma multi_compile_instancing
//
//             struct appdata {
//                 float4 vertex : POSITION;
//                 UNITY_VERTEX_INPUT_INSTANCE_ID
//             };
//
//             struct v2f {
//                 float4 vertex : SV_POSITION;
//                 UNITY_VERTEX_INPUT_INSTANCE_ID
//             };
//
//             v2f vert (appdata v) {
//                 v2f o;
//                 UNITY_SETUP_INSTANCE_ID(v);
//                 UNITY_TRANSFER_INSTANCE_ID(v, o);
//                 o.vertex = UnityObjectToClipPos(v.vertex);
//                 return o;
//             }
//
//             fixed4 frag (v2f i) : SV_Target {
//                 UNITY_SETUP_INSTANCE_ID(i);
//                 return fixed4(1, 1, 1, 1);
//             }
//             ENDCG
//         }
//     }
// }

// 步骤 2：确保材质启用了 GPU Instancing
// 在 Inspector 中：Material > 勾选 Enable GPU Instancing

// 步骤 3：使用 Graphics.DrawMeshInstanced 或 DrawMeshInstancedIndirect
public class InstancedRenderer : MonoBehaviour {
    public Mesh mesh;
    public Material material;
    public int instanceCount = 100;

    private Matrix4x4[] matrices;
    private MaterialPropertyBlock propertyBlock;

    void Start() {
        // 预分配矩阵数组
        matrices = new Matrix4x4[instanceCount];
        propertyBlock = new MaterialPropertyBlock();

        for (int i = 0; i < instanceCount; i++) {
            matrices[i] = Matrix4x4.TRS(
                new Vector3(i % 10, 0, i / 10),
                Quaternion.identity,
                Vector3.one
            );
        }
    }

    void OnRenderObject() {
        // 一次 Draw Call 绘制所有实例
        Graphics.DrawMeshInstanced(mesh, 0, material, matrices, instanceCount);
    }
}
```

**优势**：最高效，可在一个 Draw Call 中绘制数百个相同物体
**劣势**：需要修改 Shader，物体必须完全相同（除了位置）

### 方案 4：纹理 Atlas（合并纹理）

将多个小纹理合并成一个大纹理，减少材质数量

```csharp
// 步骤 1：创建 Texture Atlas
// 使用工具：TexturePacker、Unity 自带的 Sprite Atlas 等

// 步骤 2：修改 UV 坐标指向 Atlas 中的对应区域
// 在 Shader 中：
uniform sampler2D _MainTex;
varying vec2 uv;

void main() {
    vec2 atlasUV = uv;  // 或者根据对象类型偏移
    gl_FragColor = texture2D(_MainTex, atlasUV);
}

// 步骤 3：确保所有相同的物体使用同一个 Atlas 纹理
```

**优势**：减少材质数量，提高批处理成功率
**劣势**：需要美术资源重新制作，管理复杂

---

## 批处理和材质优化

### 问题诊断

```
在 Profiler 中：
- 查看 "Batches" 的成功率
- 成功率 < 50% 说明材质利用率低
- "Batched Batches" < 实际 Batches 说明有很多无法合并的物体
```

### 优化策略

#### 策略 1：减少材质数量
```csharp
// ❌ 差的做法：每个物体不同的材质
MeshRenderer renderer = GetComponent<MeshRenderer>();
renderer.material = new Material(originalMaterial);  // 创建新材质实例
renderer.material.color = Color.red;  // 修改颜色

// ✅ 好的做法：使用 MaterialPropertyBlock
MeshRenderer renderer = GetComponent<MeshRenderer>();
MaterialPropertyBlock block = new MaterialPropertyBlock();
block.SetColor("_Color", Color.red);
renderer.SetPropertyBlock(block);
// 注意：这样不会创建新的材质实例，多个物体可以共用材质
```

#### 策略 2：预加载和缓存材质
```csharp
public class MaterialCache : MonoBehaviour {
    private static Dictionary<string, Material> materialCache = new();

    public static Material GetMaterial(string name) {
        if (!materialCache.ContainsKey(name)) {
            materialCache[name] = Resources.Load<Material>("Materials/" + name);
        }
        return materialCache[name];
    }
}

// 使用
MeshRenderer renderer = GetComponent<MeshRenderer>();
renderer.sharedMaterial = MaterialCache.GetMaterial("PlayerMaterial");
```

---

## 填充率和 Overdraw 优化

填充率 = 每秒渲染的像素数 / GPU 的最大像素填充速度

Overdraw 是指同一像素被多次渲染，浪费 GPU 性能。目标是 Overdraw < 2.5（手机）。

### 方案 1：减少透明物体和透明度
```csharp
// ❌ 差的做法：过度使用 Alpha Blending
Shader "Transparent" {
    Properties {
        _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader {
        Tags { "RenderType" = "Transparent" }
        Blend SrcAlpha OneMinusSrcAlpha
        Pass {
            // 复杂计算
        }
    }
}

// ✅ 优化方案 1：使用 Alpha Test（不透明或完全透明）
Shader "AlphaTest" {
    SubShader {
        Tags { "RenderType" = "AlphaTest" }
        Pass {
            CGPROGRAM
            fixed4 frag (v2f i) : SV_Target {
                fixed4 col = tex2D(_MainTex, i.uv);
                clip(col.a - 0.5);  // 完全透明或不透明
                return col;
            }
            ENDCG
        }
    }
}

// ✅ 优化方案 2：烘焙阴影和光照，减少透明的特效
// 用预渲染的纹理替代实时透明计算
```

### 方案 2：优化 UI 透明度
```csharp
// ❌ 差的做法：UI 元素的父容器有 Alpha < 1
CanvasGroup canvasGroup = GetComponent<CanvasGroup>();
canvasGroup.alpha = 0.5f;  // 这会导致整个容器下的所有子元素都被重新合成

// ✅ 好的做法：直接修改图像的 Alpha
Image image = GetComponent<Image>();
Color color = image.color;
color.a = 0.5f;
image.color = color;
```

### 方案 3：关闭后台的 UI Canvas
```csharp
public class UIManager : MonoBehaviour {
    public Canvas mainCanvas;
    public Canvas overlayCanvas;

    void ShowOverlay() {
        overlayCanvas.gameObject.SetActive(true);
        // 禁用主 Canvas 的渲染（如果完全被遮挡）
        mainCanvas.enabled = false;
    }

    void HideOverlay() {
        overlayCanvas.gameObject.SetActive(false);
        mainCanvas.enabled = true;
    }
}
```

### 方案 4：分离 UI Canvas
```csharp
// ❌ 差的做法：所有 UI 在同一个 Canvas
// Canvas
//   - Panel A (静态)
//   - Panel B (频繁更新)
//   - Button (交互)
// 只要 Button 变化，整个 Canvas 就会重建

// ✅ 好的做法：按更新频率分离
// Canvas - Static UI (Render Mode = Screen Space - Camera)
//   - Background
//   - Title
// Canvas - Dynamic UI (Render Mode = Screen Space - Camera)
//   - Health Bar
//   - Score
// Canvas - Input (Render Mode = Screen Space - Overlay)
//   - Buttons
```

---

## Shader 优化

### 手机 Shader 优化原则

1. **顶点着色器优于像素着色器** - 在手机上，顶点着色器比像素着色器快
2. **降低精度** - 使用 `lowp`、`mediump` 而不是 `highp`
3. **避免分支** - 条件语句（if/else）在 GPU 上很慢
4. **预计算** - 将可以离线计算的内容烘焙到纹理中

### 优化技术

```glsl
// ❌ 不好的做法：像素级别的复杂计算
uniform sampler2D _MainTex;
uniform sampler2D _NormalMap;
uniform sampler2D _HeightMap;
uniform vec3 _LightPos;

void frag(v2f i, out vec4 outColor : SV_Target) {
    // 三张纹理的采样 + 复杂计算
    vec4 albedo = texture2D(_MainTex, i.uv);
    vec3 normal = normalize(texture2D(_NormalMap, i.uv).rgb * 2.0 - 1.0);
    float height = texture2D(_HeightMap, i.uv).r;

    vec3 lightDir = normalize(_LightPos - i.worldPos);
    float diffuse = max(dot(normal, lightDir), 0.0);
    vec3 viewDir = normalize(_CameraPos - i.worldPos);
    vec3 halfDir = normalize(lightDir + viewDir);
    float specular = pow(max(dot(normal, halfDir), 0.0), 32.0);

    outColor = vec4(albedo.rgb * (diffuse + specular), 1.0);
}

// ✅ 优化版本：移到顶点着色器和降低精度
precision lowp float;
precision mediump vec4;
precision lowp sampler2D;

uniform sampler2D _MainTex;
uniform sampler2D _LightMap;  // 烘焙的光照贴图

v2f vert(appdata v) {
    v2f o;
    // 顶点计算保留在这里
    o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
    o.lightingUV = ComputeLightMapUV(v.uv1);
    return o;
}

void frag(v2f i, out mediump vec4 outColor : SV_Target) {
    // 简单的采样和乘法
    mediump vec4 albedo = texture2D(_MainTex, i.uv);
    mediump vec4 lighting = texture2D(_LightMap, i.lightingUV);
    outColor = albedo * lighting;
}
```

### 常见手机 Shader 模板

```glsl
// 简单的不透明 Shader
Shader "Mobile/SimpleOpaque" {
    Properties {
        _MainTex ("Albedo", 2D) = "white" {}
        _Color ("Color", Color) = (1, 1, 1, 1)
    }
    SubShader {
        Tags { "RenderType" = "Opaque" }
        Pass {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_instancing

            precision lowp float;
            precision mediump vec4;

            sampler2D _MainTex;
            mediump vec4 _Color;

            struct appdata {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct v2f {
                float4 vertex : SV_POSITION;
                float2 uv : TEXCOORD0;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            v2f vert (appdata v) {
                v2f o;
                UNITY_SETUP_INSTANCE_ID(v);
                UNITY_TRANSFER_INSTANCE_ID(v, o);
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target {
                UNITY_SETUP_INSTANCE_ID(i);
                mediump vec4 col = tex2D(_MainTex, i.uv) * _Color;
                return col;
            }
            ENDCG
        }
    }
}
```

---

## 粒子系统优化

粒子特效是造成 GPU 发热的常见原因。

### 优化策略

```csharp
public class OptimizedParticleSystem : MonoBehaviour {
    private ParticleSystem ps;

    void Awake() {
        ps = GetComponent<ParticleSystem>();
        OptimizeParticles();
    }

    void OptimizeParticles() {
        // 优化 1：限制粒子数量
        ParticleSystem.MainModule main = ps.main;
        main.maxParticles = 50;  // 从默认的 1000 减少到 50
        main.startLifetime = 0.5f;  // 减少生命周期

        // 优化 2：降低发射率
        ParticleSystem.EmissionModule emission = ps.emission;
        emission.rateOverTime = 10;  // 每秒 10 个粒子，而不是 100 个

        // 优化 3：简化渲染器
        ParticleSystemRenderer renderer = ps.GetComponent<ParticleSystemRenderer>();
        renderer.renderMode = ParticleSystemRenderMode.Billboard;  // 最快的模式
        renderer.material = new Material(Shader.Find("Particles/Standard Unlit"));  // 简单 Shader

        // 优化 4：禁用不必要的模块
        ParticleSystem.CollisionModule collision = ps.collision;
        collision.enabled = false;  // 碰撞计算很昂贵

        ParticleSystem.LightsModule lights = ps.lights;
        lights.enabled = false;  // 粒子点光很昂贵

        // 优化 5：在低端设备上禁用粒子
        if (SystemInfo.graphicsMemorySize < 2048) {
            ps.gameObject.SetActive(false);
        }
    }
}
```

### 粒子优化检查清单
- [ ] 最大粒子数 < 100（对于小特效）
- [ ] 发射率合理（10-20/秒）
- [ ] 生命周期 < 1 秒
- [ ] 禁用碰撞和灯光
- [ ] 使用简单的 Billboard 渲染
- [ ] 在低端设备上禁用或降低质量
- [ ] 对于大规模特效，使用预烘焙纹理序列

---

## UGUI 优化

UGUI 是手机游戏中的性能瓶颈，特别是在频繁更新的情况下。

### 优化策略

#### 策略 1：减少 Canvas 重建
```csharp
// Canvas 会在以下情况重建：
// 1. 任何子元素的 RectTransform 改变
// 2. 任何 Graphic 组件（Image、Text 等）改变
// 3. 任何子元素激活/禁用

// ❌ 差的做法：频繁修改 Text 内容
void Update() {
    scoreText.text = score.ToString();  // 每帧都会导致 Canvas 重建
}

// ✅ 好的做法：只在值改变时更新
private int lastScore = -1;
void Update() {
    if (score != lastScore) {
        scoreText.text = score.ToString();
        lastScore = score;
    }
}

// ✅ 更好的做法：缓存 Text 组件，使用 StringBuilder
private StringBuilder sb = new StringBuilder();
void UpdateScore() {
    sb.Clear();
    sb.Append("Score: ").Append(score);
    scoreText.text = sb.ToString();
}
```

#### 策略 2：分离 UI Canvas
```csharp
// ❌ 差的做法：所有 UI 在一个 Canvas
// Canvas (Master Canvas)
//   - Static UI (Title, Background)
//   - Dynamic UI (Score, Health)
//   - Input UI (Buttons)
//
// 结果：任何元素改变都会导致整个 Canvas 重建

// ✅ 好的做法：按更新频率分离
// Canvas - Static (updateInterval = 0)
//   - Background
//   - Title
// Canvas - Dynamic (updateInterval = 60, 60Hz 更新)
//   - Score
//   - Health Bar
// Canvas - Input (updateInterval = 0)
//   - Buttons
```

#### 策略 3：使用 CanvasGroup 控制可见性
```csharp
// ❌ 差的做法：激活/禁用 GameObject
void HidePanel(GameObject panel) {
    panel.SetActive(false);  // 导致 Canvas 重建
}

// ✅ 好的做法：使用 CanvasGroup
CanvasGroup canvasGroup = panel.GetComponent<CanvasGroup>();
void HidePanel(GameObject panel) {
    canvasGroup.alpha = 0;
    canvasGroup.blocksRaycasts = false;
    // 不会导致 Canvas 重建，只是视觉隐藏
}
```

#### 策略 4：优化 Text 和字体
```csharp
// ❌ 差的做法：使用系统字体或高分辨率字体
// 字体纹理很大，每次修改都要重新生成

// ✅ 好的做法：使用位图字体或优化的字体
// - TextMesh Pro（推荐）
// - 位图字体（更快）
// - 限制字体大小和字符集

TextMeshProUGUI text = GetComponent<TextMeshProUGUI>();
text.fontSize = 36;  // 使用 TextMesh Pro
text.SetText("Score: {0}", score);  // 使用模板避免字符串分配
```

#### 策略 5：优化 Image 和 Sprite
```csharp
// ❌ 差的做法：Sprite 尺寸与显示尺寸不匹配
// Sprite 1024x1024，但只显示 256x256
// 浪费填充率

// ✅ 好的做法：Sprite 尺寸匹配显示尺寸
// 或使用多张不同分辨率的 Sprite

// ❌ 避免动态修改 Image 的 sprite
Image image = GetComponent<Image>();
image.sprite = Resources.Load<Sprite>("NewSprite");  // 导致重新合成

// ✅ 如果需要频繁切换，预加载所有 Sprite
private Dictionary<string, Sprite> spriteCache = new();
void ChangeSprite(string spriteName) {
    image.sprite = spriteCache[spriteName];
}
```

---

## 后处理优化

后处理特效（Bloom、 Motion Blur、Color Grading 等）在手机上很昂贵。

### 优化策略

```csharp
public class PostProcessingManager : MonoBehaviour {
    public PostProcessLayer postProcessLayer;
    public Volume volume;

    void Start() {
        // 在低端设备上禁用后处理
        if (SystemInfo.graphicsMemorySize < 2048) {
            postProcessLayer.enabled = false;
        }

        // 或者根据帧率动态调整
        if (Screen.width * Screen.height > 1920 * 1080) {
            // 高分辨率设备，禁用昂贵的特效
            DisableExpensiveEffects();
        }
    }

    void DisableExpensiveEffects() {
        // 禁用昂贵的后处理
        // - Bloom（最昂贵）
        // - Ambient Occlusion
        // - Motion Blur
        // 保留廉价的
        // - Color Grading（廉价）
        // - Vignette（廉价）
    }
}
```

---

## 场景优化

### 优化策略

#### 策略 1：LOD（细节级别）系统
```csharp
public class LODOptimizer : MonoBehaviour {
    public LODGroup lodGroup;

    void Start() {
        // 自动配置 LOD
        LOD[] lods = new LOD[3];

        // LOD 0：高质量（摄像机距离 < 20m）
        lods[0] = new LOD(0.5f, new Renderer[] { highQualityRenderer });

        // LOD 1：中质量（20-50m）
        lods[1] = new LOD(0.25f, new Renderer[] { mediumQualityRenderer });

        // LOD 2：低质量（> 50m）
        lods[2] = new LOD(0.125f, new Renderer[] { lowQualityRenderer });

        lodGroup.SetLODs(lods);
        lodGroup.RecalculateBounds();
    }
}
```

#### 策略 2：遮挡剔除（Occlusion Culling）
```csharp
// 步骤 1：Window > Rendering > Occlusion Culling
// 步骤 2：在 Scene 中，标记静态对象为 "Occluder Static"
// 步骤 3：Bake 遮挡剔除数据
// 步骤 4：在摄像机中启用 Occlusion Culling

Camera camera = GetComponent<Camera>();
// Occlusion Culling 默认启用，如果需要禁用：
// camera.useOcclusionCulling = false;
```

#### 策略 3：视锥体剔除（Frustum Culling）
```csharp
// Unity 自动执行，但可以手动优化
public class ManualCulling : MonoBehaviour {
    private Camera camera;
    private Plane[] frustumPlanes;

    void Start() {
        camera = Camera.main;
    }

    void Update() {
        // 获取视锥体平面
        frustumPlanes = GeometryUtility.CalculateFrustumPlanes(camera);

        // 手动检查对象是否在视锥体内
        Bounds bounds = GetComponent<Collider>().bounds;
        if (GeometryUtility.TestPlanesAABB(frustumPlanes, bounds)) {
            // 物体在视锥体内，显示
            GetComponent<Renderer>().enabled = true;
        } else {
            // 物体不在视锥体内，隐藏
            GetComponent<Renderer>().enabled = false;
        }
    }
}
```

---

## 渲染优化检查清单

### Batch 和 Draw Call
- [ ] Static Batching 已启用
- [ ] Dynamic Batching 已启用
- [ ] Draw Call < 100（合批后）
- [ ] Batch 成功率 > 50%
- [ ] 考虑使用 GPU Instance

### 材质优化
- [ ] 所有相同对象使用 `sharedMaterial`
- [ ] 使用 MaterialPropertyBlock 而不是创建新材质
- [ ] 材质数量最少化
- [ ] 考虑使用 Texture Atlas

### 填充率和 Overdraw
- [ ] Overdraw < 2.5
- [ ] 透明物体数量最少化
- [ ] UI Canvas 分层
- [ ] 后台隐藏的 Canvas 被禁用

### Shader 优化
- [ ] 使用 `lowp` 和 `mediump` 精度
- [ ] 避免复杂的像素着色器计算
- [ ] 避免条件分支
- [ ] 启用 GPU Instancing

### 粒子系统
- [ ] 最大粒子数 < 100
- [ ] 禁用碰撞和灯光
- [ ] 发射率合理
- [ ] 在低端设备上禁用或降低质量

### UGUI
- [ ] Canvas 按更新频率分离
- [ ] 使用 CanvasGroup 控制可见性
- [ ] 只在值改变时更新 Text
- [ ] 使用 TextMesh Pro
- [ ] Sprite 尺寸匹配显示尺寸

### 场景优化
- [ ] LOD 系统已配置
- [ ] Occlusion Culling 已启用
- [ ] Static Batching 标记正确
- [ ] 不可见对象被禁用

