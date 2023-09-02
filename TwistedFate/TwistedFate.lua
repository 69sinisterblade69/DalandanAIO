local orb = module.internal("orb");
local ts = module.internal("TS");
local pred = module.internal("pred");

local common = module.load("Dalandan_AIO", "common");
local menu = module.load("Dalandan_AIO", "menu");

local q = {
    delay = 0.25,
    speed = 100,
    width = 40,
    range = 1450,
    boundingRadiusMod = 0,
    damage = function(m)
        return 20*player:spellSlot(0).level + 50 + 0.9 * common.GetTotalAP(player)
    end,
    collision = {
        wall = true,
        hero = false,
    },
}
q.range = 1250
-- w names: PickACard GoldCardLock BlueCardLock RedCardLock

local r = {
    range = 5500,
}
local used_r = 0
local used_r_time = 0
local jungle_w = false

local function trace_filter(seg, obj)
    if seg.startPos:dist(seg.endPos) > q.range then return false end
    if pred.trace.linear.hardlock(q, seg, obj) then
        return true
    end
    if pred.trace.linear.hardlockmove(q, seg, obj) then
        return true
    end
	local buff_keys = obj.buff.keys
	for i = 1, buff_keys.n do
		local buff_key = buff_keys[i]
		local buff = obj.buff[buff_key]
        if buff and buff.valid then 
            if buff.type == 5 or buff.type == 8 or buff.type == 10 or buff.type == 11 or buff.type == 22 or
                    buff.type == 24 or buff.type == 28 or buff.type == 29 or buff.type == 30 or buff.type == 34 then
                return true
            end
        end
    end
end

local function ts_filter_q(res, object, dist)
    if object and common.IsValidTarget(object) and common.IsEnemyHero(object) then
        if (dist > q.range or object.buff["rocketgrab"]) then return end -- common.IsSpellShielded(object)  idk if important with golden card
        local seg = pred.linear.get_prediction(q, object)
        if not seg then return false end
        if seg.startPos:dist(seg.endPos) > q.range then return false end
        --chat.print(seg.endPos.x .. seg.endPos.x)
        res.pos = seg.endPos
        res.object = object
        return true
    end 
end

local function ts_filter_q_cc(res, object, dist)
    if object and common.IsValidTarget(object) and common.IsEnemyHero(object) then
        if (dist > q.range or object.buff["rocketgrab"]) then return end -- common.IsSpellShielded(object)  idk if important with golden card
        local seg = pred.linear.get_prediction(q, object)
        if not seg then return false end
        if not trace_filter(seg, object) then return false end
        if seg.startPos:dist(seg.endPos) > q.range then return false end
        --chat.print(seg.endPos.x .. seg.endPos.x)
        res.pos = seg.endPos
        res.object = object
        return true
    end 
end

local function ts_filter_w(res, object, dist)
    if object and common.IsValidTarget(object) and common.IsEnemyHero(object) then
        if (dist > common.GetAARange(object) or object.buff["rocketgrab"]) then return end -- common.IsSpellShielded(object)  idk if important with golden card
        res.object = object
        return true
    end 
end

local function combo()
    if menu.tfmenu.Combo.q_combo:get() then
        if not menu.tfmenu.Combo.q_combo_onlyCC:get() then
            if not player:spellSlot(0).state~=0 then
                local resQ = ts.get_result(ts_filter_q)
                if resQ.pos then
                    if not orb.core.is_spell_locked() then
                        player:castSpell('pos', 0, vec3(resQ.pos.x, mousePos.y, resQ.pos.y))
                    end
                end
            end
        else
            if not player:spellSlot(0).state~=0 then
                local resQ = ts.get_result(ts_filter_q_cc)
                if resQ.pos then
                    if not orb.core.is_spell_locked() then
                        player:castSpell('pos', 0, vec3(resQ.pos.x, mousePos.y, resQ.pos.y))
                    end
                end
            end
        end
    end
    if menu.tfmenu.Combo.w_combo:get() then
        local resW = ts.get_result(ts_filter_w)
        if resW.object then
            if resW.object.pos:dist(player.pos) < common.GetAARange(resW.object)+250 then
                if not player:spellSlot(1).state~=0 and player:spellSlot(1).name == "PickACard" then
                    player:castSpell('self', 1)
                end
            end
        end
    end
