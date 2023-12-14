local ts = module.internal("TS");
local pred = module.internal("pred");
local orb = module.internal("orb");

local MyMenu = {}
MyMenu.mainmenu = menu("Dalandan_Common", "Dalandan AIO - Common");
MyMenu.mainmenu:dropdown('highRes', 'High res mode', 1,{"1080p","1440p","4k"});
MyMenu.mainmenu.highRes:set('tooltip',"It's used for things like damage indicator, resolution names are just guidelines, pick one that closest matches damage indicator on your screen")

MyMenu.mainmenu:menu("customization", "Additional customization");
MyMenu.mainmenu.customization:header('head',"High res mode is used for both")
MyMenu.mainmenu.customization:header('head',"cd tracker and damage indicator")
MyMenu.mainmenu.customization:header('head',"HOWEVER this tab")
MyMenu.mainmenu.customization:header('head',"is only for damage indicator, ") 
MyMenu.mainmenu.customization:header('head',"since cd tracker has it's own tab")
MyMenu.mainmenu.customization:slider('x', 'X pos', 0, -400, 400, 1);
MyMenu.mainmenu.customization:button('xPlus',"^","+",function() 
    MyMenu.mainmenu.customization.x:set('value',MyMenu.mainmenu.customization.x:get() + 1)
end)
MyMenu.mainmenu.customization:button('xMinus',"^","-",function() 
    MyMenu.mainmenu.customization.x:set('value',MyMenu.mainmenu.customization.x:get() - 1)
end)
MyMenu.mainmenu.customization:slider('y', 'Y pos', 0, -400, 400, 1);
MyMenu.mainmenu.customization:button('yPlus',"^","+",function() 
    MyMenu.mainmenu.customization.x:set('value',MyMenu.mainmenu.customization.y:get() + 1)
end)
MyMenu.mainmenu.customization:button('yMinus',"^","-",function() 
    MyMenu.mainmenu.customization.x:set('value',MyMenu.mainmenu.customization.y:get() - 1)
end)
MyMenu.mainmenu.customization:slider('scale', 'healthbar size (scale) [x]', 100, 30, 300, 1);
MyMenu.mainmenu.customization.scale:set('tooltip',"set scale and x pos on target with full hp and with full damage indicator (KILLABLE), Changing scale changes it's x pos so you will need to compensate with both settings to make sure it's right")
MyMenu.mainmenu.customization:slider('TextSize', 'text size [%]', 100, 0, 500, 10);

MyMenu.mainmenu.customization:button('reset',"Reset to default","Click",function() 
    MyMenu.mainmenu.customization.x:set('value',0)
    MyMenu.mainmenu.customization.y:set('value',0)
    MyMenu.mainmenu.customization.scale:set('value',100)
    MyMenu.mainmenu.customization.TextSize:set('value',100)
end)
common = {}

