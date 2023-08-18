chat.print('[Dalandan AIO] PRE-RELEASE 18.08.2023 Loading...')
chat.print('[Dalandan AIO] https://discord.gg/9cxRCHYR4y')
chat.print('[Dalandan AIO] https://github.com/69sinisterblade69/DalandanAIO')

module.load("Dalandan_AIO", "reloader");

local menu = module.load("Dalandan_AIO", "menu");

local champ = ""
-- if player.charName == "Lux" and menu.reloadmenu.champion:get() then
--     champ = module.load("Dalandan_AIO", "Lux");
-- end
-- if player.charName == "Malphite" and menu.reloadmenu.champion:get() then
--     champ = module.load("Dalandan_AIO", "Malphite");
-- end
-- if player.charName == "Ryze" and menu.reloadmenu.champion:get() then
--     champ = module.load("Dalandan_AIO", "Ryze");
-- end
if player.charName == "TwistedFate" and menu.reloadmenu.champion:get() then
    champ = module.load("Dalandan_AIO", "TwistedFate");
end
if player.charName == "Xerath" and menu.reloadmenu.champion:get() then
    champ = module.load("Dalandan_AIO", "Xerath");
end
-- if player.charName == "Yasuo" and menu.reloadmenu.champion:get() then
--     champ = module.load("Dalandan_AIO", "Yasuo2");
-- end
-- if player.charName == "Zed" and menu.reloadmenu.champion:get() then
--     champ = module.load("Dalandan_AIO", "Zed");
-- end