-- Wrapped from attached_assets/InstinctsRedeemer_1790516365089.txt
-- Local wrapper; requires a Roblox Lua executor that provides loadstring.
local __instincts_redeemer_source = [=[
--[[
    WAVE CODE REDEEMER — Steal a Brainrot code sniper
    ----------------------------------------
    LISTEN : stealthy passive listener on the notify remote (mapper-resolved via
             NotificationController.Start upvalues; own connection only, no hooks).
    REDEEM : game Codes box submit via getconnections (debounce killed), with the
             redeem RemoteFunction (fixed GUID) as fallback.
    Re-running the script destroys the previous GUI and cleans up its
    connections through the GUI lifecycle.
--]]
----------------------------------------------------------------------
-- Services
----------------------------------------------------------------------
local cloneref = cloneref or function(o) return o end
local Players           = cloneref(game:GetService("Players"))
local ReplicatedStorage = cloneref(game:GetService("ReplicatedStorage"))
local UserInputService  = cloneref(game:GetService("UserInputService"))
local TweenService      = cloneref(game:GetService("TweenService"))
local RunService        = cloneref(game:GetService("RunService"))
local SoundService      = cloneref(game:GetService("SoundService"))
local LP  = Players.LocalPlayer
local PG  = LP:WaitForChild("PlayerGui")
local Net = ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Net")
----------------------------------------------------------------------
-- Executor capabilities
----------------------------------------------------------------------
local getupvalues = (debug and debug.getupvalues) or getupvalues
local getconns    = getconnections or (debug and debug.getconnections)
local setupv      = (debug and debug.setupvalue) or setupvalue
----------------------------------------------------------------------
-- Config / State
----------------------------------------------------------------------
local REDEEM_GUID        = "7d14a912-1040-4867-b005-98838eb9acc4"
local DEFAULT_KEY        = Enum.KeyCode.F
local DEFAULT_CLEAR_KEY  = Enum.KeyCode.C
local DEFAULT_ANCHOR_KEY = Enum.KeyCode.G
local listening   = false
local autoCopyCode = false
local sidePanelVisible = false
local bindKey, rebinding       = DEFAULT_KEY, false
local clearKey, clearRebinding = DEFAULT_CLEAR_KEY, false
local anchorKey, anchorRebinding = DEFAULT_ANCHOR_KEY, false
local collectBuffer = {}
local NotifyRemote, RedeemRemote
local RedeemBox, RedeemConnections
----------------------------------------------------------------------
-- Module-level UI handles (assigned inside topBar do block)
----------------------------------------------------------------------
local snipeSwitch, snipeSlider, snipeOnBtn
local clearSwitch, clearSlider, clearOnBtn
local keyBtn, clearKeyBtn, collapseBtn, gearBtn
local listenLbl
local autoCopyPill, autoCopyKnob, autoCopyLabel, autoCopyBtn
local inlineAutoBuyOnBtn
local inlineAnchorOnBtn, anchorKeyBtn
local inlineRadiusOnBtn
local settingsPanel, inlineTestBox, inlineSendTest, inlineRandomTest
local sidePanel, sidePanelCodeLine
-- Log state (assigned inside topBar do block, used by log functions below)
local logScroll, logPlaceholder
local logOrder    = 0
local cumulativeWord = ""
local wordIndex   = 0
local wordCountLabel
local wordCodeLines = {}   -- code labels; updated in bulk each word
local activeWordRow, activeCodeLine, activeArrowLine, activePillBg
----------------------------------------------------------------------
-- Helpers
----------------------------------------------------------------------
local function stripRich(s)
    if type(s) ~= "string" then return tostring(s) end
    return (s:gsub("<[^>]->", ""))
end
local function trim(s) return (s or ""):gsub("^%s+", ""):gsub("%s+$", "") end
local function escapeRichText(s)
    s = tostring(s or "")
    s = s:gsub("&",  "&amp;")
    s = s:gsub("<",  "&lt;")
    s = s:gsub(">",  "&gt;")
    s = s:gsub('"', '&quot;')
    return s
end
local function applyCase(code) return code end
local function tokenize(text)
    local t = {}
    for w in text:gmatch("[%w_]+") do
        if w:lower() ~= "and" then t[#t + 1] = w end
    end
    return t
end
local BLACKLISTED_PHRASES = {
    "sammy has spawned", "sammy spawned", "sammy has activated",
    "invalid code",
    "please wait before trying to redeem another code",
    "font color", "fontcolour", "fontcolor", "font colour",
    "sammy has activated bubblegum machine",
    "sammy activated 2x luck",  "sammy activated 6x luck",
    "sammy activated 8x luck",  "sammy activated 10x luck",
    "sammy activated 12x luck", "sammy activated 15x luck",
    "sammy activated 20x luck", "sammy activated 25x luck",
    "sammy activated 30x luck", "sammy activated 35x luck",
    "sammy activated", "sammy:", "spydersammy:",
    "coins shop", "brainrot trader", "robux shop", "robuxshop",
    "spin wheel", "spinwheel", "trade plaza", "tradeplaza",
    "event has started", "eventhasstarted",
    "allowfriends", "setcreatorid", "to buy this", "tobuythis",
    "your base is already locked", "you locked your base for",
    "you got a free spin", "broke into your base",
    "someone is stealing", "trade has been completed", "tradehasbeencompleted",
}
local CAPTURE_PREFIX_PATTERNS = {
    "^%s*code%s+is%s*:%s*", "^%s*code%s+is%s+",
    "^%s*use%s+code%s*:%s*", "^%s*use%s+code%s+",
}
local function stripCapturePrefix(text)
    local lowered = tostring(text or ""):lower()
    for _, pattern in ipairs(CAPTURE_PREFIX_PATTERNS) do
        local first, last = lowered:find(pattern)
        if first then return trim(text:sub(last + 1)) end
    end
    return text
end
local function extractNamedWords(text)
    local namedWords = {}
    for word in tostring(text or ""):gmatch(
        "[Tt][Hh][Ee]%s+[Ww][Oo][Rr][dD][%p%s]*([%w_]+)"
    ) do namedWords[#namedWords + 1] = word end
    if #namedWords > 0 then return table.concat(namedWords, " ") end
    return text
end
local function isCodeCueText(text)
    local lowered = tostring(text or ""):lower():gsub("%s+", " ")
    return lowered:find("use code", 1, true)
        or lowered:find("use this code", 1, true)
        or lowered:find("the code is", 1, true)
        or lowered:find("code is", 1, true)
        or lowered:find("%f[%w]type%f[%W]") ~= nil
end
local function isBlacklistedPhrase(text)
    local lowered    = tostring(text or ""):lower():gsub("%s+", " ")
    local normalized = lowered:gsub("[^%w_]+", " "):gsub("%s+", " ")
    if lowered:match("^%s*sammy%s*:")      then return true end
    if lowered:match("^%s*spydersammy%s*:") then return true end
    if lowered:match("^%s*@?[%w_]+%s+cancell?ed%W*$") then return true end
    for _, phrase in ipairs(BLACKLISTED_PHRASES) do
        local phraseLower = phrase:lower()
        if phraseLower ~= "sammy:" and phraseLower ~= "spydersammy:" then
            local pn = phraseLower:gsub("[^%w_]+", " "):gsub("%s+", " ")
            if lowered:find(phraseLower, 1, true)
                or (pn ~= "" and normalized:find(pn, 1, true)) then
                return true
            end
        end
    end
    return false
end
----------------------------------------------------------------------
-- Notify remote mapper
----------------------------------------------------------------------
local function getRemotesFromFn(fn)
    if not getupvalues then return {} end
    local ok, ups = pcall(getupvalues, fn)
    local out = {}
    if ok and ups then
        for _, v in pairs(ups) do
            if typeof(v) == "Instance"
                and (v:IsA("RemoteEvent") or v:IsA("RemoteFunction") or v:IsA("UnreliableRemoteEvent"))
                and v.Parent == Net then
                table.insert(out, v)
            end
        end
    end
    return out
end
local function resolveNotifyRemote()
    local ok, ctrl = pcall(function()
        return require(ReplicatedStorage.Controllers:FindFirstChild("NotificationController", true))
    end)
    if ok and type(ctrl) == "table" and type(ctrl.Start) == "function" then
        return getRemotesFromFn(ctrl["Start"])[1]
    end
end
----------------------------------------------------------------------
-- Redeem
----------------------------------------------------------------------
local function resolveRedeemRemote()
    if RedeemRemote and RedeemRemote.Parent then return RedeemRemote end
    local ok, api = pcall(require, Net)
    if ok and type(api) == "table" then
        local rok, rf = pcall(function() return api:RemoteFunction(REDEEM_GUID) end)
        if rok and typeof(rf) == "Instance" then RedeemRemote = rf end
    end
    return RedeemRemote
end
local function getGameCodeBox()
    local gui = PG:FindFirstChild("Codes")
    if not gui then return nil end
    local root = gui:FindFirstChild("Codes") or gui
    local cr   = root:FindFirstChild("CodeRedeem")
    local box  = cr and cr:FindFirstChild("TextBox")
    if box and box:IsA("TextBox") then return box end
    for _, d in ipairs(gui:GetDescendants()) do if d:IsA("TextBox") then return d end end
end
local function killDebounce(fn)
    if not (fn and setupv and getupvalues) then return end
    local ok, ups = pcall(getupvalues, fn)
    if ok and type(ups) == "table" then
        for i, v in pairs(ups) do if type(v) == "boolean" then pcall(setupv, fn, i, false) end end
    end
end
local function getRedeemTarget()
    if RedeemBox and RedeemBox.Parent and RedeemConnections and #RedeemConnections > 0 then
        return RedeemBox, RedeemConnections
    end
    local box = getGameCodeBox()
    if not box then RedeemBox, RedeemConnections = nil, nil; return nil, nil, "no codebox" end
    local ok, conns = pcall(getconns, box.FocusLost)
    if not ok or type(conns) ~= "table" or #conns == 0 then
        RedeemBox, RedeemConnections = nil, nil; return nil, nil, "no connection"
    end
    for _, c in ipairs(conns) do
        local fn; pcall(function() fn = c.Function end); killDebounce(fn)
    end
    RedeemBox, RedeemConnections = box, conns
    return box, conns
end
local function redeemViaBox(code)
    if not getconns then return false, "no getconnections" end
    local box, conns, targetErr = getRedeemTarget()
    if not box then return false, targetErr end
    box.Text = code; box.Active = true; box.Selectable = true
    local fired = false
    for _, c in ipairs(conns) do
        local fok = pcall(function() if c.Enabled ~= false then c:Fire(true) end end)
        fired = fired or fok
    end
    return fired, fired and "sent" or "fire failed"
end
local function redeemViaRemote(code)
    local rf = resolveRedeemRemote()
    if not rf then return false, "no remote" end
    local ok, accepted, detail = pcall(function() return rf:InvokeServer(code) end)
    if not ok then return false, tostring(accepted) end
    if accepted then return true, detail or "Code redeemed!" end
    return false, detail or "Request failed"
end
local function redeem(code)
    local ok, res = redeemViaBox(code)
    if ok then return true, res end
    if getconns then return false, res end
    return redeemViaRemote(code)
end
----------------------------------------------------------------------
-- Theme (black / gray / white) + builders
----------------------------------------------------------------------
local C = {
    bg    = Color3.fromRGB(7,7,9),       panel  = Color3.fromRGB(18,18,21),
    panel2= Color3.fromRGB(34,34,39),    line   = Color3.fromRGB(76,76,84),
    acc   = Color3.fromRGB(74,155,255),  acc2   = Color3.fromRGB(34,82,148),
    accHi = Color3.fromRGB(105,195,255),
    txt   = Color3.fromRGB(255,255,255), sub    = Color3.fromRGB(178,178,186),
    warn  = Color3.fromRGB(200,200,208), input  = Color3.fromRGB(3,3,5),
    dark  = Color3.fromRGB(0,0,0),
    listen= Color3.fromRGB(105,195,255),
    feedLine = Color3.fromRGB(31,72,124),
    toggleOn = Color3.fromRGB(88,174,230),
    toggleOff = Color3.fromRGB(58,60,68),
}
local function toggleKnobPosition(enabled)
    return UDim2.fromOffset(enabled and 22 or 2, 2)
end
local FR, FM, FB, FBK = Enum.Font.Gotham, Enum.Font.GothamMedium, Enum.Font.GothamBold, Enum.Font.GothamBlack
local function new(cls, props, parent)
    local o = Instance.new(cls)
    for k, v in pairs(props or {}) do o[k] = v end
    if parent then o.Parent = parent end
    return o
end
local function corner(o, r) new("UICorner", { CornerRadius = UDim.new(0, r or 8) }, o) end
local function stroke(o, col, th, tr) return new("UIStroke", { Color = col or C.line, Thickness = th or 1, Transparency = tr or 0 }, o) end
local function tween(o, t, goal, style) TweenService:Create(o, TweenInfo.new(t, style or Enum.EasingStyle.Quad), goal):Play() end
local function gradient(o, c1, c2, rot)
    return new("UIGradient", { Color = ColorSequence.new(c1, c2), Rotation = rot or 90 }, o)
end
local function label(text, size, col, font, xa, parent)
    return new("TextLabel", {
        BackgroundTransparency = 1, Text = text, Font = font or FM, TextSize = size or 12,
        TextColor3 = col or C.txt, TextXAlignment = xa or Enum.TextXAlignment.Left,
    }, parent)
end
local function ghostBtn(text, parent, noStroke)
    local b = new("TextButton", {
        BackgroundColor3 = C.panel2, Text = text, Font = FB, TextSize = 12, TextColor3 = C.txt,
        AutoButtonColor = false, BorderSizePixel = 0, TextStrokeTransparency = 1,
    }, parent)
    corner(b, 8)
    local s = (not noStroke) and stroke(b, C.line, 1, 0.2) or nil
    b.MouseEnter:Connect(function()
        tween(b, 0.12, { BackgroundColor3 = C.panel })
        if s then tween(s, 0.12, { Color = C.acc, Transparency = 0 }) end
    end)
    b.MouseLeave:Connect(function()
        tween(b, 0.12, { BackgroundColor3 = C.panel2 })
        if s then tween(s, 0.12, { Color = C.line, Transparency = 0.2 }) end
    end)
    return b
end
local function drag(handle, target)
    local d, ds, sp
    handle.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            d, ds, sp = true, i.Position, target.Position
            i.Changed:Connect(function()
                if i.UserInputState == Enum.UserInputState.End then d = false end
            end)
        end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if d and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
            local delta = i.Position - ds
            target.Position = UDim2.new(sp.X.Scale, sp.X.Offset + delta.X, sp.Y.Scale, sp.Y.Offset + delta.Y)
        end
    end)
end
----------------------------------------------------------------------
-- Build ScreenGui
----------------------------------------------------------------------
local parentGui = (gethui and gethui()) or PG
local old = parentGui:FindFirstChild("NullHub"); if old then old:Destroy() end
local SG = new("ScreenGui", {
    Name = "NullHub", ResetOnSpawn = false,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling, DisplayOrder = 250,
}, parentGui)
----------------------------------------------------------------------
-- "Snipe Now" top-of-screen notification banner
----------------------------------------------------------------------
local snipeBannerActive = false
local function showSnipeBanner(messageText)
    if snipeBannerActive then return end
    snipeBannerActive = true
    local camera = workspace.CurrentCamera
    local vw = camera and camera.ViewportSize.X or 800
    local bw = math.min(340, vw - 40)
    local banner = new("Frame", {
        Name = "SnipeBanner",
        Size = UDim2.fromOffset(bw, 52),
        Position = UDim2.new(0.5, -bw / 2, 0, -60),
        BackgroundColor3 = Color3.fromRGB(20, 24, 28),
        BorderSizePixel = 0, ClipsDescendants = true,
    }, SG)
    corner(banner, 12); stroke(banner, C.line, 1, 0.3)
    local snipeTag = label("Code Soon", 10, C.warn, FBK, Enum.TextXAlignment.Left, banner)
    snipeTag.Size = UDim2.new(0, 90, 0, 14); snipeTag.Position = UDim2.fromOffset(14, 7)
    local snipeMsg = label("Enable Snipe Soon for Code", 11, C.sub, FM, Enum.TextXAlignment.Left, banner)
    snipeMsg.Size = UDim2.new(1, -28, 0, 16); snipeMsg.Position = UDim2.fromOffset(14, 26)
    snipeMsg.TextTruncate = Enum.TextTruncate.AtEnd
    tween(banner, 0.35, { Position = UDim2.new(0.5, -bw / 2, 0, 16) }, Enum.EasingStyle.Back)
    task.delay(3.5, function()
        if banner.Parent then
            tween(banner, 0.5, { Position = UDim2.new(0.5, -bw / 2, 0, -60) }, Enum.EasingStyle.Quad)
            task.delay(0.55, function()
                if banner.Parent then banner:Destroy() end
                snipeBannerActive = false
            end)
        else
            snipeBannerActive = false
        end
    end)
end
----------------------------------------------------------------------
-- EZ Snipe overlay
----------------------------------------------------------------------
local chasSound = new("Sound", {
    Name = "EZSnipeChas", SoundId = "rbxassetid://7112275565", Volume = 0.8,
}, SoundService)
local ezSnipeOverlayToken = 0
local function showEzSnipeOverlay(messageText)
    ezSnipeOverlayToken += 1
    local existing = SG:FindFirstChild("EzSnipeOverlay")
    if existing then existing:Destroy() end
    local DURATION = 3
    local soundInterval = DURATION / 15
    local overlay = new("Frame", {
        Name = "EzSnipeOverlay", Size = UDim2.fromScale(1, 1),
        BackgroundColor3 = C.dark, BackgroundTransparency = 1, BorderSizePixel = 0, ZIndex = 180,
    }, SG)
    tween(overlay, 0.3, { BackgroundTransparency = 0.65 })
    local textLabel = new("TextLabel", {
        Name = "EZSnipeText", Size = UDim2.fromOffset(300, 50),
        Position = UDim2.new(0.5, -150, 0, 60), BackgroundTransparency = 1,
        Text = "EZ SNIPE", Font = FBK, TextSize = 36, TextColor3 = C.txt, ZIndex = 182,
    }, overlay)
    local soundElapsed, totalElapsed = 0, 0
    local soundConn
    soundConn = RunService.Heartbeat:Connect(function(dt)
        totalElapsed += dt; soundElapsed += dt
        if totalElapsed >= DURATION then
            soundConn:Disconnect()
            if overlay.Parent then
                tween(overlay, 0.4, { BackgroundTransparency = 1 })
                tween(textLabel, 0.4, { TextTransparency = 1 })
                task.delay(0.45, function() if overlay.Parent then overlay:Destroy() end end)
            end
            return
        end
        if soundElapsed >= soundInterval then soundElapsed = 0; pcall(function() chasSound:Play() end) end
    end)
    task.delay(DURATION + 1, function() if overlay.Parent then overlay:Destroy() end end)
end
----------------------------------------------------------------------
-- Vertical menu panel
----------------------------------------------------------------------
local topBarConn
do
    local BAR_W = 280
    local BAR_H = 330
    local COLLAPSED_H = 248
    local MARGIN = 9
    local ROW_W = BAR_W - MARGIN * 2  -- 262
    local ROW_H = 34
    local GAP   = 7

    local topBar = new("Frame", {
        Name = "TopStatusBar",
        Size = UDim2.fromOffset(BAR_W, BAR_H),
        AnchorPoint = Vector2.new(0.5, 0),
        Position = UDim2.new(0.5, 0, 0, 8),
        BackgroundColor3 = Color3.fromRGB(12, 12, 16),
        BorderSizePixel = 0, ClipsDescendants = true,
    }, SG)
    new("UIScale", { Scale = 0.82 }, topBar)
    corner(topBar, 17)
    stroke(topBar, C.line, 1, 0.4)

    -- Drag zone covers the header strip (y=0–40) so buttons below aren't affected
    local dragHandle = new("Frame", {
        Size = UDim2.fromOffset(BAR_W, 40), Position = UDim2.fromOffset(0, 0),
        BackgroundTransparency = 1, BorderSizePixel = 0,
    }, topBar)
    drag(dragHandle, topBar)

    local function sep(y)
        new("Frame", {
            Size = UDim2.fromOffset(BAR_W, 1), Position = UDim2.fromOffset(0, y),
            BackgroundColor3 = C.line, BackgroundTransparency = 0.4, BorderSizePixel = 0,
        }, topBar)
    end

    -- Full-width section row with background
    local function makeRow(y, parent)
        local row = new("Frame", {
            Size = UDim2.fromOffset(ROW_W, ROW_H),
            Position = UDim2.fromOffset(MARGIN, y),
            BackgroundColor3 = Color3.fromRGB(24, 24, 30),
            BorderSizePixel = 0,
        }, parent or topBar)
        corner(row, 9); stroke(row, C.line, 1, 0.4)
        return row
    end

    -- Compact sliding toggle inside a row (anchored to right side)
    local function makeToggle(parent, startOn)
        local sw = new("TextButton", {
            Size = UDim2.fromOffset(38, 18),
            Position = UDim2.fromOffset(ROW_W - 46, (ROW_H - 18) / 2),
            BackgroundColor3 = startOn and C.toggleOn or C.toggleOff,
            BorderSizePixel = 0, AutoButtonColor = false,
            Text = "",
        }, parent)
        corner(sw, 9); stroke(sw, startOn and C.toggleOn or C.line, 1, 0.15)
        local knob = new("Frame", {
            Name = "Knob", Size = UDim2.fromOffset(14, 14),
            Position = toggleKnobPosition(startOn),
            BackgroundColor3 = startOn and C.txt or C.sub,
            BorderSizePixel = 0,
        }, sw)
        corner(knob, 7)
        return sw, knob, sw
    end

    -- Lightly rounded, outlined key badge used by every rebind control
    local function makeKeybindButton(parent, keyCode, x)
        local button = new("TextButton", {
            Size = UDim2.fromOffset(30, 20),
            Position = UDim2.fromOffset(x, (ROW_H - 20) / 2),
            BackgroundColor3 = C.input, BorderSizePixel = 0,
            AutoButtonColor = false, Text = keyCode.Name,
            Font = FBK, TextSize = 9, TextColor3 = C.accHi,
        }, parent)
        corner(button, 5)
        stroke(button, C.feedLine, 1, 0)
        return button
    end

    -- Left-aligned label inside a row
    local function rowLabel(text, parent)
        local lbl = label(text, 11, C.sub, FB, Enum.TextXAlignment.Left, parent)
        lbl.Size = UDim2.fromOffset(ROW_W - 64, ROW_H)
        lbl.Position = UDim2.fromOffset(10, 0)
        return lbl
    end

    -- Left-aligned section title with a horizontal rule continuing beside it
    local function makeDivider(y, title, parent)
        local holder = new("Frame", {
            Size = UDim2.fromOffset(ROW_W, 20), Position = UDim2.fromOffset(MARGIN, y),
            BackgroundTransparency = 1, BorderSizePixel = 0,
        }, parent or topBar)
        local titleWidth = 88
        local dividerTitle = label(title, 8, C.sub, FBK, Enum.TextXAlignment.Left, holder)
        dividerTitle.Size = UDim2.fromOffset(titleWidth, 20)
        dividerTitle.Position = UDim2.fromOffset(2, 0)
        new("Frame", {
            Size = UDim2.fromOffset(ROW_W - titleWidth - 8, 1),
            Position = UDim2.fromOffset(titleWidth + 8, 10),
            BackgroundColor3 = C.line, BackgroundTransparency = 0.15, BorderSizePixel = 0,
        }, holder)
        return holder
    end

    ---- HEADER (y=0–40) ---------------------------------------------
    local topTitle = label("J7 CODE TRACKER", 14, C.txt, FBK, Enum.TextXAlignment.Left, topBar)
    topTitle.Size = UDim2.fromOffset(208, 20); topTitle.Position = UDim2.fromOffset(10, 10)
    topTitle.TextTruncate = Enum.TextTruncate.AtEnd

    gearBtn = ghostBtn("⚙️", topBar, true)
    gearBtn.Size = UDim2.fromOffset(20, 18)
    gearBtn.Position = UDim2.fromOffset(BAR_W - 53, 11)
    gearBtn.TextSize = 11; gearBtn.TextColor3 = C.txt
    gearBtn:FindFirstChildOfClass("UICorner").CornerRadius = UDim.new(0, 4)
    stroke(gearBtn, C.line, 1, 0.35)

    collapseBtn = ghostBtn("-", topBar, true)
    collapseBtn.Size = UDim2.fromOffset(18, 18)
    collapseBtn.Position = UDim2.fromOffset(BAR_W - 28, 11)
    collapseBtn.TextSize = 12; collapseBtn.Font = FBK; collapseBtn.TextColor3 = C.txt
    collapseBtn:FindFirstChildOfClass("UICorner").CornerRadius = UDim.new(0, 4)
    stroke(collapseBtn, C.line, 1, 0.35)

    sep(40)

    ---- CODE LOGS ----------------------------------------------------
    local FEED_Y, FEED_H = 48, 150
    local feedFrame = new("Frame", {
        Size = UDim2.fromOffset(BAR_W - 10, FEED_H),
        Position = UDim2.fromOffset(5, FEED_Y),
        BackgroundTransparency = 1, BorderSizePixel = 0, ClipsDescendants = false,
    }, topBar)
    logPlaceholder = label("", 1, C.sub, FM, Enum.TextXAlignment.Left, feedFrame)
    logPlaceholder.Visible = false
    logScroll = new("ScrollingFrame", {
        Size = UDim2.new(1, -2, 1, -2), Position = UDim2.fromOffset(1, 1),
        BackgroundTransparency = 1, ScrollBarThickness = 0, ScrollBarImageTransparency = 1,
        ScrollingEnabled = false, BorderSizePixel = 0,
        CanvasSize = UDim2.new(0,0,0,0), AutomaticCanvasSize = Enum.AutomaticSize.None,
    }, feedFrame)
    new("UIListLayout", { Padding = UDim.new(0,0), SortOrder = Enum.SortOrder.LayoutOrder }, logScroll)
    logOrder = 1
    activeWordRow = new("Frame", {
        Size = UDim2.new(1, 0, 0, FEED_H - 2), BackgroundTransparency = 1, LayoutOrder = logOrder,
    }, logScroll)
    activePillBg = new("Frame", {
        Size = UDim2.new(1, -2, 1, -2), Position = UDim2.fromOffset(1, 1),
        BackgroundColor3 = Color3.fromRGB(38, 39, 46),
        BackgroundTransparency = 0.05, BorderSizePixel = 0,
    }, activeWordRow)
    corner(activePillBg, 16)
    local codeOutline = stroke(activePillBg, C.feedLine, 0.75, 0)
    codeOutline.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    local feedTitle = label("Snipe Feed", 14, C.accHi, FBK, Enum.TextXAlignment.Left, activePillBg)
    feedTitle.Size = UDim2.fromOffset(100, 20); feedTitle.Position = UDim2.fromOffset(12, 30)
    local feedSubtitle = label("ez sniping", 14, C.accHi, FBK, Enum.TextXAlignment.Right, activePillBg)
    feedSubtitle.Size = UDim2.fromOffset(114, 20)
    feedSubtitle.AnchorPoint = Vector2.new(1, 0)
    feedSubtitle.Position = UDim2.new(1, -8, 0, 30)
    local codeStripe = new("Frame", {
        Size = UDim2.new(1, -16, 0, 36), Position = UDim2.new(0, 8, 0.5, -18),
        BackgroundColor3 = Color3.fromRGB(2, 3, 6), BorderSizePixel = 0,
    }, activePillBg)
    activeCodeLine = label("", 17, C.listen, FBK, Enum.TextXAlignment.Center, codeStripe)
    activeCodeLine.RichText = true
    -- Equal padding keeps the full code centered as new words extend it.
    activeCodeLine.Size = UDim2.new(1, -16, 1, 0)
    activeCodeLine.Position = UDim2.fromOffset(8, 0)
    wordCountLabel = label("", 16, C.accHi, FB, Enum.TextXAlignment.Center, activePillBg)
    wordCountLabel.Size = UDim2.new(1, -24, 0, 24)
    wordCountLabel.Position = UDim2.new(0, 12, 0.5, 23)
    wordCodeLines[#wordCodeLines + 1] = activeCodeLine

    ---- SECTION ROWS (3px gaps between each) ------------------------
    local rowY = FEED_Y + FEED_H + GAP
    local collapsibleContent = {}

    -- SNIPE ROW
    local snipeRow = makeRow(rowY)
    listenLbl = label("SNIPE", 11, C.sub, FB, Enum.TextXAlignment.Left, snipeRow)
    listenLbl.Size = UDim2.fromOffset(40, ROW_H); listenLbl.Position = UDim2.fromOffset(10, 0)
    snipeSwitch, snipeSlider, snipeOnBtn = makeToggle(snipeRow, false)

    keyBtn = makeKeybindButton(snipeRow, bindKey, 55)

    rowY = rowY + ROW_H + GAP

    -- CLEAR FEED ROW
    local clearRow = makeRow(rowY)
    collapsibleContent[#collapsibleContent + 1] = clearRow
    rowLabel("Clear Feed", clearRow)
    clearSwitch, clearSlider, clearOnBtn = makeToggle(clearRow, false)
    clearKeyBtn = makeKeybindButton(clearRow, clearKey, 74)

    rowY = rowY + ROW_H + GAP

    -- AUTO COPY ROW (moved here from header)
    local autoCopyRow = makeRow(rowY)
    collapsibleContent[#collapsibleContent + 1] = autoCopyRow
    autoCopyLabel = label("Auto Copy Typed Codes", 11, C.sub, FB, Enum.TextXAlignment.Left, autoCopyRow)
    autoCopyLabel.Size = UDim2.fromOffset(ROW_W - 64, ROW_H)
    autoCopyLabel.Position = UDim2.fromOffset(10, 0)
    autoCopyPill, autoCopyKnob, autoCopyBtn = makeToggle(autoCopyRow, false)

    -- SETTINGS (AA Help and Test Sender, opened with the gear button)
    settingsPanel = new("Frame", {
        Name = "SettingsPanel", Size = UDim2.fromOffset(BAR_W, 292),
        AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.new(0.5, 238, 0, 8),
        BackgroundColor3 = Color3.fromRGB(12, 12, 16),
        BorderSizePixel = 0, Active = true, Visible = false,
    }, SG)
    new("UIScale", { Scale = 0.82 }, settingsPanel)
    corner(settingsPanel, 14)

    local settingsHeader = new("Frame", {
        Size = UDim2.new(1, 0, 0, 32), BackgroundTransparency = 1,
        BorderSizePixel = 0, Active = true,
    }, settingsPanel)
    drag(settingsHeader, settingsPanel)
    local settingsTitle = label("SETTINGS", 10, C.txt, FBK, Enum.TextXAlignment.Left, settingsHeader)
    settingsTitle.Size = UDim2.new(1, -42, 1, 0); settingsTitle.Position = UDim2.fromOffset(10, 0)
    local settingsCloseBtn = ghostBtn("X", settingsHeader, true)
    settingsCloseBtn.Size = UDim2.fromOffset(18, 18)
    settingsCloseBtn.Position = UDim2.new(1, -27, 0, 7)
    settingsCloseBtn.TextSize = 8
    settingsCloseBtn:FindFirstChildOfClass("UICorner").CornerRadius = UDim.new(0, 4)
    new("Frame", {
        Size = UDim2.new(1, 0, 0, 1), Position = UDim2.fromOffset(0, 31),
        BackgroundColor3 = C.line, BackgroundTransparency = 0.4, BorderSizePixel = 0,
    }, settingsPanel)

    local settingsRowY = 39
    makeDivider(settingsRowY, "AA HELP", settingsPanel)

    settingsRowY = settingsRowY + 27
    local autoBuyRow = makeRow(settingsRowY, settingsPanel)
    rowLabel("Auto Buy", autoBuyRow)
    inlineAutoBuyOnBtn = makeToggle(autoBuyRow, false)

    settingsRowY = settingsRowY + ROW_H + GAP
    local anchorRow = makeRow(settingsRowY, settingsPanel)
    rowLabel("Anchor", anchorRow)
    inlineAnchorOnBtn = makeToggle(anchorRow, false)
    anchorKeyBtn = makeKeybindButton(anchorRow, anchorKey, 64)

    settingsRowY = settingsRowY + ROW_H + GAP
    local radiusRow = makeRow(settingsRowY, settingsPanel)
    rowLabel("Auto-Buy Radius", radiusRow)
    inlineRadiusOnBtn = makeToggle(radiusRow, false)

    settingsRowY = settingsRowY + ROW_H + GAP
    makeDivider(settingsRowY, "TEST SENDER", settingsPanel)

    inlineTestBox = new("TextBox", {
        Size = UDim2.fromOffset(ROW_W, 30), Position = UDim2.fromOffset(MARGIN, settingsRowY + 27),
        BackgroundColor3 = C.panel, BorderSizePixel = 0,
        PlaceholderText = "type a word or message\xE2\x80\xA6", PlaceholderColor3 = C.sub,
        Text = "", TextColor3 = C.txt, ClearTextOnFocus = false,
        Font = FBK, TextSize = 10, TextXAlignment = Enum.TextXAlignment.Left,
    }, settingsPanel)
    corner(inlineTestBox, 6); stroke(inlineTestBox, C.line, 1, 0.25)
    new("UIPadding", { PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 8) }, inlineTestBox)

    inlineSendTest = new("TextButton", {
        Size = UDim2.fromOffset(164, 30), Position = UDim2.fromOffset(MARGIN, settingsRowY + 64),
        BackgroundColor3 = C.accHi, BorderSizePixel = 0, AutoButtonColor = true,
        Text = "SEND", TextColor3 = C.dark, Font = FBK, TextSize = 10,
    }, settingsPanel)
    corner(inlineSendTest, 6)
    inlineRandomTest = ghostBtn("TEST CODE", settingsPanel)
    inlineRandomTest.Size = UDim2.fromOffset(91, 30)
    inlineRandomTest.Position = UDim2.fromOffset(MARGIN + 171, settingsRowY + 64)
    inlineRandomTest.TextSize = 9; inlineRandomTest.Font = FBK

    local function setSettingsVisible(value)
        if value then
            local p = topBar.Position
            settingsPanel.Position = UDim2.new(p.X.Scale, p.X.Offset + 238, p.Y.Scale, p.Y.Offset)
        end
        settingsPanel.Visible = value
        gearBtn.TextColor3 = value and C.accHi or C.txt
    end
    gearBtn.MouseButton1Click:Connect(function()
        setSettingsVisible(not settingsPanel.Visible)
    end)
    settingsCloseBtn.MouseButton1Click:Connect(function()
        setSettingsVisible(false)
    end)

    local collapsed = false
    collapseBtn.MouseButton1Click:Connect(function()
        collapsed = not collapsed
        collapseBtn.Text = collapsed and "+" or "-"
        for _, item in ipairs(collapsibleContent) do
            item.Visible = not collapsed
        end
        tween(topBar, 0.18, {
            Size = UDim2.fromOffset(BAR_W, collapsed and COLLAPSED_H or BAR_H),
        }, Enum.EasingStyle.Quad)
    end)

    -- Fully opaque
    topBar.BackgroundTransparency = 0
end

----------------------------------------------------------------------
-- Smooth window open/close helpers
----------------------------------------------------------------------
----------------------------------------------------------------------
-- Log functions (reference logScroll assigned above)
----------------------------------------------------------------------
local function addLogEntry(text, color, xa)
    logPlaceholder.Visible = false
    logOrder += 1
    local entry = label(text, 10, color or C.txt, FM, xa or Enum.TextXAlignment.Left, logScroll)
    entry.Size = UDim2.new(1, 0, 0, 13)
    entry.LayoutOrder = logOrder
    task.defer(function()
        if logScroll.Parent then
            logScroll.CanvasPosition = Vector2.new(0, math.max(0, logScroll.AbsoluteCanvasSize.Y - logScroll.AbsoluteSize.Y))
        end
    end)
    return entry
end
local function addWordEntry(word)
    cumulativeWord = cumulativeWord .. word
    wordIndex += 1
    if wordCountLabel and wordCountLabel.Parent then
        wordCountLabel.Text = tostring(wordIndex) .. "/" .. tostring(wordIndex)
    end
    local codeText = '<font color="rgb(105, 195, 255)">' .. escapeRichText(string.upper(cumulativeWord)) .. '</font>'
    if activeCodeLine    and activeCodeLine.Parent    then activeCodeLine.Text    = codeText end
    if sidePanelCodeLine and sidePanelCodeLine.Parent then sidePanelCodeLine.Text = codeText end
end
local function clearLog()
    -- Preserve the persistent pill row; only destroy any other stray children
    for _, child in ipairs(logScroll:GetChildren()) do
        if (child:IsA("TextLabel") or child:IsA("Frame")) and child ~= activeWordRow then
            child:Destroy()
        end
    end
    cumulativeWord = ""
    wordIndex = 0
    if wordCountLabel and wordCountLabel.Parent then wordCountLabel.Text = "" end
    wordCodeLines = {}
    if activeCodeLine    and activeCodeLine.Parent    then activeCodeLine.Text    = "" end
    if sidePanelCodeLine and sidePanelCodeLine.Parent then sidePanelCodeLine.Text = "" end
end
local recentNoticeHits = {}
local function canShowNotice(text)
    local key = tostring(text or ""):lower():gsub("%s+", " ")
    if key == "" then return false end
    local now = os.clock()
    local last = recentNoticeHits[key]
    if last and now - last < 0.45 then return false end
    recentNoticeHits[key] = now
    return true
end
local function setAutoCopyCode(v)
    autoCopyCode = v
    tween(autoCopyPill, 0.2, { BackgroundColor3 = v and C.toggleOn or C.toggleOff }, Enum.EasingStyle.Quad)
    tween(autoCopyKnob, 0.16, {
        Position = toggleKnobPosition(v),
        BackgroundColor3 = v and C.txt or C.sub,
    })
    local toggleStroke = autoCopyPill:FindFirstChildOfClass("UIStroke")
    if toggleStroke then tween(toggleStroke, 0.16, { Color = v and C.toggleOn or C.line }) end
    tween(autoCopyLabel, 0.2, { TextColor3 = v and C.txt or C.sub })
end
autoCopyBtn.MouseButton1Click:Connect(function() setAutoCopyCode(not autoCopyCode) end)
local function addSpawnLogEntry(text)
    if not canShowNotice(text) then return end
    local entry = addLogEntry(text, C.listen)
    entry.Font = FB
    return entry
end
----------------------------------------------------------------------
-- Side panel show / hide
----------------------------------------------------------------------
local function showSidePanel()
    if sidePanelVisible or not sidePanel then return end
    sidePanelVisible = true
    sidePanel.Visible = true
    -- Slide in from right to just touching (2px overlap) topBar's right edge
    tween(sidePanel, 0.28, { Position = UDim2.new(0.5, 118, 0, 8) }, Enum.EasingStyle.Back)
end
local function hideSidePanel()
    if not sidePanelVisible or not sidePanel then return end
    sidePanelVisible = false
    tween(sidePanel, 0.18, { Position = UDim2.new(0.5, 120 + 130 + 8, 0, 8) }, Enum.EasingStyle.Quad)
    task.delay(0.22, function()
        if sidePanel and sidePanel.Parent then sidePanel.Visible = false end
    end)
end
----------------------------------------------------------------------
-- Inline Test Sender
----------------------------------------------------------------------


----------------------------------------------------------------------
----------------------------------------------------------------------
do
    local function fireTestAnnouncement(text)
        text = trim(text); if text == "" then return false end
        if typeof(firesignal) ~= "function" then return false end
        if not NotifyRemote or not NotifyRemote.Parent then return false end
        local ok = pcall(firesignal, NotifyRemote.OnClientEvent, text, 5.5, "Sounds.Sfx.Blop", "Top", 2678001507)
        return ok
    end
    inlineSendTest.MouseButton1Click:Connect(function()
        if fireTestAnnouncement(inlineTestBox.Text) then
            inlineTestBox.Text = ""
            inlineTestBox:CaptureFocus()
        end
    end)
    inlineTestBox.FocusLost:Connect(function(enter)
        if enter and fireTestAnnouncement(inlineTestBox.Text) then
            inlineTestBox.Text = ""
            inlineTestBox:CaptureFocus()
        end
    end)
    inlineRandomTest.MouseButton1Click:Connect(function()
        fireTestAnnouncement("TESTCODE" .. tostring(math.random(1000, 9999)))
    end)
end
----------------------------------------------------------------------
-- Inline Help Controls (Auto Buy + Anchor)
----------------------------------------------------------------------
local autoBuyActive, anchored, radiusVisible = false, false, false
local autoBuyRadius = 15
local function inlineToggleController(hit, onChange)
    local hitStroke = hit:FindFirstChildOfClass("UIStroke")
    local knob = hit:FindFirstChild("Knob")
    local state = false
    local function set(value, silent)
        state = value
        tween(hit, 0.14, {
            BackgroundColor3 = value and C.toggleOn or C.toggleOff,
        })
        if knob then
            tween(knob, 0.14, {
                Position = toggleKnobPosition(value),
                BackgroundColor3 = value and C.txt or C.sub,
            })
        end
        if hitStroke then tween(hitStroke, 0.14, { Color = value and C.toggleOn or C.line }) end
        if onChange and not silent then onChange(value) end
    end
    hit.MouseButton1Click:Connect(function() set(not state) end)
    set(false, true)
    return set
end
inlineToggleController(inlineAutoBuyOnBtn, function(value)
    autoBuyActive = value
end)
local setAnchorToggle = inlineToggleController(inlineAnchorOnBtn, function(value)
    anchored = value
    local character = LP.Character
    if character then
        for _, part in ipairs(character:GetDescendants()) do
            if part:IsA("BasePart") then part.Anchored = value end
        end
    end
end)
local function setAnchored(value) setAnchorToggle(value) end
anchorKeyBtn.MouseButton1Click:Connect(function()
    anchorRebinding = true; anchorKeyBtn.Text = "\xE2\x80\xA6"; anchorKeyBtn.TextColor3 = C.warn
end)
inlineToggleController(inlineRadiusOnBtn, function(value)
    radiusVisible = value
end)
-- Radius ring
local radiusFolder = new("Folder", { Name = "__NullHubAutoBuyRadius" }, workspace)
local radiusModel  = new("Model", { Name = "GroundHalo" }, radiusFolder)
radiusModel.WorldPivot = CFrame.new()
local radiusRingBuilt, radiusRingEnabled = false, false
local updateRadiusGeometry, ensureRadiusRing, setRadiusRingEnabled
do
    local radiusAnchor, layerAttachments, radiusBeams = nil, {}, {}
    local BEZIER_CIRCLE = 0.5522847498
    local LAYERS = {
        { name = "NavyOutline", inset = 0, width = 2.35, color = Color3.fromRGB(30, 85, 175), transparency = 0.06, emission = 0.80 },
    }
    updateRadiusGeometry = function()
        if not radiusRingBuilt then return end
        for layerIndex, spec in ipairs(LAYERS) do
            local lr = math.max(0.5, autoBuyRadius - spec.inset)
            for i, att in ipairs(layerAttachments[layerIndex]) do
                local angle   = ((i - 1) / 4) * 2 * math.pi
                local radial  = Vector3.new(math.cos(angle), 0, math.sin(angle))
                local tangent = Vector3.new(-math.sin(angle), 0, math.cos(angle))
                att.Position = radial * lr; att.Axis = tangent; att.SecondaryAxis = radial
            end
            local curve = lr * BEZIER_CIRCLE
            for _, entry in ipairs(radiusBeams) do
                if entry.layerIndex == layerIndex then
                    entry.beam.CurveSize0 = curve; entry.beam.CurveSize1 = curve
                end
            end
        end
    end
    ensureRadiusRing = function()
        if radiusRingBuilt then return end
        radiusRingBuilt = true
        radiusAnchor = new("Part", {
            Name = "RadiusBeamAnchor", Anchored = true, CanCollide = false,
            CanTouch = false, CanQuery = false, CastShadow = false,
            Transparency = 1, Size = Vector3.new(0.1, 0.1, 0.1),
        }, radiusModel)
        for layerIndex, spec in ipairs(LAYERS) do
            layerAttachments[layerIndex] = {}
            for i = 1, 4 do
                layerAttachments[layerIndex][i] = new("Attachment", {
                    Name = spec.name .. "Point" .. i,
                }, radiusAnchor)
            end
            for i = 1, 4 do
                local beam = new("Beam", {
                    Name = spec.name .. i,
                    Attachment0 = layerAttachments[layerIndex][i],
                    Attachment1 = layerAttachments[layerIndex][(i % 4) + 1],
                    FaceCamera = false, Segments = 32,
                    Width0 = spec.width, Width1 = spec.width,
                    Color = ColorSequence.new(spec.color),
                    Transparency = NumberSequence.new(spec.transparency),
                    LightEmission = spec.emission, LightInfluence = 0, Enabled = false,
                }, radiusAnchor)
                radiusBeams[#radiusBeams + 1] = { beam = beam, layerIndex = layerIndex }
            end
        end
        updateRadiusGeometry()
    end
    setRadiusRingEnabled = function(value)
        if radiusRingEnabled == value then return end
        radiusRingEnabled = value
        for _, entry in ipairs(radiusBeams) do entry.beam.Enabled = value end
    end
end
local proximityPrompts = {}
for _, descendant in ipairs(workspace:GetDescendants()) do
    if descendant:IsA("ProximityPrompt") then proximityPrompts[descendant] = true end
end
local promptAddedConn = workspace.DescendantAdded:Connect(function(descendant)
    if descendant:IsA("ProximityPrompt") then proximityPrompts[descendant] = true end
end)
local promptRemovingConn = workspace.DescendantRemoving:Connect(function(descendant)
    proximityPrompts[descendant] = nil
end)
local lastAutoBuy = 0
local autoBuyConn = RunService.Stepped:Connect(function()
    if not autoBuyActive or os.clock() - lastAutoBuy < 0.1 then return end
    lastAutoBuy = os.clock()
    local character = LP.Character
    local root = character and character:FindFirstChild("HumanoidRootPart")
    if not root then return end
    for prompt in pairs(proximityPrompts) do
        local action = tostring(prompt.ActionText or ""):lower()
        local isPurchase = action:find("%f[%a]purchase%f[%A]") ~= nil
        local promptParent = prompt.Parent
        local promptPosition
        if promptParent and promptParent:IsA("Attachment") then
            promptPosition = promptParent.WorldPosition
        elseif promptParent and promptParent:IsA("BasePart") then
            promptPosition = promptParent.Position
        else
            local worldPart = promptParent and promptParent:FindFirstAncestorWhichIsA("BasePart")
            promptPosition = worldPart and worldPart.Position
        end
        if prompt.Parent and prompt.Enabled and isPurchase and promptPosition
            and (root.Position - promptPosition).Magnitude <= autoBuyRadius then
            prompt.HoldDuration = 0
            pcall(function()
                if typeof(fireproximityprompt) == "function" then
                    fireproximityprompt(prompt)
                else
                    prompt:InputHoldBegin(); prompt:InputHoldEnd()
                end
            end)
        end
    end
end)
local radiusVisualConn = RunService.RenderStepped:Connect(function()
    if not radiusVisible then setRadiusRingEnabled(false); return end
    local character = LP.Character
    local root = character and character:FindFirstChild("HumanoidRootPart")
    if not root then setRadiusRingEnabled(false); return end
    ensureRadiusRing()
    radiusModel:PivotTo(CFrame.new(root.Position - Vector3.new(0, 2.35, 0)))
    setRadiusRingEnabled(true)
end)
local characterConn = LP.CharacterAdded:Connect(function(character)
    if not anchored then return end
    task.wait()
    for _, part in ipairs(character:GetDescendants()) do
        if part:IsA("BasePart") then part.Anchored = true end
    end
end)
----------------------------------------------------------------------
-- Redeem action
----------------------------------------------------------------------
local function doRedeem(code)
    code = trim(code)
    if code == "" then return false end
    return redeem(applyCase(code))
end
local redeemQueue, redeemWorkerRunning = {}, false
local function queueRedeem(code)
    code = trim(code)
    if code == "" then return end
    redeemQueue[#redeemQueue + 1] = code
    if redeemWorkerRunning then return end
    redeemWorkerRunning = true
    task.spawn(function()
        while #redeemQueue > 0 do doRedeem(table.remove(redeemQueue, 1)) end
        redeemWorkerRunning = false
    end)
end
local function clearCodeTextFields()
    if RedeemBox and RedeemBox.Parent then RedeemBox.Text = "" end
    local inspected = {}
    local function clearMatchingBoxes(container)
        if not container or inspected[container] then return end
        inspected[container] = true
        for _, object in ipairs(container:GetDescendants()) do
            if object:IsA("TextBox") then
                local belongsToCodeUI = object == RedeemBox
                    or object.Name:lower():find("code", 1, true) ~= nil
                local ancestor = object.Parent
                while not belongsToCodeUI and ancestor and ancestor ~= container do
                    local name = ancestor.Name:lower()
                    belongsToCodeUI = name == "codes"
                        or name:find("phantom", 1, true) ~= nil
                        or name:find("codeui", 1, true) ~= nil
                    ancestor = ancestor.Parent
                end
                if belongsToCodeUI then object.Text = "" end
            end
        end
    end
    clearMatchingBoxes(PG)
    if parentGui ~= PG then clearMatchingBoxes(parentGui) end
end
local clearFlashToken = 0
local function setClearFeedVisual(enabled)
    tween(clearSwitch, 0.16, {
        BackgroundColor3 = enabled and C.toggleOn or C.toggleOff,
    }, Enum.EasingStyle.Quad)
    tween(clearSlider, 0.16, {
        Position = toggleKnobPosition(enabled),
        BackgroundColor3 = enabled and C.txt or C.sub,
    })
    local toggleStroke = clearSwitch:FindFirstChildOfClass("UIStroke")
    if toggleStroke then tween(toggleStroke, 0.16, { Color = enabled and C.toggleOn or C.line }) end
end
local function clearFeed()
    collectBuffer = {}
    table.clear(redeemQueue)
    clearLog()
    clearCodeTextFields()
    clearFlashToken += 1
    local token = clearFlashToken
    setClearFeedVisual(true)
    tween(clearKeyBtn, 0.16, { TextColor3 = C.listen })
    task.delay(0.35, function()
        if token ~= clearFlashToken then return end
        setClearFeedVisual(false)
        if clearKeyBtn and clearKeyBtn.Parent then tween(clearKeyBtn, 0.2, { TextColor3 = C.sub }) end
    end)
end
clearOnBtn.MouseButton1Click:Connect(clearFeed)
clearKeyBtn.MouseButton1Click:Connect(function()
    clearRebinding = true
    clearKeyBtn.Text = "\xE2\x80\xA6"
    clearKeyBtn.TextColor3 = C.warn
end)

----------------------------------------------------------------------
-- Listen / capture logic
----------------------------------------------------------------------
local function setSnipeSwitchVisual(enabled)
    tween(snipeSwitch, 0.2, { BackgroundColor3 = enabled and C.toggleOn or C.toggleOff }, Enum.EasingStyle.Quad)
    tween(snipeSlider, 0.16, {
        Position = toggleKnobPosition(enabled),
        BackgroundColor3 = enabled and C.txt or C.sub,
    })
    local toggleStroke = snipeSwitch:FindFirstChildOfClass("UIStroke")
    if toggleStroke then tween(toggleStroke, 0.16, { Color = enabled and C.toggleOn or C.line }) end
end
local function setListening(v)
    listening = v
    setSnipeSwitchVisual(v)
    tween(listenLbl, 0.16, { TextColor3 = v and C.accHi or C.sub })
    tween(keyBtn,    0.16, { TextColor3 = v and C.accHi or C.sub })
    if v then
        collectBuffer = {}
        cumulativeWord = ""
        wordIndex = 0
        if wordCountLabel and wordCountLabel.Parent then wordCountLabel.Text = "" end
        wordCodeLines = {}
        if activeCodeLine    and activeCodeLine.Parent    then activeCodeLine.Text    = "" end
        if sidePanelCodeLine and sidePanelCodeLine.Parent then sidePanelCodeLine.Text = "" end
    else
        hideSidePanel()
    end
end
local function toggleListen()
    if listening then setListening(false) else setListening(true) end
end
snipeOnBtn.MouseButton1Click:Connect(function() toggleListen() end)
keyBtn.MouseButton1Click:Connect(function()
    rebinding = true; keyBtn.Text = "\xE2\x80\xA6"; keyBtn.TextColor3 = C.warn
end)
----------------------------------------------------------------------
-- Announcement handler
----------------------------------------------------------------------
local POSITIONS = {
    Top = true, Bottom = true, Center = true, Middle = true,
    Left = true, Right = true, TopRight = true, TopLeft = true,
    BottomRight = true, BottomLeft = true,
}
local function extractAnnouncementText(...)
    local packed = table.pack(...)
    local best
    for i = 1, packed.n do
        local v = packed[i]
        if typeof(v) == "string" then
            local text  = stripRich(v)
            local lower = text:lower()
            if text ~= "" and not lower:find("sounds%.") and not lower:find("rbxassetid") and not POSITIONS[text] then
                if not best or #text > #best then best = text end
            end
        end
    end
    return stripRich(tostring(best or ((...) or "")))
end
local function looksLikeAnnouncement(...)
    local a = table.pack(...)
    if a.n == 0 or typeof(a[1]) ~= "string" then return false end
    for i = 2, a.n do
        local v = a[i]
        if typeof(v) == "string" and (v:find("Sounds%.") or v:find("rbxassetid") or POSITIONS[v]) then
            return true
        end
    end
    return false
end
local function onAnnouncement(...)
    local announcementText = extractAnnouncementText(...)
    local text = stripCapturePrefix(announcementText)
    if text == "" then return end
    if isBlacklistedPhrase(text) then return end
    local cue = isCodeCueText(text)
    if cue then return end
    text = extractNamedWords(text)
    if text == "" then return end
    if listening then
        local words = tokenize(text)
        if #words == 0 then return end
        for _, w in ipairs(words) do
            collectBuffer[#collectBuffer + 1] = w
            local joined = table.concat(collectBuffer)
            addWordEntry(w)
            showSidePanel()
            queueRedeem(joined)
            if autoCopyCode then pcall(setclipboard, joined) end
        end
    end
end
----------------------------------------------------------------------
-- Stealthy passive listener
----------------------------------------------------------------------
local listenConn
NotifyRemote = resolveNotifyRemote()
if NotifyRemote then
    listenConn = NotifyRemote.OnClientEvent:Connect(function(...)
        local rawText = extractAnnouncementText(...)
        local lower   = (rawText or ""):lower()
        if lower:find("spawned") then
            addSpawnLogEntry(rawText)
        end
        if lower:find("redeemed") then
            addLogEntry("CAPTURED (REDEEMED)", C.listen)
            showEzSnipeOverlay(rawText)
            return
        end
        if not looksLikeAnnouncement(...) then
            if listening then pcall(onAnnouncement, ...) end
            return
        end
        if lower:find("code") and not listening then
            showSnipeBanner(rawText)
        end
        pcall(onAnnouncement, ...)
    end)
end
local function watchNotificationTextObject(obj)
    if not (obj and (obj:IsA("TextLabel") or obj:IsA("TextButton"))) then return end
    if obj:IsDescendantOf(SG) then return end
    local function inspectText()
        local text  = stripRich(tostring(obj.Text or ""))
        local lower = text:lower()
        if lower:find("spawned") then addSpawnLogEntry(text) end
    end
    inspectText()
    obj:GetPropertyChangedSignal("Text"):Connect(inspectText)
end
for _, descendant in ipairs(parentGui:GetDescendants()) do
    watchNotificationTextObject(descendant)
end
parentGui.DescendantAdded:Connect(watchNotificationTextObject)
task.spawn(function()
    if getconns and getGameCodeBox() then getRedeemTarget()
    else resolveRedeemRemote() end
end)
----------------------------------------------------------------------
-- Keybind
----------------------------------------------------------------------
local inputConn = UserInputService.InputBegan:Connect(function(input, gpe)
    if input.UserInputType ~= Enum.UserInputType.Keyboard then return end
    if anchorRebinding then
        anchorRebinding = false
        if input.KeyCode ~= Enum.KeyCode.Escape then anchorKey = input.KeyCode end
        anchorKeyBtn.Text = anchorKey.Name; anchorKeyBtn.TextColor3 = C.txt
        return
    end
    if clearRebinding then
        clearRebinding = false
        if input.KeyCode ~= Enum.KeyCode.Escape then clearKey = input.KeyCode end
        clearKeyBtn.Text = clearKey.Name; clearKeyBtn.TextColor3 = C.sub
        return
    end
    if rebinding then
        rebinding = false
        if input.KeyCode ~= Enum.KeyCode.Escape then bindKey = input.KeyCode end
        keyBtn.Text = bindKey.Name; keyBtn.TextColor3 = C.sub
        return
    end
    if gpe then return end
    if input.KeyCode == bindKey  then toggleListen() end
    if input.KeyCode == clearKey then clearFeed() end
    if input.KeyCode == anchorKey then setAnchored(not anchored) end
end)
----------------------------------------------------------------------
-- Teardown
----------------------------------------------------------------------
local stopped = false
local function stopNullHub()
    if stopped then return end
    stopped = true
    if topBarConn       then pcall(function() topBarConn:Disconnect()       end); topBarConn       = nil end
    if listenConn       then pcall(function() listenConn:Disconnect()       end); listenConn       = nil end
    if inputConn        then pcall(function() inputConn:Disconnect()        end); inputConn        = nil end
    if autoBuyConn      then pcall(function() autoBuyConn:Disconnect()      end); autoBuyConn      = nil end
    if promptAddedConn  then pcall(function() promptAddedConn:Disconnect()  end); promptAddedConn  = nil end
    if promptRemovingConn then pcall(function() promptRemovingConn:Disconnect() end); promptRemovingConn = nil end
    if radiusVisualConn then pcall(function() radiusVisualConn:Disconnect() end); radiusVisualConn = nil end
    if characterConn    then pcall(function() characterConn:Disconnect()    end); characterConn    = nil end
    if anchored then pcall(function() setAnchored(false) end) end
    if radiusFolder then pcall(function() radiusFolder:Destroy() end); radiusFolder = nil end
end
SG.Destroying:Connect(stopNullHub)
setListening(false)

]=]
local __instincts_redeemer_chunk, __instincts_redeemer_error = loadstring(__instincts_redeemer_source)
if not __instincts_redeemer_chunk then
    error(__instincts_redeemer_error)
end
return __instincts_redeemer_chunk()
