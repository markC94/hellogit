-- region *.lua
-- Date
-- 此文件由[BabeLua]插件自动生成

local THEME_CHILD_ORDER =
{
    BG = 10,
    IPADEXTRA = 13,
    SPIN = 20,
    FREESPIN = 25,
    COLLECT = 30,
    BOTTOM = 40,
    TOP = 60,
    ROOMMATE = 61,
    MINIGAME = 65,
    CHATHINT = bole.ZORDER_UI,
    CHAT = bole.ZORDER_UI,
    PAYTABLE = bole.ZORDER_UI,
    DIALOG = bole.ZORDER_TOP,
    OPTIONS = bole.ZORDER_TOP
--    BG = bole.ZORDER_BG,
--    IPADEXTRA = bole.ZORDER_UI,
--    SPIN = bole.ZORDER_UI,
--    FREESPIN = bole.ZORDER_UI,
--    COLLECT = bole.ZORDER_UI,
--    BOTTOM = bole.ZORDER_UI,
--    TOP = bole.ZORDER_UI,
--    ROOMMATE = bole.ZORDER_UI,
--    MINIGAME = bole.ZORDER_UI,
--    CHATHINT = bole.ZORDER_UI,
--    CHAT = bole.ZORDER_UI,
--    PAYTABLE = bole.ZORDER_UI,
--    DIALOG = bole.ZORDER_TOP,
--    OPTIONS = bole.ZORDER_TOP
}

local FRAME_CHILD_ORDER = 
{
    SPIN = 10,
    ANIMNODE = 20
}

cc.exports.THEME_CHILD_ORDER = THEME_CHILD_ORDER

local BaseTheme = class("BaseTheme", cc.Scene)
function BaseTheme:ctor(themeId, app)
    self.themeId = themeId
    self.app = app

    self.isAlive = true
    self:enableNodeEvents()
    bole:getBoleEventKey():addKeyBack(self)

    self:onCheckThemeFiles()
end

function BaseTheme:createDownloadView()
    local downloadView = bole:getEntity("app.views.spin.ThemeDownloadView", self, self.onCreateLoadingView)
    self:addChild(downloadView, THEME_CHILD_ORDER.DIALOG)
end

function BaseTheme:onCreateLoadingView(themeData)
    local loadingView = bole:getEntity("app.views.spin.ThemeLoadingView", self, themeData)
    self:addChild(loadingView, THEME_CHILD_ORDER.DIALOG)
end

function BaseTheme:onCheckThemeFiles()
    local isUpdate = self.app:isThemeUpdated(self.themeId)
    if isUpdate then
        self:onCreateLoadingView()
    else
        self:createDownloadView()
    end
end

function BaseTheme:displayTheme(data)
    self.isAlive = false
    self:onEnter()

    self:initData(data)
    self:changeMatrix(101)
    self:genFalseReels()
    self:createChatCache()
    self:onCreateViews()
    self:addListeners()
    bole:getUIManage():addSpinEFF(self.themeId)
    bole:getAudioManage():initThemeAudio(self.themeId)
    bole:getMiniGameControl():initTheme(self.themeId)
    self:setUpdate()
    self:onFirstEnter(data)

    self.isThemeDisplay = true
end

function BaseTheme:setUpdate()
    local function update(dt)
        if not self.waitEvents then return end
        if self.isPopupViewing then return end

        for name, event in pairs(self.waitEvents) do
            if not event.isDone then
                event.elapsed = event.elapsed + dt
                if event.duration <= event.elapsed then
                    event.isDone = true
                    event.func()
                end
            end
        end

        local isEmpty = true
        for name, event in pairs(self.waitEvents) do
            if event.isDone then
                self.waitEvents[name] = nil
            else
                isEmpty = false
            end
        end

        if isEmpty then
            self.waitEvents = nil
        end
    end
    self:onUpdate(update)
end

function BaseTheme:setCachedRes(asynRes)
    self.asyncImageWeights = asynRes
end

function BaseTheme:removeCachedRes()
    cc.SpriteFrameCache:getInstance():removeSpriteFrameByName(self.app:getRes(self.themeId, "symbols.plist"))
    for _, key in ipairs(self.asyncImageWeights) do
        cc.Director:getInstance():getTextureCache():removeTextureForKey(key)
    end
    cc.Director:getInstance():getTextureCache():removeUnusedTextures()
end

function BaseTheme:addOtherAsyncImage(weights)
end

function BaseTheme:removeWaitEventByName(name)
    if self.waitEvents then
        self.waitEvents[name] = nil
    end
end

function BaseTheme:addWaitEvent(name, duration, func)
    local event = {duration = duration, func = func, elapsed = 0}
    if not self.waitEvents then self.waitEvents = {} end
    self.waitEvents[name] = event
end

function BaseTheme:onCreateTop(order)
    bole:getEntity("app.views.spin.TopView", self, order)
end

function BaseTheme:onCreateCommonBottom()
    if self.bottom then
        self.bottom:removeFromParent(true)
    end
    self.bottom = bole:getEntity("app.views.spin.BottomView", self, THEME_CHILD_ORDER.TOP, self.autoSpinning)
end

function BaseTheme:onCreateFreeSpinBottom()
    self.bottom:removeFromParent(true)
    self.bottom = bole:getEntity("app.views.spin.FreeSpinBottomView", self, THEME_CHILD_ORDER.TOP, self.freeSpinCount, self.freeSpinTotal, self.freeSpinCoins)
end

function BaseTheme:onCreateSpinView()
    self.spinView = bole:getEntity("app.views.spin.SpinView", self)
    self.spinViewNode:addChild(self.spinView)
end

function BaseTheme:onCreateRoommateView(order)
    bole:getEntity("app.views.spin.RoommateView", self, self.roomInfo, order)
end

function BaseTheme:setIPADLRFrame(leftSp, rightSp, lPos, rPos)
    leftSp:setPosition(lPos.x, lPos.y)
    rightSp:setPosition(rPos.x, rPos.y)
end

function BaseTheme:onCreatePayTableView()
    local payTableView = bole:getEntity("app.views.spin.PayTableView", self.themeId)
    self:addChild(payTableView, THEME_CHILD_ORDER.PAYTABLE, THEME_CHILD_ORDER.PAYTABLE)
end

function BaseTheme:updateFrameTexture()
    self.framBg:setTexture(self.app:getRes(self.themeId, self.matrix.matrix_image, "png"))
end

function BaseTheme:setSpinBgPosition(node)
end

function BaseTheme:onCreateViews()
    --大背景
    self.back_image = cc.Sprite:create(self.app:getRes(self.themeId, self.matrix.back_image, "png"))
    self:addChild(self.back_image, THEME_CHILD_ORDER.BG, THEME_CHILD_ORDER.BG)
    self.back_image:setPosition(display.cx, display.cy)
    --棋盘的背景
    local spinBg = cc.Sprite:create(self.app:getRes(self.themeId, self.matrix.matrix_image, "png"))
    self:addChild(spinBg, THEME_CHILD_ORDER.SPIN, THEME_CHILD_ORDER.SPIN)
--    local framePos = self.matrix.matrix_start
    local screenSize = cc.Director:getInstance():getWinSize()
    local frameSize = spinBg:getContentSize()
    local framePos = cc.p(screenSize.width/2, screenSize.height/2)
