-- Data.lua - 数据解析与持久化模块

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
    if normalizedKey == "SHIFT" or normalizedKey == "CTRL" or normalizedKey == "ALT" then
        return false
    end

    if string.match(normalizedKey, "^[A-Z]$") or string.match(normalizedKey, "^[0-9]$") or string.match(normalizedKey, "^F[0-9]+$") then
        return true
    end

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
            local disallowed = IsDisallowedKey(normalizedKey)
            if not disallowed then
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

    for line in string.gmatch(text or "", "[^\r\n]+") do
        local trimmed = string.match(line, "^%s*(.-)%s*$")
        if trimmed ~= "" then
            local keyPart, valuePart = string.match(trimmed, "^(.-)%s*=%s*(.+)$")
            if not keyPart then
                keyPart, valuePart = string.match(trimmed, "^(%S+)%s+(.+)$")
            end
            if keyPart and valuePart then
                local nKey, nVal = ValidateEntry(keyPart, valuePart)
                if nKey then
                    parsed[nKey] = nVal
                    validCount = validCount + 1
                else
                    invalidCount = invalidCount + 1
                end
            else
                invalidCount = invalidCount + 1
            end
        end
    end

    return parsed, validCount, invalidCount
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
