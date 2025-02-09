-- Function to add a character to the CrewManager
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
        Hook.Patch("SaveInventory " .. character.Name, "Barotrauma.GameSession", "EndRound",function()
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
                    local invData = savedInventories[character.Name]
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

-- Function to regen a character
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
    local newHuman = Character.Create("Human", position, oldSeed, info, 0, true, true, true, nil, false, false)
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
