local orb = module.internal("orb");
local ts = module.internal("TS");
local pred = module.internal("pred");
local damagelib = module.internal("damagelib");

local dalandanPred = module.load("Dalandan_AIO","prediction");
local common = module.load("Dalandan_AIO", "common");
local menu = module.load("Dalandan_AIO", "menu");
-- common.spellNames()

local q = {
    width = 140,
    speed = math.huge,
    delay = 0.528,
    boundingRadiusMod = 1, -- ????
    damage = function(m)
        return 40*player:spellSlot(0).level + 30 + 0.85 * common.GetTotalAP(player)
    end,
    range = 700,
    maxRange = 1450,
    collision = {
        wall = false,
        minion = false,
        hero = false, 
    },
}
local q_cast = 0
local q_range_factor = 1

local w = {
    -- delay = 0.25,
    delay = 0.78,
    range = 1000,
    radius = 275,
    radiusExtra = 125,
    boundingRadiusMod = 0, -- ????
    damage = function(m)
        return 35*player:spellSlot(1).level + 25 + 0.6 * common.GetTotalAP(player)
    end,
    damageExtra = function(m)
        return (35*player:spellSlot(1).level + 25 + 0.6 * common.GetTotalAP(player)) * 1.667
    end,
    speed = math.huge,
    collision = {
        wall = false,
        minion = false,
        hero = false, 
    },
}

local e = {
    delay = 0.25,
    range = 1125,
    width = 120,
    speed = 1400,
    boundingRadiusMod = 1, -- ????
    damage = function(m)
        return 30*player:spellSlot(2).level + 50 + 0.45 * common.GetTotalAP(player)
    end,
    collision = {
        wall = true,
        minion = true,
        hero = true, 
    },
}

local r = {
    delay = 0.627,
    range = 5000,
    radius = 170,
    speed = math.huge,
    stacks = 0,
    boundingRadiusMod = 1, -- ????

    collision = {
        wall = false,
        minion = false,
        hero = false, 
    },
    shots = function(a)
            -- xerathrshots   stacks2
            local obj = player
            local buff_keys = player.buff.keys
            for i = 1, buff_keys.n do
                local buff_key = buff_keys[i]
                local buff = player.buff[buff_key]
                if buff and buff.valid and buff.name == "xerathrshots" then
                    return buff.stacks2
                end
            end
            return 0
    end,
    maxShots = 3 + player:spellSlot(3).level
}

r.damage = function(m)
    return 50*player:spellSlot(3).level + 130 + 0.45 * common.GetTotalAP(player) + (r.stacks * (20 + player:spellSlot(3).level * 5) + 0.05 * common.GetTotalAP(player) )
end

local last_r_cast = 0 

-- must update in on_tick
local slow_pred_q = menu.xerathmenu.Combo.slow_pred_q:get()
local slow_pred_w = menu.xerathmenu.Combo.slow_pred_w:get()
-- local slow_pred_e = menu.xerathmenu.Combo.slow_pred_e:get()
local slow_pred_r = menu.xerathmenu.Combo.slow_pred_r:get()


local function trace_filter_w(seg, obj)
    if seg.startPos:dist(seg.endPos) > w.range then return false end

    if pred.trace.circular.hardlock(w, seg, obj) then
        return true
    end
    if pred.trace.circular.hardlockmove(w, seg, obj) then
        return true
    end

    if pred.trace.newpath(obj, 0.033, 0.500) then
        return true
    end
end

local function trace_filter_r(seg, obj)
    if seg.startPos:dist(seg.endPos) > r.range then return false end

    if pred.trace.circular.hardlock(r, seg, obj) then
        return true
    end
    if pred.trace.circular.hardlockmove(r, seg, obj) then
        return true
    end

    if pred.trace.newpath(obj, 0.033, 0.500) then
        return true
    end
end

local function trace_filter_q(seg, obj)
    if seg.startPos:dist(seg.endPos) > q.range then return false end

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

local function trace_filter_e(seg, obj)
    if seg.startPos:dist(seg.endPos) > e.range then return false end

    if pred.trace.linear.hardlock(e, seg, obj) then
        return true
    end
    if pred.trace.linear.hardlockmove(e, seg, obj) then
        return true
    end

    if pred.trace.newpath(obj, 0.1, 0.500) then
        return true
    end

