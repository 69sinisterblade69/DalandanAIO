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
    if lastTarget and common.IsValidTarget(lastTarget) and player.pos:dist(lastTarget.pos) < (range + lastTarget.boundingRadius) and not ts.selected then
        return lastTarget
    end
    local target = ts.get_result(ts_filter_basic).object
    if target then
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
    local count, heroes = common.CountEnemiesNearPos(pos, 450)
    if count >= 3 then
        safe = false
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

local function castE(pos)
    if orb.core.is_spell_locked() then return end
    if player:spellSlot(2).state ~= 0 then return end
    local dashPos = posAfterE(pos)
    if dashCheck(dashPos) then
        if pos.z ~= nil then
            player:castSpell("pos",2, vec3(pos.x, pos.y, pos.z))
        else
            player:castSpell("pos",2, vec3(pos.x, player.y, pos.y))
        end
    end
    -- orb.core.set_server_pause()
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
                    castQ(pred_seg.endPos, true, target)
                end
            end
        end

        -- E
        if menu.caitlynmenu.e.e_combo:get() then
            if target.pos:dist(player.pos) < e.range then
                local pred_seg = pred.linear.get_prediction(e,target)
                if pred_seg.endPos and pred_seg.endPos:dist(player.pos) < e.range and not pred.collision.get_prediction(e, pred_seg, target)  then
                    castE(pred_seg.endPos)
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

local function minionsHit(obj,pos,pred)
    -- assume no collision with minions
    local minions = objManager.minions["farm"]
    local minionSize = minions.size
    local count = 0
    if pos.z ~= nil then
        pos = vec(pos.x,pos.z)
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
            if minionsHit(obj,seg.endPos,q) >= count then
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
                    local hits = minionsHit(minion,minion.pos2D,q)
                    if hits > maxHits then
                        maxMinion = minion
                        maxHits = hits
                    end
                end
            end
            if maxHits >= count then
                local seg = pred.core.get_pos_after_time(maxMinion,q.delay)
                castQ(seg,false)
            end
        end
    end
end

local function lastHit()
    if menu.caitlynmenu.Misc.farm_key:get() and menu.caitlynmenu.q.q_lasthit:get() then
        local seg, obj = orb.farm.skill_farm_linear(q)    
        local delay = q.delay
        delay = delay + (player.pos2D:dist(seg.endPos)/q.speed)
        if seg and (string.find(string.lower(tostring(obj.charName)),"siege") or string.find(string.lower(tostring(obj.charName)),"super")) and orb.farm.predict_hp(obj,delay) < damagelib.get_spell_damage('caitlynQ',0,player,obj,false,0) then
            castQ(seg.endPos, false)
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
                                    castQ(pred_segQ.endPos, false, target)
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
                        castQ(pred_segQ.endPos, false)
                    end
                end
            end,delay)
        end
    end
end

cb.add(cb.spell, on_process_spell)

local function on_draw()
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
                local damage = damagelib.get_spell_damage('CaitlynR',3,player,obj,true,0)
                common.damageIndicatorUpdated(damage,obj)
            end
        end
    end

end

cb.add(cb.draw,on_draw)