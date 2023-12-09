local orb = module.internal("orb");
local ts = module.internal("TS");
local pred = module.internal("pred");
local damagelib = module.internal("damagelib");

local common = module.load("Dalandan_AIO", "common");
local menu = module.load("Dalandan_AIO", "menu");

local function on_draw()
    if menu.awarenessmenu.aa.show:get() then
        for i,target in pairs(common.GetEnemyHeroes()) do
            if target.isOnScreen and target.isVisible and not target.isDead then
                local color = menu.awarenessmenu.aa.MyColor:get()
                local size = menu.awarenessmenu.aa.size:get()
                local hp = target.health
                local howManyAA = 0
                local aaDmg = damagelib.calc_aa_damage(player,target,true)
                while hp > 0 do
                    howManyAA  = howManyAA + 1
                    hp = hp - aaDmg
                    aaDmg = damagelib.calc_aa_damage(player,target,false)
                end
                local v = graphics.world_to_screen(target.pos)
                graphics.draw_outlined_text_2D('AA: '..howManyAA,size,v.x,v.y+25,color)
            end
        end
    end
end

cb.add(cb.draw,on_draw)