troke(row, Color3.fromRGB(95, 45, 50), 1, 0.48)
local title = label(row, titleText, 11, Theme.Text, Enum.Font.GothamBold)
title.Size = UDim2.fromOffset(150, 22)
title.Position = UDim2.fromOffset(14, 10)
local note = label(row, noteText, 8, Theme.Dim, Enum.Font.GothamMedium)
note.Size = UDim2.fromOffset(170, 18)
note.Position = UDim2.fromOffset(14, 32)

local control = new("Frame", {
Size = UDim2.fromOffset(154, 42),
Position = UDim2.new(1, -168, 0.5, -21),
BackgroundColor3 = Color3.fromRGB(8, 8, 11),
BackgroundTransparency = 0.06,
BorderSizePixel = 0,
}, row)
corner(control, 13)
stroke(control, Color3.fromRGB(76, 76, 84), 1, 0.28)

local function smallButton(text, x)
  local button = new("TextButton", {
  Size = UDim2.fromOffset(38, 36),
  Position = UDim2.fromOffset(x, 3),
  BackgroundColor3 = Color3.fromRGB(35, 35, 41),
  BorderSizePixel = 0,
  AutoButtonColor = false,
  Active = true,
  Text = text,
  TextSize = 16,
  TextColor3 = Theme.Text,
  Font = Enum.Font.GothamBlack,
}, control)
corner(button, 11)
return button
end
local minus = smallButton("-", 3)
local plus = smallButton("+", 113)
local box = new("TextBox", {
Size = UDim2.fromOffset(68, 36),
Position = UDim2.fromOffset(43, 3),
BackgroundTransparency = 1,
ClearTextOnFocus = false,
Text = valueText,
TextColor3 = Theme.Text,
TextSize = 12,
Font = Enum.Font.GothamBlack,
TextXAlignment = Enum.TextXAlignment.Center,
}, control)
return minus, plus, box
end

UI.DelayMinus, UI.DelayPlus, UI.DelayBox = makeValueControl(48, "REDEEM DELAY", "minimum 0.01 seconds", string.format("%.2f", cfg.redeemDelay))
local function setRedeemDelay(value)
  cfg.redeemDelay = math.clamp(math.floor((tonumber(value) or cfg.redeemDelay) * 100 + 0.5) / 100, 0.01, 3.00)
  UI.DelayBox.Text = string.format("%.2f", cfg.redeemDelay)
  saveConfig()
end
bindClick(UI.DelayMinus, function() setRedeemDelay(cfg.redeemDelay - 0.01) end)
bindClick(UI.DelayPlus, function() setRedeemDelay(cfg.redeemDelay + 0.01) end)
UI.DelayBox.FocusLost:Connect(function() setRedeemDelay(UI.DelayBox.Text) end)

UI.SizeMinus, UI.SizePlus, UI.SizeBox = makeValueControl(120, "MENU SIZE", "scale the full redeemer", tostring(math.floor(cfg.menuScale * 100 + 0.5)) .. "%")
local function setMenuScale(value)
  local numeric = tonumber(tostring(value):gsub("%%", ""))
  if numeric and numeric > 2 then numeric = numeric / 100 end
  cfg.menuScale = math.clamp(numeric or cfg.menuScale, 0.70, 1.25)
  cfg.menuScale = math.floor(cfg.menuScale * 20 + 0.5) / 20
  UI.SizeBox.Text = tostring(math.floor(cfg.menuScale * 100 + 0.5)) .. "%"
  tw(MenuScale, { Scale = cfg.menuScale }, 0.16)
  saveConfig()
end
bindClick(UI.SizeMinus, function() setMenuScale(cfg.menuScale - 0.05) end)
bindClick(UI.SizePlus, function() setMenuScale(cfg.menuScale + 0.05) end)
UI.SizeBox.FocusLost:Connect(function() setMenuScale(UI.SizeBox.Text) end)

local function makeHelperToggle(y, titleText, noteText, onChange)
  local row = new("Frame", {
  Size = UDim2.new(1, 0, 0, 62),
  Position = UDim2.fromOffset(0, y),
  BackgroundColor3 = Color3.fromRGB(11, 11, 15),
  BackgroundTransparency = 0.34,
  BorderSizePixel = 0,
}, UI.HelperPage)
corner(row, 16)
local rowStroke = stroke(row, Color3.fromRGB(95, 45, 50), 1, 0.48)
local title = label(row, titleText, 12, Theme.Text, Enum.Font.GothamBlack)
title.Size = UDim2.fromOffset(190, 24)
title.Position = UDim2.fromOffset(15, 9)
local note = label(row, noteText, 8, Theme.Dim, Enum.Font.GothamMedium)
note.Size = UDim2.fromOffset(210, 18)
note.Position = UDim2.fromOffset(15, 32)
local button = new("TextButton", {
Size = UDim2.fromOffset(88, 40),
Position = UDim2.new(1, -102, 0.5, -20),
BackgroundColor3 = Color3.fromRGB(31, 31, 37),
BorderSizePixel = 0,
AutoButtonColor = false,
Active = true,
Text = "OFF",
TextColor3 = Theme.Text,
TextSize = 11,
Font = Enum.Font.GothamBlack,
}, row)
corner(button, 13)
local state = false
bindClick(button, function()
  state = not state
  tw(button, { BackgroundColor3 = state and Color3.fromRGB(246, 246, 248) or Color3.fromRGB(31, 31, 37) }, 0.13)
  tw(rowStroke, { Color = state and CURSED_RED or Color3.fromRGB(95, 45, 50) }, 0.13)
  button.Text = state and "ON" or "OFF"
  button.TextColor3 = state and Color3.fromRGB(16, 16, 19) or Theme.Text
  onChange(state)
end)
return button
end

