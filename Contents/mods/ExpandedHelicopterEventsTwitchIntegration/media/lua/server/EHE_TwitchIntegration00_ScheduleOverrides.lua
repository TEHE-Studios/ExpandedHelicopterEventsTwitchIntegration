require "ExpandedHelicopter06_EventScheduler"

local EHETI_eHeliEvent_ScheduleNew = eHeliEvent_ScheduleNew
function eHeliEvent_ScheduleNew(startDay, startTime, preset)
	if eHelicopterSandbox.config.twitchIntegrationOnly == false then
		EHETI_eHeliEvent_ScheduleNew(startDay, startTime, preset)
	end
end


local EHETI_eHeliEvent_engage = eHeliEvent_engage
function eHeliEvent_engage(ID)
	if not ID then
		return
	end
	if eHelicopterSandbox.config.twitchIntegrationOnly == false then
		EHETI_eHeliEvent_engage(ID)
	else
		local globalModData = getExpandedHeliEventsModData()
		local eHeliEvent = globalModData.EventsOnSchedule[ID]
		eHeliEvent.triggered = true
		print("EHE-TI: event loop bypassed.")
	end
end