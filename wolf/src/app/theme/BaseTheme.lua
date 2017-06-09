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

local THEMENAME = 
{
    "oz",
    "farm",
    "love",
    "mermaid",
    "sea",
    "gorilla",
    "jones"
}

local BaseTheme = class("BaseTheme", cc.Scene)
function BaseTheme:ctor(themeId, app)
    self.THEMENAME = THEMENAME
    self.FRAME_CHILD_ORDER = FRAME_CHILD_ORDER

    self.isDead = true
    self.themeId = themeId
    self.app = app

    self:createLoadingView()
end

function BaseTheme:createLoadingView()
    local loadingView = bole:getEntity("app.views.spin.ThemeLoadingView", self)
    self:addChild(loadingView, THEME_CHILD_ORDER.DIALOG)
end

function BaseTheme:displayTheme(data)
    local plistName = string.format("theme/theme%d/symbols.plist", self.themeId)
    cc.SpriteFrameCache:getInstance():addSpriteFrames(plistName)

    self.enterThemeData = data
    self:initData(data)
    self:changeMatrix(101)
    self:genFalseReels()
    self:createChatCache()
    self:onCreateViews()
    self:addListeners()
    self:enableNodeEvents()
    self:onEnter()
    bole:getUIManage():addSpinEFF(self.themeId)
    bole:getAudioManage():initThemeAudio(self.themeId)
    bole:getMiniGameControl():initTheme(self.themeId)
    bole:getAudioManage():playEff("start")
    self:setUpdate()
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
    for _, key in ipairs(self.asyncImageWeights) do
        cc.Director:getInstance():getTextureCache():removeTextureForKey(key)
    end
    local plistName = string.format("theme/theme%d/symbols.plist", self.themeId)
    cc.SpriteFrameCache:getInstance():removeSpriteFrameByName(plistName)
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
    self.top = bole:getEntity("app.views.spin.TopView", self, order)
end

function BaseTheme:onCreateBottom(order)
    self.bottom = bole:getEntity("app.views.spin.BottomView", self, order)
end

function BaseTheme:onCreateSpinView()
    self.spinView = bole:getEntity("app.views.spin.SpinView", self)
    self.spinViewNode:addChild(self.spinView)
end

function BaseTheme:onCreateRoommateView(order)
    self.roommateView = bole:getEntity("app.views.spin.RoommateView", self, self.roomInfo, order)
end

function BaseTheme:onCreateFreeSpinNode(x, y)
    self.freeSpin = bole:getEntity("app.views.spin.FreeSpinNode", self, THEME_CHILD_ORDER.FREESPIN)
    self:setFreeSpinPosition(x, y)
end

function BaseTheme:setFreeSpinPosition(x, y)
    self.freeSpin:setPosition(x, y)
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
    self.framBg:setTexture(string.format("theme/theme%s/%s.png", self.themeId, self.matrix.matrix_image))
end

function BaseTheme:setSpinBgPosition(node)
end

function BaseTheme:onCreateViews()
    --大背景
    local bgStr = string.format("theme/theme%s/%s.jpg", self.themeId, self.matrix.back_image)
    local bg = cc.Sprite:create(bgStr)
    self:addChild(bg, THEME_CHILD_ORDER.BG, THEME_CHILD_ORDER.BG)
    bg:setPosition(display.cx, display.cy)

    --棋盘的背景
    local spinBgNameStr = string.format("theme/theme%s/%s.png", self.themeId, self.matrix.matrix_image)
    local spinBg = cc.Sprite:create(spinBgNameStr)
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
        local leftSpStr = string.format("theme/theme%s/frame_left.png", self.themeId)
        local leftSp = cc.Sprite:create(leftSpStr)
        self:addChild(leftSp, THEME_CHILD_ORDER.IPADEXTRA, THEME_CHILD_ORDER.IPADEXTRA)
        leftSp:setAnchorPoint(cc.p(1, 0.5))
--        leftSp:setPosition(framePos.x - frameSize.width/2 + 13, framePos.y + 30)
        local lPos = {x = framePos.x - frameSize.width/2 + 13, y = framePos.y + 30}

        local rightSpStr = string.format("theme/theme%s/frame_right.png", self.themeId)
        local rightSp = cc.Sprite:create(rightSpStr)
        self:addChild(rightSp, THEME_CHILD_ORDER.IPADEXTRA, THEME_CHILD_ORDER.IPADEXTRA)
        rightSp:setAnchorPoint(cc.p(0, 0.5))
