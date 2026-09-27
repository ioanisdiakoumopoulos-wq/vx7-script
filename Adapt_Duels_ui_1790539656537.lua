local Players      = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService   = game:GetService("RunService")
local UIS          = game:GetService("UserInputService")
local Stats        = game:GetService("Stats")

local player = Players.LocalPlayer

local C = {
    Bg        = Color3.fromRGB(16, 16, 20),
    Panel     = Color3.fromRGB(26, 26, 32),
    Hover     = Color3.fromRGB(36, 36, 44),
    White     = Color3.fromRGB(255, 255, 255),
    WhiteSoft = Color3.fromRGB(245, 238, 248),
    SubText   = Color3.fromRGB(215, 215, 225),
    Pink      = Color3.fromRGB(255, 120, 220),
    PinkGlow  = Color3.fromRGB(255, 160, 235),
    PinkDark  = Color3.fromRGB(70, 32, 62),
    PinkDeep  = Color3.fromRGB(195, 45, 145),
    PinkTab   = Color3.fromRGB(50, 24, 46),
    Gray      = Color3.fromRGB(120, 120, 135),
    OffTrack  = Color3.fromRGB(40, 40, 48),
    OffKnob   = Color3.fromRGB(150, 150, 160),
    Yellow    = Color3.fromRGB(255, 208, 64),
    Dark      = Color3.fromRGB(18, 10, 16),
}

local function New(class, props, children)
    local o = Instance.new(class)
    for k, v in pairs(props or {}) do o[k] = v end
    for _, c in ipairs(children or {}) do c.Parent = o end
    return o
end

local function Corner(r) return New("UICorner", {CornerRadius = UDim.new(0, r)}) end

local function Stroke(col, th, tr)
    return New("UIStroke", {Color = col, Thickness = th or 1.6, Transparency = tr or 0, ApplyStrokeMode = Enum.ApplyStrokeMode.Border})
end

local function Tween(o, p, t, style, dir)
    local tw = TweenService:Create(o, TweenInfo.new(t or 0.2, style or Enum.EasingStyle.Quad, dir or Enum.EasingDirection.Out), p)
    tw:Play() return tw
end

local function Hover(btn, baseCol, hoverCol, scaleUp)
    local scale = New("UIScale", {Scale = 1, Parent = btn})
    btn.MouseEnter:Connect(function()
        Tween(scale, {Scale = scaleUp or 1.04}, 0.15, Enum.EasingStyle.Back)
        if hoverCol then Tween(btn, {BackgroundColor3 = hoverCol}, 0.15) end
    end)
    btn.MouseLeave:Connect(function()
        Tween(scale, {Scale = 1}, 0.15)
        if baseCol then Tween(btn, {BackgroundColor3 = baseCol}, 0.15) end
    end)
    btn.MouseButton1Down:Connect(function() Tween(scale, {Scale = 0.96}, 0.08) end)
    btn.MouseButton1Up:Connect(function() Tween(scale, {Scale = scaleUp or 1.04}, 0.12, Enum.EasingStyle.Back) end)
    return scale
end

local function Pulse(stroke, a, b)
    task.spawn(function()
        while stroke.Parent do
            Tween(stroke, {Color = b}, 1.2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
            task.wait(1.2)
            Tween(stroke, {Color = a}, 1.2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
            task.wait(1.2)
        end
    end)
end

local gui = New("ScreenGui", {
    Name = "AdaptUI", ResetOnSpawn = false,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    Parent = player:WaitForChild("PlayerGui"),
})

local main = New("Frame", {
    Size = UDim2.fromOffset(350, 520),
    Position = UDim2.new(0.5, -175, 0.5, -260),
    BackgroundColor3 = C.Bg, BackgroundTransparency = 0.08,
    BorderSizePixel = 0, ClipsDescendants = true,
    Parent = gui,
}, { Corner(18) })

local bgImage = New("ImageLabel", {
    Name = "BackgroundImage",
    Size = UDim2.fromScale(1, 1),
    Position = UDim2.fromScale(0, 0),
    BackgroundTransparency = 1,
    Image = "rbxassetid://116587787334634",
    ScaleType = Enum.ScaleType.Crop,
    ZIndex = 0,
    Parent = main,
}, { Corner(18) })

local mainScale = New("UIScale", {Scale = 0, Parent = main})

local locked = false
local dragging, dragStart, startPos

main.InputBegan:Connect(function(i)
    if locked then return end
    if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
        dragging, dragStart, startPos = true, i.Position, main.Position
    end
end)

UIS.InputChanged:Connect(function(i)
    if locked or not dragging then return end
    if i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch then
        local d = i.Position - dragStart
        Tween(main, {Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)}, 0.05)
    end
end)

UIS.InputEnded:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then dragging = false end
end)

