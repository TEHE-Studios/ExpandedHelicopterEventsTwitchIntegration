Events.OnGameBoot.Add(print("Twitch-Integrated Helicopter Events: ver:0.1"))

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
	eHelicopterSandbox.menu.twitchIntegrationOnly = nil

	eHelicopterSandbox.menu.twitchSpace = {type = "Space", alwaysAccessible = true, iteration=2}
	eHelicopterSandbox.menu.twitchIntegrationText = {type = "Text", alwaysAccessible = true, text = "Twitch Integration", }
	eHelicopterSandbox.menu.twitchIntegrationToolTip = {type = "Text", alwaysAccessible = true, a=0.6,
		text = "Stream deck or a similar program is required for seamless integration.\nAlternatively, you can use the numpad keys manually.\n", }
	eHelicopterSandbox.menu.twitchIntegrationOnly = {type = "Tickbox", alwaysAccessible = true, title = "Disable events outside of twitch integration.", tooltip = "", }
	for i=1, 9 do
		if appliedTwitchIntegration == false then
			eHelicopterSandbox.config["Numpad"..i] = 1
			eHelicopterSandbox.config.twitchIntegrationOnly = false
		end
		eHelicopterSandbox.menu["Numpad"..i] = nil
		eHelicopterSandbox.menu["Numpad"..i] = { type = "Combobox", title = "Numpad "..i, alwaysAccessible = true, options = generateOptions() }
	end
	appliedTwitchIntegration = true
end


twitchKeys = {["KP_1"]="Numpad1",["KP_2"]="Numpad2",["KP_3"]="Numpad3",
			  ["KP_4"]="Numpad4",["KP_5"]="Numpad5",["KP_6"]="Numpad6",
			  ["KP_7"]="Numpad7",["KP_8"]="Numpad8",["KP_9"]="Numpad9",}


Events.OnKeyPressed.Add(function(key)
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
			heli:launch(playerChar, true)

			local offsetX = ZombRand(500, 750)
			if ZombRand(101) <= 50 then
				offsetX = 0-offsetX
			end

			local offsetY = ZombRand(500, 750)
			if ZombRand(101) <= 50 then
				offsetY = 0-offsetY
			end

			heli.currentPosition:set(playerChar:getX()+offsetX, playerChar:getY()+offsetY, heli.height)

		end
	end
end)


local EHETI_eHeliEvent_ScheduleNew = eHeliEvent_ScheduleNew
function eHeliEvent_ScheduleNew(param1,param2)
	if eHelicopterSandbox.config.twitchIntegrationOnly == false then
		EHETI_eHeliEvent_ScheduleNew(param1,param2)
	end
end


local EHETI_sandboxOptionsEnd_override = sandboxOptionsEnd
function sandboxOptionsEnd()
	EHETI_sandboxOptionsEnd_override()
	applyTwitchIntegration()
end
Events.OnGameBoot.Add(sandboxOptionsEnd())


local EHETI_eHeliEvent_engage = eHeliEvent_engage
function eHeliEvent_engage(ID)
	if eHelicopterSandbox.config.twitchIntegrationOnly == false then
		EHETI_eHeliEvent_engage(ID)
	else
		local eHeliEvent = getGameTime():getModData()["EventsSchedule"][ID]
		eHeliEvent = nil
		print("EHE-TI: event loop bypassed.")
	end
end

