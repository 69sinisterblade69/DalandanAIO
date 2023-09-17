local orb = module.internal("orb");
local ts = module.internal("TS");
local pred = module.internal("pred");
local damagelib = module.internal("damagelib");

local common = module.load("Dalandan_AIO", "common");
local menu = module.load("Dalandan_AIO", "menu");
-- common.spellNames()

local q = {
    range = 450,
    delay = 0.35,
    width = 80,
    speed = math.huge,
    boundingRadiusMod = 1, --??
}

local q3 = {
    range = 1050,
    width = 160,
    speed = 1500,
    boundingRadiusMod = 1, --??
}

local w = {
    range = 550,
    width = 4 * math.pi / 9, -- ??
    delay = 0.5,
    speed = math.huge,
    boundingRadiusMod = 1, --??
}

local e = {
    range = 300,
    speed = 1200,
}

local r = {
    delay = 0.75,
    speed = math.huge,
    range = 1000,
    width = 225,
    boundingRadiusMod = 1, --??
}

local function delay()
    local d = 0.35
    local as = common.GetBonusAS()
    local i = 0
    if as > 120 then
        q.delay = 0.175
        q3.delay = 0.175
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
    q3.delay = d

    as = common.GetBonusAS()
    d = 0.5
    local j = 0
    if as > 105 then
        w.delay = 0.19
    end
    while as > 0 do
        if as - 1 > 0 then
            as = as - 1
            j = j + 1
        else
            break
        end
    end
    d = 0.5 * (1 - (0.0059523*j))
    w.delay = d
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

        currentTarget = ts.get_result(ts_filter_basic)
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

        currentTarget = ts.get_result(ts_filter_basic)
        if currentTarget.object ~= nil then
            if currentTarget.object.pos:dist(player.pos) < (range + currentTarget.object.boundingRadius) then
                return currentTarget
            end
        end

    end
end

local function isE2()
    if player.mana > 0 then
        return true
    else
        return false
    end
end

local function LogicE()
    local target = getTarget("combo",e.range)
    if target and target.object ~= nil then
        if not player:spellSlot(2).state~=0 then
            if not orb.core.is_spell_locked() and not isE2() then
                player:castSpell('pos', 2, vec3(target.object.pos.x, mousePos.y, target.object.pos.z))
            end
        end
    end
end

local function LogicR()
    local target = nil
    if not player:spellSlot(2).state ~= 0 and not isE2() then
        target = getTarget("combo",r.range+e.range)
    else
        target = getTarget("combo",r.range)
    end
    if target and target.object ~= nil then
        if not player:spellSlot(3).state~=0 then
            if not orb.core.is_spell_locked() then
                local damage = 0
                damage = damage + math.max(damagelib.get_spell_damage('YoneQ', 0, player, target.object, false, 0),damagelib.get_spell_damage('YoneQ3', 0, player, target.object, false, 0)) * 2
                damage = damage + damagelib.get_spell_damage('YoneR', 3, player, target.object, false, 0)
                damage = damage + damagelib.get_spell_damage('YoneW', 2, player, target.object, false, 0)
                if damage > target.object.health then -- r + 2q + w
                    if not player:spellSlot(2).state ~= 0 then
                        if not orb.core.is_spell_locked() and not isE2() then
                            player:castSpell('pos', 2, vec3(target.object.pos.x, mousePos.y, target.object.pos.z))
                        end
                    end
                    if not orb.core.is_spell_locked() then
                        local pred_seg = pred.linear.get_prediction(r, target.object, player)
                        player:castSpell('pos', 3, vec3(pred_seg.endPos.x, target.object.y, pred_seg.endPos.y))
                    end
                end
            end
        end
    end
end

local function LogicW()
    local target = getTarget("combo",w.range)
    if target and target.object ~= nil then
        if not player:spellSlot(1).state~=0 then
            if not orb.core.is_spell_locked() then
                local pred_seg = pred.linear.get_prediction(w, target.object, player)
                player:castSpell('pos', 1, vec3(pred_seg.endPos.x, target.object.y, pred_seg.endPos.y))
            end
        end
    end
end

local function LogicQ()
    local target = getTarget("combo",q.range)
    if target and target.object ~= nil then
        if not player:spellSlot(0).state~=0 then
            if not orb.core.is_spell_locked() then
                local pred_seg = pred.linear.get_prediction(q, target.object, player)
                player:castSpell('pos', 0, vec3(pred_seg.endPos.x, target.object.y, pred_seg.endPos.y))
            end
        end
    end
end


local function combo()
    if menu.yonemenu.Combo.e_combo:get() then
        LogicE()
    end
    if menu.yonemenu.Combo.r_combo:get() then
        LogicR()
    end
    if menu.yonemenu.Combo.w_combo:get() then
        LogicW()
    end
    if menu.yonemenu.Combo.q_combo:get() then
        LogicQ()
    end
end

