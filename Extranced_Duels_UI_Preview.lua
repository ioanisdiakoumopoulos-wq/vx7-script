-- Aspect Hub UI-only preview.
-- This script only displays a local GUI and stores preview preferences.
-- It does not alter gameplay, inspect other players, call game remotes, or load external code.

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local player = Players.LocalPlayer

local CONFIG_FILE = "aspecthub_ui_preview.json"
local ACCENTS = {
    Color3.fromRGB(225, 55, 75),
    Color3.fromRGB(236, 85, 150),
    Color3.fromRGB(160, 90, 245),
    Color3.fromRGB(245, 135, 70),
}
local DEFAULT_TOGGLES = {
    autoCarry = false, speedMode = false, antiBat = false, autoSteal = false,
    autoSwing = false, infiniteJump = false, autoLeft = false, autoRight = false,
    esp = false, fps = false, mobileButtons = true, sky = false, showHint = true,
}
local DEFAULT_NUMBERS = {normalSpeed = 16, carrySpeed = 20, scale = 1}
local DEFAULT_KEYS = {autoSteal = "G", autoSwing = "F", guiHide = "RightShift", speed = "R"}
local function copyTable(source)
    local out = {}
    for key, value in pairs(source) do out[key] = value end
    return out
end
local state = {
    accent = 1,
    toggles = copyTable(DEFAULT_TOGGLES),
    numbers = copyTable(DEFAULT_NUMBERS),
    keybinds = copyTable(DEFAULT_KEYS),
}

local function loadLocalSettings()
    if type(isfile) ~= "function" or type(readfile) ~= "function" then return end
    local okFile, exists = pcall(isfile, CONFIG_FILE)
    if not okFile or not exists then return end
    local okRead, raw = pcall(readfile, CONFIG_FILE)
    if not okRead or type(raw) ~= "string" then return end
    local okDecode, saved = pcall(function() return HttpService:JSONDecode(raw) end)
    if not okDecode or type(saved) ~= "table" then return end
    if type(saved.accent) == "number" then state.accent = math.clamp(math.floor(saved.accent), 1, #ACCENTS) end
    if type(saved.toggles) == "table" then
        for key in pairs(state.toggles) do
            if type(saved.toggles[key]) == "boolean" then state.toggles[key] = saved.toggles[key] end
        end
    end
    if type(saved.numbers) == "table" then
        for key in pairs(state.numbers) do
            local value = tonumber(saved.numbers[key])
            if value then state.numbers[key] = value end
        end
    end
    if type(saved.keybinds) == "table" then
        for key in pairs(state.keybinds) do
            if type(saved.keybinds[key]) == "string" then state.keybinds[key] = saved.keybinds[key] end
        end
    end
end

local function saveLocalSettings()
    if type(writefile) == "function" then
        pcall(writefile, CONFIG_FILE, HttpService:JSONEncode(state))
    end
end
loadLocalSettings()

local COLORS = {
    bg = Color3.fromRGB(15, 13, 18),
    panel = Color3.fromRGB(25, 21, 28),
    row = Color3.fromRGB(33, 28, 36),
    rowHover = Color3.fromRGB(43, 34, 43),
    text = Color3.fromRGB(246, 240, 244),
    muted = Color3.fromRGB(164, 151, 161),
    off = Color3.fromRGB(72, 60, 72),
}
local accent = ACCENTS[state.accent]
local gui = Instance.new("ScreenGui")
gui.Name = "AspectHubUIPreview"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.DisplayOrder = 50
gui.Parent = player:WaitForChild("PlayerGui")

local main = Instance.new("Frame")
main.Name = "PreviewWindow"
main.AnchorPoint = Vector2.new(0.5, 0.5)
main.Position = UDim2.fromScale(0.5, 0.5)
main.Size = UDim2.fromOffset(410, 520)
main.BackgroundColor3 = COLORS.bg
main.BorderSizePixel = 0
main.ClipsDescendants = true
main.Parent = gui
local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 14)
mainCorner.Parent = main
local mainStroke = Instance.new("UIStroke")
mainStroke.Color = accent
mainStroke.Thickness = 1.5
mainStroke.Transparency = 0.15
mainStroke.Parent = main
local uiScale = Instance.new("UIScale")
uiScale.Scale = math.clamp(tonumber(state.numbers.scale) or 1, 0.8, 1.2)
uiScale.Parent = main

