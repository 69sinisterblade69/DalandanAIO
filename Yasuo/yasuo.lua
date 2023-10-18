local orb = module.internal("orb");
local ts = module.internal("TS");
local pred = module.internal("pred");
local evade = module.seek("evade")
if not evade then
    chat.print("[Dalandan AIO] <font color=\"#FF0000\">ENABLE HANBOT EVADE OR YOU WILL HAVE ERRORS </font>")
end
local damagelib = module.internal("damagelib")

local common = module.load("Dalandan_AIO", "common");
local menu = module.load("Dalandan_AIO", "menu");

local q = {
    speed = math.huge,
    range = 450,
    width = 80,
    boundingRadiusMod = 1, --??
    delay = 0.35,
}

local q2 = {
    speed = 1200,
    range = 1150,
    width = 180,
    boundingRadiusMod = 1, --??
    delay = 0.35,
}

local eq = {
    radius = 215,
}

local e = {
    range = 475,
    -- speed = 750 + 0.7 * player.moveSpeed,
    speed = 750 + 0.85 * player.moveSpeed, -- experimentally derived value closer to reality than one in wiki
}

local r = {
    range = 1400,
    radius = 400,
    delay = 0,
    boundingRadiusMod = 0, --??
    speed = math.huge,
}

local flash = {
    range = 400,
    slot = nil,
    delay = 0,
}

for i = 4, 5 do
    local spell = player:spellSlot(i)
    if spell.isNotEmpty and spell.name:lower():find('flash') then
        flash.slot = i
    end
end

-- local attackSpeed = (player.attackSpeedMod - 1) * 0.67 + 0.697

local function posAfterE(target, range)
    local x = player.pos.x
    local y = player.pos.z
    local D = range or e.range 
    local x2 = target.pos.x
    local y2 = target.pos.z

    local x1 = x + D * (x2 - x) / math.sqrt((x2 - x)^2 + (y2 - y)^2)
    local y1 = y + D * (y2 - y) / math.sqrt((x2 - x)^2 + (y2 - y)^2)

    return x1,y1
end

local function canE(target)
    local can = true
	local buff_keys = target.buff.keys
	for i = 1, buff_keys.n do
		local buff_key = buff_keys[i]
		local buff = player.buff[buff_key]
        if buff and buff.valid and buff.name == "YasuoE" then 
            can = false
        end
    end

    if menu.yasuomenu.Misc.e_safety:get() and can then
        local pos = vec2(posAfterE(target)):toGame3D()
        if not evade.core.is_action_safe(pos, e.speed, 0) then
            -- chat.print(os.clock().." Unsafe")
            can = false
        end
    end
    
    return can
end

local function ts_filter_basic(res, object, dist)
    if object and common.IsValidTarget(object) and common.IsEnemyHero(object) then
        if (object.buff["rocketgrab"]) then return end
        res.object = object
        return true
    end 
end

local function getTarget(range)
	-- local currentTarget = nil
    -- -- force [hard] target check
    -- local target = ts.get_result(ts_filter_basic, nil, nil, true)
	-- if ts.selected and target ~= nil and ts.selected == target then
	-- 	if player.pos:dist(target.pos) < (range + target.boundingRadius) then
    --         return target
	-- 	end
	-- end
    -- currentTarget = ts.get_result(ts_filter_basic, ts.filter_set[1])
    -- if currenttarget ~= nil then
    --     if currenttarget.pos:dist(player.pos) < (range + currenttarget.boundingRadius) then
    --         if common.IsValidTarget(currentTarget) then
    --             return currentTarget
    --         end
    --     end
    -- end
    local target = ts.get_result(ts_filter_basic).object
    if target then
        if player.pos:dist(target.pos) < (range + target.boundingRadius) then
            return target
        end
    end
end

