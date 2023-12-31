local orb = module.internal("orb");
local ts = module.internal("TS");
local pred = module.internal("pred");
local damagelib = module.internal("damagelib");
local evade = module.seek("evade")
if not evade then
    chat.print("[Dalandan AIO] <font color=\"#FF0000\">ENABLE HANBOT EVADE OR YOU WILL HAVE ERRORS </font>")
end

local common = module.load("Dalandan_AIO", "common");
local menu = module.load("Dalandan_AIO", "menu");

local q = {    
    width = 60,
    width2 = 90,
    speed = 2200,
    delay = 0.625,
    boundingRadiusMod = 1, -- ????
    range = 1240,
    damage = function(target)
        return damagelib.get_spell_damage('CaitlynQ',0,player,target,false,0)
    end,
    collision = {
        wall = true,
        minion = false,
        hero = false, 
    },
}

q.range = q.range * 0.95

local w = {
    range = 800,
    radius = 15,
    delay = 0.25 + 1,
    speed = math.huge,
    boundingRadiusMod = 1,
}

local e = {
    delay = 0.15,
    range = 740,
    width = 70,
    speed = 1600,
    boundingRadiusMod = 1,
    dashRange = 390,
    dashSpeed = 500, -- find correct value
    collision = {
        wall = true,
        minion = true,
        hero = false, 
    },
}

local r = {
    delay = 0.375 + 1,
    range = 3500,
    width = 40,
    speed = 3200,
    boundingRadiusMod = 0,
}

local function ts_filter_basic(res, object, dist)
    if object and common.IsValidTarget(object) and common.IsEnemyHero(object) then
        if (object.buff["rocketgrab"]) then return end
        
        res.object = object
        return true
    end 
end

local lastTarget = nil
local function getTarget(range)
    local orbTarget = orb.combat.get_target()
    if orbTarget and player.pos:dist(orbTarget.pos) < (range + orbTarget.boundingRadius) and common.IsValidTarget(orbTarget) then
        lastTarget = orbTarget
        return lastTarget
    end
    if lastTarget and common.IsValidTarget(lastTarget) and player.pos:dist(lastTarget.pos) < (range + lastTarget.boundingRadius) and not ts.selected then
        return lastTarget
    end
    local target = ts.get_result(ts_filter_basic).object
    if target and common.IsValidTarget(target) then
        if player.pos:dist(target.pos) < (range + target.boundingRadius) then
            lastTarget = target
            return target
        end
    end
end

local function posAfterE(pos, range)
    local x = player.pos.x
    local y = player.pos.z
    local D = range or e.dashRange 
    -- local x2 = target.pos.x
    -- local y2 = target.pos.z
    local x2 = pos.x
    local y2
    if pos.z == nil then
        y2 = pos.y
    else
        y2 = pos.z
    end
     

    local x1 = x - D * (x2 - x) / math.sqrt((x2 - x)^2 + (y2 - y)^2)
    local y1 = y - D * (y2 - y) / math.sqrt((x2 - x)^2 + (y2 - y)^2)

    return vec2(x1,y1)
end

local hookCache = {}
for i=0, objManager.enemies_n-1 do
    local obj = objManager.enemies[i]
    if obj.charName == "Blitzcrank" or obj.charName == "Thresh" or obj.charName == "Pyke" or obj.charName == "Nautilus" then
        table.insert(hookCache,obj)
    end
end

