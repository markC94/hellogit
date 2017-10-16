--region *.lua
--Date
--此文件由[BabeLua]插件自动生成

local FreeSpinBottomView = class("FreeSpinBottomView")
function FreeSpinBottomView:ctor(theme, order, freespinNum, totalNum, totalWinCoin)
    self.app = theme:getSpinApp()
    self.theme = theme

    local rootNode = cc.CSLoader:createNodeWithVisibleSize("themeInViews/bottom/freespinBottomView.csb")
    self.rootNode = rootNode

    self:setViews(rootNode)
    self:setClickListener(rootNode)
    self:initUserData(freespinNum, totalNum, totalWinCoin)

    rootNode:registerScriptHandler(function(state)
        if state == "enter" then
            self:onEnter()
        elseif state == "exit" then
            self:onExit()
        end
    end)

    theme:addChild(rootNode, order, order)
end

function FreeSpinBottomView:initUserData(freespinNum, totalNum, totalCoin)
    self:setBetValue()
    self.totalWinCoin = totalCoin or 0
    self.winCoin = 0

    self:setWinNumVisible(false)
    self.totalWinNum:setString("")
    
    self.spinLeftNum:setString(string.format("%d/%d", freespinNum, totalNum))
end

function FreeSpinBottomView:onEnter()
    bole:addListener("spin", self.onSpin, self, nil, true)
    bole:addListener("stop", self.onStop, self, nil, true)
    bole:addListener("spinStatus", self.onSpinStatus, self, nil, true)
    bole:addListener("winAmount", self.onWinAmount, self, nil, true)
    bole:addListener("freeSpinNum", self.onFreeSpinNum, self, nil, true)
    bole:addListener("showNewMessageNum", self.showNewMessageNum, self, nil, true)
end

function FreeSpinBottomView:onExit()
    bole:getEventCenter():removeEventWithTarget("spin", self)
    bole:getEventCenter():removeEventWithTarget("stop", self)
    bole:getEventCenter():removeEventWithTarget("spinStatus", self)
    bole:getEventCenter():removeEventWithTarget("winAmount", self)
    bole:getEventCenter():removeEventWithTarget("freeSpinNum", self)
    bole:getEventCenter():removeEventWithTarget("showNewMessageNum", self)
end

function FreeSpinBottomView:onSpin(event)
    self:stopWinCoin()
    self:onSpinStatus("spinDisabled")
end

function FreeSpinBottomView:onStop(event)
    self:onSpinStatus("stopDisabled")
end

function FreeSpinBottomView:onFreeSpinNum(event)
    local result = event.result
    self.spinLeftNum:setString(string.format("%d/%d", result.remain, result.total))
end

function FreeSpinBottomView:onWinAmount(event)
    local result = event.result
    self.winCoin = result[1]
    local time = result[2]
    self.totalWinCoin = self.totalWinCoin + self.winCoin
    if self.winCoin > 0 then
        self:setWinNum(self.winCoin, self.totalWinCoin, time)
    end
end

function FreeSpinBottomView:setWinNumVisible(flag)
    self.thisWinNum:setVisible(flag)
    self.totalWinLabel:setVisible(not flag)
    if flag then
        self.thisWinNum:setString("")
    end
end

function FreeSpinBottomView:setWinNum(num, sum, time)
    self:setWinNumVisible(true)
    self.thisWinNum:setString("+" .. bole:formatCoins(num, 12))
    local function callback()
        self.winCoin = 0
    end
    bole:runNum(self.totalWinNum, sum-num, sum, time-0.02, callback, {12})
end

function FreeSpinBottomView:stopWinCoin()
    local winCount = self.winCoin

    if winCount > 0 then
        self.totalWinNum:unscheduleUpdate()
        self.totalWinNum:setString(bole:formatCoins(self.totalWinCoin, 12))
    end

    local function hideFreeSpinWin()
        if self.setWinNumVisible then
            self:setWinNumVisible(false)
        end
    end
    self.theme:addWaitEvent("bottomHideFreeSpinWin", 0.3, hideFreeSpinWin)
end

function FreeSpinBottomView:onSpinStatus(event)
    local status
    if type(event) == "table" then
        status = event.result
    else
        status = event
    end
--    status = string.gsub(status, "(%a+)_%d", "%1")
    print("FreeSpinBottomView:onSpinStatus=" .. status)

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
        spinFlag = true
        self.spinBtn:setEnabled(false)
    end

    self.spinBtn:setVisible(spinFlag)
    self.stopBtn:setVisible(stopFlag)
end

function FreeSpinBottomView:setBetValue()
    self.totalBetNum:setString(bole:formatCoins(self.theme:getSpinCost(), 3))
end

function FreeSpinBottomView:setClickListener(rootNode)
    local bottomBg = rootNode:getChildByName("bg")

    self.chatBtn = bottomBg:getChildByName("chatBtn")
    local newMessageNum = bole:getChatManage():getNewMessageNum()
    if newMessageNum ~= 0 then
        self.chatBtn:getChildByName("newMessage"):setVisible(true)
        self.chatBtn:getChildByName("newMessage"):getChildByName("txt"):setString(bole:getChatManage():getNewMessageNum())
    end
    self.spinBtn = bottomBg:getChildByName("spin")
    self.stopBtn = bottomBg:getChildByName("stop")

    local function onClick(event)
        if event.name == "ended" then
            local target = event.target
            if not target:isVisible() or not target:isEnabled() then
                return
            end

            if target == self.spinBtn then
                bole:postEvent("clickSpin", {autoSpin = false})
            elseif target == self.stopBtn then
                bole:postEvent("clickStop")
            elseif target == self.chatBtn then
                self.theme:createChatView()
            end
        end
    end

    self.chatBtn:onTouch(onClick)
    self.spinBtn:onTouch(onClick)
    self.stopBtn:onTouch(onClick)

    self.chatBtn:setPressedActionEnabled(true)
end

function FreeSpinBottomView:setViews(rootNode)
    local bottomBg = rootNode:getChildByName("bg")

    self.spinLeftNum = bottomBg:getChildByName("spinleft"):getChildByName("spinRemainNum")
    self.totalBetNum = bottomBg:getChildByName("betbg"):getChildByName("BetNum")

    local winBg = bottomBg:getChildByName("lastWinBg")
    self.thisWinNum = winBg:getChildByName("thisWinNum")
    self.totalWinNum = winBg:getChildByName("totalWinNum")
    self.totalWinLabel = winBg:getChildByName("totalLabel")
end

function FreeSpinBottomView:showNewMessageNum(data)
    data = data.result
    if data == 0 then
        self.chatBtn:getChildByName("newMessage"):setVisible(false)
    else
        self.chatBtn:getChildByName("newMessage"):setVisible(true)
        self.chatBtn:getChildByName("newMessage"):getChildByName("txt"):setString(data)
    end
end

function FreeSpinBottomView:removeFromParent(isCleanup)
    self.rootNode:removeFromParent(isCleanup)
end

return FreeSpinBottomView

--endregion
