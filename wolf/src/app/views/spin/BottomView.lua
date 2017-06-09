--region *.lua
--Date
--此文件由[BabeLua]插件自动生成

local BottomView = class("BottomView")
function BottomView:ctor(theme, order)
    self.app = theme:getSpinApp()
    self.theme = theme

    local rootNode = cc.CSLoader:createNodeWithVisibleSize("csb/spin/bottomView.csb")
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
    local betValue = {}
    local configThemeName = self.theme:getThemeName()
    local betFile = bole:getConfigCenter():getConfig(string.format("%s_bet", configThemeName))
    local i = 1
    while(true) do
        local item = betFile[tostring(i)]
        if not item then
            break
        end
        table.insert(betValue, item.bet_count)
        i = i + 1
    end
    self.betTable = betValue

    self:setBetData(self.theme:getBetValue())

    self.winNum:setString(0)
end

function BottomView:onEnter()
    self.isDead = false
    bole:addListener("spin", self.onSpin, self, nil, true)
    bole:addListener("stop", self.onStop, self, nil, true)
    bole:addListener("spinStatus", self.onSpinStatus, self, nil, true)
    bole:addListener("winAmount", self.onWinAmount, self, nil, true)
--    bole:addListener("spinCoinNotEnough", self.onStopAutoSpin, self, nil, true)
    bole:addListener("startAutoSpinEnabled", self.onStartAutoSpin, self, nil, true)
end

function BottomView:onExit()
    bole:getEventCenter():removeEventWithTarget("spin", self)
    bole:getEventCenter():removeEventWithTarget("stop", self)
    bole:getEventCenter():removeEventWithTarget("spinStatus", self)
    bole:getEventCenter():removeEventWithTarget("winAmount", self)
--    bole:getEventCenter():removeEventWithTarget("spinCoinNotEnough", self)
    bole:getEventCenter():removeEventWithTarget("startAutoSpinEnabled", self)
    self.isDead = true
end

function BottomView:onSpin(event)
    self:onSpinStatus("stopDisabled")
--    self.autoSpinNode:setVisible(false)
--    self.winNum:setString(0)
end

function BottomView:onStop(event)
    self:onSpinStatus("stopDisabled")
end

function BottomView:onWinAmount(event)
    local winCoin = event.result
    if winCoin > 0 then
        self.winNum:setString(bole:formatCoins(winCoin, 12))
    end
end

function BottomView:onSpinStatus(event)
    local status
    if type(event) == "table" then
        status = event.result
    else
        status = event
    end
--    status = string.gsub(status, "(%a+)_%d", "%1")
    print("BottomView:onSpinStatus=" .. status)

    local spinFlag, stopFlag = false, false
    if status == "stopEnabled" then
        stopFlag = true
        self.stopBtn:setEnabled(true)
    elseif status == "spinEnabled" then
        spinFlag = true
        self.spinBtn:setEnabled(true)
    elseif status == "spinDisabled" then
        spinFlag = true
        self.spinBtn:setEnabled(false)
    elseif status == "stopDisabled" then
        stopFlag = true
        self.stopBtn:setEnabled(false)
    end

    self.spinBtn:setVisible(spinFlag)
    self.stopBtn:setVisible(stopFlag)
end

--function BottomView:onStopAutoSpin(event)
--    self.isAutoSpinning = false
--end

function BottomView:onStartAutoSpin(event)
    if self.isAutoSpinning then
        local target = self.spinBtn
        if target:isVisible() and target:isEnabled() then
            bole:postEvent("clickSpin", {autoSpin = true})
        end
    end
end

function BottomView:setBetData(betNum, isAdd, betId)
    local betValue = betNum
    if isAdd then
        betValue = self.betTable[self.betId+betNum]
    end

    if betValue and betValue > 0 and betValue <= self:getMaxBetValue() then
        if not isAdd then
            if not betId then
                betId = self:getBetIdByValue(betValue)
            end
            self.betId = betId
        else
            self.betId = self.betId + betNum
        end

        self.betValue = self.betTable[self.betId]
        self.theme:setBetValue(self.betValue)
        self.totalBetNum:setString(bole:formatCoins(self.theme:getSpinCost(), 3))
        return true
    end

    return false
end

