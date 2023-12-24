-- this is such a fucking mess
-- 90% of this code was written when I was drunk
-- not even I know what the fuck develepor meant 
-- adding any new functions here is going to be torment
-- you have been warned :)

local orb = module.internal("orb");
local ts = module.internal("TS");
local pred = module.internal("pred");
local damagelib = module.internal("damagelib");

-- for location
local clip = module.internal('clipper')
local polygon = clip.polygon
local polygons = clip.polygons
local clipper = clip.clipper
local clipper_enum = clip.enum

local common = module.load("Dalandan_AIO", "common");
local menu = module.load("Dalandan_AIO", "menu");

local scale = 0.4
local textSize = 14
local textSizeDeath = 30

local heroes = objManager.enemies
local count = objManager.enemies_n
local timers = {}
for i=0, count-1 do
    local obj = heroes[i]
    timers[obj.charName] = {
        deathCD = 0,
        visible = false,
        ssTime = 0,
        ssT = game.time,
    }
end

local function draw_cd(obj,spellslot, x,y,icon,size,scale)
    -- im dumb :(
    local trueCooldown = obj:spellSlot(spellslot).cooldown
    if obj:spellSlot(spellslot).stacks == 0 and obj:spellSlot(spellslot).stacksCooldown ~= 0 then
        trueCooldown = obj:spellSlot(spellslot).stacksCooldown
    elseif obj:spellSlot(spellslot).stacks ~= 0 then
        trueCooldown = obj:spellSlot(spellslot).cooldown
    end

    if trueCooldown == 0 and obj:spellSlot(spellslot).level >= 1 then
        graphics.draw_sprite(icon,vec2(x,y),scale,0xFFFFFFFF)
    elseif obj:spellSlot(spellslot).level >= 1 then
        graphics.draw_sprite(icon,vec2(x,y),scale,0xFF444444)
        local cooldown = string.format("%.1f", trueCooldown)
        if trueCooldown >= 100 then
            cooldown = string.format("%.0f", trueCooldown)
        end
        local a,b = graphics.text_area(tostring(cooldown),textSize)
        -- ive no fuckin idea where center of text is, so it's shit
        -- too bad.
        a = (size - a) / 2
        b = ((size / 2) - (b / 2)) + 0.5*textSize
        graphics.draw_outlined_text_2D(cooldown,textSize,x+a,y+b,0xFFFFFFFF)
    elseif obj:spellSlot(spellslot).level < 1 then
        graphics.draw_sprite(icon,vec2(x,y),scale,0xFF444444)
    end
end

local lastPos = {}
for i=0, count-1 do
    local obj = heroes[i]
    lastPos[obj.charName] = {
        lastLocation = "",
    }
end
-- lastPos[player.charName] = {
--     lastLocation = "",
-- }

local function getLocation(obj)
    local location = ""
    
    -- chat.print(mousePos.x.." "..mousePos.z)
    -- chat.print(mousePos:dist(player.pos))

    -- EVERY SINGLE VALUE here is taken straight out of my ass
    
    -- fast jungle check???
    local topBlue = vec2(3800,7900):dist(player.pos2D)
    local topRed = vec2(7000,10800):dist(player.pos2D)
    local botBlue = vec2(11100,7200):dist(player.pos2D)
    local botRed = vec2(7800,3800):dist(player.pos2D)

    local closest = math.min(topBlue,topRed,botBlue,botRed)
    if closest <= 3100 then
        if closest == topBlue then
            location = "Top blue"
        elseif closest == topRed then
            location = "Top red"
        elseif closest == botBlue then
            location = "Bot blue"
        else
            location = "Bot red"
        end
    end

    -- Bot
    local botP = polygon(vec2(5074,1808),vec2(5024,720),vec2(13160,830),vec2(14160,1830),vec2(14435,6000),vec2(14135,9800),vec2(13001,9800),vec2(13000,3700),vec2(11500,2300))
    -- botP:Draw3D(obj.y,2,0xFFFFFFFF)
    if botP:Contains(obj.pos)==1 then
        location = "Bot"
    end

    -- Top
    local topP = polygon(vec2(600,5000),vec2(1700,5000),vec2(2000,11500),vec2(4300,12800),vec2(9800,13000),vec2(9800,14300),vec2(1414,14200),vec2(500,13500))
    -- topP:Draw3D(obj.y,2,0xFFFFFFFF)
    if topP:Contains(obj.pos)==1 then
        location = "Top"
    end

    -- Mid
    local midP = polygon(vec2(3600,4400),vec2(4470,3720),vec2(8100,6720),vec2(11100,10500),vec2(10200,11300),vec2(5400,6660))
    -- midP:Draw3D(obj.y,2,0xFFFFFFFF)
    if midP:Contains(obj.pos)==1 then
        location = "Mid"
    end

    -- Top River
    local tRiverP = polygon(vec2(2300,11600),vec2(4200,9000),vec2(6360,7800),vec2(7200,8400),vec2(4300,10500),vec2(3300,12200))
    -- tRiverP:Draw3D(obj.y,2,0xFFFFFFFF)
    if tRiverP:Contains(obj.pos)==1 then
        location = "Top river"
    end

    -- Bottom River
    local bRiverP = polygon(vec2(11600,2400),vec2(12700,3300),vec2(10500,6100),vec2(8600,7080),vec2(7600,6300),vec2(9700,5000),vec2(10800,3800))
    -- bRiverP:Draw3D(obj.y,2,0xFFFFFAAF)
    if bRiverP:Contains(obj.pos)==1 then
        location = "Bottom river"
    end

    -- Drake
    if obj.pos2D:dist(vec2(9859,4428)) < 700 then
        location = "Drake"
    end
    -- Baron
    if obj.pos2D:dist(vec2(4980,10400)) < 700 then
        location = "Baron"
    end

    -- Base
    if obj.pos:dist(objManager.nexus[TEAM_ALLY].pos) < 3600 then
        location = "Ally base"
    end
    if obj.pos:dist(objManager.nexus[TEAM_ENEMY].pos) < 3600 then 
        location = "Enemy base"
    end


    if location ~= "" then
        lastPos[obj.charName].lastLocation = location
    else
        location = lastPos[obj.charName].lastLocation
    end

    return location
end

local function draw_champ(obj,style,x,y,champSize,ultSize,barSize,barBorder)
    local icon = obj.iconSquare
    
    if style == 1 then
        -- champ icon
        if obj.isDead or not obj.isVisible then
            graphics.draw_sprite(icon,vec2(x,y),scale,0xFF444444)
        else
            graphics.draw_sprite(icon,vec2(x,y),scale,0xFFFFFFFF)
        end

        -- level
        local levelSize = champSize/2.5
        graphics.draw_rectangle_2D(x+champSize-levelSize, y+champSize-levelSize, levelSize, levelSize, 0, 0xAA000000, true)

        local a,b = graphics.text_area(tostring(obj.levelRef),textSize)
        a = (levelSize - a) / 2
        b = ((levelSize / 2) - (b / 2)) + 0.5*textSize
        graphics.draw_outlined_text_2D(obj.levelRef,textSize,x+champSize-levelSize+a,y+champSize-levelSize+b,0xFFFFFFFF)

        -- rune
        if menu.awarenessmenu.hud.showRune:get() then
            local runeIcon = obj.rune:get(0).icon
            graphics.draw_sprite(runeIcon,vec2(x,y),scale,0xFFFFFFFF)
        end
        
        -- exp
        local expSize = 0
        if menu.awarenessmenu.hud.showExp:get() then
            expSize = menu.awarenessmenu.hud.customization.expSize:get() -- + barBorder
        end

        -- hp and mana and exp
        local hpDX = ((4*ultSize) -barBorder*2) * (obj.health/obj.maxHealth)
        local mDX = ((4*ultSize) -barBorder*2) * (obj.mana/obj.maxMana)
        -- graphics.draw_rectangle_2D(x, y+champSize, champSize, barSize+3*barBorder, 0, 0xFF555555, true)
        graphics.draw_rectangle_2D(x+champSize, y+ultSize, 4*ultSize, ultSize, 0, 0xFF000000, true) -- black
        -- graphics.draw_rectangle_2D(x, y+champSize, champSize, barSize+3*barBorder, 0, 0xFF777700, false) -- border

        -- check Reksai Leesin
        local manaColor = 0xFF3333FF
        if obj.charName == "Akali" or obj.charName == "Kennen" or obj.charName == "LeeSin" or obj.charName == "Shen" or obj.charName == "Zed" then
            manaColor = 0xFFFFF216
        elseif obj.charName == "Tryndamere" or obj.charName == "Shyvana" or obj.charName == "Renekton" or obj.charName == "Reksai" or obj.charName == "Gnar" or obj.charName == "Sett" or 
        obj.charName == "Kled" or obj.charName == "Vladimir" then 
            manaColor = 0xFFCC2222
        elseif obj.charName == "Rumble" then
            if obj.mana <= 50 then
                manaColor = 0xFFAAAAAA
            elseif obj.mana <= 150 then
                manaColor = 0xFFFFF216
            else
                manaColor = 0xFFCC2222
            end
        elseif obj.charName == "Yasuo" then
            manaColor = 0xFFAAAAAA
        end

        if menu.awarenessmenu.hud.showExp:get() then 
            local exp ={
                [1] = 0,
                [2] = 280,
                [3] = 660,
                [4] = 1140,
                [5] = 1720,
                [6] = 2400,
                [7] = 3180,
                [8] = 4060,
                [9] = 5040,
                [10] = 6120,
                [11] = 7300,
                [12] = 8580,
                [13] = 9960,
                [14] = 11440,
                [15] = 13020,
                [16] = 14700,
                [17] = 16480,
                [18] = 18360,
                [19] = 18360,
            }
            
            local expDX = ((4*ultSize) -barBorder*2) * (obj.exp / exp[obj.levelRef+1])
            graphics.draw_rectangle_2D(x+champSize+barBorder, y+ultSize+barBorder*3+(barSize-(expSize+barBorder)), expDX, expSize, 0, 0xFFAA00AA, true)
            
            graphics.draw_rectangle_2D(x+champSize+barBorder, y+ultSize+barBorder, hpDX, (barSize-(expSize+barBorder))/2, 0, 0xFF33FF33, true)
            graphics.draw_rectangle_2D(x+champSize+barBorder, y+ultSize+barBorder*2+(barSize-(expSize+barBorder))/2, mDX, (barSize-(expSize+barBorder))/2, 0, manaColor, true)
        else
            graphics.draw_rectangle_2D(x+champSize+barBorder, y+ultSize+barBorder, hpDX, barSize/2, 0, 0xFF33FF33, true)
            graphics.draw_rectangle_2D(x+champSize+barBorder, y+ultSize+barBorder*2+(barSize+2*barBorder)/2, mDX, barSize/2, 0, manaColor, true)
        end

        -- xd
        if menu.awarenessmenu.hud.showText:get() then
            local hp = string.format("%.0f",(obj.health/obj.maxHealth)*100)
            local mp = string.format("%.0f",(obj.mana/obj.maxMana)*100)
            hp = hp.."%"
            mp = mp.."%"
            if tostring(mp) == 'nan%' then
                mp = ""
            end
            local a,b = graphics.text_area(tostring(hp),textSize)
            a = ((4*ultSize) - a) / 2
            b = ((barSize / 2) - (b / 2)) + 0.6*textSize
            graphics.draw_outlined_text_2D(hp,textSize,x+champSize+a,y+ultSize+b,0xFFFFFFFF)
            graphics.draw_outlined_text_2D(mp,textSize,x+champSize+a,y+ultSize+b+(barSize/2),0xFFFFFFFF)
        end

        -- Ult + summ
        local q = obj:spellSlot(0)
        local w = obj:spellSlot(1)
        local e = obj:spellSlot(2)
        local ult = obj:spellSlot(3)
        local summ1 = obj:spellSlot(4)
        local summ2 = obj:spellSlot(5)

        local ultScale = ultSize/64

        draw_cd(obj,0,x+champSize,y,q.icon,ultSize,ultScale)
        draw_cd(obj,1,x+champSize+(ultSize),y,w.icon,ultSize,ultScale)
        draw_cd(obj,2,x+champSize+(ultSize*2),y,e.icon,ultSize,ultScale)
        draw_cd(obj,3,x+champSize+(ultSize*3),y,ult.icon,ultSize,ultScale)
        draw_cd(obj,4,x+champSize+(ultSize*4),y,summ1.icon,ultSize,ultScale)
        draw_cd(obj,5,x+champSize+(ultSize*4),y+ultSize,summ2.icon,ultSize,ultScale)

        -- death + missing text
        if obj.isDead then
            local deathTime = timers[obj.charName].deathCD
            deathTime = string.format("%.0f",deathTime)
            local a,b = graphics.text_area(tostring(deathTime),textSizeDeath)
            a = (champSize - a) / 2
            b = ((champSize / 2) - (b / 2)) + 0.5*textSizeDeath
            graphics.draw_outlined_text_2D(deathTime,textSizeDeath,x+a,y+b,0xFFFF0000)
        elseif not obj.isVisible then
            local ssTime = timers[obj.charName].ssTime
            ssTime = string.format("%.0f",ssTime)
            local a,b = graphics.text_area(tostring(ssTime),textSizeDeath)
            a = (champSize - a) / 2
            b = ((champSize / 2) - (b / 2)) + 0.5*textSizeDeath
            graphics.draw_outlined_text_2D(ssTime,textSizeDeath,x+a,y+b,0xFFFFF216)
        end

        -- location
        if menu.awarenessmenu.hud.showLocation:get() then
            local location = getLocation(obj)
            graphics.draw_outlined_text_2D(location,textSize,x,y+champSize*1+0.5*textSize,0xFFFFF216)
        end
    end
    if style == 2 then
        -- champ icon
        scale = ultSize/120
        if obj.isDead or not obj.isVisible then
            graphics.draw_sprite(icon,vec2(x,y),scale,0xFF444444)
        else
            graphics.draw_sprite(icon,vec2(x,y),scale,0xFFFFFFFF)
        end

        -- level
        local levelSize = champSize/2.5
        graphics.draw_rectangle_2D(x+champSize-levelSize, y+champSize-levelSize, levelSize, levelSize, 0, 0xAA000000, true)

        local a,b = graphics.text_area(tostring(obj.levelRef),textSize)
        a = (levelSize - a) / 2
        b = ((levelSize / 2) - (b / 2)) + 0.5*textSize
        graphics.draw_outlined_text_2D(obj.levelRef,textSize,x+champSize-levelSize+a,y+champSize-levelSize+b,0xFFFFFFFF)

        -- rune
        if menu.awarenessmenu.hud.showRune:get() then
            local runeIcon = obj.rune:get(0).icon
            graphics.draw_sprite(runeIcon,vec2(x,y),scale,0xFFFFFFFF)
        end
        
        -- exp
        local expSize = 0
        if menu.awarenessmenu.hud.showExp:get() then
            expSize = menu.awarenessmenu.hud.customization.expSize:get() -- + barBorder
        end

        -- hp and mana and exp
        local hpDX = ((2*ultSize) -barBorder*2) * (obj.health/obj.maxHealth)
        local mDX = ((2*ultSize) -barBorder*2) * (obj.mana/obj.maxMana)
        -- graphics.draw_rectangle_2D(x, y+champSize, champSize, barSize+3*barBorder, 0, 0xFF555555, true)
        graphics.draw_rectangle_2D(x, y+ultSize, 2*ultSize, ultSize, 0, 0xFF000000, true) -- black
        -- graphics.draw_rectangle_2D(x, y+champSize, champSize, barSize+3*barBorder, 0, 0xFF777700, false) -- border

        -- check Reksai Leesin
        local manaColor = 0xFF3333FF
        if obj.charName == "Akali" or obj.charName == "Kennen" or obj.charName == "LeeSin" or obj.charName == "Shen" or obj.charName == "Zed" then
            manaColor = 0xFFFFF216
        elseif obj.charName == "Tryndamere" or obj.charName == "Shyvana" or obj.charName == "Renekton" or obj.charName == "Reksai" or obj.charName == "Gnar" or obj.charName == "Sett" or 
        obj.charName == "Kled" or obj.charName == "Vladimir" then 
            manaColor = 0xFFCC2222
        elseif obj.charName == "Rumble" then
            if obj.mana <= 50 then
                manaColor = 0xFFAAAAAA
            elseif obj.mana <= 150 then
                manaColor = 0xFFFFF216
            else
                manaColor = 0xFFCC2222
            end
        elseif obj.charName == "Yasuo" then
            manaColor = 0xFFAAAAAA
        end

        if menu.awarenessmenu.hud.showExp:get() then 
            local exp ={
                [1] = 0,
                [2] = 280,
                [3] = 660,
                [4] = 1140,
                [5] = 1720,
                [6] = 2400,
                [7] = 3180,
                [8] = 4060,
                [9] = 5040,
                [10] = 6120,
                [11] = 7300,
                [12] = 8580,
                [13] = 9960,
                [14] = 11440,
                [15] = 13020,
                [16] = 14700,
                [17] = 16480,
                [18] = 18360,
                [19] = 18360,
            }
            
            local expDX = ((2*ultSize) -barBorder*2) * (obj.exp / exp[obj.levelRef+1])
            graphics.draw_rectangle_2D(x+barBorder, y+ultSize+barBorder*3+(barSize-(expSize+barBorder)), expDX, expSize, 0, 0xFFAA00AA, true)
            
            graphics.draw_rectangle_2D(x+barBorder, y+ultSize+barBorder, hpDX, (barSize-(expSize+barBorder))/2, 0, 0xFF33FF33, true)
            graphics.draw_rectangle_2D(x+barBorder, y+ultSize+barBorder*2+(barSize-(expSize+barBorder))/2, mDX, (barSize-(expSize+barBorder))/2, 0, manaColor, true)
        else
            graphics.draw_rectangle_2D(x+barBorder, y+ultSize+barBorder, hpDX, barSize/2, 0, 0xFF33FF33, true)
            graphics.draw_rectangle_2D(x+barBorder, y+ultSize+barBorder*2+(barSize+2*barBorder)/2, mDX, barSize/2, 0, manaColor, true)
        end

        -- xd
        if menu.awarenessmenu.hud.showText:get() then
            local hp = string.format("%.0f",(obj.health/obj.maxHealth)*100)
            local mp = string.format("%.0f",(obj.mana/obj.maxMana)*100)
            hp = hp.."%"
            mp = mp.."%"
            if tostring(mp) == 'nan%' then
                mp = ""
            end
            local a,b = graphics.text_area(tostring(hp),textSize)
            a = ((4*ultSize) - a) / 2
            b = ((barSize / 2) - (b / 2)) + 0.6*textSize
            graphics.draw_outlined_text_2D(hp,textSize,x+champSize+a,y+ultSize+b,0xFFFFFFFF)
            graphics.draw_outlined_text_2D(mp,textSize,x+champSize+a,y+ultSize+b+(barSize/2),0xFFFFFFFF)
        end

        -- Ult + summ
        local q = obj:spellSlot(0)
        local w = obj:spellSlot(1)
        local e = obj:spellSlot(2)
        local ult = obj:spellSlot(3)
        local summ1 = obj:spellSlot(4)
        local summ2 = obj:spellSlot(5)

        local ultScale = ultSize/64

        -- draw_cd(obj,0,x+champSize,y,q.icon,ultSize,ultScale)
        -- draw_cd(obj,1,x+champSize+(ultSize),y,w.icon,ultSize,ultScale)
        -- draw_cd(obj,2,x+champSize+(ultSize*2),y,e.icon,ultSize,ultScale)
        draw_cd(obj,3,x+champSize+(ultSize*0),y,ult.icon,ultSize,ultScale)
        draw_cd(obj,4,x+champSize+(ultSize*1),y,summ1.icon,ultSize,ultScale)
        draw_cd(obj,5,x+champSize+(ultSize*1),y+ultSize,summ2.icon,ultSize,ultScale)

        -- death + missing text
        if obj.isDead then
            local deathTime = timers[obj.charName].deathCD
            deathTime = string.format("%.0f",deathTime)
            local a,b = graphics.text_area(tostring(deathTime),textSizeDeath)
            a = (champSize - a) / 2
            b = ((champSize / 2) - (b / 2)) + 0.5*textSizeDeath
            graphics.draw_outlined_text_2D(deathTime,textSizeDeath,x+a,y+b,0xFFFF0000)
        elseif not obj.isVisible then
            local ssTime = timers[obj.charName].ssTime
            ssTime = string.format("%.0f",ssTime)
            local a,b = graphics.text_area(tostring(ssTime),textSizeDeath)
            a = (champSize - a) / 2
            b = ((champSize / 2) - (b / 2)) + 0.5*textSizeDeath
            graphics.draw_outlined_text_2D(ssTime,textSizeDeath,x+a,y+b,0xFFFFF216)
        end

        -- location
        if menu.awarenessmenu.hud.showLocation:get() then
            local location = getLocation(obj)
            graphics.draw_outlined_text_2D(location,textSize,x,y+ultSize*2+0.5*textSize,0xFFFFF216)
        end
    end
    if style == 3 then
        -- champ icon
        if obj.isDead or not obj.isVisible then
            graphics.draw_sprite(icon,vec2(x,y),scale,0xFF444444)
        else
            graphics.draw_sprite(icon,vec2(x,y),scale,0xFFFFFFFF)
        end

        -- level
        local levelSize = champSize/2.5
        graphics.draw_rectangle_2D(x+champSize-levelSize, y+champSize-levelSize, levelSize, levelSize, 0, 0xAA000000, true)

        local a,b = graphics.text_area(tostring(obj.levelRef),textSize)
        a = (levelSize - a) / 2
        b = ((levelSize / 2) - (b / 2)) + 0.5*textSize
        graphics.draw_outlined_text_2D(obj.levelRef,textSize,x+champSize-levelSize+a,y+champSize-levelSize+b,0xFFFFFFFF)

        -- rune
        if menu.awarenessmenu.hud.showRune:get() then
            local runeIcon = obj.rune:get(0).icon
            graphics.draw_sprite(runeIcon,vec2(x,y),scale,0xFFFFFFFF)
        end

        -- exp
        local expSize = 0
        if menu.awarenessmenu.hud.showExp:get() then
            expSize = menu.awarenessmenu.hud.customization.expSize:get() + barBorder
            -- ultSize = ultSize + expSize - barBorder
        end

        -- hp and mana and exp
        local hpDX = (champSize -barBorder*2) * (obj.health/obj.maxHealth)
        local mDX = (champSize -barBorder*2) * (obj.mana/obj.maxMana)
        -- graphics.draw_rectangle_2D(x, y+champSize, champSize, barSize+3*barBorder, 0, 0xFF555555, true)
        graphics.draw_rectangle_2D(x, y+champSize, champSize, barSize+3*barBorder+expSize, 0, 0xFF000000, true) -- black
        graphics.draw_rectangle_2D(x, y+champSize, champSize, barSize+3*barBorder+expSize, 0, 0xFF777700, false) -- border

        -- check Reksai Leesin
        local manaColor = 0xFF3333FF
        if obj.charName == "Akali" or obj.charName == "Kennen" or obj.charName == "LeeSin" or obj.charName == "Shen" or obj.charName == "Zed" then
            manaColor = 0xFFFFF216
        elseif obj.charName == "Tryndamere" or obj.charName == "Shyvana" or obj.charName == "Renekton" or obj.charName == "Reksai" or obj.charName == "Gnar" or obj.charName == "Sett" or 
        obj.charName == "Kled" or obj.charName == "Vladimir" then 
            manaColor = 0xFFCC2222
        elseif obj.charName == "Rumble" then
            if obj.mana <= 50 then
                manaColor = 0xFFAAAAAA
            elseif obj.mana <= 150 then
                manaColor = 0xFFFFF216
            else
                manaColor = 0xFFCC2222
            end
        elseif obj.charName == "Yasuo" then
            manaColor = 0xFFAAAAAA
        end

        if menu.awarenessmenu.hud.showExp:get() then
            expSize = menu.awarenessmenu.hud.customization.expSize:get()
            local exp ={
                [1] = 0,
                [2] = 280,
                [3] = 660,
                [4] = 1140,
                [5] = 1720,
                [6] = 2400,
                [7] = 3180,
                [8] = 4060,
                [9] = 5040,
                [10] = 6120,
                [11] = 7300,
                [12] = 8580,
                [13] = 9960,
                [14] = 11440,
                [15] = 13020,
                [16] = 14700,
                [17] = 16480,
                [18] = 18360,
                [19] = 18360,
            }
            
            local expDX = (champSize -barBorder*2) * ((obj.exp-exp[obj.levelRef]) / (exp[obj.levelRef+1]-exp[obj.levelRef]))
            graphics.draw_rectangle_2D(x+barBorder, y+champSize+barBorder, hpDX, barSize/2, 0, 0xFF33FF33, true)
            graphics.draw_rectangle_2D(x+barBorder, y+champSize+barBorder*2+barSize/2, mDX, barSize/2, 0, manaColor, true)
            graphics.draw_rectangle_2D(x+barBorder, y+champSize+barBorder*3+barSize, expDX, expSize, 0, 0xFFAA00AA, true)
        else
            graphics.draw_rectangle_2D(x+barBorder, y+champSize+barBorder, hpDX, barSize/2, 0, 0xFF33FF33, true)
            graphics.draw_rectangle_2D(x+barBorder, y+champSize+barBorder*2+barSize/2, mDX, barSize/2, 0, manaColor, true)
        end
        


        if menu.awarenessmenu.hud.showText:get() then
            local hp = string.format("%.0f",(obj.health/obj.maxHealth)*100)
            local mp = string.format("%.0f",(obj.mana/obj.maxMana)*100)
            hp = hp.."%"
            mp = mp.."%"
            if tostring(mp) == 'nan%' then
                mp = ""
            end
            local a,b = graphics.text_area(tostring(hp),textSize)
            a = (champSize - a) / 2
            b = ((barSize / 2) - (b / 2)) + 0.5*textSize
            graphics.draw_outlined_text_2D(hp,textSize,x+a,y+champSize+b,0xFFFFFFFF)
            graphics.draw_outlined_text_2D(mp,textSize,x+a,y+champSize+b+((barSize+2*barBorder)/2),0xFFFFFFFF)
        end

        -- Ult + summ
        local ult = obj:spellSlot(3)
        local summ1 = obj:spellSlot(4)
        local summ2 = obj:spellSlot(5)

        local ultScale = ultSize/64

        if not menu.awarenessmenu.hud.reverseSumm:get() then
            draw_cd(obj,3,x+champSize,y,ult.icon,ultSize,ultScale)
            draw_cd(obj,4,x+champSize,y+ultSize,summ1.icon,ultSize,ultScale)
            draw_cd(obj,5,x+champSize,y+ultSize*2,summ2.icon,ultSize,ultScale)
        else
            draw_cd(obj,5,x+champSize,y,summ2.icon,ultSize,ultScale)
            draw_cd(obj,4,x+champSize,y+ultSize,summ1.icon,ultSize,ultScale)
            draw_cd(obj,3,x+champSize,y+ultSize*2,ult.icon,ultSize,ultScale)
        end

        -- death + missing text
        if obj.isDead then
            local deathTime = timers[obj.charName].deathCD
            deathTime = string.format("%.0f",deathTime)
            local a,b = graphics.text_area(tostring(deathTime),textSizeDeath)
            a = (champSize - a) / 2
            b = ((champSize / 2) - (b / 2)) + 0.5*textSizeDeath
            graphics.draw_outlined_text_2D(deathTime,textSizeDeath,x+a,y+b,0xFFFF0000)
        elseif not obj.isVisible then
            local ssTime = timers[obj.charName].ssTime
            ssTime = string.format("%.0f",ssTime)
            local a,b = graphics.text_area(tostring(ssTime),textSizeDeath)
            a = (champSize - a) / 2
            b = ((champSize / 2) - (b / 2)) + 0.5*textSizeDeath
            graphics.draw_outlined_text_2D(ssTime,textSizeDeath,x+a,y+b,0xFFFFF216)
        end

        -- location
        if menu.awarenessmenu.hud.showLocation:get() then
            local location = getLocation(obj)
            graphics.draw_outlined_text_2D(location,textSize,x,y+ultSize*3+0.5*textSize,0xFFFFF216)
        end
    end

end

local function update_pos(x,y,style,direction,size,barSize,barBorder,ultSize)
    if menu.awarenessmenu:isopen() then
        if style == 1 then
            local expSize = 0
            if menu.awarenessmenu.hud.showExp:get() then
                expSize = menu.awarenessmenu.hud.customization.expSize:get()
            end
            local locationSize = 0
            if menu.awarenessmenu.hud.showLocation:get() then
                locationSize = textSize
            end
            local x1,y1 = x+size+(5*(ultSize)),y+(count*(size+menu.awarenessmenu.hud.customization.champSpacing:get()+expSize+locationSize))
            local width = x1-x
            local height = y1-y
            graphics.draw_outlined_text_2D("Click to drag",textSize,x,y-textSize,0xFFFFFFFF)
            local m = cursorPos
            if m.x > x and m.x < x1 and m.y > y and m.y < y1 then
                if keyboard.isKeyDown(1) then
                    x,y = m.x-width/2,m.y-height/2
                end
            end
        end
        if style == 2 then
            local expSize = 0
            if menu.awarenessmenu.hud.showExp:get() then
                expSize = menu.awarenessmenu.hud.customization.expSize:get()
            end
            local locationSize = 0
            if menu.awarenessmenu.hud.showLocation:get() then
                locationSize = textSize
            end
            local x1,y1 = x+(3*(ultSize)),y+(count*(2*ultSize+menu.awarenessmenu.hud.customization.champSpacing:get()+locationSize))
            local width = x1-x
            local height = y1-y
            graphics.draw_outlined_text_2D("Click to drag",textSize,x,y-textSize,0xFFFFFFFF)
            local m = cursorPos
            if m.x > x and m.x < x1 and m.y > y and m.y < y1 then
                if keyboard.isKeyDown(1) then
                    x,y = m.x-width/2,m.y-height/2
                end
            end
        end
        if style == 3 then
            local locationSize = 0
            if menu.awarenessmenu.hud.showLocation:get() then
                locationSize = textSize
            end
            if direction == 1 then
                local x1,y1 = x+size+ultSize,y+(count*(size+barSize+(3*barBorder)+menu.awarenessmenu.hud.customization.champSpacing:get()+locationSize))
                local width = x1-x
                local height = y1-y
                graphics.draw_outlined_text_2D("Click to drag",textSize,x,y-textSize,0xFFFFFFFF)
                local m = cursorPos
                if m.x > x and m.x < x1 and m.y > y and m.y < y1 then
                    if keyboard.isKeyDown(1) then
                        x,y = m.x-width/2,m.y-height/2
                    end
                end
            elseif direction == 2 then
                local x1,y1 = x+(count*(size+barSize+(3*barBorder)+menu.awarenessmenu.hud.customization.champSpacing:get())),y+size+ultSize+locationSize
                local width = x1-x
                local height = y1-y
                graphics.draw_outlined_text_2D("Click to drag",textSize,x,y-textSize,0xFFFFFFFF)
                local m = cursorPos
                if m.x > x and m.x < x1 and m.y > y and m.y < y1 then
                    if keyboard.isKeyDown(1) then
                        x,y = m.x-width/2,m.y-height/2
                    end
                end
            end
        end
    end
    menu.awarenessmenu.hud.customization.x:set('value',x)
    menu.awarenessmenu.hud.customization.y:set('value',y)
    return x,y
end
local x = menu.awarenessmenu.hud.customization.x:get()
local y = menu.awarenessmenu.hud.customization.y:get()
local function draw_hud(style, direction)


    scale = 0.4 * menu.awarenessmenu.hud.customization.scale:get()/100
    local size = 120 * scale
    textSize = 14 * menu.awarenessmenu.hud.customization.textSize:get()/100
    textSizeDeath = 30 * menu.awarenessmenu.hud.customization.deathSize:get()/100
    local champSpacing = menu.awarenessmenu.hud.customization.champSpacing:get()

    if style == 1 then -- only vertical!
        local barBorder = menu.awarenessmenu.hud.customization.barBorder:get()
        local ultSize = size/2

        local barSize = ultSize-3*barBorder
        x,y = update_pos(x,y,style,direction,size,barSize,barBorder,ultSize) 
        local heroes = objManager.enemies
        local count = objManager.enemies_n

        local locationSize = 0
        if menu.awarenessmenu.hud.showLocation:get() then
            locationSize = textSize
        end

        for i=0, count-1 do
            local obj = heroes[i]
            draw_champ(obj, style, x, y+i*(size+champSpacing+locationSize), size,ultSize,barSize,barBorder)
        end
    elseif style == 2 then -- only vertical!
        local barBorder = menu.awarenessmenu.hud.customization.barBorder:get()
        local ultSize = size/2
        size = size/2

        local barSize = ultSize-3*barBorder
        x,y = update_pos(x,y,style,direction,size,barSize,barBorder,ultSize) 
        local heroes = objManager.enemies
        local count = objManager.enemies_n

        local locationSize = 0
        if menu.awarenessmenu.hud.showLocation:get() then
            locationSize = textSize
        end

        for i=0, count-1 do
            local obj = heroes[i]
            draw_champ(obj, style, x, y+i*(ultSize*2+champSpacing+locationSize), size,ultSize,barSize,barBorder)
        end    
    elseif style == 3 then
        local barSize = menu.awarenessmenu.hud.customization.barSize:get()
        local barBorder = menu.awarenessmenu.hud.customization.barBorder:get()
        local ultSize = (size+barSize+(3*barBorder))/3
        if menu.awarenessmenu.hud.showExp:get() then
            ultSize = (size+barSize+(4*barBorder)+menu.awarenessmenu.hud.customization.expSize:get())/3
        end
        local locationSize = 0
        if menu.awarenessmenu.hud.showLocation:get() then
            locationSize = textSize
        end
        
        x,y = update_pos(x,y,style,direction,size,barSize,barBorder,ultSize)
        if direction == 1 then -- vertical
            local heroes = objManager.enemies
            local count = objManager.enemies_n
            for i=0, count-1 do
                local obj = heroes[i]
                draw_champ(obj, style, x, y+i*(size+barSize+barBorder*3+champSpacing+menu.awarenessmenu.hud.customization.expSize:get()+locationSize), size,ultSize,barSize,barBorder)
            end
        elseif direction == 2 then -- horizontal
            local heroes = objManager.enemies
            local count = objManager.enemies_n
            for i=0, count-1 do
                local obj = heroes[i]
                draw_champ(obj, style, x+i*(size+ultSize+champSpacing), y, size,ultSize,barSize,barBorder)
            end
        end
    end
end

local function update_timers()
    -- god bless wiki
    local BRW = {
        [1] = 6,
        [2] = 6,
        [3] = 8,
        [4] = 8,
        [5] = 10,
        [6] = 12,
        [7] = 16,
        [8] = 21,
        [9] = 26,
        [10] = 32.5,
        [11] = 35,
        [12] = 37.5,
        [13] = 40,
        [14] = 42.5,
        [15] = 45,
        [16] = 47.5,
        [17] = 50,
        [18] = 52.5,
    }
    local TIF = 0
    if game.time >= 900 and game.time < 1800 then
        TIF = 0 + math.ceil(2*((game.time/60)-15))*0.425/100
    elseif game.time >= 1800 and game.time < 2700 then
        TIF = (12.75 + math.ceil(2*((game.time/60)-30))*0.3)/100
    elseif game.time >= 2700 then
        TIF = (21.75 + math.ceil(2*((game.time/60)-45))*1.45)/100
    end
    TIF = math.min(TIF,0.5)
    -- chat.print(TIF)
    local heroes = objManager.enemies
    local count = objManager.enemies_n
    for i=0, count-1 do
        local obj = heroes[i]
        if obj.isDead then
            if game.mapID == 11 then -- SR
                timers[obj.charName].deathCD = (BRW[obj.levelRef] + BRW[obj.levelRef]*TIF) - (game.time - obj.deathTime)
            else -- ARAM and shit
                timers[obj.charName].deathCD = ((obj.levelRef * 2) + 4) - (game.time - obj.deathTime)
            end
        end
        if timers[obj.charName].visible ~= obj.isVisible and not obj.isVisible then
            timers[obj.charName].ssT = game.time
        end
        timers[obj.charName].ssTime = game.time - timers[obj.charName].ssT
        timers[obj.charName].visible = obj.isVisible
    end
end

local function on_draw()
    if game.shopOpen then
        return
    end
    if not menu.awarenessmenu.hud.show:get() then return end

    -- location
    -- local location = getLocation(player)
    -- graphics.draw_outlined_text_2D(location,30,500,500,0xFFFFFFFF)

    x = menu.awarenessmenu.hud.customization.x:get()
    y = menu.awarenessmenu.hud.customization.y:get()
    local style = menu.awarenessmenu.hud.style:get()
    local direction = menu.awarenessmenu.hud.direction:get()

    update_timers()

    draw_hud(style, direction)
end

cb.add(cb.draw,on_draw)