end

local function catch_w()
    -- Semi catch
    if not player:spellSlot(1).state~=0 and player:spellSlot(1).name == "GoldCardLock" and menu.tfmenu.Misc.semi_gold:get() then
        player:castSpell('self', 1)
    end
    if not player:spellSlot(1).state~=0 and player:spellSlot(1).name == "BlueCardLock" and menu.tfmenu.Misc.semi_blue:get() then
        player:castSpell('self', 1)
    end
    if not player:spellSlot(1).state~=0 and player:spellSlot(1).name == "RedCardLock" and menu.tfmenu.Misc.semi_red:get() then
        player:castSpell('self', 1)
    end

    --catch in R
    if not player:spellSlot(1).state~=0 and player:spellSlot(1).name == "GoldCardLock" and menu.tfmenu.Misc.r_gold:get() and used_r == 1 then
        player:castSpell('self', 1)
    elseif used_r == 1 then
        return
    end
    

    --catch golden in combo
    if not player:spellSlot(1).state~=0 and player:spellSlot(1).name == "GoldCardLock" and menu.tfmenu.Combo.w_always_gold:get() and orb.combat.is_active() then
        player:castSpell('self', 1)
    end
    --catch whatever in combo in no w_always_gold
    if not player:spellSlot(1).state~=0 and not menu.tfmenu.Combo.w_always_gold:get() and orb.combat.is_active() then
        player:castSpell('self', 1)
    end

    --catch in Lane clear
    local manaPercent = player.mana / player.maxMana
    manaPercent = manaPercent * 100
    if not jungle_w and not player:spellSlot(1).state~=0 and orb.menu.lane_clear.key:get() and manaPercent <= menu.tfmenu.Lane.w_lane_mana:get() and player:spellSlot(1).name == "BlueCardLock" then
        player:castSpell('self', 1)
    elseif not jungle_w and not player:spellSlot(1).state~=0 and orb.menu.lane_clear.key:get() and manaPercent >= menu.tfmenu.Lane.w_lane_mana:get() and player:spellSlot(1).name == "RedCardLock" then
        player:castSpell('self', 1)
    end

    --catch jungle clear
    if jungle_w and not player:spellSlot(1).state~=0 and orb.menu.lane_clear.key:get() and manaPercent <= menu.tfmenu.Lane.w_jungle_mana:get() and menu.tfmenu.Lane.w_jungle:get() and player:spellSlot(1).name == "BlueCardLock" then
        player:castSpell('self', 1)
        jungle_w = false
    elseif jungle_w and not player:spellSlot(1).state~=0 and orb.menu.lane_clear.key:get() and manaPercent >= menu.tfmenu.Lane.w_jungle_mana:get() and menu.tfmenu.Lane.w_jungle:get() and player:spellSlot(1).name == "RedCardLock" then
        player:castSpell('self', 1)
        jungle_w = false
    end
end