local function dashCheck(pos)
    local safe = true
    if pos.z == nil then
        pos = pos:toGame3D()
    end
    -- evade check
    if evade and not evade.core.is_action_safe(pos, e.dashSpeed, e.delay) then
        safe = false
    end

    -- turret check
    local turretSize = objManager.turrets.size[TEAM_ENEMY]-1
    for i=0, turretSize do
        turret = objManager.turrets[TEAM_ENEMY][i]
        if pos:dist(turret.pos) <= 800 + turret.boundingRadius + player.boundingRadius then
            safe = false
        end
    end

    -- enemy check
    local count, heroes = common.CountEnemiesNearPos(pos, 650)
    if count >= 3 then
        safe = false
    end

    if menu.caitlynmenu.e.e_safety_melee:get() then
        local count = 0
        if heroes then
            for i,hero in pairs(heroes) do
                if hero.pos:dist(pos) < 450 and hero.isMelee then
                    count = count + 1
                end
            end
            if count >= 1 then
                safe = false
            end 
        end
    end

    -- wall check
    -- local seg = e.dashRange / 5
    -- for i=1, 5 do
    --     local factor = 0.2 * I
    --     local checkPos = player.pos:lerp(pos,factor)
    --     if navmesh.isWall(checkPos) then
    --         safe = false
    --     end
    -- end
    local checkPos = pos:lerp(player.pos,0.17)
    if navmesh.isWall(pos) and navmesh.isWall(checkPos) then
        safe = false
    end

    -- hook check
    if menu.caitlynmenu.e.e_safety_hook:get() then
        local hooks = {
            ["Blitzcrank"] = 0,
            ["Thresh"] = 0,
            ["Pyke"] = 0,
            ["Nautilus"] = 0,
        }
        for j,hhero in pairs(hookCache) do
            if hhero then
                if (hhero:spellSlot(hooks[hhero.charName]).cooldown == 0 or hhero:spellSlot(hooks[hhero.charName]).totalCooldown - hhero:spellSlot(hooks[hhero.charName]).cooldown < 0.7) and (hhero.pos:dist(player.pos) < 1500 or pos:dist(hhero.pos) < 1500) then
                    -- chat.print(os.clock().." hook")
                    safe = false
                end
            end
        end
    end

    return safe
end

local issueTarget = nil
local function on_issue_order(args)
    if args.order == 3 then --attack order
        issueTarget = args.target
    end
end

cb.add(cb.issue_order, on_issue_order)

local LastW = {
    target = player,
    time = 0,
}
local function castW(pos, target)
    if orb.core.is_spell_locked() then return end
    if player:spellSlot(1).state ~= 0 then return end
    if LastW.target == target and game.time - LastW.time < 3.2 then return end

    if pos.z ~= nil then
        LastW.target = target
        LastW.time = game.time
        player:castSpell("pos",1, vec3(pos.x, pos.y, pos.z))
    else
        LastW.target = target
        LastW.time = game.time
        player:castSpell("pos",1, vec3(pos.x, player.y, pos.y))
    end
    -- orb.core.set_server_pause()
end

local function castE(pos, skip)
    if orb.core.is_spell_locked() then return end
    if player:spellSlot(2).state ~= 0 then return end
    
    skip = skip or false
    local dashPos = posAfterE(pos)
    local safe = dashCheck(dashPos)
    if (safe and not skip) or skip then
        if pos.z ~= nil then
            player:castSpell("pos",2, vec3(pos.x, pos.y, pos.z))
        else
            player:castSpell("pos",2, vec3(pos.x, player.y, pos.y))
        end
    end
    -- orb.core.set_server_pause()
end

local function trace_filter_q(seg, obj)
    if pred.trace.linear.hardlock(q, seg, obj) then
        return true
    end
    if pred.trace.linear.hardlockmove(q, seg, obj) then
        return true
    end

    if pred.trace.newpath(obj, 0.033, 0.500) then
        return true
    end
end

local function castQ(pos, check, target)
    if orb.core.is_spell_locked() then return end
    if player:spellSlot(0).state ~= 0 then return end
    local check = check or false
    local target = target or nil
    if check then
        -- aa range check
        if menu.caitlynmenu.q.aarange:get() and player.pos2D:dist(pos) < common.GetAARange() then return end
        
        -- dmg check
        if menu.caitlynmenu.q.q_dps:get() and target ~= nil then
            local qDmg = damagelib.get_spell_damage('CaitlynQ', 0, player, target, false, 0)
            local aaDmg = 0
            local howManyAA = 0
            local qDelay = q.delay
            while qDelay > 0 do
                howManyAA = howManyAA + 1
                qDelay = qDelay - player:attackDelay()
            end
            aaDmg = damagelib.calc_aa_damage(player,target,true)
            aaDmg = aaDmg + (damagelib.calc_aa_damage(player,target,false) * (howManyAA - 1))
            if player.pos2D:dist(pos) < common.GetAARange() + 65 and aaDmg > qDmg then
                return
            end
        end

        -- w prio check
        if menu.caitlynmenu.w.w_prio:get() then
            if target.pos:dist(player.pos) < w.range + 50 then
                -- get w cd
                local trueCooldown = player:spellSlot(1).cooldown
                if player:spellSlot(1).stacks == 0 and player:spellSlot(1).stacksCooldown ~= 0 then
                    trueCooldown = player:spellSlot(1).stacksCooldown
                elseif player:spellSlot(1).stacks ~= 0 then
                    trueCooldown = player:spellSlot(1).cooldown
                end
                
                if trueCooldown < q.delay then
                    return
                end
            end
        end
    end

    if pos.z ~= nil then
        player:castSpell("pos",0, vec3(pos.x, pos.y, pos.z))
    else
        player:castSpell("pos",0, vec3(pos.x, player.y, pos.y))
    end
    orb.core.set_server_pause()
