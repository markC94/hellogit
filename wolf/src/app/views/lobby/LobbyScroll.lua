-- region *.lua
-- Date
-- 此文件由[BabeLua]插件自动生成

local LobbyScroll = class("LobbyScroll")
local AUTO_STOP_SPEED = 2    -- 惯性滑动停止速度
local AUTO_IN_MOVE = 20      -- 手势滑动开启平均值

local AUTO_FRICTIONE = 0.3  -- 摩擦力
local AUTO_MAX_SPEED = 30   -- 速度峰值

local BOUNDRAY_LEN = 100    -- 边缘回弹距离
local BOUNDRAY_TIME = 0.1   -- 边缘回弹时间
local DELTA_SPEED = 0.5     -- 惯性初速度系数


--if device.platform == "android" then
AUTO_FRICTIONE = 0.6  -- 摩擦力
AUTO_MAX_SPEED = 50   -- 速度峰值
DELTA_SPEED = 0.75    -- 惯性初速度系数
--elseif device.platform == "windows" then
--AUTO_FRICTIONE = 1.2  -- 摩擦力
--AUTO_MAX_SPEED = 40   -- 速度峰值
--DELTA_SPEED = 0.5    -- 惯性初速度系数
--end
local CENTER_POS = 266  --大厅中心位置偏移量
local CENTER_BOUNDARY_POS=1334 --右侧第一次回弹启动距离
function LobbyScroll:ctor(node)
    self:initData()
    self:initHead(node)
    self:initContent(node)
    self:move(CENTER_POS)
    self.node=node
    node:onUpdate(handler(self, self.update))
end

function LobbyScroll:initData()
    self.contentPosition_x = 0
    self.topLeft = -20
    self.topRigth = 13540
    self.moveIndex = 1
    self.moveList = { 0, 0, 0, 0, 0, 0 }
    self.headCount=6
    self.isAuto = false
    self.autoSpeed = 0
end

function LobbyScroll:reset()
    if self.lobbyHead then
        self.lobbyHead:reset()
    end
    self:initData()
    self:move(CENTER_POS)
    self:updateHead()
end

function LobbyScroll:initHead(node)
    local list_friend = node:getChildByName("list_friend")
    self.lobbyHead = bole:getEntity("app.views.lobby.LobbyScrollHead", list_friend)
    self:updateHead()
end

function LobbyScroll:startAddHead()
    if self.addHeading then
        return
    end
    self.addHeading=true
    performWithDelay(self.node,function()
        self:addHead()
    end,0.2)
    performWithDelay(self.node,function()
        self.addHeading=nil
    end,0.7)
end
function LobbyScroll:addHead()
    if self.maxHead then
        return
    end
    self.headCount=self.headCount+6
    if self.headCount>=self.lobbyHead:getMaxHeadCount() then
        self.headCount=self.lobbyHead:getMaxHeadCount()
        self.maxHead=true
    end
    self:updateHead()
end

function LobbyScroll:updateHead()
    self.lobbyHead:setHeadCount(self.headCount)
    self.topRigth = self.lobbyHead:getMaxPos()
end
function LobbyScroll:initContent(node)
    self.content = node
    local function onTouchBegan(touch, event)
        self:touchBeginLogic(touch, event)
        return true
    end
    local function onTouchEnded(touch, event)
        self:toucEndLogic(touch, event)
    end
    local function onTouchCancelled(touch, event)
        self:toucEndLogic(touch, event)
    end
    local function onTouchMoved(touch, event)
        self:touchMoveLogic(touch, event)
    end

    local listener1 = cc.EventListenerTouchOneByOne:create()
    listener1:setSwallowTouches(true)
    listener1:registerScriptHandler(onTouchBegan, cc.Handler.EVENT_TOUCH_BEGAN)
    listener1:registerScriptHandler(onTouchMoved, cc.Handler.EVENT_TOUCH_MOVED)
    listener1:registerScriptHandler(onTouchEnded, cc.Handler.EVENT_TOUCH_ENDED)
    listener1:registerScriptHandler(onTouchCancelled, cc.Handler.EVENT_TOUCH_CANCELLED)
    local eventDispatcher = node:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener1, node)
end

function LobbyScroll:add(child, zorder, tag)
    if tag then
        self.content:addChild(child, zorder, tag)
    elseif zorder then
        self.content:addChild(child, zorder)
    else
        self.content:addChild(child)
    end
end

function LobbyScroll:getPosition()
    return self.content:getPosition()
end

function LobbyScroll:getBoundaryFactor(dir)
    if self:getBoundaryType() == 1 and dir < 0 then
        return 0.5
    elseif self:getBoundaryType() == 2 and dir > 0 then
        return 0.5
    end
    return 1
end

