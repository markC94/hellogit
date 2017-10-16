-- region *.lua
-- Date
-- 此文件由[BabeLua]插件自动生成

local BottomView = class("BottomView")
function BottomView:ctor(theme, order, isAuto)
    self.app = theme:getSpinApp()
    self.theme = theme

    local rootNode = cc.CSLoader:createNodeWithVisibleSize("themeInViews/bottom/commonBottomView.csb")
    self.rootNode = rootNode

    self:setViews(rootNode)
    self:setClickListener(rootNode)
    self:initUserData()

    rootNode:registerScriptHandler( function(state)
        if state == "enter" then
            self:onEnter()
        elseif state == "exit" then
            self:onExit()
        end
    end )

    theme:addChild(rootNode, order, order)

    if isAuto then
        self:setAutoStatus()
    end
end

function BottomView:initUserData()
    self:setBetValue()

    self.winCoin = 0
    -- 本次spin赢的金币数量
    self:setWinNumVisible(false)
end

function BottomView:onEnter()
    bole:addListener("spin", self.onSpin, self, nil, true)
    bole:addListener("stop", self.onStop, self, nil, true)
    bole:addListener("spinStatus", self.onSpinStatus, self, nil, true)
    bole:addListener("winAmount", self.onWinAmount, self, nil, true)
    bole:addListener("spinCoinNotEnough", self.stopAuto, self, nil, true)
    bole:addListener("startAutoSpinEnabled", self.onStartAutoSpin, self, nil, true)
    bole:addListener("showNewMessageNum", self.showNewMessageNum, self, nil, true)
end

function BottomView:onExit()
    bole:getEventCenter():removeEventWithTarget("spin", self)
    bole:getEventCenter():removeEventWithTarget("stop", self)
    bole:getEventCenter():removeEventWithTarget("spinStatus", self)
    bole:getEventCenter():removeEventWithTarget("winAmount", self)
    bole:getEventCenter():removeEventWithTarget("spinCoinNotEnough", self)
    bole:getEventCenter():removeEventWithTarget("startAutoSpinEnabled", self)
    bole:getEventCenter():removeEventWithTarget("showNewMessageNum", self)
    self:removeListenForAuto()
end

function BottomView:onSpin(event)
    self:stopWinCoin()
    self:onSpinStatus("spinDisabled")
end

function BottomView:onStop(event)
    self:onSpinStatus("stopDisabled")
end

function BottomView:onWinAmount(event)
    local result = event.result
    self.winCoin = result[1]
    self.sumCoin = bole:getUserDataByKey("coins")
    local winTime = result[3]
    if self.winCoin > 0 then
        self:setWinNum(self.winCoin, self.sumCoin, winTime)
    end
end

function BottomView:setWinNum(num, sum, time)
    self:setWinNumVisible(true)
    local function callback()
        self:addWinToTop(num, sum)
    end
    bole:runNum(self.winNum, 0, num, time, callback, { 12 })
end

function BottomView:addWinToTop(winCount, sum)
    self.winCoin = 0
    local function addWinCoinToTop()
        bole:postEvent("putWinCoinToTop", { coin = sum })
    end
    self.theme:addWaitEvent("addWinCoinToTop", 0.3, addWinCoinToTop)
end

function BottomView:stopWinCoin()
    local winCount = self.winCoin

    if winCount > 0 then
        self.winNum:unscheduleUpdate()
        self.winNum:setString(bole:formatCoins(winCount, 12))

        self:addWinToTop(winCount, self.sumCoin)
    end

    local function hideSpinWin()
        if self.setWinNumVisible then
            self:setWinNumVisible(false)
        end
    end
    self.theme:addWaitEvent("bottomHideSpinWin", 0.3, hideSpinWin)
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
        if not self.isAutoSpinning then
            self:setBetEnabled(true)
            self:onSpinBtnAnim(true)
        end

        self:removeListenForAuto()
    elseif status == "spinDisabled" then
        spinFlag = true
        self.spinBtn:setEnabled(false)

        if not self.isAutoSpinning then
            self:setBetEnabled(false)
            self:onSpinBtnAnim(false)
        end
    elseif status == "stopDisabled" then
        spinFlag = true
        self.spinBtn:setEnabled(false)
    end

    if not self.isAutoSpinning then
        self.spinBtn:setVisible(spinFlag)
        self.stopBtn:setVisible(stopFlag)
    end

    self.spinStatus = status
