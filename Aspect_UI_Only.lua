-- UI-ONLY PREVIEW: no gameplay changes, server remotes, or external code loading.
--leaked by aggredire. on /noxaduel
--leaked by aggredire. on /noxaduel
--leaked by aggredire. on /noxaduel
--leaked by aggredire. on /noxaduel
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local LocalPlayer = Players.LocalPlayer

-- ============================================================
-- FILE API (opzionale, per persistenza impostazioni)
-- ============================================================
local function hasFunc(n) return type(getfenv()[n]) == "function" end
local FILE_API = hasFunc("writefile") and hasFunc("readfile") and hasFunc("isfile")

local FOLDER   = "AspectSpeedBypass"
local SAVEFILE = FOLDER .. "/settings.json"

local function ensureFolder()
    if not FILE_API then return end
    if hasFunc("isfolder") and hasFunc("makefolder") then
        local ok, exists = pcall(isfolder, FOLDER)
        if ok and not exists then pcall(makefolder, FOLDER) end
    end
end

local function saveSettings(data)
    if not FILE_API then return end
    ensureFolder()
    pcall(function() writefile(SAVEFILE, HttpService:JSONEncode(data)) end)
end

local function loadSettings()
    if not FILE_API then return nil end
    local ok, exists = pcall(isfile, SAVEFILE)
    if not ok or not exists then return nil end
    local okR, raw = pcall(readfile, SAVEFILE)
    if not okR or type(raw) ~= "string" or raw == "" then return nil end
    local okD, decoded = pcall(function() return HttpService:JSONDecode(raw) end)
    if not okD or type(decoded) ~= "table" then return nil end
    return decoded
end

local saved = loadSettings() or {}

-- ============================================================
-- STATE / CONFIG
-- ============================================================
local VERSIONS = { "V1", "V2" }

local state = {
    enabled          = false,
    stopAfterDrop    = saved.stopAfterDrop    == true,
    enableAfterGrab  = saved.enableAfterGrab  == true,
    mode             = (saved.mode == "MOB") and "MOB" or "PC",
    version          = (saved.version == "V2") and "V2" or "V1",
    listeningForKey  = false,
}

local function defaultVersion()
    return { pcPower = 97000, mobilePower = 72000, keybind = "R" }
end

local versionData = {}
for _, ver in ipairs(VERSIONS) do
    local def = defaultVersion()
    local src = (type(saved.versions) == "table" and type(saved.versions[ver]) == "table")
        and saved.versions[ver] or {}
    versionData[ver] = {
        pcPower     = math.clamp(tonumber(src.pcPower)     or def.pcPower,     10000, 500000),
        mobilePower = math.clamp(tonumber(src.mobilePower) or def.mobilePower, 10000, 500000),
        keybind     = tostring(src.keybind or def.keybind),
    }
    if versionData[ver].keybind == "" then versionData[ver].keybind = "R" end
end

local function currentV() return versionData[state.version] end
local function getCurrentPower()
    if state.mode == "MOB" then return currentV().mobilePower
    else return currentV().pcPower end
end

local function persistAll()
    saveSettings({
        stopAfterDrop   = state.stopAfterDrop,
        enableAfterGrab = state.enableAfterGrab,
        mode            = state.mode,
        version         = state.version,
        versions        = versionData,
    })
end

-- ============================================================
-- GUI
-- ============================================================
local AspectSpeedBypassGUI = Instance.new("ScreenGui")
AspectSpeedBypassGUI.Name = "AspectSpeedBypassGUI"
AspectSpeedBypassGUI.IgnoreGuiInset = true
AspectSpeedBypassGUI.ResetOnSpawn = false
AspectSpeedBypassGUI.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
AspectSpeedBypassGUI.Parent = LocalPlayer:WaitForChild("PlayerGui")

-- // Utility: make a frame draggable
local function makeDraggable(handle, frame)
    local dragging = false
    local dragStart, startPos
    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (
            input.UserInputType == Enum.UserInputType.MouseMovement or
            input.UserInputType == Enum.UserInputType.Touch
        ) then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)
end

local function tween(obj, props, t)
    TweenService:Create(obj, TweenInfo.new(t or 0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), props):Play()
end

local PURPLE_ON  = Color3.fromRGB(120, 60, 220)
local PURPLE_OFF = Color3.fromRGB(55, 30, 80)
local GREEN_ON   = Color3.fromRGB(60, 200, 100)
local RED_OFF    = Color3.fromRGB(200, 60, 60)