local function laneClear()
    local minions = {}
    for i=0, objManager.maxObjects-1 do
        local obj = objManager.get(i)
        if obj and obj.team ~= TEAM_ALLY and obj.type==TYPE_MINION and common.IsValidTarget(obj) and not string.find(string.lower(tostring(obj.name)),"plant") then
            minions[i]=obj
        end
    end

    if menu.yonemenu.Lane.q_laneclear:get() then
        for i, minion in pairs(minions) do
            if player.pos:dist(minion.pos) <= q.range then
                local count, table = common.CountEnemiesNearPos(minion.pos, 400)
                local qdamage = math.max(damagelib.get_spell_damage('YoneQ', 0, player, minion, false, 0),damagelib.get_spell_damage('YoneQ3', 0, player, minion, false, 0))
                if minion.health > qdamage + 50 and count <= 0 and not player.path.isDashing then
                    player:castSpell('pos', 0, vec3(minion.pos.x, minion.pos.y, minion.pos.z)) 
                end
            end
        end
    end

    if menu.yonemenu.Lane.w_laneclear:get() then
        for i, minion in pairs(minions) do
            if player.pos:dist(minion.pos) <= q.range then
                local count, table = common.CountEnemiesNearPos(minion.pos, 400)
                if minion.health > damagelib.get_spell_damage('YoneW', 1, player, minion, false, 0) + 50 and count <= 0 and not player.path.isDashing then
                    player:castSpell('pos', 1, vec3(minion.pos.x, minion.pos.y, minion.pos.z)) 
                end
            end
        end
    end
    
end

local function killsteal()
    local Qtarget = getTarget("combo",q.range);
    local Wtarget = getTarget("combo",w.range);
    local Rtarget = getTarget("combo",r.range);
    
    if Qtarget and Qtarget.object and common.IsValidTarget(Qtarget.object) and menu.yonemenu.Misc.q_ks:get() then
        if math.max(damagelib.get_spell_damage('YoneQ', 0, player, Qtarget.object, false, 0),damagelib.get_spell_damage('YoneQ3', 0, player, Qtarget.object, false, 0)) > Qtarget.object.health then
            if not orb.core.is_spell_locked() then
                local pred_seg = pred.linear.get_prediction(q, Qtarget.object, player)
                player:castSpell('pos', 0, vec3(pred_seg.endPos.x, Qtarget.object.y, pred_seg.endPos.y))
            end
        end
    end

    if Wtarget and Wtarget.object and common.IsValidTarget(Wtarget.object) and menu.yonemenu.Misc.w_ks:get() then
        if damagelib.get_spell_damage('YoneW', 1, player, Wtarget.object, false, 0) > Wtarget.object.health then
            if not orb.core.is_spell_locked() then
                local pred_seg = pred.linear.get_prediction(w, Wtarget.object, player)
                player:castSpell('pos', 1, vec3(pred_seg.endPos.x, Wtarget.object.y, pred_seg.endPos.y))
            end
        end
    end

    if Rtarget and Rtarget.object and common.IsValidTarget(Rtarget.object) and menu.yonemenu.Misc.r_ks:get() then
        if damagelib.get_spell_damage('YoneR', 3, player, Rtarget.object, false, 0) > Rtarget.object.health then
            if not orb.core.is_spell_locked() then
                local pred_seg = pred.linear.get_prediction(r, Rtarget.object, player)
                player:castSpell('pos', 3, vec3(pred_seg.endPos.x, Rtarget.object.y, pred_seg.endPos.y))
            end
        end
    end
end

local function semi()
    local target = getTarget("combo",r.range-50)
    if target and target.object ~= nil then
        if not orb.core.is_spell_locked() then
            local pred_seg = pred.linear.get_prediction(r, target.object, player)
            player:castSpell('pos', 3, vec3(pred_seg.endPos.x, target.object.y, pred_seg.endPos.y))
        end
    end
end

-- Screen dimensions
local screenWidth = graphics.width
local screenHeight = graphics.height

-- Image dimensions
local imageWidth = 250
local imageHeight = 250

-- Position and velocity
local p = vec2(screenWidth / 2, screenHeight / 2)
local v = vec2(2, 2)

local function on_tick()
    delay()
    if menu.yonemenu.Misc.r_semi:get() then
        semi()
    end
    if orb.combat.is_active() then
        combo()
    end 
    if orb.menu.lane_clear.key:get() then
        laneClear()
    end
    -- if orb.menu.hybrid.key:get() then
    --     harass()
    -- end
    -- if orb.menu.last_hit.key:get() then
    --     lasthit()
    -- end
    killsteal()

    p = p + v

    -- Bounce off edges
    if p.x < 0 or p.x > screenWidth - imageWidth then
        v.x = -v.x
    end
    if p.y < 0 or p.y > screenHeight - imageHeight then
        v.y = -v.y
    end

end


local function on_draw()
    local drawq = menu.yonemenu.Draw.q_draw:get()
    local draww = menu.yonemenu.Draw.w_draw:get()
    local drawe = menu.yonemenu.Draw.e_draw:get()
    local drawr = menu.yonemenu.Draw.r_draw:get()
    local ready = menu.yonemenu.Draw.ready:get()
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
    end

    if menu.yonemenu.Draw.dmg_draw:get() then
        for i,obj in pairs(common.GetEnemyHeroes()) do
            local damage = 0
            damage = damage + math.max(damagelib.get_spell_damage('YoneQ', 0, player, obj, false, 0),damagelib.get_spell_damage('YoneQ3', 0, player, obj, false, 0))
            damage = damage + damagelib.get_spell_damage('YoneW', 1, player, obj, false, 0)
            damage = damage + damagelib.get_spell_damage('YoneR', 3, player, obj, false, 0)
            if damage > obj.health then
                common.damageIndicatorUpdated(damage, obj,100000,0,"Combo = Kill")
            else
                damage = damage + damagelib.calc_aa_damage(player, obj, true) * 2
                if damage > obj.health then
                    common.damageIndicatorUpdated(damage, obj,100000,0,"Combo + 2AA = Kill")
                else
                    common.damageIndicatorUpdated(damage, obj)
                end
            end
        end
    end
    graphics.draw_sprite("Sprites/Yone.png", vec2(p.x, p.y), 1, 0x66FFFFFF)
end

cb.add(cb.tick,on_tick)
cb.add(cb.draw,on_draw)