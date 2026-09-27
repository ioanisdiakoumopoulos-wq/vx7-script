= false, nil end
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
  if not moved and delta.Magnitude < THRESHOLD then return end
  moved = true
  local scale = math.max(GlobalScale.Scale, 0.01)
  Launcher.Position = UDim2.new(
  startPos.X.Scale, startPos.X.Offset + delta.X / scale,
  startPos.Y.Scale, startPos.Y.Offset + delta.Y / scale
  )
end)
end

UserInputService.InputBegan:Connect(function(input, processed)
  if processed then return end
  if input.KeyCode == Enum.KeyCode.RightControl then
    GUI.Enabled = not GUI.Enabled
  end
end)

do
  local target = Window.Position
  MenuScale.Scale = cfg.menuScale * 0.94
  Window.Position = UDim2.new(target.X.Scale, target.X.Offset, target.Y.Scale, target.Y.Offset + 18)
  tw(MenuScale, { Scale = cfg.menuScale }, 0.20)
  tw(Window, { Position = target }, 0.20)
end

applyPowerVisual()
bumpSolvedLabel()
logRich('<font color="' .. LOG.acc .. '">CURSED HUB REDEEMER loaded</font>')
logRich('<font color="' .. LOG.dim .. '">deob by Crxkv</font>')
logRich('<font color="' .. LOG.dim .. '">waiting for a code...</font>')

clearCapture = function() _capturedParts = {} end
local function clearBoxWatchers()
  if _boxTextConn then pcall(function() _boxTextConn:Disconnect() end) end
  if _boxAncestryConn then pcall(function() _boxAncestryConn:Disconnect() end) end
  _boxTextConn, _boxAncestryConn, _lastWatchedBox = nil, nil, nil
end
local function watchBox(box)
  if not box or _lastWatchedBox == box then return end
  clearBoxWatchers()
  _lastWatchedBox = box
  if box.Text ~= "" then _lastNonBlankText = box.Text end
  _boxTextConn = box:GetPropertyChangedSignal("Text"):Connect(function()
    if box.Text == "" then clearCapture() else _lastNonBlankText = box.Text end
  end)
_boxAncestryConn = box.AncestryChanged:Connect(function(_, parent)
  if not parent then clearCapture() clearBoxWatchers() end
end)
end

clearPending = function()
  _pendingToken += 1
  _pendingText, _pendingBox, _pendingUntil = nil, nil, 0
end

rememberPending = function(box, text, replaceExisting)
  if not text or text == "" then return end
  if not replaceExisting and _pendingText and os.clock() <= _pendingUntil then return end
  _pendingToken += 1
  local token = _pendingToken
  _pendingText, _pendingBox = text, box
  _pendingUntil = os.clock() + 8
  task.delay(8, function()
    if token == _pendingToken then clearPending() end
  end)
end
local function restoreRejected(box, text)
  if not cfg.retypeInvalid or not text or text == "" then return false end
  RunService.Heartbeat:Wait()
  local target = currentCodeBox() or box
  if not target or not isVisibleChain(target) then return false end
  local ok = pcall(function() target.Text = text end)
  if ok then
    _lastBox = target
    watchBox(target)
  end
return ok
end

handleFeedback = function(text, sourceObject)
  if not _pendingText then return end
  if os.clock() > _pendingUntil then clearPending() return end
  if sourceObject and sourceObject:IsDescendantOf(GUI) then return end
  local lower = tostring(text or ""):lower()
  local rejected = lower:find("invalid code", 1, true)
  or lower:find("code is invalid", 1, true)
  or lower:find("expired", 1, true)
  or lower:find("already redeemed", 1, true)
  or lower:find("already used", 1, true)
  or lower:find("doesn't exist", 1, true)
  or lower:find("does not exist", 1, true)
  or lower:find("not found", 1, true)
  or lower:find("rejected", 1, true)
  or lower:find("wrong code", 1, true)
  or lower:find("code failed", 1, true)
  local accepted = lower:find("code redeemed", 1, true)
  or lower:find("redeemed successfully", 1, true)
  or lower:find("successfully redeemed", 1, true)
  or lower:find("code accepted", 1, true)
  or lower:find("reward claimed", 1, true)
  or lower:find("code claimed", 1, true)
  or lower:find("success", 1, true)
  or lower == "redeemed"
  if not rejected and not accepted then return end
  local previousText, previousBox = _pendingText, _pendingBox
  if accepted and not rejected then
    clearPending()
    setStatus("VALID  •  " .. previousText, LOG.ok)
    return
  end
