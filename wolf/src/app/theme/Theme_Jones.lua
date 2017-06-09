--region *.lua
--Date
--此文件由[BabeLua]插件自动生成

local Theme_Jones = class("Theme_Jones", bole:getTable("app.theme.BaseTheme"))

function Theme_Jones:ctor(themeId, app)
    print("Theme_Jones:ctor")
    self.reSpinCount = 0
    Theme_Jones.super.ctor(self, themeId, app)
end

function Theme_Jones:onDealWithRespinData(data)
    self.lastRespinFlag = false
    local recordRespinData = data["re_spin_item_lists"]
    if recordRespinData then
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

function Theme_Jones:onFirstEnterCheck(event)
    print("Theme_Jones:onFirstEnterCheck")
    local result = event.result
    if result and result.wild then
        self.wildColumn = true
    end
    Theme_Jones.super.onFirstEnterCheck(self, event)
end

function Theme_Jones:onAutoRespin()
    self:startSpinRequest(self.freeSpinCount)

    if self.respinSp then
        self.respinSp:setTexture(string.format("theme/theme%s/respin/0%s.png", self.themeId, self.reSpinCount))
        self.respinSpNode:setAnimation(0, "animation", false)
    end

    bole:getAudioManage():playEff("jones_respin_start") --respin开始的音效
end

function Theme_Jones:spinRequest()
    print("Theme_Jones:spinRequest")
    if self.reSpinCount > 0 then
        local function falseDataCallback()
            local data = {}
            data.list = {}
            data.list[1] = self.thisReceiveData
            self:spinResponse("batch_spin", data)

            self.spinView:stopColumn(2)
            bole:postEvent("promptSuccess", 2)
        end
        self:addWaitEvent("falseDataCallback", 0.4, falseDataCallback)
    else
        Theme_Jones.super.spinRequest(self)
    end
end

function Theme_Jones:onDataFilter(data)
    print("Theme_Jones:onDataFilter")
    Theme_Jones.super.onDataFilter(self, data)

    self:onDealWithRespinData(data)
end

function Theme_Jones:createAnimLayer(parentNode, order, pos)
    Theme_Jones.super.createAnimLayer(self, parentNode, order, pos)

    local animNode = cc.Node:create()
    parentNode:addChild(animNode, order-1)
    animNode:setPosition(pos[1], pos[2])
    self.promptNode = animNode
end

function Theme_Jones:getPromptNode()
    return self.promptNode
end

function Theme_Jones:dealRespinAnimation()
    local fixedNum = 0
    for columnIndex = 2, #self.stopReels do
        local column = self.stopReels[columnIndex]
        for row, id in ipairs(column) do
            if id == 2 or id == 3 then
                fixedNum = fixedNum + 1
                self:onRemoveFixedSymbol(columnIndex, row)

                local newId = id
                if id == 2 then
                    newId = 15
                end
                local function endCallback()
                    fixedNum = fixedNum - 1
                    self:onCreateFixedSymbol(columnIndex, row, newId)
                    if fixedNum == 0 then
                        self:onAutoRespin()
                    end
                end
                self:createAnimNode(columnIndex, row, "bonus", false, true, endCallback)
            end
        end
    end

    if fixedNum == 0 then
        self:onAutoRespin()
    else
        bole:getAudioManage():playEff("jones_change") --在respin中有symbol hold住的音效
    end
end

function Theme_Jones:onStartRespin(data)
    print("Theme_Jones:onStartRespin")
    if self.freeSpinCount == 0 and self.wildColumn then
        self.wildColumn = false
    end

    if self.reSpinCount > 0 then
        self:dealRespinAnimation()
    else
        self:onNextPopup()
    end
end

function Theme_Jones:onDealWithMiniGameData(data)
    if data then
        dump(data, "Theme_Jones:onDealWithMiniGameData")
        if data.freeSpin and data.freeSpin > 0 then
            self.isHaveMiniGame = true
            self.freeSpinCount = data.freeSpin
        end
        
        if data.wild then
            self.wildColumn = true
        end
    end
end

function Theme_Jones:genFalseReels()
    Theme_Jones.super.genFalseReels(self)
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

function Theme_Jones:onNextPopup()
    self.curStepName = "reSpinOver"
    self:onNext()
end

function Theme_Jones:onMiniEffect(data)
    if self.lastRespinFlag then
        self:removeAnimNode(true)
        self:onClearFixedSymbolLayer()
        bole:getAudioManage():stopAudio("Jones_respin")--停止时调用
    end
    Theme_Jones.super.onMiniEffect(self, data)
end

function Theme_Jones:removeAnimNode(isIncludeClipAnimNode)
    if self.reSpinCount > 0 then return end
    self.respinSp = nil
    Theme_Jones.super.removeAnimNode(self, isIncludeClipAnimNode)
