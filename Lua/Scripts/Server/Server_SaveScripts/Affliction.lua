local NTIn = NTCompat.isNTactive()
local NTCIn = NTCompat.isNTCactive()
local NTEIn = NTCompat.isNTEactive()

-- Function to collect all afflictions from a character upon death
function CollectAfflictionsOnDeath(character)
    if not character or not character.CharacterHealth then
        return {}
    end
    
    local afflictions = {}

    -- Define valid limb mappings for limb-specific afflictions
    local limbMapping = {}

    -- List of global afflictions (non-limb-specific)
    local globalAfflictions = {
        "abcplus", "ominus", "aminus", "bminus", "abminus", "abplus",
        "aplus", "oplus", "bplus"
    }

    -- NT afflictions
    if NTIn and RSConfig.Get("NTLRS", true) then
        local ntGAfflictions = {
            "tra_amputation",
            "tla_amputation",
            "trl_amputation",
            "tll_amputation",
            "sra_amputation",
            "sla_amputation",
            "srl_amputation",
            "sll_amputation"
        }
        for _, affliction in ipairs(ntGAfflictions) do
            table.insert(globalAfflictions, affliction)
        end

        if NTEIn and RSConfig.Get("NTERS", true) then
            local nteLAfflictions = {
                noeye = {LimbType.Head},
                eyesdead = {LimbType.Head},
                eyeone = {LimbType.Head},
                lefteyegone = {LimbType.Head},
                righteyegone = {LimbType.Head},
                eyelowbloodpressure = {LimbType.Head},
                eyedamage = {LimbType.Head},
                eyeshock = {LimbType.Head},
                eyedrop = {LimbType.Head},
                deusizinedrop = {LimbType.Head},
                eyesickness = {LimbType.Head},
                eyecataract = {LimbType.Head},
                eyemuscle = {LimbType.Head},
                eyegell = {LimbType.Head},
                eyenerve = {LimbType.Head},
                eyelid = {LimbType.Head},
                eyepopped = {LimbType.Head},
                corneaincision = {LimbType.Head},
                emulsification = {LimbType.Head},
                lasereyesurgery = {LimbType.Head},
                hasglasses = {LimbType.Head}
            }
            for affliction, limbs in pairs(nteLAfflictions) do
                limbMapping[affliction] = limbs  -- Directly insert key-value pairs
            end
        end
    end

    -- NTC afflictions
    if NTCIn and RSConfig.Get("NTCRS", true) then
        local ntcGAfflictions = {
            "ntc_cyberpsychosis",
            "ntc_cyberpsychosis_resistance",
            "ntc_cyberlung_pressure_recovery"
        }
        local ntcLAfflictions = {
            ntc_cyberarm = {LimbType.LeftArm, LimbType.RightArm},
            ntc_cyberleg = {LimbType.LeftLeg, LimbType.RightLeg},
            ntc_cyberlimb = {LimbType.LeftArm, LimbType.RightArm, LimbType.LeftLeg, LimbType.RightLeg},
            ntc_cyberliver = {LimbType.Torso},
            ntc_cyberkidney = {LimbType.Torso},
            ntc_cyberlung = {LimbType.Torso},
            ntc_cyberheart = {LimbType.Torso},
            ntc_cyberbrain = {LimbType.Head},
            ntc_loosescrews = {LimbType.LeftArm, LimbType.RightArm, LimbType.LeftLeg, LimbType.RightLeg},
            ntc_damagedelectronics = {LimbType.LeftArm, LimbType.RightArm, LimbType.LeftLeg, LimbType.RightLeg},
            ntc_bentmetal = {LimbType.LeftArm, LimbType.RightArm, LimbType.LeftLeg, LimbType.RightLeg},
            ntc_materialloss = {LimbType.LeftArm, LimbType.RightArm, LimbType.LeftLeg, LimbType.RightLeg},
            ntc_armspeed = {LimbType.LeftArm, LimbType.RightArm},
            ntc_waterproof = {LimbType.LeftArm, LimbType.RightArm, LimbType.LeftLeg, LimbType.RightLeg},
            ntc_legspeed = {LimbType.LeftLeg, LimbType.RightLeg}
        }
        for _, affliction in ipairs(ntcGAfflictions) do
            table.insert(globalAfflictions, affliction)
        end
        for affliction, limbs in pairs(ntcLAfflictions) do
            limbMapping[affliction] = limbs  -- Directly insert key-value pairs
        end
    end

    -- NTE afflictions
    if NTEIn and RSConfig.Get("NTERS", true) then
        local nteLAfflictions = {
            eyebionic = {LimbType.Head},
            medicallens = {LimbType.Head},
            electricallens = {LimbType.Head},
            zoomlens = {LimbType.Head},
            eyenight = {LimbType.Head},
            eyeinfrared = {LimbType.Head},
            eyeplastic = {LimbType.Head},
            eyemonster = {LimbType.Head},
            eyehusk = {LimbType.Head},
            eyeterror = {LimbType.Head}
        }
        for affliction, limbs in pairs(nteLAfflictions) do
            limbMapping[affliction] = limbs  -- Directly insert key-value pairs
        end
    end

    -- Collect limb-specific afflictions
    for _, limb in ipairs(character.AnimController.Limbs) do
        for identifier, validLimbs in pairs(limbMapping) do
            if HF.TableContains(validLimbs, limb.type) then
                local strength = HF.GetAfflictionStrengthLimb(character, limb.type, identifier, 0)
                if strength > 0 then
                    table.insert(afflictions, {identifier = identifier, strength = strength, limbType = limb.type})
                end
            end
        end
    end

    -- Collect global afflictions
    for _, identifier in ipairs(globalAfflictions) do
        local strength = HF.GetAfflictionStrength(character, identifier, 0)
        if strength > 0 then
            table.insert(afflictions, {identifier = identifier, strength = strength, limbType = nil})
        end
    end

    return afflictions
