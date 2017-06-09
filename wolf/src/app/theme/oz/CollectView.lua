--region *.lua
--Date
--此文件由[BabeLua]插件自动生成
local CollectView = class("CollectView")
function CollectView:ctor(theme, collectMaxCount, collectProgress, collectCoin, order)
    self.theme = theme

    self.collectMaxCount = collectMaxCount
    self.collectProgress = collectProgress
    self.collectCoin = collectCoin

    local root = cc.CSLoader:createNode("csb/theme/oz/collectView.csb")
    root:registerScriptHandler(function(state)
        if state == "enter" then
            self:onEnter()
        elseif state == "exit" then
            self:onExit()
        end
    end)
    self:setViews(root)
    theme:addChild(root, order, order)

    self.collectNode = root
    self:initData()
end

function CollectView:onEnter()
    self.isDead = false
    bole:addListener("collectProgress", self.onCollect, self, nil, true)
    bole:addListener("collectAnimation", self.onCollectAnimation, self, nil, true)
end

function CollectView:onExit()
    bole:removeListener("collectProgress", self)
    bole:removeListener("collectAnimation", self)
    self.isDead = false
end

function CollectView:onCollect(event)
    if self.collectMaxCount then
        local data = event.result
        self:setCollectData(data.coin, data.progress)
    end
end

function CollectView:onCollectAnimation(event)
    if not self.collectMaxCount then
        return
    end

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
                self.collectNode:addChild(skeletonNode)
            else
                skeletonNode:setVisible(true)
                skeletonNode:setScale(1)
            end

            local startPosition = self.collectNode:convertToNodeSpace(self.theme:getWorldPositionByPos(pos[1], pos[2], true))
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
                local x, y = self.collectWalkNode:getPosition()
                local endPosition = cc.p(x, y)
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
                        self:setCollectData(nil, self.collectProgress+1)
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

function CollectView:initData()
    if self.collectMaxCount then
        self:setCollectData(self.collectCoin, self.collectProgress, true)
        self.skeletonCache = {}
    else
        self.collectNode:setVisible(false)
    end
end

function CollectView:setCollectData(coin, curProgress, isFirst)
    if curProgress and (isFirst or self.collectProgress ~= curProgress) then
        if curProgress > self.collectMaxCount then
            curProgress = self.collectMaxCount
        end
        self.collectProgressNum:setString(curProgress .. "/" .. self.collectMaxCount)

        local rate = curProgress/self.collectMaxCount*100
        self.collectProgressBar:setPercent(rate)

--        if rate >= 6 then
            self.collectWalkNode:setVisible(true)
            local posX = rate*70/6 - 2
            self.collectWalkNode:setPositionX(posX)
--        else
--            self.collectWalkNode:setVisible(false)
--        end
        self.collectProgress = curProgress
    end

    if coin and (isFirst or self.collectCoin ~= coin) then
        self.collectCoinNum:setString(coin)
        self.collectCoin = coin
    end
end

function CollectView:setViews(root)
    local collectNumBg = root:getChildByName("collect")
    self.collectProgressNum = collectNumBg:getChildByName("collectDiamondNum")
    self.collectCoinNum = collectNumBg:getChildByName("collectCoinNum")

    self.collectProgressBar = root:getChildByName("bottomProgressBar")
    self.collectWalkNode = root:getChildByName("progressWalk")
    self.collectGirl = self.collectWalkNode:getChildByName("progressbarGirl")
end

function CollectView:removeFromParent(isCleanup)
    self.collectNode:removeFromParent(isCleanup)
end

return CollectView
--endregion
