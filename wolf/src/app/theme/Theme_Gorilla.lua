-- region *.lua
-- Date
-- 此文件由[BabeLua]插件自动生成

local Theme_Gorilla = class("Theme_Gorilla", bole:getTable("app.theme.BaseTheme"))

function Theme_Gorilla:ctor(themeId, app)
    print("Theme_Gorilla:ctor")
    self.allSymbolInfo = {}
    Theme_Gorilla.super.ctor(self, themeId, app)
end

function Theme_Gorilla:onEnter()
    print("Theme_Gorilla:onEnter")
    Theme_Gorilla.super.onEnter(self)
    bole:addListener("collectButterFlyEnd", self.onCollectResult, self, nil, true)
end

function Theme_Gorilla:onExit()
    print("Theme_Gorilla:onExit")
    bole:removeListener("collectButterFlyEnd", self)
    Theme_Gorilla.super.onExit(self)
end

function Theme_Gorilla:onFirstEnter()
    for columnIndex, column in ipairs(self.stopReels) do
        for row, id in ipairs(column) do
            if id == 14 or id == 15 then
                self:onCreateFixedSymbol(columnIndex, row, 14)
            end
        end
    end

    Theme_Gorilla.super.onFirstEnter(self)
end

function Theme_Gorilla:onStopFreeSpin(event)
    print("Theme_Gorilla:onStopFreeSpin")
    Theme_Gorilla.super.onStopFreeSpin(self, event)
    self:onClearFixedSymbolLayer()
end

function Theme_Gorilla:setFreeSpinPosition(x, y)
    y = y - 28
    Theme_Gorilla.super.setFreeSpinPosition(self, x, y)
end

function Theme_Gorilla:setSpinBgPosition(node)
    node:setPositionY(node:getPositionY() - 16)
end

function Theme_Gorilla:onCreateViews()
    print("Theme_Gorilla:onCreateViews")
    Theme_Gorilla.super.onCreateViews(self)
    self:onCreateCollect()
end

function Theme_Gorilla:enterThemeDataFilter(data)
    print("Theme_Gorilla:enterThemeDataFilter")
    Theme_Gorilla.super.enterThemeDataFilter(self, data)
    --collect的三个数据
    self.collectMaxCount = data.collect_total_count  --收集的最大值
    self.collectCoinCount = data.collect_coin_pool or 0  --收集的金币数
    self.collectProgress = data.collect_count or 0  --收集的进度
end

function Theme_Gorilla:onDataFilter(data)
    print("Theme_Gorilla:onDataFilter")
    Theme_Gorilla.super.onDataFilter(self, data)

    self.collectProgress = data.collect_count
    self.collectCoinCount = data.collect_coin_pool
    self.collectPosInfo = data.collect_data
end

function Theme_Gorilla:onDealWithFreeSpinFeatureData(batchData)
    self.freeSpinFeatureId = nil
    self.freeSpinChangePos = nil

    for _, line in ipairs(batchData) do
        if line.feature == 10101 or line.feature == 10102 then
            self.freeSpinFeatureId = line.feature
            self.freeSpinChangePos = line.icons
            break
        end
    end
end

function Theme_Gorilla:onCreateCollect()
    print("Theme_Gorilla:onCreateCollect")
    local position = self.framBg:convertToWorldSpace(cc.p(0, self.framBg:getContentSize().height))
    local colllectPos = self:convertToNodeSpace(position)
    self.collect = bole:getEntity("app.theme.gorilla.CollectView", self, self.collectMaxCount, self.collectProgress, self.collectCoinCount, THEME_CHILD_ORDER.COLLECT, colllectPos)
end

function Theme_Gorilla:onCollect(data)
    print("Theme_Gorilla:onCollect")
    bole:postEvent("collectButterFly", {pos = self.collectPosInfo, collectProgress = self.collectProgress, collectCoin = self.collectCoinCount})
    if self.collectPosInfo and #self.thisReceiveData["feature"] == 0 then
        bole:postEvent("spinStatus", "spinEnabled")
    end
end

function Theme_Gorilla:onCollectResult(event)
    print("Theme_Gorilla:onCollectResult")
    local eventName = "collect"
    self.curStepName = eventName
    self:onNext()
end

function Theme_Gorilla:onChangeScatter(data)
    local flag = false
    if self.freeSpinFeatureId == 10102 then
        local count = 0
        for _, pos in ipairs(self.freeSpinChangePos) do
            local columnIndex = pos[1]
            local row = pos[2]
            local id = self.stopReels[columnIndex][row]
            if id == 15 then
                count = count + 1

                local function endCallback()
                    count = count - 1
                    if count == 0 then
                        self:onChangeScatterResult()
                    end
                end
                self:createAnimNode(pos[1], pos[2], "wild", false, true, endCallback)
                self:onRemoveFixedSymbol(columnIndex, row)
                flag = true
            end
        end
    end
    
    if not flag then
        self:onChangeScatterResult()
    end
