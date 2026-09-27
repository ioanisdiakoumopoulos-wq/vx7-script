local cloneref = cloneref or function(o) return o end
local function svc(name)
  local ok, s = pcall(function() return game:GetService(name) end)
  if not ok or not s then return nil end
  local ok2, r = pcall(cloneref, s)
  if ok2 and r then return r end
  return s
end
local Players           = svc("Players")
local ReplicatedStorage  = svc("ReplicatedStorage")
local RunService         = svc("RunService")
local UserInputService   = svc("UserInputService")
local HttpService        = svc("HttpService")
local TweenService       = svc("TweenService")
local CoreGui            = svc("CoreGui")

local player = Players.LocalPlayer
if not player then
  Players:GetPropertyChangedSignal("LocalPlayer"):Wait()
  player = Players.LocalPlayer
end
local playerGui = player:WaitForChild("PlayerGui")

local env = (typeof(getgenv) == "function" and getgenv()) or _G

  if env.CursedRedeemerStop then pcall(env.CursedRedeemerStop) end
  if env.Skyr0Stop then pcall(env.Skyr0Stop) end
  if env.StopAura then pcall(env.StopAura) end
  if type(env._KatanaConnections) == "table" then
    for _, connection in ipairs(env._KatanaConnections) do
      pcall(function() connection:Disconnect() end)
    end
  env._KatanaConnections = {}
end
local getupvalues = (debug and debug.getupvalues) or getupvalues
local getconns    = getconnections or (debug and debug.getconnections)
local setupv      = (debug and debug.setupvalue) or setupvalue

local CONFIG_FILE = "cursed_hub_code_redeemer.json"
local cfg = {
sniper        = true,
autoSubmit    = true,
submitAfter   = 3,
retypeInvalid = false,
riddleSolver  = true,
redeemDelay   = 0.05,
menuScale     = 1.00,
}

pcall(function()
  if type(isfile) == "function" and type(readfile) == "function" and isfile(CONFIG_FILE) then
        local decoded = HttpService:JSONDecode(readfile(CONFIG_FILE))
        if type(decoded) == "table" then
          for key, value in pairs(cfg) do
            local got = decoded[key]
            if type(got) == type(value) then cfg[key] = got end
          end
        cfg.submitAfter = math.clamp(math.floor(tonumber(cfg.submitAfter) or 3), 1, 5)
        cfg.redeemDelay = math.clamp(tonumber(cfg.redeemDelay) or 0.05, 0.01, 3.00)
        cfg.menuScale = math.clamp(tonumber(cfg.menuScale) or 1.00, 0.70, 1.25)
      end
  end
end)

local function saveConfig()
  if type(writefile) ~= "function" then return end
  pcall(function() writefile(CONFIG_FILE, HttpService:JSONEncode(cfg)) end)
end
local UI_NAME = "CursedHub_CodeRedeemer"

local _seen               = {}
local _capturedParts      = {}
local _lastBox            = nil
local _focused            = nil
local _lastWatchedBox     = nil
local _lastNonBlankText   = ""
local _boxTextConn, _boxAncestryConn
local _pendingText, _pendingBox, _pendingUntil, _pendingToken = nil, nil, 0, 0
local _solvedCount        = 0
local _askedCount         = 0
local _riddleQueue        = {}
local _riddleBusy         = false

local GUI
local logRich, clearLog
local setStatus
local typeAndSubmitCode, appendToBox, clearCapture
local rememberPending, clearPending, handleFeedback
local bumpSolvedLabel, applyPowerVisual

local function trim(s) return (tostring(s or ""):gsub("^%s+", ""):gsub("%s+$", "")) end
local function stripRich(s)
  if type(s) ~= "string" then return tostring(s) end
  return (s:gsub("<[^>]->", ""))
end
local function upperClean(s)
  return (tostring(s or ""):upper():gsub("%s+", ""):gsub("[%?%.%,!\"'`\n\r]", ""))
