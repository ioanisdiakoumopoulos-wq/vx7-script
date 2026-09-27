Theme.MainBackground, bgDeep = Theme.InputBg, panel = Theme.Panel,
panel2 = Theme.Row, line = Theme.Stroke, accent = Theme.Accent,
accent2 = Theme.AccentLight, accentHi = Theme.Accent, text = Theme.Text,
sub = Theme.Dim, ok = Theme.Green, err = Theme.Red, warn = Color3.fromRGB(250, 204, 90),
}

local LOG = {
dim   = "rgb(138,138,150)",
white = "rgb(255,255,255)",
ok    = "rgb(45,214,96)",
err   = "rgb(226,72,80)",
warn  = "rgb(250,204,90)",
acc   = "rgb(235,38,48)",
cyan  = "rgb(255,255,255)",
}

local function new(class, props, parent)
  local inst = Instance.new(class)
  for key, value in pairs(props or {}) do inst[key] = value end
  if parent then inst.Parent = parent end
  return inst
end
local function corner(o, r)
  local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0, r); c.Parent = o;
  return c
end
local function stroke(o, col, th, tr)
  local s = Instance.new("UIStroke")
  s.Color = col or Theme.Stroke; s.Thickness = th or 1; s.Transparency = tr or 0
  s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border; s.Parent = o
  return s
end
local function tw(o, p, t)
  TweenService:Create(o, TweenInfo.new(t or 0.14, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), p):Play()
end
local function tween(o, t, p) tw(o, p, t) end
local function addOutline(f)
  local o = Instance.new("UIStroke")
  o.Color = Theme.AccentLight; o.Thickness = 1.25; o.Transparency = 0.08
  o.ApplyStrokeMode = Enum.ApplyStrokeMode.Border; o.Parent = f
  return o
end
local function decoratePanel(f)
  local g = Instance.new("UIGradient", f); g.Rotation = 90
  g.Color = ColorSequence.new{
  ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
  ColorSequenceKeypoint.new(1, Color3.fromRGB(188, 188, 188)),
}
local hl = Instance.new("Frame")
hl.Size = UDim2.new(1, -16, 0, 1); hl.Position = UDim2.new(0, 8, 0, 1)
hl.BackgroundColor3 = Color3.fromRGB(243, 243, 243); hl.BackgroundTransparency = 0.5
hl.BorderSizePixel = 0; hl.ZIndex = 6; hl.Parent = f
local hlg = Instance.new("UIGradient", hl)
hlg.Transparency = NumberSequence.new{
NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(0.5, 0), NumberSequenceKeypoint.new(1, 1),
}
return g
end
local function label(parent, text, size, color, font, align)
  return new("TextLabel", {
  BackgroundTransparency = 1, Text = text, TextSize = size or 11,
  TextColor3 = color or Theme.Text, Font = font or Enum.Font.GothamMedium,
  TextXAlignment = align or Enum.TextXAlignment.Left,
  TextYAlignment = Enum.TextYAlignment.Center,
}, parent)
end
local function bindClick(button, callback)
  local last = 0
  local function fire()
    if tick() - last < 0.16 then return end
    last = tick()
    callback()
  end
button.Activated:Connect(fire)
button.MouseButton1Click:Connect(fire)
button.InputBegan:Connect(function(input)
  if input.UserInputType == Enum.UserInputType.Touch then fire() end
end)
end

pcall(function()
  for _, name in ipairs({ UI_NAME, "KatanaHub", "HiddenUI", "skyr0wtf_CodeRedeemer", "Skyr0WtfUI", "ACECodeSniperUI", "AutoTypeCodesUI", "ACEPaste", "GuiznxRiddle" }) do
    local old = playerGui:FindFirstChild(name)
    if old then old:Destroy() end
    local oldCore = CoreGui and CoreGui:FindFirstChild(name)
    if oldCore then oldCore:Destroy() end
  end
end)

GUI = new("ScreenGui", {
Name = UI_NAME,
ResetOnSpawn = false,
IgnoreGuiInset = true,
DisplayOrder = 9999999,
ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
}, playerGui)

local Master = new("Frame", {
Name = "CursedHub_MasterFrame",
BackgroundTransparency = 1,
BorderSizePixel = 0,
Size = UDim2.new(1, 0, 1, 0),
}, GUI)
local GlobalScale = new("UIScale", { Name = "CursedHub_GlobalScale", Scale = 1 }, Master)

local Launcher = new("Frame", {
Name = "Launcher",
Size = UDim2.fromOffset(570, 66),
Position = UDim2.new(0.5, -285, 0, 16),
BackgroundColor3 = Color3.fromRGB(114, 9, 19),
BackgroundTransparency = 0.01,
BorderSizePixel = 0,
Active = true,
}, Master)
corner(Launcher, 99)
stroke(Launcher, Color3.fromRGB(255, 78, 88), 1.25, 0.12)
new("UIGradient", {
Color = ColorSequence.new{
ColorSequenceKeypoint.new(0, Color3.fromRGB(168, 12, 27)),
ColorSequenceKeypoint.new(0.46, Color3.fromRGB(103, 7, 18)),
ColorSequenceKeypoint.new(1, Color3.fromRGB(48, 8, 14)),
},
Rotation = 8,
}, Launcher)

