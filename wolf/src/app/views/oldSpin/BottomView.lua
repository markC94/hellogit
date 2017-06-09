--region *.lua
--Date
--此文件由[BabeLua]插件自动生成

local BottomView = class("BottomView")
function BottomView:ctor(theme, order)
    self.app = theme:getSpinApp()
    self.theme = theme

    local rootNode = cc.CSLoader:createNode("csb/spin/bottomView.csb")
    self.rootNode = rootNode

    self:setViews(rootNode)
    self:setClickListener(rootNode)
    self:initUserData()

    rootNode:registerScriptHandler(function(state)
        if state == "enter" then
            self:onEnter()
        elseif state == "exit" then
            self:onExit()
        end
    end)

    theme:addChild(rootNode, order, order)
end

function BottomView:initUserData()
    self:setBetData(self.theme:getBetValue())
    
    self.winNum:setString(0)
end

function BottomView:onEnter()
    self.isDead = false
    bole:addListener("spin", self.onSpin, self, nil, true)
    bole:addListener("stop", self.onStop, self, nil, true)
    bole:addListener("spinStatus", self.onSpinStatus, self, nil, true)
    bole:addListener("winAmount", self.onWinAmount, self, nil, true)
end

function BottomView:onExit()
    bole:getEventCenter():removeEventWithTarget("spin", self)
    bole:getEventCenter():removeEventWithTarget("stop", self)
    bole:getEventCenter():removeEventWithTarget("spinStatus", self)
    bole:getEventCenter():removeEventWithTarget("winAmount", self)
    self.isDead = true
end

function BottomView:onSpin(event)
    self:onSpinStatus("stopDisabled")
    self.autoSpinNode:setVisible(false)
    self.winNum:setString(0)
end

function BottomView:onStop(event)
    self:onSpinStatus("stopDisabled")
end

function BottomView:onWinAmount(event)
    self.winNum:setString(event.result)
end

function BottomView:onSpinStatus(event)
    local status
    if type(event) == "table" then
        status = event.result
    else
        status = event
    end

    self.stopBtn:setVisible(false)
    self.spinBtn:setVisible(false)

    if status == "stopEnabled" then
        self.stopBtn:setVisible(true)
        self.stopBtn:setEnabled(true)
    elseif status == "spinEnabled" then
        self.spinBtn:setVisible(true)
        self.spinBtn:setEnabled(true)
    elseif status == "spinDisabled" then
        self.spinBtn:setVisible(true)
        self.spinBtn:setEnabled(false)
    elseif status == "stopDisabled" then
        self.stopBtn:setVisible(true)
        self.stopBtn:setEnabled(false)
    end
end

function BottomView:setBetData(betNum, isAdd)
    if isAdd then
        betNum = self.betValue + betNum
    end

    if betNum > 0 then
        self.betValue = betNum
        self.betNum:setString(betNum)
        self.totalBetNum:setString(betNum*self.theme:getEachLineBet())
        self.theme:setBetValue(self.betValue)
        return true
    end

    return false
end

function BottomView:setClickListener()
    self.addBetBtn = self.rootNode:getChildByName("addBet")
    self.subBetBtn = self.rootNode:getChildByName("subBet")
    self.payTableBtn = self.rootNode:getChildByName("payTable")
    self.maxBetBtn = self.rootNode:getChildByName("maxBet")
    self.stopBtn = self.rootNode:getChildByName("stop")
    self.spinBtn = self.rootNode:getChildByName("spin")

    local function onClick(event)
        if event.name == "ended" then
            if event.target == self.spinBtn then
                bole:postEvent("clickSpin")
            elseif event.target == self.stopBtn then
                bole:postEvent("clickStop")
            elseif event.target == self.addBetBtn then
                self:setBetData(1, true)
            elseif event.target == self.subBetBtn then
                self:setBetData(-1, true)
            elseif event.target == self.payTableBtn then
            elseif event.target == self.maxBetBtn then
            end
        end
    end

    self.addBetBtn:onTouch(onClick)
    self.subBetBtn:onTouch(onClick)
    self.payTableBtn:onTouch(onClick)
    self.maxBetBtn:onTouch(onClick)
    self.stopBtn:onTouch(onClick)
    self.spinBtn:onTouch(onClick)
end

function BottomView:setViews(rootNode)
    self.autoSpinNode = rootNode:getChildByName("autoSpinBottomBg")
    self.autoSpinNode:setVisible(false)

    self.betNum = rootNode:getChildByName("betNumBg"):getChildByName("betNum")

    local winNumBg = rootNode:getChildByName("winNumBg")
    self.totalBetNum = winNumBg:getChildByName("totalBetNum")
    self.winNum = winNumBg:getChildByName("winNum")
end

function BottomView:removeFromParent(isCleanup)
    self.rootNode:removeFromParent(isCleanup)
end

return BottomView

--endregion
