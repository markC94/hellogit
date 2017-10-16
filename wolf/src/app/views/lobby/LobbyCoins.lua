-- region *.lua
-- Date
-- 此文件由[BabeLua]插件自动生成

local LobbyCoins = class("LobbyCoins", cc.Node)
LobbyCoins.POS_COINS_LOBBY = 1
LobbyCoins.POS_ZS_LOBBY = 2
LobbyCoins.POS_COINS_SPIN = 3
function LobbyCoins:ctor(isSlot)
    self.pos = 0
    self.isZS = false
    self.animate_time=1
    self.isSlot=isSlot
    self.node_coins = cc.CSLoader:createNode("csb/lobby/LobbyCoins.csb")
    self:addChild(self.node_coins,-3)
    self.coin=0
    self:registerScriptHandler( function(state)
        if state == "enter" then
            self:onEnter()
        elseif state == "exit" then
            self:onExit()
        end
    end )

    self.sp_money=self.node_coins:getChildByName("sp_money")
    self.sp_zs=self.node_coins:getChildByName("sp_zs")
    self.sp_add=self.node_coins:getChildByName("sp_add")

    local function touchEvent(sender, eventType)
        if eventType == ccui.TouchEventType.began then
        elseif eventType == ccui.TouchEventType.ended then
            bole:getUIManage():openNewUI("ShopLayer",true,"shop_lobby","app.views.shop")
            if self.isZS then
                bole:postEvent("openDiamondShop")
            end
        elseif eventType == ccui.TouchEventType.canceled then
        end
    end


    self.bg_act = sp.SkeletonAnimation:create("common_act/shoujiJB_ZS_1.json", "common_act/shoujiJB_ZS_1.atlas")
    self:addChild(self.bg_act, -2)
    self.act_icon = sp.SkeletonAnimation:create("common_act/JB_ZS_saoguang_1.json", "common_act/JB_ZS_saoguang_1.atlas")
    self:addChild(self.act_icon, -1)

    self.txt_money = self.node_coins:getChildByName("txt_money")
    self.btn_buyMoney = self.node_coins:getChildByName("btn_buyMoney")
    self.btn_buyMoney:setTouchEnabled(true)
    self.btn_buyMoney:addTouchEventListener(touchEvent)
    self.btn_buyMoney:setSwallowTouches(true)
end

function LobbyCoins:changeUI()
    if not self.isZS then
        self.bg_act:setPosition(-160, 0)
        self.act_icon:setPosition(-160, 0)
        self.btn_buyMoney:setContentSize(310, 47)
        self.sp_money:setVisible(true)
        self.sp_zs:setVisible(false)
        self.sp_add:setPosition(150, 0)
    else
        self.bg_act:setPosition(-85, 3)
        self.act_icon:setPosition(-85, 3)
        self.btn_buyMoney:setContentSize(190, 47)
        self.sp_money:setVisible(false)
        self.sp_zs:setVisible(true)
        self.sp_add:setPosition(85, 0)
    end
end

function LobbyCoins:updatePos(pos)
    self.pos = pos
    if pos == self.POS_COINS_LOBBY then
        self.bg_act:setAnimation(0, "JBidle", true)
        self.isZS = false
        self.act_icon:setAnimation(0, "JB", true)
    elseif pos == self.POS_ZS_LOBBY then
        self.bg_act:setAnimation(0, "ZSidle", true)
        self.isZS = true
        self.act_icon:setAnimation(0, "ZS", true)
    elseif pos == self.POS_COINS_SPIN then
        self.bg_act:setAnimation(0, "JBidle", true)
        self.isZS = false
        self.act_icon:setAnimation(0, "JB", true)
    end
    self:changeUI()
    self:initCoins()
end
function LobbyCoins:onEnter()
    if self.isSlot then
        bole:addListener("putWinCoinToTop", self.onCoinsChangedSlot, self, nil, true)
    else
        bole:addListener("coinsChanged", self.onCoins, self, nil, true)
        bole:addListener("coinsJump", self.onJump, self, nil, true)
        bole:addListener("diamondChanged", self.diamondChanged, self, nil, true)
    end
end

function LobbyCoins:onExit()
    if self.isSlot then
        bole:getEventCenter():removeEventWithTarget("putWinCoinToTop", self)
    else
        bole:getEventCenter():removeEventWithTarget("coinsChanged", self)
        bole:getEventCenter():removeEventWithTarget("coinsJump", self)
        bole:getEventCenter():removeEventWithTarget("diamondChanged", self)
    end
end

function LobbyCoins:onCoinsChangedSlot(event)
    local coin=event.result.coin
    if coin then
        print("----------------------------onCoinsChangedSlot coin="..coin)
        self:onCoinsChangedProgress(coin,1)
    end
end

function LobbyCoins:onCoinsChangedProgress(newCoin, useTime)
    local speed =(newCoin - self.coin) / useTime
    local spendTime = 0
    local function update(dt)
        if spendTime >= useTime then
            self:unscheduleUpdate()
        end
        spendTime = spendTime + dt
        if spendTime >= useTime then
            self.coin=newCoin
        else
            self.coin=self.coin+speed*dt
        end
        self.txt_money:setString(bole:formatCoins(self.coin,12))
    end
    self:onUpdate(update)
end


function LobbyCoins:diamondChanged(event)
    dump(event, "LobbyCoins:onCoins")
    local coins = event.result.changed
    if self.isZS then
        self:updateCoins(coins, coins>0)
    end
end

function LobbyCoins:onCoins(event)
    dump(event, "LobbyCoins:onCoins")
    local coins = event.result.changed
    if not self.isZS then
        self:updateCoins(coins, coins>0)
    end
end

function LobbyCoins:onJump(event)
    local data = event.result
    local pos = data.pos
    local time = data.time
    if pos == self.pos then
        if self.isZS then
            self.bg_act:setAnimation(0, "ZSjump", true)
            performWithDelay(self, function()
                self.bg_act:setAnimation(0, "ZSidle", true)
            end , time)
        else
            self.bg_act:setAnimation(0, "JBjump", true)
            performWithDelay(self, function()
                self.bg_act:setAnimation(0, "JBidle", true)
            end , time)
        end
    end
end

function LobbyCoins:setAnimaTime(time)
    self.animate_time=time
end

function LobbyCoins:initCoins()
    local num
    local coinsName
    if self.isZS then
        num = 5
        coinsName = "diamond"
    else
        num = 12
        coinsName = "coins"
    end

    local coins = bole:getUserDataByKey(coinsName)
    self.txt_money:setString(bole:formatCoins(coins, num))
    self.coin=coins
end

function LobbyCoins:updateCoins(changeCoins, isAnima)
    if self.isSlot then
        return
    end

    local num
    local coinsName
    if self.isZS then
        num = 5
        coinsName = "diamond"
    else
        num = 12
        coinsName = "coins"
    end

    local coins = bole:getUserDataByKey(coinsName)
    if isAnima then
        bole:runNum(self.txt_money, coins - changeCoins, coins, self.animate_time, nil, { num },false)
    else
        self.txt_money:setString(bole:formatCoins(coins, num))
    end
end
return LobbyCoins

-- endregion
