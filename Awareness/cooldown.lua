local orb = module.internal("orb");
local ts = module.internal("TS");
local pred = module.internal("pred");
local damagelib = module.internal("damagelib");

local common = module.load("Dalandan_AIO", "common");
local menu = module.load("Dalandan_AIO", "menu");

local colorCooldown = 0xFF555555
local colorReady = 0xFFFFFFFF 
local scale = 1
local textSize = 15


local function draw_cd(obj,spellslot, x,y,icons,size)

    -- im dumb :(
    local trueCooldown = obj:spellSlot(spellslot).cooldown
    if obj:spellSlot(spellslot).stacks == 0 and obj:spellSlot(spellslot).stacksCooldown ~= 0 then
        trueCooldown = obj:spellSlot(spellslot).stacksCooldown
    elseif obj:spellSlot(spellslot).stacks ~= 0 then
        trueCooldown = obj:spellSlot(spellslot).cooldown
    end

    if trueCooldown == 0 and obj:spellSlot(spellslot).level >= 1 then
        if menu.awarenessmenu.cdtracker.border:get() then
            graphics.draw_rectangle_2D(x-1, y-1, size+1, size+1, menu.awarenessmenu.cdtracker.borderSize:get(), menu.awarenessmenu.cdtracker.MyColor:get(), false)
        end
        graphics.draw_sprite(icons[spellslot+1],vec2(x,y),scale,colorReady)
    elseif obj:spellSlot(spellslot).level >= 1 then
        if menu.awarenessmenu.cdtracker.border:get() then
            graphics.draw_rectangle_2D(x-1, y-1, size+1, size+1, menu.awarenessmenu.cdtracker.borderSize:get(), menu.awarenessmenu.cdtracker.MyColor:get(), false)
        end
        graphics.draw_sprite(icons[spellslot+1],vec2(x,y),scale,colorCooldown)
        local cooldown = string.format("%.1f", trueCooldown)
        if trueCooldown >= 100 then
            cooldown = string.format("%.0f", trueCooldown)
        end
        local a,b = graphics.text_area(tostring(cooldown),textSize)
        -- ive no fuckin idea where center of text is, so it's shit
        -- too bad.
        a = (size - a) / 2
        b = ((size / 2) - (b / 2)) + 0.5*textSize
        graphics.draw_text_2D(cooldown,textSize,x+a,y+b,0xFFFFFFFF)
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
    scale = 1
    textSize = 15
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
    elseif common.highRes == 3 then --1440
        x = x + 292
        y = y + 248
        scale = 0.75
        textSize = 25
    end

    size = (64 * scale) + 1

    -- spell
    draw_cd(obj,0,x,y,icons,size)
    draw_cd(obj,1,x+size,y,icons,size)
    draw_cd(obj,2,x+2*size,y,icons,size)
    draw_cd(obj,3,x+3*size,y,icons,size)
    draw_cd(obj,4,x+4*size,y,icons,size)
    draw_cd(obj,5,x+4*size,y-size,icons,size)

end

local function on_draw()
    -- local v = graphics.world_to_screen(mousePos)
    -- graphics.draw_text_2D("xd",100,v.x,v.y,0xFFFFFFFF)
    if not menu.awarenessmenu.cdtracker.show:get() then return end
    local heroes = objManager.allies
    local count = objManager.allies_n
    for i=0, count-1 do
        local obj = heroes[i]
        local show = false
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
    end

    heroes = objManager.enemies
    count = objManager.enemies_n
    for i=0, count-1 do
        local obj = heroes[i]
        if not menu.awarenessmenu.cdtracker.enemy:get() then break end

        if not obj.isDead and obj.isOnScreen and obj.isVisible then 
            drawSpells(obj) 
        end
    end
end

cb.add(cb.draw,on_draw)