--require "ISUI/ISUIElement"
require "ISUI/ISButton"

local SCHEDULER_ICON = {
    TWITCH = {
        COLOR = getTexture("media/textures/scheduleButtons/t_color.png"),
        WHITE = getTexture("media/textures/scheduleButtons/t_w.png"),
        BLACK = getTexture("media/textures/scheduleButtons/t_b.png"),
    },
    YOUTUBE = {
        COLOR = getTexture("media/textures/scheduleButtons/yt_color.png"),
        WHITE = getTexture("media/textures/scheduleButtons/yt_w.png"),
        BLACK = getTexture("media/textures/scheduleButtons/yt_b.png"),
    },
}


local SCHEDULER_ICONS = {}

for _,family in pairs(SCHEDULER_ICON) do
    for _,texture in pairs(family) do
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
end

function schedulerButton:render()
    if self.visible then
        local speedControls = UIManager.getSpeedControls()
        local x = speedControls:getX()-(25)
        local y = speedControls:getY()
        self:setX(x)
        self:setY(y)
        self:drawTexture(SCHEDULER_ICONS[currentSchedulerIconIndex], -6, -6, 1, 1, 1, 1)
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
    o.tooltip = "TEST"--getText("")
    o.center = false
    o:initialise()
    return o
end
