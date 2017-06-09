--region *.lua
--Date
--此文件由[BabeLua]插件自动生成

local ShopLayer = class("ShopLayer", cc.load("mvc").ViewBase)

function ShopLayer:onCreate()
    print("VipLayer:onCreate")
    self.root_ = self:getCsbNode():getChildByName("root")
    self.top_ = self.root_:getChildByName("top")

    self:initTop(self.top_)
    self.listView_ = self.root_:getChildByName("ListView")

    self:adaptScreen()

    self:reShopInfo("shop_info", data)
end


function ShopLayer:onEnter()
    bole.socket:registerCmd("collect_shop_bonus", self.reCollect, self)
    --bole:addListener("initFrirndList", self.initFrirndList, self, nil, true)
end

function ShopLayer:reShopInfo(t, data)
    if t == "shop_info" then
        self.shopdata_ = data
        self:refrushShowInfo()
        self:refrushButton("coins")
    end
end

function ShopLayer:initTop(root)
    local btn_coins = self.root_:getChildByName("btn_coins")
    btn_coins:addTouchEventListener(handler(self, self.topButtomTouchEvent))

    local btn_diamond = self.root_:getChildByName("btn_diamond")
    btn_diamond:addTouchEventListener(handler(self, self.topButtomTouchEvent))

    local btn_close = self.root_:getChildByName("btn_close")
    btn_close:addTouchEventListener(handler(self, self.touchEvent))

    self.shop_type_ = 1

    self.txtTitle_ = root:getChildByName("txt_title")
    self.btn_freeCoins_ = root:getChildByName("btn_freeCoins")
    self.btn_freeCoins_:addTouchEventListener(handler(self, self.touchEvent))

    local btn_vip = root:getChildByName("btn_vip")
    btn_vip:addTouchEventListener(handler(self, self.touchEvent))

    self.btn_countdown_ = root:getChildByName("btn_countdown")
    self.btn_countdown_:addTouchEventListener(handler(self, self.touchEvent))
   
    local timeP = self.btn_countdown_:getChildByName("time")
        self.txt_second1 = timeP:getChildByName("txt_second1")
        self.txt_second2 = timeP:getChildByName("txt_second2")
        self.txt_minute1 = timeP:getChildByName("txt_minute1")
        self.txt_minute2 = timeP:getChildByName("txt_minute2")
        self.txt_hour1 = timeP:getChildByName("txt_hour1")
        self.txt_hour2 = timeP:getChildByName("txt_hour2")
        


    self.freeTitle_ = self.btn_freeCoins_:getChildByName("txt_title")
    self.freeCoinsNum_ = self.btn_freeCoins_:getChildByName("txt_num")
end

