local NTIn = NTCompat.isNTactive()
local NTCIn = NTCompat.isNTCactive()

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

    if NTIn and RSConfig.Get("NTLRS", true) then
        local ntGAfflictions = {
            --NT
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
    end

    if NTCIn and RSConfig.Get("NTCRS", true) then
        local ntcGAfflictions = {
            "ntc_cyberpsychosis",
            "ntc_cyberpsychosis_resistance",
            "ntc_cyberlung_pressure_recovery"
        }
        local ntcLAfflictions = {
            --NTC
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
                if hasNanobots and (
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

function regen(character, position, user)
    local client = HF.CharacterToClient(character)

    -- If character has already turned into AI husk, try to retrieve their original client
    if client == nil then
        client = HF.ClientFromName(character)
    end

    -- Check if the character is already in the remove queue
    if Entity.Spawner.IsInRemoveQueue(character) then
        return false
    end

    -- Properly disable character before replacement
    character.Enabled = false

    -- Save talents
    local savedTalents = SaveTalents(character)

    -- Save inventory
    local savedInventory = SaveInv(character)

    -- Remove character safely
    if SERVER then
        Timer.Wait(function()
            Entity.Spawner.AddEntityToRemoveQueue(character)
        end, 100) -- Delay ensures it does not conflict with new character creation
    end

    -- Create new human character
    local info = character.Info
    local oldSeed = character.Seed -- Extract the old character's seed
    local newHuman = Character.Create("Human", position, oldSeed, info, 0, true, true)
    newHuman.TeamID = character.TeamID
    newHuman.Revive(false, true)
    newHuman.Enabled = true

    -- Reapply talents
    LoadTalents(newHuman, savedTalents)

    --Load inventory
    LoadInventory(newHuman, savedInventory)

    -- Reapply afflictions
    ApplyRevivedAfflictions(user, character, newHuman)

    -- Apply saved afflictions
    ApplySavedAfflictions(newHuman)
    
    -- Set client character
    if SERVER then
        if client == nil and newHuman ~= nil then
            -- Try to find the client using the target's name
            for key, potentialClient in pairs(Client.ClientList) do
                if potentialClient.Name == newHuman.Name then
                    client = potentialClient
                    break
                end
            end
        end

        -- If client is still not found, default to the newHuman's name lookup
        if client ~= nil then
            client.SetClientCharacter(newHuman)
        else
            print("Failed to find a client for character: " .. tostring(newHuman.Name))
        end
    end

    -- Add to CrewManager via separate function
    AddToCrewManager(newHuman)

    return true
end

function AddToCrewManager(character)
    -- Ensure this function only runs on the server
    if not SERVER then return end

    -- Ensure character is valid
    if character == nil or character.ID == nil then
        print("Error: character or character.ID is nil, cannot add to CrewManager.")
        return
    end

    -- Get CrewManager
    local session = Game.GameSession
    local crewManager = session.CrewManager
    if crewManager ~= nil then
        -- Add character to CrewManager
        crewManager.AddCharacter(character)

        savedInventories = savedInventories or {}
        -- Save inventory at round end
        Hook.Patch("LoadInventory " .. character.Name, "Barotrauma.GameSession", "EndRound",function()
            if not SERVER then return end

            if character ~= nil then
                local invData = SaveInv(character)
                print("Saving inventory for " .. character.Name .. " with " .. tostring(#invData.items) .. " items.")
                savedInventories[character.Name] = invData
            else
                print("No saved inventory found for " .. character.Name)
            end

            -- Remove the patch after execution
            Hook.RemovePatch("LoadInventory " .. character.Name, "Barotrauma.GameSession","EndRound", Hook.HookMethodType.Before)
        end, Hook.HookMethodType.Before)

        -- Load inventory at round start
        Hook.Add("roundStart", "LoadTargetInventory_" .. character.Name, function()
            if not SERVER then return end

            Timer.Wait(function()
                if character ~= nil then
                    -- Find the new character with the same name
                    local newCharacter = nil
                    local invData = savedInventories and savedInventories[character.Name]
                    for _, char in ipairs(Character.CharacterList) do
                        if char.Name == character.Name then
                            newCharacter = char
                            break
                        end
                    end

                    if newCharacter and invData then
                        print("Applying inventory to new character: " .. newCharacter.Name .. " with " .. tostring(#invData.items) .. " items.")
                        LoadInventory(newCharacter, invData)
                    else
                        print(newCharacter.Name .. " not found for inventory restoration.")
                    end                

                    -- Remove this hook after execution
                    Hook.Remove("roundStart", "LoadTargetInventory_" .. character.Name)
                else
                    print("No saved inventory found for " .. character.Name)
                    Hook.Remove("roundStart", "LoadTargetInventory_" .. character.Name)
                end
            end, 5000) -- Small delay to ensure the character is fully initialized
        end) 
    else
        print("Error: CrewManager is nil, cannot add character to CrewManager.")
    end
    
end

function SaveInv(character)
    if not character or not character.Inventory then 
        print("No character or inventory found.")
        return nil 
    end

    local inventoryData = { items = {} }

    -- Recursive function to save item data, including contained items
    local function SaveItem(item, parentContainerPrefab, parentSlot)
        if not item then return end

        local itemData = {
            prefab = item.Prefab.Identifier,  -- Use the item's prefab identifier
            condition = item.Condition or 100,
            slot = parentSlot or nil,  -- Store the slot index if available
            container = parentContainerPrefab,  -- Store the prefab identifier of the parent container
            contained_items = {} -- Store nested items
        }

        -- If the item has an inventory (is a container), save its contents
        if item.OwnInventory then
            for containedItem in item.OwnInventory.AllItems do
                local containedData = SaveItem(containedItem, item.Prefab.Identifier, nil)
                table.insert(itemData.contained_items, containedData)
                print("Saved contained item: " .. tostring(containedItem.Prefab.Identifier) .. " in " .. tostring(item.Prefab.Identifier))
            end
        end

        return itemData
    end

    -- Save all items in the character's inventory
    for i = 0, character.Inventory.Capacity - 1 do
        local itemList = character.Inventory.GetItemsAt(i)
        if itemList then
            for _, item in ipairs(itemList) do
                table.insert(inventoryData.items, SaveItem(item, nil, i))
            end
        end
    end

    return inventoryData
end

function LoadInventory(target, inventoryData)
    if not target or not target.Inventory or not inventoryData then return end

    -- First pass: Spawn all top-level items
    for _, data in ipairs(inventoryData.items) do
        local params = { condition = data.condition or 100 }

        HF.SpawnItemPlusFunction(data.prefab, nil, params, target.Inventory, data.slot, target.WorldPosition)
    end

    local function GetItem(player, itemIdentifier)
        if not player or player.Inventory == nil then return nil end
        for item in player.Inventory.AllItems do
            if item.Prefab.Identifier == itemIdentifier then
                return item -- Return the item itself
            end
        end
        return nil -- Return nil if not found
    end

    Timer.Wait(function()
        -- Second pass: Load contained items into their respective containers
        for _, data in ipairs(inventoryData.items) do
            if data.prefab and data.contained_items then

                for _, containedItemData in ipairs(data.contained_items) do
                    local params = { condition = containedItemData.condition or 100 }
                    local containerItem = nil
                    local containedItem = nil
                    if containedItemData.container ~= nil then
                        containerItem = GetItem(target, containedItemData.container)
                        containedItem = containedItemData.prefab
                    end

                    HF.PutItemInsideItem(containerItem, containedItem, 1)

                end
            end
        end
    end, 50) -- Delay ensures the container is present
end

function ApplyRevivedAfflictions(user, character, target)
    local hasNanobots = HF.HasAffliction(character, "nanobots", 1)
    -- Apply (revived) afflictions
    if hasNanobots then
        HF.SetAffliction(target, "nanobots", 100)
    else
        -- Check if config for RS_VanillaDMG is true if so then it applies Vanilla Afflictions
        if RSConfig.Get("RS_VanillaDMG", true) or RSConfig.Get("NTRS", true) then
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
        if NTIn and RSConfig.Get("NTRS", true) then
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

function SaveTalents(character)
    local talents = {}

    if character and character.Info and character.Info.UnlockedTalents then
        for talent in character.Info.UnlockedTalents do
            table.insert(talents, talent.Value)
        end
    end

    return talents or {}  -- Ensure it always returns a valid table
end

function LoadTalents(character, talents)
    if not talents or type(talents) ~= "table" then
        print("Warning: Tried to load talents but received nil or invalid data.")
        return
    end

    for _, talent in ipairs(talents) do
        character.GiveTalent(Identifier(talent), false)
    end
end
