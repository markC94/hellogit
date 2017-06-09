local SpinAction = class("SpinAction")  -- 动作的基础类(抽象的类)
function SpinAction:ctor(duration)
    self.duration = duration
    self.elapsed = 0
    self.isFirst = true
    self.timeOver = false  -- 动作结束
    self.eventCommand = {} -- 动作事件注册
end

function SpinAction:isDone()
    return self.timeOver
end

function SpinAction:isRunning()
    return not self.isFirst
end

function SpinAction:execAction()
end

function SpinAction:stop()
    self.timeOver = true
end

function SpinAction:update(s)
    self.target:step(s)
end

-- 动作执行的第一帧执行的方法
function SpinAction:init()
end

function SpinAction:step(dt, isCutTime)
    if not self.target then return false end

    if self.isFirst then
        self.isFirst = false
        self.speed = self.target:getSpeed()
        self:init()
    end

    if self.timeOver then return false end

    self.elapsed = self.elapsed + dt

    if self.elapsed >= self.duration then
        self.timeOver = true
        if isCutTime or self:getTagEnabled("cutTime") then
            self.elapsed = self.duration
        end
    end

    return true
end

function SpinAction:runWithTarget(target)
    self.target = target
end

function SpinAction:actionDoneCallback()
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
        self:execAction()
    end
end


local SpinSpeedAction = class("SpinSpeedAction", SpinAction)    -- 速度动作
function SpinSpeedAction:ctor(duration, accelerate)
    SpinSpeedAction.super.ctor(self, duration)
    self.accelerate = accelerate or 0
    self.movedDistance = 0
end

function SpinSpeedAction:step(dt)
    if not SpinSpeedAction.super.step(self, dt) then return false end

    local s = self.speed * self.elapsed + 0.5 * self.accelerate * math.pow(self.elapsed, 2)
    local disLen = s - self.movedDistance
    self.movedDistance = s
    self:update(disLen)

    if self.accelerate ~= 0 then
        self.target:setSpeed(self.speed + self.accelerate * self.elapsed)
    end

    if self.timeOver then
        self:actionDoneCallback()
    else
        if self:getTagEnabled("useRemain") and self.elapsed + 0.01 > self.duration then
            self:step(self.duration - self.elapsed + 0.001, true)
        end
    end

    return true
end

function SpinSpeedAction:reset()
    self.elapsed = 0
    self.movedDistance = 0
end


local SpinDelayAction = class("SpinDelayAction", SpinSpeedAction)    -- 只做延时时间
function SpinDelayAction:ctor(duration, isKeepStop)
    SpinDelayAction.super.ctor(self, duration)
    self.isKeepStop = isKeepStop
end

function SpinDelayAction:init()
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
        bole:postEvent("promptSuccess", self.target:getIndex())
    end

    local result = SpinWinBonusAction.super.step(self, dt)

    if self.accelerateEnabled then
        if self.elapsed >= self.accelerateTime then
            self:setTagEnabled("useRemain")

            self.accelerate = 0
            self.speed = self.target:getSpeed()
            
            self:reset()
            self.duration = self.duration - self.accelerateTime
            self.accelerateEnabled = false
        end
    end
    
    return result
end

function SpinWinBonusAction:execAction()
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
    if self.speed > 5000 then
        self.speed = 5000
    end

    self.needMoveLen = self.target:getRemainLen() + self.target:getTrueReelUpdateLen()
    if self.clickStop then
        self.speed = self.stopClickSpeed
        self.target:setSpeed(self.speed)
    end

    self.duration = self.needMoveLen / self.speed + 0.00001
    self.target:startReplaceTrueReel()
    self:setTagEnabled("useRemain")
end

function SpinTrueReelAction:execAction()
    if self.clickStop then
        return
    end

    if self.needMoveLen and self.elapsed + 0.05 < self.duration then
        self.needMoveLen = self.needMoveLen - self.movedDistance
        self.speed = self.stopClickSpeed
        self.target:setSpeed(self.speed)

        self.duration = self.needMoveLen / self.speed + 0.00001
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
    self.needMoveLen = self.target:getRemainLen()
    if self.clickStop then
        self.speed = self.stopClickSpeed
        self.target:setSpeed(self.speed)
    end

    self.duration = self.needMoveLen / self.speed
    self:setTagEnabled("cutTime")
    self:setTagEnabled("useRemain")
end

function SpinStopAction:execAction()
    if self.clickStop then
        return
    end

    if self.needMoveLen and self.elapsed + 0.05 < self.duration then
        self.needMoveLen = self.needMoveLen - self.movedDistance
        self.speed = self.stopClickSpeed
        self.target:setSpeed(self.speed)

        self.duration = self.needMoveLen / self.speed
        self:reset()
    end
    self.clickStop = true
