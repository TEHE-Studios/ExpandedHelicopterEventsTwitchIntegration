require "EHE_TwitchIntegration00_ScheduleOverrides"

local function onCommand(_module, _command, _player, _event)
    --serverside
    if _module == "twitchIntegration" then
        if getDebug() then print("Received command from " .. _player:getUsername() .." [".._module..".".._command.."]") end
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

            triggerEvent("EHE_ServerModDataReady")
        end
    end
end
Events.OnClientCommand.Add(onCommand)--/client/ to server