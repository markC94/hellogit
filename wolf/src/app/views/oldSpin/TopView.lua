--region *.lua
--Date
--此文件由[BabeLua]插件自动生成

local TopView = class("TopView")
function TopView:ctor(theme, order)
    self.theme = theme

    local rootNode = cc.CSLoader:createNode("csb/spin/topView.csb")
    self.rootNode = rootNode

    self:setViews(rootNode)
    self:setClickListener(rootNode)
    self:initUserData()

    rootNode:registerScriptHandler(function(state)
        if state == "enter" then
            self:onEnter()
        elseif state == "exit" then
            self:onExit()
        end
    end)

    theme:addChild(rootNode, order, order)
end

function TopView:initUserData()
    self.coinNum:setString(bole:getUserDataByKey("coins"))
    self.expNum:setString(bole:getUserDataByKey("level"))
    self:addExp(self.expProgress)
    self.freeSpinIcon:setVisible(false)
end

function TopView:addExp(node_bar)
    node_bar:setPercent(bole:getExpPercent())
end

function TopView:onEnter()
    self.isDead = false
    bole:addListener("coinsChanged", self.onCoinChanged, self, nil, true)
    bole:addListener("experienceChanged", self.onExpChanged, self, nil, true)
    bole:addListener("levelChanged", self.onLevelChanged, self, nil, true)
    bole:addListener("freeSpinNum", self.onFreeSpinNum, self, nil, true)
    bole:addListener("startFreeSpin", self.onStartFreeSpin, self, nil, true)
    bole:addListener("stopFreeSpin", self.onStopFreeSpin, self, nil, true)
   
    
end

function TopView:onExit()
    bole:getEventCenter():removeEventWithTarget("coinsChanged", self)
    bole:getEventCenter():removeEventWithTarget("experienceChanged", self)
    bole:getEventCenter():removeEventWithTarget("levelChanged", self)
    bole:getEventCenter():removeEventWithTarget("freeSpinNum", self)
    bole:getEventCenter():removeEventWithTarget("startFreeSpin", self)
    bole:getEventCenter():removeEventWithTarget("stopFreeSpin", self)


    self.isDead = true
end

function TopView:onCoinChanged(event)
    local result = event.result
    self.coinNum:setString(result.result)
end

function TopView:onExpChanged(event)
    local result = event.result
    self:addExp(self.expProgress)
end

function TopView:onLevelChanged(event)
    local result = event.result
    self.expNum:setString(result.result)
end

function TopView:onFreeSpinNum(event)
    self.freeSpinNum:setString(event.result)
end

function TopView:onStartFreeSpin(event)
    self.freeSpinIcon:setVisible(true)
    local action = cc.MoveBy:create(0.4, cc.p(0, -72))
    self.freeSpinIcon:runAction(action)
    if event.result then
        self.freeSpinNum:setString(event.result)
    end
end

function TopView:onStopFreeSpin(event)
    local moveByAction = cc.MoveBy:create(0.4, cc.p(0, 72))
    local function callback()
        self.freeSpinIcon:setVisible(false)
    end
    local callFuncAction = cc.CallFunc:create(callback)
    self.freeSpinIcon:runAction(cc.Sequence:create(moveByAction, callFuncAction))
end

function TopView:setClickListener()
    self.lobbyBtn = self.rootNode:getChildByName("lobby")
    self.buyBtn = self.rootNode:getChildByName("buyCoin")
    self.menuBtn = self.rootNode:getChildByName("menu")

    local function onClick(event)
        if event.name == "ended" then
            if event.target == self.lobbyBtn then
                bole:postEvent("enterLobby")
            elseif event.target == self.buyBtn then
            elseif event.target == self.menuBtn then
            end
        end
    end

    self.lobbyBtn:onTouch(onClick)
    self.buyBtn:onTouch(onClick)
    self.menuBtn:onTouch(onClick)
end

function TopView:setViews(rootNode)
    self.freeSpinIcon = rootNode:getChildByName("freeSpinIcon")
    self.freeSpinNum = self.freeSpinIcon:getChildByName("freeSpinNum")

    self.coinNum = rootNode:getChildByName("coinBg"):getChildByName("coinLabel")

    local expBg = rootNode:getChildByName("expBg")
    self.expNum = expBg:getChildByName("expLabel")
    self.expProgress = expBg:getChildByName("expProgress")
end

function TopView:removeFromParent(isCleanup)
    self.rootNode:removeFromParent(isCleanup)
end

return TopView


--endregion
