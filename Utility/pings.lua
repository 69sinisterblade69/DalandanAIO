local common = module.load("Dalandan_AIO", "common");
local menu = module.load("Dalandan_AIO", "menu");

local function on_create_minion(obj)
    local pingType = nil
    if menu.utilitymenu.pings.ping_ward:get() then
        if menu.utilitymenu.pings.ping_ward_type:get() == 1 then
            pingType = ping.AREA_IS_WARDED
        elseif menu.utilitymenu.pings.ping_ward_type:get() == 2 then
            pingType = ping.ALERT
        end

        if obj.isWard and obj.team == TEAM_ENEMY and menu.utilitymenu.pings.ping_ward_visible:get() and obj.isOnScreen then
            ping.send(obj.pos, pingType, obj)
        elseif obj.isWard and obj.team == TEAM_ENEMY and not menu.utilitymenu.pings.ping_ward_visible:get() then
            ping.send(obj.pos, pingType, obj)
        end
    end

end

local function on_process_spell(spell)
    if spell.owner.type == TYPE_HERO and spell.owner.team == TEAM_ENEMY then
        -- chat.print(spell.owner:spellSlot(4).name)
        -- chat.print(spell.owner:spellSlot(5).name)
        -- chat.print(spell.name.." "..spell.owner.charName)
        for i, obj in pairs(common.GetEnemyHeroes()) do
            if spell.owner == obj then
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
                if menu.utilitymenu.pings.summoner[spell.owner.charName.."4"]:get() then
                    if spell.slot == spell.owner:spellSlot(4).slot then
                        if menu.utilitymenu.pings.chat_summoner:get() then
                            local name = spell.name
                            if spell.owner:spellSlot(4).name == "SummonerDot" then
                                name = "ignite"
                            end
                            if spell.owner:spellSlot(4).name == "SummonerHaste" then
                                name = "ghost"
                            end
                            if spell.owner:spellSlot(4).name == "SummonerHeal" then
                                name = "heal"
                            end
                            if spell.owner:spellSlot(4).name == "SummonerBoost" then
                                name = "cleanse"
                            end
                            if spell.owner:spellSlot(4).name == "SummonerExhaust" then
                                name = "exhaust"
                            end
                            if string.find(spell.owner:spellSlot(4).name, "Smite") then
                                name = "smite"
                            end
                            if string.find(spell.owner:spellSlot(4).name, "teleport") then
                                name = "teleport"
                            end
                            if spell.owner:spellSlot(4).name == "SummonerBarrier" then
                                name = "barrier"
                            end
                            if spell.owner:spellSlot(4).name == "SummonerFlash" then
                                name = "flash"
                            end

                            local time = 0
                            if name == "smite" then
                                -- -- chat.print(spell.owner:spellSlot(4).cooldown)
                                -- -- chat.print(spell.owner:spellSlot(4).totalCooldown)
                                -- -- chat.print(spell.owner:spellSlot(4).stacksCooldown)
                                -- -- chat.print(spell.owner:spellSlot(4).stacks)
                                -- if spell.owner:spellSlot(4).stacks > 0 then
                                --     time = game.time + spell.owner:spellSlot(4).cooldown
                                -- else
                                --     time = game.time + spell.owner:spellSlot(4).stacksCooldown
                                -- end
                                -- local minutes = math.floor(time / 60)
                                -- local seconds = math.floor(time % 60)
                                -- chat.send(spell.owner.charName.." used "..name..". Will be back on "..minutes..":"..seconds)
                            else
                                time = game.time + spell.owner:spellSlot(4).cooldown
                                local minutes = math.floor(time / 60)
                                local seconds = math.floor(time % 60)
                                chat.send(spell.owner.charName.." used "..name..". Will be back on "..minutes..":"..seconds)
                            end
                        end
                    end
                end
                -- if not true then
                if menu.utilitymenu.pings.summoner[spell.owner.charName.."5"]:get() then
                    if spell.slot == spell.owner:spellSlot(5).slot then
                        if menu.utilitymenu.pings.chat_summoner:get() then
                            local name = spell.name
                            if spell.owner:spellSlot(5).name == "SummonerDot" then
                                name = "ignite"
                            end
                            if spell.owner:spellSlot(5).name == "SummonerHaste" then
                                name = "ghost"
                            end
                            if spell.owner:spellSlot(5).name == "SummonerHeal" then
                                name = "heal"
                            end
                            if spell.owner:spellSlot(5).name == "SummonerBoost" then
                                name = "cleanse"
                            end
                            if spell.owner:spellSlot(5).name == "SummonerExhaust" then
                                name = "exhaust"
                            end
                            if string.find(spell.owner:spellSlot(5).name, "Smite") then
                                name = "smite"
                            end
                            if string.find(spell.owner:spellSlot(5).name, "teleport") then
                                name = "teleport"
                            end
                            if spell.owner:spellSlot(5).name == "SummonerBarrier" then
                                name = "barrier"
                            end
                            if spell.owner:spellSlot(5).name == "SummonerFlash" then
                                name = "flash"
                            end

                            local time = 0
                            if name == "smite" then
                                -- if spell.owner:spellSlot(5).stacks > 0 then
                                --     time = game.time + spell.owner:spellSlot(5).cooldown
                                -- else
                                --     time = game.time + spell.owner:spellSlot(5).stacksCooldown
                                -- end
                                -- local minutes = math.floor(time / 60)
                                -- local seconds = math.floor(time % 60)
                                -- chat.send(spell.owner.charName.." used "..name..". Will be back on "..minutes..":"..seconds)
                            else
                                time = game.time + spell.owner:spellSlot(5).cooldown
                                local minutes = math.floor(time / 60)
                                local seconds = math.floor(time % 60)
                                chat.send(spell.owner.charName.." used "..name..". Will be back on "..minutes..":"..seconds)
                            end
                        end
                    end
                end
            end
        end
    end
end

local function on_tick()
    -- for i=0, objManager.enemies_n-1 do
    --     local obj = objManager.enemies[i]
    --     chat.print(obj.isVisible)
    -- end
    -- chat.print(player:spellSlot(_Q).cooldown)
    -- local time = player:spellSlot(_Q).totalCooldown 
    -- chat.print(player:spellSlot(_R).totalCooldown)
    -- for i=0, objManager.enemies_n-1 do
    --     local obj = objManager.enemies[i]
    --     chat.print(obj:spellSlot(_R).cooldown)
    -- end
    -- for i=4,5 do 
    --     chat.print(player:spellSlot(i).name)
    -- end
    -- chat.print(player:spellSlot(4).stacks)
    -- local time = 0

end

cb.add(cb.tick,on_tick)
cb.add(cb.create_minion,on_create_minion)
cb.add(cb.spell,on_process_spell)

chat.print("[Dalandan AIO] Auto pings loaded successfully")