local common = module.load("Dalandan_AIO", "common");
local menu = module.load("Dalandan_AIO", "menu");

local allies = {}
for i=0, objManager.allies_n-1 do
  local obj = objManager.allies[i]
  allies[i] = obj
end

local function troll()
    for i,obj in pairs(allies) do
        if objManager.allies_n > 1 and obj.charName == allies[menu.utilitymenu.TrollPing.selectedTroll:get()].charName and menu.utilitymenu.TrollPing.DoTroll:get() and obj.isAlive then
            ping.send(obj.pos, ping.MISSING_ENEMY)
        end
    end
end

common.SetInterval(troll, 5,9999999)