end

-- 特殊处理 （只会在checkAction的地方调用，少调用一次）
function SpinStopAction:isDone()
    if SpinStopAction.super.isDone(self) then
        return true
    else
        if not self:isRunning() then
            return self.target:getRemainLen() < 1
        else
            return false
        end
    end
end


local SpinJumpAction = class("SpinJumpAction", SpinAction)  -- 弹动作播电影
function SpinJumpAction:ctor(movie)
    SpinJumpAction.super.ctor(self)
    self.movie = movie
    self:setTagEnabled("movie")
end

function SpinJumpAction:init()
    self.index = 1
    self.movedDistance = 0
    self.duration = 2
    bole:postEvent("audio_reel_stop")
end

function SpinJumpAction:step(dt)
    if not SpinJumpAction.super.step(self, dt) then return false end

    local thisBouncePosY = self.movie[self.index]
    local disLen = thisBouncePosY - self.movedDistance

    self.movedDistance = thisBouncePosY

    self:update(disLen)

    self.index = self.index + 1
    if self.index > #self.movie then
        self.timeOver = true
        self:actionDoneCallback()
        self.target:resetPos()
        bole:postEvent("columnStop", self.target:getIndex())
    end

    return true
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


local ActionNode = class("ActionNode")
function ActionNode:ctor(spinColumn, theme)
    self.spinColumn = spinColumn
    self.theme = theme
    self.app = theme:getSpinApp()
    self.themeId = theme:getThemeId()

    local column = spinColumn:getColumnIndex()
    local matrix = theme:getMatrix()
    self.row = matrix.array[column]  --本列的行数
    self.rowNeedNum = matrix.filled  --本列上下需要填充的行数
    self.rowCount = self.row + 2*self.rowNeedNum  --这一列的总长度，包括棋盘的长度和上下填充的长度
    self.updateLen = matrix.cell_size[2] -- 纵向的两格之间的距离(移动一格的距离，也是更新symbol的触发距离)
    
    local bottomPos = matrix.coordinate[column]
    self.bottomPosY = bottomPos.y - self.updateLen * self.rowNeedNum  -- 最下面一行的位置(多出rowNeedNum格位置)
    self.bottomPosX = bottomPos.x

    self.trueSymbols = self.spinColumn:getTrueReel()
    self.falseSymbols = self.spinColumn:getFalseReel()
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
end

function ActionNode:clearRemainLongSymbol()
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

function ActionNode:getIndex()
    return self.spinColumn:getColumnIndex()
end

function ActionNode:clear()
    self.actionQueue:clear()
    self.trueSymbols = nil
    self.startTrueReelIndex = 0   -- 替换真滚轴的标志，以及替换的index
    self.speed = 0  -- 为了使速度不出现间隔性跳跃，移动的速度统一由actionNode统一管理
    self:reVisibleSymbol()
end

function ActionNode:resetPos()
    self.curThisMove = 0
    self:reel()
end

function ActionNode:getRemainLen()
    return self.updateLen - self.curThisMove
end

--替换真滚轴需要走的距离
function ActionNode:getTrueReelUpdateLen()
    return (self.rowCount - 2) * self.updateLen
end

function ActionNode:reel()
    for i, v in ipairs(self.nodes) do
        if v.node and not v.isHide then
            local num = self.theme:getSymbolNumById(v.symbol)
            v.node:setPositionY(self.bottomPosY + (i - 1 + num/2) * self.updateLen - self.curThisMove)
        end
    end
end

function ActionNode:getNodeByReelRow(row)
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

function ActionNode:update(dt)
    self.actionQueue:update(dt)
end

function ActionNode:step(s)
    self.curThisMove = self.curThisMove + s
    if self.curThisMove >= self.updateLen then
        local num = math.floor(self.curThisMove / self.updateLen)
        self.curThisMove = self.curThisMove - self.updateLen * num
        self:updateSymbols(num)
    elseif self.curThisMove < 0 then
        self.curThisMove = 0
    end
    self:reel()
end

function ActionNode:genSymbolTagInfo(info)
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

function ActionNode:updateSymbols(num)
    for i = 1, num do
        local info = table.remove(self.nodes, 1)
        table.insert(self.nodes, info)
        
        self:genSymbolTagInfo(info)
    end
    self:reorderSymbol()
end

function ActionNode:setTrueReel(trueSymbols, falseSymbols)
    self.trueSymbols = trueSymbols
    self.falseSymbols = falseSymbols
    self.startFalseReelIndex = 1

    self.actionQueue:stopByTag("wait")
end

function ActionNode:setFalseReel(falseSymbols)
    self.falseSymbols = falseSymbols
