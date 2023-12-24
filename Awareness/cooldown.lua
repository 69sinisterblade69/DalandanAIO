local orb = module.internal("orb");
local ts = module.internal("TS");
local pred = module.internal("pred");
local damagelib = module.internal("damagelib");

local common = module.load("Dalandan_AIO", "common");
local menu = module.load("Dalandan_AIO", "menu");

local MenuColor = menu.awarenessmenu.cdtracker.cdColor:get()
local colorCooldown = graphics.argb(255,MenuColor,MenuColor,MenuColor)
local colorReady = 0xFFFFFFFF 
local scale = 0.4
local textSize = 15

-- KYS KYS
-- btw brian pls no skid ok? 
local fuck_my_shit = {}

local function on_process_spell(spell)
    if spell.owner.type==TYPE_HERO and spell.slot >= 6 and spell.slot <= 11 and menu.awarenessmenu.cdtracker.item:get() then
        -- print(os.clock(), spell.name, spell.slot)
        if fuck_my_shit[spell.owner.name] == nil then
            fuck_my_shit[spell.owner.name] = {}
        end
        local cooldown = 0
        if spell.name == "ZhonyasHourglass" or spell.name == "6671Cast" or spell.name == "3222Active" then
            cooldown = 120
        end
        if spell.name == "YoumusBlade" then
            cooldown = 45
        end
        if spell.name == "QuicksilverSash" or spell.name == "ItemMercurial" or spell.name == "6035_Spell" or spell.name == "ItemRedemption" or spell.name == "3190Active" or spell.name == "Item3193Active" then
            cooldown = 90
        end        
        if spell.name == "6630Active" or spell.name == "6631Active" then
            cooldown = 12
        end        
        if spell.name == "RanduinsOmen" then
            cooldown = 60
        end        
        if spell.name == "6656Cast" then
            cooldown = 30
        end
        if spell.name == "3152Active" then
            cooldown = 40
        end 
        if spell.name == "2065Active" then
            cooldown = 70
        end 
        
        local time = game.time
        fuck_my_shit[spell.owner.name][spell.name] = {
            cooldown = cooldown,
            time = time,
            cd = 0,
            trueTime = 0,
        }
    end
end

cb.add(cb.spell, on_process_spell)


-- KYS KYS KYS KYS KYS 
-- why cant spellslot cooldown just work for items
-- KYS KYS KYS KYS KYS
local function cdShit()
    if menu.awarenessmenu.cdtracker.item:get() then
        for name, shit in pairs(fuck_my_shit) do
            if shit and name then
                for spell, cd in pairs(shit) do
                    if spell then
                        fuck_my_shit[name][spell].cd = game.time - fuck_my_shit[name][spell].time
                        fuck_my_shit[name][spell].trueTime = fuck_my_shit[name][spell].cooldown - fuck_my_shit[name][spell].cd
                        if fuck_my_shit[name][spell].trueTime < 0 then
                            fuck_my_shit[name][spell].trueTime = 0
                        end
                        -- print(os.clock(), tostring(spell), fuck_my_shit[name][spell].trueTime)
                    end
                end
            end
        end
    end
end

cb.add(cb.draw, cdShit)
-- KYS KYS

