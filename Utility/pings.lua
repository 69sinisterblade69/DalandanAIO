local common = module.load("Dalandan_AIO", "common");
local menu = module.load("Dalandan_AIO", "menu");

local function on_create_minion(obj)
    if menu.utilitymenu.pings.ping_ward:get() then
        if obj.isWard and obj.team == TEAM_ENEMY and menu.utilitymenu.pings.ping_ward_visible:get() and obj.isOnScreen then
            -- chat.print("1")
            ping.send(obj.pos, ping.AREA_IS_WARDED, obj)
        elseif obj.isWard and obj.team == TEAM_ENEMY and not menu.utilitymenu.pings.ping_ward_visible:get() then
            -- chat.print("2")
            ping.send(obj.pos, ping.AREA_IS_WARDED, obj)
        end
    end

end

local function on_process_spell(spell)
    if spell.owner.type == TYPE_HERO and spell.owner.team == TEAM_ENEMY then
        -- chat.print(spell.name.." "..spell.owner.charName)
        for i, obj in pairs(common.GetEnemyHeroes()) do
            if menu.utilitymenu.pings.ults[spell.owner.charName]:get() then
                if spell.slot == spell.owner:spellSlot(_R).slot then
                    if menu.utilitymenu.pings.chat_ult:get() then
                        local time = game.time + spell.owner:spellSlot(_R).cooldown
                        local minutes = math.floor(time / 60)
                        local seconds = math.floor(time % 60)
                        chat.send(spell.owner.charName.." used ult. Will be back on "..minutes..":"..seconds)
                    end
                end
            end
        end
    end
end

-- local function on_tick()
--     for i=0, objManager.enemies_n-1 do
--         local obj = objManager.enemies[i]
--         chat.print(obj.isVisible)
--     end
--     chat.print(player:spellSlot(_Q).cooldown)
--     local time = player:spellSlot(_Q).totalCooldown 
--     chat.print(player:spellSlot(_R).totalCooldown)
--     for i=0, objManager.enemies_n-1 do
--         local obj = objManager.enemies[i]
--         chat.print(obj:spellSlot(_R).cooldown)
--     end
-- end

-- cb.add(cb.tick,on_tick)
cb.add(cb.create_minion,on_create_minion)
cb.add(cb.spell,on_process_spell)

chat.print("[Dalandan AIO] Auto pings loaded successfully")