local header = New("Frame", {Size = UDim2.new(1, 0, 0, 64), BackgroundTransparency = 1, ZIndex = 2, Parent = main})

local logo = New("ImageButton", {
    Position = UDim2.fromOffset(14, 14), Size = UDim2.fromOffset(38, 38),
    BackgroundColor3 = C.Panel, AutoButtonColor = false,
    Image = "", ScaleType = Enum.ScaleType.Crop,
    Parent = header,
}, { Corner(11), Stroke(C.Pink, 1.2) })
Hover(logo, C.Panel, C.Hover)

task.spawn(function()
    local ok, content = pcall(function()
        return Players:GetUserThumbnailAsync(player.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size150x150)
    end)
    if ok and content then
        logo.Image = content
    end
end)

local title = New("TextLabel", {
    Position = UDim2.fromOffset(64, 10), Size = UDim2.fromOffset(120, 24),
    BackgroundTransparency = 1, Text = "", Font = Enum.Font.GothamBlack, TextSize = 21,
    TextColor3 = C.White, TextXAlignment = Enum.TextXAlignment.Left, Parent = header,
})

New("TextLabel", {
    Position = UDim2.fromOffset(64, 34), Size = UDim2.fromOffset(150, 16),
    BackgroundTransparency = 1, Text = "Made By TooZe/Juel", Font = Enum.Font.GothamBold, TextSize = 11,
    TextColor3 = C.WhiteSoft, TextXAlignment = Enum.TextXAlignment.Left, Parent = header,
})

local discord = New("TextButton", {
    Position = UDim2.fromOffset(156, 8), Size = UDim2.fromOffset(112, 22),
    BackgroundColor3 = C.Bg, AutoButtonColor = false,
    Text = "discord.gg/adaptt", Font = Enum.Font.GothamBold, TextSize = 11, TextColor3 = C.White,
    Parent = header,
}, { Corner(11) })
local discordStroke = Stroke(C.Pink, 1.8) discordStroke.Parent = discord
Pulse(discordStroke, C.Pink, C.PinkGlow)
Hover(discord, C.Bg, C.PinkTab, 1.06)

discord.MouseButton1Click:Connect(function()
    local text = discord.Text
    if setclipboard then
        setclipboard(text)
    elseif typeof(setclipboard) == "function" then
        setclipboard(text)
    end
    local old = discord.Text
    discord.Text = "copied"
    task.delay(0.8, function()
        if discord and discord.Parent then
            discord.Text = old
        end
    end)
end)

local pingLabel = New("TextLabel", {
    Position = UDim2.fromOffset(200, 34), Size = UDim2.fromOffset(120, 16),
    BackgroundTransparency = 1, Text = "Ping: 0ms | FPS: 0", Font = Enum.Font.GothamBold, TextSize = 11,
    TextColor3 = C.PinkGlow, TextXAlignment = Enum.TextXAlignment.Left, Parent = header,
})

local lockBtn = New("TextButton", {
    Position = UDim2.new(1, -78, 0, 14), Size = UDim2.fromOffset(30, 30),
    BackgroundColor3 = C.Panel, AutoButtonColor = false,
    Text = "🔓", TextSize = 14, Font = Enum.Font.GothamBold, TextColor3 = C.Yellow,
    Parent = header,
}, { Corner(9), Stroke(C.Pink, 1.2) })
Hover(lockBtn, C.Panel, C.Hover)
lockBtn.MouseButton1Click:Connect(function()
    locked = not locked
    lockBtn.Text = locked and "🔒" or "🔓"
end)

local minimizeBtn = New("TextButton", {
    Position = UDim2.new(1, -42, 0, 14), Size = UDim2.fromOffset(30, 30),
    BackgroundColor3 = C.Panel, AutoButtonColor = false,
    Text = "–", TextSize = 20, Font = Enum.Font.GothamBold, TextColor3 = C.White,
    Parent = header,
}, { Corner(9), Stroke(C.Pink, 1.2) })
Hover(minimizeBtn, C.Panel, C.Hover)

