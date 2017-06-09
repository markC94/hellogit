--region *.lua
--Date
--此文件由[BabeLua]插件自动生成

local FreeSpinNode = class("FreeSpinNode")
function FreeSpinNode:ctor(parentNode, order)

    local rootNode = cc.CSLoader:createNode("csb/spin/freeSpinNode.csb")
    local actionTimeLine = cc.CSLoader:createTimeline("csb/spin/freeSpinNode.csb")
    rootNode:runAction(actionTimeLine)
    actionTimeLine:gotoFrameAndPause(0)

    self.rootNode = rootNode
    self.rootAction = actionTimeLine

    self:setViews(rootNode)

    rootNode:registerScriptHandler(function(state)
        if state == "enter" then
            self:onEnter()
        elseif state == "exit" then
            self:onExit()
        end
    end)

    parentNode:addChild(rootNode, order)
end

function FreeSpinNode:onEnter()
    self.isDead = false
    bole:addListener("freeSpinNum", self.onFreeSpinNum, self, nil, true)
    bole:addListener("startFreeSpin", self.onStartFreeSpin, self, nil, true)
    bole:addListener("stopFreeSpin", self.onStopFreeSpin, self, nil, true)
end

function FreeSpinNode:onExit()
    bole:getEventCenter():removeEventWithTarget("freeSpinNum", self)
    bole:getEventCenter():removeEventWithTarget("startFreeSpin", self)
    bole:getEventCenter():removeEventWithTarget("stopFreeSpin", self)

    self.isDead = true
end

function FreeSpinNode:onFreeSpinNum(event)
    self.freeSpinNum:setString(event.result)
end

function FreeSpinNode:onStartFreeSpin(event)
    self.rootAction:play("moveIn", false)
    if event.result then
        self.freeSpinNum:setString(event.result)
    end
end

function FreeSpinNode:onStopFreeSpin(event)
    self.rootAction:play("moveOut", false)
end

function FreeSpinNode:setViews(rootNode)
    self.freeSpinNum = rootNode:getChildByName("clip"):getChildByName("icon"):getChildByName("num")
end

function FreeSpinNode:setPosition(x, y)
    self.rootNode:setPosition(x, y)
end

return FreeSpinNode

--endregion