-- ============================================================
-- MAIN FRAME
-- ============================================================
local Main = Instance.new("Frame")
Main.Name = "Main"
Main.Active = true
Main.ClipsDescendants = true
Main.Position = UDim2.new(0.5,-120,0.5,-189)
Main.Size = UDim2.new(0,240,0,378)
Main.BackgroundColor3 = Color3.fromRGB(22,10,40)
Main.BorderSizePixel = 0
Main.Parent = AspectSpeedBypassGUI

    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0,14)
    UICorner.Parent = Main

    -- Bordo perfettamente arrotondato con gradiente applicato direttamente allo UIStroke
    local UIStroke = Instance.new("UIStroke")
    UIStroke.Color = Color3.fromRGB(175,95,255)
    UIStroke.Thickness = 2
    UIStroke.Transparency = 0.1
    UIStroke.Parent = Main

    local StrokeGradient = Instance.new("UIGradient")
    StrokeGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(175, 95, 255)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(220, 180, 255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(175, 95, 255))
    })
    StrokeGradient.Rotation = 45
    StrokeGradient.Parent = UIStroke

    local BackgroundImage = Instance.new("ImageLabel")
    BackgroundImage.Size = UDim2.new(1,0,1,0)
    BackgroundImage.BackgroundTransparency = 1
    BackgroundImage.Image = "rbxassetid://105617353987418"
    BackgroundImage.ScaleType = Enum.ScaleType.Crop -- Mantiene l'adattamento perfetto
    BackgroundImage.Parent = Main

        local UICorner3 = Instance.new("UICorner")
        UICorner3.CornerRadius = UDim.new(0,14)
        UICorner3.Parent = BackgroundImage

    local ContentShade = Instance.new("Frame")
    ContentShade.ZIndex = 2
    ContentShade.Size = UDim2.new(1,0,1,0)
    ContentShade.BackgroundColor3 = Color3.fromRGB(12,4,24)
    ContentShade.BackgroundTransparency = 0.55
    ContentShade.BorderSizePixel = 0
    ContentShade.Parent = Main

        local UICorner4 = Instance.new("UICorner")
        UICorner4.CornerRadius = UDim.new(0,14)
        UICorner4.Parent = ContentShade

-- ============================================================
-- TOP BAR
-- ============================================================
    local TopBar = Instance.new("Frame")
    TopBar.Name = "TopBar"
    TopBar.ZIndex = 4
    TopBar.Size = UDim2.new(1,0,0,48)
    TopBar.BackgroundTransparency = 1
    TopBar.BorderSizePixel = 0
    TopBar.Parent = Main

        local TitleImage = Instance.new("ImageLabel")
        TitleImage.ZIndex = 5
        TitleImage.Position = UDim2.new(0,4,0,2)
        TitleImage.Size = UDim2.new(1,-40,1,-4)
        TitleImage.BackgroundTransparency = 1
        TitleImage.Image = "rbxassetid://109469814162273"
        TitleImage.Parent = TopBar

        local MinBtn = Instance.new("TextButton")
        MinBtn.Name = "MinBtn"
        MinBtn.ZIndex = 6
        MinBtn.Position = UDim2.new(1,-34,0,11)
        MinBtn.Size = UDim2.new(0,28,0,26)
        MinBtn.BackgroundColor3 = Color3.fromRGB(48,24,82)
        MinBtn.BackgroundTransparency = 0.15
        MinBtn.BorderSizePixel = 0
        MinBtn.Text = "−"
        MinBtn.TextColor3 = Color3.fromRGB(255,255,255)
        MinBtn.TextSize = 18
        MinBtn.Font = Enum.Font.GothamBold
        MinBtn.AutoButtonColor = false
        MinBtn.Parent = TopBar

            local UICorner5 = Instance.new("UICorner")
            UICorner5.CornerRadius = UDim.new(0,7)
            UICorner5.Parent = MinBtn

            local UIStroke2 = Instance.new("UIStroke")
            UIStroke2.Color = Color3.fromRGB(175,95,255)
            UIStroke2.Transparency = 0.3
            UIStroke2.Parent = MinBtn

-- ============================================================
-- STATUS BOX
-- ============================================================
    local StatusBox = Instance.new("TextButton")
    StatusBox.Name = "StatusBox"
    StatusBox.ZIndex = 4
    StatusBox.Position = UDim2.new(0,10,0,54)
    StatusBox.Size = UDim2.new(1,-20,0,34)
    StatusBox.BackgroundColor3 = Color3.fromRGB(38,18,68)
    StatusBox.BackgroundTransparency = 0.15
    StatusBox.BorderSizePixel = 0
    StatusBox.Text = ""
    StatusBox.AutoButtonColor = false
    StatusBox.Parent = Main

        local UICorner6 = Instance.new("UICorner")
        UICorner6.CornerRadius = UDim.new(0,9)
        UICorner6.Parent = StatusBox

        local UIStroke3 = Instance.new("UIStroke")
        UIStroke3.Color = Color3.fromRGB(155,80,245)
        UIStroke3.Thickness = 1.2
        UIStroke3.Transparency = 0.25
        UIStroke3.Parent = StatusBox

        local StateLabel = Instance.new("TextLabel")
        StateLabel.ZIndex = 5
        StateLabel.Position = UDim2.new(0,12,0,0)
        StateLabel.Size = UDim2.new(0,50,0,34)
        StateLabel.BackgroundTransparency = 1
        StateLabel.Text = "State"
        StateLabel.TextColor3 = Color3.fromRGB(255,255,255)
        StateLabel.TextSize = 12
        StateLabel.Font = Enum.Font.GothamBold
        StateLabel.TextXAlignment = Enum.TextXAlignment.Left
        StateLabel.Parent = StatusBox

        local StatusValueLabel = Instance.new("TextLabel")
        StatusValueLabel.ZIndex = 5
        StatusValueLabel.Position = UDim2.new(1,-100,0,0)
        StatusValueLabel.Size = UDim2.new(0,90,0,34)
        StatusValueLabel.BackgroundTransparency = 1
        StatusValueLabel.Text = "PREVIEW OFF"
        StatusValueLabel.TextColor3 = RED_OFF
        StatusValueLabel.TextSize = 13
        StatusValueLabel.Font = Enum.Font.GothamBold
        StatusValueLabel.TextXAlignment = Enum.TextXAlignment.Right
        StatusValueLabel.Parent = StatusBox

