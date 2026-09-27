d
local clean = upperClean(answer)
if clean == "" or clean == "AND" or clean:find("ATTHEEND") or clean:find("ATTHESTART") then
  return nil
end
return times and string.rep(clean, times) or clean
end
local function solveRiddle(text)
  local suffix = trailingSuffixNumber(text)
  local parts = splitQuestions(text)
  local breakdown = {}
  local head, middle, tail = {}, {}, {}
  local missing = 0

  for _, rawPart in ipairs(parts) do
    local part, placement = extractPlacement(rawPart)
    local ok, result = pcall(resolvePart, part)
    if ok and result and result ~= "" then
      local bucket = (placement == "start" and head) or (placement == "end" and tail) or middle
    bucket[#bucket + 1] = result
    breakdown[#breakdown + 1] = part:sub(1, 30) .. " = " .. result
  else

  missing = missing + 1
  breakdown[#breakdown + 1] = part:sub(1, 30) .. " = ?"
end
end
local answers = {}
for _, list in ipairs({ head, middle, tail }) do
  for _, value in ipairs(list) do answers[#answers + 1] = value end
end
if #answers == 0 then
  return nil, breakdown, "not in database"
end
local out = table.concat(answers, "")
if suffix and out:sub(-#suffix) ~= suffix then out = out .. suffix end
return out, breakdown, (missing > 0) and (missing .. (missing == 1 and " part" or " parts") .. " not in database") or nil
end
local RIDDLE_API_KEY = ""
local RIDDLE_API_URL = ""
local RIDDLE_API_MODEL = "openai/gpt-oss-120b"
local _riddleKnowledgeCache, _riddleSystemCache

local function executorRequest()
  local candidates = {
  rawget(env, "request"), rawget(env, "http_request"), rawget(env, "httprequest"),
  rawget(_G, "request"), rawget(_G, "http_request"), rawget(_G, "httprequest"),
}
local synTable = rawget(env, "syn") or rawget(_G, "syn")
if type(synTable) == "table" then candidates[#candidates + 1] = synTable.request end
local httpTable = rawget(env, "http") or rawget(_G, "http")
if type(httpTable) == "table" then candidates[#candidates + 1] = httpTable.request end
for _, candidate in ipairs(candidates) do
  if type(candidate) == "function" then return candidate end
end
return nil
end
local function riddleKnowledge()
  if _riddleKnowledgeCache then return _riddleKnowledgeCache end
  local lines = {}
  for question, answer in pairs(SAB_DB) do
    lines[#lines + 1] = tostring(question) .. " => " .. tostring(answer)
  end
table.sort(lines)
_riddleKnowledgeCache = table.concat(lines, "\n")
return _riddleKnowledgeCache
end
local function riddleSystemPrompt()
  if _riddleSystemCache then return _riddleSystemCache end
  _riddleSystemCache = [[
  You are the CURSED HUB riddle engine for the Roblox game Steal a Brainrot.

  OUTPUT RULE: Return exactly ONE line containing only the final answer. Never add a label, explanation, quote, markdown, punctuation around it, apology, or refusal.

  TYPE 1 is the default: redeem-code riddles. Use it if the question joins parts with AND, PLUS or +, or if any part concerns Steal a Brainrot, its developer Sammy, brainrots, OGs, mutations, traits, rarities, events, machines, items, updates, base skins or personal favorites. Resolve every requested part in order and concatenate exactly one value per part. Use UPPERCASE and remove spaces, apostrophes, hyphens and slashes. Do not omit or repeat a part.

    TYPE 2 is only an ordinary settled real-world question completely unrelated to the game or developer. Return the shortest plain answer in normal writing.

    Important code rules:
    - A named literal word stays that exact word; do not replace it with a synonym.
      - For event names, drop only the generic word EVENT. Keep FUSE, CRAFT, MACHINE and RITUAL when part of a proper name.
      - When asked when game content was added, answer with the MONTH name unless a year is explicitly requested.
      - Never invent a brainrot name. Prefer supplied knowledge.
      - If uncertain, give one best guess anyway.

      Developer facts: real/first/last/nickname SAMMY; Roblox/display/social name SPYDERSAMMY; age 24; born 2002; birthday month FEBRUARY; birth day FRIDAY; birthplace ALGERIA; from/lives in BRAZIL and Sao Paulo; favorite color BLUE; sport FOOTBALL; player RONALDO; food PIZZA; animal SPIDER; number SEVEN; favorite brainrot MEOWL; favorite artist DRAKE; favorite Travis Scott album ASTROWORLD; favorite game ROBLOX; best friend STEAK; least favorite brainrot RACCOONIJANDELINI.

      Official game overrides (these override any conflicting mapping below):
      - Base mutations are Default, Gold, Diamond and Rainbow. They do NOT count when a riddle asks for mutations Sammy added.
        - Added mutation order: BLOODROT, CANDY, LAVA, GALAXY, YINYANG, RADIOACTIVE, CURSED, DIVINE, CYBER, PHANTOM, CRYSTAL. First added mutation is BLOODROT; newest is CRYSTAL.
        - OG order: STRAWBERRYELEPHANT, MEOWL, SKIBIDITOILET, JOHNPORK. John Pork is fourth/newest.
        - First seasonal event is BLOODMOON. Newest supplied seasonal event is CRYSTAL.
        - Lucky Blocks were added in JULY. Steal a Brainrot released MAY 16 2025.
        - Machine sources must stay exact: FIRSTFUSEMACHINE, FIRSTCRAFTMACHINE, DIVINEFUSE, OGFUSE, SUMMERFUSE, SANTASFUSE, WITCHSFUSE, CYBERCRAFT, LIMITEDQUANTITYCRAFT.
        - Griffin comes from DIVINEFUSE. La Supreme Combinasion comes from FIRSTFUSEMACHINE.

        Use the following verified question-to-answer knowledge as reference. Apply the official overrides above whenever there is a conflict:
        ]] .. riddleKnowledge()
        return _riddleSystemCache
      end
    local function isCodeRiddleQuestion(question)
      local q = " " .. tostring(question or ""):lower() .. " "
      if q:find("%s+and%s+") or q:find("%s+plus%s+") or q:find("+", 1, true) then return true end
      for _, word in ipairs({
      "brainrot", "sammy", "spyder", "mutation", "trait", "rarity", "event",
      "machine", "fuse", "craft", "og ", "update", "rebirth", "lucky block",
      "favorite", "favourite", "my name", "my birthday", "steal a brainrot",
    }) do
      if q:find(word, 1, true) then return true end
    end
  return false
end
local function cleanApiAnswer(answer, question)
  local text = tostring(answer or "")
  text = text:gsub("<think>[%s%S]-</think>", "")
  text = trim(text)
  text = text:match("([^\r\n]+)") or text
  text = trim(text):gsub("^```[%w_%-]*", ""):gsub("```$", "")
  text = trim(text):gsub("^[\"'`]+", ""):gsub("[\"'`]+$", "")
  text = text:gsub("^[Aa][Nn][Ss][Ww][Ee][Rr]%s*:%s*", "")
  text = text:gsub("^[Cc][Oo][Dd][Ee]%s*:%s*", "")
  text = trim(text)
  if isCodeRiddleQuestion(question) then text = upperClean(text) end
  if text == "" or #text > 160 then return nil end
  return text
end
local function solveRiddleWithApi(question)
  local key = trim(tostring(RIDDLE_API_KEY or ""))
  if key == "" then return nil, "API key missing" end
  local requestFn = executorRequest()
  if not requestFn then return nil, "executor HTTP request unavailable" end
  if not HttpService then return nil, "HttpService unavailable" end
  local body = HttpService:JSONEncode({
  model = RIDDLE_API_MODEL,
  messages = {
  { role = "system", content = riddleSystemPrompt() },
  { role = "user", content = tostring(question or "") },
},
temperature = 0,
max_completion_tokens = 96,
stream = false,
})
local ok, response = pcall(requestFn, {
Url = RIDDLE_API_URL,
Method = "POST",
Headers = {
["Authorization"] = "Bearer " .. key,
["Content-Type"] = "application/json",
},
Body = body,
})
if not ok or not response then return nil, "API request failed" end
local status, responseBody
if type(response) == "string" then
  status, responseBody = 200, response
else
status = tonumber(response.StatusCode or response.Status or response.status_code) or 0
responseBody = response.Body or response.body
end
if status < 200 or status >= 300 or type(responseBody) ~= "string" then
  return nil, "API HTTP " .. tostring(status)
end
local decodedOk, decoded = pcall(function() return HttpService:JSONDecode(responseBody) end)
if not decodedOk or type(decoded) ~= "table" 