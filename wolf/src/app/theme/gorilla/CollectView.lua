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

    local app = theme:getSpinApp()
    local themeId = theme:getThemeId()
    local root = cc.CSLoader:createNode(app:getMiniRes(themeId, "collect/collectNode.csb"))
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
    bole:getUIManage():addTips(root,theme:getThemeId(),420,-70)
end

function CollectView:onEnter()
    bole:addListener("spin", self.onSpin, self, nil, true)
    bole:addListener("collectButterFly", self.onCollect, self, nil, true)
    bole:addListener("startFreeSpin", self.onStartFreeSpin, self, nil, true)
    bole:addListener("stopFreeSpin", self.onStopFreeSpin, self, nil, true)
    bole:addListener("gorillaAfterMini", self.onAfterMiniGame, self, nil, true)
end

function CollectView:onExit()
    bole:removeListener("spin", self)
    bole:removeListener("collectButterFly", self)
    bole:removeListener("startFreeSpin", self)
    bole:removeListener("stopFreeSpin", self)
    bole:removeListener("gorillaAfterMini", self)
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
    bole:getAudioManage():playAudioOnly("w2") --蝴蝶飞到位置的音效
    self:startProgressBar(self:getPercent(true))
    bole:runNum(self.lightCollectCoinNum, self.collectCoin-self.addCoin, self.collectCoin, ProgressTime,nil,nil,nil,"$")
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

function CollectView:onAfterMiniGame(event)
    print("CollectView:onAfterMiniGame")
    if self.collectProgress >= self.collectMaxCount then
        self.collectProgress = self.collectProgress - self.collectMaxCount
        self.collectCoin = 0
        self.lightCollectCoinNum:setString("$0")
        self:startProgressBar(0)
    end
end

function CollectView:getEndCallbackEvent(func)
    local callbackData = {}
    callbackData.callbackFunc = func
    self.callbackData = callbackData
    return callbackData
end

function CollectView:onCollect(event)
    local data = event.result
    if not data.collectProgress then
        return
    end

    self.addCoin = data.collectCoin-self.collectCoin
    self.collectCoin = data.collectCoin
    self.collectProgress = data.collectProgress
    local callbackData = self:getEndCallbackEvent(data.backFunc)
    for index, pos in ipairs(data.pos[1].pos) do
        local skeletonNode = self.skeletonCache[index]
        if not skeletonNode or not skeletonNode:isVisible() then
            skeletonNode = self.theme:genSkeletonNodeByPos(pos[1], pos[2], "trigger")
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
            local moveAction = cc.MoveTo:create(0.6, self.flyPosition)
            local scaleAction = cc.ScaleTo:create(0.6, 0.4)
            local callAction = cc.CallFunc:create(function()
                skeletonNode:setVisible(false)
                if index == 1 then
                    self:onCollectEnd(callbackData)
                end
            end)
            bole:getAudioManage():playAudioOnly("w3") --触发收集的蝴蝶时候的音效
            skeletonNode:runAction(cc.Sequence:create(cc.Spawn:create(moveAction, scaleAction), callAction))
        end

        skeletonNode:registerSpineEventHandler(function(event)
            if event.animation == skeletonNode.trigger then
                playMoveAction()
            end
        end , sp.EventType.ANIMATION_COMPLETE)
    end
end

function CollectView:setLightVisible(flag)
    self.lightNode:setVisible(flag)
    self.grayNode:setVisible(not flag)

    local rate = self.collectProgress/self.collectMaxCount*100
    if flag then
        self:startProgressBar(rate, true)
        bole:runNum(self.lightCollectCoinNum, 0, self.collectCoin, ProgressTime,nil,nil,nil,"$")
    else
        self.remainTime = 0
        self:setPercent(rate, false)
        self.grayCollectCoinNum:setString("$"..self.collectCoin)
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

function CollectView:startProgressBar(startValue, notGrowing)
    self:setPercent(startValue, true)
    self.animNode1:setVisible(true)
    self.animNode2:setVisible(true)

    if not notGrowing then
        self.remainTime = ProgressTime
        self.addValuePerSecond = (self.collectProgress/self.collectMaxCount*100 - startValue)/self.remainTime
        self:registerUpdate()
    end
end

function CollectView:updateProgressBar(dt)
    if self.remainTime <= 0 then
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
    local skeletonNode = sp.SkeletonAnimation:create(self.theme:getSpinApp():getSymbolAnim(self.theme:getThemeId(), "colect2"))
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