end

local function antiGapClose()
    if menu.caitlynmenu.e.e_antigapcloser:get() then
        local seg = {}
		for i, target in pairs(common.GetEnemyHeroes()) do
            if target and common.IsValidTarget(target) and target.path.isActive and target.path.isDashing then
                local pred_seg = pred.linear.get_prediction(e, target, player)
                if pred_seg and pred_seg.endPos:dist(player.path.serverPos2D) <= e.range then
                    seg.startPos = player.path.serverPos2D
                    -- seg.endPos = vec2(pred_pos.x, pred_pos.y)
                    seg.endPos = pred_seg.endPos
                    -- chat.print(os.clock().." cast E due to antigapclose")
                    castE(seg.endPos)
                end
            end    
        end
    end
    if menu.caitlynmenu.w.w_antigapcloser:get() then
        local seg = {}
		for i, target in pairs(common.GetEnemyHeroes()) do
            if target and common.IsValidTarget(target) and target.path.isActive and target.path.isDashing then
                local pred_seg = pred.circular.get_prediction(w, target, player)
                if pred_seg and pred_seg.endPos:dist(player.path.serverPos2D) <= w.range then
                    seg.startPos = player.path.serverPos2D
                    -- seg.endPos = vec2(pred_pos.x, pred_pos.y)
                    seg.endPos = pred_seg.endPos
                    -- chat.print(os.clock().." cast W due to antigapclose")
                    castW(seg.endPos, target)
                end
            end    
        end
    end
end

local function hard_cc(pred_input, seg, obj, p)
    if p == "circular" then
        if pred.trace.circular.hardlock(pred_input, seg, obj) then
            return true
        end
        if pred.trace.circular.hardlockmove(pred_input, seg, obj) then
            return true
        end
    end
    if p == "linear" then
        if pred.trace.linear.hardlock(pred_input, seg, obj) then
            return true
        end
        if pred.trace.linear.hardlockmove(pred_input, seg, obj) then
            return true
        end
    end
    return false
end

local function autoW()
    if menu.caitlynmenu.w.w_auto:get() then
        for i, target in pairs(common.GetEnemyHeroes()) do
            if target and common.IsValidTarget(target) then
                local pred_seg = pred.circular.get_prediction(w,target,player)
                if pred_seg.endPos:dist(player.pos) < w.range then
                    
                    --melee range
                    if player.pos:dist(target.pos) < 300 then
                        -- chat.print(os.clock().." cast W due to melee")
                        castW(pred_seg.endPos,target)
                    end

                    -- hard cc
                    if hard_cc(w,pred_seg,target,"circular") then
                        -- chat.print(os.clock().." cast W due to hard CC")
                        castW(pred_seg.endPos,target)
                    end
                    
                    -- slow
                    if target.buff[BUFF_SLOW] then
                        -- chat.print(os.clock().." cast W due to slow")
                        castW(pred_seg.endPos,target)
                    end
                end
            end
        end
    end
end

