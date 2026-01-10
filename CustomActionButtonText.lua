
--[[
Custom Action Button Text - 主模块
使用内置默认或用户数据，自定义动作条按钮上的快捷键文字显示
]]--

local addonName = "CustomActionButtonText"
local Data = _G.CustomActionButtonText_Data
local savedVariableName = "CustomActionButtonTextDB"
local defaultMappings = {
    -- 修饰键（用于拼接）
    ["SHIFT"] = "S+",
    ["CTRL"] = "C+",
    ["ALT"] = "A+",

    -- 鼠标按键（基础/拼接）
    ["MOUSEWHEELUP"] = "MU",
    ["MOUSEWHEELDOWN"] = "MD",
    ["BUTTON3"] = "M3",
    ["BUTTON4"] = "M4",
    ["BUTTON5"] = "M5",

    -- 组合键（优先级最高：精确命中即使用）
    ["SHIFT-MOUSEWHEELUP"] = "SMU",
    ["CTRL-MOUSEWHEELUP"] = "CMU",
    ["ALT-MOUSEWHEELUP"] = "AMU",

    ["SHIFT-MOUSEWHEELDOWN"] = "SMD",
    ["CTRL-MOUSEWHEELDOWN"] = "CMD",
    ["ALT-MOUSEWHEELDOWN"] = "AMD",

    ["SHIFT-BUTTON3"] = "SM3",
    ["CTRL-BUTTON3"] = "CM3",
    ["ALT-BUTTON3"] = "AM3",

    ["SHIFT-BUTTON4"] = "SM4",
    ["CTRL-BUTTON4"] = "CM4",
    ["ALT-BUTTON4"] = "AM4",

    ["SHIFT-BUTTON5"] = "SM5",
    ["CTRL-BUTTON5"] = "CM5",
    ["ALT-BUTTON5"] = "AM5",
}
local lastDuplicateWarnings = {}
local lastDuplicateWarningsCount = 0
local Hotkeys = _G.CustomActionButtonText_Hotkeys

-- 调试统计：记录回退原因
local debugCounters = {
    singleDisallowed = 0,        -- 单键/数字/F键被禁止自定义
    multiModifierDisallowed = 0, -- 多重修饰键被禁止自定义
    missingMapping = 0,          -- 允许自定义但未找到映射，回退原生
}

local function ResetDebugCounters()
    debugCounters.singleDisallowed = 0
    debugCounters.multiModifierDisallowed = 0
    debugCounters.missingMapping = 0
end

local function DeepCopyTable(tbl)
    if type(tbl) ~= "table" then return tbl end
    local copy = {}
    for k, v in pairs(tbl) do
        if type(v) == "table" then
            copy[k] = DeepCopyTable(v)
        else
            copy[k] = v
        end
    end
    return copy
end

local function TableCount(tbl)
    local c = 0
    if type(tbl) ~= "table" then return c end
    for _ in pairs(tbl) do
        c = c + 1
    end
    return c
end

-- 配置映射表（从Config.lua加载）
local keyMappings = {}

-- 标准化键名（统一格式用于匹配）
local NormalizeKey = Data.NormalizeKey
local IsDisallowedKey = Data.IsDisallowedKey

local function BuildMappingsFromTable(rawMappings)
    local normalizeFn = NormalizeKey
    local disallowFn = IsDisallowedKey
    local normalized = {}
    local duplicateWarnings = {}
    if type(rawMappings) ~= "table" then
        return normalized, duplicateWarnings
    end

    for key, value in pairs(rawMappings) do
        if type(key) == "string" and value ~= nil then
            local normalizedKey = normalizeFn(key)
            local textValue = tostring(value)
            local disallowed = disallowFn(normalizedKey)
            if not disallowed then
                if normalized[normalizedKey] then
                    table.insert(duplicateWarnings, {
                        key = normalizedKey,
                        previousValue = normalized[normalizedKey],
                        newValue = textValue,
                    })
                end
                normalized[normalizedKey] = textValue
            end
        end
    end

    return normalized, duplicateWarnings
end

local function LoadDefaultMappings()
    return DeepCopyTable(defaultMappings)
end

