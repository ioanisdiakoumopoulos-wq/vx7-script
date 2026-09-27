
corner(button, 12)

local state = initial
local function render(value)
  state = value
  tw(button, { BackgroundColor3 = value and Color3.fromRGB(246, 246, 248) or Theme.ToggleOff2 }, 0.12)
  tw(cardStroke, { Color = value and CURSED_RED or Color3.fromRGB(83, 83, 92) }, 0.12)
  button.Text = value and "ON" or "OFF"
  button.TextColor3 = value and Color3.fromRGB(18, 18, 21) or Theme.Text
end
bindClick(button, function()
  render(not state)
  onChange(state)
end)
render(initial)
return render
end
local setAutoSubmitCard = makeFeatureCard(UDim2.fromOffset(0, 0), "AUTO SUBMIT", "send at mode limit", cfg.autoSubmit, function(state)
  cfg.autoSubmit = state
  saveConfig()
  logRich('<font color="' .. LOG.dim .. '">auto submit </font><font color="'
  .. (state and LOG.ok or LOG.err) .. '">' .. (state and "on" or "off") .. "</font>")
end)

local setRiddleCard = makeFeatureCard(UDim2.new(1, -184, 0, 0), "RIDDLE SOLVER", "AI + local fallback", cfg.riddleSolver, function(state)
  cfg.riddleSolver = state
  saveConfig()
  logRich('<font color="' .. LOG.dim .. '">riddle solver </font><font color="'
  .. (state and LOG.ok or LOG.err) .. '">' .. (state and "on" or "off") .. "</font>")
end)

do
  local MIN, MAX = 1, 5
  local holder = new("Frame", {
  Size = UDim2.new(1, 0, 0, 68),
  Position = UDim2.fromOffset(0, 98),
  BackgroundColor3 = Color3.fromRGB(14, 14, 18),
  BackgroundTransparency = 0.16,
  BorderSizePixel = 0,
}, Body)
corner(holder, 18)
stroke(holder, Color3.fromRGB(83, 83, 92), 1, 0.28)

local modeTitle = label(holder, "REDEEM MODE", 11, Theme.Text, Enum.Font.GothamBold)
modeTitle.Size = UDim2.fromOffset(150, 22)
modeTitle.Position = UDim2.fromOffset(14, 12)
local modeNote = label(holder, "fragments required before submit", 8, Theme.Dim, Enum.Font.GothamMedium)
modeNote.Size = UDim2.fromOffset(190, 18)
modeNote.Position = UDim2.fromOffset(14, 34)

local selector = new("Frame", {
Size = UDim2.fromOffset(142, 44),
Position = UDim2.new(1, -156, 0.5, -22),
BackgroundColor3 = Color3.fromRGB(8, 8, 11),
BackgroundTransparency = 0.05,
BorderSizePixel = 0,
}, holder)
corner(selector, 15)
stroke(selector, Color3.fromRGB(67, 67, 75), 1, 0.15)

local function modeButton(text, x)
  local button = new("TextButton", {
  Size = UDim2.fromOffset(38, 38),
  Position = UDim2.fromOffset(x, 3),
  BackgroundColor3 = Theme.Row,
  BorderSizePixel = 0,
  AutoButtonColor = false,
  Active = true,
  Text = text,
  TextSize = 17,
  TextColor3 = Theme.Text,
  Font = Enum.Font.GothamBlack,
}, selector)
corner(button, 12)
return button
end
local minusButton = modeButton("-", 3)
local valueLabel = label(selector, tostring(cfg.submitAfter), 17, Theme.Text,
Enum.Font.GothamBlack, Enum.TextXAlignment.Center)
valueLabel.Size = UDim2.fromOffset(52, 44)
valueLabel.Position = UDim2.fromOffset(45, 0)
local plusButton = modeButton("+", 101)

local function setMode(delta)
  local nextValue = math.clamp(cfg.submitAfter + delta, MIN, MAX)
  if nextValue == cfg.submitAfter then return end
  cfg.submitAfter = nextValue
  valueLabel.Text = tostring(nextValue)
  clearCapture()
  saveConfig()
  logRich('<font color="' .. LOG.dim .. '">mode: </font><font color="'
  .. LOG.ok .. '">' .. nextValue .. "/5</font>")
end
bindClick(minusButton, function() setMode(-1) end)
bindClick(plusButton, function() setMode(1) end)
end

UI.RetypeRow = new("Frame", {
Size = UDim2.new(1, 0, 0, 58),
Position = UDim2.fromOffset(0, 176),
BackgroundColor3 = Color3.fromRGB(14, 14, 18),
BackgroundTransparency = 0.16,
BorderSizePixel = 0,
}, Body)
corner(UI.RetypeRow, 18)
UI.RetypeStroke = stroke(UI.RetypeRow, cfg.retypeInvalid and CURSED_RED or Color3.fromRGB(83, 83, 92), 1, 0.28)
UI.RetypeTitle = label(UI.RetypeRow, "AUTO RETYPE INVALID", 11, Theme.Text, Enum.Font.GothamBold)
UI.RetypeTitle.Size = UDim2.fromOffset(220, 58)
UI.RetypeTitle.Position = UDim2.fromOffset(14, 0)
UI.RetypeBtn = new("TextButton", {
Size = UDim2.fromOffset(68, 34),
Position = UDim2.new(1, -82, 0.5, -17),
BackgroundColor3 = cfg.retypeInvalid and Color3.fromRGB(246, 246, 248) or Theme.ToggleOff2,
BorderSizePixel = 0,
AutoButtonColor = false,
Active = true,
Text = cfg.retypeInvalid and "ON" or "OFF",
TextColor3 = cfg.retypeInvalid and Color3.fromRGB(18, 18, 21) or Theme.Text,
Font = Enum.Font.GothamBlack,
TextSize = 10,
}, UI.RetypeRow)
corner(UI.RetypeBtn, 12)
local retypeState = cfg.retypeInvalid
bindClick(UI.RetypeBtn, function()
  retypeState = not retypeState
  cfg.retypeInvalid = retypeState
  saveConfig()
  tw(UI.RetypeBtn, { BackgroundColor3 = retypeState and Color3.fromRGB(246, 246, 248) or Theme.ToggleOff2 }, 0.12)
  tw(UI.RetypeStroke, { Color = retypeState and CURSED_RED or Color3.fromRGB(83, 83, 92) }, 0.12)
  UI.RetypeBtn.Text = retypeState and "ON" or "OFF"
  UI.RetypeBtn.TextColor3 = retypeState and Color3.fromRGB(18, 18, 21) or Theme.Text
  logRich('<font color="' .. LOG.dim .. '">retype invalid </font><font color="'
  .. (retypeState and LOG.ok or LOG.err) .. '">' .. (retypeState and "on" or "off") .. "</font>")
end)

