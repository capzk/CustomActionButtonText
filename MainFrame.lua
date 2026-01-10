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
        uiFrame:SetSize(540, 520)
        uiFrame:SetPoint("CENTER")
        uiFrame:SetMovable(true)
        uiFrame:EnableMouse(true)
        uiFrame:RegisterForDrag("LeftButton")
        uiFrame:SetScript("OnDragStart", uiFrame.StartMoving)
        uiFrame:SetScript("OnDragStop", uiFrame.StopMovingOrSizing)
        uiFrame.TitleText:SetText("Custom Action Button Text")

        local padding = 12
        local editorWidth = uiFrame:GetWidth() - padding * 2

        -- 顶部自定义帮助按钮（●●●）
        local helpBtn = CreateFrame("Button", nil, uiFrame)
        helpBtn:SetSize(36, 20)
        helpBtn:SetPoint("TOPRIGHT", uiFrame.CloseButton, "LEFT", -6, 10)
        local helpText = helpBtn:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        helpText:SetPoint("CENTER")
        helpText:SetText("●●●")
        helpBtn:SetScript("OnEnter", function(self) helpText:SetTextColor(1, 0.82, 0) end)
        helpBtn:SetScript("OnLeave", function(self) helpText:SetTextColor(1, 1, 1) end)

        local editorFrame = CreateFrame("ScrollFrame", nil, uiFrame, "InputScrollFrameTemplate")
        editorFrame:SetPoint("TOPLEFT", padding, -32)
        editorFrame:SetPoint("BOTTOMRIGHT", -padding, 12)
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
        -- 撤销/重做历史
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

        uiFrame.state = { mappings = {}, helpMode = false, rawText = nil }

        local function GetInitialMappings()
            local savedText = api.GetSavedRawText and api.GetSavedRawText()
            if savedText and savedText ~= "" then
                return savedText
            end
            local saved = api.GetSavedMappings and api.GetSavedMappings()
            if saved and next(saved) ~= nil then
                return SerializeMappings(saved)
            end
            local defaults = api.GetDefaultMappings and api.GetDefaultMappings()
            if defaults and next(defaults) ~= nil then
                return SerializeMappings(defaults)
            end
            local current = api.GetMappings and api.GetMappings() or {}
            return SerializeMappings(current)
        end

        local function LoadToEditor()
            local text = uiFrame.state.rawText
            if not text or text == "" then
                text = GetInitialMappings()
                uiFrame.state.rawText = text
            end
            uiFrame.state.mappings = {}
            editorFrame.EditBox:SetText(text)
            uiFrame.state.helpMode = false
            history.stack = { text }
            history.index = 1
            history.restoring = false
        end

        local function LoadDefaults()
            local defaults = api.GetDefaultMappings and api.GetDefaultMappings()
            if defaults then
                api.ApplyMappings(defaults, {persist = false, source = "UI-defaults"})
                editorFrame.EditBox:SetText(SerializeMappings(defaults))
                print("CustomActionButtonText: 已加载默认映射（未保存）。")
            else
                print("CustomActionButtonText: 无默认映射可加载。")
            end
        end

        -- 帮助窗口
        local function ShowHelpWindow()
            if _G["CustomActionButtonTextHelp"] then
                _G["CustomActionButtonTextHelp"]:Show()
                return
            end
            -- 独立帮助窗口（可拖动，置顶显示）
            local helpFrame = CreateFrame("Frame", "CustomActionButtonTextHelp", UIParent, "BasicFrameTemplateWithInset")
            helpFrame:SetSize(640, 600)
            helpFrame:SetPoint("CENTER")
            helpFrame:SetMovable(true)
            helpFrame:EnableMouse(true)
            helpFrame:RegisterForDrag("LeftButton")
            helpFrame:SetScript("OnDragStart", helpFrame.StartMoving)
            helpFrame:SetScript("OnDragStop", helpFrame.StopMovingOrSizing)
            helpFrame:SetFrameStrata("DIALOG")
            helpFrame.TitleText:SetText("Custom Action Button Text - 帮助")

            local scroll = CreateFrame("ScrollFrame", nil, helpFrame, "InputScrollFrameTemplate")
            scroll:SetPoint("TOPLEFT", 12, -32)
            scroll:SetPoint("BOTTOMRIGHT", -12, 12)
            scroll.CharCount:Hide()
            scroll.EditBox:SetFontObject("GameFontHighlight")
            scroll.EditBox:SetWidth(616) -- 640 - 左右间距(24)
            scroll.EditBox:SetAutoFocus(false)
            scroll.EditBox:SetSpacing(4)
            scroll.EditBox:SetMultiLine(true)
            scroll.EditBox:EnableKeyboard(true)
            scroll.EditBox:SetPropagateKeyboardInput(false)
            scroll.EditBox:SetAltArrowKeyMode(false)
            scroll.EditBox:EnableMouse(true)

            local helpLines = { -- 标准写法示例，供复制使用
                "标准写法（可复制，使用半角“=”与“+”）：",
                "",
                "-- 修饰键（单独）",
                "SHIFT = S+",
                "CTRL = C+",
                "ALT = A+",
                "",
                "-- 鼠标滚轮与侧键",
                "MOUSEWHEELUP = MU",
                "MOUSEWHEELDOWN = MD",
                "BUTTON3 = M3",
                "BUTTON4 = M4",
                "BUTTON5 = M5",
                "",
                "-- 修饰键 + 鼠标",
                "SHIFT-MOUSEWHEELUP = SMU",
                "CTRL-MOUSEWHEELUP = CMU",
                "ALT-MOUSEWHEELUP = AMU",
                "SHIFT-MOUSEWHEELDOWN = SMD",
                "CTRL-MOUSEWHEELDOWN = CMD",
                "ALT-MOUSEWHEELDOWN = AMD",
                "SHIFT-BUTTON3 = SM3",
                "CTRL-BUTTON3 = CM3",
                "ALT-BUTTON3 = AM3",
                "SHIFT-BUTTON4 = SM4",
                "CTRL-BUTTON4 = CM4",
                "ALT-BUTTON4 = AM4",
                "SHIFT-BUTTON5 = SM5",
                "CTRL-BUTTON5 = CM5",
                "ALT-BUTTON5 = AM5",
                "",
                "-- 修饰键 + 字母/数字示例",
                "SHIFT-1 = S1",
                "CTRL-2 = C2",
                "ALT-3 = A3",
                "SHIFT-A = SA",
                "CTRL-E = CE",
                "ALT-R = AR",
            }
            local helpText = table.concat(helpLines, "\n")
            scroll.EditBox:SetText(helpText)
            scroll.EditBox:SetScript("OnTextChanged", function(self, userInput)
                if userInput then
                    local cursor = self:GetCursorPosition()
                    self:SetText(helpText)
                    self:SetCursorPosition(math.min(cursor, #helpText))
                end
            end)
            scroll.EditBox:SetScript("OnEditFocusGained", function(self)
                self:HighlightText()
            end)
            scroll.EditBox:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)
            scroll.EditBox:SetScript("OnMouseDown", function(self, button)
                if button == "LeftButton" then
                    self:SetFocus()
                end
            end)
        end

        helpBtn:SetScript("OnClick", function()
            ShowHelpWindow()
        end)

        -- 快捷键：Ctrl+S 保存
        editorFrame.EditBox:SetScript("OnKeyDown", function(self, key)
            local ctrl = IsControlKeyDown()
            if ctrl and key == "S" then
                local parsed, ok, bad = ParseMappings(editorFrame.EditBox:GetText(), api.ValidateEntry)
                if ok == 0 then
                    print("CustomActionButtonText: 保存失败，编辑器没有任何有效行（请检查格式：KEY = VALUE，半角符号）。")
                    return
                end
                if bad > 0 then
                    print(string.format("CustomActionButtonText: 保存失败，发现 %d 条无效行，成功解析 %d 条。", bad, ok))
                    return
                end
                local rawText = editorFrame.EditBox:GetText()
                local applied, reason = api.ApplyMappings(parsed, {persist = true, source = "UI", trusted = true, silent = true, rawText = rawText})
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

        uiFrame:SetScript("OnShow", function()
            LoadToEditor()
        end)
    end

    uiFrame:Show()
    if uiFrame:GetScript("OnShow") then
        uiFrame:GetScript("OnShow")(uiFrame)
    end
end
