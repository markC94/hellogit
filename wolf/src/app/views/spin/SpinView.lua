local testFrames = false
local SpinAction = class("SpinAction")  -- 动作的基础类(抽象的类)
function SpinAction:ctor(duration)
    self.duration = duration
    self.elapsed = 0
    self.isFirst = true
    self.timeOver = false  -- 动作结束
    self.eventCommand = {} -- 动作事件注册

    if testFrames then
        self.frameCount = 0
        self.log = {}
    end
end

function SpinAction:setName(name)
    if testFrames then
        self.actionName = name
    end
end

function SpinAction:recordEachFrame(dt, s)
    if testFrames then
        local info = {dt, s}
        table.insert(self.log, info)
    end
end

function SpinAction:isDone()
    return self.timeOver
end

function SpinAction:isRunning()
    return not self.isFirst
end

function SpinAction:execAction(tag)
    if testFrames then
        self.target:recordLog("execAction name=" .. self.actionName)
    end
end

function SpinAction:stop()
    self.timeOver = true

    if testFrames then
        self.target:recordLog(string.format("stopAciton name=%s,time=%f,frames=%d,s=%f", self.actionName, self.elapsed, self.frameCount, self.movedDistance or 0))
        self.target:recordEachFrameLog(self.actionName, self.log)
    end
end

function SpinAction:update(s)
    return self.target:step(s)
end

-- 动作执行的第一帧执行的方法
function SpinAction:init()
    if testFrames then
        self.target:recordLog("aciton start name=" .. self.actionName)
    end
end

function SpinAction:step(dt)
    if not self.target then return false end

    if self.isFirst then
        self.isFirst = false
        self.speed = self.target:getSpeed()
        self:init()
    end

    if self.timeOver then return false end

    self.elapsed = self.elapsed + dt

    if testFrames then
        self.frameCount = self.frameCount + 1
    end

    if self.elapsed >= self.duration then
        self.timeOver = true
        if self:getTagEnabled("cutTime") then
            self.elapsed = self.duration
        end
    end

    return true
end

function SpinAction:overTime()
    if self.elapsed + 0.5*self.target:getFrameInterval() > self.duration then
        self.timeOver = true
        self:actionDoneCallback()
    end
end

function SpinAction:runWithTarget(target)
    self.target = target
end

function SpinAction:actionDoneCallback()
    if testFrames then
        self.target:recordLog(string.format("aciton end name=%s,time=%f,frames=%d,s=%f", self.actionName, self.elapsed, self.frameCount, self.movedDistance or 0))
        self.target:recordEachFrameLog(self.actionName, self.log)
    end

    if self.endCallback then
        self.endCallback()
    end
end

function SpinAction:setEndCallback(endBack)
    self.endCallback = endBack
end

function SpinAction:setEventCallback(eventName, func, target, args)
    self.eventCommand[eventName] = { eventName = eventName, target = target, func = func, args = args }
end

function SpinAction:removeEvent(eventName)
    self.eventCommand[eventName] = nil
end

function SpinAction:removeAllEvent(eventName)
    self.eventCommand = {}
end

function SpinAction:setTagEnabled(tag)
    self[tag .. "Enabled"] = true
end

function SpinAction:setTagDisabled(tag)
    self[tag .. "Enabled"] = false
end

function SpinAction:getTagEnabled(tag)
    return self[tag .. "Enabled"]
end

function SpinAction:stopByTag(tag)
    if self[tag .. "Enabled"] then
        self:stop()
    end
end

function SpinAction:execByTag(tag)
    if self[tag .. "Enabled"] then
        self:execAction(tag)
    end
end


local SpinSpeedAction = class("SpinSpeedAction", SpinAction)    -- 速度动作
function SpinSpeedAction:ctor(duration, accelerate)
    SpinSpeedAction.super.ctor(self, duration)
    self.accelerate = accelerate or 0
    self.movedDistance = 0
end

function SpinSpeedAction:step(dt)
    local lastElapsed
    if testFrames then
        lastElapsed = self.elapsed
    end

    if not SpinSpeedAction.super.step(self, dt) then return false end

    local s = self.speed * self.elapsed + 0.5 * self.accelerate * math.pow(self.elapsed, 2)
    local disLen = s - self.movedDistance
    self.movedDistance = s
    self:update(disLen)

    if testFrames then
        self:recordEachFrame(self.elapsed-lastElapsed, disLen)
    end

    if self.accelerate ~= 0 then
        self.target:setSpeed(self.speed + self.accelerate * self.elapsed)
    end

    if self.timeOver then
        self:actionDoneCallback()
    else
        if self.elapsed + self.target:getFrameInterval() > self.duration then
            self:overTime()
        end
    end

    return true
end

function SpinSpeedAction:execAction(tag)
    SpinSpeedAction.super.execAction(self, tag)
    if tag == "questNetData" then
        if not self.timeOver then
            self.duration = self.elapsed + 0.02
        end
    end
end

function SpinSpeedAction:reset()
    if testFrames then
        self.target:recordLog(string.format("reset action name=%s,duration=%f,frames=%d,s=%f", self.actionName, self.elapsed, self.frameCount, self.movedDistance or 0))
    end

    self.elapsed = 0
    self.movedDistance = 0
end


local SpinDelayAction = class("SpinDelayAction", SpinSpeedAction)    -- 只做延时时间
function SpinDelayAction:ctor(duration, isKeepStop)
    SpinDelayAction.super.ctor(self, duration)
    self.isKeepStop = isKeepStop
end

function SpinDelayAction:init()
    SpinDelayAction.super.init(self)
    if self.isKeepStop then
        self.speed = 0
    end
end


