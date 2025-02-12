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


    -- Create new human character
    local info = character.Info
    local oldSeed = character.Seed -- Extract the old character's seed
    local newHuman = Character.Create("Human", position, oldSeed, info, 0, true, true, true, nil, false, false)
    newHuman.TeamID = character.TeamID
    newHuman.Revive(false, true)

    newHuman.Enabled = true

    TransferInventory(character, newHuman)

    -- Remove character safely
    if SERVER then
        Timer.Wait(function()
            Entity.Spawner.AddEntityToRemoveQueue(character)
        end, 100) -- Delay ensures it does not conflict with new character creation
    end

    -- Reapply talents
    LoadTalents(newHuman, savedTalents)

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

    -- Get CrewManager
    local session = Game.GameSession
    local crewManager = session.CrewManager
    if crewManager ~= nil then
        -- Add character to CrewManager
        crewManager.AddCharacter(newHuman)
    end
    
    return true
end