end
local SAB_DB = {

["real name"]                   = "SAMMY",
["sammy real name"]             = "SAMMY",
["sammys real name"]            = "SAMMY",
["my real name"]                = "SAMMY",
["creator real name"]           = "SAMMY",
["owner real name"]             = "SAMMY",
["creator name"]                = "SAMMY",
["who created sab"]             = "SAMMY",
["who made sab"]                = "SAMMY",
["who made steal a brainrot"]   = "SAMMY",
["who is the owner"]            = "SAMMY",
["who owns sab"]                = "SAMMY",
["owner"]                       = "SAMMY",
["creator"]                     = "SAMMY",
["name"]                        = "SAMMY",
["my name"]                     = "SAMMY",
["sammy name"]                  = "SAMMY",
["sammys name"]                 = "SAMMY",
["game owner"]                  = "SAMMY",
["developer"]                   = "SAMMY",
["dev"]                         = "SAMMY",
["made by"]                     = "SAMMY",
["created by"]                  = "SAMMY",
["made this game"]              = "SAMMY",
["real name of sammy"]          = "SAMMY",
["roblox username"]             = "SPYDERSAMMY",
["my roblox username"]          = "SPYDERSAMMY",
["sammy username"]              = "SPYDERSAMMY",
["sammy roblox name"]           = "SPYDERSAMMY",
["roblox name"]                 = "SPYDERSAMMY",
["username"]                    = "SPYDERSAMMY",
["my username"]                 = "SPYDERSAMMY",
["roblox"]                      = "SPYDERSAMMY",
["channel"]                     = "SPYDERSAMMY",
["handle"]                      = "SPYDERSAMMY",

["how old am i"]                = "24",
["how old is sammy"]            = "24",
["my age"]                      = "24",
["sammy age"]                   = "24",
["age"]                         = "24",
["birth year"]                  = "2002",
["year born"]                   = "2002",
["year i was born"]             = "2002",
["born year"]                   = "2002",
["birth day"]                   = "FRIDAY",
["day i was born"]              = "FRIDAY",
["day born"]                    = "FRIDAY",
["birthday"]                    = "FRIDAY",
["born on"]                     = "FRIDAY",
["birth month"]                 = "FEBRUARY",
["month born"]                  = "FEBRUARY",
["month i was born"]            = "FEBRUARY",
["where was i born"]            = "ALGERIA",
["where was i born at"]         = "ALGERIA",
["birthplace"]                  = "ALGERIA",
["where i was born"]            = "ALGERIA",

["where am i from"]             = "BRAZIL",
["where is sammy from"]         = "BRAZIL",
["my country"]                  = "BRAZIL",
["sammy country"]               = "BRAZIL",
["country"]                     = "BRAZIL",
["where do i live"]             = "BRAZIL",
  ["where does sammy live"]       = "BRAZIL",
  ["sammy location"]              = "BRAZIL",
  ["location"]                    = "BRAZIL",
  ["from"]                        = "BRAZIL",
  ["birth country"]               = "BRAZIL",
  ["born in"]                     = "BRAZIL",
  ["lives in"]                    = "BRAZIL",
  ["comes from"]                  = "BRAZIL",
  ["nationality"]                 = "BRAZILIAN",
  ["sammy nationality"]           = "BRAZILIAN",
  ["my nationality"]              = "BRAZILIAN",
  ["state"]                       = "SAOPAULO",
  ["my state"]                    = "SAOPAULO",
  ["sammy state"]                 = "SAOPAULO",
  ["city"]                        = "SAOPAULO",
  ["my city"]                     = "SAOPAULO",
  ["sammy city"]                  = "SAOPAULO",

  ["favorite color"]              = "BLUE",
  ["my color"]                    = "BLUE",
  ["sammy color"]                 = "BLUE",
  ["color"]                       = "BLUE",
  ["favorite color is blue"]      = "BLUE",
  ["color is blue"]               = "BLUE",
  ["favorite sport"]              = "FOOTBALL",
  ["sport"]                       = "FOOTBALL",
  ["my sport"]                    = "FOOTBALL",
  ["football"]                    = "FOOTBALL",
  ["favorite football player"]    = "RONALDO",
  ["my favorite football player"] = "RONALDO",
  ["football player"]             = "RONALDO",
  ["favorite player"]             = "RONALDO",
  ["player"]                      = "RONALDO",
  ["ronaldo"]                     = "RONALDO",
  ["favorite food"]               = "PIZZA",
  ["my food"]                     = "PIZZA",
  ["food"]                        = "PIZZA",
  ["favorite meal"]               = "PIZZA",
  ["favorite dish"]               = "PIZZA",
  ["favorite animal"]             = "SPIDER",
  ["my animal"]                   = "SPIDER",
  ["my pet"]                      = "SPIDER",
  ["pet name"]                    = "SPIDER",
  ["sammy pet name"]              = "SPIDER",
  ["pet"]                         = "SPIDER",
  ["animal"]                      = "SPIDER",
  ["favorite game"]               = "ROBLOX",
  ["game"]                        = "ROBLOX",
  ["favorite number"]             = "SEVEN",
  ["lucky number"]                = "SEVEN",
  ["number"]                      = "SEVEN",
  ["social media"]                = "YOUTUBE",
  ["youtube channel"]             = "SPYDERSAMMY",
  ["my youtube"]                  = "SPYDERSAMMY",
  ["sammy youtube"]               = "SPYDERSAMMY",
  ["youtube"]                     = "SPYDERSAMMY",
  ["discord"]                     = "ACE",
  ["discord server"]              = "ACE",
  ["sammy discord"]               = "SPYDERSAMMY",
  ["twitter"]                     = "SPYDERSAMMY",
  ["sammy twitter"]               = "SPYDERSAMMY",
  ["x account"]                   = "SPYDERSAMMY",
  ["tiktok"]                      = "SPYDERSAMMY",
  ["sammy tiktok"]                = "SPYDERSAMMY",
  ["instagram"]                   = "SPYDERSAMMY",

  ["game created on"]             = "FRIDAY",
  ["created on"]                  = "FRIDAY",
  ["what day was the game created"] = "FRIDAY",
  ["what day was sab created"]    = "FRIDAY",
  ["game creation day"]           = "FRIDAY",
  ["release month"]               = "MAY",
  ["release year"]                = "2025",
  ["year sab was created"]        = "2025",
  ["what year was sab created"]   = "2025",
  ["what year was the game created"] = "2025",
  ["year the game was created"]   = "2025",
  ["year sab was made"]           = "2025",
  ["month sab was made"]          = "MAY",
  ["month the game was made"]     = "MAY",
  ["month sab was released"]      = "MAY",
  ["what month was sab made"]     = "MAY",
  ["what month was sab released"] = "MAY",
  ["sab release month"]           = "MAY",
  ["day sab was made"]            = "FRIDAY",
  ["day sab was released"]        = "FRIDAY",
  ["what day was sab made"]       = "FRIDAY",
  ["what day was sab released"]   = "FRIDAY",
  ["sab release day"]             = "FRIDAY",
  ["game made on"]                = "FRIDAY",
  ["sab made on"]                 = "FRIDAY",
  ["day game released"]           = "FRIDAY",
  ["day sab released"]            = "FRIDAY",
  ["release day"]                 = "FRIDAY",
  ["day released"]                = "FRIDAY",
  ["what day was it released"]    = "FRIDAY",
  ["what day was it created"]     = "FRIDAY",
  ["year the game was made"]      = "2025",
  ["year made"]                   = "2025",
  ["year created"]                = "2025",
  ["what year was sab made"]      = "2025",
  ["year of sab"]                 = "2025",
  ["sab creation year"]           = "2025",
  ["creation year"]               = "2025",
  ["when was sab made"]           = "MAY162025",
  ["when made"]                   = "MAY162025",
  ["date made"]                   = "MAY162025",
  ["when was sab created"]        = "MAY162025",
  ["release date"]                = "MAY162025",
  ["when was sab released"]       = "MAY162025",
  ["when was the game released"]  = "MAY162025",
  ["game release date"]           = "MAY162025",
  ["game release"]                = "MAY162025",
  ["sab release"]                 = "MAY162025",
  ["game released"]               = "MAY162025",
  ["sab released"]                = "MAY162025",
  ["when created"]                = "MAY162025",
  ["when released"]               = "MAY162025",
  ["date released"]               = "MAY162025",
  ["date created"]                = "MAY162025",

  ["my name twice"]               = "SAMMYSAMMY",
  ["my name 2 times"]             = "SAMMYSAMMY",
  ["my name 3 times"]             = "SAMMYSAMMYSAMMY",
  ["name twice"]                  = "SAMMYSAMMY",
  ["owner twice"]                 = "SAMMYSAMMY",
  ["creator twice"]               = "SAMMYSAMMY",
  ["my age twice"]                = "2424",
  ["my age 2 times"]              = "2424",
  ["my age 3 times"]              = "242424",
  ["favorite color twice"]        = "BLUEBLUE",
  ["favorite color 2 times"]      = "BLUEBLUE",
  ["favorite color 3 times"]      = "BLUEBLUEBLUE",
  ["favorite color three times"]  = "BLUEBLUEBLUE",
  ["favorite color 5 times"]      = "BLUEBLUEBLUEBLUEBLUE",
  ["my favorite color twice"]     = "BLUEBLUE",
  ["my favorite color 2 times"]   = "BLUEBLUE",
  ["my favorite color 3 times"]   = "BLUEBLUEBLUE",
  ["favorite sport twice"]        = "FOOTBALLFOOTBALL",
  ["favorite food twice"]         = "PIZZAPIZZA",

  ["first trait"]                 = "LIGHTNING",
  ["1st trait"]                   = "LIGHTNING",
  ["first trait created"]         = "LIGHTNING",
  ["1st trait created"]           = "LIGHTNING",
  ["first trait added"]           = "BUBBLEGUM",
  ["trait added first"]           = "BUBBLEGUM",
  ["trait first added"]           = "BUBBLEGUM",
  ["what trait"]                  = "LIGHTNING",
  ["trait"]                       = "LIGHTNING",
  ["trait you get when struck by lightning"] = "MATEO",
  ["struck by lightning"]         = "MATEO",
  ["lightning trait"]             = "MATEO",
  ["trait from lightning"]        = "MATEO",
  ["trait when struck by lightning"] = "MATEO",
  ["lightning strike trait"]      = "MATEO",
  ["get struck by lightning"]     = "MATEO",
  ["lightning gives"]             = "MATEO",
  ["struck by lightning trait"]   = "MATEO",
  ["lightning"]                   = "MATEO",
  ["mateo"]                       = "MATEO",

  ["first mutation"]              = "BLOODROT",
  ["1st mutation"]                = "BLOODROT",
  ["second mutation"]             = "CANDY",
  ["2nd mutation"]                = "CANDY",
  ["third mutation"]              = "LAVA",
  ["3rd mutation"]                = "LAVA",
  ["fourth mutation"]             = "GALAXY",
  ["4th mutation"]                = "GALAXY",
  ["fifth mutation"]              = "YINYANG",
  ["5th mutation"]                = "YINYANG",
  ["sixth mutation"]              = "RADIOACTIVE",
  ["6th mutation"]                = "RADIOACTIVE",
  ["seventh mutation"]            = "CURSED",
  ["7th mutation"]                = "CURSED",
  ["eighth mutation"]             = "DIVINE",
  ["8th mutation"]                = "DIVINE",
  ["ninth mutation"]              = "CYBER",
  ["9th mutation"]                = "CYBER",
  ["tenth mutation"]              = "PHANTOM",
  ["10th mutation"]               = "PHANTOM",
  ["eleventh mutation"]           = "CRYSTAL",
  ["11th mutation"]               = "CRYSTAL",
  ["mutation 1"]  = "BLOODROT",    ["mutation number 1"]  = "BLOODROT",
  ["mutation 2"]  = "CANDY",       ["mutation number 2"]  = "CANDY",
  ["mutation 3"]  = "LAVA",        ["mutation number 3"]  = "LAVA",
  ["mutation 4"]  = "GALAXY",      ["mutation number 4"]  = "GALAXY",
  ["mutation 5"]  = "YINYANG",     ["mutation number 5"]  = "YINYANG",
  ["mutation 6"]  = "RADIOACTIVE", ["mutation number 6"]  = "RADIOACTIVE",
  ["mutation 7"]  = "CURSED",      ["mutation number 7"]  = "CURSED",
  ["mutation 8"]  = "DIVINE",      ["mutation number 8"]  = "DIVINE",
  ["mutation 9"]  = "CYBER",       ["mutation number 9"]  = "CYBER",
  ["mutation 10"] = "PHANTOM",     ["mutation number 10"] = "PHANTOM",
  ["mutation 11"] = "CRYSTAL",     ["mutation number 11"] = "CRYSTAL",
  ["evil mutation"]               = "CURSED",
  ["evil"]                        = "CURSED",
  ["cursed mutation"]             = "CURSED",
  ["angelic mutation"]            = "DIVINE",
  ["angelic"]                     = "DIVINE",
  ["divine mutation"]             = "DIVINE",
  ["good mutation"]               = "DIVINE",
  ["best mutation"]               = "DIVINE",
  ["top mutation"]                = "DIVINE",
  ["latest mutation"]             = "CRYSTAL",
  ["most recent mutation"]        = "CRYSTAL",
  ["most recent"]                 = "CRYSTAL",
  ["newest mutation"]             = "CRYSTAL",
  ["last mutation"]               = "CRYSTAL",
  ["divinecursed"]                = "DIVINECURSED",
  ["curseddivine"]                = "CURSEDDIVINE",
  ["green mutation"]              = "RADIOACTIVE",
  ["turns green"]                 = "RADIOACTIVE",
  ["green"]                       = "RADIOACTIVE",
  ["purple mutation"]             = "GALAXY",
  ["turns purple"]                = "GALAXY",
  ["purple"]                      = "GALAXY",
  ["black and white mutation"]    = "YINYANG",
  ["black mutation"]              = "YINYANG",
  ["turns black"]                 = "YINYANG",
  ["black and white"]             = "YINYANG",
  ["yellow mutation"]             = "DIVINE",
  ["turns yellow"]                = "DIVINE",
  ["yellow"]                      = "DIVINE",
  ["red mutation"]                = "CURSED",
  ["turns red"]                   = "CURSED",
  ["red"]                         = "CURSED",
  ["orange mutation"]             = "LAVA",
  ["turns orange"]                = "LAVA",
  ["orange"]                      = "LAVA",
  ["blue mutation"]               = "DIAMOND",
  ["pink mutation"]               = "CANDY",
  ["gold"]                        = "GOLD",
  ["diamond"]                     = "DIAMOND",
  ["bloodrot"]                    = "BLOODROT",
  ["rainbow"]                     = "RAINBOW",
  ["candy"]                       = "CANDY",
  ["lava"]                        = "LAVA",
  ["galaxy"]                      = "GALAXY",
  ["yinyang"]                     = "YINYANG",
  ["radioactive"]                 = "RADIOACTIVE",
  ["cursed"]                      = "CURSED",
  ["divine"]                      = "DIVINE",
  ["cyber"]                       = "CYBER",
  ["phantom"]                     = "PHANTOM",
  ["crystal"]                     = "CRYSTAL",
  ["color of gold mutation"]      = "YELLOW",
  ["color of diamond mutation"]   = "BLUE",
  ["color of bloodrot mutation"]  = "RED",
  ["color of rainbow mutation"]   = "RAINBOW",
  ["color of candy mutation"]     = "PINK",
  ["color of lava mutation"]      = "ORANGE",
  ["color of galaxy mutation"]    = "PURPLE",
  ["color of yinyang mutation"]   = "BLACK",
  ["color of radioactive mutation"] = "GREEN",
  ["color of cursed mutation"]    = "RED",
  ["color of divine mutation"]    = "YELLOW",
  ["color of cyber mutation"]     = "BLUE",
  ["color of phantom mutation"]   = "BLACK",
  ["color of crystal mutation"]   = "BLUEPURPLE",
  ["divine color"]                = "YELLOW",
  ["cursed color"]                = "RED",
  ["radioactive color"]           = "GREEN",
  ["galaxy color"]                = "PURPLE",
  ["yinyang color"]               = "BLACK",
  ["lava color"]                  = "ORANGE",
  ["what number is bloodrot"]     = "1",
  ["what number is candy"]        = "2",
  ["what number is lava"]         = "3",
  ["what number is galaxy"]       = "4",
  ["what number is yinyang"]      = "5",
  ["what number is radioactive"]  = "6",
  ["what number is cursed"]       = "7",
  ["what number is divine"]       = "8",
  ["what number is cyber"]        = "9",
  ["what number is phantom"]      = "10",
  ["what number is crystal"]      = "11",

  ["first machine"]               = "RAINBOWMACHINE",
  ["1st machine"]                 = "RAINBOWMACHINE",
  ["second machine"]              = "BUBBLEGUMMACHINE",
  ["2nd machine"]                 = "BUBBLEGUMMACHINE",
  ["third machine"]               = "FUSEMACHINE",
  ["3rd machine"]                 = "FUSEMACHINE",
  ["fourth machine"]              = "CRAFTMACHINE",
  ["4th machine"]                 = "CRAFTMACHINE",
  ["fifth machine"]               = "WITCHFUSE",
  ["5th machine"]                 = "WITCHFUSE",
  ["sixth machine"]               = "BRAINROTDEALER",
  ["6th machine"]                 = "BRAINROTDEALER",
  ["seventh machine"]             = "BRAINROTTRADER",
  ["7th machine"]                 = "BRAINROTTRADER",
  ["eighth machine"]              = "SANTASFUSE",
  ["8th machine"]                 = "SANTASFUSE",
  ["ninth machine"]               = "SANTASSHOP",
  ["9th machine"]                 = "SANTASSHOP",
  ["tenth machine"]               = "NEWYEARSMACHINE",
  ["10th machine"]                = "NEWYEARSMACHINE",
  ["eleventh machine"]            = "DUELSMACHINE",
  ["11th machine"]                = "DUELSMACHINE",
  ["twelfth machine"]             = "CUPIDSMACHINE",
  ["12th machine"]                = "CUPIDSMACHINE",
  ["thirteenth machine"]          = "TRADEMACHINE",
  ["13th machine"]                = "TRADEMACHINE",
  ["fourteenth machine"]          = "DIVINEFUSE",
  ["14th machine"]                = "DIVINEFUSE",
  ["fifteenth machine"]           = "EGGINCUBATOR",
  ["15th machine"]                = "EGGINCUBATOR",
  ["sixteenth machine"]           = "CYBERCRAFTMACHINE",
  ["16th machine"]                = "CYBERCRAFTMACHINE",
  ["seventeenth machine"]         = "SUMMERFUSE",
  ["17th machine"]                = "SUMMERFUSE",
  ["eighteenth machine"]          = "LOSTRADERS",
  ["18th machine"]                = "LOSTRADERS",
  ["machine 1"]  = "RAINBOWMACHINE",    ["machine number 1"]  = "RAINBOWMACHINE",
  ["machine 2"]  = "BUBBLEGUMMACHINE",  ["machine number 2"]  = "BUBBLEGUMMACHINE",
  ["machine 3"]  = "FUSEMACHINE",       ["machine number 3"]  = "FUSEMACHINE",
  ["machine 4"]  = "CRAFTMACHINE",      ["machine number 4"]  = "CRAFTMACHINE",
  ["machine 5"]  = "WITCHFUSE",         ["machine number 5"]  = "WITCHFUSE",
  ["machine 6"]  = "BRAINROTDEALER",    ["machine number 6"]  = "BRAINROTDEALER",
  ["machine 7"]  = "BRAINROTTRADER",    ["machine number 7"]  = "BRAINROTTRADER",
  ["machine 8"]  = "SANTASFUSE",        ["machine number 8"]  = "SANTASFUSE",
  ["machine 9"]  = "SANTASSHOP",        ["machine number 9"]  = "SANTASSHOP",
  ["machine 10"] = "NEWYEARSMACHINE",   ["machine number 10"] = "NEWYEARSMACHINE",
  ["machine 11"] = "DUELSMACHINE",      ["machine number 11"] = "DUELSMACHINE",
  ["machine 12"] = "CUPIDSMACHINE",     ["machine number 12"] = "CUPIDSMACHINE",
  ["machine 13"] = "TRADEMACHINE",      ["machine number 13"] = "TRADEMACHINE",
  ["machine 14"] = "DIVINEFUSE",        ["machine number 14"] = "DIVINEFUSE",
  ["machine 15"] = "EGGINCUBATOR",      ["machine number 15"] = "EGGINCUBATOR",
  ["machine 16"] = "CYBERCRAFTMACHINE", ["machine number 16"] = "CYBERCRAFTMACHINE",
  ["machine 17"] = "SUMMERFUSE",        ["machine number 17"] = "SUMMERFUSE",
  ["machine 18"] = "LOSTRADERS",        ["machine number 18"] = "LOSTRADERS",
  ["rainbowmachine"]              = "RAINBOWMACHINE",
  ["bubblegummachine"]            = "BUBBLEGUMMACHINE",
  ["fusemachine"]                 = "FUSEMACHINE",
  ["craftmachine"]                = "CRAFTMACHINE",
  ["witchfuse"]                   = "WITCHFUSE",
  ["brainrotdealer"]              = "BRAINROTDEALER",
  ["brainrottrader"]              = "BRAINROTTRADER",
  ["santasfuse"]                  = "SANTASFUSE",
  ["santasshop"]                  = "SANTASSHOP",
  ["newyearsmachine"]             = "NEWYEARSMACHINE",
  ["duelsmachine"]                = "DUELSMACHINE",
  ["cupidsmachine"]               = "CUPIDSMACHINE",
  ["trademachine"]                = "TRADEMACHINE",
  ["divinefuse"]                  = "DIVINEFUSE",
  ["eggincubator"]                = "EGGINCUBATOR",
  ["cybercraftmachine"]           = "CYBERCRAFTMACHINE",
  ["summerfuse"]                  = "SUMMERFUSE",
  ["lostraders"]                  = "LOSTRADERS",
  ["newest machine"]              = "LOSTRADERS",
  ["last machine"]                = "LOSTRADERS",
  ["latest machine"]              = "LOSTRADERS",

  ["og brainrot cannot be obtained"] = "HEADLESSHORSEMAN",
  ["headless horseman"]           = "HEADLESSHORSEMAN",
  ["rarest brainrot"]             = "HEADLESSHORSEMAN",
  ["rarest"]                      = "HEADLESSHORSEMAN",
  ["unobtainable brainrot"]       = "HEADLESSHORSEMAN",
  ["unobtainable"]                = "HEADLESSHORSEMAN",
  ["best brainrot"]               = "STRAWBERRYELEPHANT",
  ["first og added"]              = "STRAWBERRYELEPHANT",
  ["1st og"]                      = "STRAWBERRYELEPHANT",
  ["second og added"]             = "MEOWL",
  ["2nd og"]                      = "MEOWL",
  ["third og added"]              = "SKIBIDITOILET",
  ["3rd og"]                      = "SKIBIDITOILET",
  ["fourth og added"]             = "JOHNPORK",
  ["4th og"]                      = "JOHNPORK",
  ["og 1"]  = "STRAWBERRYELEPHANT", ["og number 1"] = "STRAWBERRYELEPHANT",
  ["og 2"]  = "MEOWL",              ["og number 2"] = "MEOWL",
  ["og 3"]  = "SKIBIDITOILET",      ["og number 3"] = "SKIBIDITOILET",
  ["og 4"]  = "JOHNPORK",           ["og number 4"] = "JOHNPORK",
  ["first brainrot added"]        = "STRAWBERRYELEPHANT",
  ["1st brainrot"]                = "STRAWBERRYELEPHANT",
  ["oldest brainrot"]             = "STRAWBERRYELEPHANT",
  ["worst brainrot"]              = "NOOBINIPIZZANINI",
  ["most common brainrot"]        = "NOOBINIPIZZANINI",
  ["least rare brainrot"]         = "NOOBINIPIZZANINI",
  ["weakest brainrot"]            = "NOOBINIPIZZANINI",
  ["common brainrot"]             = "NOOBINIPIZZANINI",
  ["most popular brainrot"]       = "DRAGONCANNELONNI",
  ["highest rarity"]              = "OG",
  ["rarest rarity"]               = "OG",
  ["top rarity"]                  = "OG",
  ["best rarity"]                 = "OG",
  ["6th rarity"]                  = "OG",
  ["sixth rarity"]                = "OG",
  ["lowest rarity"]               = "COMMON",
  ["worst rarity"]                = "COMMON",
  ["common rarity"]               = "COMMON",
  ["1st rarity"]                  = "COMMON",
  ["second rarity"]               = "UNCOMMON",
  ["2nd rarity"]                  = "UNCOMMON",
  ["third rarity"]                = "RARE",
  ["3rd rarity"]                  = "RARE",
  ["fourth rarity"]               = "EPIC",
  ["4th rarity"]                  = "EPIC",
  ["fifth rarity"]                = "LEGENDARY",
  ["5th rarity"]                  = "LEGENDARY",
  ["uncommon"]                    = "UNCOMMON",
  ["rare"]                        = "RARE",
  ["epic"]                        = "EPIC",
  ["legendary"]                   = "LEGENDARY",
  ["og"]                          = "OG",
  ["common"]                      = "COMMON",

  ["fire represents"]             = "DRAGON",
  ["fire stands for"]             = "DRAGON",
  ["fire symbol"]                 = "DRAGON",
  ["fire meaning"]                = "DRAGON",
  ["fire brainrot"]               = "DRAGON",
  ["fire"]                        = "DRAGON",
  ["dragon"]                      = "DRAGON",
  ["won the world cup"]           = "SPAIN",
  ["world cup winner"]            = "SPAIN",
  ["world cup"]                   = "SPAIN",
  ["won world cup"]               = "SPAIN",
  ["football world cup"]          = "SPAIN",
  ["worst game owner"]            = "SECRETLOKII",
  ["most boring game owner"]      = "SECRETLOKII",
  ["worst owner"]                 = "SECRETLOKII",
  ["boring owner"]                = "SECRETLOKII",
  ["most boring owner"]           = "SECRETLOKII",
  ["most boring game on roblox"]  = "KEYBOARDESCAPE",
  ["boring game"]                 = "KEYBOARDESCAPE",
  ["most boring game"]            = "KEYBOARDESCAPE",
  ["boring roblox game"]          = "KEYBOARDESCAPE",
  ["spawned during admin abuse war"] = "RACOONINIJANDELINI",
  ["admin war brainrot"]          = "RACOONINIJANDELINI",
  ["spawned in admin war"]        = "RACOONINIJANDELINI",
  ["who did i fight in the admin abuse war"] = "JANDEL",
  ["fought in admin abuse war"]   = "JANDEL",
  ["who did sammy fight"]         = "JANDEL",
  ["sammy fought"]                = "JANDEL",
  ["fight in admin war"]          = "JANDEL",
  ["won the admin abuse war"]     = "GROWAGARDEN",
  ["admin abuse war"]             = "GROWAGARDEN",
  ["who won admin war"]           = "GROWAGARDEN",
  ["admin war winner"]            = "GROWAGARDEN",
  ["admin war"]                   = "GROWAGARDEN",
  ["worst secret"]                = "KARKERKARKURKUR",
  ["secret"]                      = "KARKERKARKURKUR",
  ["bad secret"]                  = "KARKERKARKURKUR",
  ["maximum server size"]         = "EIGHT",
  ["max server size"]             = "EIGHT",
  ["server size"]                 = "EIGHT",
  ["how many players"]            = "EIGHT",
  ["max players"]                 = "EIGHT",
  ["players"]                     = "EIGHT",
  ["player count"]                = "EIGHT",
  ["server"]                      = "EIGHT",
  ["how many players in server"]  = "EIGHT",
  ["server capacity"]             = "EIGHT",
  ["players per server"]          = "EIGHT",
  ["max server"]                  = "EIGHT",
  ["brother of hydra bunny"]      = "CERBERUS",
  ["hydra bunny brother"]         = "CERBERUS",
  ["hydra bunny"]                 = "CERBERUS",
  ["cerberus brother"]            = "CERBERUS",
  ["brother of hydra"]            = "CERBERUS",
  ["brother"]                     = "CERBERUS",
  ["cerberus"]                    = "CERBERUS",

  ["game name"]                   = "STEALABRAINROT",
  ["name of the game"]            = "STEALABRAINROT",
  ["sab"]                         = "STEALABRAINROT",
  ["sab stands for"]              = "STEALABRAINROT",
  ["full name"]                   = "STEALABRAINROT",
  ["what is sab"]                 = "STEALABRAINROT",
  ["steal a brainrot"]            = "STEALABRAINROT",
  ["full game name"]              = "STEALABRAINROT",
  ["game full name"]              = "STEALABRAINROT",
  ["sab full name"]               = "STEALABRAINROT",
  ["number of mutations"]         = "14",
  ["how many mutations"]          = "14",
  ["total mutations"]             = "THIRTEEN",
  ["mutation count"]              = "THIRTEEN",
  ["number of machines"]          = "18",
  ["how many machines"]           = "18",
  ["total machines"]              = "18",
  ["machine count"]               = "EIGHTEEN",
  ["total rarities"]              = "SIX",
  ["how many rarities"]           = "SIX",
  ["number of rarities"]          = "SIX",
  ["rarities"]                    = "SIX",
  ["rarity count"]                = "SIX",
  ["brainrot count"]              = "THIRTEEN",
  ["how many brainrots"]          = "THIRTEEN",
  ["number brainrots"]            = "THIRTEEN",
  ["how many og brainrots"]       = "FIVE",
  ["total og brainrots"]          = "FIVE",
  ["og count"]                    = "FIVE",
  ["type of game"]                = "SIMULATOR",
  ["game genre"]                  = "SIMULATOR",
  ["genre"]                       = "SIMULATOR",
  ["game type"]                   = "SIMULATOR",
  ["what type"]                   = "SIMULATOR",
  ["sab genre"]                   = "SIMULATOR",
  ["sab type"]                    = "SIMULATOR",
  ["first update"]                = "MUTATIONS",
  ["1st update"]                  = "MUTATIONS",
  ["update"]                      = "MUTATIONS",

  ["favorite color favorite sport"]   = "BLUEFOOTBALL",
  ["favorite color favorite animal"]  = "BLUESPIDER",
  ["favorite color favorite food"]    = "BLUEPIZZA",
  ["favorite color favorite player"]  = "BLUERONALDO",
  ["favorite color creator"]          = "BLUESAMMY",
  ["favorite color owner"]            = "BLUESAMMY",
  ["favorite color username"]         = "BLUESPYDERSAMMY",
  ["favorite sport favorite player"]  = "FOOTBALLRONALDO",
  ["favorite sport favorite animal"]  = "FOOTBALLSPIDER",
  ["name favorite food"]              = "SAMMYPIZZA",
  ["name favorite color"]             = "SAMMYBLUE",
}

