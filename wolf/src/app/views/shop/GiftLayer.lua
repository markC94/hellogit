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
    self.buyPanel_:setVisible(false)
    self.coinsList = bole:getBuyManage():getGiftCoinsData()
    self.drinkList = bole:getBuyManage():getGiftDrinkData()

    self:initBuyPanel()
    self:initTop()
    self:initListView()
    self:adaptScreen()
    self:createLayerAct()
end

function GiftLayer:onEnter()
    bole:addListener("initGiftLayer", self.initGiftLayer, self, nil, true)
    bole:addListener("showNoBuyLayer", self.showNoBuyLayer, self, nil, true) 
    bole:addListener("closeGiftLayer", self.closeGiftLayer, self, nil, true)
end

function GiftLayer:initGiftLayer(data)
    data = data.result
    self.playerId_ = tonumber(data[1])
    self.parentHeadNodes_ = data[2]
    --[[
    self.coinsInfo_ = bole:getConfigCenter():getConfig("givecoins")
    table.sort(self.coinsInfo_, function(a,b) return a.givecoins_id > b.givecoins_id end)
    self.drinkInfo_ = bole:getConfigCenter():getConfig("buydrinks")
    table.sort(self.drinkInfo_, function(a,b) return a.givecoins_id > b.givecoins_id end)
    --]]
    self:refrushButton("drink")
end

function GiftLayer:initTop()
    local btn_coins = self.root_:getChildByName("btn_coins")
    btn_coins:addTouchEventListener(handler(self, self.touchEvent))

    local btn_drink = self.root_:getChildByName("btn_drink")
    btn_drink:addTouchEventListener(handler(self, self.touchEvent))

    local btn_close = self.root_:getChildByName("btn_close")
    btn_close:addTouchEventListener(handler(self, self.touchEvent))

    local btn_add = self.root_:getChildByName("btn_add")
    btn_add:addTouchEventListener(handler(self, self.touchEvent))

    local txt_coins = self.root_:getChildByName("txt_coins")
    txt_coins:setString(bole:formatCoins(bole:getUserDataByKey("coins"), 12))
    local txt_coins = self.root_:getChildByName("txt_diamond")
    txt_coins:setString(bole:formatCoins(bole:getUserDataByKey("diamond"), 12))

    self.give_type_ = 1
end

function GiftLayer:initListView()
    self.listView_ = self.root_:getChildByName("ListView")
    self.listView_:setScrollBarOpacity(0)
end

function GiftLayer:initBuyPanel()
    local btn_buyR = self.buyPanel_:getChildByName("btn_buyR")
    btn_buyR:addTouchEventListener(handler(self, self.touchEvent))

    local btn_buyO = self.buyPanel_:getChildByName("btn_buyO")
    btn_buyO:addTouchEventListener(handler(self, self.touchEvent))
end