end

-- Temporary storage for collected afflictions
local tempAfflictionStorage = {}

-- Example usage: Trigger the function when a character dies
Hook.Add("character.death", "OnCharacterDeath", function(character)
    -- Check if character afflictions are already stored to avoid duplication
    for _, entry in ipairs(tempAfflictionStorage) do
        if entry.characterName == character.Name then
            return
        end
    end

    local afflictions = CollectAfflictionsOnDeath(character)
    table.insert(tempAfflictionStorage, { characterName = character.Name, afflictions = afflictions })
end)

-- Function to apply saved afflictions to a target character
function ApplySavedAfflictions(targetCharacter)
    if not targetCharacter or not targetCharacter.CharacterHealth then
        return
    end

    -- **Check if the revived character has "nanobots" before applying NT afflictions**
    local hasNanobots = HF.HasAffliction(targetCharacter, "nanobots", 1)

    for index, entry in ipairs(tempAfflictionStorage) do
        if entry.characterName == targetCharacter.Name then
            -- Apply all afflictions stored for this character
            for _, affliction in ipairs(entry.afflictions) do
                local identifier = affliction.identifier
                local strength = affliction.strength
                local limbType = affliction.limbType

                -- **Skip NT afflictions if the character has "nanobots"**
                if hasNanobots and NTIn and (
                    identifier == "tra_amputation" or
                    identifier == "tla_amputation" or
                    identifier == "trl_amputation" or
                    identifier == "tll_amputation" or
                    identifier == "sra_amputation" or
                    identifier == "sla_amputation" or
                    identifier == "srl_amputation" or
                    identifier == "sll_amputation"
                ) then
                    -- Skip applying NT amputation afflictions
                    print("Skipping " .. identifier .. " because the character has nanobots.")
                elseif hasNanobots and NTEIn and (
                    identifier == "noeye" or
                    identifier == "eyesdead" or
                    identifier == "eyeone" or
                    identifier == "lefteyegone" or
                    identifier == "righteyegone" or
                    identifier == "eyelowbloodpressure" or
                    identifier == "eyedamage" or
                    identifier == "eyeshock" or
                    identifier == "eyedrop" or
                    identifier == "deusizinedrop" or
                    identifier == "eyesickness" or
                    identifier == "eyecataract" or
                    identifier == "eyemuscle" or
                    identifier == "eyegell" or
                    identifier == "eyenerve" or
                    identifier == "eyelid" or
                    identifier == "eyepopped" or
                    identifier == "corneaincision" or
                    identifier == "emulsification" or
                    identifier == "lasereyesurgery" or
                    identifier == "hasglasses"
                ) then
                    -- Skip applying NTE amputation afflictions
                    print("Skipping " .. identifier .. " because the character has nanobots.")                        
                else
                    -- Apply the affliction normally
                    if limbType then
                        HF.SetAfflictionLimb(targetCharacter, identifier, limbType, strength)
                    else
                        HF.SetAffliction(targetCharacter, identifier, strength)
                    end
                end
            end

            -- Remove the applied entry from the table
            table.remove(tempAfflictionStorage, index)
            break  -- Exit loop early since we found the character
        end
    end
end

-- Function to apply Revive afflictions to a revived character
function ApplyRevivedAfflictions(user, character, target)
    local hasNanobots = HF.HasAffliction(character, "nanobots", 1)
    local VanillaDMG = RSConfig.Get("RS_VanillaDMG", true)
    local NTRS = RSConfig.Get("NTRS", true)

    -- Apply (revived) afflictions
    if hasNanobots then
        HF.SetAffliction(target, "nanobots", 100)
    else
        -- Check if config for RS_VanillaDMG is true if so then it applies Vanilla Afflictions
        if (VanillaDMG and not NTRS) or (NTRS and not VanillaDMG) then
            if user.GetSkillLevel("medical") >= 60 then
                HF.SetAffliction(target, "bloodloss", math.random(40, 60))
                HF.SetAffliction(target, "organdamage", math.random(40, 60))
                HF.SetAffliction(target, "reaperstax", math.random(15, 25))
                HF.SetAffliction(target, "stun", math.random(15, 25))
            else
                HF.SetAffliction(target, "bloodloss", math.random(60, 80))
                HF.SetAffliction(target, "organdamage", math.random(80, 100))
                HF.SetAffliction(target, "reaperstax", math.random(35, 50))
                HF.SetAffliction(target, "stun", math.random(30, 50))
            end
        end

        -- Check if NT is installed and that config for NT Patch is true then applies corresponding damage group
        if NTIn and NTRS then
            if user.GetSkillLevel("medical") >= 60 then
                HF.SetAffliction(target, "sym_confusion", 100)
                HF.SetAffliction(target, "sym_unconsciousness", 100)
                HF.SetAffliction(target, "kidneydamage", math.random(20, 30))
                HF.SetAffliction(target, "heartdamage", math.random(20, 30))
                HF.SetAffliction(target, "lungdamage", math.random(20, 30))
                HF.SetAffliction(target, "liverdamage", math.random(20, 30))
            else
                HF.SetAffliction(target, "sym_confusion", 100)
                HF.SetAffliction(target, "sym_unconsciousness", 100)
                HF.SetAffliction(target, "kidneydamage", math.random(35, 60))
                HF.SetAffliction(target, "heartdamage", math.random(35, 60))
                HF.SetAffliction(target, "lungdamage", math.random(35, 60))
                HF.SetAffliction(target, "liverdamage", math.random(35, 60))
            end
        end
    end

    if RSConfig.Get("RS_Affliction", true) then
        HF.SetAffliction(target, "revived", 100)
    end

end