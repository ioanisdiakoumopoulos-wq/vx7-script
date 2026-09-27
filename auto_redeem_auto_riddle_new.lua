-- Wrapped from attached_assets/AUTO_REDEEM_+_AUTO_RIDDLE_NEW_(2)_1790516918148.txt
-- Local wrapper; requires a Roblox Lua executor that provides loadstring.
local __auto_redeem_source = [=[
-- ========================================================================
--  360 LEAKS  —  Full Auto‑Redeemer & Riddle Solver
--  Custom Obsidian UI (purple/cyan accent, no overlapping, smaller welcome)
-- ========================================================================

-- ========================== OBSIDIAN UI ================================
local TweenService      = game:GetService("TweenService")
local UserInputService  = game:GetService("UserInputService")
local Players           = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Custom Theme – purple/cyan
local Theme = {
    Background  = Color3.fromRGB( 10, 11, 14),
    Panel       = Color3.fromRGB( 16, 18, 22),
    Element     = Color3.fromRGB( 22, 26, 32),
    ElementHover= Color3.fromRGB( 30, 35, 42),
    Border      = Color3.fromRGB( 40, 46, 54),
    BorderLight = Color3.fromRGB( 56, 64, 74),
    Accent      = Color3.fromRGB(150,  80, 255),
    AccentDim   = Color3.fromRGB(100,  50, 180),
    Text        = Color3.fromRGB(220, 226, 234),
    TextDim     = Color3.fromRGB(140, 150, 165),
    TextFaint   = Color3.fromRGB( 90, 100, 115),
    Risk        = Color3.fromRGB(232,  86,  86),
}

local Registry = {}
local function reg(inst, prop, key)
    table.insert(Registry, { inst = inst, prop = prop, key = key })
    inst[prop] = Theme[key]
    return inst
end

local function retint(key, color)
    Theme[key] = color
    for _, e in ipairs(Registry) do
        if e.key == key and e.inst and e.inst.Parent ~= nil then
            pcall(function() e.inst[e.prop] = color end)
        end
    end
end

local function font(name, fallback)
    local ok, f = pcall(function() return Enum.Font[name] end)
    if ok and f then return f end
    return Enum.Font[fallback or "SourceSans"]
end

local F = {
    Label = font("Gotham", "SourceSans"),
    Head  = font("GothamMedium", "SourceSansBold"),
    Bold  = font("GothamBold", "SourceSansBold"),
    Mono  = font("Code", "SourceSans"),
}

local function new(class, props, children)
    local inst = Instance.new(class)
    local parent
    for k, v in pairs(props or {}) do
        if k == "Parent" then parent = v else inst[k] = v end
    end
    for _, c in ipairs(children or {}) do c.Parent = inst end
    if parent then inst.Parent = parent end
    return inst
end

local function corner(r)
    return new("UICorner", { CornerRadius = UDim.new(0, r or 4) })
end

local function stroke(key, thickness, transparency)
    local s = new("UIStroke", {
        Thickness        = thickness or 1,
        Transparency     = transparency or 0,
        ApplyStrokeMode  = Enum.ApplyStrokeMode.Border,
    })
    reg(s, "Color", key or "Border")
    return s
end

local function pad(t, b, l, r)
    return new("UIPadding", {
        PaddingTop    = UDim.new(0, t or 0),
        PaddingBottom = UDim.new(0, b or t or 0),
        PaddingLeft   = UDim.new(0, l or 0),
        PaddingRight  = UDim.new(0, r or l or 0),
    })
end

local function list(padding, dir)
    return new("UIListLayout", {
        Padding   = UDim.new(0, padding or 0),
        SortOrder = Enum.SortOrder.LayoutOrder,
        FillDirection = dir or Enum.FillDirection.Vertical,
    })
end

local TW_FAST = TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local TW_MED  = TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local TW_SLOW = TweenInfo.new(0.40, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)

local function tween(inst, info, props)
    local t = TweenService:Create(inst, info, props)
    t:Play()
    return t
end

local function round(n, places)
    local m = 10 ^ (places or 0)
    return math.floor(n * m + 0.5) / m
end

local function mount(gui)
    if typeof(gethui) == "function" then
        local ok = pcall(function() gui.Parent = gethui() end)
        if ok and gui.Parent then return end
    end
    if syn and typeof(syn.protect_gui) == "function" then
        local ok = pcall(function()
            syn.protect_gui(gui)
            gui.Parent = game:GetService("CoreGui")
        end)
        if ok and gui.Parent then return end
    end
    local ok = pcall(function() gui.Parent = game:GetService("CoreGui") end)
    if ok and gui.Parent then return end
    gui.Parent = LocalPlayer:WaitForChild("PlayerGui")
end

local Obsidian = {}
Obsidian.Flags = {}
Obsidian.Theme = Theme

local Screen = new("ScreenGui", {
    Name             = "ObsidianUI",
    ResetOnSpawn     = false,
    ZIndexBehavior   = Enum.ZIndexBehavior.Sibling,
    IgnoreGuiInset   = true,
    DisplayOrder     = 999,
})
mount(Screen)

-- Notifications
local NotifyHolder = new("Frame", {
    Name                   = "Notifications",
    AnchorPoint            = Vector2.new(1, 1),
    Position               = UDim2.new(1, -16, 1, -16),
    Size                   = UDim2.new(0, 260, 1, -32),
    BackgroundTransparency = 1,
    Parent                 = Screen,
}, {
    new("UIListLayout", {
        Padding             = UDim.new(0, 6),
        SortOrder           = Enum.SortOrder.LayoutOrder,
        VerticalAlignment   = Enum.VerticalAlignment.Bottom,
        HorizontalAlignment = Enum.HorizontalAlignment.Right,
    }),
})

function Obsidian:Notify(text, duration)
    duration = duration or 3
    local card = new("Frame", {
        Size                   = UDim2.new(1, 0, 0, 0),
        BackgroundTransparency = 1,
        ClipsDescendants       = true,
        Parent                 = NotifyHolder,
    })
    local body = new("Frame", {
        Size     = UDim2.new(1, 0, 0, 38),
        Parent   = card,
    }, { corner(4), stroke("Border") })
    reg(body, "BackgroundColor3", "Panel")

    local rail = new("Frame", {
        Size         = UDim2.new(0, 2, 1, -10),
        Position     = UDim2.new(0, 8, 0, 5),
        BorderSizePixel = 0,
        Parent       = body,
    })
    reg(rail, "BackgroundColor3", "Accent")

    local label = new("TextLabel", {
        Position               = UDim2.new(0, 20, 0, 0),
        Size                   = UDim2.new(1, -28, 1, 0),
        BackgroundTransparency = 1,
        Font                   = F.Label,
        Text                   = tostring(text),
        TextSize               = 14,
        TextXAlignment         = Enum.TextXAlignment.Left,
        TextTruncate           = Enum.TextTruncate.AtEnd,
        Parent                 = body,
    })
    reg(label, "TextColor3", "Text")

    tween(card, TW_MED, { Size = UDim2.new(1, 0, 0, 38) })
    task.delay(duration, function()
        tween(card, TW_MED, { Size = UDim2.new(1, 0, 0, 0) })
        tween(body, TW_MED, { BackgroundTransparency = 1 })
        tween(label, TW_MED, { TextTransparency = 1 })
        task.wait(0.28)
        card:Destroy()
    end)
end

function Obsidian:CreateWindow(cfg)
    cfg = cfg or {}
    local title     = cfg.Title     or "obsidian"
    local tag       = cfg.Tag       or ""
    local size      = cfg.Size      or UDim2.new(0, 700, 0, 480)
    local toggleKey = cfg.ToggleKey or Enum.KeyCode.RightShift

    local Main = new("Frame", {
        Name             = "Window",
        AnchorPoint      = Vector2.new(0.5, 0.5),
        Position         = UDim2.new(0.5, 0, 0.5, 0),
        Size             = UDim2.new(0, 0, 0, 0),
        BorderSizePixel  = 0,
        ClipsDescendants = true,
        Visible          = false,
        Parent           = Screen,
    }, { corner(6), stroke("BorderLight") })
    reg(Main, "BackgroundColor3", "Background")

    -- Title bar (height 38)
    local TitleBar = new("Frame", {
        Size            = UDim2.new(1, 0, 0, 38),
        BackgroundTransparency = 1,
        Parent          = Main,
    })

    local brand = new("TextLabel", {
        Position               = UDim2.new(0, 16, 0, 0),
        Size                   = UDim2.new(0, 220, 1, 0),
        BackgroundTransparency = 1,
        Font                   = F.Bold,
        Text                   = title,
        TextSize               = 16,
        TextXAlignment         = Enum.TextXAlignment.Left,
        Parent                 = TitleBar,
    })
    reg(brand, "TextColor3", "Text")

    if tag and tag ~= "" then
        local brandTag = new("TextLabel", {
            Position               = UDim2.new(0, 16 + brand.TextBounds.X, 0, 0),
            Size                   = UDim2.new(0, 120, 1, 0),
            BackgroundTransparency = 1,
            Font                   = F.Bold,
            Text                   = tag,
            TextSize               = 16,
            TextXAlignment         = Enum.TextXAlignment.Left,
            Parent                 = TitleBar,
        })
        reg(brandTag, "TextColor3", "Accent")
        task.defer(function()
            brandTag.Position = UDim2.new(0, 16 + brand.TextBounds.X + 2, 0, 0)
        end)
    end

    -- Status indicator
    local statusContainer = new("Frame", {
        AnchorPoint     = Vector2.new(1, 0.5),
        Position        = UDim2.new(1, -110, 0.5, 0),
        Size            = UDim2.new(0, 90, 0, 24),
        BackgroundTransparency = 1,
        Parent          = TitleBar,
    })

    local statusDot = new("Frame", {
        AnchorPoint     = Vector2.new(0, 0.5),
        Position        = UDim2.new(0, 0, 0.5, 0),
        Size            = UDim2.new(0, 10, 0, 10),
        BorderSizePixel = 0,
        Parent          = statusContainer,
    }, { corner(5) })
    reg(statusDot, "BackgroundColor3", "Accent")
    local dotGlow = new("UIStroke", {
        Thickness = 2,
        Transparency = 0.3,
        Color = Theme.Accent,
        Parent = statusDot,
    })

    local statusLabel = new("TextLabel", {
        Position        = UDim2.new(0, 16, 0, 0),
        Size            = UDim2.new(1, -16, 1, 0),
        BackgroundTransparency = 1,
        Font            = F.Label,
        Text            = "Active",
        TextSize        = 14,
        TextXAlignment  = Enum.TextXAlignment.Left,
        Parent          = statusContainer,
    })
    reg(statusLabel, "TextColor3", "Accent")

    -- Window buttons
    local function winButton(char, offset, hoverKey, onClick)
        local b = new("TextButton", {
            AnchorPoint            = Vector2.new(1, 0.5),
            Position               = UDim2.new(1, -offset, 0.5, 0),
            Size                   = UDim2.new(0, 24, 0, 24),
            BackgroundTransparency = 1,
            AutoButtonColor        = false,
            Font                   = F.Mono,
            Text                   = char,
            TextSize               = 16,
            Parent                 = TitleBar,
        })
        reg(b, "TextColor3", "TextDim")
        b.MouseEnter:Connect(function() b.TextColor3 = Theme[hoverKey] end)
        b.MouseLeave:Connect(function() b.TextColor3 = Theme.TextDim end)
        b.MouseButton1Click:Connect(onClick)
        return b
    end

    local minimized = false
    local fullSize  = size

    winButton("x", 14, "Risk", function()
        tween(Main, TW_MED, { Size = UDim2.new(0, fullSize.X.Offset, 0, 0) })
        task.wait(0.25)
        Screen:Destroy()
    end)

    local minBtn = winButton("-", 42, "Accent", function()
        minimized = not minimized
        tween(Main, TW_MED, {
            Size = minimized and UDim2.new(0, fullSize.X.Offset, 0, 38) or fullSize
        })
        minBtn.Text = minimized and "+" or "-"
    end)

    local sep = new("Frame", {
        Position        = UDim2.new(0, 0, 0, 38),
        Size            = UDim2.new(1, 0, 0, 1),
        BorderSizePixel = 0,
        Parent          = Main,
    })
    reg(sep, "BackgroundColor3", "Border")

    -- Dragging
    do
        local dragging, dragStart, startPos
        TitleBar.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
                dragging  = true
                dragStart = input.Position
                startPos  = Main.Position
                input.Changed:Connect(function()
                    if input.UserInputState == Enum.UserInputState.End then
                        dragging = false
                    end
                end)
            end
        end)
        UserInputService.InputChanged:Connect(function(input)
            if not dragging then return end
            if input.UserInputType == Enum.UserInputType.MouseMovement
            or input.UserInputType == Enum.UserInputType.Touch then
                local d = input.Position - dragStart
                Main.Position = UDim2.new(
                    startPos.X.Scale, startPos.X.Offset + d.X,
                    startPos.Y.Scale, startPos.Y.Offset + d.Y
                )
            end
        end)
    end

    -- Sidebar
    local Sidebar = new("Frame", {
        Position        = UDim2.new(0, 0, 0, 39),
        Size            = UDim2.new(0, 132, 1, -39),
        BackgroundTransparency = 1,
        Parent          = Main,
    }, { pad(12, 12, 8, 8), list(3) })

    local sideLine = new("Frame", {
        Position        = UDim2.new(0, 132, 0, 39),
        Size            = UDim2.new(0, 1, 1, -39),
        BorderSizePixel = 0,
        Parent          = Main,
    })
    reg(sideLine, "BackgroundColor3", "Border")

    -- Content
    local Content = new("Frame", {
        Position               = UDim2.new(0, 133, 0, 39),
        Size                   = UDim2.new(1, -133, 1, -39),
        BackgroundTransparency = 1,
        ClipsDescendants       = true,
        Parent                 = Main,
    })

    UserInputService.InputBegan:Connect(function(input, gpe)
        if gpe then return end
        if input.KeyCode == toggleKey then
            Main.Visible = not Main.Visible
        end
    end)

    local Window = { Tabs = {}, Main = Main, statusDot = statusDot, statusLabel = statusLabel }
    local activeTab

    function Window:AddTab(name)
        local Tab = {}

        local btn = new("TextButton", {
            Size                   = UDim2.new(1, 0, 0, 32),
            BackgroundTransparency = 1,
            AutoButtonColor        = false,
            Text                   = "",
            Parent                 = Sidebar,
        }, { corner(4) })
        reg(btn, "BackgroundColor3", "Element")

        local indicator = new("Frame", {
            Position        = UDim2.new(0, 0, 0.5, 0),
            AnchorPoint     = Vector2.new(0, 0.5),
            Size            = UDim2.new(0, 2, 0, 0),
            BorderSizePixel = 0,
            Parent          = btn,
        })
        reg(indicator, "BackgroundColor3", "Accent")

        local lbl = new("TextLabel", {
            Position               = UDim2.new(0, 14, 0, 0),
            Size                   = UDim2.new(1, -16, 1, 0),
            BackgroundTransparency = 1,
            Font                   = F.Label,
            Text                   = name,
            TextSize               = 14,
            TextXAlignment         = Enum.TextXAlignment.Left,
            Parent                 = btn,
        })
        reg(lbl, "TextColor3", "TextDim")

        local page = new("Frame", {
            Size                   = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            Visible                = false,
            Parent                 = Content,
        }, { pad(24, 14, 14, 14) })

        local function column(xScale, xOff)
            local col = new("ScrollingFrame", {
                Position               = UDim2.new(xScale, xOff, 0, 0),
                Size                   = UDim2.new(0.5, -5, 1, 0),
                BackgroundTransparency = 1,
                BorderSizePixel        = 0,
                ScrollBarThickness     = 2,
                ScrollBarImageColor3   = Theme.BorderLight,
                CanvasSize             = UDim2.new(0, 0, 0, 0),
                AutomaticCanvasSize    = Enum.AutomaticSize.Y,
                Parent                 = page,
            }, { list(12), pad(0, 12, 0, 4) })
            return col
        end

        local left  = column(0, 0)
        local right = column(0.5, 5)

        btn.MouseEnter:Connect(function()
            if activeTab ~= Tab then lbl.TextColor3 = Theme.Text end
        end)
        btn.MouseLeave:Connect(function()
            if activeTab ~= Tab then lbl.TextColor3 = Theme.TextDim end
        end)

        function Tab:Select()
            for _, t in ipairs(Window.Tabs) do t._deselect() end
            activeTab      = Tab
            page.Visible   = true
            lbl.TextColor3 = Theme.Text
            tween(btn, TW_FAST, { BackgroundTransparency = 0 })
            tween(indicator, TW_FAST, { Size = UDim2.new(0, 2, 0, 20) })
        end

        function Tab._deselect()
            page.Visible   = false
            lbl.TextColor3 = Theme.TextDim
            tween(btn, TW_FAST, { BackgroundTransparency = 1 })
            tween(indicator, TW_FAST, { Size = UDim2.new(0, 2, 0, 0) })
        end

        btn.MouseButton1Click:Connect(function() Tab:Select() end)

        function Tab:AddSection(sectionTitle, side)
            local parentCol = (side == "right") and right or left

            local box = new("Frame", {
                Size            = UDim2.new(1, 0, 0, 0),
                AutomaticSize   = Enum.AutomaticSize.Y,
                BorderSizePixel = 0,
                Parent          = parentCol,
            }, { corner(4), stroke("Border") })
            reg(box, "BackgroundColor3", "Panel")

            local inner = new("Frame", {
                Size                   = UDim2.new(1, 0, 0, 0),
                AutomaticSize          = Enum.AutomaticSize.Y,
                BackgroundTransparency = 1,
                Parent                 = box,
            }, { list(6), pad(16, 12, 12, 12) })

            local titleLbl = new("TextLabel", {
                Position       = UDim2.new(0, 10, 0, -8),
                Size           = UDim2.new(0, 0, 0, 14),
                AutomaticSize  = Enum.AutomaticSize.X,
                Font           = F.Head,
                Text           = sectionTitle,
                TextSize       = 13,
                TextXAlignment = Enum.TextXAlignment.Left,
                BorderSizePixel= 0,
                ZIndex         = 3,
                Parent         = box,
            }, { pad(0, 0, 6, 6) })
            reg(titleLbl, "TextColor3", "TextDim")
            reg(titleLbl, "BackgroundColor3", "Panel")

            local Section = {}

            local function row(height)
                return new("Frame", {
                    Size                   = UDim2.new(1, 0, 0, height),
                    BackgroundTransparency = 1,
                    Parent                 = inner,
                })
            end

            function Section:AddLabel(text)
                local r = row(20)
                local l = new("TextLabel", {
                    Size                   = UDim2.new(1, 0, 1, 0),
                    BackgroundTransparency = 1,
                    Font                   = F.Label,
                    Text                   = text,
                    TextSize               = 14,
                    TextXAlignment         = Enum.TextXAlignment.Left,
                    TextWrapped            = true,
                    Parent                 = r,
                })
                reg(l, "TextColor3", "TextFaint")
                return { Set = function(_, t) l.Text = t end }
            end

            function Section:AddDivider()
                local r = row(10)
                local d = new("Frame", {
                    Position        = UDim2.new(0, 0, 0.5, 0),
                    Size            = UDim2.new(1, 0, 0, 1),
                    BorderSizePixel = 0,
                    Parent          = r,
                })
                reg(d, "BackgroundColor3", "Border")
            end

            function Section:AddToggle(o)
                o = o or {}
                local state = o.Default or false

                local r = row(22)
                local btn2 = new("TextButton", {
                    Size                   = UDim2.new(1, 0, 1, 0),
                    BackgroundTransparency = 1,
                    AutoButtonColor        = false,
                    Text                   = "",
                    Parent                 = r,
                })

                local boxOuter = new("Frame", {
                    AnchorPoint     = Vector2.new(0, 0.5),
                    Position        = UDim2.new(0, 0, 0.5, 0),
                    Size            = UDim2.new(0, 16, 0, 16),
                    BorderSizePixel = 0,
                    Parent          = btn2,
                }, { corner(3), stroke("BorderLight") })
                reg(boxOuter, "BackgroundColor3", "Element")

                local fill = new("Frame", {
                    AnchorPoint            = Vector2.new(0.5, 0.5),
                    Position               = UDim2.new(0.5, 0, 0.5, 0),
                    Size                   = UDim2.new(0, 0, 0, 0),
                    BorderSizePixel        = 0,
                    Parent                 = boxOuter,
                }, { corner(2) })
                reg(fill, "BackgroundColor3", "Accent")

                local lbl2 = new("TextLabel", {
                    Position               = UDim2.new(0, 24, 0, 0),
                    Size                   = UDim2.new(1, -24, 1, 0),
                    BackgroundTransparency = 1,
                    Font                   = F.Label,
                    Text                   = o.Text or "Toggle",
                    TextSize               = 14,
                    TextXAlignment         = Enum.TextXAlignment.Left,
                    Parent                 = btn2,
                })
                reg(lbl2, "TextColor3", "TextDim")

                local api = {}

                function api:Set(v, silent)
                    state = v and true or false
                    if o.Flag then Obsidian.Flags[o.Flag] = state end
                    tween(fill, TW_FAST, {
                        Size = state and UDim2.new(0, 9, 0, 9) or UDim2.new(0, 0, 0, 0)
                    })
                    lbl2.TextColor3 = state and Theme.Text or Theme.TextDim
                    if not silent and o.Callback then
                        task.spawn(o.Callback, state)
                    end
                end

                function api:Get() return state end

                btn2.MouseButton1Click:Connect(function() api:Set(not state) end)
                btn2.MouseEnter:Connect(function()
                    if not state then lbl2.TextColor3 = Theme.Text end
                end)
                btn2.MouseLeave:Connect(function()
                    if not state then lbl2.TextColor3 = Theme.TextDim end
                end)

                api:Set(state, true)
                return api
            end

            function Section:AddSlider(o)
                o = o or {}
                local min      = o.Min or 0
                local max      = o.Max or 100
                local decimals = o.Decimals or 0
                local value    = math.clamp(o.Default or min, min, max)
                local suffix   = o.Suffix or ""

                local r = row(34)

                local lbl3 = new("TextLabel", {
                    Size                   = UDim2.new(1, -80, 0, 16),
                    BackgroundTransparency = 1,
                    Font                   = F.Label,
                    Text                   = o.Text or "Slider",
                    TextSize               = 14,
                    TextXAlignment         = Enum.TextXAlignment.Left,
                    Parent                 = r,
                })
                reg(lbl3, "TextColor3", "TextDim")

                local valLbl = new("TextLabel", {
                    AnchorPoint            = Vector2.new(1, 0),
                    Position               = UDim2.new(1, 0, 0, 0),
                    Size                   = UDim2.new(0, 80, 0, 16),
                    BackgroundTransparency = 1,
                    Font                   = F.Mono,
                    Text                   = "",
                    TextSize               = 14,
                    TextXAlignment         = Enum.TextXAlignment.Right,
                    Parent                 = r,
                })
                reg(valLbl, "TextColor3", "Text")

                local track = new("Frame", {
                    Position        = UDim2.new(0, 0, 0, 24),
                    Size            = UDim2.new(1, 0, 0, 5),
                    BorderSizePixel = 0,
                    Parent          = r,
                }, { corner(3) })
                reg(track, "BackgroundColor3", "Element")

                local fill2 = new("Frame", {
                    Size            = UDim2.new(0, 0, 1, 0),
                    BorderSizePixel = 0,
                    Parent          = track,
                }, { corner(3) })
                reg(fill2, "BackgroundColor3", "Accent")

                local api = {}

                function api:Set(v, silent)
                    value = math.clamp(round(v, decimals), min, max)
                    if o.Flag then Obsidian.Flags[o.Flag] = value end
                    local alpha = (max == min) and 0 or (value - min) / (max - min)
                    tween(fill2, TW_FAST, { Size = UDim2.new(alpha, 0, 1, 0) })
                    valLbl.Text = tostring(value) .. suffix
                    if not silent and o.Callback then
                        task.spawn(o.Callback, value)
                    end
                end

                function api:Get() return value end

                local sliding = false
                local function fromX(px)
                    local w = track.AbsoluteSize.X
                    if w <= 0 then return end
                    local a = math.clamp((px - track.AbsolutePosition.X) / w, 0, 1)
                    api:Set(min + (max - min) * a)
                end

                track.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1
                    or input.UserInputType == Enum.UserInputType.Touch then
                        sliding = true
                        fromX(input.Position.X)
                    end
                end)
                UserInputService.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1
                    or input.UserInputType == Enum.UserInputType.Touch then
                        sliding = false
                    end
                end)
                UserInputService.InputChanged:Connect(function(input)
                    if not sliding then return end
                    if input.UserInputType == Enum.UserInputType.MouseMovement
                    or input.UserInputType == Enum.UserInputType.Touch then
                        fromX(input.Position.X)
                    end
                end)

                api:Set(value, true)
                return api
            end

            function Section:AddButton(o)
                o = o or {}
                local r = row(28)
                local b = new("TextButton", {
                    Size            = UDim2.new(1, 0, 1, 0),
                    AutoButtonColor = false,
                    BorderSizePixel = 0,
                    Font            = F.Label,
                    Text            = o.Text or "Button",
                    TextSize        = 14,
                    Parent          = r,
                }, { corner(4), stroke("Border") })
                reg(b, "BackgroundColor3", "Element")
                reg(b, "TextColor3", "TextDim")

                b.MouseEnter:Connect(function()
                    tween(b, TW_FAST, { BackgroundColor3 = Theme.ElementHover })
                    b.TextColor3 = Theme.Text
                end)
                b.MouseLeave:Connect(function()
                    tween(b, TW_FAST, { BackgroundColor3 = Theme.Element })
                    b.TextColor3 = Theme.TextDim
                end)
                b.MouseButton1Click:Connect(function()
                    if o.Callback then task.spawn(o.Callback) end
                end)
                return b
            end

            function Section:AddTextbox(o)
                o = o or {}
                local r = row(42)

                local l = new("TextLabel", {
                    Size                   = UDim2.new(1, 0, 0, 16),
                    BackgroundTransparency = 1,
                    Font                   = F.Label,
                    Text                   = o.Text or "Input",
                    TextSize               = 14,
                    TextXAlignment         = Enum.TextXAlignment.Left,
                    Parent                 = r,
                })
                reg(l, "TextColor3", "TextDim")

                local holder = new("Frame", {
                    Position        = UDim2.new(0, 0, 0, 20),
                    Size            = UDim2.new(1, 0, 0, 22),
                    BorderSizePixel = 0,
                    Parent          = r,
                }, { corner(4), stroke("Border") })
                reg(holder, "BackgroundColor3", "Element")

                local tb = new("TextBox", {
                    Size                   = UDim2.new(1, -14, 1, 0),
                    Position               = UDim2.new(0, 8, 0, 0),
                    BackgroundTransparency = 1,
                    Font                   = F.Mono,
                    Text                   = o.Default or "",
                    PlaceholderText        = o.Placeholder or "...",
                    TextSize               = 14,
                    TextXAlignment         = Enum.TextXAlignment.Left,
                    ClearTextOnFocus       = false,
                    Parent                 = holder,
                })
                reg(tb, "TextColor3", "Text")
                reg(tb, "PlaceholderColor3", "TextFaint")

                tb.FocusLost:Connect(function(enter)
                    if o.Flag then Obsidian.Flags[o.Flag] = tb.Text end
                    if o.Callback then task.spawn(o.Callback, tb.Text, enter) end
                end)
                return tb
            end

            function Section:AddDropdown(o)
                o = o or {}
                local options  = o.Options or {}
                local selected = o.Default or (options[1] or "None")
                local open     = false

                local r = new("Frame", {
                    Size                   = UDim2.new(1, 0, 0, 42),
                    BackgroundTransparency = 1,
                    ClipsDescendants       = true,
                    Parent                 = inner,
                })

                local l = new("TextLabel", {
                    Size                   = UDim2.new(1, 0, 0, 16),
                    BackgroundTransparency = 1,
                    Font                   = F.Label,
                    Text                   = o.Text or "Dropdown",
                    TextSize               = 14,
                    TextXAlignment         = Enum.TextXAlignment.Left,
                    Parent                 = r,
                })
                reg(l, "TextColor3", "TextDim")

                local head = new("TextButton", {
                    Position        = UDim2.new(0, 0, 0, 20),
                    Size            = UDim2.new(1, 0, 0, 22),
                    AutoButtonColor = false,
                    BorderSizePixel = 0,
                    Text            = "",
                    Parent          = r,
                }, { corner(4), stroke("Border") })
                reg(head, "BackgroundColor3", "Element")

                local sel = new("TextLabel", {
                    Position               = UDim2.new(0, 8, 0, 0),
                    Size                   = UDim2.new(1, -30, 1, 0),
                    BackgroundTransparency = 1,
                    Font                   = F.Mono,
                    Text                   = tostring(selected),
                    TextSize               = 14,
                    TextXAlignment         = Enum.TextXAlignment.Left,
                    TextTruncate           = Enum.TextTruncate.AtEnd,
                    Parent                 = head,
                })
                reg(sel, "TextColor3", "Text")

                local arrow = new("TextLabel", {
                    AnchorPoint            = Vector2.new(1, 0.5),
                    Position               = UDim2.new(1, -8, 0.5, 0),
                    Size                   = UDim2.new(0, 14, 0, 14),
                    BackgroundTransparency = 1,
                    Font                   = F.Mono,
                    Text                   = "+",
                    TextSize               = 16,
                    Parent                 = head,
                })
                reg(arrow, "TextColor3", "TextDim")

                local listHolder = new("Frame", {
                    Position               = UDim2.new(0, 0, 0, 44),
                    Size                   = UDim2.new(1, 0, 0, 0),
                    BackgroundTransparency = 1,
                    Parent                 = r,
                }, { list(2) })

                local api = { Selected = selected }

                local function rebuild()
                    for _, c in ipairs(listHolder:GetChildren()) do
                        if c:IsA("TextButton") then c:Destroy() end
                    end
                    for _, opt in ipairs(options) do
                        local ob = new("TextButton", {
                            Size            = UDim2.new(1, 0, 0, 22),
                            AutoButtonColor = false,
                            BorderSizePixel = 0,
                            Font            = F.Mono,
                            Text            = "  " .. tostring(opt),
                            TextSize        = 14,
                            TextXAlignment  = Enum.TextXAlignment.Left,
                            Parent          = listHolder,
                        }, { corner(3) })
                        reg(ob, "BackgroundColor3", "Element")
                        ob.TextColor3 = (opt == api.Selected) and Theme.Accent or Theme.TextDim

                        ob.MouseEnter:Connect(function()
                            tween(ob, TW_FAST, { BackgroundColor3 = Theme.ElementHover })
                        end)
                        ob.MouseLeave:Connect(function()
                            tween(ob, TW_FAST, { BackgroundColor3 = Theme.Element })
                        end)
                        ob.MouseButton1Click:Connect(function()
                            api:Set(opt)
                            open = false
                            tween(r, TW_FAST, { Size = UDim2.new(1, 0, 0, 42) })
                            arrow.Text = "+"
                        end)
                    end
                end

                function api:Set(v, silent)
                    api.Selected = v
                    sel.Text = tostring(v)
                    if o.Flag then Obsidian.Flags[o.Flag] = v end
                    rebuild()
                    if not silent and o.Callback then task.spawn(o.Callback, v) end
                end

                function api:SetOptions(t)
                    options = t
                    rebuild()
                end

                head.MouseButton1Click:Connect(function()
                    open = not open
                    local h = open and (44 + #options * 23) or 42
                    tween(r, TW_FAST, { Size = UDim2.new(1, 0, 0, h) })
                    arrow.Text = open and "-" or "+"
                end)

                rebuild()
                if o.Flag then Obsidian.Flags[o.Flag] = selected end
                return api
            end

            function Section:AddKeybind(o)
                o = o or {}
                local bound   = o.Default
                local binding = false

                local r = row(24)

                local l = new("TextLabel", {
                    Size                   = UDim2.new(1, -80, 1, 0),
                    BackgroundTransparency = 1,
                    Font                   = F.Label,
                    Text                   = o.Text or "Keybind",
                    TextSize               = 14,
                    TextXAlignment         = Enum.TextXAlignment.Left,
                    Parent                 = r,
                })
                reg(l, "TextColor3", "TextDim")

                local kb = new("TextButton", {
                    AnchorPoint     = Vector2.new(1, 0.5),
                    Position        = UDim2.new(1, 0, 0.5, 0),
                    Size            = UDim2.new(0, 74, 0, 20),
                    AutoButtonColor = false,
                    BorderSizePixel = 0,
                    Font            = F.Mono,
                    Text            = bound and bound.Name or "[ none ]",
                    TextSize        = 13,
                    Parent          = r,
                }, { corner(3), stroke("Border") })
                reg(kb, "BackgroundColor3", "Element")
                reg(kb, "TextColor3", "TextDim")

                kb.MouseButton1Click:Connect(function()
                    binding  = true
                    kb.Text  = "[ ... ]"
                    kb.TextColor3 = Theme.Accent
                end)

                UserInputService.InputBegan:Connect(function(input, gpe)
                    if binding and input.UserInputType == Enum.UserInputType.Keyboard then
                        binding = false
                        if input.KeyCode == Enum.KeyCode.Backspace then
                            bound   = nil
                            kb.Text = "[ none ]"
                        else
                            bound   = input.KeyCode
                            kb.Text = bound.Name
                        end
                        kb.TextColor3 = Theme.TextDim
                        if o.Flag then Obsidian.Flags[o.Flag] = bound end
                        if o.OnBind then task.spawn(o.OnBind, bound) end
                        return
                    end
                    if gpe then return end
                    if bound and input.KeyCode == bound and o.Callback then
                        task.spawn(o.Callback)
                    end
                end)

                return {
                    Get = function() return bound end,
                    Set = function(_, k)
                        bound   = k
                        kb.Text = k and k.Name or "[ none ]"
                    end,
                }
            end

            function Section:AddColorpicker(o)
                o = o or {}
                local col   = o.Default or Theme.Accent
                local h, s, v = Color3.toHSV(col)
                local open  = false

                local r = new("Frame", {
                    Size                   = UDim2.new(1, 0, 0, 24),
                    BackgroundTransparency = 1,
                    ClipsDescendants       = true,
                    Parent                 = inner,
                })

                local l = new("TextLabel", {
                    Size                   = UDim2.new(1, -44, 0, 24),
                    BackgroundTransparency = 1,
                    Font                   = F.Label,
                    Text                   = o.Text or "Color",
                    TextSize               = 14,
                    TextXAlignment         = Enum.TextXAlignment.Left,
                    Parent                 = r,
                })
                reg(l, "TextColor3", "TextDim")

                local swatch = new("TextButton", {
                    AnchorPoint     = Vector2.new(1, 0),
                    Position        = UDim2.new(1, 0, 0, 4),
                    Size            = UDim2.new(0, 36, 0, 16),
                    BackgroundColor3= col,
                    AutoButtonColor = false,
                    BorderSizePixel = 0,
                    Text            = "",
                    Parent          = r,
                }, { corner(3), stroke("BorderLight") })

                local body2 = new("Frame", {
                    Position        = UDim2.new(0, 0, 0, 28),
                    Size            = UDim2.new(1, 0, 0, 108),
                    BorderSizePixel = 0,
                    Parent          = r,
                }, { corner(4), stroke("Border") })
                reg(body2, "BackgroundColor3", "Element")

                local field = new("Frame", {
                    Position         = UDim2.new(0, 10, 0, 10),
                    Size             = UDim2.new(1, -20, 0, 70),
                    BackgroundColor3 = Color3.fromHSV(h, 1, 1),
                    BorderSizePixel  = 0,
                    Parent           = body2,
                }, { corner(3) })

                new("Frame", {
                    Size                   = UDim2.new(1, 0, 1, 0),
                    BackgroundColor3       = Color3.new(1, 1, 1),
                    BorderSizePixel        = 0,
                    Parent                 = field,
                }, {
                    corner(3),
                    new("UIGradient", {
                        Transparency = NumberSequence.new({
                            NumberSequenceKeypoint.new(0, 0),
                            NumberSequenceKeypoint.new(1, 1),
                        }),
                    }),
                })

                new("Frame", {
                    Size             = UDim2.new(1, 0, 1, 0),
                    BackgroundColor3 = Color3.new(0, 0, 0),
                    BorderSizePixel  = 0,
                    Parent           = field,
                }, {
                    corner(3),
                    new("UIGradient", {
                        Rotation     = 90,
                        Transparency = NumberSequence.new({
                            NumberSequenceKeypoint.new(0, 1),
                            NumberSequenceKeypoint.new(1, 0),
                        }),
                    }),
                })

                local cursor = new("Frame", {
                    AnchorPoint            = Vector2.new(0.5, 0.5),
                    Size                   = UDim2.new(0, 9, 0, 9),
                    BackgroundTransparency = 1,
                    ZIndex                 = 5,
                    Parent                 = field,
                }, {
                    corner(5),
                    new("UIStroke", { Color = Color3.new(1, 1, 1), Thickness = 1.5 }),
                })

                local hueBar = new("Frame", {
                    Position        = UDim2.new(0, 10, 0, 86),
                    Size            = UDim2.new(1, -20, 0, 12),
                    BorderSizePixel = 0,
                    Parent          = body2,
                }, {
                    corner(3),
                    new("UIGradient", {
                        Color = ColorSequence.new({
                            ColorSequenceKeypoint.new(0.00, Color3.fromRGB(255,   0,   0)),
                            ColorSequenceKeypoint.new(0.17, Color3.fromRGB(255, 255,   0)),
                            ColorSequenceKeypoint.new(0.33, Color3.fromRGB(  0, 255,   0)),
                            ColorSequenceKeypoint.new(0.50, Color3.fromRGB(  0, 255, 255)),
                            ColorSequenceKeypoint.new(0.67, Color3.fromRGB(  0,   0, 255)),
                            ColorSequenceKeypoint.new(0.83, Color3.fromRGB(255,   0, 255)),
                            ColorSequenceKeypoint.new(1.00, Color3.fromRGB(255,   0,   0)),
                        }),
                    }),
                })

                local hueCursor = new("Frame", {
                    AnchorPoint      = Vector2.new(0.5, 0.5),
                    Position         = UDim2.new(0, 0, 0.5, 0),
                    Size             = UDim2.new(0, 4, 1, 6),
                    BackgroundColor3 = Color3.new(1, 1, 1),
                    BorderSizePixel  = 0,
                    ZIndex           = 5,
                    Parent           = hueBar,
                }, { corner(2) })

                local api = {}

                local function push(silent)
                    col = Color3.fromHSV(h, s, v)
                    swatch.BackgroundColor3 = col
                    field.BackgroundColor3  = Color3.fromHSV(h, 1, 1)
                    cursor.Position         = UDim2.new(s, 0, 1 - v, 0)
                    hueCursor.Position      = UDim2.new(h, 0, 0.5, 0)
                    if o.Flag then Obsidian.Flags[o.Flag] = col end
                    if not silent and o.Callback then task.spawn(o.Callback, col) end
                end

                function api:Set(c, silent)
                    h, s, v = Color3.toHSV(c)
                    push(silent)
                end
                function api:Get() return col end

                local fieldDrag, hueDrag = false, false
                local function fieldFrom(p)
                    local sz = field.AbsoluteSize
                    if sz.X <= 0 then return end
                    s = math.clamp((p.X - field.AbsolutePosition.X) / sz.X, 0, 1)
                    v = 1 - math.clamp((p.Y - field.AbsolutePosition.Y) / sz.Y, 0, 1)
                    push()
                end
                local function hueFrom(p)
                    local sz = hueBar.AbsoluteSize
                    if sz.X <= 0 then return end
                    h = math.clamp((p.X - hueBar.AbsolutePosition.X) / sz.X, 0, 1)
                    push()
                end

                field.InputBegan:Connect(function(i)
                    if i.UserInputType == Enum.UserInputType.MouseButton1
                    or i.UserInputType == Enum.UserInputType.Touch then
                        fieldDrag = true; fieldFrom(i.Position)
                    end
                end)
                hueBar.InputBegan:Connect(function(i)
                    if i.UserInputType == Enum.UserInputType.MouseButton1
                    or i.UserInputType == Enum.UserInputType.Touch then
                        hueDrag = true; hueFrom(i.Position)
                    end
                end)
                UserInputService.InputEnded:Connect(function(i)
                    if i.UserInputType == Enum.UserInputType.MouseButton1
                    or i.UserInputType == Enum.UserInputType.Touch then
                        fieldDrag, hueDrag = false, false
                    end
                end)
                UserInputService.InputChanged:Connect(function(i)
                    if i.UserInputType ~= Enum.UserInputType.MouseMovement
                    and i.UserInputType ~= Enum.UserInputType.Touch then return end
                    if fieldDrag then fieldFrom(i.Position) end
                    if hueDrag   then hueFrom(i.Position)   end
                end)

                swatch.MouseButton1Click:Connect(function()
                    open = not open
                    tween(r, TW_FAST, { Size = UDim2.new(1, 0, 0, open and 140 or 24) })
                end)

                push(true)
                return api
            end

            return Section
        end

        table.insert(Window.Tabs, Tab)
        if #Window.Tabs == 1 then Tab:Select() end
        return Tab
    end

    -- ================================================================
    --  WELCOME SCREEN – smaller and proportional
    -- ================================================================
    local Welcome = new("Frame", {
        AnchorPoint      = Vector2.new(0.5, 0.5),
        Position         = UDim2.new(0.5, 0, 0.5, 0),
        Size             = UDim2.new(0, 0, 0, 0),
        BorderSizePixel  = 0,
        ClipsDescendants = true,
        Parent           = Screen,
    }, { corner(6), stroke("BorderLight") })
    reg(Welcome, "BackgroundColor3", "Background")

    local wTitle = new("TextLabel", {
        Position               = UDim2.new(0, 0, 0, 34),
        Size                   = UDim2.new(1, 0, 0, 22),
        BackgroundTransparency = 1,
        Font                   = F.Bold,
        Text                   = "Welcome " .. (LocalPlayer and LocalPlayer.DisplayName or "guest"),
        TextSize               = 18,
        TextTransparency       = 1,
        Parent                 = Welcome,
    })
    reg(wTitle, "TextColor3", "Text")

    local wSub = new("TextLabel", {
        Position               = UDim2.new(0, 0, 0, 60),
        Size                   = UDim2.new(1, 0, 0, 16),
        BackgroundTransparency = 1,
        Font                   = F.Mono,
        Text                   = "powered by 360",
        TextSize               = 11,
        TextTransparency       = 1,
        Parent                 = Welcome,
    })
    reg(wSub, "TextColor3", "TextFaint")

    local wLine = new("Frame", {
        AnchorPoint     = Vector2.new(0.5, 0),
        Position        = UDim2.new(0.5, 0, 0, 86),
        Size            = UDim2.new(0, 0, 0, 1),
        BorderSizePixel = 0,
        Parent          = Welcome,
    })
    reg(wLine, "BackgroundColor3", "Border")

    local wStatus = new("TextLabel", {
        Position               = UDim2.new(0, 0, 0, 102),
        Size                   = UDim2.new(1, 0, 0, 14),
        BackgroundTransparency = 1,
        Font                   = F.Mono,
        Text                   = "",
        TextSize               = 11,
        TextTransparency       = 1,
        Parent                 = Welcome,
    })
    reg(wStatus, "TextColor3", "TextFaint")

    local wBarBg = new("Frame", {
        AnchorPoint            = Vector2.new(0.5, 0),
        Position               = UDim2.new(0.5, 0, 0, 120),
        Size                   = UDim2.new(0, 200, 0, 3),
        BorderSizePixel        = 0,
        BackgroundTransparency = 1,
        Parent                 = Welcome,
    }, { corner(3) })
    reg(wBarBg, "BackgroundColor3", "Element")

    local wBar = new("Frame", {
        Size                   = UDim2.new(0, 0, 1, 0),
        BorderSizePixel        = 0,
        BackgroundTransparency = 1,
        Parent                 = wBarBg,
    }, { corner(3) })
    reg(wBar, "BackgroundColor3", "Accent")

    local wBtn = new("TextButton", {
        AnchorPoint     = Vector2.new(0.5, 0),
        Position        = UDim2.new(0.5, 0, 0, 144),
        Size            = UDim2.new(0, 110, 0, 28),
        AutoButtonColor = false,
        BorderSizePixel = 0,
        Font            = F.Head,
        Text            = "L O A D",
        TextSize        = 12,
        BackgroundTransparency = 1,
        TextTransparency       = 1,
        Parent          = Welcome,
    }, { corner(4), stroke("BorderLight") })
    reg(wBtn, "BackgroundColor3", "Element")
    reg(wBtn, "TextColor3", "Text")

    wBtn.MouseEnter:Connect(function()
        tween(wBtn, TW_FAST, { BackgroundColor3 = Theme.ElementHover })
    end)
    wBtn.MouseLeave:Connect(function()
        tween(wBtn, TW_FAST, { BackgroundColor3 = Theme.Element })
    end)

    task.spawn(function()
        tween(Welcome, TW_SLOW, { Size = UDim2.new(0, 320, 0, 180) })
        task.wait(0.30)
        tween(wTitle,  TW_MED, { TextTransparency = 0 })
        task.wait(0.08)
        tween(wSub,    TW_MED, { TextTransparency = 0 })
        tween(wLine,   TW_MED, { Size = UDim2.new(0, 240, 0, 1) })
        task.wait(0.08)
        tween(wBtn,    TW_MED, { TextTransparency = 0, BackgroundTransparency = 0 })
    end)

    local loaded = false
    wBtn.MouseButton1Click:Connect(function()
        if loaded then return end
        loaded = true

        tween(wBtn, TW_FAST, { TextTransparency = 1, BackgroundTransparency = 1 })
        wBtn.Active = false
        tween(wBarBg,  TW_FAST, { BackgroundTransparency = 0 })
        tween(wBar,    TW_FAST, { BackgroundTransparency = 0 })
        tween(wStatus, TW_FAST, { TextTransparency = 0 })

        local steps = {
            { "initialising interface", 0.25 },
            { "building components",    0.55 },
            { "applying theme",         0.80 },
            { "ready",                  1.00 },
        }

        task.spawn(function()
            for _, step in ipairs(steps) do
                wStatus.Text = step[1]
                tween(wBar, TweenInfo.new(0.30, Enum.EasingStyle.Quad), {
                    Size = UDim2.new(step[2], 0, 1, 0)
                })
                task.wait(0.34)
            end
            task.wait(0.20)

            tween(Welcome, TW_MED, { Size = UDim2.new(0, 320, 0, 0) })
            task.wait(0.24)
            Welcome:Destroy()

            Main.Visible = true
            fullSize = size
            tween(Main, TW_SLOW, { Size = size })

            if cfg.OnLoad then task.spawn(cfg.OnLoad) end
        end)
    end)

    return Window
end
-- ======================= END OF OBSIDIAN ===============================

-- ========================================================================
--  APPLICATION:  360 LEAKS  —  Auto‑Redeemer & Riddle Solver
-- ========================================================================

-- Safety fallback for table.clear
if not table.clear then
    function table.clear(t)
        for k in pairs(t) do t[k] = nil end
    end
end

-- Global settings
_G.ScriptEnabled = true
_G.AutoWriteEnabled = false
_G.AutoSubmitEnabled = false
_G.RiddleSolverEnabled = false
_G.SubmitAfterCount = 1
_G.SubmitAttempts = 3

local FAST_WAIT = 0.000000000000000000000000000000000000000000000000000000000000000001

local enteredCodes = {}
local activeConnections = {}
local latestCode = nil
local lastWrittenCode = nil
local lastAttemptedCode = nil
local lastSubmittedBatch = {}
local autoWriteConn = nil
local pendingQueue = {}
local pendingSeen = {}
local writeBusy = false
local collectedCodes = {}
local collectedSeen = {}
local CODE_SEPARATOR = ""

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer

-- ===== COMPLETE SAB DATABASE =====
local SAB_DB = {
    ["how old am i"] = "24",
    ["how old is sammy"] = "24",
    ["my age"] = "24",
    ["sammy age"] = "24",
    ["age"] = "24",
    ["where am i from"] = "BRAZIL",
    ["where is sammy from"] = "BRAZIL",
    ["my country"] = "BRAZIL",
    ["sammy country"] = "BRAZIL",
    ["favorite color"] = "BLUE",
    ["fav color"] = "BLUE",
    ["my color"] = "BLUE",
    ["sammy color"] = "BLUE",
    ["color"] = "BLUE",
    ["favorite football player"] = "RONALDO",
    ["fav football player"] = "RONALDO",
    ["my favorite football player"] = "RONALDO",
    ["ronaldo"] = "RONALDO",
    ["game created on"] = "FRIDAY",
    ["created on"] = "FRIDAY",
    ["what day was the game created"] = "FRIDAY",
    ["what day was sab created"] = "FRIDAY",
    ["game creation day"] = "FRIDAY",
    ["seventh mutation"] = "CURSED",
    ["7th mutation"] = "CURSED",
    ["eighth mutation"] = "DIVINE",
    ["8th mutation"] = "DIVINE",
    ["ninth mutation"] = "CYBER",
    ["9th mutation"] = "CYBER",
    ["tenth mutation"] = "PHANTOM",
    ["10th mutation"] = "PHANTOM",
    ["first machine"] = "RAINBOW MACHINE",
    ["1st machine"] = "RAINBOW MACHINE",
    ["second machine"] = "BUBBLEGUM MACHINE",
    ["2nd machine"] = "BUBBLEGUM MACHINE",
    ["third machine"] = "FUSE MACHINE",
    ["3rd machine"] = "FUSE MACHINE",
    ["fourth machine"] = "CRAFT MACHINE",
    ["4th machine"] = "CRAFT MACHINE",
    ["fifth machine"] = "WITCH FUSE",
    ["5th machine"] = "WITCH FUSE",
    ["sixth machine"] = "BRAINROT DEALER",
    ["6th machine"] = "BRAINROT DEALER",
    ["seventh machine"] = "BRAINROT TRADER",
    ["7th machine"] = "BRAINROT TRADER",
    ["eighth machine"] = "SANTA'S FUSE",
    ["8th machine"] = "SANTA'S FUSE",
    ["ninth machine"] = "SANTA'S SHOP",
    ["9th machine"] = "SANTA'S SHOP",
    ["tenth machine"] = "NEW YEAR'S MACHINE",
    ["10th machine"] = "NEW YEAR'S MACHINE",
    ["eleventh machine"] = "DUELS MACHINE",
    ["11th machine"] = "DUELS MACHINE",
    ["twelfth machine"] = "CUPID'S MACHINE",
    ["12th machine"] = "CUPID'S MACHINE",
    ["thirteenth machine"] = "TRADE MACHINE",
    ["13th machine"] = "TRADE MACHINE",
    ["fourteenth machine"] = "DIVINE FUSE",
    ["14th machine"] = "DIVINE FUSE",
    ["fifteenth machine"] = "EGG INCUBATOR",
    ["15th machine"] = "EGG INCUBATOR",
    ["sixteenth machine"] = "CYBER CRAFT MACHINE",
    ["16th machine"] = "CYBER CRAFT MACHINE",
    ["seventeenth machine"] = "SUMMER FUSE",
    ["17th machine"] = "SUMMER FUSE",
    ["eighteenth machine"] = "LOS TRADERS",
    ["18th machine"] = "LOS TRADERS",
    ["og brainrot cannot be obtained"] = "HEADLESS HORSEMAN",
    ["headless horseman"] = "HEADLESS HORSEMAN",
    ["first og added"] = "STRAWBERRYELEPHANT",
    ["1st og"] = "STRAWBERRYELEPHANT",
    ["second og added"] = "MEOWL",
    ["2nd og"] = "MEOWL",
    ["third og added"] = "SKIBIDITOILET",
    ["3rd og"] = "SKIBIDITOILET",
    ["fifth og added"] = "JOHNPORK",
    ["5th og"] = "JOHNPORK",
    ["highest rarity"] = "OG",
    ["fire represents"] = "DRAGON",
    ["fire stands for"] = "DRAGON",
    ["won the world cup"] = "ARGENTINA",
    ["world cup winner"] = "ARGENTINA",
    ["world cup"] = "ARGENTINA",
    ["worst game owner"] = "SECRETLOKII",
    ["most boring game owner"] = "SECRETLOKII",
    ["most boring game on roblox"] = "KEYBOARDESCAPE",
    ["spawned during admin abuse war"] = "RACOONINI JANDELINI",
    ["won the admin abuse war"] = "GROWAGARDEN",
    ["worst secret"] = "KARKERKARKURKUR",
    ["maximum server size"] = "EIGHT",
    ["max server size"] = "EIGHT",
    ["brother of hydra bunny"] = "CERBERUS",
    ["hydra bunny brother"] = "CERBERUS",
    ["release month"] = "MAY",
    ["release year"] = "2025",
    ["release date"] = "MAY162025",
    ["code 1"] = "SAB2024",
    ["code 2"] = "SAMMYGIFT",
    ["code 3"] = "BRAINROT",
    ["code 4"] = "SPYDER",
    ["code 5"] = "RELEASE",
    ["code 6"] = "MAY25",
    ["code 7"] = "BLUEBOY",
    ["code 8"] = "KEYBOARD",
    ["code 9"] = "ESCAPE",
    ["code 10"] = "RAINBOW",
    ["total codes"] = "247",
    ["active codes"] = "89",
    ["expired codes"] = "158",
    ["rare codes"] = "12",
    ["legendary codes"] = "3",
    ["mythic codes"] = "1",
}

-- ========== FETCH SPYDERSAMMY USERID ==========
local targetUserId = nil
task.spawn(function()
    local success, result = pcall(function()
        return Players:GetUserIdFromNameAsync("SpyderSammy")
    end)
    if success then targetUserId = result end
end)

-- ========== UI SCANNER ==========
local function isAvatarImage(imageLabel)
    if not imageLabel.Visible or imageLabel.Image == "" then return false end
    if targetUserId and string.find(string.lower(imageLabel.Image), tostring(targetUserId)) then
        return true
    end
    return false
end

local function verifySourceIsSammy(textObj)
    if Obsidian and Obsidian.Screen and textObj:IsDescendantOf(Obsidian.Screen) then return false end
    local container = textObj.Parent
    while container and not container:IsA("ScreenGui") and container.Name ~= "PlayerGui" do
        for _, item in ipairs(container:GetChildren()) do
            if item:IsA("TextLabel") and string.find(string.lower(item.Text), "spydersammy") then
                return true
            end
        end
        for _, item in ipairs(container:GetDescendants()) do
            if item:IsA("ImageLabel") and isAvatarImage(item) then
                return true
            end
        end
        if container.Parent and (container.Parent:IsA("Frame") or container.Parent:IsA("ImageLabel") or container.Parent:IsA("CanvasGroup")) then
            container = container.Parent
        else
            break
        end
    end
    return false
end

-- ========== RIDDLE SOLVER ==========
local function answerQuestion(text)
    if not _G.RiddleSolverEnabled then return nil end
    if not text or text == "" then return nil end
    local l = text:lower()
    local clean = l:gsub("what%s+is", ""):gsub("what%s+are", ""):gsub("what%s+was", ""):gsub("what%s+were", "")
    clean = clean:gsub("who%s+is", ""):gsub("who%s+was", ""):gsub("when%s+is", ""):gsub("when%s+was", "")
    clean = clean:gsub("where%s+is", ""):gsub("where%s+are", ""):gsub("how%s+old", ""):gsub("how%s+tall", "")
    clean = clean:gsub("how%s+many", ""):gsub("how%s+much", ""):gsub("do%s+you%s+know", ""):gsub("can%s+you%s+tell", "")
    clean = clean:gsub("tell%s+me", ""):gsub("i%s+need", ""):gsub("give%s+me", ""):gsub("what's", ""):gsub("whats", "")
    clean = clean:gsub("my%s+", ""):gsub("am%s+i", ""):gsub("do%s+i", ""):gsub("did%s+i", ""):gsub("have%s+i", "")
    clean = clean:gsub("the%s+", ""):gsub("a%s+", ""):gsub("an%s+", ""):gsub("of%s+", ""):gsub("for%s+", "")
    clean = clean:gsub("[%?%.%,!]", ""):gsub("^%s+", ""):gsub("%s+$", "")
    if clean == "" then clean = l:gsub("[%?%.%,!]", "") end

    if l:find("fortnite") or l:find("fn ") or l:find("battle royale") or l:find("epic games") then
        return "SAB ONLY"
    end

    if SAB_DB[clean] then return SAB_DB[clean] end
    for key, value in pairs(SAB_DB) do
        if clean:find(key) or key:find(clean) then return value end
        if #key > 3 and #clean > 2 then
            for word in key:gmatch("%S+") do
                if #word > 2 and (clean:find(word) or word:find(clean)) then return value end
            end
        end
    end

    -- fallback heuristics
    if l:find("game created") or l:find("created on") or l:find("made on") then
        if l:find("day") or l:find("when") then return "FRIDAY" end
    end
    if l:find("football") or l:find("soccer") then
        if l:find("favorite") or l:find("fav") or l:find("player") then return "RONALDO" end
    end
    if l:find("ronaldo") then return "RONALDO" end
    if l:find("worst game") or l:find("boring game") then
        if l:find("owner") then return "SECRETLOKII" else return "KEYBOARDESCAPE" end
    end
    if l:find("world cup") then return "ARGENTINA" end
    if l:find("mutation") then
        if l:find("7") or l:find("seven") then return "CURSED" end
        if l:find("8") or l:find("eight") then return "DIVINE" end
        if l:find("9") or l:find("nine") then return "CYBER" end
        if l:find("10") or l:find("ten") then return "PHANTOM" end
    end
    if l:find("machine") then
        if l:find("1") or l:find("first") then return "RAINBOW MACHINE" end
        if l:find("2") or l:find("second") then return "BUBBLEGUM MACHINE" end
        if l:find("3") or l:find("third") then return "FUSE MACHINE" end
        if l:find("4") or l:find("fourth") then return "CRAFT MACHINE" end
        if l:find("5") or l:find("fifth") then return "WITCH FUSE" end
        if l:find("6") or l:find("sixth") then return "BRAINROT DEALER" end
        if l:find("7") or l:find("seventh") then return "BRAINROT TRADER" end
        if l:find("8") or l:find("eighth") then return "SANTA'S FUSE" end
        if l:find("9") or l:find("ninth") then return "SANTA'S SHOP" end
        if l:find("10") or l:find("tenth") then return "NEW YEAR'S MACHINE" end
        if l:find("11") or l:find("eleventh") then return "DUELS MACHINE" end
        if l:find("12") or l:find("twelfth") then return "CUPID'S MACHINE" end
        if l:find("13") or l:find("thirteenth") then return "TRADE MACHINE" end
        if l:find("14") or l:find("fourteenth") then return "DIVINE FUSE" end
        if l:find("15") or l:find("fifteenth") then return "EGG INCUBATOR" end
        if l:find("16") or l:find("sixteenth") then return "CYBER CRAFT MACHINE" end
        if l:find("17") or l:find("seventeenth") then return "SUMMER FUSE" end
        if l:find("18") or l:find("eighteenth") then return "LOS TRADERS" end
    end
    if l:find("og") or l:find("cannot be obtained") then
        if l:find("headless") then return "HEADLESS HORSEMAN" end
        if l:find("first") or l:find("1st") then return "STRAWBERRYELEPHANT" end
        if l:find("second") or l:find("2nd") then return "MEOWL" end
        if l:find("third") or l:find("3rd") then return "SKIBIDITOILET" end
        if l:find("fifth") or l:find("5th") then return "JOHNPORK" end
    end
    if l:find("highest rarity") then return "OG" end
    if l:find("fire") and (l:find("represent") or l:find("stand")) then return "DRAGON" end
    if l:find("admin abuse") then
        if l:find("spawn") then return "RACOONINI JANDELINI" end
        if l:find("won") then return "GROWAGARDEN" end
    end
    if l:find("worst secret") or l:find("bad secret") then return "KARKERKARKURKUR" end
    if l:find("server") and (l:find("max") or l:find("size")) then return "EIGHT" end
    if l:find("hydra bunny") and (l:find("brother") or l:find("sibling")) then return "CERBERUS" end
    if l:find("old") or l:find("age") then
        if l:find("sammy") or l:find("am i") then return "24" end
    end
    if l:find("from") or l:find("country") then
        if l:find("sammy") or l:find("am i") then return "BRAZIL" end
    end
    return nil
end

-- ========== UI HELPERS ==========
local function isGuiVisible(obj)
    if not obj or not obj.Visible then return false end
    local current = obj.Parent
    while current do
        if current:IsA("GuiObject") and not current.Visible then return false end
        if current:IsA("ScreenGui") and not current.Enabled then return false end
        current = current.Parent
    end
    return true
end

local function looksLikeCode(token)
    if not token then return false end
    if #token < 1 or #token > 50 then return false end
    return token:match("^%w+$") ~= nil
end

local function isLoneCode(text)
    if not text then return false end
    text = text:match("^%s*(.-)%s*$")
    if text == "" or text:find("%s") then return false end
    if #text < 1 or #text > 50 then return false end
    return text:match("^%w+$") ~= nil
end

local function extractCodesFromText(text)
    local found = {}
    if not text then return found end
    local trimmed = text:match("^%s*(.-)%s*$")
    trimmed = trimmed:gsub("<[^>]->", "")
    if isLoneCode(trimmed) then
        table.insert(found, trimmed)
        return found
    end
    for token in text:gmatch("%w+") do
        if looksLikeCode(token) then
            table.insert(found, token)
        end
    end
    return found
end

local function copyCodeToClipboard(code)
    local formatted = string.upper(code)
    if setclipboard then pcall(function() setclipboard(formatted) end)
    elseif toclipboard then pcall(function() toclipboard(formatted) end)
    elseif set_clipboard then pcall(function() set_clipboard(formatted) end)
    elseif Clipboard and Clipboard.set then pcall(function() Clipboard.set(formatted) end) end
end

local function formatCode(code) return string.upper(code) end

local _cachedBox = nil
local function _isCodeBox(obj)
    if not obj:IsA("TextBox") then return false end
    if Obsidian and Obsidian.Screen and obj:IsDescendantOf(Obsidian.Screen) then return false end
    local hint = ((obj.PlaceholderText or "") .. " " .. obj.Name):lower()
    return hint:find("code") or hint:find("redeem") or hint:find("here")
end

local function findCodeTextBox()
    if _cachedBox and _cachedBox.Parent and isGuiVisible(_cachedBox) then
        return _cachedBox
    end
    _cachedBox = nil
    local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
    if not playerGui then return nil end
    for _, obj in ipairs(playerGui:GetDescendants()) do
        if _isCodeBox(obj) and isGuiVisible(obj) then
            _cachedBox = obj
            return obj
        end
    end
    return nil
end

local function fireSignal(sig)
    if not sig then return end
    pcall(function()
        if getconnections then
            for _, c in ipairs(getconnections(sig)) do
                if c.Fire then c:Fire() end
            end
        end
    end)
    if firesignal then pcall(function() firesignal(sig) end) end
end

local function isSubmitButton(obj)
    if not (obj:IsA("TextButton") or obj:IsA("ImageButton")) then return false end
    if Obsidian and Obsidian.Screen and obj:IsDescendantOf(Obsidian.Screen) then return false end
    if not isGuiVisible(obj) then return false end
    local hint = (((obj:IsA("TextButton") and obj.Text) or "") .. " " .. obj.Name):lower()
    return hint:find("redeem") ~= nil or hint:find("submit") ~= nil
end

local function fireSubmitButton(nearObj)
    local target = nil
    local container = nearObj and nearObj.Parent or nil
    local levels = 0
    while container and not target and levels < 5 do
        for _, obj in ipairs(container:GetDescendants()) do
            if isSubmitButton(obj) then
                target = obj
                break
            end
        end
        container = container.Parent
        levels = levels + 1
    end
    if not target then return false end
    fireSignal(target.MouseButton1Click)
    fireSignal(target.Activated)
    return true
end

local _rfRemote = nil
local function getRedemptionRF()
    if _rfRemote and _rfRemote.Parent then return _rfRemote end
    _rfRemote = nil
    local rfFolder = ReplicatedStorage:FindFirstChild("RF")
    if rfFolder then
        local rf = rfFolder:FindFirstChild("RequestRedemption")
        if rf and rf:IsA("RemoteFunction") then
            _rfRemote = rf
            return _rfRemote
        end
    end
    if rfFolder then
        for _, v in ipairs(rfFolder:GetChildren()) do
            if v.Name == "RequestRedemption" and v:IsA("RemoteFunction") then
                _rfRemote = v
                return _rfRemote
            end
        end
    end
    if getinstances then
        for _, v in ipairs(getinstances()) do
            if v.Name == "RequestRedemption" and v:IsA("RemoteFunction") then
                _rfRemote = v
                return _rfRemote
            end
        end
    end
    return _rfRemote
end

local function redeemViaRF(code)
    local rf = getRedemptionRF()
    if not rf then return false end
    local formatted = formatCode(code)
    local ok, result = pcall(function() return rf:InvokeServer(formatted) end)
    if ok then return true else return false end
end

-- ========== WRITE & SUBMIT ==========
local function writeAndSubmit(code)
    lastAttemptedCode = code
    if redeemViaRF(code) then return true end

    local textBox = findCodeTextBox()
    if not textBox then return false end
    local formatted = formatCode(code)
    pcall(function() textBox.ClearTextOnFocus = false end)

    if not collectedSeen[formatted] then
        collectedSeen[formatted] = true
        table.insert(collectedCodes, formatted)
    end

    local fullText = table.concat(collectedCodes, CODE_SEPARATOR)
    local target = math.max(1, tonumber(_G.SubmitAfterCount) or 1)
    local ready = #collectedCodes >= target

    if ready and _G.AutoSubmitEnabled then
        lastSubmittedBatch = {}
        for _, c in ipairs(collectedCodes) do table.insert(lastSubmittedBatch, c) end
        local box = findCodeTextBox()
        if box then
            for i = 1, _G.SubmitAttempts do
                pcall(function()
                    box:CaptureFocus()
                    box.Text = fullText
                    box.CursorPosition = #fullText + 1
                end)
                pcall(function() box:ReleaseFocus(true) end)
                task.wait(FAST_WAIT)
                fireSubmitButton(box)
            end
        end
        table.clear(collectedCodes)
        table.clear(collectedSeen)
    else
        task.wait(FAST_WAIT)
        local ok = pcall(function()
            textBox:CaptureFocus()
            textBox.Text = fullText
            textBox.CursorPosition = #fullText + 1
        end)
        if not ok then pcall(function() textBox.Text = fullText end) end
        if ready then
            table.clear(collectedCodes)
            table.clear(collectedSeen)
        end
    end
    return true
end

local function triggerWrite()
    if writeBusy or not _G.AutoWriteEnabled or #pendingQueue == 0 then return end
    local focused = UserInputService:GetFocusedTextBox()
    if focused and Obsidian and Obsidian.Screen and focused:IsDescendantOf(Obsidian.Screen) then return end
    local box = findCodeTextBox()
    if not (box and isGuiVisible(box)) then return end
    writeBusy = true
    task.spawn(function()
        local ok, err = pcall(function()
            while _G.AutoWriteEnabled and #pendingQueue > 0 do
                local b = findCodeTextBox()
                if not (b and isGuiVisible(b)) then break end
                local code = table.remove(pendingQueue, 1)
                pendingSeen[code] = nil
                writeAndSubmit(code)
                task.wait(FAST_WAIT)
            end
        end)
        writeBusy = false
        if not ok then warn("[360] triggerWrite error: " .. tostring(err)) end
    end)
end

local function startAutoWriteLoop()
    if autoWriteConn then return end
    local playerGui = LocalPlayer:FindFirstChild("PlayerGui") or LocalPlayer:WaitForChild("PlayerGui", 10)
    local boxConn = playerGui and playerGui.DescendantAdded:Connect(function(obj)
        if _isCodeBox(obj) and isGuiVisible(obj) then
            _cachedBox = obj
            triggerWrite()
        end
    end)
    local boxRemConn = playerGui and playerGui.DescendantRemoving:Connect(function(obj)
        if obj == _cachedBox then _cachedBox = nil end
    end)
    autoWriteConn = { Disconnect = function()
        if boxConn then boxConn:Disconnect() end
        if boxRemConn then boxRemConn:Disconnect() end
    end }
    table.insert(activeConnections, autoWriteConn)
end

local function riddleWriteAndSubmit(code)
    local textBox = findCodeTextBox()
    if not textBox then return false end
    local formatted = formatCode(code)
    pcall(function() textBox.ClearTextOnFocus = false end)
    pcall(function()
        textBox:CaptureFocus()
        textBox.Text = formatted
        textBox.CursorPosition = #formatted + 1
    end)
    pcall(function() textBox:ReleaseFocus(true) end)
    task.wait(FAST_WAIT)
    fireSubmitButton(textBox)
    copyCodeToClipboard(formatted)
    return true
end

function processText(text)
    if _G.RiddleSolverEnabled then
        local answer = answerQuestion(text)
        if answer then
            riddleWriteAndSubmit(answer)
            return
        end
    end
    if not _G.AutoWriteEnabled then return end
    table.clear(pendingQueue)
    table.clear(pendingSeen)
    if not text or text == "" then return end
    local codes = extractCodesFromText(text)
    if #codes == 0 then return end
    for _, code in ipairs(codes) do
        copyCodeToClipboard(code)
        latestCode = code
        table.insert(pendingQueue, code)
    end
    triggerWrite()
end

local function handleIncomingText(textObj)
    if not _G.ScriptEnabled or writeBusy then return end
    local text = textObj.Text
    if text == "" then return end
    if verifySourceIsSammy(textObj) then
        task.spawn(function() processText(text) end)
    end
end

local function hookUiTextObject(obj)
    if obj:IsA("TextLabel") then
        handleIncomingText(obj)
        obj:GetPropertyChangedSignal("Text"):Connect(function()
            handleIncomingText(obj)
        end)
    end
end

local function startPlayerGuiScanner()
    local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
    if not playerGui then return end
    for _, desc in ipairs(playerGui:GetDescendants()) do
        hookUiTextObject(desc)
    end
    local conn = playerGui.DescendantAdded:Connect(hookUiTextObject)
    table.insert(activeConnections, conn)
end

local function cleanupMonitoring()
    for _, conn in pairs(activeConnections) do
        if typeof(conn) == "RBXScriptConnection" then conn:Disconnect() end
    end
    table.clear(activeConnections)
    table.clear(enteredCodes)
    table.clear(collectedCodes)
    table.clear(collectedSeen)
    table.clear(pendingQueue)
    table.clear(pendingSeen)
    table.clear(lastSubmittedBatch)
    writeBusy = false
    autoWriteConn = nil
    latestCode = nil
    lastWrittenCode = nil
    lastAttemptedCode = nil
end

local claimedCount = 0

function redeemAllCodes()
    local count = 0
    for key, value in pairs(SAB_DB) do
        if key:match("^code %d+$") then
            local code = formatCode(value)
            if redeemViaRF(code) then
                count = count + 1
            else
                if writeAndSubmit(code) then
                    count = count + 1
                end
            end
            task.wait(0.1)
        end
    end
    claimedCount = claimedCount + count
    return count
end

-- ========================================================================
--  BUILD OBSIDIAN WINDOW FOR 360 LEAKS
-- ========================================================================

local Window = Obsidian:CreateWindow({
    Title     = "360 leaks",
    Tag       = "",
    Size      = UDim2.new(0, 680, 0, 460),
    ToggleKey = Enum.KeyCode.RightShift,
    OnLoad    = function()
        Obsidian:Notify("360 leaks ready  •  RightShift to toggle", 4)
        task.spawn(function()
            startPlayerGuiScanner()
            startAutoWriteLoop()
            while true do
                task.wait(2)
                if MainTab and MainTab.statusLabel then
                    local status = "Collected: " .. #collectedCodes .. "  |  Claimed: " .. claimedCount
                    MainTab.statusLabel:Set(status)
                end
                -- Update status indicator in title bar
                if Window.statusDot and Window.statusLabel then
                    if _G.ScriptEnabled then
                        Window.statusDot.BackgroundColor3 = Theme.Accent
                        Window.statusDot.UIStroke.Color = Theme.Accent
                        Window.statusLabel.Text = "Active"
                        Window.statusLabel.TextColor3 = Theme.Accent
                    else
                        Window.statusDot.BackgroundColor3 = Theme.Risk
                        Window.statusDot.UIStroke.Color = Theme.Risk
                        Window.statusLabel.Text = "Inactive"
                        Window.statusLabel.TextColor3 = Theme.Risk
                    end
                end
            end
        end)
    end,
})

-- Only Main and Info tabs
local MainTab = Window:AddTab("Main")
local InfoTab = Window:AddTab("Info")

-- ========== MAIN TAB ==========
local sect1 = MainTab:AddSection("Controls", "left")

local awToggle = sect1:AddToggle({
    Text = "Auto Write",
    Default = _G.AutoWriteEnabled,
    Callback = function(v)
        _G.AutoWriteEnabled = v
        if not v then
            table.clear(pendingQueue)
            table.clear(pendingSeen)
        end
    end
})

local asToggle = sect1:AddToggle({
    Text = "Auto Submit",
    Default = _G.AutoSubmitEnabled,
    Callback = function(v)
        _G.AutoSubmitEnabled = v
        if not v then
            table.clear(collectedCodes)
            table.clear(collectedSeen)
        end
    end
})

local rsToggle = sect1:AddToggle({
    Text = "Riddle Solver",
    Default = _G.RiddleSolverEnabled,
    Callback = function(v) _G.RiddleSolverEnabled = v end
})

local countSlider = sect1:AddSlider({
    Text = "Submit After Count",
    Min = 1, Max = 10, Default = _G.SubmitAfterCount, Decimals = 0,
    Suffix = " code(s)",
    Callback = function(v) _G.SubmitAfterCount = v end
})

sect1:AddDivider()

local redeemBtn = sect1:AddButton({
    Text = "Redeem All Codes",
    Callback = function()
        local count = redeemAllCodes()
        Obsidian:Notify("Redeemed " .. count .. " new codes.", 3)
        local status = "Collected: " .. #collectedCodes .. "  |  Claimed: " .. claimedCount
        MainTab.statusLabel:Set(status)
    end
})

local statusLabel = sect1:AddLabel("Collected: 0  |  Claimed: 0")
MainTab.statusLabel = statusLabel

-- ========== INFO TAB ==========
local sect3 = InfoTab:AddSection("About", "left")
sect3:AddLabel("360 leaks")
sect3:AddLabel("Auto‑Redeemer & Riddle Solver")
sect3:AddDivider()
sect3:AddLabel("Toggle: RightShift")

-- Script toggle (like Auto Type)
local scriptToggle = sect3:AddToggle({
    Text = "Script",
    Default = _G.ScriptEnabled,
    Callback = function(v)
        _G.ScriptEnabled = v
        local status = "Collected: " .. #collectedCodes .. "  |  Claimed: " .. claimedCount
        MainTab.statusLabel:Set(status)
        Obsidian:Notify("Script " .. (_G.ScriptEnabled and "enabled" or "disabled"), 2)
    end
})

print("[360 leaks] Loaded successfully.")
]=]
local __auto_redeem_chunk, __auto_redeem_error = loadstring(__auto_redeem_source)
if not __auto_redeem_chunk then
    error(__auto_redeem_error)
end
return __auto_redeem_chunk()