local function combo()
    local target = getTarget(q.range)
    if target then
        -- Q
        if menu.caitlynmenu.q.q_combo:get() then
            local count, table = common.CountEnemiesNearPos(player.pos,400)
            if count < 1 then
                local pred_seg = pred.linear.get_prediction(q,target)
                if pred_seg.endPos and pred_seg.endPos:dist(player.pos) < q.range then
                    if menu.caitlynmenu.q.pred:get() then
                        if trace_filter_q(pred_seg,target) then
                            castQ(pred_seg.endPos, true, target)
                        end
                    else
                        castQ(pred_seg.endPos, true, target)
                    end
                end
            end
        end

        -- E (+ galeforce)
        if menu.caitlynmenu.e.e_combo:get() then
            if target.pos:dist(player.pos) < e.range then
                local pred_seg = pred.linear.get_prediction(e,target)
                if pred_seg.endPos and pred_seg.endPos:dist(player.pos) < e.range and not pred.collision.get_prediction(e, pred_seg, target)  then
                    if menu.caitlynmenu.e.e_galeforce:get() then
                        for i=0, 5 do
                            if player:itemID(i) == 6671 then -- galeforce 
                                if player:spellSlot(6+i).cooldown == 0 and dashCheck(posAfterE(pred_seg.endPos,-425)) and target.health/target.maxHealth <= menu.caitlynmenu.e.gale_hp:get()/100 then
                                    castE(pred_seg.endPos, true)
                                    player:castSpell("pos",6+i, vec3(pred_seg.endPos.x, player.y, pred_seg.endPos.y))
                                    common.DelayAction(function()
                                        player:castSpell("pos",6+i, vec3(pred_seg.endPos.x, player.y, pred_seg.endPos.y))
                                    end,2*network.latency + 0.01)
                                end
                            end
                        end
                        castE(pred_seg.endPos)
                    else
                        castE(pred_seg.endPos)
                    end
                end
            end
        end

        -- E chase
        if menu.caitlynmenu.e.e_chase:get() then
            if player.pos:dist(target.pos) > common.GetAARange(target) + 150 and target.health/target.maxHealth <= menu.caitlynmenu.e.chase_hp:get()/100 then
                local v1 = target.pos
                local pos = posAfterE(v1)
                castE(pos)
            end
        end
    end
end

local function minionsHit(pos,pred)
    -- assume no collision with minions
    local minions = objManager.minions["farm"]
    local minionSize = minions.size
    local count = 0
    if pos.z ~= nil then
        pos = vec2(pos.x,pos.z)
    end
    local endPos = posAfterE(pos,-q.range)
    for i=0,minionSize do
        local obj2 = minions[i]
        if common.IsValidTarget(obj2) and obj2.pos:dist(player.pos) < pred.range and not obj2.isDead and obj2.health and obj2.health > 0 and obj2.isVisible and obj2.isTargetable then
            local p = mathf.closest_vec_line(obj2.pos2D, player.pos2D, endPos)
            local res = obj2.pos2D:dist(p)
            if count <= 0 then
                if res <= q.width + obj2.boundingRadius then
                    count = count + 1
                end
            else
                if res <= q.width2 + obj2.boundingRadius then
                    count = count + 1
                end
            end
        end
    end
    return count
end

local function laneClear()
    if menu.caitlynmenu.Misc.farm_key:get() and menu.caitlynmenu.q.q_farm:get() then
        local seg, obj = orb.farm.skill_farm_linear(q)
        local count = menu.caitlynmenu.q.q_count:get()
        if seg then
            if minionsHit(seg.endPos,q) >= count then
                castQ(seg.endPos, false)
            end
        elseif not orb.farm.lane_clear_wait() then
            local minions = objManager.minions["farm"]
            local minionSize = minions.size
            local maxMinion = nil
            local maxHits = 0
            for i=0,minionSize do
                local minion = minions[i]
                if common.IsValidTarget(minion) then
                    local hits = minionsHit(minion.pos2D,q)
                    if hits > maxHits then
                        maxMinion = minion
                        maxHits = hits
                    end
                end
            end
            if maxHits >= count then
                -- local seg = pred.core.get_pos_after_time(maxMinion,q.delay)
                castQ(maxMinion.pos,false)
            end
        end
    end
end

local function lastHit()
    if menu.caitlynmenu.Misc.farm_key:get() and menu.caitlynmenu.q.q_lasthit:get() then
        local seg, obj = orb.farm.skill_farm_linear(q)    
        local delay = q.delay
        if seg then
            delay = delay + (player.pos2D:dist(seg.endPos)/q.speed)
            if (string.find(string.lower(tostring(obj.charName)),"siege") or string.find(string.lower(tostring(obj.charName)),"super")) and orb.farm.predict_hp(obj,delay) < damagelib.get_spell_damage('caitlynQ',0,player,obj,false,0) then
                castQ(seg.endPos, false)
            end
        end
    end
end

