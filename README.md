# Custom Action Button Text

魔兽世界插件，用于自定义动作条按钮上的快捷键文字显示。

## 功能

- 自定义修饰键显示（Shift, Ctrl, Alt）
- 自定义功能键显示（F1-F12）
- 自定义鼠标按钮显示
- 自定义滚轮按钮显示
- 支持组合键格式自定义
- 配置持久化保存

## 安装方法

1. 将 `CustomActionButtonText` 文件夹复制到魔兽世界安装目录下的 `Interface\AddOns` 文件夹中
2. 启动魔兽世界，在角色选择界面的插件列表中启用本插件
3. 进入游戏后，配置会自动加载

## 配置方法

本插件使用独立的配置文件进行配置，您可以直接编辑 `CustomActionButtonText\Config.lua` 文件来自定义设置。

### 配置文件位置
```
魔兽世界安装目录\Interface\AddOns\CustomActionButtonText\Config.lua
```

### 编辑配置文件

用文本编辑器打开 `Config.lua` 文件，您可以修改以下配置项：

```lua
-- 功能键格式 (使用 %s 表示数字)
functionKeyFormat = "F%s",  -- 默认: F1, F2, 等

-- 修饰键格式
shiftFormat = "S",           -- 默认: S (Shift)
ctrlFormat = "C",            -- 默认: C (Ctrl)
altFormat = "A",             -- 默认: A (Alt)

-- 鼠标按钮格式
mouseButtonFormat = "M%s",    -- 默认: M4, M5, 等
middleButtonFormat = "M3",    -- 默认: M3 (鼠标中间键)
wheelUpFormat = "WU",         -- 默认: WU (滚轮向上)
wheelDownFormat = "WD",       -- 默认: WD (滚轮向下)

-- 组合键格式
-- %s+%s 表示修饰键+按键，例如 S+F1
-- %s%s 表示修饰键按键组合，例如 SF1
combinedFormat = "%s+%s"      -- 默认: S+F1, C+M3, 等
```

### 配置示例

将 Shift+F1 显示为 SF1：
```lua
functionKeyFormat = "F%s",
shiftFormat = "S",
combinedFormat = "%s%s"
```

将 Shift+鼠标中间显示为 S+M3：
```lua
shiftFormat = "S",
middleButtonFormat = "M3",
combinedFormat = "%s+%s"
```

将 Ctrl+Alt+F5 显示为 CAF5：
```lua
ctrlFormat = "C",
altFormat = "A",
functionKeyFormat = "F%s",
combinedFormat = "%s%s%s"
```

### 重新加载配置

修改配置文件后，需要重新加载插件才能生效。您可以使用以下命令重新加载插件：
```
/reload
```

## 命令行选项（可选）

插件仍然支持部分命令行选项，用于快速调整设置：

### 重置设置
```
/cabet reset
```
将所有设置重置为默认值。

### 设置修饰键格式
```
/cabet modifier shift S
/cabet modifier ctrl C
/cabet modifier alt A
```
设置修饰键的显示格式，例如将 Shift 显示为 S，Ctrl 显示为 C，Alt 显示为 A。

### 设置功能键格式
```
/cabet function F%s
```
设置功能键的显示格式，`%s` 会被替换为数字。例如 `F%s` 会显示为 F1, F2 等。

### 设置组合键格式
```
/cabet combined %s+%s
```
设置组合键的显示格式，第一个 `%s` 是修饰键，第二个 `%s` 是主按键。例如 `%s+%s` 会显示为 S+F1, C+M3 等。



### 调试命令
```
/cabet debug
```
显示插件状态和配置信息，用于故障排除。

## 默认配置

```
shiftFormat = "S"      # Shift 显示为 S
ctrlFormat = "C"        # Ctrl 显示为 C
altFormat = "A"         # Alt 显示为 A
functionKeyFormat = "F%s"  # F1, F2 等
combinedFormat = "%s+%s"    # S+F1, C+M3 等
middleButtonFormat = "M3"    # 鼠标中键显示为 M3
mouseButtonFormat = "M%s"    # 鼠标侧键显示为 M4, M5 等
wheelUpFormat = "WU"        # 滚轮上滚显示为 WU
wheelDownFormat = "WD"      # 滚轮下滚显示为 WD
```

## 支持的按键类型

- 功能键：F1-F12
- 修饰键：Shift, Ctrl, Alt
- 鼠标按钮：鼠标中键（M3）、侧键（M4, M5）
- 滚轮：滚轮上滚（WU）、滚轮下滚（WD）
- 其他按键：数字键、字母键等

## 故障排除

如果插件加载后没有效果，请尝试以下步骤：

### 1. 检查插件是否正确加载
在游戏中输入以下命令来检查插件状态：
```
/cabet debug
```
这会显示插件的配置信息和测试功能。

### 2. 手动重新加载插件
```
/reload
```

### 3. 重置插件设置
如果配置可能损坏，可以重置为默认设置：
```
/cabet reset
```

### 4. 检查按键绑定
确保您的动作条按钮有绑定的快捷键。插件只会修改已有快捷键的显示文字。

### 5. 测试基本功能
尝试设置一个简单的修饰键格式：
```
/cabet modifier shift S
```

### 6. 检查魔兽世界版本
确保您使用的是支持的魔兽世界版本（11.0+）。

## 注意事项

1. 插件会自动保存配置，下次登录时会自动加载
2. 配置更改后会立即应用到所有动作条按钮
3. 支持所有动作条，包括主动作条、额外动作条、宠物动作条和姿态动作条
4. 不修改游戏的实际按键绑定，只修改显示的文字

## 版本支持

- 魔兽世界 11.0+ 版本

## 作者

Your Name
