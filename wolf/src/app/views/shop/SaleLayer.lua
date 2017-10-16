-- region *.lua
-- Date
-- 此文件由[BabeLua]插件自动生成

local SaleLayer = class("SaleLayer", cc.load("mvc").ViewBase)

local radom = {40,25,15,10}

function SaleLayer:onKeyBack()
   self:closeUI()
end

function SaleLayer:onCreate()
    print("SaleLayer:onCreate")
    self.price_list = bole:getConfigCenter():getConfig("price")
    self.sale_list = bole:getConfigCenter():getConfig("ingame_sale_random")
    self.sale_index = 0
    self.count = 0
    self.mulit = 0.05
    local root = self:getCsbNode():getChildByName("root")
    self.root = root
    local head = bole:getNewHeadView(bole:getUserData())
    self.Node_me = root:getChildByName("Node_me")
    head:updatePos(head.POS_SALE_SELF)
    head:setScale(1.9)
    self.Node_me:addChild(head)

    local bg = root:getChildByName("bg")
    local bg3 = root:getChildByName("panel_time"):getChildByName("bg3")
    self.bg3 = bg3
    self.tips = root:getChildByName("txt_info")
    self.nobody = root:getChildByName("nobody")
    self.nobody:setVisible(false)

    self.players = {}
    self.players[1] = root:getChildByName("player1")
    self.players[2] = root:getChildByName("player2")
    self.players[3] = root:getChildByName("player3")
    self.players[4] = root:getChildByName("player4")

    local btn_close = root:getChildByName("btn_close")
    btn_close:addTouchEventListener(handler(self, self.touchEvent))
    local btn_get = root:getChildByName("btn_get")
    btn_get:addTouchEventListener(handler(self, self.touchEvent))
    self.btn_get = btn_get
    self.coins = root:getChildByName("txt_num")
    self.time_m = bg3:getChildByName("time_m")
    self.time_s = bg3:getChildByName("time_s")
    self.price = btn_get:getChildByName("txt")
    self.freeCoins = root:getChildByName("txt_rNum")
    self.clockActNode = bg3:getChildByName("node_act")
    local clockAct = sp.SkeletonAnimation:create("shop_act/biao_1.json", "shop_act/biao_1.atlas")
    clockAct:setScale(0.5)
    clockAct:setAnimation(0, "animation", true)
    self.clockActNode:addChild(clockAct)
    self.showChatTime = math.random(20, 30 )*0.5
    self.timekeeper = 0
    self.schTime = 0
    local function update(dt)
        self:updateTime(dt)
    end
    self:onUpdate(update)
    --[[
    self:onUpdate(hander(self,self.updateTime))
    self.updateId = cc.Director:getInstance():getScheduler():scheduleScriptFunc( function (dt)
        self:updateTime(dt)
    end,0,false)
    --]]
    --self:updateInfo()
end