local function draw_cd(obj,spellslot, x,y,icon,size)

    -- im dumb :(
    local trueCooldown = obj:spellSlot(spellslot).cooldown
    if obj:spellSlot(spellslot).stacks == 0 and obj:spellSlot(spellslot).stacksCooldown ~= 0 then
        trueCooldown = obj:spellSlot(spellslot).stacksCooldown
    elseif obj:spellSlot(spellslot).stacks ~= 0 then
        trueCooldown = obj:spellSlot(spellslot).cooldown
    end

    local borderColor = menu.awarenessmenu.cdtracker.borderr.MyColor:get()
    if trueCooldown == 0 and obj:spellSlot(spellslot).level >= 1 then
        if menu.awarenessmenu.cdtracker.borderr.border:get() then
            if menu.awarenessmenu.cdtracker.borderr.borderChange:get() then
                borderColor = menu.awarenessmenu.cdtracker.borderr.MyColorReady:get()
            end
            graphics.draw_rectangle_2D(x-1, y-1, size+2, size+2, menu.awarenessmenu.cdtracker.borderr.borderSize:get(), borderColor, false)
        end
        graphics.draw_sprite(icon,vec2(x,y),scale,colorReady)
    elseif obj:spellSlot(spellslot).level >= 1 then
        if menu.awarenessmenu.cdtracker.borderr.border:get() and not menu.awarenessmenu.cdtracker.borderr.borderReady:get() then
            if menu.awarenessmenu.cdtracker.borderr.borderChange:get() then
                borderColor = menu.awarenessmenu.cdtracker.borderr.MyColorCD:get()
            end
            graphics.draw_rectangle_2D(x-1, y-1, size+2, size+2, menu.awarenessmenu.cdtracker.borderr.borderSize:get(), borderColor, false)
        end
        graphics.draw_sprite(icon,vec2(x,y),scale,colorCooldown)
        local cooldown = string.format("%.1f", trueCooldown)
        if trueCooldown >= 100 then
            cooldown = string.format("%.0f", trueCooldown)
        end
        local a,b = graphics.text_area(tostring(cooldown),textSize)
        -- ive no fuckin idea where center of text is, so it's shit
        -- too bad.
        a = (size - a) / 2
        b = ((size / 2) - (b / 2)) + 0.5*textSize
        a = a + menu.awarenessmenu.cdtracker.customization.cdX:get()
        b = b + menu.awarenessmenu.cdtracker.customization.cdY:get()
        graphics.draw_outlined_text_2D(cooldown,textSize,x+a,y+b,0xFFFFFFFF)
    end

    if menu.awarenessmenu.cdtracker.level:get() and obj:spellSlot(spellslot).level >= 1 and spellslot >= 0 and spellslot <= 3 then
        local lvlSize = size/6
        local space = lvlSize/4
        local count = 0
        local menuX = menu.awarenessmenu.cdtracker.customization.levelX:get()
        local menuY = menu.awarenessmenu.cdtracker.customization.levelY:get()
        -- chat.print(size)
        if menu.awarenessmenu.cdtracker.level_type:get() == 1 then -- rectangle
            for i=1, obj:spellSlot(spellslot).level do
                graphics.draw_rectangle_2D(x+(lvlSize*count)+(space*count)+menuX, y+size+menu.awarenessmenu.cdtracker.borderr.borderSize:get()+4+menuY, lvlSize , lvlSize*2, 0, menu.awarenessmenu.cdtracker.skill_color:get(), true)
                count = count + 1
            end
        elseif menu.awarenessmenu.cdtracker.level_type:get() == 2 then -- dots outside
            for i=1, obj:spellSlot(spellslot).level do
                graphics.draw_circle_2D(x+(lvlSize*count)+(space*count)+(lvlSize/2)+menuX, y+size+menu.awarenessmenu.cdtracker.borderr.borderSize:get()+4+menuY, lvlSize/3 , lvlSize/2, menu.awarenessmenu.cdtracker.skill_color:get(), 8)
                count = count + 1
            end
        elseif menu.awarenessmenu.cdtracker.level_type:get() == 3 then -- dots inside
            for i=1, obj:spellSlot(spellslot).level do
                graphics.draw_circle_2D(x+(lvlSize*count)+(space*count)+(lvlSize/2)+menuX, y+size-4+menuY, lvlSize/3 , lvlSize/2, menu.awarenessmenu.cdtracker.skill_color:get(), 8)
                count = count + 1
            end
        elseif menu.awarenessmenu.cdtracker.level_type:get() == 4 then -- number
            local text = obj:spellSlot(spellslot).level
            local a,b = graphics.text_area(tostring(cooldown),textSize)
            -- ive no fuckin idea where center of text is, so it's shit
            -- too bad.
            a = (size - a) / 2
            b = ((size / 2) - (b / 2)) + 0.5*textSize
            a = a + menuX
            b = b + menuY
            graphics.draw_outlined_text_2D(text,textSize,x+a,y+3*b,menu.awarenessmenu.cdtracker.skill_color:get())
        end
    end
end

-- KYS KYS KYS KYS
local function draw_shit_cd(obj,spellslot, x,y,icon,size, item)

    local ShitList = {
        [3157] = "ZhonyasHourglass",
        [6671] = "6671Cast",
        [3142] = "YoumusBlade",
        [3140] = "QuicksilverSash",
        [3139] = "ItemMercurial",
        [6035] = "6035_Spell",
        [6630] = "6630Active",
        [6631] = "6631Active",
        [6029] = "6029Active",
        [3143] = "RanduinsOmen",
        [6656] = "6656Cast",
        [3152] = "3152Active",
        [2065] = "2065Active",
        [3222] = "3222Active",
        [3107] = "ItemRedemption",
        [3190] = "3190Active",
        [3193] = "Item3193Active",
    }

    -- -- im dumb :(
    local trueCooldown
    for name, shit in pairs(fuck_my_shit) do
        if shit and name then
            for spell, cd in pairs(shit) do
                if spell then
                    if fuck_my_shit[name][ShitList[item]] then
                        trueCooldown = fuck_my_shit[name][ShitList[item]].trueTime
                    end
                end
            end
        end
    end
    if not trueCooldown then
        trueCooldown = 0
    end

    local borderColor = menu.awarenessmenu.cdtracker.borderr.MyColor:get()
    if trueCooldown == 0 and obj:spellSlot(spellslot).level >= 1 then
        if menu.awarenessmenu.cdtracker.borderr.border:get() then
            if menu.awarenessmenu.cdtracker.borderr.borderChange:get() then
                borderColor = menu.awarenessmenu.cdtracker.borderr.MyColorReady:get()
            end
            graphics.draw_rectangle_2D(x-1, y-1, size+2, size+2, menu.awarenessmenu.cdtracker.borderr.borderSize:get(), borderColor, false)
        end
        graphics.draw_sprite(icon,vec2(x,y),scale,colorReady)
    elseif obj:spellSlot(spellslot).level >= 1 then
        if menu.awarenessmenu.cdtracker.borderr.border:get() and not menu.awarenessmenu.cdtracker.borderr.borderReady:get() then
            if menu.awarenessmenu.cdtracker.borderr.borderChange:get() then
                borderColor = menu.awarenessmenu.cdtracker.borderr.MyColorCD:get()
            end
            graphics.draw_rectangle_2D(x-1, y-1, size+2, size+2, menu.awarenessmenu.cdtracker.borderr.borderSize:get(), borderColor, false)
        end
        graphics.draw_sprite(icon,vec2(x,y),scale,colorCooldown)

        local cooldown = string.format("%.1f", trueCooldown)
        if trueCooldown >= 100 then
            cooldown = string.format("%.0f", trueCooldown)
        end
        local a,b = graphics.text_area(tostring(cooldown),textSize)
        -- ive no fuckin idea where center of text is, so it's shit
        -- too bad.
        a = (size - a) / 2
        b = ((size / 2) - (b / 2)) + 0.5*textSize
        a = a + menu.awarenessmenu.cdtracker.customization.cdX:get()
        b = b + menu.awarenessmenu.cdtracker.customization.cdY:get()
        graphics.draw_outlined_text_2D(cooldown,textSize,x+a,y+b,0xFFFFFFFF)
    end
end

local function drawSpells(obj)
    local icons = {
        obj:spellSlot(0).icon,
        obj:spellSlot(1).icon,
        obj:spellSlot(2).icon,
        obj:spellSlot(3).icon,
        obj:spellSlot(4).icon,
        obj:spellSlot(5).icon,
    }

    local x = obj.barPos.x
    local y = obj.barPos.y
    if common.highRes == 1 then --1080p
        x = x + 164
        y = y + 138
        scale = 0.4
        textSize = 15
    elseif common.highRes == 2 then --1440
        x = x + 196
        y = y + 165
        scale = 0.48
        textSize = 18
    elseif common.highRes == 3 then --4k
        x = x + 292
        y = y + 248
        scale = 0.75
        textSize = 25
    end
    
    x = x + menu.awarenessmenu.cdtracker.customization.x:get()
    y = y + menu.awarenessmenu.cdtracker.customization.y:get()
    scale = scale * menu.awarenessmenu.cdtracker.customization.scale:get()/100
    textSize = textSize * menu.awarenessmenu.cdtracker.customization.textSize:get()/100

    size = (64 * scale)
    local spaceX = menu.awarenessmenu.cdtracker.customization.spaceX:get()
    local spaceY = menu.awarenessmenu.cdtracker.customization.spaceY:get()

    if menu.awarenessmenu.cdtracker.customization.some_champs:get() then
        if obj.charName == "Annie" or obj.charName == "Jhin" or obj.charName == "Samira" or obj.charName == "Rengar" or
        (obj.charName == "Corki" and obj.levelRef >= 6) or obj.charName == "Aphelios" or obj.charName == "Graves" or 
        obj.charName == "Gwen" or obj.charName == "Irelia" or obj.charName == "Ryze" or obj.charName == "Riven" or
        obj.charName == "Sona" or obj.charName == "Syndra" then
            y = y + menu.awarenessmenu.cdtracker.customization.some_champs_value:get()
        end
    end

    -- spell
    draw_cd(obj,0,x,y,icons[1],size)
    draw_cd(obj,1,x+size+spaceX,y,icons[2],size)
    draw_cd(obj,2,x+2*size+2*spaceX,y,icons[3],size)
    draw_cd(obj,3,x+3*size+3*spaceX,y,icons[4],size)
    if menu.awarenessmenu.cdtracker.tracker_style:get() == 1 then
        draw_cd(obj,4,x+4*size+4*spaceX,y,icons[5],size)
        draw_cd(obj,5,x+4*size+4*spaceX,y-size-spaceY,icons[6],size)
    elseif menu.awarenessmenu.cdtracker.tracker_style:get() == 2 then
        draw_cd(obj,4,x+4*size+4*spaceX,y-size-spaceY,icons[5],size)
        draw_cd(obj,5,x+5*size+5*spaceX,y-size-spaceY,icons[6],size)
    end


    if menu.awarenessmenu.cdtracker.item:get() then
        local items_to_check = {}
        if menu.awarenessmenu.cdtracker.item_select.zhonya:get() then
            table.insert(items_to_check,3157)
            table.insert(items_to_check,2420)
            -- table.insert(items_to_check,2419)
            table.insert(items_to_check,2423)
        end
        if menu.awarenessmenu.cdtracker.item_select.randuin:get() then
            table.insert(items_to_check,3143)
        end
        if menu.awarenessmenu.cdtracker.item_select.youmuu:get() then
            table.insert(items_to_check,3142)
        end
        if menu.awarenessmenu.cdtracker.item_select.galeforce:get() then
            table.insert(items_to_check,6671)
        end
        -- if menu.awarenessmenu.cdtracker.item_select.ga:get() then
        --     table.insert(items_to_check,3026) 
        -- end
        if menu.awarenessmenu.cdtracker.item_select.goredrinker:get() then
            table.insert(items_to_check,6630)
            table.insert(items_to_check,6029)
            table.insert(items_to_check,6631) 
        end
        
        -- if menu.awarenessmenu.cdtracker.item_select.crown:get() then
        --     table.insert(items_to_check,4644) 
        -- end
        if menu.awarenessmenu.cdtracker.item_select.qss:get() then
            table.insert(items_to_check,3140) 
            table.insert(items_to_check,3139) 
            table.insert(items_to_check,6035) 
        end
        if menu.awarenessmenu.cdtracker.item_select.everfrost:get() then
            table.insert(items_to_check,6656) 
        end
        if menu.awarenessmenu.cdtracker.item_select.rocketbelt:get() then
            table.insert(items_to_check,3152) 
        end
        if menu.awarenessmenu.cdtracker.item_select.shurelya:get() then
            table.insert(items_to_check,2065) 
        end
        if menu.awarenessmenu.cdtracker.item_select.redemption:get() then
            table.insert(items_to_check,3107) 
        end
        if menu.awarenessmenu.cdtracker.item_select.mikael:get() then
            table.insert(items_to_check,3222) 
        end
        -- if menu.awarenessmenu.cdtracker.item_select.shieldbow:get() then
        --     table.insert(items_to_check,6673) 
        -- end
        if menu.awarenessmenu.cdtracker.item_select.solari:get() then
            table.insert(items_to_check,3190) 
        end
        if menu.awarenessmenu.cdtracker.item_select.gargoyle:get() then
            table.insert(items_to_check,3193) 
        end
        -- if menu.awarenessmenu.cdtracker.item_select.banshee:get() then
        --     table.insert(items_to_check,3102) 
        -- end
        -- --
        -- if menu.awarenessmenu.cdtracker.item_select.archangel:get() then
        --     table.insert(items_to_check,3040) 
        -- end

        local countX = 0
        if menu.awarenessmenu.cdtracker.level:get() and menu.awarenessmenu.cdtracker.level_type:get() == 1 or menu.awarenessmenu.cdtracker.level_type:get() == 2 or menu.awarenessmenu.cdtracker.level_type:get() == 4 then
            spaceY = spaceY + menu.awarenessmenu.cdtracker.borderr.borderSize:get()+4 + (3*(size/6))
        end

        for j, item in pairs(items_to_check) do
            for i=0, 5 do
                if obj:itemID(i) == item then
                    local icon = obj:spellSlot(6+i).icon
                    
                    -- some items are just retarded :/
                    -- cuz player:inventorySlot(0).icon doesn't work
                    if item == 2420 or item == 2423 then
                        icon = graphics.sprite("Sprites/items/2420.png")
                    end
                    if item == 3026 then
                        icon = graphics.sprite("Sprites/items/3026.png")
                    end
                    if item == 4644 then
                        icon = graphics.sprite("Sprites/items/4644.png")
                    end
                    if item == 3139 then
                        icon = graphics.sprite("Sprites/items/3139.png")
                    end
                    if item == 3140 then
                        icon = graphics.sprite("Sprites/items/3140.png")
                    end
                    if item == 6035 then
                        icon = graphics.sprite("Sprites/items/6035.png")
                    end
                    if item == 3222 then
                        icon = graphics.sprite("Sprites/items/3222.png")
                    end
                    if item == 6673 then
                        icon = graphics.sprite("Sprites/items/6673.png")
                    end
                    if item == 3040 then
                        icon = graphics.sprite("Sprites/items/3040.png")
                    end
                    if item == 3193 then
                        icon = graphics.sprite("Sprites/items/3193.png")
                    end
                    if item == 3102 then
                        icon = graphics.sprite("Sprites/items/3102.png")
                    end
                    if item == 6029 then
                        icon = graphics.sprite("Sprites/items/6029.png")
                    end

                    if menu.awarenessmenu.cdtracker.tracker_style:get() == 1 then
                        -- draw_cd(obj,6+i,x+countX*size+countX*spaceX,y+size+spaceY,icon,size)
                        draw_shit_cd(obj,6+i,x+countX*size+countX*spaceX,y+size+spaceY,icon,size,item)
                    elseif menu.awarenessmenu.cdtracker.tracker_style:get() == 2 then
                        draw_shit_cd(obj,6+i,x+4*size+4*spaceX+countX*size+countX*spaceX,y,icon,size,item)
                    end

                    countX = countX + 1
                end
            end
        end
    end

end

local function on_draw()
    if game.shopOpen then
        return
    end
    if not menu.awarenessmenu.cdtracker.show:get() then return end

    MenuColor = menu.awarenessmenu.cdtracker.cdColor:get()
    colorCooldown = graphics.argb(255,MenuColor,MenuColor,MenuColor)

    if menu.awarenessmenu.cdtracker.enemy:get() then
        local heroesS = objManager.enemies
        local countT = objManager.enemies_n
        for i=0, countT-1 do
            local obj = heroesS[i]
            if menu.awarenessmenu.cdtracker.yuumi:get() then
                if obj.charName == "Yuumi" then
                    goto Y
                end
            end
            if not obj.isDead and obj.isOnScreen and obj.isVisible then 
                drawSpells(obj) 
            end
            ::Y::
        end
    end

    if menu.awarenessmenu.cdtracker.self:get() or menu.awarenessmenu.cdtracker.ally:get() then
        local heroes = objManager.allies
        local count = objManager.allies_n
        for i=0, count-1 do
            local obj = heroes[i]
            local show = false
            if menu.awarenessmenu.cdtracker.yuumi:get() then
                if obj.charName == "Yuumi" then
                    goto YY
                end
            end
            if menu.awarenessmenu.cdtracker.self:get() and obj == player then
                show = true
            end
            if menu.awarenessmenu.cdtracker.ally:get() and obj ~= player then
                show = true
            end
            if show then
                if not obj.isDead and obj.isOnScreen and obj.isVisible then 
                    drawSpells(obj) 
                end
            end
            ::YY::
        end
    end

end

cb.add(cb.draw,on_draw)