-- ============================================================
-- KEYBIND ROW
-- ============================================================
    local KeyRow = Instance.new("Frame")
    KeyRow.Name = "KeyRow"
    KeyRow.ZIndex = 4
    KeyRow.Position = UDim2.new(0,10,0,96)
    KeyRow.Size = UDim2.new(1,-20,0,36)
    KeyRow.BackgroundColor3 = Color3.fromRGB(38,18,68)
    KeyRow.BackgroundTransparency = 0.15
    KeyRow.BorderSizePixel = 0
    KeyRow.Parent = Main

        local UICorner7 = Instance.new("UICorner")
        UICorner7.CornerRadius = UDim.new(0,9)
        UICorner7.Parent = KeyRow

        local UIStroke4 = Instance.new("UIStroke")
        UIStroke4.Color = Color3.fromRGB(155,80,245)
        UIStroke4.Thickness = 1.2
        UIStroke4.Transparency = 0.25
        UIStroke4.Parent = KeyRow

        local KeybindLabel = Instance.new("TextLabel")
        KeybindLabel.ZIndex = 5
        KeybindLabel.Position = UDim2.new(0,12,0,0)
        KeybindLabel.Size = UDim2.new(0,60,0,36)
        KeybindLabel.BackgroundTransparency = 1
        KeybindLabel.Text = "Keybind"
        KeybindLabel.TextColor3 = Color3.fromRGB(255,255,255)
        KeybindLabel.TextSize = 12
        KeybindLabel.Font = Enum.Font.GothamBold
        KeybindLabel.TextXAlignment = Enum.TextXAlignment.Left
        KeybindLabel.Parent = KeyRow

        local KeyBtn = Instance.new("TextButton")
        KeyBtn.Name = "KeyBtn"
        KeyBtn.ZIndex = 5
        KeyBtn.Position = UDim2.new(1,-76,0,6)
        KeyBtn.Size = UDim2.new(0,64,0,24)
        KeyBtn.BackgroundColor3 = Color3.fromRGB(48,24,82)
        KeyBtn.BackgroundTransparency = 0.05
        KeyBtn.BorderSizePixel = 0
        KeyBtn.Text = currentV().keybind
        KeyBtn.TextColor3 = Color3.fromRGB(255,255,255)
        KeyBtn.TextSize = 13
        KeyBtn.Font = Enum.Font.GothamBold
        KeyBtn.AutoButtonColor = false
        KeyBtn.Parent = KeyRow

            local UICorner8 = Instance.new("UICorner")
            UICorner8.CornerRadius = UDim.new(0,7)
            UICorner8.Parent = KeyBtn

            local UIStroke5 = Instance.new("UIStroke")
            UIStroke5.Color = Color3.fromRGB(175,95,255)
            UIStroke5.Thickness = 1.1
            UIStroke5.Transparency = 0.15
            UIStroke5.Parent = KeyBtn

-- ============================================================
-- POWER ROW
-- ============================================================
    local PowerRow = Instance.new("Frame")
    PowerRow.Name = "PowerRow"
    PowerRow.ZIndex = 4
    PowerRow.Position = UDim2.new(0,10,0,140)
    PowerRow.Size = UDim2.new(1,-20,0,36)
    PowerRow.BackgroundColor3 = Color3.fromRGB(38,18,68)
    PowerRow.BackgroundTransparency = 0.15
    PowerRow.BorderSizePixel = 0
    PowerRow.Parent = Main

        local UICorner9 = Instance.new("UICorner")
        UICorner9.CornerRadius = UDim.new(0,9)
        UICorner9.Parent = PowerRow

        local UIStroke6 = Instance.new("UIStroke")
        UIStroke6.Color = Color3.fromRGB(155,80,245)
        UIStroke6.Thickness = 1.2
        UIStroke6.Transparency = 0.25
        UIStroke6.Parent = PowerRow

        local PowerLabel = Instance.new("TextLabel")
        PowerLabel.ZIndex = 5
        PowerLabel.Position = UDim2.new(0,12,0,0)
        PowerLabel.Size = UDim2.new(0,60,0,36)
        PowerLabel.BackgroundTransparency = 1
        PowerLabel.Text = "Power"
        PowerLabel.TextColor3 = Color3.fromRGB(255,255,255)
        PowerLabel.TextSize = 12
        PowerLabel.Font = Enum.Font.GothamBold
        PowerLabel.TextXAlignment = Enum.TextXAlignment.Left
        PowerLabel.Parent = PowerRow

        local PowerBox = Instance.new("TextBox")
        PowerBox.Name = "PowerBox"
        PowerBox.ZIndex = 5
        PowerBox.Position = UDim2.new(1,-96,0,6)
        PowerBox.Size = UDim2.new(0,84,0,24)
        PowerBox.BackgroundColor3 = Color3.fromRGB(48,24,82)
        PowerBox.BackgroundTransparency = 0.05
        PowerBox.BorderSizePixel = 0
        PowerBox.Text = tostring(getCurrentPower())
        PowerBox.TextColor3 = Color3.fromRGB(255,255,255)
        PowerBox.TextSize = 12
        PowerBox.Font = Enum.Font.GothamBold
        PowerBox.PlaceholderText = "10K-500K"
        PowerBox.PlaceholderColor3 = Color3.fromRGB(160,130,190)
        PowerBox.ClearTextOnFocus = false
        PowerBox.Parent = PowerRow

            local UICorner10 = Instance.new("UICorner")
            UICorner10.CornerRadius = UDim.new(0,7)
            UICorner10.Parent = PowerBox

            local UIStroke7 = Instance.new("UIStroke")
            UIStroke7.Color = Color3.fromRGB(175,95,255)
            UIStroke7.Thickness = 1.1
            UIStroke7.Transparency = 0.15
            UIStroke7.Parent = PowerBox