function GiftLayer:refrushButton(str)
--[[
    self.root_:getChildByName("btn_coins"):setTouchEnabled(true)
    self.root_:getChildByName("btn_drink"):setTouchEnabled(true)

    self.root_:getChildByName("img_coins"):setVisible(false)
    self.root_:getChildByName("img_drink"):setVisible(false)
 
    self.root_:getChildByName("txt_coins"):setTextColor({ r = 119, g = 121, b = 159})
    self.root_:getChildByName("txt_drink"):setTextColor({ r = 119, g = 121, b = 159})


    self.root_:getChildByName("btn_" .. str):setTouchEnabled(false)
    self.root_:getChildByName("img_" .. str):setVisible(true)
    self.root_:getChildByName("txt_" .. str):setTextColor({ r = 255, g = 255, b = 255})
 --]]
    self.root_:getChildByName("btn_coins"):setTouchEnabled(true)
    self.root_:getChildByName("btn_drink"):setTouchEnabled(true)

    self.root_:getChildByName("btn_coins"):loadTexture("inSlot_icon/inslot_giftStore_tag_dark.png")
    self.root_:getChildByName("btn_drink"):loadTexture("inSlot_icon/inslot_giftStore_tag_dark.png")

    self.root_:getChildByName("btn_coins"):getChildByName("icon"):setOpacity(117)
    self.root_:getChildByName("btn_drink"):getChildByName("icon"):setOpacity(117)

    self.root_:getChildByName("btn_coins"):getChildByName("txt"):setOpacity(117)
    self.root_:getChildByName("btn_drink"):getChildByName("txt"):setOpacity(117)

    self.root_:getChildByName("btn_" .. str):setTouchEnabled(false)
    self.root_:getChildByName("btn_" .. str):loadTexture("inSlot_icon/inslot_giftStore_tag_light.png")
    self.root_:getChildByName("btn_" .. str):getChildByName("icon"):setOpacity(255)
    self.root_:getChildByName("btn_" .. str):getChildByName("txt"):setOpacity(255)
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
        for i = 1, # self.coinsList do
            local cell = self:createBuyCoinsPanel(i)
            self.listView_:pushBackCustomItem(cell)
        end
    elseif str == "drink" then
        for i = 1, # self.drinkList do
            local cell = self:createBuyDrinkPanel(i)
            self.listView_:pushBackCustomItem(cell)
        end
    end
end

function GiftLayer:createBuyCoinsPanel(i)
    local cell = self.buyPanel_:clone()
    cell:setVisible(true)
    cell:setTag(tonumber(self.coinsList[i].givecoins_id))
    local sp = cc.Sprite:create("inSlot_icon/" .. self.coinsList[i].givecoins_pictureid .. ".png")
    cell:getChildByName("icon"):addChild(sp)
    if i % 2 == 1 then
        cell:getChildByName("bg"):loadTexture("inSlot_icon/inslot_giftStore_item_dark.png")
    else
        cell:getChildByName("bg"):loadTexture("inSlot_icon/inslot_giftStore_item_light.png")
    end
    cell:getChildByName("icon_spend"):loadTexture("inSlot_icon/common_diamond.png")
    cell:getChildByName("txt_title"):setString("Give " .. bole:formatCoins(self.coinsList[i].givecoins_amount ,4) .. " Coins")
    cell:getChildByName("txt_speed"):setString(self.coinsList[i].givecoins_spenddiamond)
    return cell
end

function GiftLayer:createBuyDrinkPanel(i)
    local cell = self.buyPanel_:clone()
    cell:setVisible(true)
    cell:setTag(tonumber(self.drinkList[i].drinks_id))
    local sp = cc.Sprite:create("inSlot_icon/" .. self.drinkList[i].buydrinks_pictureid .. ".png")
    cell:getChildByName("icon"):addChild(sp)
    if i % 2 == 1 then
        cell:getChildByName("bg"):loadTexture("inSlot_icon/inslot_giftStore_item_dark.png")
    else
        cell:getChildByName("bg"):loadTexture("inSlot_icon/inslot_giftStore_item_light.png")
    end
    cell:getChildByName("icon_spend"):loadTexture("inSlot_icon/common_coin.png")
    cell:getChildByName("txt_title"):setString(self.drinkList[i].drinks_name)
    cell:getChildByName("txt_speed"):setString(self.drinkList[i].drinks_spend)
    return cell
end


