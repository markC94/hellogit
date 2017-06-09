--region *.lua
--Date
--此文件由[BabeLua]插件自动生成

local OutOfCoinsLayer = class("OutOfCoinsLayer", cc.load("mvc").ViewBase)

function OutOfCoinsLayer:onCreate()
    print("OutOfCoinsLayer:onCreate")
    self.root_ = self:getCsbNode():getChildByName("root")

    self:initTop(self.root_)

    self:adaptScreen()

    self:initShowInfo()
    self:refreshView()
end

function OutOfCoinsLayer:onEnter()
    --bole.socket:registerCmd("shop_info", self.reShopInfo, self)
    --bole:addListener("initFrirndList", self.initFrirndList, self, nil, true)
end

function OutOfCoinsLayer:initTop(root)
    local btn_close = root:getChildByName("btn_close")
    btn_close:addTouchEventListener(handler(self, self.touchEvent))

    self.txt_title_ = root:getChildByName("txt_title")
    self.txt_info_ = root:getChildByName("txt_titleInfo")

    self.goods_ = {}
    self.goods_[1] = root:getChildByName("panel_1")
    local btn_get_1 = self.goods_[1] :getChildByName("btn_buy_1")
    btn_get_1:addTouchEventListener(handler(self, self.touchEvent))
    self.goods_[2] = root:getChildByName("panel_2")
    local btn_get_2 = self.goods_[2] :getChildByName("btn_buy_2")
    btn_get_2:addTouchEventListener(handler(self, self.touchEvent))
    self.goods_[3] = root:getChildByName("panel_3")
    local btn_get_3 = self.goods_[3] :getChildByName("btn_buy_3")
    btn_get_3:addTouchEventListener(handler(self, self.touchEvent))
end

