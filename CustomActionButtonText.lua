--[[
Custom Action Button Text - 主模块
从Config.lua读取配置，自定义动作条按钮上的快捷键文字显示
]]--

local addonName = "CustomActionButtonText"
local originalHotkeys = {}

-- 配置映射表（从Config.lua加载）
local keyMappings = {}

-- 标准化键名（统一格式用于匹配）
local function NormalizeKey(key)
    if not key or key == "" then return "" end
    return string.upper(key)
end

-- 获取显示文本（支持组合键，不加连字符）
-- 优先级：组合键配置 > 单独键配置的组合 > 原生显示
local function GetDisplayText(bindingKey)
    if not bindingKey or bindingKey == "" then return nil end
    
    local key = NormalizeKey(bindingKey)
    
    -- 优先级1：检查组合键完整配置（最高优先级）
    if keyMappings[key] then
        return keyMappings[key]
    end
    
    -- 优先级2：解析修饰键和基础键，使用单独键配置组合
    local result = ""
    local hasModifier = false
    local hasConfig = false  -- 标记是否有配置
    
    -- 检查修饰键（按顺序：CTRL, SHIFT, ALT，与WoW绑定系统一致）
    if string.find(key, "CTRL%-") then
        local ctrlText = keyMappings["CTRL"]
        if ctrlText then
            result = result .. ctrlText
            hasConfig = true
        end
        key = string.gsub(key, "CTRL%-", "")
        hasModifier = true
    end
    if string.find(key, "SHIFT%-") then
        local shiftText = keyMappings["SHIFT"]
        if shiftText then
            result = result .. shiftText
            hasConfig = true
        end
        key = string.gsub(key, "SHIFT%-", "")
        hasModifier = true
    end
    if string.find(key, "ALT%-") then
        local altText = keyMappings["ALT"]
        if altText then
            result = result .. altText
            hasConfig = true
        end
        key = string.gsub(key, "ALT%-", "")
        hasModifier = true
    end
    
    -- 检查鼠标按键（扩展支持 BUTTON3, BUTTON4, BUTTON5 等）
    if key == "MOUSEWHEELUP" then
        local mouseText = keyMappings["MOUSEWHEELUP"]
        if mouseText then
            result = result .. mouseText
            hasConfig = true
        end
    elseif key == "MOUSEWHEELDOWN" then
        local mouseText = keyMappings["MOUSEWHEELDOWN"]
        if mouseText then
            result = result .. mouseText
            hasConfig = true
        end
    elseif key == "BUTTON3" then
        local mouseText = keyMappings["BUTTON3"]
        if mouseText then
            result = result .. mouseText
            hasConfig = true
        end
    elseif key == "BUTTON4" then
        local mouseText = keyMappings["BUTTON4"]
        if mouseText then
            result = result .. mouseText
            hasConfig = true
        end
    elseif key == "BUTTON5" then
        local mouseText = keyMappings["BUTTON5"]
        if mouseText then
            result = result .. mouseText
            hasConfig = true
        end
    elseif string.match(key, "^BUTTON(%d+)$") then
        -- 支持 BUTTON6, BUTTON7 等更多鼠标按键
        local buttonNum = string.match(key, "^BUTTON(%d+)$")
        local buttonKey = "BUTTON" .. buttonNum
        local mouseText = keyMappings[buttonKey]
        if mouseText then
            result = result .. mouseText
            hasConfig = true
        end
    else
        -- 其他按键（如字母、数字等）
        if not hasModifier then
            -- 没有修饰键，返回nil使用原始显示
            return nil
        end
        -- 有修饰键，将剩余按键（字母/数字）也添加到结果中
        if key and key ~= "" then
            result = result .. key
        end
    end
    
    -- 只有在有配置且结果不为空时才返回自定义文本，否则返回nil使用原生显示
    if hasConfig and result ~= "" then
        return result
    else
        return nil
    end
end

-- 获取按钮的绑定键名
local function GetBindingNameForButton(buttonName)
    if not buttonName then return nil end
    local num = string.match(buttonName, "(%d+)$")
    if not num then return nil end

    if string.find(buttonName, "ActionButton") then
        return "ACTIONBUTTON" .. num
    end

    local bar = string.match(buttonName, "MultiBar(%w+)Button")
    if bar == "BottomLeft" then
        return "MULTIACTIONBAR1BUTTON" .. num
    elseif bar == "BottomRight" then
        return "MULTIACTIONBAR2BUTTON" .. num
    elseif bar == "Right" then
        return "MULTIACTIONBAR3BUTTON" .. num
    elseif bar == "Left" then
        return "MULTIACTIONBAR4BUTTON" .. num
    elseif bar == "5" then
        return "MULTIACTIONBAR5BUTTON" .. num
    elseif bar == "6" then
        return "MULTIACTIONBAR6BUTTON" .. num
    elseif bar == "7" then
        return "MULTIACTIONBAR7BUTTON" .. num
    end

    if string.find(buttonName, "StanceButton") then
        return "SHAPESHIFTBUTTON" .. num
    elseif string.find(buttonName, "PetActionButton") then
        return "BONUSACTIONBUTTON" .. num
    end

    return nil
end

-- 解析按钮的绑定键
local function ResolveBindingKey(button)
    local bindingName = GetBindingNameForButton(button:GetName())
    if not bindingName then return nil end
    local k1, k2 = GetBindingKey(bindingName)
    return k1 or k2
