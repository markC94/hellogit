--region *.lua
--Date
--此文件由[BabeLua]插件自动生成

local ShopLayer = class("ShopLayer", cc.load("mvc").ViewBase)

function ShopLayer:onCreate()
    self.bonus = bole:getBuyManage():getFreeCoinsNum()
 
    print("VipLayer:onCreate")
    self.root_ = self:getCsbNode():getChildByName("root")

    self:initTop()
    self:initBonusPanel()
    self.listView_ = self.root_:getChildByName("ListView")
    self.listView_:setScrollBarOpacity(0)

    self:refrushShowInfo()
    self:refrushButton("coins")

    self:adaptScreen()
end

function ShopLayer:onKeyBack()
   self:closeUI()
end

function ShopLayer:onEnter()
    bole:addListener("show_collect_shop_bonus_act", self.showBonusAct, self, nil, true)
    bole:addListener("showBuyAct_shopLayer", self.showBuyAct, self, nil, true)
    bole:addListener("openDiamondShop", self.reOpenDiamondShop, self, nil, true)
end

function ShopLayer:reOpenDiamondShop(data)
    self:refrushShowInfo()
    self:refrushButton("diamond")
end

function ShopLayer:initTop()
    local btn_coins = self.root_:getChildByName("btn_coins")
    btn_coins:addTouchEventListener(handler(self, self.topButtomTouchEvent))
    self.btn_coins_ = btn_coins

    local btn_diamond = self.root_:getChildByName("btn_diamond")
    btn_diamond:addTouchEventListener(handler(self, self.topButtomTouchEvent))
    self.btn_diamond_ = btn_diamond

    local btn_close = self.root_:getChildByName("btn_close")
    btn_close:addTouchEventListener(handler(self, self.touchEvent))

    self.shop_type_ = 1

    local btn_vip = self.root_:getChildByName("vip")
    btn_vip:addTouchEventListener(handler(self, self.touchEvent))
    self.vipIcon_ = btn_vip:getChildByName("vipIcon")
    self.vipLevel_ = btn_vip:getChildByName("vipLevel")
    self.vipInfon_ = btn_vip:getChildByName("vipInfo")

    self.coins_info_ = self.root_:getChildByName("coins_info")
    self.diamond_info_ = self.root_:getChildByName("diamond_info")
    self.diamond_image_ = self.root_:getChildByName("diamond_image")
    self.vip_ = btn_vip
end

function ShopLayer:initBonusPanel()
    self.freeCoins_ = self.root_:getChildByName("Panel_freeCoins")
    self.freeCoins_:setVisible(true)
    self.freeCoinsNum_ = self.freeCoins_:getChildByName("txt_num")
    local btn_freeCoins = self.freeCoins_:getChildByName("btn_freeCoins")
    btn_freeCoins:addTouchEventListener(handler(self, self.touchEvent))
    self.btn_freeCoins_ = btn_freeCoins


    self.countdown_ = self.root_:getChildByName("Panel_countdown")
    self.countdown_:setVisible(false)
    local node_clock = self.countdown_:getChildByName("Node_clock")
    local clockAct = sp.SkeletonAnimation:create("shop_act/biao_1.json", "shop_act/biao_1.atlas")
    clockAct:setScale(0.65)
    clockAct:setAnimation(0, "animation", true)
    node_clock:addChild(clockAct)

    self.time_1 = self.countdown_:getChildByName("time_1")
    self.time_2 = self.countdown_:getChildByName("time_2")
    self.unit_1 = self.countdown_:getChildByName("time_unit_1")
    self.unit_2 = self.countdown_:getChildByName("time_unit_2")
end

function ShopLayer:refrushShowInfo()
    self.coinsStoreInfo_ = bole:getBuyManage():getCoinShopData()
    self.diamondStoreInfo_ = bole:getBuyManage():getDiamondShopData()
    self.freeCoinsNum_:setString( bole:formatCoins( bole:getBuyManage():getFreeCoinsNum(),15))

    local sp = cc.Sprite:create(bole:getBuyManage():getVipIconStr())
    sp:setScale(0.4)
    self.vipIcon_:addChild(sp)
    self.vipLevel_:setString(bole:getBuyManage():getVipLevel() + 1)
    self.vipInfon_:setString(bole:getBuyManage():getShopVipMulShowNum())


    if bole.shop_bonus_time ~= nil then
        if bole.shop_bonus_time > 0 then
            self.reCollectBonus_ = false
            self.btn_freeCoins_:setTouchEnabled(false)
            self.freeCoins_:setVisible(false)
            self.countdown_:setVisible(true)
            self:startUpdate()
        end
    end
end


function ShopLayer:refrushButton(str)
    self.btn_coins_:setTouchEnabled(true)
    self.btn_diamond_:setTouchEnabled(true)

    self.btn_coins_:loadTexture("shop_lobby/ui/shop_tab_dark.png")
    self.btn_diamond_:loadTexture("shop_lobby/ui/shop_tab_dark.png")

    self.btn_coins_:getChildByName("icon"):setOpacity(117)
    self.btn_diamond_:getChildByName("icon"):setOpacity(117)

    self.btn_coins_:getChildByName("txt"):setOpacity(117)
    self.btn_diamond_:getChildByName("txt"):setOpacity(117)

    local btn = self.root_:getChildByName("btn_" .. str)
    btn:setTouchEnabled(false)
    btn:loadTexture("shop_lobby/ui/shop_tab_bright.png")
    btn:getChildByName("txt"):setOpacity(255)
    btn:getChildByName("icon"):setOpacity(255)

    if str == "coins" then
        self.shop_type_ = 1
        self.showList_ = self.coinsStoreInfo_ 
        self.coins_info_:setVisible(true)
        self.diamond_info_:setVisible(false)
        self.vip_:setVisible(true)
        self.diamond_image_:setVisible(false)
    elseif str == "diamond" then
        self.shop_type_ = 2
        self.showList_ = self.diamondStoreInfo_ 
        self.coins_info_:setVisible(false)
        self.diamond_info_:setVisible(true)
        self.vip_:setVisible(false)
        self.diamond_image_:setVisible(true)
    end

    self:refrushListView()
