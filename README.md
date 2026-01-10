# Custom Action Button Text / 自定义动作条按键文本

轻量插件，只改动作条热键**显示文本**，不改游戏按键绑定或数据。配置保存在 SavedVariables（账号共享），无本地 Config.lua 依赖。

## 使用方法 / Usage

- 打开编辑器：`/cabet ui`（顶部“●●●”按钮弹出帮助窗口）
- 编辑与保存：在编辑器中按 `Ctrl+S` 校验并保存；保存后立即刷新动作条显示
- 重载配置：`/cabet reload` 重新应用已保存数据（若无则使用内置默认）
- 调试：`/cabet debug` 查看映射数量、回退统计等

## 文本格式 / Format

- 半角字符，逐行 `KEY = VALUE`（或空格分隔），示例：

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

- 允许：单修饰键，鼠标键（滚轮/中键/侧键），单修饰 + 基础键或鼠标  
- 不允许：裸字母/数字/F键，多重修饰键
- 重复键：同一规范化键以**最后一条**为准；保存时若有非法行会拒绝保存并提示

## 帮助窗口 / Help

- 顶部“●●●”按钮打开独立帮助窗（可拖动，置顶显示）
- 帮助内容只读，但可选中复制；需要编辑请在主编辑器窗口操作

## 命令 / Commands

- `/cabet ui` 打开编辑器
- `/cabet reload` 重载已保存数据或默认
- `/cabet debug` 打印调试信息
