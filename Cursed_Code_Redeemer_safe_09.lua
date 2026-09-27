{ BackgroundColor3 = Theme.Green }, 0.12) end)

UI.BottomBar = new("Frame", {
Name = "BottomBar",
Size = UDim2.new(1, -12, 0, 38),
Position = UDim2.new(0, 6, 1, -44),
BackgroundColor3 = Theme.Background,
BackgroundTransparency = 0.3,
BorderSizePixel = 0,
Visible = false,
}, Window)
corner(UI.BottomBar, 10)
stroke(UI.BottomBar, Theme.AccentLight, 1, 0.28)

UI.LogoTile = new("Frame", {
Size = UDim2.fromOffset(26, 26),
Position = UDim2.new(0, 8, 0.5, -13),
BackgroundColor3 = Theme.SoftAccent,
BorderSizePixel = 0,
}, UI.BottomBar)
corner(UI.LogoTile, 8)
stroke(UI.LogoTile, Theme.AccentLight, 1, 0.4)

UI.WordMark = label(UI.BottomBar, "CURSED", 15, Theme.AccentLight, Enum.Font.GothamBlack)
UI.WordMark.Size = UDim2.fromOffset(46, 20)
UI.WordMark.Position = UDim2.fromOffset(40, 4)

UI.BarDivider = label(UI.BottomBar, "|", 14, Theme.AccentLight, Enum.Font.GothamBlack)
UI.BarDivider.Size = UDim2.fromOffset(10, 20)
UI.BarDivider.Position = UDim2.fromOffset(84, 4)

UI.FullMark = label(UI.BottomBar, "CURSED HUB", 12, Theme.AccentLight, Enum.Font.GothamBold)
UI.FullMark.Size = UDim2.fromOffset(80, 20)
UI.FullMark.Position = UDim2.fromOffset(96, 4)

UI.Author = label(UI.BottomBar, "REDEEMER", 8, Theme.Dim, Enum.Font.GothamSemibold)
UI.Author.Size = UDim2.fromOffset(120, 12)
UI.Author.Position = UDim2.fromOffset(41, 22)

UI.SolvedLabel = label(UI.BottomBar, "0 solved / 0 asked", 9, Theme.Green, Enum.Font.GothamBold, Enum.TextXAlignment.Right)
UI.SolvedLabel.Size = UDim2.fromOffset(110, 38)
UI.SolvedLabel.Position = UDim2.new(1, -118, 0, 0)

UI.Footer = label(Window, "CURSED SYSTEMS  •  CODE REDEEMER", 9, Theme.Dim,
Enum.Font.GothamBold, Enum.TextXAlignment.Center)
UI.Footer.Size = UDim2.new(1, -28, 0, 18)
UI.Footer.Position = UDim2.new(0, 14, 1, -22)
UI.Footer.ZIndex = 4

local logLines = {}
local MAX_LOG = 160

local function scrollToBottom()
  task.defer(function()
    task.wait()
    if not UI.Console or not ConsoleText then return end
    local height = ConsoleText.AbsoluteSize.Y + 12
    UI.Console.CanvasSize = UDim2.new(0, 0, 0, height)
    UI.Console.CanvasPosition = Vector2.new(0, math.max(0, height - UI.Console.AbsoluteSize.Y))
  end)
end
ConsoleText:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
  UI.Console.CanvasSize = UDim2.new(0, 0, 0, ConsoleText.AbsoluteSize.Y + 12)
end)

