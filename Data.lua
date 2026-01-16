-- Data.lua - 文本解析与序列化

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

local function NormalizeKey(key)
    if not key or key == "" then return "" end
    return string.upper(key)
end

local function IsDisallowedKey(normalizedKey)
    -- 修饰键：允许单独配置
    if normalizedKey == "SHIFT" or normalizedKey == "CTRL" or normalizedKey == "ALT" then
        return false
    end

    -- 检查是否为多重修饰键组合（不允许）
    local key = normalizedKey
    local modifierCount = 0
    if string.find(key, "CTRL%-") then
        modifierCount = modifierCount + 1
        key = string.gsub(key, "CTRL%-", "")
    end
    if string.find(key, "SHIFT%-") then
        modifierCount = modifierCount + 1
        key = string.gsub(key, "SHIFT%-", "")
    end
    if string.find(key, "ALT%-") then
        modifierCount = modifierCount + 1
        key = string.gsub(key, "ALT%-", "")
    end

    if modifierCount > 1 then
        return true
    end

    -- 如果有修饰键，则基础键部分允许（已经在组合中）
    if modifierCount > 0 then
        return false
    end

    -- 以下是没有修饰键的单独键判断

    -- 特殊键：允许单独配置
    local specialKeys = {
        -- 空格和常用特殊键
        "SPACE", "TAB", "ESCAPE", "ENTER", "BACKSPACE", "DELETE", "INSERT",
        -- 导航键
        "HOME", "END", "PAGEUP", "PAGEDOWN",
        -- 方向键
        "UP", "DOWN", "LEFT", "RIGHT",
        -- 小键盘数字
        "NUMPAD0", "NUMPAD1", "NUMPAD2", "NUMPAD3", "NUMPAD4",
        "NUMPAD5", "NUMPAD6", "NUMPAD7", "NUMPAD8", "NUMPAD9",
        -- 小键盘特殊键
        "NUMPADMULTIPLY", "NUMPADDIVIDE", "NUMPADPLUS", "NUMPADMINUS", "NUMPADDECIMAL",
        -- 符号键（可能显示较长）
        "BACKQUOTE", "MINUS", "EQUALS", "LEFTBRACKET", "RIGHTBRACKET",
        "BACKSLASH", "SEMICOLON", "APOSTROPHE", "COMMA", "PERIOD", "SLASH",
    }
    
    for _, specialKey in ipairs(specialKeys) do
        if normalizedKey == specialKey then
            return false
        end
    end

    -- 鼠标键：允许单独配置（已在其他地方处理，这里也明确允许）
    if string.match(normalizedKey, "^BUTTON%d+$") or 
       normalizedKey == "MOUSEWHEELUP" or 
       normalizedKey == "MOUSEWHEELDOWN" then
        return false
    end

    -- 普通键：单独的字母、数字、功能键不允许自定义
    if string.match(normalizedKey, "^[A-Z]$") or           -- 单个字母
       string.match(normalizedKey, "^[0-9]$") or           -- 单个数字
       string.match(normalizedKey, "^F[0-9]+$") then       -- 功能键 F1-F12等
        return true
    end

    -- 其他未知键：默认允许
    return false
end

local function BuildMappingsFromTable(rawMappings)
    local normalized = {}
    if type(rawMappings) ~= "table" then
        return normalized
    end

    for key, value in pairs(rawMappings) do
        if type(key) == "string" and value ~= nil then
            local normalizedKey = NormalizeKey(key)
            local textValue = tostring(value)
            local trimmedValue = string.match(textValue, "^%s*(.-)%s*$") or ""
            local disallowed = IsDisallowedKey(normalizedKey)
            if not disallowed and trimmedValue ~= "" then
                normalized[normalizedKey] = textValue
            end
        end
    end

    return normalized
end

local function ValidateEntry(keyText, valueText)
    local normalized = BuildMappingsFromTable({[keyText] = valueText})
    if not next(normalized) then
        return nil
    end
    local nKey, nVal = next(normalized)
    return nKey, nVal
end

local function ParseText(text)
    local parsed = {}
    local validCount = 0
    local invalidCount = 0
    local invalidReasons = {}

    local function StripComments(line)
        if not line or line == "" then return "" end
        local earliest
        local markers = {"#", "//", "--"}
        for _, marker in ipairs(markers) do
            local searchStart = 1
            while true do
                local pos = string.find(line, marker, searchStart, true)
                if not pos then break end
                local prevChar = pos > 1 and string.sub(line, pos - 1, pos - 1) or ""
                if prevChar == "" or string.match(prevChar, "%s") then
                    if not earliest or pos < earliest then
                        earliest = pos
                    end
                    break
                end
                searchStart = pos + 1
            end
        end
        if earliest then
            return string.sub(line, 1, earliest - 1)
        end
        return line
    end

    for line in string.gmatch(text or "", "[^\r\n]+") do
        local noComments = StripComments(line)
        local trimmed = string.match(noComments, "^%s*(.-)%s*$")
        if trimmed ~= "" then
            local keyPart, valuePart = string.match(trimmed, "^(.-)%s*=%s*(.+)$")
            if not keyPart then
                keyPart, valuePart = string.match(trimmed, "^(%S+)%s+(.+)$")
            end
            if keyPart and valuePart then
                local trimmedVal = string.match(valuePart, "^%s*(.-)%s*$") or ""
                if trimmedVal == "" then
                    invalidCount = invalidCount + 1
                    if #invalidReasons < 3 then
                        table.insert(invalidReasons, string.format("空值: %s", trimmed))
                    end
                else
                    local nKey, nVal = ValidateEntry(keyPart, valuePart)
                    if nKey then
                        parsed[nKey] = nVal
                        validCount = validCount + 1
                    else
                        invalidCount = invalidCount + 1
                        if #invalidReasons < 3 then
                            table.insert(invalidReasons, string.format("非法键或不允许: %s", trimmed))
                        end
                    end
                end
            else
                invalidCount = invalidCount + 1
                if #invalidReasons < 3 then
                    table.insert(invalidReasons, string.format("格式错误: %s", trimmed))
                end
            end
        end
    end

    return parsed, validCount, invalidCount, invalidReasons
end

local function SerializeMappings(mappings)
    local keys = {}
    for k in pairs(mappings or {}) do
        table.insert(keys, k)
    end
    table.sort(keys)
    local lines = {}
    for _, k in ipairs(keys) do
        table.insert(lines, string.format("%s = %s", k, tostring(mappings[k])))
    end
    return table.concat(lines, "\n")
end

CustomActionButtonText_Data = {
    DeepCopyTable = DeepCopyTable,
    NormalizeKey = NormalizeKey,
    IsDisallowedKey = IsDisallowedKey,
    BuildMappingsFromTable = BuildMappingsFromTable,
    ValidateEntry = ValidateEntry,
    ParseText = ParseText,
    SerializeMappings = SerializeMappings,
}
