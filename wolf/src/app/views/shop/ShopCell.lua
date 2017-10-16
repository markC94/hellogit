--region *.lua
--Date
--此文件由[BabeLua]插件自动生成

local ShopCell = class("ShopCell", ccui.Layout)
local CellNum = 5

function ShopCell:ctor( i ,type , showInfo)
    self.node_ = cc.CSLoader:createNode("shop_lobby/ShopCell.csb")
    self:addChild(self.node_)
    self:setContentSize( { width = 1070, height = 100 })

    local root = self.node_:getChildByName("root")
    self.icon_ = root:getChildByName("icon")
    self.bg_ = root:getChildByName("bg1")
    if i == 1 then
        self.bg_:loadTexture("shop_icon/shop_itemBlue.png")
        root:getChildByName("img_bestV"):setVisible(true)
    end
    if i == 3 then
        self.bg_:loadTexture("shop_icon/shop_itemBlue.png")
        root:getChildByName("img_mostP"):setVisible(true)
    end
    self.txt2_ = root:getChildByName("txt2")
    root:getChildByName("txt_m"):setString("$")
    self.txt_money_ = root:getChildByName("txt_money")
    local btn_buy = root:getChildByName("btn_buy")
    btn_buy:addTouchEventListener(handler(self, self.touchEvent))

    --[[
    local btn_buyAct = sp.SkeletonAnimation:create("shop_act/buy_saoguang_1.json", "shop_act/buy_saoguang_1.atlas")
    btn_buyAct:setAnimation(0, "animation", true)
    btn_buyAct:setPosition(100, 40)
    btn_buy:addChild(btn_buyAct)
    --]]

    self.showInfo_ = showInfo
    self.moreMul_ = root:getChildByName("more_img"):getChildByName("txt")

    self:initView(root, i, type)

    --[[
    if i == 1 or i == 3 then
        local cellAct = sp.SkeletonAnimation:create("shop_act/most_popular_1.json", "shop_act/most_popular_1.atlas")
        cellAct:setAnimation(0, "animation", true)
        cellAct:setPosition(526, 44)
        self.node_:addChild(cellAct)
    end
    --]]
        --cellAct:setPosition(130, 85)
end

function ShopCell:initView( root ,i,type)
    if type == 1 then
        local icon = cc.Sprite:create("shop_icon/shop_coins0" .. CellNum - i + 1 .. ".png")
        self.icon_:addChild(icon)
    elseif type == 2 then
        local icon = cc.Sprite:create("shop_icon/shop_diamond0" .. CellNum - i + 1 .. ".png")
        self.icon_:addChild(icon)
    end

    --[[
    self.bestSeller_:setVisible(false)
    self.mostPopular_:setVisible(false)
    if i == 1 then
        self.bestSeller_:setVisible(true)
    elseif i == 3 then
        self.mostPopular_:setVisible(true)
    end
    --]]
        --self.txt1_:setString( bole:formatCoins(self.showInfo_.fakeNum,15))
    local num = self.showInfo_.num
    if type == 1 then
        num = num * bole:getBuyManage():getCoinsShopMul()
    end
    self.txt2_:setString(bole:formatCoins(num ,15))
   
    self.txt_money_:setString(self.showInfo_.price)
    self.moreMul_:setString(bole:getBuyManage():getCoinsShopMulShowNum(self.showInfo_.commodity_id))
    root:getChildByName("vip_point"):setString("+ " .. self.showInfo_.vipP .. " VIP Points")
    --[[
    local myDrawNode=cc.DrawNode:create()  
    root:addChild(myDrawNode, 10)  
    myDrawNode:setPosition(cc.p(0,0))  
    myDrawNode:drawSegment(cc.p(175,66), cc.p(175 + self.txt1_:getContentSize().width,66),1, cc.c4f(1 , 0.43 , 0.43 , 1))  
    --]]

    --[[
    for i = 1, 4 do
        if root:getChildByName("reward_" .. i ) ~= nil then
            root:getChildByName("reward_" .. i ):setVisible(false)
        end
    end
    --]]

    local reward = bole:getBuyManage():getReward(self.showInfo_.reward)
    local showIconIndex = 0
    for i = 1 ,# reward do 
        local v = reward[i]
         if v.type ~= 5 then
            showIconIndex = showIconIndex + 1
         end
         if v.type == 2 or v.type == 3 or v.type == 4 then -- 铜卷 --银卷 --金券
            local lotteryIcon
            if v.type == 2 then
                lotteryIcon = cc.Sprite:create("shop_icon/shop_lotto_copper.png")
            elseif v.type == 3 then
                lotteryIcon = cc.Sprite:create("shop_icon/shop_lotto_silver.png")
            elseif v.type == 4 then
                lotteryIcon = cc.Sprite:create("shop_icon/shop_lotto_gold.png")
            end
            lotteryIcon:setScale(1.5)
            lotteryIcon:setPosition(0,10)
            local num = cc.Label:createWithTTF("x " .. v.number, "font/bole_ttf.ttf", 25)
            num:setAnchorPoint(0.5,0.5)
            num:setTextColor({ r = 241, g = 235, b = 88})
            --num:enableOutline({r = 241, g = 235, b = 88, a = 255}, 1)
            num:setPosition(0, -25)
            root:getChildByName("reward_" .. showIconIndex):addChild(lotteryIcon)
            root:getChildByName("reward_" .. showIconIndex):addChild(num)

         elseif v.type == 8 then --大厅加速券
            local jiasuIcon = cc.Sprite:create("shop_icon/shop_clockIcon.png")
            root:getChildByName("reward_" .. showIconIndex):addChild(jiasuIcon)
         elseif v.type == 1 then --双倍经验
            local shuangbeiIcon = cc.Sprite:create("shop_icon/shop_exp_24h.png")
            root:getChildByName("reward_" .. showIconIndex):addChild(shuangbeiIcon)
         elseif v.type == 5 then --vip积分
            root:getChildByName("vip_point"):setString("+ " .. v.number .. " VIP Points")
            --root:getChildByName("reward_2"):setVisible(true)
            --root:getChildByName("reward_2"):getChildByName("txt"):setString("+" .. v.number)
         end     
    end

    --root:getChildByName("reward_2"):setVisible(true)
    --root:getChildByName("reward_2"):getChildByName("txt"):setString("+" .. self.showInfo_.vipPoints)
end

function ShopCell:touchEvent(sender, eventType)
    local name = sender:getName()
    if eventType == ccui.TouchEventType.began then
        sender:runAction(cc.ScaleTo:create(0.1, 1.05, 1.05))
    elseif eventType == ccui.TouchEventType.moved then

    elseif eventType == ccui.TouchEventType.ended then
        sender:runAction(cc.ScaleTo:create(0.1, 1, 1))
        if name == "btn_buy" then
            self:buy()
        end
    elseif eventType == ccui.TouchEventType.canceled then
        sender:runAction(cc.ScaleTo:create(0.1, 1, 1))
    end
end

function ShopCell:buy()
    bole:getBuyManage():buy(self.showInfo_.commodity_id)
end


return ShopCell
--endregion
