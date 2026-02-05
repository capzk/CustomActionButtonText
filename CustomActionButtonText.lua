local addonName = "CustomActionButtonText"
local savedVariableName = "CustomActionButtonTextDB"
local currentTemplateVersion = 1
local Data = _G.CustomActionButtonText_Data
local NormalizeKey = Data.NormalizeKey
local defaultMappings = {
    -- 修饰键
    ["SHIFT"] = "S-",
    ["CTRL"] = "C-",
    ["ALT"] = "A-",

    -- 鼠标按键
    ["MOUSEWHEELUP"] = "MU",
    ["MOUSEWHEELDOWN"] = "MD",
    ["BUTTON3"] = "M3",
    ["BUTTON4"] = "M4",
    ["BUTTON5"] = "M5",

    -- 其他按键
    ["SPACE"] = "Sp",
}
local Hotkeys = _G.CustomActionButtonText_Hotkeys

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

local keyMappings = {}

local function LoadDefaultMappings()
    return DeepCopyTable(defaultMappings)
end

local function BuildTemplateText(defaults)
    local d = defaults or {}
    local function val(key, fallback)
        return d[key] or fallback or ""
    end
    local lines = {
        "# ==================================================",
        "# Custom Action Button Text",
        "# https://www.curseforge.com/wow/addons/customactionbuttontext",
        "# Hotkey Display Config",
        "# ==================================================",
        "# Shortcuts",
        "# Ctrl+S 保存 | Ctrl+Z 撤销 | Ctrl+Y 重做 | ESC 取消焦点",
        "# Ctrl+S Save | Ctrl+Z Undo | Ctrl+Y Redo | ESC Clear Focus",
        "# Reset",
        "# /cabt reset 清除本地配置并恢复默认模板",
        "# ==================================================",
        "# 说明：组合键精确匹配优先；否则自动拼接",
        "# Note: Combo exact match first; otherwise auto-join",
        "# 版本更新后建议运行 /cabt reset 清空本地配置避免异常",
        "# After update, run /cabt reset to clear local config if issues",
        "# ==================================================",
        "",
        "# 修饰键",
        "# Modifiers",
        string.format("SHIFT = %s", val("SHIFT", "S-")),
        string.format("CTRL = %s", val("CTRL", "C-")),
        string.format("ALT = %s", val("ALT", "A-")),
        "",
        "# 鼠标按键",
        "# Mouse Buttons",
        string.format("MOUSEWHEELUP = %s", val("MOUSEWHEELUP", "MU")),
        string.format("MOUSEWHEELDOWN = %s", val("MOUSEWHEELDOWN", "MD")),
        string.format("BUTTON3 = %s", val("BUTTON3", "M3")),
        string.format("BUTTON4 = %s", val("BUTTON4", "M4")),
        string.format("BUTTON5 = %s", val("BUTTON5", "M5")),
        "",
        "# 其他按键",
        "# Other Keys",
        string.format("SPACE = %s", val("SPACE", "Sp")),
        "",
        "# 例子：组合键优先",
        "# Example: Combo override",
        "# SHIFT-MOUSEWHEELUP = SMU",
        "# SHIFT-MOUSEWHEELDOWN = SMD",
        "# CTRL-SPACE = CSp",
        "# ALT-MOUSEWHEELUP = AMU",
        "# SHIFT-BUTTON4 = SM4",
    }
    return table.concat(lines, "\n")
end

local function SetMappings(normalized, opts)
    opts = opts or {}
    keyMappings = normalized or {}

    if opts.persist then
        local saved = _G[savedVariableName] or {}
        if opts.rawText ~= nil then
            saved.rawText = opts.rawText
        end
        saved.mappings = nil
        saved.templateVersion = opts.templateVersion or saved.templateVersion or currentTemplateVersion
        _G[savedVariableName] = saved
    end

    Hotkeys.UpdateAllButtons()

    if not opts.silent then
        print(string.format("CustomActionButtonText: Loaded %d mappings from %s.", TableCount(keyMappings), opts.source or "unknown"))
    end
end

local function SaveRawText(rawText, templateVersion)
    local saved = _G[savedVariableName] or {}
    saved.rawText = rawText
    saved.mappings = nil
    saved.templateVersion = templateVersion or saved.templateVersion or currentTemplateVersion
    _G[savedVariableName] = saved
end

local function ApplyMappings(rawMappings, opts)
    opts = opts or {}
    local normalized = DeepCopyTable(rawMappings or {})
    SetMappings(normalized, {
        source = opts.source,
        silent = opts.silent,
        persist = opts.persist,
        rawText = opts.rawText,
        templateVersion = opts.templateVersion,
    })
    return true
end

local function GetMappings()
    return DeepCopyTable(keyMappings)
end

local function ResetToConfigDefaults(opts)
    opts = opts or {}
    local defaults = LoadDefaultMappings()
    SetMappings(defaults, {persist = opts.persist, source = "Defaults", rawText = opts.rawText, templateVersion = opts.templateVersion})
    return defaults
end

local function ClearSavedConfig()
    _G[savedVariableName] = nil
end

local function GetSavedMappings()
    if _G[savedVariableName] and _G[savedVariableName].mappings then
        return DeepCopyTable(_G[savedVariableName].mappings)
    end
    return nil