end

function ActionNode:startReplaceTrueReel()
    if not self.trueSymbols then return end

    self.startTrueReelIndex = 1
    self:clearRemainLongSymbol()
end

function ActionNode:getSymbolTag()
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

function ActionNode:reorderSymbol()
    for i, v in ipairs(self.nodes) do
        if v.node and not v.isHide then
            local symbol_set = self.theme:getItemById(v.symbol).symbol_set
            v.node:setLocalZOrder(self.rowCount-i+200*symbol_set)
        end
    end
end

function ActionNode:reVisibleSymbol()
    for i, v in ipairs(self.nodes) do
        if v.node and not v.isHide then
            v.node:setVisible(true)
        end
    end
end

function ActionNode:genSymbol(info)
    local isNew = self.theme:getSymbolInfo(info)
    local sp = info.node
    if isNew then
        sp:setPositionX(self.bottomPosX)
        self.spinColumn:getSymbolNode():addChild(sp)
    else
        if info.isHide then
            sp:setVisible(true)
        end
    end

    info.isHide = false
end

function ActionNode:runAction(actionQueue)
    self.actionQueue = actionQueue
    self.actionQueue:runWithTarget(self)
    self:run()
end

function ActionNode:setSpeed(speed)
    self.speed = speed
end

function ActionNode:getSpeed()
    return self.speed
end

function ActionNode:run()
    self.actionQueue:run()
end

function ActionNode:pause()
    self.actionQueue:pause()
end

function ActionNode:resume()
    self.actionQueue:resume()
end

function ActionNode:stop()
    self.actionQueue:stopByTag("stop")
end

function ActionNode:stopByTag(tag)
    self.actionQueue:stopByTag(tag)
end

function ActionNode:removeWinBonus()
    self.actionQueue:stopByTag("winBonusAction")
end

function ActionNode:execByTag(tag)
    self.actionQueue:execByTag(tag)
end

function ActionNode:isStoped()
    return self.actionQueue:isStoped()
end

function ActionNode:isDone()
    return self.actionQueue:isDone()
end

function ActionNode:addAction(action)
    self.actionQueue:addAction(action, self)
end


-- 线段
local SpinLine = class("SpinLine")
function SpinLine:ctor(pt1, pt2, color)
    self.pt1 = pt1
    self.pt2 = pt2
    self.color = color
end


local SpinColumn = class("SpinColumn")
function SpinColumn:ctor(columnIndex, spinView)
    self.columnIndex = columnIndex
    self.spinView = spinView

    self.theme = spinView:getTheme()

    self.actionNode = ActionNode:create(self, self.theme)
end

function SpinColumn:getSymbolNode()
    return self.spinView:getSymbolNode()
end

function SpinColumn:getSymbolSprite(row)
    return self.actionNode:getNodeByReelRow(row)
end

function SpinColumn:getColumnIndex()
    return self.columnIndex
end

function SpinColumn:drawRect(rect)
    self.spinView:drawRect(rect)
end

function SpinColumn:update(dt)
    if dt > 0.1 then
        return
    end

    self.actionNode:update(dt)
end

function SpinColumn:isDone()
    return self.actionNode:isDone()
end

function SpinColumn:isStoped()
    return self.actionNode:isStoped()
end

function SpinColumn:start()
end

function SpinColumn:stop()
    self.actionNode:stop()
    self.actionNode:execByTag("stopAccelerate")
end

function SpinColumn:removeWinBonus()
    self.actionNode:removeWinBonus()
end

function SpinColumn:execByTag(tag)
    self.actionNode:execByTag(tag)
end

function SpinColumn:stopByTag(tag)
    self.actionNode:stopByTag(tag)
end

function SpinColumn:pause()
    self.actionNode:pause()
end

function SpinColumn:resume()
    self.actionNode:resume()
end

function SpinColumn:setWinBonusAction()
    self.actionNode:execByTag("winBonusAction")
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

function SpinColumn:clear()
    self.actionNode:clear()
end