end

local function ts_filter_q(res, object, dist)
    if object and common.IsValidTarget(object) and common.IsEnemyHero(object) then
        if (dist > q.range or object.buff["rocketgrab"]) then return end
        local seg = pred.linear.get_prediction(q, object)
        if not seg then return false end
        if seg.startPos:dist(seg.endPos) > q.range * 0.9 then return false end
        if slow_pred_q then
            if not trace_filter_q(seg, object) then return false end
        end
        res.pos = seg.endPos
        res.object = object
        return true
    end 
end

local function ts_filter_q_max(res, object, dist)
    if object and common.IsValidTarget(object) and common.IsEnemyHero(object) then
        if (dist > q.maxRange or object.buff["rocketgrab"] or common.IsSpellShielded(object)) then return end
        local seg = pred.linear.get_prediction(q, object)
        if not seg then return false end
        if seg.startPos:dist(seg.endPos) > q.maxRange * 0.9 then return false end
        res.pos = seg.endPos
        res.object = object
        return true
    end 
end

local function ts_filter_w(res, object, dist)
    if object and common.IsValidTarget(object) and common.IsEnemyHero(object) then
        if (dist > w.range or common.IsSpellShielded(object) or object.buff["rocketgrab"]) then return end
        local seg = pred.circular.get_prediction(w, object)
        if not seg then return false end
        if seg.startPos:dist(seg.endPos) > w.range then return false end
        if slow_pred_w then
            if not trace_filter_w(seg, object) then return false end
        end
        res.pos = seg.endPos
        res.object = object
        return true
    end 
end

local function ts_filter_e(res, object, dist)
    if object and common.IsValidTarget(object) and common.IsEnemyHero(object) then
        if (dist > e.range or object.buff["rocketgrab"] or common.IsSpellShielded(object)) then return end
        local seg = pred.linear.get_prediction(e, object)
        if not seg then return false end
        if seg.startPos:dist(seg.endPos) > e.range * 0.9 then return false end
        if not trace_filter_e(seg, object) then return false end
        res.pos = seg.endPos
        res.object = object
        return true
    end 
end

local function ts_filter_e_gap(res, object, dist)
    if object and common.IsValidTarget(object) and common.IsEnemyHero(object) and object.path.isActive and object.path.isDashing then
        if (dist > e.range or object.buff["rocketgrab"] or common.IsSpellShielded(object)) then return end
        res.object = object
        return true
    end 
end

local function ts_filter_r(res, object, dist)
    if object and common.IsValidTarget(object) and common.IsEnemyHero(object) then
        if (dist > r.range or object.buff["rocketgrab"]) then return end
        if (menu.xerathmenu.Combo.r_size:get() < game.mousePos:dist(object.pos)) then return end
        
        if menu.xerathmenu.Combo.r_prediction:get() == 1 then
            -- OLD PRED 
            local seg = pred.circular.get_prediction(r, object)
            if not seg then return false end
            if seg.startPos:dist(seg.endPos) > r.range then return false end
            if slow_pred_r then
                if not trace_filter_r(seg, object) then return false end
            end
            res.pos = seg.endPos
        else
            -- NEW PRED
            local pos,hitchance = dalandanPred.getPredPos(object,r.delay,r)
            if not pos then return false end
            res.pos = vec2(pos.x, pos.z)
        end
        res.object = object
        return true
    end 
end