local function jungleClear()
    if menu.caitlynmenu.Misc.farm_key:get() and menu.caitlynmenu.q.q_jungle:get() then
        if issueTarget ~= nil and common.IsValidTarget(issueTarget) and issueTarget.team == TEAM_NEUTRAL and not string.find(string.lower(tostring(issueTarget.charName)),"plant")  then
            local pred_segQ = pred.linear.get_prediction(q, issueTarget, player)
            if pred_segQ and pred_segQ.endPos:dist(player.pos) <= q.range then
                castQ(pred_segQ.endPos, false)
            end
        end
    end
end

local function killsteal()
    for i, target in pairs(common.GetEnemyHeroes()) do
        if target and common.IsValidTarget(target) then
            if menu.caitlynmenu.Misc.eq_ks:get() and player:spellSlot(2).state == 0 then
                local edmg = damagelib.get_spell_damage('CaitlynE', 2, player, target, false, 0)
                local qdmg = 0
                if player:spellSlot(0).state == 0 or player:spellSlot(0).cooldown < e.delay then
                    qdmg = damagelib.get_spell_damage('CaitlynQ', 0, player, target, false, 0)
                end
                local aadmg = damagelib.calc_aa_damage(player,target,true)
                if target.health < edmg + qdmg + aadmg then
                    local pred_seg = pred.linear.get_prediction(e, target, player)
                    if pred_seg and pred_seg.endPos:dist(player.pos) < e.range then
                        castE(pred_seg.endPos)
                        common.DelayAction(function() player:attack(target) end, e.delay+network.latency*2 + 0.2)
                        common.DelayAction(function()
                            local target = getTarget(q.range)
                            if target and common.IsValidTarget(target) then
                                local pred_segQ = pred.linear.get_prediction(q, target, player)
                                if pred_segQ and pred_segQ.endPos:dist(player.pos) <= q.range and menu.caitlynmenu.q.q_eq:get() then
                                    if menu.caitlynmenu.q.pred:get() then
                                        if trace_filter_q(pred_segQ,target) then
                                            castQ(pred_segQ.endPos, false, target)
                                        end
                                    else
                                        castQ(pred_segQ.endPos, false, target)
                                    end
                                end
                            end
                        end,e.delay + network.latency)
                        player:attack(target)
                    end
                end
            end
        end
    end
end

local function flee()
    if menu.caitlynmenu.Misc.flee_key:get() then
        local v1 = mousePos
        local pos = posAfterE(v1)
        -- local pos2 = posAfterE(pos)
        castE(pos)

        -- graphics.draw_circle(vec3(pos.x,player.y,pos.y), 20, 2, graphics.argb(255, 0, 255, 255), 5)
        -- graphics.draw_circle(vec3(pos2.x,player.y,pos2.y), 20, 2, graphics.argb(255, 255, 255, 0), 5)
    end
end

local function semiR()
    if menu.caitlynmenu.r.r_key:get() then
        local target = nil
        if menu.caitlynmenu.r.r_mode:get() == 1 then
            local dist = math.huge
            for i,obj in pairs(common.GetEnemyHeroes()) do
                local newDist = obj.pos:dist(mousePos)
                if newDist < dist and common.IsValidTarget(obj) then
                    dist = newDist
                    target = obj
                end
            end
        elseif menu.caitlynmenu.r.r_mode:get() == 2 then
            local hp = math.huge
            for i,obj in pairs(common.GetEnemyHeroes()) do
                local newHP = obj.health
                if player.pos:dist(obj.pos) < r.range and common.IsValidTarget(obj) and newHP < hp then
                    hp = newHP 
                    target = obj
                end
            end
        end
        if target ~= nil then
            player:castSpell("obj",3, target)    
        end
    end
end

local function harass()
    if menu.caitlynmenu.Misc.farm_key:get() and menu.caitlynmenu.q.q_harass:get() then
        local target = getTarget(q.range)
        if target then
            local seg = pred.linear.get_prediction(q, target, player)
            local count = menu.caitlynmenu.q.q_count_harass:get()
            if seg and seg.endPos:dist(player.pos) <= q.range then
                if minionsHit(seg.endPos,q) >= count then
                    if menu.caitlynmenu.q.pred:get() then
                        if trace_filter_q(seg,target) then
                            castQ(seg.endPos, false)
                        end
                    else
                        castQ(seg.endPos, false)
                    end
                end
            end
        end
    end
end

