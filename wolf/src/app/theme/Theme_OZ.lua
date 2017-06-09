-- region *.lua
-- Date
-- 此文件由[BabeLua]插件自动生成

local Theme_OZ = class("Theme_OZ", bole:getTable("app.theme.BaseTheme"))

function Theme_OZ:ctor(themeId, app, data)
    print("Theme_OZ:ctor")
    self.wildPreviousIds = {}
    self.bottomWildIds = {16, 17, 18, 19}
    Theme_OZ.super.ctor(self, themeId, app, data)
end

function Theme_OZ:onCreateCollect()
    print("Theme_OZ:onCreateCollect")
    self.collect = bole:getEntity("app.theme.oz.CollectView", self, self.collectMaxCount, self.collectProgress, self.collectCoinCount, THEME_CHILD_ORDER.COLLECT)
end

function Theme_OZ:onCreateViews()
    print("Theme_OZ:onCreateViews")
    Theme_OZ.super.onCreateViews(self)
    self:onCreateCollect()
end

function Theme_OZ:onEnter()
    print("Theme_OZ:onEnter")
    Theme_OZ.super.onEnter(self)
    bole:addListener("collectAnimationEnd", self.onCollectResult, self, nil, true)
    bole:addListener("startFreeSpin", self.onStartSpin, self, nil, true)
    bole:addListener("stopFreeSpin", self.onStopSpin, self, nil, true)
    bole:addListener("free_spin_stop", self.onFreeSpinOver, self, nil, true)
    bole:addListener("changeWildSymbol", self.onChangeWildRecords, self, nil, true)
end

function Theme_OZ:onExit()
    print("Theme_OZ:onExit")
    bole:removeListener("collectAnimationEnd", self)
    bole:removeListener("startFreeSpin", self)
    bole:removeListener("stopFreeSpin", self)
    bole:removeListener("free_spin_stop", self)
    bole:removeListener("changeWildSymbol", self)
    Theme_OZ.super.onExit(self)
end

function Theme_OZ:onCollect(data)
    local info = self.collectPosInfo
    if info and #info > 0 and self.freeSpinFeatureId ~= 10102 then
        bole:postEvent("collectAnimation", info)
    else
        self:onCollectResult()
    end
end

function Theme_OZ:onCollectResult(event)
    print("Theme_OZ:onCollect")
    if self.collectDataChanged then --收集的数据发生了变化
        bole:postEvent("collectProgress", {coin = self.collectCoinCount, progress = self.collectProgress})
    end
    local eventName = "collect"
    self.curStepName = eventName
    self:onNext()
end

--处理收集的过程中触发了wild的效果
function Theme_OZ:getImgById(id, themeId)
    local tag = self.THEMENAME[self.themeId] .. "_symbol"
    if self.freeSpinFeatureId == 10103 and self.wildPreviousIds[id] then
        return bole:getConfig(tag, id, "symbol_front")
    else
        return bole:getConfig(tag, id, "symbol_name")
    end
end

function Theme_OZ:onChangeWildRecords(event)
    local curCount
    if type(event) == "table" then
        curCount = event.result
    else
        curCount = event
    end

    local wildIndex = math.floor(curCount/3)
    self.wildPreviousIds = {}
    for i = wildIndex + 1, #self.bottomWildIds do
        self.wildPreviousIds[self.bottomWildIds[i]] = true
    end
end

function Theme_OZ:onDealWithMiniGameData(data)
    print("Theme_OZ:onDealWithMiniGameData")
    if data then
        if data.freeSpin and data.freeSpin > 0 then
            self.isHaveMiniGame = true
            self.freeSpinCount = data.freeSpin
            self.freeSpinFeatureId = data.feature_id
            self.freeSpinMultiple = data.multiple

            self.freeSpinCoins = 0
            self.freeSpinCollect = 0
        end

        --收集满了触发的小游戏结束（需重新计算收集的数量）
        if data.collect_count then
            self.collectProgress = data.collect_count
            self.collectCoinCount = 0
            bole:postEvent("collectProgress", {coin = self.collectCoinCount, progress = self.collectProgress})
        end

--        if data.win_amount then
--            bole:postEvent("winAmount", data.win_amount)
--        end
    end

    if self.freeSpinFeatureId and self.freeSpinCoins then
        bole:postEvent("freeSpinTotalWin", self.freeSpinCoins)
    end

    if self.freeSpinFeatureId == 10103 and self.freeSpinCollect then
        bole:postEvent("freeSpinCollect", self.freeSpinCollect)
    end
end

function Theme_OZ:onStartSpin(event)
    print("Theme_OZ:onStartSpin")
    self.bottom:removeFromParent(true)
    self.bottom = nil

    self.collect:removeFromParent(true)
    self.collect = nil

    if self.freeSpinFeatureId == 10102 then --女巫
        self:changeMatrix(102)
        self.freeSpin = bole:getEntity("app.theme.oz.WitchFreeSpinView", self, self.freeSpinMultiple, self.freeSpinCoins, THEME_CHILD_ORDER.BOTTOM)
    else  --魔法师
        self:changeMatrix(103)
        self.freeSpin = bole:getEntity("app.theme.oz.MagicFreeSpinView", self, self.freeSpinCollect, self.freeSpinCoins, THEME_CHILD_ORDER.BOTTOM)
    end
end

function Theme_OZ:onStopSpin(event)
    print("Theme_OZ:onStopSpin")
    bole:postEvent("freespin_dialog", {msg = "over", allData = self.thisReceiveData, freeSpinFeatureId = self.freeSpinFeatureId, chose = {self.freeSpinTotal, self.freeSpinCoins, self.freeSpinMultiple}})
end

