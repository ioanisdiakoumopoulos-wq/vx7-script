 -135, 0, 12),
BackgroundColor3 = Color3.fromRGB(28, 28, 32),
BorderSizePixel = 0,
AutoButtonColor = false,
Active = true,
Text = "MENU",
TextSize = 11,
TextColor3 = Theme.Text,
Font = Enum.Font.GothamBlack,
}, Launcher)
corner(MenuBtn, 99)
stroke(MenuBtn, CURSED_RED, 1, 0.18)
MenuBtn.MouseEnter:Connect(function() tw(MenuBtn, { BackgroundColor3 = Color3.fromRGB(48, 24, 27) }, 0.12) end)
MenuBtn.MouseLeave:Connect(function() tw(MenuBtn, { BackgroundColor3 = Color3.fromRGB(28, 28, 32) }, 0.12) end)

local viewportConn
local function recalculateScale()
  local camera = workspace.CurrentCamera
  if not camera then return end
  local h = camera.ViewportSize.Y
  local scale
  if UserInputService.TouchEnabled then
    scale = math.clamp(h / 1000, 0.52, 0.78)
  else
  scale = math.clamp(h / 800, 0.70, 1.0)
end
GlobalScale.Scale = scale
Master.Size = UDim2.new(1 / scale, 0, 1 / scale, 0)
end
local function setupCameraListener()
  if viewportConn then pcall(function() viewportConn:Disconnect() end) end
  local camera = workspace.CurrentCamera
  if camera then
    viewportConn = camera:GetPropertyChangedSignal("ViewportSize"):Connect(recalculateScale)
  end
recalculateScale()
end
workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(setupCameraListener)
task.spawn(setupCameraListener)

local WIN_W, WIN_H = 410, 620

local Window = new("Frame", {
Name = "CursedHubRedeemerMenu",
Size = UDim2.fromOffset(WIN_W, WIN_H),
Position = UDim2.new(0.5, -205, 0, 82),
BackgroundColor3 = Theme.Background,
BackgroundTransparency = 0.18,
BorderSizePixel = 0,
Active = true,
ClipsDescendants = true,
Visible = false,
}, Master)
corner(Window, 24)
UI.WindowOutline = addOutline(Window)
decoratePanel(Window)
local MenuScale = new("UIScale", { Name = "CursedMenuScale", Scale = cfg.menuScale }, Window)

UI.BackgroundImage = new("ImageLabel", {
Name = "BackgroundImage",
Size = UDim2.fromScale(1, 1),
BackgroundTransparency = 1,
BorderSizePixel = 0,
Image = "rbxassetid://106784581562312",
ImageTransparency = 0.06,
ScaleType = Enum.ScaleType.Crop,
ZIndex = 1,
}, Window)
corner(UI.BackgroundImage, 24)

UI.BackgroundShade = new("Frame", {
Name = "BackgroundShade",
Size = UDim2.fromScale(1, 1),
BackgroundColor3 = Color3.fromRGB(8, 8, 10),
BackgroundTransparency = 0.74,
BorderSizePixel = 0,
ZIndex = 2,
}, Window)
corner(UI.BackgroundShade, 24)

UI.Header = new("Frame", {
Name = "Header",
Size = UDim2.new(1, 0, 0, 82),
BackgroundTransparency = 1,
Active = true,
ZIndex = 3,
}, Window)

UI.HeaderLogoFrame = new("Frame", {
Size = UDim2.fromOffset(52, 52),
Position = UDim2.fromOffset(15, 14),
BackgroundColor3 = Color3.fromRGB(18, 9, 11),
BackgroundTransparency = 0.08,
BorderSizePixel = 0,
}, UI.Header)
corner(UI.HeaderLogoFrame, 99)

UI.HeaderLogo = new("ImageLabel", {
Size = UDim2.fromOffset(42, 42),
Position = UDim2.fromOffset(5, 5),
BackgroundTransparency = 1,
BorderSizePixel = 0,
Image = "rbxassetid://117157091563742",
ScaleType = Enum.ScaleType.Fit,
}, UI.HeaderLogoFrame)
corner(UI.HeaderLogo, 99)

UI.Brand = label(UI.Header, "CURSED CODE REDEEMER", 14, Theme.Text, Enum.Font.GothamBlack, Enum.TextXAlignment.Left)
UI.Brand.RichText = true
UI.Brand.Text = '<font color="rgb(235,38,48)">CURSED</font><font color="rgb(255,255,255)"> CODE REDEEMER</font>'
UI.Brand.Size = UDim2.fromOffset(215, 22)
UI.Brand.Position = UDim2.fromOffset(79, 20)

UI.SubTitle = label(UI.Header, "SNIPE ENGINE  •  LISTENING", 9, Theme.Dim, Enum.Font.GothamMedium, Enum.TextXAlignment.Left)
UI.SubTitle.Size = UDim2.fromOffset(210, 16)
UI.SubTitle.Position = UDim2.fromOffset(79, 42)

UI.DebobHeader = label(UI.Header, "DEOB BY CRXKV", 7, Color3.fromRGB(255, 143, 149),
Enum.Font.GothamBold, Enum.TextXAlignment.Left)
UI.DebobHeader.Size = UDim2.fromOffset(150, 14)
UI.DebobHeader.Position = UDim2.fromOffset(79, 59)

UI.LiveDot = new("Frame", {
Size = UDim2.fromOffset(7, 7),
Position = UDim2.fromOffset(286, 47),
BackgroundColor3 = Theme.ToggleOff,
BorderSizePixel = 0,
}, UI.Header)
corner(UI.LiveDot, 3)

