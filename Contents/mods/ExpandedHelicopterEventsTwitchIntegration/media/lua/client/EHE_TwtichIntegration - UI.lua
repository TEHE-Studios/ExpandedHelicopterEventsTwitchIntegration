--require "ISUI/ISUIElement"
require "ISUI/ISButton"

local SCHEDULER_ICON = {
    TWITCH =    { COLOR = getTexture("media/textures/scheduleButtons/t_color.png"),
                  WHITE = getTexture("media/textures/scheduleButtons/t_w.png"),
                  BLACK = getTexture("media/textures/scheduleButtons/t_b.png"), },
    YOUTUBE =   { COLOR = getTexture("media/textures/scheduleButtons/yt_color.png"),
                  WHITE = getTexture("media/textures/scheduleButtons/yt_w.png"),
                  BLACK = getTexture("media/textures/scheduleButtons/yt_b.png"), },
}

local SCHEDULER_ICONS = {}

for famID,family in pairs(SCHEDULER_ICON) do
    for colorID,texture in pairs(family) do
        table.insert(SCHEDULER_ICONS, texture)
    end
end


---@class schedulerButton
schedulerButton = ISButton:derive("schedulerButton")

local currentSchedulerIconIndex = 1
local schedulerButtonUI
local function setUpSchedulerButton(player)
    ---@type schedulerButton|ISButton|ISPanel|ISUIElement
    schedulerButtonUI = schedulerButton:new(-50, -50, 20, 20, player)
    print(" -- EHE-TI: button created")
end

Events.OnCreatePlayer.Add(setUpSchedulerButton)


function schedulerButton:onMouseUp(x, y)
    currentSchedulerIconIndex = currentSchedulerIconIndex+1
    if currentSchedulerIconIndex > #SCHEDULER_ICONS then
        currentSchedulerIconIndex = 1
    end
    --print("currentSchedulerIconIndex:"..currentSchedulerIconIndex)
end

function schedulerButton:initialise()
    ISButton.initialise(self)
    self:addToUIManager()
    self:setVisible(true)
    --schedulerEvents = {}
end

function schedulerButton:render()
    if self.visible then
        local speedControls = UIManager.getSpeedControls()
        local x = speedControls:getX()-(25)
        local y = speedControls:getY()
        self:setX(x)
        self:setY(y)
        self:drawTexture(SCHEDULER_ICONS[currentSchedulerIconIndex], -6, -6, 1, 1, 1, 1)

        --if self.tooltipUI then self.tooltipUI:setVisible(false) end
        self.tooltip = " No events on schedule. "
        local C_EHE = CLIENT_ExpandedHelicopterEvents
        if C_EHE and C_EHE.EventsOnSchedule and #C_EHE.EventsOnSchedule>0 then
            local newTooltip = ""
            for k,e in pairs(C_EHE.EventsOnSchedule) do
                if not e.triggered then
                    newTooltip = newTooltip.." - "..e.preset.."  Day:"..e.startDay.." Time:"..e.startTime.."\n"
                end
            end
            self.tooltip = newTooltip.." "
            --if self.tooltipUI then self.tooltipUI:setVisible(true) end
        end

        ISButton.render(self)
    end
end

function schedulerButton:new(x, y, width, height, player)
    local o = {}
    o = ISButton:new(x, y, width, height)
    setmetatable(o, self)
    self.__index = self
    o.x = x
    o.y = y
    o.displayBackground = false
    o.player = player
    o.width = width
    o.height = height
    o.visible = true
    o.title = ""
    o.tooltip = " "--getText("")
    o.center = false
    o:initialise()
    return o
end



--[[
local function drawDetailsTooltip(tooltip, tooltipStart, skillsRecord, x, y, fontType)
    local lineHeight = getTextManager():getFontFromEnum(fontType):getLineHeight()
    local fnt = {r=0.9, g=0.9, b=0.9, a=1}
    tooltip:drawText(tooltipStart, x, (y+(15-lineHeight)/2), fnt.r, fnt.g, fnt.b, fnt.a, fontType)
    if skillsRecord then
        y=y+(lineHeight*1.5)
        tooltip:drawText(skillsRecord, x+1, (y+(15-lineHeight)/2), fnt.r, fnt.g, fnt.b, fnt.a, fontType)
    end
end

local fontDict = { ["Small"] = UIFont.NewSmall, ["Medium"] = UIFont.NewMedium, ["Large"] = UIFont.NewLarge, }
local fontBounds = { ["Small"] = 28, ["Medium"] = 32, ["Large"] = 42, }

local ISToolTipInv_render = ISToolTipInv.render
function ISToolTipInv.render(self)
    if not ISContextMenu.instance or not ISContextMenu.instance.visibleCheck then
        local itemObj = self.item
        if itemObj and itemObj:getType() == "SkillRecoveryJournal" then

            local tooltipStart, skillsRecord = SRJ.generateTooltip(itemObj)

            local font = getCore():getOptionTooltipFont()
            local fontType = fontDict[font] or UIFont.Medium
            local textWidth = math.max(getTextManager():MeasureStringX(fontType, tooltipStart),getTextManager():MeasureStringX(fontType, skillsRecord))
            local textHeight = getTextManager():MeasureStringY(fontType, tooltipStart)

            if skillsRecord then textHeight=textHeight+getTextManager():MeasureStringY(fontType, skillsRecord)+8 end

            local journalTooltipWidth = textWidth+fontBounds[font]
            ISToolTipInv_render_Override(self,journalTooltipWidth)

            local tooltipY = self.tooltip:getHeight()-1

            self:setX(self.tooltip:getX() - 11)
            if self.x > 1 and self.y > 1 then
                local yoff = tooltipY + 8
                local bgColor = self.backgroundColor
                local bdrColor = self.borderColor

                self:drawRect(0, tooltipY, journalTooltipWidth, textHeight + 8, math.min(1,bgColor.a+0.4), bgColor.r, bgColor.g, bgColor.b)
                self:drawRectBorder(0, tooltipY, journalTooltipWidth, textHeight + 8, bdrColor.a, bdrColor.r, bdrColor.g, bdrColor.b)
                drawDetailsTooltip(self, tooltipStart, skillsRecord, 15, yoff, fontType)
                yoff = yoff + 12
            end
        else
            ISToolTipInv_render(self)
        end
    end
end
--]]