local SpinWaitNetDataAction = class("SpinWaitNetDataAction", SpinSpeedAction)  -- 等待网络数据
function SpinWaitNetDataAction:ctor()
    SpinWaitNetDataAction.super.ctor(self, 10)
    self:setTagEnabled("wait")
end


local SpinWinBonusAction = class("SpinWinBonusAction", SpinSpeedAction)   -- 快要得到bounce和scatter时的加速提示动作
function SpinWinBonusAction:ctor(duration, lastSpeed)
    self.lastSpeed = lastSpeed
    self.delayDuration = duration
    SpinWinBonusAction.super.ctor(self, 15)
    self:setTagEnabled("winBonusAction")
    self.accelerateEnabled = false
    self.accelerateTime = 0.2
end

function SpinWinBonusAction:step(dt)
    if self.accelerateEnabled and self.accelerate == 0 then
        local speed = self.target:getSpeed()
        self.accelerate = (self.lastSpeed-speed)/self.accelerateTime
        bole:postEvent("promptSuccess", self.target:getColumnIndex())
        self.target:execByTag("movie")
    end

    local result = SpinWinBonusAction.super.step(self, dt)

    if self.accelerateEnabled and not self:isDone() then
        if self.elapsed >= self.accelerateTime then
            self.accelerate = 0
            self.speed = self.target:getSpeed()
            
            self:reset()
            self.duration = self.duration - self.accelerateTime
            self.accelerateEnabled = false
        end
    end
    
    return result
end

function SpinWinBonusAction:execAction(tag)
    SpinWinBonusAction.super.execAction(self, tag)
    self:reset()
    self.duration = self.delayDuration + self.accelerateTime
    self.accelerateEnabled = true
end


local SpinTrueReelAction = class("SpinTrueReelAction", SpinSpeedAction)   -- 替换真滚轴
function SpinTrueReelAction:ctor(speed)
    self.stopClickSpeed = speed
    self:setTagEnabled("stopAccelerate")
    SpinTrueReelAction.super.ctor(self)
end

function SpinTrueReelAction:init()
    SpinTrueReelAction.super.init(self)
    if self.speed > 5000 then
        self.speed = 5000
    end

    self.needMoveLen = self.target:getRemainLen() + self.target:getTrueReelUpdateLen()
    if self.clickStop then
        self.speed = self.stopClickSpeed
        self.target:setSpeed(self.speed)
    end

    self.duration = (self.needMoveLen+1) / self.speed
    self.target:startReplaceTrueReel()
end

function SpinTrueReelAction:overTime()
end

function SpinTrueReelAction:execAction(tag)
    SpinTrueReelAction.super.execAction(self, tag)
    if self.clickStop then
        return
    end

    if self.needMoveLen and self.elapsed + 5*self.target:getFrameInterval() < self.duration then
        self.needMoveLen = self.needMoveLen - self.movedDistance
        self.speed = self.stopClickSpeed
        self.target:setSpeed(self.speed)

        self.duration = (self.needMoveLen+1) / self.speed
        self:reset()
    end
    self.clickStop = true
end


local SpinStopAction = class("SpinStopAction", SpinSpeedAction)   -- 停止动作
function SpinStopAction:ctor(speed)
    self.stopClickSpeed = speed
    self:setTagEnabled("stopAccelerate")
    SpinStopAction.super.ctor(self)
end

function SpinStopAction:init()
    SpinStopAction.super.init(self)
    self.needMoveLen = self.target:getRemainLen()
    if self.clickStop then
        self.speed = self.stopClickSpeed
        self.target:setSpeed(self.speed)
    end

    self.duration = self.needMoveLen / self.speed
    self:setTagEnabled("cutTime")
end

function SpinStopAction:execAction(tag)
    SpinStopAction.super.execAction(self, tag)
    if self.clickStop then
        return
    end

    if self.needMoveLen and self.elapsed + 5*self.target:getFrameInterval() < self.duration then
        self.needMoveLen = self.needMoveLen - self.movedDistance
        self.speed = self.stopClickSpeed
        self.target:setSpeed(self.speed)

        self.duration = self.needMoveLen / self.speed
        self:reset()
    end
    self.clickStop = true
end

local ignoreLenMix = 0.8
-- 特殊处理 （只会在checkAction的地方调用，少调用一次）
function SpinStopAction:isDone()
    if SpinStopAction.super.isDone(self) then
        return true
    else
        if not self:isRunning() then
            return self.target:getRemainLen() < ignoreLenMix*self.target:getFirstMovieLen()
        else
            return false
        end
    end
end

function SpinStopAction:overTime()
    if self.target:getRemainLen() < ignoreLenMix*self.target:getFirstMovieLen() then
        SpinStopAction.super.overTime(self)
    end
end


local SpinJumpAction = class("SpinJumpAction", SpinAction)  -- 弹动作播电影
function SpinJumpAction:ctor(movie)
    SpinJumpAction.super.ctor(self)
    self.movie = movie
    self:setTagEnabled("movie")

    local maxIndex = 1
    local maxLen = movie[maxIndex]
    for k, v in ipairs(self.movie) do
        if v > maxLen then
            maxLen = v
            maxIndex = k
        else
            break
        end
    end
    self.maxIndex = maxIndex
    self.maxLen = maxLen
end

function SpinJumpAction:init()
    SpinJumpAction.super.init(self)
    self.index = 1
    self.movedDistance = 0
    self.duration = 2
    
    self.remainLenForEachFrame = self.target:getMinRemain()

    if testFrames then
        self.target:recordLog(string.format("triggerStopEvent remainLenForEachFrame=%f, maxlen=%d", self.remainLenForEachFrame, self.maxLen))
    end
end

