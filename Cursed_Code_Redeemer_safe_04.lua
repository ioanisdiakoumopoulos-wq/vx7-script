 end
  local cur = codesFrame
  while cur and cur ~= codesGui do
    if cur:IsA("GuiObject") then cur.Visible = true end
    cur = cur.Parent
  end
local box = nil
for _, d in ipairs(codesFrame:GetDescendants()) do
  if d:IsA("TextBox") and not isOurGui(d) then
    box = d
    break
  end
end
local submitBtn = nil
for _, d in ipairs(codesFrame:GetDescendants()) do
  if (d:IsA("TextButton") or d:IsA("ImageButton")) and not isOurGui(d) then
    local n = d.Name:lower()
    local txt = ""
    pcall(function() txt = d.Text:lower() end)
    if n:find("submit") or txt:find("submit") or n:find("redeem") or txt:find("redeem")
    or n:find("claim") or txt:find("confirm") or n:find("enter") then
      submitBtn = d
      break
    end
end
end
if not submitBtn then
  for _, d in ipairs(codesFrame:GetDescendants()) do
    if (d:IsA("TextButton") or d:IsA("ImageButton")) and not isOurGui(d) then
      local n = d.Name:lower()
      if not n:find("close") and not n:find("x") and not n:find("toggle") then
        submitBtn = d
        break
      end
  end
end
end
if box then
  if rememberPending then rememberPending(box, code, true) end
  writeCodeToBox(box, code)
  task.wait(math.max(0.01, tonumber(cfg.redeemDelay) or 0.05))
  if submitBtn then
    clickButton(submitBtn)
  end
fireBoxFocusLost(box)
return true, "submitted via PlayerGui.Codes.Codes"
end
end
end
local function tryOpenPanel()
  local btns = findCodeButtons(pg)
  for _, btn in ipairs(btns) do
    clickButton(btn)
    task.wait(0.05)
  end
return #btns > 0
end

tryOpenPanel()
task.wait(0.3)

local box = nil
local deadline = tick() + 3
while tick() < deadline do
  local allBoxes = findAllTextBoxes(pg)
  for _, d in ipairs(allBoxes) do
    if isVisibleChain(d) then
      local n = d.Name:lower()
      local pn = (d.Parent and d.Parent.Name or ""):lower()
      if n:find("code") or pn:find("code") or n:find("redeem") or pn:find("redeem")
      or n:find("input") or pn:find("input") or n:find("textbox") or n:find("enter") then
        box = d
        break
      end
  end
end
if not box then
  for _, d in ipairs(allBoxes) do
    if isVisibleChain(d) then box = d; break end
  end
end
if box then break end
task.wait(0.1)
end
if not box then return false, "no codebox visible" end
if rememberPending then rememberPending(box, code, true) end
writeCodeToBox(box, code)
task.wait(math.max(0.01, tonumber(cfg.redeemDelay) or 0.05))

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
          if isVisibleChain(d) then
            redeemBtn = d
            break
          end
      end
  end
if redeemBtn then break end
end
end
if redeemBtn then break end
p = p.Parent
end
if redeemBtn then
  clickButton(redeemBtn)
end

fireBoxFocusLost(box)
return true, "fallback methods used"
end
local helperAutoBuyActive = false
local helperAnchored = false
local helperAntiRagdollActive = false
local helperAutoBuyElapsed = 0
local helperAntiRagdollCooldown = 0
local helperAntiRagdollConn

local function triggerWorkspacePrompts()
  for _, prompt in ipairs(workspace:GetDescendants()) do
    if prompt:IsA("ProximityPrompt") then
      pcall(function()
        prompt.HoldDuration = 0
        prompt:InputHoldBegin()
        prompt:InputHoldEnd()
      end)
  end
end
end
local helperAutoBuyConn = RunService.Stepped:Connect(function(_, deltaTime)
  if not helperAutoBuyActive then return end
  helperAutoBuyElapsed += tonumber(deltaTime) or 0
  if helperAutoBuyElapsed < 0.12 then return end
  helperAutoBuyElapsed = 0
  triggerWorkspacePrompts()
end)

local function setCharacterAnchored(state, character)
  local char = character or player.Character
  if not char then return end
  for _, part in ipairs(char:GetDescendants()) do
    if part:IsA("BasePart") then
      pcall(function() part.Anchored = state end)
    end
