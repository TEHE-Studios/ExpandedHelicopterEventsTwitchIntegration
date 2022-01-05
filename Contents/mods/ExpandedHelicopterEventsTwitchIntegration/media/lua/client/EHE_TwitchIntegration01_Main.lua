Events.OnGameBoot.Add(print("Twitch-Integrated Helicopter Events: ver:0.2-totallyNotMP"))

require "ExpandedHelicopter02a_Presets"
require "ExpandedHelicopter09_EasyConfigOptions"

twitchIntegrationPresets = {}
function generateTwitchIntegrationPresets()
	local tempTIP = {"NONE"}
	for presetID,presetVariables in pairs(eHelicopter_PRESETS) do
		if presetVariables.doNotListForTwitchIntegration~=true then
			table.insert(tempTIP, presetID)
		end
	end
	table.insert(tempTIP, "RANDOM")
	twitchIntegrationPresets = tempTIP
end


function generateOptions()
	local newOptions = {}
	for key,presetID in pairs(twitchIntegrationPresets) do
		table.insert(newOptions, {presetID, key})
	end
	return newOptions
end


appliedTwitchIntegration = false
function applyTwitchIntegration()
	eHelicopterSandbox = eHelicopterSandbox or {}
	eHelicopterSandbox.menu = eHelicopterSandbox.menu or {}

	eHelicopterSandbox.menu.twitchSpace = nil
	eHelicopterSandbox.menu.twitchIntegrationText = nil
	eHelicopterSandbox.menu.twitchIntegrationToolTip = nil
	eHelicopterSandbox.menu.twitchIntegrationOnly = nil
	eHelicopterSandbox.menu.twitchSpaceEnd = nil

	--TODO: Fix MP
	if (getCore():getGameMode() == "Multiplayer") and isIngameState() then
		return
	end

	generateTwitchIntegrationPresets()

	eHelicopterSandbox.menu.twitchSpace = {type = "Space", alwaysAccessible = true}
	eHelicopterSandbox.menu.twitchIntegrationText = {type = "Text", alwaysAccessible = true, text = "Twitch Integration", }
	eHelicopterSandbox.menu.twitchIntegrationToolTip = {type = "Text", alwaysAccessible = true, a=0.6,
		text = "Stream deck or a similar program is required for seamless integration.\nAlternatively, you can use the numpad keys manually.\n", }
	eHelicopterSandbox.menu.twitchIntegrationOnly = {type = "Tickbox", alwaysAccessible = true, title = "Disable events outside of twitch integration.", tooltip = "", }

	for i=1, 9 do
		eHelicopterSandbox.menu["Numpad"..i] = nil

		local fetchedOptions = generateOptions()
		if #fetchedOptions > 0 then
			eHelicopterSandbox.menu["Numpad"..i] = { type = "Combobox", title = "Numpad "..i, alwaysAccessible = true, options = fetchedOptions }
			if appliedTwitchIntegration == false then
				eHelicopterSandbox.config["Numpad"..i] = 1
			end
		end
	end
	eHelicopterSandbox.menu.twitchSpaceEnd = {type = "Space", alwaysAccessible = true}

	if appliedTwitchIntegration == false then
		eHelicopterSandbox.config.twitchIntegrationOnly = false
	end
	appliedTwitchIntegration = true
end


Events.OnGameBoot.Add(applyTwitchIntegration)