local function canStack(obj)
    -- if obj and obj.team ~= TEAM_ALLY and (obj.type==TYPE_HERO or obj.type==TYPE_MINION) and common.IsValidTarget(obj) and not string.find(string.lower(tostring(obj.name)),"plant") then
    --     return true
    -- else
    --     return false
    -- end
    return (obj and obj.team ~= TEAM_ALLY and (obj.type==TYPE_HERO or obj.type==TYPE_MINION) and common.IsValidTarget(obj) and not string.find(string.lower(tostring(obj.name)),"plant"))
end

local function pathTo(target)
    
end

local function rSafetyCheck(target)
    if target.pos:dist(player.pos) < common.GetAARange(target) and target.health < damagelib.calc_aa_damage(player, target, true) * 2 then
        return false
    end
    -- if pathTo(target) and target.health < damagelib.calc_aa_damage(player, target, true) * 2 then
    --     return false
    -- end
    return true
end

local function flee()
    local x,y = player.pos.x, player.pos.z
    local min_dist = math.huge
    local max_minion = nil
    for i=0, objManager.maxObjects-1 do
        local obj = objManager.get(i)
        if obj and obj.team ~= TEAM_ALLY and (obj.type==TYPE_HERO or obj.type==TYPE_MINION) and common.IsValidTarget(obj) and canE(obj) and obj.pos:dist(player.pos) <= e.range and not string.find(string.lower(tostring(obj.name)),"plant") then
            local x1,y1 = posAfterE(obj)
            if vec3(x1,obj.pos.y,y1):dist(mousePos) < min_dist then
                min_dist = vec3(x1,obj.pos.y,y1):dist(mousePos)
                max_minion = obj
            end
        end
    end

    local qBuff = false
	local buff_keys = player.buff.keys
	for i = 1, buff_keys.n do
		local buff_key = buff_keys[i]
		local buff = player.buff[buff_key]
        if buff and buff.valid and buff.name == "YasuoQ2" then
            qBuff = true
        end
    end

    if max_minion ~= nil and min_dist + 100 < player.pos:dist(mousePos) then
        player:castSpell('obj', 2, max_minion)
    end

    -- stack Q
    if menu.yasuomenu.Misc.flee_q:get() and max_minion ~= nil and not qBuff and player:spellSlot(0).state == 0 and player.path.isDashing then
        local posE = vec2(posAfterE(max_minion)):toGame3D()
        -- local count, minions = common.CountMinionsNearPos2(posE, eq.radius)
        -- local Hcount, heroes = common.CountEnemiesNearPos(posE, eq.radius)
        -- count = count + Hcount
        local hittable = {}
        for j=0, objManager.maxObjects-1 do
            local obj = objManager.get(j)
            if canStack(obj) then
                hittable[j] = obj
            end
        end
        local count = 0
        for i,minion in pairs(hittable) do
            if minion.pos:dist(posE) < eq.radius then
                count = count + 1
            end
        end
        if count > 0 then
            player:castSpell('pos', 0, max_minion.pos)
        end
    end

    -- Use Q3 on target
    if menu.yasuomenu.Misc.flee_q3:get() and qBuff then
        local target = nil
        if menu.yasuomenu.Misc.flee_q3_target:get() == 2 then -- normal
            target = getTarget(1200) 
        end
        if menu.yasuomenu.Misc.flee_q3_target:get() == 1 then -- closest
            local closest_hero = nil
            local closest_dist = math.huge
            for i,hero in pairs(common.GetEnemyHeroes()) do
                if player.pos:dist(hero.pos) < closest_dist and common.IsValidTarget(hero) then
                    closest_dist = player.pos:dist(hero.pos)
                    closest_hero = hero
                end
            end
            target = closest_hero
        end
        if target ~= nil and player:spellSlot(0).state == 0 and not orb.core.is_spell_locked() then
            if not player.path.isDashing then
                local seg = pred.linear.get_prediction(q2,target)
                if seg ~= nil and seg.endPos:dist(player.pos) <= q2.range then
                    player:castSpell('pos', 0, vec3(seg.endPos.x, mousePos.y, seg.endPos.y))
                end
            end
        end
    end

    player:move(mousePos)
