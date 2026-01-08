--[[
Custom Action Button Text - Configuration File / 配置文件
Modify this file to customize hotkey text display / 修改此文件来自定义按键显示文本

Configuration Priority System / 配置优先级系统：
1. Combination Keys (combinations) - Highest Priority / 组合键完整映射 - 最高优先级
   Exact matches for specific key combinations / 精确匹配特定组合键
2. Modifier Keys (modifiers) - Medium Priority / 修饰键配置 - 中等优先级
   Used to build combination displays / 用于构建组合键显示
3. Mouse Keys (mouseKeys) - Base Priority / 鼠标按键配置 - 基础优先级
   Individual mouse button displays / 单独鼠标按键显示

Usage Instructions / 使用说明：
- If a combination key is defined in 'combinations', it will be used directly
  如果某个组合键在 combinations 中有定义，将直接使用该定义
- If no exact match, the system will auto-combine using 'modifiers' and 'mouseKeys'
  如果没有精确匹配，系统会根据 modifiers 和 mouseKeys 自动组合
- After modifying, use /reload to refresh the game interface
  修改配置后需要 /reload 重新加载游戏界面

Supported Keys / 支持的按键：
- Modifier Keys / 修饰键: SHIFT, CTRL, ALT
- Mouse Keys / 鼠标按键: MOUSEWHEELUP, MOUSEWHEELDOWN, BUTTON3, BUTTON4, BUTTON5, etc.
- Other Keys / 其他按键: Function keys (F1-F12), letters, numbers, etc.
]]--

-- ============================================================================
-- Combination Keys Configuration / 组合键完整映射配置（优先级最高 / Highest Priority）
-- ============================================================================
-- Format / 格式：["MODIFIER-BASEKEY"] = "DISPLAY_TEXT"
-- Description / 说明：These configurations will exactly match specific key combinations
--                    这里的配置会精确匹配特定的按键组合，优先级最高
-- Examples / 示例：
--   ["SHIFT-MOUSEWHEELUP"] = "SMU" means Shift+Mouse Wheel Up displays as "SMU"
--   ["SHIFT-MOUSEWHEELUP"] = "SMU" 表示 Shift+鼠标滚轮向上 显示为 "SMU"
local combinations = {
    -- Modifier + Mouse Wheel Up / 修饰键 + 滚轮上 (Recommended for quick skill/item switching / 推荐用于快速切换技能/物品)
    ["SHIFT-MOUSEWHEELUP"] = "SMU",     -- Shift + Mouse Wheel Up / Shift + 滚轮上
    ["CTRL-MOUSEWHEELUP"] = "CMU",      -- Ctrl + Mouse Wheel Up / Ctrl + 滚轮上
    ["ALT-MOUSEWHEELUP"] = "AMU",       -- Alt + Mouse Wheel Up / Alt + 滚轮上
    
    -- Modifier + Mouse Wheel Down / 修饰键 + 滚轮下 (Recommended for quick skill/item switching / 推荐用于快速切换技能/物品)
    ["SHIFT-MOUSEWHEELDOWN"] = "SMD",   -- Shift + Mouse Wheel Down / Shift + 滚轮下
    ["CTRL-MOUSEWHEELDOWN"] = "CMD",    -- Ctrl + Mouse Wheel Down / Ctrl + 滚轮下
    ["ALT-MOUSEWHEELDOWN"] = "AMD",     -- Alt + Mouse Wheel Down / Alt + 滚轮下
    
    -- Modifier + Middle Mouse Button / 修饰键 + 鼠标中键 (Recommended for important skills / 推荐用于重要技能)
    ["SHIFT-BUTTON3"] = "SM3",          -- Shift + Middle Mouse Button / Shift + 鼠标中键
    ["CTRL-BUTTON3"] = "CM3",           -- Ctrl + Middle Mouse Button / Ctrl + 鼠标中键
    ["ALT-BUTTON3"] = "AM3",            -- Alt + Middle Mouse Button / Alt + 鼠标中键
    
    -- Modifier + Mouse Side Button 4 / 修饰键 + 鼠标侧键4 (Recommended for common skills / 推荐用于常用技能)
    ["SHIFT-BUTTON4"] = "SM4",          -- Shift + Mouse Side Button 4 / Shift + 鼠标侧键4
    ["CTRL-BUTTON4"] = "CM4",           -- Ctrl + Mouse Side Button 4 / Ctrl + 鼠标侧键4
    ["ALT-BUTTON4"] = "AM4",            -- Alt + Mouse Side Button 4 / Alt + 鼠标侧键4
    
    -- Modifier + Mouse Side Button 5 / 修饰键 + 鼠标侧键5 (Recommended for common skills / 推荐用于常用技能)
    ["SHIFT-BUTTON5"] = "SM5",          -- Shift + Mouse Side Button 5 / Shift + 鼠标侧键5
    ["CTRL-BUTTON5"] = "CM5",           -- Ctrl + Mouse Side Button 5 / Ctrl + 鼠标侧键5
    ["ALT-BUTTON5"] = "AM5",            -- Alt + Mouse Side Button 5 / Alt + 鼠标侧键5
    
    -- Multiple Modifier Key Combinations / 多重修饰键组合 (Advanced usage, add more as needed / 高级用法，可添加更多)
    ["CTRL-SHIFT-T"] = "CST",           -- Ctrl + Shift + T
    -- ["CTRL-ALT-F1"] = "CAF1",        -- Example: Ctrl + Alt + F1 / 示例：Ctrl + Alt + F1
    -- ["SHIFT-ALT-SPACE"] = "SAS",     -- Example: Shift + Alt + Space / 示例：Shift + Alt + 空格
    
    -- Add your custom combinations here / 在此添加您的自定义组合键
    -- ["YOUR-COMBINATION"] = "DISPLAY", -- Your custom combination / 您的自定义组合
}

