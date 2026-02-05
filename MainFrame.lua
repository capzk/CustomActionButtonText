-- MainFrame.lua - Text editor UI for CustomActionButtonText

local Data = _G.CustomActionButtonText_Data

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
    -- 如果Data模块不可用，返回空字符串
    return ""
end

local function ParseMappings(text, validateFn)
    if Data and Data.ParseText then
        return Data.ParseText(text)
    end
    -- 如果Data模块不可用，返回空结果
    return {}, 0, 1
end

local function SplitLinesPreserveEmpty(text)
    local lines = {}
    local start = 1
    local len = string.len(text or "")
    if len == 0 then
        return { "" }
    end
    while true do
        local pos = string.find(text, "\n", start, true)
        if not pos then
            local line = string.sub(text, start)
            if string.sub(line, -1) == "\r" then
                line = string.sub(line, 1, -2)
            end
            table.insert(lines, line)
            break
        end
        local line = string.sub(text, start, pos - 1)
        if string.sub(line, -1) == "\r" then
            line = string.sub(line, 1, -2)
        end
        table.insert(lines, line)
        start = pos + 1
        if start > len then
            table.insert(lines, "")
            break
        end
    end
    return lines
end

local function ApplyCommentColoring(text)
    if text == nil then return "" end
    local lines = {}
    for _, line in ipairs(SplitLinesPreserveEmpty(text)) do
        local trimmed = string.match(line, "^%s*(.-)%s*$") or ""
        if trimmed:match("^#") or trimmed:match("^//") or trimmed:match("^%-%-") then
            table.insert(lines, "|cff969696" .. line .. "|r")
        else
            table.insert(lines, line)
        end
    end
    return table.concat(lines, "\n")
end

local function StripColorCodes(text)
    if not text then return "" end
    local stripped = string.gsub(text, "|c%x%x%x%x%x%x%x%x", "")
    stripped = string.gsub(stripped, "|r", "")
    return stripped
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

        local editorFrame = CreateFrame("ScrollFrame", nil, uiFrame, "InputScrollFrameTemplate")
        editorFrame:SetPoint("TOPLEFT", padding, -32)
        editorFrame:SetPoint("BOTTOMRIGHT", -padding, 12)
        uiFrame.editorFrame = editorFrame
        editorFrame.CharCount:Hide()
        editorFrame.EditBox:SetFontObject("GameFontHighlight")
        editorFrame.EditBox:SetWidth(720 - padding * 2 - 20)  -- 固定宽度：窗口宽度 - 边距 - 滚动条
        editorFrame.EditBox:SetAutoFocus(false)
        -- 不设置固定的Spacing，让它自动适应字体大小
        editorFrame.EditBox:SetPropagateKeyboardInput(false)
        editorFrame.EditBox:SetAltArrowKeyMode(false)
        editorFrame.EditBox:SetMaxLetters(0)
        editorFrame.EditBox:SetScript("OnEscapePressed", function(self) 
            self:ClearFocus()
        end)
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
            if savedText ~= nil then
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
            if text == nil then
                text = GetInitialMappings()
                uiFrame.state.rawText = text
            end
            uiFrame.state.mappings = {}
            
            local coloredText = ApplyCommentColoring(text)
            editorFrame.EditBox:SetText(coloredText)
            editorFrame.EditBox:SetCursorPosition(0)
            
            history.stack = { text }
            history.index = 1
            history.restoring = false
        end

        editorFrame.EditBox:SetScript("OnKeyDown", function(self, key)
            local ctrl = IsControlKeyDown()
            if ctrl and key == "S" then
                local rawText = StripColorCodes(editorFrame.EditBox:GetText())
                local parsed, ok, bad, reasons = ParseMappings(rawText, api.ValidateEntry)
                if bad > 0 then
                    print(string.format("CustomActionButtonText: 警告：发现 %d 条格式无效行，成功解析 %d 条。", bad, ok))
                    if reasons and reasons[1] then
                        print("示例无效行：" .. reasons[1])
                    end
                end
                if ok > 0 then
                    local applied, reason = api.ApplyMappings(parsed, {persist = true, source = "UI", trusted = true, silent = true, rawText = rawText, templateVersion = api.TemplateVersion})
                    if applied ~= false then
                        uiFrame.state.mappings = ShallowCopy(parsed)
                        uiFrame.state.rawText = rawText
                        print(string.format("CustomActionButtonText: 已应用并保存 %d 条映射。", ok))
                    else
                        print("CustomActionButtonText: 保存失败，原因：" .. tostring(reason or "未知"))
                    end
                else
                    if api.SaveRawText then
                        api.SaveRawText(rawText, api.TemplateVersion)
                    end
                    uiFrame.state.mappings = {}
                    uiFrame.state.rawText = rawText
                    print("CustomActionButtonText: 已保存配置，但无有效映射，未应用。")
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
            
            local coloredText = ApplyCommentColoring(template)
            uiFrame.editorFrame.EditBox:SetText(coloredText)
            
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