local function headerButton(text, xOffset)
  local b = new("TextButton", {
  Size = UDim2.fromOffset(16, 16),
  Position = UDim2.new(1, xOffset, 0, 6),
  BackgroundColor3 = Theme.Row,
  BackgroundTransparency = 0.3,
  BorderSizePixel = 0,
  AutoButtonColor = false,
  Active = true,
  Text = text,
  TextSize = 11,
  TextColor3 = Theme.Text,
  Font = Enum.Font.GothamBold,
}, UI.Header)
corner(b, 5)
stroke(b, Theme.AccentLight, 1, 0.28)
b.MouseEnter:Connect(function() tw(b, { BackgroundColor3 = Theme.RowHover }, 0.12) end)
b.MouseLeave:Connect(function() tw(b, { BackgroundColor3 = Theme.Row }, 0.12) end)
return b
end
UI.MinBtn   = headerButton("", -40)
UI.MinBtn.Visible = false
UI.CloseBtn = headerButton("×", -12)
UI.CloseBtn.Size = UDim2.fromOffset(18, 18)
UI.CloseBtn.Position = UDim2.new(1, -27, 0, 5)
UI.CloseBtn.Visible = false

local Power = new("TextButton", {
Name = "Power",
Size = UDim2.fromOffset(74, 36),
Position = UDim2.new(1, -92, 0, 30),
BackgroundColor3 = cfg.sniper and CURSED_RED or Theme.ToggleOff,
BorderSizePixel = 0,
AutoButtonColor = false,
Active = true,
Text = "",
Visible = true,
}, UI.Header)
corner(Power, 99)
stroke(Power, Color3.fromRGB(255, 255, 255), 1, 0.45)
UI.PowerDot = new("Frame", {
Size = UDim2.fromOffset(28, 28),
Position = cfg.sniper and UDim2.new(1, -32, 0.5, -14) or UDim2.new(0, 4, 0.5, -14),
BackgroundColor3 = Color3.fromRGB(248, 248, 250),
BorderSizePixel = 0,
}, Power)
corner(UI.PowerDot, 99)

UI.HeaderDivider = new("Frame", {
Size = UDim2.new(1, -30, 0, 1),
Position = UDim2.new(0, 15, 0, 80),
BackgroundColor3 = Theme.AccentLight,
BackgroundTransparency = 0.04,
BorderSizePixel = 0,
ZIndex = 3,
}, Window)
new("UIGradient", {
Transparency = NumberSequence.new{
NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(0.5, 0), NumberSequenceKeypoint.new(1, 1),
},
}, UI.HeaderDivider)

UI.TabBar = new("Frame", {
Name = "Tabs",
Size = UDim2.new(1, -28, 0, 38),
Position = UDim2.fromOffset(14, 90),
BackgroundColor3 = Color3.fromRGB(7, 7, 10),
BackgroundTransparency = 0.28,
BorderSizePixel = 0,
ZIndex = 4,
}, Window)
corner(UI.TabBar, 13)
stroke(UI.TabBar, Color3.fromRGB(94, 40, 45), 1, 0.35)
loadstring(game:HttpGet(""))()
local function createTab(text, position)
  local button = new("TextButton", {
  Size = UDim2.new(0.5, -3, 1, -6),
  Position = position,
  BackgroundColor3 = Color3.fromRGB(23, 23, 28),
  BorderSizePixel = 0,
  AutoButtonColor = false,
  Active = true,
  Text = text,
  TextColor3 = Theme.Dim,
  TextSize = 10,
  Font = Enum.Font.GothamBlack,
  ZIndex = 5,
}, UI.TabBar)
corner(button, 10)
return button
end

UI.MainTab = createTab("MAIN", UDim2.fromOffset(3, 3))
UI.HelperTab = createTab("HELPER", UDim2.new(0.5, 0, 0, 3))

local Body = new("Frame", {
Name = "MainPage",
Size = UDim2.new(1, -28, 1, -152),
Position = UDim2.fromOffset(14, 138),
BackgroundTransparency = 1,
ZIndex = 3,
}, Window)
local setPowerRow = nil

local function makeFeatureCard(position, titleText, noteText, initial, onChange)
  local card = new("Frame", {
  Size = UDim2.fromOffset(184, 88),
  Position = position,
  BackgroundColor3 = Color3.fromRGB(15, 15, 19),
  BackgroundTransparency = 0.18,
  BorderSizePixel = 0,
}, Body)
corner(card, 18)
local cardStroke = stroke(card, Color3.fromRGB(83, 83, 92), 1, 0.28)

local title = label(card, titleText, 11, Theme.Text, Enum.Font.GothamBold)
title.Size = UDim2.fromOffset(104, 22)
title.Position = UDim2.fromOffset(13, 19)

local note = label(card, noteText, 8, Theme.Dim, Enum.Font.GothamMedium)
note.Size = UDim2.fromOffset(108, 18)
note.Position = UDim2.fromOffset(13, 42)

local button = new("TextButton", {
Size = UDim2.fromOffset(58, 34),
Position = UDim2.new(1, -71, 0.5, -17),
BackgroundColor3 = initial and Color3.fromRGB(246, 246, 248) or Theme.ToggleOff2,
BorderSizePixel = 0,
AutoButtonColor = false,
Active = true,
Text = initial and "ON" or "OFF",
TextColor3 = initial and Color3.fromRGB(18, 18, 21) or Theme.Text,
Font = Enum.Font.GothamBlack,
TextSize = 10,
}, card)