-- ============================================================
-- MODE CONTAINER (PC / MOB)
-- ============================================================
    local ModeContainer = Instance.new("Frame")
    ModeContainer.Name = "ModeContainer"
    ModeContainer.ZIndex = 4
    ModeContainer.Position = UDim2.new(0,10,0,184)
    ModeContainer.Size = UDim2.new(1,-20,0,32)
    ModeContainer.BackgroundColor3 = Color3.fromRGB(38,18,68)
    ModeContainer.BackgroundTransparency = 0.15
    ModeContainer.BorderSizePixel = 0
    ModeContainer.Parent = Main

        local UICorner11 = Instance.new("UICorner")
        UICorner11.CornerRadius = UDim.new(0,9)
        UICorner11.Parent = ModeContainer

        local UIStroke8 = Instance.new("UIStroke")
        UIStroke8.Color = Color3.fromRGB(155,80,245)
        UIStroke8.Thickness = 1.2
        UIStroke8.Transparency = 0.25
        UIStroke8.Parent = ModeContainer

        local ModeIndicator = Instance.new("Frame")
        ModeIndicator.Name = "ModeIndicator"
        ModeIndicator.ZIndex = 5
        ModeIndicator.Position = UDim2.new(0,3,0,3)
        ModeIndicator.Size = UDim2.new(0,107,0,26)
        ModeIndicator.BackgroundColor3 = Color3.fromRGB(48,24,82)
        ModeIndicator.BorderSizePixel = 0
        ModeIndicator.Parent = ModeContainer

            local UICorner12 = Instance.new("UICorner")
            UICorner12.CornerRadius = UDim.new(0,7)
            UICorner12.Parent = ModeIndicator

            local UIStroke9 = Instance.new("UIStroke")
            UIStroke9.Color = Color3.fromRGB(175,95,255)
            UIStroke9.Transparency = 0.2
            UIStroke9.Parent = ModeIndicator

        local ModePC = Instance.new("TextButton")
        ModePC.Name = "ModePC"
        ModePC.ZIndex = 6
        ModePC.Size = UDim2.new(0.5,0,1,0)
        ModePC.BackgroundTransparency = 1
        ModePC.Text = "PC"
        ModePC.TextColor3 = Color3.fromRGB(255,255,255)
        ModePC.TextSize = 12
        ModePC.Font = Enum.Font.GothamBold
        ModePC.AutoButtonColor = false
        ModePC.Parent = ModeContainer

        local ModeMob = Instance.new("TextButton")
        ModeMob.Name = "ModeMob"
        ModeMob.ZIndex = 6
        ModeMob.Position = UDim2.new(0.5,0,0,0)
        ModeMob.Size = UDim2.new(0.5,0,1,0)
        ModeMob.BackgroundTransparency = 1
        ModeMob.Text = "MOB"
        ModeMob.TextColor3 = Color3.fromRGB(255,255,255)
        ModeMob.TextSize = 12
        ModeMob.Font = Enum.Font.GothamBold
        ModeMob.AutoButtonColor = false
        ModeMob.Parent = ModeContainer