local topbar = Instance.new("Frame")
topbar.Name = "Topbar"
topbar.Size = UDim2.new(1, 0, 0, 54)
topbar.BackgroundColor3 = COLORS.panel
topbar.BorderSizePixel = 0
topbar.Parent = main
local topCorner = Instance.new("UICorner")
topCorner.CornerRadius = UDim.new(0, 14)
topCorner.Parent = topbar
local title = Instance.new("TextLabel")
title.BackgroundTransparency = 1
title.Position = UDim2.fromOffset(16, 6)
title.Size = UDim2.new(0.58, 0, 0, 25)
title.Font = Enum.Font.GothamBold
title.Text = "ASPECT HUB"
title.TextSize = 17
title.TextColor3 = accent
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = topbar
local subtitle = Instance.new("TextLabel")
subtitle.BackgroundTransparency = 1
subtitle.Position = UDim2.fromOffset(17, 31)
subtitle.Size = UDim2.new(0.7, 0, 0, 15)
subtitle.Font = Enum.Font.Gotham
subtitle.Text = "UI preview · local controls only"
subtitle.TextSize = 10
subtitle.TextColor3 = COLORS.muted
subtitle.TextXAlignment = Enum.TextXAlignment.Left
subtitle.Parent = topbar
local minimize = Instance.new("TextButton")
minimize.Name = "Minimize"
minimize.Position = UDim2.new(1, -40, 0, 13)
minimize.Size = UDim2.fromOffset(27, 27)
minimize.BackgroundColor3 = COLORS.row
minimize.BorderSizePixel = 0
minimize.Text = "−"
minimize.TextSize = 18
minimize.TextColor3 = COLORS.text
minimize.Font = Enum.Font.GothamBold
minimize.AutoButtonColor = false
minimize.Parent = topbar
local minCorner = Instance.new("UICorner")
minCorner.CornerRadius = UDim.new(0, 8)
minCorner.Parent = minimize

local hint = Instance.new("TextLabel")
hint.Name = "PreviewNotice"
hint.Position = UDim2.fromOffset(14, 61)
hint.Size = UDim2.new(1, -28, 0, 27)
hint.BackgroundColor3 = Color3.fromRGB(42, 25, 33)
hint.BorderSizePixel = 0
hint.Font = Enum.Font.Gotham
hint.Text = "PREVIEW ONLY  •  buttons change this panel, not the game"
hint.TextSize = 10
hint.TextColor3 = COLORS.text
hint.Parent = main
local hintCorner = Instance.new("UICorner")
hintCorner.CornerRadius = UDim.new(0, 8)
hintCorner.Parent = hint
local hintStroke = Instance.new("UIStroke")
hintStroke.Color = accent
hintStroke.Transparency = 0.7
hintStroke.Parent = hint

local tabBar = Instance.new("Frame")
tabBar.Name = "Tabs"
tabBar.Position = UDim2.fromOffset(12, 98)
tabBar.Size = UDim2.new(1, -24, 0, 34)
tabBar.BackgroundTransparency = 1
tabBar.Parent = main
local pageHolder = Instance.new("Frame")
pageHolder.Name = "Pages"
pageHolder.Position = UDim2.fromOffset(12, 140)
pageHolder.Size = UDim2.new(1, -24, 1, -152)
pageHolder.BackgroundTransparency = 1
pageHolder.Parent = main
local tabs = {"Speed", "Mechanics", "Keybinds", "Utils", "Settings"}
local pages, tabButtons, lists = {}, {}, {}
local activeTab = "Speed"

local function rounded(object, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, radius or 8)
    c.Parent = object
    return c
end
local function makePage(tabName)
    local page = Instance.new("ScrollingFrame")
    page.Name = tabName .. "Page"
    page.Size = UDim2.fromScale(1, 1)
    page.BackgroundTransparency = 1
    page.BorderSizePixel = 0
    page.ScrollBarThickness = 3
    page.ScrollBarImageColor3 = accent
    page.CanvasSize = UDim2.new(0, 0, 0, 0)
    page.Visible = false
    page.Parent = pageHolder
    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 8)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Parent = page
    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        page.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 8)
    end)
    pages[tabName], lists[tabName] = page, layout
end
for _, tabName in ipairs(tabs) do makePage(tabName) end

local function refreshTabs()
    for tabName, button in pairs(tabButtons) do
        local selected = tabName == activeTab
        button.BackgroundColor3 = selected and accent or COLORS.panel
        button.TextColor3 = selected and COLORS.text or COLORS.muted
    end
