twitchIntegrationPresets = {}
for presetID,_ in pairs(eHelicopter_PRESETS) do
	table.insert(twitchIntegrationPresets, presetID)
end
table.insert(twitchIntegrationPresets, "Random")


function generateOptions()
	local newOptions = {}
	for key,presetID in ipairs(twitchIntegrationPresets) do
		table.insert(newOptions, {presetID, key})
	end
	return newOptions
end


appliedTwitchIntegration = false
function applyTwitchIntegration(bAdd)

	if bAdd then
		eHelicopterSandbox.menu.twitchSpace = {type = "Space", alwaysAccessible = true, iteration=2}
		eHelicopterSandbox.menu.twitchIntegrationText = {type = "Text", alwaysAccessible = true, text = "Twitch Integration\n", }
	else
		eHelicopterSandbox.menu.twitchSpace = nil
		eHelicopterSandbox.menu.twitchIntegrationText = nil
	end

	for i=1, 9 do
		if appliedTwitchIntegration == false then
			eHelicopterSandbox.config["Numpad"..i] = 1
		end
		if bAdd then
			eHelicopterSandbox.menu["Numpad"..i] = { type = "Combobox", title = "Numpad "..i, alwaysAccessible = true, options = generateOptions() }
		else
			eHelicopterSandbox.menu["Numpad"..i] = nil
		end
	end

	appliedTwitchIntegration = true
end


sandboxOptionsEnd_override = sandboxOptionsEnd
function sandboxOptionsEnd(bAdd)
	sandboxOptionsEnd_override(bAdd)
	applyTwitchIntegration(bAdd)
end


twitchKeys = {["KP_1"]="Numpad1",["KP_2"]="Numpad2",["KP_3"]="Numpad3",
			  ["KP_4"]="Numpad4",["KP_5"]="Numpad5",["KP_6"]="Numpad6",
			  ["KP_7"]="Numpad7",["KP_8"]="Numpad8",["KP_9"]="Numpad9",}

Events.OnCustomUIKey.Add(function(key)
	if getPlayer() then
		local twitchKey = twitchKeys[Keyboard.getKeyName(key)]
		if twitchKey then
			local numpadKey = eHelicopterSandbox.config[twitchKey]
			local integration = twitchIntegrationPresets[numpadKey]
			if integration=="Random" then
				integration = twitchIntegrationPresets[ZombRand(1,#twitchIntegrationPresets)]
			end
			DEBUG_TESTS.launchHeliTest(integration)
		end
	end
end)

Events.OnGameBoot.Add(sandboxOptionsEnd(true))