local function laneClear()
    local manaPercent = player.mana / player.maxMana
    manaPercent = manaPercent * 100
    if menu.tfmenu.Lane.q_lane:get() and menu.tfmenu.Lane.q_lane_mana:get() <= manaPercent then
        local minion_hits = 0
        local max_hits = 0
        local max_minion = {}
        for i=0, objManager.minions.size[TEAM_ENEMY]-1 do
            local obj = objManager.minions[TEAM_ENEMY][i]
            if obj.pos:dist(player.pos) <= q.range and obj.type == TYPE_MINION and not obj.isDead and obj.health and obj.health > 0 and obj.isVisible then
                minion_hits = 0
                for j=0, objManager.minions.size[TEAM_ENEMY]-1 do
                    local obj2 = objManager.minions[TEAM_ENEMY][j]
                    if obj2.pos:dist(player.pos) <= q.range and obj2.type == TYPE_MINION and not obj2.isDead and obj2.health and obj2.health > 0 and obj2.isVisible and obj2.isTargetable then
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
        if max_minion and max_hits >= menu.tfmenu.Lane.q_lane_minion:get() then
            if not orb.core.is_spell_locked() then
                player:castSpell('pos', 0, vec3(max_minion.pos.x, mousePos.y, max_minion.pos.z))
            end
        end
    end
    -- ------------------- FUTURE LANE DEFEND -------------------
    
    -- if menu.tfmenu.Lane.w_lane_defend:get() then
    --     local super_dupa = 0
    --     local super_dupa_obj = {}
    --     for i=0, objManager.turrets.size[TEAM_ALLY]-1 do
    --         local tower = objManager.turrets[TEAM_ALLY][i]
    --         if tower.pos:dist(player.pos) <= q.range then
    --             for i=0, objManager.minions.size[TEAM_ENEMY]-1 do
    --                 local minion = objManager.minions[TEAM_ENEMY][i]
    --                 if minion and not minion.isDead and minion.health and minion.health > 0 and minion.isVisible then
    --                     if minion.pos:dist(tower.pos) <= common.GetAARange(minion) + 150 and minion.name == "dupa" then
    --                         super_dupa = super_dupa + 1
    --                         super_dupa_obj = minion
    --                     end
    --                 end
    --             end
    --         end
    --     end
    --     if super_dupa > 0 and player:spellSlot(1).name == "PickACard" then
    --         orb.farm.set_clear_target(super_dupa_obj)
    --         player:castSpell('self', 1)
    --     end
    -- end

    if menu.tfmenu.Lane.w_lane:get()then 
        local minions_close = 0
        for i=0, objManager.minions.size[TEAM_ENEMY]-1 do
            local obj = objManager.minions[TEAM_ENEMY][i]
            if obj.pos:dist(player.pos)<= common.GetAARange(obj) + 150 and obj.isVisible and not obj.isDead and obj.isTargetable then
                minions_close = minions_close + 1
            end
        end
        if minions_close > 2 and player:spellSlot(1).name == "PickACard" then
            player:castSpell('self', 1)
        end
    end

    -- JUNGLE --
    if menu.tfmenu.Lane.w_jungle:get()then 
        local minions_close = 0
        for i=0, objManager.minions.size[TEAM_NEUTRAL]-1 do
            local obj = objManager.minions[TEAM_NEUTRAL][i]
            if obj.pos:dist(player.pos)<= common.GetAARange(obj) + 150 and obj.isVisible and not obj.isDead and obj.isTargetable then
                minions_close = minions_close + 1
            end
        end
        if minions_close > 0 and player:spellSlot(1).name == "PickACard" then
            jungle_w = true
            player:castSpell('self', 1)
        end
    end

    if menu.tfmenu.Lane.q_jungle:get()then 
        local minion_hits = 0
        local max_hits = 0
        local max_minion = {}
        for i=0, objManager.minions.size[TEAM_NEUTRAL]-1 do
            local obj = objManager.minions[TEAM_NEUTRAL][i]
            if obj.pos:dist(player.pos) <= q.range and obj.type == TYPE_MINION and not obj.isDead and obj.health and obj.health > 0 and obj.isVisible then
                minion_hits = 0
                for j=0, objManager.minions.size[TEAM_NEUTRAL]-1 do
                    local obj2 = objManager.minions[TEAM_NEUTRAL][j]
                    if obj2.pos:dist(player.pos) <= q.range and obj2.type == TYPE_MINION and not obj2.isDead and obj2.health and obj2.health > 0 and obj2.isVisible and obj2.isTargetable then
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
                if string.find(obj.name, "Dragon") or string.find(obj.name, "RiftHerald") or string.find(obj.name, "Baron") then
                    max_minion = obj
                    max_hits = 99
                end
            end
        end
        if max_minion ~= nil and max_minion.pos ~= nil then
            if not orb.core.is_spell_locked() then
                player:castSpell('pos', 0, vec3(max_minion.pos.x, mousePos.y, max_minion.pos.z))
            end
        end
    end
