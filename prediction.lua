-- "inspired" by league sharp prediction :)
local ts = module.internal("TS");
local pred = module.internal("pred");
local orb = module.internal("orb");

prediction = {}
hitchance = {
    COLLISION = 0,
    OUT_OF_RANGE = 1,
    IMPOSSIBLE = 2,
    LOW = 3,
    MEDIUM = 4,
    HIGH = 5,
    VERY_HIGH = 6,
    DASHING = 7,
    IMMOBILE = 8,
}
function prediction.getPredPos(target,delay,input)
    local delay = delay or 0
    local predPos = pred.core.get_pos_after_time(target, delay)
    predPos = predPos:toGame3D()
    local targetPos = pred.present.get_source_pos(target)
    targetPos = targetPos:toGame3D()
    local predHitchance = hitchance.IMPOSSIBLE
    
    -- idk do it better?? new func?? 
    -- does that one even work correctly???
    -- chat.print(target.charName.." "..target.moveSpeed * delay)
    -- if target.moveSpeed * delay < (input.width or input.radius) then
    --     predHitchance = hitchance.VERY_HIGH
    -- end
    
    return predPos,predHitchance
end

return prediction