function SpinColumn:spin(endCallback, stopAliveCallback)
    self:clear()

    -- 开始的延时时间
    local matrix = self.theme:getMatrix()
    local column = self.columnIndex
    local startDelay = matrix.start_delay[column]
    if startDelay > 0.01 then
        local startDelayAction = SpinDelayAction:create(startDelay, true)
        self.actionNode:addAction(startDelayAction)
    end

    -- 加速时间
    local aTime = matrix.acceleration_time[column]
    local speed = matrix.speed[column]
    local addSpeedAction = SpinSpeedAction:create(aTime, speed / aTime)
    self.actionNode:addAction(addSpeedAction)

    -- 匀速的时间，滚轮必须转完的时间（转完此时间才有可能激活stop按钮）
    local speedTime = matrix.uniform_time[column]
    local speedAction = SpinSpeedAction:create(speedTime)
    self.actionNode:addAction(speedAction)
    speedAction:setEndCallback(stopAliveCallback)

    -- 等待网络的时间
    local waitNetAction = SpinWaitNetDataAction:create()
    self.actionNode:addAction(waitNetAction)

    -- 匀速时间用完，若此时已经得到真数据，继续转动的时间。另：这个时间可以被stop按钮打断（stop按钮可以打断这个时间）
    local bounceTime = matrix.bounce_time[column]
    local bounceAction = SpinSpeedAction:create(bounceTime)
    self.actionNode:addAction(bounceAction)
    bounceAction:setTagEnabled("stop")

    -- 准备停止时的延时。另：这个时间可以被stop按钮打断（stop按钮可以打断这个时间）
    local stopDelay = matrix.stop_delay[column]
    if stopDelay > 0.01 then
        local stopDelayAction = SpinDelayAction:create(stopDelay)
        self.actionNode:addAction(stopDelayAction)
        stopDelayAction:setTagEnabled("stop")
    end

    --最后一个得到bonus的列的加速停止动作
    if self.theme:getBonusWin() then
        local winBonusAction = SpinWinBonusAction:create(matrix.prompt_success_delay, matrix.prompt_success_speed)
        self.actionNode:addAction(winBonusAction)
        winBonusAction:setTagEnabled("stop")
    end

    -- 替换真滚轴
    local trueReelAction = SpinTrueReelAction:create(matrix.forcibly_stop)
    self.actionNode:addAction(trueReelAction)

    -- 停止动作
    local stopAction = SpinStopAction:create(matrix.forcibly_stop)
    self.actionNode:addAction(stopAction)

    -- 停止时的弹跳
    local jumpMovie = matrix.spring_type
    local jumpAction = SpinJumpAction:create(jumpMovie)
    self.actionNode:addAction(jumpAction)
    jumpAction:setEndCallback(endCallback)

    self.actionNode:run()
end

function SpinColumn:setTrueReel(reel, falseReels)
    self.actionNode:setTrueReel(reel, falseReels)
end

function SpinColumn:setFalseReel(reel)
    self.actionNode:setFalseReel(reel)
end

function SpinColumn:getTrueReel()
    return self.theme:getDisplayReelByColumn(self.columnIndex)
end

function SpinColumn:getFalseReel()
    return self.theme:getFalseReelByColumn(self.columnIndex)
end


local WinEffectAnimation = class("WinEffectAnimation")
function WinEffectAnimation:ctor(spinView)
    print("WinEffectAnimation:ctor")
    self.isStop = true
    self.isFirst = true
    self.spinView = spinView

    self.theme = self.spinView:getTheme()
    self.themeId = self.theme:getThemeId()

    self.rectLineNode = self.spinView:getRectLineNode()
    self.pureLineNode = self.spinView:getPureLineNode()

    self.fadeTime = 0.8
    self.intervalTime = 2 * self.fadeTime
end

function WinEffectAnimation:start(winData)
    print("WinEffectAnimation:start")
    self.isStop = false
    self.winLineData = winData.line
    self.isFreeSpin = winData.isFreeSpin
end

function WinEffectAnimation:stop()
    print("WinEffectAnimation:stop")
    self.isStop = true
    self.isFirst = true
    self.rectLineNode:clear()
    self.pureLineNode:clear()
end

function WinEffectAnimation:init()
    print("WinEffectAnimation:init")
    self.useFirstRound = true
    self.count = #self.winLineData

    self.index = 0
    self.needToChangeNextLine = false
    self.elapsed = 0

    self.cacheLineAnimation = {}
    self.cacheLineInfo = {}
    self.visibleNodes = {}

    return self.count > 0
end

function WinEffectAnimation:step(dt)
    if self.isStop then
        return
    end

    if self.isFirst then
        print("WinEffectAnimation:step isFirst")
        self.isFirst = false
        if not self:init() then
            self:stop()
            self:firstRoundOver(0)
            return
        end
    end

    if self.count == 0 then
        return
    end

    self.elapsed = self.elapsed + dt

    if self.elapsed >= self.intervalTime then
        print("self.elapsed >= self.intervalTime")
        self.elapsed = self.elapsed - self.intervalTime
        --        if self.isFreeSpin then
        --            self:stop()
        --            self:firstRoundOver(1)
        --            return
        --        end

        if self.needToChangeNextLine then
            if not self.isFreeSpin then
                print("if not self.isFreeSpin")
                self.needToChangeNextLine = false
                self.elapsed = 0
                self:next()
            else
                self:stop()
                self:firstRoundOver(1)
                return
            end
        elseif self.index == 0 then
            self.needToChangeNextLine = true
        end
    end

    self:hideLineNodes()
    self:playLineNodes(self.index)
