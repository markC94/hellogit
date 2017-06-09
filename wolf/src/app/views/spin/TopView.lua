--region *.lua
--Date
--此文件由[BabeLua]插件自动生成

local TopView = class("TopView")
function TopView:ctor(theme, order)
    self.theme = theme

    local rootNode = cc.CSLoader:createNodeWithVisibleSize("csb/spin/topView.csb")
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
--    self.coinNum:setString(bole:getUserDataByKey("coins"))
--    self.expNum:setString(bole:getUserDataByKey("level"))
--    self:addExp(self.expProgress)
--    self.freeSpinIcon:setVisible(false)
end

function TopView:addExp(node_bar)
--    node_bar:setPercent(bole:getExpPercent())
end

function TopView:onEnter()
    self.isDead = false
--    bole:addListener("coinsChanged", self.onCoinChanged, self, nil, true)
--    bole:addListener("experienceChanged", self.onExpChanged, self, nil, true)
--    bole:addListener("levelChanged", self.onLevelChanged, self, nil, true)
--    bole:addListener("freeSpinNum", self.onFreeSpinNum, self, nil, true)
--    bole:addListener("startFreeSpin", self.onStartFreeSpin, self, nil, true)
--    bole:addListener("stopFreeSpin", self.onStopFreeSpin, self, nil, true)
end

function TopView:onExit()
--    bole:getEventCenter():removeEventWithTarget("coinsChanged", self)
--    bole:getEventCenter():removeEventWithTarget("experienceChanged", self)
--    bole:getEventCenter():removeEventWithTarget("levelChanged", self)
--    bole:getEventCenter():removeEventWithTarget("freeSpinNum", self)
--    bole:getEventCenter():removeEventWithTarget("startFreeSpin", self)
--    bole:getEventCenter():removeEventWithTarget("stopFreeSpin", self)

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
    local rightPart = self.rootNode:getChildByName("rightInfo")

    self.saleBtn = rightPart:getChildByName("saleBt")
    self.saleTimeNum = self.saleBtn:getChildByName("saleNum")
    self.filmBtn = rightPart:getChildByName("filmBt")
    self.menuBtn = rightPart:getChildByName("setupBt")

    local function onClick(event)
        if event.name == "ended" then
            if event.target == self.menuBtn then
                local view = bole:getUIManage():getSimpleLayer(bole.UI_NAME.Options)
                view:setDialog(true)
                self.theme:addOptions(view)
            elseif event.target == self.saleBtn then
            elseif event.target == self.filmBtn then
            end
        end
    end

    self.saleBtn:onTouch(onClick)
    self.filmBtn:onTouch(onClick)
    self.menuBtn:onTouch(onClick)

    self.saleBtn:setPressedActionEnabled(true)
    self.filmBtn:setPressedActionEnabled(true)
    self.menuBtn:setPressedActionEnabled(true)
end

function TopView:setViews(rootNode)
--    self.freeSpinIcon = rootNode:getChildByName("freeSpinIcon")
--    self.freeSpinNum = self.freeSpinIcon:getChildByName("freeSpinNum")

--    self.coinNum = rootNode:getChildByName("coinBg"):getChildByName("coinLabel")

--    local expBg = rootNode:getChildByName("expBg")
--    self.expNum = expBg:getChildByName("expLabel")
--    self.expProgress = expBg:getChildByName("expProgress")
    local headPart = rootNode:getChildByName("headInfo")
    
    
    local coinsNode = headPart:getChildByName("coinsNode")
    local nCoins = bole:getNewCoinsView()
    nCoins:updatePos(nCoins.POS_SPIN)
    coinsNode:addChild(nCoins)

    local headNode = headPart:getChildByName("headNode")
    local head = bole:getNewHeadView(bole:getUserData())
    headNode:addChild(head)
    head:updatePos(head.POS_SPIN_SELF)

    local expNode = headPart:getChildByName("expNode")
    local exp = bole:getNewExpView()
    expNode:addChild(exp)

    local diamond = headPart:getChildByName("diamondNum")
    diamond:setString(bole:getUserData():getDataByKey("diamond"))
end

function TopView:removeFromParent(isCleanup)
    self.rootNode:removeFromParent(isCleanup)
end

return TopView


--endregion