local function combo()
    if menu.xerathmenu.Combo.q_combo:get() then
        if not player:spellSlot(0).state~=0 and player:spellSlot(0).isCharging then
            local resQ = ts.get_result(ts_filter_q)
            if resQ.pos then
                if not orb.core.is_spell_locked()then
                    player:castSpell('release', 0, vec3(resQ.pos.x, mousePos.y, resQ.pos.y))
                end
            end
        elseif not player:spellSlot(0).state~=0 then
            local resQ = ts.get_result(ts_filter_q_max)
            if resQ.pos then
                if not orb.core.is_spell_locked() then
                    player:castSpell('line', 0, player.pos, mousePos)
                end
            end
        end
    end
    if menu.xerathmenu.Combo.w_combo:get() then
        if not player:spellSlot(1).state~=0 then
            local resW = ts.get_result(ts_filter_w)
            if resW.pos then
                if not orb.core.is_spell_locked() then
                    player:castSpell('pos', 1, vec3(resW.pos.x, mousePos.y, resW.pos.y))
                end
            end
        end
    end
    if menu.xerathmenu.Combo.e_combo:get() then
        if not player:spellSlot(2).state~=0 then
            local resE = ts.get_result(ts_filter_e)
            if resE.pos then
                local pred_pos = resE.pos
                local seg = {}
                seg.startPos = player.path.serverPos2D
				seg.endPos = vec2(pred_pos.x, pred_pos.y)
                local dupa = pred.linear.get_prediction(e, resE.object)
				if not pred.collision.get_prediction(e, dupa, resE.object) then
                    if not orb.core.is_spell_locked() then
                        player:castSpell('pos', 2, vec3(resE.pos.x, mousePos.y, resE.pos.y))
                    end
                end
            end
        end
    end
end

local function killsteal()
    if menu.xerathmenu.Misc.q_ks:get() then
        if not player:spellSlot(0).state~=0 and player:spellSlot(0).isCharging then
            local resQ = ts.get_result(ts_filter_q)
            -- if resQ.pos and resQ.object.health <= q.damage() * common.MagicReduction(resQ.object, player) then
            if resQ.pos and resQ.object.health <= damagelib.get_spell_damage('XerathArcanopulseChargeUp', 0, player, resQ.object, false, 0) then    
                if not orb.core.is_spell_locked()then
                    player:castSpell('release', 0, vec3(resQ.pos.x, mousePos.y, resQ.pos.y))
                end
            end
        elseif not player:spellSlot(0).state~=0 then
            local resQ = ts.get_result(ts_filter_q_max)
            if resQ.pos and resQ.object.health <= damagelib.get_spell_damage('XerathArcanopulseChargeUp', 0, player, resQ.object, false, 0) then
                if not orb.core.is_spell_locked() then
                    player:castSpell('line', 0, player.pos, mousePos)
                end
            end
        end
    end
    if menu.xerathmenu.Misc.w_ks:get() then
        if not player:spellSlot(1).state~=0 then
            local resW = ts.get_result(ts_filter_w)
            if resW.pos and resW.object.health <= damagelib.get_spell_damage('XerathArcaneBarrage2', 1, player, resW.object, false, 0) then
                if not orb.core.is_spell_locked() then
                    player:castSpell('pos', 1, vec3(resW.pos.x, mousePos.y, resW.pos.y))
                end
            end
        end
    end
end

