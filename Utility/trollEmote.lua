local common = module.load("Dalandan_AIO", "common");
local menu = module.load("Dalandan_AIO", "menu");

local delay = menu.utilitymenu.trollemote.delay:get()
local checked = menu.utilitymenu.trollemote.emote:get()

local function emotee()
    delay = menu.utilitymenu.trollemote.delay:get()
    checked = menu.utilitymenu.trollemote.emote:get()
    if menu.utilitymenu.trollemote.emote_spam:get() then
        game.sendEmote(checked-1)
    end
end

common.SetInterval(emotee, delay/1000,9999999)