function SaleLayer:updateTime(dt)
    self.schTime = self.schTime + dt
    if self.schTime > 1 then
        self.schTime = 0
        if self.isShowActing == false then
        if self.count ~= 0 then
            for i = 1, 4 do
                if self.players[i].chatBg ~= nil then
                    if not self.players[i].isShowAct then
                        if math.random(1, 100) <= radom[self.count] then
                            self.players[i].isShowAct = true
                            local v = self.players[i]
                            --[[
                            v.chatBg:setOpacity(0)

                            v.chat:setVisible(false)

                             v.chatBg:runAction(cc.FadeIn:create(0.8))
                             v.chatBg:setScale(0.01)
                             v.chatBg:setVisible(true)
                             v.chatBg:runAction(cc.Sequence:create(cc.ScaleTo:create(0.5, 1.2), cc.ScaleTo:create(0.2, 1) , cc.CallFunc:create( function() v.chat:setVisible(true)   v.chat:setOpacity(0)  v.chat:runAction(cc.FadeIn:create(0.5)) end )))
                             performWithDelay(self, function()
                                 v.chatBg:runAction(cc.FadeOut:create(0.5))
                                 v.chat:runAction(cc.FadeOut:create(0.5))
                                 performWithDelay(self, function()
                                 self.players[i].isShowAct = false
                                 end,0.5)
                             end , 3.3)

                             --]]

                            v.chatBg:setOpacity(0)
                            for i = 1, 6 do
                                v.chat[i]:setVisible(false)
                            end
                            v.chatBg:runAction(cc.FadeIn:create(0.8))
                            v.chatBg:setScale(0.01)
                            v.chatBg:setVisible(true)
                            v.chatBg:runAction(cc.Sequence:create(cc.ScaleTo:create(0.5, 1.2), cc.ScaleTo:create(0.2, 1)))

                            for i = 1, 6 do
                                performWithDelay(self, function()
                                    v.chat[i]:setVisible(true)
                                    v.chat[i]:setOpacity(0)
                                    v.chat[i]:runAction(cc.FadeIn:create(0.5))
                                end , 0.8 +(i - 1) * 0.08)
                            end

                            performWithDelay(self, function()
                                v.chatBg:runAction(cc.FadeOut:create(0.5))
                                for i = 1, 6 do
                                    v.chat[i]:runAction(cc.FadeOut:create(0.5))
                                end
                                performWithDelay(self, function()
                                    self.players[i].isShowAct = false
                                end , 0.5)
                            end , 3.3)
                        end
                        -- ]]
                    end
                end
            end
            end
        end
    end
    if not self.delayTime then
        return
    end
    self.delayTime = self.delayTime - dt
    if self.delayTime <= 0 then
        self.sale_index = self.sale_index + 1
        self.delayTime = 600
        --self:updateInfo(self.roomPlayers)
        self:closeUI()
    end
    self.time_m:setString(math.floor(self.delayTime / 60))
    self.time_s:setString(math.floor(self.delayTime % 60))
end

function SaleLayer:updateUI(event)
    self.sale_index = event.result.index
    self:updateInfo(event.result.plays)
    self.roomPlayers = event.result.plays

    self:createLayerAct()
end

function SaleLayer:getInfo()
    if not self.sale_list["" .. self.sale_index] then
        self.sale_index = 1
    end

    local index = self.sale_list["" .. self.sale_index].ingame_sale_id
    local sale_data
    for k, v in pairs(self.price_list) do
        if v.purchase_id == index then
            sale_data = v
        end
    end
    local info = {
        time = bole.slot_sale_time,
        tips = "And these players will each receive",
        freeCoins = bole:formatCoins(self.mulit * sale_data.coins_amount,12),
        coins = bole:formatCoins(sale_data.coins_amount,12),
        price = "Now only $" .. sale_data.price,
    }
    dump(info, "info")
    dump(sale_data, "sale_data")
    return info, sale_data
end

function SaleLayer:updateInfo(plays)
    self.count = 0
    local data = self:getInfo()
    if data.tips then
        self.tips:setString(data.tips)
    end
    if data.coins then
        self.coins:setString(data.coins)
    end
    if data.price then
        self.price:setString(data.price)
    end
    if data.time then
        self.delayTime = data.time
    end
    if data.freeCoins then
        self.freeCoins:setString(data.freeCoins)
    end
    if plays then
        self:initPlayer(plays)
    end
    self:updatePos()
end

function SaleLayer:updatePos()
    
    self.players[1]:setPosition(195, 245)
    self.players[2]:setPosition(195 + 170, 245)
    self.players[3]:setPosition(195 + 170 * 2, 245)
    self.players[4]:setPosition(195 + 170 * 3, 245)
    self.nobody:setVisible(false)
    if self.count == 0 then
        self.nobody:setVisible(true)
    elseif self.count == 1 then
        self.nobody:setVisible(false)
        self.players[1]:setPosition(195 + 170 + 85, 245)
    elseif self.count == 2 then
        self.nobody:setVisible(false)
        self.players[1]:setPosition(195 + 170, 245)
        self.players[2]:setPosition(195 + 170 * 2, 245)
    elseif self.count == 3 then
        self.nobody:setVisible(false)
        self.players[1]:setPosition(195 + 85, 245)
        self.players[2]:setPosition(195 + 170 + 85, 245)
        self.players[3]:setPosition(195 + 170 * 2 + 85, 245)
    end
end

function SaleLayer:initPlayer(data)
    for i =1 ,4 do
        self.players[i]:removeAllChildren()
    end
    for k, v in pairs(data) do
        local headNode = bole:getNewHeadView(v)
        self.players[k]:addChild(headNode)

        headNode:updatePos(headNode.POS_SCALE_FRIEND)
        headNode:setScale(0.9)
        self:setChatAct(self.players[k])
        self.count = self.count + 1
    end