end

local waitAirblade = false
local canAirblade = false
local waitBayblade = false

local function combo()
    local target = getTarget(1400)
    local willUlt = false
    local underTower = false
    if target ~= nil then

        local turrets = {}
        local turretSize = objManager.turrets.size[TEAM_ENEMY]-1
        for i=0, turretSize do
            turrets[i] = objManager.turrets[TEAM_ENEMY][i]
        end
        for i, turret in pairs(turrets) do
            if target.pos:dist(turret.pos) <= 800 + turret.boundingRadius + player.boundingRadius then
                underTower = true
            end
        end

        -- Cast R and airblade
        local enemyHPPercentage = target.maxHealth / 100 * menu.yasuomenu.Combo.r_enemy_hp:get()
        local HPDiff = player.health - target.health
        local HPDiffNeeded = target.maxHealth / 100 * menu.yasuomenu.Combo.r_yasuo_hp:get()
        if HPDiff >= HPDiffNeeded then
            if target.health <= enemyHPPercentage and menu.yasuomenu.Combo.r_combo:get() and player:spellSlot(3).state == 0 then
                if (menu.yasuomenu.Combo.r_safety:get() and rSafetyCheck(target)) or not menu.yasuomenu.Combo.r_safety:get() then
                    willUlt = true
                end
            end
        end

        if menu.yasuomenu.Combo.r_combo:get() and player:spellSlot(3).state == 0 and (not underTower or (underTower and menu.yasuomenu.Misc.dive_key:get())) then
            local isEnemyKnockedUp = false
            local buffTime = 0
            local myBuff = nil
            local buff_keys = target.buff.keys
            for i = 1, buff_keys.n do
                local buff_key = buff_keys[i]
                local buff = target.buff[buff_key]
                if buff and buff.valid and buff.type == BUFF_KNOCKUP then 
                    isEnemyKnockedUp = true
                    buffTime = buff.endTime - game.time
                    myBuff = buff
                end
            end
            if isEnemyKnockedUp then
                if player.pos:dist(target.pos) <= r.range and willUlt then
                    if menu.yasuomenu.Combo.airblade:get() then
                        local enemyMinions = objManager.minions[TEAM_ENEMY]
                        local enemyMinionsSize = enemyMinions.size
                        local myobj = nil
                        for i=0, enemyMinionsSize-1 do
                            local obj = enemyMinions[i]
                            if obj.pos:dist(player.pos) < e.range and canE(obj) then
                                myobj = obj
                            end
                        end
                        if myobj == nil then
                            local enemyMinionss = objManager.minions[TEAM_NEUTRAL]
                            local enemyMinionsSizee = enemyMinionss.size
                            for i=0, enemyMinionsSizee-1 do
                                local obj = enemyMinionss[i]
                                if obj.pos:dist(player.pos) < e.range and canE(obj) then
                                    myobj = obj
                                end
                            end
                        end
                        if myobj == nil then
                            local heroes = common.GetEnemyHeroes()
                            for i,obj in pairs(heroes) do
                                if obj.pos:dist(player.pos) < e.range and canE(obj) then
                                    myobj = obj
                                end
                            end
                        end
                        -- if buffTime > player:spellSlot(0).cooldown - 0.5 and buffTime > 0.5 then
                        --     canAirblade = true
                        -- end
                        if myobj then
                            local posE = vec2(posAfterE(myobj))
                            if posE:dist(target.pos) <= r.range and player:spellSlot(0).cooldown < 0.5 and player:spellSlot(2).state == 0 then
                                canAirblade = true
                            end
                            if buffTime > player:spellSlot(0).cooldown - 0.3 then
                                waitAirblade = true
                            end
                            if canAirblade and waitAirblade then
                                -- chat.print(os.clock().."xd")
                                player:castSpell('obj', 2, myobj)
                                common.DelayAction(function() player:castSpell('pos', 0, myobj.pos) end,0.01)
                                local eTime = e.range / e.speed 
                                common.DelayAction(function() player:castSpell('pos', 3, vec3(target.pos.x, target.y, target.pos.z)); waitAirblade = false; canAirblade = false end,eTime * 0.95)
                                -- canAirblade = false
                                -- orb.core.set_server_pause()
                            else
                                if not player.path.isDashing then
                                    waitAirblade = false
                                    common.DelayAction(function() player:castSpell('pos', 3, vec3(target.pos.x, target.y, target.pos.z)) end,buffTime - (network.latency*2)-0.07)
                                end
                            end
                        else
                            if player.pos:dist(target.pos) < common.GetAARange(target)  then
                                player:attack(target)
                            end
                            common.DelayAction(function() player:castSpell('pos', 3, vec3(target.pos.x, target.y, target.pos.z)) end,buffTime - (network.latency*2)-0.07)
                        end
                    else
                        if player.pos:dist(target.pos) < common.GetAARange(target)  then
                            player:attack(target)
                        end
                        common.DelayAction(function() player:castSpell('pos', 3, vec3(target.pos.x, target.y, target.pos.z)) end,buffTime - (network.latency*2)-0.07)
                    end
                end
            end
        end
        local qBuff = false
        local buff_keys = player.buff.keys
        for i = 1, buff_keys.n do
            local buff_key = buff_keys[i]
            local buff = player.buff[buff_key]
            if buff and buff.valid and buff.name == "YasuoQ2" then
                qBuff = true
            end
        end

        -- bayblade
        if menu.yasuomenu.Combo.bayblade:get() and qBuff and ts.selected and willUlt and player:spellSlot(0).state == 0 and player:spellSlot(2).state == 0 and player:spellSlot(flash.slot).state == 0 and player:spellSlot(3).state == 0 and (not underTower or (underTower and menu.yasuomenu.Misc.dive_key:get())) then
            local enemyMinions = objManager.minions[TEAM_ENEMY]
            local enemyMinionsSize = enemyMinions.size
            local myobj = nil
            for i=0, enemyMinionsSize-1 do
                local obj = enemyMinions[i]
                if obj.pos:dist(player.pos) < e.range and canE(obj) then
                    myobj = obj
                end
            end
            if myobj == nil then
                local enemyMinionss = objManager.minions[TEAM_NEUTRAL]
                local enemyMinionsSizee = enemyMinionss.size
                for i=0, enemyMinionsSizee-1 do
                    local obj = enemyMinionss[i]
                    if obj.pos:dist(player.pos) < e.range and canE(obj) then
                        myobj = obj
                    end
                end
            end
            if myobj == nil then
                local heroes = common.GetEnemyHeroes()
                for i,obj in pairs(heroes) do
                    if obj.pos:dist(player.pos) < e.range and canE(obj) then
                        myobj = obj
                    end
                end
            end
            if myobj then
                local posE = vec2(posAfterE(myobj,e.range/2))
                local posEE = vec2(posAfterE(myobj))
                waitBayblade = true
                if target.pos:dist(posE:toGame3D()) < flash.range + (eq.radius-80) then
                    -- chat.print(os.clock().." BAY")
                    player:castSpell('obj', 2, myobj)
                    common.DelayAction(function() player:castSpell('pos', 0, myobj.pos) end,0.01)
                    -- if player.path.isDashing and player:spellSlot(0).state ~= 0 then
                    --     player:castSpell('pos', flash.slot, target.pos)
                    -- end
                    local targetPos = pred.core.get_pos_after_time(target, 0.33)
                    common.DelayAction(function() 
                        if player.path.isDashing and player:spellSlot(0).state ~= 0 and not (posEE:dist(targetPos) < eq.radius-110) then 
                            player:castSpell('pos', flash.slot, target.pos)
                            orb.core.set_pause(0)
                        end
                        waitBayblade = false
                        end,0.3)
                end
            end
        end

        -- Gapclose on minions
        if not player:spellSlot(2).state ~= 0 and not (canAirblade or waitAirblade or waitBayblade) and (not underTower or (underTower and menu.yasuomenu.Misc.dive_key:get())) then
            local targetPos = target.pos
            local playerPos = player.pos
            if player.path.isActive then
                playerPos = player.path.serverPos
            end
            if target.path.isActive then
                targetPos = target.path.serverPos
            end
            local min_dist = math.huge
            local min_minion = nil
            local enemyMinions = objManager.minions[TEAM_ENEMY]
            local enemyMinionsSize = enemyMinions.size
            for i=0, enemyMinionsSize-1 do
                local obj = enemyMinions[i]
                if obj and common.IsValidTarget(obj) and canE(obj) and obj.pos:dist(playerPos) <= e.range then
                    local x1,y1 = posAfterE(obj)
                    local posE = vec3(x1,obj.pos.y,y1)
                    if posE:dist(targetPos) < min_dist then
                        local d = e.range/e.speed
                        local targetPosA = pred.core.get_pos_after_time(target, d)
                        targetPosA = targetPosA:to3D(mousePos.y)
                        min_dist = posE:dist(targetPosA)
                        min_minion = obj
                    end
                end
            end
            if min_minion ~= nil and (min_dist + 80 < playerPos:dist(targetPos)) then  
                player:castSpell('obj', 2, min_minion)
            end
            if min_minion ~= nil and min_dist < common.GetAARange(target) - 50 then
                -- chat.print(os.clock().." generating shield")
                player:castSpell('obj', 2, min_minion)
            end
        end

        -- use q in dash when possible
        if player.path.isDashing then
            local d = player.path.serverPos:dist(player.path.endPos) / player.path.dashSpeed
            local pos = pred.core.get_pos_after_time(target, d)
            pos = pos:to3D(mousePos.y)
            if player.path.endPos:dist(pos) < eq.radius/2 + target.boundingRadius then
                player:castSpell('pos', 0, pos)
            end
        end

        -- use e on target if still in aaRange but not when R ready
        if player:spellSlot(2).state == 0 and player:spellSlot(3).state ~= 0 and (not underTower or (underTower and menu.yasuomenu.Misc.dive_key:get())) then
            if canE(target) and target.pos:dist(player.pos) < e.range + target.boundingRadius then
                local x1,y1 = posAfterE(target)
                local ePos = vec3(x1,mousePos.y,y1)
                local d = player.path.serverPos:dist(ePos) / e.speed
                local targetPos = pred.core.get_pos_after_time(target, d)
                if ePos:dist(targetPos:to3D(mousePos.y)) < common.GetAARange(target) then
                    player:castSpell('obj', 2, target)
                end
            end
        end

        -- use q/q3
        if not player:spellSlot(0).state ~= 0 and not player.path.isDashing and ((player.pos:dist(target) > common.GetAARange(target) and menu.yasuomenu.Misc.Q_after_aa:get()) or not menu.yasuomenu.Misc.Q_after_aa:get()) and not waitBayblade then
            if qBuff then
                if not player:spellSlot(0).state ~= 0 and not orb.core.is_spell_locked() then
                    local seg = pred.linear.get_prediction(q2,target)
                    if seg ~= nil and seg.endPos:dist(player.pos) <= q2.range then
                        player:castSpell('pos', 0, vec3(seg.endPos.x, mousePos.y, seg.endPos.y))
                    end
                end
            else
                if not player:spellSlot(0).state ~= 0 and not orb.core.is_spell_locked() then
                    local seg = pred.linear.get_prediction(q,target)
                    if seg ~= nil and seg.endPos:dist(player.pos) <= q.range then
                        player:castSpell('pos', 0, vec3(seg.endPos.x, mousePos.y, seg.endPos.y))
                    end
                end
            end
        end

    end