function GiftLayer:touchEvent(sender, eventType)
    local name = sender:getName()
    print("touchEvent:" .. name)
    if eventType == ccui.TouchEventType.began then
        print("Touch Down")
        if name == "btn_coins" then
            self.root_:getChildByName("btn_coins"):loadTexture("inSlot_icon/inslot_giftStore_tag_light.png")
            self.root_:getChildByName("btn_coins"):getChildByName("icon"):setOpacity(255)
            self.root_:getChildByName("btn_coins"):getChildByName("txt"):setOpacity(255)
        elseif name == "btn_drink" then
            self.root_:getChildByName("btn_drink"):loadTexture("inSlot_icon/inslot_giftStore_tag_light.png")
            self.root_:getChildByName("btn_drink"):getChildByName("icon"):setOpacity(255)
            self.root_:getChildByName("btn_drink"):getChildByName("txt"):setOpacity(255)
        end
    elseif eventType == ccui.TouchEventType.moved then
        print("Touch Move")
    elseif eventType == ccui.TouchEventType.ended then
        print("Touch Up")
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
        elseif name == "btn_add" then
            bole:getUIManage():openNewUI("ShopLayer",true,"shop_lobby","app.views.shop")
            if self.give_type_ == 1 then
                bole:postEvent("openDiamondShop")
            end
        end
    elseif eventType == ccui.TouchEventType.canceled then
        if name == "btn_coins" then
            self.root_:getChildByName("btn_coins"):loadTexture("inSlot_icon/inslot_giftStore_tag_dark.png")
            self.root_:getChildByName("btn_coins"):getChildByName("icon"):setOpacity(117)
            self.root_:getChildByName("btn_coins"):getChildByName("txt"):setOpacity(117)
        elseif name == "btn_drink" then
            self.root_:getChildByName("btn_drink"):loadTexture("inSlot_icon/inslot_giftStore_tag_dark.png")
            self.root_:getChildByName("btn_drink"):getChildByName("icon"):setOpacity(117)
            self.root_:getChildByName("btn_drink"):getChildByName("txt"):setOpacity(117)
        end
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
    local isInSlot = false
    for k, v in pairs(self.parentHeadNodes_) do
         if v.head.info.user_id == self.playerId_ then
            isInSlot = true
         end
    end

    if not isInSlot then
        bole:popMsg( { msg = "the player has left.", title = "gift", cancle = false })
        return
    end

    if self.give_type_ == 1 then
        have = bole:getUserData():getDataByKey("diamond")
        speed = tonumber(bole:getConfigCenter():getConfig("givecoins" , id, "givecoins_spenddiamond") )
    elseif self.give_type_ == 2 then
        have = bole:getUserData():getDataByKey("coins")
        speed = tonumber(bole:getConfigCenter():getConfig("buydrinks" , id, "drinks_spend"))
    end

    if have <speed then
        if self.give_type_ == 1 then
            bole:popMsg( { msg = "can not buy it.", title = "gift", cancle = false }, function() bole:getUIManage():openNewUI("ShopLayer",true,"shop_lobby","app.views.shop") bole:postEvent("openDiamondShop") end)
        else
            bole:popMsg( { msg = "can not buy it.", title = "gift", cancle = false }, function() bole:getUIManage():openNewUI("ShopLayer",true,"shop_lobby","app.views.shop") end)
        end
    else
        bole.socket:send("give",{ give_type = self.give_type_, give_id = id ,target_id = self.playerId_ },true)
    end
end

function GiftLayer:showNoBuyLayer()
        if self.give_type_ == 1 then
            bole:popMsg( { msg = "can not buy it.", title = "gift", cancle = false }, function() bole:getUIManage():openNewUI("ShopLayer",true,"shop_lobby","app.views.shop") bole:postEvent("openDiamondShop") end)
        else
            bole:popMsg( { msg = "can not buy it.", title = "gift", cancle = false }, function() bole:getUIManage():openNewUI("ShopLayer",true,"shop_lobby","app.views.shop") end)
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
    bole:removeListener("showNoBuyLayer", self)
end

function GiftLayer:createLayerAct()
    bole:autoOpacityC(self)

    --self.root_:setOpacity(0)
    --self.root_:runAction(cc.FadeIn:create(0.5))
    self.root_:setScale(0.01)
    self.root_:runAction(cc.Sequence:create(cc.ScaleTo:create(0.3, 1.05), cc.ScaleTo:create(0.3, 1)))
end


return GiftLayer
--endregion