local function SetMappings(normalized, duplicateWarnings, opts)
    opts = opts or {}
    keyMappings = normalized or {}
    lastDuplicateWarnings = duplicateWarnings or {}
    lastDuplicateWarningsCount = #lastDuplicateWarnings
    ResetDebugCounters()

    if lastDuplicateWarningsCount > 0 and not opts.silent then
        print("CustomActionButtonText: 检测到重复配置键，使用最后一次定义：")
        for i, warning in ipairs(lastDuplicateWarnings) do
            if i > 5 then
                print(string.format("  ... 还有 %d 个重复键", lastDuplicateWarningsCount - 5))
                break
            end
            print(string.format(
                "  %s: %s -> %s",
                warning.key,
                tostring(warning.previousValue),
                tostring(warning.newValue)
            ))
        end
    end

    if opts.persist then
        -- 覆盖式写入，保证每次保存都会替换旧数据
        _G[savedVariableName] = {
            mappings = DeepCopyTable(keyMappings),
            disabled = nil,
            rawText = opts.rawText,
        }
    end

    Hotkeys.UpdateAllButtons()

    if not opts.silent then
        print(string.format("CustomActionButtonText: Loaded %d mappings from %s.", TableCount(keyMappings), opts.source or "unknown"))
    end
end

local function ApplyMappings(rawMappings, opts)
    opts = opts or {}
    -- UI 层已做逐行校验，这里仅做空表防护和持久化
    local normalized = DeepCopyTable(rawMappings or {})
    if TableCount(normalized) == 0 then
        if not opts.silent then
            print("CustomActionButtonText: 没有可用映射，已忽略保存请求。")
        end
        return false, "no_valid_mappings"
    end
    SetMappings(normalized, {}, {
        persist = opts.persist,
        source = opts.source,
        silent = opts.silent,
        rawText = opts.rawText,
    })
    return true
end

local function GetMappings()
    return DeepCopyTable(keyMappings)
end

local function ResetToConfigDefaults(opts)
    opts = opts or {}
    local defaults = LoadDefaultMappings()
    SetMappings(defaults, {}, {persist = opts.persist, source = "Defaults"})
    return defaults
end

local function GetSavedMappings()
    if _G[savedVariableName] and _G[savedVariableName].mappings then
        return DeepCopyTable(_G[savedVariableName].mappings)
    end
    return nil
end

local function GetSavedRawText()
    if _G[savedVariableName] and _G[savedVariableName].rawText then
        return _G[savedVariableName].rawText
    end
    return nil
end

local function ValidateMappingEntry(keyText, valueText)
    return Data.ValidateEntry(keyText, valueText)
end

local function ShowConfigUI()
    if type(_G.CustomActionButtonText_ShowUI) == "function" then
        _G.CustomActionButtonText_ShowUI({
            GetMappings = GetMappings,
            ApplyMappings = function(m, opts)
                opts = opts or {}
                return ApplyMappings(m, {
                    persist = opts.persist ~= false,
                    source = opts.source or "UI",
                    trusted = opts.trusted,
                    rawText = opts.rawText,
                    silent = opts.silent,
                })
            end,
            ResetToDefaults = ResetToConfigDefaults,
            ValidateEntry = ValidateMappingEntry,
        })
    else
        print("CustomActionButtonText: UI module is missing.")
    end
end
-- 获取显示文本（支持组合键，限制自定义范围）
-- 允许自定义的按键类型：
-- 1. 鼠标键（单独）
-- 2. 修饰键+鼠标键
-- 3. 修饰键+字母/数字/功能键（仅单个修饰键）
-- 4. 修饰键（单独，用于构建组合）
-- 不允许：单独的字母、数字、功能键，多重修饰键组合
local function GetDisplayText(bindingKey)
    if not bindingKey or bindingKey == "" then return nil end
    
    local key = NormalizeKey(bindingKey)
    
    -- 优先级1：检查组合键完整配置（最高优先级）
    if keyMappings[key] then
        return keyMappings[key]
    end
    
    -- 检查是否为单独的字母、数字或功能键（不允许自定义）
    if string.match(key, "^[A-Z]$") or           -- 单个字母
       string.match(key, "^[0-9]$") or           -- 单个数字
       string.match(key, "^F[0-9]+$") then       -- 功能键 F1-F12等
        debugCounters.singleDisallowed = debugCounters.singleDisallowed + 1
        return nil  -- 不允许自定义，使用原生显示
    end
    
    -- 检查是否为多重修饰键组合（不允许自定义）
    local modifierCount = 0
    if string.find(key, "CTRL%-") then modifierCount = modifierCount + 1 end
    if string.find(key, "SHIFT%-") then modifierCount = modifierCount + 1 end
    if string.find(key, "ALT%-") then modifierCount = modifierCount + 1 end
    
    if modifierCount > 1 then
        debugCounters.multiModifierDisallowed = debugCounters.multiModifierDisallowed + 1
        return nil  -- 多重修饰键组合不允许自定义，使用原生显示
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
    
    -- 检查鼠标按键（允许单独自定义）
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
        -- 其他按键（字母、数字、功能键等）
        if not hasModifier then
            -- 没有修饰键的其他按键，不允许自定义，返回nil使用原始显示
            return nil
        end
        -- 有修饰键的组合，将剩余按键（字母/数字/功能键）也添加到结果中
        if key and key ~= "" then
            result = result .. key
        end
    end
    
    -- 只有在有配置且结果不为空时才返回自定义文本，否则返回nil使用原生显示
    if hasConfig and result ~= "" then
        return result
    else
        debugCounters.missingMapping = debugCounters.missingMapping + 1
        return nil
    end
