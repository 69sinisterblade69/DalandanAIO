local orb = module.internal("orb");
local ts = module.internal("TS");
local pred = module.internal("pred");
local evade = module.seek('evade')
local damagelib = module.internal("damagelib")

local common = module.load("Dalandan_AIO", "common");
local menu = module.load("Dalandan_AIO", "menu");

local q = {
    speed = math.huge,
    range = 450,
    width = 80,
    boundingRadiusMod = 1, --??
    damage = function(m)
        return 15*player:spellSlot(0).level + 5 + 1.05 * common.GetTotalAD(player)
    end,
    delay = 0.35,
}

local q2 = {
    speed = 1200,
    range = 1150,
    width = 180,
    boundingRadiusMod = 1, --??
    damage = function(m)
        return 15*player:spellSlot(0).level + 5 + 1.05 * common.GetTotalAD(player)
    end,
    delay = 0.35,
}

local eq = {
    radius = 215,
}

local e = {
    range = 475,
    speed = 750 + 0.6 * player.moveSpeed,
    damage = function(m)
        return 50 + (10*player:spellSlot(2).level) + 0.2* common.GetBonusAD() + 0.6* common.GetTotalAP()
    end,
}

local r = {
    range = 1400,
    radius = 400,
    damage = function(m)
        return 150*player:spellSlot(0).level + 50 + 1.5 * common.GetBonusAD(player)
    end,
    delay = 0,
    boundingRadiusMod = 0, --??
    speed = math.huge,
}

local function posAfterE(target)
    local x = player.pos.x
    local y = player.pos.z
    local D = e.range
    local x2 = target.pos.x
    local y2 = target.pos.z

    local x1 = x + D * (x2 - x) / math.sqrt((x2 - x)^2 + (y2 - y)^2)
    local y1 = y + D * (y2 - y) / math.sqrt((x2 - x)^2 + (y2 - y)^2)

    return x1,y1
end

local function canE(target)
    local ebuff = nil
	local buff_keys = player.buff.keys
	for i = 1, buff_keys.n do
		local buff_key = buff_keys[i]
		local buff = player.buff[buff_key]
        if buff and buff.valid and buff.name == "YasuoE" then 
            return false
        end
    end
    return true
end

local function ts_filter_basic(res, object, dist)
    if object and common.IsValidTarget(object) and common.IsEnemyHero(object) then
        if (object.buff["rocketgrab"]) then return end
        res.object = object
        return true
    end 
end

local function getTarget(mode, range)
	local currentTarget = nil
    if mode == "combo" then

        --force [hard] target check
        local target = ts.get_result(ts_filter_basic, nil, nil, true)
		if target.object ~= nil then
			if player.pos:dist(target.object.pos) < (range + target.object.boundingRadius) then
                return target
			end
		end

        currentTarget = ts.get_result(ts_filter_basic, ts.filter_set[1])
        if currentTarget.object ~= nil then
            if currentTarget.object.pos:dist(player.pos) < (range + currentTarget.object.boundingRadius) then
                return currentTarget
            end
        end
	end
    if mode == "harass" then
        local count, minions = common.CountMinionsNearPos2(player.pos, range+50)
        for i, minion in pairs(minions) do
            local time = orb.utility.get_hit_time(player, minion)
            if damagelib.calc_aa_damage(player, minion) > orb.farm.predict_hp(minion, time) and orb.core.can_attack() then
                return minion
            end
        end
        -- hard target
        local target = ts.get_result(ts_filter_basic, nil, nil, true)
		if target.object ~= nil then
			if player.pos:dist(target.object.pos) < (range + target.object.boundingRadius) then
                return target
			end
		end

        currentTarget = ts.get_result(ts_filter_basic, ts.filter_set[1])
        if currentTarget.object ~= nil then
            if currentTarget.object.pos:dist(player.pos) < (range + currentTarget.object.boundingRadius) then
                return currentTarget
            end
        end

    end
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
    if max_minion ~= nil and min_dist + 100 < player.pos:dist(mousePos) then
        player:castSpell('obj', 2, max_minion)
    end
    player:move(mousePos)
end