function SpinJumpAction:triggerStopEvent()
    if not self.hadColumnStop then
        self.hadColumnStop = true

        bole:postEvent("columnStop", {self.target:getColumnIndex(), self.noJump})

        if testFrames then
            self.target:recordLog(string.format("triggerStopEvent backLen=%f", remainLen))
        end
    end
end

function SpinJumpAction:step(dt)
    if not SpinJumpAction.super.step(self, dt) then return false end

    local thisBouncePosY = self.movie[self.index]
    local disLen = thisBouncePosY - self.movedDistance

    self.movedDistance = thisBouncePosY

    if self.index <= self.maxIndex and self.remainLenForEachFrame > 0 then
        disLen = disLen + self.remainLenForEachFrame*disLen/self.maxLen
    end

    local isUpdate = self:update(disLen)

    if testFrames then
        self:recordEachFrame(dt, disLen)
    end

    if self.remainLenForEachFrame == 0 and self.index == 1 then
        self:triggerStopEvent()
    elseif isUpdate and self.index <= self.maxIndex then
        self:triggerStopEvent()
    end

    self.index = self.index + 1
    if (self.noJump and self.hadColumnStop) or self.index > #self.movie then
        self:overTime()
    end

    return true
end

function SpinJumpAction:execAction(tag)
    self.noJump = true
end

function SpinJumpAction:overTime()
    self.timeOver = true
    self.target:resetPos()
    bole:postEvent("columnStopCalm", self.target:getColumnIndex())
    self:actionDoneCallback()
end


local ActionQueue = class("ActionQueue")
function ActionQueue:ctor()
    self.actions = {}
    self.runningAction = nil
    self.target = nil
    self.isRunning = false
end

function ActionQueue:update(dt)
    if not self:checkAction() then return false end

    self.runningAction:step(dt)

    return true
end

function ActionQueue:checkAction()
    if not self.isRunning then
        return false
    end

    if not self.runningAction or self.runningAction:isDone() then
        if #self.actions == 0 then
            self.runningAction = nil
            return false
        else
            self.runningAction = table.remove(self.actions, 1)
            return self:checkAction()
        end
    end
    return true
end

function ActionQueue:isDone()
    return #self.actions == 0 and (not self.runningAction or self.runningAction:isDone())
end