function LobbyScroll:getBoundaryType()
    if self.contentPosition_x < self.topLeft then
        return 1
    elseif self.contentPosition_x > self.topRigth then
        return 2
    end
    return 0
end
function LobbyScroll:isBoundary()
    --补丁
    if self.isCenterBoundary then   
        if self.autoSpeed < 0 and self.contentPosition_x <= CENTER_POS- BOUNDRAY_LEN then
            self.contentPosition_x = CENTER_POS-BOUNDRAY_LEN
            self:stopAutoScroll()
            self.content:runAction(cc.MoveTo:create(BOUNDRAY_TIME, cc.p(CENTER_POS, 0)))
            self.isCenterBoundary=nil
            return true
        end
    end
    if self.contentPosition_x <= self.topLeft - BOUNDRAY_LEN then
        self.contentPosition_x = self.topLeft - BOUNDRAY_LEN
        return true
    elseif self.contentPosition_x >= self.topRigth then
        self:startAddHead()
        if self.contentPosition_x >= self.topRigth + BOUNDRAY_LEN then
            self.contentPosition_x = self.topRigth + BOUNDRAY_LEN
            return true
        end
    end
end

function LobbyScroll:move(x)
    if x then
        self.contentPosition_x = x
    end

    if self:isBoundary() then
        self:stopAutoScroll()
    end
    self.content:setPosition(self.contentPosition_x, 0)
    self.lobbyHead:step(self.contentPosition_x)
    if not self.isCenterBoundary then
        if self.contentPosition_x >=CENTER_BOUNDARY_POS then
            self.isCenterBoundary=true
        end
    end
end

function LobbyScroll:startBoundary()
    if self:getBoundaryType() == 1 then
        self.contentPosition_x = self.topLeft
    elseif self:getBoundaryType() == 2 then
        self.contentPosition_x = self.topRigth
    else
        return
    end
    self:stopAutoScroll()
    self.content:runAction(cc.MoveTo:create(BOUNDRAY_TIME, cc.p(self.contentPosition_x, 0)))
end



function LobbyScroll:touchBeginLogic(touch, event)
    self:stopAutoScroll()
end

function LobbyScroll:touchMoveLogic(touch, event)
    local delta = touch:getDelta()
    local target = event:getCurrentTarget()
    local posX, posY = target:getPosition()
    local touchBeginPosition = posX
    local touchMovePosition = delta.x * self:getBoundaryFactor(delta.x)
    local newPosition = touchMovePosition + touchBeginPosition
    local locationInNode = target:convertToWorldSpace(touch:getLocation())
    self:move(newPosition)
    self:pushMoveDelta(touchMovePosition)
end

function LobbyScroll:toucEndLogic(touch, event)
    local delta = self:getMoveDelta()
    if math.abs(delta) > AUTO_IN_MOVE then
        self:startAutoScroll(delta)
    else
        self:stopAutoScroll()
    end
    self:startBoundary()
end

function LobbyScroll:pushMoveDelta(delta)
    self.moveList[self.moveIndex] = delta
    self.moveIndex = self.moveIndex + 1
    if self.moveIndex > 6 then
        self.moveIndex = 1
    end
end

function LobbyScroll:getMoveDelta()
    local delta = 0
    for i = 1, 6 do
        delta = delta + self.moveList[i]
    end
    return delta
end
function LobbyScroll:startAutoScroll(delta)
    self.isAuto = true
    self.autoSpeed = delta * DELTA_SPEED
end

function LobbyScroll:stopAutoScroll()
    self.isAuto = false
    self.autoSpeed = 0
    self.moveList = { 0, 0, 0, 0, 0, 0 }
    self.moveIndex = 1
end

function LobbyScroll:update(dt)
    if self.isAuto then
        if math.abs(self.autoSpeed) <= AUTO_STOP_SPEED then
            self:stopAutoScroll()
            self:startBoundary()
            return
        end
        self.autoSpeed = self.autoSpeed - self.autoSpeed * AUTO_FRICTIONE * 0.1 * dt * 60
        --        print("------autoSpeed="..self.autoSpeed)
        if self.autoSpeed > AUTO_MAX_SPEED then
            self:move(self.contentPosition_x + AUTO_MAX_SPEED * self:getBoundaryFactor(self.autoSpeed))
        elseif self.autoSpeed < - AUTO_MAX_SPEED then
            self:move(self.contentPosition_x - AUTO_MAX_SPEED * self:getBoundaryFactor(self.autoSpeed))
        else
            self:move(self.contentPosition_x + self.autoSpeed * self:getBoundaryFactor(self.autoSpeed))
        end
        if self:isBoundary() then
            print("------isBoundary=-------------------")
            self:startBoundary()
        end
    end
end

return LobbyScroll
-- endregion
