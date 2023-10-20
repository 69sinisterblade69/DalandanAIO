local Dalandan_menu = {}
local common = module.load("Dalandan_AIO", "common");

local function menuReload() 
  local function reload()
      core.reload()
  end
  common.DelayAction(reload,0.1)
end

Dalandan_menu.mainmenu = menu("Dalandan_Menu", "Dalandan AIO - Menu");
Dalandan_menu.mainmenu:boolean('champion', 'Load champion script', true);
Dalandan_menu.mainmenu:boolean('reload', 'Load auto reloading on arena', true);
Dalandan_menu.mainmenu:boolean('utility', 'Load utility', true);

local champ 
if common.champs[player.charName] then
  champ = true
else
  champ = false
end

Dalandan_menu.mainmenu.champion:set('visible',champ)

Dalandan_menu.mainmenu.champion:set('callback', menuReload)
Dalandan_menu.mainmenu.reload:set('callback', menuReload)
Dalandan_menu.mainmenu.utility:set('callback', menuReload)

if Dalandan_menu.mainmenu.utility:get() then
    Dalandan_menu.utilitymenu = menu("Dalandan_Menu_Utility", "Dalandan AIO - Utility");
    
    Dalandan_menu.utilitymenu:menu("pings", "Auto pings")
    Dalandan_menu.utilitymenu.pings:boolean('ping_ward', 'Ping "enemy has vision" on wards', false);
    Dalandan_menu.utilitymenu.pings:boolean('ping_ward_visible', '^ Ping only if ward is on your screen', false);
    Dalandan_menu.utilitymenu.pings:boolean('chat_ult','Write ults in chat', false)
    -- Dalandan_menu.utilitymenu.pings:boolean('ping_ult','Ping ults in chat', false)
    Dalandan_menu.utilitymenu.pings:menu("ults","Ults")
    for i, obj in pairs(common.GetEnemyHeroes()) do
      Dalandan_menu.utilitymenu.pings.ults:boolean(obj.charName,"Ping on "..obj.charName.." ult",false)
    end
    Dalandan_menu.utilitymenu.pings:boolean('chat_summoner','Write summoner spells in chat', false)
    Dalandan_menu.utilitymenu.pings:menu("summoner","Summoner spells")
    for i, obj in pairs(common.GetEnemyHeroes()) do
      -- Dalandan_menu.utilitymenu.pings.summoner:boolean(obj.charName.."1","Ping on "..obj:spellSlot(4).name,false)
      -- Dalandan_menu.utilitymenu.pings.summoner:boolean(obj.charName.."2","Ping on "..obj:spellSlot(5).name,false)
      for i=4,5 do
        if obj:spellSlot(i).name == "SummonerDot" then
          Dalandan_menu.utilitymenu.pings.summoner:boolean(obj.charName..i,"Ping on "..obj.charName.." ignite",false)
          goto SummonerEnd
        end
        if obj:spellSlot(i).name == "SummonerHaste" then
          Dalandan_menu.utilitymenu.pings.summoner:boolean(obj.charName..i,"Ping on "..obj.charName.." ghost",false)
          goto SummonerEnd
        end
        if obj:spellSlot(i).name == "SummonerHeal" then
          Dalandan_menu.utilitymenu.pings.summoner:boolean(obj.charName..i,"Ping on "..obj.charName.." heal",false)
          goto SummonerEnd
        end
        if obj:spellSlot(i).name == "SummonerBoost" then
          Dalandan_menu.utilitymenu.pings.summoner:boolean(obj.charName..i,"Ping on "..obj.charName.." cleanse",false)
          goto SummonerEnd
        end
        if obj:spellSlot(i).name == "SummonerExhaust" then
          Dalandan_menu.utilitymenu.pings.summoner:boolean(obj.charName..i,"Ping on "..obj.charName.." exhaust",false)
          goto SummonerEnd
        end
        if string.find(obj:spellSlot(i).name, "Smite") then
          -- Dalandan_menu.utilitymenu.pings.summoner:boolean(obj.charName..i,"Ping on "..obj.charName.." smite",false)
          Dalandan_menu.utilitymenu.pings.summoner:boolean(obj.charName..i,"SMITE IS BUGGED AND I DONT KNOW WHY",false)
          goto SummonerEnd
        end
        if string.find(obj:spellSlot(i).name, "teleport") then
          Dalandan_menu.utilitymenu.pings.summoner:boolean(obj.charName..i,"Ping on "..obj.charName.." teleport",false)
          goto SummonerEnd
        end
        if obj:spellSlot(i).name == "SummonerBarrier" then
          Dalandan_menu.utilitymenu.pings.summoner:boolean(obj.charName..i,"Ping on "..obj.charName.." barrier",false)
          goto SummonerEnd
        end
        if obj:spellSlot(i).name == "SummonerFlash" then
          Dalandan_menu.utilitymenu.pings.summoner:boolean(obj.charName..i,"Ping on "..obj.charName.." flash",false)
          goto SummonerEnd
        end
        Dalandan_menu.utilitymenu.pings.summoner:boolean(obj.charName..i,"Ping on "..obj.charName.." "..obj:spellSlot(i).name,false)
        ::SummonerEnd::
      end
    end
    Dalandan_menu.utilitymenu:menu("trollchat", "Troll Chat")
    Dalandan_menu.utilitymenu.trollchat:header("troll_header","Every message sent is customizable")
    Dalandan_menu.utilitymenu.trollchat:header("troll_header2","in file dalandan.txt")
    Dalandan_menu.utilitymenu.trollchat:slider('troll_delay', 'Delay in writing message (ms) [WIP]', 1000, 0, 5000, 50 );
    Dalandan_menu.utilitymenu.trollchat:boolean('troll_kill', 'Write random "kill" message', false);
    Dalandan_menu.utilitymenu.trollchat:boolean('troll_death', 'Write random "death" message', false);
    Dalandan_menu.utilitymenu.trollchat:boolean('troll_assist', 'Write random "assist" message', false);
    Dalandan_menu.utilitymenu.trollchat:boolean('troll_minion_kill', 'Write random "minion kill" message', false);
    Dalandan_menu.utilitymenu.trollchat:boolean('troll_double', 'Write random "doublekill" message', false);
    Dalandan_menu.utilitymenu.trollchat:boolean('troll_triple', 'Write random "triplekill" message', false);
    Dalandan_menu.utilitymenu.trollchat:boolean('troll_quadra', 'Write random "quadrakill" message', false);
    Dalandan_menu.utilitymenu.trollchat:boolean('troll_penta', 'Write random "pentakill" message', false);
    Dalandan_menu.utilitymenu.trollchat:keybind('troll_keybind1', 'Write random "keybind1" message', nil,nil);
    Dalandan_menu.utilitymenu.trollchat:keybind('troll_keybind2', 'Write random "keybind2" message', nil,nil);
    Dalandan_menu.utilitymenu.trollchat:keybind('troll_keybind3', 'Write random "keybind3" message', nil,nil);