local function laneClear()
    if menu.xerathmenu.Misc.farm_key:get() then
        if menu.xerathmenu.Lane.q_lane:get() then
            local minion_hits = 0
            local max_hits = 0
            local max_minion = {}
            local req_range = 0
            for i=0, objManager.minions.size[TEAM_ENEMY]-1 do
                local obj = objManager.minions[TEAM_ENEMY][i]
                if obj.pos:dist(player.pos) <= q.maxRange and obj.type == TYPE_MINION and not obj.isDead and obj.health and obj.health > 0 and obj.isVisible then
                    minion_hits = 0
                    for j=0, objManager.minions.size[TEAM_ENEMY]-1 do
                        local obj2 = objManager.minions[TEAM_ENEMY][j]
                        if obj2.pos:dist(player.pos) <= q.maxRange and obj2.type == TYPE_MINION and not obj2.isDead and obj2.health and obj2.health > 0 and obj2.isVisible and obj2.isTargetable then
                            local p = mathf.closest_vec_line(obj2.pos2D, player.pos2D, obj.pos2D)
                            local res = obj2.pos2D:dist(p)
                            if res <= q.width + obj2.boundingRadius then
                                minion_hits = minion_hits + 1
                            end
                        end
                    end
                    if max_hits <= minion_hits then
                        max_hits = minion_hits
                        max_minion = obj
                    end
                end
            end
            if max_minion then
                -- chat.print(max_hits)
                if not player:spellSlot(0).state~=0 and player:spellSlot(0).isCharging and max_minion.pos:dist(player.pos) <= q.range then
                    if not orb.core.is_spell_locked() then
                        player:castSpell('release', 0, vec3(max_minion.pos.x, mousePos.y, max_minion.pos.z))
                    end
                elseif not player:spellSlot(0).state~=0 and not orb.core.is_spell_locked() and max_hits >= menu.xerathmenu.Lane.q_lane_minion:get() then
                    player:castSpell('line', 0, player.pos, mousePos)
                end
            end
        end
        if menu.xerathmenu.Lane.w_lane:get() then
            local minion_hits = 0
            local max_hits = 0
            local max_minion = {}
            local minions = {}
            for i=0, objManager.minions.size[TEAM_ENEMY]-1 do
                minions[i] = objManager.minions[TEAM_ENEMY][i]
            end
            for i=0, objManager.minions.size[TEAM_ENEMY]-1 do
                local obj = objManager.minions[TEAM_ENEMY][i]
                if obj.pos:dist(player.pos) <= w.range + w.radius/2 and obj.type == TYPE_MINION and not obj.isDead and obj.health and obj.health > 0 and obj.isVisible then
                    minion_hits = 0
                    for j=0, objManager.minions.size[TEAM_ENEMY]-1 do
                        local obj2 = objManager.minions[TEAM_ENEMY][j]
                        if obj2.pos:dist(player.pos) <= w.range + w.radius/2 and obj2.type == TYPE_MINION and not obj2.isDead and obj2.health and obj2.health > 0 and obj2.isVisible and obj2.isTargetable then
                            minion_hits = common.CountMinionsNearPos(obj2.pos,w.radius,minions,TEAM_ENEMY)
                        end
                    end
                    if max_hits <= minion_hits then
                        max_hits = minion_hits
                        max_minion = obj
                    end
                end
            end
            if max_minion and max_hits >= 3 then
                if not orb.core.is_spell_locked() then
                    player:castSpell('pos', 1, vec3(max_minion.pos.x, mousePos.y, max_minion.pos.z))
                end
            end
        end
    end
end

local function q_range()
    if q_cast ~= 0 then
        q.range = 700
        if os.clock() >= q_cast + 1.75 then
            q.range = 1450
            q.range = q.range * q_range_factor
            return
        end
        if os.clock() >= q_cast + 1.5 then
            q.range = 1342.86
            q.range = q.range * q_range_factor
            return
        end
        if os.clock() >= q_cast + 1.25 then
            q.range = 1235.71
            q.range = q.range * q_range_factor
            return
        end
        if os.clock() >= q_cast + 1 then
            q.range = 1128.57
            q.range = q.range * q_range_factor
            return
        end
        if os.clock() >= q_cast + 0.75 then
            q.range = 1021.43
            q.range = q.range * q_range_factor
            return
        end
        if os.clock() >= q_cast + 0.5 then
            q.range = 914.29
            q.range = q.range * q_range_factor
            return
        end
        if os.clock() >= q_cast + 0.25 then
            q.range = 807.14
            q.range = q.range * q_range_factor
            return
        end
        if os.clock() >= q_cast then
            q.range = 700
            q.range = q.range * q_range_factor
            return
        end
    end
end

local function gapClose()
    if menu.xerathmenu.Misc.e_gap:get() then
        local seg = {}
		local target = ts.get_result(ts_filter_e_gap).object
		if target then
			-- local pred_pos = pred.core.lerp(target.path, network.latency + e.delay, target.path.dashSpeed)
            local pred_seg = pred.linear.get_prediction(e, target, player)
			if pred_seg and pred_seg.endPos:dist(player.path.serverPos2D) <= e.range then
				seg.startPos = player.path.serverPos2D
				-- seg.endPos = vec2(pred_pos.x, pred_pos.y)
                seg.endPos = pred_seg.endPos
				if not pred.collision.get_prediction(e, seg, target.pos:to2D()) then
					player:castSpell("pos", 2, vec3(seg.endPos.x, target.y, seg.endPos.y))
				end
			end
		end    
    end
end


