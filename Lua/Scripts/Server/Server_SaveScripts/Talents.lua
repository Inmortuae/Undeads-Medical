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