-- ============================================================
-- EXTRA BUTTONS ROW
-- ============================================================
    local ExtraBtnsRow = Instance.new("Frame")
    ExtraBtnsRow.Name = "ExtraBtnsRow"
    ExtraBtnsRow.ZIndex = 4
    ExtraBtnsRow.Position = UDim2.new(0,10,0,224)
    ExtraBtnsRow.Size = UDim2.new(1,-20,0,44)
    ExtraBtnsRow.BackgroundTransparency = 1
    ExtraBtnsRow.Parent = Main

        -- Stop After Drop
        local StopAfterHitBtn = Instance.new("TextButton")
        StopAfterHitBtn.Name = "StopAfterHitBtn"
        StopAfterHitBtn.ZIndex = 5
        StopAfterHitBtn.Size = UDim2.new(0.5,-3,1,0)
        StopAfterHitBtn.BackgroundColor3 = Color3.fromRGB(38,18,68)
        StopAfterHitBtn.BackgroundTransparency = 0.15
        StopAfterHitBtn.BorderSizePixel = 0
        StopAfterHitBtn.Text = ""
        StopAfterHitBtn.AutoButtonColor = false
        StopAfterHitBtn.Parent = ExtraBtnsRow

            local UICorner13 = Instance.new("UICorner")
            UICorner13.CornerRadius = UDim.new(0,9)
            UICorner13.Parent = StopAfterHitBtn

            local UIStroke10 = Instance.new("UIStroke")
            UIStroke10.Color = Color3.fromRGB(155,80,245)
            UIStroke10.Thickness = 1.2
            UIStroke10.Transparency = 0.25
            UIStroke10.Parent = StopAfterHitBtn

            local StopLabel = Instance.new("TextLabel")
            StopLabel.ZIndex = 6
            StopLabel.Position = UDim2.new(0,6,0,2)
            StopLabel.Size = UDim2.new(1,-48,1,-4)
            StopLabel.BackgroundTransparency = 1
            StopLabel.Text = "Option A\n(UI only)"
            StopLabel.TextColor3 = Color3.fromRGB(255,255,255)
            StopLabel.TextSize = 10
            StopLabel.Font = Enum.Font.GothamBold
            StopLabel.TextXAlignment = Enum.TextXAlignment.Left
            StopLabel.TextWrapped = true
            StopLabel.Parent = StopAfterHitBtn

            local StopToggle = Instance.new("TextButton")
            StopToggle.ZIndex = 6
            StopToggle.Position = UDim2.new(1,-42,0.5,-10)
            StopToggle.Size = UDim2.new(0,36,0,20)
            StopToggle.BackgroundColor3 = PURPLE_OFF
            StopToggle.BackgroundTransparency = 0.05
            StopToggle.BorderSizePixel = 0
            StopToggle.Text = ""
            StopToggle.AutoButtonColor = false
            StopToggle.Parent = StopAfterHitBtn

                local UICorner14 = Instance.new("UICorner")
                UICorner14.CornerRadius = UDim.new(0,10)
                UICorner14.Parent = StopToggle

                local UIStroke11 = Instance.new("UIStroke")
                UIStroke11.Color = Color3.fromRGB(155,80,245)
                UIStroke11.Transparency = 0.25
                UIStroke11.Parent = StopToggle

                local StopKnob = Instance.new("Frame")
                StopKnob.ZIndex = 7
                StopKnob.Position = UDim2.new(0,2,0,2)
                StopKnob.Size = UDim2.new(0,16,0,16)
                StopKnob.BackgroundColor3 = Color3.fromRGB(255,255,255)
                StopKnob.BorderSizePixel = 0
                StopKnob.Parent = StopToggle

                    local UICorner15 = Instance.new("UICorner")
                    UICorner15.Parent = StopKnob

        -- Enable After Grab
        local BrainrotAutoBtn = Instance.new("TextButton")
        BrainrotAutoBtn.Name = "BrainrotAutoBtn"
        BrainrotAutoBtn.ZIndex = 5
        BrainrotAutoBtn.Position = UDim2.new(0.5,3,0,0)
        BrainrotAutoBtn.Size = UDim2.new(0.5,-3,1,0)
        BrainrotAutoBtn.BackgroundColor3 = Color3.fromRGB(38,18,68)
        BrainrotAutoBtn.BackgroundTransparency = 0.15
        BrainrotAutoBtn.BorderSizePixel = 0
        BrainrotAutoBtn.Text = ""
        BrainrotAutoBtn.AutoButtonColor = false
        BrainrotAutoBtn.Parent = ExtraBtnsRow

            local UICorner16 = Instance.new("UICorner")
            UICorner16.CornerRadius = UDim.new(0,9)
            UICorner16.Parent = BrainrotAutoBtn

            local UIStroke12 = Instance.new("UIStroke")
            UIStroke12.Color = Color3.fromRGB(155,80,245)
            UIStroke12.Thickness = 1.2
            UIStroke12.Transparency = 0.25
            UIStroke12.Parent = BrainrotAutoBtn

            local GrabLabel = Instance.new("TextLabel")
            GrabLabel.ZIndex = 6
            GrabLabel.Position = UDim2.new(0,6,0,2)
            GrabLabel.Size = UDim2.new(1,-48,1,-4)
            GrabLabel.BackgroundTransparency = 1
            GrabLabel.Text = "Option B\n(UI only)"
            GrabLabel.TextColor3 = Color3.fromRGB(255,255,255)
            GrabLabel.TextSize = 10
            GrabLabel.Font = Enum.Font.GothamBold
            GrabLabel.TextXAlignment = Enum.TextXAlignment.Left
            GrabLabel.TextWrapped = true
            GrabLabel.Parent = BrainrotAutoBtn

            local GrabToggle = Instance.new("TextButton")
            GrabToggle.ZIndex = 6
            GrabToggle.Position = UDim2.new(1,-42,0.5,-10)
            GrabToggle.Size = UDim2.new(0,36,0,20)
            GrabToggle.BackgroundColor3 = PURPLE_OFF
            GrabToggle.BackgroundTransparency = 0.05
            GrabToggle.BorderSizePixel = 0
            GrabToggle.Text = ""
            GrabToggle.AutoButtonColor = false
            GrabToggle.Parent = BrainrotAutoBtn

                local UICorner17 = Instance.new("UICorner")
                UICorner17.CornerRadius = UDim.new(0,10)
                UICorner17.Parent = GrabToggle

                local UIStroke13 = Instance.new("UIStroke")
                UIStroke13.Color = Color3.fromRGB(155,80,245)
                UIStroke13.Transparency = 0.25
                UIStroke13.Parent = GrabToggle

                local GrabKnob = Instance.new("Frame")
                GrabKnob.ZIndex = 7
                GrabKnob.Position = UDim2.new(0,2,0,2)
                GrabKnob.Size = UDim2.new(0,16,0,16)
                GrabKnob.BackgroundColor3 = Color3.fromRGB(255,255,255)
                GrabKnob.BorderSizePixel = 0
                GrabKnob.Parent = GrabToggle

                    local UICorner18 = Instance.new("UICorner")
                    UICorner18.Parent = GrabKnob

