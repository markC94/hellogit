--region *.lua
--Date
--此文件由[BabeLua]插件自动生成

local ShopCell = class("ShopCell", ccui.Layout)
ShopCell.iconPath = {"res/shop/common_lottoTicket.png",
                     "res/shop/shop_icon_vipPoint.png",
                     "res/shop/shop_xp.png",
                     "res/shop/shop_speedUp.png"}

function ShopCell:ctor( i ,type , showInfo)
    self.node_ = cc.CSLoader:createNode("csb/shop/ShopCell.csb")
    self:addChild(self.node_)
    self:setContentSize( { width = 1230, height = 95 })

    local root = self.node_:getChildByName("root")
    self.iconBg_ = root:getChildByName("iconBg")
    self.icon_ = root:getChildByName("icon")
    self.txt1_ = root:getChildByName("txt1")
    self.txt2_ = root:getChildByName("txt2")
    root:getChildByName("txt_m"):setString("$")
    self.txt_money_ = root:getChildByName("txt_money")
    local btn_but = root:getChildByName("btn_but")
    btn_but:addTouchEventListener(handler(self, self.touchEvent))
    self.bestSeller_ = root:getChildByName("bestSeller")
    self.mostPopular_ = root:getChildByName("mostPopular")
    self.more_ = root:getChildByName("more")

    self.showInfo_ = showInfo
    self:initView( root,i ,type )
end



function ShopCell:getReward(idList)
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


function ShopCell:initView( root ,i,type)
    if type == 1 then
        self.icon_:loadTexture("res/shop/shop_coins_0" .. i .. ".png")
    elseif type == 2 then
        self.icon_:loadTexture("res/shop/shop_diamond_0" .. i .. ".png")
    end


    self.bestSeller_:setVisible(false)
    self.mostPopular_:setVisible(false)
    if i == 1 then
        self.bestSeller_:setVisible(true)
    elseif i == 3 then
        self.mostPopular_:setVisible(true)
    end

    self.txt1_:setString( bole:formatCoins(self.showInfo_.num,15))
    self.txt2_:setString(bole:formatCoins(self.showInfo_.num,15))
    self.txt_money_:setString(self.showInfo_.price)

    local myDrawNode=cc.DrawNode:create()  
    root:addChild(myDrawNode, 10)  
    myDrawNode:setPosition(cc.p(0,0))  
    myDrawNode:drawSegment(cc.p(175,66), cc.p(175 + self.txt1_:getContentSize().width,66),1, cc.c4f(1 , 0.43 , 0.43 , 1))  

    for i = 1, 4 do
        root:getChildByName("reward_" .. i ):setVisible(false)
    end


    local reward = self:getReward(self.showInfo_.reward)
    for k ,v in pairs(reward) do

         if v.type == 2 then -- 铜卷
            root:getChildByName("reward_1"):setVisible(true)
            root:getChildByName("reward_1"):loadTexture("res/shop/levelup_lottoBronze.png")
            root:getChildByName("reward_1"):getChildByName("txt"):setString("+" .. v.number)
         elseif v.type == 3 then --银卷
            root:getChildByName("reward_1"):setVisible(true)
            root:getChildByName("reward_1"):loadTexture("res/shop/levelup_lottoSilver.png")
            root:getChildByName("reward_1"):getChildByName("txt"):setString("+" .. v.number)
         elseif v.type == 4 then --金券
            root:getChildByName("reward_1"):setVisible(true)
            root:getChildByName("reward_1"):loadTexture("res/shop/levelup_lottoGold.png")
            root:getChildByName("reward_1"):getChildByName("txt"):setString("+" .. v.number)
         elseif v.type == 8 then --大厅加速券
            root:getChildByName("reward_4"):setVisible(true)
            root:getChildByName("reward_4"):getChildByName("txt"):setString("+" .. v.number .. "s")
         elseif v.type == 1 then --双倍经验
            root:getChildByName("reward_3"):setVisible(true)
            root:getChildByName("reward_3"):getChildByName("txt"):setString("+" .. v.number .. "s")
         end     
    end

    root:getChildByName("reward_2"):setVisible(true)
    root:getChildByName("reward_2"):getChildByName("txt"):setString("+" .. self.showInfo_.vipPoints)
end

function ShopCell:touchEvent(sender, eventType)
    local name = sender:getName()
    if eventType == ccui.TouchEventType.began then
        sender:runAction(cc.ScaleTo:create(0.1, 1.05, 1.05))
    elseif eventType == ccui.TouchEventType.moved then

    elseif eventType == ccui.TouchEventType.ended then
        sender:runAction(cc.ScaleTo:create(0.1, 1, 1))
        if name == "btn_but" then

        end
    elseif eventType == ccui.TouchEventType.canceled then
        sender:runAction(cc.ScaleTo:create(0.1, 1, 1))
    end
end


return ShopCell
--endregion
