-- MainFrame.lua - Text editor UI for CustomActionButtonText

local Data = _G.CustomActionButtonText_Data

local function BuildSortedList(mappings)
    local list = {}
    for k, v in pairs(mappings or {}) do
        table.insert(list, {key = k, value = v})
    end
    table.sort(list, function(a, b) return a.key < b.key end)
    return list
end

local function ShallowCopy(tbl)
    local t = {}
    for k, v in pairs(tbl or {}) do
        t[k] = v
    end
    return t
end

local function SerializeMappings(mappings)
    if Data and Data.SerializeMappings then
        return Data.SerializeMappings(mappings)
    end
    local lines = {}
    for _, entry in ipairs(BuildSortedList(mappings)) do
        lines[#lines + 1] = string.format("%s = %s", entry.key, entry.value)
    end
    return table.concat(lines, "\n")
end

local function ParseMappings(text, validateFn)
    if Data and Data.ParseText then
        return Data.ParseText(text)
    end
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
                local nKey, nVal = validateFn and validateFn(keyPart, valuePart)
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

function CustomActionButtonText_ShowUI(api)
    if not api then
        print("CustomActionButtonText: UI API missing.")
        return
    end

    local uiFrame = _G["CustomActionButtonTextUI"]
    if not uiFrame then
        uiFrame = CreateFrame("Frame", "CustomActionButtonTextUI", UIParent, "BasicFrameTemplateWithInset")
        uiFrame:SetSize(720, 640)
        uiFrame:SetPoint("CENTER")
        uiFrame:SetMovable(true)
        uiFrame:EnableMouse(true)
        uiFrame:RegisterForDrag("LeftButton")
        uiFrame:SetScript("OnDragStart", uiFrame.StartMoving)
        uiFrame:SetScript("OnDragStop", uiFrame.StopMovingOrSizing)
        uiFrame.TitleText:SetText("Custom Action Button Text")

        local padding = 12
        local editorWidth = uiFrame:GetWidth() - padding * 2

        local editorFrame = CreateFrame("ScrollFrame", nil, uiFrame, "InputScrollFrameTemplate")
        editorFrame:SetPoint("TOPLEFT", padding, -32)
        editorFrame:SetPoint("BOTTOMRIGHT", -padding, 12)
        uiFrame.editorFrame = editorFrame
        editorFrame.CharCount:Hide()
        editorFrame.EditBox:SetFontObject("GameFontHighlight")
        editorFrame.EditBox:SetWidth(editorWidth - 30)
        editorFrame.EditBox:SetAutoFocus(false)
        editorFrame.EditBox:SetSpacing(6)
        editorFrame.EditBox:SetPropagateKeyboardInput(false)
        editorFrame.EditBox:SetAltArrowKeyMode(false)
        editorFrame.EditBox:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)
        editorFrame.EditBox:SetScript("OnTabPressed", function(self)
            self:Insert("    ")
        end)
        local history = { stack = {}, index = 0, restoring = false, max = 50 }
        local function PushHistory(text)
            if history.restoring then return end
            local current = text or ""
            if history.stack[history.index] == current then return end
            history.index = history.index + 1
            history.stack[history.index] = current
            if history.index > history.max then
                table.remove(history.stack, 1)
                history.index = history.max
            end
        end

        uiFrame.state = { mappings = {}, rawText = nil }

        local function GetInitialMappings()
            local savedText = api.GetSavedRawText and api.GetSavedRawText()
            if savedText and savedText ~= "" then
                return savedText
            end
            local saved = api.GetSavedMappings and api.GetSavedMappings()
            if saved and next(saved) ~= nil then
                return SerializeMappings(saved)
            end
            local defaults = api.GetDefaultMappings and api.GetDefaultMappings() or {}
            if api.BuildTemplateText then
                return api.BuildTemplateText(defaults)
            end
            return SerializeMappings(defaults)
        end

        local function LoadToEditor()
            local text = uiFrame.state.rawText
            if not text or text == "" then
                text = GetInitialMappings()
                uiFrame.state.rawText = text
            end
            uiFrame.state.mappings = {}
            editorFrame.EditBox:SetText(text)
            history.stack = { text }
            history.index = 1
            history.restoring = false
        end

        local function LoadDefaults()
            local defaults = api.GetDefaultMappings and api.GetDefaultMappings()
            if defaults then
                local template = api.BuildTemplateText and api.BuildTemplateText(defaults) or SerializeMappings(defaults)
                api.ApplyMappings(defaults, {persist = true, source = "UI-defaults", rawText = template, templateVersion = api.TemplateVersion})
                editorFrame.EditBox:SetText(template)
                uiFrame.state.rawText = template
                print("CustomActionButtonText: 已加载默认模板并保存。")
            else
                print("CustomActionButtonText: 无默认映射可加载。")
            end
        end

        -- 快捷键：Ctrl+S 保存
        editorFrame.EditBox:SetScript("OnKeyDown", function(self, key)
            local ctrl = IsControlKeyDown()
            if ctrl and key == "S" then
                local parsed, ok, bad, reasons = ParseMappings(editorFrame.EditBox:GetText(), api.ValidateEntry)
                if ok == 0 then
                    print("CustomActionButtonText: 保存失败，编辑器没有任何有效行（请检查格式：KEY = VALUE，半角符号）。")
                    return
                end
                if bad > 0 then
                    print(string.format("CustomActionButtonText: 保存失败，发现 %d 条无效行，成功解析 %d 条。", bad, ok))
                    if reasons and reasons[1] then
                        print("示例无效行：" .. reasons[1])
                    end
                    return
                end
                local rawText = editorFrame.EditBox:GetText()
                local applied, reason = api.ApplyMappings(parsed, {persist = true, source = "UI", trusted = true, silent = true, rawText = rawText, templateVersion = api.TemplateVersion})
                if applied ~= false then
                    uiFrame.state.mappings = ShallowCopy(parsed)
                    uiFrame.state.rawText = rawText
                    print(string.format("CustomActionButtonText: 已应用并保存 %d 条映射。", ok))
                else
                    print("CustomActionButtonText: 保存失败，原因：" .. tostring(reason or "未知"))
                end
                return
            end
            if ctrl and key == "Z" then
                if history.index > 1 then
                    history.restoring = true
                    history.index = history.index - 1
                    self:SetText(history.stack[history.index] or "")
                    history.restoring = false
                end
                return
            end
            if ctrl and key == "Y" then
                if history.index < #history.stack then
                    history.restoring = true
                    history.index = history.index + 1
                    self:SetText(history.stack[history.index] or "")
                    history.restoring = false
                end
                return
            end
            self:EnableKeyboard(true)
        end)

        editorFrame.EditBox:SetScript("OnTextChanged", function(self)
            PushHistory(self:GetText())
        end)

        local function ResetEditorTemplate(defaults)
            if not uiFrame or not uiFrame.editorFrame then return false end
            local template = (api.BuildTemplateText and api.BuildTemplateText(defaults or (api.GetDefaultMappings and api.GetDefaultMappings() or {}))) or ""
            uiFrame.state.rawText = template
            uiFrame.state.mappings = {}
            uiFrame.editorFrame.EditBox:SetText(template)
            history.stack = { template }
            history.index = 1
            history.restoring = false
            return true
        end

        _G.CustomActionButtonText_ResetEditorTemplate = ResetEditorTemplate

        uiFrame:SetScript("OnShow", function()
            LoadToEditor()
        end)
    end

    uiFrame:Show()
    if uiFrame:GetScript("OnShow") then
        uiFrame:GetScript("OnShow")(uiFrame)
    end
end
