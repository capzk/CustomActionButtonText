--[[
Custom Action Button Text - 配置文件
修改此文件来自定义按键显示文本

配置优先级说明：
1. 组合键完整映射 (combinations) - 最高优先级，精确匹配特定组合键
2. 修饰键配置 (modifiers) - 中等优先级，用于构建组合键显示
3. 鼠标按键配置 (mouseKeys) - 基础优先级，单独鼠标按键显示

使用说明：
- 如果某个组合键在 combinations 中有定义，将直接使用该定义
- 如果没有精确匹配，系统会根据 modifiers 和 mouseKeys 自动组合
- 修改配置后需要 /reload 重新加载游戏界面
]]--

-- ============================================================================
-- 组合键完整映射（优先级最高）
-- ============================================================================
-- 格式：["修饰键-基础键"] = "显示文本"
-- 说明：这里的配置会精确匹配特定的按键组合，优先级最高
-- 支持的修饰键：SHIFT, CTRL, ALT
-- 支持的基础键：MOUSEWHEELUP, MOUSEWHEELDOWN, BUTTON3, BUTTON4, BUTTON5 等
local combinations = {
    -- 修饰键 + 滚轮上 (推荐用于快速切换技能/物品)
    ["SHIFT-MOUSEWHEELUP"] = "SMU",     -- Shift + 滚轮上 (Mouse Up)
    ["CTRL-MOUSEWHEELUP"] = "CMU",      -- Ctrl + 滚轮上
    ["ALT-MOUSEWHEELUP"] = "AMU",       -- Alt + 滚轮上
    
    -- 修饰键 + 滚轮下 (推荐用于快速切换技能/物品)
    ["SHIFT-MOUSEWHEELDOWN"] = "SMD",   -- Shift + 滚轮下 (Mouse Down)
    ["CTRL-MOUSEWHEELDOWN"] = "CMD",    -- Ctrl + 滚轮下
    ["ALT-MOUSEWHEELDOWN"] = "AMD",     -- Alt + 滚轮下
    
    -- 修饰键 + 鼠标中键 (推荐用于重要技能)
    ["SHIFT-BUTTON3"] = "SM3",          -- Shift + 鼠标中键 (Mouse 3)
    ["CTRL-BUTTON3"] = "CM3",           -- Ctrl + 鼠标中键
    ["ALT-BUTTON3"] = "AM3",            -- Alt + 鼠标中键
    
    -- 修饰键 + 鼠标侧键4 (推荐用于常用技能)
    ["SHIFT-BUTTON4"] = "SM4",          -- Shift + 鼠标侧键4
    ["CTRL-BUTTON4"] = "CM4",           -- Ctrl + 鼠标侧键4
    ["ALT-BUTTON4"] = "AM4",            -- Alt + 鼠标侧键4
    
    -- 修饰键 + 鼠标侧键5 (推荐用于常用技能)
    ["SHIFT-BUTTON5"] = "SM5",          -- Shift + 鼠标侧键5
    ["CTRL-BUTTON5"] = "CM5",           -- Ctrl + 鼠标侧键5
    ["ALT-BUTTON5"] = "AM5",            -- Alt + 鼠标侧键5
    
    -- 多重修饰键组合 (高级用法，可添加更多)
    ["CTRL-SHIFT-T"] = "CST",           -- Ctrl + Shift + T
    -- ["CTRL-ALT-F1"] = "CAF1",        -- 示例：Ctrl + Alt + F1
    -- ["SHIFT-ALT-SPACE"] = "SAS",     -- 示例：Shift + Alt + 空格
}

-- ============================================================================
-- 修饰键显示配置（中等优先级）
-- ============================================================================
-- 说明：当组合键没有在上面精确定义时，系统会使用这些配置来构建显示文本
-- 格式：修饰键名 = "显示文本"
local modifiers = {
    shift = "S+",   -- Shift 键显示为 S+
    ctrl = "C+",    -- Ctrl 键显示为 C+
    alt = "A+",     -- Alt 键显示为 A+
}

-- ============================================================================
-- 鼠标按键显示配置（基础优先级）
-- ============================================================================
-- 说明：定义单独鼠标按键的显示文本，也用于构建组合键显示
-- 格式：按键名 = "显示文本"
local mouseKeys = {
    mousewheelup = "MU",            -- 鼠标滚轮向上显示为 MU (Mouse Up)
    mousewheeldown = "MD",          -- 鼠标滚轮向下显示为 MD (Mouse Down)
    mousemiddlebutton = "M3",       -- 鼠标中键 (BUTTON3) 显示为 M3
    mousebutton4 = "M4",            -- 鼠标侧键1 (BUTTON4) 显示为 M4
    mousebutton5 = "M5",            -- 鼠标侧键2 (BUTTON5) 显示为 M5
    -- 可以继续扩展更多鼠标按键
    -- mousebutton6 = "M6",        -- 鼠标侧键3 (BUTTON6) 显示为 M6
    -- mousebutton7 = "M7",        -- 鼠标侧键4 (BUTTON7) 显示为 M7
}

-- 导出配置
CustomActionButtonText_Config = {
    modifiers = modifiers,
    mouseKeys = mouseKeys,
    combinations = combinations,
}