end

function WinEffectAnimation:firstRoundOver(index)
    print("WinEffectAnimation:firstRoundOver")
    if self.useFirstRound then
        self.useFirstRound = false
--        self.theme:playWinLineEnd(index)
        bole:postEvent("winLineEnd")
    end
end

function WinEffectAnimation:next()
    print("WinEffectAnimation:next")
    if self.isFreeSpin then return end

    self.index = self.index + 1
    if self.index > self.count then
        self.index = 0
        self:firstRoundOver(2)
    end

    self:playAnimationNodes(self.index)
end

function WinEffectAnimation:hideLineNodes(index)
    self.rectLineNode:clear()
    self.pureLineNode:clear()
end

function WinEffectAnimation:lineAnimationPlayOver()
    print("WinEffectAnimation:lineAnimationPlayOver")
    self.needToChangeNextLine = true
end

function WinEffectAnimation:playLineEffect(index)
    print("WinEffectAnimation:playLineEffect")
    local info = self.winLineData[index]
    bole:postEvent("audio_link", info.link)
end

function WinEffectAnimation:playAnimationNodes(index)
    print("WinEffectAnimation:playLineEffect")
    for _, info in ipairs(self.visibleNodes) do
        local skNode = info[1]
        if skNode.useTag then
            skNode:setVisible(false)
            skNode.useTag = nil
        end
        local sp = info[2]
        if sp then
            sp:setVisible(true)
        end
    end
    self.visibleNodes = {}

    if index == 0 then return end

    if not self.cacheLineAnimation[index] then
        self.cacheLineAnimation[index] = true
        self:playLineEffect(index)
    end

    local info = self.winLineData[index].icons
    local needToPlayCount = #info
    
    for _, item in ipairs(info) do
        local function endCallback(skNode, sp)
            skNode:setVisible(true)
            if sp then
                sp:setVisible(false)
            end
            needToPlayCount = needToPlayCount - 1
            if needToPlayCount == 0 then
                self:lineAnimationPlayOver()
            end
        end

        local skNode, sp = self.theme:createAnimNode(item[1], item[2], "trigger", false, true, endCallback)
        skNode.useTag = true
        table.insert(self.visibleNodes, {skNode, sp})
    end
end

function WinEffectAnimation:playLineNodes(index)
    local rate = self.elapsed / self.fadeTime
    if rate > 1 then
        rate = 2 - rate
    end

    local info = self:getInfoItemByIndex(index)
    local node
    if index == 0 then
        node = self.pureLineNode
    else
        node = self.rectLineNode
    end
    self:drawLine(node, info, rate)
end

local _fillColor = { 0, 0, 0, 0 }
function WinEffectAnimation:drawLine(node, infoItem, opacityRate)
    local lines = infoItem.lines
    if lines then
        for _, line in ipairs(lines) do
            local color = clone(line.color)
            color.a = color.a * opacityRate
            node:drawSegment(line.pt1, line.pt2, 2, color)
        end
    end

    local rects = infoItem.rects
    if rects then
        for _, rect in ipairs(rects) do
            local color = clone(rect.color)
            color.a = color.a * opacityRate
            node:drawPolygon(rect.vec2s, 4, _fillColor, 2, color)
        end
    end
end

function WinEffectAnimation:getInfoItemByIndex(index)
    local infoItem = self.cacheLineInfo[index]
    if not infoItem then
        infoItem = {}

        if index == 0 then
            -- 只画交叉的线
            infoItem.lines = {}
            for _, line in ipairs(self.winLineData) do
                local lineConfig = self.theme:getLineById(line.line_id)
                local color = cc.convertColor(lineConfig.line_color[3], "4f")
                for i = 1, #lineConfig.line_turnning - 1 do
                    local pt1 = lineConfig.line_turnning[i]
                    local pt2 = lineConfig.line_turnning[i + 1]
                    local line = SpinLine:create(pt1, pt2, color)
                    table.insert(infoItem.lines, line)
                end
            end
        else
            infoItem.rects = {}
            local lineConfig = self.theme:getLineById(self.winLineData[index].line_id)
            local color = cc.convertColor(lineConfig.line_color[3], "4f")

            local rects = {}
            for _, posItem in ipairs(self.winLineData[index].icons) do
                local rect = self.spinView:getRectByPos(posItem[1], posItem[2])
                table.insert(rects, rect)
            end

            local lines = self.spinView:getLines(lineConfig.line_turnning, rects)
            for _, line in ipairs(lines) do
                line.color = color
            end
            infoItem.lines = lines

            for _, rect in ipairs(rects) do
                local pt1 = cc.p(rect.x + 2, rect.y + 2)
                local pt2 = cc.p(rect.x + rect.width - 2, rect.y + rect.height - 2)

                local pLB = cc.p(pt1.x, pt1.y)
                local pRB = cc.p(pt2.x, pt1.y)
                local pRT = cc.p(pt2.x, pt2.y)
                local pLT = cc.p(pt1.x, pt2.y)

                local info = {}
                info.vec2s = { pLB, pRB, pRT, pLT }
                info.color = color
                table.insert(infoItem.rects, info)
            end
        end

        self.cacheLineInfo[index] = infoItem
    end
    return infoItem
