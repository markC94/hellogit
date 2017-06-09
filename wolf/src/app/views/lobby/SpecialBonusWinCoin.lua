--region *.lua
--Date
--此文件由[BabeLua]插件自动生成
local SpecialBonusWinCoin = class("SpecialBonusWinCoin", cc.Node)
function SpecialBonusWinCoin:ctor(auto,endPos,func)
    if endPos then
        self.endPos=endPos
    else
        self.endPos=cc.p(100,700)
    end
    local bonusNode = sp.SkeletonAnimation:create("specialBonusAnim/coin_boom.json", "specialBonusAnim/coin_boom.atlas")
    self:addChild(bonusNode)
    bonusNode:setAnimation(0, "animation1", true)

    self.bonusNode = bonusNode
    self.touchRect = cc.rect(-80, -80, 160, 160)
    self.touchEnabled = true
    self.isFlying = false

    local function onTouchBegan(touch, event)
        return self:onTouchBegan(touch, event)
    end
    local function onTouchEnded(touch, event)
        self:onTouchEnded(touch, event)
    end
    local eventListener = cc.EventListenerTouchOneByOne:create()
    eventListener:registerScriptHandler(onTouchBegan, cc.Handler.EVENT_TOUCH_BEGAN)
    eventListener:registerScriptHandler(onTouchEnded, cc.Handler.EVENT_TOUCH_ENDED)
    eventListener:setSwallowTouches(true)
    self:getEventDispatcher():addEventListenerWithSceneGraphPriority(eventListener, self)

    if auto then
        self:startBonusAnim()
    end
    if func then
        self.endFunc=func
    end
end

function SpecialBonusWinCoin:startBonusAnim()
    self.isFlying = true

    local bonusNode = self.bonusNode
    bonusNode:setToSetupPose()
    bonusNode:setAnimation(0, "animation2", false)
    bonusNode:addAnimation(0, "animation3", false)

    bonusNode:registerSpineEventHandler(function(event)
        local eventData = event.eventData
        if event.animation == "animation3" and eventData and eventData.name == "1" then
            self:flowerCoin()
        end
    end, sp.EventType.ANIMATION_EVENT)

    local centerPos = self:convertToNodeSpace(display.center)
    local moveByAction = cc.MoveBy:create(0.6667, cc.p(0, centerPos.y))
    bonusNode:runAction(moveByAction)
end

local durationTime = 1.2
local randomNum1 = 5
local randomNum2 = 9
local eachWaitTime = 0.1
function SpecialBonusWinCoin:flowerCoin()
    local particleNode1 = cc.ParticleSystemQuad:create("specialBonusAnim/particle_texture.plist")
    self:addChild(particleNode1)
    local x, y = self.bonusNode:getPosition()
    particleNode1:setPosition(x, y)

    local particleNode2 = cc.ParticleSystemQuad:create("specialBonusAnim/particle_texture2.plist")
    self:addChild(particleNode2)
    particleNode2:setPosition(x, y)

    local spendTime = 0
    local eachSpendTime = 0
    local stopLaunch = false
    local launchFunc
    local hideLaunchNodeFunc
    local flyEndFunc
    local cacheCoinNodes = {}
    local launchOneCoin
    local function update(dt)
        spendTime = spendTime + dt

        if spendTime > durationTime then
            stopLaunch = true
            hideLaunchNodeFunc()
            self:unscheduleUpdate()
            return
        end

        eachSpendTime = eachSpendTime + dt
        if eachSpendTime >= eachWaitTime then
            eachSpendTime = eachSpendTime - eachWaitTime
            launchFunc()
        end
    end
    self:onUpdate(update)

    local launchCount = 0
    local timeCount = 0
    launchFunc = function()
        local num = math.random(randomNum1, randomNum2)
        launchCount = launchCount + num
        local decreaseRate = 1-timeCount*0.06
        for i = 1, num do
            launchOneCoin(decreaseRate)
        end
        timeCount = timeCount + 1
    end

    launchOneCoin = function(decreaseRate)
        local coinNode = sp.SkeletonAnimation:create("common/coin_turnd.json", "common/coin_turnd.atlas", math.random(6, 12)/10)
        self:addChild(coinNode)
        table.insert(cacheCoinNodes, coinNode)

        coinNode:setPosition(x + math.random(-15, 15), y + math.random(-15, 15))
        local randomRotation = math.random(360)
        coinNode:setRotation(randomRotation)
        coinNode:setAnimation(0, "animation" .. math.random(5), true)
        coinNode:setOpacity(0)

        local flyLen = math.random(240*decreaseRate, 280*decreaseRate)
        local radians = math.rad(randomRotation)
        local newX = flyLen*math.cos(radians)
        local newY = flyLen*math.sin(radians)
        local moveByAct = cc.MoveBy:create(0.5*decreaseRate, cc.p(newX, newY))
        local easeInAct = cc.EaseIn:create(moveByAct, 1)
        local moveByAct = cc.MoveBy:create(0.3*decreaseRate, cc.p(newX/6, newY/6))
        local easeOutAct = cc.EaseOut:create(moveByAct, 1)
        local fadeIn = cc.FadeIn:create(0.2)
        local moveToAct = cc.MoveTo:create(0.6, self:convertToNodeSpace(self.endPos))
        local easeInOutAct = cc.EaseInOut:create(moveToAct, 1)
        local fadeOutAct = cc.FadeOut:create(0.3)
        local endCallAct = cc.CallFunc:create(function()
            launchCount = launchCount - 1
            flyEndFunc()
        end)
        coinNode:runAction(cc.Sequence:create(cc.Spawn:create(fadeIn, easeInAct), easeOutAct, easeInOutAct, fadeOutAct, endCallAct))
    end

    hideLaunchNodeFunc = function()
        if particleNode1 then
            local nodes = {particleNode1, particleNode2, self.bonusNode}
            for _, hideNode in ipairs(nodes) do
                local fadeOut = cc.FadeOut:create(0.3)
                local function endbackFunc()
                    hideNode:removeFromParent(true)
                end
                local callAction = cc.CallFunc:create(endbackFunc)
                hideNode:runAction(cc.Sequence:create(fadeOut, callAction))
            end
            particleNode1 = nil
        end
    end

    local isRemoveSelf = false
    flyEndFunc = function()
        if launchCount == 0 and stopLaunch and not self.isDead and not isRemoveSelf then
            isRemoveSelf = true
            if self.endFunc then
                self.endFunc()
            end
            self:removeFromParent(true)
        end
    end
end

function SpecialBonusWinCoin:onEnter()
    self.isDead = false
end

function SpecialBonusWinCoin:onExit()
    self.isDead = true
end

function SpecialBonusWinCoin:onTouchBegan(touch, event)
    if self.isFlying then return true end

    if not self.touchEnabled then return false end

    local pos = touch:getLocation()
    local point = self:convertToNodeSpace(pos)
    if cc.rectContainsPoint(self.touchRect, point) then
        return true
    end

    return false
end

function SpecialBonusWinCoin:onTouchEnded(touch, event)
    if self.isFlying then return end

    if not self.touchEnabled then return end

    local pos = touch:getLocation()
    local point = self:convertToNodeSpace(pos)
    if cc.rectContainsPoint(self.touchRect, point) then
        self:startBonusAnim()
    end
end

return SpecialBonusWinCoin
--endregion