UI.LauncherInner = new("Frame", {
Size = UDim2.new(1, -6, 1, -6),
Position = UDim2.fromOffset(3, 3),
BackgroundColor3 = Color3.fromRGB(8, 8, 11),
BackgroundTransparency = 0.42,
BorderSizePixel = 0,
}, Launcher)
corner(UI.LauncherInner, 99)
new("UIGradient", {
Color = ColorSequence.new{
ColorSequenceKeypoint.new(0, Color3.fromRGB(88, 11, 21)),
ColorSequenceKeypoint.new(0.48, Color3.fromRGB(18, 11, 15)),
ColorSequenceKeypoint.new(1, Color3.fromRGB(40, 8, 14)),
},
}, UI.LauncherInner)

UI.LauncherShadow = new("Frame", {
Size = UDim2.new(1, -18, 1, -4),
Position = UDim2.new(0, 9, 0, 8),
BackgroundColor3 = Color3.fromRGB(235, 38, 48),
BackgroundTransparency = 0.82,
BorderSizePixel = 0,
ZIndex = 0,
}, Launcher)
corner(UI.LauncherShadow, 99)

UI.LauncherGlow = new("Frame", {
Name = "RedDecoration",
Size = UDim2.new(1, -44, 0, 2),
Position = UDim2.new(0, 22, 1, -3),
BackgroundColor3 = CURSED_RED,
BackgroundTransparency = 0.1,
BorderSizePixel = 0,
}, Launcher)
corner(UI.LauncherGlow, 99)
new("UIGradient", {
Transparency = NumberSequence.new{
NumberSequenceKeypoint.new(0, 1),
NumberSequenceKeypoint.new(0.22, 0.2),
NumberSequenceKeypoint.new(0.78, 0.2),
NumberSequenceKeypoint.new(1, 1),
},
}, UI.LauncherGlow)

UI.LauncherLogoFrame = new("Frame", {
Size = UDim2.fromOffset(48, 48),
Position = UDim2.fromOffset(9, 9),
BackgroundColor3 = Color3.fromRGB(35, 7, 12),
BorderSizePixel = 0,
}, Launcher)
corner(UI.LauncherLogoFrame, 99)

UI.LauncherLogo = new("ImageLabel", {
Size = UDim2.fromOffset(40, 40),
Position = UDim2.fromOffset(4, 4),
BackgroundTransparency = 1,
BorderSizePixel = 0,
Image = "rbxassetid://117157091563742",
ScaleType = Enum.ScaleType.Fit,
}, UI.LauncherLogoFrame)
corner(UI.LauncherLogo, 99)

UI.LauncherTitle = label(Launcher, "", 16, Theme.Text, Enum.Font.GothamBlack)
UI.LauncherTitle.RichText = true
UI.LauncherTitle.Text = '<font color="rgb(255,112,120)">CURSED</font><font color="rgb(255,255,255)"> HUB</font>'
UI.LauncherTitle.Size = UDim2.fromOffset(118, 66)
UI.LauncherTitle.Position = UDim2.fromOffset(65, 0)

UI.DebobCredit = label(Master, "DEOB BY CRXKV", 9, Color3.fromRGB(255, 143, 149),
Enum.Font.GothamBlack, Enum.TextXAlignment.Center)
UI.DebobCredit.Size = UDim2.fromOffset(240, 14)
UI.DebobCredit.Position = UDim2.new(0.5, 0, 0, 1)

UI.LauncherDivider = new("Frame", {
Size = UDim2.fromOffset(1, 30),
Position = UDim2.fromOffset(182, 18),
BackgroundColor3 = Color3.fromRGB(255, 143, 149),
BackgroundTransparency = 0.52,
BorderSizePixel = 0,
}, Launcher)

local RedeemerBtn = new("TextButton", {
Name = "CodeRedeemerToggle",
Size = UDim2.fromOffset(230, 42),
Position = UDim2.fromOffset(194, 12),
BackgroundColor3 = cfg.sniper and Color3.fromRGB(16, 79, 39) or Color3.fromRGB(30, 30, 35),
BorderSizePixel = 0,
AutoButtonColor = false,
Active = true,
Text = "",
}, Launcher)
corner(RedeemerBtn, 99)
UI.RedeemerStroke = stroke(RedeemerBtn, cfg.sniper and ACTIVE_GREEN or Color3.fromRGB(64, 64, 70), 1, 0.05)

UI.RedeemerDot = new("Frame", {
Size = UDim2.fromOffset(10, 10),
Position = UDim2.fromOffset(13, 16),
BackgroundColor3 = cfg.sniper and ACTIVE_GREEN or Theme.ToggleOff,
BorderSizePixel = 0,
}, RedeemerBtn)
corner(UI.RedeemerDot, 10)

UI.RedeemerText = label(RedeemerBtn, "CODE REDEEMER", 11, Theme.Text, Enum.Font.GothamBold)
UI.RedeemerText.Size = UDim2.new(1, -72, 1, 0)
UI.RedeemerText.Position = UDim2.fromOffset(31, 0)

local RedeemerState = label(RedeemerBtn, cfg.sniper and "ON" or "OFF", 11,
cfg.sniper and ACTIVE_GREEN or Theme.Dim, Enum.Font.GothamBlack, Enum.TextXAlignment.Right)
RedeemerState.Size = UDim2.fromOffset(42, 42)
RedeemerState.Position = UDim2.new(1, -53, 0, 0)

local MenuBtn = new("TextButton", {
Name = "MenuButton",
Size = UDim2.fromOffset(123, 42),
Position = UDim2.new(1,