local function combo()
    local target = getTarget("combo",1400)
    if target and target.object ~= nil then
        if menu.yasuomenu.Combo.r_combo:get() and not player:spellSlot(3).state ~= 0 then
            local enemyHPPercentage = target.object.maxHealth / 100 * menu.yasuomenu.Combo.r_enemy_hp:get()
            local isEnemyKnockedUp = false
            local buff_keys = target.buff.keys
            for i = 1, buff_keys.n do
                local buff_key = buff_keys[i]
                local buff = target.buff[buff_key]
                if buff and buff.valid and buff.type == BUFF_KNOCKUP then 
                    isEnemyKnockedUp = true
                end
            end
            if isEnemyKnockedUp then
                local HPDiff = player.health - target.object.health
                local HPDiffNeeded = target.object.maxHealth / 100 * menu.yasuomenu.Combo.r_yasuo_hp:get()
                if HPDiff >= HPDiffNeeded then
                    if target.object.health <= enemyHPPercentage then
                        -- ResetReady block here??
                        if player.pos:dist(target.object.pos) <= r.range then
                            if not orb.core.is_spell_locked() then
                                player:castSpell('pos', 3, vec3(target.object.pos.x, target.object.y, target.object.pos.z))
                            end
                        end
                    end
                end
            end
        end
        if menu.yasuomenu.Combo.e_gap_combo:get() and not player:spellSlot(2).state ~= 0 then
            local YasuoDistToTarget = player.pos:dist(target.object.pos)
            if YasuoDistToTarget > 450 then

                local min_dist = math.huge
                local min_minion = nil
                for i=0, objManager.maxObjects-1 do
                    local obj = objManager.get(i)
                    if obj and obj.team ~= TEAM_ALLY and obj.type==TYPE_MINION and common.IsValidTarget(obj) and canE(obj) and obj.pos:dist(player.pos) <= e.range and not string.find(string.lower(tostring(obj.name)),"plant") then
                        local x1,y1 = posAfterE(obj)
                        if vec3(x1,obj.pos.y,y1):dist(target.object.pos) < min_dist then
                            min_dist = vec3(x1,obj.pos.y,y1):dist(mousePos)
                            min_minion = obj
                        end
                    end
                end
                if min_minion ~= nil and min_dist + 80 < player.pos:dist(target.object.pos) then --?
                    player:castSpell('obj', 2, min_minion)
                end

            end
        end
        local qBuff = nil
        local buff_keys = player.buff.keys
        for i = 1, buff_keys.n do
            local buff_key = buff_keys[i]
            local buff = player.buff[buff_key]
            if buff and buff.valid and buff.name == "YasuoQ2" then 
                qBuff = true
            end
        end
        
        if qBuff and menu.yasuomenu.Combo.q_combo:get() and menu.yasuomenu.Combo.e_combo:get() then
            if player.pos:dist(target.object.pos) >= 500 then
                if not player:spellSlot(0).state ~= 0 and not orb.core.is_spell_locked() and not player.path.isDashing then
                    local seg = pred.linear.get_prediction(q2,target.object)
                    if seg ~= nil then
                        player:castSpell('pos', 0, vec3(seg.endPos.x, mousePos.y, seg.endPos.y))
                    end
                end
            end
            if player:spellSlot(0).state == 0 and not player:spellSlot(2).state ~= 0 and not orb.core.is_spell_locked() then
                if player.pos:dist(target.object.pos) <= 450 and canE(target.object) and player.pos:dist(target.object.pos) > ((e.range - eq.radius)+100)  then
                    player:castSpell('obj', 2, target.object)
                    player:castSpell('pos', 0, target.object.pos)
                end
            else
                if player:spellSlot(0).state == 0 then --better logic here, wait for E and check canE?
                    local seg = pred.linear.get_prediction(q2,target.object)
                    if seg ~= nil and not player.path.isDashing then
                        player:castSpell('pos', 0, vec3(seg.endPos.x, mousePos.y, seg.endPos.y))
                    end
                end
            end
        end
        if player:spellSlot(0).state == 0 and menu.yasuomenu.Combo.q_combo:get() then
            if player.pos:dist(target.object.pos) <= 450 then
                local seg = pred.linear.get_prediction(q,target.object)
                -- probably will cancel AA's like crazy so do something
                if seg ~= nil and orb.core.can_attack() and not player.path.isDashing  then -- ResetReady | ResetReady = 1  - can attack?
                    player:castSpell('pos', 0, vec3(seg.endPos.x, mousePos.y, seg.endPos.y)) 
                end
            end
        end
        if player:spellSlot(2).state == 0 and menu.yasuomenu.Combo.e_combo:get() then
            local qBuff = nil
            local buff_keys = player.buff.keys
            for i = 1, buff_keys.n do
                local buff_key = buff_keys[i]
                local buff = player.buff[buff_key]
                if buff and buff.valid and buff.name == "YasuoQ1" then -- missclick? YasuoQ2 maybe??
                    qBuff = true
                end
            end
            if canE(target.object) and qBuff ~= true then
                if player.pos:dist(target.object.pos) >= player.attackRange + 50 and player.pos:dist(target.object.pos) <= 450 then
                    player:castSpell('obj', 2, target.object)
                end
            end
        end
    end
