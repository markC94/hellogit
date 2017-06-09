--region *.lua
--Date
--此文件由[BabeLua]插件自动生成

local CollectView = class("CollectView")
local ProgressTime = 1
function CollectView:ctor(theme, collectMaxCount, collectProgress, collectCoin, order, position)
    self.theme = theme

    self.collectMaxCount = collectMaxCount
    self.collectProgress = collectProgress
    self.collectCoin = collectCoin
    self.addCoin = collectCoin
    self.ratePos = 5.6
    self.skeletonCache = {}
    self.callbackData = {}

    local root = cc.CSLoader:createNode("csb/theme/gorilla/collectNode.csb")
    self.collectNode = root

    root:registerScriptHandler(function(state)
        if state == "enter" then
            self:onEnter()
        elseif state == "exit" then
            self:onExit()
        end
    end)

    self:setViews(root)
    theme:addChild(root, order, order)
    root:setPosition(position.x, position.y)
end

function CollectView:onEnter()
    self.isDead = false
    bole:addListener("spin", self.onSpin, self, nil, true)
    bole:addListener("collectButterFly", self.onCollect, self, nil, true)
    bole:addListener("startFreeSpin", self.onStartFreeSpin, self, nil, true)
    bole:addListener("stopFreeSpin", self.onStopFreeSpin, self, nil, true)
end

function CollectView:onExit()
    bole:removeListener("spin", self)
    bole:removeListener("collectButterFly", self)
    bole:removeListener("startFreeSpin", self)
    bole:removeListener("stopFreeSpin", self)
    self.isDead = false
end

function CollectView:onSpin(event)
    self.callbackData.callbackFunc = nil
end

function CollectView:onStartFreeSpin(event)
    self:setLightVisible(fasle)
end

function CollectView:onStopFreeSpin(event)
    self:setLightVisible(true)
end

function CollectView:onCollectEnd(data)
    self.butterflyAnimNode:setAnimation(0, "animation", false)
    bole:getAudioManage():playEff("gorilla_collection2") --蝴蝶飞到位置的音效
    self:startProgressBar(self:getPercent(true))
    bole:runNum(self.lightCollectCoinNum, self.collectCoin-self.addCoin, self.collectCoin, ProgressTime)
    self.butterflyAnimNode:registerSpineEventHandler(function(event)
        if event.animation == "animation" then
            if data and data.callbackFunc then
                data.callbackFunc(self)
            end

            for i = #self.skeletonCache, 4, -1 do
                self.skeletonCache[i]:removeFromParent(true)
                self.skeletonCache[i] = nil
            end
        end
    end , sp.EventType.ANIMATION_COMPLETE)
end

function CollectView:onEndCallbackFunc()
    bole:postEvent("collectButterFlyEnd")
end

function CollectView:afterMiniGame()
    print("CollectView:afterMiniGame")
    if self.collectProgress >= self.collectMaxCount then
        self.collectProgress = self.collectProgress - self.collectMaxCount
        self.collectCoin = 0
        self.lightCollectCoinNum:setString(0)
        self:startProgressBar(0)
    end
end

function CollectView:getEndCallbackEvent()
    local callbackData = {}
    callbackData.callbackFunc = self.onEndCallbackFunc
    self.callbackData = callbackData
    return callbackData
end

function CollectView:onCollect(event)
    local data = event.result

    if not data.collectProgress then
        self:onEndCallbackFunc()
        return
    end

    self.addCoin = self.collectCoin - data.collectCoin
    self.collectCoin = data.collectCoin
    self.collectProgress = data.collectProgress
    
    local callbackData = self:getEndCallbackEvent()
    bole:getAudioManage():playEff("gorilla_collection1") --触发收集的蝴蝶时候的音效
    for index, pos in ipairs(data.pos[1].pos) do
        local skeletonNode = self.skeletonCache[index]
        if not skeletonNode then
            skeletonNode = self.theme:getSkeletonNodeByPos(pos[1], pos[2], "trigger")
            self.skeletonCache[index] = skeletonNode
            self.collectNode:addChild(skeletonNode)
        else
            skeletonNode:setVisible(true)
            skeletonNode:setScale(1)
            skeletonNode:setToSetupPose()
        end
        self.theme:removeButterFly(pos[1], pos[2])

        local startPosition = self.collectNode:convertToNodeSpace(self.theme:getWorldPositionByPos(pos[1], pos[2], true))
        skeletonNode:setPosition(startPosition.x, startPosition.y)
        skeletonNode:setAnimation(0, skeletonNode.trigger, false)
        skeletonNode:addAnimation(0, "fly", true)

        local playMoveAction = function()
            local moveAction = cc.MoveTo:create(0.8, self.flyPosition)
            local scaleAction = cc.ScaleTo:create(0.8, 0.4)
            local callAction = cc.CallFunc:create(function()
                skeletonNode:setVisible(false)
                if index == 1 then
                    self:onCollectEnd(callbackData)
                end
            end)

            skeletonNode:runAction(cc.Sequence:create(cc.Spawn:create(moveAction, scaleAction), callAction))
        end

        skeletonNode:registerSpineEventHandler(function(event)
            if event.animation == skeletonNode.trigger then
                playMoveAction()
            end
        end , sp.EventType.ANIMATION_COMPLETE)
    end
