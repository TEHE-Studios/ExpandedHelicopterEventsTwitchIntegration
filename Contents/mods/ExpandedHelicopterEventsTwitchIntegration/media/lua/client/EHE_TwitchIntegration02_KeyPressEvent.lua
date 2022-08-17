require "ExpandedHelicopter00a_Util"

twitchKeys = {["KP_1"]="Numpad1",["KP_2"]="Numpad2",["KP_3"]="Numpad3",
			  ["KP_4"]="Numpad4",["KP_5"]="Numpad5",["KP_6"]="Numpad6",
			  ["KP_7"]="Numpad7",["KP_8"]="Numpad8",["KP_9"]="Numpad9",}

function twitchIntegration_OnKeyPressed(key)

	if isClient() then
		if (not isAdmin()) and (not isCoopHost()) then
			return
		end
	end

	local twitchKey = twitchKeys[Keyboard.getKeyName(key)]
	if twitchKey then

		local players = getActualPlayers()
		---@type IsoGameCharacter|IsoPlayer|IsoMovingObject|IsoObject
		local playerChar = players[ZombRand(#players)+1]

		if eHelicopterSandbox.config.twitchStreamerTargeted == true then
			playerChar = getPlayer()
		end

		if playerChar then

			local numpadKey = eHelicopterSandbox.config[twitchKey]
			local presetID = twitchIntegrationPresets[numpadKey]

			if presetID=="RANDOM" then
				presetID = twitchIntegrationPresets[ZombRand(2,#twitchIntegrationPresets)]
			end

			if presetID=="NONE" then
				return
			end

			local pUsername = playerChar:getUsername()
			sendClientCommand(playerChar, "twitchIntegration", "scheduleEvent", {presetID=presetID,twitchTarget=pUsername})
		end
	end
end

Events.OnKeyPressed.Add(twitchIntegration_OnKeyPressed)