local WORD_ALIAS = {
favourite = "favorite", fav = "favorite", favorites = "favorite",
colour = "color", colours = "color", colors = "color",
whats = "what is", ["what's"] = "what is",
whos = "who is", ["who's"] = "who is",
wheres = "where is", whens = "when is",
u = "you", ur = "your", pls = "", please = "",
["sammy's"] = "sammys", ["i'm"] = "i am",
}

local FILLERS = {
"what is", "what are", "what was", "what were", "what do", "what does",
  "who is", "who was", "who are", "when is", "when was", "where is",
  "where are", "how old", "how many", "how much", "do you know",
    "can you tell me", "can you tell", "tell me", "i need", "give me",
    "answer me", "say", "type", "write", "the answer to", "question",
    "am i", "do i", "did i", "have i", "is my", "is the", "is a",
    }

    local NUMWORDS = {
    first = 1, second = 2, third = 3, fourth = 4, fifth = 5, sixth = 6,
    seventh = 7, eighth = 8, ninth = 9, tenth = 10, eleventh = 11,
    twelfth = 12, thirteenth = 13, fourteenth = 14, fifteenth = 15,
    sixteenth = 16, seventeenth = 17, eighteenth = 18,
  }
  local CARDINALS = {
  one = 1, two = 2, three = 3, four = 4, five = 5, six = 6, seven = 7,
  eight = 8, nine = 9, ten = 10, eleven = 11, twelve = 12,
  thirteen = 13, fourteen = 14, fifteen = 15, sixteen = 16,
  seventeen = 17, eighteen = 18,
}
local ORD_SUFFIX = { [1] = "1st", [2] = "2nd", [3] = "3rd" }
local function ordinal(n) return ORD_SUFFIX[n] or (tostring(n) .. "th") end
local function applyAliases(s)
  local out = {}
  for word in s:gmatch("%S+") do
    local swapped = WORD_ALIAS[word]
    if swapped ~= nil then
      if swapped ~= "" then out[#out + 1] = swapped end
    else
    out[#out + 1] = word
  end
end
return table.concat(out, " ")
end
local function basicClean(s)
  s = tostring(s or ""):lower()
  s = s:gsub("[%?%!%.%,%;%:\"'`]", " ")
  s = s:gsub("%s+", " ")
  return trim(s)
end
local function stripFillers(s)
  local out = " " .. s .. " "
  for _, filler in ipairs(FILLERS) do
    out = out:gsub("%s" .. filler:gsub("%%", "%%%%") .. "%s", " ")
  end
out = out:gsub("%s+my%s+", " "):gsub("^%s*my%s+", " ")
out = out:gsub("%s+sammys?%s+", " "):gsub("^%s*sammys?%s+", " ")
out = out:gsub("%s+the%s+", " "):gsub("%s+of%s+", " "):gsub("%s+for%s+", " ")
out = out:gsub("%s+a%s+", " "):gsub("%s+an%s+", " "):gsub("%s+in%s+", " ")
out = out:gsub("%s+i%s+", " "):gsub("%s+is%s+", " "):gsub("%s+was%s+", " ")
out = out:gsub("%s+", " ")
return trim(out)
end
local function toDigits(s)
  local conv = s
  for word, n in pairs(NUMWORDS) do
    conv = conv:gsub("%f[%a]" .. word .. "%f[%A]", ordinal(n))
  end
for word, n in pairs(CARDINALS) do
  conv = conv:gsub("%f[%a]" .. word .. "%f[%A]", tostring(n))
end
return conv
end
local QWORDS = {
who = true, what = true, which = true, when = true, where = true,
how = true, why = true, name = true, tell = true, say = true,
type = true, guess = true, answer = true, spell = true, write = true,
}
local CATEGORY_WORDS = {
mutation = true, machine = true, trait = true, brainrot = true,
rarity = true, color = true, number = true, thing = true, one = true,
word = true, day = true, year = true, month = true, update = true,
}
local STOPWORDS = {
you = true, your = true, yours = true, me = true, we = true, us = true,
it = true, its = true, be = true, been = true, this = true, that = true,
["do"] = true, does = true, did = true, ["then"] = true,
  }

  local function words(s)
    local list = {}
    for word in s:gmatch("%S+") do list[#list + 1] = word end
    return list
  end
local function dropLead(s)
  local list = words(s)
  if #list < 2 or not QWORDS[list[1]] then return nil end
  table.remove(list, 1)
  if #list > 1 and CATEGORY_WORDS[list[1]] then table.remove(list, 1) end
  return table.concat(list, " ")
end
local function dropStopwords(s)
  local out = {}
  for _, word in ipairs(words(s)) do
    if not STOPWORDS[word] then out[#out + 1] = word end
  end
return table.concat(out, " ")
end
local function localAnswer(text)
  if not text or text == "" then return nil end
  local raw      = basicClean(text)
  local aliased  = applyAliases(raw)
  local core     = stripFillers(aliased)
  local noStop   = dropStopwords(core)

  local candidates = { raw, aliased, core, noStop }

  local lead = dropLead(core)
  if lead then candidates[#candidates + 1] = lead end
  local leadNoStop = dropLead(noStop)
  if leadNoStop then candidates[#candidates + 1] = leadNoStop end
  local base = #candidates
  for index = 1, base do
    local converted = toDigits(candidates[index])
    if converted ~= candidates[index] then candidates[#candidates + 1] = converted end
  end
candidates[#candidates + 1] = (core:gsub("%d+", ""):gsub("%s+", " "))

local digitForm = toDigits(noStop)
local kind, num = digitForm:match("^(.-)%s+(%d+)$")
if kind and num then
  candidates[#candidates + 1] = ordinal(tonumber(num)) .. " " .. trim(kind)
end
local num2, kind2 = digitForm:match("^(%d+)%s+(.-)$")
if num2 and kind2 then
  candidates[#candidates + 1] = ordinal(tonumber(num2)) .. " " .. trim(kind2)
end
for _, key in ipairs(candidates) do
  key = trim(key)
  if key ~= "" and SAB_DB[key] then return SAB_DB[key] end
end
return nil
end
local PROTECTED = {
["black and white"] = "\1blackwhite\1",
["yin and yang"]    = "\1yinyang\1",
["salt and pepper"] = "\1saltpepper\1",
["rock and roll"]   = "\1rockroll\1",
["cat and dog"]     = "\1catdog\1",
}
local UNPROTECT = {}
for phrase, token in pairs(PROTECTED) do UNPROTECT[token] = phrase end
local function splitQuestions(text)
  local s = " " .. tostring(text or ""):lower() .. " "
  for phrase, token in pairs(PROTECTED) do s = s:gsub(phrase, token) end

  s = s:gsub("%s*[%?%;%,]%s*", " and ")
  s = s:gsub("%s*&%s*", " and ")
  s = s:gsub("%s*%+%s*", " and ")
  s = " " .. basicClean(s) .. " "

  s = s:gsub("%s+add%s+", " and ")
  s = s:gsub("%s+plus%s+", " and ")
  s = s:gsub("%s+then%s+", " and ")
    s = s:gsub("%s+followed%s+by%s+", " and ")
    s = s:gsub("%s+also%s+", " and ")
    s = s:gsub("%s+", " ")

    local parts = {}
    for part in (s .. " and "):gmatch("(.-)%s+and%s+") do
      part = trim(part)
      if part ~= "" then
        for token, phrase in pairs(UNPROTECT) do part = part:gsub(token, phrase) end
        parts[#parts + 1] = part
      end
  end
if #parts == 0 then parts[1] = trim(basicClean(text)) end
return parts
end
local function multiplierOf(text)
  local l = text:lower()
  if l:find("twice") then return 2 end
  if l:find("thrice") then return 3 end
  local n = tonumber(l:match("(%d+)%s*times"))
  if n and n >= 2 and n <= 10 then return n end
  for word, value in pairs(CARDINALS) do
    if value >= 2 and value <= 10 and l:find("%f[%a]" .. word .. "%s+times") then return value end
  end
return nil
end
local function stripMultiplier(text)
  local s = text
  s = s:gsub("%s*%d+%s*times%s*", " ")
  s = s:gsub("%s*twice%s*", " ")
  s = s:gsub("%s*thrice%s*", " ")
  for word, value in pairs(CARDINALS) do
    if value >= 2 and value <= 10 then s = s:gsub("%s*" .. word .. "%s+times%s*", " ") end
  end
s = trim(s)
return s ~= "" and s or text
end
local function trailingSuffixNumber(text)
  local words, prev, suffix = {}, nil, nil
  for word in basicClean(text):gmatch("%S+") do words[#words + 1] = word end
  local SKIP = { mutation = true, machine = true, og = true, number = true,
  brainrot = true, trait = true, rarity = true, times = true }
  for index, word in ipairs(words) do
    if word:match("^%d+$") and tonumber(word) > 13 then
      prev = index > 1 and words[index - 1] or ""
      local nxt = words[index + 1] or ""
      if not SKIP[prev] and not SKIP[nxt] then suffix = word end
    end
end
return suffix
end
local function stripTrailingNumber(text)
  return trim(tostring(text):gsub("%s+%d+%s*$", ""))
end
local function extractPlacement(part)
  local placement
  if part:find("at the end") then placement = "end" end
  if part:find("at the start") or part:find("at the beginning") then placement = "start" end
  local cleaned = part
  :gsub("%s*at the end%s*", " ")
:gsub("%s*at the start%s*", " ")
:gsub("%s*at the beginning%s*", " ")
return trim(cleaned), placement
end
local function resolvePart(part)
  local times = multiplierOf(part)
  local q = stripMultiplier(part)

  if trailingSuffixNumber(part) then q = stripTrailingNumber(q) end
  q = trim(q)
  if q == "" then return nil end
  local onlyNumber = q:match("^%d+$")
  if onlyNumber then
    return times and string.rep(onlyNumber, times) or onlyNumber
  end
local answer = localAnswer(q)
if not answer then return nil en