end


local MiniGameAnimation = class("MiniGameAnimation")
function MiniGameAnimation:ctor(spinView)
    self.isStop = true
    self.isFirst = true
    self.spinView = spinView

    self.theme = self.spinView:getTheme()
    self.themeId = self.theme:getThemeId()

    self.rectLineNode = self.spinView:getRectLineNode()

    self.fadeTime = 0.8
    self.intervalTime = 2 * self.fadeTime
end

function MiniGameAnimation:start(winData)
    self.isStop = false
    self.winLineData = winData
end

function MiniGameAnimation:stop()
    self.isStop = true
    self.isFirst = true
    self.rectLineNode:clear()
end

function MiniGameAnimation:init()
    self.count = #self.winLineData
    if self.count == 0 then
        return false
    end

    self.index = 1  -- 进入之后，直接触发动画
    self.elapsed = 0
    self.needToChangeNextLine = false

    self.cacheLineInfo = {}
    return true
end

function MiniGameAnimation:step(dt)
    if self.isStop then
        return
    end

    if self.isFirst then
        self.isFirst = false
        if not self:init() then
            self:stop()
            self:firstRoundOver(0)
            return
        end

        self:playAnimationNodes(1)
    end

    if self.count == 0 then
        return
    end

    self.elapsed = self.elapsed + dt

    if self.elapsed >= self.intervalTime then
        self.elapsed = self.elapsed - self.intervalTime

        if self.needToChangeNextLine then
            self.needToChangeNextLine = false
            self.elapsed = 0
            self:stop()
            self:firstRoundOver(0)
            return
        end
    end

    self:hideLineNodes()
    self:playLineNodes(self.index)
end

function MiniGameAnimation:firstRoundOver(index)
    bole:postEvent("miniEffectEnd")
end

function MiniGameAnimation:hideLineNodes()
    self.rectLineNode:clear()
end

function MiniGameAnimation:lineAnimationPlayOver()
    self.needToChangeNextLine = true
end

function MiniGameAnimation:playAnimationNodes(index)
    local info = self.winLineData[index].icons
    local needToPlayCount = #info
    for _, item in ipairs(info) do
        local function endCallback()
            needToPlayCount = needToPlayCount - 1
            if needToPlayCount == 0 then
                self:lineAnimationPlayOver()
            end
        end

        self.theme:createAnimNode(item[1], item[2], "trigger", false, true, endCallback)
    end
end

function MiniGameAnimation:playLineNodes(index)
    local rate = self.elapsed / self.fadeTime
    if rate > 1 then
        rate = 2 - rate
    end

    local info = self:getInfoItemByIndex(index)
    local node = self.rectLineNode
    self:drawLine(node, info, rate)
end

local _fillColor = { 0, 0, 0, 0 }
function MiniGameAnimation:drawLine(node, infoItem, opacityRate)
    local lines = infoItem.lines
    if lines then
        for _, line in ipairs(lines) do
            local color = clone(line.color)
            color.a = color.a * opacityRate
            node:drawSegment(line.pt1, line.pt2, 2, color)
        end
    end

    local rects = infoItem.rects
    if rects then
        for _, rect in ipairs(rects) do
            local color = clone(rect.color)
            color.a = color.a * opacityRate
            node:drawPolygon(rect.vec2s, 4, _fillColor, 2, color)
        end
    end
end

function MiniGameAnimation:getInfoItemByIndex(index)
    local infoItem = self.cacheLineInfo[index]
    if not infoItem then
        infoItem = {}

        if index > 0 then -- 只画矩形
            infoItem.rects = {}
            local color = cc.convertColor(cc.c4b(255, 255, 0, 255), "4f")

            local rects = {}
            for _, posItem in ipairs(self.winLineData[index].icons) do
                local rect = self.spinView:getRectByPos(posItem[1], posItem[2])
                table.insert(rects, rect)
            end

            for _, rect in ipairs(rects) do
                local pt1 = cc.p(rect.x + 2, rect.y + 2)
                local pt2 = cc.p(rect.x + rect.width - 2, rect.y + rect.height - 2)

                local pLB = cc.p(pt1.x, pt1.y)
                local pRB = cc.p(pt2.x, pt1.y)
                local pRT = cc.p(pt2.x, pt2.y)
                local pLT = cc.p(pt1.x, pt2.y)

                local info = {}
                info.vec2s = { pLB, pRB, pRT, pLT }
                info.color = color
                table.insert(infoItem.rects, info)
            end
        end

        self.cacheLineInfo[index] = infoItem
    end
    return infoItem