end

if player.charName == "Lux" and Dalandan_menu.mainmenu.champion:get() then
    Dalandan_menu.luxmenu = menu("Dalandan_Menu_"..player.charName, "Dalandan AIO - "..player.charName);
    --Combo
    Dalandan_menu.luxmenu:menu("Combo", "Combo");
    Dalandan_menu.luxmenu.Combo:boolean('q_combo', 'Use Q', true);
    Dalandan_menu.luxmenu.Combo:boolean('e_combo', 'Use E', true);
    Dalandan_menu.luxmenu.Combo:boolean('r_combo', 'Use R', true);
    Dalandan_menu.luxmenu.Combo:boolean('r_onlykill', '^ Use R only when kill [BAD]', false);
    Dalandan_menu.luxmenu.Combo:boolean('r_onlyCC', '^ Use R only when hard CC or not moving', true);
    -- Harras?
    
    --Lane
    Dalandan_menu.luxmenu:menu("Lane", "Lane Clear");
    -- Dalandan_menu.luxmenu.Lane:boolean('q_jg', 'Use Q in jungle', true);
    -- Dalandan_menu.luxmenu.Lane:boolean('e_jg', 'Use E in jungle', true);
    Dalandan_menu.luxmenu.Lane:boolean('e_lane', 'Use E in lane [idk its weird]', true);
    Dalandan_menu.luxmenu.Lane:slider('e_lane_minion', '^ Only when x minion hit', 3, 1, 6, 1);

    --Misc
    Dalandan_menu.luxmenu:menu("Misc", "Misc");
    Dalandan_menu.luxmenu.Misc:boolean('q_ks', 'Use Q to killsteal', false);
    Dalandan_menu.luxmenu.Misc:boolean('e_ks', 'Use E to killsteal', true);
    Dalandan_menu.luxmenu.Misc:boolean('r_ks', 'Use R to killsteal', true);
    -- Dalandan_menu.luxmenu.Misc:boolean('w_misc', 'Use W [Auto shield]', false);

    --Draw
    --TODO: COLORS?
    Dalandan_menu.luxmenu:menu("Draw", "Drawing");
    Dalandan_menu.luxmenu.Draw:boolean('ready', 'Draw only when skill is ready', true);
    Dalandan_menu.luxmenu.Draw:boolean('q_draw', 'Draw Q', true);
    Dalandan_menu.luxmenu.Draw:boolean('w_draw', 'Draw W', false);
    Dalandan_menu.luxmenu.Draw:boolean('e_draw', 'Draw E', false);
    Dalandan_menu.luxmenu.Draw:boolean('r_draw', 'Draw R', true);
end

