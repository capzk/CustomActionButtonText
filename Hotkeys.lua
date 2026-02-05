-- Hotkeys.lua - 按钮更新与钩子模块

local Hotkeys = {}
local getDisplayText
local originalHotkeys = {}

local function GetBindingNameForButton(buttonName)
    if not buttonName then return nil end
    if buttonName == "ExtraActionButton1" then
        return "EXTRAACTIONBUTTON1"
    end
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

local function ResolveBindingKey(button)
    local bindingName = GetBindingNameForButton(button:GetName())
    if not bindingName then return nil end
    local k1, k2 = GetBindingKey(bindingName)
    return k1 or k2
end

function Hotkeys.SetDisplayTextProvider(fn)
    getDisplayText = fn
end

local function UpdateButton(button)
    if not button or not button.HotKey or not getDisplayText then return false end

    local buttonName = button:GetName()
    if not buttonName then return false end

    -- 12.0兼容性：在战斗中跳过更新以避免保护错误
    if InCombatLockdown() then
        return false
    end

    local bindingKey = ResolveBindingKey(button)
    if bindingKey then
        local label = getDisplayText(bindingKey)
        if label and label ~= "" then
            if not originalHotkeys[buttonName] then
                originalHotkeys[buttonName] = button.HotKey:GetText()
            end
            -- 使用pcall保护SetText调用，防止12.0的secret values错误
            local success, err = pcall(function()
                button.HotKey:SetText(label)
            end)
            if not success then
                -- 如果SetText失败，记录但不中断执行
                return false
            end
            return true
        else
            if originalHotkeys[buttonName] then
                local success, err = pcall(function()
                    button.HotKey:SetText(originalHotkeys[buttonName])
                end)
            end
        end
    else
        if originalHotkeys[buttonName] then
            local success, err = pcall(function()
                button.HotKey:SetText(originalHotkeys[buttonName])
            end)
        end
    end

    return false
end

function Hotkeys.UpdateAllButtons()
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

function Hotkeys.HookActionButtonUpdate()
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

function Hotkeys.ResetAllButtons()
    -- 12.0兼容性：在战斗中不执行重置操作
    if InCombatLockdown() then
        return
    end

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

    originalHotkeys = {}
    
    for _, buttonSet in ipairs(buttonSets) do
        for i = 1, buttonSet.count do
            local button = _G[buttonSet.prefix .. i]
            if button and button.HotKey then
                local bindingName = GetBindingNameForButton(button:GetName())
                if bindingName then
                    local k1, k2 = GetBindingKey(bindingName)
                    local key = k1 or k2
                    if key then
                        pcall(function()
                            button.HotKey:SetText(GetBindingText(key, "KEY_", 1))
                        end)
                    else
                        pcall(function()
                            button.HotKey:SetText("")
                        end)
                    end
                else
                    pcall(function()
                        button.HotKey:SetText("")
                    end)
                end
            end
        end
    end

    local extraButton = _G["ExtraActionButton1"]
    if extraButton and extraButton.HotKey then
        local bindingName = "EXTRAACTIONBUTTON1"
        local k1, k2 = GetBindingKey(bindingName)
        local key = k1 or k2
        if key then
            pcall(function()
                extraButton.HotKey:SetText(GetBindingText(key, "KEY_", 1))
            end)
        else
            pcall(function()
                extraButton.HotKey:SetText("")
            end)
        end
    end
end

function Hotkeys.GetOriginalHotkeysInfo()
    local count = 0
    for _ in pairs(originalHotkeys) do
        count = count + 1
    end
    return originalHotkeys ~= nil, count
end

_G.CustomActionButtonText_Hotkeys = Hotkeys