local function interrupt(spell)
    if menu.xerathmenu.Misc.e_int:get() then
        if spell then
            if common.IsEnemyHero(spell.owner) and not spell.isBasicAttack then
                -- print(spell.owner.charName,spell.name, spell.windUpTime, spell.clientWindUpTime, spell.animationTime, spell.owner:spellSlot(spell.slot).startTimeForCurrentCast)
                -- print(spell.owner.charName,spell.name, spell.animationTime, )
            end
        end
    end
end

local function auto_r()
    local desiredDelay = menu.xerathmenu.Combo.r_delay:get() / 1000
    if menu.xerathmenu.Combo.r_fast:get() then desiredDelay = 0 end

    if menu.xerathmenu.Combo.r_use:get() then
        if r.shots() ~= 0 then
            orb.core.set_server_pause()
            local resR = ts.get_result(ts_filter_r)
            if resR.pos then
                if not orb.core.is_spell_locked() and os.clock() > last_r_cast + desiredDelay then
                    player:castSpell('pos', 3, vec3(resR.pos.x, mousePos.y, resR.pos.y))
                    last_r_cast = os.clock()
                end
            end
        end
    end
end


local function on_tick()
    -- chat.print(r.shots().." "..r.maxShots)
    slow_pred_q = menu.xerathmenu.Combo.slow_pred_q:get()
    slow_pred_w = menu.xerathmenu.Combo.slow_pred_w:get()
    -- slow_pred_e = menu.xerathmenu.Combo.slow_pred_e:get()
    slow_pred_r = menu.xerathmenu.Combo.slow_pred_r:get()
    auto_r()
    gapClose()
    q_range()
    killsteal()
    if orb.combat.is_active() then
        combo()
    end 
    if orb.menu.lane_clear.key:get() then
        laneClear()
    end
    if menu.xerathmenu.Misc.aa_key:get() then
        
    else
        orb.core.set_pause_attack(0.5)
    end
    
end