local restored = false
if cfg.retypeInvalid then
  restored = restoreRejected(previousBox, previousText)
end
clearPending()
if restored then
  setStatus("INVALID  •  " .. previousText .. "  (retyped)", LOG.warn)
else
setStatus("INVALID  •  " .. previousText, LOG.err)
end
end

appendToBox = function(text)
  if not text or text == "" then return end
  if _lastWatchedBox and not isVisibleChain(_lastWatchedBox) then
    clearCapture()
    clearBoxWatchers()
  end
local box = currentCodeBox()
_capturedParts[#_capturedParts + 1] = text
local combined = table.concat(_capturedParts)
local count = #_capturedParts

if UI.CodeBox then
  UI.CodeBox.Text = combined
end
if box then
  _lastBox = box
  watchBox(box)
  local wasFocused = UserInputService:GetFocusedTextBox() == box
  pcall(function() box.Text = combined end)
  if wasFocused then
    pcall(function()
      local caret = #combined + 1
      box.CursorPosition = caret
      box.SelectionStart = caret
    end)
end
end

logRich('<font color="' .. LOG.dim .. '">code ' .. count .. "/" .. cfg.submitAfter
.. ': </font><font color="' .. LOG.ok .. '">' .. combined .. "</font>")

if count >= cfg.submitAfter then
  _capturedParts = {}
  if cfg.autoSubmit then
    rememberPending(box, combined, true)
    local ok, message = typeAndSubmitCode(combined)
    if ok then
      setStatus("SUBMITTED  •  " .. combined .. "  (checking...)", LOG.white)
    else
    local restored = restoreRejected(box, combined)
    clearPending()
    if restored then
      setStatus("FAILED  •  " .. combined .. "  (retyped)", LOG.warn)
    else
    setStatus("FAILED  •  " .. combined .. "  (" .. tostring(message) .. ")", LOG.err)
  end
end
end
end
end
local function runRiddle(question)
  _askedCount += 1
  bumpSolvedLabel()

  logRich('<font color="' .. LOG.dim .. '">riddle: </font>'
  .. '<font color="' .. LOG.white .. '">' .. question:sub(1, 90) .. "</font>")

  local answer, breakdown, note
  local apiAnswer, apiError = solveRiddleWithApi(question)
  if apiAnswer then
    answer = apiAnswer
    breakdown = { "AI = " .. apiAnswer }
    note = "Groq AI"
  else
  answer, breakdown, note = solveRiddle(question)
  if apiError then
    logRich('<font color="' .. LOG.warn .. '">  ' .. apiError .. ' • local fallback</font>')
  end
end
if breakdown then
  for _, line in ipairs(breakdown) do
    local colour = line:sub(-1) == "?" and LOG.err or LOG.dim
    logRich('<font color="' .. colour .. '">  ' .. line .. "</font>")
  end
end
if not answer or answer == "" then
  logRich('<font color="' .. LOG.err .. '">  ' .. tostring(note or "not in database") .. "</font>")
  return
end

_solvedCount += 1
bumpSolvedLabel()
logRich('<font color="' .. LOG.dim .. '">  answer: </font><font color="' .. LOG.ok .. '">' .. answer .. "</font>")
if note then
  logRich('<font color="' .. LOG.warn .. '">  ' .. note .. "</font>")
end
if UI.CodeBox then
  UI.CodeBox.Text = answer
end
if cfg.autoSubmit then
  local ok, message = typeAndSubmitCode(answer)
  logRich('<font color="' .. LOG.dim .. '">  ' .. (ok and message or ("submit failed: " .. tostring(message))) .. "</font>")
else
logRich('<font color="' .. LOG.dim .. '">  auto submit is off, not sent</font>')
end
end
local function pumpQueue()
  if _riddleBusy then return end
  _riddleBusy = true
  task.spawn(function()
    while #_riddleQueue > 0 do
      local question = table.remove(_riddleQueue, 1)
      pcall(runRiddle, question)
    end
  _riddleBusy = false
end)
end
local funct