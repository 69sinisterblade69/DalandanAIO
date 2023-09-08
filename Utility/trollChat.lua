local common = module.load("Dalandan_AIO", "common");
local menu = module.load("Dalandan_AIO", "menu");

local delay = menu.utilitymenu.trollchat.troll_delay:get()
local kills = player:getStat("CHAMPIONS_KILLED")
local deaths = player:getStat("NUM_DEATHS")
local assists = player:getStat("ASSISTS")
local minions = player:getStat("MINIONS_KILLED")
local doublekills = player:getStat("DOUBLE_KILLS")
local triplekills = player:getStat("TRIPLE_KILLS")
local quadrakills = player:getStat("QUADRA_KILLS")
local pentakills = player:getStat("PENTA_KILLS")
local keybind1 = menu.utilitymenu.trollchat.troll_keybind1:get()
local keybind2 = menu.utilitymenu.trollchat.troll_keybind2:get()
local keybind3 = menu.utilitymenu.trollchat.troll_keybind3:get()
local dalandanPath = hanbot.path.."dalandan.txt"

local default_txt = [[
;lines starting with ";" are comments
;dont change lines with "[" and "]"
;also don't write text with "[" and "]"
;lines starting with "#" are part of multi-line
;you can use empty line to separate two multi-lines
;take a look at [keybind1] to see example

[kill]
Wow, you suck.
commit sudoku
???

[death]
close one
fucking lucker

[assist]
ks

[minion_kill]
farmed another one
get some CS loser

[doublekill]

[triplekill]

[quadrakill]

[pentakill]
"Skill issue" ~ Sun Tzu
Take decisions that are beneficial, and don't take decisions that are not beneficial. ~ Art of War - summarized

[keybind1]
###_______##___########
#_##_____##____##______##
#__##___##_____##_______##
#____###_______##_______##
#__##___##_____##_______##
#_##_____##____##______##
###_______##___########

#__######____######__
#_##____##__##____##_
#_##________##_______
#_##___####_##___####
#_##____##__##____##_
#_##____##__##____##_
#__######____######__

[keybind2]

[keybind3]

]]

function magiclines(s)
    if s:sub(-1)~="\n" then s=s.."\n" end
    return s:gmatch("(.-)\n")
end


local function parse_text(text)
    local result = {}
    local current_section = nil
    local current_multiline = {}
    for line in magiclines(text) do
        if line == "" or line:match("^%s*$") then
            if #current_multiline > 0 then
                table.insert(result[current_section], current_multiline)
                current_multiline = {}
            end
        end
        if not (line:match("^;") or line:match("^%s*$")) then
            local section = line:match("^%[(.+)%]$")
            if section then
                current_section = section
                result[current_section] = {}
            else
                local multiline = line:match("^#(.+)$")
                if multiline then
                    table.insert(current_multiline, multiline)
                else
                    if #current_multiline > 0 then
                        table.insert(result[current_section], current_multiline)
                        current_multiline = {}
                    end
                    if current_section then
                        table.insert(result[current_section], line)
                    end
                end
            end
        end
    end
    return result
end

local function parse_file(path)
    local file = io.open(path, "r")
    if not file then return nil end

    local content = file:read "*a"
    file:close()

    return parse_text(content)
end

local data = nil
if module.file_exists(dalandanPath) then
    print("[Dalandan AIO] Troll chat is using dalandan.txt")
    data = parse_file(dalandanPath)
else
    print("[Dalandan AIO] Troll chat can't find dalandan.txt")
    print("[Dalandan AIO] Using default text and creating dalandan.txt")
    data = parse_text(default_txt)
    local file = io.open(dalandanPath, "r")
    if not file then
        file = io.open(dalandanPath, "w")
        file:write(default_txt)
        file:close()
    end
end

local function chat_troll(mode)
    if data[mode] == nil then
        return
    elseif data[mode][1] == nil then
        return
    end

    local len = #data[mode]
    if len < 1 then return end

    local i = math.random(1,len)
    local selected_data = data[mode][i]
    
    if type(selected_data) == "table" then -- multi-line data point
        for _, line in ipairs(selected_data) do
            common.DelayAction(function() chat.send("/all "..line) end,delay/1000)
        end
    else -- single line data point
        common.DelayAction(function() chat.send("/all "..selected_data) end,delay/1000)
    end
end

local function on_tick()
    if kills ~= player:getStat("CHAMPIONS_KILLED") and menu.utilitymenu.trollchat.troll_kill:get() then
        chat_troll("kill")
    end
    if deaths ~= player:getStat("NUM_DEATHS") and menu.utilitymenu.trollchat.troll_death:get() then
        chat_troll("death")
    end
    if assists ~= player:getStat("ASSISTS") and menu.utilitymenu.trollchat.troll_assist:get() then
        chat_troll("assist")
    end
    if minions ~= player:getStat("MINIONS_KILLED") and menu.utilitymenu.trollchat.troll_minion_kill:get() then
        chat_troll("minion_kill")
    end
    if doublekills ~= player:getStat("DOUBLE_KILLS") and menu.utilitymenu.trollchat.troll_penta:get() then
        chat_troll("doublekill")
    end
    if triplekills ~= player:getStat("TRIPLE_KILLS") and menu.utilitymenu.trollchat.troll_penta:get() then
        chat_troll("triplekill")
    end
    if quadrakills ~= player:getStat("QUADRA_KILLS") and menu.utilitymenu.trollchat.troll_penta:get() then
        chat_troll("quadrakill")
    end
    if pentakills ~= player:getStat("PENTA_KILLS") and menu.utilitymenu.trollchat.troll_penta:get() then
        chat_troll("pentakill")
    end
    if not keybind1 and menu.utilitymenu.trollchat.troll_keybind1:get() then
        chat_troll("keybind1")
    end
    if not keybind2 and menu.utilitymenu.trollchat.troll_keybind2:get() then
        chat_troll("keybind2")
    end
    if not keybind3 and menu.utilitymenu.trollchat.troll_keybind3:get() then
        chat_troll("keybind3")
    end

    delay = menu.utilitymenu.trollchat.troll_delay:get()
    kills = player:getStat("CHAMPIONS_KILLED")
    deaths = player:getStat("NUM_DEATHS")
    assists = player:getStat("ASSISTS")
    minions = player:getStat("MINIONS_KILLED")
    doublekills = player:getStat("DOUBLE_KILLS")
    triplekills = player:getStat("TRIPLE_KILLS")
    quadrakills = player:getStat("QUADRA_KILLS")
    pentakills = player:getStat("PENTA_KILLS")
    keybind1 = menu.utilitymenu.trollchat.troll_keybind1:get()
    keybind2 = menu.utilitymenu.trollchat.troll_keybind2:get()
    keybind3 = menu.utilitymenu.trollchat.troll_keybind3:get()
end

cb.add(cb.tick,on_tick)
