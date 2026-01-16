local addonName = "CustomActionButtonText"
local savedVariableName = "CustomActionButtonTextDB"
local currentTemplateVersion = 1
local Data = _G.CustomActionButtonText_Data
local defaultMappings = {
    -- 修饰键（必须配置，用于组合键拼接）
    ["SHIFT"] = "S",
    ["CTRL"] = "C",
    ["ALT"] = "A",
    ["SPACE"] = "Sp",  -- 空格键可单独使用或被修饰

    -- 鼠标按键（必须配置，常用）
    ["MOUSEWHEELUP"] = "MU",
    ["MOUSEWHEELDOWN"] = "MD",
    ["BUTTON3"] = "M3",
    ["BUTTON4"] = "M4",
    ["BUTTON5"] = "M5",

    -- 修饰键 + 鼠标组合（示例，每类一个）
    ["SHIFT-MOUSEWHEELUP"] = "SMU",
    ["CTRL-BUTTON3"] = "CM3",
    ["ALT-BUTTON4"] = "AM4",

    -- 修饰键 + 空格组合（空格被其他修饰键修饰）
    ["SHIFT-SPACE"] = "SSp",
    ["CTRL-SPACE"] = "CSp",

    -- 特殊键（常用）
    ["NUMPAD1"] = "N1",
    ["NUMPAD2"] = "N2",
    ["NUMPAD3"] = "N3",

    -- 修饰键 + 字母/数字（示例）
    ["SHIFT-1"] = "S1",
    ["CTRL-E"] = "CE",
}
local lastDuplicateWarnings = {}
local lastDuplicateWarningsCount = 0
local Hotkeys = _G.CustomActionButtonText_Hotkeys