end

function ShopLayer:refrushListView()
    self.listView_:removeAllChildren()
    for i = 1 , 5 do
        local cell = bole:getEntity("app.views.shop.ShopCell",i,self.shop_type_,self.showList_[i])
        self.listView_:pushBackCustomItem(cell)
    end
end


function ShopLayer:topButtomTouchEvent(sender, eventType)
    local name = sender:getName()
    if eventType == ccui.TouchEventType.began then
        if name == "btn_coins" then
            self.btn_coins_:loadTexture("shop_lobby/ui/shop_tab_bright.png")
            self.btn_coins_:getChildByName("icon"):setOpacity(255)
            self.btn_coins_:getChildByName("txt"):setOpacity(255)
        elseif name == "btn_diamond" then
            self.btn_diamond_:loadTexture("shop_lobby/ui/shop_tab_bright.png")
            self.btn_diamond_:getChildByName("icon"):setOpacity(255)
            self.btn_diamond_:getChildByName("txt"):setOpacity(255)
        end
    elseif eventType == ccui.TouchEventType.moved then

    elseif eventType == ccui.TouchEventType.ended then
        if name == "btn_coins" then
            self:refrushButton("coins")
        elseif name == "btn_diamond" then
            self:refrushButton("diamond")
        end
    elseif eventType == ccui.TouchEventType.canceled then
        if name == "btn_coins" then
            self.btn_coins_:loadTexture("shop_lobby/ui/shop_tab_dark.png")
            self.btn_coins_:getChildByName("icon"):setOpacity(117)
            self.btn_coins_:getChildByName("txt"):setOpacity(117)
        elseif name == "btn_diamond" then
            self.btn_diamond_:loadTexture("shop_lobby/ui/shop_tab_dark.png")
            self.btn_diamond_:getChildByName("icon"):setOpacity(117)
            self.btn_diamond_:getChildByName("txt"):setOpacity(117)
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
        elseif name == "vip" then
            bole:getUIManage():openNewUI("VipLayer",true,"vip","app.views.vip")
        end
    elseif eventType == ccui.TouchEventType.canceled then
        sender:runAction(cc.ScaleTo:create(0.1, 1, 1))
    end
end

function ShopLayer:collectBonus()
    self.btn_freeCoins_:setTouchEnabled(false)
    bole.socket:send("collect_shop_bonus",{},true) 
end

function ShopLayer:showBonusAct(data)
    self.reCollectBonus_ = false
    self:startUpdate()
    local myHeadPos = cc.p(225,cc.Director:getInstance():getWinSize().height - 50)
    local startPos = self.btn_freeCoins_:getWorldPosition()
    startPos.x = startPos.x + 100
    if bole:getSpinApp():isThemeAlive() then 
        bole:refreshCoinsAndDiamondInSlot()
        myHeadPos = cc.p(120,cc.Director:getInstance():getWinSize().height - 50)
    end
    bole:getAudioManage():playMusic("common_cc",true)
    bole:getUIManage():flyCoin(startPos,myHeadPos,function() bole:getAudioManage():stopAudio("common_cc") end,nil)
    performWithDelay(self, function()
        self.freeCoins_:setVisible(false)
        self.countdown_:setVisible(true)
    end , 1.8)
end

function ShopLayer:startUpdate()
    local function update(dt)
        self:updateTime(dt)
    end
    self:onUpdate(update)
end

function ShopLayer:updateTime(dt)
    if not bole.shop_bonus_time then
        return
    end

    if bole.shop_bonus_time > 0 then
        local s = math.floor(bole.shop_bonus_time) % 60
        local m = math.floor(bole.shop_bonus_time / 60) % 60
        local h = math.floor(bole.shop_bonus_time / 3600) % 24

        if h == 0 then
            self.unit_1:setString("M")
            self.unit_2:setString("S")
            self.time_1:setString(m)
            self.time_2:setString(s)
        else
            self.unit_1:setString("H")
            self.unit_2:setString("M")
            self.time_1:setString(h)
            self.time_2:setString(m)
        end
    else
        if not self.freeCoins_:isVisible() then
            bole.shop_bonus_time = nil
            self.unit_1:setString("M")
            self.unit_2:setString("S")
            self.time_1:setString(0)
            self.time_2:setString(0)
            self.freeCoins_:setVisible(true)
            self.countdown_:setVisible(false)
            self.btn_freeCoins_:setTouchEnabled(true)
        end
    end
end

function ShopLayer:onExit()
    bole:removeListener("showBuyAct_shopLayer", self)
    bole:removeListener("openDiamondShop", self)
    bole:removeListener("show_collect_shop_bonus_act", self)
end


function ShopLayer:adaptScreen()
    local winSize = cc.Director:getInstance():getWinSize()
    self:setPosition(0,0)
    self.root_:setPosition(winSize.width / 2, winSize.height / 2)
    self.root_:setScale(0.1)
    self.root_:runAction(cc.ScaleTo:create(0.2,1,1))
end

function ShopLayer:showBuyAct(data)
    data = data.result
    print("showBuyAct_shopLayer")
end

return ShopLayer
--endregion
