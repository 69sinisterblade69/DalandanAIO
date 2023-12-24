local orb = module.internal("orb");
local ts = module.internal("TS");
local pred = module.internal("pred");
local damagelib = module.internal("damagelib");

local common = module.load("Dalandan_AIO", "common");
local menu = module.load("Dalandan_AIO", "menu");

local LethalTempoHash = game.fnvhash("ASSETS/Perks/Styles/Precision/LethalTempo/LethalTempo.lua") 

local q = {    
    delay = 0.9,
    range = function(target)
        local range = 0
        if target then
            range = 525 + player.boundingRadius + target.boundingRadius 
        else 
            range = 525 + player.boundingRadius
        end
        local LethalTempo = player:findBuff(LethalTempoHash)
        if LethalTempo and LethalTempo.stacks2 >= 6 then
            range = range+50
        end
        return range
    end,
    range2 = function(target)
        local range = 0
        if target then
            range = 525 + player.boundingRadius + 50 + (30 * player:spellSlot(0).level) + target.boundingRadius 
        else
            range = 525 + player.boundingRadius + 50 + (30 * player:spellSlot(0).level) 
        end
        local LethalTempo = player:findBuff(LethalTempoHash)
        if LethalTempo and LethalTempo.stacks2 >= 6 then
            range = range+50
        end
        return range
    end,
    radius = 250,
}

local w = {
    delay = 0.6,
    range = 1440,
    width = 60,
    speed = 3300,
    boundingRadiusMod = 1,
    damage = function(target)
        local damage,ad,ap,truedmg = damagelib.get_spell_damage('JinxW',1,player,target,false,0)
        return damage
    end,
    collision = {
        wall = true,
        minion = true,
        hero = false,
    },
}

local e = {
    delay = 0 + 0.4 + 0.5, -- cast + landing + arming
    range = 925,
    radius = 115,
    speed = math.huge,
    boundingRadiusMod = 0,
    collision = {
        wall = true,
        minion = false,
    },
}