end
local function switchTab(tabName)
    activeTab = tabName
    for name, page in pairs(pages) do page.Visible = name == tabName end
    refreshTabs()
end
for index, tabName in ipairs(tabs) do
    local button = Instance.new("TextButton")
    button.Name = tabName .. "Tab"
    button.Position = UDim2.new((index - 1) / #tabs, 2, 0, 0)
    button.Size = UDim2.new(1 / #tabs, -4, 1, 0)
    button.BackgroundColor3 = COLORS.panel
    button.BorderSizePixel = 0
    button.AutoButtonColor = false
    button.Text = tabName
    button.TextColor3 = COLORS.muted
    button.TextSize = 9
    button.Font = Enum.Font.GothamBold
    button.Parent = tabBar
    rounded(button, 8)
    button.Activated:Connect(function() switchTab(tabName) end)
    tabButtons[tabName] = button
end

local function addSection(tabName, heading, description)
    local section = Instance.new("Frame")
    section.Size = UDim2.new(1, -4, 0, 42)
    section.BackgroundTransparency = 1
    section.Parent = pages[tabName]
    local head = Instance.new("TextLabel")
    head.BackgroundTransparency = 1
    head.Position = UDim2.fromOffset(2, 0)
    head.Size = UDim2.new(1, -4, 0, 21)
    head.Font = Enum.Font.GothamBold
    head.Text = string.upper(heading)
    head.TextSize = 10
    head.TextColor3 = accent
    head.TextXAlignment = Enum.TextXAlignment.Left
    head.Parent = section
    local sub = Instance.new("TextLabel")
    sub.BackgroundTransparency = 1
    sub.Position = UDim2.fromOffset(2, 20)
    sub.Size = UDim2.new(1, -4, 0, 18)
    sub.Font = Enum.Font.Gotham
    sub.Text = description
    sub.TextSize = 9
    sub.TextColor3 = COLORS.muted
    sub.TextXAlignment = Enum.TextXAlignment.Left
    sub.Parent = section
end
local function addRow(tabName, height, rowName, detail)
    local row = Instance.new("Frame")
    row.Name = rowName:gsub("%s+", "") .. "PreviewRow"
    row.Size = UDim2.new(1, -4, 0, height or 58)
    row.BackgroundColor3 = COLORS.row
    row.BorderSizePixel = 0
    row.Parent = pages[tabName]
    rounded(row, 9)
    local label = Instance.new("TextLabel")
    label.BackgroundTransparency = 1
    label.Position = UDim2.fromOffset(12, 7)
    label.Size = UDim2.new(1, -104, 0, 19)
    label.Font = Enum.Font.GothamSemibold
    label.Text = rowName
    label.TextSize = 11
    label.TextColor3 = COLORS.text
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = row
    local desc = Instance.new("TextLabel")
    desc.BackgroundTransparency = 1
    desc.Position = UDim2.fromOffset(12, 27)
    desc.Size = UDim2.new(1, -104, 0, 20)
    desc.Font = Enum.Font.Gotham
    desc.Text = detail or "Preview preference only"
    desc.TextSize = 9
    desc.TextColor3 = COLORS.muted
    desc.TextXAlignment = Enum.TextXAlignment.Left
    desc.TextTruncate = Enum.TextTruncate.AtEnd
    desc.Parent = row
    return row
end
local function addToggle(tabName, label, detail, key)
    local row = addRow(tabName, 58, label, detail or "Visual state only; no game action")
    local button = Instance.new("TextButton")
    button.Size = UDim2.fromOffset(54, 25)
    button.Position = UDim2.new(1, -66, 0.5, -12)
    button.BackgroundColor3 = state.toggles[key] and accent or COLORS.off
    button.BorderSizePixel = 0
    button.AutoButtonColor = false
    button.Text = state.toggles[key] and "ON" or "OFF"
    button.TextColor3 = COLORS.text
    button.TextSize = 9
    button.Font = Enum.Font.GothamBold
    button.Parent = row
    rounded(button, 8)
    button.Activated:Connect(function()
        state.toggles[key] = not state.toggles[key]
        button.Text = state.toggles[key] and "ON" or "OFF"
        button.BackgroundColor3 = state.toggles[key] and accent or COLORS.off
        saveLocalSettings()
    end)
    return row
end
local function addNumber(tabName, label, detail, key, minValue, maxValue)
    local row = addRow(tabName, 58, label, detail)
    local box = Instance.new("TextBox")
    box.Size = UDim2.fromOffset(62, 27)
    box.Position = UDim2.new(1, -74, 0.5, -13)
    box.BackgroundColor3 = COLORS.bg
    box.BorderSizePixel = 0
    box.ClearTextOnFocus = false
    box.Text = tostring(state.numbers[key])
    box.TextColor3 = COLORS.text
    box.TextSize = 11
    box.Font = Enum.Font.GothamBold
    box.Parent = row
    rounded(box, 7)
    box.FocusLost:Connect(function()
        local value = tonumber(box.Text)
        if not value then box.Text = tostring(state.numbers[key]); return end
        value = math.clamp(math.floor(value + 0.5), minValue, maxValue)
        state.numbers[key] = value
        box.Text = tostring(value)
        if key == "scale" then uiScale.Scale = value / 100 end
        saveLocalSettings()
    end)
end
local function addKeybind(tabName, label, detail, key)
    local row = addRow(tabName, 58, label, detail or "Stores a label only; not bound to gameplay")
    local button = Instance.new("TextButton")
    button.Size = UDim2.fromOffset(74, 27)
    button.Position = UDim2.new(1, -86, 0.5, -13)
    button.BackgroundColor3 = COLORS.bg
    button.BorderSizePixel = 0
    button.Text = state.keybinds[key]
    button.TextColor3 = COLORS.text
    button.TextSize = 10
    button.Font = Enum.Font.GothamBold
    button.Parent = row
    rounded(button, 7)
    local connection
    button.Activated:Connect(function()
        if connection then connection:Disconnect(); connection = nil end
        button.Text = "Press key"
        connection = UserInputService.InputBegan:Connect(function(input)
            if input.UserInputType ~= Enum.UserInputType.Keyboard then return end
            if input.KeyCode == Enum.KeyCode.Unknown then return end
            if input.KeyCode == Enum.KeyCode.Escape then
                button.Text = state.keybinds[key]
            else
                state.keybinds[key] = input.KeyCode.Name
                button.Text = input.KeyCode.Name
                saveLocalSettings()
            end
            connection:Disconnect()
            connection = nil
        end)
    end)
end

addSection("Speed", "Speed display", "These values are saved for the preview only.")
addNumber("Speed", "Normal speed", "Display value; does not change character speed.", "normalSpeed", 1, 100)
addNumber("Speed", "Carry speed", "Display value; does not change character speed.", "carrySpeed", 1, 100)
addToggle("Speed", "Auto carry speed", "Preview toggle only; no movement changes.", "autoCarry")
addToggle("Speed", "Speed mode", "Preview toggle only; no gameplay effect.", "speedMode")

addSection("Mechanics", "Mechanics preview", "Controls only change their visible ON/OFF state.")
addToggle("Mechanics", "Anti-bat", "Visual mockup only; does not block or send remotes.", "antiBat")
addToggle("Mechanics", "Auto steal", "Visual mockup only; no prompts or server calls.", "autoSteal")
addToggle("Mechanics", "Auto swing", "Visual mockup only; no player or remote actions.", "autoSwing")
addToggle("Mechanics", "Infinite jump", "Visual mockup only; no character changes.", "infiniteJump")
addToggle("Mechanics", "Auto left route", "Visual mockup only; no movement automation.", "autoLeft")
addToggle("Mechanics", "Auto right route", "Visual mockup only; no movement automation.", "autoRight")

addSection("Keybinds", "Key labels", "Capture a key to save its label; keys trigger no actions.")
addKeybind("Keybinds", "Auto steal label", "Saved label only; not connected to gameplay.", "autoSteal")
addKeybind("Keybinds", "Auto swing label", "Saved label only; not connected to gameplay.", "autoSwing")
addKeybind("Keybinds", "Hide UI label", "Saved label only; not connected to gameplay.", "guiHide")
addKeybind("Keybinds", "Speed label", "Saved label only; not connected to gameplay.", "speed")

addSection("Utils", "Utility previews", "Local interface options only.")
addToggle("Utils", "ESP preview", "Visual state only; no player tracking or overlays.", "esp")
addToggle("Utils", "FPS option preview", "Visual state only; no performance or instance changes.", "fps")
addToggle("Utils", "Mobile buttons preview", "Visual state only; no gameplay controls.", "mobileButtons")
addToggle("Utils", "Sky theme preview", "Visual state only; does not alter Lighting.", "sky")

addSection("Settings", "Preview settings", "Saved locally as aspecthub_ui_preview.json when file access is available.")
addToggle("Settings", "Show preview notice", "Show or hide the safety notice at the top.", "showHint")
addNumber("Settings", "UI scale percent", "80–120; changes this panel's size only.", "scale", 80, 120)
local accentRow = addRow("Settings", 58, "Accent color", "Cycle the local preview accent.")
local accentButton = Instance.new("TextButton")
accentButton.Size = UDim2.fromOffset(74, 27)
accentButton.Position = UDim2.new(1, -86, 0.5, -13)
accentButton.BackgroundColor3 = accent
accentButton.BorderSizePixel = 0
accentButton.Text = "CHANGE"
accentButton.TextColor3 = COLORS.text
accentButton.TextSize = 9
accentButton.Font = Enum.Font.GothamBold
accentButton.Parent = accentRow
rounded(accentButton, 7)
local function applyAccent()
    accent = ACCENTS[state.accent]
    mainStroke.Color = accent
    title.TextColor3 = accent
    hintStroke.Color = accent
    hint.Visible = state.toggles.showHint
    accentButton.BackgroundColor3 = accent
    for tabName, button in pairs(tabButtons) do
        if tabName == activeTab then button.BackgroundColor3 = accent end
        local page = pages[tabName]
        if page then page.ScrollBarImageColor3 = accent end
    end
end
accentButton.Activated:Connect(function()
    state.accent = (state.accent % #ACCENTS) + 1
    applyAccent()
    saveLocalSettings()
end)
local saveRow = addRow("Settings", 58, "Save preview settings", "Writes only this UI's values to local storage.")
local saveButton = Instance.new("TextButton")
saveButton.Size = UDim2.fromOffset(74, 27)
saveButton.Position = UDim2.new(1, -86, 0.5, -13)
saveButton.BackgroundColor3 = COLORS.rowHover
saveButton.BorderSizePixel = 0
saveButton.Text = "SAVE"
saveButton.TextColor3 = COLORS.text
saveButton.TextSize = 9
saveButton.Font = Enum.Font.GothamBold
saveButton.Parent = saveRow
rounded(saveButton, 7)
saveButton.Activated:Connect(function()
    saveLocalSettings()
    saveButton.Text = "SAVED"
    task.delay(1, function() if saveButton.Parent then saveButton.Text = "SAVE" end end)
end)

local dock = Instance.new("TextButton")
dock.Name = "PreviewDock"
dock.AnchorPoint = Vector2.new(1, 1)
dock.Position = UDim2.new(1, -18, 1, -18)
dock.Size = UDim2.fromOffset(118, 36)
dock.BackgroundColor3 = COLORS.panel
dock.BorderSizePixel = 0
dock.Text = "ASPECT PREVIEW"
dock.TextColor3 = accent
dock.TextSize = 10
dock.Font = Enum.Font.GothamBold
dock.Visible = false
dock.Parent = gui
rounded(dock, 10)
local dockStroke = Instance.new("UIStroke")
dockStroke.Color = accent
dockStroke.Transparency = 0.2
dockStroke.Parent = dock
minimize.Activated:Connect(function() main.Visible = false; dock.Visible = true end)
dock.Activated:Connect(function() dock.Visible = false; main.Visible = true end)

local close = Instance.new("TextButton")
close.Name = "ClosePreview"
close.Position = UDim2.new(1, -76, 0, 13)
close.Size = UDim2.fromOffset(27, 27)
close.BackgroundColor3 = COLORS.row
close.BorderSizePixel = 0
close.Text = "×"
close.TextSize = 16
close.TextColor3 = COLORS.muted
close.Font = Enum.Font.GothamBold
close.AutoButtonColor = false
close.Parent = topbar
rounded(close, 8)
close.Activated:Connect(function() gui:Destroy() end)

local dragging = false
local dragInput, dragStart, startPosition
 topbar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPosition = main.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then dragging = false end
        end)
    end
end)
topbar.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then dragInput = input end
end)
UserInputService.InputChanged:Connect(function(input)
    if dragging and input == dragInput then
        local delta = input.Position - dragStart
        main.Position = UDim2.new(startPosition.X.Scale, startPosition.X.Offset + delta.X, startPosition.Y.Scale, startPosition.Y.Offset + delta.Y)
    end
end)
for tabName in pairs(pages) do
    lists[tabName]:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        pages[tabName].CanvasPosition = Vector2.new(0, 0)
    end)
end
applyAccent()
switchTab("Speed")
print("Aspect Hub UI-only preview loaded")