end

local function after_attack()
    -- chat.print('attack is on cooldown')
    local target = getTarget(1400)
    if target and target ~= nil and menu.yasuomenu.Misc.Q_after_aa:get() then
        -- use q/q3
        local qBuff = false
        local buff_keys = player.buff.keys
        for i = 1, buff_keys.n do
            local buff_key = buff_keys[i]
            local buff = player.buff[buff_key]
            if buff and buff.valid and buff.name == "YasuoQ2" then
                qBuff = true
            end
        end

        if player:spellSlot(0).state == 0 and not player.path.isDashing then
            if not orb.core.is_spell_locked() then
                local seg
                if qBuff then
                    seg = pred.linear.get_prediction(q2, target)
                    if seg and seg.endPos:dist(player.pos) <= q2.range then
                        player:castSpell('pos', 0, vec3(seg.endPos.x, mousePos.y, seg.endPos.y))
                    end
                else
                    seg = pred.linear.get_prediction(q, target)
                    if seg and seg.endPos:dist(player.pos) <= q.range then
                        player:castSpell('pos', 0, vec3(seg.endPos.x, mousePos.y, seg.endPos.y))
                    end
                end
            end
        end
    end
end
  
orb.combat.register_f_after_attack(after_attack)

local function Edmg(obj)
    return (50 + 10 * player:spellSlot(2).level + 0.2 * player.bonusAd + 0.6 * player.totalAp) * common.MagicReduction(obj)