--    local height = framePos[2]/CC_DESIGN_RESOLUTION.height * frameSize.height
    spinBg:setPosition(framePos.x, framePos.y)--height+spinBg:getContentSize().height/2)
    self:setSpinBgPosition(spinBg)
    self.framBg = spinBg

    if bole.isPadScreen then
        local leftSp = cc.Sprite:create(self.app:getRes(self.themeId, "frame_left.png"))
        self:addChild(leftSp, THEME_CHILD_ORDER.IPADEXTRA, THEME_CHILD_ORDER.IPADEXTRA)
        leftSp:setAnchorPoint(cc.p(1, 0.5))
--        leftSp:setPosition(framePos.x - frameSize.width/2 + 13, framePos.y + 30)
        local lPos = {x = framePos.x - frameSize.width/2 + 13, y = framePos.y + 30}

        local rightSp = cc.Sprite:create(self.app:getRes(self.themeId, "frame_right.png"))
        self:addChild(rightSp, THEME_CHILD_ORDER.IPADEXTRA, THEME_CHILD_ORDER.IPADEXTRA)
        rightSp:setAnchorPoint(cc.p(0, 0.5))
--        rightSp:setPosition(framePos.x + frameSize.width/2 - 13, framePos.y + 30)
        local rPos = {x = framePos.x + frameSize.width/2 - 13, y = framePos.y + 30}

        self:setIPADLRFrame(leftSp, rightSp, lPos, rPos)
    end

    --遮挡的shader
    local shadeBg = cc.Sprite:create(self.app:getRes(self.themeId, "masking", "png"))
    shadeBg:setAnchorPoint(cc.p(0, 0))
    local stencil = cc.Node:create()
    stencil:addChild(shadeBg)
    local clippingNode = cc.ClippingNode:create(stencil)
    local clipPos = self.matrix.shelter
    clippingNode:setPosition(clipPos[1], clipPos[2])
    spinBg:addChild(clippingNode, FRAME_CHILD_ORDER.SPIN, FRAME_CHILD_ORDER.SPIN)
    clippingNode:setAlphaThreshold(0.9)
    self.spinViewNode = clippingNode

    self:createOtherNodes(spinBg, FRAME_CHILD_ORDER)
    self:createAnimLayer(spinBg, FRAME_CHILD_ORDER.ANIMNODE, clipPos)

    self:onCreateTop(THEME_CHILD_ORDER.TOP)
    self:onCreateCommonBottom()
    self:onCreateSpinView()
    self:onCreateRoommateView(THEME_CHILD_ORDER.ROOMMATE)
end

function BaseTheme:createOtherNodes(spinBg, orderTable)
end

function BaseTheme:createAnimLayer(parentNode, order, pos)
    local animNode = cc.Node:create()
    parentNode:addChild(animNode, order)
    animNode:setPosition(pos[1], pos[2])
    self.animNode = animNode
end

function BaseTheme:onRemoveFixedSymbol(column, row)
    local key = string.format("%d_%d", column, row)
    local sp = self.fixedSymbol[key]
    if sp then
        sp:removeFromParent(true)
        self.fixedSymbol[key] = nil
        return true
    end
    return false
end

function BaseTheme:onCreateFixedSymbol(column, row, id)
    print(string.format("BaseTheme:onCreateFixedSymbol column=%d, row=%d, id=%s", column, row, id))
    local sp = display.newSprite("#" .. self:getFrameNameById(id))
    local symbolSp = self:getSymbolNodeByPos(column, row)
    sp:setPosition(symbolSp:getPosition())
    self.animNode:addChild(sp, 50+row)

    local key = string.format("%d_%d", column, row)
    sp:setName("fixed_" .. key)
    self.fixedSymbol[key] = sp
end

function BaseTheme:getFixedNode(column, row)
    return self.fixedSymbol[string.format("%d_%d", column, row)]
end

function BaseTheme:onClearFixedSymbolLayer()
    if table.empty(self.fixedSymbol) then return end

    for _, node in pairs(self.fixedSymbol) do
        node:removeFromParent(true)
    end
    self.fixedSymbol = {}
end

function BaseTheme:getAnimLayer(isClipping)
    if isClipping then
        return self.spinView:getClippingAnimNode()
    else
        return self.animNode
    end
end

function BaseTheme:getPromptNode()
    return self.spinView.promptSuccessNode
end

function BaseTheme:createAnimNode(column, row, key, loop, isHideSymRunning, isHideAnimEnd, endCallback)
    local symbolId = self.stopReels[column][row]
    print("createAnimNode id=" .. symbolId .. ",column=" .. column .. ",row=" .. row .. ",key=" .. key)
    local indexKey, animationName, isCut = self:getAnimName(symbolId, key)
    local symbolSp = self:getSymbolNodeByPos(column, row)
    local symbolNum = self:getSymbolNumById(symbolId)
    local node
    local nodeList = self.cacheAnimNodes[indexKey]
    if not nodeList then
        nodeList = {}
        self.cacheAnimNodes[indexKey] = nodeList
    else
        for _, item in ipairs(nodeList) do
            local flag = false
            if not item:isVisible() or (item.column == column and item.row == row) then
                flag = true
            elseif symbolNum > 1 and item.column == column and math.abs(item:getPositionX() - symbolSp:getPositionX()) < 1 then
                flag = true
            end

            if flag then
                node = item
                print("find AnimNode in cacheAnimNodes")
                break
            end
        end
    end

    local parentNode = self:getAnimLayer(isCut == 0)
    if not node then
        node = self:genSkeletonNodeById(symbolId, key)
        parentNode:addChild(node)
        table.insert(nodeList, node)
    else
        local oldParentNode = node:getParent()
        if oldParentNode ~= parentNode then
            node:retain()
            node:removeFromParent()
            parentNode:addChild(node)
            node:release()
        end
        node:setVisible(true)
        node:clearTracks()
        node:setToSetupPose()
    end

    node:setPosition(symbolSp:getPosition())
    node:setAnimation(0, animationName, loop)
    local fixedNode = self:getFixedNode(column, row)
    if not fixedNode then
        node:setLocalZOrder(row)
    else
        node:setLocalZOrder(fixedNode:getLocalZOrder()+10)
    end

    if isHideSymRunning and symbolSp then
        symbolSp:setVisible(false)
    end
    
    node:registerSpineEventHandler(function(event)
        if event.animation == animationName then
            if isHideAnimEnd then
                node:setVisible(false)
                if symbolSp then
                    symbolSp:setVisible(true)
                end
            end

            if endCallback then
                endCallback(node, symbolSp)
            end
        end
    end, sp.EventType.ANIMATION_COMPLETE)

    node.column = column
    node.row = row

    return node, symbolSp
end

function BaseTheme:removeAnimNode(isIncludeClipAnimNode)
    if table.empty(self.fixedSymbol) then
        self.animNode:removeAllChildren(true)
    else
        local children = self.animNode:getChildren()
        for _, node in ipairs(children) do
            local name = node:getName()
            if not string.find(name, "fixed_") then
                node:removeFromParent(true)
            end
        end
    end

    self.cacheAnimNodes = {}
    
    if isIncludeClipAnimNode then
        self:getAnimLayer(true):removeAllChildren(true)
    end
    self.spinView:removeCacheNodes()
end

function BaseTheme:setSymbolsVisible(flag)
    self.spinView:setAllSymbolVisible(flag)
end

