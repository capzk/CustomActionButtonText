# Custom Action Button Text / 自定义动作条按键文本

[English](#english) | [中文](#中文)

---

> This addon **only personalizes hotkey text display**. It does **not** change key bindings or any game data. Changes apply when the addon loads (and when you manually `/cabet reload`), and can be reset with `/cabet reset`.  
> 本插件**仅修改快捷键文本显示**，**不会**修改按键绑定或任何游戏数据。显示改动在插件加载（或手动 `/cabet reload`）时生效，可用 `/cabet reset` 还原。

## English

A World of Warcraft addon that customizes the display of hotkey text on action buttons, allowing players to create cleaner and more personalized action bar interfaces.

### Features

- **Display-only**: Visual change only; bindings and data stay untouched
- **Modifier Key Customization**: Customize display of Shift, Ctrl, Alt keys
- **Mouse Button Support**: Custom display for mouse wheel, middle button, and side buttons
- **Combination Keys**: Exact-match mappings plus fallback concatenation
- **Manual reload/reset**: Apply config via `/cabet reload`; restore native via `/cabet reset`
- **Native UI**: Edit/save mappings in-game with `/cabet ui` (stored in SavedVariables)
- **Comprehensive Coverage**: Works with all action bars including main, extra, pet, and stance bars

### Installation

1. Download and extract the `CustomActionButtonText` folder
2. Copy it to your World of Warcraft `Interface\AddOns` directory
3. Enable the addon in the character selection screen
4. Configuration will load automatically when you enter the game

### Configuration

Configure in game via `/cabet ui`. The text editor saves to SavedVariables (account-wide). If no saved data exists, built-in defaults are loaded into the editor.

#### Format & Rules
- Use half-width characters; format `KEY = VALUE` (or `KEY VALUE`).
- Allowed: single modifier (`SHIFT`/`CTRL`/`ALT`), mouse buttons (wheel up/down, button3/4/5…), or single modifier + key/mouse. No multi-modifier combos; no bare letters/numbers/F-keys.
- Priority: exact combinations first; otherwise modifier text + base key concatenation. Invalid lines are rejected on save.
- Duplicates: same normalized key uses the **last** definition; `/cabet reload` prints warnings (up to 5).
- Debug: `/cabet debug` shows duplicate count and fallback stats.

#### Current Default Configuration

```
SHIFT = S+
CTRL = C+
ALT = A+
MOUSEWHEELUP = MU
MOUSEWHEELDOWN = MD
BUTTON3 = M3
BUTTON4 = M4
BUTTON5 = M5
SHIFT-MOUSEWHEELUP = SMU
CTRL-MOUSEWHEELUP = CMU
ALT-MOUSEWHEELUP = AMU
SHIFT-MOUSEWHEELDOWN = SMD
CTRL-MOUSEWHEELDOWN = CMD
ALT-MOUSEWHEELDOWN = AMD
SHIFT-BUTTON3 = SM3
CTRL-BUTTON3 = CM3
ALT-BUTTON3 = AM3
SHIFT-BUTTON4 = SM4
CTRL-BUTTON4 = CM4
ALT-BUTTON4 = AM4
SHIFT-BUTTON5 = SM5
CTRL-BUTTON5 = CM5
ALT-BUTTON5 = AM5
```

#### Applying Changes
- In UI: edit → 保存并应用（writes to SavedVariables and refreshes buttons）
- Slash: `/cabet reload` reloads saved data/defaults; `/cabet reset` restores native display; `/cabet debug` prints stats.

### Available Commands

The addon provides a comprehensive command system for easy management:

#### **Configuration Management**
- **`/cabet reload`** or **`/cabet r`**
  - **Purpose**: Reload configuration from Config.lua without restarting the game
  - **When to use**: After modifying the Config.lua file
  - **Example**: You changed mouse wheel settings, use this to apply changes instantly
- **`/cabet ui`**
  - **Purpose**: Open the native UI to view/edit/save mappings (SavedVariables)
  - **When to use**: Adjust mappings in-game without editing files

#### **Reset Functions**
- **`/cabet reset`**
  - **Purpose**: Reset all buttons to native display (fixes display issues)
  - **When to use**: When buttons show incorrect text (like dots instead of letters)
  - **Example**: If single letters appear as dots, this command restores original display

#### **Troubleshooting**
- **`/cabet debug`** or **`/cabet d`**
  - **Purpose**: Show detailed debug information for troubleshooting
  - **When to use**: When the addon isn't working as expected
  - **Information shown**: 
    - Configuration loading status
    - Number of active mappings
    - Original hotkeys backup status
    - Memory usage statistics

#### **Help**
- **`/cabet`** (no parameters)
  - **Purpose**: Show help with all available commands
  - **When to use**: When you forget command syntax or need quick reference

### Command Usage Examples

**Typical workflow (UI):**
```
1. /cabet ui              (open editor)
2. Edit mappings          (KEY = VALUE, half-width)
3. 保存并应用             (writes to SavedVariables & refreshes)
4. /cabet debug           (verify)
```

### Supported Key Types

- **Function Keys**: F1-F12
- **Modifier Keys**: Shift, Ctrl, Alt
- **Mouse Buttons**: Middle button (M3), Side buttons (M4, M5, etc.)
- **Mouse Wheel**: Scroll up/down
- **Other Keys**: Number keys, letter keys, etc.

### Troubleshooting

If the addon doesn't work as expected, follow these steps:

#### **Common Issues and Solutions**

**Issue 1: Letters/numbers show as dots**
```
Solution: /cabet reset
Explanation: This restores native hotkey display
```

**Issue 2: Saved mappings not applied**
```
Solution: /cabet reload
Explanation: Reload SavedVariables or defaults
```

**Issue 3: Some buttons not updating**
```
Solution: /cabet reload
Explanation: Reload mappings and refresh all buttons
```

**Issue 4: Addon seems broken**
```
Solution: /cabet debug
Explanation: This shows what's wrong with the configuration
```

#### **Step-by-Step Troubleshooting**

1. **First, check current status**
   ```
   /cabet debug
   ```
   Look for error messages or unusual values

2. **Reset to clean state**
   ```
   /cabet reset
   ```
   This fixes most display issues

3. **Reload saved mappings**
   ```
   /cabet reload
   ```
   This reapplies your saved settings

4. **Force refresh if needed**
   ```
   /cabet reload
   ```
   This ensures all buttons are refreshed

5. **If still not working**
   ```
   /reload
   ```
   This restarts the entire UI (last resort)

#### **Additional Checks**

- **Verify key bindings**: Ensure your action buttons have assigned hotkeys
- **Check WoW version**: Ensure you're using a supported version (11.0+)
- **Check configuration**: Verify your Config.lua file syntax is correct
- **Test with simple config**: Try with minimal configuration first

### Version Support

- World of Warcraft 11.0+ (The War Within and later)

### Important Notes

- **Visual Only**: This addon only changes the visual display of hotkey text, it does not modify your actual key bindings or game data
- **Completely Reversible**: Disabling or removing the addon will immediately restore the original hotkey display
- **No Data Loss**: Your original key bindings and game settings remain completely unchanged
- **Safe to Use**: The addon only affects the UI display layer and cannot cause data corruption or game issues
- **Emergency Reset**: If anything goes wrong, use `/cabet reset` to instantly restore native display
- **Real-time Configuration**: Use `/cabet reload` to apply configuration changes without restarting the game

### Author

capzk

---

## 中文

魔兽世界插件，用于自定义动作条按钮上的快捷键文字显示，让玩家可以创建更简洁、更个性化的动作条界面。

### 功能特性

- **仅显示层**：只改热键文本，不改按键绑定或数据
- **修饰键自定义**: 自定义 Shift、Ctrl、Alt 键的显示方式
- **鼠标按键支持**: 支持鼠标滚轮、中键、侧键的自定义显示
- **组合键支持**: 精确组合配置 + 自动拼接
- **手动重载/还原**: `/cabet reload` 套用配置，`/cabet reset` 还原显示
- **原生设置界面**：使用 `/cabet ui` 在游戏内查看/编辑/保存映射（写入 SavedVariables）
- **全面覆盖**: 支持所有动作条，包括主动作条、额外动作条、宠物动作条和姿态动作条

### 安装方法

1. 下载并解压 `CustomActionButtonText` 文件夹
2. 将其复制到魔兽世界 `Interface\AddOns` 目录下
3. 在角色选择界面的插件列表中启用本插件
4. 进入游戏后配置会自动加载

### 配置方法

在游戏内使用文本编辑器：输入 `/cabet ui`，按 `KEY = VALUE`（半角符号）逐行编辑，点击“保存并应用”即可写入 SavedVariables（账号共享）。没有用户数据时会自动载入内置默认映射。

#### 格式与规则
- 使用半角符号，格式 `KEY = VALUE`（或 `KEY VALUE`）
- 允许：单修饰键（SHIFT/CTRL/ALT）、鼠标键（滚轮、Button3/4/5…）、单修饰 + 基础键/鼠标键
- 不允许：裸字母/数字/F键、多重修饰键
- 优先级：精确组合最高；否则修饰键文本 + 基础键拼接。非法行保存时直接拒绝。
- 重复：同一规范化键重复定义时 **后面的值生效**，`/cabet reload` 会打印覆盖警告（最多显示前 5 条）。
- 调试：`/cabet debug` 会显示重复计数以及回退原因统计（单键被拒、多重修饰被拒、允许但未找到映射）。

#### 当前默认配置

```
SHIFT = S+
CTRL = C+
ALT = A+
MOUSEWHEELUP = MU
MOUSEWHEELDOWN = MD
BUTTON3 = M3
BUTTON4 = M4
BUTTON5 = M5
SHIFT-MOUSEWHEELUP = SMU
CTRL-MOUSEWHEELUP = CMU
ALT-MOUSEWHEELUP = AMU
SHIFT-MOUSEWHEELDOWN = SMD
CTRL-MOUSEWHEELDOWN = CMD
ALT-MOUSEWHEELDOWN = AMD
SHIFT-BUTTON3 = SM3
CTRL-BUTTON3 = CM3
ALT-BUTTON3 = AM3
SHIFT-BUTTON4 = SM4
CTRL-BUTTON4 = CM4
ALT-BUTTON4 = AM4
SHIFT-BUTTON5 = SM5
CTRL-BUTTON5 = CM5
ALT-BUTTON5 = AM5
```

#### 应用更改
- UI 编辑后点击“保存并应用”，写入 SavedVariables 并刷新显示
- `/cabet reload` 重新加载；`/cabet reset` 恢复原生显示；`/cabet debug` 查看统计

### 可用命令

插件提供了完整的命令系统，便于管理：

#### **配置管理**
- **`/cabet reload`** 或 **`/cabet r`**
  - **作用**: 从Config.lua重新加载配置，无需重启游戏
  - **使用时机**: 修改Config.lua文件后
  - **示例**: 您更改了鼠标滚轮设置，使用此命令立即应用更改
- **`/cabet ui`**
  - **作用**: 打开原生设置界面，在游戏内查看/编辑/保存映射（写入 SavedVariables）
  - **使用时机**: 想直接在游戏中调整映射时

#### **重置功能**
- **`/cabet reset`**
  - **作用**: 重置所有按钮为原生显示（修复显示问题）
  - **使用时机**: 当按钮显示错误文本时（如字母显示为点）
  - **示例**: 如果单个字母显示为点，此命令可恢复原始显示

#### **故障排除**
- **`/cabet debug`** 或 **`/cabet d`**
  - **作用**: 显示详细的调试信息，用于故障排除
  - **使用时机**: 当插件无法按预期工作时
  - **显示信息**: 
    - 配置加载状态
    - 活动映射数量
    - 原始热键备份状态
    - 内存使用统计

#### **帮助**
- **`/cabet`** （无参数）
  - **作用**: 显示所有可用命令的帮助
  - **使用时机**: 当您忘记命令语法或需要快速参考时

### 命令使用示例

**配置更改后的典型工作流程：**
```
1. 编辑 Config.lua 文件
2. /cabet reload          (应用更改)
3. /cabet debug           (验证更改已加载)
```

**故障排除工作流程：**
```
1. /cabet debug           (检查当前状态)
2. /cabet reset           (修复显示问题)
3. /cabet reload          (重新应用配置)
```

### 支持的按键类型

- **功能键**: F1-F12
- **修饰键**: Shift, Ctrl, Alt
- **鼠标按钮**: 鼠标中键（M3）、侧键（M4, M5等）
- **鼠标滚轮**: 滚轮上滚/下滚
- **其他按键**: 数字键、字母键等

### 故障排除

如果插件无法正常工作，请按照以下步骤操作：

#### **常见问题和解决方案**

**问题1：字母/数字显示为点**
```
解决方案：/cabet reset
说明：这会恢复原生热键显示
```

**问题2：配置更改未应用**
```
解决方案：/cabet reload
说明：这会重新加载您的Config.lua更改
```

**问题3：某些按钮未更新**
```
解决方案：/cabet reload
说明：这会重新加载配置并刷新所有按钮
```

**问题4：插件似乎损坏**
```
解决方案：/cabet debug
说明：这会显示配置出了什么问题
```

#### **分步故障排除**

1. **首先，检查当前状态**
   ```
   /cabet debug
   ```
   查找错误消息或异常值

2. **重置为干净状态**
   ```
   /cabet reset
   ```
   这可以修复大多数显示问题

3. **重新加载您的配置**
   ```
   /cabet reload
   ```
   这会应用您的自定义设置

4. **如需要，强制刷新**
   ```
   /cabet reload
   ```
   这会重新加载配置并刷新所有按钮

5. **如果仍然无效**
   ```
   /reload
   ```
   这会重启整个UI（最后手段）

#### **其他检查项目**

- **验证按键绑定**: 确保您的动作条按钮已分配热键
- **检查魔兽世界版本**: 确保使用支持的版本（11.0+）
- **检查配置文件**: 验证Config.lua文件语法是否正确
- **使用简单配置测试**: 先尝试最小配置

### 版本支持

- 魔兽世界 11.0+（巨龙时代及更高版本）

### 重要说明

- **仅视觉效果**: 本插件仅改变快捷键文本的视觉显示，不会修改您的实际按键绑定或游戏数据
- **完全可逆**: 禁用或删除插件后会立即恢复原始的快捷键显示
- **无数据丢失**: 您的原始按键绑定和游戏设置保持完全不变
- **安全使用**: 插件仅影响UI显示层，不会造成数据损坏或游戏问题
- **紧急重置**: 如果出现任何问题，使用 `/cabet reset` 立即恢复原生显示
- **实时配置**: 使用 `/cabet reload` 应用配置更改，无需重启游戏

### 作者

capzk

---

## License / 许可证

This project is open source. Feel free to modify and distribute.

本项目为开源项目，欢迎修改和分发。