end

local function laneClear()
    local target = getTarget(1400)
    local enemyMinions = objManager.minions[TEAM_ENEMY]
    local enemyMinionsSize = enemyMinions.size

    local qTime = 0
    if player.buff['yasuoq2'] then
        qTime = player.buff['yasuoq2'].endTime - game.time
    end
    local turrets = {}
    for i=0, objManager.turrets.size[TEAM_ENEMY]-1 do
        turrets[i] = objManager.turrets[TEAM_ENEMY][i]
    end

    for i=0, enemyMinionsSize-1 do
        local minion = enemyMinions[i]
        if common.IsValidTarget(minion) and minion.pos:dist(player.pos) < q2.range then

        end
    end

    local max_hits_eq = 0
    local max_minion_eq = nil
    local max_hits_q = 0
    local max_minion_q = nil
    local max_hits_q2 = 0
    local max_minion_q2 = nil

    local minion_hits_q = 0
    local minion_hits_q2 = 0
    for i=0, enemyMinionsSize-1 do
        local minion = enemyMinions[i]
        if common.IsValidTarget(minion) then
            -- if vec2(posAfterE(minion)):to3D(mousePos.y).countEnemyLaneMinions(eq.radius+minion.boundingRadius) > max_hits_eq and not orb.core.is_spell_locked() then
            --     max_hits_eq = vec2(posAfterE(minion)):to3D(mousePos.y).countEnemyLaneMinions(eq.radius+minion.boundingRadius)
            if minion.pos:dist(player.pos) < e.range and common.CountMinionsNearPos2(vec2(posAfterE(minion)):to3D(mousePos.y),eq.radius+minion.boundingRadius) > max_hits_eq and not orb.core.is_spell_locked() and canE(minion) then
                max_hits_eq = common.CountMinionsNearPos2(vec2(posAfterE(minion)):to3D(mousePos.y),eq.radius+minion.boundingRadius)
                max_minion_eq = minion
            end
            if minion.pos:dist(player.pos) < q.range then
                for j=0, enemyMinionsSize-1 do
                    local minion2 = enemyMinions[j]
                    if common.IsValidTarget(minion) then
                        local p = mathf.closest_vec_line(minion2.pos2D, player.pos2D, minion.pos2D)
                        local res = minion2.pos2D:dist(p)
                        if res <= q.width + minion2.boundingRadius then
                            minion_hits_q = minion_hits_q + 1
                        end
                    end
                end
                if minion_hits_q > max_hits_q then
                    max_hits_q = minion_hits_q
                    max_minion_q = minion
                end
            elseif minion.pos:dist(player.pos) < q2.range then
                for j=0, enemyMinionsSize-1 do
                    local minion2 = enemyMinions[j]
                    if common.IsValidTarget(minion) then
                        local p = mathf.closest_vec_line(minion2.pos2D, player.pos2D, minion.pos2D)
                        local res = minion2.pos2D:dist(p)
                        if res <= q.width + minion2.boundingRadius then
                            minion_hits_q2 = minion_hits_q2 + 1
                        end
                    end
                end
                if minion_hits_q2 > max_hits_q then
                    max_hits_q2 = minion_hits_q2
                    max_minion_q2 = minion
                end
            end
        end
    end

    if orb.farm.lane_clear_wait() then
        if orb.farm.clear_target and orb.farm.predict_hp(orb.farm.clear_target, q.delay) < math.max(damagelib.get_spell_damage('YasuoQ1Wrapper', 0, player, orb.farm.clear_target, false, 0),damagelib.get_spell_damage('YasuoQ2Wrapper', 0, player, orb.farm.clear_target, false, 0),damagelib.get_spell_damage('YasuoQ3Wrapper', 0, player, orb.farm.clear_target, false, 0)) then
            if not player.path.isDashing then
                player:castSpell('pos', 0, orb.farm.clear_target.pos)
            end
        end
    end

    if player:spellSlot(0).state == 0 and not player.path.isDashing then
        if qTime == 0 or qTime == nil then
            if max_minion_q then
                player:castSpell('pos', 0, max_minion_q.pos)
            end
        end
    end

    if target == nil then

        if player:spellSlot(0).state == 0 and player:spellSlot(2).state == 0 and max_hits_eq > 3 and not orb.core.is_spell_locked() and (qTime == 0 or qTime == nil) then
            for i, turret in pairs(turrets) do
                local x,y = posAfterE(max_minion_eq)
                if vec2(x,y):dist(vec2(turret.pos.x, turret.pos.z)) <= 800 + turret.boundingRadius + player.boundingRadius then
                    goto turretEQSkip
                end
            end
            player:castSpell('obj', 2, max_minion_eq)
            common.DelayAction(function() player:castSpell('pos', 0, vec3(max_minion_eq.pos.x,max_minion_eq.pos.y,max_minion_eq.pos.z)) end,0.2)
        end
        ::turretEQSkip::
        if player:spellSlot(0).state == 0 and not player.path.isDashing then
            if not (qTime == 0 or qTime == nil) then
                if max_minion_q2 then
                    player:castSpell('pos', 0, max_minion_q2.pos)
                end
            end
        end

        -- E lasthit
        if player:spellSlot(2).state == 0 then
            for i=0, enemyMinionsSize-1 do
                local minion = enemyMinions[i]
                if common.IsValidTarget(minion) and minion.pos:dist(player.pos) < e.range and canE(minion) then
                    if minion.health < Edmg(minion) then
                        -- chat.print(damagelib.get_spell_damage('YasuoE', 2, player, minion, false, 0))
                        for i, turret in pairs(turrets) do
                            local x,y = posAfterE(minion)
                            if vec2(x,y):dist(vec2(turret.pos.x, turret.pos.z)) <= 800 + turret.boundingRadius + player.boundingRadius then
                                goto turretESkip
                            end
                        end
                        player:castSpell('obj', 2, minion) 
                        ::turretESkip::
                    end
                end
            end
        end
    else
        if player:spellSlot(0).state == 0 and not player.path.isDashing then
            if not (qTime == 0 or qTime == nil) then
                local seg = pred.linear.get_prediction(q2,target)
                if seg ~= nil and seg.endPos:dist(player.pos) <= q2.range then
                    player:castSpell('pos', 0, vec3(seg.endPos.x, mousePos.y, seg.endPos.y))
                end
            end
        end
    end
    