function ActionQueue:push(action)
    self.actions[#self.actions + 1] = action
end

function ActionQueue:addAction(action, target)
    assert((not self.target or target == self.target), "ActionQueue:addAction - target is changed")
    self:push(action)
    action:runWithTarget(target)

    if not self.target then
        self.target = target
    end
end

function ActionQueue:runWithTarget(target)
    self.target = target
    for _, v in pairs(self.actions) do
        v:runWithTarget(target)
    end
end

function ActionQueue:pause()
    self.isRunning = false
end

function ActionQueue:resume()
    self.isRunning = true
end

function ActionQueue:run()
    self.isRunning = true
end

function ActionQueue:stopByTag(tag)
    if not self.target then
        return
    end

    if self:isDone() then
        return
    end

    if self.runningAction then
        self.runningAction:stopByTag(tag)
    end

    for _, v in pairs(self.actions) do
        v:stopByTag(tag)
    end
end

function ActionQueue:execByTag(tag)
    if not self.target then
        return
    end

    if self:isDone() then
        return
    end

    if self.runningAction then
        self.runningAction:execByTag(tag)
    end

    for _, v in pairs(self.actions) do
        v:execByTag(tag)
    end
end

function ActionQueue:isStoped()
    return not self.isRunning or self:isDone()
end

function ActionQueue:clear()
    self.actions = {}
    self.runningAction = nil
    self.target = nil
    self.isRunning = false
end


local SpinColumn = class("SpinColumn")
function SpinColumn:ctor(columnIndex, spinView, theme)
    self.columnIndex = columnIndex
    self.spinView = spinView
    self.theme = theme

    self.app = theme:getSpinApp()
    self.themeId = theme:getThemeId()

    local matrix = theme:getMatrix()
    self.row = matrix.array[columnIndex]  --本列的行数
    self.rowNeedNum = matrix.filled  --本列上下需要填充的行数
    self.rowCount = self.row + 2*self.rowNeedNum  --这一列的总长度，包括棋盘的长度和上下填充的长度
    self.updateLen = matrix.cell_size[2] -- 纵向的两格之间的距离(移动一格的距离，也是更新symbol的触发距离)
    
    local bottomPos = matrix.coordinate[columnIndex]
    self.bottomPosY = bottomPos.y - self.updateLen * self.rowNeedNum  -- 最下面一行的位置(多出rowNeedNum格位置)
    self.bottomPosX = bottomPos.x

    self.trueSymbols = self:getTrueReel()
    self.falseSymbols = self:getFalseReel()
    self.startFalseReelIndex = 1
    self.startTrueReelIndex = 1
    self.remainLenNum = 0  --剩余长条的个数

    -- 包含的symbols节点
    self.nodes = {}
    for i = 1, self.rowCount do
        local symbolInfo = self:genSymbolTagInfo()
        table.insert(self.nodes, symbolInfo)
    end

    self:reorderSymbol()
    self:resetPos()  -- 重置每个symbol的位置，回到最正确的位置上

    self.actionQueue = ActionQueue:create()
    self:clear()

    if testFrames then
        self.log = {}
        self.eachFrameLog = {}
    end
end

function SpinColumn:getFrameInterval()
    return self.spinView:getFrameInterval()
end

function SpinColumn:getNodeHeight()
    return self.updateLen
end

function SpinColumn:clearRemainLongSymbol()
    if self.remainLenNum > 0 then
        local symbolLen = self.theme:getSymbolNumById(self.lastId)
        for i = #self.nodes, #self.nodes - (symbolLen - self.remainLenNum) + 1, -1 do  --替换非长条的
            local info = self.nodes[i]
            info.symbol = self.theme:getFilledInId()
            self:genSymbol(info)
        end
    end
    self.lastId = self.nodes[#self.nodes].symbol
    self.remainLenNum = 0
end

function SpinColumn:getColumnIndex()
    return self.columnIndex
end

function SpinColumn:clear()
    self.actionQueue:clear()
    self.trueSymbols = nil
    self.startTrueReelIndex = 0   -- 替换真滚轴的标志，以及替换的index
    self.speed = 0  -- 为了使速度不出现间隔性跳跃，移动的速度统一由actionNode统一管理
    self:reVisibleSymbol()
    self:clearAnimNodes()
end

function SpinColumn:resetPos()
    local remainLen = self.curThisMove
    self.curThisMove = 0
    self:reel()
    return remainLen
end

function SpinColumn:getRemainLen()
    return self.updateLen - self.curThisMove
end

function SpinColumn:getFirstMovieLen()
    return self.firstMovieLen
end

function SpinColumn:getMinRemain()
    if self.curThisMove < 1 or self.updateLen - self.curThisMove < 1 then
        return 0
    else
        return self:getRemainLen()
    end
end

--替换真滚轴需要走的距离
function SpinColumn:getTrueReelUpdateLen()
    return (self.rowCount - 2) * self.updateLen
end

function SpinColumn:addMoveNode(node, sp)
    for i, v in ipairs(self.nodes) do
        if v.node == sp then
            v.animNode = node
            break
        end
    end
end

function SpinColumn:clearAnimNodes()
    for i, v in ipairs(self.nodes) do
        if v.animNode then
            v.animNode = nil
        end
    end
end

function SpinColumn:reel()
    for i, v in ipairs(self.nodes) do
        if v.node and not v.isHide then
            local num = self.theme:getSymbolNumById(v.symbol)
            local posY = self.bottomPosY + (i - 1 + num/2) * self.updateLen - self.curThisMove
            v.node:setPositionY(posY)
            local animNode = v.animNode
            if animNode then
                animNode:setPositionY(posY)
            end
        end
    end
end

function SpinColumn:setVisible(isVisible)
    for i, v in ipairs(self.nodes) do
        if v.node and not v.isHide then
            v.node:setVisible(isVisible)
        end
    end
end

function SpinColumn:getSymbolSprite(row)
    local nodeIndex = self.rowCount - self.rowNeedNum - row + 1
    local info = self.nodes[nodeIndex]
    if not info.node or info.isHide then
        for i = nodeIndex, 1, -1 do
            local findInfo = self.nodes[i]
            if findInfo.node and not findInfo.isHide then
                return findInfo.node
            end
        end
    else
        return info.node
    end

    return nil
end

function SpinColumn:getNodeInfo(row)
    local nodeIndex = self.rowCount - self.rowNeedNum - row + 1
    return self.nodes[nodeIndex]
end

function SpinColumn:update(dt)
    self.actionQueue:update(dt)
end

function SpinColumn:step(s)
    local isUpdate = false
    self.curThisMove = self.curThisMove + s
    if self.curThisMove >= self.updateLen then
        local num = math.floor(self.curThisMove / self.updateLen)
        self.curThisMove = self.curThisMove - self.updateLen * num
        self:updateSymbols(num)
        isUpdate = true
    elseif self.curThisMove < 0 then
        self.curThisMove = 0
    end
    self:reel()
    return isUpdate
end

function SpinColumn:genSymbolTagInfo(info)
    if not info then
        info = {}
    end

    local symbol = self:getSymbolTag()

    if self.remainLenNum == 0 then
        info.symbol = symbol
        self:genSymbol(info)

        self.lastId = symbol
        self.remainLenNum = self.theme:getSymbolNumById(symbol) - 1
    else
        info.symbol = self.lastId
        self.remainLenNum = self.remainLenNum - 1

        if not info.isHide then
            info.isHide = true
            if info.node then
                info.node:setVisible(false)
            end
        end
    end

    return info
end

function SpinColumn:updateSymbols(num)
    for i = 1, num do
        local info = table.remove(self.nodes, 1)
        table.insert(self.nodes, info)
        
        self:genSymbolTagInfo(info)
    end
    self:reorderSymbol()
end

function SpinColumn:recordLog(content)
    if testFrames then
        table.insert(self.log, content)
    end
end

function SpinColumn:recordEachFrameLog(name, tableInfo)
    if testFrames then
        local info = {name, tableInfo}
        table.insert(self.eachFrameLog, info)
    end
end

function SpinColumn:printLog()
    if not testFrames then return end

    print("column\t" .. self:getColumnIndex())
    for _, v in ipairs(self.log) do
        print(v)
    end

    for _, info in pairs(self.eachFrameLog) do
        print("aciton\t" .. info[1] .. "\tframeCount=" .. #info[2])
        for _, item in ipairs(info[2]) do
            print(string.format("dt=%f\ts=%f", item[1], item[2]))
        end
    end

    self.log = {}
    self.eachFrameLog = {}
end

function SpinColumn:setTrueReel(trueSymbols, falseSymbols)
    self.trueSymbols = trueSymbols
    self.falseSymbols = falseSymbols
    self.startFalseReelIndex = 1

    self.actionQueue:stopByTag("wait")
end

function SpinColumn:setFalseReel(falseSymbols)
    self.falseSymbols = falseSymbols
end

function SpinColumn:startReplaceTrueReel()
    if not self.trueSymbols then return end

    self.startTrueReelIndex = 1
    self:clearRemainLongSymbol()
end

function SpinColumn:getSymbolTag()
    if self.startTrueReelIndex > 0 and self.startTrueReelIndex <= #self.trueSymbols then
        local tag = self.trueSymbols[self.startTrueReelIndex]
        self.startTrueReelIndex = self.startTrueReelIndex + 1
        return tag
    else
        local tag = self.falseSymbols[self.startFalseReelIndex]
        self.startFalseReelIndex = self.startFalseReelIndex + 1
        if self.startFalseReelIndex > #self.falseSymbols then
            self.startFalseReelIndex = 1
        end
        return tag
    end
end

function SpinColumn:reorderSymbol()
    for i, v in ipairs(self.nodes) do
        if v.node and not v.isHide then
            local symbol_set = self.theme:getItemById(v.symbol).symbol_set
            v.node:setLocalZOrder(self.rowCount-i+200*symbol_set)
        end
    end
end

function SpinColumn:reVisibleSymbol()
    for i, v in ipairs(self.nodes) do
        if v.node and not v.isHide then
            v.node:setVisible(true)
        end
    end
end

function SpinColumn:genSymbol(info)
    info.colum = self.columnIndex
    local isNew = self.theme:getSymbolInfo(info)
    local sp = info.node
    if isNew then
        sp:setPositionX(self.bottomPosX)
        self:getSymbolNode():addChild(sp)
    else
        if info.isHide then
            sp:setVisible(true)
        end
    end

    info.isHide = false
end

function SpinColumn:runAction(actionQueue)
    self.actionQueue = actionQueue
    self.actionQueue:runWithTarget(self)
    self:run()
end

function SpinColumn:setSpeed(speed)
    self.speed = speed
end

function SpinColumn:getSpeed()
    return self.speed
end

function SpinColumn:getSymbolNode()
    return self.spinView:getSymbolNode()
end

function SpinColumn:setWinBonusAction()
    self:execByTag("winBonusAction")
end

function SpinColumn:setTagEnabled(tag)
    self[tag .. "Enabled"] = true
end

function SpinColumn:setTagDisabled(tag)
    self[tag .. "Enabled"] = false
end

function SpinColumn:getTagEnabled(tag)
    return self[tag .. "Enabled"]
end

function SpinColumn:getTrueReel()
    return self.theme:getDisplayReelByColumn(self.columnIndex)
end

function SpinColumn:getFalseReel()
    return self.theme:getFalseReelByColumn(self.columnIndex)
end

function SpinColumn:spin(endCallback, stopAliveCallback)
    self:clear()

    -- 开始的延时时间
    local matrix = self.theme:getMatrix()
    local columnIndex = self.columnIndex
    local startDelay = matrix.start_delay[columnIndex]
    if startDelay > 0.01 then
        local startDelayAction = SpinDelayAction:create(startDelay, true)
        self:addAction(startDelayAction)
        startDelayAction:setName("StartDelayAction")
    end

    -- 加速时间
    local aTime = matrix.acceleration_time[columnIndex]
    local speed = matrix.speed[columnIndex]
    local addSpeedAction = SpinSpeedAction:create(aTime, speed / aTime)
    self:addAction(addSpeedAction)
    addSpeedAction:setName("AccelarateAction")

    -- 匀速的时间，滚轮必须转完的时间（转完此时间才有可能激活stop按钮）
    local speedTime = matrix.uniform_time[columnIndex]
    local speedAction = SpinSpeedAction:create(speedTime)
    self:addAction(speedAction)
    speedAction:setEndCallback(stopAliveCallback)
    speedAction:setTagEnabled("questNetData")
    speedAction:setName("SpeedAction")

    -- 等待网络的时间
    local waitNetAction = SpinWaitNetDataAction:create()
    self:addAction(waitNetAction)
    waitNetAction:setName("WaitNetAction")

    -- 匀速时间用完，若此时已经得到真数据，继续转动的时间。另：这个时间可以被stop按钮打断（stop按钮可以打断这个时间）
    local bounceTime = matrix.bounce_time[columnIndex]
    local bounceAction = SpinSpeedAction:create(bounceTime)
    self:addAction(bounceAction)
    bounceAction:setTagEnabled("stop")
    bounceAction:setName("BounceAction")

    -- 准备停止时的延时。另：这个时间可以被stop按钮打断（stop按钮可以打断这个时间）
    local stopDelay = matrix.stop_delay[columnIndex]
    if stopDelay > 0.01 then
        local stopDelayAction = SpinDelayAction:create(stopDelay)
        self:addAction(stopDelayAction)
        stopDelayAction:setTagEnabled("stop")
        stopDelayAction:setName("StopDelayAction")
    end

    --最后一个得到bonus的列的加速停止动作
    if self.theme:getBonusWin() then
        local winBonusAction = SpinWinBonusAction:create(matrix.prompt_success_delay, matrix.prompt_success_speed)
        self:addAction(winBonusAction)
        winBonusAction:setTagEnabled("stop")
        winBonusAction:setName("PromptAction")
    end

    -- 替换真滚轴
    local trueReelAction = SpinTrueReelAction:create(matrix.forcibly_stop)
    self:addAction(trueReelAction)
    trueReelAction:setName("SpinTrueReelAction")

    -- 停止动作
    local stopAction = SpinStopAction:create(matrix.forcibly_stop)
    self:addAction(stopAction)
    stopAction:setName("StopAction")

    -- 停止时的弹跳
    local jumpMovie = matrix.spring_type
    local jumpAction = SpinJumpAction:create(jumpMovie)
    self:addAction(jumpAction)
    jumpAction:setEndCallback(endCallback)
    self.firstMovieLen = jumpMovie[1]
    jumpAction:setName("SpinJumpAction")

    self:run()
end

function SpinColumn:run()
    self.actionQueue:run()
end

function SpinColumn:pause()
    self.actionQueue:pause()
end

function SpinColumn:resume()
    self.actionQueue:resume()
end

function SpinColumn:stop()
    self.actionQueue:stopByTag("stop")
    self:execByTag("stopAccelerate")
end

function SpinColumn:stopByTag(tag)
    self.actionQueue:stopByTag(tag)
end

function SpinColumn:removeWinBonus()
    self.actionQueue:stopByTag("winBonusAction")
end

function SpinColumn:execByTag(tag)
    self.actionQueue:execByTag(tag)
end

function SpinColumn:isStoped()
    return self.actionQueue:isStoped()
end

function SpinColumn:isDone()
    return self.actionQueue:isDone()
end

function SpinColumn:addAction(action)
    self.actionQueue:addAction(action, self)
end


local MiniGameAnimation = class("MiniGameAnimation")
function MiniGameAnimation:ctor(theme)
    self.theme = theme
    self.cacheLineAnimNodes = {}
    self.checkFilePos = 0

    self.jsonName, self.atlasName = theme:getSpinApp():getSymbolAnim(theme:getThemeId(), "kuang")
end

function MiniGameAnimation:firstRoundOver()
    if self.isCallingBack then return end

    self.isCallingBack = true
    bole:postEvent("miniEffectEnd")
end

function MiniGameAnimation:start(lines)
    self.isCallingBack = false

    self.index = 0
    self.lines = lines[1]
    self.isFreeSpining = lines[2]
    self:playAnimationNodes(lines)
end

function MiniGameAnimation:stop()
    self:hideLine()
    self.index = 0
    self.theme:removeWaitEventByName("spinViewRealPlayNext")
end

function MiniGameAnimation:hideLine()
    for _, node in ipairs(self.cacheLineAnimNodes) do
        node:setVisible(false)
    end
end

function MiniGameAnimation:addLineIndex()
    self.index = self.index + 1
    if self.index > #self.lines then
        self.index = 1
    end

    if self.lines[self.index].feature ~= 0 then
        self:addLineIndex()
    end
end

function MiniGameAnimation:removeCacheNodes()
    self.cacheLineAnimNodes = {}
end

function MiniGameAnimation:getEffAnimNode(pos, parentNode, loop, callback)
    local node
    for _, v in ipairs(self.cacheLineAnimNodes) do
        if not v:isVisible() then
            node = v
            break
        end
    end

    if not node then
        node = sp.SkeletonAnimation:create(self.jsonName, self.atlasName)
        parentNode:addChild(node, 100)
        table.insert(self.cacheLineAnimNodes, node)
    else
        local oldParentNode = node:getParent()
        if oldParentNode ~= parentNode then
            node:retain()
            node:removeFromParent()
            parentNode:addChild(node, 100)
            node:release()
        end
        node:setVisible(true)
        node:setToSetupPose()
    end

    node:registerSpineEventHandler(function(event)
        if callback then
            callback()
        end
    end, sp.EventType.ANIMATION_COMPLETE)

    node:setPosition(pos.x, pos.y)
    node:setAnimation(0, "animation", loop)
    return node
end

function MiniGameAnimation:startPlayLine()
    if self.isFreeSpining or self.index == 0 then return end

    local line = self.lines[self.index]

    local callback
    if self.winLineCount > 1 then
        self:addLineIndex()

        local function realPlayNext()
            self:startPlayLine()
        end
        callback = function()
            self:hideLine()
            self.theme:addWaitEvent("spinViewRealPlayNext", 0.1, realPlayNext)
        end
    end

    for _, item in ipairs(line.icons) do
        self:getEffAnimNode(item[3], item[4], self.winLineCount == 1, callback)
        callback = nil
    end
end

function MiniGameAnimation:playAnimationNodes(info)
    local lines = info[1]
    local isFreeSpining = info[2]

    local lineIndex = 0
    local recordSetIndexs = {}
    for k, line in ipairs(lines) do
        if line.feature > 0 then
            local endCallback = function()
                self:firstRoundOver()
            end
            for _, item in ipairs(line.icons) do
                local node, sp = self.theme:createAnimNode(item[1], item[2], "trigger", false, true, false, endCallback)
                endCallback = nil

                local keyIndex = item[1]*10 + item[2]
                if not recordSetIndexs[keyIndex] then
                    local pos = cc.p(sp:getPosition())
                    local parentNode = node:getParent()
                    recordSetIndexs[keyIndex] = {pos, parentNode}
                end
            end
        else
            lineIndex = lineIndex + 1
            if lineIndex == 1 then
                if self.index == 0 then
                    self.index = k
                end
            end

            for _, item in ipairs(line.icons) do
                local keyIndex = item[1]*10 + item[2]
                local itemValue = recordSetIndexs[keyIndex]
                if not itemValue then
                    local node, sp = self.theme:createAnimNode(item[1], item[2], "trigger", true, true, false)

                    local pos = cc.p(sp:getPosition())
                    local parentNode = node:getParent()

                    if isFreeSpining then
                        self:getEffAnimNode(pos, parentNode, true)
                    end

                    itemValue = {pos, parentNode}
                    recordSetIndexs[keyIndex] = itemValue
                end

                if not isFreeSpining then
                    item[3] = itemValue[1]
                    item[4] = itemValue[2]
                end
            end
        end
    end
    self.winLineCount = lineIndex
    self:startPlayLine()
end

local SPINORDER = {
    SYMBOL = 15,
    PROMPT = 18,
    WINRECT = 20,
    SYMBOL_ANIM = 25,
    WINLINE = 30
}


local SpinView = class("SpinView", cc.Node)
SpinView.SPINORDER = SPINORDER
function SpinView:ctor(theme)
    self.app = theme:getSpinApp()
    self.theme = theme  --主题view
    self.themeId = theme:getThemeId()

    -- 行列数
    local matrix = theme:getMatrix()
    self.columnCount = #matrix.array
    self.rowHeight = matrix.cell_size[2]

    -- 创建节点层级
    self:createNodes()
    self.miniEffect = MiniGameAnimation:create(theme) -- freespin和minigame的效果
    self:createColumns()

    self:enableNodeEvents() -- 激活事件(enter, exit, cleanup等)

    self.frameIntervalTime = cc.Director:getInstance():getAnimationInterval()
end

function SpinView:getFrameInterval()
    return self.frameIntervalTime
end

function SpinView:onEnter()
    local openCalDt = true
    local sumTime  = 0
    local recordTimes = 0
    local function update(dt)
        if dt > 0.05 then
            dt = self.frameIntervalTime
        end

        if openCalDt then
            sumTime = sumTime + dt
            recordTimes = recordTimes + 1

            dt = sumTime/recordTimes
            self.frameIntervalTime = dt

            if recordTimes > 10000 then
                openCalDt = false
            end
        else
            dt = self.frameIntervalTime
        end

        for _, column in ipairs(self.spinColumns) do
            column:update(dt)
        end
    end
    self:onUpdate(update)

    bole:addListener("stop", self.stop, self, nil, true)
    bole:addListener("miniEffect", self.playMiniAnim, self, nil, true)
    bole:addListener("columnStop", self.onColumnStop, self, nil, true)
    bole:addListener("columnStopCalm", self.onColumnStopCalm, self, nil, true)
end

function SpinView:onExit()
    bole:getEventCenter():removeEventWithTarget("stop", self)
    bole:getEventCenter():removeEventWithTarget("miniEffect", self)
    bole:getEventCenter():removeEventWithTarget("columnStop", self)
    bole:getEventCenter():removeEventWithTarget("columnStopCalm", self)
end

function SpinView:createNodes()
    self.symbolNode = cc.Node:create()
    self:addChild(self.symbolNode, SPINORDER.SYMBOL)

    self.promptSuccessNode = cc.Node:create()
    self:addChild(self.promptSuccessNode, SPINORDER.PROMPT)

    self.animNode = cc.Node:create()
    self:addChild(self.animNode, SPINORDER.SYMBOL_ANIM)
end

function SpinView:getClippingAnimNode()
    return self.animNode
end

function SpinView:createOneNode(order)
    local fixedNode = cc.Node:create()
    self:addChild(fixedNode, order+1)
    return fixedNode
end

function SpinView:addMoveNode(node, sp, column)
    self.spinColumns[column]:addMoveNode(node, sp)
end

function SpinView:getAnimationNode()
    return self.theme:getAnimLayer()
end

function SpinView:removeCacheNodes()
    self.miniEffect:removeCacheNodes()
end

function SpinView:setAllSymbolVisible(flag)
    for _, column in ipairs(self.spinColumns) do
        column:setVisible(flag)
    end
end

function SpinView:clearLineNode()
    self.miniEffect:stop()
end

function SpinView:createColumns()
    self.spinColumns = {}
    for i = 1, self.columnCount do
        local spinColumn = SpinColumn:create(i, self, self.theme)
        table.insert(self.spinColumns, spinColumn)
    end
end

function SpinView:printLog()
    if testFrames then
        for _, column in ipairs(self.spinColumns) do
            column:printLog()
        end
    end
end

function SpinView:setTrueReels(trueReels, falseReels)
    for index, column in ipairs(self.spinColumns) do
        column:setTrueReel(trueReels[index], falseReels[index])
    end
end

function SpinView:stopEnabledEvent()
    self.theme:onStopEnabled()
end

function SpinView:reelStoped()
    bole:postEvent("reelStoped")
end

function SpinView:spin(ignoreColumns)
    self:clearLineNode()
    self:onChangeWinBonus()

    local lastColumnIndex = self.columnCount
    for i = self.columnCount, 1, -1 do
        if not ignoreColumns or not ignoreColumns[i] then
            lastColumnIndex = i
            break
        end
    end

    for k, column in ipairs(self.spinColumns) do
        if k == lastColumnIndex then
            local function reelStoped()
                self:reelStoped()
            end
            local function stopBtnEnabled()
                self:stopEnabledEvent()
            end
            column:spin(reelStoped, stopBtnEnabled)
        else
            if ignoreColumns and ignoreColumns[k] then
                column:clear()
            else
                column:spin()
            end
        end
    end
end

function SpinView:stop(event)
    for _, column in ipairs(self.spinColumns) do
        column:stop()
    end
end

function SpinView:stopColumn(column)
    self.spinColumns[column]:stop()
end

function SpinView:execByTag(tag, columnIndex)
    if columnIndex then
        self.spinColumns[columnIndex]:execByTag(tag)
    else
        for _, column in ipairs(self.spinColumns) do
            column:execByTag(tag)
        end
    end
end

function SpinView:playMiniAnim(event)
    self.miniEffect:start(event.result)
end

function SpinView:getSymbolSpriteByPos(column, row)
    return self.spinColumns[column]:getSymbolSprite(row)
end

function SpinView:getNodeInfoByPos(column, row)
    return self.spinColumns[column]:getNodeInfo(row)
end

function SpinView:getPositionByPos(column, row, isCenter)
    local matrix = self.theme:getMatrix()
    local bottomPos = matrix.coordinate[column]
    local disY = (matrix.array[column] - row) * matrix.cell_size[2]

    local position = cc.p(bottomPos.x, bottomPos.y + disY)
    if isCenter then
        position.y = position.y + matrix.cell_size[2] / 2
    end
    return position
end

function SpinView:getRectByPos(column, row)
    local matrix = self.theme:getMatrix() 
    local rect = self.theme:getSpinPositionByPos(column, row)
    rect.width = matrix.cell_size[1]
    rect.x = rect.x - rect.width/2
    rect.height = matrix.cell_size[2]
    return rect
end

function SpinView:onChangeWinBonus()
    for _, column in ipairs(self.spinColumns) do
        column:setTagDisabled("winBonus")
    end

    local reels = self.theme:getBonusWin()
    if not reels then
        return
    end

    for _, item in ipairs(reels) do
        for index, max in ipairs(item.reel_max) do
            if max > 0 then
                self.spinColumns[index]:setTagEnabled("winBonus")
            end
        end
    end
end

function SpinView:onColumnStop(event)
    local result = event.result
    self.theme:onColumnStop(result[1], result[2])
end

function SpinView:onColumnStopCalm(event)
    local column = event.result
    self.theme:onColumnStopCalm(column)
end

function SpinView:onTriggerColumnPrompt(index)
    if index >= self.columnCount then return end

    local column = self.spinColumns[index + 1]
    if column:getTagEnabled("winBonus") then
        column:setWinBonusAction()
    else
        column:removeWinBonus()
    end
end

function SpinView:onStopWinBonusAction(minWinBonusColumn, maxWinBonusColumn)
    for i = 1, minWinBonusColumn do
        self.spinColumns[i]:removeWinBonus()
    end

    if maxWinBonusColumn and maxWinBonusColumn > minWinBonusColumn then
        for i = maxWinBonusColumn+1, self.columnCount do
            self.spinColumns[i]:setTagDisabled("winBonus")
        end
    end
end

function SpinView:getColumnCount()
    return self.columnCount
end

function SpinView:getSpinApp()
    return self.app
end

function SpinView:getTheme()
    return self.theme
end

function SpinView:getSymbolNode()
    return self.symbolNode
end

return SpinView


-- 线段
--local SpinLine = class("SpinLine")
--function SpinLine:ctor(pt1, pt2, color)
--    self.pt1 = pt1
--    self.pt2 = pt2
--    self.color = color
--end


--function SpinView:getLines(points, rects)
--    local lines = {}
--    for i = 1, #points - 1 do
--        local pt1 = points[i]
--        local pt2 = points[i + 1]
--        for j = 1, #rects do
--            if pt1.x == pt2.x and pt1.y == pt2.y then
--                break
--            end

--            local rect = rects[j]
--            if pt2.x < rect.x then
--                break
--            end

--            local intersectionPoint, nextStartPoint = self:getIntersectPoint(pt1, pt2, rect)
--            if intersectionPoint then
--                local line = SpinLine:create(pt1, intersectionPoint)
--                table.insert(lines, line)
--            end

--            pt1 = nextStartPoint

--            if not pt1 then
--                break
--            end
--        end

--        if pt1 and (pt1.x ~= pt2.x or pt1.y ~= pt2.y) then
--            local line = SpinLine:create(pt1, pt2)
--            table.insert(lines, line)
--        end
--    end

--    return lines
--end

--function SpinView:getIntersectPoint(pointA, pointB, rect)
--    local LB_point = cc.p(rect.x, rect.y)
--    local LT_point = cc.p(rect.x, rect.y + rect.height)
--    local RT_point = cc.p(rect.x + rect.width, rect.y + rect.height)
--    local RB_point = cc.p(rect.x + rect.width, rect.y)

--    local resultPoints = {}

--    local flag = cc.pIsSegmentIntersect(pointA, pointB, LB_point, LT_point)
--    if flag then
--        local point = cc.pGetIntersectPoint(pointA, pointB, LB_point, LT_point)
--        table.insert(resultPoints, point)
--    end

--    flag = cc.pIsSegmentIntersect(pointA, pointB, LT_point, RT_point)
--    if flag then
--        local point = cc.pGetIntersectPoint(pointA, pointB, LT_point, RT_point)
--        table.insert(resultPoints, point)
--    end

--    flag = cc.pIsSegmentIntersect(pointA, pointB, LB_point, RB_point)
--    if flag then
--        local point = cc.pGetIntersectPoint(pointA, pointB, LB_point, RB_point)
--        table.insert(resultPoints, point)
--    end

--    flag = cc.pIsSegmentIntersect(pointA, pointB, RB_point, RT_point)
--    if flag then
--        local point = cc.pGetIntersectPoint(pointA, pointB, RB_point, RT_point)
--        table.insert(resultPoints, point)
--    end

--    local len = #resultPoints
--    if len == 0 then
--        if cc.rectContainsPoint(rect, pointB) then
--            -- 处理两个点都在rect的情况
--            pointA = nil
--        end
--        return nil, pointA
--    elseif len == 1 then
--        if cc.rectContainsPoint(rect, pointA) then
--            if cc.rectContainsPoint(rect, pointB) and pointB.x > resultPoints[1].x then
--                return nil, nil
--            else
--                return nil, resultPoints[1]
--            end
--        else
--            return resultPoints[1], pointB
--        end
--    else
--        local intersectionPoint, nextStartPoint
--        if resultPoints[1].x < resultPoints[2].x then
--            intersectionPoint = resultPoints[1]
--            nextStartPoint = resultPoints[2]
--        else
--            intersectionPoint = resultPoints[2]
--            nextStartPoint = resultPoints[1]
--        end

--        return intersectionPoint, nextStartPoint
--    end
--end