local function on_tick()
    flee()
    antiGapClose()
    autoW()
    killsteal()
    semiR()
    if orb.combat.is_active() then
        combo()
    end 
    if orb.menu.lane_clear.key:get() then
        laneClear()
        jungleClear()
    end
    if orb.menu.hybrid.key:get() then
        harass()
    end
    if orb.menu.last_hit.key:get() then
        lastHit()
    end
end

cb.add(cb.tick,on_tick)

local function on_process_spell(spell)
    if spell.owner == player and spell.slot == 2 then
        local ew = false
        if menu.caitlynmenu.w.w_ew:get() then
            if player:spellSlot(1).state == 0 then
                ew = true
            end
            common.DelayAction(function()
                local target = getTarget(w.range)
                if target and common.IsValidTarget(target) then
                    local pred_seg = pred.circular.get_prediction(w, target, player)
                    if pred_seg and pred_seg.endPos:dist(player.path.serverPos2D) <= w.range then
                        castW(pred_seg.endPos,target)
                    end
                end
            end,e.delay+network.latency)
        end 
        if menu.caitlynmenu.q.q_eq:get() then
            local delay = e.delay+network.latency
            if ew then
                delay = delay + 0.25 -- w cast delay
            end
            common.DelayAction(function()
                local target = getTarget(q.range)
                if target and common.IsValidTarget(target) then
                    local pred_segQ = pred.linear.get_prediction(q, target, player)
                    if pred_segQ and pred_segQ.endPos:dist(player.pos) <= q.range and menu.caitlynmenu.q.q_eq:get() then
                        if menu.caitlynmenu.q.pred:get() then
                            if trace_filter_q(pred_segQ,target) then
                                castQ(pred_segQ.endPos, false, target)
                            end
                        else
                            castQ(pred_segQ.endPos, false, target)
                        end
                    end
                end
            end,delay)
        end
    end
end

cb.add(cb.spell, on_process_spell)

local function on_draw()
    if game.shopOpen then
        return
    end
    local drawq = menu.caitlynmenu.Draw.q_draw:get()
    local draww = menu.caitlynmenu.Draw.w_draw:get()
    local drawe = menu.caitlynmenu.Draw.e_draw:get()
    local drawr = menu.caitlynmenu.Draw.r_draw:get()
    local ready = menu.caitlynmenu.Draw.ready:get()

    if ((ready and player:spellSlot(0).state == 0) or not ready) and drawq then
        graphics.draw_circle(player.pos, q.range, 2, graphics.argb(255, 0, 255, 0), 100)
    end
    if ((ready and player:spellSlot(1).state == 0) or not ready) and draww then
        graphics.draw_circle(player.pos, w.range, 2, graphics.argb(255, 0, 255, 0), 100)
    end
    if ((ready and player:spellSlot(2).state == 0) or not ready) and drawe then
        graphics.draw_circle(player.pos, e.range, 2, graphics.argb(255, 0, 255, 0), 100)
    end
    if ((ready and player:spellSlot(3).state == 0) or not ready) and drawr then
        graphics.draw_circle(player.pos, r.range, 2, graphics.argb(255, 0, 255, 0), 100)
        minimap.draw_circle(player.pos, r.range, 1, 0xFFFFFFFF, 32)
    end

    if ((ready and player:spellSlot(3).state == 0) or not ready) and menu.caitlynmenu.Draw.r_dmg:get() then
        for i,obj in pairs(common.GetEnemyHeroes()) do
            if common.IsValidTarget(obj) then
                local damage, ad,ap,truedmg = damagelib.get_spell_damage('CaitlynR',3,player,obj,false,0)
                common.damageIndicatorUpdated(damage,obj)
            end
        end
    end

    if menu.caitlynmenu.Draw.farm:get() then
        -- graphics.draw_text_2D("KILLABLE: NO", 22, hpBar.x + 190, hpBar.y + 105, 0xFFEDCE34)
        local v = graphics.world_to_screen(player.pos)
        if menu.caitlynmenu.Misc.farm_key:get() then
            graphics.draw_text_2D("Farm: [ON]",16,v.x,v.y+100,0xFF44FF44)
        else
            graphics.draw_text_2D("Farm: [OFF]",16,v.x,v.y+100,0xFFFF4444)
        end
    end
end

cb.add(cb.draw,on_draw)