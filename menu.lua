local Dalandan_menu = {}

if player.charName == "Lux" then
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

if player.charName == "Malphite" then
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
if player.charName == "Ryze" then
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
if player.charName == "TwistedFate" then
    Dalandan_menu.tfmenu = menu("Dalandan_Menu_"..player.charName, "Dalandan AIO - "..player.charName);
    -- Combo
    Dalandan_menu.tfmenu:menu("Combo", "Combo");
    Dalandan_menu.tfmenu.Combo:header('q_combo_header','Q settings')
    Dalandan_menu.tfmenu.Combo:boolean('q_combo', 'Use Q', true);
    Dalandan_menu.tfmenu.Combo:boolean('q_combo_onlyCC', '^ Use Q only when CC/Slow [shit]', true);
    Dalandan_menu.tfmenu.Combo:header('w_combo_header','W settings')
    Dalandan_menu.tfmenu.Combo:boolean('w_combo', 'Use W', true);
    Dalandan_menu.tfmenu.Combo:boolean('w_always_gold', '^ Always use golden card in combo', true);
    -- Dalandan_menu.tfmenu.Combo:boolean('w_damage_card', '^ Unless other card can kill', true);
    
    --Lane
    Dalandan_menu.tfmenu:menu("Lane", "Lane Clear");
    Dalandan_menu.tfmenu.Lane:header('q_lane_header','Q settings lane')
    Dalandan_menu.tfmenu.Lane:boolean('q_lane', 'Use Q in lane [idk kinda wonky]', true);
    Dalandan_menu.tfmenu.Lane:slider('q_lane_minion', '^ Only when x minion hit', 4, 1, 12, 1);
    Dalandan_menu.tfmenu.Lane:slider('q_lane_mana', '^ Only when above x% mana', 25, 0, 100, 5);
    
    Dalandan_menu.tfmenu.Lane:header('w_lane_header','W settings lane')
    Dalandan_menu.tfmenu.Lane:boolean('w_lane', 'Use W in lane', true);
    Dalandan_menu.tfmenu.Lane.w_lane:set('tooltip', 'Will always pick red card unless other conditions are met');
    Dalandan_menu.tfmenu.Lane:slider('w_lane_mana', 'Pick blue card if below x% mana', 45, 0, 100, 5);
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
    Dalandan_menu.tfmenu.Draw:header('draw_header','Draw range')
    Dalandan_menu.tfmenu.Draw:boolean('ready', 'Draw only when skill is ready', true);
    Dalandan_menu.tfmenu.Draw:boolean('q_draw', 'Draw Q', true);
    Dalandan_menu.tfmenu.Draw:boolean('r_draw', 'Draw R', true);
    Dalandan_menu.tfmenu.Draw:header('dmg_draw_header','Draw damage')
    Dalandan_menu.tfmenu.Draw:boolean('dmg_draw', 'Show damage on hp bar', true);
    Dalandan_menu.tfmenu.Draw:boolean('dmg_draw_ready', '^ Show damage only if skill ready', true);
    Dalandan_menu.tfmenu.Draw:boolean('q_draw_dmg', '^ Draw Q damage', true);
end
if player.charName == "Xerath" then
    Dalandan_menu.xerathmenu = menu("Dalandan_Menu_"..player.charName, "Dalandan AIO - "..player.charName);

    
    -- Combo
    Dalandan_menu.xerathmenu:menu("Combo", "Combo");
    Dalandan_menu.xerathmenu.Combo:header('q_combo_header','Q settings')
    Dalandan_menu.xerathmenu.Combo:boolean('q_combo', 'Use Q', true);
    Dalandan_menu.xerathmenu.Combo:dropdown('q_combo_when', 'Use Q time (if possible) [WIP]',2, {"Before W","After W"});
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
    Dalandan_menu.xerathmenu.Combo:boolean('slow_pred_r', 'Use slower prediction on R', true);


    -- Lane
    Dalandan_menu.xerathmenu:menu("Lane", "Lane");
    Dalandan_menu.xerathmenu.Lane:header('q_lane_header','Q settings')
    Dalandan_menu.xerathmenu.Lane:boolean('q_lane', 'Use Q in lane [sometimes bugged lmao]', true); 
    Dalandan_menu.xerathmenu.Lane:slider('q_lane_minion', '^ Only when x minion hit', 4, 1, 12, 1);

    Dalandan_menu.xerathmenu.Lane:header('w_lane_header','W settings')
    Dalandan_menu.xerathmenu.Lane:boolean('w_lane', 'Use W in lane', true);

    -- Misc
    Dalandan_menu.xerathmenu:menu("Misc", "Misc"); 
    Dalandan_menu.xerathmenu.Misc:header('gapClose_header','Anti-Gapcloser settings')
    Dalandan_menu.xerathmenu.Misc:boolean('e_gap', 'Use E for Anti-Gapclose', true);
    Dalandan_menu.xerathmenu.Misc:header('interrupt_header','Interrupt settings')
    Dalandan_menu.xerathmenu.Misc:boolean('e_int', 'Use E for interrupt enemy spells [WIP]', true);
    Dalandan_menu.xerathmenu.Misc:header('killsteal_header','Killsteal settings')
    Dalandan_menu.xerathmenu.Misc:boolean('q_ks', 'Use Q to Killsteal', true);
    Dalandan_menu.xerathmenu.Misc:boolean('w_ks', 'Use W to Killsteal', true);
    Dalandan_menu.xerathmenu.Misc:header('r_header','R settings')





    --draw
    Dalandan_menu.xerathmenu:menu("Draw", "Drawing");
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
return Dalandan_menu