function BaseTheme:getSpinPositionByPos(column, row, isCenter)
    local matrix = self.matrix
    local bottomPos = matrix.coordinate[column]
    local disY = (matrix.array[column] - row) * matrix.cell_size[2]

    local position = cc.p(bottomPos.x, bottomPos.y + disY)
    if isCenter then
        position.y = position.y + matrix.cell_size[2] / 2
    end
    return position
end

function BaseTheme:getSpinCost()
    return self:getCurBetValue()*self.spinEachLineCost
end

function BaseTheme:getEachLineBet()
    return self.spinEachLineCost
end

function BaseTheme:initBetTable()
    self.spinEachLineCost = bole:getConfig("theme", self.themeId, "spin_need")
    local betFile = self.app:getConfig(self.themeId, "bet")
    local i = 1
    local betValue = {}
    while (true) do
        local item = betFile[tostring(i)]
        if not item then
            break
        end
        table.insert(betValue, item) --.bet_count)
        i = i + 1
    end
    self.betValueTable = betValue
end

function BaseTheme:getBetSoundById(id)
    return self.betValueTable[id].bet_sound
end

function BaseTheme:getBetValueById(id)
    return self.betValueTable[id].bet_count
end

function BaseTheme:getBetIdByValue(betValue)
    local betId = 1
    for k = #self.betValueTable, 1, -1 do
        if self.betValueTable[k].bet_count <= betValue then
            betId = k
            break
        end
    end
    return betId
end

function BaseTheme:getMaxBetId()
    local level = bole:getUserData():getDataByKey("level")
    local maxBetValue = bole:getConfigCenter():getConfig("level", level, "max_bet")
    local betId = self:getBetIdByValue(maxBetValue)
    return betId
end

function BaseTheme:adjustBetValue(betValue)
    local betId = self:getBetIdByValue(betValue)
    local maxBetId = self:getMaxBetId()
    if betId > maxBetId then
        betId = maxBetId
    end
    self.betId = betId
    print("BaseTheme:adjustBetValue betId=" .. self.betId)
end

function BaseTheme:playBetSoundById(betId)
    local str_sound = self:getBetSoundById(betId)
    if str_sound then
        bole:getAudioManage():playEff(str_sound)
    end
end

function BaseTheme:changedBetValue()
    local maxBetId = self:getMaxBetId()
    if self.betId == maxBetId then
        bole:getAudioManage():playMaxBet()
    else
        self:playBetSoundById(self.betId)
    end
end

function BaseTheme:addBet()
    if self.betId < self:getMaxBetId() then
        self.betId = self.betId + 1
        self:changedBetValue()
        return true
    end
end

function BaseTheme:subBet()
    if self.betId > 1 then
        self.betId = self.betId - 1
        self:changedBetValue()
        return true
    end
end

function BaseTheme:setMaxBetValue()
    if self.betId < self:getMaxBetId() then
        self.betId = self:getMaxBetId()
        self:changedBetValue()
        return true
    end
end

function BaseTheme:getCurBetValue()
    return self:getBetValueById(self.betId)
end

function BaseTheme:initData(data)
    self:initBetTable()
    self.lastReceiveData = nil
    self.spinForNewbieCnt = 0
    self.thisReceiveData = nil
    self.isFreeSpining = false
    self.freeSpinCount = 0
    self.winTime = 0
    self.spinError = false
    self.curStepName = nil
    self.winBonusReels = {}
    self.insertBonusReels = {}
    self.cacheAnimNodes = {}
    self.fixedSymbol = {}
    self:genSymbolSizeSet()
    self:enterThemeDataFilter(data)
end

function BaseTheme:onKeyBack()
   --self.isThemeDisplay 老虎机过程 需要屏蔽返回键时使用 别忘还原状态
   if self.isThemeDisplay then
       local view = bole:getUIManage():createNewUI("Options","options","app.views",nil,false)
       view:setDialog(true)
       self:addOptions(view)
   end
end

function BaseTheme:onEnterChild()
end

function BaseTheme:onEnter()
    if self.isAlive then return end
    print("BaseTheme:onEnter")
    self.isAlive = true
    bole:getBoleEventKey():addKeyBack(self)

    cc.SpriteFrameCache:getInstance():addSpriteFrames(self.app:getRes(self.themeId, "symbols.plist"))

    self:onEnterChild()

    bole:addListener("spin", self.onSpin, self, nil, true)
    bole:addListener("reelStoped", self.onReelStoped, self, nil, true)
    bole:addListener("clickSpin", self.onClickSpin, self, nil, true)
    bole:addListener("clickStop", self.onClickStop, self, nil, true)
    bole:addListener("next", self.onNext, self, nil, true)
    bole:addListener("winLineEnd", self.onWinLineEnd, self, nil, true)
    bole:addListener("miniEffectEnd", self.onMiniEffectEnd, self, nil, true)
    bole:addListener("remainMiniResult", self.onFirstEnterCheck, self, nil, true)
    bole:addListener("showPayTable", self.onCreatePayTableView, self, nil, true)
    bole:addListener("startFreeSpin", self.onStartFreeSpin, self, nil, true)
    bole:addListener("stopFreeSpin", self.onStopFreeSpin, self, nil, true)
    bole:addListener("free_spin_stop", self.onFreeSpinOver, self, nil, true)
    bole:addListener("promptSuccess", self.onPromptSuccess, self, nil, true)
    bole:addListener("enterPopupView", self.onEnterPopupView, self, nil, true)
    bole:addListener("exitPopupView", self.onExitPopupView, self, nil, true)
    bole:addListener("bottomViewStopAuto", self.onStopAutoSpinning, self, nil, true)
    bole:addListener("miniEndPopup", self.onMiniEndPopup, self, nil, true)
    bole:addListener("closeOutOfCoinsLayer", self.closeOutOfCoinsLayer, self, nil, true)

    bole.socket:registerCmd("batch_spin", self.spinResponse, self)
end

function BaseTheme:onExit()
    print("BaseTheme:onExit")
    bole:openAndroidUtil(2)

    bole:getBoleEventKey():removeKeyBack(self)
    bole:removeListener("spin", self)
    bole:removeListener("reelStoped", self)
    bole:removeListener("clickSpin", self)
    bole:removeListener("clickStop", self)
    bole:removeListener("next", self)
    bole:removeListener("winLineEnd", self)
    bole:removeListener("miniEffectEnd", self)
    bole:removeListener("remainMiniResult", self)
    bole:removeListener("showPayTable", self)
    bole:removeListener("startFreeSpin", self)
    bole:removeListener("stopFreeSpin", self)
    bole:removeListener("free_spin_stop", self)
    bole:removeListener("promptSuccess", self)
    bole:removeListener("enterPopupView", self)
    bole:removeListener("exitPopupView", self)
    bole:removeListener("bottomViewStopAuto", self)
    bole:removeListener("miniEndPopup", self)
    bole:removeListener("closeOutOfCoinsLayer", self)

    bole.socket:unregisterCmd("batch_spin")

    self:removeChatCache()
    self:removeCachedRes()
    self.isAlive = false
end

function BaseTheme:onFirstEnter(data)
    print("BaseTheme:onFirstEnter")
    bole:postEvent("remainMini", data)
end