end

local function q_delay()
    local d = 0.35
    local as = common.GetBonusAS()
    local i = 0
    if as > 120 then
        q.delay = 0.175
    end
    while as > 0 do
        if as - 1 > 0 then
            as = as - 1
            i = i + 1
        else
            break
        end
    end
    d = d - i * 0.001458333333333333
    q.delay = d 

    d = 0.35
    local j = 0
    if as > 48 then
        q2.delay = 0.28
    end
    while as > 0 do
        if as - 1 > 0 then
            as = as - 1
            j = j + 1
        else
            break
        end
    end
    d = d - j * 0.001458333333333333
    q2.delay = d
end

local function on_tick()
    -- q_delay()
    e.speed = 750 + 0.85 * player.moveSpeed
    -- chat.print(os.clock().." "..tostring(canAirblade).." "..tostring(waitAirblade).." "..tostring(waitBayblade))
    -- local myVec = vec3(player.pos.x,player.pos.y,player.pos.z)

    -- attackSpeed = (player.attackSpeedMod - 1) * 0.67 + 0.697
    -- chat.print(tostring(orb.core.is_spell_locked()).." "..tostring(orb.core.is_paused()))
    -- chat.print(tostring(rAA).." "..tostring(orb.core.is_spell_locked()))
    -- orb.core.set_server_pause()
    -- orb.core.set_pause(0.0001)
    -- chat.print(player:spellSlot(0).cooldown)
    -- chat.print(speed)
    if orb.combat.is_active() then
        combo()
    end 
    if orb.menu.lane_clear.key:get() and menu.yasuomenu.Misc.farm_key:get() then
        laneClear()
    end
    -- if orb.menu.hybrid.key:get() then
    --     harass()
    -- end
    -- if orb.menu.last_hit.key:get() then
    --     lasthit()
    -- end
    if menu.yasuomenu.Misc.flee_key:get() then
        flee()
    end