logRich = function(line)
  logLines[#logLines + 1] = line
  if #logLines > MAX_LOG then table.remove(logLines, 1) end
  ConsoleText.Text = table.concat(logLines, "\n")
  scrollToBottom()
end

clearLog = function()
  logLines = {}
  ConsoleText.Text = '<font color="' .. LOG.dim .. '">cleared</font>'
  UI.Console.CanvasPosition = Vector2.new(0, 0)
end

setStatus = function(msg, color)
  logRich('<font color="' .. (color or LOG.dim) .. '">' .. tostring(msg) .. "</font>")
end

bumpSolvedLabel = function()
  UI.SolvedLabel.Text = _solvedCount .. " solved / " .. _askedCount .. " asked"
end

bindClick(UI.ClearBtn, function()
  clearLog()
  _solvedCount, _askedCount = 0, 0
  bumpSolvedLabel()
end)

applyPowerVisual = function()
  local on = cfg.sniper
  tw(Power, { BackgroundColor3 = on and CURSED_RED or Theme.ToggleOff }, 0.12)
  tw(UI.PowerDot, { Position = on and UDim2.new(1, -32, 0.5, -14) or UDim2.new(0, 4, 0.5, -14) }, 0.12)
  tw(UI.LiveDot, { BackgroundColor3 = on and Theme.Green or Theme.ToggleOff }, 0.12)
  UI.SubTitle.Text = on and "SNIPE ENGINE  •  LISTENING" or "SNIPE ENGINE  •  PAUSED"
  UI.SubTitle.TextColor3 = on and Theme.Green or Theme.Dim
  tw(RedeemerBtn, { BackgroundColor3 = on and Color3.fromRGB(18, 92, 44) or Color3.fromRGB(35, 35, 40) }, 0.12)
  tw(UI.RedeemerDot, { BackgroundColor3 = on and ACTIVE_GREEN or Theme.ToggleOff }, 0.12)
  tw(UI.RedeemerStroke, { Color = on and ACTIVE_GREEN or Color3.fromRGB(64, 64, 70) }, 0.12)
  RedeemerState.Text = on and "ON" or "OFF"
  RedeemerState.TextColor3 = on and ACTIVE_GREEN or Theme.Dim
  tw(UI.WindowOutline, { Transparency = on and 0.08 or 0.45 }, 0.12)
  if setPowerRow then setPowerRow(on) end
end
local function toggleSniper()
  cfg.sniper = not cfg.sniper
  saveConfig()
  applyPowerVisual()
  if cfg.sniper then
    clearCapture()
    logRich('<font color="' .. LOG.ok .. '">sniper on</font>')
  else
  logRich('<font color="' .. LOG.err .. '">sniper off</font>')
end
end
bindClick(Power, toggleSniper)
bindClick(RedeemerBtn, toggleSniper)

local menuOpen = false
local function setMenuOpen(open)
  menuOpen = open
  if open then
    Window.Visible = true
    Window.Size = UDim2.fromOffset(WIN_W, 38)
    tw(Window, { Size = UDim2.fromOffset(WIN_W, WIN_H) }, 0.18)
    MenuBtn.Text = "CLOSE"
  else
  MenuBtn.Text = "MENU"
  tw(Window, { Size = UDim2.fromOffset(WIN_W, 38) }, 0.14)
  task.delay(0.15, function()
    if not menuOpen then Window.Visible = false end
  end)
end
end

bindClick(MenuBtn, function() setMenuOpen(not menuOpen) end)

bindClick(UI.CloseBtn, function()
  setMenuOpen(false)
end)

do
  local dragging, dragInput, dragStart, startPos = false, nil, nil, nil
  local THRESHOLD = UserInputService.TouchEnabled and 8 or 2
  local moved = false

  local function overControl(position)
    for _, control in ipairs({ Power, UI.MinBtn, UI.CloseBtn }) do
      local pos, size = control.AbsolutePosition, control.AbsoluteSize
      if position.X >= pos.X - 8 and position.X <= pos.X + size.X + 8
      and position.Y >= pos.Y - 8 and position.Y <= pos.Y + size.Y + 8 then
        return true
      end
  end
return false
end

UI.Header.InputBegan:Connect(function(input)
  if input.UserInputType ~= Enum.UserInputType.MouseButton1
  and input.UserInputType ~= Enum.UserInputType.Touch then return end
  if dragging or overControl(input.Position) then return end
  dragging, dragInput = true, input
  dragStart = Vector2.new(input.Position.X, input.Position.Y)
  startPos = Window.Position
  moved = false
  input.Changed:Connect(function()
    if input.UserInputState == Enum.UserInputState.End
    or input.UserInputState == Enum.UserInputState.Cancel then
      if input == dragInput then dragging, dragInput = false, nil end
    end
end)
end)

UserInputService.InputChanged:Connect(function(input)
  if not dragging or not dragInput then return end
  local trackedTouch = dragInput.UserInputType == Enum.UserInputType.Touch and input == dragInput
  local trackedMouse = dragInput.UserInputType == Enum.UserInputType.MouseButton1
  and input.UserInputType == Enum.UserInputType.MouseMovement
  if not trackedTouch and not trackedMouse then return end
  local delta = Vector2.new(input.Position.X, input.Position.Y) - dragStart
  if not moved then
    if delta.Magnitude < THRESHOLD then return end
    moved = true
  end
local scale = GlobalScale.Scale
if scale <= 0 then scale = 1 end
Window.Position = UDim2.new(
startPos.X.Scale, startPos.X.Offset + (delta.X / scale),
startPos.Y.Scale, startPos.Y.Offset + (delta.Y / scale)
)
end)
end

do
  local dragging, dragInput, dragStart, startPos = false, nil, nil, nil
  local moved = false
  local THRESHOLD = UserInputService.TouchEnabled and 8 or 2

  local function overLauncherControl(position)
    for _, control in ipairs({ RedeemerBtn, MenuBtn }) do
      local pos, size = control.AbsolutePosition, control.AbsoluteSize
      if position.X >= pos.X - 6 and position.X <= pos.X + size.X + 6
      and position.Y >= pos.Y - 6 and position.Y <= pos.Y + size.Y + 6 then
        return true
      end
  end
return false
end

Launcher.InputBegan:Connect(function(input)
  if input.UserInputType ~= Enum.UserInputType.MouseButton1
  and input.UserInputType ~= Enum.UserInputType.Touch then return end
  if dragging or overLauncherControl(input.Position) then return end
  dragging, dragInput = true, input
  dragStart = Vector2.new(input.Position.X, input.Position.Y)
  startPos = Launcher.Position
  moved = false
  input.Changed:Connect(function()
    if input.UserInputState == Enum.UserInputState.End
    or input.UserInputState == Enum.UserInputState.Cancel then
      if input == dragInput then dragging, dragInput 