--if Game.IsMultiplayer and CLIENT then return end
 
RS = {} -- Undead's Medical
RS.Name="Undead's Medical"
RS.Version = "1.4.8"
RS.VersionNum = 01090301
RS.Path = table.pack(...)[1]

dofile(RS.Path.."/Lua/Scripts/helperfunctions.lua")

-- all things config
dofile(RS.Path.."/Lua/Scripts/configdata.lua")

-- server-side code (also run in singleplayer)
if (Game.IsMultiplayer and SERVER) or not Game.IsMultiplayer then

    -- Version and expansion display
    Timer.Wait(function() Timer.Wait(function()
        local runstring = "\n/// Running Undead's Medical V "..RS.Version.." ///\n"

        -- add dashes
        local linelength = string.len(runstring)+4
        local i = 0
        while i < linelength do runstring=runstring.."-" i=i+1 end

        print(runstring)
    end,1) end,1)

	dofile(RS.Path.."/Lua/Scripts/Server/compat.lua")
	dofile(RS.Path.."/Lua/Scripts/Server/Server_SaveScripts/Talents.lua")
	dofile(RS.Path.."/Lua/Scripts/Server/Server_SaveScripts/Inv.Lua")
	dofile(RS.Path.."/Lua/Scripts/Server/Server_SaveScripts/Affliction.lua")
	dofile(RS.Path.."/Lua/Scripts/Server/Regen.lua")
    dofile(RS.Path.."/Lua/Scripts/Server/revivesyringe.lua")
    dofile(RS.Path.."/Lua/Scripts/Server/nanobots.lua")
	dofile(RS.Path.."/Lua/Scripts/Server/refinedcalyxsyringe.lua")
    
end

-- server-side code only
if SERVER then
	Networking.Receive("RS.ConfigUpdate", function(msg, sender)
		if not sender.HasPermission(ClientPermissions.ManageSettings) then
			return
		end
		RSConfig.ReceiveConfig(msg)
		RSConfig.SaveConfig()
	end)

	Networking.Receive("RS.ConfigRequest", function(msg, sender)
		if not sender then
			return
		end
		RSConfig.SendConfig(sender)
	end)
end

-- client-side code
if CLIENT then
    dofile(RS.Path.."/Lua/Scripts/Client/configgui.lua")
end