if player.charName == "Malphite" and Dalandan_menu.mainmenu.champion:get() then
    Dalandan_menu.malphitemenu = menu("Dalandan_Menu_"..player.charName, "Dalandan AIO - "..player.charName);
    --Combo
    Dalandan_menu.malphitemenu:menu("Combo", "Combo");
    Dalandan_menu.malphitemenu.Combo:boolean('q_combo', 'Use Q', true);
    Dalandan_menu.malphitemenu.Combo:boolean('w_combo', 'Use W', true);
    Dalandan_menu.malphitemenu.Combo:boolean('e_combo', 'Use E', true);
    Dalandan_menu.malphitemenu.Combo:boolean('r_combo', 'Use R', true);
    Dalandan_menu.malphitemenu.Combo:slider('r_combo_count', '^ Only when x hero hit [doesnt work]', 2, 1, 5, 1);

    --Lane
    Dalandan_menu.malphitemenu:menu("Lane", "Lane Clear");
    Dalandan_menu.malphitemenu.Lane:boolean('q_lane', 'Use Q', true);
    -- Dalandan_menu.malphitemenu.Lane:boolean('e_lane', 'Use E', true); 
    
    --Misc
    Dalandan_menu.malphitemenu:menu("Misc", "Misc");
    Dalandan_menu.malphitemenu.Misc:boolean('q_ks', 'Use Q to killsteal', true);
    Dalandan_menu.malphitemenu.Misc:boolean('e_ks', 'Use E to killsteal', true);
    Dalandan_menu.malphitemenu.Misc:boolean('r_ks', 'Use R to killsteal', false);
    Dalandan_menu.malphitemenu.Misc:keybind('r_semi', 'Semi R', 'T', nil);
    Dalandan_menu.malphitemenu.Misc:slider('range_factor', 'Change range for pred (%)', 98, 90, 105, 1);
    Dalandan_menu.malphitemenu.Misc:header('range_factor_header','^ Must reload script')
    Dalandan_menu.malphitemenu.Misc:header('range_factor_header2','Lower % will help with missing skills')

    --Draw
    --TODO: COLORS?
    Dalandan_menu.malphitemenu:menu("Draw", "Drawing");
    Dalandan_menu.malphitemenu.Draw:boolean('ready', 'Draw only when skill is ready', true);
    Dalandan_menu.malphitemenu.Draw:boolean('q_draw', 'Draw Q range', true);
    Dalandan_menu.malphitemenu.Draw:boolean('e_draw', 'Draw E range', false);
    Dalandan_menu.malphitemenu.Draw:boolean('r_draw', 'Draw R range', true);
    Dalandan_menu.malphitemenu.Draw:boolean('dmg_draw', 'Show damage on hp bar', true);
    Dalandan_menu.malphitemenu.Draw:boolean('dmg_draw_ready', '^ Show damage only if skill ready', true);
    Dalandan_menu.malphitemenu.Draw:boolean('q_draw_dmg', '^ Draw Q damage', true);
    Dalandan_menu.malphitemenu.Draw:boolean('w_draw_dmg', '^ Draw W damage (1 autoattack)' , true);
    Dalandan_menu.malphitemenu.Draw:boolean('e_draw_dmg', '^ Draw E damage', true);
    Dalandan_menu.malphitemenu.Draw:keybind('r_draw_dmg', '^ Draw R damage', nil, 'G');
    -- Dalandan_menu.malphitemenu.Draw:dropdown('dmg_draw_type', '^ Show dmg from all skills or only ready', 1,{"full","full without R","ready"});
end
if player.charName == "Ryze" and Dalandan_menu.mainmenu.champion:get() then
    Dalandan_menu.ryzemenu = menu("Dalandan_Menu_"..player.charName, "Dalandan AIO - "..player.charName);
    --Combo
    Dalandan_menu.ryzemenu:menu("Combo", "Combo");
    Dalandan_menu.ryzemenu.Combo:boolean('do_combo', 'Enable combo', true);
    Dalandan_menu.ryzemenu.Combo:header('type_combo_header','Simple = use any spell in any order')
    Dalandan_menu.ryzemenu.Combo:header('type_combo_header2','Smart = use combos to max damage')
    Dalandan_menu.ryzemenu.Combo:dropdown('type_combo', 'Combo type', 2, {"smart [WIP]","simple"});
    Dalandan_menu.ryzemenu.Combo:keybind('root_combo', 'Root combo [LOL]', nil, 'T');
    Dalandan_menu.ryzemenu.Combo.root_combo:set('tooltip', 'Should combo root or deal max damage');

    --Harass
    Dalandan_menu.ryzemenu:menu("Harass", "Harass");
    Dalandan_menu.ryzemenu.Harass:boolean('qeq_harass', 'Use Q > E > Q to harass', true);

    --Misc
    Dalandan_menu.ryzemenu:menu("Misc", "Misc");
    Dalandan_menu.ryzemenu.Misc:boolean('type_combo_permashow', 'Permashow combo type', true);
    Dalandan_menu.ryzemenu.Misc:boolean('q_ks', 'Use Q to killsteal', true);
    Dalandan_menu.ryzemenu.Misc:boolean('w_ks', 'Use W to killsteal', true);
    Dalandan_menu.ryzemenu.Misc:boolean('e_ks', 'Use E to killsteal', true);
    Dalandan_menu.ryzemenu.Misc:keybind('flee', 'Use E > W to flee', 'Z', nil);

    --Draw
    Dalandan_menu.ryzemenu:menu("Draw", "Drawing");
    Dalandan_menu.ryzemenu.Draw:boolean('ready', 'Draw only when skill is ready', true);
    Dalandan_menu.ryzemenu.Draw:boolean('q_draw', 'Draw Q', true);
    Dalandan_menu.ryzemenu.Draw:boolean('w_draw', 'Draw W', false);
    Dalandan_menu.ryzemenu.Draw:boolean('e_draw', 'Draw E', false);