function BaseTheme:onSpin(event)
    print("BaseTheme:onSpin")

    self.clickStopManual = false
    self.hadReplaceTrueReels = false
    self.hadStopEnabled = false

    self:removeWaitEventByName("freeSpinNoWinWait")
    self:removeWaitEventByName("startCalTimeForBackLobbyReady")
    self:removeWaitEventByName("startCalTimeForBackLobby")
    self:removeWaitEventByName("popupViewForWaitNext")
    self.spinError = false
    self.curStepName = nil

    self:resetToSpinView()
    self:onSpinViewStart()

    bole:postEvent("audio_play_spin",{self.isFreeSpining,self.autoSpinning})
    self:spinRequest()
end

function BaseTheme:resetToSpinView()
    self:getPromptNode():setVisible(false)
    self:removeAnimNode(true)
    self:setSymbolsVisible(true)
end

function BaseTheme:onEnterPopupView()
    self.isPopupViewing = true
end

function BaseTheme:onExitPopupView()
    self.isPopupViewing = false
end

function BaseTheme:onSpinViewStart(ignoreTable)
    self.spinView:spin(ignoreTable)
end

function BaseTheme:onResponse(data)
    dump(data, "batch_spin", nil, {win_lines = true})
    self.lastReceiveData = self.thisReceiveData
    self.thisReceiveData = data
    bole:getAppManage():updateUser(data)
end

function BaseTheme:onStopEnabled()
    if self.hadReplaceTrueReels then
        bole:postEvent("spinStatus", "stopEnabled")
    end
    self.hadStopEnabled = true
end

function BaseTheme:onReplaceTrueReels()
    print("BaseTheme:onReplaceTrueReels")
    self:genFalseReels()
    self.spinView:setTrueReels(self.displayReels, self.falseReels)
    self:onSpinPrompt(self.stopReels)
    self.hadReplaceTrueReels = true
    if self.hadStopEnabled then
        self:onStopEnabled()
    end
end

function BaseTheme:onSpinPrompt(stopReels)
    local bonusWinReels = self:getBonusWin()
    if not bonusWinReels then return end

    self.promptSuccessId = nil
    self.promptBonusSound = {}
    self.promptBonusPos = {}

    local minWinColumnIndex = #stopReels
    local maxWinColumnIndex
    local columnCount = minWinColumnIndex
    for _, reelItem in ipairs(bonusWinReels) do
        local totalNum = 0
        local isCutWinBouns = reelItem.interrupt_trigger == 1
        local isHavePromptSucAnim = reelItem.prompt_resource
        local soundCountIndex = 0
        local prompt_sound = reelItem.prompt_sound
        for columnIndex, column in ipairs(stopReels) do
            local checkBonusPos = {}
            local bonusSound
            local thisTotal = 0
            local columnMaxNum = reelItem.reel_max[columnIndex]
            if columnMaxNum > 0 then
                local arrayIn = reelItem.reels[columnIndex]
                local remainLen = 0
                local lastTag = -100
                for row, tag in ipairs(column) do
                    local symbolNum = self:getSymbolNumById(tag)
                    local bonusFlag = true
                    if symbolNum > 1 then
                        if tag == lastTag and remainLen > 0 then
                            remainLen = remainLen - 1
                            bonusFlag = false
                        else
                            remainLen = symbolNum - 1
                        end
                    else
                        remainLen = 0
                    end

                    if bonusFlag and arrayIn[tag] then
                        thisTotal = thisTotal + 1
                        checkBonusPos[row] = true
                        if thisTotal == columnMaxNum then
                            break
                        end
                    end
                    lastTag = tag
                end

                if thisTotal > 0 then
                    totalNum = totalNum + thisTotal
                    if soundCountIndex + 1 < #prompt_sound then
                        soundCountIndex = soundCountIndex + 1
                    end
                    bonusSound = prompt_sound[soundCountIndex]
                elseif isCutWinBouns then
                    break
                end
            end

            local remainMaxTotal = 0
            for k = columnIndex+1, #stopReels do
                remainMaxTotal = reelItem.reel_max[k] + remainMaxTotal
            end
            if remainMaxTotal + totalNum < reelItem.prompt_near_win then  --如果后面的总数都不够，就不再出提示动画
                break
            elseif thisTotal > 0 then
                local insertItem = self.promptBonusPos[columnIndex]
                if insertItem then
                    for k, v in pairs(checkBonusPos) do
                        insertItem[k] = v
                    end
                else
                    self.promptBonusPos[columnIndex] = checkBonusPos
                end

                if bonusSound then
                    self.promptBonusSound[columnIndex] = bonusSound
                end
            end

            if isHavePromptSucAnim and not self.autoSpinning and not self.isFreeSpining and columnIndex < columnCount and totalNum + reelItem.reel_max[columnIndex+1] >= reelItem.prompt_near_win then
                if minWinColumnIndex > columnIndex then
                    minWinColumnIndex = columnIndex
                    self.promptSuccessId = reelItem.prompt_id
                end

                if not maxWinColumnIndex or maxWinColumnIndex < columnIndex + 1 then
                    maxWinColumnIndex = columnIndex + 1
                end
            end
        end
    end
    self.spinView:onStopWinBonusAction(minWinColumnIndex, maxWinColumnIndex)
end

function BaseTheme:onColumnStop(columnIndex, noJump)
    if self.clickStopManual then
        local flag = false
        local maxColumnIndex = self.spinView:getColumnCount()
        if self.promptBonusSound then
            for k = 1, maxColumnIndex do
                if self.promptBonusSound[k] then
                    if flag then
                        self.promptBonusSound[k] = nil
                    else
                        flag = true
                    end
                end
            end
        end

        if not flag and columnIndex == maxColumnIndex then
            bole:postEvent("audio_reel_stop")
        end
    else
        if not noJump and (not self.promptBonusSound or not self.promptBonusSound[columnIndex]) then
            bole:postEvent("audio_reel_stop")
        end
    end

    if self.promptBonusPos then
        local promptSuccessNode = self:getPromptNode()
        if promptSuccessNode:isVisible() then
            promptSuccessNode:setVisible(false)
        end

        local promptPos = self.promptBonusPos[columnIndex]
        if promptPos then
            for row, _ in pairs(promptPos) do
                local node, sp = self:createAnimNode(columnIndex, row, "prompt", false, true)
                self.spinView:addMoveNode(node, sp, columnIndex)
            end
        end
    end

    if self.promptBonusSound then
        local audioValue = self.promptBonusSound[columnIndex]
        if audioValue then
            bole:postEvent("audio_prompt", audioValue)
            if not self.clickStopManual then
                self.promptBonusSound[columnIndex] = nil
            end
        end
    end
end

function BaseTheme:onColumnStopCalm(columnIndex)
    if not self.clickStopManual and self:getBonusWin() then
        self.spinView:onTriggerColumnPrompt(columnIndex)
    end
end

--滚轮停止，正式开始每个周期单独自己的处理逻辑
function BaseTheme:onReelStoped(event)
    print("BaseTheme:onReelStoped")
    if self.spinError then
        bole:postEvent("spinStatus", "spinEnabled")
        return
    end

    bole:postEvent("spinStatus", "stopDisabled")
    bole:postEvent("audio_stop_spin", self.freeSpinCount)

    self.curStepName = "reelStoped"
    self:onNext(event)
end

--5连的弹窗
function BaseTheme:onPopupDialog(data)
    print("BaseTheme:onPopupDialog")
    local eventName = "popupDialog"
    self.curStepName = eventName
    self.thisReceiveData.isFreeSpining = self.isFreeSpining

    local data = self.thisReceiveData
    if data["big_win"] == 1 or data["mega_win"] == 1 or data["crazy_win"] == 1 then
        self.bigWinPoped = true
    else
        self.bigWinPoped = false
    end
    bole:postEvent(eventName, self.thisReceiveData)
