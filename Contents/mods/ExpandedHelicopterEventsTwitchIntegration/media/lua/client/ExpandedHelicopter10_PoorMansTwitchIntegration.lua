twitchIntegrationPresets = {}
function generateTwitchIntegrationPresets()
	local tempTIP = {"NONE"}
	for presetID,_ in pairs(eHelicopter_PRESETS) do
		table.insert(tempTIP, presetID)
	end
	table.insert(tempTIP, "RANDOM")
	twitchIntegrationPresets = tempTIP
end


function generateOptions()
	local newOptions = {}
	for key,presetID in ipairs(twitchIntegrationPresets) do
		table.insert(newOptions, {presetID, key})
	end
	return newOptions
end


appliedTwitchIntegration = false
function applyTwitchIntegration()
	generateTwitchIntegrationPresets()
	eHelicopterSandbox.menu.twitchSpace = nil
	eHelicopterSandbox.menu.twitchIntegrationText = nil
	eHelicopterSandbox.menu.twitchIntegrationToolTip = nil

	eHelicopterSandbox.menu.twitchSpace = {type = "Space", alwaysAccessible = true, iteration=2}
	eHelicopterSandbox.menu.twitchIntegrationText = {type = "Text", alwaysAccessible = true, text = "Twitch Integration", }
	eHelicopterSandbox.menu.twitchIntegrationToolTip = {type = "Text", alwaysAccessible = true, a=0.6,
		text = "Stream deck or a similar program is required for seamless integration.\nAlternatively, you can use the numpad keys manually.\n", }

	for i=1, 9 do
		if appliedTwitchIntegration == false then
			eHelicopterSandbox.config["Numpad"..i] = 1
		end
		eHelicopterSandbox.menu["Numpad"..i] = nil
		eHelicopterSandbox.menu["Numpad"..i] = { type = "Combobox", title = "Numpad "..i, alwaysAccessible = true, options = generateOptions() }
	end
	appliedTwitchIntegration = true
end


twitchKeys = {["KP_1"]="Numpad1",["KP_2"]="Numpad2",["KP_3"]="Numpad3",
			  ["KP_4"]="Numpad4",["KP_5"]="Numpad5",["KP_6"]="Numpad6",
			  ["KP_7"]="Numpad7",["KP_8"]="Numpad8",["KP_9"]="Numpad9",}


Events.OnCustomUIKey.Add(function(key)
	local playerChar = getPlayer()

	if playerChar then
		local twitchKey = twitchKeys[Keyboard.getKeyName(key)]

		if twitchKey then
			local numpadKey = eHelicopterSandbox.config[twitchKey]
			local integration = twitchIntegrationPresets[numpadKey]
			
			if integration=="RANDOM" then
				integration = twitchIntegrationPresets[ZombRand(2,#twitchIntegrationPresets)]
			end

			if integration=="NONE" then
				return
			end

			local heli = getFreeHelicopter(integration)
			print("EHE-TI: launch: "..tostring(integration).." target:"..playerChar:getDisplayName())
			heli:launch(playerChar)

		end
	end
end)


EHETI_sandboxOptionsEnd_override = sandboxOptionsEnd
function sandboxOptionsEnd()
	EHETI_sandboxOptionsEnd_override()
	applyTwitchIntegration()
end
Events.OnGameBoot.Add(sandboxOptionsEnd())