end
if player.charName == "TwistedFate" and Dalandan_menu.mainmenu.champion:get() then
    Dalandan_menu.tfmenu = menu("Dalandan_Menu_"..player.charName, "Dalandan AIO - "..player.charName);
    Dalandan_menu.tfmenu:set('icon',graphics.sprite('TwistedFate/TwistedFate.png'))
    -- Combo
    Dalandan_menu.tfmenu:menu("Combo", "Combo");
    Dalandan_menu.tfmenu.Combo:set('icon',graphics.sprite('Sprites/Combo.png'))
    Dalandan_menu.tfmenu.Combo:header('q_combo_header','Q settings')
    Dalandan_menu.tfmenu.Combo:boolean('q_combo', 'Use Q', true);
    Dalandan_menu.tfmenu.Combo:boolean('q_combo_onlyCC', '^ Use Q only when CC/Slow [shit]', true);
    Dalandan_menu.tfmenu.Combo:header('w_combo_header','W settings')
    Dalandan_menu.tfmenu.Combo:boolean('w_combo', 'Use W', true);
    Dalandan_menu.tfmenu.Combo:boolean('w_always_gold', '^ Always use golden card in combo', true);
    -- Dalandan_menu.tfmenu.Combo:boolean('w_damage_card', '^ Unless other card can kill', true);
    
    --Lane
    Dalandan_menu.tfmenu:menu("Lane", "Lane Clear");
    Dalandan_menu.tfmenu.Lane:set('icon',graphics.sprite('Sprites/icon minions light.png'))
    Dalandan_menu.tfmenu.Lane:header('q_lane_header','Q settings lane')
    Dalandan_menu.tfmenu.Lane:boolean('q_lane', 'Use Q in lane [idk kinda wonky]', true);
    Dalandan_menu.tfmenu.Lane:slider('q_lane_minion', '^ Only when x minion hit', 4, 1, 12, 1);
    Dalandan_menu.tfmenu.Lane:slider('q_lane_mana', '^ Only when above x% mana', 25, 0, 100, 5);
    
    Dalandan_menu.tfmenu.Lane:header('w_lane_header','W settings lane')
    Dalandan_menu.tfmenu.Lane:boolean('w_lane', 'Use W in lane', true);
    Dalandan_menu.tfmenu.Lane.w_lane:set('tooltip', 'Will always pick red card unless other conditions are met');
    Dalandan_menu.tfmenu.Lane:slider('w_lane_mana', 'Pick blue card if below x% mana', 80, 0, 100, 5);
    Dalandan_menu.tfmenu.Lane:boolean('w_lane_defend', 'Defend tower [WIP]', true);
    Dalandan_menu.tfmenu.Lane.w_lane_defend:set('tooltip', 'Will stun Super Minions attacking turret');

    Dalandan_menu.tfmenu.Lane:header('q_jungle_header','Q settings jungle')
    Dalandan_menu.tfmenu.Lane:boolean('q_jungle', 'Use Q in jungle', true);
    
    Dalandan_menu.tfmenu.Lane:header('w_jungle_header','W settings jungle')
    Dalandan_menu.tfmenu.Lane:boolean('w_jungle', 'Use W in jungle', true);
    Dalandan_menu.tfmenu.Lane.w_lane:set('tooltip', 'Will always pick red card unless other conditions are met');
    Dalandan_menu.tfmenu.Lane:slider('w_jungle_mana', 'Pick blue card if below x% mana', 45, 0, 100, 5);

    --misc
    Dalandan_menu.tfmenu:menu("Misc", "Misc");
    Dalandan_menu.tfmenu.Misc:set('icon',graphics.sprite('Sprites/Misc.png'))
    Dalandan_menu.tfmenu.Misc:header('semi_header','Auto W')
    Dalandan_menu.tfmenu.Misc:keybind('semi_gold', 'Pick golden card', 'W', nil);
    Dalandan_menu.tfmenu.Misc:keybind('semi_blue', 'Pick blue card', 'E', nil);
    Dalandan_menu.tfmenu.Misc:keybind('semi_red', 'Pick red card', 'T', nil);
    Dalandan_menu.tfmenu.Misc:header('ks_header','Killsteal')
    Dalandan_menu.tfmenu.Misc:boolean('q_ks', 'Use Q to killsteal', true);
    Dalandan_menu.tfmenu.Misc:boolean('q_ks_cc', '^ Only killsteal when CC/Slow [XDDDDD]', false);
    Dalandan_menu.tfmenu.Misc:header('r_header','R settings')
    Dalandan_menu.tfmenu.Misc:boolean('r_gold', 'Get golden card when using R', true);

    --draw
    Dalandan_menu.tfmenu:menu("Draw", "Drawing");
    Dalandan_menu.tfmenu.Draw:set('icon',graphics.sprite('Sprites/Draw.png'))
    Dalandan_menu.tfmenu.Draw:header('draw_header','Draw range')
    Dalandan_menu.tfmenu.Draw:boolean('ready', 'Draw only when skill is ready', true);
    Dalandan_menu.tfmenu.Draw:boolean('q_draw', 'Draw Q', true);
    Dalandan_menu.tfmenu.Draw:boolean('r_draw', 'Draw R', true);
    Dalandan_menu.tfmenu.Draw:header('dmg_draw_header','Draw damage')
    Dalandan_menu.tfmenu.Draw:boolean('dmg_draw', 'Show damage on hp bar', true);
    Dalandan_menu.tfmenu.Draw:boolean('dmg_draw_ready', '^ Show damage only if skill ready', true);
    Dalandan_menu.tfmenu.Draw:boolean('q_draw_dmg', '^ Draw Q damage', true);