function ShopLayer:refrushShowInfo()
    self.rfm_ = tonumber(bole:getUserDataByKey("purchase_level"))
    local storeIdList = {1001,1002,1003,1004,1006}
    if self.rfm_ < 10 then
        storeIdList = bole:getConfigCenter():getConfig("store_position", 1, "store_item")
    elseif self.rfm_ < 20 then
        storeIdList = bole:getConfigCenter():getConfig("store_position", 10, "store_item")
    elseif self.rfm_ < 50 then
        storeIdList = bole:getConfigCenter():getConfig("store_position", 20, "store_item")
    elseif self.rfm_ < 100 then
        storeIdList = bole:getConfigCenter():getConfig("store_position", 50, "store_item")
    else
        storeIdList = bole:getConfigCenter():getConfig("store_position", 100, "store_item")
    end

    self.coinsStoreInfo_ = {}
    self.diamondStoreInfo_ = {}
    for i = # storeIdList, 1 , -1 do
        local info = {}
        info.id = storeIdList[i]
        info.num = bole:getConfigCenter():getConfig("store_coins", storeIdList[i], "coins_amount")
        info.vipPoints = bole:getConfigCenter():getConfig("store_coins", storeIdList[i], "vip_getpoints")
        info.price = bole:getConfigCenter():getConfig("price", bole:getConfigCenter():getConfig("store_coins", storeIdList[i], "price_id"), "price")
        info.reward = bole:getConfigCenter():getConfig("store_coins", storeIdList[i], "store_specialbonus")
        table.insert(self.coinsStoreInfo_, # self.coinsStoreInfo_ + 1, info)
    end
    for i = # storeIdList, 1 , -1 do
        local info = {}
        info.id = storeIdList[i]
        info.num = bole:getConfigCenter():getConfig("store_diamonds", storeIdList[i], "diamonds_amount")
        info.vipPoints = bole:getConfigCenter():getConfig("store_diamonds", storeIdList[i], "vip_getpoints")
        info.price = bole:getConfigCenter():getConfig("price", bole:getConfigCenter():getConfig("store_diamonds", storeIdList[i], "price_id"), "price")
        info.reward = bole:getConfigCenter():getConfig("store_diamonds", storeIdList[i], "store_specialbonus")
        table.insert(self.diamondStoreInfo_, # self.diamondStoreInfo_ + 1, info)
    end

    local time = bole:getUserDataByKey("shop_bonus")
    if time ~= 0 then
        local loginTime = bole:getUserDataByKey("loginTime")
        local showTime = time - ( os.time() - loginTime)
        if showTime > 0 then
            self.reCollectBonus_ = false
            self.delayTime = showTime
            self.btn_freeCoins_:setTouchEnabled(true)
            self.btn_freeCoins_:setVisible(false)
            self.btn_countdown_:setVisible(true)
            self:startUpdate()
        end
    end
end

function ShopLayer:refrushButton(str)
    self.root_:getChildByName("btn_coins"):setTouchEnabled(true)
    self.root_:getChildByName("btn_diamond"):setTouchEnabled(true)

    self.root_:getChildByName("img_coins"):setVisible(false)
    self.root_:getChildByName("img_diamond"):setVisible(false)
 
    self.root_:getChildByName("txt_coins"):setTextColor({ r = 119, g = 121, b = 159})
    self.root_:getChildByName("txt_diamond"):setTextColor({ r = 119, g = 121, b = 159})


    self.root_:getChildByName("btn_" .. str):setTouchEnabled(false)
    self.root_:getChildByName("img_" .. str):setVisible(true)
    self.root_:getChildByName("txt_" .. str):setTextColor({ r = 255, g = 255, b = 255})

    if str == "coins" then
        self.shop_type_ = 1
        self.showList_ = self.coinsStoreInfo_ 
    elseif str == "diamond" then
        self.shop_type_ = 2
        self.showList_ = self.diamondStoreInfo_ 
    end

    self:refrushListView(str)
end

function ShopLayer:refrushListView(str)
    self.listView_:removeAllChildren()
    for i = 1 , 5 do
        local cell = bole:getEntity("app.views.shop.ShopCell",i,self.shop_type_,self.showList_[i])
        self.listView_:pushBackCustomItem(cell)
    end
end


function ShopLayer:topButtomTouchEvent(sender, eventType)
    local name = sender:getName()
    if eventType == ccui.TouchEventType.ended then
        if name == "btn_coins" then
            self:refrushButton("coins")
        elseif name == "btn_diamond" then
            self:refrushButton("diamond")
        end
    end
end

function ShopLayer:touchEvent(sender, eventType)
    local name = sender:getName()
    if eventType == ccui.TouchEventType.began then
        sender:runAction(cc.ScaleTo:create(0.1, 1.05, 1.05))
    elseif eventType == ccui.TouchEventType.moved then

    elseif eventType == ccui.TouchEventType.ended then
        sender:runAction(cc.ScaleTo:create(0.1, 1, 1))
        if name == "btn_close" then
            self:closeUI()
        elseif name == "btn_freeCoins" then
            self:collectBonus()
        elseif name == "btn_vip" then
            bole:getUIManage():openUI("VipLayer",true)
        end
    elseif eventType == ccui.TouchEventType.canceled then
        sender:runAction(cc.ScaleTo:create(0.1, 1, 1))
    end
end

function ShopLayer:collectBonus()
    self.btn_freeCoins_:setTouchEnabled(false)
    bole.socket:send("collect_shop_bonus",{},true) 
end

function ShopLayer:reCollect(t, data)
    if t == "collect_shop_bonus" then
        self.reCollectBonus_ = false
        self.delayTime = 28800
        self.btn_freeCoins_:setTouchEnabled(true)
        self.btn_freeCoins_:setVisible(false)
        self.btn_countdown_:setVisible(true)
        self:startUpdate()
        bole:changeUserDataByKey("coins",100000)
    end
end

function ShopLayer:startUpdate()
    local function update(dt)
        self:updateTime(dt)
    end
    self:onUpdate(update)
end

function ShopLayer:updateTime(dt)
    if not self.delayTime then
        return
    end
    self.delayTime = self.delayTime - dt
    if self.delayTime > 0 then
        local s = math.floor(self.delayTime) % 60
        local m = math.floor(self.delayTime / 60) % 60
        local h = math.floor(self.delayTime / 3600) % 24
        self.txt_second1:setString(math.floor(s / 10))
        self.txt_second2:setString(math.floor(s % 10))
        self.txt_minute1:setString(math.floor(m / 10))
        self.txt_minute2:setString(math.floor(m % 10))
        self.txt_hour1:setString(math.floor(h / 10))
        self.txt_hour2:setString(math.floor(h % 10))
    else
        self.txt_second1:setString(0)
        self.txt_second2:setString(0)
        self.txt_minute1:setString(0)
        self.txt_minute2:setString(0)
        self.txt_hour1:setString(0)
        self.txt_hour2:setString(0)
    end
end

function ShopLayer:onExit()
    bole.socket:unregisterCmd("collect_shop_bonus")
    --bole:removeListener("initFrirndList", self)
end

function ShopLayer:adaptScreen()
    local winSize = cc.Director:getInstance():getWinSize()
    self:setPosition(0,0)
    self.root_:setPosition(winSize.width / 2, winSize.height / 2)
    self.root_:setScale(0.1)
    self.root_:runAction(cc.ScaleTo:create(0.2,1,1))
end

return ShopLayer
--endregion