end

function BaseTheme:onNext(event)
    print("BaseTheme:onNext")
    if self.isPopupViewing then
        local function popupViewForWaitNext()
            self:onNext(event)
        end
        self:addWaitEvent("popupViewForWaitNext", 0.1, popupViewForWaitNext)
        return
    end

    local func = self.eventListenerForNext[self.curStepName]
    if func then
        local data = event
        if event and type(event) == "table" and event.func then
            data = event.result
        end
        func(self, data)
    end
end

--include freespin minigame
function BaseTheme:checkMiniGameData()
    local isHaveMiniGame = false
    local isHaveWinLines = false
    local winLines = self.thisReceiveData["win_lines"]
    for _, line in ipairs(winLines) do
        if line.feature > 0 then
            isHaveMiniGame = true
            if isHaveWinLines then
                break
            end
        else
            isHaveWinLines = true
        end
    end
    self.isHaveMiniGame = isHaveMiniGame
    self.isHaveWinLines = isHaveWinLines

    local amount = self.thisReceiveData["win_amount"]
    if amount > 0 then
        local times = amount/self:getSpinCost()
        local bet = 1
        if times <= 1 then
            bet = 1
        elseif times <= 3 then
            bet = 2
        elseif times <= 6 then
            bet = 3
        else
            bet = 4
        end
        self.winTime = self.matrix.win_time[bet]
    else
        self.winTime = 0
    end
end

function BaseTheme:onMiniEffect(data)
    print("BaseTheme:onMiniEffect")
    
    self:checkMiniGameData()

    if self.isHaveMiniGame or self.isHaveWinLines then
        local eventName = "miniEffect"
        self.curStepName = eventName
        bole:postEvent(eventName, {self.thisReceiveData["win_lines"], self.isFreeSpining or self.autoSpinning})
    end

    local runTime = self.winTime
    if runTime < 0.5 then
        runTime = 0.5
    end
    bole:postEvent("winAmount", {self.thisReceiveData["win_amount"], runTime})

    self:showFiveKind()

    if not self.isHaveMiniGame then
        self:onMiniEffectEnd()
    else
        bole:getAudioManage():playFeature(self.thisReceiveData)
    end

    bole:getAudioManage():tryPlayWin()
end

function BaseTheme:showFiveKind()
    if not self.bigWinPoped and not self.closeFiveKind then
        bole:getUIManage():showFiveKing(self.thisReceiveData["xofakind"])
    end
end

function BaseTheme:onMiniEffectEnd(event)
    print("BaseTheme:onMiniEffectEnd")
    self.curStepName = "miniEffectEnd"
    self:onNext(event)
end

function BaseTheme:onMiniGame()
    print("BaseTheme:onMiniGame")
    local eventName = "miniGame"
    self.curStepName = eventName
    self.thisReceiveData.autoSpinning = self.autoSpinning
    bole:postEvent(eventName, self.thisReceiveData)
end

function BaseTheme:onMiniEndPopup()
    print("BaseTheme:onMiniEndPopup")
    self:resetToSpinView()
end

function BaseTheme:onMiniGameBack(data)
    print("BaseTheme:onMiniGameBack")

    self:onDealWithMiniGameData(data)
    if data and data.isDeal then
        self.winTime = 1
        self:putCoinToTopWin(bole:getUserDataByKey("coins"))
    end
    self:onCheckStartFreeSpin()

    self.curStepName = "miniGameBack"
    self:onNext()
end

function BaseTheme:onStopAutoSpinning(event)
    self.autoSpinning = false
end

--function BaseTheme:onDrawLine(data)
--    print("BaseTheme:onDrawLine")

--    bole:postEvent("audio_win", {win_lines = self.thisReceiveData["win_lines"], themeId = self.themeId})

--    if not isFreeSpinStop then        
--        --新手引导
--        self.spinForNewbieCnt = self.spinForNewbieCnt + 1
--        if self.spinForNewbieCnt == 3 then
--            bole:postEvent("checkNewbieStep", "afterSpinNum")
--        end
--    end
--end

function BaseTheme:onCheckStartFreeSpin()
    if not self.isFreeSpining and self.freeSpinCount > 0 then
        self.isFreeSpining = true
        self.winTime = 1
        bole:postEvent("startFreeSpin", self.freeSpinCount)
    end
end

function BaseTheme:onDealWithMiniGameData(data)
end

function BaseTheme:waitNextFreeSpin(time)
    local function waitSpin()
        bole:postEvent("spin", {autoSpin = self.autoSpinning})
    end
    self:addWaitEvent("freeSpinNoWinWait", time, waitSpin)
end

function BaseTheme:startAutoSpin(time)
    local function waitSpin()
        bole:postEvent("startAutoSpinEnabled")
    end
    self:addWaitEvent("freeSpinNoWinWait", time, waitSpin)
end

function BaseTheme:onDealNextSpin()
    print("BaseTheme:onDealNextSpin")

    local isEnableSpin = true
    local isNext = false
    if self.isFreeSpining then
        if self.freeSpinCount > 0 then
            local waitTime
            if self.winTime > 0 then
                waitTime = self.winTime
            else
                waitTime = 0.5
            end
            self:waitNextFreeSpin(waitTime)
            isNext = true
        else
            local waitTime
            if self.winTime > 0 then
                waitTime = self.winTime
            else
                waitTime = 0.5
            end

            local function stopFreeSpin()
                bole:postEvent("stopFreeSpin")
            end
            self:addWaitEvent("freeSpinStopFreeSpin", waitTime, stopFreeSpin)

            isEnableSpin = false
            self.isFreeSpining = false
        end
    elseif self.autoSpinning then
        isNext = true
        local waitTime
        if self.winTime > 0 then
            waitTime = 2
        else
            waitTime = 0.5
        end

        self:startAutoSpin(waitTime)
    end

    if isEnableSpin then
        bole:postEvent("spinStatus", "spinEnabled")
    end

    --走到这里表明可以点击，可以用来计算等待的时间
    if not isNext and isEnableSpin and bole:getUserDataByKey("level") > 5 then
        local function startCalTimeForBackLobbyReady()
            bole:popMsg({msg = "Hello!Keep making spins or you will be moved to the lobby...", title = "Notice"})
            local function startCalTimeForBackLobby()
                bole.socket:send(bole.SERVER_LEAVE_THEME, {})
                bole:getAppManage():updateLobby()
                bole:postEvent("enterLobby", true)
            end
            self:addWaitEvent("startCalTimeForBackLobby", 30, startCalTimeForBackLobby)
        end
        self:addWaitEvent("startCalTimeForBackLobbyReady", 60, startCalTimeForBackLobbyReady)
    end
end

--freespinstart 对话框即将消失（点击start按钮）(minigameback触发的事件)
function BaseTheme:onStartFreeSpin(event)
    print("BaseTheme:onStartFreeSpin")
    self:changeMatrix(102)
    self:onCreateFreeSpinBottom()
    local function waitFun()
        self:onStartFreeSpinPopEnd()
    end
    self:addWaitEvent("onStartFreeSpinPopEnd", 1, waitFun)
end

--freespinstart 对话框完全消失
function BaseTheme:onStartFreeSpinPopEnd(event)
    print("BaseTheme:onStartFreeSpinPopEnd")
