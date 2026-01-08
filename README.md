# Custom Action Button Text / 自定义动作条按键文本

[English](#english) | [中文](#中文)

---

## English

A World of Warcraft addon that customizes the display of hotkey text on action buttons, allowing players to create cleaner and more personalized action bar interfaces.

### Features

- **Modifier Key Customization**: Customize display of Shift, Ctrl, Alt keys
- **Mouse Button Support**: Custom display for mouse wheel, middle button, and side buttons
- **Combination Keys**: Advanced support for complex key combinations
- **Persistent Configuration**: Settings are automatically saved and restored
- **Real-time Updates**: Changes apply immediately to all action bars
- **Comprehensive Coverage**: Works with all action bars including main, extra, pet, and stance bars
- **Non-invasive**: Only changes visual display, does not modify game data or key bindings
- **Safe and Reversible**: Disabling the addon instantly restores original hotkey display

### Installation

1. Download and extract the `CustomActionButtonText` folder
2. Copy it to your World of Warcraft `Interface\AddOns` directory
3. Enable the addon in the character selection screen
4. Configuration will load automatically when you enter the game

### Configuration

The addon uses a configuration file approach for maximum flexibility. Edit the `Config.lua` file to customize your settings.

#### Configuration File Location
```
World of Warcraft\Interface\AddOns\CustomActionButtonText\Config.lua
```

#### Configuration Structure

The configuration follows a priority system:

1. **Combination Keys** (Highest Priority) - Exact matches for specific key combinations
2. **Modifier Keys** (Medium Priority) - Used to build combination displays
3. **Mouse Keys** (Base Priority) - Individual mouse button displays

#### Current Default Configuration

```lua
-- Combination Keys (Highest Priority)
combinations = {
    ["SHIFT-MOUSEWHEELUP"] = "SMU",     -- Shift + Mouse Wheel Up
    ["CTRL-MOUSEWHEELDOWN"] = "CMD",    -- Ctrl + Mouse Wheel Down
    ["ALT-BUTTON3"] = "AM3",            -- Alt + Middle Mouse Button
    -- ... more combinations
}

-- Modifier Keys
modifiers = {
    shift = "S+",    -- Shift key displays as S+
    ctrl = "C+",     -- Ctrl key displays as C+
    alt = "A+",      -- Alt key displays as A+
}

-- Mouse Keys
mouseKeys = {
    mousewheelup = "MU",        -- Mouse wheel up displays as MU
    mousewheeldown = "MD",      -- Mouse wheel down displays as MD
    mousemiddlebutton = "M3",   -- Middle mouse button displays as M3
    mousebutton4 = "M4",        -- Mouse side button 4 displays as M4
    mousebutton5 = "M5",        -- Mouse side button 5 displays as M5
}
```

#### Applying Changes

After modifying the configuration file, reload the UI:
```
/reload
```

### Supported Key Types

- **Function Keys**: F1-F12
- **Modifier Keys**: Shift, Ctrl, Alt
- **Mouse Buttons**: Middle button (M3), Side buttons (M4, M5, etc.)
- **Mouse Wheel**: Scroll up/down
- **Other Keys**: Number keys, letter keys, etc.

### Troubleshooting

If the addon doesn't work as expected:

1. **Reload UI**: Use `/reload` to refresh the interface
2. **Verify key bindings**: Ensure your action buttons have assigned hotkeys
3. **Check WoW version**: Ensure you're using a supported version (11.0+)
4. **Check configuration**: Verify your Config.lua file syntax is correct

### Version Support

- World of Warcraft 11.0+ (The War Within and later)

### Important Notes

- **Visual Only**: This addon only changes the visual display of hotkey text, it does not modify your actual key bindings or game data
- **Completely Reversible**: Disabling or removing the addon will immediately restore the original hotkey display
- **No Data Loss**: Your original key bindings and game settings remain completely unchanged
- **Safe to Use**: The addon only affects the UI display layer and cannot cause data corruption or game issues

### Author

capzk

---

## 中文

魔兽世界插件，用于自定义动作条按钮上的快捷键文字显示，让玩家可以创建更简洁、更个性化的动作条界面。

### 功能特性

- **修饰键自定义**: 自定义 Shift、Ctrl、Alt 键的显示方式
- **鼠标按键支持**: 支持鼠标滚轮、中键、侧键的自定义显示
- **组合键支持**: 高级组合键配置，支持复杂按键组合
- **配置持久化**: 设置自动保存和恢复
- **实时更新**: 配置更改立即应用到所有动作条
- **全面覆盖**: 支持所有动作条，包括主动作条、额外动作条、宠物动作条和姿态动作条
- **非侵入性**: 仅改变视觉显示，不修改游戏数据或按键绑定
- **安全可逆**: 禁用插件后立即恢复原始快捷键显示

### 安装方法

1. 下载并解压 `CustomActionButtonText` 文件夹
2. 将其复制到魔兽世界 `Interface\AddOns` 目录下
3. 在角色选择界面的插件列表中启用本插件
4. 进入游戏后配置会自动加载

### 配置方法

本插件采用配置文件方式，提供最大的灵活性。编辑 `Config.lua` 文件来自定义您的设置。

#### 配置文件位置
```
魔兽世界安装目录\Interface\AddOns\CustomActionButtonText\Config.lua
```

#### 配置结构

配置采用优先级系统：

1. **组合键完整映射**（最高优先级）- 精确匹配特定按键组合
2. **修饰键配置**（中等优先级）- 用于构建组合键显示
3. **鼠标按键配置**（基础优先级）- 单独鼠标按键显示

#### 当前默认配置

```lua
-- 组合键完整映射（最高优先级）
combinations = {
    ["SHIFT-MOUSEWHEELUP"] = "SMU",     -- Shift + 鼠标滚轮上
    ["CTRL-MOUSEWHEELDOWN"] = "CMD",    -- Ctrl + 鼠标滚轮下
    ["ALT-BUTTON3"] = "AM3",            -- Alt + 鼠标中键
    -- ... 更多组合
}

-- 修饰键配置
modifiers = {
    shift = "S+",    -- Shift 键显示为 S+
    ctrl = "C+",     -- Ctrl 键显示为 C+
    alt = "A+",      -- Alt 键显示为 A+
}

-- 鼠标按键配置
mouseKeys = {
    mousewheelup = "MU",        -- 鼠标滚轮向上显示为 MU
    mousewheeldown = "MD",      -- 鼠标滚轮向下显示为 MD
    mousemiddlebutton = "M3",   -- 鼠标中键显示为 M3
    mousebutton4 = "M4",        -- 鼠标侧键4显示为 M4
    mousebutton5 = "M5",        -- 鼠标侧键5显示为 M5
}
```

#### 应用更改

修改配置文件后，重新加载界面：
```
/reload
```

### 支持的按键类型

- **功能键**: F1-F12
- **修饰键**: Shift, Ctrl, Alt
- **鼠标按钮**: 鼠标中键（M3）、侧键（M4, M5等）
- **鼠标滚轮**: 滚轮上滚/下滚
- **其他按键**: 数字键、字母键等

### 故障排除

如果插件无法正常工作：

1. **重新加载界面**: 使用 `/reload` 刷新界面
2. **验证按键绑定**: 确保动作条按钮已分配快捷键
3. **检查魔兽世界版本**: 确保使用支持的版本（11.0+）
4. **检查配置文件**: 验证 Config.lua 文件语法是否正确

### 版本支持

- 魔兽世界 11.0+（巨龙时代及更高版本）

### 重要说明

- **仅视觉效果**: 本插件仅改变快捷键文本的视觉显示，不会修改您的实际按键绑定或游戏数据
- **完全可逆**: 禁用或删除插件后会立即恢复原始的快捷键显示
- **无数据丢失**: 您的原始按键绑定和游戏设置保持完全不变
- **安全使用**: 插件仅影响UI显示层，不会造成数据损坏或游戏问题

### 作者

capzk

---

## License / 许可证

This project is open source. Feel free to modify and distribute.

本项目为开源项目，欢迎修改和分发。