local delayedActions, delayedActionsExecuter = {}, nil
function common.DelayAction(func, delay, args) --delay in seconds
  if not delayedActionsExecuter then
    function delayedActionsExecuter()
      for t, funcs in pairs(delayedActions) do
        if t <= os.clock() then
          for i = 1, #funcs do
            local f = funcs[i]
            if f and f.func then
              f.func(unpack(f.args or {}))
            end
          end
          delayedActions[t] = nil
        end
      end
    end
    cb.add(cb.tick, delayedActionsExecuter)
  end
  local t = os.clock() + (delay or 0)
  if delayedActions[t] then
    delayedActions[t][#delayedActions[t] + 1] = {func = func, args = args}
  else
    delayedActions[t] = {{func = func, args = args}}
  end
end

local _intervalFunction
function common.SetInterval(userFunction, timeout, count, params)
  if not _intervalFunction then
    function _intervalFunction(userFunction, startTime, timeout, count, params)
      if userFunction(unpack(params or {})) ~= false and (not count or count > 1) then
        common.DelayAction(
          _intervalFunction,
          (timeout - (os.clock() - startTime - timeout)),
          {userFunction, startTime + timeout, timeout, count and (count - 1), params}
        )
      end
    end
  end
  common.DelayAction(_intervalFunction, timeout, {userFunction, os.clock(), timeout or 0, count, params})
end

-- Returns true if @object is valid target
function common.IsValidTarget(object)
    return (object and not object.isDead and object.isVisible and object.isTargetable and not object.buff[17])
end

function common.IsEnemyHero(object) -- works?
    return object.type == TYPE_HERO and object.team == TEAM_ENEMY
end

function common.IsSpellShielded(object) -- also fiora W and morgana spell shield
    return object.buff["bansheesveil"] or    object.buff["itemmagekillerveil"] or object.buff["nocturneshroudofdarkness"] or object.buff["sivire"] or object.buff["fioraw"] or object.buff["blackshield"]
end

-- Returns table and number of objects near @pos
function common.CountObjectsNearPos(pos, radius, objects, validFunc)
    local n, o = 0, {}
    for i, object in ipairs(objects) do
        if validFunc(object) and pos:dist(object.pos) <= radius then
            n = n + 1
            o[n] = object
        end
    end
    return n, o
end

function common.GetEnemyHeroes()
    local heroes = {}
    for i=0, objManager.enemies_n-1 do
            local obj = objManager.enemies[i]
            heroes[i] = obj 
    end
    return heroes
end

-- Returns table and number of enemy heroes near @pos
function common.CountEnemiesNearPos(pos, radius)
    heroes = {}
    for i=0, objManager.enemies_n-1 do
        heroes[i] = objManager.enemies[i]
    end
    local validFunc = function(obj)
        return obj and obj.health and obj.health > 0 and common.IsValidTarget(obj) and obj.type == TYPE_HERO
    end
    return common.CountObjectsNearPos(pos, radius, heroes, validFunc)
end


-- Returns table and number of objects near @pos
function common.CountMinionsNearPos(pos, radius, objects, team)
    local validFunc = function(obj)
        return obj and obj.type == TYPE_MINION and obj.team == team and not obj.isDead and obj.health and obj.health > 0 and obj.isVisible
    end
    return common.CountObjectsNearPos(pos, radius, objects, validFunc)
end

-- Returns table and number of objects near @pos
function common.CountMinionsNearPos2(pos, radius)
    minions = {}
    for i=0, objManager.minions.size[TEAM_ENEMY]-1 do
        minions[i] = objManager.minions[TEAM_ENEMY][i]
    end
    local validFunc = function(obj)
        return obj and not obj.isDead and obj.health and obj.health > 0 and obj.isVisible and obj.isTargetable
    end
    return common.CountObjectsNearPos(pos, radius, minions, validFunc)
end


-- Returns total AD of @obj or player
function common.GetTotalAD(obj)
    local obj = obj or player
    return (obj.baseAttackDamage + obj.flatPhysicalDamageMod) * obj.percentPhysicalDamageMod
end
    
-- Returns bonus AD of @obj or player
function common.GetBonusAD(obj)
    local obj = obj or player
    return ((obj.baseAttackDamage + obj.flatPhysicalDamageMod) * obj.percentPhysicalDamageMod) - obj.baseAttackDamage
end
    
-- Returns total AP of @obj or player
function common.GetTotalAP(obj)
    local obj = obj or player
    return obj.flatMagicDamageMod * obj.percentMagicDamageMod
end
    
function common.GetBonusAS(obj)
    local obj = obj or player
    return mathf.round(((obj.attackSpeedMod - 1) * 100),3)
end

-- Returns physical damage multiplier on @target from @damageSource or player
function common.PhysicalReduction(target, damageSource)
    local damageSource = damageSource or player
    local armor = ((target.bonusArmor * damageSource.percentBonusArmorPenetration) + (target.armor - target.bonusArmor)) * damageSource.percentArmorPenetration
    local lethality = (damageSource.physicalLethality * .4) + ((damageSource.physicalLethality * .6) * (damageSource.levelRef / 18))
    return armor >= 0 and (100 / (100 + (armor - lethality))) or (2 - (100 / (100 - (armor - lethality))))
end
    
-- Returns magic damage multiplier on @target from @damageSource or player
function common.MagicReduction(target, damageSource)
    local damageSource = damageSource or player
    local flatpens = damageSource.flatMagicPenetration
    for i=6,0,-1 do --kys shadowflame
        if player:itemID(i) == 4645 then
            if target.health <= 1000 then flatpens = flatpens + 20 goto shadowshit end
            if target.health <= 1150 then flatpens = flatpens + 19 goto shadowshit end
            if target.health <= 1300 then flatpens = flatpens + 18 goto shadowshit end
            if target.health <= 1450 then flatpens = flatpens + 17 goto shadowshit end
            if target.health <= 1600 then flatpens = flatpens + 16 goto shadowshit end
            if target.health <= 1750 then flatpens = flatpens + 15 goto shadowshit end
            if target.health <= 1900 then flatpens = flatpens + 14 goto shadowshit end
            if target.health <= 2050 then flatpens = flatpens + 13 goto shadowshit end
            if target.health <= 2200 then flatpens = flatpens + 12 goto shadowshit end
            if target.health <= 2350 then flatpens = flatpens + 11 goto shadowshit end
            if target.health > 2350 then flatpens = flatpens + 10 goto shadowshit end
        end
    end
    ::shadowshit::
    local magicResist = (target.spellBlock * damageSource.percentMagicPenetration) - flatpens
    return magicResist >= 0 and (100 / (100 + magicResist)) or (2 - (100 / (100 - magicResist)))
end
    
-- Calculates AA damage on @target from @damageSource or player
function common.CalculateAADamage(target, damageSource)
    local damageSource = damageSource or player
    if target then
        return common.GetTotalAD(damageSource) * common.PhysicalReduction(target, damageSource)
    end
    return 0
end
    
-- Returns @target attack range (@target is optional; will consider @target boundingRadius into calculation)
function common.GetAARange(target)
    return player.attackRange + player.boundingRadius + (target and target.boundingRadius or 0)
end

common.enum = {}
common.enum.buff_types = {
    Internal = 0,
    Aura = 1,
    CombatEnchancer = 2,
    CombatDehancer = 3,
    SpellShield = 4,
    Stun = 5,
    Invisibility = 6,
    Silence = 7,
    Taunt = 8,
    Polymorph = 9,
    Slow = 10,
    Snare = 11,
    Damage = 12,
    Heal = 13,
    Haste = 14,
    SpellImmunity = 15,
    PhysicalImmunity = 16,
    Invulnerability = 17,
    AttackSpeedSlow = 18,
    NearSight = 19,
    Currency = 20,
    Fear = 21,
    Charm = 22,
    Poison = 23,
    Suppression = 24,
    Blind = 25,
    Counter = 26,
    Shred = 27,
    Flee = 28,
    Knockup = 29,
    Knockback = 30,
    Disarm = 31,
    Grounded = 32,
    Drowsy = 33,
    Asleep = 34
}

-- Returns true if @unit has buff.type btype

common.hard_cc = {
    [5] = true, -- stun
    [8] = true, -- taunt
    [11] = true, -- snare
    [18] = true, -- sleep
    [21] = true, -- fear
    [22] = true, -- charm
    [24] = true, -- suppression
    [28] = true, -- flee
    [29] = true, -- knockup
    [30] = true -- knockback
}

function common.max(t, fn)
    if #t == 0 then return nil, nil end
    local key, value = 1, t[1]
    for i = 2, #t do
            if fn(value, t[i]) then
                    key, value = i, t[i]
            end
    end
    return key, value
end

-- pure M and P dmg  with runes and items and shit but no armor/spellblock
-- range_max is optional
-- range_min is optional
-- tooltip is optional
function common.damageIndicator(damageM,damageP,range_max,range_min,tooltip)
    local range = range_max or 100000
    local range_min = range_min or 0
    local tooltip = tooltip or ""
    for i=0, objManager.enemies_n-1 do
        local obj = objManager.enemies[i]
        if common.IsValidTarget(obj) and obj.isOnScreen and obj.pos:dist(player.pos) <= range and obj.pos:dist(player.pos) > range_min then 
            local hpBar = obj.barPos

            damageM = common.MagicReduction(obj, player) * damageM
            damageP = common.PhysicalReduction(obj, player) * damageP
            local damage = damageM + damageP
            local damagePercentage = 0
            if (obj.health - damage) > 0 then 
                damagePercentage =  (obj.health - damage) / obj.maxHealth
            end
            local currentHealthPercentage = obj.health / obj.maxHealth

            local startPoint = vec2(hpBar.x + 163 + currentHealthPercentage * 104 , hpBar.y + 123);
            local endPoint = vec2(hpBar.x + 163 + damagePercentage * 104, hpBar.y + 123);
            
            if damage > obj.health then
                graphics.draw_text_2D("KILLABLE: YES", 18, hpBar.x + 160, hpBar.y + 90, 0xFFFF0000)
                graphics.draw_text_2D(tooltip, 18, hpBar.x + 160, hpBar.y + 70, 0xFFFFFFFF)
                graphics.draw_line_2D(startPoint.x, startPoint.y, endPoint.x, endPoint.y, 12, 0xA07DFE33)
            else
                graphics.draw_text_2D("KILLABLE: NO", 18, hpBar.x + 160, hpBar.y + 90, 0xFFEDCE34)
                graphics.draw_text_2D(tooltip, 18, hpBar.x + 160, hpBar.y + 70, 0xFFFFFFFF)
                graphics.draw_line_2D(startPoint.x, startPoint.y, endPoint.x, endPoint.y, 12, 0xA0EDCE34)
            end
        end
    end
end

cb.add(cb.tick,function() 
    common.highRes = MyMenu.mainmenu.highRes:get()
end)

-- pure M and P dmg  with runes and items and shit but no armor/spellblock
-- range_max is optional
-- range_min is optional
-- tooltip is optional
function common.damageIndicatorUpdated(damage,target,range_max,range_min,tooltip)
    local range = range_max or 100000
    local range_min = range_min or 0
    local tooltip = tooltip or ""
    if common.IsValidTarget(target) and target.isOnScreen and target.pos:dist(player.pos) <= range and target.pos:dist(player.pos) > range_min then 
        local hpBar = target.barPos

        local damagePercentage = 0
        if (target.health - damage) > 0 then 
            damagePercentage =  (target.health - damage) / target.maxHealth
        end
        local currentHealthPercentage = target.health / target.maxHealth

        local highRes = common.highRes
        local percentage = 104
        local pointX = 164
        local pointY = 123
        local textX = 160
        local textY = 90
        local tooltipY = 70
        local textSize = 18
        local lineSize = 12
        if highRes == 1 then

        elseif highRes == 2 then
            percentage = 125
            pointX = 196
            pointY = 148
            textX = 190
            textY = 105
            tooltipY = 82
            textSize = 22
            lineSize = 12 
        elseif highRes == 3 then
            percentage = 190
            pointX = 292
            pointY = 222
            textX = 310
            textY = 160
            tooltipY = 130
            textSize = 32
            lineSize = 20
        end
        percentage = percentage * MyMenu.mainmenu.customization.scale:get()/100
        pointX = pointX + MyMenu.mainmenu.customization.x:get()
        pointY = pointY + MyMenu.mainmenu.customization.y:get()
        textX = textX + MyMenu.mainmenu.customization.x:get()
        textY = textY + MyMenu.mainmenu.customization.y:get()
        tooltipY = tooltipY + MyMenu.mainmenu.customization.y:get()
        textSize = textSize * MyMenu.mainmenu.customization.TextSize:get()/100

        local startPoint = vec2(hpBar.x + pointX + currentHealthPercentage * percentage , hpBar.y + pointY);
        local endPoint = vec2(hpBar.x + pointX + damagePercentage * percentage, hpBar.y + pointY);
        if damage > target.health then
            graphics.draw_text_2D("KILLABLE: YES", textSize, hpBar.x + textX, hpBar.y + textY, 0xFFFF0000)
            graphics.draw_text_2D(tooltip, textSize, hpBar.x + textX, hpBar.y + tooltipY, 0xFFFFFFFF)
            graphics.draw_line_2D(startPoint.x, startPoint.y, endPoint.x, endPoint.y, lineSize, 0xA07DFE33)
        else
            graphics.draw_text_2D("KILLABLE: NO", textSize, hpBar.x + textX, hpBar.y + textY, 0xFFEDCE34)
            graphics.draw_text_2D(tooltip, textSize, hpBar.x + textX, hpBar.y + tooltipY, 0xFFFFFFFF)
            graphics.draw_line_2D(startPoint.x, startPoint.y, endPoint.x, endPoint.y, lineSize, 0xA0EDCE34)
        end
        -- if not highRes then
        --     local startPoint = vec2(hpBar.x + 163 + currentHealthPercentage * 104 , hpBar.y + 123);
        --     local endPoint = vec2(hpBar.x + 163 + damagePercentage * 104, hpBar.y + 123);
        --     if damage > target.health then
        --         graphics.draw_text_2D("KILLABLE: YES", 18, hpBar.x + 160, hpBar.y + 90, 0xFFFF0000)
        --         graphics.draw_text_2D(tooltip, 18, hpBar.x + 160, hpBar.y + 70, 0xFFFFFFFF)
        --         graphics.draw_line_2D(startPoint.x, startPoint.y, endPoint.x, endPoint.y, 12, 0xA07DFE33)
        --     else
        --         graphics.draw_text_2D("KILLABLE: NO", 18, hpBar.x + 160, hpBar.y + 90, 0xFFEDCE34)
        --         graphics.draw_text_2D(tooltip, 18, hpBar.x + 160, hpBar.y + 70, 0xFFFFFFFF)
        --         graphics.draw_line_2D(startPoint.x, startPoint.y, endPoint.x, endPoint.y, 12, 0xA0EDCE34)
        --     end
        -- else
        --     local startPoint = vec2(hpBar.x + 196 + currentHealthPercentage * 125 , hpBar.y + 148);
        --     local endPoint = vec2(hpBar.x + 196 + damagePercentage * 125, hpBar.y + 148);
        --     if damage > target.health then
        --         graphics.draw_text_2D("KILLABLE: YES", 22, hpBar.x + 190, hpBar.y + 105, 0xFFFF0000)
        --         graphics.draw_text_2D(tooltip, 22, hpBar.x + 190, hpBar.y + 82, 0xFFFFFFFF)
        --         graphics.draw_line_2D(startPoint.x, startPoint.y, endPoint.x, endPoint.y, 12, 0xA07DFE33)
        --     else
        --         graphics.draw_text_2D("KILLABLE: NO", 22, hpBar.x + 190, hpBar.y + 105, 0xFFEDCE34)
        --         graphics.draw_text_2D(tooltip, 22, hpBar.x + 190, hpBar.y + 82, 0xFFFFFFFF)
        --         graphics.draw_line_2D(startPoint.x, startPoint.y, endPoint.x, endPoint.y, 12, 0xA0EDCE34)
        --     end
        -- end
    end
end

function common.spellNames()
    print(player:spellSlot(0).name)
    print(player:spellSlot(1).name)
    print(player:spellSlot(2).name)
    print(player:spellSlot(3).name)
end

common.champs = {
    --   Lux = true;
    --   Malphite = true;
    --   Ryze = true;
      TwistedFate = true;
      Xerath = true;
      Yasuo = true;
      -- Zed = true;
      Yone = true;
    --   Ezreal = true;
    Caitlyn = true;
}

return common


-- less forbidden art

-- for j=0, objManager.maxObjects-1 do
--     local obj = objManager.get(j)
--     if obj and obj.type==TYPE_HERO then
--         local hpBar = obj.barPos
--         local buff_keys = obj.buff.keys
--         for i = 1, buff_keys.n do
--             local buff_key = buff_keys[i]
--             local buff = obj.buff[buff_key]
--             if buff and buff.valid then 
--                 local string = "Name: "..buff.name.." Type: "..buff.type.." Stacks: "..buff.stacks.." Stacks2: "..buff.stacks2
--                 graphics.draw_text_2D(string, 18, hpBar.x + 160, hpBar.y + 70 + 15*i, 0xFFFFFFFF)
--             end
--         end
--     end
-- end