end

local function killsteal()
    if menu.tfmenu.Misc.q_ks:get() then
        if not player:spellSlot(0).state~=0 then
            local resQ = 0
            if menu.tfmenu.Misc.q_ks_cc:get() then
                resQ = ts.get_result(ts_filter_q_cc)
            else
                resQ = ts.get_result(ts_filter_q)
            end
            if resQ.pos and resQ.object.health <= q.damage() * common.MagicReduction(resQ.object) then
                if not orb.core.is_spell_locked() then
                    player:castSpell('pos', 0, vec3(resQ.pos.x, mousePos.y, resQ.pos.y))
                end
            end
        end
    end
end

local function semi_w_start()
    if not player:spellSlot(1).state~=0 and player:spellSlot(1).name == "PickACard" and (menu.tfmenu.Misc.semi_gold:get() or menu.tfmenu.Misc.semi_blue:get() or menu.tfmenu.Misc.semi_red:get()) then
        player:castSpell('self', 1)
    end

end

local function process_r()
    if used_r == 1 and os.clock() > used_r_time + 3 then
        used_r = 0
        used_r_time = 0
    elseif used_r == 1 and os.clock() < used_r_time + 3 and not player:spellSlot(1).state~=0 and player:spellSlot(1).name == "PickACard" then
        player:castSpell('self', 1)
    end
end

local function on_tick()
    catch_w()
    semi_w_start()
    killsteal()
    if orb.combat.is_active() then
        combo()
    end 
    if orb.menu.lane_clear.key:get() then
        laneClear()
    end
    process_r()

end

local function on_draw()
    local drawq = menu.tfmenu.Draw.q_draw:get()
    local drawr = menu.tfmenu.Draw.r_draw:get()
    local ready = menu.tfmenu.Draw.ready:get()
    if ((ready and player:spellSlot(0).state == 0) or not ready) and drawq then
        graphics.draw_circle(player.pos, q.range, 2, graphics.argb(255, 0, 255, 0), 100)
    end
    if ((ready and player:spellSlot(3).state == 0) or not ready) and drawr then
        graphics.draw_circle(player.pos, r.range, 2, graphics.argb(255, 0, 255, 0), 100)
        local v1 = player.pos
        local radius = r.range
        local line_width = 1
        local color = 0xFFFFFFFF
        local points_n = 32
        minimap.draw_circle(v1, radius, line_width, color, points_n)
    end

    if menu.tfmenu.Draw.dmg_draw:get() then
        local damageM = 0
        local damageP = 0
        local v = graphics.world_to_screen(player.pos)

        if menu.tfmenu.Draw.dmg_draw_ready:get() then
            if menu.tfmenu.Draw.q_draw_dmg:get() and player:spellSlot(0).state == 0 then
                damageM = damageM + q.damage()
            end
        else
            if menu.tfmenu.Draw.q_draw_dmg:get() then
                damageM = damageM + q.damage()
            end
        end

        common.damageIndicator(damageM, damageP, r.range)
    end
end

local function on_process_spell(spell)
    if spell.name == "Destiny" and spell.owner == player then
        used_r = 1
        used_r_time = os.clock()
    end

end


cb.add(cb.spell, on_process_spell)

cb.add(cb.tick,on_tick)

-- TODO: COLORS
cb.add(cb.draw,on_draw)

chat.print('[Dalandan AIO] Loading Twisted Fate successful!')