end

--freespinstop 对话框即将出现（触发弹出freespinstop对话框）
function BaseTheme:onStopFreeSpin(event)
    print("BaseTheme:onStopFreeSpin")
    self:onCreateCommonBottom()
    self:changeMatrix(101)
    self:resetToSpinView()
    bole:postEvent("freespin_dialog", {allData = self.thisReceiveData})

    local function waitFun()
        self:onFreeSpinOverPopup()
    end
    self:addWaitEvent("onFreeSpinOverPopup", 1, waitFun)
end

--freespinstop 对话框已经完整出现
function BaseTheme:onFreeSpinOverPopup()
    print("BaseTheme:onFreeSpinOverPopup")
    self:onClearFixedSymbolLayer()
end

--freespinstop 对话框即将消失（点击collect按钮）
function BaseTheme:onFreeSpinOver(event)
    print("BaseTheme:onFreeSpinOver")
    self:putCoinToTopWin(bole:getUserDataByKey("coins"))
    self.winTime = 1
    self:onDealNextSpin()
    local function waitFun()
        self:onFreeSpinOverPopEnd()
    end
    self:addWaitEvent("onFreeSpinOverPopEnd", 1, waitFun)
end

--freespinstop 对话框完全消失
function BaseTheme:onFreeSpinOverPopEnd(event)
    print("BaseTheme:onFreeSpinOverPopEnd")
end

function BaseTheme:addListeners()
    self.eventListenerForNext = {}
    self:addListenerForNext("reelStoped", self.onPopupDialog)
    self:addListenerForNext("popupDialog", self.onMiniEffect)
    self:addListenerForNext("miniEffectEnd", self.onMiniGame)
    self:addListenerForNext("miniGame", self.onMiniGameBack)
    self:addListenerForNext("miniGameBack", self.onDealNextSpin)
end

function BaseTheme:run()
    bole:getUIManage():runScene(self)
end

function BaseTheme:spinRequest()
    print("BaseTheme:spinRequest")
    bole.socket:send("batch_spin", {bet = self:getCurBetValue()})
end

function BaseTheme:spinResponse(t, data)
    print("BaseTheme:spinResponse")
    if data.list then
        local realData = data.list[1]
        if realData then
            self:onResponse(realData)
            self:onDataFilter(realData)
            self:onReplaceTrueReels()
            self:setVouchersNum(realData)
        else
            self:spinErrorTip()
        end
    else
        self:spinErrorTip()
    end
end

function BaseTheme:spinErrorTip()
    self.spinError = true
    bole:popMsg({msg = "internet link error." , title = "Failure" , cancle = false})
end

function BaseTheme:addListenerForNext(name, func)
    self.eventListenerForNext[name] = func
end

function BaseTheme:onDealWithFreeSpinFeatureData(batchData)
    
end

function BaseTheme:onDataFilter(data)
    print("BaseTheme:onDataFilter")

    self.freeSpinCount = data.free_spins_amount or data.free_spins or 0  --剩余freespin的次数
    self.freeSpinTotal = data.free_spins_total --此次freespin的总次数
    self.freeSpinCoins = data.fs_coins  --freespin累计的金币
    self.stopReels = data.view_reels  --停止时的棋盘

    self:onDealWithFreeSpinFeatureData(data)

    if self.isFreeSpining then
        if data.free_spins then
            bole:postEvent("freeSpinNum", {remain = self.freeSpinCount-data.free_spins, total = self.freeSpinTotal-data.free_spins})
        else
            bole:postEvent("freeSpinNum", {remain = self.freeSpinCount, total = self.freeSpinTotal})
        end
    else
        self:putCoinToTopWin(bole:getUserDataByKey("coins")-self:getSpinCost(), data["experience"], data["levelup"])
    end

    bole:setUserDataByKey("coins", data["coins"])
end

function BaseTheme:putCoinToTopWin(coin, exp, lvlup)
    bole:postEvent("putWinCoinToTop", {coin = coin, exp = exp, levelup = lvlup})
end

function BaseTheme:enterThemeDataFilter(data)
    print("BaseTheme:enterThemeDataFilter")
    local betNum = data.last_bet or 0 --上次的倍率
    self:adjustBetValue(tonumber(betNum)/self.spinEachLineCost)

    self.freeSpinCount = data.free_spins or 0  --剩余freespin的次数
    self.freeSpinTotal = data.free_spins_total --此次freespin的总次数
    self.freeSpinCoins = data.fs_coins --freespin累计的金币
    self.stopReels = data.default_item_list  --刚进来时的棋盘

    local featureId = data.fs_type  --上次中断了的小游戏id
    if featureId then
        self.freeSpinFeatureType = bole:getMiniGameControl():getFeatureType(featureId)
    end

    self.roomInfo = data.room_info  --同房间的其他人的信息

    self.thisReceiveData = data
end

function BaseTheme:getOtherPlayerInfo()
    return self.roomInfo.other_players
end

function BaseTheme:getFilledInIdsAndStack()
    local info = self.stopReels

    local stackResult = {}
    local resultFilledIds = {}
    local stackNum = 2 
    local isFindStack = self.matrix.stack_random > 0
    local ignoreIds = table.set(self.matrix.removed)
    for _, column in ipairs(info) do
        local findNum = 0
        local findId
        for k, id in ipairs(column) do
            if findId == id then
                findNum = findNum + 1
                if isFindStack and k == #column and not self.symbolsSizeSet[id] and findNum >= stackNum then
                    table.insert(stackResult, id)
                end
            else
                if isFindStack and not self.symbolsSizeSet[findId] and findId and findNum >= stackNum then
                    table.insert(stackResult, findId)
                end

                if not ignoreIds[id] then
                    table.insert(resultFilledIds, id)
                end

                findNum = 1
                findId = id
            end
        end
    end
    stackResult = table.set(stackResult)
    return resultFilledIds, stackResult
end

function BaseTheme:genFalseColumn(row, filledInIds, stackIds)
    local stackRandom = self.matrix.stack_random
    local isStack = stackRandom > 0
    local filledInNum = #filledInIds
    local columnBottom = {}
    local i = 1
    while(i <= row) do
        local id = filledInIds[math.random(filledInNum)]
        columnBottom[i] = id
        if isStack and stackIds[id] then
            local thisNum = math.random(0, stackRandom)
            if thisNum > 0 then
                for index = i + 1, i + thisNum do
                    if index > row then
                        break
                    end
                    columnBottom[index] = id
                end
                i = i + thisNum
            end
        end
        i = i + 1
    end
    return columnBottom
end

