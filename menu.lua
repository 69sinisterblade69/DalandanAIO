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
Dalandan_menu.mainmenu:boolean('awareness', 'Load awareness', true);

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
Dalandan_menu.mainmenu.awareness:set('callback', menuReload)

if Dalandan_menu.mainmenu.utility:get() then
    Dalandan_menu.utilitymenu = menu("Dalandan_Menu_Utility", "Dalandan AIO - Utility");
    
    Dalandan_menu.utilitymenu:menu("pings", "Auto pings")
    Dalandan_menu.utilitymenu.pings:boolean('ping_ward', 'Ping on enemy wards', false);
    Dalandan_menu.utilitymenu.pings:boolean('ping_ward_visible', '^ Ping only if ward is on your screen', false);
    Dalandan_menu.utilitymenu.pings:slider('delay', '^ Delay [ms]', 700, 0, 5000, 50 );
    Dalandan_menu.utilitymenu.pings:dropdown('ping_ward_type',"Ping type",1,{"Enemy has vision","alert/generic (the blue dot)"})
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

    local allies = {}
    for i=0, objManager.allies_n-1 do
      local obj = objManager.allies[i]
      allies[i] = obj.charName
    end
    if objManager.allies_n > 1 then
      Dalandan_menu.utilitymenu:menu("TrollPing", "Troll Ping")
      Dalandan_menu.utilitymenu.TrollPing:boolean("DoTroll","Use troll ping", false)
      Dalandan_menu.utilitymenu.TrollPing.DoTroll:set('tooltip', 'Will use "?" ping on ally every couple seconds');
      Dalandan_menu.utilitymenu.TrollPing:dropdown("selectedTroll", "Who to troll", 1,allies);
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
    Dalandan_menu.utilitymenu.trollchat:keybind('troll_keybind1', '"keybind1" message', nil,nil);
    Dalandan_menu.utilitymenu.trollchat:keybind('troll_keybind2', '"keybind2" message', nil,nil);
    Dalandan_menu.utilitymenu.trollchat:keybind('troll_keybind3', '"keybind3" message', nil,nil);
    Dalandan_menu.utilitymenu.trollchat.troll_keybind1:permashow(false)
    Dalandan_menu.utilitymenu.trollchat.troll_keybind2:permashow(false)
    Dalandan_menu.utilitymenu.trollchat.troll_keybind3:permashow(false)

    Dalandan_menu.utilitymenu:menu("trollemote", "Troll Emote")
    Dalandan_menu.utilitymenu.trollemote:keybind('emote_spam', 'Spam selected emote', nil,'H');
    Dalandan_menu.utilitymenu.trollemote:dropdown('emote',"Select emote",1,{"dance","taunt","laugh","joke"})
    Dalandan_menu.utilitymenu.trollemote:slider('delay', 'Delay (ms)', 250, 100, 500, 10);
    Dalandan_menu.utilitymenu.trollemote.delay:set('callback',menuReload)
end