local function on_draw()
    local drawq = menu.xerathmenu.Draw.q_draw:get()
    local draww = menu.xerathmenu.Draw.w_draw:get()
    local drawe = menu.xerathmenu.Draw.e_draw:get()
    local drawr = menu.xerathmenu.Draw.r_draw:get()
    local ready = menu.xerathmenu.Draw.ready:get()
    if ((ready and player:spellSlot(0).state == 0) or not ready) and drawq then
        graphics.draw_circle(player.pos, q.range, 2, graphics.argb(255, 0, 255, 0), 100)
        graphics.draw_circle(player.pos, q.maxRange, 2, graphics.argb(255, 0, 255, 0), 100)
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
        if r.shots() ~= 0 and menu.xerathmenu.Combo.r_use:get() then
            local v1 = vec3(game.mousePos.x,game.mousePos.y,game.mousePos.z)
            graphics.draw_circle(v1, menu.xerathmenu.Combo.r_size:get(), 1, graphics.argb(200, 255, 255, 255), 100)
        end
    end
    if menu.xerathmenu.Draw.dmg_draw:get() then
        
        local r_shots = 0
        if r.shots() ~= 0 then
            r_shots = r.shots()
        else
            r_shots = r.maxShots
        end
        -- chat.print(r_shots)
        for i,obj in pairs(common.GetEnemyHeroes()) do
            local damage = 0
            local killable = false
            local kill_shots = 0
            local showR = false
            if (player.pos:dist(obj.pos) > q.maxRange * 1.5) or r.shots() ~= 0 then
                showR = true
            end
            if not showR then
                if menu.xerathmenu.Draw.dmg_draw_ready:get() then
                    if menu.xerathmenu.Draw.q_draw_dmg:get() and player:spellSlot(0).state == 0 then
                        damage = damage + damagelib.get_spell_damage('XerathArcanopulseChargeUp', 0, player, obj, false, 0)
                    end
                    if menu.xerathmenu.Draw.w_draw_dmg:get() and player:spellSlot(1).state == 0 then
                        damage = damage + damagelib.get_spell_damage('XerathArcaneBarrage2', 1, player, obj, false, 0)
                    end
                    if menu.xerathmenu.Draw.e_draw_dmg:get() and player:spellSlot(2).state == 0 then
                        damage = damage + damagelib.get_spell_damage('XerathMageSpear', 2, player, obj, false, 0)
                    end
                else
                    if menu.xerathmenu.Draw.q_draw_dmg:get() then
                        damage = damage + damagelib.get_spell_damage('XerathArcanopulseChargeUp', 0, player, obj, false, 0)
                    end
                    if menu.xerathmenu.Draw.w_draw_dmg:get() then
                        damage = damage + damagelib.get_spell_damage('XerathArcaneBarrage2', 1, player, obj, false, 0)
                    end
                    if menu.xerathmenu.Draw.e_draw_dmg:get() then
                        damage = damage + damagelib.get_spell_damage('XerathMageSpear', 2, player, obj, false, 0)
                    end
                end
                common.damageIndicatorUpdated(damage, obj)
            else
                local killShots = 0
                for j=1, r_shots do 
                    damage = math.max(damagelib.get_spell_damage('XerathLocusOfPower2', 3, player, obj, false, 0) * j, damagelib.get_spell_damage('XerathRMissileWrapper', 3, player, obj, false, 0) * j)
                    if player.buff["xerathrrampup"] then
                        damage = damage + (player.buff["xerathrrampup"].stacks2 * (20 + player:spellSlot(3).level * 5) + 0.05 * common.GetTotalAP(player))
                    end
                    
                    if damage > obj.health then
                        killShots = j
                        break
                    end
                end
                if killShots ~= 0 and player:spellSlot(3).level ~= 0 then
                    common.damageIndicatorUpdated(damage, obj,100000,0,"Killable in "..killShots.." shots")
                else
                    common.damageIndicatorUpdated(damage, obj,100000,0,"In "..r_shots.." shots")
                end
            end
        end
    end
    if menu.xerathmenu.Misc.farm_key:get() then
        graphics.draw_text_2D("Farm: [ON]",16,graphics.width/2,graphics.height/2+100,0xFF44FF44)
    else
        graphics.draw_text_2D("Farm: [OFF]",16,graphics.width/2,graphics.height/2+100,0xFFFF4444)
    end
    if menu.xerathmenu.Misc.aa_key:get() then
        -- graphics.draw_text_2D("AA: [ON]",16,graphics.width/2,graphics.height/2+120,0xFF44FF44)
    else
        graphics.draw_text_2D("AA Disabled",16,graphics.width/2,graphics.height/2+120,0xFFFF4444)
    end

    -- debug shit
    -- for i=0, objManager.enemies_n-1 do
    --     local hero = objManager.enemies[i]
    --     local predPos = pred.core.get_pos_after_time(hero, r.delay):toGame3D()
    --     graphics.draw_circle(predPos, 20, 2, graphics.argb(255, 0, 255, 0), 10)
    --     predPos = pred.circular.get_prediction(r, hero).endPos
    --     if predPos then
    --         graphics.draw_circle(predPos:toGame3D(), 10, 2, graphics.argb(255, 255, 0, 0), 10)
    --     end
    --     graphics.draw_circle(prediction.getPredPos(hero,r.delay,r), 10, 2, graphics.argb(255, 0, 0, 255), 10)

    --     --instant - get_source_pos = serverPos maybe
    --     -- graphics.draw_circle(hero.pos, 20, 2, graphics.argb(255, 0, 255, 0), 10)
    --     -- graphics.draw_circle(pred.present.get_source_pos(hero):toGame3D(), 15, 2, graphics.argb(255, 255, 0, 0), 10)
    --     -- if hero.path.isActive then
    --     --     graphics.draw_circle(hero.path.serverPos, 20, 2, graphics.argb(255, 0, 0, 255), 10)
    --     -- end
        
    -- end
end

cb.add(cb.tick,on_tick)

local function on_process_spell(spell)
    if spell.owner == player then
        -- print(spell.name)
    end
    interrupt(spell)
    if spell.owner == player and spell.name == "XerathArcanopulseChargeUp" then
        q_cast = os.clock() -0.25
    end
    if spell.owner == player and spell.name == "XerathArcanopulse2" then
        q.range = 700
        q_cast = 0
    end
end


cb.add(cb.spell, on_process_spell)

-- TODO: COLORS
cb.add(cb.draw,on_draw)

chat.print('[Dalandan AIO] Loading Xerath successful!')