end
if player.charName == "Xerath" and Dalandan_menu.mainmenu.champion:get() then
    Dalandan_menu.xerathmenu = menu("Dalandan_Menu_"..player.charName, "Dalandan AIO - "..player.charName);
    Dalandan_menu.xerathmenu:set('icon',graphics.sprite('Xerath/Xerath.png'))
    
    -- Combo
    Dalandan_menu.xerathmenu:menu("Combo", "Combo");
    Dalandan_menu.xerathmenu.Combo:set('icon',graphics.sprite('Sprites/Combo.png'))
    Dalandan_menu.xerathmenu.Combo:header('q_combo_header','Q settings')
    Dalandan_menu.xerathmenu.Combo:boolean('q_combo', 'Use Q', true);
    -- Dalandan_menu.xerathmenu.Combo:dropdown('q_combo_when', 'Use Q time (if possible) [WIP]',2, {"Before W","After W"});
    Dalandan_menu.xerathmenu.Combo:boolean('slow_pred_q', 'Use slower prediction on Q', false);
    Dalandan_menu.xerathmenu.Combo:header('w_combo_header','W settings')
    Dalandan_menu.xerathmenu.Combo:boolean('w_combo', 'Use W', true);
    Dalandan_menu.xerathmenu.Combo:boolean('slow_pred_w', 'Use slower prediction on W', true);
    Dalandan_menu.xerathmenu.Combo:header('e_combo_header','E settings')
    Dalandan_menu.xerathmenu.Combo:boolean('e_combo', 'Use E', true);
    -- Dalandan_menu.xerathmenu.Combo:boolean('slow_pred_e', 'Use slower prediction on E', true);
    Dalandan_menu.xerathmenu.Combo:header('r_combo_header','R settings')
    Dalandan_menu.xerathmenu.Combo:boolean('r_use', 'Use R (auto missiles)', true);
    Dalandan_menu.xerathmenu.Combo:slider('r_size', 'Size of auto missile', 500, 300, 800, 50);
    Dalandan_menu.xerathmenu.Combo:slider('r_delay', 'Delay [ms]', 300, 0, 2000, 50);
    Dalandan_menu.xerathmenu.Combo:keybind('r_fast', 'Fast R (0 delay)', 'Space', nil);
    Dalandan_menu.xerathmenu.Combo:boolean('slow_pred_r', 'Use slow pred on R (only old prediction)', true);
    Dalandan_menu.xerathmenu.Combo:dropdown('r_prediction', 'Prediction', 2, {"old","experimental"});

    -- Lane
    Dalandan_menu.xerathmenu:menu("Lane", "Lane");
    Dalandan_menu.xerathmenu.Lane:set('icon',graphics.sprite('Sprites/icon minions light.png'))
    Dalandan_menu.xerathmenu.Lane:header('q_lane_header','Q settings')
    Dalandan_menu.xerathmenu.Lane:boolean('q_lane', 'Use Q in lane [sometimes bugged lmao]', true); 
    Dalandan_menu.xerathmenu.Lane:slider('q_lane_minion', '^ Only when x minion hit', 4, 1, 12, 1);

    Dalandan_menu.xerathmenu.Lane:header('w_lane_header','W settings')
    Dalandan_menu.xerathmenu.Lane:boolean('w_lane', 'Use W in lane', true);

    -- Misc
    Dalandan_menu.xerathmenu:menu("Misc", "Misc");
    Dalandan_menu.xerathmenu.Misc:set('icon',graphics.sprite('Sprites/Misc.png'))
    Dalandan_menu.xerathmenu.Misc:header('gapClose_header','Anti-Gapcloser settings')
    Dalandan_menu.xerathmenu.Misc:boolean('e_gap', 'Use E for Anti-Gapclose', true);
    Dalandan_menu.xerathmenu.Misc:header('interrupt_header','Interrupt settings')
    Dalandan_menu.xerathmenu.Misc:boolean('e_int', 'Use E for interrupt enemy spells [WIP]', true);
    Dalandan_menu.xerathmenu.Misc:header('killsteal_header','Killsteal settings')
    Dalandan_menu.xerathmenu.Misc:boolean('q_ks', 'Use Q to Killsteal', true);
    Dalandan_menu.xerathmenu.Misc:boolean('w_ks', 'Use W to Killsteal', true);
    Dalandan_menu.xerathmenu.Misc:header('keybind_header','Keybinds')
    Dalandan_menu.xerathmenu.Misc:keybind('farm_key', 'Farm toggle', nil, 'A');
    Dalandan_menu.xerathmenu.Misc:keybind('aa_key', 'Stop aa toggle', nil, 'Z');

    --draw
    Dalandan_menu.xerathmenu:menu("Draw", "Drawing");
    Dalandan_menu.xerathmenu.Draw:set('icon',graphics.sprite('Sprites/Draw.png'))
    Dalandan_menu.xerathmenu.Draw:header('draw_header','Draw range')
    Dalandan_menu.xerathmenu.Draw:boolean('ready', 'Draw only when skill is ready', true);
    Dalandan_menu.xerathmenu.Draw:boolean('q_draw', 'Draw Q', true);
    Dalandan_menu.xerathmenu.Draw:boolean('w_draw', 'Draw W', true);
    Dalandan_menu.xerathmenu.Draw:boolean('e_draw', 'Draw E', true);
    Dalandan_menu.xerathmenu.Draw:boolean('r_draw', 'Draw R', true);
    Dalandan_menu.xerathmenu.Draw:header('dmg_draw_header','Draw damage')
    Dalandan_menu.xerathmenu.Draw:boolean('dmg_draw', 'Show damage on hp bar', true);
    Dalandan_menu.xerathmenu.Draw.dmg_draw:set('tooltip','if slightly (x1.5) above Q range show QWE damage, otherwise show only R damage')
    Dalandan_menu.xerathmenu.Draw:boolean('dmg_draw_ready', '^ Show damage only if skill ready', true);
    Dalandan_menu.xerathmenu.Draw:boolean('q_draw_dmg', '^ Draw Q damage', true);
    Dalandan_menu.xerathmenu.Draw:boolean('w_draw_dmg', '^ Draw W damage', true);
    Dalandan_menu.xerathmenu.Draw:boolean('e_draw_dmg', '^ Draw E damage', true);
    