end

-- 获取按钮的绑定键名
-- 重新加载配置
local function ReloadConfig()

    local loaded = false

    -- 优先尝试 SavedVariables（空表则视为无效）
    if _G[savedVariableName] and _G[savedVariableName].mappings then
        local saved = _G[savedVariableName].mappings
        if TableCount(saved) > 0 then
            local ok = ApplyMappings(saved, {persist = false, source = "SavedVariables", trusted = true})
            if ok then
                loaded = true
            end
        else
            -- 丢弃空的旧数据，后续写入默认
            _G[savedVariableName] = nil
        end
    end

    if not loaded then
        local defaults = LoadDefaultMappings()
        ApplyMappings(defaults, {persist = true, source = "Defaults", trusted = true})
    end
end

-- 斜杠命令处理
SLASH_CUSTOMACTIONBUTTONTEXT1 = "/cabt"
SlashCmdList["CUSTOMACTIONBUTTONTEXT"] = function(msg)
    local command = string.lower(strtrim(msg or ""))
    
    if command == "" or command == "ui" then
        ShowConfigUI()
    elseif command == "debug" or command == "d" then
        print("CustomActionButtonText Debug Info:")
        print("- Loaded mappings: " .. (keyMappings and "Yes" or "No"))
        local mappingCount = 0
        if keyMappings then
            for k, v in pairs(keyMappings) do
                mappingCount = mappingCount + 1
            end
        end
        print("- Total mappings: " .. mappingCount)
        local hasOriginal, originalCount = Hotkeys.GetOriginalHotkeysInfo()
        print("- Original hotkeys saved: " .. (hasOriginal and "Yes" or "No"))
        print("- Original hotkeys count: " .. originalCount)
        print("- Duplicate mappings on last reload: " .. lastDuplicateWarningsCount)
        print("- Fallback stats (since last reload):")
        print(string.format("  single keys disallowed: %d", debugCounters.singleDisallowed))
        print(string.format("  multi modifiers disallowed: %d", debugCounters.multiModifierDisallowed))
        print(string.format("  allowed but missing mapping (native used): %d", debugCounters.missingMapping))
    else
        print("CustomActionButtonText Commands:")
        print("  /cabt - Open settings UI")
        print("  /cabt debug (or /cabt d) - Show debug information")
    end
end

-- 导出简单接口（供外部或测试使用）
CustomActionButtonText_API = {
    GetMappings = GetMappings,
    ApplyMappings = ApplyMappings,
    ResetToDefaults = ResetToConfigDefaults,
    GetDefaultMappings = LoadDefaultMappings,
    GetSavedMappings = GetSavedMappings,
    ValidateEntry = ValidateMappingEntry,
    Hotkeys = Hotkeys,
    GetSavedRawText = GetSavedRawText,
}
-- 事件处理
local frame = CreateFrame("Frame")
frame:RegisterEvent("ADDON_LOADED")
frame:RegisterEvent("PLAYER_LOGIN")
frame:RegisterEvent("UPDATE_BINDINGS")
frame:RegisterEvent("ACTIONBAR_SLOT_CHANGED")

frame:SetScript("OnEvent", function(self, event, ...)
    if event == "ADDON_LOADED" and ... == addonName then
        -- 插件加载完成，读取用户数据；缺失时使用内置默认
        ReloadConfig()

    elseif event == "PLAYER_LOGIN" then
        Hotkeys.SetDisplayTextProvider(GetDisplayText)
        Hotkeys.HookActionButtonUpdate()
        C_Timer.After(2, function()
            Hotkeys.UpdateAllButtons()
        end)

    elseif event == "UPDATE_BINDINGS" or event == "ACTIONBAR_SLOT_CHANGED" then
        C_Timer.After(0.5, function()
            Hotkeys.UpdateAllButtons()
        end)
    end
end)
