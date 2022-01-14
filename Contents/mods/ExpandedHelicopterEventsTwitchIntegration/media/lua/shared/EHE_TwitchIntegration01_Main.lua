Events.OnGameBoot.Add(print("Twitch-Integrated Helicopter Events: ver:0.3.3-EasyConfigMPUpdate"))

require "ExpandedHelicopter02a_Presets"
require "ExpandedHelicopter09_EasyConfigOptions"
require "EasyConfigChucked1_Main"

twitchIntegrationPresets = {"NONE"}
function generateTwitchIntegrationPresets()
	for presetID,presetVariables in pairs(eHelicopter_PRESETS) do
		if presetVariables.doNotListForTwitchIntegration~=true then
			table.insert(twitchIntegrationPresets, presetID)
		end
	end
	table.insert(twitchIntegrationPresets, "RANDOM")
end

function EHETI_generateOptions()
	local newOptions = {}
	for key,presetID in pairs(twitchIntegrationPresets) do
		table.insert(newOptions, {presetID, key})
	end
	return newOptions
end


appliedTwitchIntegration = false
function applyTwitchIntegration()
	eHelicopterSandbox.menu.twitchSpace = nil
	eHelicopterSandbox.menu.twitchIntegrationText = nil
	eHelicopterSandbox.menu.twitchIntegrationToolTip = nil
	eHelicopterSandbox.menu.twitchIntegrationOnly = nil
	eHelicopterSandbox.menu.twitchSpaceEnd = nil
	eHelicopterSandbox.menu.twitchStreamerTargeted = nil

	generateTwitchIntegrationPresets()

	eHelicopterSandbox.menu.twitchSpace = {type = "Space", alwaysAccessible = true}
	eHelicopterSandbox.menu.twitchIntegrationText = {type = "Text", alwaysAccessible = true, text = "Twitch Integration", }
	eHelicopterSandbox.menu.twitchIntegrationToolTip = {type = "Text", alwaysAccessible = true, a=0.6,
		text = "Stream deck or a similar program is required for seamless integration.\nAlternatively, you can use the numpad keys manually.\n", }
	eHelicopterSandbox.menu.twitchIntegrationOnly = {type = "Tickbox", alwaysAccessible = true, title = "Disable events outside of twitch integration.", tooltip = "", }
	eHelicopterSandbox.menu.twitchStreamerTargeted = {type = "Tickbox", alwaysAccessible = true, title = "Target the streamer only.", tooltip = "", }

	for i=1, 9 do
		eHelicopterSandbox.menu["Numpad"..i] = nil

		local fetchedOptions = EHETI_generateOptions()
		if #fetchedOptions > 0 then
			eHelicopterSandbox.menu["Numpad"..i] = { type = "Combobox", title = "Numpad "..i, alwaysAccessible = true, options = fetchedOptions }
			if appliedTwitchIntegration == false then
				eHelicopterSandbox.config["Numpad"..i] = eHelicopterSandbox.config["Numpad"..i] or 1
			end
		end
	end
	eHelicopterSandbox.menu.twitchSpaceEnd = {type = "Space", alwaysAccessible = true}

	if appliedTwitchIntegration == false then
		eHelicopterSandbox.config.twitchIntegrationOnly = false
		eHelicopterSandbox.config.twitchStreamerTargeted = true
	end
	appliedTwitchIntegration = true
end

Events.OnGameBoot.Add(applyTwitchIntegration)
