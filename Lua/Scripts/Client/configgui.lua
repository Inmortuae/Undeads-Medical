--easysettings by Evil Factory
local rsSettings = dofile(RS.Path .. "/Lua/Scripts/Client/rssettings.lua")
local MultiLineTextBox = dofile(RS.Path .. "/Lua/Scripts/Client/MultiLineTextBox.lua")
local GUIComponent = LuaUserData.CreateStatic("Barotrauma.GUIComponent")
local configUI

local function CommaStringToTable(str)
	local tbl = {}

	for word in string.gmatch(str, "([^,]+)") do
		table.insert(tbl, word)
	end

	return tbl
end

--bulk of the GUI code
local function ConstructUI(parent)
	local list = rsSettings.BasicList(parent)

	--info text
	local userBlock = GUI.TextBlock(
		GUI.RectTransform(Vector2(1, 0.2), list.Content.RectTransform),
		"Server config can be changed by owner or a client with manage settings permission. If the server doesn't allow writing into the config folder, then it must be edited manually.",
		Color(200, 255, 255),
		nil,
		GUI.Alignment.Center,
		true,
		nil,
		Color(0, 0, 0)
	)

	--empty space
	--GUI.TextBlock(GUI.RectTransform(Vector2(0.2, 0.1), list.Content.RectTransform), "", Color(255,255,255), nil, GUI.Alignment.Center, true, nil, Color(0,0,0))

	-- procedurally construct config UI
	for key, entry in pairs(RSConfig.Entries) do
		if entry.type == "float" then
			-- scalar value
			--grab range
			local minrange = ""
			local maxrange = ""
			local count = 0
			for _, rangegrab in pairs(entry.range) do
				if count == 0 then
					minrange = rangegrab
				end
				if count == 1 then
					maxrange = rangegrab
				end
				count = count + 1
			end

			local rect = GUI.RectTransform(Vector2(1, 0.05), list.Content.RectTransform)
			local textBlock = GUI.TextBlock(
				rect,
				entry.name .. " (" .. minrange .. "-" .. maxrange .. ")",
				Color(230, 230, 170),
				nil,
				GUI.Alignment.Center,
				true,
				nil,
				Color(0, 0, 0)
			)
			if entry.description then
				textBlock.ToolTip = entry.description
			end
			local scalar =
				GUI.NumberInput(GUI.RectTransform(Vector2(1, 0.08), list.Content.RectTransform), NumberType.Float)
			local key2 = key
			scalar.valueStep = 0.1
			scalar.MinValueFloat = 0
			scalar.MaxValueFloat = 100
			if entry.range then
				scalar.MinValueFloat = entry.range[1]
				scalar.MaxValueFloat = entry.range[2]
			end
			scalar.FloatValue = RSConfig.Get(key2, 1)
			scalar.OnValueChanged = function()
				RSConfig.Set(key2, scalar.FloatValue)
				OnChanged()
			end
		elseif entry.type == "string" then
			--user string input
			local style = ""
			--get custom style
			if entry.style ~= nil then
				style = " (" .. entry.style .. ")"
			end

			local rect = GUI.RectTransform(Vector2(1, 0.05), list.Content.RectTransform)
			local textBlock = GUI.TextBlock(
				rect,
				entry.name .. style,
				Color(230, 230, 170),
				nil,
				GUI.Alignment.Center,
				true,
				nil,
				Color(0, 0, 0)
			)
			if entry.description then
				textBlock.ToolTip = entry.description
			end

			local stringinput = MultiLineTextBox(list.Content.RectTransform, "", entry.boxsize)

			stringinput.Text = table.concat(entry.value, ",")

			stringinput.OnTextChangedDelegate = function(textBox)
				entry.value = CommaStringToTable(textBox.Text)
			end
		elseif entry.type == "bool" then
			-- toggle
			local rect = GUI.RectTransform(Vector2(1, 0.2), list.Content.RectTransform)
			local toggle = GUI.TickBox(rect, entry.name)
			if entry.description then
				toggle.ToolTip = entry.description
			end
			local key2 = key
			toggle.Selected = RSConfig.Get(key2, false)
			toggle.OnSelected = function()
				RSConfig.Set(key2, toggle.State == GUIComponent.ComponentState.Selected)
				OnChanged()
			end
		elseif entry.type == "category" then
			-- visual separation
			GUI.TextBlock(
				GUI.RectTransform(Vector2(1, 0.05), list.Content.RectTransform),
				entry.name,
				Color(255, 255, 255),
				nil,
				GUI.Alignment.Center,
				true,
				nil,
				Color(0, 0, 0)
			)
		end
	end

	--empty space as last tickbox was getting cutoff
	GUI.TextBlock(
		GUI.RectTransform(Vector2(1, 0.05), list.Content.RectTransform),
		"",
		Color(255, 255, 255),
		nil,
		GUI.Alignment.Center,
		true,
		nil,
		Color(0, 0, 0)
	)

	if Game.IsMultiplayer and not Game.Client.HasPermission(ClientPermissions.ManageSettings) then
		for guicomponent in list.GetAllChildren() do
			guicomponent.enabled = false
		end
	end

	return list
end

Networking.Receive("RS.ConfigUpdate", function(msg)
	RSConfig.ReceiveConfig(msg)
	local parent = configUI.Parent.Parent
	configUI.RectTransform.Parent = nil
	configUI = nil
	configUI = ConstructUI(parent)
end)

rsSettings.AddMenu("Undead's Medical", function(parent)
	if Game.IsMultiplayer then
		local msg = Networking.Start("RS.ConfigRequest")
		Networking.Send(msg)
	end
	configUI = ConstructUI(parent)
end)