if Dalandan_menu.mainmenu.awareness:get() then
    Dalandan_menu.awarenessmenu = menu("Dalandan_Menu_Awareness", "Dalandan AIO - Awareness");

    Dalandan_menu.awarenessmenu:menu("aa", "AA indicator")
    Dalandan_menu.awarenessmenu.aa:boolean('show', 'Show how many aa to kill', true);
    Dalandan_menu.awarenessmenu.aa:slider('size', 'Size', 22, 14, 50, 1);
    Dalandan_menu.awarenessmenu.aa:color('MyColor',"Color",255,255,255,255)

    Dalandan_menu.awarenessmenu:menu("cdtracker", "Cooldown tracker")
    Dalandan_menu.awarenessmenu.cdtracker:boolean('show', 'Show cooldown tracker', false);
    Dalandan_menu.awarenessmenu.cdtracker:dropdown('tracker_style', 'Style of cooldown tracker', 1,{"1","2"})
    Dalandan_menu.awarenessmenu.cdtracker:boolean('enemy', 'Show on enemy', true);
    Dalandan_menu.awarenessmenu.cdtracker:boolean('ally', 'Show on ally', false);
    Dalandan_menu.awarenessmenu.cdtracker:boolean('self', 'Show on self', false);
    Dalandan_menu.awarenessmenu.cdtracker:boolean('yuumi', 'Dont show on yuumi', false);
    Dalandan_menu.awarenessmenu.cdtracker:boolean('level', 'Show skill levels', true);
    Dalandan_menu.awarenessmenu.cdtracker:dropdown('level_type', 'Style of skill level', 4,{"rectangle","dots outside","dots inside","number"})
    Dalandan_menu.awarenessmenu.cdtracker:color('skill_color', "Skill levels color", 255, 255, 255, 255)
    
    Dalandan_menu.awarenessmenu.cdtracker:menu("borderr", "Border")
    Dalandan_menu.awarenessmenu.cdtracker.borderr:boolean('border', 'Show border', true);
    Dalandan_menu.awarenessmenu.cdtracker.borderr:boolean('borderReady', '^ Only if skill ready', true);
    Dalandan_menu.awarenessmenu.cdtracker.borderr:slider('borderSize', 'Border size', 2, 1, 10, 1);
    Dalandan_menu.awarenessmenu.cdtracker.borderr:color('MyColor', "Border color", 255, 255, 255, 255)
    Dalandan_menu.awarenessmenu.cdtracker.borderr:boolean('borderChange', '^ auto change color if on cd or ready', true);
    Dalandan_menu.awarenessmenu.cdtracker.borderr.borderChange:set('tooltip', "Remember to disable Only If Skill Ready option!")
    Dalandan_menu.awarenessmenu.cdtracker.borderr:color('MyColorCD', "Border color CD", 255, 255, 0, 0)
    Dalandan_menu.awarenessmenu.cdtracker.borderr:color('MyColorReady', "Border color Ready", 255, 0, 255, 0)
    Dalandan_menu.awarenessmenu.cdtracker.borderr:button("reset","Set default colors","Reset",function() 
      Dalandan_menu.awarenessmenu.cdtracker.borderr.MyColorCD:set('red',255)
      Dalandan_menu.awarenessmenu.cdtracker.borderr.MyColorCD:set('green',0)
      Dalandan_menu.awarenessmenu.cdtracker.borderr.MyColorCD:set('blue',0)
      Dalandan_menu.awarenessmenu.cdtracker.borderr.MyColorCD:set('alpha',255)

      Dalandan_menu.awarenessmenu.cdtracker.borderr.MyColorReady:set('red',0)
      Dalandan_menu.awarenessmenu.cdtracker.borderr.MyColorReady:set('green',255)
      Dalandan_menu.awarenessmenu.cdtracker.borderr.MyColorReady:set('blue',0)
      Dalandan_menu.awarenessmenu.cdtracker.borderr.MyColorReady:set('alpha',255)
    end)

    Dalandan_menu.awarenessmenu.cdtracker:slider('cdColor', 'Brightness of spell on cooldown', 130, 0, 255, 1);
    -- Dalandan_menu.awarenessmenu.cdtracker:boolean('passive', 'Show certain passives', true);
    -- Dalandan_menu.awarenessmenu.cdtracker.passive:set('tooltip', 'Like anivia, zac, corki etc.');
    Dalandan_menu.awarenessmenu.cdtracker:boolean('item', 'Show items cooldown', true);
    
    Dalandan_menu.awarenessmenu.cdtracker:menu("item_select", "Item select")
    Dalandan_menu.awarenessmenu.cdtracker.item_select:boolean('zhonya', 'Show Zhonya/Stopwatch', true);
    Dalandan_menu.awarenessmenu.cdtracker.item_select:boolean('galeforce', 'Show Galeforce', true);
    -- Dalandan_menu.awarenessmenu.cdtracker.item_select:boolean('ga', 'Show Guardians Angel', true);
    Dalandan_menu.awarenessmenu.cdtracker.item_select:boolean('qss', 'Show qss/Mercurial Scimitar/Silvermere Dawn', true);
    Dalandan_menu.awarenessmenu.cdtracker.item_select:boolean('youmuu', 'Show Youmuu Ghostblade', true);
    Dalandan_menu.awarenessmenu.cdtracker.item_select:boolean('goredrinker', 'Show Goredrinker/Stridebreaker/Ironspike whip', true);
    Dalandan_menu.awarenessmenu.cdtracker.item_select:boolean('randuin', 'Show Randuin Omen', true);
    -- Dalandan_menu.awarenessmenu.cdtracker.item_select:boolean('crown', 'Show Crown of the Shattered Queen', true);
    -- Dalandan_menu.awarenessmenu.cdtracker.item_select:boolean('stridebreaker', 'Show Stridebreaker', true);
    Dalandan_menu.awarenessmenu.cdtracker.item_select:boolean('everfrost', 'Show Everfrost', true);
    Dalandan_menu.awarenessmenu.cdtracker.item_select:boolean('rocketbelt', 'Show Rocketbelt', true);
    Dalandan_menu.awarenessmenu.cdtracker.item_select:boolean('shurelya', 'Show Shurelyas Battlesong', true);
    Dalandan_menu.awarenessmenu.cdtracker.item_select:boolean('mikael', 'Show Mikaels Blessing', true);
    Dalandan_menu.awarenessmenu.cdtracker.item_select:boolean('redemption', 'Show Redemption', true);
    -- Dalandan_menu.awarenessmenu.cdtracker.item_select:boolean('shieldbow', 'Show Immortal Shieldbow', true);
    Dalandan_menu.awarenessmenu.cdtracker.item_select:boolean('solari', 'Show Locket of the Iron Solari', true);
    Dalandan_menu.awarenessmenu.cdtracker.item_select:boolean('gargoyle', 'Show Gargoyle Stoneplate', true);
    -- Dalandan_menu.awarenessmenu.cdtracker.item_select:boolean('banshee', 'Show Banshees Veil', true);
    -- Dalandan_menu.awarenessmenu.cdtracker.item_select:boolean('archangel', 'Show Seraphs Embrace', true);
    
    Dalandan_menu.awarenessmenu.cdtracker:menu("customization", "Additional Customization")
    Dalandan_menu.awarenessmenu.cdtracker.customization:header("cust","FIRST CHECK HIGHRES MODE")
    Dalandan_menu.awarenessmenu.cdtracker.customization:header("cust","THIS TAB IS FOR FINETUNING")
    Dalandan_menu.awarenessmenu.cdtracker.customization:boolean('some_champs', 'Automatically move it down on some champs', true);
    Dalandan_menu.awarenessmenu.cdtracker.customization.some_champs:set('tooltip',"like annie, jhin, samira etc.")
    Dalandan_menu.awarenessmenu.cdtracker.customization:slider('some_champs_value', '^ Move how much', 10, 0, 100, 1);
    Dalandan_menu.awarenessmenu.cdtracker.customization:slider('x', 'X pos', 0, -100, 100, 1);
    Dalandan_menu.awarenessmenu.cdtracker.customization:slider('y', 'Y pos', 0, -100, 100, 1);
    Dalandan_menu.awarenessmenu.cdtracker.customization:slider('scale', 'Size of icons [%]', 100, 0, 500, 1);
    Dalandan_menu.awarenessmenu.cdtracker.customization:slider('spaceX', 'Spacing of icons [X]', 1, -5, 20, 1);
    Dalandan_menu.awarenessmenu.cdtracker.customization:slider('spaceY', 'Spacing of icons [Y]', 1, -5, 20, 1);
    Dalandan_menu.awarenessmenu.cdtracker.customization:slider('cdX', 'CD text pos x', 0, -50, 50, 1);
    Dalandan_menu.awarenessmenu.cdtracker.customization:slider('cdY', 'CD text pos y', 0, -50, 50, 1);
    Dalandan_menu.awarenessmenu.cdtracker.customization:slider('levelX', 'Level pos x', 0, -50, 50, 1);
    Dalandan_menu.awarenessmenu.cdtracker.customization:slider('levelY', 'Level pos y', 0, -50, 50, 1);
    Dalandan_menu.awarenessmenu.cdtracker.customization:slider('textSize', 'Text size [%]', 0, 0, 500, 5);
    Dalandan_menu.awarenessmenu.cdtracker.customization:button('reset',"Reset to default","Click",function() 
        Dalandan_menu.awarenessmenu.cdtracker.customization.x:set('value',0)
        Dalandan_menu.awarenessmenu.cdtracker.customization.y:set('value',0)
        Dalandan_menu.awarenessmenu.cdtracker.customization.scale:set('value',100)
        Dalandan_menu.awarenessmenu.cdtracker.customization.spaceX:set('value',1)
        Dalandan_menu.awarenessmenu.cdtracker.customization.spaceY:set('value',1)
        Dalandan_menu.awarenessmenu.cdtracker.customization.cdX:set('value',0)
        Dalandan_menu.awarenessmenu.cdtracker.customization.cdY:set('value',0)
        Dalandan_menu.awarenessmenu.cdtracker.customization.levelX:set('value',0)
        Dalandan_menu.awarenessmenu.cdtracker.customization.levelY:set('value',0)
        Dalandan_menu.awarenessmenu.cdtracker.customization.textSize:set('value',100)
    end)
    Dalandan_menu.awarenessmenu.cdtracker.customization:button('Level1Preset',"Preset for 1080p and <number> skill levels","Click",function() 
      Dalandan_menu.awarenessmenu.cdtracker.customization.x:set('value',-25)
      Dalandan_menu.awarenessmenu.cdtracker.customization.y:set('value',5)
      Dalandan_menu.awarenessmenu.cdtracker.customization.scale:set('value',110)
      Dalandan_menu.awarenessmenu.cdtracker.customization.spaceX:set('value',5)
      Dalandan_menu.awarenessmenu.cdtracker.customization.spaceY:set('value',1)
      Dalandan_menu.awarenessmenu.cdtracker.customization.cdX:set('value',1)
      Dalandan_menu.awarenessmenu.cdtracker.customization.cdY:set('value',1)
      Dalandan_menu.awarenessmenu.cdtracker.customization.levelX:set('value',4)
      Dalandan_menu.awarenessmenu.cdtracker.customization.levelY:set('value',0)
      Dalandan_menu.awarenessmenu.cdtracker.customization.textSize:set('value',100)
    end)
    Dalandan_menu.awarenessmenu.cdtracker.customization.Level1Preset:set('tooltip', 'Recommended values if playing with <number> skill levels on 1080p screen');

    Dalandan_menu.awarenessmenu:menu("hud", "HUD")
    Dalandan_menu.awarenessmenu.hud:boolean('show', 'Show HUD', true);
    Dalandan_menu.awarenessmenu.hud:dropdown('style', 'HUD Style', 3,{"Ws","Ws short","Dalandan"});
    Dalandan_menu.awarenessmenu.hud.style:set('tooltip','Not every option (like direction or bar height) works on every style, and Im too lazy to hide them automatically, sorry')
    Dalandan_menu.awarenessmenu.hud:dropdown('direction', 'HUD direction', 1,{"Vertical","Horizontal"});
    Dalandan_menu.awarenessmenu.hud:boolean('showText', 'Show text on hp and mp', false);
    Dalandan_menu.awarenessmenu.hud:boolean('showRune', 'Show Runes', false);
    Dalandan_menu.awarenessmenu.hud:boolean('showExp', 'Show Exp', true);
    Dalandan_menu.awarenessmenu.hud:boolean('showLocation', 'Show current/last known location', true);
    Dalandan_menu.awarenessmenu.hud:boolean('reverseSumm', 'Reverse Ult and summoners order', false);

    Dalandan_menu.awarenessmenu.hud:menu("customization", "Customization")
    Dalandan_menu.awarenessmenu.hud.customization:slider('x', 'X pos', 5, 5, graphics.width, 5);
    Dalandan_menu.awarenessmenu.hud.customization:slider('y', 'Y pos', 100, 0, graphics.height, 5);
    Dalandan_menu.awarenessmenu.hud.customization:slider('scale', 'Scale [%]', 100, 1, 500, 5);
    Dalandan_menu.awarenessmenu.hud.customization:slider('textSize', 'Text size (cooldown and level) [%]', 100, 1, 500, 5);
    Dalandan_menu.awarenessmenu.hud.customization:slider('deathSize', 'Text size (death and missing timer) [%]', 100, 1, 500, 5);
    Dalandan_menu.awarenessmenu.hud.customization:slider('barSize', 'Bar height', 15, 1, 100, 1);
    Dalandan_menu.awarenessmenu.hud.customization:slider('barBorder', 'Bar border size', 3, 0, 20, 1);
    Dalandan_menu.awarenessmenu.hud.customization:slider('expSize', 'Exp bar height', 2, 1, 100, 1);
    Dalandan_menu.awarenessmenu.hud.customization:slider('champSpacing', 'Spacing', 5, 0, 50, 1);
    Dalandan_menu.awarenessmenu.hud.customization:button('reset',"Reset to default","Click",function()
      Dalandan_menu.awarenessmenu.hud.customization.x:set('value',1) 
      Dalandan_menu.awarenessmenu.hud.customization.y:set('value',100) 
      Dalandan_menu.awarenessmenu.hud.customization.scale:set('value',100) 
      Dalandan_menu.awarenessmenu.hud.customization.textSize:set('value',100)
      Dalandan_menu.awarenessmenu.hud.customization.deathSize:set('value',100)
      Dalandan_menu.awarenessmenu.hud.customization.barSize:set('value',15)
      Dalandan_menu.awarenessmenu.hud.customization.barBorder:set('value',3)
      Dalandan_menu.awarenessmenu.hud.customization.champSpacing:set('value',5)
      Dalandan_menu.awarenessmenu.hud.customization.expSize:set('value',2)

  end)
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
    Dalandan_menu.tfmenu:set('icon',player.iconSquare)
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
    Dalandan_menu.xerathmenu:set('icon',player.iconSquare)
    
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
    Dalandan_menu.xerathmenu.Combo:boolean('slow_pred_r', 'Use slow pred on R', true);
    Dalandan_menu.xerathmenu.Combo.slow_pred_r:set('tooltip',"only old and mixed prediction");
    Dalandan_menu.xerathmenu.Combo:dropdown('r_prediction', 'Prediction', 3, {"old","experimental","mixed"});
    Dalandan_menu.xerathmenu.Combo:slider('r_pred_factor', 'Pred factor, only mixed pred', 30, 0, 100, 1);
    Dalandan_menu.xerathmenu.Combo.r_pred_factor:set('tooltip',"0 = old, 100 = experimental, default = 30, lower this value if you overshoot, increase it if you undershoot");
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
    Dalandan_menu.yasuomenu:set('icon',player.iconSquare)

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
    Dalandan_menu.yonemenu:set('icon',player.iconSquare)

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
-- if player.charName == "Ezreal" and Dalandan_menu.mainmenu.champion:get() then
--     Dalandan_menu.ezrealmenu = menu("Dalandan_Menu_"..player.charName, "Dalandan AIO - "..player.charName);
--     -- Dalandan_menu.ezrealmenu:set('icon',graphics.sprite('Yone/Yone.png'))