-- ============================================================================
-- Modifier Keys Configuration / 修饰键显示配置（中等优先级 / Medium Priority）
-- ============================================================================
-- Description / 说明：When combination keys are not exactly defined above, the system will use
--                    these configurations to build display text
--                    当组合键没有在上面精确定义时，系统会使用这些配置来构建显示文本
-- Format / 格式：modifier_name = "DISPLAY_TEXT"
local modifiers = {
    shift = "S+",   -- Shift key displays as "S+" / Shift 键显示为 "S+"
    ctrl = "C+",    -- Ctrl key displays as "C+" / Ctrl 键显示为 "C+"
    alt = "A+",     -- Alt key displays as "A+" / Alt 键显示为 "A+"
}

-- ============================================================================
-- Mouse Keys Configuration / 鼠标按键显示配置（基础优先级 / Base Priority）
-- ============================================================================
-- Description / 说明：Defines display text for individual mouse keys, also used for building combination displays
--                    定义单独鼠标按键的显示文本，也用于构建组合键显示
-- Format / 格式：key_name = "DISPLAY_TEXT"
local mouseKeys = {
    mousewheelup = "MU",            -- Mouse wheel up displays as "MU" / 鼠标滚轮向上显示为 "MU"
    mousewheeldown = "MD",          -- Mouse wheel down displays as "MD" / 鼠标滚轮向下显示为 "MD"
    mousemiddlebutton = "M3",       -- Middle mouse button (BUTTON3) displays as "M3" / 鼠标中键 (BUTTON3) 显示为 "M3"
    mousebutton4 = "M4",            -- Mouse side button 1 (BUTTON4) displays as "M4" / 鼠标侧键1 (BUTTON4) 显示为 "M4"
    mousebutton5 = "M5",            -- Mouse side button 2 (BUTTON5) displays as "M5" / 鼠标侧键2 (BUTTON5) 显示为 "M5"
    
    -- Extend with more mouse buttons as needed / 可以继续扩展更多鼠标按键
    -- mousebutton6 = "M6",        -- Mouse side button 3 (BUTTON6) displays as "M6" / 鼠标侧键3 (BUTTON6) 显示为 "M6"
    -- mousebutton7 = "M7",        -- Mouse side button 4 (BUTTON7) displays as "M7" / 鼠标侧键4 (BUTTON7) 显示为 "M7"
    -- mousebutton8 = "M8",        -- Additional mouse button (BUTTON8) displays as "M8" / 额外鼠标按键 (BUTTON8) 显示为 "M8"
}

-- 导出配置
CustomActionButtonText_Config = {
    modifiers = modifiers,
    mouseKeys = mouseKeys,
    combinations = combinations,
}

