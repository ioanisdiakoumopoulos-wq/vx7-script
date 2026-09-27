ion queueRiddle(question)
  if #_riddleQueue > 6 then return end
  _riddleQueue[#_riddleQueue + 1] = question
  pumpQueue()
end
local function manualRedeemFromMenu()
  local code = trim(UI.CodeBox.Text)
  if code == "" then
    setStatus("type a code first", LOG.warn)
    return
  end
local ok, message = typeAndSubmitCode(code)
if ok then
  setStatus("SUBMITTED  •  " .. code .. "  (checking...)", LOG.white)
  logRich('<font color="' .. LOG.dim .. '">manual redeem: </font><font color="' .. LOG.ok .. '">' .. code .. "</font>")
else
setStatus("FAILED  •  " .. code .. "  (" .. tostring(message) .. ")", LOG.err)
end
end

bindClick(UI.CodeRedeemBtn, manualRedeemFromMenu)
UI.CodeBox.FocusLost:Connect(function(enterPressed)
  if enterPressed then manualRedeemFromMenu() end
end)

bindClick(UI.AskBtn, function()
  local question = trim(UI.AskBox.Text)
  if question == "" then
    setStatus("type a riddle first", LOG.warn)
    return
  end
UI.AskBox.Text = ""
queueRiddle(question)
end)
UI.AskBox.FocusLost:Connect(function(enterPressed)
  if not enterPressed then return end
  local question = trim(UI.AskBox.Text)
  if question == "" then return end
  UI.AskBox.Text = ""
  queueRiddle(question)
end)

local function tokenize(text)
  local words = {}
  for word in text:gmatch("[%w_]+") do words[#words + 1] = word end
  return words
end
local _lastRiddleKey, _lastRiddleAt = "", 0

local function onAnnouncement(...)
  local text = trim(stripRich(tostring((...) or "")))
  if text == "" then return end
  if text:find("%s") then
    if not (cfg.riddleSolver and looksLikeRiddle(text)) then return end
    local key = basicClean(text)
    if key == _lastRiddleKey and tick() - _lastRiddleAt < 5 then return end
    _lastRiddleKey, _lastRiddleAt = key, tick()
    queueRiddle(text)
    return
  end
for _, word in ipairs(tokenize(text)) do
  if word ~= "" and not _seen[word] then
    _seen[word] = true
    task.delay(1.25, function() _seen[word] = nil end)
    appendToBox(word)
  end
end
end
local function resolveNotifyRemote()
  if _G.PhiNotifyRemote then return _G.PhiNotifyRemote end
  local ok, controller = pcall(function()
    if not ReplicatedStorage then return nil end
    local controllers = ReplicatedStorage:FindFirstChild("Controllers")
    local notification = controllers and controllers:FindFirstChild("NotificationController", true)
    if notification then return require(notification) end
    return nil
  end)
if ok and type(controller) == "table" and type(controller.Start) == "function"
  and typeof(getupvalues) == "function" then
      local valuesOk, values = pcall(getupvalues, controller.Start)
      if valuesOk and type(values) == "table" then
        for _, value in pairs(values) do
          if typeof(value) == "Instance"
          and (value:IsA("RemoteEvent") or value:IsA("UnreliableRemoteEvent")) then
            return value
          end
      end
  end
end
local getinfo = debug and (debug.getinfo or debug.info)
local packages = ReplicatedStorage and ReplicatedStorage:FindFirstChild("Packages")
local net = packages and packages:FindFirstChild("Net")
if net and getinfo and getconns then
  for _, d in ipairs(net:GetDescendants()) do
    if d:IsA("RemoteEvent") then
      local okConns, connections = pcall(getconns, d.OnClientEvent)
      if okConns and type(connections) == "table" then
        for _, connection in ipairs(connections) do
          local fnOk, fn = pcall(function() return connection.Function end)
          if fnOk and type(fn) == "function" then
              local infoOk, info = pcall(getinfo, fn)
              if infoOk and info
              and tostring(info.short_src or info.source or ""):find("NotificationController", 1, true) then
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
local listenConn
task.spawn(function()
  local remote = resolveNotifyRemote()
  if remote and (remote:IsA("RemoteEvent") or remote:IsA("UnreliableRemoteEvent")) then
    listenConn = remote.OnClientEvent:Connect(function(...)
      if not cfg.sniper then return end
      pcall(onAnnouncement, ...)
    end)
  logRich('<font color="' .. LOG.dim .. '">listener attached: ' .. remote.Name .. "</font>")
else
UI.LiveDot.BackgroundColor3 = T.err
logRich('<font color="' .. LOG.err .. '">no notify remote, use the box below</font>')
end
end)

local function watchFeedbackObject(obj)
  if not (obj:IsA("TextLabel") or obj:IsA("TextButton")) then return end
  if isOurGui(obj) then return end
  handleFeedback(obj.Text or "", obj)
  obj:GetPropertyChangedSignal("Text"):Connect(function()
    handleFeedback(obj.Text or "", obj)
  end)
end
for _, obj in ipairs(playerGui:GetDescendants()) do pcall(watchFeedbackObject, obj) end
playerGui.DescendantAdded:Connect(function(obj)
  task.wait(0.04)
  pcall(watchFeedbackObject, obj)
end)

UserInputService.TextBoxFocused:Connect(function(box)
  if box:IsDescendantOf(GUI) then return end
  if box ~= currentCodeBox() then return end
  _focused, _lastBox = box, box
  watchBox(box)
end)

UserInputService.TextBoxFocusReleased:Connect(function(box)
  if box:IsDescendantOf(GUI) then return end
  local codeBox = currentCodeBox()
  if box ~= codeBox and box ~= _lastBox then return end
  if cfg.retypeInvalid then
    local submitted = box.Text ~= "" and box.Text or _lastNonBlankText
    rememberPending(box, submitted, false)
  end
if _focused == box then _focused = nil end
end)

local function stopEverything()
  if listenConn then
    pcall(function() listenConn:Disconnect() end)
    listenConn = nil
  end
if viewportConn then pcall(function() viewportConn:Disconnect() end) end
helperAutoBuyActive = false
helperAntiRagdollActive = false
if helperAutoBuyConn then pcall(function() helperAutoBuyConn:Disconnect() end) end
if helperCharacterConn then pcall(function() helperCharacterConn:Disconnect() end) end
if helperAntiRagdollConn then pcall(function() helperAntiRagdollConn:Disconnect() end) end
if helperAnchored then pcall(function() setCharacterAnchored(false) end) end
helperAnchored = false
clearBoxWatchers()
if GUI then pcall(function() GUI:Destroy() end) end
end

env.CursedRedeemerStop = stopEverything
env.Skyr0Stop = stopEverything
env.StopAura = stopEverything
print("prince is the best")