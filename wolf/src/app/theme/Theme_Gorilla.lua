-- region *.lua
-- Date
-- 此文件由[BabeLua]插件自动生成

local Theme_gorilla = class("Theme_gorilla", bole:getTable("app.theme.BaseTheme"))

function Theme_gorilla:ctor(themeId, app)
    print("Theme_gorilla:ctor")
    self.allSymbolInfo = {}
    Theme_gorilla.super.ctor(self, themeId, app)
end

function Theme_gorilla:onFirstEnter(data)
    for columnIndex, column in ipairs(self.stopReels) do
        for row, id in ipairs(column) do
            if id == 14 or id == 15 then
                self:onCreateFixedSymbol(columnIndex, row, 14)
            end
        end
    end

    Theme_gorilla.super.onFirstEnter(self, data)
end

function Theme_gorilla:setSpinBgPosition(node)
    node:setPositionY(node:getPositionY() - 16)
end

function Theme_gorilla:onCreateViews()
    print("Theme_gorilla:onCreateViews")
    Theme_gorilla.super.onCreateViews(self)
    self:onCreateCollect()
end

function Theme_gorilla:onCreateCollect()
    print("Theme_gorilla:onCreateCollect")
    local position = self.framBg:convertToWorldSpace(cc.p(0, self.framBg:getContentSize().height))
    local colllectPos = self:convertToNodeSpace(position)
    bole:getEntity("app.theme.gorilla.CollectView", self, self.collectMaxCount, self.collectProgress, self.collectCoinCount, THEME_CHILD_ORDER.COLLECT, colllectPos)
end

function Theme_gorilla:enterThemeDataFilter(data)
    print("Theme_gorilla:enterThemeDataFilter")
    Theme_gorilla.super.enterThemeDataFilter(self, data)
    --collect的三个数据
    self.collectMaxCount = data.collect_total_count  --收集的最大值
    self.collectCoinCount = data.collect_coin_pool or 0  --收集的金币数
    self.collectProgress = data.collect_count or 0  --收集的进度
end

function Theme_gorilla:onDataFilter(data)
    print("Theme_gorilla:onDataFilter")
    Theme_gorilla.super.onDataFilter(self, data)

    self.collectProgress = data.collect_count
    self.collectCoinCount = data.collect_coin_pool
    self.collectPosInfo = data.collect_data
end

function Theme_gorilla:onDealWithFreeSpinFeatureData(data)
    self.freeSpinFeatureType = nil
    self.freeSpinChangePos = nil

    self.isCollectMiniGame = false

    for _, id in ipairs(data.feature) do
        local featureType = bole:getMiniGameControl():getFeatureType(id)
        if featureType == 2 then  --collct minigame
            self.isCollectMiniGame = true
        elseif featureType == 6 or featureType == 7 then
            self.freeSpinFeatureType = featureType
        end
    end

    if self.freeSpinFeatureType then
        for _, line in ipairs(data["win_lines"]) do
            local feature = line.feature
            if feature ~= 0 then
                local featureType = bole:getMiniGameControl():getFeatureType(feature)
                if featureType == self.freeSpinFeatureType then
                    self.freeSpinChangePos = line.icons
                    break
                end
            end
        end
    end
end

function Theme_gorilla:onCollect(data)
    print("Theme_gorilla:onCollect")
    local funcEnd
    if self.isCollectMiniGame then
        funcEnd = function()
            self.isCollectMiniGame = false
            self:onMiniGame()
        end
    end
    bole:postEvent("collectButterFly", {pos = self.collectPosInfo, collectProgress = self.collectProgress, collectCoin = self.collectCoinCount, backFunc = funcEnd})
end

function Theme_gorilla:onMiniEffect(data)
    print("Theme_gorilla:onMiniEffect")
    Theme_gorilla.super.onMiniEffect(self, data)
    self:onCollect(data)
end

function Theme_gorilla:onMiniGame()
    print("Theme_gorilla:onMiniGame")
    if not self.isCollectMiniGame then
        Theme_gorilla.super.onMiniGame(self)
    end
end

function Theme_gorilla:onChangeScatter(data)
    local flag = false
    if self.freeSpinFeatureType == 7 then
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
                self:createAnimNode(pos[1], pos[2], "wild", false, true, true, endCallback)
                self:onRemoveFixedSymbol(columnIndex, row)
                flag = true
            end
        end
    end
    
    if not flag then
        self:onChangeScatterResult()
    end
