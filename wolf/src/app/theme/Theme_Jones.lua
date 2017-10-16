--region *.lua
--Date
--此文件由[BabeLua]插件自动生成

local Theme_jones = class("Theme_jones", bole:getTable("app.theme.BaseTheme"))

function Theme_jones:ctor(themeId, app)
    print("Theme_jones:ctor")
    self.reSpinCount = 0
    self.reSpinReelStopCount = 0
    Theme_jones.super.ctor(self, themeId, app)
end

function Theme_jones:setSpinBgPosition(node)
    node:setPositionY(node:getPositionY() + 8)
end

function Theme_jones:createAnimLayer(parentNode, order, pos)
    Theme_jones.super.createAnimLayer(self, parentNode, order, pos)

    local animNode = cc.Node:create()
    parentNode:addChild(animNode, order+1)
    animNode:setPosition(pos[1], pos[2])
    self.promptNode = animNode
end

function Theme_jones:getPromptNode()
    return self.promptNode
end

function Theme_jones:creatRespinNumNode()
    print("Theme_jones:creatRespinNumNode")
    local position = self:getSpinPositionByPos(1, 5, true)
    position.x = position.x - 30

    local spb = cc.Sprite:create(self.app:getRes(self.themeId, "respin/04.png"))
    self.animNode:addChild(spb)
    spb:setPosition(position.x, position.y)

    local spt = cc.Sprite:create(self.app:getRes(self.themeId, "respin/03.png"))
    spb:addChild(spt)
    spt:setPosition(spb:getContentSize().width/2, spb:getContentSize().height/2)
    self.respinSp = spt

    local node = sp.SkeletonAnimation:create(self.app:getSymbolAnim(self.themeId, "jones_shiban"))
    spb:addChild(node)
    node:setAnimation(0, "animation", false)
    node:setPosition(spb:getContentSize().width/2+1, spb:getContentSize().height/2-6)
    self.respinSpNode = node

    bole:autoOpacityC(spb)
    spb:setOpacity(0)
    spb:runAction(cc.FadeIn:create(0.4))
end

function Theme_jones:spinRequest()
    print("Theme_jones:spinRequest")
    if self.reSpinCount > 0 then
        local function falseDataCallback()
            self:onDealWithRespinData(self.thisReceiveData)
            self:onReplaceTrueReels()
            self.spinView:execByTag("questNetData")
            self:onColumnStopCalm(1)
        end
        self:addWaitEvent("joneFalseDataCallback", 0.05, falseDataCallback)
    else
        if self.lastRespinFlag then
            self.lastRespinFlag = false
            self:onClearFixedSymbolLayer()
        end
        Theme_jones.super.spinRequest(self)
    end
end

function Theme_jones:removeAnimNode(isIncludeClipAnimNode)
    if self.reSpinCount > 0 then return end

    Theme_jones.super.removeAnimNode(self, isIncludeClipAnimNode)
end

function Theme_jones:resetToSpinView()
    Theme_jones.super.resetToSpinView(self)
    if self.reSpinCount > 0 then
        for row = 1, 3 do
            self:getSymbolNodeByPos(1, row):setVisible(false)
        end
    end
end

function Theme_jones:onSpinViewStart()
    if self.reSpinCount > 0 then
        Theme_jones.super.onSpinViewStart(self, self.respinStopedReels)
    else
        Theme_jones.super.onSpinViewStart(self)
    end
end

function Theme_jones:onDataFilter(data)
    print("Theme_jones:onDataFilter")
    Theme_jones.super.onDataFilter(self, data)

    self:onDealWithRespinData(data)
end

function Theme_jones:onDealWithRespinData(data)
    local recordRespinData = data["re_spin_item_lists"]
    if recordRespinData then
        self.respinStopedReels = {true}

        self.recordRespinData = recordRespinData
        data["re_spin_item_lists"] = nil

        self.recordWinLineData = data["win_lines"]
        data["win_lines"] = nil

        self.reSpinCount = data["re_spins"]
    elseif self.reSpinCount > 0 then
        self.stopReels = table.remove(self.recordRespinData, 1)
        self.reSpinCount = self.reSpinCount - 1
        if self.reSpinCount == 0 then
            data["win_lines"] = self.recordWinLineData
            self.recordWinLineData = nil
            self.recordRespinData = nil
            self.lastRespinFlag = true
        end
    end
end

function Theme_jones:genFalseReels()
    Theme_jones.super.genFalseReels(self)
    if self.wildColumn then
        local flag = false
        for i = 5, 6 do
            local stopReel = self.stopReels[i]
            for _, id in ipairs(stopReel) do
                if id ~= 2 then
                    flag = true
                    break
                end
            end
        end

        if flag then return end

        for i = 5, 6 do
            local displayColumn = self.displayReels[i]
            for k = 1, #displayColumn do
                displayColumn[k] = 2
            end

            local falseColumn = self.falseReels[i]
            for k = 1, #falseColumn do
                falseColumn[k] = 2
            end
        end
    end
