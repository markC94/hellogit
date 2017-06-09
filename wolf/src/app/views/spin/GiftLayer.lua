--region *.lua
--Date
--此文件由[BabeLua]插件自动生成

local GiftLayer = class("GiftLayer", cc.load("mvc").ViewBase)

GiftLayer.givecoinsId = {101, 102, 103, 104, 105}
GiftLayer.buydrinksId = {101, 102, 103, 104, 105}

function GiftLayer:onCreate()
    print("GiftLayer-onCreate")
    self.root_ = self:getCsbNode():getChildByName("root")
    self.buyPanel_ = self:getCsbNode():getChildByName("buy_panel")

    self:initBuyPanel()
    self:initTop()
    self:initListView()
    self:adaptScreen()
end

function GiftLayer:onEnter()
    bole:addListener("initGiftLayer", self.initGiftLayer, self, nil, true)
    bole:addListener("closeGiftLayer", self.closeGiftLayer, self, nil, true)
end

function GiftLayer:initGiftLayer(data)
    data = data.result
    self.playerId_ = tonumber(data)
    --[[
    self.coinsInfo_ = bole:getConfigCenter():getConfig("givecoins")
    table.sort(self.coinsInfo_, function(a,b) return a.givecoins_id > b.givecoins_id end)
    self.drinkInfo_ = bole:getConfigCenter():getConfig("buydrinks")
    table.sort(self.drinkInfo_, function(a,b) return a.givecoins_id > b.givecoins_id end)
    --]]
    self:refrushButton("coins")
end

function GiftLayer:initTop()
    local btn_coins = self.root_:getChildByName("btn_coins")
    btn_coins:addTouchEventListener(handler(self, self.touchEvent))

    local btn_drink = self.root_:getChildByName("btn_drink")
    btn_drink:addTouchEventListener(handler(self, self.touchEvent))

    local btn_close = self.root_:getChildByName("btn_close")
    btn_close:addTouchEventListener(handler(self, self.touchEvent))

    self.give_type_ = 1
end

function GiftLayer:initListView()
    self.listView_ = self.root_:getChildByName("ListView")
end

function GiftLayer:initBuyPanel()
    local btn_buyR = self.buyPanel_:getChildByName("btn_buyR")
    btn_buyR:addTouchEventListener(handler(self, self.touchEvent))

    local btn_buyO = self.buyPanel_:getChildByName("btn_buyO")
    btn_buyO:addTouchEventListener(handler(self, self.touchEvent))
end


function GiftLayer:refrushButton(str)
    self.root_:getChildByName("btn_coins"):setTouchEnabled(true)
    self.root_:getChildByName("btn_drink"):setTouchEnabled(true)

    self.root_:getChildByName("img_coins"):setVisible(false)
    self.root_:getChildByName("img_drink"):setVisible(false)
 
    self.root_:getChildByName("txt_coins"):setTextColor({ r = 119, g = 121, b = 159})
    self.root_:getChildByName("txt_drink"):setTextColor({ r = 119, g = 121, b = 159})


    self.root_:getChildByName("btn_" .. str):setTouchEnabled(false)
    self.root_:getChildByName("img_" .. str):setVisible(true)
    self.root_:getChildByName("txt_" .. str):setTextColor({ r = 255, g = 255, b = 255})

    if str == "coins" then
        self.give_type_ = 1
    elseif str == "drink" then
        self.give_type_ = 2
    end

    self:refrushListView(str)
end

function GiftLayer:refrushListView(str)
    self.listView_:removeAllChildren()
    if str == "coins" then
        for i = 1, 5 do
            local cell = self:createBuyCoinsPanel(i)
            self.listView_:pushBackCustomItem(cell)
        end
    elseif str == "drink" then
        for i = 1, 5 do
            local cell = self:createBuyDrinkPanel(i)
            self.listView_:pushBackCustomItem(cell)
        end
    end
end

function GiftLayer:createBuyCoinsPanel(i)
    local info = bole:getConfigCenter():getConfig("givecoins" , 100 + i)
    local cell = self.buyPanel_:clone()
    cell:setVisible(true)
    cell:setTag(100 + i)
    cell:getChildByName("icon"):loadTexture("res/giftshop/coin" .. 100 + i .. ".png")
    cell:getChildByName("icon_spend"):loadTexture("res/giftshop/common_diamond.png")
    cell:getChildByName("txt_title"):setString("Give " .. info.givecoins_amount .. " Coins")
    cell:getChildByName("txt_speed"):setString(info.givecoins_spenddiamond)
    return cell
end

function GiftLayer:createBuyDrinkPanel(i)
    local info = bole:getConfigCenter():getConfig("buydrinks" , 100 + i) 
    local cell = self.buyPanel_:clone()
    cell:setTag(100 + i)
    cell:setVisible(true)
    cell:getChildByName("icon"):loadTexture("res/giftshop/drink" .. 100 + i .. ".png")
    cell:getChildByName("icon_spend"):loadTexture("res/giftshop/common_coin.png")
    cell:getChildByName("txt_title"):setString(info.drinks_name)
    cell:getChildByName("txt_speed"):setString(info.drinks_spend)
    return cell
end


function GiftLayer:touchEvent(sender, eventType)
    local name = sender:getName()
    print("touchEvent:" .. name)
    if eventType == ccui.TouchEventType.began then
        print("Touch Down")
        sender:setScale(1.05)
    elseif eventType == ccui.TouchEventType.moved then
        print("Touch Move")
    elseif eventType == ccui.TouchEventType.ended then
        print("Touch Up")
        sender:setScale(1)
        if name == "btn_close" then
            self:closeUI()
        elseif name == "btn_coins" then
            self:refrushButton("coins")
        elseif name == "btn_drink" then
            self:refrushButton("drink")
        elseif name == "btn_buyR" then
            self:buyRound(sender)
        elseif name == "btn_buyO" then
            self:buyOne(sender)
        end
    elseif eventType == ccui.TouchEventType.canceled then
        print("Touch Cancelled")
        sender:setScale(1)
    end
end

function GiftLayer:buyRound(sender)
    local id = sender:getParent():getTag()
    bole.socket:send("give",{ give_type = self.give_type_, give_id = id ,target_id = 0 },true)
end

function GiftLayer:buyOne(sender)
    local id = sender:getParent():getTag()
    local have = 0
    local speed = 0
    if self.give_type_ == 1 then
        have = bole:getUserData():getDataByKey("diamond")
        speed = tonumber(bole:getConfigCenter():getConfig("givecoins" , id, "givecoins_spenddiamond") )
    elseif self.give_type_ == 2 then
        have = bole:getUserData():getDataByKey("coins")
        speed = tonumber(bole:getConfigCenter():getConfig("buydrinks" , id, "drinks_spend"))
    end

    if have <speed then
        bole:getUIManage():openClubTipsView(16,nil)
    else
        bole.socket:send("give",{ give_type = self.give_type_, give_id = id ,target_id = self.playerId_ },true)
    end
end

function GiftLayer:adaptScreen(root)
    local winSize = cc.Director:getInstance():getWinSize()
    self:setPosition(0,0)
    self.root_ :setPosition(winSize.width / 2, winSize.height / 2)
end

function GiftLayer:closeGiftLayer()
    self:closeUI()
end

function GiftLayer:onExit()
    bole:removeListener("closeGiftLayer", self)
    bole:removeListener("initGiftLayer", self)
end

return GiftLayer
--endregion