function BottomView:getMaxBetId()
    local level = bole:getUserData():getDataByKey("level")
    local maxBetValue = bole:getConfigCenter():getConfig("level", level, "max_bet")
    local betId = self:getBetIdByValue(maxBetValue)
    return betId
end

function BottomView:getMaxBetValue()
    return self.betTable[self:getMaxBetId()]
end

function BottomView:getBetIdByValue(betValue)
    local betId = 1
    for k = #self.betTable, 1 , -1 do
        if self.betTable[k] <= betValue then
            betId = k
            break
        end
    end
    return betId
end

function BottomView:setMaxBetValue()
    local betId = self:getMaxBetId()
    self:setBetData(self.betTable[betId], false, betId)

--    local node = bole:getEntity("app.views.lobby.SpecialBonusWinCoin")
--    local nodePos = self.rootNode:convertToNodeSpace(cc.p(cc.Director:getInstance():getWinSize().width/2, 80))
--    node:setPosition(nodePos.x, nodePos.y)
--    self.rootNode:addChild(node, 9999)
end

function BottomView:setClickListener()
    self.stopBtn = self.rootNode:getChildByName("stop")
    self.spinBtn = self.rootNode:getChildByName("spin")
    self.friendBtn = self.rootNode:getChildByName("friendBt")
    self.chatBtn = self.rootNode:getChildByName("chatBt")

    local bottomBg = self.rootNode:getChildByName("bottomBg")
    self.maxBetBtn = bottomBg:getChildByName("maxBetBt")

    local betNode = bottomBg:getChildByName("betBg")
    self.addBetBtn = betNode:getChildByName("addBetBt")
    self.subBetBtn = betNode:getChildByName("subBetBt")

    local function onClick(event)
        if event.name == "ended" then
            local target = event.target
            if not target:isVisible() or not target:isEnabled() then
                return
            end

            if target == self.spinBtn then
                if not self.isAutoSpinning then
                    local nowTimeSecond = os.time()
                    print("oldTime=" .. self.startTimeSecond .. ",newTime=" .. nowTimeSecond)
                    if nowTimeSecond - self.startTimeSecond >= 2 then
                        self.isAutoSpinning = true
                    else
                        self.isAutoSpinning = false
                    end
                else
                    self.isAutoSpinning = false
                end
                bole:postEvent("clickSpin", {autoSpin = self.isAutoSpinning})
            elseif target == self.stopBtn then
                self.isAutoSpinning = false
                bole:postEvent("clickStop")
            elseif target == self.addBetBtn then
                self.isAutoSpinning = false
                self:setBetData(1, true)
            elseif target == self.subBetBtn then
                self.isAutoSpinning = false
                self:setBetData(-1, true)
            elseif target == self.maxBetBtn then
                self.isAutoSpinning = false
                self:setMaxBetValue()
            elseif target == self.chatBtn then
                self.isAutoSpinning = false
                self.theme:createChatView()
            elseif target == self.friendBtn then
                self.isAutoSpinning = false
                self.theme:createFriendView()
            end
        elseif event.name == "began" then
            if event.target == self.spinBtn then
                self.startTimeSecond = os.time()
            end
        end
    end

    self.addBetBtn:onTouch(onClick)
    self.subBetBtn:onTouch(onClick)
    self.maxBetBtn:onTouch(onClick)
    self.stopBtn:onTouch(onClick)
    self.spinBtn:onTouch(onClick)
    self.friendBtn:onTouch(onClick)
    self.chatBtn:onTouch(onClick)

    --按钮放缩的动作
    self.addBetBtn:setPressedActionEnabled(true)
    self.subBetBtn:setPressedActionEnabled(true)
    self.maxBetBtn:setPressedActionEnabled(true)
    self.stopBtn:setPressedActionEnabled(true)
    self.spinBtn:setPressedActionEnabled(true)
    self.friendBtn:setPressedActionEnabled(true)
    self.chatBtn:setPressedActionEnabled(true)
end

function BottomView:setViews(rootNode)
    local bottomBg = rootNode:getChildByName("bottomBg")

    self.totalBetNum = bottomBg:getChildByName("betBg"):getChildByName("BetNum")
    self.winNum = bottomBg:getChildByName("lastWinBg"):getChildByName("lastWinNum")
end

function BottomView:removeFromParent(isCleanup)
    self.rootNode:removeFromParent(isCleanup)
end

return BottomView

--endregion