end

function Theme_jones:onSpinPrompt(stopReels)
    if self.reSpinCount > 0 or self.lastRespinFlag then
        self.spinView:onStopWinBonusAction(1)
    else
        Theme_jones.super.onSpinPrompt(self, stopReels)
    end
end

function Theme_jones:onColumnStop(columnIndex, noJump)
    if self.reSpinCount > 0 or self.lastRespinFlag then
        if columnIndex == 1 and self.reSpinCount == 2 then
            bole:postEvent("audio_reel_stop")
        end
    else
        Theme_jones.super.onColumnStop(self, columnIndex, noJump)
    end
end

function Theme_jones:onColumnStopCalm(columnIndex)
    bole:getAudioManage():stopAudio("tishi_success")
    if columnIndex == 1 and self.reSpinCount == 2 then
        local key = "change"
        local zOrder = 20
        local skeletonNode = self:genSkeletonNodeByPos(1, 2, key)
        local animationName1 = skeletonNode[key]
        skeletonNode:setPosition(self:getSpinPositionByPos(1, 2, true))
        self:getAnimLayer():addChild(skeletonNode, zOrder)

        skeletonNode:registerSpineEventHandler(function(event)
            if event.animation == animationName1 then
                bole:getAudioManage():playEff("w8")

                for row = 1, 3 do
                    self:getSymbolNodeByPos(1, row):setVisible(false)
                end

                local lightNode = sp.SkeletonAnimation:create(self.app:getSymbolAnim(self.themeId, "fusion_light"))
                skeletonNode:addChild(lightNode, 1, 1)
                lightNode:setAnimation(0, "animation", true)

                self:creatRespinNumNode()
            end
        end, sp.EventType.ANIMATION_COMPLETE)

        skeletonNode:setAnimation(0, animationName1, false)
        bole:getAudioManage():playEff("w1")

        local projectName2, animationName2 = self:getAnimName(self.stopReels[1][2], "fusion")
        skeletonNode:addAnimation(0, animationName2, true)

        self.firstColumnNode = skeletonNode
        self.firstColumnAnimName = animationName2
    end

    if self.reSpinCount > 0 or self.lastRespinFlag then
        if self.reSpinCount > 0 then
            self:dealColumnChangeAnim(columnIndex)
        end

        self:getPromptNode():setVisible(false)

        local index = columnIndex + 1
        if self.respinStopedReels and index <= self.spinView:getColumnCount() and self.respinStopedReels[index] then
            self:onColumnStopCalm(index)
        else
            Theme_jones.super.onColumnStopCalm(self, columnIndex)
        end
    else
        Theme_jones.super.onColumnStopCalm(self, columnIndex)
    end
end

function Theme_jones:onPromptSuccess(event)
    local columnIndex = event.result
    print("Theme_jones:onPromptSuccess column=" .. columnIndex)
    local promptSuccessNode = self:getPromptNode()
    promptSuccessNode:setVisible(true)
    local skeletonNode = promptSuccessNode:getChildByTag(100)
    if not skeletonNode then
        skeletonNode = sp.SkeletonAnimation:create(self.app:getSymbolAnim(self.themeId, "respin"))
        promptSuccessNode:addChild(skeletonNode)
        skeletonNode:setTag(100)
    end

    local position = self:getBottomPosByColumn(columnIndex, true)
    skeletonNode:setPosition(position.x, position.y)
    local respinAnimName
    if columnIndex < 6 then
        respinAnimName = "respin" .. columnIndex
    else
        respinAnimName = "respin5"
    end
    skeletonNode:setAnimation(0, respinAnimName, true)

    bole:getAudioManage():playMusic("tishi_success")
end

function Theme_jones:dealColumnChangeAnim(columnIndex)
    print("Theme_jones:dealColumnChangeAnim columnIndex=" .. columnIndex)

    local function animEndFunc()
        self.reSpinReelStopCount = self.reSpinReelStopCount + 1
        self:onNextRespin()
    end

    if self.respinStopedReels[columnIndex] then
        animEndFunc()
        return
    end

    local haveChangeAnim = false
    local isAllChanged = true
    local column = self.stopReels[columnIndex]
    for row, id in ipairs(column) do
        if id == 2 or id == 3 then
            if not self:getFixedNode(columnIndex, row) then
                local resultRow = row
                local resultId = id

                local lightNode
                local function endCallback()
                    lightNode:removeFromParent(true)
                    self:onCreateFixedSymbol(columnIndex, resultRow, resultId)
                    if animEndFunc then
                        animEndFunc()
                        animEndFunc = nil
                    end
                end

                local skeletonNode = self:createAnimNode(columnIndex, resultRow, "bonus", false, true, true, endCallback)
                lightNode = sp.SkeletonAnimation:create(self.app:getSymbolAnim(self.themeId, "trigger_light"))
                skeletonNode:addChild(lightNode, 1, 1)
                lightNode:setAnimation(0, "animation", false)

                haveChangeAnim = true
            end
        else
            isAllChanged = false
        end
    end

    if not haveChangeAnim then
        animEndFunc()
    elseif isAllChanged then
        self.respinStopedReels[columnIndex] = true
    end