end

function Theme_gorilla:onChangeScatterResult(event)
    self.curStepName = "changeScatter"
    self:onNext()
end

function Theme_gorilla:onDealWithMiniGameData(data)
    print("Theme_gorilla:onDealWithMiniGameData")
    if data and data.isDeal then
        bole:postEvent("gorillaAfterMini")
    end
end

function Theme_gorilla:onChangeWild(data)
    local flag = false
    if self.freeSpinFeatureType == 6 or self.freeSpinFeatureType == 7 then
        for _, pos in ipairs(self.freeSpinChangePos) do
            local id = self.stopReels[pos[1]][pos[2]]
            if id == 13 or id == 15 then
                flag = true
                break
            end
        end
    end
    
    if flag then
        local function waitFunc()
            self:execChangeWild(data)
        end
        self:addWaitEvent("gorillaExecChangeWild", 1, waitFunc)
        self.winTime = 0
    else
        self:onChangeWildResult(data)
    end
end

function Theme_gorilla:execChangeWild(data)
    local count = 0
    for _, pos in ipairs(self.freeSpinChangePos) do
        local id = self.stopReels[pos[1]][pos[2]]
        if id == 13 or id == 15 then
            count = count + 1

            local function endCallback()
                self:onCreateFixedSymbol(pos[1], pos[2], 14)
                count = count - 1
                if count == 0 then
                    self:onChangeWildResult(data)
                end
            end

            self:createAnimNode(pos[1], pos[2], "scatter", false, true, true, endCallback)
            self:onRemoveFixedSymbol(pos[1], pos[2])
        end
    end
end

function Theme_gorilla:onChangeWildResult(data)
    self.curStepName = "changeWild"
    self:onNext(data)
end

function Theme_gorilla:addListeners()
    Theme_gorilla.super.addListeners(self)
    self:addListenerForNext("popupDialog", self.onChangeScatter)
    self:addListenerForNext("changeScatter", self.onMiniEffect)
    self:addListenerForNext("miniGameBack", self.onChangeWild)
    self:addListenerForNext("changeWild", self.onDealNextSpin)
end

function Theme_gorilla:getSymbolInfo(info)
    if info.symbol == 14 then
        local filled_reserve = self.matrix.filled_reserve
        info.symbol = filled_reserve[math.random(#filled_reserve)]
    end

    local isNew = Theme_gorilla.super.getSymbolInfo(self, info)
    if isNew then
        table.insert(self.allSymbolInfo, info)
    end
    local sp = info.node
    info.label = nil
    sp:removeAllChildren(true)
    if info.symbol == 16 then --收集的单独处理
        local butterflySp = display.newSprite("#symbol/gorilla_collection2.png")
        sp:addChild(butterflySp, 1, 10)
        butterflySp:setPosition(71.5, 50.5)

        local outSp = display.newSprite("#symbol/gorilla_collection3.png")
        sp:addChild(outSp, 2, 20)
        outSp:setPosition(71.5, 29)

        local label = cc.LabelBMFont:create("", "common_fnt/ziti08.fnt")
        label:setScale(0.45)
        self:setSymbolCoin(label)
        label:setPosition(outSp:getContentSize().width/2, outSp:getContentSize().height/2+8)
        outSp:addChild(label)
        info.label = label
    end

    return isNew
end

function Theme_gorilla:onClearFixedSymbolLayer()
    for key, node in pairs(self.fixedSymbol) do
        local pos = string.split(key, "_")
        local info = self:getSpinNodeInfoByPos(tonumber(pos[1]), tonumber(pos[2]))
        info.symbol = 14
        self:getSymbolInfo(info)
    end

    Theme_gorilla.super.onClearFixedSymbolLayer(self)
end

function Theme_gorilla:setSymbolCoin(label)
    label:setString("$"..bole:formatCoins(self:getSpinCost()/100, 3))
end

function Theme_gorilla:changedBetValue()
    Theme_gorilla.super.changedBetValue(self)
    for _, info in ipairs(self.allSymbolInfo) do
        if info.label then
            self:setSymbolCoin(info.label)
        end
    end
end

function Theme_gorilla:removeButterFly(column, row)
    local symbolNode = self:getSymbolNodeByPos(column, row)
    symbolNode:removeChildByTag(10)
end

return Theme_gorilla

-- endregion