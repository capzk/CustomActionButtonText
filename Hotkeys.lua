-- Hotkeys.lua - 按钮更新与钩子模块

local Hotkeys = {}
local getDisplayText
local originalHotkeys = {}

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

    local bindingKey = ResolveBindingKey(button)
    if bindingKey then
        local label = getDisplayText(bindingKey)
        if label and label ~= "" then
            if not originalHotkeys[buttonName] then
                originalHotkeys[buttonName] = button.HotKey:GetText()
            end
            button.HotKey:SetText(label)
            return true
        else
            if originalHotkeys[buttonName] then
                button.HotKey:SetText(originalHotkeys[buttonName])
            end
        end
    else
        if originalHotkeys[buttonName] then
            button.HotKey:SetText(originalHotkeys[buttonName])
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
                        button.HotKey:SetText(GetBindingText(key, "KEY_", 1))
                    else
                        button.HotKey:SetText("")
                    end
                else
                    button.HotKey:SetText("")
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
            extraButton.HotKey:SetText(GetBindingText(key, "KEY_", 1))
        else
            extraButton.HotKey:SetText("")
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
