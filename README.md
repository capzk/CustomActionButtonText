# Custom Action Button Text / 自定义动作条按键文本

轻量插件，只改动作条热键**显示文本**，不改游戏按键绑定或数据。配置写入 SavedVariables，重载/重登后保留原样（含注释与格式）。

**插件更新地址：** https://www.curseforge.com/wow/addons/customactionbuttontext

## 新特性 / New Features (v0.1.4+)

### 🎨 简洁编辑器
- **注释着色**：注释行显示为灰色，便于区分配置和说明
- **流畅编辑**：无模式切换，打开即可编辑，无滚动干扰
- **快捷操作**：Ctrl+S 保存，ESC 关闭焦点，Tab 插入空格

### ⚠️ 重要限制
- **3字符限制**：游戏引擎限制热键文本最多3个字符，超过会显示成点
- 建议配置：修饰键单字符（S, C, A），组合键不超过3字符（SMU, CM3）

## 使用方法 / Usage

### 基本操作
- **打开编辑器**：`/cabt`（打开即可编辑，注释显示为灰色）
- **保存配置**：按 `Ctrl+S` 校验并保存
- **关闭焦点**：按 `ESC` 取消输入焦点
- **撤销/重做**：`Ctrl+Z` 撤销，`Ctrl+Y` 重做
- **调试信息**：`/cabt debug` 查看映射数量、回退统计等
- **重置配置**：`/cabt reset` 恢复默认模板并应用

### 编辑器快捷键
- `Ctrl+S` - 保存并应用配置
- `Ctrl+Z` - 撤销
- `Ctrl+Y` - 重做
- `ESC` - 取消输入焦点
- `Tab` - 插入4个空格

## 配置规则 / Configuration Rules

### ✅ 允许自定义 / Allowed
- **修饰键**：SHIFT, CTRL, ALT, SPACE（空格既可单独用也可作修饰键）
- **鼠标键**：滚轮、中键、侧键（MOUSEWHEELUP, BUTTON3-5）
- **特殊键**：方向键、小键盘、导航键等（显示较长的键名）
- **组合键**：单个修饰键+其他键（SHIFT-A, CTRL-1, SPACE-MOUSEWHEELUP）

### ❌ 不允许自定义 / Not Allowed
- **单独的字母/数字/F键**：A, 1, F1（原生显示已经很短）
- **多重修饰键**：CTRL-SHIFT-T, SPACE-SHIFT-A（不支持）

### 优先级说明 / Priority
1. **精确匹配**：SHIFT-MOUSEWHEELUP = SMU
2. **自动拼接**：SHIFT + MOUSEWHEELUP = S + MU = SMU
3. **原生显示**：未配置的键使用游戏原生文本

## 文本格式 / Format

- 半角字符，逐行 `KEY = VALUE`（或空格分隔）
- 支持注释（行首或行尾的 `#` / `//` / `--`），空行会被忽略
- 初次打开会显示带注释的默认模板，可直接修改后 `Ctrl+S` 保存
- **重要**：显示文本最多3个字符，超过会显示成点

### 配置示例 / Example

```
# 修饰键（建议单字符）
SHIFT = S
CTRL = C
ALT = A
SPACE = Sp

# 鼠标键（建议2字符）
MOUSEWHEELUP = MU
MOUSEWHEELDOWN = MD
BUTTON3 = M3
BUTTON4 = M4
BUTTON5 = M5

# 修饰键 + 鼠标组合（最多3字符）
SHIFT-MOUSEWHEELUP = SMU
CTRL-BUTTON3 = CM3
ALT-BUTTON4 = AM4
SPACE-MOUSEWHEELUP = SpU

# 修饰键组合（最多3字符）
SHIFT-SPACE = SSp
CTRL-SPACE = CSp

# 特殊键（最多3字符）
NUMPAD1 = N1
NUMPAD2 = N2
NUMPAD3 = N3

# 修饰键 + 字母/数字（最多3字符）
SHIFT-1 = S1
CTRL-E = CE
```

## 命令 / Commands

- `/cabt` - 打开编辑器
- `/cabt debug` 或 `/cabt d` - 打印调试信息
- `/cabt reset` 或 `/cabt r` - 恢复默认模板并立即应用

## 技术说明 / Technical Notes

- 配置写入 SavedVariables，重载/重登后保留原样（含注释与格式）
- 只改动作条热键显示文本，不改游戏按键绑定或数据
- 重复键以最后一条为准；保存时若有非法行会拒绝保存并提示
- 支持所有 WoW 原生支持的快捷键组合

## 更新日志 / Changelog

### v0.1.4
- 优化：移除预览/编辑模式切换，简化为单一编辑模式
- 优化：移除所有自动滚动行为，由用户完全控制滚动
- 优化：保留注释着色功能（灰色显示），提升可读性
- 修复：解决编辑器自动滚动到底部的问题

### v0.1.3
- 新增：配置编辑器语法高亮（预览模式完整高亮，编辑模式注释着色）
- 新增：预览/编辑模式自动切换（点击编辑，保存/ESC退出）
- 优化：模板文字说明中英文分开显示，更清晰易读
- 优化：添加插件更新地址到模板顶部

### v0.1.2
- 新增：支持空格键（SPACE）作为修饰键和组合键
- 新增：支持特殊键自定义（方向键、小键盘、导航键等）
- 优化：所有默认配置优化为3字符以内（游戏显示限制）
- 优化：模板配置分类整理，添加中英对照注释

### v0.1.0
- 初始版本：基础热键文本自定义功能