local tabs = New("ScrollingFrame", {
    Position = UDim2.fromOffset(14, 72), Size = UDim2.new(1, -28, 0, 42),
    BackgroundTransparency = 1, BorderSizePixel = 0, ScrollBarThickness = 0,
    ScrollingDirection = Enum.ScrollingDirection.X,
    CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.X,
    ElasticBehavior = Enum.ElasticBehavior.Always, ZIndex = 2, Parent = main,
}, {
    New("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 8),
        SortOrder = Enum.SortOrder.LayoutOrder, VerticalAlignment = Enum.VerticalAlignment.Center,
    }),
    New("UIPadding", {
        PaddingLeft   = UDim.new(0, 4),
        PaddingRight  = UDim.new(0, 6),
        PaddingTop    = UDim.new(0, 3),
        PaddingBottom = UDim.new(0, 3),
    }),
})

local content
local activeTab

local function SetActiveTab(btn)
    if activeTab == btn then return end
    if activeTab then
        Tween(activeTab, {BackgroundColor3 = C.Panel, BackgroundTransparency = 0.45}, 0.25)
        Tween(activeTab.UIStroke, {Color = C.White, Thickness = 1.0, Transparency = 0.2}, 0.25)
    end
    activeTab = btn
    Tween(btn, {BackgroundColor3 = C.PinkTab, BackgroundTransparency = 0.25}, 0.25)
    Tween(btn.UIStroke, {Color = C.Pink, Thickness = 1.4, Transparency = 0}, 0.25)
    task.spawn(function()
        Tween(btn.UIStroke, {Color = C.PinkGlow}, 0.15)
        task.wait(0.15)
        Tween(btn.UIStroke, {Color = C.Pink}, 0.4)
    end)
    if content then
        for _, row in ipairs(content:GetChildren()) do
            if row:IsA("Frame") then
                local s = row:FindFirstChildOfClass("UIScale")
                if s then s.Scale = 0.9 end
                row.BackgroundTransparency = 1
                task.delay(0.03 * (row.LayoutOrder - 1), function()
                    if s then Tween(s, {Scale = 1}, 0.35, Enum.EasingStyle.Back) end
                    Tween(row, {BackgroundTransparency = 0.45}, 0.3)
                end)
            end
        end
    end
end

local tabButtons = {}
for i, name in ipairs({"Speed", "Combat", "Steal", "Movement", "Visuals", "Player", "Misc", "Settings"}) do
    local btn = New("TextButton", {
        Size = UDim2.fromOffset(78, 36), BackgroundColor3 = C.Panel, BackgroundTransparency = 0.45,
        AutoButtonColor = false, Text = name, Font = Enum.Font.GothamBold, TextSize = 13,
        TextColor3 = C.White, LayoutOrder = i, ZIndex = 2, Parent = tabs,
    }, { Corner(10), Stroke(C.White, 1.0, 0.2) })
    Hover(btn, nil, nil, 1.05)
    btn.MouseButton1Click:Connect(function() SetActiveTab(btn) end)
    tabButtons[name] = btn
end

content = New("ScrollingFrame", {
    Position = UDim2.fromOffset(14, 124), Size = UDim2.new(1, -28, 1, -138),
    BackgroundTransparency = 1, BorderSizePixel = 0,
    ScrollBarThickness = 3, ScrollBarImageColor3 = C.Pink,
    CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.Y,
    ElasticBehavior = Enum.ElasticBehavior.Always, ZIndex = 2, Parent = main,
}, {
    New("UIListLayout", {Padding = UDim.new(0, 9), SortOrder = Enum.SortOrder.LayoutOrder}),
    New("UIPadding", {
        PaddingLeft   = UDim.new(0, 4),
        PaddingRight  = UDim.new(0, 8),
        PaddingTop    = UDim.new(0, 4),
        PaddingBottom = UDim.new(0, 6),
    }),
})

local order = 0
local function Row(h)
    order += 1
    local row = New("Frame", {
        Size = UDim2.new(1, -12, 0, h or 44), BackgroundColor3 = C.Panel, BackgroundTransparency = 0.45,
        LayoutOrder = order, ZIndex = 2, Parent = content,
    }, { Corner(12), Stroke(C.Pink, 1.0, 0.25), New("UIScale", {Scale = 1}) })
    row.MouseEnter:Connect(function()
        Tween(row.UIStroke, {Color = C.PinkGlow, Transparency = 0}, 0.2)
        Tween(row, {BackgroundColor3 = C.Hover, BackgroundTransparency = 0.3}, 0.2)
    end)
    row.MouseLeave:Connect(function()
        Tween(row.UIStroke, {Color = C.Pink, Transparency = 0.25}, 0.2)
        Tween(row, {BackgroundColor3 = C.Panel, BackgroundTransparency = 0.45}, 0.2)
    end)
    return row