end

function BottomView:onSpinBtnAnim(flag)
    local target = self.spinPlayBtn
    if flag then
        if not target then
            target = sp.SkeletonAnimation:create("spin_bottom/spin_1.json", "spin_bottom/spin_1.atlas")
            self.spinBtn:addChild(target)
            local spinBtnSize = self.spinBtn:getContentSize()
            target:setPosition(spinBtnSize.width/2, spinBtnSize.height/2)
            self.spinPlayBtn = target
        end

        target:setVisible(true)
        target:clearTracks()
        target:setToSetupPose()
        target:setAnimation(0, "animation", true)
    else
        if target then
            target:setVisible(false)
        end
    end
end

function BottomView:onAutoSpinBtnAnim(flag)
    local target = self.autoSpinPlayBtn
    if flag then
        if not target then
            target = sp.SkeletonAnimation:create("spin_bottom/auto_spin.json", "spin_bottom/auto_spin.atlas")
            self.autoBtn:addChild(target)
            local spinBtnSize = self.autoBtn:getContentSize()
            target:setPosition(spinBtnSize.width/2, spinBtnSize.height/2)
            self.autoSpinPlayBtn = target
        end

        target:setVisible(true)
        target:clearTracks()
        target:setToSetupPose()
        target:setAnimation(0, "animation", true)
    else
        if target then
            target:setVisible(false)
        end
    end
end

function BottomView:setBetEnabled(isEnabled)
    self.addBetBtn:setEnabled(isEnabled)
    self.subBetBtn:setEnabled(isEnabled)
    self.maxBetBtn:setEnabled(isEnabled)
end

function BottomView:onStartAutoSpin(event)
    if self.isAutoSpinning then
        local target = self.autoBtn
        if target:isVisible() and target:isEnabled() then
            bole:postEvent("clickSpin", { autoSpin = true })
        end
    end
end

function BottomView:setBetValue()
    self.totalBetNum:setString(bole:formatCoins(self.theme:getSpinCost(), 3))
end

function BottomView:setClickListener(rootNode)
    local bottomBg = rootNode:getChildByName("bg")

    self.chatBtn = bottomBg:getChildByName("chatBtn")
    local newMessageNum = bole:getChatManage():getNewMessageNum()
    if newMessageNum ~= 0 then
        self.chatBtn:getChildByName("newMessage"):setVisible(true)
        self.chatBtn:getChildByName("newMessage"):getChildByName("txt"):setString(bole:getChatManage():getNewMessageNum())
    end
    self.maxBetBtn = bottomBg:getChildByName("maxBetBt")

    local betNode = bottomBg:getChildByName("betbg")
    self.addBetBtn = betNode:getChildByName("addBetBt")
    self.subBetBtn = betNode:getChildByName("subBetBt")

    self.stopBtn = bottomBg:getChildByName("stop")
    self.spinBtn = bottomBg:getChildByName("spin")
    self.autoBtn = bottomBg:getChildByName("autospin")

    local function onClick(event)
        local target = event.target
        if not target:isVisible() or not target:isEnabled() then
            return
        end

        if event.name == "ended" then
            if target == self.spinBtn then
                self:removeListenForAuto()
                bole:postEvent("clickSpin", { autoSpin = self.isAutoSpinning })
            elseif target == self.stopBtn then
                bole:postEvent("clickStop")
            elseif target == self.addBetBtn then
                if self.theme:addBet() then
                    self:setBetValue()
                end
            elseif target == self.subBetBtn then
                if self.theme:subBet() then
                    self:setBetValue()
                end
            elseif target == self.maxBetBtn then
                if self.theme:setMaxBetValue() then
                    self:setBetValue()
                end
            elseif target == self.chatBtn then
                self.theme:createChatView()
            elseif target == self.autoBtn then
                self:stopAuto()
            end
        elseif event.name == "moved" then
            if target == self.spinBtn then
                local isPressed = target:isHighlighted()
                if not self.spinBtnMoveOut and not isPressed then
                    self.spinBtnMoveOut = true
                    self:onSpinBtnAnim(true)
                    self:removeListenForAuto()
                elseif self.spinBtnMoveOut and isPressed then
                    self.spinBtnMoveOut = false
                    self:onSpinBtnAnim(false)
                    self:startListenForAuto()
                end
            elseif target == self.autoBtn then
                local isPressed = target:isHighlighted()
                if not self.spinAutoBtnMoveOut and not isPressed then
                    self.spinAutoBtnMoveOut = true
                    self:onAutoSpinBtnAnim(true)
                elseif self.spinAutoBtnMoveOut and isPressed then
                    self.spinAutoBtnMoveOut = false
                    self:onAutoSpinBtnAnim(false)
                end
            end
        elseif event.name == "cancelled" then
            if target == self.spinBtn then
                self:removeListenForAuto()
            end
        elseif event.name == "began" then
            if target == self.spinBtn then
                self.spinBtnMoveOut = false
                self:onSpinBtnAnim(false)
                self:startListenForAuto()
            elseif target == self.autoBtn then
                self.spinAutoBtnMoveOut = false
                self:onAutoSpinBtnAnim(false)
            end
        end
    end

    self.addBetBtn:onTouch(onClick)
    self.subBetBtn:onTouch(onClick)
    self.maxBetBtn:onTouch(onClick)
    self.chatBtn:onTouch(onClick)

    self.stopBtn:onTouch(onClick)
    self.spinBtn:onTouch(onClick)
    self.autoBtn:onTouch(onClick)

    -- 按钮放缩的动作
    self.addBetBtn:setPressedActionEnabled(true)
    self.subBetBtn:setPressedActionEnabled(true)
    self.maxBetBtn:setPressedActionEnabled(true)
    self.chatBtn:setPressedActionEnabled(true)

    self.autoBtn:setVisible(false)