end
end
local helperCharacterConn = player.CharacterAdded:Connect(function(character)
  if helperAnchored then
    task.defer(function()
      character:WaitForChild("HumanoidRootPart", 5)
      setCharacterAnchored(true, character)
    end)
end
end)

local function forceAntiRagdollReset()
  local character = player.Character
  if not character then return end
  local humanoid = character:FindFirstChildOfClass("Humanoid")
  local root = character:FindFirstChild("HumanoidRootPart")
  if not humanoid or not root or humanoid.Health <= 0 then return end

  pcall(function()
    humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
    root.Velocity = Vector3.zero
    root.RotVelocity = Vector3.zero
    root.AssemblyLinearVelocity = Vector3.zero
    root.AssemblyAngularVelocity = Vector3.zero
    for _, object in ipairs(character:GetDescendants()) do
      if object:IsA("Motor6D") then object.Enabled = true end
      if object:IsA("Constraint") then object.Enabled = true end
    end
  if workspace.CurrentCamera then workspace.CurrentCamera.CameraSubject = humanoid end
  humanoid.AutoRotate = true
  humanoid.PlatformStand = false
  humanoid.Sit = false
end)

pcall(function()
  local playerModule = player:FindFirstChild("PlayerScripts")
  and player.PlayerScripts:FindFirstChild("PlayerModule")
  local controlModule = playerModule and playerModule:FindFirstChild("ControlModule")
  if controlModule then
    local controls = require(controlModule)
    if controls and controls.Enable then controls:Enable() end
  end
end)
end
local function setHelperAutoBuy(state)
  helperAutoBuyActive = state == true
  helperAutoBuyElapsed = 0
  if helperAutoBuyActive then task.spawn(triggerWorkspacePrompts) end
end
local function setHelperAnchor(state)
  helperAnchored = state == true
  setCharacterAnchored(helperAnchored)
end
local function setHelperAntiRagdoll(state)
  helperAntiRagdollActive = state == true
  if not helperAntiRagdollActive then
    if helperAntiRagdollConn then helperAntiRagdollConn:Disconnect() end
    helperAntiRagdollConn = nil
    return
  end
if helperAntiRagdollConn then return end
helperAntiRagdollConn = RunService.Heartbeat:Connect(function()
  if not helperAntiRagdollActive then return end
  local character = player.Character
  local humanoid = character and character:FindFirstChildOfClass("Humanoid")
  if not humanoid or humanoid.Health <= 0 then return end
  local stateNow = humanoid:GetState()
  local ragdolled = stateNow == Enum.HumanoidStateType.Physics
  or stateNow == Enum.HumanoidStateType.Ragdoll
  or stateNow == Enum.HumanoidStateType.FallingDown
  if ragdolled and tick() - helperAntiRagdollCooldown > 0.15 then
    helperAntiRagdollCooldown = tick()
    forceAntiRagdollReset()
  end
end)
end
local UI = {}
local CURSED_RED = Color3.fromRGB(235, 38, 48)
local ACTIVE_GREEN = Color3.fromRGB(45, 214, 96)

local Theme = {
MainBackground = Color3.fromRGB(12, 12, 14),  Background = Color3.fromRGB(20, 20, 23),
Panel          = Color3.fromRGB(28, 28, 32),  Row        = Color3.fromRGB(38, 38, 43),
RowHover       = Color3.fromRGB(50, 50, 57),
Accent         = CURSED_RED, AccentLight = Color3.fromRGB(175, 28, 36),
Green          = ACTIVE_GREEN,
Red            = Color3.fromRGB(226, 72, 80),  Red2 = Color3.fromRGB(190, 54, 62),
Text           = Color3.fromRGB(255, 255, 255), Dim = Color3.fromRGB(138, 138, 150),
Stroke         = Color3.fromRGB(44, 44, 50),
SoftButton     = Color3.fromRGB(38, 38, 43),  SoftButtonHover = Color3.fromRGB(50, 50, 57),
SoftAccent     = Color3.fromRGB(42, 18, 20),
ToggleOff      = Color3.fromRGB(58, 58, 66),  ToggleOff2 = Color3.fromRGB(30, 30, 34),
InputBg        = Color3.fromRGB(16, 16, 19),  SliderBg = Color3.fromRGB(44, 44, 50),
}

local T = {
bg = 