end

local function RowLabel(parent, text, dot)
    if dot then
        New("Frame", {
            AnchorPoint = Vector2.new(0, 0.5),
            Position = UDim2.new(0, 0, 0.5, 0),
            Size = UDim2.fromOffset(4, 24),
            BackgroundColor3 = C.Pink,
            BackgroundTransparency = 0.45,
            BorderSizePixel = 0,
            ZIndex = 3,
            Parent = parent,
        }, { Corner(3) })

        New("Frame", {
            AnchorPoint = Vector2.new(0, 0.5),
            Position = UDim2.new(0, 11, 0.5, 0),
            Size = UDim2.fromOffset(5, 5),
            BackgroundColor3 = C.PinkDeep,
            BorderSizePixel = 0,
            ZIndex = 3,
            Parent = parent,
        }, { Corner(3) })
    end
    return New("TextLabel", {
        Position = UDim2.fromOffset(dot and 22 or 12, 0), Size = UDim2.new(1, -120, 1, 0),
        BackgroundTransparency = 1, Text = text, Font = Enum.Font.GothamBold, TextSize = 13,
        TextColor3 = C.White, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 3, Parent = parent,
    })
end

local function Toggle(text, default, cb)
    local row = Row(44)
    RowLabel(row, text, true)
    local state = default or false
    local track = New("TextButton", {
        AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -11, 0.5, 0),
        Size = UDim2.fromOffset(44, 22), BackgroundColor3 = state and C.PinkTab or C.OffTrack,
        BackgroundTransparency = 0.2, AutoButtonColor = false, Text = "", ZIndex = 3, Parent = row,
    }, { Corner(11), Stroke(C.Pink, 1.4, state and 0 or 0.3) })
    local knob = New("Frame", {
        AnchorPoint = Vector2.new(0, 0.5),
        Position = state and UDim2.new(1, -19, 0.5, 0) or UDim2.new(0, 3, 0.5, 0),
        Size = UDim2.fromOffset(16, 16), BackgroundColor3 = state and C.White or C.OffKnob,
        ZIndex = 4, Parent = track,
    }, { Corner(4) })
    local function Refresh()
        Tween(track, {BackgroundColor3 = state and C.PinkTab or C.OffTrack}, 0.25)
        Tween(track.UIStroke, {Color = state and C.Pink or C.PinkDeep, Transparency = state and 0 or 0.3}, 0.25)
        Tween(knob, {
            Position = state and UDim2.new(1, -19, 0.5, 0) or UDim2.new(0, 3, 0.5, 0),
            BackgroundColor3 = state and C.White or C.OffKnob,
        }, 0.35, Enum.EasingStyle.Back)
        Tween(knob, {Size = UDim2.fromOffset(20, 14)}, 0.1)
        task.delay(0.1, function() Tween(knob, {Size = UDim2.fromOffset(16, 16)}, 0.2, Enum.EasingStyle.Back) end)
    end
    track.MouseButton1Click:Connect(function() state = not state Refresh() if cb then cb(state) end end)
    return row
end

local function ValueBox(text, default, cb)
    local row = Row(44)
    RowLabel(row, text, true)
    local box = New("TextBox", {
        AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -11, 0.5, 0),
        Size = UDim2.fromOffset(70, 28), BackgroundColor3 = C.PinkDark, BackgroundTransparency = 0.3,
        Text = tostring(default), Font = Enum.Font.GothamBold, TextSize = 13,
        TextColor3 = C.White, ClearTextOnFocus = false, ZIndex = 3, Parent = row,
    }, { Corner(9), Stroke(C.Pink, 1.4) })
    box.Focused:Connect(function()
        Tween(box, {BackgroundColor3 = C.PinkTab, BackgroundTransparency = 0.15, Size = UDim2.fromOffset(76, 30)}, 0.2, Enum.EasingStyle.Back)
        Tween(box.UIStroke, {Color = C.PinkGlow, Thickness = 2.0}, 0.2)
    end)
    box.FocusLost:Connect(function()
        Tween(box, {BackgroundColor3 = C.PinkDark, BackgroundTransparency = 0.3, Size = UDim2.fromOffset(70, 28)}, 0.2)
        Tween(box.UIStroke, {Color = C.Pink, Thickness = 1.4}, 0.2)
        local n = tonumber(box.Text)
        if n then if cb then cb(n) end else box.Text = tostring(default) end
    end)
    return row