end


local SPINORDER = {
    PROMPT = 10,
    SYMBOL = 15,
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
    self.column = #matrix.array
    self.rowHeight = matrix.cell_size[2]

    -- 创建节点层级
    self:createNodes()
    self.winLineEffect = WinEffectAnimation:create(self) -- 创建连线的动画效果器
    self.miniEffect = MiniGameAnimation:create(self) -- freespin和minigame的效果
    self:createColumns()

    self:enableNodeEvents() -- 激活事件(enter, exit, cleanup等)

    self:onChangeWinBonus()
end

function SpinView:onEnter()
    self.isDead = false
    local function update(dt)
        for _, column in ipairs(self.spinColumns) do
            column:update(dt)
        end

        self.winLineEffect:step(dt)
        self.miniEffect:step(dt)
    end
    self:onUpdate(update)

--    bole:addListener("spin", self.spin, self, nil, true)
    bole:addListener("stop", self.stop, self, nil, true)
    bole:addListener("trueReelsResponse", self.onTrueReelsResponse, self, nil, true)  --得到真数据
    bole:addListener("drawLine", self.playLineAnim, self, nil, true)
    bole:addListener("miniEffect", self.playMiniAnim, self, nil, true)
    bole:addListener("columnStop", self.onColumnStop, self, nil, true)
end

function SpinView:onExit()
    self.isDead = true

--    bole:getEventCenter():removeEventWithTarget("spin", self)
    bole:getEventCenter():removeEventWithTarget("stop", self)
    bole:getEventCenter():removeEventWithTarget("trueReelsResponse", self)
    bole:getEventCenter():removeEventWithTarget("drawLine", self)
    bole:getEventCenter():removeEventWithTarget("miniEffect", self)
    bole:getEventCenter():removeEventWithTarget("columnStop", self)
    bole:getEventCenter():removeEventWithTarget("promptSuccess", self)
end

function SpinView:createNodes()
    self.promptSuccessNode = cc.Node:create()
    self:addChild(self.promptSuccessNode, SPINORDER.PROMPT)

    self.symbolNode = cc.Node:create()
    self:addChild(self.symbolNode, SPINORDER.SYMBOL)

    self.pureLineNode = cc.DrawNode:create()
    self:addChild(self.pureLineNode, SPINORDER.WINRECT)

    self.animNode = cc.Node:create()
    self:addChild(self.animNode, SPINORDER.SYMBOL_ANIM)

    self.rectLineNode = cc.DrawNode:create()
    self:addChild(self.rectLineNode, SPINORDER.WINLINE)
end

function SpinView:getClippingAnimNode()
    return self.animNode
end

function SpinView:createOneNode(order)
    local fixedNode = cc.Node:create()
    self:addChild(fixedNode, order+1)
    return fixedNode
end

function SpinView:getRectLineNode()
    return self.rectLineNode
end

function SpinView:getPureLineNode()
    return self.pureLineNode
end

function SpinView:getAnimationNode()
    return self.theme:getAnimLayer()
end

function SpinView:clearLineNode()
    self.winLineEffect:stop()
    self.miniEffect:stop()
end

function SpinView:createColumns()
    self.spinColumns = {}
    for i = 1, self.column do
        local spinColumn = SpinColumn:create(i, self)
        table.insert(self.spinColumns, spinColumn)
    end
end

function SpinView:stopEnabledEvent()
    bole:postEvent("spinStatus", "stopEnabled")
end

function SpinView:reelStoped()
    bole:postEvent("reelStoped")
end

function SpinView:spin(ignoreColumns)
    self:clearLineNode()

    local lastColumnIndex = self.column
    for i = self.column, 1, -1 do
        if not ignoreColumns or not ignoreColumns[i] then
            lastColumnIndex = i
            break
        end
    end

    for k, column in ipairs(self.spinColumns) do
        if k == lastColumnIndex then
            column:spin(self.reelStoped, self.stopEnabledEvent)
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

function SpinView:playLineAnim(event)
    self.winLineEffect:start(event.result)
end

function SpinView:playMiniAnim(event)
    self.miniEffect:start(event.result)
end

function SpinView:getSymbolSpriteByPos(column, row)
    return self.spinColumns[column]:getSymbolSprite(row)
end

function SpinView:onChangeWinBonus(num)
    for _, column in ipairs(self.spinColumns) do
        column:setTagDisabled("winBonus")
    end

    local reels = self.theme:getBonusWin()
    if not reels then
        return
    end

    if num then
        for index = 1, num-1 do
            self.spinColumns[index]:setTagEnabled("winBonus")
        end
    else
        for _, item in ipairs(reels) do
            for index, max in ipairs(item.reel_max) do
                if max > 0 then
                    self.spinColumns[index]:setTagEnabled("winBonus")
                end
            end
        end
    end
end

function SpinView:onColumnStop(event)
    local column = event.result
    self.theme:onColumnStop(column)
end

function SpinView:onTriggerColumnPrompt(index)
    if index >= self.column then return end

    local column = self.spinColumns[index + 1]
    if column:getTagEnabled("winBonus") then
        column:setWinBonusAction()
    else
        column:removeWinBonus()
    end
end

function SpinView:onStopWinBonusAction(minWinBonusColumn)
    for i = 1, minWinBonusColumn do
        self.spinColumns[i]:removeWinBonus()
    end
end

function SpinView:onTrueReelsResponse(event)
    local result = event.result
    self:setTrueReels(result.displayReels, result.falseReels)
end

function SpinView:setTrueReels(trueReels, falseReels)
    for index, column in ipairs(self.spinColumns) do
        column:setTrueReel(trueReels[index], falseReels[index])
    end
end

function SpinView:getColumnCount()
    return self.column
end

function SpinView:getLines(points, rects)
    local lines = {}
    for i = 1, #points - 1 do
        local pt1 = points[i]
        local pt2 = points[i + 1]
        for j = 1, #rects do
            if pt1.x == pt2.x and pt1.y == pt2.y then
                break
            end

            local rect = rects[j]
            if pt2.x < rect.x then
                break
            end

            local intersectionPoint, nextStartPoint = self:getIntersectPoint(pt1, pt2, rect)
            if intersectionPoint then
                local line = SpinLine:create(pt1, intersectionPoint)
                table.insert(lines, line)
            end
            
            pt1 = nextStartPoint

            if not pt1 then
                break
            end
        end

        if pt1 and (pt1.x ~= pt2.x or pt1.y ~= pt2.y) then
            local line = SpinLine:create(pt1, pt2)
            table.insert(lines, line)
        end
    end

    return lines
end

function SpinView:getIntersectPoint(pointA, pointB, rect)
    local LB_point = cc.p(rect.x, rect.y)
    local LT_point = cc.p(rect.x, rect.y + rect.height)
    local RT_point = cc.p(rect.x + rect.width, rect.y + rect.height)
    local RB_point = cc.p(rect.x + rect.width, rect.y)

    local resultPoints = {}

    local flag = cc.pIsSegmentIntersect(pointA, pointB, LB_point, LT_point)
    if flag then
        local point = cc.pGetIntersectPoint(pointA, pointB, LB_point, LT_point)
        table.insert(resultPoints, point)
    end

    flag = cc.pIsSegmentIntersect(pointA, pointB, LT_point, RT_point)
    if flag then
        local point = cc.pGetIntersectPoint(pointA, pointB, LT_point, RT_point)
        table.insert(resultPoints, point)
    end

    flag = cc.pIsSegmentIntersect(pointA, pointB, LB_point, RB_point)
    if flag then
        local point = cc.pGetIntersectPoint(pointA, pointB, LB_point, RB_point)
        table.insert(resultPoints, point)
    end

    flag = cc.pIsSegmentIntersect(pointA, pointB, RB_point, RT_point)
    if flag then
        local point = cc.pGetIntersectPoint(pointA, pointB, RB_point, RT_point)
        table.insert(resultPoints, point)
    end

    local len = #resultPoints
    if len == 0 then
        if cc.rectContainsPoint(rect, pointB) then
            -- 处理两个点都在rect的情况
            pointA = nil
        end
        return nil, pointA
    elseif len == 1 then
        if cc.rectContainsPoint(rect, pointA) then
            if cc.rectContainsPoint(rect, pointB) and pointB.x > resultPoints[1].x then
                return nil, nil
            else
                return nil, resultPoints[1]
            end
        else
            return resultPoints[1], pointB
        end
    else
        local intersectionPoint, nextStartPoint
        if resultPoints[1].x < resultPoints[2].x then
            intersectionPoint = resultPoints[1]
            nextStartPoint = resultPoints[2]
        else
            intersectionPoint = resultPoints[2]
            nextStartPoint = resultPoints[1]
        end

        return intersectionPoint, nextStartPoint
    end
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