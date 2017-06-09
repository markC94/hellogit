--region *.lua
--Date
--此文件由[BabeLua]插件自动生成

local LobbyCoins = class("LobbyCoins", cc.Node)
LobbyCoins.POS_LOBBY = 1
LobbyCoins.POS_SPIN = 2
function LobbyCoins:ctor(node)
    self.pos=0
    if not node then
        self.node_coins = cc.CSLoader:createNode("csb/lobby/LobbyCoins.csb")
    else
        node:removeFromParent()
        self.node_coins = node
    end
    self:addChild(self.node_coins)

    self:registerScriptHandler(function(state)
        if state == "enter" then
            self:onEnter()
        elseif state == "exit" then
            self:onExit()
        end
    end)

    self.img_money = self.node_coins:getChildByName("img_money")
    local function touchEvent(sender, eventType)
        if eventType == ccui.TouchEventType.began then
        elseif eventType == ccui.TouchEventType.ended then
            print("show_shop")
        elseif eventType == ccui.TouchEventType.canceled then
        end
    end
    self.btn_buyMoney = self.img_money:getChildByName("btn_buyMoney")
    self.img_salebg = self.img_money:getChildByName("img_salebg")
    self.img_sale = self.img_salebg:getChildByName("img_sale")
    self.txt_money = self.img_money:getChildByName("txt_money")

    self.btn_buyMoney:setPressedActionEnabled(true)
    self.btn_buyMoney:addTouchEventListener(touchEvent)
    self.btn_buyMoney:setSwallowTouches(true)
    self:updateCoins(bole:getUserDataByKey("coins"))
    self:updatePos(self.POS_LOBBY)
end

function LobbyCoins:updatePos(pos)
    self.pos=pos
    if pos== self.POS_LOBBY then
        self.img_sale:setVisible(true)
        self.btn_buyMoney:setVisible(true)
        self:updateCoins()
    elseif pos== self.POS_SPIN then
        self.img_sale:setVisible(false)
        self.btn_buyMoney:setVisible(false)
        self:updateCoins()
    end
end
function LobbyCoins:onEnter()
    bole:addListener("coinsChanged", self.onCoins, self, nil, true)
end

function LobbyCoins:onExit()
    bole:getEventCenter():removeEventWithTarget("coinsChanged", self)
end


function LobbyCoins:onCoins(event)
    dump(event,"LobbyCoins:onCoins")
    local coins = event.result.result
    self:updateCoins(coins)
end

function LobbyCoins:updateCoins(coins)
    if not coins then
        coins=bole:getUserDataByKey("coins")
    end
    if self.pos== self.POS_LOBBY then
        self.txt_money:setString(bole:formatCoins(coins,12))
    elseif self.pos== self.POS_SPIN then
        self.txt_money:setString(bole:formatCoins(coins,4))
    end
    
end
return LobbyCoins

--endregion