end
if player.charName == "Zed" and Dalandan_menu.mainmenu.champion:get() then
    Dalandan_menu.zedmenu = menu("Dalandan_Menu_"..player.charName, "Dalandan AIO - "..player.charName);
    Dalandan_menu.zedmenu:menu("Combo", "Combo");
    Dalandan_menu.zedmenu.Combo:boolean('q_combo', 'Use Q', true);
    Dalandan_menu.zedmenu.Combo:boolean('w_combo', 'Use W', true);
    Dalandan_menu.zedmenu.Combo:boolean('e_combo', 'Use E', true);
    Dalandan_menu.zedmenu.Combo:boolean('r_combo', 'Use R', true);

    Dalandan_menu.zedmenu:menu("Harass", "Harass");
    Dalandan_menu.zedmenu.Harass:boolean('q_harass', 'Use Q', true);
    Dalandan_menu.zedmenu.Harass:boolean('w_harass', 'Use W', true);
    Dalandan_menu.zedmenu.Harass:boolean('e_harass', 'Use E', true);

    Dalandan_menu.zedmenu:menu("Lane", "Lane clear");
    Dalandan_menu.zedmenu.Lane:boolean('q_lane', 'Use Q', true);
    Dalandan_menu.zedmenu.Lane:boolean('e_lane', 'Use E', true);
    Dalandan_menu.zedmenu.Lane:slider('e_lane_minion', '^ Only when x minion hit', 3, 1, 6, 1);

    Dalandan_menu.zedmenu:menu("Draw", "Drawing");
    Dalandan_menu.zedmenu.Draw:boolean('ready', 'Draw only when skill is ready', true);
    Dalandan_menu.zedmenu.Draw:boolean('q_draw', 'Draw Q', true);
    Dalandan_menu.zedmenu.Draw:boolean('w_draw', 'Draw W', true);
    Dalandan_menu.zedmenu.Draw:boolean('e_draw', 'Draw E', true);
    Dalandan_menu.zedmenu.Draw:boolean('r_draw', 'Draw R', true);
    Dalandan_menu.zedmenu.Draw:boolean('wq_draw', 'Draw WQ', true);
    Dalandan_menu.zedmenu.Draw:boolean('shadow_draw', 'Draw Shadows', true);
    Dalandan_menu.zedmenu.Draw:boolean('dmg_draw', 'Draw if killable with R', true);
