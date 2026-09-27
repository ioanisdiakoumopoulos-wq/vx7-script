then return nil, "bad API response" end
local choice = decoded.choices and decoded.choices[1]
local message = choice and choice.message
local answer = cleanApiAnswer(message and message.content, question)
if not answer then return nil, "empty API answer" end
return answer
end
local QUESTION_STARTERS = {
"what", "whats", "who", "whos", "when", "where", "which", "how",
"name", "tell", "type", "say", "guess", "answer", "riddle", "spell",
}

local function looksLikeRiddle(text)
  local l = basicClean(text)
  if l == "" then return false end
  if not l:find(" ") then return false end
  if l:find("?", 1, true) then return true end
  local firstWord = l:match("^(%S+)")
  for _, starter in ipairs(QUESTION_STARTERS) do
    if firstWord == starter then return true end
  end
if l:find("%f[%a]my%f[%A]") and (l:find("%f[%a]and%f[%A]") or l:find("favorite") or l:find("favourite")) then
  return true
end
if l:find("favorite") or l:find("favourite") then return true end
return false
end
local function isOurGui(instance)
  local node = instance
  for _ = 1, 12 do
    if not node then break end
    if node.Name == UI_NAME then return true end
    node = node.Parent
  end
return false
end
local function isVisibleChain(inst)
  local node = inst
  while node do
    if node:IsA("GuiObject") and not node.Visible then return false end
    if node:IsA("ScreenGui") then return node.Enabled end
    node = node.Parent
  end
return true
end
local function findAllTextBoxes(pg)
  local boxes = {}
  for _, gui in ipairs(pg:GetChildren()) do
    if gui:IsA("ScreenGui") and gui.Enabled and not isOurGui(gui) then
      for _, d in ipairs(gui:GetDescendants()) do
        if d:IsA("TextBox") and not isOurGui(d) then boxes[#boxes + 1] = d end
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
          if (n:find("code") or n:find("redeem") or pn:find("code") or pn:find("redeem"))
          and isVisibleChain(d) then
            btns[#btns + 1] = d
          end
      end
  end
end
end
return btns
end
local function fireConnections(signal, ...)
  if typeof(getconns) ~= "function" then return false end
  local ok, connections = pcall(getconns, signal)
  if not ok or type(connections) ~= "table" then return false end
  local args = table.pack(...)
  local fired = false
  for _, connection in ipairs(connections) do
    local fireOk = pcall(function()
      if connection.Enabled ~= false then
        if args.n > 0 then connection:Fire(table.unpack(args, 1, args.n))
        else connection:Fire() end
    end
end)
fired = fired or fireOk
end
return fired
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
      local fOk = pcall(function()
        if c.Enabled ~= false then c:Fire(true) end
      end)
    anyFired = anyFired or fOk
  end
end
end
return anyFired
end
local function releaseFocus(box)
  pcall(function() box:ReleaseFocus(false) end)
  pcall(function()
    local vim = game:GetService("VirtualInputManager")
    if vim then
      vim:SendMouseButtonEvent(0, 0, 0, true, game, 0)
      task.wait(0.03)
      vim:SendMouseButtonEvent(0, 0, 0, false, game, 0)
    end
end)
pcall(function() box:ReleaseFocus(false) end)
end
local RedeemCache = { box = nil, button = nil, frame = nil }

local function writeCodeToBox(box, code)
  if not box then return false end
  pcall(function()
    box.Text = code
  end)
return box.Text == code
end
local function cacheStillValid()
  local box, frame = RedeemCache.box, RedeemCache.frame
  return box and box.Parent and frame and frame.Parent
end
local function currentCodeBox()
  if cacheStillValid() then return RedeemCache.box end
  local pg = playerGui or player:FindFirstChildOfClass("PlayerGui")
  if not pg then return nil end
  local codesGui = pg:FindFirstChild("Codes")
  if codesGui then
    local codesFrame = codesGui:FindFirstChild("Codes") or codesGui
    local redeem = codesFrame and codesFrame:FindFirstChild("CodeRedeem")
    local exact = redeem and redeem:FindFirstChild("TextBox")
    if exact and exact:IsA("TextBox") then
      RedeemCache.box = exact
      RedeemCache.frame = codesFrame
      return exact
    end
  for _, d in ipairs(codesGui:GetDescendants()) do
    if d:IsA("TextBox") and not isOurGui(d) then
      RedeemCache.box = d
      RedeemCache.frame = codesFrame
      return d
    end
end
end
for _, box in ipairs(findAllTextBoxes(pg)) do
  if isVisibleChain(box) then return box end
end
return nil
end
local function findSubmitButton(box)
  if not box then return nil end
  local names = { "submit", "redeem", "claim", "confirm", "enter", "send", "apply", "ok", "use", "go", "check" }
  local node = box.Parent
  for _ = 1, 8 do
    if not node then break end
    for _, d in ipairs(node:GetDescendants()) do
      if (d:IsA("TextButton") or d:IsA("ImageButton")) and not isOurGui(d) and d ~= box then
        local n = d.Name:lower()
        local txt = ""
        pcall(function() txt = tostring(d.Text):lower() end)
        for _, key in ipairs(names) do
          if (n:find(key) or txt:find(key)) and isVisibleChain(d) then return d end
        end
    end
end
node = node.Parent
end
return nil
end

typeAndSubmitCode = function(code)
  if not player then return false, "no LP" end
  local pg = player:FindFirstChildOfClass("PlayerGui")
  if not pg then return false, "no PlayerGui" end

  code = tostring(code or "")
  if code == "" then return false, "empty code" end
  local codesGui = pg:FindFirstChild("Codes")
  if codesGui then
    if codesGui:IsA("ScreenGui") then
      codesGui.Enabled = true
    end
  local codesFrame = codesGui:FindFirstChild("Codes") or codesGui
  if codesFrame then
    if codesFrame:IsA("GuiObject") then
      codesFrame.Visible = true
   