Hook.Add("revive_syringe.onUse", function(effect, deltaTime, item, targets, worldPosition)

    -- Local Definitions
    local target = targets[1]
    local char = effect.user
    local targetType = tostring(target)
    local NTIn = NTCompat.isNTactive()
    local headLimb = target.AnimController:GetLimb(LimbType.Head)

    -- Check if target is either Human or Humanhusk
    if targetType == "Human" or targetType == "Humanhusk" then
        -- Check if RS_Affliction is true
        if RSConfig.Get("RS_Affliction", true) then
            -- Check if target has revived affliction
            if HF.HasAffliction(target, "revived", 100) then
                return -- Do not allow reviving
            end
        end

        if RSConfig.Get("NOREV", true) then
            -- Check if target has revived afflictions
            if  HF.HasAffliction(target, "pressure", 1) or
                HF.HasAffliction(target, "gunshotwound", 190) or
                HF.HasAffliction(target, "bloodloss", 100) or
                headLimb == nil then
                    return -- Do not allow reviving
            end

            -- surgical head amputation and traumatic head amputation
            if HF.HasAffliction(target, "sh_amputation", 1) or HF.HasAffliction(target, "th_amputation", 1) then
                return
            end
        end

        if RSConfig.Get("FD", true) or RSConfig.Get("RS_VanillaDMG", true) or RSConfig.Get("NTRS", true) then
            -- Revive the target and set affliction (fixed death)
            HF.RemoveItem(item)
            regen(target, target.worldPosition, char)
        else
            -- Revive the target and set affliction (real death)
            HF.SetAffliction(target, "pressure", 0)
            HF.SetAffliction(target, "givein", 0)

            if NTIn then
                if HF.HasAffliction(target, "th_amputation", 1) then
                    HF.SetAffliction(target, "th_amputation", 0)
                end

                if HF.HasAffliction(target, "sh_amputation", 1) then
                    HF.SetAffliction(target, "sh_amputation", 0)
                end
            end
           
            local afflictions = target.CharacterHealth.GetAllAfflictions()

            -- Convert afflictions from EnumerableWrapper to Lua table
            local afflictionTable = {}
            if type(afflictions) == "userdata" then
                for affliction in afflictions do
                    table.insert(afflictionTable, affliction)
                end
            else
                afflictionTable = afflictions
            end
            
            -- Proceed with the rest of the code
            local limbTypes = {
                LimbType.Head,
                LimbType.Torso,
                LimbType.RightArm,
                LimbType.LeftArm,
                LimbType.RightLeg,
                LimbType.LeftLeg
            }
            
            for _, limbType in ipairs(limbTypes) do
                for _, affliction in ipairs(afflictionTable) do
                    local affName = affliction.Prefab.Identifier
                    local severity = affliction.Strength
            
                    -- Ensure severity is set to 30 if it exceeds 30
                    if severity >= 30 then
                        severity = 30
                    end
            
                    -- Check if the limb has the affliction
                    if HF.HasAfflictionLimb(target, affName, limbType) then
                        HF.SetAfflictionLimb(target, affName, limbType, severity)
                    end
                end
            end              
            
            Timer.Wait(function () 
                target.Revive(false, true)
                local clientCharacter = Util.FindClientCharacter(target)
                if clientCharacter then
                    clientCharacter.SetClientCharacter(target)
                end
            end, 1)
            HF.RemoveItem(item)
            ApplySavedAfflictions(target)
        end
    end

end)