end
if player.charName == "Yasuo" and Dalandan_menu.mainmenu.champion:get() then
    Dalandan_menu.yasuomenu = menu("Dalandan_Menu_"..player.charName, "Dalandan AIO - "..player.charName);
    Dalandan_menu.yasuomenu:set('icon',graphics.sprite('Yasuo/Yasuo.png'))

    -- --------------- new shit (old) ---------------
    -- Dalandan_menu.yasuomenu:menu("Combo", "Combo");
    -- Dalandan_menu.yasuomenu.Combo:set('icon',graphics.sprite('Sprites/Combo.png'))
    -- Dalandan_menu.yasuomenu.Combo:boolean("q_combo","Use Q", true)
    -- Dalandan_menu.yasuomenu.Combo:boolean("e_combo","Use E", true)
    -- Dalandan_menu.yasuomenu.Combo:boolean("e_gap_combo","Use E as gapcloser", true)
    -- Dalandan_menu.yasuomenu.Combo:boolean("r_combo","Use R", true)
    -- Dalandan_menu.yasuomenu.Combo:slider("r_enemy_hp","R if enemy %HP is < this value",60,1,100,1)
    -- Dalandan_menu.yasuomenu.Combo:slider("r_yasuo_hp","R if your %HP > target %HP by this much",15,1,100,1)
    -- Dalandan_menu.yasuomenu.Combo.r_yasuo_hp:set('tooltip','Recommended value is between 10-20')

    -- Dalandan_menu.yasuomenu:menu("Harass", "Harass");
    -- Dalandan_menu.yasuomenu.Harass:set('icon',graphics.sprite('Sprites/Harass.png'))
    -- Dalandan_menu.yasuomenu.Harass:boolean("q_harass","Use Q", true)
    -- Dalandan_menu.yasuomenu.Harass:boolean("e_harass","Use E", true)
    -- Dalandan_menu.yasuomenu.Harass:boolean("e_gap_harass","Use E as gapcloser with minions", true)

    -- Dalandan_menu.yasuomenu:menu("Misc", "Misc");
    -- Dalandan_menu.yasuomenu.Misc:set('icon',graphics.sprite('Sprites/Misc.png'))
    -- -- Dalandan_menu.yasuomenu.Misc:boolean("EEvade", "Use E evade",true);
    -- Dalandan_menu.yasuomenu.Misc:keybind('flee_key', 'Flee', 'Z', nil);
    -- Dalandan_menu.yasuomenu.Misc:boolean("q_laneclear_stack","Use Q to stack in laneclear", true)
    -- Dalandan_menu.yasuomenu.Misc:boolean("e_laneclear","Use E in laneclear", true)
    -- Dalandan_menu.yasuomenu.Misc:boolean("q_lasthit","Use Q in lasthit", true)
    -- Dalandan_menu.yasuomenu.Misc:boolean("e_lasthit","Use E in lasthit", true)

    -- Dalandan_menu.yasuomenu:menu("Draw", "Draw");
    -- Dalandan_menu.yasuomenu.Draw:set('icon',graphics.sprite('Sprites/Draw.png'))
    -- Dalandan_menu.yasuomenu.Draw:boolean('ready', 'Draw only when skill is ready', true);
    -- Dalandan_menu.yasuomenu.Draw:boolean('q_draw', 'Draw Q', true);
    -- -- Dalandan_menu.yasuomenu.Draw:boolean('w_draw', 'Draw W', true);
    -- -- Dalandan_menu.yasuomenu.Draw:boolean('e_draw', 'Draw E', true);
    -- Dalandan_menu.yasuomenu.Draw:boolean('r_draw', 'Draw R', true);

    --------------- newer shit (mine) ---------------
    Dalandan_menu.yasuomenu:menu("Combo", "Combo");
    Dalandan_menu.yasuomenu.Combo:set('icon',graphics.sprite('Sprites/Combo.png'))
    Dalandan_menu.yasuomenu.Combo:header("r_header","R settings")
    -- Dalandan_menu.yasuomenu.Combo:boolean("r_combo","Use R", true)
    Dalandan_menu.yasuomenu.Combo:keybind('r_combo', 'Auto R', nil, 'G');
    Dalandan_menu.yasuomenu.Combo:slider("r_enemy_hp","R if enemy %HP is < this value",60,1,100,1)
    Dalandan_menu.yasuomenu.Combo:slider("r_yasuo_hp","R if your %HP > target %HP by this much",15,1,100,1)
    Dalandan_menu.yasuomenu.Combo.r_yasuo_hp:set('tooltip','Recommended value is between 10-20')
    Dalandan_menu.yasuomenu.Combo:boolean("r_safety","Don't waste R on killable [WIP]", true)
    Dalandan_menu.yasuomenu.Combo.r_safety:set('tooltip','Dont use R if target is killable')
    Dalandan_menu.yasuomenu.Combo:boolean("airblade","Use airblade if possible", true)
    Dalandan_menu.yasuomenu.Combo.airblade:set('tooltip','Q3 -> EQ -> R')
    Dalandan_menu.yasuomenu.Combo:header("r_header","bayblade = EQ3 -> flash into enemy -> (R)")
    Dalandan_menu.yasuomenu.Combo:boolean("bayblade","Use bayblade", true)
    Dalandan_menu.yasuomenu.Combo.bayblade:set('tooltip','bayblade only works when target is manually selected')

    -- Dalandan_menu.yasuomenu:menu("Harass", "Harass");
    -- Dalandan_menu.yasuomenu.Harass:set('icon',graphics.sprite('Sprites/Harass.png'))
    -- Dalandan_menu.yasuomenu.Harass:boolean("q_harass","Use Q", true)
    -- Dalandan_menu.yasuomenu.Harass:boolean("e_harass","Use E", true)
    -- Dalandan_menu.yasuomenu.Harass:boolean("e_gap_harass","Use E as gapcloser with minions", true)

    Dalandan_menu.yasuomenu:menu("Misc", "Misc");
    Dalandan_menu.yasuomenu.Misc:set('icon',graphics.sprite('Sprites/Misc.png'))
    -- Dalandan_menu.yasuomenu.Misc:boolean("EEvade", "Use E evade",true);
    Dalandan_menu.yasuomenu.Misc:keybind('flee_key', 'Flee', 'Z', nil);
    Dalandan_menu.yasuomenu.Misc:boolean("flee_q","Stack Q when fleeing", true)
    Dalandan_menu.yasuomenu.Misc:boolean("flee_q3","Use Q3 on enemy when fleeing", true)
    Dalandan_menu.yasuomenu.Misc:dropdown('flee_q3_target', '^ Target', 1, {"closest","normal"});
    Dalandan_menu.yasuomenu.Misc:keybind('farm_key', 'Farm', nil, 'A');
    Dalandan_menu.yasuomenu.Misc:keybind('dive_key', 'Dive', nil, 'T');
    Dalandan_menu.yasuomenu.Misc:boolean("Q_after_aa","Use Q after aa", true)
    Dalandan_menu.yasuomenu.Misc:boolean("e_safety","Check E safety", true)
    -- Dalandan_menu.yasuomenu.Misc:boolean("q_laneclear_stack","Use Q to stack in laneclear", true)
    -- Dalandan_menu.yasuomenu.Misc:boolean("e_laneclear","Use E in laneclear", true)
    -- Dalandan_menu.yasuomenu.Misc:boolean("q_lasthit","Use Q in lasthit", true)
    -- Dalandan_menu.yasuomenu.Misc:boolean("e_lasthit","Use E in lasthit", true)

    Dalandan_menu.yasuomenu:menu("Draw", "Draw");
    Dalandan_menu.yasuomenu.Draw:set('icon',graphics.sprite('Sprites/Draw.png'))
    Dalandan_menu.yasuomenu.Draw:boolean('ready', 'Draw only when skill is ready', true);
    Dalandan_menu.yasuomenu.Draw:boolean('q_draw', 'Draw Q', true);
    -- Dalandan_menu.yasuomenu.Draw:boolean('w_draw', 'Draw W', true);
    -- Dalandan_menu.yasuomenu.Draw:boolean('e_draw', 'Draw E', true);
    Dalandan_menu.yasuomenu.Draw:boolean('r_draw', 'Draw R', true);

