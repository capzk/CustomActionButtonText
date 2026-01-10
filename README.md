# Custom Action Button Text / 自定义动作条按键文本

轻量插件，只改动作条热键**显示文本**，不改游戏按键绑定或数据。配置写入 SavedVariables，重载/重登后保留原样（含注释与格式）。

## 使用方法 / Usage

- 打开编辑器：`/cabt`（内置示例与注释直接在编辑器中展示；默认读取保存的原文）
- 编辑与保存：在编辑器中按 `Ctrl+S` 校验并保存；保存后立即刷新动作条显示并写入 SavedVariables
- 调试：`/cabt debug` 查看映射数量、回退统计等
- 重置：`/cabt reset` 恢复默认模板并应用（写入 SavedVariables）

## 文本格式 / Format

- 半角字符，逐行 `KEY = VALUE`（或空格分隔）；支持注释（行首或行尾的 `#` / `//` / `--`），空行会被忽略
- 初次打开会显示带注释的默认模板，可直接修改后 `Ctrl+S` 保存
- 示例：

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
SHIFT-1 = S1
CTRL-2 = C2
ALT-3 = A3
SHIFT-A = SA
CTRL-E = CE
ALT-R = AR
```

- 允许：单修饰键，鼠标键（滚轮/中键/侧键），单修饰 + 基础键或鼠标  
- 不允许：裸字母/数字/F键，多重修饰键
- 重复键：同一规范化键以**最后一条**为准；保存时若有非法行会拒绝保存并提示

## 命令 / Commands

- `/cabt` 打开编辑器
- `/cabt debug` 打印调试信息
- `/cabt reset` 恢复默认模板并立即应用
