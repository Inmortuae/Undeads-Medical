Hook.Add("nanobots.onUse", function(effect, deltaTime, item, targets, worldPosition)
    
    -- Local Definitions
    local target = targets[1]
    local char = effect.user
    local targetType = tostring(target)
    
    -- Check if target is either Human or Humanhusk
    if targetType == "Human" or targetType == "Humanhusk" then

        -- Revive the target and set affliction
        HF.RemoveItem(item)
        HF.SetAffliction(target, "nanobots", 100)
        
        regen(target, target.worldPosition, char)
        
    end

end)
