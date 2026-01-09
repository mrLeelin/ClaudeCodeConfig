---
name: csharp-naming-translator
description: 中文到 C# 命名翻译助手。当用户需要将中文概念翻译为 C# 字段名、类名、属性名、方法名时自动激活。帮助开发者快速获得简洁、准确、符合 C# 命名规范的英文命名。
---

# 中文到 C# 命名翻译 Skill

## 核心功能

将中文概念翻译为符合 C# 命名规范的英文名称，确保命名简洁、准确、易懂。

## 命名规范

| 类型 | 规范 | 示例 |
|------|------|------|
| 类名 | PascalCase | `PlayerController`, `GameManager` |
| 方法名 | PascalCase | `Initialize()`, `GetPlayerData()` |
| 属性名 | PascalCase | `MaxHealth`, `CurrentLevel` |
| 公共字段 | PascalCase | `PlayerName` |
| 私有字段 | camelCase 或 _camelCase | `playerSpeed`, `_currentHp` |
| 常量 | UPPER_SNAKE_CASE | `MAX_PLAYER_COUNT` |
| 枚举 | PascalCase | `GameState`, `PlayerType` |
| 接口 | I + PascalCase | `IMovable`, `IDamageable` |

## 翻译原则

1. **简洁优先**：用最少的单词表达完整含义
2. **动词开头**：方法名以动词开头（Get, Set, Create, Update, Delete）
3. **名词为主**：类名、属性名使用名词或名词短语
4. **避免缩写**：除非是广泛认可的缩写（HP, ID, UI, AI）
5. **语义准确**：选择最贴切的英文单词
6. **一致性**：同一概念在项目中保持统一命名

## 常用词汇对照表

### 游戏核心

| 中文 | 英文 | 用法示例 |
|------|------|----------|
| 玩家 | Player | `PlayerController` |
| 敌人 | Enemy | `EnemySpawner` |
| 角色 | Character | `CharacterData` |
| 怪物 | Monster | `MonsterAI` |
| Boss | Boss | `BossHealth` |
| NPC | NPC | `NPCDialog` |
| 英雄 | Hero | `HeroStats` |

### 属性与状态

| 中文 | 英文 | 用法示例 |
|------|------|----------|
| 生命值 | Health / HP | `MaxHealth`, `CurrentHP` |
| 魔法值 | Mana / MP | `MaxMana`, `CurrentMP` |
| 攻击力 | Attack / ATK | `BaseAttack` |
| 防御力 | Defense / DEF | `TotalDefense` |
| 速度 | Speed | `MoveSpeed` |
| 等级 | Level | `CurrentLevel` |
| 经验值 | Experience / EXP | `TotalExp` |
| 金币 | Gold / Coin | `PlayerGold` |
| 体力 | Stamina | `MaxStamina` |
| 耐久度 | Durability | `ItemDurability` |

### 动作与行为

| 中文 | 英文 | 用法示例 |
|------|------|----------|
| 移动 | Move | `MoveToTarget()` |
| 攻击 | Attack | `PerformAttack()` |
| 跳跃 | Jump | `TryJump()` |
| 死亡 | Die / Death | `OnDeath()` |
| 重生 | Respawn | `RespawnPlayer()` |
| 拾取 | Pickup / Collect | `CollectItem()` |
| 使用 | Use | `UseItem()` |
| 装备 | Equip | `EquipWeapon()` |
| 卸下 | Unequip | `UnequipArmor()` |
| 升级 | LevelUp / Upgrade | `OnLevelUp()` |
| 保存 | Save | `SaveGame()` |
| 加载 | Load | `LoadGame()` |

### 系统与管理

| 中文 | 英文 | 用法示例 |
|------|------|----------|
| 管理器 | Manager | `GameManager` |
| 控制器 | Controller | `InputController` |
| 系统 | System | `CombatSystem` |
| 服务 | Service | `AudioService` |
| 处理器 | Handler | `EventHandler` |
| 工厂 | Factory | `EnemyFactory` |
| 池 | Pool | `ObjectPool` |
| 配置 | Config | `GameConfig` |
| 数据 | Data | `PlayerData` |
| 设置 | Settings | `AudioSettings` |