end

--function CollectView:setCollectData(coin, curProgress)
--    if curProgress > self.collectMaxCount then
--        curProgress = self.collectMaxCount
--    end

--    local rate = curProgress / self.collectMaxCount * 100
--    self.collectProgressBar:setPercent(rate)

--    local posX = rate * self.ratePos
--    self.collectWalkNode:setPositionX(0.4 + posX)
--    self.collectProgress = curProgress

--    self.collectCoinNum:setString(coin)
--end

function CollectView:setLightVisible(flag)
    self.lightNode:setVisible(flag)
    self.grayNode:setVisible(not flag)

    local rate = self.collectProgress/self.collectMaxCount*100
    if flag then
        self:startProgressBar(0)
        bole:runNum(self.lightCollectCoinNum, 0, self.collectCoin, ProgressTime)
    else
        self.remainTime = 0
        self:setPercent(rate, false)
        self.grayCollectCoinNum:setString(self.collectCoin)
    end
end

function CollectView:setPercent(rate, flag)
    local posX = rate * self.ratePos

    if flag then
        self.lightCollectProgressBar:setPercent(rate)
        self.lightCollectWalkNode:setPositionX(0.4 + posX)
    else
        self.grayCollectProgressBar:setPercent(rate)
        self.grayCollectWalkNode:setPositionX(0.4 + posX)
    end
end

function CollectView:getPercent(flag)
    if flag then
        return self.lightCollectProgressBar:getPercent()
    else
        return self.grayCollectProgressBar:getPercent()
    end
end

function CollectView:startProgressBar(startValue)
    self.remainTime = ProgressTime
    self:setPercent(startValue, true)
    self.addValuePerSecond = (self.collectProgress/self.collectMaxCount*100 - startValue)/self.remainTime
    self.animNode1:setVisible(true)
    self.animNode2:setVisible(true)
    self:registerUpdate()
end

function CollectView:updateProgressBar(dt)
    if self.remainTime <= 0 then
        self.animNode1:setVisible(false)
        self.animNode2:setVisible(false)
        self:unregisterUpdate()
        return
    end

    self.remainTime = self.remainTime - dt

    if self.remainTime <= 0 then
        self:setPercent(self.collectProgress/self.collectMaxCount*100, true)
    else
        local value = self.addValuePerSecond*dt
        local curPercent = self:getPercent(true)
        self:setPercent(curPercent+value, true)
    end
end

function CollectView:setViews(root)
    local lightNode = root:getChildByName("light")
    local grayNode = root:getChildByName("gray")
    self.lightNode = lightNode
    self.grayNode = grayNode

    self.lightCollectCoinNum = lightNode:getChildByName("numBg"):getChildByName("num")
    self.grayCollectCoinNum = grayNode:getChildByName("numBg"):getChildByName("num")

    local barBg = lightNode:getChildByName("barBg")
    self.lightCollectProgressBar = barBg:getChildByName("bar")
    self.lightCollectWalkNode = barBg:getChildByName("light")

    local grayBarBg = grayNode:getChildByName("barBg")
    self.grayCollectProgressBar = grayBarBg:getChildByName("bar")
    self.grayCollectWalkNode = grayBarBg:getChildByName("light")

    self.animNode1 = self.lightCollectWalkNode:getChildByName("anim1")
    self.animNode2 = self.lightCollectWalkNode:getChildByName("anim2")

    local node = lightNode:getChildByName("icon")
    local x, y = node:getPosition()
    self.flyPosition = cc.p(x, y)
    local projectName = "colect2"
    local skeletonNode = sp.SkeletonAnimation:create(string.format("theme/theme%s/symbolAnimal/%s.json", self.theme:getThemeId(), projectName), string.format("theme/theme%s/symbolAnimal/%s.atlas", self.theme:getThemeId(), projectName))
    node:addChild(skeletonNode)
    self.butterflyAnimNode = skeletonNode

    self:setLightVisible(true)
end

function CollectView:registerUpdate()
    local function updateProgressBar(dt)
        self:updateProgressBar(dt)
    end
    self.collectNode:onUpdate(updateProgressBar)
end

function CollectView:unregisterUpdate()
    self.collectNode:unscheduleUpdate()
end

function CollectView:removeFromParent(isCleanup)
    self.collectNode:removeFromParent(isCleanup)
end

return CollectView

--endregion