UI.ConsoleBar = new("Frame", {
Size = UDim2.new(1, 0, 0, 16),
Position = UDim2.fromOffset(0, 244),
BackgroundTransparency = 1,
}, Body)

UI.ConsoleTitle = label(UI.ConsoleBar, "CONSOLE", 9, Theme.Dim, Enum.Font.GothamBlack)
UI.ConsoleTitle.Text = "REDEEMED CODE / RESULT"
UI.ConsoleTitle.Size = UDim2.fromOffset(180, 16)
UI.ConsoleTitle.Position = UDim2.fromOffset(4, 0)

UI.ClearBtn = new("TextButton", {
Size = UDim2.fromOffset(46, 16),
Position = UDim2.new(1, -46, 0, 0),
BackgroundColor3 = Theme.Row,
BackgroundTransparency = 0.3,
BorderSizePixel = 0,
AutoButtonColor = false,
Active = true,
Text = "CLEAR",
TextSize = 9,
TextColor3 = Theme.Text,
Font = Enum.Font.GothamBold,
}, UI.ConsoleBar)
corner(UI.ClearBtn, 6)
stroke(UI.ClearBtn, Theme.AccentLight, 1, 0.28)
UI.ClearBtn.MouseEnter:Connect(function() tw(UI.ClearBtn, { BackgroundColor3 = Theme.RowHover }, 0.12) end)
UI.ClearBtn.MouseLeave:Connect(function() tw(UI.ClearBtn, { BackgroundColor3 = Theme.Row }, 0.12) end)

UI.Console = new("ScrollingFrame", {
Name = "Console",
Size = UDim2.new(1, 0, 0, 124),
Position = UDim2.fromOffset(0, 264),
BackgroundColor3 = Theme.InputBg,
BackgroundTransparency = 0.15,
BorderSizePixel = 0,
Active = true,
ClipsDescendants = true,
ScrollingDirection = Enum.ScrollingDirection.Y,
ScrollBarThickness = 3,
ScrollBarImageColor3 = Theme.Accent,
CanvasSize = UDim2.new(0, 0, 0, 0),
AutomaticCanvasSize = Enum.AutomaticSize.None,
ElasticBehavior = Enum.ElasticBehavior.WhenScrollable,
}, Body)
corner(UI.Console, 18)
stroke(UI.Console, Color3.fromRGB(83, 83, 92), 1, 0.22)

local ConsoleText = new("TextLabel", {
Name = "Output",
Size = UDim2.new(1, -14, 0, 0),
AutomaticSize = Enum.AutomaticSize.Y,
Position = UDim2.fromOffset(7, 5),
BackgroundTransparency = 1,
RichText = true,
Text = "",
TextSize = 11,
Font = Enum.Font.Code,
TextColor3 = Theme.Text,
TextXAlignment = Enum.TextXAlignment.Left,
TextYAlignment = Enum.TextYAlignment.Top,
TextWrapped = true,
}, UI.Console)

UI.HelperPage = new("Frame", {
Name = "HelperPage",
Size = UDim2.new(1, -28, 1, -152),
Position = UDim2.fromOffset(14, 138),
BackgroundTransparency = 1,
Visible = false,
ZIndex = 3,
}, Window)

UI.HelperTitle = label(UI.HelperPage, "AA HELPER", 17, Theme.Text, Enum.Font.GothamBlack)
UI.HelperTitle.RichText = true
UI.HelperTitle.Text = '<font color="rgb(235,38,48)">AA</font><font color="rgb(255,255,255)"> HELPER</font>'
UI.HelperTitle.Size = UDim2.new(1, 0, 0, 25)
UI.HelperTitle.Position = UDim2.fromOffset(4, 0)
UI.HelperSub = label(UI.HelperPage, "UTILITY CONTROLS", 8, Theme.Dim, Enum.Font.GothamBold)
UI.HelperSub.Size = UDim2.new(1, 0, 0, 16)
UI.HelperSub.Position = UDim2.fromOffset(5, 24)

local function makeValueControl(y, titleText, noteText, valueText)
  local row = new("Frame", {
  Size = UDim2.new(1, 0, 0, 64),
  Position = UDim2.fromOffset(0, y),
  BackgroundColor3 = Color3.fromRGB(11, 11, 15),
  BackgroundTransparency = 0.38,
  BorderSizePixel = 0,
}, UI.HelperPage)
corner(row, 16)
s