### UI 相关

| 中文 | 英文 | 用法示例 |
|------|------|----------|
| 界面 | UI / Panel | `MainMenuUI` |
| 按钮 | Button | `StartButton` |
| 文本 | Text | `ScoreText` |
| 图标 | Icon | `SkillIcon` |
| 弹窗 | Popup / Dialog | `ConfirmDialog` |
| 提示 | Tip / Tooltip | `ItemTooltip` |
| 进度条 | ProgressBar | `HealthBar` |
| 列表 | List | `ItemList` |
| 背包 | Inventory / Bag | `PlayerInventory` |
| 商店 | Shop | `ItemShop` |

### 状态与事件

| 中文 | 英文 | 用法示例 |
|------|------|----------|
| 开始 | Start / Begin | `OnGameStart()` |
| 结束 | End / Finish | `OnGameEnd()` |
| 暂停 | Pause | `PauseGame()` |
| 继续 | Resume | `ResumeGame()` |
| 激活 | Active / Enable | `SetActive()` |
| 禁用 | Disable | `DisableInput()` |
| 完成 | Complete | `OnTaskComplete()` |
| 失败 | Fail | `OnMissionFail()` |
| 触发 | Trigger | `TriggerEvent()` |
| 回调 | Callback | `OnCompleteCallback` |

## 翻译示例

### 类名翻译

| 中文 | C# 类名 |
|------|---------|
| 玩家控制器 | `PlayerController` |
| 游戏管理器 | `GameManager` |
| 背包系统 | `InventorySystem` |
| 战斗数据 | `CombatData` |
| 音效服务 | `AudioService` |
| 存档管理器 | `SaveManager` |
| 对象池 | `ObjectPool` |
| 敌人生成器 | `EnemySpawner` |

### 方法名翻译

| 中文 | C# 方法名 |
|------|-----------|
| 初始化玩家 | `InitializePlayer()` |
| 获取玩家数据 | `GetPlayerData()` |
| 设置生命值 | `SetHealth()` |
| 计算伤害 | `CalculateDamage()` |
| 检查是否死亡 | `IsDead()` |
| 播放音效 | `PlaySound()` |
| 显示界面 | `ShowPanel()` |
| 隐藏提示 | `HideTooltip()` |
| 添加物品 | `AddItem()` |
| 移除效果 | `RemoveEffect()` |

### 属性名翻译

| 中文 | C# 属性名 |
|------|-----------|
| 最大生命值 | `MaxHealth` |
| 当前等级 | `CurrentLevel` |
| 移动速度 | `MoveSpeed` |
| 是否存活 | `IsAlive` |
| 攻击间隔 | `AttackInterval` |
| 技能冷却 | `SkillCooldown` |
| 暴击率 | `CriticalRate` |
| 闪避率 | `DodgeRate` |

### 字段名翻译

| 中文 | C# 私有字段 |
|------|-------------|
| 玩家速度 | `_playerSpeed` |
| 当前血量 | `_currentHp` |
| 目标位置 | `_targetPosition` |
| 是否初始化 | `_isInitialized` |
| 计时器 | `_timer` |
| 缓存组件 | `_cachedComponent` |

## 命名技巧

### 布尔类型命名
- 使用 `Is`, `Has`, `Can`, `Should` 前缀
- 示例：`IsActive`, `HasWeapon`, `CanMove`, `ShouldUpdate`

### 集合类型命名
- 使用复数形式或 `List`, `Array`, `Collection` 后缀
- 示例：`Items`, `EnemyList`, `SkillArray`

### 事件命名
- 使用 `On` 前缀表示事件触发
- 示例：`OnDeath`, `OnLevelUp`, `OnItemCollected`

### 异步方法命名
- 使用 `Async` 后缀
- 示例：`LoadDataAsync()`, `SaveGameAsync()`