end

function BottomView:startListenForAuto()
    local function changeToAuto()
        self:startAuto()
    end
    self.theme:addWaitEvent("listenforautospin", 1.2, changeToAuto)
end

function BottomView:removeListenForAuto()
    self.theme:removeWaitEventByName("listenforautospin")
end

function BottomView:setAutoStatus()
    self.spinBtn:setVisible(false)
    self.stopBtn:setVisible(false)
    self.autoBtn:setVisible(true)
    self:onAutoSpinBtnAnim(true)
    self:setBetEnabled(false)
    self.isAutoSpinning = true
end

function BottomView:startAuto()
    if self.isAutoSpinning or not self.spinBtn:isVisible() or not self.spinBtn:isEnabled() then
        return
    end
    bole:openAndroidUtil(1)
    self:setAutoStatus()
    bole:getAudioManage():playAutoSpin()
    bole:postEvent("clickSpin", { autoSpin = self.isAutoSpinning })
end

function BottomView:stopAuto(event)
    bole:openAndroidUtil(2)
    self.isAutoSpinning = false
    self.autoBtn:setVisible(false)
    self:onSpinStatus(self.spinStatus)
    bole:postEvent("bottomViewStopAuto")
end

function BottomView:setViews(rootNode)
    local bottomBg = rootNode:getChildByName("bg")

    self.totalBetNum = bottomBg:getChildByName("betbg"):getChildByName("BetNum")

    local lastWinBg = bottomBg:getChildByName("lastWinBg")
    self.winNum = lastWinBg:getChildByName("lastWinNum")
    self.winLabel = lastWinBg:getChildByName("lastwin")
    self.winLine = lastWinBg:getChildByName("lines")
    self.lineNum = self.winLine:getChildByName("lineNum")
end

function BottomView:setWinNumVisible(flag)
    self.winNum:setVisible(flag)
    self.winLabel:setVisible(flag)
    self.winLine:setVisible(not flag)
    if flag then
        self.winNum:setString("")
    end
end

function BottomView:showNewMessageNum(data)
    data = data.result
    if data == 0 then
        self.chatBtn:getChildByName("newMessage"):setVisible(false)
    else
        self.chatBtn:getChildByName("newMessage"):setVisible(true)
        self.chatBtn:getChildByName("newMessage"):getChildByName("txt"):setString(data)
    end
end

function BottomView:removeFromParent(isCleanup)
    self.rootNode:removeFromParent(isCleanup)
end

return BottomView

-- endregion