end

function Theme_Gorilla:onChangeScatterResult(event)
    local eventName = "changeScatter"
    self.curStepName = eventName
    self:onNext()
end

function Theme_Gorilla:onChangeWild(data)
    local flag = false
    if self.freeSpinFeatureId == 10101 or self.freeSpinFeatureId == 10102 then
        local count = 0
        for _, pos in ipairs(self.freeSpinChangePos) do
            local id = self.stopReels[pos[1]][pos[2]]
            if id == 13 or id == 15 then
                count = count + 1
                
                local function endCallback()
                    self:onCreateFixedSymbol(pos[1], pos[2], 14)
                    count = count - 1
                    if count == 0 then
                        self:onChangeWildResult()
                    end
                end

                self:createAnimNode(pos[1], pos[2], "scatter", false, true, endCallback)
                self:onRemoveFixedSymbol(pos[1], pos[2])
                flag = true
            end
        end
    end
    
    if not flag then
        self:onChangeWildResult()
    end
end

function Theme_Gorilla:onChangeWildResult(event)
    local eventName = "changeWild"
    self.curStepName = eventName
    self:onNext()
end

function Theme_Gorilla:addListeners()
    Theme_Gorilla.super.addListeners(self)
    self:addListenerForNext("popupDialog", self.onCollect)
    self:addListenerForNext("collect", self.onChangeScatter)
    self:addListenerForNext("changeScatter", self.onMiniEffect)
    self:addListenerForNext("miniEffectEnd", self.onChangeWild)
    self:addListenerForNext("changeWild", self.onMiniGame)
end

function Theme_Gorilla:getFrameNameById(id, noChangeId)
    if not noChangeId and id == 14 then
        local filled_reserve = self.matrix.filled_reserve
        id = filled_reserve[math.random(#filled_reserve)]
    end
    return Theme_Gorilla.super.getFrameNameById(self, id)
end

function Theme_Gorilla:getSymbolInfo(info)
    local isNew = Theme_Gorilla.super.getSymbolInfo(self, info)
    if isNew then
        table.insert(self.allSymbolInfo, info)
    end
    local sp = info.node
    info.label = nil
    sp:removeAllChildren(true)
    if info.symbol == 16 then --收集的单独处理
        local spStr = string.format("#theme/theme%s/gorilla_collection2.png", self.themeId)
        local butterflySp = display.newSprite(spStr)
        sp:addChild(butterflySp, 1, 10)
        butterflySp:setPosition(71.5, 50.5)

        local outStr = string.format("#theme/theme%s/gorilla_collection3.png", self.themeId)
        local outSp = display.newSprite(outStr)
        sp:addChild(outSp, 2, 20)
        outSp:setPosition(71.5, 18)

        local label = cc.Label:create()
        self:setSymbolCoin(label)
        label:setPosition(outSp:getContentSize().width/2, outSp:getContentSize().height/2+4)
        label:setSystemFontSize(30)
        outSp:addChild(label)
        info.label = label
    end

    return isNew
end

function Theme_Gorilla:onDealWithMiniGameData(data)
    print("Theme_Gorilla:onDealWithMiniGameData")
    if data and data.isDeal then
        self.collect:afterMiniGame()
    end
end

function Theme_Gorilla:setSymbolCoin(label)
    label:setString(bole:formatCoins(self:getSpinCost()/100, 3))
end

function Theme_Gorilla:setBetValue(value)
    Theme_Gorilla.super.setBetValue(self, value)
    for _, info in ipairs(self.allSymbolInfo) do
        if info.label then
            self:setSymbolCoin(info.label)
        end
    end
end

function Theme_Gorilla:removeButterFly(column, row)
    local symbolNode = self:getSymbolNodeByPos(column, row)
    symbolNode:removeChildByTag(10)
end

function Theme_Gorilla:onSpinPrompt(stopReels)
    local bonusWinReels = self:getBonusWin()
    if not bonusWinReels then return end

    self.promptSuccessId = nil
    self.promptBonusColumnIndex = {}
    self.promptBonusPos = {}

    local minWinColumnIndex = #stopReels
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
                else
                    if minWinColumnIndex > columnIndex then
                        minWinColumnIndex = columnIndex
                    end
                    break
                end
            end
        end
    end

    self.spinView:onStopWinBonusAction(6)
    self.spinView:onChangeWinBonus(minWinColumnIndex)
end

return Theme_Gorilla

-- endregion