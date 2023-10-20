chat.print('[Dalandan AIO] RELEASE 20.10.2023 Loading...')
chat.print('[Dalandan AIO] https://discord.gg/9cxRCHYR4y')
chat.print('[Dalandan AIO] https://github.com/69sinisterblade69/DalandanAIO')

local menu = module.load("Dalandan_AIO", "menu");
if menu.mainmenu.reload:get() then
    module.load("Dalandan_AIO", "Utility/reloader");
end
if menu.mainmenu.utility:get() then
    module.load("Dalandan_AIO", "Utility/pings");
    module.load("Dalandan_AIO", "Utility/trollChat"); --etc..
end



local champ = ""
-- if player.charName == "Lux" and menu.mainmenu.champion:get() then
--     champ = module.load("Dalandan_AIO", "Lux");
-- end
-- if player.charName == "Malphite" and menu.mainmenu.champion:get() then
--     champ = module.load("Dalandan_AIO", "Malphite");
-- end
-- if player.charName == "Ryze" and menu.mainmenu.champion:get() then
--     champ = module.load("Dalandan_AIO", "Ryze");
-- end
if player.charName == "TwistedFate" and menu.mainmenu.champion:get() then
    champ = module.load("Dalandan_AIO", "TwistedFate/TwistedFate");
end
if player.charName == "Xerath" and menu.mainmenu.champion:get() then
    champ = module.load("Dalandan_AIO", "Xerath/Xerath");
end
if player.charName == "Yasuo" and menu.mainmenu.champion:get() then
    -- champ = module.load("Dalandan_AIO", "Yasuo/Yasuo2");
    champ = module.load("Dalandan_AIO", "Yasuo/Yasuo");
end
if player.charName == "Yone" and menu.mainmenu.champion:get() then
    champ = module.load("Dalandan_AIO", "Yone/Yone");
end
-- if player.charName == "Zed" and menu.mainmenu.champion:get() then
--     champ = module.load("Dalandan_AIO", "Zed");
-- end