function BaseTheme:fillLongSymbolColumn(minIndex, maxIndex, column)
    local filled_reserve = self.matrix.filled_reserve
    local i = minIndex
    while(i <= maxIndex) do
        local id = column[i]
        local symbolSize = self.symbolsSizeSet[id]
        if symbolSize then
            local len = symbolSize[2]
            if len <= maxIndex - i + 1 then
                for k = i + 1, i + len - 1 do
                    column[k] = id
                end
                i = i + len - 1
            else
                local randomId = filled_reserve[math.random(#filled_reserve)]
                column[i] = randomId
            end
        end
        i = i + 1
    end
end

function BaseTheme:genFalseReels()
    local filledInIds, stackIds = self:getFilledInIdsAndStack()
    local bottomReels = {}  --真滚轴以上的一小部分 （第一行显示在最上面）
    local topReels = {}  --真滚轴以下的一小部分  (第一行显示在最下面)
    local falseReels = {}  --假滚轴

    local filledInIds2 = self.matrix.filled_number  --假滚轴选择的种子id
--    for _, id in ipairs(filledInIds2) do
--        table.insert(filledInIds, id)
--    end
    local num = 0
    local numIndex = {}
    local randomSumLen = #filledInIds2
    while(num <= 3) do
        local random = math.random(randomSumLen)
        if not numIndex[random] then
            numIndex[random] = true
            num = num + 1
            table.insert(filledInIds, filledInIds2[random])
        end
    end

    local rowNeedNum = self.matrix.filled  --真滚轴上下需要补的行数
    local falseReelNum = self.matrix.fake_reel_count  --假滚轴的数量
    
    --生成真滚轴的补齐，以及假滚轴
    for column = 1, #self.stopReels do
        bottomReels[column] = self:genFalseColumn(rowNeedNum, filledInIds, stackIds)
        topReels[column] = self:genFalseColumn(rowNeedNum, filledInIds, stackIds)
        falseReels[column] = self:genFalseColumn(falseReelNum, filledInIds, stackIds)
    end

    --添加bonusId
    local insertReels = self.insertBonusReels[self.matrixId]  --本次可需要检查的bonus表
    for _, item in ipairs(insertReels) do
        for index, column in ipairs(self.stopReels) do   --第一行显示在最上面
            local findRowIndex
            local searchItem = item.reels[index]
            if searchItem then
                findRowIndex = -1
                for row = #column, 1, -1 do  --从下面开始找，找到最下面的那个Bonus
                    local id = column[row]
                    if searchItem[id] then
                        findRowIndex = row
                        break
                    end
                end

                local chooseBonusIds = item["insert_symbol_reel" .. index]
                local firstBonusIndex = 0
                if findRowIndex == -1 then
                    local random = math.random(15)
                    if random >= 1 and random <= rowNeedNum then
                        findRowIndex = rowNeedNum - random + 1
                        bottomReels[index][findRowIndex] = chooseBonusIds[math.random(#chooseBonusIds)]
                        firstBonusIndex = random
                    elseif random > rowNeedNum + #column and random <= 2*rowNeedNum + #column then
                        findRowIndex = random - rowNeedNum - #column
                        topReels[index][findRowIndex] = chooseBonusIds[math.random(#chooseBonusIds)]
                        firstBonusIndex = random
                    end
                else
                    firstBonusIndex = #column - findRowIndex + 1 + rowNeedNum
                end

                local bonusInter = item.insert_length  --假数据的插入长度空间
                local falseRandom = math.random(bonusInter[1], bonusInter[2]) + firstBonusIndex
                if falseRandom > 2*rowNeedNum + #column and falseRandom <= 2*rowNeedNum + #column + falseReelNum then
                    falseReels[index][falseRandom - 2*rowNeedNum - #column] = chooseBonusIds[math.random(#chooseBonusIds)]
                end
            end
        end
    end

    --补齐长条
    for index, column in ipairs(self.stopReels) do
        local columnLen = #column
--        local firstRowId = column[1]  --最上面
--        local topIndex = 1
--        if self.symbolsSizeSet[firstRowId] then  --真滚轴的上面那部分长条补齐
--            local findRowIndex = columnLen
--            for row = 2, columnLen do
--                if column[row] ~= firstRowId then
--                    findRowIndex = row - 1  --往上退一格
--                    break
--                end
--            end
--            if findRowIndex ~= columnLen then  --如果此列全部相同，补齐下边，不管上边
--                local num = self.symbolsSizeSet[firstRowId][2]
--                local needNum = num - (findRowIndex % num)
--                for i = 1, needNum do  --从下向上补齐长条
--                    topReels[index][i] = firstRowId
--                end
--                topIndex = needNum + 1
--            end
--        end

        local lastRowId = column[columnLen]
        local bottomIndex = 1
        if self.symbolsSizeSet[lastRowId] then  --真滚轴的下面那部分长条补齐
            local findRowIndex = 1
            for row = columnLen - 1, 1, -1 do  --真滚轴从下往上走
                if column[row] ~= lastRowId then
                    findRowIndex = row + 1  --往下退一格
                    break
                end
            end
            local num = self.symbolsSizeSet[lastRowId][2]
            local needNum = num - ((columnLen-findRowIndex+1) % num)
            for i = 1, needNum do
                bottomReels[index][i] = lastRowId
            end
            bottomIndex = needNum + 1
        end

--        self:fillLongSymbolColumn(topIndex, rowNeedNum, topReels[index])
        self:fillLongSymbolColumn(bottomIndex, rowNeedNum, bottomReels[index])
--        self:fillLongSymbolColumn(1, falseReelNum, falseReels[index])
    end

    for i, topColumn in ipairs(topReels) do
        local stopColumn = self.stopReels[i]
        for row = 1, #stopColumn do
            table.insert(topColumn, 1, stopColumn[row])
        end
        local bottomColumn = bottomReels[i]
        for row = 1, #bottomColumn do
            table.insert(topColumn, 1, bottomColumn[row])
        end
    end

    self.falseReels = falseReels
    self.displayReels = topReels
end

function BaseTheme:getDisplayReelByColumn(column)
    return self.displayReels[column]
end

function BaseTheme:getFalseReelByColumn(column)
    return self.falseReels[column]
end

function BaseTheme:getFilledInId()
    local filled_reserve = self.matrix.filled_reserve
    return filled_reserve[math.random(#filled_reserve)]
end

function BaseTheme:getSymbolNumById(id)
    local lenSize = self.symbolsSizeSet[id]
    if lenSize then  --真滚轴的下面那部分长条补齐
        return lenSize[2]
    else
        return 1
    end
end

function BaseTheme:onClickSpin(event)
    print("BaseTheme:onClickSpin")
    local result = event.result
    self.autoSpinning = result.autoSpin
    if bole:getUserDataByKey("coins") < self:getSpinCost() then
        bole:postEvent("spinCoinNotEnough")
        if self.outOfCoinsLayer_ == nil then 
            self.outOfCoinsLayer_ = bole:getUIManage():openNewUI("OutOfCoinsLayer", true, "shop_out", "app.views.shop")
        end
    else
        self:startSpinRequest()
    end
end

function BaseTheme:closeOutOfCoinsLayer()
    self.outOfCoinsLayer_ = nil
end


function BaseTheme:startSpinRequest()
    bole:postEvent("spin")
end

function BaseTheme:onClickStop(event)
    print("BaseTheme:onClickStop")
    self.clickStopManual = true
    self:getPromptNode():setVisible(false)
    bole:postEvent("stop")
end

function BaseTheme:onFirstEnterCheck(event)
    print("BaseTheme:onFirstEnterCheck")
    self:putCoinToTopWin(bole:getUserDataByKey("coins"), self.thisReceiveData["experience"])

    self:onMiniGameBack(event.result)
end

function BaseTheme:getMatrix()
    return self.matrix
end

function BaseTheme:getBonusWin()
    return self.winBonusReels[self.matrixId]
end

function BaseTheme:getWorldPositionByPos(column, row, isCenter)
    local position = self:getSpinPositionByPos(column, row, isCenter)
    return self.spinView:convertToWorldSpace(position)
end

function BaseTheme:getSymbolNameByPos(column, row)
    local imgName = self:getImgByPos(column, row)
    return string.format("symbol/%s.png", imgName)
end

function BaseTheme:genSkeletonNodeByPos(column, row, key)
    return self:genSkeletonNodeById(self.stopReels[column][row], key)
end

function BaseTheme:genSkeletonNodeById(id, key)
    local projectName, animationName = self:getAnimName(id, key)
    print("projectName=" .. projectName .. ", animationName=" .. animationName)
    local skeletonNode = sp.SkeletonAnimation:create(self.app:getSymbolAnim(self.themeId, projectName))
    skeletonNode[key] = animationName
    return skeletonNode
end

function BaseTheme:getSymbolNodeByPos(column, row)
    return self.spinView:getSymbolSpriteByPos(column, row)
end

function BaseTheme:getSpinNodeInfoByPos(column, row)
    return self.spinView:getNodeInfoByPos(column, row)
end

function BaseTheme:getAnimNodeByPos(column, row)
    for _, nodelist in pairs(self.cacheAnimNodes) do
        for _, node in ipairs(nodelist) do
            if node.column == column and node.row == row then
                return node
            end
        end
    end
end

function BaseTheme:changeMatrix(id)
    self.matrixId = id
    bole:getAudioManage():changeMatrix(self.matrixId)
    self.matrix = self.app:getConfig(self.themeId, "matrix", id)

    local columnNum = #self.matrix.array
    if not self.winBonusReels[id] then
        local promptConfig = self.app:getConfig(self.themeId, "prompt")
        if promptConfig then
            local winReels = {}
            for _, item in pairs(promptConfig) do
                if item.matrix_id == id then
                    if not item.reels then
                        item.reels = {}
                        for i = 1, columnNum do
                            local arrayIn = item["prompt_symbol_reel" .. i]
                            item.reels[i] = table.set(arrayIn)
                        end
                    end

                    table.insert(winReels, item)
                end
            end
            self.winBonusReels[id] = winReels
        end
    end
    
    if not self.insertBonusReels[id] then
        local promptConfig = self.app:getConfig(self.themeId, "insert")
        local winReels = {}
        for _, item in pairs(promptConfig) do
            if item.matrix_id == id then
                if not item.reels then
                    item.reels = {}
                    for i = 1, columnNum do
                        local arrayIn = item["insert_symbol_reel" .. i]
                        if arrayIn[1] ~= -1 then
                            item.reels[i] = table.set(arrayIn)
                        end
                    end
                end

                table.insert(winReels, item)
            end
        end
        self.insertBonusReels[id] = winReels
    end

    if self.back_image then
        self.back_image:setTexture(self.app:getRes(self.themeId, self.matrix.back_image, "png"))
    end
end

function BaseTheme:onPromptSuccess(event)
    print("BaseTheme:onPromptSuccess")
    local columnIndex = event.result

    local configPrompt = self:getBonusWin()
    local imgName
    local promptSound
    for _, item in ipairs(configPrompt) do
        if item.prompt_id == self.promptSuccessId then
            imgName = item.prompt_resource
            promptSound = item.prompt_success_sound
            break
        end
    end

    local position = self:getBottomPosByColumn(columnIndex, true)
    local promptSuccessNode = self:getPromptNode()
    promptSuccessNode:setVisible(true)

    local skeletonNode = promptSuccessNode:getChildByTag(100)
    if not skeletonNode then
        skeletonNode = sp.SkeletonAnimation:create(self.app:getSymbolAnim(self.themeId, imgName))
        promptSuccessNode:addChild(skeletonNode)
        skeletonNode:setTag(100)
    else
        skeletonNode:stopAllActions()
    end
    skeletonNode:setPosition(position.x, position.y)
    skeletonNode:setAnimation(0, "animation", true)
    skeletonNode:setOpacity(0)
    skeletonNode:runAction(cc.FadeIn:create(0.4))

    if promptSound then
        bole:postEvent("audio_prompt_success", promptSound)
    end
end

function BaseTheme:getBottomPosByColumn(column, isCenter)
    local matrix = self.matrix
    local bottomPos = matrix.coordinate[column]
    local position = cc.p(bottomPos.x, bottomPos.y)
    if isCenter then
        position.y = position.y + (matrix.cell_size[2] * matrix.array[column]) / 2
    end
    return position
end

function BaseTheme:getSymbolInfo(info)
    local sp = info.node
    local isNew = not sp
    local spStr = self:getFrameNameById(info.symbol)
    if not sp then
        sp = display.newSprite("#" .. spStr)
        info.node = sp
    else
        sp:setSpriteFrame(spStr)
    end

    return isNew
end

function BaseTheme:getFrameNameById(id)
    local img = self:getImgById(id)
    return string.format("symbol/%s.png", img)
end

function BaseTheme:getImgById(id)
    return self:getItemById(id).symbol_name
end

function BaseTheme:getImgByPos(column, row)
    return self:getImgById(self.stopReels[column][row])
end

function BaseTheme:getItemById(id)
    return self.app:getConfig(self.themeId, "symbol", id)
end

function BaseTheme:getAnimName(id, key)
    local item = self:getItemById(id)
    return item[key .. "_project"], item[key .. "_animation"], item[key .. "_cut"]
end

function BaseTheme:genSymbolSizeSet()
    self.symbolsSizeSet = {}

    local symbols = self.app:getConfig(self.themeId, "symbol")
    for id, item in pairs(symbols) do
        local symbolSize = item.symbol_size
        if symbolSize[1] > 1 or symbolSize[2] > 1 then  --[1]宽， [2]长
            self.symbolsSizeSet[tonumber(id)] = symbolSize
        end
    end
end

function BaseTheme:getThemeId()
    return self.themeId
end

function BaseTheme:addMiniGame(view)
    self:addChild(view, THEME_CHILD_ORDER.MINIGAME, THEME_CHILD_ORDER.MINIGAME)
end

function BaseTheme:addDialog(view)
    self:addChild(view, THEME_CHILD_ORDER.DIALOG, THEME_CHILD_ORDER.DIALOG)
end

function BaseTheme:addOptions(view)
    self:addChild(view, THEME_CHILD_ORDER.OPTIONS, THEME_CHILD_ORDER.OPTIONS)
    bole:postEvent("initOptions",1)
end

function BaseTheme:getSpinApp()
    return self.app
end

function BaseTheme:createChatView()
    if self.chatView_ == nil then
        self.chatView_ = bole:getUIManage():createNewUI("ChatLayer","inSlot_chat","app.views.chat",nil,false)
        self:addChild(self.chatView_, THEME_CHILD_ORDER.CHAT, THEME_CHILD_ORDER.CHAT)
    end
    self.chatView_:setVisible(true)
    self.chatView_.chatView_:runAction(cc.MoveTo:create(0.2,cc.p(0,0)))
end

function BaseTheme:createFriendView()
    bole:getUIManage():openUI("FriendLayer",true, "friend")
end

function BaseTheme:createChatCache()
    
end

function BaseTheme:removeChatCache()
    bole:getChatManage():cleanGameChatMsg()
end

function BaseTheme:setVouchersNum(data)  
    if data.vouchers ~= nil then
        bole:getUserData():setDataByKey("vouchers",data.vouchers)
    end

    if data.vip_level ~= nil then
        bole:getUserData():setDataByKey("vip_level",data.vip_level)
    end

    if data.vip_points ~= nil then
        bole:getUserData():setDataByKey("vip_points",data.vip_points)
    end
end

return BaseTheme

-- endregion
