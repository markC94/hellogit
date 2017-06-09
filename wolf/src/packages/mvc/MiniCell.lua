--region *.lua
--Date
--此文件由[BabeLua]插件自动生成
local MiniCell = class("MiniCell",cc.Node)

local ACTION_IDLE = "idle"
local ACTION_CLICK = "click"
local ACTION_TRIGGET = "trigget"
local ACTION_OVER = "over"
-- minigame id

function MiniCell:ctor(gameid, tag, callback)
    self.gameid=gameid
    self:setTag(tag)
    self.callback = callback
    
    self.status = ACTION_IDLE
    self.touch = nil
    self.delay_time = -1
   
    schedule(self, self.updateTime, 0.1)

    self:onCreate()

    self:idle()
end

function MiniCell:onCreate()
    self:setTouchSize(200,200)
end

function MiniCell:setTouchSize(width,height)
    self.width = width
    self.height = height
    self:initTouch()
end
function MiniCell:updateTime()
    if self.delay_time == -1 then
        return
    end
    if self.delay_time <= 0 then
        self.delay_time = -1
        self:timeCallback()
        return
    end
    self.delay_time = self.delay_time - 0.1
end
function MiniCell:timeCallback()
    
end
function MiniCell:setTimeCallback(delayTime)
    self.delay_time=delayTime
end
function MiniCell:idle()
    self.status = ACTION_IDLE
    --self.action:play(self.status,true)
end

function MiniCell:changeNode(fileName)
    if not fileName then return end
    if self.animaNode then
        self.animaNode:removeFromParent()
        self.animaNode = nil
    end
    self.animaNode = cc.CSLoader:createNode(fileName)
    self:addChild(self.animaNode)
    self.action = cc.CSLoader:createTimeline(fileName)
    self.animaNode:runAction(self.action)
    self.action:gotoFrameAndPause(0)
end
function MiniCell:initTouch()
    local function touchEvent(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            if (self.status == ACTION_IDLE)then
                if self.callback then
                    self.callback(self:getTag())
                end
            end
        end
    end
    local touch = ccui.Layout:create()
    self.touch = touch
    touch:ignoreContentAdaptWithSize(false)
    touch:setClippingEnabled(false)
    touch:setBackGroundColorOpacity(102)
    touch:setTouchEnabled(true);
    touch:setLayoutComponentEnabled(true)
    touch:setName("touch")
    touch:setTag(100)
    touch:setCascadeColorEnabled(true)
    touch:setCascadeOpacityEnabled(true)
    touch:setAnchorPoint(0.5000, 0.5000)
    local isColor=false
    if isColor then
        touch:setBackGroundColorType(1)
        touch:setBackGroundColor( { r = 0, g = 0, b = 0 })
    end

    local layout = ccui.LayoutComponent:bindLayoutComponent(touch)
    layout:setSize( { width = self.width, height = self.height })
    layout:setLeftMargin(-100.0000)
    layout:setRightMargin(-100.0000)
    layout:setTopMargin(-100.0000)
    layout:setBottomMargin(-100.0000)
    self:addChild(touch)
    self.touch:addTouchEventListener(touchEvent)
end

return MiniCell
--endregion