end

local function laneClear()
    local target = getTarget("combo",1400)
    local minions = {}
    for i=0, objManager.maxObjects-1 do
        local obj = objManager.get(i)
        if obj and obj.team ~= TEAM_ALLY and obj.type==TYPE_MINION and common.IsValidTarget(obj) and not string.find(string.lower(tostring(obj.name)),"plant") then
            minions[i]=obj
        end
    end
    
    if target == nil then
        if player:spellSlot(0).state == 0 and menu.yasuomenu.Misc.q_laneclear_stack:get() then
            for i, minion in pairs(minions) do
                if player.pos:dist(minion.pos) <= 450 and canE(minion) then
                    local count, table = common.CountEnemiesNearPos(minion.pos, 400)
                    if minion.health > q.damage() + 50 and count <= 0 and not player.path.isDashing then
                        player:castSpell('pos', 0, vec3(minion.pos.x, minion.pos.y, minion.pos.z)) 
                    end
                end
            end
        end
    else
        if player:spellSlot(0).state == 0 and menu.yasuomenu.Misc.q_laneclear_stack:get() then
            local qBuff = false
            local buff_keys = player.buff.keys
            for i = 1, buff_keys.n do
                local buff_key = buff_keys[i]
                local buff = player.buff[buff_key]
                if buff and buff.valid and buff.name == "YasuoQ2" then
                    qBuff = true
                end
            end
            if not qBuff then
                for i, minion in pairs(minions) do
                    if player.pos:dist(minion.pos) <= 450 and canE(minion) then
                        local count, table = common.CountEnemiesNearPos(minion.pos, 400)
                        if minion.health > q.damage() * common.PhysicalReduction(minion) + 50 and count <= 0 and not player.path.isDashing then
                            player:castSpell('pos', 0, vec3(minion.pos.x, minion.pos.y, minion.pos.z)) 
                        end
                    end
                end
            end
        end
    end
    if menu.yasuomenu.Misc.e_laneclear:get() and player:spellSlot(2).state == 0 then
        local turrets = {}
        for i=0, objManager.turrets.size[TEAM_ENEMY]-1 do
            turrets[i] = objManager.turrets[TEAM_ENEMY][i]
        end

        for i, minion in pairs(minions) do
            if player.pos:dist(minion.pos) <= e.range and canE(minion) then
                if minion.health <= e.damage() * common.MagicReduction(minion) then
                    for i, turret in pairs(turrets) do
                        local x,y = posAfterE(minion)
                        if vec2(x,y):dist(vec2(turret.pos.x, turret.pos.z)) <= 750 + turret.boundingRadius + player.boundingRadius then
                            goto turretESkip
                        end
                    end
                    player:castSpell('obj', 2, minion) 
                    ::turretESkip::
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

local function lasthit()
    local minions = {}
    for i=0, objManager.maxObjects-1 do
        local obj = objManager.get(i)
        if obj and obj.team ~= TEAM_ALLY and obj.type==TYPE_MINION and common.IsValidTarget(obj) and not string.find(string.lower(tostring(obj.name)),"plant") then
            minions[i]=obj
        end
    end
    
    if menu.yasuomenu.Misc.q_lasthit:get() and player:spellSlot(0).state == 0 then
        local qBuff = false
        local buff_keys = player.buff.keys
        for i = 1, buff_keys.n do
            local buff_key = buff_keys[i]
            local buff = player.buff[buff_key]
            if buff and buff.valid and buff.name == "YasuoQ2" then
                qBuff = true
            end
        end

        if not qBuff then
            for i, minion in pairs(minions) do
                if player.pos:dist(minion.pos) <= 450 then
                    if minion.health <= q.damage() * common.PhysicalReduction(minion) and not player.path.isDashing then
                        player:castSpell('pos', 0, vec3(minion.pos.x, minion.pos.y, minion.pos.z)) 
                    end
                end
            end
        end
    end

    if menu.yasuomenu.Misc.e_lasthit:get() and player:spellSlot(2).state == 0 then
        for i, minion in pairs(minions) do
            if player.pos:dist(minion.pos) <= e.range then
                if minion.health <= e.damage() * common.MagicReduction(minion) then
                    player:castSpell('obj', 2, minion) 
                end
            end
        end
    end