-- ============================================================
-- VERSION CONTAINER
-- ============================================================
    local VersionContainer = Instance.new("Frame")
    VersionContainer.Name = "VersionContainer"
    VersionContainer.ZIndex = 4
    VersionContainer.Position = UDim2.new(0,10,0,276)
    VersionContainer.Size = UDim2.new(1,-20,0,48)
    VersionContainer.BackgroundTransparency = 1
    VersionContainer.Parent = Main

        local VersionV1 = Instance.new("TextButton")
        VersionV1.Name = "VersionV1"
        VersionV1.ZIndex = 5
        VersionV1.Size = UDim2.new(0.5,-3,1,0)
        VersionV1.BackgroundColor3 = Color3.fromRGB(38,18,68)
        VersionV1.BackgroundTransparency = 0.08
        VersionV1.BorderSizePixel = 0
        VersionV1.Text = ""
        VersionV1.AutoButtonColor = false
        VersionV1.Parent = VersionContainer

            local UICorner19 = Instance.new("UICorner")
            UICorner19.CornerRadius = UDim.new(0,10)
            UICorner19.Parent = VersionV1

            local UIStroke14 = Instance.new("UIStroke")
            UIStroke14.Color = Color3.fromRGB(175,95,255)
            UIStroke14.Thickness = 1.8
            UIStroke14.Transparency = 0.08
            UIStroke14.Parent = VersionV1

            local V1Img = Instance.new("ImageLabel")
            V1Img.ZIndex = 6
            V1Img.Position = UDim2.new(0,3,0,3)
            V1Img.Size = UDim2.new(1,-6,1,-6)
            V1Img.BackgroundTransparency = 1
            V1Img.Image = "rbxassetid://116555606982534"
            V1Img.ScaleType = Enum.ScaleType.Fit
            V1Img.Parent = VersionV1

        local VersionV2 = Instance.new("TextButton")
        VersionV2.Name = "VersionV2"
        VersionV2.ZIndex = 5
        VersionV2.Position = UDim2.new(0.5,3,0,0)
        VersionV2.Size = UDim2.new(0.5,-3,1,0)
        VersionV2.BackgroundColor3 = Color3.fromRGB(38,18,68)
        VersionV2.BackgroundTransparency = 0.3
        VersionV2.BorderSizePixel = 0
        VersionV2.Text = ""
        VersionV2.AutoButtonColor = false
        VersionV2.Parent = VersionContainer

            local UICorner20 = Instance.new("UICorner")
            UICorner20.CornerRadius = UDim.new(0,10)
            UICorner20.Parent = VersionV2

            local UIStroke15 = Instance.new("UIStroke")
            UIStroke15.Color = Color3.fromRGB(155,80,245)
            UIStroke15.Thickness = 1.2
            UIStroke15.Transparency = 0.4
            UIStroke15.Parent = VersionV2

            local V2Img = Instance.new("ImageLabel")
            V2Img.ZIndex = 6
            V2Img.Position = UDim2.new(0,3,0,3)
            V2Img.Size = UDim2.new(1,-6,1,-6)
            V2Img.BackgroundTransparency = 1
            V2Img.Image = "rbxassetid://74690657427259"
            V2Img.ImageTransparency = 0.4
            V2Img.ScaleType = Enum.ScaleType.Fit
            V2Img.Parent = VersionV2

-- ============================================================
-- FOOTER
-- ============================================================
    local Footer = Instance.new("TextButton")
    Footer.Name = "Footer"
    Footer.ZIndex = 4
    Footer.Position = UDim2.new(0,10,0,332)
    Footer.Size = UDim2.new(1,-20,0,18)
    Footer.BackgroundTransparency = 1
    Footer.Text = "discord.gg/aspectt"
    Footer.TextColor3 = Color3.fromRGB(255,255,255)
    Footer.TextSize = 12
    Footer.Font = Enum.Font.GothamBold
    Footer.AutoButtonColor = false
    Footer.Parent = Main