end

-- 更新单个按钮
local function UpdateButton(button)
    if not button or not button.HotKey then return false end

    local buttonName = button:GetName()
    if not buttonName then return false end

    -- 保存原始文本
    if not originalHotkeys[buttonName] then
        originalHotkeys[buttonName] = button.HotKey:GetText()
    end

    local bindingKey = ResolveBindingKey(button)
    if bindingKey then
        local label = GetDisplayText(bindingKey)
        if label and label ~= "" then
            button.HotKey:SetText(label)
            return true
        else
            -- 没有配置，恢复原始文本
            button.HotKey:SetText(originalHotkeys[buttonName])
        end
    else
        -- 没有绑定，恢复原始文本
        button.HotKey:SetText(originalHotkeys[buttonName])
    end

    return false
end

-- 更新所有按钮
local function UpdateAllButtons()
    local updatedCount = 0
    local buttonSets = {
        {prefix = "ActionButton", count = 12},
        {prefix = "MultiBarBottomLeftButton", count = 12},
        {prefix = "MultiBarBottomRightButton", count = 12},
        {prefix = "MultiBarRightButton", count = 12},
        {prefix = "MultiBarLeftButton", count = 12},
        {prefix = "MultiBar5Button", count = 12},
        {prefix = "MultiBar6Button", count = 12},
        {prefix = "MultiBar7Button", count = 12},
        {prefix = "StanceButton", count = 10},
        {prefix = "PetActionButton", count = 10},
    }

    for _, buttonSet in ipairs(buttonSets) do
        for i = 1, buttonSet.count do
            local button = _G[buttonSet.prefix .. i]
            if button and button.HotKey then
                if UpdateButton(button) then
                    updatedCount = updatedCount + 1
                end
            end
        end
    end

    local extraButton = _G["ExtraActionButton1"]
    if extraButton and extraButton.HotKey then
        if UpdateButton(extraButton) then
            updatedCount = updatedCount + 1
        end
    end

    return updatedCount
end

-- Hook游戏原生函数
local function HookActionButtonUpdate()
    if ActionButton_UpdateHotkeys then
        hooksecurefunc("ActionButton_UpdateHotkeys", function(button)
            if button and button.HotKey then
                C_Timer.After(0.1, function() UpdateButton(button) end)
            end
        end)
    end

    if ActionButton_Update then
        hooksecurefunc("ActionButton_Update", function(button)
            if button and button.HotKey then
                C_Timer.After(0.1, function() UpdateButton(button) end)
            end
        end)
    end

    if ActionButton_UpdateAction then
        hooksecurefunc("ActionButton_UpdateAction", function(button)
            if button and button.HotKey then
                C_Timer.After(0.2, function() UpdateButton(button) end)
            end
        end)
    end
end

-- 事件处理
local frame = CreateFrame("Frame")
frame:RegisterEvent("ADDON_LOADED")
frame:RegisterEvent("PLAYER_LOGIN")
frame:RegisterEvent("UPDATE_BINDINGS")
frame:RegisterEvent("ACTIONBAR_SLOT_CHANGED")

frame:SetScript("OnEvent", function(self, event, ...)
    if event == "ADDON_LOADED" and ... == addonName then
        -- 插件加载完成，从配置文件加载设置（只从Config.lua加载）
        local config = _G["CustomActionButtonText_Config"]
        
        -- 清空之前的映射
        keyMappings = {}
        
        -- 加载修饰键配置
        if config and config.modifiers then
            local modifiers = config.modifiers
            if modifiers.alt then keyMappings["ALT"] = modifiers.alt end
            if modifiers.ctrl then keyMappings["CTRL"] = modifiers.ctrl end
            if modifiers.shift then keyMappings["SHIFT"] = modifiers.shift end
        end
        
        -- 加载鼠标按键配置（扩展支持 BUTTON3, BUTTON4, BUTTON5 等）
        if config and config.mouseKeys then
            local mouseKeys = config.mouseKeys
            if mouseKeys.mousewheelup then keyMappings["MOUSEWHEELUP"] = mouseKeys.mousewheelup end
            if mouseKeys.mousewheeldown then keyMappings["MOUSEWHEELDOWN"] = mouseKeys.mousewheeldown end
            if mouseKeys.mousemiddlebutton then keyMappings["BUTTON3"] = mouseKeys.mousemiddlebutton end
            if mouseKeys.mousebutton4 then keyMappings["BUTTON4"] = mouseKeys.mousebutton4 end
            if mouseKeys.mousebutton5 then keyMappings["BUTTON5"] = mouseKeys.mousebutton5 end
            -- 可以继续扩展更多鼠标按键
        end
        
        -- 加载组合键配置（优先级最高，会覆盖单独键的组合显示）
        if config and config.combinations then
            for key, value in pairs(config.combinations) do
                if key and value then
                    -- 标准化键名（转大写）用于匹配
                    local normalizedKey = NormalizeKey(key)
                    keyMappings[normalizedKey] = value
                end
            end
        end

    elseif event == "PLAYER_LOGIN" then
        HookActionButtonUpdate()
        C_Timer.After(2, function()
            originalHotkeys = {}
            UpdateAllButtons()
        end)

    elseif event == "UPDATE_BINDINGS" or event == "ACTIONBAR_SLOT_CHANGED" then
        C_Timer.After(0.5, function()
            UpdateAllButtons()
        end)
    end
end)