end 

function SaleLayer:setChatAct(node)
    local chatBg = cc.Sprite:create("head/common_chatting.png")
    chatBg:setAnchorPoint(0,0)
    chatBg:setVisible(false)
    chatBg:setPosition(30,15)
    node:addChild(chatBg)
    node.chatBg = chatBg
    node.showChatTime = math.random(2, 2 )*0.5
   node.isShowAct = false
    --[[
    local chatStr = cc.Label:createWithTTF("Buy it!", "font/bole_ttf.ttf", 18)
    chatStr:setTextColor({ r = 0, g = 0, b = 0} )
    chatStr:setAnchorPoint(0,0)
    chatBg:addChild(chatStr)
    node.chat = chatStr
    chatStr:setPosition(5,20)
    --]]

    
    node.chat = {}
    local xchat = {"b" , "u" , "y" ,"i" , "t" , "!"}
    local num = 10
    for i = 1,6 do
        local c = cc.Label:createWithTTF(xchat[i], "font/bole_ttf.ttf", 18)
        c:setTextColor({ r = 0, g = 0, b = 0} )
        chatBg:addChild(c)
        node.chat[i] = c
        c:setPosition(num ,30)
        num = num + c:getContentSize().width - 1
    end
    --]]
end

function SaleLayer:touchEvent(sender, eventType)
    local name = sender:getName()
    local tag = sender:getTag()
    print("touchEvent:" .. name)
    if eventType == ccui.TouchEventType.began then
    sender:setScale(1.05)
        print("Touch Down")
    elseif eventType == ccui.TouchEventType.moved then
        print("Touch Move")
    elseif eventType == ccui.TouchEventType.ended then
        sender:setScale(1)
        print("Touch Up")
        if name == "btn_get" then
            local _, price = self:getInfo()
            dump(price,"price")
            bole:getBuyManage():buy(price.commodity_id)
            --bole:postEvent("showSaleAct")
        end
        if name == "btn_close" then
            self:closeUI()
        end
    elseif eventType == ccui.TouchEventType.canceled then
        sender:setScale(1)
        print("Touch Cancelled")
    end
end

function SaleLayer:onEnter()
    bole:addListener("closeSaleLayer", self.closeUI, self, nil, true)
end

function SaleLayer:onExit()
    bole:removeListener("closeSaleLayer", self)
end

function SaleLayer:createLayerAct()
    self.nobody:setVisible(false)
    self.bg3:setVisible(false)
    self.btn_get:setVisible(false)
    for i = 1, 4 do
        self.players[i]:setVisible(false)
    end

    bole:autoOpacityC(self)
    self.isShowActing = true
    local addTime = 0
    self.root:setOpacity(0)
    self.root:runAction(cc.FadeIn:create(0.5))
    self.root:setScale(0.01)
    self.root:runAction(cc.Sequence:create(cc.ScaleTo:create(0.3, 1.05), cc.ScaleTo:create(0.3, 1)))
    addTime = addTime + 0.5

    if self.count == 0 then
        performWithDelay(self, function()
            self.nobody:setVisible(true)
            self.nobody:setOpacity(0)
            self.nobody:runAction(cc.FadeIn:create(0.2))
        end , addTime)
        addTime = addTime + 0.5
    else
        for i = 1,  4 do
            if self.players[i].chatBg ~= nil then
                performWithDelay(self, function()
                    self.players[i]:setVisible(true)
                    self.players[i]:setOpacity(0)
                    self.players[i]:runAction(cc.FadeIn:create(0.5))
                end , addTime)  
                addTime = addTime + 0 
            else
                self.players[i]:setVisible(true)
            end
        end
        addTime = addTime + 0.5
    end
    performWithDelay(self, function()
        self.bg3:setVisible(true)
        self.bg3:setPosition(-110,34)
        self.bg3:runAction(cc.MoveTo:create(0.2,cc.p(107,34)))
    end , addTime)
    addTime = addTime + 0.4

    performWithDelay(self, function()
        self.btn_get:setVisible(true)
        self.btn_get:setOpacity(0)
        self.btn_get:runAction(cc.FadeIn:create(0.5))
        performWithDelay(self, function() 
            self.isShowActing = false
        end,0.5)
    end , addTime)
end

return SaleLayer
-- endregion