end

local function Segment(text, options, default, cb)
    local row = Row(44)
    RowLabel(row, text, true)
    local underline = New("Frame", {
        Position = UDim2.fromOffset(22, 31), Size = UDim2.fromOffset(0, 2),
        BackgroundColor3 = C.Pink, BorderSizePixel = 0, ZIndex = 3, Parent = row,
    }, {Corner(1)})
    task.delay(0.6, function() Tween(underline, {Size = UDim2.fromOffset(56, 2)}, 0.5, Enum.EasingStyle.Quart) end)
    local holder = New("Frame", {
        AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -8, 0.5, 0),
        Size = UDim2.fromOffset(170, 28), BackgroundTransparency = 1, ZIndex = 3, Parent = row,
    }, { New("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal, HorizontalAlignment = Enum.HorizontalAlignment.Right,
        VerticalAlignment = Enum.VerticalAlignment.Center, Padding = UDim.new(0, 5),
    }) })
    local buttons = {}
    local function Select(name)
        for n, b in pairs(buttons) do
            local on = n == name
            Tween(b, {
                BackgroundColor3 = on and C.Pink or C.Bg,
                BackgroundTransparency = on and 0.2 or 0.45,
                TextColor3 = on and C.Dark or C.White
            }, 0.25)
            Tween(b.UIStroke, {Transparency = on and 1 or 0.5}, 0.25)
            Tween(b.UIScale, {Scale = on and 1.08 or 1}, 0.3, Enum.EasingStyle.Back)
        end
        if cb then cb(name) end
    end
    for _, opt in ipairs(options) do
        local b = New("TextButton", {
            Size = UDim2.fromOffset(opt == "INFO" and 42 or 56, 25), BackgroundColor3 = C.Bg,
            BackgroundTransparency = 0.45, AutoButtonColor = false, Text = opt, Font = Enum.Font.GothamBold,
            TextSize = 10, TextColor3 = C.White, ZIndex = 3, Parent = holder,
        }, { Corner(8), Stroke(C.White, 1.0, 0.4), New("UIScale", {Scale = 1}) })
        b.MouseButton1Click:Connect(function() Select(opt) end)
        buttons[opt] = b
    end
    Select(default)
    return row
end

ValueBox("FOV Value", 120)
Toggle("No Cam Collision", true)
Toggle("Anti Lag", true)
Toggle("Ultra Mode", true)
Toggle("Remove Accessories", false)
Toggle("Potato Graphics", false)
Toggle("Player ESP", true)
Segment("ESP Mode", {"INFO", "NO INFO", "LINE ON"}, "LINE ON")

local minimized = false
minimizeBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    minimizeBtn.Text = minimized and "+" or "–"
    if minimized then
        tabs.Visible = false
        content.Visible = false
        Tween(main, {Size = UDim2.fromOffset(350, 64)}, 0.35, Enum.EasingStyle.Quart)
    else
        Tween(main, {Size = UDim2.fromOffset(350, 520)}, 0.4, Enum.EasingStyle.Back)
        task.delay(0.15, function()
            tabs.Visible = true
            content.Visible = true
        end)
    end
end)

task.spawn(function()
    Tween(mainScale, {Scale = 1}, 0.5, Enum.EasingStyle.Back)
    for i = 1, #("ADAPT") do
        title.Text = ("ADAPT"):sub(1, i)
        task.wait(0.06)
    end
    for i, name in ipairs({"Speed", "Combat", "Steal", "Movement", "Visuals", "Player", "Misc", "Settings"}) do
        local b = tabButtons[name]
        local s = b:FindFirstChildOfClass("UIScale")
        s.Scale = 0
        task.delay(0.05 * i, function() Tween(s, {Scale = 1}, 0.35, Enum.EasingStyle.Back) end)
    end
    task.wait(0.3)
    SetActiveTab(tabButtons.Movement)
end)

local frames, last = 0, tick()
RunService.RenderStepped:Connect(function()
    frames += 1
    if tick() - last >= 1 then
        local ok, ping = pcall(function() return math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue()) end)
        pingLabel.Text = ("Ping: %dms | FPS: %d"):format(ok and ping or 0, frames)
        frames, last = 0, tick()
    end
end)