-- chat.print('[Dalandan AIO] Arena reloader Loading...')

if game.mapID ~= 30 then
    -- chat.print("[Dalandan AIO] Not arena :(")
    return
end

local delayedActions, delayedActionsExecuter = {}, nil
local function DelayAction(func, delay, args) --delay in seconds
  if not delayedActionsExecuter then
    function delayedActionsExecuter()
      for t, funcs in pairs(delayedActions) do
        if t <= os.clock() then
          for i = 1, #funcs do
            local f = funcs[i]
            if f and f.func then
              f.func(unpack(f.args or {}))
            end
          end
          delayedActions[t] = nil
        end
      end
    end
    cb.add(cb.tick, delayedActionsExecuter)
  end
  local t = os.clock() + (delay or 0)
  if delayedActions[t] then
    delayedActions[t][#delayedActions[t] + 1] = {func = func, args = args}
  else
    delayedActions[t] = {{func = func, args = args}}
  end
end

local last_shop = player.inShopRange

local function reload()
    core.reload()
end

local function on_tick()
    if player.charName == "Viego" then
        for i = 0, player.buffManager.count - 1 do
            local buff = player.buffManager:get(i)
            if buff and buff.valid and (buff.name == "viegopassivecasting" or buff.name == "viegopassivetransform") then 
                goto skip
            end
        end
    end
    if player.inShopRange ~= last_shop then
        DelayAction(reload,1)
    end
    ::skip::
    last_shop = player.inShopRange
end

cb.add(cb.tick, on_tick)
chat.print("[Dalandan AIO] Arena reloader loaded successfully!")