local debugCounters = {
    singleDisallowed = 0,
    multiModifierDisallowed = 0,
    missingMapping = 0,
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

local keyMappings = {}

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

local function BuildTemplateText(defaults)
    local d = defaults or {}
    local function val(key, fallback)
        return d[key] or fallback or ""
    end
    local lines = {
        "# ========================================================================",
        "# Custom Action Button Text - 快捷键显示自定义配置",
        "# ========================================================================",
        "# 插件更新：https://www.curseforge.com/wow/addons/customactionbuttontext",
        "# 快捷键：Ctrl+S 保存 | Ctrl+Z 撤销 | Ctrl+Y 重做 | ESC 取消焦点",
        "# 提示：显示文本建议不超过3个字符，超过可能显示成点",
        "# ========================================================================",
        "",
        "# 修饰键（必须配置）| Modifiers (Required)",
        string.format("SHIFT = %s", val("SHIFT", "S")),
        string.format("CTRL = %s", val("CTRL", "C")),
        string.format("ALT = %s", val("ALT", "A")),
        string.format("SPACE = %s", val("SPACE", "Sp")),
        "",
        "# 鼠标按键 | Mouse Buttons",
        string.format("MOUSEWHEELUP = %s", val("MOUSEWHEELUP", "MU")),
        string.format("MOUSEWHEELDOWN = %s", val("MOUSEWHEELDOWN", "MD")),
        string.format("BUTTON3 = %s", val("BUTTON3", "M3")),
        string.format("BUTTON4 = %s", val("BUTTON4", "M4")),
        string.format("BUTTON5 = %s", val("BUTTON5", "M5")),
        "",
        "# 修饰键 + 鼠标组合 | Modifier + Mouse Combinations",
        string.format("SHIFT-MOUSEWHEELUP = %s", val("SHIFT-MOUSEWHEELUP", "SMU")),
        string.format("CTRL-BUTTON3 = %s", val("CTRL-BUTTON3", "CM3")),
        string.format("ALT-BUTTON4 = %s", val("ALT-BUTTON4", "AM4")),
        "",
        "# 修饰键 + 空格 | Modifier + Space (空格被修饰)",
        string.format("SHIFT-SPACE = %s", val("SHIFT-SPACE", "SSp")),
        string.format("CTRL-SPACE = %s", val("CTRL-SPACE", "CSp")),
        "",
        "# 特殊键 | Special Keys",
        string.format("NUMPAD1 = %s", val("NUMPAD1", "N1")),
        string.format("NUMPAD2 = %s", val("NUMPAD2", "N2")),
        string.format("NUMPAD3 = %s", val("NUMPAD3", "N3")),
        "",
        "# 修饰键 + 字母/数字 | Modifier + Letter/Number",
        string.format("SHIFT-1 = %s", val("SHIFT-1", "S1")),
        string.format("CTRL-E = %s", val("CTRL-E", "CE")),
        "",
        "# 自定义区域 | Custom Area",
        "# 在此添加你的配置... | Add your configurations here...",
        "",
        "",
        "",
        "# ========================================================================",
        "# 详细说明（可折叠/忽略）| Detailed Guide (Collapsible/Ignorable)",
        "# ========================================================================",
        "#",
        "# 【使用说明】| Usage Guide",
        "# • 格式：KEY = VALUE（每行一个配置）",
        "# • 注释：# 或 // 或 -- 开头",
        "# • 保存：Ctrl+S 保存并应用",
        "# • 撤销：Ctrl+Z 撤销，Ctrl+Y 重做",
        "# • 重置：/cabt reset 恢复默认",
        "#",
        "# • Format: KEY = VALUE (one per line)",
        "# • Comments: Start with # or // or --",
        "# • Save: Ctrl+S to save and apply",
        "# • Undo: Ctrl+Z to undo, Ctrl+Y to redo",
        "# • Reset: /cabt reset to restore defaults",
        "#",
        "# 【配置规则】| Configuration Rules",
        "# ✅ 允许自定义 | Allowed:",
        "#    - 修饰键：SHIFT, CTRL, ALT",
        "#    - 空格键：SPACE（可单独使用或被修饰，如 SHIFT-SPACE）",
        "#    - 鼠标键：滚轮、中键、侧键",
        "#    - 特殊键：方向键、小键盘等",
        "#    - 组合键：单个修饰键+其他键",
        "#",
        "# ❌ 不允许 | Not allowed:",
        "#    - 单独的字母/数字/F键：A, 1, F1",
        "#    - 多重修饰键：CTRL-SHIFT-T",
        "#    - 空格作为修饰键：SPACE-MOUSEWHEELUP（游戏不支持）",
        "#",
        "# 【优先级】| Priority",
        "# 1. 精确匹配 | Exact match: SHIFT-MOUSEWHEELUP = SMU",
        "# 2. 自动拼接 | Auto compose: SHIFT + MOUSEWHEELUP = S + MU = SMU",
        "# 3. 原生显示 | Native display: 未配置的键使用游戏原生文本",
        "#",
        "# 【更多示例】| More Examples",
        "#",
        "# 鼠标按键扩展 | Extended mouse buttons:",
        "# BUTTON6 = M6",
        "# SHIFT-MOUSEWHEELDOWN = SMD",
        "# SHIFT-BUTTON3 = SM3",
        "# CTRL-MOUSEWHEELUP = CMU",
        "# CTRL-MOUSEWHEELDOWN = CMD",
        "# CTRL-BUTTON4 = CM4",
        "# ALT-MOUSEWHEELUP = AMU",
        "# ALT-BUTTON3 = AM3",
        "# ALT-BUTTON5 = AM5",
        "#",
        "# 修饰键 + 空格 | Modifier + Space (空格被修饰):",
        "# ALT-SPACE = ASp",
        "#",
        "# 小键盘 | Numpad:",
        "# NUMPAD4 = N4",
        "# NUMPAD5 = N5",
        "# NUMPAD6 = N6",
        "# NUMPAD7 = N7",
        "# NUMPAD8 = N8",
        "# NUMPAD9 = N9",
        "# NUMPAD0 = N0",
        "#",
        "# 方向键 | Arrow keys:",
        "# UP = ↑",
        "# DOWN = ↓",
        "# LEFT = ←",
        "# RIGHT = →",
        "#",
        "# 其他特殊键 | Other special keys:",
        "# PAGEUP = PgU",
        "# PAGEDOWN = PgD",
        "# HOME = Hom",
        "# END = End",
        "# INSERT = Ins",
        "# DELETE = Del",
        "#",
        "# 修饰键 + 数字 | Modifier + Numbers:",
        "# SHIFT-2 = S2",
        "# CTRL-2 = C2",
        "# ALT-3 = A3",
        "#",
        "# 修饰键 + 字母 | Modifier + Letters:",
        "# SHIFT-A = SA",
        "# SHIFT-Q = SQ",
        "# CTRL-W = CW",
        "# ALT-R = AR",
        "#",
        "# 【支持的所有特殊键】| Supported Special Keys",
        "# 修饰键 | Modifiers:",
        "#   SHIFT, CTRL, ALT, SPACE",
        "#",
        "# 功能键 | Function keys:",
        "#   TAB, ESCAPE, ENTER, BACKSPACE, DELETE, INSERT",
        "#",
        "# 导航键 | Navigation:",
        "#   HOME, END, PAGEUP, PAGEDOWN",
        "#",
        "# 方向键 | Arrows:",
        "#   UP, DOWN, LEFT, RIGHT",
        "#",
        "# 小键盘 | Numpad:",
        "#   NUMPAD0-9, NUMPADMULTIPLY(*), NUMPADDIVIDE(/),",
        "#   NUMPADPLUS(+), NUMPADMINUS(-), NUMPADDECIMAL(.)",
        "# ========================================================================",
    }
    return table.concat(lines, "\n")
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
        _G[savedVariableName] = {
            mappings = DeepCopyTable(keyMappings),
            rawText = opts.rawText,
            templateVersion = opts.templateVersion or currentTemplateVersion,
        }
    end

    Hotkeys.UpdateAllButtons()

    if not opts.silent then
        print(string.format("CustomActionButtonText: Loaded %d mappings from %s.", TableCount(keyMappings), opts.source or "unknown"))
    end
end

local function ApplyMappings(rawMappings, opts)
    opts = opts or {}
    -- 空表防护
    local normalized = DeepCopyTable(rawMappings or {})
    if TableCount(normalized) == 0 then
        if not opts.silent then
            print("CustomActionButtonText: 没有可用映射，已忽略保存请求。")
        end
        return false, "no_valid_mappings"
    end
    SetMappings(normalized, {}, {
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
    SetMappings(defaults, {}, {persist = opts.persist, source = "Defaults", rawText = opts.rawText, templateVersion = opts.templateVersion})
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
                    templateVersion = opts.templateVersion,
                })
            end,
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
-- 生成显示文本：优先精确匹配；单修饰拼接允许，裸字母/数字/F键与多修饰返回原生文本
local function GetDisplayText(bindingKey)
    if not bindingKey or bindingKey == "" then return nil end
    
    local key = NormalizeKey(bindingKey)
    
    if keyMappings[key] then
        return keyMappings[key]
    end
    
    -- 单独的字母、数字、功能键不允许自定义（显示原生）
    if string.match(key, "^[A-Z]$") or
       string.match(key, "^[0-9]$") or
       string.match(key, "^F[0-9]+$") then
        debugCounters.singleDisallowed = debugCounters.singleDisallowed + 1
        return nil
    end
    
    local modifierCount = 0
    if string.find(key, "CTRL%-") then modifierCount = modifierCount + 1 end
    if string.find(key, "SHIFT%-") then modifierCount = modifierCount + 1 end
    if string.find(key, "ALT%-") then modifierCount = modifierCount + 1 end
    
    if modifierCount > 1 then
        debugCounters.multiModifierDisallowed = debugCounters.multiModifierDisallowed + 1
        return nil
    end
    
    local result = ""
    local hasModifier = false
    local hasConfig = false
    
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
    
    -- 检查鼠标键
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
        local buttonNum = string.match(key, "^BUTTON(%d+)$")
        local buttonKey = "BUTTON" .. buttonNum
        local mouseText = keyMappings[buttonKey]
        if mouseText then
            result = result .. mouseText
            hasConfig = true
        end
    else
        -- 检查是否为特殊键（允许单独配置）
        local specialKeys = {
            "SPACE", "TAB", "ESCAPE", "ENTER", "BACKSPACE", "DELETE", "INSERT",
            "HOME", "END", "PAGEUP", "PAGEDOWN",
            "UP", "DOWN", "LEFT", "RIGHT",
            "NUMPAD0", "NUMPAD1", "NUMPAD2", "NUMPAD3", "NUMPAD4",
            "NUMPAD5", "NUMPAD6", "NUMPAD7", "NUMPAD8", "NUMPAD9",
            "NUMPADMULTIPLY", "NUMPADDIVIDE", "NUMPADPLUS", "NUMPADMINUS", "NUMPADDECIMAL",
            "BACKQUOTE", "MINUS", "EQUALS", "LEFTBRACKET", "RIGHTBRACKET",
            "BACKSLASH", "SEMICOLON", "APOSTROPHE", "COMMA", "PERIOD", "SLASH",
        }
        
        local isSpecialKey = false
        for _, specialKey in ipairs(specialKeys) do
            if key == specialKey then
                isSpecialKey = true
                break
            end
        end
        
        if isSpecialKey then
            -- 特殊键：检查是否有配置
            local specialText = keyMappings[key]
            if specialText then
                result = result .. specialText
                hasConfig = true
            elseif not hasModifier then
                -- 没有修饰键且没有配置，返回nil使用原生显示
                return nil
            end
        elseif not hasModifier then
            -- 其他键没有修饰键，不允许自定义
            return nil
        else
            -- 有修饰键的组合，将剩余按键添加到结果中
            if key and key ~= "" then
                result = result .. key
            end
        end
    end
    
    if hasConfig and result ~= "" then
        return result
    else
        debugCounters.missingMapping = debugCounters.missingMapping + 1
        return nil
    end
end

local function ReloadConfig()
    local saved = _G[savedVariableName]
    if saved then
        local raw = saved.rawText
        if raw and raw ~= "" then
            local parsed, ok, bad = Data.ParseText(raw)
            if ok > 0 and bad == 0 then
                ApplyMappings(parsed, {persist = false, source = "SavedVariables(raw)", trusted = true, rawText = raw, templateVersion = saved.templateVersion})
                return
            else
                print(string.format("CustomActionButtonText: 存档解析失败（有效:%d 无效:%d），已回退默认模板。", ok or 0, bad or 0))
            end
        end
        if saved.mappings and TableCount(saved.mappings) > 0 then
            ApplyMappings(saved.mappings, {persist = false, source = "SavedVariables(mappings)", trusted = true, rawText = raw, templateVersion = saved.templateVersion})
            return
        end
    end

    local defaults = LoadDefaultMappings()
    local template = BuildTemplateText(defaults)
    ApplyMappings(defaults, {persist = true, source = "Defaults", trusted = true, rawText = template, templateVersion = currentTemplateVersion})
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
    elseif command == "reset" or command == "r" then
        local defaults = ResetToConfigDefaults({
            persist = true,
            rawText = BuildTemplateText(LoadDefaultMappings()),
            templateVersion = currentTemplateVersion,
        })
        if type(_G.CustomActionButtonText_ResetEditorTemplate) == "function" then
            _G.CustomActionButtonText_ResetEditorTemplate(defaults)
        end
        print("CustomActionButtonText: 已重置为默认模板并应用（存档已更新）。")
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
    end
end)
