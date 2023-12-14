chat.print('[Dalandan AIO] RELEASE 14.12.2023 Loading...')
chat.print('[Dalandan AIO] https://discord.gg/9cxRCHYR4y')
chat.print('[Dalandan AIO] https://github.com/69sinisterblade69/DalandanAIO')

local menu = module.load("Dalandan_AIO", "menu");
if menu.mainmenu.reload:get() then
    module.load("Dalandan_AIO", "Utility/reloader");
end
if menu.mainmenu.utility:get() then
    module.load("Dalandan_AIO", "Utility/pings");
    module.load("Dalandan_AIO", "Utility/trollChat");
    module.load("Dalandan_AIO", "Utility/trollPing");
    module.load("Dalandan_AIO", "Utility/trollEmote");
end
if menu.mainmenu.awareness:get() then
    module.load("Dalandan_AIO", "Awareness/aa");
    module.load("Dalandan_AIO", "Awareness/cooldown");
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
if player.charName == "Caitlyn" and menu.mainmenu.champion:get() then
    champ = module.load("Dalandan_AIO", "Caitlyn/Caitlyn");
end
-- if player.charName == "Zed" and menu.mainmenu.champion:get() then
--     champ = module.load("Dalandan_AIO", "Zed");
-- end