function OutOfCoinsLayer:initShowInfo()
    self.rfm_ = tonumber(bole:getUserDataByKey("purchase_level"))
    local storeIdList = {1001,1002,1003}
    if self.rfm_ < 7 then
        storeIdList = bole:getConfigCenter():getConfig("out_of_coin_position", 7, "store_item")
    elseif self.rfm_ < 12 then
        storeIdList = bole:getConfigCenter():getConfig("out_of_coin_position", 12, "store_item")
    elseif self.rfm_ < 20 then
        storeIdList = bole:getConfigCenter():getConfig("out_of_coin_position", 20, "store_item")
    else
        storeIdList = bole:getConfigCenter():getConfig("out_of_coin_position", 50, "store_item")
    end

    self.storeInfo_ = {}
    for i = 1, # storeIdList do
        local info = {}
        info.id = storeIdList[i]
        info.num = bole:getConfigCenter():getConfig("out_of_coin", storeIdList[i], "coins_amount")
        info.price = bole:getConfigCenter():getConfig("price", bole:getConfigCenter():getConfig("out_of_coin", storeIdList[i], "price_id"), "price")
        info.reward = bole:getConfigCenter():getConfig("out_of_coin", storeIdList[i], "store_specialbonus")
        table.insert(self.storeInfo_, # self.storeInfo_ + 1, info)
    end
end

function OutOfCoinsLayer:refreshView()
    self.txt_title_:setString("KEEP PLAYING")
    self.txt_info_:setString("We've prepared the best offers of you.\nEnjoy playing and have fun!")
    for i = 1, 3 do
        self.goods_[i]:getChildByName("txt_coinsNum"):setString(bole:formatCoins(self.storeInfo_[i].num,15))
        self.goods_[i]:getChildByName("txt_worth"):setString("Worth " ..  self.storeInfo_[i].price)
        self.goods_[i]:getChildByName("txt_only"):setString("Only " .. self.storeInfo_[i].price)

        local myDrawNode=cc.DrawNode:create()  
        self.goods_[i]:addChild(myDrawNode, 10)  
        local width = self.goods_[i]:getChildByName("txt_worth"):getContentSize().width
        myDrawNode:drawSegment(cc.p(0,0), cc.p(width,0),1, cc.c4f(1 , 0.43 , 0.43 , 1))  
        local posX,posY = self.goods_[i]:getChildByName("txt_worth"):getPosition()
        myDrawNode:setPosition(posX - width / 2,posY)  

        for j = 1, 3 do 
            self.goods_[i]:getChildByName("icon_rw" .. j):setVisible(false)
        end

        local rewardList = self:getReward(self.storeInfo_[i].reward)
        local panel = self.goods_[i]
        for k ,v in pairs(rewardList) do
             if v.type == 2 then -- 铜卷
                panel:getChildByName("icon_rw3"):setVisible(true)
                panel:getChildByName("icon_rw3"):loadTexture("res/shop/levelup_lottoBronze.png")
                panel:getChildByName("icon_rw3"):getChildByName("txt"):setString("+" .. v.number)
             elseif v.type == 3 then --银卷
                panel:getChildByName("icon_rw3"):setVisible(true)
                panel:getChildByName("icon_rw3"):loadTexture("res/shop/levelup_lottoSilver.png")
                panel:getChildByName("icon_rw3"):getChildByName("txt"):setString("+" .. v.number)
             elseif v.type == 4 then --金券
                panel:getChildByName("icon_rw3"):setVisible(true)
                panel:getChildByName("icon_rw3"):loadTexture("res/shop/levelup_lottoGold.png")
                panel:getChildByName("icon_rw3"):getChildByName("txt"):setString("+" .. v.number)
             elseif v.type == 8 then --大厅加速券
                panel:getChildByName("icon_rw2"):setVisible(true)
                panel:getChildByName("icon_rw2"):getChildByName("txt"):setString("+" .. v.number .. "s")
             elseif v.type == 1 then --双倍经验
                panel:getChildByName("icon_rw1"):setVisible(true)
                panel:getChildByName("icon_rw1"):getChildByName("txt"):setString("+" .. v.number .. "s")
             end  
        end
    end
end

function OutOfCoinsLayer:getReward(idList)
    local infoList = {}
    for i = 1, # idList do
        local info = {}
         info.typeStr = ""
         info.type = bole:getConfigCenter():getConfig("reward", idList[i] , "bonus_type")
         info.number = bole:getConfigCenter():getConfig("reward", idList[i] , "bonus_number")
         if type == 10 then
            info.typeStr = "coins"
         elseif type == 9 then
            info.typeStr = "diamond"
         elseif type == 2 then
            info.typeStr = "铜卷"
         elseif type == 3 then
            info.typeStr = "银卷"
         elseif type == 4 then
            info.typeStr = "金券"
         elseif type == 8 then
            info.typeStr = "大厅加速券"
         elseif type == 1 then
            info.typeStr = "双倍经验"
         end     
         table.insert(infoList, # infoList + 1, info)    
    end
    return infoList
end

function OutOfCoinsLayer:touchEvent(sender, eventType)
    local name = sender:getName()
    if eventType == ccui.TouchEventType.began then
        sender:runAction(cc.ScaleTo:create(0.1, 1.05, 1.05))
    elseif eventType == ccui.TouchEventType.moved then

    elseif eventType == ccui.TouchEventType.ended then
        sender:runAction(cc.ScaleTo:create(0.1, 1, 1))
        if name == "btn_close" then
            self:closeUI()
        elseif name == "btn_buy_1" then
            self:buy(1)
        elseif name == "btn_buy_2" then
            self:buy(2)
        elseif name == "btn_buy_3" then
            self:buy(3)
        end
    elseif eventType == ccui.TouchEventType.canceled then
        sender:runAction(cc.ScaleTo:create(0.1, 1, 1))
    end
end

function OutOfCoinsLayer:buy(id)

end

function OutOfCoinsLayer:onExit()
    --bole.socket:unregisterCmd("shop_info")
    --bole:removeListener("initFrirndList", self)
end

function OutOfCoinsLayer:adaptScreen()
    local winSize = cc.Director:getInstance():getWinSize()
    self:setPosition(0,0)
    self.root_:setPosition(winSize.width / 2, winSize.height / 2)
    self.root_:setScale(0.1)
    self.root_:runAction(cc.ScaleTo:create(0.2,1,1))
end

return OutOfCoinsLayer

--endregion