--        rightSp:setPosition(framePos.x + frameSize.width/2 - 13, framePos.y + 30)
        local rPos = {x = framePos.x + frameSize.width/2 - 13, y = framePos.y + 30}

        self:setIPADLRFrame(leftSp, rightSp, lPos, rPos)
    end

    --遮挡的shader
    local shadeBgNameStr = string.format("theme/theme%s/%s.png", self.themeId, "masking")
    local shadeBg = cc.Sprite:create(shadeBgNameStr)
    shadeBg:setAnchorPoint(cc.p(0, 0))
    local stencil = cc.Node:create()
    stencil:addChild(shadeBg)
    local clippingNode = cc.ClippingNode:create(stencil)
    local clipPos = self.matrix.shelter
    clippingNode:setPosition(clipPos[1], clipPos[2])
    spinBg:addChild(clippingNode, FRAME_CHILD_ORDER.SPIN, FRAME_CHILD_ORDER.SPIN)
    clippingNode:setAlphaThreshold(0.9)
    self.spinViewNode = clippingNode

    self:createAnimLayer(spinBg, FRAME_CHILD_ORDER.ANIMNODE, clipPos)

    self:onCreateTop(THEME_CHILD_ORDER.TOP)
    self:onCreateBottom(THEME_CHILD_ORDER.BOTTOM)
    self:onCreateSpinView()
    self:onCreateRoommateView(THEME_CHILD_ORDER.ROOMMATE)

    self:onCreateFreeSpinNode(framePos.x, framePos.y + spinBg:getContentSize().height/2)
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
    if not self.fixedSymbolLayer then
        self.fixedSymbolLayer = self.spinView:createOneNode(self.spinView.SPINORDER.SYMBOL)
    end

    local sp = display.newSprite("#" .. self:getFrameNameById(id, true))
    local symbolSp = self:getSymbolNodeByPos(column, row)
    local posX, posY = symbolSp:getPosition()
    sp:setPosition(posX, posY)
    self.fixedSymbolLayer:addChild(sp)

    local key = string.format("%d_%d", column, row)
    self.fixedSymbol[key] = sp
end

function BaseTheme:onClearFixedSymbolLayer()
    if self.fixedSymbolLayer then
        self.fixedSymbolLayer:removeFromParent(true)
        self.fixedSymbolLayer = nil
        self.fixedSymbol = {}
    end
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

