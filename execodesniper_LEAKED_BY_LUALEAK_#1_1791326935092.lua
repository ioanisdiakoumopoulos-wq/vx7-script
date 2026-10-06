print("Made by eclipwze")
local success, err = pcall(function()
-- ===== ORIGINAL SCRIPT BEGINS =====

local cloneref = cloneref or function(object) return object end

local Players = cloneref(game:GetService("Players"))
local ReplicatedStorage = cloneref(game:GetService("ReplicatedStorage"))
local RunService = cloneref(game:GetService("RunService"))
local UserInputService = cloneref(game:GetService("UserInputService"))
local HttpService = cloneref(game:GetService("HttpService"))
local Stats = cloneref(game:GetService("Stats"))
local Lighting = cloneref(game:GetService("Lighting"))
local Workspace = cloneref(game:GetService("Workspace"))
local TweenService = cloneref(game:GetService("TweenService"))

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

if getgenv and getgenv().StopAura then
    pcall(getgenv().StopAura)
end

-- CONFIGURATION SYSTEM --
local CONFIG_FILE = "exe_code_sniper_config.json"
local savedConfig = {
    codeSniper = true,
    autoSubmit = true,
    submitAfter = 1,
    spamRedeem = true,
    spamCount = 20,
    antiLag = false,
    antiRagdoll = false,
    antiDie = false,
    removeAccessories = false,
    autoBuy = false,
    listenKeybind = "F",
    clearFeedKeybind = "C",
    autoSubmitKeybind = "G",
    antiRagdollKeybind = "R",
    antiLagKeybind = "L",
    removeAccessoriesKeybind = "X",
    autoBuyKeybind = "K",
    autoCodeTyped = true,
}

pcall(function()
    if type(isfile) == "function" and type(readfile) == "function" and isfile(CONFIG_FILE) then
        local decoded = HttpService:JSONDecode(readfile(CONFIG_FILE))
        if type(decoded) == "table" then
            if type(decoded.codeSniper) == "boolean" then savedConfig.codeSniper = decoded.codeSniper end
            if type(decoded.autoSubmit) == "boolean" then savedConfig.autoSubmit = decoded.autoSubmit end
            if type(decoded.submitAfter) == "number" then savedConfig.submitAfter = math.max(1, math.min(10, math.floor(decoded.submitAfter))) end
            if type(decoded.spamRedeem) == "boolean" then savedConfig.spamRedeem = decoded.spamRedeem end
            if type(decoded.spamCount) == "number" then savedConfig.spamCount = math.max(0, math.min(50, math.floor(decoded.spamCount))) end
            if type(decoded.antiLag) == "boolean" then savedConfig.antiLag = decoded.antiLag end
            if type(decoded.antiRagdoll) == "boolean" then savedConfig.antiRagdoll = decoded.antiRagdoll end
            if type(decoded.antiDie) == "boolean" then savedConfig.antiDie = decoded.antiDie end
            if type(decoded.removeAccessories) == "boolean" then savedConfig.removeAccessories = decoded.removeAccessories end
            if type(decoded.autoBuy) == "boolean" then savedConfig.autoBuy = decoded.autoBuy end
            if type(decoded.listenKeybind) == "string" and #decoded.listenKeybind >= 1 then savedConfig.listenKeybind = decoded.listenKeybind:upper() end
            if type(decoded.clearFeedKeybind) == "string" and #decoded.clearFeedKeybind >= 1 then savedConfig.clearFeedKeybind = decoded.clearFeedKeybind:upper() end
            if type(decoded.autoSubmitKeybind) == "string" and #decoded.autoSubmitKeybind >= 1 then savedConfig.autoSubmitKeybind = decoded.autoSubmitKeybind:upper() end
            if type(decoded.antiRagdollKeybind) == "string" and #decoded.antiRagdollKeybind >= 1 then savedConfig.antiRagdollKeybind = decoded.antiRagdollKeybind:upper() end
            if type(decoded.antiLagKeybind) == "string" and #decoded.antiLagKeybind >= 1 then savedConfig.antiLagKeybind = decoded.antiLagKeybind:upper() end
            if type(decoded.removeAccessoriesKeybind) == "string" and #decoded.removeAccessoriesKeybind >= 1 then savedConfig.removeAccessoriesKeybind = decoded.removeAccessoriesKeybind:upper() end
            if type(decoded.autoBuyKeybind) == "string" and #decoded.autoBuyKeybind >= 1 then savedConfig.autoBuyKeybind = decoded.autoBuyKeybind:upper() end
            if type(decoded.autoCodeTyped) == "boolean" then savedConfig.autoCodeTyped = decoded.autoCodeTyped end
        end
    end
end)

local function saveConfig()
    if type(writefile) ~= "function" then return end
    pcall(function()
        writefile(CONFIG_FILE, HttpService:JSONEncode({
            codeSniper = savedConfig.codeSniper,
            autoSubmit = savedConfig.autoSubmit,
            submitAfter = savedConfig.submitAfter,
            spamRedeem = savedConfig.spamRedeem,
            spamCount = savedConfig.spamCount or 20,
            antiLag = savedConfig.antiLag,
            antiRagdoll = savedConfig.antiRagdoll,
            antiDie = savedConfig.antiDie,
            removeAccessories = savedConfig.removeAccessories,
            autoBuy = savedConfig.autoBuy,
            listenKeybind = savedConfig.listenKeybind,
            clearFeedKeybind = savedConfig.clearFeedKeybind,
            autoSubmitKeybind = savedConfig.autoSubmitKeybind,
            antiRagdollKeybind = savedConfig.antiRagdollKeybind,
            antiLagKeybind = savedConfig.antiLagKeybind,
            removeAccessoriesKeybind = savedConfig.removeAccessoriesKeybind,
            autoBuyKeybind = savedConfig.autoBuyKeybind,
            autoCodeTyped = savedConfig.autoCodeTyped,
        }))
    end)
end

-- STATE VARIABLES --
local _enabled = savedConfig.codeSniper
local _seen = {}
local _focused = nil
local _lastBox = nil
local _autoAccept = savedConfig.autoSubmit
local _submitAfter = savedConfig.submitAfter
local _capturedParts = {}
local _lastWatchedBox = nil
local _boxTextConn = nil
local _boxAncestryConn = nil
local _boxVisibilityConns = {}
local _spamRedeem = savedConfig.spamRedeem
local _spamCount = (type(savedConfig.spamCount) == "number" and savedConfig.spamCount) or 20
local _lastNonBlankBoxText = ""
local INSTINCT_CASE_MODE = "EXACT"
local INSTINCT_WORD_COUNT = 1
local _autoCodeTypedEnabled = savedConfig.autoCodeTyped
local _programmaticChange = false
local _manualSubmitDebounce = nil
local _listenKeybind = savedConfig.listenKeybind or "F"
local _listenInputConnection = nil
local _capturingListenKey = false
local snipeKeyBtn = nil
local _clearFeedKeybind = savedConfig.clearFeedKeybind or "C"
local _clearFeedInputConnection = nil
local _capturingClearFeedKey = false
local clearFeedKeyBtn = nil
local _autoSubmitKeybind = savedConfig.autoSubmitKeybind or "G"
local _antiRagdollKeybind = savedConfig.antiRagdollKeybind or "R"
local _antiLagKeybind = savedConfig.antiLagKeybind or "L"
local _removeAccessoriesKeybind = savedConfig.removeAccessoriesKeybind or "X"
local _featureKeybindConn = nil
local _capturingFeatureKey = nil -- string id while capturing
local _keybindLabels = {} -- id -> TextButton in settings
local _antiLagEnabled = savedConfig.antiLag
local _antiLagDescendantConn = nil
local _removeAccessoriesEnabled = savedConfig.removeAccessories
local _accessoryConnection = nil
local _antiRagdollEnabled = savedConfig.antiRagdoll
local _ragdollConnection = nil
local _ragdollCooldown = 0

-- ANTI DIE STATE --
local _antiDieEnabled = savedConfig.antiDie
local _antiDieHeartConn = nil
local _antiDieDeathConns = {}
local _antiDieCharAddedConn = nil

-- ============================================================
-- DZ AUTO BUY BACKEND (integrated)
-- ============================================================
local _autoBuyEnabled = savedConfig.autoBuy
local _autoBuyActive = false
local _autoBuyRange = 17
local _autoBuyKeybind = savedConfig.autoBuyKeybind or "K"
local _autoBuyLockedTarget = nil
local _autoBuyBodyPos = nil
local _autoBuyCarpetConn = nil
local _autoBuyRingPart = nil
local _autoBuyPurchaseRemote = nil
local _autoBuyConveyorCache = {}
local _autoBuyBuyLoop = nil
local _autoBuyScanLoop = nil
local _autoBuyRingUpdateConn = nil
local HOVER_HEIGHT = 5
local BUY_INTERVAL = 0.08

local function autoBuyCreateRing()
    if _autoBuyRingPart then _autoBuyRingPart:Destroy() end
    local r = Instance.new("Part")
    r.Name = "DZAutoBuyRing"
    r.Shape = Enum.PartType.Cylinder
    r.Anchored = true
    r.CanCollide = false
    r.CanTouch = false
    r.CanQuery = false
    r.CastShadow = false
    r.Material = Enum.Material.Neon
    r.Transparency = 0.5
    r.Color = Color3.fromRGB(255, 255, 255)
    r.Size = Vector3.new(0.5, _autoBuyRange * 2, _autoBuyRange * 2)
    r.Parent = Workspace
    _autoBuyRingPart = r
end

local function autoBuyDestroyRing()
    if _autoBuyRingPart then _autoBuyRingPart:Destroy(); _autoBuyRingPart = nil end
end

local function autoBuyEquipCarpet()
    local char = player.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return end
    local toolName = "Flying Carpet"
    if not char:FindFirstChild(toolName) then
        local tool = player.Backpack:FindFirstChild(toolName)
        if tool then hum:EquipTool(tool) end
    end
end

local function autoBuyStartCarpetLock()
    if _autoBuyCarpetConn then _autoBuyCarpetConn:Disconnect() end
    _autoBuyCarpetConn = RunService.Heartbeat:Connect(function()
        if _autoBuyActive then autoBuyEquipCarpet() end
    end)
    autoBuyEquipCarpet()
end

local function autoBuyStopCarpetLock()
    if _autoBuyCarpetConn then _autoBuyCarpetConn:Disconnect(); _autoBuyCarpetConn = nil end
end

local function autoBuyEnsureBodyPos(hrp)
    if _autoBuyBodyPos and _autoBuyBodyPos.Parent == hrp then return _autoBuyBodyPos end
    if _autoBuyBodyPos then _autoBuyBodyPos:Destroy() end
    local bp = Instance.new("BodyPosition", hrp)
    bp.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    bp.P = 20000
    bp.D = 1000
    bp.Position = hrp.Position
    _autoBuyBodyPos = bp
    return bp
end

local function autoBuyDestroyBodyPos()
    if _autoBuyBodyPos then _autoBuyBodyPos:Destroy(); _autoBuyBodyPos = nil end
end

local function autoBuyResolveRemote()
    if _autoBuyPurchaseRemote and _autoBuyPurchaseRemote.Parent then return _autoBuyPurchaseRemote end
    pcall(function()
        local net = ReplicatedStorage:FindFirstChild("Packages") and ReplicatedStorage.Packages:FindFirstChild("Net")
        if net then
            for _, v in ipairs(net:GetChildren()) do
                local nl = (v.Name or ""):lower()
                if nl:find("buy") or nl:find("purchase") or nl:find("acquire") then
                    _autoBuyPurchaseRemote = v; return
                end
            end
        end
    end)
    return _autoBuyPurchaseRemote
end

local function autoBuyFirePurchase(prompt)
    if not prompt or not prompt.Parent or not prompt.Enabled then return end
    pcall(function() if fireproximityprompt then fireproximityprompt(prompt) end end)
    task.spawn(function()
        local remote = autoBuyResolveRemote()
        if remote then
            pcall(function()
                if remote:IsA("RemoteFunction") then
                    remote:InvokeServer(prompt.Parent)
                elseif remote:IsA("RemoteEvent") then
                    remote:FireServer(prompt.Parent)
                end
            end)
        end
    end)
end

local function autoBuyScanConveyor()
    local results = {}
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("ProximityPrompt") and obj.Enabled then
            local action = (obj.ActionText or ""):lower()
            if action:find("purchase") or action:find("buy") or action:find("comprar") then
                local part = obj.Parent
                if not part then continue end
                local realPart = part:IsA("Attachment") and part.Parent or part
                if not (realPart and realPart:IsA("BasePart")) then continue end
                local model = nil
                local cur = realPart
                for _ = 1, 6 do
                    if cur and cur:IsA("Model") then model = cur; break end
                    cur = cur and cur.Parent
                end
                local name = "Brainrot"
                if model then
                    for _, bb in ipairs(model:GetDescendants()) do
                        if bb:IsA("BillboardGui") then
                            for _, lbl in ipairs(bb:GetDescendants()) do
                                if lbl:IsA("TextLabel") and lbl.Text and lbl.Text ~= "" then
                                    local t = lbl.Text:gsub("<[^>]+>", ""):match("^%s*(.-)%s*$")
                                    if t and #t > 1 and not t:match("^%$") and not t:match("/s$") and not t:match("^[%d%.]+") then
                                        name = t; break
                                    end
                                end
                            end
                        end
                    end
                end
                table.insert(results, { prompt = obj, part = realPart, model = model, name = name })
            end
        end
    end
    return results
end

local function autoBuyRefreshConveyor()
    local ok, found = pcall(autoBuyScanConveyor)
    if ok then _autoBuyConveyorCache = found end
end

local function autoBuyUpdate()
    if not _autoBuyActive then
        if _autoBuyLockedTarget then _autoBuyLockedTarget = nil end
        autoBuyDestroyBodyPos()
        autoBuyStopCarpetLock()
        return
    end
    local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    local radius = _autoBuyRange
    local best = nil
    local bestDist = math.huge
    for _, entry in ipairs(_autoBuyConveyorCache) do
        if entry.prompt and entry.prompt.Parent and entry.prompt.Enabled and entry.part and entry.part.Parent then
            local dist = (hrp.Position - entry.part.Position).Magnitude
            if dist <= radius and dist < bestDist then
                bestDist = dist
                best = entry
            end
        end
    end
    if best then
        if not _autoBuyLockedTarget or _autoBuyLockedTarget.prompt ~= best.prompt then
            _autoBuyLockedTarget = best
        end
        local targetPos = best.part.Position + Vector3.new(0, HOVER_HEIGHT, 0)
        local bp = autoBuyEnsureBodyPos(hrp)
        if bp then bp.Position = targetPos end
        autoBuyFirePurchase(best.prompt)
    else
        if _autoBuyLockedTarget then
            _autoBuyLockedTarget = nil
            autoBuyDestroyBodyPos()
        end
    end
end

local function autoBuyStart()
    if _autoBuyActive then return end
    _autoBuyActive = true
    savedConfig.autoBuy = true
    saveConfig()
    autoBuyCreateRing()
    autoBuyStartCarpetLock()
    autoBuyRefreshConveyor()
    if not _autoBuyBuyLoop then
        _autoBuyBuyLoop = task.spawn(function()
            while true do
                task.wait(BUY_INTERVAL)
                if _autoBuyActive then pcall(autoBuyUpdate) end
            end
        end)
    end
    if not _autoBuyScanLoop then
        _autoBuyScanLoop = task.spawn(function()
            while true do
                task.wait(0.5)
                if _autoBuyActive then pcall(autoBuyRefreshConveyor) end
            end
        end)
    end
    if not _autoBuyRingUpdateConn then
        _autoBuyRingUpdateConn = RunService.Heartbeat:Connect(function()
            if not _autoBuyActive then return end
            local char = player.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            if hrp and _autoBuyRingPart then
                _autoBuyRingPart.CFrame = hrp.CFrame * CFrame.Angles(0, 0, math.rad(90)) + Vector3.new(0, -2.5, 0)
                local r = _autoBuyRange
                if _autoBuyRingPart.Size.Y ~= r * 2 then
                    _autoBuyRingPart.Size = Vector3.new(0.5, r * 2, r * 2)
                end
            end
        end)
    end
end

local function autoBuyStop()
    if not _autoBuyActive then return end
    _autoBuyActive = false
    savedConfig.autoBuy = false
    saveConfig()
    autoBuyDestroyRing()
    autoBuyStopCarpetLock()
    autoBuyDestroyBodyPos()
    _autoBuyLockedTarget = nil
    if _autoBuyBuyLoop then task.cancel(_autoBuyBuyLoop); _autoBuyBuyLoop = nil end
    if _autoBuyScanLoop then task.cancel(_autoBuyScanLoop); _autoBuyScanLoop = nil end
    if _autoBuyRingUpdateConn then _autoBuyRingUpdateConn:Disconnect(); _autoBuyRingUpdateConn = nil end
end

local function toggleAutoBuy()
    if _autoBuyActive then autoBuyStop() else autoBuyStart() end
end

player.CharacterAdded:Connect(function()
    if _autoBuyActive then
        task.wait(0.5)
        if _autoBuyActive then
            autoBuyStartCarpetLock()
            autoBuyCreateRing()
        end
    end
end)
-- ============================================================
-- END OF DZ AUTO BUY INTEGRATION
-- ============================================================

local getupvalues = (debug and debug.getupvalues) or getupvalues
local getconns = getconnections or (debug and debug.getconnections)
local setupv = (debug and debug.setupvalue) or setupvalue

local setStatus, flashCode, appendToBox
local clearInstinctCapture
local _lastStatusMsg = nil

-- ============================================================
-- ANTIâ€‘LAG LOGIC
-- ============================================================
local function processDescendant(obj)
    if obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Beam") or obj:IsA("Fire") then
        obj.Enabled = false
    end
    if obj:IsA("Decal") or obj:IsA("Texture") then
        obj.Transparency = 1
    end
    if obj:IsA("BasePart") then
        obj.Material = Enum.Material.Plastic
        obj.Reflectance = 0
        obj.CastShadow = false
    end
    if _removeAccessoriesEnabled and (obj:IsA("Accessory") or obj:IsA("Hat")) then
        obj:Destroy()
    end
end

local function optimizeLighting()
    Lighting.GlobalShadows = false
    Lighting.FogEnd = 9000000488
    Lighting.Brightness = 1
    Lighting.EnvironmentDiffuseScale = 0
    Lighting.EnvironmentSpecularScale = 0
    for _, effect in pairs(Lighting:GetChildren()) do
        if effect:IsA("BlurEffect") or effect:IsA("SunRaysEffect") or effect:IsA("ColorCorrectionEffect") or effect:IsA("BloomEffect") or effect:IsA("DepthOfFieldEffect") then
            effect.Enabled = false
        end
    end
    for _, obj in pairs(Workspace:GetDescendants()) do
        processDescendant(obj)
    end
end

local function removeAllAccessories()
    for _, plr in pairs(Players:GetPlayers()) do
        if plr.Character then
            for _, obj in ipairs(plr.Character:GetDescendants()) do
                if obj:IsA("Accessory") or obj:IsA("Hat") then
                    obj:Destroy()
                end
            end
        end
    end
end

local function startAntiLag()
    if _antiLagEnabled then return end
    _antiLagEnabled = true
    settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
    optimizeLighting()
    if _antiLagDescendantConn then _antiLagDescendantConn:Disconnect() end
    _antiLagDescendantConn = Workspace.DescendantAdded:Connect(processDescendant)
    if _removeAccessoriesEnabled then
        removeAllAccessories()
        if not _accessoryConnection then
            _accessoryConnection = Players.PlayerAdded:Connect(function(plr)
                plr.CharacterAdded:Connect(function(char)
                    task.wait(0.5)
                    if _removeAccessoriesEnabled then
                        for _, obj in ipairs(char:GetDescendants()) do
                            if obj:IsA("Accessory") or obj:IsA("Hat") then obj:Destroy() end
                        end
                    end
                end)
            end)
        end
    end
end

local function stopAntiLag()
    _antiLagEnabled = false
    if _antiLagDescendantConn then _antiLagDescendantConn:Disconnect(); _antiLagDescendantConn = nil end
end

local function startRemoveAccessories()
    if _removeAccessoriesEnabled then return end
    _removeAccessoriesEnabled = true
    removeAllAccessories()
    if not _accessoryConnection then
        _accessoryConnection = Players.PlayerAdded:Connect(function(plr)
            plr.CharacterAdded:Connect(function(char)
                task.wait(0.5)
                if _removeAccessoriesEnabled then
                    for _, obj in ipairs(char:GetDescendants()) do
                        if obj:IsA("Accessory") or obj:IsA("Hat") then obj:Destroy() end
                    end
                end
            end)
        end)
    end
    if not _antiLagEnabled then
        if _antiLagDescendantConn then _antiLagDescendantConn:Disconnect() end
        _antiLagDescendantConn = Workspace.DescendantAdded:Connect(processDescendant)
    end
end

local function stopRemoveAccessories()
    _removeAccessoriesEnabled = false
    if _accessoryConnection then _accessoryConnection:Disconnect(); _accessoryConnection = nil end
    if not _antiLagEnabled and _antiLagDescendantConn then
        _antiLagDescendantConn:Disconnect(); _antiLagDescendantConn = nil
    end
end

-- ============================================================
-- ANTIâ€‘RAGDOLL LOGIC
-- ============================================================
local function forceReset()
    local char = player.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    local root = char:FindFirstChild("HumanoidRootPart")
    if not hum or not root or hum.Health <= 0 then return end
    pcall(function()
        hum:ChangeState(Enum.HumanoidStateType.GettingUp)
        root.Velocity = Vector3.zero
        root.RotVelocity = Vector3.zero
        root.AssemblyLinearVelocity = Vector3.zero
        root.AssemblyAngularVelocity = Vector3.zero
        for _, obj in ipairs(char:GetDescendants()) do
            if obj:IsA("Motor6D") then obj.Enabled = true end
            if obj:IsA("Constraint") then obj.Enabled = true end
        end
        workspace.CurrentCamera.CameraSubject = hum
        local PM = player.PlayerScripts:FindFirstChild("PlayerModule")
        if PM then
            local CM = require(PM:FindFirstChild("ControlModule"))
            if CM then CM:Enable() end
        end
        hum.AutoRotate = true
        hum.PlatformStand = false
        hum.Sit = false
    end)
end

local function startAntiRagdoll()
    if _ragdollConnection then return end
    _antiRagdollEnabled = true
    _ragdollConnection = RunService.Heartbeat:Connect(function()
        if not _antiRagdollEnabled then return end
        local char = player.Character
        if not char then return end
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not hum or hum.Health <= 0 then return end
        local state = hum:GetState()
        local isRagdolled = (state == Enum.HumanoidStateType.Physics or state == Enum.HumanoidStateType.Ragdoll or state == Enum.HumanoidStateType.FallingDown)
        if isRagdolled then
            local now = tick()
            if now - _ragdollCooldown > 0.15 then
                _ragdollCooldown = now
                forceReset()
            end
        end
    end)
end

local function stopAntiRagdoll()
    _antiRagdollEnabled = false
    if _ragdollConnection then _ragdollConnection:Disconnect(); _ragdollConnection = nil end
end

-- ============================================================
-- ANTI DIE LOGIC
-- ============================================================
local function _antiDieProtectChar(character)
    if not character then return end
    local hum = character:WaitForChild("Humanoid", 5)
    if not hum then return end

    pcall(function()
        hum.MaxHealth = math.huge
        hum.Health = math.huge
    end)

    local sc = hum.StateChanged:Connect(function(_, new)
        if not _antiDieEnabled then return end
        if new == Enum.HumanoidStateType.Dead then
            pcall(function()
                hum.Health = math.huge
                hum:SetStateEnabled(Enum.HumanoidStateType.Dead, false)
            end)
        end
    end)
    table.insert(_antiDieDeathConns, sc)

    pcall(function()
        hum:SetStateEnabled(Enum.HumanoidStateType.Dead, false)
    end)

    local hc = hum:GetPropertyChangedSignal("Health"):Connect(function()
        if not _antiDieEnabled then return end
        if hum.Health < hum.MaxHealth then
            pcall(function() hum.Health = math.huge end)
        end
    end)
    table.insert(_antiDieDeathConns, hc)

    if _antiDieHeartConn then _antiDieHeartConn:Disconnect() end
    _antiDieHeartConn = RunService.Heartbeat:Connect(function()
        if not _antiDieEnabled then return end
        if hum and hum.Parent and hum.Health < hum.MaxHealth then
            pcall(function() hum.Health = math.huge end)
        end
    end)
end

local function startAntiDie()
    for _, c in ipairs(_antiDieDeathConns) do
        pcall(function() c:Disconnect() end)
    end
    _antiDieDeathConns = {}
    if _antiDieHeartConn then _antiDieHeartConn:Disconnect(); _antiDieHeartConn = nil end
    if _antiDieCharAddedConn then _antiDieCharAddedConn:Disconnect(); _antiDieCharAddedConn = nil end

    _antiDieEnabled = true
    _antiDieProtectChar(player.Character)

    _antiDieCharAddedConn = player.CharacterAdded:Connect(function(c)
        if not _antiDieEnabled then return end
        task.wait(0.1)
        for _, c2 in ipairs(_antiDieDeathConns) do
            pcall(function() c2:Disconnect() end)
        end
        _antiDieDeathConns = {}
        _antiDieProtectChar(c)
    end)
end

local function stopAntiDie()
    _antiDieEnabled = false
    for _, c in ipairs(_antiDieDeathConns) do
        pcall(function() c:Disconnect() end)
    end
    _antiDieDeathConns = {}
    if _antiDieHeartConn then _antiDieHeartConn:Disconnect(); _antiDieHeartConn = nil end
    if _antiDieCharAddedConn then _antiDieCharAddedConn:Disconnect(); _antiDieCharAddedConn = nil end

    local char = player.Character
    if char then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then
            pcall(function()
                hum:SetStateEnabled(Enum.HumanoidStateType.Dead, true)
                hum.MaxHealth = 100
                hum.Health = 100
            end)
        end
    end
end

-- ============================================================
-- UTILITY & REDEEM LOGIC
-- ============================================================
local function isOurGui(instance)
    local p = instance
    for _ = 1, 10 do
        if not p then break end
        if p.Name == "ExeCodeSniperUI" or p.Name == "SourcesHubRedeemerGui" or p.Name == "ExeCodeSniperSettingsUI" then
            return true
        end
        p = p.Parent
    end
    return false
end

local function isVisibleChain(inst)
    local current = inst
    while current do
        if current:IsA("GuiObject") and not current.Visible then return false end
        if current:IsA("ScreenGui") then return current.Enabled end
        current = current.Parent
    end
    return true
end

local function findAllTextBoxes(pg)
    local boxes = {}
    for _, gui in ipairs(pg:GetChildren()) do
        if gui:IsA("ScreenGui") and gui.Enabled and not isOurGui(gui) then
            for _, d in ipairs(gui:GetDescendants()) do
                if d:IsA("TextBox") and not isOurGui(d) then
                    boxes[#boxes+1] = d
                end
            end
        end
    end
    return boxes
end

local function findCodeButtons(pg)
    local btns = {}
    for _, gui in ipairs(pg:GetChildren()) do
        if gui:IsA("ScreenGui") and gui.Enabled and not isOurGui(gui) then
            for _, d in ipairs(gui:GetDescendants()) do
                if (d:IsA("TextButton") or d:IsA("ImageButton")) and not isOurGui(d) then
                    local n = d.Name:lower()
                    local pn = (d.Parent and d.Parent.Name or ""):lower()
                    if (n:find("code") or n:find("redeem") or pn:find("code") or pn:find("redeem")) and isVisibleChain(d) then
                        btns[#btns+1] = d
                    end
                end
            end
        end
    end
    return btns
end

local function clickButton(btn)
    if not btn then return false end
    local methods = {}
    methods[#methods+1] = function() btn.MouseButton1Click:Fire() end
    methods[#methods+1] = function() btn.Activated:Fire() end
    if typeof(firesignal) == "function" then
        methods[#methods+1] = function() firesignal(btn.MouseButton1Click) end
        methods[#methods+1] = function() firesignal(btn.Activated) end
    end
    if typeof(getconns) == "function" then
        methods[#methods+1] = function()
            local ok, cs = pcall(getconns, btn.MouseButton1Click)
            if ok and type(cs) == "table" then
                for _, c in ipairs(cs) do pcall(function() c:Fire() end) end
            end
            local ok2, cs2 = pcall(getconns, btn.Activated)
            if ok2 and type(cs2) == "table" then
                for _, c in ipairs(cs2) do pcall(function() c:Fire() end) end
            end
        end
    end
    if typeof(fireclick) == "function" then
        methods[#methods+1] = function() fireclick(btn) end
    end
    local anyOk = false
    for _, fn in ipairs(methods) do
        local ok = pcall(fn)
        anyOk = anyOk or ok
    end
    return anyOk
end

local function fireBoxFocusLost(box)
    if not box then return false end
    local anyFired = false
    if typeof(firesignal) == "function" then
        local ok = pcall(firesignal, box.FocusLost, true)
        anyFired = anyFired or ok
    end
    if typeof(getconns) == "function" then
        local ok, cs = pcall(getconns, box.FocusLost)
        if ok and type(cs) == "table" then
            for _, c in ipairs(cs) do
                local fn
                pcall(function() fn = c.Function end)
                if fn and typeof(getupvalues) == "function" and typeof(setupv) == "function" then
                    local uOk, ups = pcall(getupvalues, fn)
                    if uOk and type(ups) == "table" then
                        for i, v in pairs(ups) do
                            if type(v) == "boolean" and v == true then
                                pcall(setupv, fn, i, false)
                            end
                        end
                    end
                end
                local fOk = pcall(function() if c.Enabled ~= false then c:Fire(true) end end)
                anyFired = anyFired or fOk
            end
        end
    end
    return anyFired
end

-- NOTE: All spam redeem loops and auto-submit delays below use 0.05s.
local SPAM_DELAY = 0.05
local SUBMIT_DELAY = 0.05

local function typeAndSubmitCode(code)
    local pg = playerGui or player:FindFirstChildOfClass("PlayerGui")
    if not pg then return false, "no PlayerGui" end
    local codesGui = pg:FindFirstChild("Codes")
    if codesGui then
        if codesGui:IsA("ScreenGui") then codesGui.Enabled = true end
        local codesFrame = codesGui:FindFirstChild("Codes") or codesGui
        if codesFrame then
            if codesFrame:IsA("GuiObject") then codesFrame.Visible = true end
            local cur = codesFrame
            while cur and cur ~= codesGui do
                if cur:IsA("GuiObject") then cur.Visible = true end
                cur = cur.Parent
            end
            local box = nil
            for _, d in ipairs(codesFrame:GetDescendants()) do
                if d:IsA("TextBox") and not isOurGui(d) then box = d; break end
            end
            local submitBtn = nil
            for _, d in ipairs(codesFrame:GetDescendants()) do
                if (d:IsA("TextButton") or d:IsA("ImageButton")) and not isOurGui(d) then
                    local n = d.Name:lower()
                    local txt = ""
                    pcall(function() txt = d.Text:lower() end)
                    if n:find("submit") or txt:find("submit") or n:find("redeem") or txt:find("redeem") or n:find("claim") or txt:find("confirm") or n:find("enter") then
                        submitBtn = d; break
                    end
                end
            end
            if not submitBtn then
                for _, d in ipairs(codesFrame:GetDescendants()) do
                    if (d:IsA("TextButton") or d:IsA("ImageButton")) and not isOurGui(d) then
                        local n = d.Name:lower()
                        if not n:find("close") and not n:find("x") and not n:find("toggle") then
                            submitBtn = d; break
                        end
                    end
                end
            end
            if box then
                pcall(function() box.Text = code end)
                if submitBtn then
                    local times = (_spamRedeem and math.max(1, tonumber(_spamCount) or 20)) or 1
                    for i = 1, times do
                        clickButton(submitBtn)
                        if times > 1 then task.wait(SPAM_DELAY) end
                    end
                end
                fireBoxFocusLost(box)
                return true, "submitted via PlayerGui.Codes"
            end
        end
    end

    local btns = findCodeButtons(pg)
    for _, btn in ipairs(btns) do
        clickButton(btn)
        task.wait(0)
    end

    local box = nil
    local deadline = tick() + 2
    while tick() < deadline do
        local allBoxes = findAllTextBoxes(pg)
        for _, d in ipairs(allBoxes) do
            if isVisibleChain(d) then
                local n = d.Name:lower()
                local pn = (d.Parent and d.Parent.Name or ""):lower()
                if n:find("code") or pn:find("code") or n:find("redeem") or pn:find("redeem") or n:find("input") or pn:find("textbox") or n:find("enter") then
                    box = d; break
                end
            end
        end
        if not box then
            for _, d in ipairs(allBoxes) do
                if isVisibleChain(d) then box = d; break end
            end
        end
        if box then break end
        task.wait()
    end
    if not box then return false, "no codebox visible" end

    pcall(function() box.Text = code end)

    local redeemBtn = nil
    local searchNames = {"submit","redeem","claim","confirm","enter","send","apply","ok","use","go","check"}
    local p = box.Parent
    for _ = 1, 8 do
        if not p then break end
        for _, d in ipairs(p:GetDescendants()) do
            if (d:IsA("TextButton") or d:IsA("ImageButton")) and not isOurGui(d) and d ~= box then
                local n = d.Name:lower()
                local txt = ""
                pcall(function() txt = d.Text:lower() end)
                for _, sn in ipairs(searchNames) do
                    if n:find(sn) or txt:find(sn) then
                        if isVisibleChain(d) then redeemBtn = d; break end
                    end
                end
                if redeemBtn then break end
            end
        end
        if redeemBtn then break end
        p = p.Parent
    end
    if redeemBtn then
        local times = (_spamRedeem and math.max(1, tonumber(_spamCount) or 20)) or 1
        for i = 1, times do
            clickButton(redeemBtn)
            if times > 1 then task.wait(SPAM_DELAY) end
        end
    end
    fireBoxFocusLost(box)
    return true, "submitted via dynamic search"
end

local function instinctCodeBox()
    local pg = playerGui
    local allBoxes = findAllTextBoxes(pg)
    for _, box in ipairs(allBoxes) do
        if isVisibleChain(box) then return box end
    end
    return nil
end

-- ============================================================
-- STYLING & HELPER UTILITIES (BLACK / WHITE / GRAY)
-- ============================================================
local COLORS = {
    Window      = Color3.fromRGB(12, 12, 16),
    Row         = Color3.fromRGB(22, 22, 28),
    Control     = Color3.fromRGB(36, 36, 42),
    Log         = Color3.fromRGB(10, 10, 14),
    Gray        = Color3.fromRGB(18, 18, 22),
    Box         = Color3.fromRGB(20, 20, 26),
    Border      = Color3.fromRGB(70, 70, 80),
    White       = Color3.fromRGB(255, 255, 255),
    Text        = Color3.fromRGB(235, 235, 240),
    Dim         = Color3.fromRGB(140, 140, 150),
    Accent      = Color3.fromRGB(255, 255, 255),
    Blue        = Color3.fromRGB(245, 245, 250),
    VeryLightBlue = Color3.fromRGB(220, 220, 230),
    LightBlue   = Color3.fromRGB(190, 190, 200),
    Green       = Color3.fromRGB(90, 220, 130),
    Red         = Color3.fromRGB(220, 90, 90),
    Purple      = Color3.fromRGB(200, 200, 210),
    OnBtn       = Color3.fromRGB(255, 255, 255),
    OffBtn      = Color3.fromRGB(32, 32, 38),
}

local function addCorner(parent, radius)
    local value = Instance.new("UICorner")
    value.CornerRadius = UDim.new(0, radius)
    value.Parent = parent
    return value
end

local function addStroke(parent, color, thickness, transparency)
    local value = Instance.new("UIStroke")
    value.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    value.Color = color
    value.Thickness = thickness or 1
    value.Transparency = transparency or 0
    value.Parent = parent
    return value
end

local function makeLabel(parent, name, text, size, position, textSize, color, font)
    local label = Instance.new("TextLabel")
    label.Name = name
    label.Size = size
    label.Position = position
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextSize = textSize
    label.TextColor3 = color
    label.Font = font or Enum.Font.GothamMedium
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.TextYAlignment = Enum.TextYAlignment.Center
    label.Parent = parent
    return label
end

local function applyToggleStyle(btn, stroke, state)
    btn.Text = state and "ON" or "OFF"
    btn.BackgroundColor3 = state and (COLORS.OnBtn or COLORS.White) or (COLORS.OffBtn or COLORS.Control)
    btn.TextColor3 = state and Color3.fromRGB(20, 20, 24) or COLORS.Dim
    if stroke then stroke.Transparency = state and 0.55 or 0.85 end
end

local function setClipboardSafe(text)
    if not text or text == "" then return end
    if setclipboard then pcall(function() setclipboard(text) end)
    elseif toclipboard then pcall(function() toclipboard(text) end) end
end

-- ============================================================
-- CUSTOM FONT (LuckiestGuy) â€” only applied to OUR gui
-- ============================================================
local CustomFont
do
    local ok, font = pcall(function()
        return Font.new("rbxasset://fonts/families/LuckiestGuy.json")
    end)
    if ok and font then CustomFont = font end
end

local function applyCustomFont(root)
    if not CustomFont or not root then return end
    local function applyOne(obj)
        if obj:IsA("TextLabel") or obj:IsA("TextButton") or obj:IsA("TextBox") then
            pcall(function() obj.FontFace = CustomFont end)
        end
    end
    applyOne(root)
    for _, obj in ipairs(root:GetDescendants()) do
        applyOne(obj)
    end
end

local function watchAndApplyFont(root)
    if not CustomFont or not root then return end
    pcall(function()
        root.DescendantAdded:Connect(function(obj)
            if obj:IsA("TextLabel") or obj:IsA("TextButton") or obj:IsA("TextBox") then
                pcall(function() obj.FontFace = CustomFont end)
            end
        end)
    end)
end

-- ============================================================
-- STATIC TRANSPARENCY (~45% so background image shows through)
-- ============================================================
local UI_TRANSPARENCY = 0.45
local _currentlyFaded = false

local function registerFade(inst, prop, orig)
    -- no-op (idle fade removed)
end

local function registerToggleStroke(btn, stroke)
    -- no-op
end

local function applyFade(_faded)
    -- no-op
end

local function resetIdleTimer()
    -- no-op
end

-- CLEANUP OLD GUIS
pcall(function()
    for _, name in ipairs({"ExeCodeSniperUI", "ExeCodeSniperSettingsUI", "InstinctCodeSniperUI", "InstinctCodeSniperSettingsUI", "AutoTypeCodesUI", "ACEPaste"}) do
        local previous = game.CoreGui:FindFirstChild(name)
        if previous then previous:Destroy() end
    end
end)
for _, name in ipairs({"ExeCodeSniperUI", "ExeCodeSniperSettingsUI", "InstinctCodeSniperUI", "InstinctCodeSniperSettingsUI", "AutoTypeCodesUI", "ACEPaste"}) do
    local previous = playerGui:FindFirstChild(name)
    if previous then previous:Destroy() end
end

-- ============================================================
-- MAIN GUI CREATION (Weekly Sniper style)
-- ============================================================
local FULL_HEIGHT = 480
local HEADER_HEIGHT = 52

local GUI = Instance.new("ScreenGui")
GUI.Name = "ExeCodeSniperUI"
GUI.ResetOnSpawn = false
GUI.IgnoreGuiInset = true
GUI.DisplayOrder = 999
if not pcall(function() GUI.Parent = game.CoreGui end) then
    GUI.Parent = playerGui
end

local Window = Instance.new("Frame")
Window.Name = "Window"
Window.Size = UDim2.fromOffset(300, FULL_HEIGHT)
Window.AnchorPoint = Vector2.new(1, 0)
Window.Position = UDim2.new(1, -10, 0, 12)
Window.BackgroundColor3 = COLORS.Window
Window.BackgroundTransparency = 0.45
Window.BorderSizePixel = 0
Window.ClipsDescendants = true
Window.Parent = GUI
addCorner(Window, 16)
addStroke(Window, COLORS.Border, 1, 0.45)

-- BACKGROUND IMAGE
local BACKGROUND_IMAGES = {
    "rbxassetid://140028775780827",
    "rbxassetid://131295589185120",
    "rbxassetid://85269167779930",
    "rbxassetid://104186191673998",
}
math.randomseed(os.time() + math.floor(tick() * 1000) % 100000)
local chosenBg = BACKGROUND_IMAGES[math.random(1, #BACKGROUND_IMAGES)]

local BackgroundImage = Instance.new("ImageLabel")
BackgroundImage.Name = "BackgroundImage"
BackgroundImage.Size = UDim2.new(1, 0, 1, 0)
BackgroundImage.BackgroundTransparency = 1
BackgroundImage.Image = chosenBg
BackgroundImage.ImageColor3 = Color3.fromRGB(140, 140, 150)
BackgroundImage.ImageTransparency = 0.15
BackgroundImage.ScaleType = Enum.ScaleType.Crop
BackgroundImage.ZIndex = 1
BackgroundImage.Parent = Window
addCorner(BackgroundImage, 16)

local DimOverlay = Instance.new("Frame")
DimOverlay.Size = UDim2.new(1, 0, 1, 0)
DimOverlay.BackgroundColor3 = Color3.fromRGB(8, 8, 12)
DimOverlay.BackgroundTransparency = 0.55
DimOverlay.BorderSizePixel = 0
DimOverlay.ZIndex = 2
DimOverlay.Parent = Window
addCorner(DimOverlay, 16)

local InterfaceScale = Instance.new("UIScale")
InterfaceScale.Name = "InterfaceScale"
InterfaceScale.Scale = 0.95
InterfaceScale.Parent = Window

local viewportConnection
local function updateInterfaceScale()
    local camera = workspace.CurrentCamera
    if not camera then InterfaceScale.Scale = 0.95; return end
    local viewport = camera.ViewportSize
    local fitScale = math.min((viewport.X - 16) / 300, (viewport.Y - 16) / FULL_HEIGHT)
    if UserInputService.TouchEnabled then
        InterfaceScale.Scale = math.max(0.5, math.min(0.85, fitScale))
    else
        InterfaceScale.Scale = 0.95
    end
end
local function watchViewport()
    if viewportConnection then viewportConnection:Disconnect(); viewportConnection = nil end
    local camera = workspace.CurrentCamera
    if camera then
        viewportConnection = camera:GetPropertyChangedSignal("ViewportSize"):Connect(updateInterfaceScale)
    end
    updateInterfaceScale()
end
workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(watchViewport)
watchViewport()

-- HEADER
local Header = Instance.new("Frame")
Header.Name = "Header"
Header.Size = UDim2.new(1, 0, 0, HEADER_HEIGHT)
Header.BackgroundTransparency = 1
Header.Active = true
Header.ZIndex = 5
Header.Parent = Window

local Title = makeLabel(Header, "Title", "Exe Sniper", UDim2.fromOffset(160, 22), UDim2.fromOffset(14, 4), 17, COLORS.White, Enum.Font.GothamBold)
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.ZIndex = 6

local DiscordFooter = makeLabel(Header, "DiscordFooter", "discord.gg/ZvERp8sHq", UDim2.fromOffset(180, 16), UDim2.fromOffset(14, 28), 11, Color3.fromRGB(114, 137, 218), Enum.Font.GothamMedium)
DiscordFooter.TextXAlignment = Enum.TextXAlignment.Left
DiscordFooter.ZIndex = 6

local GearButton = Instance.new("TextButton")
GearButton.Name = "GearButton"
GearButton.Size = UDim2.fromOffset(72, 24)
GearButton.Position = UDim2.new(1, -104, 0, 14)
GearButton.BackgroundColor3 = COLORS.Control
GearButton.BackgroundTransparency = 0.45
GearButton.BorderSizePixel = 0
GearButton.AutoButtonColor = false
GearButton.Text = "Keybinds"
GearButton.TextSize = 12
GearButton.TextColor3 = COLORS.White
GearButton.Font = Enum.Font.GothamBold
GearButton.ZIndex = 6
GearButton.Parent = Header
addCorner(GearButton, 8)
addStroke(GearButton, COLORS.Border, 1, 0.5)

local MinusButton = Instance.new("TextButton")
MinusButton.Name = "MinusButton"
MinusButton.Size = UDim2.fromOffset(24, 24)
MinusButton.Position = UDim2.new(1, -28, 0, 14)
MinusButton.BackgroundColor3 = COLORS.Control
MinusButton.BackgroundTransparency = 0.45
MinusButton.BorderSizePixel = 0
MinusButton.AutoButtonColor = false
MinusButton.Text = "-"
MinusButton.TextSize = 16
MinusButton.TextColor3 = COLORS.White
MinusButton.Font = Enum.Font.GothamBold
MinusButton.ZIndex = 6
MinusButton.Parent = Header
addCorner(MinusButton, 8)

local function updateStatusDot() end

local _minimized = false
local function setMinimized(state)
    _minimized = state
    Window.Size = UDim2.fromOffset(300, state and HEADER_HEIGHT or FULL_HEIGHT)
end
MinusButton.Activated:Connect(function() setMinimized(not _minimized) end)

-- ============================================================
-- STATUS / FEED BOX
-- ============================================================
local Console, ConsoleOutput, AnswerScroll, updateConsoleCanvas

local CONSOLE_COLORS = {
    Dim   = "rgb(140,140,150)",
    Amber = "rgb(230,230,235)",
    Green = "rgb(90,220,130)",
    Red   = "rgb(220,90,90)",
    Cyan  = "rgb(210,210,220)",
}

local function scrollConsoleToBottom()
    task.defer(function()
        task.wait()
        if not AnswerScroll then return end
        if updateConsoleCanvas then updateConsoleCanvas() end
        local bottom = math.max(0, AnswerScroll.AbsoluteCanvasSize.Y - AnswerScroll.AbsoluteWindowSize.Y)
        AnswerScroll.CanvasPosition = Vector2.new(0, bottom)
    end)
end

Console = Instance.new("Frame")
Console.Name = "Console"
Console.Size = UDim2.new(1, -24, 0, 56)
Console.Position = UDim2.fromOffset(12, 56)
Console.BackgroundColor3 = Color3.fromRGB(8, 8, 12)
Console.BackgroundTransparency = 0.45
Console.BorderSizePixel = 0
Console.ClipsDescendants = true
Console.ZIndex = 5
Console.Parent = Window
addCorner(Console, 12)
local ConsoleStroke = addStroke(Console, COLORS.Border, 1, 0.5)
registerFade(Console, "BackgroundTransparency", 0.25)
registerFade(ConsoleStroke, "Transparency", 0.5)

AnswerScroll = Instance.new("ScrollingFrame")
AnswerScroll.Name = "AnswerScroll"
AnswerScroll.Size = UDim2.new(1, -16, 1, -10)
AnswerScroll.Position = UDim2.fromOffset(8, 5)
AnswerScroll.BackgroundTransparency = 1
AnswerScroll.BorderSizePixel = 0
AnswerScroll.ClipsDescendants = true
AnswerScroll.ScrollingEnabled = true
AnswerScroll.ScrollingDirection = Enum.ScrollingDirection.Y
AnswerScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
AnswerScroll.ScrollBarThickness = 2
AnswerScroll.ScrollBarImageColor3 = COLORS.Dim
AnswerScroll.ZIndex = 6
AnswerScroll.Parent = Console

ConsoleOutput = Instance.new("TextLabel")
ConsoleOutput.Name = "ConsoleOutput"
ConsoleOutput.Size = UDim2.new(1, -4, 0, 0)
ConsoleOutput.AutomaticSize = Enum.AutomaticSize.Y
ConsoleOutput.BackgroundTransparency = 1
ConsoleOutput.RichText = true
ConsoleOutput.Text = '<font color="' .. CONSOLE_COLORS.Green .. '">Sniping for codes</font>'
ConsoleOutput.TextSize = 14
ConsoleOutput.Font = Enum.Font.GothamMedium
ConsoleOutput.TextColor3 = COLORS.Green
ConsoleOutput.TextXAlignment = Enum.TextXAlignment.Left
ConsoleOutput.TextYAlignment = Enum.TextYAlignment.Center
ConsoleOutput.TextWrapped = true
ConsoleOutput.ZIndex = 7
ConsoleOutput.Parent = AnswerScroll
registerFade(ConsoleOutput, "TextTransparency", 0)

local CONSOLE_BOTTOM_PADDING = 4
updateConsoleCanvas = function()
    if not AnswerScroll or not ConsoleOutput then return end
    local contentHeight = math.max(40, ConsoleOutput.AbsoluteSize.Y + CONSOLE_BOTTOM_PADDING)
    AnswerScroll.CanvasSize = UDim2.new(0, 0, 0, contentHeight)
end
ConsoleOutput:GetPropertyChangedSignal("AbsoluteSize"):Connect(updateConsoleCanvas)
task.defer(updateConsoleCanvas)

-- ============================================================
-- ACTION BUTTONS: Clear / Redeem / Copy
-- ============================================================
local ActionRow = Instance.new("Frame")
ActionRow.Name = "ActionRow"
ActionRow.Size = UDim2.new(1, -24, 0, 36)
ActionRow.Position = UDim2.fromOffset(12, 120)
ActionRow.BackgroundTransparency = 1
ActionRow.ZIndex = 5
ActionRow.Parent = Window

local function makeActionBtn(name, text, xScale, xOffset, primary)
    local btn = Instance.new("TextButton")
    btn.Name = name
    btn.Size = UDim2.new(0.32, -4, 1, 0)
    btn.Position = UDim2.new(xScale, xOffset, 0, 0)
    btn.BackgroundColor3 = primary and COLORS.White or COLORS.Control
    btn.BackgroundTransparency = primary and 0.25 or 0.45
    btn.BorderSizePixel = 0
    btn.AutoButtonColor = false
    btn.Text = text
    btn.TextSize = 13
    btn.TextColor3 = primary and Color3.fromRGB(20, 20, 24) or COLORS.White
    btn.Font = Enum.Font.GothamBold
    btn.ZIndex = 6
    btn.Parent = ActionRow
    addCorner(btn, 10)
    if not primary then addStroke(btn, COLORS.Border, 1, 0.45) end
    registerFade(btn, "BackgroundTransparency", primary and 0 or 0.15)
    registerFade(btn, "TextTransparency", 0)
    return btn
end

local clearFeedBtn = makeActionBtn("ClearBtn", "Clear", 0, 0, false)
local redeemBtn = makeActionBtn("RedeemBtn", "Redeem", 0.34, 0, true)
local copyBtn = makeActionBtn("CopyBtn", "Copy", 0.68, 0, false)

local function performClearFeed()
    if _enabled then
        ConsoleOutput.Text = '<font color="' .. CONSOLE_COLORS.Green .. '">Sniping for codes</font>'
    else
        ConsoleOutput.Text = '<font color="' .. CONSOLE_COLORS.Red .. '">Off</font>'
    end
    task.defer(updateConsoleCanvas)
    _capturedParts = {}
    local box = instinctCodeBox()
    if box then
        _programmaticChange = true
        pcall(function() box.Text = "" end)
        _programmaticChange = false
    end
end

clearFeedBtn.Activated:Connect(function()
    performClearFeed()
end)

redeemBtn.Activated:Connect(function()
    local code = _lastNonBlankBoxText
    if (not code or code == "") and _lastBox and _lastBox.Text then
        code = _lastBox.Text
    end
    if not code or code == "" then
        local box = instinctCodeBox()
        if box then code = box.Text end
    end
    if not code or code == "" then
        setStatus("No code to redeem", COLORS.Red)
        return
    end
    local ok, statusMsg = typeAndSubmitCode(code)
    if ok then
        setStatus("Code redeemed (" .. code .. ")", COLORS.Green)
    else
        setStatus("Failed: " .. tostring(statusMsg), COLORS.Red)
    end
end)

copyBtn.Activated:Connect(function()
    local code = _lastNonBlankBoxText
    if (not code or code == "") and _lastBox and _lastBox.Text then code = _lastBox.Text end
    if not code or code == "" then
        local box = instinctCodeBox()
        if box then code = box.Text end
    end
    if code and code ~= "" then
        setClipboardSafe(code)
        setStatus("Copied: " .. code, COLORS.Green)
    else
        setStatus("Nothing to copy", COLORS.Dim)
    end
end)

-- ============================================================
-- MAIN SECTION
-- ============================================================
local MainTitle = makeLabel(Window, "MainTitle", "Main", UDim2.fromOffset(80, 16), UDim2.fromOffset(16, 164), 12, COLORS.Dim, Enum.Font.GothamBold)
MainTitle.ZIndex = 5

local ControlsBox = Instance.new("Frame")
ControlsBox.Name = "ControlsBox"
ControlsBox.Size = UDim2.new(1, -24, 0, 130)
ControlsBox.Position = UDim2.fromOffset(12, 182)
ControlsBox.BackgroundColor3 = COLORS.Box
ControlsBox.BackgroundTransparency = 0.45
ControlsBox.BorderSizePixel = 0
ControlsBox.ZIndex = 4
ControlsBox.Parent = Window
addCorner(ControlsBox, 12)
addStroke(ControlsBox, COLORS.Border, 1, 0.45)
registerFade(ControlsBox, "BackgroundTransparency", 0.25)

local function makeToggleRow(parent, y, labelText, initialState, onToggle)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, -16, 0, 26)
    row.Position = UDim2.fromOffset(8, y)
    row.BackgroundTransparency = 1
    row.ZIndex = 5
    row.Parent = parent
    makeLabel(row, "Title", labelText, UDim2.fromOffset(160, 26), UDim2.fromOffset(4, 0), 14, COLORS.Text, Enum.Font.GothamMedium).ZIndex = 6

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.fromOffset(48, 22)
    btn.Position = UDim2.new(1, -54, 0.5, -11)
    btn.BackgroundColor3 = initialState and COLORS.OnBtn or COLORS.OffBtn
    btn.BackgroundTransparency = 0.45
    btn.BorderSizePixel = 0
    btn.AutoButtonColor = false
    btn.Text = initialState and "ON" or "OFF"
    btn.TextSize = 12
    btn.TextColor3 = initialState and Color3.fromRGB(20, 20, 24) or COLORS.Dim
    btn.Font = Enum.Font.GothamBold
    btn.ZIndex = 6
    btn.Parent = row
    addCorner(btn, 8)
    local stroke = addStroke(btn, COLORS.White, 1, initialState and 0.55 or 0.85)
    registerFade(btn, "BackgroundTransparency", 0)
    registerFade(btn, "TextTransparency", 0)
    registerToggleStroke(btn, stroke)
    local state = initialState
    btn.Activated:Connect(function()
        state = not state
        if onToggle then onToggle(state) end
        applyToggleStyle(btn, stroke, state)
        
    end)
    return btn, stroke, function() return state end, function(s)
        state = s and true or false
        applyToggleStyle(btn, stroke, state)
    end
end

local function makeStepperRow(parent, y, labelText, value, minV, maxV, onChange)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, -16, 0, 26)
    row.Position = UDim2.fromOffset(8, y)
    row.BackgroundTransparency = 1
    row.ZIndex = 5
    row.Parent = parent
    makeLabel(row, "Title", labelText, UDim2.fromOffset(140, 26), UDim2.fromOffset(4, 0), 14, COLORS.Text, Enum.Font.GothamMedium).ZIndex = 6

    local shell = Instance.new("Frame")
    shell.Size = UDim2.fromOffset(90, 24)
    shell.Position = UDim2.new(1, -96, 0.5, -12)
    shell.BackgroundColor3 = COLORS.Log
    shell.BackgroundTransparency = 0.45
    shell.BorderSizePixel = 0
    shell.ZIndex = 6
    shell.Parent = row
    addCorner(shell, 8)

    local minus = Instance.new("TextButton")
    minus.Size = UDim2.fromOffset(24, 22)
    minus.Position = UDim2.fromOffset(1, 1)
    minus.BackgroundColor3 = COLORS.Control
    minus.BorderSizePixel = 0
    minus.AutoButtonColor = false
    minus.Text = "-"
    minus.TextSize = 14
    minus.TextColor3 = COLORS.White
    minus.Font = Enum.Font.GothamBold
    minus.ZIndex = 7
    minus.Parent = shell
    addCorner(minus, 6)

    local countLbl = makeLabel(shell, "Count", tostring(value), UDim2.fromOffset(36, 22), UDim2.fromOffset(27, 1), 13, COLORS.White, Enum.Font.GothamBold)
    countLbl.TextXAlignment = Enum.TextXAlignment.Center
    countLbl.ZIndex = 7

    local plus = Instance.new("TextButton")
    plus.Size = UDim2.fromOffset(24, 22)
    plus.Position = UDim2.fromOffset(65, 1)
    plus.BackgroundColor3 = COLORS.Control
    plus.BorderSizePixel = 0
    plus.AutoButtonColor = false
    plus.Text = "+"
    plus.TextSize = 14
    plus.TextColor3 = COLORS.White
    plus.Font = Enum.Font.GothamBold
    plus.ZIndex = 7
    plus.Parent = shell
    addCorner(plus, 6)

    local cur = value
    local function setVal(v)
        cur = math.clamp(v, minV, maxV)
        countLbl.Text = tostring(cur)
        if onChange then onChange(cur) end
    end
    minus.Activated:Connect(function() setVal(cur - 1) end)
    plus.Activated:Connect(function() setVal(cur + 1) end)
    return setVal
end

local snipeBtn, snipeStroke = makeToggleRow(ControlsBox, 6, "Snipe", _enabled, function(state)
    _enabled = state
    savedConfig.codeSniper = _enabled
    saveConfig()
    updateStatusDot()
    if _enabled then
        ConsoleOutput.Text = '<font color="' .. CONSOLE_COLORS.Green .. '">Sniping for codes</font>'
    else
        ConsoleOutput.Text = '<font color="' .. CONSOLE_COLORS.Red .. '">Off</font>'
    end
    task.defer(updateConsoleCanvas)
end)

-- hidden keybind capture buttons (still used by settings/keybinds)
snipeKeyBtn = Instance.new("TextButton")
snipeKeyBtn.Name = "SnipeKeyBtn"
snipeKeyBtn.Size = UDim2.fromOffset(1, 1)
snipeKeyBtn.Position = UDim2.fromOffset(-100, -100)
snipeKeyBtn.BackgroundTransparency = 1
snipeKeyBtn.Text = _listenKeybind
snipeKeyBtn.Visible = false
snipeKeyBtn.Parent = Window

clearFeedKeyBtn = Instance.new("TextButton")
clearFeedKeyBtn.Name = "ClearFeedKeyBtn"
clearFeedKeyBtn.Size = UDim2.fromOffset(1, 1)
clearFeedKeyBtn.Position = UDim2.fromOffset(-100, -100)
clearFeedKeyBtn.BackgroundTransparency = 1
clearFeedKeyBtn.Text = _clearFeedKeybind
clearFeedKeyBtn.Visible = false
clearFeedKeyBtn.Parent = Window

local autoSubmitBtn = makeToggleRow(ControlsBox, 34, "Auto submit", _autoAccept, function(state)
    _autoAccept = state
    savedConfig.autoSubmit = _autoAccept
    saveConfig()
end)

makeStepperRow(ControlsBox, 62, "Submit after", _submitAfter, 1, 10, function(v)
    _submitAfter = v
    savedConfig.submitAfter = _submitAfter
    clearInstinctCapture()
    saveConfig()
end)

makeStepperRow(ControlsBox, 90, "Spam redeem", _spamCount, 0, 50, function(v)
    _spamCount = v
    _spamRedeem = v > 0
    savedConfig.spamCount = _spamCount
    savedConfig.spamRedeem = _spamRedeem
    saveConfig()
end)

-- ============================================================
-- AA HELPER SECTION
-- ============================================================
local AAHelperTitle = makeLabel(Window, "AAHelperTitle", "aa helper", UDim2.fromOffset(120, 16), UDim2.fromOffset(16, 320), 12, COLORS.Dim, Enum.Font.GothamBold)
AAHelperTitle.ZIndex = 5

local AAHelperBox = Instance.new("Frame")
AAHelperBox.Name = "AAHelperBox"
AAHelperBox.Size = UDim2.new(1, -24, 0, 130)
AAHelperBox.Position = UDim2.fromOffset(12, 338)
AAHelperBox.BackgroundColor3 = COLORS.Box
AAHelperBox.BackgroundTransparency = 0.45
AAHelperBox.BorderSizePixel = 0
AAHelperBox.ZIndex = 4
AAHelperBox.Parent = Window
addCorner(AAHelperBox, 12)
addStroke(AAHelperBox, COLORS.Border, 1, 0.45)
registerFade(AAHelperBox, "BackgroundTransparency", 0.25)

local function makeHelperRow(y, labelText, initialState, onToggle)
    return makeToggleRow(AAHelperBox, y, labelText, initialState, onToggle)
end

makeHelperRow(6, "Anti Ragdoll", _antiRagdollEnabled, function(state)
    if state then startAntiRagdoll() else stopAntiRagdoll() end
    savedConfig.antiRagdoll = _antiRagdollEnabled
    saveConfig()
end)
makeHelperRow(34, "Auto Buy", _autoBuyActive, function(state)
    if state then autoBuyStart() else autoBuyStop() end
end)
makeHelperRow(62, "Anti Lag", _antiLagEnabled, function(state)
    if state then startAntiLag() else stopAntiLag() end
    savedConfig.antiLag = _antiLagEnabled
    saveConfig()
end)
makeHelperRow(90, "Remove Accessories", _removeAccessoriesEnabled, function(state)
    if state then startRemoveAccessories() else stopRemoveAccessories() end
    savedConfig.removeAccessories = _removeAccessoriesEnabled
    saveConfig()
end)

-- ============================================================
-- KEYBIND HANDLERS (Snipe + Clear Feed)
-- ============================================================
local function setupListenKeybind()
    if _listenInputConnection then _listenInputConnection:Disconnect(); _listenInputConnection = nil end
    _listenInputConnection = UserInputService.InputBegan:Connect(function(inp, gp)
        if gp then return end
        if UserInputService:GetFocusedTextBox() then return end
        if _capturingListenKey then return end
        if inp.KeyCode == Enum.KeyCode[_listenKeybind] then
            _enabled = not _enabled
            savedConfig.codeSniper = _enabled
            saveConfig()
            applyToggleStyle(snipeBtn, snipeStroke, _enabled)
            
            updateStatusDot()
            if _enabled then
                ConsoleOutput.Text = '<font color="' .. CONSOLE_COLORS.Green .. '">Sniping for codes</font>'
            else
                ConsoleOutput.Text = '<font color="' .. CONSOLE_COLORS.Red .. '">Off</font>'
            end
            task.defer(updateConsoleCanvas)
        end
    end)
end

local function setupClearFeedKeybind()
    if _clearFeedInputConnection then _clearFeedInputConnection:Disconnect(); _clearFeedInputConnection = nil end
    _clearFeedInputConnection = UserInputService.InputBegan:Connect(function(inp, gp)
        if gp then return end
        if UserInputService:GetFocusedTextBox() then return end
        if _capturingClearFeedKey then return end
        if inp.KeyCode == Enum.KeyCode[_clearFeedKeybind] then
            performClearFeed()
        end
    end)
end

UserInputService.InputBegan:Connect(function(inp, gp)
    if not _capturingListenKey then return end
    if gp then return end
    if inp.UserInputType ~= Enum.UserInputType.Keyboard then return end
    local key = inp.KeyCode
    if key == Enum.KeyCode.Unknown then return end
    local keyName = key.Name
    if #keyName == 1 then _listenKeybind = keyName:upper() else _listenKeybind = keyName end
    savedConfig.listenKeybind = _listenKeybind
    saveConfig()
    if snipeKeyBtn then
        snipeKeyBtn.Text = _listenKeybind
        snipeKeyBtn.TextColor3 = COLORS.White
    end
    _capturingListenKey = false
    setupListenKeybind()
end)

UserInputService.InputBegan:Connect(function(inp, gp)
    if not _capturingClearFeedKey then return end
    if gp then return end
    if inp.UserInputType ~= Enum.UserInputType.Keyboard then return end
    local key = inp.KeyCode
    if key == Enum.KeyCode.Unknown then return end
    local keyName = key.Name
    if #keyName == 1 then _clearFeedKeybind = keyName:upper() else _clearFeedKeybind = keyName end
    savedConfig.clearFeedKeybind = _clearFeedKeybind
    saveConfig()
    if clearFeedKeyBtn then
        clearFeedKeyBtn.Text = _clearFeedKeybind
        clearFeedKeyBtn.TextColor3 = COLORS.White
    end
    _capturingClearFeedKey = false
    setupClearFeedKeybind()
end)

-- ============================================================
-- KEYBINDS POPUP GUI
-- ============================================================
local SettingsGUI = nil

local function keyCodeFromName(name)
    if type(name) ~= "string" or name == "" then return nil end
    local ok, kc = pcall(function() return Enum.KeyCode[name] end)
    if ok and typeof(kc) == "EnumItem" then return kc end
    return nil
end

local function createSettingsUI()
    if SettingsGUI and SettingsGUI.Parent then
        SettingsGUI:Destroy(); SettingsGUI = nil; return
    end
    SettingsGUI = Instance.new("ScreenGui")
    SettingsGUI.Name = "ExeCodeSniperSettingsUI"
    SettingsGUI.ResetOnSpawn = false
    SettingsGUI.IgnoreGuiInset = true
    SettingsGUI.DisplayOrder = 998
    if not pcall(function() SettingsGUI.Parent = game.CoreGui end) then
        SettingsGUI.Parent = playerGui
    end

    local rows = {
        { id = "snipe", label = "Snipe", get = function() return _listenKeybind end, set = function(v)
            _listenKeybind = v; savedConfig.listenKeybind = v
            if snipeKeyBtn then snipeKeyBtn.Text = v end
            setupListenKeybind()
        end },
        { id = "autoSubmit", label = "Auto submit", get = function() return _autoSubmitKeybind end, set = function(v)
            _autoSubmitKeybind = v; savedConfig.autoSubmitKeybind = v
        end },
        { id = "clearFeed", label = "Clear feed", get = function() return _clearFeedKeybind end, set = function(v)
            _clearFeedKeybind = v; savedConfig.clearFeedKeybind = v
            if clearFeedKeyBtn then clearFeedKeyBtn.Text = v end
            setupClearFeedKeybind()
        end },
        { id = "antiRagdoll", label = "Anti Ragdoll", get = function() return _antiRagdollKeybind end, set = function(v)
            _antiRagdollKeybind = v; savedConfig.antiRagdollKeybind = v
        end },
        { id = "autoBuy", label = "Auto Buy", get = function() return _autoBuyKeybind end, set = function(v)
            _autoBuyKeybind = v; savedConfig.autoBuyKeybind = v
        end },
        { id = "antiLag", label = "Anti Lag", get = function() return _antiLagKeybind end, set = function(v)
            _antiLagKeybind = v; savedConfig.antiLagKeybind = v
        end },
        { id = "removeAcc", label = "Remove Accessories", get = function() return _removeAccessoriesKeybind end, set = function(v)
            _removeAccessoriesKeybind = v; savedConfig.removeAccessoriesKeybind = v
        end },
    }

    local rowH, pad, titleH = 28, 8, 34
    local h = titleH + #rows * rowH + pad * 2 + 8
    local SW = Instance.new("Frame")
    SW.Name = "SettingsWindow"
    SW.Size = UDim2.fromOffset(250, h)
    SW.AnchorPoint = Vector2.new(0.5, 0.5)
    SW.Position = UDim2.new(0.5, 0, 0.5, 0)
    SW.BackgroundColor3 = COLORS.Window
    SW.BackgroundTransparency = 0.35
    SW.BorderSizePixel = 0
    SW.ClipsDescendants = true
    SW.Parent = SettingsGUI
    addCorner(SW, 12)
    addStroke(SW, COLORS.Border, 1, 0.35)

    local TitleBar = Instance.new("Frame")
    TitleBar.Name = "TitleBar"
    TitleBar.Size = UDim2.new(1, 0, 0, titleH)
    TitleBar.BackgroundTransparency = 1
    TitleBar.Active = true
    TitleBar.Parent = SW
    local sTitle = makeLabel(TitleBar, "Title", "KEYBINDS", UDim2.new(1, -60, 0, titleH), UDim2.fromOffset(12, 0), 14, COLORS.White, Enum.Font.GothamBold)
    sTitle.ZIndex = 2

    local closeBtn = Instance.new("TextButton")
    closeBtn.Name = "CloseBtn"
    closeBtn.Size = UDim2.fromOffset(22, 22)
    closeBtn.Position = UDim2.new(1, -28, 0, 6)
    closeBtn.BackgroundTransparency = 1
    closeBtn.Text = "X"
    closeBtn.TextSize = 14
    closeBtn.TextColor3 = COLORS.Dim
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.ZIndex = 3
    closeBtn.Parent = TitleBar
    closeBtn.Activated:Connect(function()
        _capturingFeatureKey = nil
        if SettingsGUI then SettingsGUI:Destroy(); SettingsGUI = nil end
    end)

    _keybindLabels = {}
    for i, info in ipairs(rows) do
        local y = titleH + (i - 1) * rowH
        local row = Instance.new("Frame")
        row.Size = UDim2.new(1, -20, 0, rowH - 4)
        row.Position = UDim2.fromOffset(10, y)
        row.BackgroundTransparency = 1
        row.Parent = SW
        makeLabel(row, "L", info.label, UDim2.fromOffset(150, rowH - 4), UDim2.fromOffset(4, 0), 13, COLORS.Text, Enum.Font.GothamMedium)

        local kb = Instance.new("TextButton")
        kb.Size = UDim2.fromOffset(48, 22)
        kb.Position = UDim2.new(1, -52, 0.5, -11)
        kb.BackgroundColor3 = COLORS.Control
        kb.BorderSizePixel = 0
        kb.AutoButtonColor = false
        kb.Text = tostring(info.get() or "-")
        kb.TextSize = 12
        kb.TextColor3 = COLORS.White
        kb.Font = Enum.Font.GothamBold
        kb.Parent = row
        addCorner(kb, 6)
        addStroke(kb, COLORS.Border, 1, 0.45)
        _keybindLabels[info.id] = kb

        kb.Activated:Connect(function()
            if _capturingFeatureKey then return end
            _capturingFeatureKey = info.id
            kb.Text = "..."
            kb.TextColor3 = COLORS.Dim
        end)
    end

    -- capture handler for settings keybinds
    local captureConn
    captureConn = UserInputService.InputBegan:Connect(function(inp, gp)
        if not _capturingFeatureKey then return end
        if inp.UserInputType ~= Enum.UserInputType.Keyboard then return end
        local key = inp.KeyCode
        if key == Enum.KeyCode.Unknown or key == Enum.KeyCode.Escape then
            local id = _capturingFeatureKey
            _capturingFeatureKey = nil
            for _, info in ipairs(rows) do
                if info.id == id and _keybindLabels[id] then
                    _keybindLabels[id].Text = tostring(info.get() or "-")
                    _keybindLabels[id].TextColor3 = COLORS.White
                end
            end
            return
        end
        local keyName = key.Name
        if #keyName == 1 then keyName = keyName:upper() end
        local id = _capturingFeatureKey
        _capturingFeatureKey = nil
        for _, info in ipairs(rows) do
            if info.id == id then
                info.set(keyName)
                saveConfig()
                if _keybindLabels[id] then
                    _keybindLabels[id].Text = keyName
                    _keybindLabels[id].TextColor3 = COLORS.White
                end
                break
            end
        end
    end)
    SettingsGUI.Destroying:Connect(function()
        _capturingFeatureKey = nil
        if captureConn then pcall(function() captureConn:Disconnect() end) end
    end)

    applyCustomFont(SW)
    watchAndApplyFont(SW)

    do
        local drag, dInput, dStart, dPos
        TitleBar.InputBegan:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
                drag = true
                dInput = i
                dStart = Vector2.new(i.Position.X, i.Position.Y)
                dPos = SW.Position
                i.Changed:Connect(function()
                    if i.UserInputState == Enum.UserInputState.End or i.UserInputState == Enum.UserInputState.Cancel then
                        drag = false
                        dInput = nil
                    end
                end)
            end
        end)
        UserInputService.InputChanged:Connect(function(i)
            if drag and dInput then
                if (dInput.UserInputType == Enum.UserInputType.MouseButton1 and i.UserInputType == Enum.UserInputType.MouseMovement)
                or (dInput.UserInputType == Enum.UserInputType.Touch and i == dInput) then
                    local delta = Vector2.new(i.Position.X, i.Position.Y) - dStart
                    SW.Position = UDim2.new(dPos.X.Scale, dPos.X.Offset + delta.X, dPos.Y.Scale, dPos.Y.Offset + delta.Y)
                end
            end
        end)
    end
end

-- Feature keybinds (toggle each feature)
local function setupFeatureKeybinds()
    if _featureKeybindConn then pcall(function() _featureKeybindConn:Disconnect() end); _featureKeybindConn = nil end
    _featureKeybindConn = UserInputService.InputBegan:Connect(function(inp, gp)
        if gp then return end
        if UserInputService:GetFocusedTextBox() then return end
        if _capturingFeatureKey or _capturingListenKey or _capturingClearFeedKey then return end
        if inp.UserInputType ~= Enum.UserInputType.Keyboard then return end
        local key = inp.KeyCode
        local function isKey(name)
            local kc = keyCodeFromName(name)
            return kc and key == kc
        end

        if isKey(_autoSubmitKeybind) then
            _autoAccept = not _autoAccept
            savedConfig.autoSubmit = _autoAccept
            saveConfig()
            setStatus("Auto submit: " .. (_autoAccept and "ON" or "OFF"), _autoAccept and COLORS.Green or COLORS.Dim)
            return
        end
        if isKey(_antiRagdollKeybind) then
            if _antiRagdollEnabled then stopAntiRagdoll() else startAntiRagdoll() end
            savedConfig.antiRagdoll = _antiRagdollEnabled
            saveConfig()
            setStatus("Anti Ragdoll: " .. (_antiRagdollEnabled and "ON" or "OFF"), _antiRagdollEnabled and COLORS.Green or COLORS.Dim)
            return
        end
        if isKey(_antiLagKeybind) then
            if _antiLagEnabled then stopAntiLag() else startAntiLag() end
            savedConfig.antiLag = _antiLagEnabled
            saveConfig()
            setStatus("Anti Lag: " .. (_antiLagEnabled and "ON" or "OFF"), _antiLagEnabled and COLORS.Green or COLORS.Dim)
            return
        end
        if isKey(_removeAccessoriesKeybind) then
            if _removeAccessoriesEnabled then stopRemoveAccessories() else startRemoveAccessories() end
            savedConfig.removeAccessories = _removeAccessoriesEnabled
            saveConfig()
            setStatus("Remove Accessories: " .. (_removeAccessoriesEnabled and "ON" or "OFF"), _removeAccessoriesEnabled and COLORS.Green or COLORS.Dim)
            return
        end
        -- auto buy uses existing K handler too; still support config keybind
        if isKey(_autoBuyKeybind) then
            toggleAutoBuy()
            setStatus("Auto Buy: " .. (_autoBuyActive and "ON" or "OFF"), _autoBuyActive and COLORS.Green or COLORS.Dim)
            return
        end
    end)
end

GearButton.Activated:Connect(createSettingsUI)

-- ============================================================
-- WINDOW DRAGGING
-- ============================================================
do
    local dragging = false
    local activeDragInput
    local dragStart
    local startPosition
    local dragMoved = false
    local DRAG_THRESHOLD = UserInputService.TouchEnabled and 10 or 3

    local function isOverHeaderControl(position)
        local function inBox(absPos, absSize)
            return position.X >= (absPos.X - 6) and position.X <= (absPos.X + absSize.X + 6)
               and position.Y >= (absPos.Y - 6) and position.Y <= (absPos.Y + absSize.Y + 6)
        end
        return inBox(GearButton.AbsolutePosition, GearButton.AbsoluteSize)
            or inBox(MinusButton.AbsolutePosition, MinusButton.AbsoluteSize)
    end

    local function stopDragging(input)
        if input ~= activeDragInput then return end
        dragging = false
        activeDragInput = nil
        dragStart = nil
        startPosition = nil
    end

    Header.InputBegan:Connect(function(input)
        if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then return end
        if dragging or isOverHeaderControl(input.Position) then return end
        dragging = true
        activeDragInput = input
        dragStart = Vector2.new(input.Position.X, input.Position.Y)
        startPosition = Window.Position
        dragMoved = false
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End or input.UserInputState == Enum.UserInputState.Cancel then
                stopDragging(input)
            end
        end)
    end)

    UserInputService.InputChanged:Connect(function(input)
        if not dragging or not activeDragInput then return end
        local isTrackedTouch = activeDragInput.UserInputType == Enum.UserInputType.Touch and input == activeDragInput
        local isTrackedMouse = activeDragInput.UserInputType == Enum.UserInputType.MouseButton1 and input.UserInputType == Enum.UserInputType.MouseMovement
        if not isTrackedTouch and not isTrackedMouse then return end
        local current = Vector2.new(input.Position.X, input.Position.Y)
        local delta = current - dragStart
        if not dragMoved then
            if delta.Magnitude < DRAG_THRESHOLD then return end
            dragMoved = true
        end
        Window.Position = UDim2.new(
            startPosition.X.Scale, startPosition.X.Offset + delta.X,
            startPosition.Y.Scale, startPosition.Y.Offset + delta.Y
        )
    end)
end

-- ============================================================
-- REST OF SCRIPT
-- ============================================================
local function col3ToRich(col)
    if col == COLORS.Green then return CONSOLE_COLORS.Green end
    if col == COLORS.Red then return CONSOLE_COLORS.Red end
    if col == COLORS.Text then return CONSOLE_COLORS.Amber end
    if col == COLORS.White then return CONSOLE_COLORS.Cyan end
    if col == COLORS.Dim then return CONSOLE_COLORS.Dim end
    return string.format("rgb(%d,%d,%d)", math.floor(col.R * 255 + 0.5), math.floor(col.G * 255 + 0.5), math.floor(col.B * 255 + 0.5))
end

function setStatus(msg, col)
    if not ConsoleOutput then return end
    col = col or COLORS.Dim
    local line = '<font color="' .. col3ToRich(col) .. '">' .. tostring(msg) .. "</font>"
    local lines = {}
    for line in ConsoleOutput.Text:gmatch("[^\n]+") do
        table.insert(lines, line)
    end
    if #lines == 0 then
        ConsoleOutput.Text = line
    else
        local newText = lines[1] .. "\n\n" .. line
        ConsoleOutput.Text = newText
    end
    scrollConsoleToBottom()
end

function flashCode(code, col)
    if not code or code == "" or code == "â€”" then return end
    setStatus("[code] -> " .. tostring(code), col or COLORS.White)
end

local function resetPasteCounter()
    _capturedParts = {}
end
clearInstinctCapture = function()
    _capturedParts = {}
end

local function clearBoxWatchers()
    if _boxTextConn then pcall(function() _boxTextConn:Disconnect() end) end
    if _boxAncestryConn then pcall(function() _boxAncestryConn:Disconnect() end) end
    for _, connection in ipairs(_boxVisibilityConns) do
        pcall(function() connection:Disconnect() end)
    end
    _boxTextConn = nil
    _boxAncestryConn = nil
    _boxVisibilityConns = {}
    _lastWatchedBox = nil
    if _manualSubmitDebounce then
        _manualSubmitDebounce:Disconnect()
        _manualSubmitDebounce = nil
    end
end

local function watchBoxForBlankReset(box)
    if not box or _lastWatchedBox == box then return end
    clearBoxWatchers()
    _lastWatchedBox = box
    if box.Text ~= "" then
        _lastNonBlankBoxText = box.Text
    end
    _boxTextConn = box:GetPropertyChangedSignal("Text"):Connect(function()
        if box.Text == "" then
            resetPasteCounter()
            _lastNonBlankBoxText = ""
            if _manualSubmitDebounce then
                _manualSubmitDebounce:Disconnect()
                _manualSubmitDebounce = nil
            end
        else
            _lastNonBlankBoxText = box.Text
            if not _programmaticChange and box.Text ~= "" and _autoCodeTypedEnabled then
                setClipboardSafe(box.Text)
            end
            if not _programmaticChange and _autoAccept then
                local words = {}
                for w in box.Text:gmatch("%S+") do
                    table.insert(words, w)
                end
                if #words >= _submitAfter then
                    if _manualSubmitDebounce then
                        _manualSubmitDebounce:Disconnect()
                    end
                    _manualSubmitDebounce = task.delay(SUBMIT_DELAY, function()
                        _manualSubmitDebounce = nil
                        if _autoAccept and box and box.Parent and isVisibleChain(box) then
                            local code = box.Text
                            if code ~= "" then
                                local ok, statusMsg = typeAndSubmitCode(code)
                                if ok then
                                    setStatus("Code redeemed (" .. code .. ")", COLORS.Green)
                                else
                                    setStatus("Failed: " .. tostring(statusMsg), COLORS.Red)
                                end
                            end
                        end
                    end)
                end
            end
        end
    end)
    _boxAncestryConn = box.AncestryChanged:Connect(function(_, parent)
        if not parent then
            resetPasteCounter()
            clearBoxWatchers()
        end
    end)
end

UserInputService.TextBoxFocused:Connect(function(box)
    if box:IsDescendantOf(GUI) or (SettingsGUI and box:IsDescendantOf(SettingsGUI)) then return end
    if box ~= instinctCodeBox() then return end
    _focused = box
    _lastBox = box
    watchBoxForBlankReset(box)
end)

UserInputService.TextBoxFocusReleased:Connect(function(box)
    if box:IsDescendantOf(GUI) or (SettingsGUI and box:IsDescendantOf(SettingsGUI)) then return end
    local codeBox = instinctCodeBox()
    if box ~= codeBox and box ~= _lastBox then return end
    if _focused == box then
        _focused = nil
        if _enabled then
            setStatus((_lastBox and _lastBox.Parent) and "Ready" or "Click code box first", (_lastBox and _lastBox.Parent) and COLORS.Green or COLORS.Dim)
        end
    end
end)

function appendToBox(text)
    if not text or text == "" then return end
    if not _enabled then return end
    if _lastWatchedBox and not isVisibleChain(_lastWatchedBox) then
        resetPasteCounter()
        clearBoxWatchers()
    end
    local box = instinctCodeBox()
    _capturedParts[#_capturedParts + 1] = text
    local combinedCode = table.concat(_capturedParts)
    local capturedCount = #_capturedParts
    if _autoCodeTypedEnabled then
        setClipboardSafe(combinedCode)
    end
    if box then
        _lastBox = box
        watchBoxForBlankReset(box)
        local boxWasFocused = UserInputService:GetFocusedTextBox() == box
        _programmaticChange = true
        box.Text = combinedCode
        _programmaticChange = false
        if boxWasFocused then
            pcall(function()
                local caretEnd = #combinedCode + 1
                box.CursorPosition = caretEnd
                box.SelectionStart = caretEnd
            end)
        end
    else
        setStatus("Captured; opening & searching UI...", COLORS.Text)
    end
    setStatus("Pasted " .. tostring(capturedCount) .. "/" .. tostring(_submitAfter), COLORS.Green)
    flashCode(combinedCode, COLORS.Green)
    if capturedCount >= _submitAfter then
        _capturedParts = {}
        if _autoAccept then
            task.wait(SUBMIT_DELAY)
            local ok, statusMsg = typeAndSubmitCode(combinedCode)
            if ok then
                setStatus("Code redeemed (" .. combinedCode .. ")", COLORS.Green)
            else
                setStatus("Failed: " .. tostring(statusMsg), COLORS.Red)
            end
        end
    end
end

-- ============================================================
-- ANNOUNCEMENT NOTIFICATION LISTENER
-- ============================================================
local function resolveNotifyRemote()
    if _G.PhiNotifyRemote then return _G.PhiNotifyRemote end
    local Net = ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Net")
    local getinfo = debug and (debug.getinfo or debug.info)
    if getgc and getinfo and getconnections then
        for _, d in ipairs(Net:GetDescendants()) do
            if d:IsA("RemoteEvent") then
                local ok, cs = pcall(getconnections, d.OnClientEvent)
                if ok then
                    for _, c in ipairs(cs) do
                        local f, fn = pcall(function() return c.Function end)
                        if f and type(fn) == "function" then
                            local i, info = pcall(getinfo, fn)
                            if i and tostring(info.short_src or info.source or ""):find("NotificationController", 1, true) then
                                return d
                            end
                        end
                    end
                end
            end
        end
    end
    return nil
end

local function instinctStripRich(text)
    if type(text) ~= "string" then return tostring(text) end
    return (text:gsub("<[^>]->", ""))
end

local function instinctTokenize(text)
    local words = {}
    for word in text:gmatch("[%w_]+") do
        words[#words + 1] = word
    end
    return words
end

local instinctCollectBuffer = {}
local function onInstinctAnnouncement(...)
    if not _enabled then return end
    local text = instinctStripRich(tostring((...) or ""))
    text = text:match("^%s*(.-)%s*$") or ""
    if text == "" then return end
    if text:find("%s") then return end
    for _, word in ipairs(instinctTokenize(text)) do
        instinctCollectBuffer[#instinctCollectBuffer + 1] = word
    end
    local parts = {}
    for index = 1, math.min(#instinctCollectBuffer, INSTINCT_WORD_COUNT) do
        parts[index] = instinctCollectBuffer[index]
    end
    if #instinctCollectBuffer < INSTINCT_WORD_COUNT then return end
    instinctCollectBuffer = {}
    local captured = table.concat(parts)
    if captured == "" or _seen[captured] then return end
    _seen[captured] = true
    task.delay(1.25, function() _seen[captured] = nil end)
    appendToBox(captured)
end

local instinctNotifyRemote = resolveNotifyRemote()
local instinctListenConnection
if instinctNotifyRemote then
    if getgenv then
        local previous = getgenv().ExeCodeSniperNotifyConnection
        if previous then pcall(function() previous:Disconnect() end) end
    end
    instinctListenConnection = instinctNotifyRemote.OnClientEvent:Connect(function(...)
        pcall(onInstinctAnnouncement, ...)
    end)
    if getgenv then
        getgenv().ExeCodeSniperNotifyConnection = instinctListenConnection
    end
end

if getgenv then
    getgenv().StopAura = function()
        if instinctListenConnection then
            pcall(function() instinctListenConnection:Disconnect() end)
            instinctListenConnection = nil
        end
        if getgenv().ExeCodeSniperNotifyConnection then
            pcall(function() getgenv().ExeCodeSniperNotifyConnection:Disconnect() end)
            getgenv().ExeCodeSniperNotifyConnection = nil
        end
        if _listenInputConnection then _listenInputConnection:Disconnect(); _listenInputConnection = nil end
        if _clearFeedInputConnection then _clearFeedInputConnection:Disconnect(); _clearFeedInputConnection = nil end
        stopAntiLag()
        stopAntiRagdoll()
        stopAntiDie()
        stopRemoveAccessories()
        autoBuyStop()
        if GUI then GUI:Destroy() end
        if SettingsGUI then SettingsGUI:Destroy() end
    end
end

-- Ensure initial states
if _antiLagEnabled then startAntiLag() end
if _antiRagdollEnabled then startAntiRagdoll() end
if _antiDieEnabled then startAntiDie() end
if _removeAccessoriesEnabled then startRemoveAccessories() end
if savedConfig.autoBuy then autoBuyStart() end
updateStatusDot()
setupListenKeybind()
setupClearFeedKeybind()
setupFeatureKeybinds()
if ConsoleOutput then
    ConsoleOutput.Text = _enabled
        and '<font color="rgb(90,220,130)">Sniping for codes</font>'
        or '<font color="rgb(220,90,90)">Off</font>'
end


-- ============================================================
-- APPLY CUSTOM FONT TO OUR MAIN GUI
-- ============================================================
applyCustomFont(GUI)
watchAndApplyFont(GUI)

-- ===== ORIGINAL SCRIPT ENDS =====
end)

if not success then
    warn("Exe Code Sniper error: " .. tostring(err))
    print("Check the error above. The script may not work in this environment.")
end