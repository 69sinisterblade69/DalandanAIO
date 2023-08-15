chat.print('[Dalandan AIO] PRE-RELEASE 15.08.2023 Loading...')

-- local menu = module.load("Dalandan_AIO", "menu")

local champ = ""
if player.charName == "Lux" then
    champ = module.load("Dalandan_AIO", "Lux");
end
if player.charName == "Malphite" then
    champ = module.load("Dalandan_AIO", "Malphite");
end
if player.charName == "Ryze" then
    champ = module.load("Dalandan_AIO", "Ryze");
end
if player.charName == "TwistedFate" then
    champ = module.load("Dalandan_AIO", "TwistedFate");
end
if player.charName == "Xerath" then
    champ = module.load("Dalandan_AIO", "Xerath");
end