--     Dalandan_menu.ezrealmenu:menu("q", "Q settings");
--     Dalandan_menu.ezrealmenu.q:boolean("q_always","Use Q when high stacks", true)
--     Dalandan_menu.ezrealmenu.q:boolean("q_combo","Use Q in combo", true)
--     Dalandan_menu.ezrealmenu.q:boolean("q_laneclear","Use Q in laneclear on enemy", true)
--     Dalandan_menu.ezrealmenu.q:boolean("q_minion","Use Q in laneclear on minions", true)

--     Dalandan_menu.ezrealmenu:menu("w", "W settings");
--     Dalandan_menu.ezrealmenu.w:boolean("w_combo","Use W in combo", true)

--     Dalandan_menu.ezrealmenu:menu("r", "R settings");
--     Dalandan_menu.ezrealmenu.r:boolean("r_ks","Use R killsteal", true)
--     Dalandan_menu.ezrealmenu.r:slider("r_min","R min range",common.GetAARange()+100,0,2000,50)
--     Dalandan_menu.ezrealmenu.r:slider("r_max","R max range",15,1,100,1)
     
-- end
if player.charName == "Caitlyn" and Dalandan_menu.mainmenu.champion:get() then
    Dalandan_menu.caitlynmenu = menu("Dalandan_Menu_"..player.charName, "Dalandan AIO - "..player.charName);
    Dalandan_menu.caitlynmenu:set('icon',player.iconSquare)

    Dalandan_menu.caitlynmenu:menu("q", "Q settings");
    Dalandan_menu.caitlynmenu.q:set('icon',player:spellSlot(0).icon)
    Dalandan_menu.caitlynmenu.q:boolean("pred","Use slow pred for Q", true)
    Dalandan_menu.caitlynmenu.q:boolean("aarange","Don't use Q in AA range on enemy", true)
    Dalandan_menu.caitlynmenu.q.aarange:set("tooltip","works only in combo")
    Dalandan_menu.caitlynmenu.q:boolean("q_dps","Don't use Q if dps < aa dps", true)
    -- Dalandan_menu.caitlynmenu.q:slider("q_dps_critChance","^ Use crit damage when critchance above", 100,0,100,1)
    Dalandan_menu.caitlynmenu.q.q_dps:set("tooltip","and target is in aa range, works only in combo")
    Dalandan_menu.caitlynmenu.q:boolean("q_combo","Use Q in combo", true)
    Dalandan_menu.caitlynmenu.q:boolean("q_eq","Use Q when casting E", true)
    Dalandan_menu.caitlynmenu.q:boolean("q_farm","Use Q in laneclear", true)
    Dalandan_menu.caitlynmenu.q:slider('q_count', '^ Only when x minion hit', 3, 1, 6, 1);
    Dalandan_menu.caitlynmenu.q:boolean("q_jungle","Use Q in jungle clear", true)
    Dalandan_menu.caitlynmenu.q:boolean("q_lasthit","Use Q to lasthit cannon", true)
    Dalandan_menu.caitlynmenu.q:boolean("q_harass","Use Q in Harass", true)
    Dalandan_menu.caitlynmenu.q:slider('q_count_harass', '^ Only when enemy and x minion hit', 3, 1, 6, 1);

    Dalandan_menu.caitlynmenu:menu("w", "W settings");
    Dalandan_menu.caitlynmenu.w:set('icon',player:spellSlot(1).icon)
    -- Dalandan_menu.caitlynmenu.w:boolean("w_combo","Use W in combo", true)
    Dalandan_menu.caitlynmenu.w:boolean("w_antigapcloser","Use W for Anti-Gapclose", true)
    Dalandan_menu.caitlynmenu.w:boolean("w_auto","Auto W in certain situations", true)
    Dalandan_menu.caitlynmenu.w.w_auto:set("tooltip","like if in melee range, slowed, cc'd, ")
    Dalandan_menu.caitlynmenu.w:boolean("w_ew","Auto W when casting E", true)
    Dalandan_menu.caitlynmenu.w:boolean("w_prio","Prioritize W over Q in combo (WIP)", true)

    Dalandan_menu.caitlynmenu:menu("e", "E settings");
    Dalandan_menu.caitlynmenu.e:set('icon',player:spellSlot(2).icon)
    Dalandan_menu.caitlynmenu.e:boolean("e_combo","Use E in combo", true)
    Dalandan_menu.caitlynmenu.e:boolean("e_antigapcloser","Use E for Anti-Gapclose", true)
    Dalandan_menu.caitlynmenu.e:boolean("e_chase","Use E to chase low hp target", true)
    Dalandan_menu.caitlynmenu.e:slider('chase_hp', 'How low hp to chase [%]', 25, 0, 100, 5);
    Dalandan_menu.caitlynmenu.e:boolean("e_galeforce","Use E + galeforce in combo", true)
    Dalandan_menu.caitlynmenu.e:slider('gale_hp', 'How low hp to chase with galeforce combo [%]', 20, 0, 100, 5);
    Dalandan_menu.caitlynmenu.e:boolean("e_safety_melee","Safety check for dashing into melee champion", true)
    Dalandan_menu.caitlynmenu.e:boolean("e_safety_hook","Block E cast if near enemy has hook", true)
    Dalandan_menu.caitlynmenu.e.e_safety_hook:set('tooltip',"Blitz, Thresh, Pyke, Nautilus")

    Dalandan_menu.caitlynmenu:menu("r", "R settings");
    Dalandan_menu.caitlynmenu.r:set('icon',player:spellSlot(3).icon)
    Dalandan_menu.caitlynmenu.r:keybind('r_key', 'Semi R', 'R', nil);
    Dalandan_menu.caitlynmenu.r:dropdown('r_mode',"Semi R mode",1,{"Closest to mouse","Lowest HP"})

    Dalandan_menu.caitlynmenu:menu("Misc", "Misc");
    Dalandan_menu.caitlynmenu.Misc:set('icon',graphics.sprite('Sprites/Misc.png'))
    Dalandan_menu.caitlynmenu.Misc:keybind('farm_key', 'Farm toggle', nil, 'A');
    Dalandan_menu.caitlynmenu.Misc:keybind('flee_key', 'Use E to dash to mouse pos', 'Z', nil);
    Dalandan_menu.caitlynmenu.Misc:boolean("eq_ks","Use E + [Q] + AA ks", true)

    Dalandan_menu.caitlynmenu:menu("Draw", "Draw");
    Dalandan_menu.caitlynmenu.Draw:set('icon',graphics.sprite('Sprites/Draw.png'))
    Dalandan_menu.caitlynmenu.Draw:boolean('ready', 'Draw only when skill is ready', true);
    Dalandan_menu.caitlynmenu.Draw:boolean('q_draw', 'Draw Q', true);
    Dalandan_menu.caitlynmenu.Draw:boolean('w_draw', 'Draw W', true);
    Dalandan_menu.caitlynmenu.Draw:boolean('e_draw', 'Draw E', true);
    Dalandan_menu.caitlynmenu.Draw:boolean('r_draw', 'Draw R', true);
    Dalandan_menu.caitlynmenu.Draw:boolean('r_dmg', 'Draw R Damage', true);
    Dalandan_menu.caitlynmenu.Draw:boolean('farm', 'Draw farm toggle status', true);