end

function Theme_jones:onNextRespin()
    print("Theme_jones:onNextRespin")
    if self.reSpinReelStopCount < self.spinView:getColumnCount() then return end

    if not self.canStartNextRespin then
        local function canStartNextRespin()
            self.canStartNextRespin = true
            self:onNextRespin()
        end
        self:addWaitEvent("joneCanStartNextRespin2", 0.5, canStartNextRespin)
        return
    end

    self.reSpinReelStopCount = 0
    self.canStartNextRespin = false

    local count = self.reSpinCount
    local function changeNum()
        self.respinSp:setTexture(self.app:getRes(self.themeId, string.format("respin/0%s.png", count)))
    end
    self.respinSp:runAction(cc.Sequence:create(cc.DelayTime:create(0.5), cc.CallFunc:create(changeNum)))
    self.respinSpNode:setAnimation(0, "animation", false)

    self:startSpinRequest()
end

function Theme_jones:onStartRespin(data)
    print("Theme_jones:onStartRespin")
    if self.lastRespinFlag then
        self.respinStopedReels = nil

        local spPaNode = self.respinSp:getParent()
        local function callEnd()
            spPaNode:removeFromParent(true)
            self.respinSp = nil
        end
        spPaNode:runAction(cc.Sequence:create(cc.DelayTime:create(0.6), cc.CallFunc:create(callEnd)))

        self.firstColumnNode:removeChildByTag(1, true)
        self.firstColumnNode:setAnimation(0, self.firstColumnAnimName, false)

        local winLines = self.thisReceiveData["win_lines"]
        for k, line in ipairs(winLines) do
            if line.feature > 0 then
                table.remove(winLines, k)
                break
            end
        end
    end

    if self.reSpinCount == 0 then
        if self.lastRespinFlag then
            local function waitOnNextPopup()
                self:onNextPopup()
            end
            self:addWaitEvent("joneWaitOnNextPopup", 0.5, waitOnNextPopup)
        else
            self:onNextPopup()
        end
    else
        local function canStartNextRespin()
            self.canStartNextRespin = true
        end
        self:addWaitEvent("joneCanStartNextRespin", 0.5, canStartNextRespin)
    end
end

function Theme_jones:onMiniEffect(data)
    print("Theme_jones:onMiniEffect")
    Theme_jones.super.onMiniEffect(self, data)

    if self.lastRespinFlag then
        if self.isHaveWinLines then
            for row = 1, 3 do
                local animNode = self:getAnimNodeByPos(1, row)
                if animNode then
                    animNode:setVisible(false)
                end
            end
            self.firstColumnNode:setAnimation(0, self.firstColumnAnimName, true)
        else
            self.firstColumnNode:removeFromParent(true)
            for row = 1, 3 do
                self:getSymbolNodeByPos(1, row):setVisible(true)
            end
        end
    end
end

function Theme_jones:onDealWithMiniGameData(data)
    print("Theme_jones:onDealWithMiniGameData")
    if data and data.freeSpin then
        self.freeSpinCount = data.freeSpin
        self.freeSpinTotal = data.freeSpin
        self.wildColumn = data.wild
    end
end

function Theme_jones:onNextPopup()
    self.curStepName = "reSpinOver"
    self:onNext()
end

function Theme_jones:onStopFreeSpin(event)
    self.wildColumn = false
    Theme_jones.super.onStopFreeSpin(self, event)
end

function Theme_jones:addListeners()
    Theme_jones.super.addListeners(self)
    self:addListenerForNext("reelStoped", self.onStartRespin)
    self:addListenerForNext("reSpinOver", self.onPopupDialog)
end

function Theme_jones:addOtherAsyncImage(weights)
    table.insert(weights, self.app:getSymbolAnimImg(self.themeId, "respin"))
    for i = 1, 4 do
        table.insert(weights, self.app:getRes(self.themeId, "respin/0" .. i, "png"))
    end
    table.insert(weights, self.app:getRes(self.themeId, "jones_freespins", "png"))
    table.insert(weights, self.app:getSymbolAnimImg(self.themeId, "jones_shiban"))
    table.insert(weights, self.app:getSymbolAnimImg(self.themeId, "fusion_light"))
    table.insert(weights, self.app:getSymbolAnimImg(self.themeId, "trigger_light"))
end

return Theme_jones

--endregion