local common = module.load("Dalandan_AIO", "common");
local menu = module.load("Dalandan_AIO", "menu");

local deaths = player:getStat("NUM_DEATHS")
local doublekills = player:getStat("DOUBLE_KILLS")
local triplekills = player:getStat("TRIPLE_KILLS")
local quadrakills = player:getStat("QUADRA_KILLS")
local pentakills = player:getStat("PENTA_KILLS")

local dalandanPath = hanbot.path.."/dalandanAIO"

local x = graphics.width / 2 
local y = graphics.height * 0.9 -- * 0.1

local function init()
    if not module.directory_exists(dalandanPath) then
        module.create_directory("dalandanAIO", dalandanPath)
    end
end
init()

local function weeb_img(mode) then

end

local function weeb_sound(mode) then

end

local function weeb(mode)
    if menu.utilitymenu.weeb.img:get() then
        weeb_img(mode)
    end
    if menu.utilitymenu.weeb.sound:get() then
        weeb_sound(mode)
    end
end

cb.add(cb.tick,function() 
    if pentakills ~= player:getStat("NUM_DEATHS") then
        weeb("death")
    end    
    if doublekills ~= player:getStat("DOUBLE_KILLS") then
        weeb("doublekill")
    end
    if triplekills ~= player:getStat("TRIPLE_KILLS") then
        weeb("triplekill")
    end
    if quadrakills ~= player:getStat("QUADRA_KILLS") then
        weeb("quadrakill")
    end
    if pentakills ~= player:getStat("PENTA_KILLS") then
        weeb("pentakill")
    end

    deaths = player:getStat("NUM_DEATHS")
    doublekills = player:getStat("DOUBLE_KILLS")
    triplekills = player:getStat("TRIPLE_KILLS")
    quadrakills = player:getStat("QUADRA_KILLS")
    pentakills = player:getStat("PENTA_KILLS")
end)