end
if player.charName == "Jinx" and Dalandan_menu.mainmenu.champion:get() then
    Dalandan_menu.jinxmenu = menu("Dalandan_Menu_"..player.charName, "Dalandan AIO - "..player.charName);
    Dalandan_menu.jinxmenu:set('icon',player.iconSquare)

    Dalandan_menu.jinxmenu:menu("q", "Q settings");
    Dalandan_menu.jinxmenu.q:boolean("q_combo","Use Q in combo", true)
    Dalandan_menu.jinxmenu.q:boolean("q_combo_aoe","^ Try to use Q for aoe", true)
    Dalandan_menu.jinxmenu.q:header('head',"Laneclear/Jungleclear")
    Dalandan_menu.jinxmenu.q:boolean("q_laneclear","Use Q in laneclear", true)
    Dalandan_menu.jinxmenu.q.q_laneclear:set("tooltip","Will always change to minigun, unless other conditions are met")
    Dalandan_menu.jinxmenu.q:boolean("q_laneclear_minion","Change to rockets if minions hit", true)
    Dalandan_menu.jinxmenu.q:slider("q_laneclear_count","^ If can hit x minions", 4, 0, 10, 1)
    Dalandan_menu.jinxmenu.q:slider("q_laneclear_mana","^ Only when mana >= x [%]", 25, 0, 100, 1)
    Dalandan_menu.jinxmenu.q:boolean("q_laneclear_heroes","Change to rockets if can hit enemy", true)
    Dalandan_menu.jinxmenu.q:slider("q_laneclear_heroes_mana","^ Only when mana >= x [%]", 25, 0, 100, 1)
    Dalandan_menu.jinxmenu.q:boolean("q_laneclear_heroes_orb","Experimental farming mode to poke more with rockets", true)
    Dalandan_menu.jinxmenu.q.q_laneclear_heroes_orb:set("tooltip","Change farming logic to more often use rockets on minion when enemy stands near them. Enabling this may result in a lot of missed farm")
    Dalandan_menu.jinxmenu.q:slider("q_laneclear_heroes_orb_mana","^ Only when mana >= x [%]", 25, 0, 100, 1)
    Dalandan_menu.jinxmenu.q:header('head',"Harass")
    Dalandan_menu.jinxmenu.q:boolean("q_harass","Use Q in harass", true)

    Dalandan_menu.jinxmenu:menu("w", "W settings");
    Dalandan_menu.jinxmenu.w:boolean("w_combo","Use W in combo", true)
    Dalandan_menu.jinxmenu.w:boolean("w_slow_pred","Use slow pred for W", true)
    Dalandan_menu.jinxmenu.w:menu("block", "Block W cast");
    Dalandan_menu.jinxmenu.w.block:boolean("w_aa","Don't use W if in AA range", false)
    Dalandan_menu.jinxmenu.w.block:boolean("w_dps","Don't use W if W dps < aa dps", true)
    Dalandan_menu.jinxmenu.w.block:boolean("w_near","Don't use W if enemies are near", true)
    Dalandan_menu.jinxmenu.w.block:slider("w_near_count","^ How many enemies to block cast", 1, 0, 5, 1)
    Dalandan_menu.jinxmenu.w.block:slider("w_near_range","^ Detection range", 200, 100, 500, 50)
    Dalandan_menu.jinxmenu.w:boolean("w_ks","Use W to killsteal", true)
    Dalandan_menu.jinxmenu.w:boolean("w_harass","Use W in harass", true)

    Dalandan_menu.jinxmenu:menu("e", "E settings");
    Dalandan_menu.jinxmenu.e:boolean("e_antigapcloser","Use E for Anti-Gapclose", true)
    Dalandan_menu.jinxmenu.e:menu("combo", "E in combo");
    Dalandan_menu.jinxmenu.e.combo:boolean("e_combo","Use E in combo", true)
    Dalandan_menu.jinxmenu.e.combo:boolean("e_melee","^ if in melee range", true)
    Dalandan_menu.jinxmenu.e.combo:boolean("e_slow","^ if slowed", true)
    Dalandan_menu.jinxmenu.e.combo:boolean("e_stun","^ if hard CC", true)
    Dalandan_menu.jinxmenu.e:menu("auto", "E auto cast");
    Dalandan_menu.jinxmenu.e.auto:boolean("e_auto","Enable auto cast E", true)
    Dalandan_menu.jinxmenu.e.auto:boolean("e_melee","^ if in melee range", true)
    Dalandan_menu.jinxmenu.e.auto:boolean("e_slow","^ if slowed", false)
    Dalandan_menu.jinxmenu.e.auto:boolean("e_stun","^ if hard CC", true)

    Dalandan_menu.jinxmenu:menu("r", "R settings");
    Dalandan_menu.jinxmenu.r:keybind('r_semi', 'Semi R', 'T', nil);
    Dalandan_menu.jinxmenu.r:boolean("r_ks","Use R to killsteal", true)
    Dalandan_menu.jinxmenu.r:boolean("r_near","Don't use R if enemies are near", true)
    Dalandan_menu.jinxmenu.r:slider("r_near_count","^ How many enemies to block cast", 1, 0, 5, 1)
    Dalandan_menu.jinxmenu.r:slider("r_near_range","^ Detection range", 350, 100, 1000, 50)
    -- Dalandan_menu.jinxmenu.r:slider("r_min","R min range",900,0,2000,50)
    Dalandan_menu.jinxmenu.r:boolean("r_aa","Don't cast R in aa range", true)
    Dalandan_menu.jinxmenu.r:slider("r_max","R max range",2000,1000,5000,100)

    Dalandan_menu.jinxmenu:menu("Draw", "Draw");
    Dalandan_menu.jinxmenu.Draw:set('icon',graphics.sprite('Sprites/Draw.png'))
    Dalandan_menu.jinxmenu.Draw:boolean('ready', 'Draw only when skill is ready', true);
    Dalandan_menu.jinxmenu.Draw:boolean('q_draw', 'Draw Q', true);
    Dalandan_menu.jinxmenu.Draw:boolean('w_draw', 'Draw W', true);
    Dalandan_menu.jinxmenu.Draw:boolean('e_draw', 'Draw E', false);
    Dalandan_menu.jinxmenu.Draw:boolean('r_draw', 'Draw R', true);
    Dalandan_menu.jinxmenu.Draw:boolean('r_dmg', 'Draw R Damage', true);
     
end
return Dalandan_menu