end

function Theme_Jones:onSpinViewStart()
    if self.reSpinCount > 0 then
        local ignoreColumns = {}
        ignoreColumns[1] = true
        Theme_Jones.super.onSpinViewStart(self, ignoreColumns)
    else
        Theme_Jones.super.onSpinViewStart(self)
    end
end

function Theme_Jones:getMiniGameLineData(data)
    local winLines = {}
    for _, line in ipairs(self.thisReceiveData["win_lines"]) do
        local feature = line.feature
        if feature ~= 0 and feature ~= 10102 and feature ~= 10104 then
            table.insert(winLines, line)
        end
    end
    return winLines
end

function Theme_Jones:addListeners()
    Theme_Jones.super.addListeners(self)
    self:addListenerForNext("reelStoped", self.onStartRespin)
    self:addListenerForNext("reSpinOver", self.onPopupDialog)
    self:addListenerForNext("popupDialog", self.onMiniEffect)
end

function Theme_Jones:setFreeSpinPosition(x, y)
    y = y - 9
    x = x - 15
    Theme_Jones.super.setFreeSpinPosition(self, x, y)
end

function Theme_Jones:creatRespinNumNode()
    print("Theme_Jones:creatRespinNumNode")
    local position = self:getSpinPositionByPos(1, 5, true)
    position.x = position.x - 30

    local spb = cc.Sprite:create(string.format("theme/theme%s/respin/04.png", self.themeId))
    self.animNode:addChild(spb)
    spb:setPosition(position.x, position.y)

    local spt = cc.Sprite:create(string.format("theme/theme%s/respin/03.png", self.themeId))
    spb:addChild(spt)
    spt:setPosition(spb:getContentSize().width/2, spb:getContentSize().height/2)
    self.respinSp = spt

    local node = sp.SkeletonAnimation:create(string.format("theme/theme%s/respin/jones_shiban.json", self.themeId), string.format("theme/theme%s/respin/jones_shiban.atlas", self.themeId))
    spb:addChild(node)
    node:setAnimation(0, "animation", false)
    node:setPosition(spb:getContentSize().width/2+1, spb:getContentSize().height/2-6)
    self.respinSpNode = node
end

function Theme_Jones:onColumnStop(columnIndex)
    if self.reSpinCount > 0 or self.lastRespinFlag then
        if columnIndex == 1 and self.reSpinCount == 2 then
            local key = "change"
            local skeletonNode = self:createAnimNode(columnIndex, 2, key, false)
            local projectName, animationName2 = self:getAnimName(self.stopReels[1][2], "fusion")
            skeletonNode:addAnimation(0, animationName2, true)

            self:creatRespinNumNode()
            bole:getAudioManage():playMusic("Jones_respin", true)--respin过程中的音乐,循环播放
        end

        local promptSuccessNode = self:getPromptNode()
        promptSuccessNode:setVisible(false)

        if self.clickStopManual then return end

        self.spinView:onTriggerColumnPrompt(columnIndex)
    else
        Theme_Jones.super.onColumnStop(self, columnIndex)
    end
end

function Theme_Jones:onPromptSuccess(event)
    local columnIndex = event.result
    print("Theme_Jones:onPromptSuccess column=" .. columnIndex)
    if self.reSpinCount > 0 or self.lastRespinFlag then
        local promptSuccessNode = self:getPromptNode()
        promptSuccessNode:setVisible(true)
        local skeletonNode = promptSuccessNode:getChildByTag(100)
        if not skeletonNode then
            skeletonNode = sp.SkeletonAnimation:create(string.format("theme/theme%s/respin.json", self.themeId), string.format("theme/theme%s/respin.atlas", self.themeId))
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

        bole:postEvent("audio_prompt_success", self.THEMENAME[self.themeId] .. "_respin")
    else
        Theme_Jones.super.onPromptSuccess(self, event)
    end
end

function Theme_Jones:onSpinPrompt(stopReels)
    if self.reSpinCount > 0 or self.lastRespinFlag then
        self.spinView:onStopWinBonusAction(1)
        self.spinView:onChangeWinBonus(7)
        return
    end

    local bonusWinReels = self:getBonusWin()
    if not bonusWinReels then return end

    self.promptSuccessId = nil
    self.promptBonusColumnIndex = {}
    self.promptBonusPos = {}

    local minWinColumnIndex = self.spinView:getColumnCount()
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

function Theme_Jones:addOtherAsyncImage(weights)
    local promptKey = string.format("theme/theme%d/respin.png", self.themeId)
    table.insert(weights, promptKey)
end

return Theme_Jones

--endregion
