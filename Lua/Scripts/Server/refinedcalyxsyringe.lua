Hook.Add("refinedcalyx_syringe.onUse", function(effect, deltaTime, item, targets, worldPosition)

    -- Local Definitions
    local target = targets[1]
    local char = effect.user

    local hasSymbiosis = HF.HasAffliction(target, "husksymbiosis", 1)
    local firedFromGun = item.ParentInventory == nil -- If the syringe is not in an inventory, it was likely fired

    if hasSymbiosis then
        if not firedFromGun and char ~= nil and char.Inventory ~= nil then
            HF.GiveItem(char, "symbiosis_syringe")
        else
            HF.SpawnItemAt("symbiosis_syringe", target.WorldPosition)
        end
    end

    local hasHuskInfection = HF.HasAffliction(target, "huskinfection", 1)

    if not hasHuskInfection then
        local infectionAmount = math.random(75, 85)
        HF.SetAffliction(target, "huskinfection", infectionAmount)
    end

    HF.RemoveItem(item)

end)