function Theme_OZ:onFreeSpinOver(event)
    print("Theme_OZ:onFreeSpinOver")
    self.freeSpin:removeFromParent(true)
    self.freeSpin = nil
    self.freeSpinFeatureId = nil

    self.freeSpinMultiple = nil
    self.freeSpinTotal = 0
    self.freeSpinCoins = 0

    self:changeMatrix(101)

    self:onCreateBottom(THEME_CHILD_ORDER.BOTTOM)
    self:onCreateCollect()
end

function Theme_OZ:enterThemeDataFilter(data)
    print("Theme_OZ:enterThemeDataFilter")
    Theme_OZ.super.enterThemeDataFilter(self, data)
    
    --collect的三个数据（主题里的）
    self.collectMaxCount = data.collect_total_count  --收集的最大值
    self.collectCoinCount = data.collect_coin_pool or 0  --收集的金币数
    self.collectProgress = data.collect_count or 0  --收集的进度
    
    self.freeSpinMultiple = data.fs_multiple --女巫里freespin的倍率
    self.freeSpinCollect = data.fs_collect --魔法师里freespin的收集个数
    if self.freeSpinFeatureId == 10103 and self.freeSpinCollect then
        self:onChangeWildRecords(self.freeSpinCollect)
    end
end

function Theme_OZ:onDataFilter(data)
    print("Theme_OZ:onDataFilter")
    Theme_OZ.super.onDataFilter(self, data)
    self.freeSpinCollect = data.fs_collect  --魔法师的收集

    --收集的进度(只有变化才会发)
    self.collectDataChanged = false
    if data.collect_count then
        self.collectProgress = data.collect_count
    end
    --收集的金币数（只有变化才会发）
    if data.collect_coin_pool then
        self.collectCoinCount = data.collect_coin_pool
        self.collectDataChanged = true
    end

    self.collectPosInfo = data.collect_data
end

function Theme_OZ:addListeners()
    Theme_OZ.super.addListeners(self)
    self:addListenerForNext("popupDialog", self.onCollect)
    self:addListenerForNext("collect", self.onMiniEffect)
end



return Theme_OZ
--function Theme_OZ:test()
--    self.testSpinStatus = 0
--    local btn = ccui.Button:create("common/spin.png")
--    btn:setScale(0.2)
--    self:addChild(btn)
--    btn:setPosition(cc.p(880, 70))
--    local function callback(event)
--        if event.name == "ended" then
--            self.drawTest(1, 0)
--            if self.testSpinStatus == 0 then
--                --                bole:postEvent("spin", 1)
--                --                self:spin()
--                --                self.testSpinStatus = 1
--                if bole:changeUserDataByKey("coins", - self:getSpinCost()) then
--                    bole:postEvent("spin", { themeId = self:getThemeId() })
--                else
--                    bole:alert("coin less", "")
--                end
--            else
--                self:stop()
--                self.testSpinStatus = 0
--            end
--        end
--    end
--    btn:onTouch(callback)
--    self.stopBtn = btn

--    local label = cc.Label:create()
--    label:setSystemFontSize(30)
--    self:addChild(label, 11)
--    label:setPosition(cc.p(880, 70))
--    label:setString("play")
--    self.stopLabel = label
--    label:setColor(display.COLOR_GREEN)





--    self.lineIndex = 0
--    local function drawTest(num1, num2)
--        self.testLable:setString("")
--        self.testNode:clear()
--        local testNode = self.testNode
--        for line = num1, num2 do
--            local lineConfig = self:getLineById(line)
--            local color = lineConfig.line_color[3]
--            for i = 1, #lineConfig.line_turnning - 1 do
--                local pt1 = lineConfig.line_turnning[i]
--                local pt2 = lineConfig.line_turnning[i + 1]
--                testNode:drawSegment(pt1, pt2, 2, cc.convertColor(color, "4f"))
--            end
--            if num1 == num2 then
--                self.testLable:setString(num1)
--                self.testLable:setPosition(lineConfig.line_turnning[1].x - 30, lineConfig.line_turnning[1].y)
--                self.testLable:setColor(color)
--            end
--        end
--    end
--    self.drawTest = drawTest

--    local function addLine(event)
--        if event.name ~= "ended" then
--            return
--        end
--        self.lineIndex = self.lineIndex + 1
--        if self.lineIndex == 51 then
--            self.lineIndex = 1
--        end

--        drawTest(self.lineIndex, self.lineIndex)
--    end
--    local btnL = ccui.Button:create("common/spin.png")
--    btnL:setScale(0.2)
--    self.spinViewParent:getParent():addChild(btnL)
--    btnL:setPosition(-100, 300)
--    btnL:onTouch(addLine)

--    local function subLine(event)
--        if event.name ~= "ended" then
--            return
--        end

--        --        if self.lineIndex == 1 then
--        --            return
--        --        end
--        --        self.lineIndex = self.lineIndex - 1
--        drawTest(1, 50)
--    end
--    local btnR = ccui.Button:create("common/spin.png")
--    btnR:setScale(0.2)
--    self.spinViewParent:getParent():addChild(btnR)
--    btnR:setPosition(-100, 200)
--    btnR:onTouch(subLine)

--    local testNode = cc.DrawNode:create()
--    local x, y = self.spinViewParent:getPosition()
--    testNode:setPosition(x - self.spinViewParent:getContentSize().width / 2, y - self.spinViewParent:getContentSize().height / 2)
--    self.spinViewParent:getParent():addChild(testNode, 100)
--    self.testNode = testNode

--    self.testLable = cc.Label:create()
--    self.spinViewParent:getParent():addChild(self.testLable, 100)
--    self.testLable:setSystemFontSize(30)
--end



-- endregion
