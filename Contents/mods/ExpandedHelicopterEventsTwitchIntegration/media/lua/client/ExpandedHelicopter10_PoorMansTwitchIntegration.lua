twitchIntegrationPresets = {}
for presetID,_ in pairs(eHelicopter_PRESETS) do
	table.insert(twitchIntegrationPresets, presetID)
end


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
		eHelicopterSandbox.menu.twitchSpace = {type = "Space", iteration=2}
		eHelicopterSandbox.menu.twitchIntegrationText = {type = "Text", text = "Twitch Integration\n", }
	else
		eHelicopterSandbox.menu.twitchSpace = nil
		eHelicopterSandbox.menu.twitchIntegrationText = nil
	end

	for i=1, 9 do
		if appliedTwitchIntegration == false then
			eHelicopterSandbox.config["Numpad"..i] = 1
		end
		if bAdd then
			eHelicopterSandbox.menu["Numpad"..i] = { type = "Combobox", title = "Numpad "..i, options = generateOptions() }
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


Events.OnCustomUIKey.Add(function(key)
	if key == Keyboard.KEY_NUMPAD1 then DEBUG_TESTS.launchHeliTest(twitchIntegrationPresets[eHelicopterSandbox.config.Numpad1])
	elseif key == Keyboard.KEY_NUMPAD2 then DEBUG_TESTS.launchHeliTest(twitchIntegrationPresets[eHelicopterSandbox.config.Numpad2])
	elseif key == Keyboard.KEY_NUMPAD3 then DEBUG_TESTS.launchHeliTest(twitchIntegrationPresets[eHelicopterSandbox.config.Numpad3])
	elseif key == Keyboard.KEY_NUMPAD4 then DEBUG_TESTS.launchHeliTest(twitchIntegrationPresets[eHelicopterSandbox.config.Numpad4])
	elseif key == Keyboard.KEY_NUMPAD5 then DEBUG_TESTS.launchHeliTest(twitchIntegrationPresets[eHelicopterSandbox.config.Numpad5])
	elseif key == Keyboard.KEY_NUMPAD6 then DEBUG_TESTS.launchHeliTest(twitchIntegrationPresets[eHelicopterSandbox.config.Numpad6])
	elseif key == Keyboard.KEY_NUMPAD7 then DEBUG_TESTS.launchHeliTest(twitchIntegrationPresets[eHelicopterSandbox.config.Numpad7])
	elseif key == Keyboard.KEY_NUMPAD8 then DEBUG_TESTS.launchHeliTest(twitchIntegrationPresets[eHelicopterSandbox.config.Numpad8])
	elseif key == Keyboard.KEY_NUMPAD9 then DEBUG_TESTS.launchHeliTest(twitchIntegrationPresets[eHelicopterSandbox.config.Numpad9])
	end
end)