local r = {
    delay = 0.6,
    range = 2000,
    width = 140,
    speed = 1700,
    boundingRadiusMod = 1,
    damage = function(target)
        local damage,ad,ap,truedmg = damagelib.get_spell_damage('JinxR',3,player,target,false,0)
        return damage
    end,
    collision = {
        wall = true,
        minion = false,
        hero = true,
    },
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

local function castQ()
    if orb.core.is_spell_locked() then return end
    if player:spellSlot(0).state ~= 0 then return end

    player:castSpell("self",0)
end

local function trace_filter_w(seg, obj)
    if pred.trace.linear.hardlock(w, seg, obj) then
        return true
    end
    if pred.trace.linear.hardlockmove(w, seg, obj) then
        return true
    end
    if pred.trace.newpath(obj, 0.033, 0.500) then
        return true
    end
end

local function trace_filter_r(seg, obj)
    if pred.trace.linear.hardlock(r, seg, obj) then
        return true
    end
    if pred.trace.linear.hardlockmove(r, seg, obj) then
        return true
    end
    if pred.trace.newpath(obj, 0.033, 0.500) then
        return true
    end
end

local function trace_filter_e(seg, obj)
    if pred.trace.circular.hardlock(e, seg, obj) then
        return true
    end
    if pred.trace.circular.hardlockmove(e, seg, obj) then
        return true
    end
    if pred.trace.newpath(obj, 0.033, 0.500) then
        return true
    end
end


local function castW(pos)
    if orb.core.is_spell_locked() then return end
    if player:spellSlot(1).state ~= 0 then return end

    if menu.jinxmenu.w.block.w_near:get() then
        local count, heroes = common.CountEnemiesNearPos(player.pos, menu.jinxmenu.w.block.w_near_range:get())
        if count >= menu.jinxmenu.w.block.w_near_count:get() then
            return
        end
    end

    if pos.z ~= nil then
        player:castSpell("pos",1, vec3(pos.x, pos.y, pos.z))
    else
        player:castSpell("pos",1, vec3(pos.x, player.y, pos.y))
    end
    orb.core.set_server_pause()
end

local function castE(pos)
    if orb.core.is_spell_locked() then return end
    if player:spellSlot(2).state ~= 0 then return end

    if pos.z ~= nil then
        player:castSpell("pos",2, vec3(pos.x, pos.y, pos.z))
    else
        player:castSpell("pos",2, vec3(pos.x, player.y, pos.y))
    end
end

local function castR(pos)
    if orb.core.is_spell_locked() then return end
    if player:spellSlot(3).state ~= 0 then return end

    if menu.jinxmenu.r.r_near:get() then
        local count, heroes = common.CountEnemiesNearPos(player.pos, menu.jinxmenu.r.r_near_range:get())
        if count >= menu.jinxmenu.r.r_near_count:get() then
            return
        end
    end

    if pos.z ~= nil then
        player:castSpell("pos",3, vec3(pos.x, pos.y, pos.z))
    else
        player:castSpell("pos",3, vec3(pos.x, player.y, pos.y))
    end
    orb.core.set_server_pause()
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

local JinxQHash = game.fnvhash("JinxQ")

local function combo()
    local target = getTarget(w.range+100)
    if target then
        -- Q
        local QBuff = player:findBuff(JinxQHash)
        if menu.jinxmenu.q.q_combo:get() then
            local QFutureState = player.pos:dist(target.pos) > q.range() -- true = rockets, false = minigun
            
            if menu.jinxmenu.q.q_combo_aoe:get() then
                if player.pos:dist(target.pos) < q.range2(target) and target.pos:countEnemies(q.radius+target.boundingRadius) >= 2 then
                    QFutureState = true
                end
            end

            -- :skull:
            -- done this way cuz its boolean and buff.obj
            if not QFutureState ~= not QBuff then
                castQ()
            end
        end
        
        -- W
        if menu.jinxmenu.w.w_combo:get() then
            
            -- checks
            local check = true

            if menu.jinxmenu.w.block.w_aa:get() then
                if player.pos:dist(target.pos) < common.GetAARange(target) then
                    check = false
                end
            end

            if menu.jinxmenu.w.block.w_dps:get() then
                local wDmg,ad,ap,truedmg = damagelib.get_spell_damage('JinxW', 0, player, target, false, 0)
                local aaDmg = 0
                local howManyAA = 0
                local wDelay = w.delay
                while wDelay > 0 do
                    howManyAA = howManyAA + 1
                    wDelay = wDelay - player:attackDelay()
                end
                aaDmg = damagelib.calc_aa_damage(player,target,true) * howManyAA
                if player.pos:dist(target.pos) < common.GetAARange(target) and aaDmg > wDmg then
                    check = false
                end
            end


            local pred_seg = pred.linear.get_prediction(w, target)
            if pred_seg and pred_seg.endPos:dist(player.path.serverPos2D) <= w.range then
                -- collision
                if pred.collision.get_prediction(w,pred_seg,target) then
                    check = false
                end
                if ((menu.jinxmenu.w.w_slow_pred:get() and trace_filter_w(pred_seg,target)) or not menu.jinxmenu.w.w_slow_pred:get()) and check then
                    castW(pred_seg.endPos)
                end
            end
        end

        -- E
        if menu.jinxmenu.e.combo.e_combo:get() then
            local pred_seg = pred.circular.get_prediction(e,target,player)
            if pred_seg.endPos:dist(player.pos) < e.range then
                
                --melee range
                if menu.jinxmenu.e.combo.e_melee:get() then
                    if player.pos:dist(target.pos) < 300 then
                        castE(pred_seg.endPos,target)
                    end
                end
    
                -- hard cc
                if menu.jinxmenu.e.combo.e_stun:get() then
                    if hard_cc(e,pred_seg,target,"circular") then
                        castE(pred_seg.endPos,target)
                    end
                end
                
                -- slow
                if menu.jinxmenu.e.combo.e_slow:get() then
                    if target.buff[BUFF_SLOW] then
                        castE(pred_seg.endPos,target)
                    end
                end
            end
        end
    end
end

local function laneClear()
    if menu.jinxmenu.q.q_laneclear:get() then
        local QFutureState = false -- true = rockets, false = minigun
        local QBuff = player:findBuff(JinxQHash)
                
        if menu.jinxmenu.q.q_laneclear_heroes_orb:get() and not orb.farm.lane_clear_wait() then
            local hTarget = getTarget(q.range2()+60)
            if hTarget then
                local count, minions = common.CountMinionsNearPos2(hTarget.pos, q.radius+50)
                if count >= 1 then
                    local closest = nil
                    local cDist = math.huge
                    for i, minion in pairs(minions) do
                        if common.IsValidTarget(minion) then
                            local trueDelay = network.latency + orb.utility.get_hit_time(player, minion) + orb.utility.get_wind_up_time(player)
                            local tDist = pred.core.get_pos_after_time(minion,trueDelay):dist(pred.core.get_pos_after_time(hTarget,trueDelay))
                            if tDist < q.radius then
                                local hp = orb.farm.predict_hp(minion, trueDelay)
                                local dmg = damagelib.calc_aa_damage(player,minion,true)
                                if hp+10 < dmg or hp > dmg*2.1 then -- values taken straight out of my ass, but they seem to improve it 
                                    if tDist < cDist then
                                        cDist = tDist
                                        closest = minion
                                    end
                                end
                            end
                        end
                    end
                    if closest then
                    orb.farm.set_clear_target(closest)
                    QFutureState = true
                    end
                end
            end
        end

        local target = orb.farm.get_clear_target()
        if target and not orb.farm.lane_clear_wait() then
            if menu.jinxmenu.q.q_laneclear_minion:get() then
                if target.pos:countEnemyLaneMinions(q.radius) >= menu.jinxmenu.q.q_laneclear_count:get() and (player.mana/player.maxMana >= menu.jinxmenu.q.q_laneclear_mana:get()/100) then
                    QFutureState = true
                end
            end
            if menu.jinxmenu.q.q_laneclear_heroes:get() then
                if target.pos:countEnemies(q.radius) >= 1 and (player.mana/player.maxMana >= menu.jinxmenu.q.q_laneclear_heroes_mana:get()/100) then
                    QFutureState = true
                end
            end
        end

        
        -- :skull:
        -- done this way cuz its boolean and buff.obj
        if not QFutureState ~= not QBuff then
            castQ()
        end
    end
end

local function jungleClear()
    local issueTarget = orb.farm.get_clear_target()
    if issueTarget ~= nil and common.IsValidTarget(issueTarget) and issueTarget.team == TEAM_NEUTRAL and not string.find(string.lower(tostring(issueTarget.charName)),"plant") then
        local pred_seg = pred.linear.get_prediction(w, issueTarget, player)
        if pred_seg and pred_seg.endPos:dist(player.pos) <= w.range then
            castW(pred_seg.endPos)
        end
    end
end

local function harass()
    if menu.jinxmenu.q.q_harass:get() then
        local QFutureState = false -- true = rockets, false = minigun
        local QBuff = player:findBuff(JinxQHash)
        local target = orb.farm.get_clear_target()
        local hTarget = getTarget(q.range2())
        if target and not orb.farm.lane_clear_wait() then
            if target.pos:countEnemies(q.radius) >= 1 then
                QFutureState = true
            end
        end
        if hTarget then
            QFutureState = true
        end

        -- :skull:
        -- done this way cuz its boolean and buff.obj
        if not QFutureState ~= not QBuff then
            castQ()
        end
    end

    if menu.jinxmenu.w.w_harass:get() then
        local hTarget = getTarget(w.range)
        if hTarget and not orb.farm.lane_clear_wait() then
            local pred_seg = pred.linear.get_prediction(w, hTarget)
            if pred_seg and pred_seg.endPos:dist(player.path.serverPos2D) <= w.range then
                if ((menu.jinxmenu.w.w_slow_pred:get() and trace_filter_w(pred_seg, hTarget)) or not menu.jinxmenu.w.w_slow_pred:get()) and not pred.collision.get_prediction(w, pred_seg, hTarget) then
                    castW(pred_seg.endPos)
                end
            end 
        end
    end
end

local function autoE()
    if menu.jinxmenu.e.auto.e_auto:get() then
        local heroes = objManager.enemies
        local hn = objManager.enemies_n
        for i=0, hn-1 do
            local target = heroes[i]
            if target and common.IsValidTarget(target) then
                local pred_seg = pred.circular.get_prediction(e,target,player)
                if pred_seg.endPos:dist(player.pos) < e.range then
                    
                    --melee range
                    if menu.jinxmenu.e.auto.e_melee:get() then
                        if player.pos:dist(target.pos) < 300 then
                            castE(pred_seg.endPos,target)
                        end
                    end
    
                    -- hard cc
                    if menu.jinxmenu.e.auto.e_stun:get() then
                        if hard_cc(e,pred_seg,target,"circular") then
                            castE(pred_seg.endPos,target)
                        end
                    end
                    
                    -- slow
                    if menu.jinxmenu.e.auto.e_slow:get() then
                        if target.buff[BUFF_SLOW] then
                            castE(pred_seg.endPos,target)
                        end
                    end
                end
            end
        end
    end
end

local function antiGapClose()
    if menu.jinxmenu.e.e_antigapcloser:get() then
        local seg = {}
        local heroes = objManager.enemies
        local hn = objManager.enemies_n
        for i=0, hn-1 do
            local target = heroes[i]
            if target and common.IsValidTarget(target) and target.path.isActive and target.path.isDashing and (target.path.serverPos2D:dist(player.pos2D) > target.path.endPos2D:dist(player.pos2D)) then
                local pred_seg = pred.circular.get_prediction(e, target, player)
                if pred_seg and pred_seg.endPos:dist(player.path.serverPos2D) <= e.range then
                    seg.startPos = player.path.serverPos2D
                    seg.endPos = pred_seg.endPos
                    castE(seg.endPos)
                end
            end    
        end
    end
end

local function ks()
    local heroes = objManager.enemies
    local hn = objManager.enemies_n
    for i = 0, hn - 1 do
        local target = heroes[i]
        if target and common.IsValidTarget(target) then
            if menu.jinxmenu.w.w_ks:get() then
                if target.health < w.damage(target) then
                    local pred_seg = pred.linear.get_prediction(w, target)
                    if pred_seg and pred_seg.endPos:dist(player.path.serverPos2D) <= w.range then
                        if ((menu.jinxmenu.w.w_slow_pred:get() and trace_filter_w(pred_seg, target)) or not menu.jinxmenu.w.w_slow_pred:get()) and not pred.collision.get_prediction(w, pred_seg, target) then
                            castW(pred_seg.endPos)
                        end
                    end
                end
            end
            if menu.jinxmenu.r.r_ks:get() then
                if target.health < r.damage(target) then
                    local dis = target.pos:dist(player.pos)
                    if dis < menu.jinxmenu.r.r_max:get() and ((menu.jinxmenu.r.r_aa:get() and dis > common.GetAARange(target)) or not menu.jinxmenu.r.r_aa:get()) then -- and menu.jinxmenu.r.r_min:get()
                        local pred_seg = pred.linear.get_prediction(r, target)
                        if pred_seg then
                            if trace_filter_r(pred_seg, target) and not pred.collision.get_prediction(r, pred_seg, target) then
                                castR(pred_seg.endPos)
                            end
                        end
                    end
                end
            end
        end
    end
end


local function semiR()
    if menu.jinxmenu.r.r_semi:get() then
        local target = nil
        local dist = math.huge
        local heroes = objManager.enemies
        local hn = objManager.enemies_n
        for i=0, hn-1 do
            local obj = heroes[i]
            local newDist = obj.pos:dist(mousePos)
            if newDist < dist and common.IsValidTarget(obj) then
                dist = newDist
                target = obj
            end
        end
        if target then
            local pred_seg = pred.linear.get_prediction(r, target)
            if pred_seg then
                -- collision
                if pred.collision.get_prediction(r,pred_seg,target) then
                    return
                end
                castR(pred_seg.endPos)
            end
        end
    end
end

local function wDelay()
    w.delay = math.max(0.4, 0.6 - (common.GetBonusAS() - 100) / 25 * (0.02))
end

local function on_tick()
    wDelay()
    ks()
    semiR()
    antiGapClose()
    if orb.combat.is_active() then
        combo()
    else
        autoE()
    end 
    if orb.menu.lane_clear.key:get() then
        laneClear()
        jungleClear()
    end
    if orb.menu.hybrid.key:get() then
        harass()
    end
end

cb.add(cb.tick,on_tick)

local function on_draw()
    if game.shopOpen then
        return
    end

    local drawq = menu.jinxmenu.Draw.q_draw:get()
    local draww = menu.jinxmenu.Draw.w_draw:get()
    local drawe = menu.jinxmenu.Draw.e_draw:get()
    local drawr = menu.jinxmenu.Draw.r_draw:get()
    local drawrdmg = menu.jinxmenu.Draw.r_dmg:get()
    local ready = menu.jinxmenu.Draw.ready:get()

    if drawq then
        graphics.draw_circle(player.pos, q.range2(), 2, graphics.argb(255, 0, 0, 255), 100)
        graphics.draw_circle(player.pos, q.range(), 2, graphics.argb(255, 0, 255, 0), 100)
    end
    if ((ready and player:spellSlot(1).state == 0) or not ready) and draww then
        graphics.draw_circle(player.pos, w.range, 2, graphics.argb(255, 0, 255, 0), 100)
    end
    if ((ready and player:spellSlot(2).state == 0) or not ready) and drawe then
        graphics.draw_circle(player.pos, e.range, 2, graphics.argb(255, 0, 255, 0), 100)
    end
    if ((ready and player:spellSlot(3).state == 0) or not ready) and drawr then
        graphics.draw_circle(player.pos, menu.jinxmenu.r.r_max:get(), 2, graphics.argb(255, 0, 255, 0), 100)
    end
    if drawrdmg then
        local heroes = objManager.enemies
        local hn = objManager.enemies_n
        for i=0, hn-1 do
            local target = heroes[i]
            if common.IsValidTarget(target) then
                common.damageIndicatorUpdated(r.damage(target),target)
            end
        end
    end

end

cb.add(cb.draw,on_draw)