end
if player.charName == "Yone" and Dalandan_menu.mainmenu.champion:get() then
    Dalandan_menu.yonemenu = menu("Dalandan_Menu_"..player.charName, "Dalandan AIO - "..player.charName);
    Dalandan_menu.yonemenu:set('icon',graphics.sprite('Yone/Yone.png'))

    Dalandan_menu.yonemenu:menu("Combo", "Combo");
    Dalandan_menu.yonemenu.Combo:set('icon',graphics.sprite('Sprites/Combo.png'))
    Dalandan_menu.yonemenu.Combo:boolean("q_combo","Use Q", true)
    Dalandan_menu.yonemenu.Combo:boolean("w_combo","Use W", true)
    Dalandan_menu.yonemenu.Combo:boolean("e_combo","Use E", true)
    Dalandan_menu.yonemenu.Combo:boolean("r_combo","Use R", true)

    Dalandan_menu.yonemenu:menu("Lane", "Lane");
    Dalandan_menu.yonemenu.Lane:set('icon',graphics.sprite('Sprites/icon minions light.png'))
    -- Dalandan_menu.yonemenu.Lane:boolean("q_lasthit","Use Q to lasthit", true)
    Dalandan_menu.yonemenu.Lane:boolean("q_laneclear","Use Q to laneclear", true)
    Dalandan_menu.yonemenu.Lane:boolean("w_laneclear","Use W to laneclear", true)
    Dalandan_menu.yonemenu.Lane:boolean("q_jungle","Use Q to jungle", true)
    Dalandan_menu.yonemenu.Lane:boolean("w_jungle","Use W to jungle", true)

    Dalandan_menu.yonemenu:menu("Misc", "Misc");
    Dalandan_menu.yonemenu.Misc:set('icon',graphics.sprite('Sprites/Misc.png'))
    Dalandan_menu.yonemenu.Misc:boolean("q_ks","Use Q to killsteal", true)
    Dalandan_menu.yonemenu.Misc:boolean("w_ks","Use W to killsteal", true)
    Dalandan_menu.yonemenu.Misc:boolean("r_ks","Use R to killsteal", true)
    Dalandan_menu.yonemenu.Misc:keybind('r_semi', 'Semi R', 'T',nil);

    Dalandan_menu.yonemenu:menu("Draw", "Draw");
    Dalandan_menu.yonemenu.Draw:set('icon',graphics.sprite('Sprites/Draw.png'))
    Dalandan_menu.yonemenu.Draw:boolean('ready', 'Draw only when skill is ready', true);
    Dalandan_menu.yonemenu.Draw:boolean('q_draw', 'Draw Q', true);
    Dalandan_menu.yonemenu.Draw:boolean('w_draw', 'Draw W', false);
    Dalandan_menu.yonemenu.Draw:boolean('e_draw', 'Draw E', false);
    Dalandan_menu.yonemenu.Draw:boolean('r_draw', 'Draw R', true);
    Dalandan_menu.yonemenu.Draw:boolean('dmg_draw', 'Show damage on hp bar', true);
end
return Dalandan_menu