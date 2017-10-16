-- region *.lua
-- Date
-- 此文件由[BabeLua]插件自动生成
local SimpleMoveAction = class("SimpleMoveAction", cc.Node)
local ACTION_IDLE = 1
local ACTION_START = 2
local ACTION_STEP = 3
local ACTION_STOP = 4
--目前是升级老虎机使用
function SimpleMoveAction:ctor(data, node)
    --匀速滚动时间
    self.time = data.time
    --起始速度加和速度 (停止加速度有最终距离和最大速度决定)
    self.max_speed = 50
    self.rate = 1.5
    --最终停滞位置
    self.maxPos = data.maxPos
    --起始坐标
    self.orgX = data.X
    self.orgY = data.Y
   
    self.moveNode = node
    --默认为0 第二圈开始坐标偏移量
    self.addY = data.addY
    --停止回调
    self.callFun = data.callFun
    if not self.addY then
        self.addY = 0
    end
    
    self.cur_pos = - data.Y
    self.cur_speed = 0
    self.action = ACTION_START
    local function update(dt)
        self:updateWaitTime(dt)
    end
    self:onUpdate(update)
end

function SimpleMoveAction:updateWaitTime(dt)
    if self.action == ACTION_IDLE then
        self:idle()
    elseif self.action == ACTION_START then
        self:start(dt)
    elseif self.action == ACTION_STEP then
        self:step(dt)
    elseif self.action == ACTION_STOP then
        self:stop(dt)
    end
    self:checkPos()
end
function SimpleMoveAction:idle()

end

function SimpleMoveAction:start(dt)
    --local fps = cc.Director:getInstance():getAnimationInterval()
    if self.cur_speed < self.max_speed then
        self.cur_speed = self.cur_speed + self.rate
    else
        self.action = ACTION_STEP
        self.cur_speed = self.max_speed
    end
end

function SimpleMoveAction:step(dt)
    self.time = self.time - dt
    if self.time <= 0 then
        self.action = ACTION_STOP
        self.cur_pos = - self.orgY + self.addY
        self.rate = self.max_speed * self.max_speed /(self.maxPos - self.addY/2)/2
    end
end

function SimpleMoveAction:stop(dt)
    --local fps = cc.Director:getInstance():getAnimationInterval()
    self.cur_speed = self.cur_speed - self.rate
    if self.cur_speed <= 0 then
        self.cur_speed=0
        self:isIdle()
    end
end

function SimpleMoveAction:isIdle()
    if self.action == ACTION_STOP then
        self.action = ACTION_IDLE
        self.cur_speed = 0
        self.moveNode:setPosition(cc.p(self.orgX, - self.maxPos))
        if self.callFun then
            self.callFun()
        end
        return true
    end
end

function SimpleMoveAction:checkPos()
    if self.cur_speed == 0 then
        return
    end
    self.cur_pos = self.cur_pos + self.cur_speed
    if self.cur_pos > self.maxPos then
        self.cur_pos = - self.orgY + self.addY
        if self:isIdle() then
            return
        end
    end
    self.moveNode:setPosition(cc.p(self.orgX, - self.cur_pos))
end
return SimpleMoveAction
-- endregion
