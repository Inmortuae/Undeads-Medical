local savedCharacterData = {}

Hook.Add("character.death", "SaveCharacterDataOnDeath", function(character)
    if character == nil or character.IsHuman == false then return end

    savedCharacterData[character.Name] = {
        info = character.Info,
        seed = character.Seed,
        teamID = character.TeamID
    }

end)

-- Function to regen a character
function regen(character, position, user)
    local client = HF.CharacterToClient(character)

    -- If character has already turned into AI husk, try to retrieve their original client
    if client == nil then
        client = HF.ClientFromName(character)
    end

    -- Save talents
    local savedTalents = SaveTalents(character)

    -- Retrieve saved character data
    local charData = savedCharacterData[character.Name]
    local oldinfo = charData.info 
    local oldSeed = charData.seed
    local oldTeamID = charData.teamID

    -- Remove the old character
    Entity.Spawner.AddEntityToRemoveQueue(character)

    -- Create new human character
    local newHuman = Character.Create("Human", position, oldSeed, oldinfo, 0, false, true, true, nil, false, false)

    newHuman.TeamID = oldTeamID
    
    TransferInventory(character, newHuman)

    newHuman.Revive(false, true)

    -- Reapply talents
    LoadTalents(newHuman, savedTalents)

    -- Reapply afflictions
    ApplyRevivedAfflictions(user, character, newHuman)

    -- Apply saved afflictions
    ApplySavedAfflictions(newHuman)
    
    -- Set client character
    if SERVER then
        if client == nil and not newHuman.IsBot then
            -- Try to find the client using the target's name
            for _, potentialClient in pairs(Client.ClientList) do
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