-- ============================================================
-- MINIBAR
-- ============================================================
local MiniBar = Instance.new("Frame")
MiniBar.Name = "MiniBar"
MiniBar.Visible = false
MiniBar.Active = true
MiniBar.ZIndex = 20
MiniBar.Position = UDim2.new(0,1407,0,323)
MiniBar.Size = UDim2.new(0,220,0,44)
MiniBar.BackgroundColor3 = Color3.fromRGB(22,10,40)
MiniBar.BorderSizePixel = 0
MiniBar.Parent = AspectSpeedBypassGUI

    local UICorner21 = Instance.new("UICorner")
    UICorner21.CornerRadius = UDim.new(0,12)
    UICorner21.Parent = MiniBar

    local UIStroke16 = Instance.new("UIStroke")
    UIStroke16.Color = Color3.fromRGB(175,95,255)
    UIStroke16.Thickness = 1.5
    UIStroke16.Transparency = 0.12
    UIStroke16.Parent = MiniBar

    local MiniTitleImg = Instance.new("ImageLabel")
    MiniTitleImg.ZIndex = 22
    MiniTitleImg.Position = UDim2.new(0,6,0,4)
    MiniTitleImg.Size = UDim2.new(1,-100,1,-8)
    MiniTitleImg.BackgroundTransparency = 1
    MiniTitleImg.Image = "rbxassetid://109469814162273"
    MiniTitleImg.Parent = MiniBar

    local MiniStatusBtn = Instance.new("TextButton")
    MiniStatusBtn.Name = "MiniStatusBtn"
    MiniStatusBtn.ZIndex = 23
    MiniStatusBtn.Position = UDim2.new(1,-88,0,9)
    MiniStatusBtn.Size = UDim2.new(0,52,0,26)
    MiniStatusBtn.BackgroundColor3 = Color3.fromRGB(38,18,68)
    MiniStatusBtn.BackgroundTransparency = 0.1
    MiniStatusBtn.Text = "OFF"
    MiniStatusBtn.TextColor3 = Color3.fromRGB(255,255,255)
    MiniStatusBtn.TextSize = 11
    MiniStatusBtn.Font = Enum.Font.GothamBold
    MiniStatusBtn.AutoButtonColor = false
    MiniStatusBtn.Parent = MiniBar

        local UICorner24 = Instance.new("UICorner")
        UICorner24.CornerRadius = UDim.new(0,7)
        UICorner24.Parent = MiniStatusBtn

    local MiniExpand = Instance.new("TextButton")
    MiniExpand.Name = "MiniExpand"
    MiniExpand.ZIndex = 23
    MiniExpand.Position = UDim2.new(1,-32,0,9)
    MiniExpand.Size = UDim2.new(0,26,0,26)
    MiniExpand.BackgroundColor3 = Color3.fromRGB(48,24,82)
    MiniExpand.BackgroundTransparency = 0.1
    MiniExpand.Text = "+"
    MiniExpand.TextColor3 = Color3.fromRGB(255,255,255)
    MiniExpand.TextSize = 16
    MiniExpand.Font = Enum.Font.GothamBold
    MiniExpand.AutoButtonColor = false
    MiniExpand.Parent = MiniBar

        local UICorner25 = Instance.new("UICorner")
        UICorner25.CornerRadius = UDim.new(0,7)
        UICorner25.Parent = MiniExpand

-- ============================================================
-- UI-ONLY PREVIEW
-- Controls update this interface and local preferences only; they do not alter gameplay or contact game remotes.

-- UI UPDATES
-- ============================================================
local function updateEnabledUI()
    if state.enabled then
        StatusValueLabel.Text = "PREVIEW ON"
        StatusValueLabel.TextColor3 = GREEN_ON
        MiniStatusBtn.Text = "ON"
        MiniStatusBtn.TextColor3 = GREEN_ON
    else
        StatusValueLabel.Text = "DISABLED"
        StatusValueLabel.TextColor3 = RED_OFF
        MiniStatusBtn.Text = "OFF"
        MiniStatusBtn.TextColor3 = Color3.fromRGB(255,255,255)
    end
end

local function refreshPowerUI()
    PowerBox.Text = tostring(getCurrentPower())
end

local function refreshKeybindUI()
    if state.listeningForKey then
        KeyBtn.Text = "..."
        KeyBtn.TextColor3 = Color3.fromRGB(255,220,80)
    else
        KeyBtn.Text = currentV().keybind
        KeyBtn.TextColor3 = Color3.fromRGB(255,255,255)
    end
end

-- ============================================================
-- DRAG
-- ============================================================
makeDraggable(TopBar, Main)
makeDraggable(MiniBar, MiniBar)

-- ============================================================
-- TOGGLE PRINCIPALE
-- ============================================================
local function toggleEnabled()
    state.enabled = not state.enabled
    updateEnabledUI()
end

StatusBox.MouseButton1Click:Connect(toggleEnabled)
MiniStatusBtn.MouseButton1Click:Connect(toggleEnabled)

-- Minimize / Expand
MinBtn.MouseButton1Click:Connect(function()
    Main.Visible = false
    MiniBar.Position = Main.Position
    MiniBar.Visible = true
end)

MiniExpand.MouseButton1Click:Connect(function()
    Main.Position = MiniBar.Position
    MiniBar.Visible = false
    Main.Visible = true
end)

-- ============================================================
-- TOGGLE "Stop After Drop"
-- ============================================================
local function updateStopToggle()
    if state.stopAfterDrop then
        tween(StopKnob, {Position = UDim2.new(0,18,0,2)}, 0.15)
        tween(StopToggle, {BackgroundColor3 = PURPLE_ON}, 0.15)
    else
        tween(StopKnob, {Position = UDim2.new(0,2,0,2)}, 0.15)
        tween(StopToggle, {BackgroundColor3 = PURPLE_OFF}, 0.15)
    end
end

local function toggleStopAfterDrop()
    state.stopAfterDrop = not state.stopAfterDrop
    updateStopToggle()
    -- Preview only: saved preference; no gameplay monitoring.
    persistAll()
end

StopAfterHitBtn.MouseButton1Click:Connect(toggleStopAfterDrop)
StopToggle.MouseButton1Click:Connect(toggleStopAfterDrop)

-- ============================================================
-- TOGGLE "Enable After Grab"
-- ============================================================
local function updateGrabToggle()
    if state.enableAfterGrab then
        tween(GrabKnob, {Position = UDim2.new(0,18,0,2)}, 0.15)
        tween(GrabToggle, {BackgroundColor3 = PURPLE_ON}, 0.15)
    else
        tween(GrabKnob, {Position = UDim2.new(0,2,0,2)}, 0.15)
        tween(GrabToggle, {BackgroundColor3 = PURPLE_OFF}, 0.15)
    end
