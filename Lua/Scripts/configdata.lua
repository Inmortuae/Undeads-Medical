RSConfig = { Entries = {}, Expansions = {} } -- contains all config options, their default, type, valid ranges, difficulty influence

local configDirectoryPath = Game.SaveFolder .. "/ModConfigs"
local configFilePath = configDirectoryPath .. "/RSConfig.json"

-- Add configuration options
function RSConfig.AddConfigOptions(expansion)
    table.insert(RSConfig.Expansions, expansion)

    for key, entry in pairs(expansion.ConfigData) do
        RSConfig.Entries[key] = entry
        RSConfig.Entries[key].value = entry.default
    end
end

-- Save configuration to file
function RSConfig.SaveConfig()
    if Game.IsMultiplayer and CLIENT and Game.Client.MyClient.IsOwner then
        return
    end

    local tableToSave = {}
    for key, entry in pairs(RSConfig.Entries) do
        tableToSave[key] = entry.value
    end

    File.CreateDirectory(configDirectoryPath)
    File.Write(configFilePath, json.serialize(tableToSave))
end

-- Reset configuration to default values
function RSConfig.ResetConfig()
    local tableToSave = {}
    for key, entry in pairs(RSConfig.Entries) do
        tableToSave[key] = entry.default
        RSConfig.Entries[key] = entry
        RSConfig.Entries[key].value = entry.default
    end
end

-- Load configuration from file
function RSConfig.LoadConfig()
    if not File.Exists(configFilePath) then
        return
    end

    local readConfig = json.parse(File.Read(configFilePath))

    for key, value in pairs(readConfig) do
        if RSConfig.Entries[key] then
            RSConfig.Entries[key].value = value
        end
    end
end

-- Get a configuration value
function RSConfig.Get(key, default)
    if RSConfig.Entries[key] then
        return RSConfig.Entries[key].value
    end
    return default
end

-- Set a configuration value
function RSConfig.Set(key, value)
    if RSConfig.Entries[key] then
        RSConfig.Entries[key].value = value
    end
end

-- Send configuration to a client
function RSConfig.SendConfig(receiverClient)
    local tableToSend = {}
    for key, entry in pairs(RSConfig.Entries) do
        tableToSend[key] = entry.value
    end

    local msg = Networking.Start("RS.ConfigUpdate")
    msg.WriteString(json.serialize(tableToSend))
    if SERVER then
        Networking.Send(msg, receiverClient and receiverClient.Connection or nil)
    else
        Networking.Send(msg)
    end
end

-- Receive configuration from a server
function RSConfig.ReceiveConfig(msg)
    local receivedTable = json.parse(msg.ReadString())
    for key, value in pairs(receivedTable) do
        RSConfig.Set(key, value)
    end
end

RS.ConfigData = {
    RS_header1 = { name = "Undead's Medical", type = "category" },

    RS_VanillaDMG = {
        name = "Vanilla Damage Patch",
        default = true,
        type = "bool",
        description = "Enables standard afflictions without requiring Neurotrauma. If enabled With Neurotrauma, vanilla afflictions will be disabled.",
    },
    NTRS = {
        name = "Neurotrauma Patch",
        default = false,
        type = "bool",
        description = "Enables standard afflictions and afflictions from Neurotrauma. Includes vanilla afflictions unless vanilla damage patch is enabled.",
    },
    NTCRS = {
        name = "Cybernetics Enhanced Patch",
        default = false,
        type = "bool",
        description = "Allows the saving of Cyberlimbs and Cyberorgans.",
    },
    NTERS = {
        name = "Neurotrauma Eyes Patch",
        default = false,
        type = "bool",
        description = "Allows the saving of Positive Neurotrauma Eye afflictions. I.e. Implanted Eyes.",
    },
    NTLRS = {
        name = "Neurotrauma Removed Limb Patch",
        default = false,
        type = "bool",
        description = "Allows the saving of removed limbs. If Neurotrauma Eyes Patch is enabled, Neurotrauma Eye negative afflictions will be saved.",
    },
    FD = {
        name = "Instant Revive Patch",
        default = false,
        type = "bool",
        description = "Removes injuries upon revival when using the Revive Serum. Do not use alongside Neurotrauma Patch or Vanilla Damage.",
    },
    RS_Affliction = {
        name = "Revive Affliction",
        default = true,
        type = "bool",
        description = "Applies a custom affliction that makes the Revive Serum only work on characters without the affliction, restricting revival for affected individuals. Does not affect Nanobots.",
    },
    NOREV = {
        name = "No Revive",
        default = true,
        type = "bool",
        description = "Prevents revival in cases of severe injuries such as extreme blood loss, gunshot wounds above a fatal threshold, pressure injuries, or missing vital limbs (e.g., head).",
    },
}

RSConfig.AddConfigOptions(RS)

-- Wait for all options to load before loading configuration
Timer.Wait(function()
    RSConfig.LoadConfig()

    Timer.Wait(function()
        RSConfig.SaveConfig()
    end, 1000)
end, 50)