end

cb.add(cb.tick,on_tick)

local function on_draw()
    local drawq = menu.yasuomenu.Draw.q_draw:get()
    local drawr = menu.yasuomenu.Draw.r_draw:get()
    local ready = menu.yasuomenu.Draw.ready:get()

    local qBuff = false
	local buff_keys = player.buff.keys
	for i = 1, buff_keys.n do
		local buff_key = buff_keys[i]
		local buff = player.buff[buff_key]
        if buff and buff.valid and buff.name == "YasuoQ2" then
            qBuff = true
        end
    end

    if ((ready and player:spellSlot(0).state == 0) or not ready) and drawq and qBuff then
        graphics.draw_circle(player.pos, q2.range, 2, graphics.argb(255, 0, 255, 0), 100)
    elseif ((ready and player:spellSlot(0).state == 0) or not ready) and drawq then
        graphics.draw_circle(player.pos, q.range, 2, graphics.argb(255, 0, 255, 0), 100)
    end
    if ((ready and player:spellSlot(3).state == 0) or not ready) and drawr then
        graphics.draw_circle(player.pos, r.range, 2, graphics.argb(255, 0, 255, 0), 100)
    end
    -- local dir = player.direction
    -- dir = dir * 200
    -- dir = player.pos + dir
    -- graphics.draw_line(player.pos, dir, 2, 0xFFFFFFFF)

    -- local target = getTarget("combo",1400)
    -- if target and target ~= nil then
    --     local dir = target.direction
    --     dir = dir * 50
    --     dir = target.pos + dir
    --     graphics.draw_line(target.pos, dir, 2, 0xFFFFFFFF)
    -- end
        -- local hpBar = player.barPos
        -- local buff_keys = player.buff.keys
        -- for i = 1, buff_keys.n do
        --     local buff_key = buff_keys[i]
        --     local buff = player.buff[buff_key]
        --     if buff and buff.valid then 
        --         local string = "Name: "..buff.name.." Type: "..buff.type.." Stacks: "..buff.stacks.." Stacks2: "..buff.stacks2
        --         graphics.draw_text_2D(string, 18, hpBar.x + 160, hpBar.y + 70 + 15*i, 0xFFFFFFFF)
        --     end
        -- end
end

cb.add(cb.draw,on_draw)

-- chat.print('[Dalandan AIO] Loading yasuo successful!')