end

local function toggleEnableAfterGrab()
    state.enableAfterGrab = not state.enableAfterGrab
    updateGrabToggle()
    -- Preview only: saved preference; no gameplay monitoring.
    persistAll()
end

BrainrotAutoBtn.MouseButton1Click:Connect(toggleEnableAfterGrab)
GrabToggle.MouseButton1Click:Connect(toggleEnableAfterGrab)

-- ============================================================
-- MODE PC / MOB
-- ============================================================
local function updateModeUI()
    if state.mode == "PC" then
        tween(ModeIndicator, {Position = UDim2.new(0,3,0,3), Size = UDim2.new(0,107,0,26)}, 0.18)
    else
        tween(ModeIndicator, {Position = UDim2.new(0.5,3,0,3), Size = UDim2.new(0,107,0,26)}, 0.18)
    end
end

ModePC.MouseButton1Click:Connect(function()
    if state.mode == "PC" then return end
    state.mode = "PC"
    updateModeUI()
    refreshPowerUI()
    persistAll()
end)

ModeMob.MouseButton1Click:Connect(function()
    if state.mode == "MOB" then return end
    state.mode = "MOB"
    updateModeUI()
    refreshPowerUI()
    persistAll()
end)

-- ============================================================
-- KEYBIND
-- ============================================================
KeyBtn.MouseButton1Click:Connect(function()
    if state.listeningForKey then return end
    state.listeningForKey = true
    refreshKeybindUI()
end)

-- ============================================================
-- POWER BOX
-- ============================================================
PowerBox.FocusLost:Connect(function()
    local val = tonumber(PowerBox.Text)
    if val then
        val = math.clamp(math.floor(val), 10000, 500000)
        if state.mode == "MOB" then
            currentV().mobilePower = val
        else
            currentV().pcPower = val
        end
        PowerBox.Text = tostring(val)
        persistAll()
    else
        refreshPowerUI()
    end
end)

-- ============================================================
-- VERSION SWITCH
-- ============================================================
local function selectVersion(v)
    if state.version == v then return end
    state.version = v
    state.listeningForKey = false
    if v == "V1" then
        tween(VersionV1, {BackgroundTransparency = 0.08}, 0.15)
        tween(UIStroke14, {Transparency = 0.08}, 0.15)
        tween(VersionV2, {BackgroundTransparency = 0.5}, 0.15)
        tween(UIStroke15, {Transparency = 0.5}, 0.15)
        V2Img.ImageTransparency = 0.5
        V1Img.ImageTransparency = 0
    else
        tween(VersionV2, {BackgroundTransparency = 0.08}, 0.15)
        tween(UIStroke15, {Transparency = 0.08}, 0.15)
        tween(VersionV1, {BackgroundTransparency = 0.5}, 0.15)
        tween(UIStroke14, {Transparency = 0.5}, 0.15)
        V1Img.ImageTransparency = 0.5
        V2Img.ImageTransparency = 0
    end
    refreshPowerUI()
    refreshKeybindUI()
    persistAll()
end

VersionV1.MouseButton1Click:Connect(function() selectVersion("V1") end)
VersionV2.MouseButton1Click:Connect(function() selectVersion("V2") end)

-- ============================================================
-- FOOTER
-- ============================================================
-- INPUT LISTENER (keybind + global)
-- ============================================================
UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end

    -- Keybind listening
    if state.listeningForKey then
        if input.UserInputType == Enum.UserInputType.Keyboard
        or input.UserInputType == Enum.UserInputType.Gamepad1
        or input.UserInputType == Enum.UserInputType.Gamepad2
        or input.UserInputType == Enum.UserInputType.Gamepad3
        or input.UserInputType == Enum.UserInputType.Gamepad4 then
            if input.KeyCode == Enum.KeyCode.Unknown then return end
            currentV().keybind = input.KeyCode.Name
            state.listeningForKey = false
            refreshKeybindUI()
            persistAll()
        end
        return
    end

    -- Toggle con keybind
    if input.UserInputType == Enum.UserInputType.Keyboard
    or input.UserInputType == Enum.UserInputType.Gamepad1
    or input.UserInputType == Enum.UserInputType.Gamepad2
    or input.UserInputType == Enum.UserInputType.Gamepad3
    or input.UserInputType == Enum.UserInputType.Gamepad4 then
        if input.KeyCode.Name == currentV().keybind then
            toggleEnabled()
        end
    end
end)

-- ============================================================
-- INIT
-- ============================================================
updateEnabledUI()
updateModeUI()
updateStopToggle()
updateGrabToggle()
refreshPowerUI()
refreshKeybindUI()

-- Imposta UI versione iniziale
if state.version == "V1" then
    VersionV1.BackgroundTransparency = 0.08
    UIStroke14.Transparency = 0.08
    VersionV2.BackgroundTransparency = 0.5
    UIStroke15.Transparency = 0.5
    V2Img.ImageTransparency = 0.5
    V1Img.ImageTransparency = 0
else
    VersionV2.BackgroundTransparency = 0.08
    UIStroke15.Transparency = 0.08
    VersionV1.BackgroundTransparency = 0.5
    UIStroke14.Transparency = 0.5
    V1Img.ImageTransparency = 0.5
    V2Img.ImageTransparency = 0
end

print("Aspect UI-only preview loaded")