function BaseTheme:createAnimNode(column, row, key, loop, isHideSymbol, endCallback)
    local symbolId = self.stopReels[column][row]
    local indexKey, animationName = self:getAnimName(symbolId, key)
    print("createAnimNode id=" .. self.stopReels[column][row] .. ",column=" .. column .. ",row=" .. row .. ",key=" .. key)
    local nodeList = self.cacheAnimNodes[indexKey]
    local node
    if not nodeList then
        nodeList = {}
        self.cacheAnimNodes[indexKey] = nodeList
    else
        for _, item in ipairs(nodeList) do
            if not item:isVisible() then
                node = item
                break
            end
        end
    end

    local symbolNum = self:getSymbolNumById(symbolId)
    local parentNode = self:getAnimLayer(symbolNum > 1)
    if not node then
        node = self:getSkeletonNodeById(symbolId, key)
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
        node:setToSetupPose()
    end

    local symbolSp = self:getSymbolNodeByPos(column, row)

    local posX, posY = symbolSp:getPosition()
    node:setPosition(posX, posY)
    node:setAnimation(0, animationName, loop)

    if isHideSymbol and symbolSp then
        symbolSp:setVisible(false)
    end
    
    node:registerSpineEventHandler(function(event)
        if event.animation == animationName then
            if isHideSymbol then
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

    if node.useTag then
        node.useTag = nil
    end

    return node, symbolSp
end

function BaseTheme:removeAnimNode(isIncludeClipAnimNode)
    self.animNode:removeAllChildren(true)
    self.cacheAnimNodes = {}
    
    if isIncludeClipAnimNode then
        self:getAnimLayer(true):removeAllChildren(true)
    end
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

function BaseTheme:initData(data)
    self.spinEachLineCost = bole:getConfig("theme", self.themeId, "spin_need")
    self.lastReceiveData = nil
    self.thisReceiveData = nil
    self.isFreeSpining = false
    self.freeSpinCount = 0
    self.spinError = false
    self.curStepName = nil
    self.winBonusReels = {}
    self.insertBonusReels = {}
    self.cacheAnimNodes = {}
    self.fixedSymbol = {}
    self:genSymbolSizeSet()
    self:enterThemeDataFilter(data)

    local function checkRemainMiniGame()
        self:onFirstEnter()
    end
    self:addWaitEvent("checkRemainMiniGame", 0.01, checkRemainMiniGame)
end

function BaseTheme:onEnter()
    if not self.isDead then return end
    print("BaseTheme:onEnter")
    self.isDead = false
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

    bole.socket:registerCmd("batch_spin", self.spinResponse, self)
    bole.socket:registerCmd("complete_task", self.completeTask, self)
end

function BaseTheme:onExit()
    print("BaseTheme:onExit")
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

    bole.socket:unregisterCmd("batch_spin")
    bole.socket:unregisterCmd("complete_task")

    self.isDead = true
end

function BaseTheme:onCleanup()
    print("BaseTheme:onCleanup")
    self:removeChatCache()
    bole.socket:send("leave_theme", {})
    self:removeCachedRes()
end

function BaseTheme:onFirstEnter()
    print("BaseTheme:onFirstEnter")
    bole:postEvent("remainMini", self.enterThemeData)
end

function BaseTheme:onSpin(event)
    print("BaseTheme:onSpin")
    self.clickStopManual = false

    self:getPromptNode():setVisible(false)
    self:removeWaitEventByName("freeSpinNoWinWait")
    self:removeWaitEventByName("startCalTimeForBackLobbyReady")
    self:removeWaitEventByName("startCalTimeForBackLobby")
    self:removeWaitEventByName("popupViewForWaitNext")
    self.spinError = false
    self.curStepName = nil

    self:removeAnimNode(true)
    self:onSpinViewStart()

    bole:postEvent("audio_play_spin", self.freeSpinCount)
    self:spinRequest()
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
    self:onReplaceTrueReels(data)
end

function BaseTheme:onReplaceTrueReels(data)
    print("BaseTheme:onReplaceTrueReels")
    self:genFalseReels()
    bole:postEvent("trueReelsResponse", {displayReels = self.displayReels, falseReels = self.falseReels})
    self:onSpinPrompt(self.stopReels)
end

function BaseTheme:onSpinPrompt(stopReels)
    local bonusWinReels = self:getBonusWin()
    if not bonusWinReels then return end

    self.promptSuccessId = nil
    self.promptBonusColumnIndex = {}
    self.promptBonusPos = {}

    local minWinColumnIndex = #stopReels
    local columnCount = minWinColumnIndex
    for _, reelItem in ipairs(bonusWinReels) do
        local totalNum = 0
        for columnIndex, column in ipairs(stopReels) do
            local thisTotal = 0
            self.promptBonusPos[columnIndex] = self.promptBonusPos[columnIndex] or {}
            local columnMaxNum = reelItem.reel_max[columnIndex]
            if columnMaxNum > 0 then
                local arrayIn = reelItem.reels[columnIndex]
                local remainLen = 0
                local lastTag = -100
                for row = #column, 1, -1 do
                    local tag = column[row]
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
                        self.promptBonusPos[columnIndex][row] = true
                        if thisTotal == columnMaxNum then
                            break
                        end
                    end
                    lastTag = tag
                end

                if thisTotal > 0 then
                    totalNum = totalNum + thisTotal
                    self.promptBonusColumnIndex[columnIndex] = reelItem.prompt_sound
                end
            end

            if columnIndex < columnCount and totalNum + reelItem.reel_max[columnIndex+1] >= reelItem.prompt_near_win then
                if minWinColumnIndex > columnIndex then
                    minWinColumnIndex = columnIndex
                    self.promptSuccessId = reelItem.prompt_id
                end
                break
            end
        end
    end

    self.spinView:onStopWinBonusAction(minWinColumnIndex)
end

function BaseTheme:onColumnStop(columnIndex)
    if self:getBonusWin() then
        local promptSuccessNode = self:getPromptNode()
        promptSuccessNode:setVisible(false)

        if self.clickStopManual then return end

        if columnIndex < self.spinView:getColumnCount() then
            self.spinView:onTriggerColumnPrompt(columnIndex)

            local audioValue = self.promptBonusColumnIndex[columnIndex]
            if audioValue then
                bole:postEvent("audio_prompt", audioValue)
            end

            local promptPos = self.promptBonusPos[columnIndex]
            if promptPos then
                for row, _ in pairs(promptPos) do
                    self:createAnimNode(columnIndex, row, "prompt", false, true, nil)
                end
            end
        end
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

    if self.isFreeSpining then
        bole:postEvent("freeSpinNum", self.freeSpinCount)
    end
end

--5连的弹窗
function BaseTheme:onPopupDialog(data)
    print("BaseTheme:onPopupDialog")
    local eventName = "popupDialog"
    self.curStepName = eventName
    self.thisReceiveData.isFreeSpining = self.isFreeSpining
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
        local data
        if event and type(event) == "table" then
            data = event.result
        end
        func(self, data)
    end
end

function BaseTheme:getMiniGameLineData(data)
    local winLines = {}
    for _, line in ipairs(self.thisReceiveData["win_lines"]) do
        if line.feature ~= 0 then   --10101 or line.feature == 10102 or line.feature == 10104 or line.feature == 10105 then
            table.insert(winLines, line)
        end
    end
    return winLines
end

--bonus game and free spin drawing rects
function BaseTheme:onMiniEffect(data)
    print("BaseTheme:onMiniEffect")
    local winLines = self:getMiniGameLineData(data)

    if #winLines > 0 then
        self.isHaveMiniGame = true
    else
        self.isHaveMiniGame = false
    end

    local eventName = "miniEffect"
    self.curStepName = eventName
    bole:postEvent(eventName, winLines)
    bole:setUserDataByKey("coins", self.thisReceiveData["coins"])
end

function BaseTheme:onMiniEffectEnd(event)
    print("BaseTheme:onMiniEffectEnd")
    self.curStepName = "miniEffectEnd"
    self:onNext(event)
end

function BaseTheme:onMiniGame(data)
    local eventName = "miniGame"
    self.curStepName = eventName
    bole:postEvent(eventName, self.thisReceiveData)
end

function BaseTheme:onDealWithMiniGameData(data)
end

function BaseTheme:onDrawLine(data)
    print("BaseTheme:onDrawLine")

    self:onDealWithMiniGameData(data)

    bole:postEvent("audio_win", { win_lines = self.thisReceiveData["win_lines"], themeId = self.themeId })
    bole:postEvent("winAmount", self.thisReceiveData["win_amount"])

    local isFreeSpinStop = false
    if self.isFreeSpining and self.freeSpinCount == 0 then
--        self.isFreeSpining = false
--        bole:postEvent("stopFreeSpin")
        isFreeSpinStop = true
    elseif not self.isFreeSpining and self.freeSpinCount > 0 then
        self.isFreeSpining = true
        bole:postEvent("startFreeSpin", self.freeSpinCount)
    end

    local eventName = "drawLine"
    self.curStepName = eventName
    local winLines = {}
    self.isHaveWinLines = false
    if not self.isHaveMiniGame then
        for _, line in ipairs(self.thisReceiveData["win_lines"]) do
            if line.feature == 0 then
                table.insert(winLines, line)
                self.isHaveWinLines = true
            end
        end
    end
    bole:postEvent(eventName, {line = winLines, isFreeSpin = self.isFreeSpining or self.autoSpinning})

    if not isFreeSpinStop then
        bole:postEvent("spinStatus", "spinEnabled")
    end
end

function BaseTheme:onWinLineEnd(event)
    print("BaseTheme:onWinLineEnd")
    self.curStepName = "winLineEnd"
    self:onNext(event)
end

function BaseTheme:onFreeSpin(data)
    print("BaseTheme:onFreeSpin")

    --走到这里表明可以点击，可以用来计算等待的时间
    local function startCalTimeForBackLobbyReady()
        bole:popMsg({msg = "如果30秒之内还没有任何操作，你将被踢出房间。", title = "提示"})
        local function startCalTimeForBackLobby()
            bole:postEvent("enterLobby")
        end
        self:addWaitEvent("startCalTimeForBackLobby", 30, startCalTimeForBackLobby)
    end
    self:addWaitEvent("startCalTimeForBackLobbyReady", 60, startCalTimeForBackLobbyReady)

    self.curStepName = "freeSpin"
    local flag = true
    if self.freeSpinCount > 0 then
        if self.isHaveMiniGame or self.isHaveWinLines then
            bole:postEvent("spin")
        else
            local function waitSpin()
                bole:postEvent("spin")
            end
            self:addWaitEvent("freeSpinNoWinWait", 0.5, waitSpin)
        end
        flag = false
    elseif self.isFreeSpining then
        self.isFreeSpining = false
        bole:postEvent("stopFreeSpin")
    end

    if flag and self.autoSpinning then
        bole:postEvent("startAutoSpinEnabled")
    end
end

function BaseTheme:onStartFreeSpin(event)
    print("BaseTheme:onStartFreeSpin")
    self:changeMatrix(102)
end

function BaseTheme:onStopFreeSpin(event)
    print("BaseTheme:onStopFreeSpin")
    bole:postEvent("freespin_dialog", {allData = self.thisReceiveData})
end

function BaseTheme:onFreeSpinOver(event)
    print("BaseTheme:onFreeSpinOver")
    self:changeMatrix(101)
    bole:postEvent("spinStatus", "spinEnabled")
end

function BaseTheme:addListeners()
    self.eventListenerForNext = {}
    self:addListenerForNext("reelStoped", self.onPopupDialog)
    self:addListenerForNext("miniEffectEnd", self.onMiniGame)
    self:addListenerForNext("miniGame", self.onDrawLine)
    self:addListenerForNext("winLineEnd", self.onFreeSpin)
end

function BaseTheme:run()
    display.runScene(self)
end

function BaseTheme:spinRequest()
    print("BaseTheme:spinRequest")
    bole.socket:send("batch_spin", {bet = self:getBetValue()})
end

function BaseTheme:spinResponse(t, data)
    print("BaseTheme:spinResponse")
    if data.list then
        local realData = data.list[1]
        if realData then
            self:onDataFilter(realData)
            self:onResponse(realData)
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
    bole:alert("提示", "网络请求错误")
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

    self:onDealWithFreeSpinFeatureData(data["win_lines"])
end

function BaseTheme:enterThemeDataFilter(data)
    print("BaseTheme:enterThemeDataFilter")
    local betNum = data.last_bet or 1
    self.betValue = tonumber(betNum)  --上次的倍率
    if self.betValue == 0 then
        self.betValue = 1
    end

    self.freeSpinCount = data.free_spins or 0  --剩余freespin的次数
    self.freeSpinTotal = data.free_spins_total --此次freespin的总次数
    self.freeSpinCoins = data.fs_coins --freespin累计的金币

    self.freeSpinFeatureId = data.fs_type  --上次中断了的小游戏id

    self.stopReels = data.default_item_list  --刚进来时的棋盘

    self.roomInfo = data.room_info  --同房间的其他人的信息
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
    for _, id in ipairs(filledInIds2) do
        table.insert(filledInIds, id)
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
    local flag = true
    if not bole:changeUserDataByKey("coins", -self:getSpinCost()) then
        --bole:popMsg({msg = "你的金币已经不足，请充值。", title = "提示"})
        bole:getUIManage():openUI("OutOfCoinsLayer",true,"csb/shop") 
        flag = false
    end
    
    if flag then
        self:startSpinRequest(freeSpinCount)
    end
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
    if self.freeSpinCount > 0 then
        self.isFreeSpining = true
        bole:postEvent("startFreeSpin", self.freeSpinCount)
    end

    self:onFreeSpin()
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
    return string.format("theme/theme%s/%s.png", self.themeId, imgName)
end

function BaseTheme:getSkeletonNodeByPos(column, row, key)
    return self:getSkeletonNodeById(self.stopReels[column][row], key)
end

function BaseTheme:getSkeletonNodeById(id, key)
    local projectName, animationName = self:getAnimName(id, key)
    print("projectName=" .. projectName .. ", animationName=" .. animationName)
    local skeletonNode = sp.SkeletonAnimation:create(string.format("theme/theme%s/symbolAnimal/%s.json", self.themeId, projectName), string.format("theme/theme%s/symbolAnimal/%s.atlas", self.themeId, projectName))
    skeletonNode[key] = animationName
    return skeletonNode
end

function BaseTheme:getSymbolNodeByPos(column, row)
    return self.spinView:getSymbolSpriteByPos(column, row)
end

function BaseTheme:changeMatrix(id)
    self.matrixId = id
    local tag = THEMENAME[self.themeId] .. "_matrix"
    self.matrix = bole:getConfig(tag, id)

    local columnNum = #self.matrix.array
    if not self.winBonusReels[id] then
        local tag = THEMENAME[self.themeId] .. "_prompt"
        local promptConfig = bole:getConfig(tag)
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
        local tag = THEMENAME[self.themeId] .. "_insert"
        local promptConfig = bole:getConfig(tag)
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

    if self.spinView then
        self.spinView:onChangeWinBonus()
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

    if imgName and imgName ~= "" then
        local promptFile = string.format("theme/theme%s/%s.json", self.themeId, imgName)
        if cc.FileUtils:getInstance():isFileExist(promptFile) then
            local position = self:getBottomPosByColumn(columnIndex, true)
            local promptSuccessNode = self:getPromptNode()
            promptSuccessNode:setVisible(true)
            local skeletonNode = promptSuccessNode:getChildByTag(100)
            if not skeletonNode then
                skeletonNode = sp.SkeletonAnimation:create(promptFile, string.format("theme/theme%s/%s.atlas", self.themeId, imgName))
                promptSuccessNode:addChild(skeletonNode)
                skeletonNode:setTag(100)
            end
            skeletonNode:setPosition(position.x, position.y)
            skeletonNode:setAnimation(0, "animation", true)
        end
    end

    bole:postEvent("audio_prompt_success", promptSound)
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

function BaseTheme:getLineById(id, key)
    local tag = THEMENAME[self.themeId] .. "_line"
    return bole:getConfig(tag, id, key)
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

function BaseTheme:getFrameNameById(id, flag)
    local img = self:getImgById(id)
    return string.format("theme/theme%s/%s.png", self.themeId, img)
end

function BaseTheme:getImgById(id)
    return self:getItemById(id).symbol_name
end

function BaseTheme:getImgByPos(column, row)
    return self:getImgById(self.stopReels[column][row])
end

function BaseTheme:getItemById(id)
    local tag = THEMENAME[self.themeId] .. "_symbol"
    return bole:getConfig(tag, id)
end

function BaseTheme:getAnimName(id, key)
    local item = self:getItemById(id)
    return item[key .. "_project"], item[key .. "_animation"]
end

function BaseTheme:getSymbolsByColumn(column)
    return self.symbols[column]
end

function BaseTheme:genSymbolSizeSet()
    self.symbolsSizeSet = {}

    local tag = THEMENAME[self.themeId] .. "_symbol"
    local symbols = bole:getConfig(tag)
    for id, item in pairs(symbols) do
        local symbolSize = item.symbol_size
        if symbolSize[1] > 1 or symbolSize[2] > 1 then  --[1]宽， [2]长
            self.symbolsSizeSet[tonumber(id)] = symbolSize
        end
    end
end

function BaseTheme:getSpinCost()
    return self.betValue*self.spinEachLineCost
end

function BaseTheme:getBetValue()
    return self.betValue
end

function BaseTheme:setBetValue(value)
    self.betValue = value
end

function BaseTheme:getEachLineBet()
    return self.spinEachLineCost
end

function BaseTheme:getThemeId()
    return self.themeId
end

function BaseTheme:getThemeName()
    return THEMENAME[self.themeId]
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
        self.chatView_ = bole:getUIManage():getSimpleLayer("ChatLayer")
        self:addChild(self.chatView_, THEME_CHILD_ORDER.CHAT, THEME_CHILD_ORDER.CHAT)
    end
    self.chatView_:setVisible(true)
    self.chatView_.chatView_:runAction(cc.MoveTo:create(0.2,cc.p(0,0)))
end

function BaseTheme:createFriendView()
    bole:getUIManage():openUI("FriendLayer",true)
end

function BaseTheme:createChatCache()
    bole:getInstance("app.views.chat.ChatManager"):initChatManager()
end

function BaseTheme:removeChatCache()
    bole:getInstance("app.views.chat.ChatManager"):removeChatManager()
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

function BaseTheme:completeTask(t,data)
    if t == "complete_task" then
        if data ~= nil then
            local taskTable = bole:getUserData():getDataByKey("daily_task")
            for j = 1, # data do
                for i = 1, # taskTable do
                    if tonumber(taskTable[i].id) == tonumber(data[j]) then
                        taskTable[i].is_completed = 1
                        taskTable[i].collect_reward = 0
                    end
                end
            end
            bole:getUserData():setDataByKey("daily_task",taskTable)
        end
    end
end

return BaseTheme

-- endregion