makeHelperToggle(202, "AUTO BUY", "activate nearby prompts", setHelperAutoBuy)
makeHelperToggle(272, "ANCHOR", "anchor your character", setHelperAnchor)
makeHelperToggle(342, "ANTI RAGDOLL", "force getting-up state", setHelperAntiRagdoll)

UI.HelperHint = label(UI.HelperPage, "HELPER SYSTEMS RUN ONLY WHILE ENABLED", 8, Theme.Dim,
Enum.Font.GothamBold, Enum.TextXAlignment.Center)
UI.HelperHint.Size = UDim2.new(1, 0, 0, 18)
UI.HelperHint.Position = UDim2.fromOffset(0, 418)

local function showPage(name)
  local helper = name == "HELPER"
  Body.Visible = not helper
  UI.HelperPage.Visible = helper
  tw(UI.MainTab, { BackgroundColor3 = helper and Color3.fromRGB(23, 23, 28) or Color3.fromRGB(117, 13, 24) }, 0.12)
  tw(UI.HelperTab, { BackgroundColor3 = helper and Color3.fromRGB(117, 13, 24) or Color3.fromRGB(23, 23, 28) }, 0.12)
  UI.MainTab.TextColor3 = helper and Theme.Dim or Theme.Text
  UI.HelperTab.TextColor3 = helper and Theme.Text or Theme.Dim
end
bindClick(UI.MainTab, function() showPage("MAIN") end)
bindClick(UI.HelperTab, function() showPage("HELPER") end)
showPage("MAIN")

UI.CodeRow = new("Frame", {
Size = UDim2.new(1, 0, 0, 30),
Position = UDim2.fromOffset(0, 398),
BackgroundTransparency = 1,
}, Body)

UI.CodeBox = new("TextBox", {
Name = "ManualCodeBox",
Size = UDim2.new(1, -84, 1, 0),
BackgroundColor3 = Color3.fromRGB(10, 10, 14),
BackgroundTransparency = 0.06,
BorderSizePixel = 0,
ClearTextOnFocus = false,
Text = "",
PlaceholderText = "captured / type code...",
PlaceholderColor3 = Theme.Dim,
TextSize = 11,
Font = Enum.Font.GothamBold,
TextColor3 = Theme.Text,
TextXAlignment = Enum.TextXAlignment.Left,
}, UI.CodeRow)
corner(UI.CodeBox, 9)
stroke(UI.CodeBox, CURSED_RED, 1, 0.22)
new("UIPadding", { PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 8) }, UI.CodeBox)

UI.CodeRedeemBtn = new("TextButton", {
Name = "ManualRedeemButton",
Size = UDim2.fromOffset(78, 30),
Position = UDim2.new(1, -78, 0, 0),
BackgroundColor3 = Color3.fromRGB(240, 240, 244),
BorderSizePixel = 0,
AutoButtonColor = false,
Active = true,
Text = "REDEEM",
TextSize = 10,
TextColor3 = Color3.fromRGB(15, 15, 18),
Font = Enum.Font.GothamBlack,
}, UI.CodeRow)
corner(UI.CodeRedeemBtn, 9)
stroke(UI.CodeRedeemBtn, CURSED_RED, 1, 0.28)
UI.CodeRedeemBtn.MouseEnter:Connect(function()
  tw(UI.CodeRedeemBtn, { BackgroundColor3 = Color3.fromRGB(255, 255, 255) }, 0.12)
end)
UI.CodeRedeemBtn.MouseLeave:Connect(function()
  tw(UI.CodeRedeemBtn, { BackgroundColor3 = Color3.fromRGB(240, 240, 244) }, 0.12)
end)

UI.AskRow = new("Frame", {
Size = UDim2.new(1, 0, 0, 30),
Position = UDim2.fromOffset(0, 434),
BackgroundTransparency = 1,
Visible = true,
}, Body)

UI.AskBox = new("TextBox", {
Size = UDim2.new(1, -84, 1, 0),
BackgroundColor3 = Theme.InputBg,
BackgroundTransparency = 0.10,
BorderSizePixel = 0,
ClearTextOnFocus = false,
Text = "",
PlaceholderText = "ask AI / test a riddle...",
PlaceholderColor3 = Theme.Dim,
TextSize = 10,
Font = Enum.Font.GothamMedium,
TextColor3 = Theme.Text,
TextXAlignment = Enum.TextXAlignment.Left,
}, UI.AskRow)
corner(UI.AskBox, 9)
stroke(UI.AskBox, Theme.AccentLight, 1, 0.28)
new("UIPadding", { PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 8) }, UI.AskBox)

UI.AskBtn = new("TextButton", {
Size = UDim2.fromOffset(78, 30),
Position = UDim2.new(1, -78, 0, 0),
BackgroundColor3 = Theme.Green,
BorderSizePixel = 0,
AutoButtonColor = false,
Active = true,
Text = "SOLVE",
TextSize = 10,
TextColor3 = Color3.fromRGB(15, 15, 15),
Font = Enum.Font.GothamBlack,
}, UI.AskRow)
corner(UI.AskBtn, 9)
UI.AskBtn.MouseEnter:Connect(function() tw(UI.AskBtn, { BackgroundColor3 = Theme.AccentLight }, 0.12) end)
UI.AskBtn.MouseLeave:Connect(function() tw(UI.AskBtn, 