end

local function harass()
    local target = getTarget("harass", 1400)
    if target and target.object ~= nil then
        
        if menu.yasuomenu.Harass.e_gap_harass:get() and not player:spellSlot(2).state ~= 0 then
            local YasuoDistToTarget = player.pos:dist(target.object.pos)
            if YasuoDistToTarget > 450 then
                local min_dist = math.huge
                local min_minion = nil
                for i=0, objManager.maxObjects-1 do
                    local obj = objManager.get(i)
                    if obj and obj.team ~= TEAM_ALLY and obj.type==TYPE_MINION and common.IsValidTarget(obj) and canE(obj) and obj.pos:dist(player.pos) <= e.range and not string.find(string.lower(tostring(obj.name)),"plant") then
                        local x1,y1 = posAfterE(obj)
                        if vec3(x1,obj.pos.y,y1):dist(target.object.pos) < min_dist then
                            min_dist = vec3(x1,obj.pos.y,y1):dist(mousePos)
                            min_minion = obj
                        end
                    end
                end
                if min_minion ~= nil and min_dist + 80 < player.pos:dist(target.object.pos) then --?
                    player:castSpell('obj', 2, min_minion)
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
        
        if qBuff and menu.yasuomenu.Harass.q_harass:get() and menu.yasuomenu.Harass.e_harass:get() then
            -- q2
            if player.pos:dist(target.object.pos) > 500 then
                if player:spellSlot(0).state == 0 then
                    local seg = pred.linear.get_prediction(q2,target.object)
                    if seg ~= nil and not player.path.isDashing then
                        player:castSpell('pos', 0, vec3(seg.endPos.x, mousePos.y, seg.endPos.y))
                    end
                end
            end 
            -- here
            if player:spellSlot(0).state == 0 and player:spellSlot(2).state == 0 then
                if canE(target.object) and player.pos:dist(target.object.pos) <= 450 and player.pos:dist(target.object.pos) > ((e.range - eq.radius)+100) then
                    player:castSpell('obj', 2, target.object)
                    player:castSpell('pos', 0, target.object.pos)
                end
            elseif player:spellSlot(0).state == 0 then
                local seg = pred.linear.get_prediction(q2,target.object)
                if seg ~= nil and not player.path.isDashing then
                    player:castSpell('pos', 0, vec3(seg.endPos.x, mousePos.y, seg.endPos.y))
                end
            end 
        end
        if menu.yasuomenu.Harass.q_harass:get() and player:spellSlot(0).state == 0 then
            if player.pos:dist(target.object.pos) <= 450 then
                -- resetready bullshit again
                local seg = pred.linear.get_prediction(q,target.object)
                if seg ~= nil and not player.path.isDashing  then --  and orb.core.can_attack() -- idk this fucking shit
                    player:castSpell('pos', 0, vec3(seg.endPos.x, mousePos.y, seg.endPos.y)) 
                end
            end
        end
        if menu.yasuomenu.Harass.e_harass:get() and player:spellSlot(2).state == 0 then
            local qBuff = false
            local buff_keys = player.buff.keys
            for i = 1, buff_keys.n do
                local buff_key = buff_keys[i]
                local buff = player.buff[buff_key]
                if buff and buff.valid and buff.name == "YasuoQ1" then
                    qBuff = true
                end
            end
            if canE(target) and not qBuff then -- not qBuff = use only on first Q or windQ
                if player.pos:dist(target.object.pos) <= player.attackRange + 50 and player.pos:dist(target.object.pos) <= 450 then
                    player:castSpell('obj', 2, target.object)
                end
            end
        end
    end
end

local function on_tick()
    q_delay()
    if orb.combat.is_active() then
        combo()
    end 
    if orb.menu.lane_clear.key:get() then
        laneClear()
    end
    if orb.menu.hybrid.key:get() then
        harass()
    end
    if orb.menu.last_hit.key:get() then
        lasthit()
    end
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

end

cb.add(cb.draw,on_draw)

chat.print('[Dalandan AIO] Loading yasuo successful!')