end

local function GetSavedRawText()
    if _G[savedVariableName] and _G[savedVariableName].rawText ~= nil then
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
                    templateVersion = opts.templateVersion,
                })
            end,
            SaveRawText = SaveRawText,
            ResetToDefaults = ResetToConfigDefaults,
            ValidateEntry = ValidateMappingEntry,
            GetDefaultMappings = LoadDefaultMappings,
            GetSavedMappings = GetSavedMappings,
            GetSavedRawText = GetSavedRawText,
            BuildTemplateText = BuildTemplateText,
        })
    else
        print("CustomActionButtonText: UI module is missing.")
    end
end
-- 生成显示文本：精确匹配优先，其次自动拼接（修饰键+基础键，基础键无配置则使用原始键）
local function GetDisplayText(bindingKey)
    if not bindingKey or bindingKey == "" then return nil end
    local key = NormalizeKey(bindingKey)
    local direct = keyMappings[key]
    if direct then
        return direct
    end

    local baseKey = key
    local result = ""
    local hasModifier = false
    local hasConfig = false

    local function AppendModifier(modKey, token)
        if string.find(baseKey, token) then
            hasModifier = true
            local modText = keyMappings[modKey]
            if modText and modText ~= "" then
                result = result .. modText
                hasConfig = true
            end
            baseKey = string.gsub(baseKey, token, "")
        end
    end

    AppendModifier("CTRL", "CTRL%-")
    AppendModifier("SHIFT", "SHIFT%-")
    AppendModifier("ALT", "ALT%-")

    baseKey = string.gsub(baseKey, "^%-+", "")
    baseKey = string.gsub(baseKey, "%-+$", "")

    if baseKey ~= "" then
        local baseText = keyMappings[baseKey]
        if baseText and baseText ~= "" then
            result = result .. baseText
            hasConfig = true
        elseif hasModifier then
            result = result .. baseKey
        end
    end

    if hasConfig and result ~= "" then
        return result
    end
    return nil
end

local function ReloadConfig()
    local saved = _G[savedVariableName]
    if saved then
        local raw = saved.rawText
        if raw ~= nil then
            local parsed, ok, bad = Data.ParseText(raw)
            if ok > 0 then
                ApplyMappings(parsed, {persist = false, source = "SavedVariables(raw)", trusted = true, rawText = raw, templateVersion = saved.templateVersion, silent = true})
            end
            return
        end
        if saved.mappings and TableCount(saved.mappings) > 0 then
            local rawText = Data.SerializeMappings(saved.mappings)
            ApplyMappings(saved.mappings, {persist = true, source = "SavedVariables(migrate)", trusted = true, rawText = rawText, templateVersion = saved.templateVersion, silent = true})
            return
        end
    end

    local defaults = LoadDefaultMappings()
    local template = BuildTemplateText(defaults)
    ApplyMappings(defaults, {persist = false, source = "Defaults", trusted = true, rawText = template, templateVersion = currentTemplateVersion, silent = true})
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
    elseif command == "reset" or command == "r" then
        ClearSavedConfig()
        local defaults = ResetToConfigDefaults({
            persist = false,
            rawText = BuildTemplateText(LoadDefaultMappings()),
            templateVersion = currentTemplateVersion,
        })
        if type(_G.CustomActionButtonText_ResetEditorTemplate) == "function" then
            _G.CustomActionButtonText_ResetEditorTemplate(defaults)
        end
        print("CustomActionButtonText: 已清除本地配置并恢复默认模板（未保存）。")
    else
        print("CustomActionButtonText Commands:")
        print("  /cabt - Open settings UI")
        print("  /cabt debug (or /cabt d) - Show debug information")
        print("  /cabt reset (or /cabt r) - Reset mappings to default template")
    end
end

-- 导出简单接口（供外部或测试使用）
CustomActionButtonText_API = {
    GetMappings = GetMappings,
    ApplyMappings = ApplyMappings,
    SaveRawText = SaveRawText,
    ResetToDefaults = ResetToConfigDefaults,
    GetDefaultMappings = LoadDefaultMappings,
    GetSavedMappings = GetSavedMappings,
    GetSavedRawText = GetSavedRawText,
    ValidateEntry = ValidateMappingEntry,
    Hotkeys = Hotkeys,
    BuildTemplateText = BuildTemplateText,
    TemplateVersion = currentTemplateVersion,
}
-- 事件处理
local frame = CreateFrame("Frame")
frame:RegisterEvent("ADDON_LOADED")
frame:RegisterEvent("PLAYER_LOGIN")
frame:RegisterEvent("UPDATE_BINDINGS")
frame:RegisterEvent("ACTIONBAR_SLOT_CHANGED")
frame:RegisterEvent("PLAYER_REGEN_ENABLED")  -- 12.0兼容性：战斗结束事件

frame:SetScript("OnEvent", function(self, event, ...)
    if event == "ADDON_LOADED" and ... == addonName then
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
    
    elseif event == "PLAYER_REGEN_ENABLED" then
        -- 12.0兼容性：战斗结束后更新按钮，确保在非战斗状态下应用更改
        C_Timer.After(1, function()
            Hotkeys.UpdateAllButtons()
        end)
    end
end)
