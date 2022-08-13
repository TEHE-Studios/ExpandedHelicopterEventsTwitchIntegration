require "ExpandedHelicopter06_EventScheduler"

local EHETI_eHeliEvent_ScheduleNew = eHeliEvent_ScheduleNew
function eHeliEvent_ScheduleNew(startDay, startTime, preset)
	if eHelicopterSandbox.config.twitchIntegrationOnly == false then
		EHETI_eHeliEvent_ScheduleNew(startDay, startTime, preset)
	end
end


local function twitch_MoveHeliCloser(heli, playerChar)
	if not heli then return end
	print("EHE-TI: "..heli:heliToString().." moved closer to "..playerChar:getUsername()..".")
	local min, max = eheBounds.threshold/2, eheBounds.threshold-1
	local offsetX = ZombRand(min, max)
	if ZombRand(101) <= 50 then offsetX = 0-offsetX end
	local offsetY = ZombRand(min, max)
	if ZombRand(101) <= 50 then offsetY = 0-offsetY end
	heli.currentPosition:set(playerChar:getX()+offsetX, playerChar:getY()+offsetY, heli.height)
end


--Engages specific eHeliEvent based on ID
---@param ID number position in "EventsOnSchedule"
function eHeliEvent_engage(ID)

	local globalModData = getExpandedHeliEventsModData()
	local eHeliEvent = globalModData.EventsOnSchedule[ID]

	--check if the event will occur
	local willFly,_ = eHeliEvent_weatherImpact()
	local foundTarget

	if eHeliEvent.twitchTarget then
		willFly = true
		print(" ---- EHE-TI: twitchTarget:"..eHeliEvent.twitchTarget)

		local players = getActualPlayers()
		for _,player in pairs(players) do
			if player:getUsername() == eHeliEvent.twitchTarget then
				foundTarget = player
			end
		end
		if not foundTarget then
			print(" ----- EHE-TI: Cannot find "..eHeliEvent.twitchTarget..".")
			eHeliEvent.triggered = true
			willFly = false
		end
	else
		if eHelicopterSandbox.config.twitchIntegrationOnly == true then
			eHeliEvent.triggered = true
			print(" ----- EHE-TI: "..eHeliEvent.preset.." event bypassed.")
			return
		end

		foundTarget = eHelicopter:findTarget(nil, "eHeliEvent_engage")
		if SandboxVars.ExpandedHeli["Frequency_"..eHeliEvent.preset]==1 then
			eHeliEvent.triggered = true
			willFly = false
		end
	end

	if willFly and foundTarget then
		---@type eHelicopter
		local heli = getFreeHelicopter(eHeliEvent.preset)
		if heli then
			eHeliEvent.triggered = true
			heli:launch(foundTarget, (not not eHeliEvent.twitchTarget) )

			if eHeliEvent.twitchTarget then
				twitch_MoveHeliCloser(heli, foundTarget)
			end
		end
	end
end


function eHeliEvent_new(startDay, startTime, preset, twitchTarget)
	if (not startDay) or (not startTime) then
		return
	end
	local newEvent = {["startDay"] = startDay, ["startTime"] = startTime, ["preset"] = preset, ["triggered"] = false}

	if twitchTarget then newEvent["twitchTarget"] = twitchTarget end

	local globalModData = getExpandedHeliEventsModData()
	table.insert(globalModData.EventsOnSchedule, newEvent)

	if twitchTarget then
		eHeliEvent_Loop()
	end
end


local function onCommand(_module, _command, _dataA, _event)
	--serverside
	if _module == "twitchIntegration" then
		if _command == "scheduleEvent" then
			
			local appliedDayDelay, appliedHourDelay = 0, 0
			local configDelayBetween = eHelicopterSandbox.config.twitchHoursDelayBetweenEvents or 0

			local tHoursDelayBetweenEvents = math.max(0, configDelayBetween)
			if tHoursDelayBetweenEvents>0 then
				local latestEventDay = 0
				local latestEventHour = 0

				local globalModData = getExpandedHeliEventsModData()
				for _,event in pairs(globalModData.EventsOnSchedule) do
					if (eHelicopter_PRESETS[event.preset]) and event.twitchTarget and event.twitchTarget==_event.twitchTarget then
						if (event.startDay > latestEventDay) then
							latestEventDay = event.startDay
							latestEventHour = event.startTime
						elseif (event.startDay == latestEventDay) then
							if (event.startTime > latestEventHour) then
								latestEventHour = event.startTime
							end
						end
					end
				end

				local DaysDelayBetweenEvents = math.floor(tHoursDelayBetweenEvents/24)
				local HoursDelayBetweenEvents = math.floor(tHoursDelayBetweenEvents-(DaysDelayBetweenEvents*24))

				appliedDayDelay = latestEventDay+DaysDelayBetweenEvents
				appliedHourDelay = latestEventHour+HoursDelayBetweenEvents
			end

			local configTimeBefore = eHelicopterSandbox.config.twitchHoursBeforeEventsAllowed or 0
			local tHoursBeforeEventsAllowed = math.max(0, configTimeBefore)
			local DaysBeforeAllowed = math.floor(tHoursBeforeEventsAllowed/24)
			local HoursBeforeAllowed = math.floor(tHoursBeforeEventsAllowed-(DaysBeforeAllowed*24))

			local GT = getGameTime()
			local currentDay = GT:getNightsSurvived()
			local currentHour = GT:getHour()

			local startDay, startTime = 0, 0
			local dayHoursSelection = {
				["beforeAllowed"]={ d = DaysBeforeAllowed, h = HoursBeforeAllowed },
				["current"]={ d = currentDay, h = currentHour },
				["appliedDelay"]={ d = appliedDayDelay, h = appliedHourDelay }
			}

			for ID,dayHours in pairs(dayHoursSelection) do

				if dayHours.h > 24 then
					local dAdded = math.floor(dayHours.h/24)
					dayHours.h = dayHours.h-(dAdded*24)
					dayHours.d = dayHours.d+dAdded
				end

				if (dayHours.d > startDay) then
					startDay = dayHours.d
					startTime = dayHours.h
				elseif (dayHours.d == startDay) then
					if (dayHours.h > startTime) then
						startTime = dayHours.h
					end
				end
			end

			print(" ---- EHE-TI: Scheduled: "..tostring(_event.presetID).." d:"..startDay.."t: "..startTime.." target:".._event.twitchTarget)
			eHeliEvent_new(startDay, startTime, _event.presetID, _event.twitchTarget)
		end
	end
end
Events.OnClientCommand.Add(onCommand)--/client/ to server