--region *.lua
--Date
--此文件由[BabeLua]插件自动生成
local MagicFreeSpinView = class("MagicFreeSpinView", bole:getTable("app.theme.oz.FreeSpinView"))
function MagicFreeSpinView:ctor(theme, collectCount, totalCoin, order)
    self.collectCount = collectCount
    self.totalCoin = totalCoin
    MagicFreeSpinView.super.ctor(self, theme, order, "csb/theme/oz/MagicFreeSpinView.csb")
end

function MagicFreeSpinView:onEnter()
    MagicFreeSpinView.super.onEnter(self)
    bole:addListener("mng_dialog", self.onStopSpin, self, nil, true)
    bole:addListener("freeSpinCollect", self.onFreeSpinCollect, self, nil, true)
    bole:addListener("freeSpinTotalWin", self.onFreeSpinTotalWin, self, nil, true)
    bole:addListener("collectAnimation", self.onCollectAnimation, self, nil, true)
end

function MagicFreeSpinView:onExit()
    bole:removeListener("mng_dialog", self)
    bole:removeListener("freeSpinCollect", self)
    bole:removeListener("freeSpinTotalWin", self)
    bole:removeListener("collectAnimation", self)
    MagicFreeSpinView.super.onExit(self)
end

function MagicFreeSpinView:initData()
    MagicFreeSpinView.super.initData(self)
    self.freeSpinTotalNum:setString(self.totalCoin)
    self:setWildProgress(self.collectCount or 0)
    self.skeletonCache = {}
end

function MagicFreeSpinView:setViews(root)
    MagicFreeSpinView.super.setViews(self, root)
    local freeSpinBg = root:getChildByName("freeSpinBg")
    self.freeSpinBg = freeSpinBg
    self.dianNode = {}
    for i = 1, 15 do
        self.dianNode[i] = freeSpinBg:getChildByName("dian" .. i)
    end
    self.iconNode = {}
    self.wildNode = {}
    for i = 1, 4 do
        self.iconNode[i] = freeSpinBg:getChildByName("icon" .. i)
        self.wildNode[i] = freeSpinBg:getChildByName("wild" .. i)
    end

    self.freeSpinTotalNum = freeSpinBg:getChildByName("totalNum")
end

function MagicFreeSpinView:setWildProgress(index)
    for i = 1, index do
        self.dianNode[i]:setVisible(true)
    end
    for i = index+1, 15 do
        self.dianNode[i]:setVisible(false)
    end

    local wildIndex = math.floor(index/3)
    for i = 1, wildIndex do
        self.wildNode[i]:setVisible(true)
    end
    for i = wildIndex+1, 4 do
        self.wildNode[i]:setVisible(false)
    end
    self.collectCount = index
end

function MagicFreeSpinView:getNextCollectPos()
    local index = self.collectCount + 1
    if index > 15 then
        index = 15
    end
    local x,y = self.dianNode[index]:getPosition()
    return cc.p(x, y)
end

function MagicFreeSpinView:onCollectAnimation(event)
    local data = event.result
    local posArray = {}
    for _, info in ipairs(data) do
        for _, pos in ipairs(info.pos) do
            table.insert(posArray, pos)
        end
    end

    local function nextAction()
        if #posArray > 0 then
            local pos = table.remove(posArray, #posArray)

            local keyImage = self.theme:getSymbolNameByPos(pos[1], pos[2])
            local skeletonNode = self.skeletonCache[keyImage]
            if not skeletonNode then
                skeletonNode = self.theme:getSkeletonNodeByPos(pos[1], pos[2])
                self.skeletonCache[keyImage] = skeletonNode
                self.freeSpinBg:addChild(skeletonNode)
            else
                skeletonNode:setVisible(true)
                skeletonNode:setScale(1)
            end

            local startPosition = self.freeSpinBg:convertToNodeSpace(self.theme:getWorldPositionByPos(pos[1], pos[2], true))
            skeletonNode:setPosition(startPosition.x, startPosition.y)

            local playDisappearAction
            local playMoveAction
            skeletonNode:setAnimation(0, "trigger", false)
            skeletonNode:registerSpineEventHandler(function(event)
                if event.animation == "trigger" then
                    playMoveAction()
                end
            end , sp.EventType.ANIMATION_COMPLETE)

            playMoveAction = function()
                local endPosition = self:getNextCollectPos()
                local moveAction = cc.MoveTo:create(0.8, endPosition)
                local scaleAction = cc.ScaleTo:create(0.8, 0.4)
                local callAction = cc.CallFunc:create(function()
                    playDisappearAction()
                end)

                skeletonNode:runAction(cc.Sequence:create(cc.Spawn:create(moveAction, scaleAction), callAction))
            end

            playDisappearAction = function()
                skeletonNode:setAnimation(1, "disappear", false)
                skeletonNode:registerSpineEventHandler(function(event)
                    if event.animation == "disappear" then
                        skeletonNode:setVisible(false)
                        local curCollectCount = self.collectCount + 1
                        self:setWildProgress(curCollectCount)
                        if curCollectCount % 3 == 0 then
                            bole:postEvent("changeWildSymbol", curCollectCount)
                        end
                        nextAction()
                    end
                end , sp.EventType.ANIMATION_COMPLETE)
            end
        else
            bole:postEvent("collectAnimationEnd")
        end
    end
    
    if #posArray > 0 then
        nextAction()
    end
end

function MagicFreeSpinView:onFreeSpinTotalWin(event)
    self.freeSpinTotalNum:setString(event.result)
end

function MagicFreeSpinView:onStopSpin(event)
    self.spinForbidden = true
end

function MagicFreeSpinView:onFreeSpinCollect(event)
    self:setWildProgress(event.result)
end

return MagicFreeSpinView
--endregion
