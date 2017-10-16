--region *.lua
--Date
--此文件由[BabeLua]插件自动生成
local BaseActDialog = bole:getTable("app.views.activity.BaseActDialog")
local LoyalSaleDialog = class("LoyalSaleDialog", BaseActDialog)
function LoyalSaleDialog:ctor(data)
    self.rootNode = LoyalSaleDialog.super.ctor(self, "activity/LoyalSaleAct.csb",data)
    self:initView(data)
end

function LoyalSaleDialog:initView(data)
    self.buyData = bole:getBuyManage():getPriceDataById(data)


    local coinsPanel = self.rootNode:getChildByName("panel_coins")
    local money = self.rootNode:getChildByName("money")
    local saleNum = coinsPanel:getChildByName("num")
    local extroAward = self.rootNode:getChildByName("extroAward")
    local headNode = self.rootNode:getChildByName("head")
    local playerTxt1 = self.rootNode:getChildByName("playerTxt1")
    local playerTxt2 = self.rootNode:getChildByName("playerTxt2")
    local panel_time = self.rootNode:getChildByName("panel_time")
    local node_clock = panel_time:getChildByName("node_act")
    local clockAct = sp.SkeletonAnimation:create("shop_act/biao_1.json", "shop_act/biao_1.atlas")
    clockAct:setScale(0.6)
    clockAct:setAnimation(0, "animation", true)
    node_clock:addChild(clockAct)
    self:startUpdate()

    self.time_1 = panel_time:getChildByName("time_m")
    self.time_2 = panel_time:getChildByName("time_s")
    self.unit_1 = panel_time:getChildByName("time_1")
    self.unit_2 = panel_time:getChildByName("time_2")

    local coinsIcon = cc.Sprite:create("shop_icon/shop_coins04.png")
    self.rootNode:getChildByName("panel_coins"):getChildByName("icon"):addChild(coinsIcon)
    saleNum:setString("+" .. bole:formatCoins(self.buyData.coins_amount,15))
    money:setString("$" .. self.buyData.price)
    extroAward:setString("+" .. self.buyData.vipp_amount ..  " VIP Points")

    local head = bole:getNewHeadView(bole:getUserData())
    head:setScale(0.95)
    headNode:addChild(head)
    head:updatePos(head.POS_LOYALSALE)

    local reward = bole:getBuyManage():getReward(self.buyData.item_id)
    
    local showIconIndex = 1
    for i = 1 ,# reward do 
        local v = reward[i]
         if v.type == 2 or v.type == 3 or v.type == 4 then -- 铜卷 --银卷 --金券
            local lotteryIcon
            if v.type == 2 then
                lotteryIcon = cc.Sprite:create("shop_icon/shop_lotto_copper.png")
            elseif v.type == 3 then
                lotteryIcon = cc.Sprite:create("shop_icon/shop_lotto_silver.png")
            elseif v.type == 4 then
                lotteryIcon = cc.Sprite:create("shop_icon/shop_lotto_gold.png")
            end
            --[[
            lotteryIcon:setScale(1.5)
            lotteryIcon:setPosition(0,10)
            local num = cc.Label:createWithTTF("x " .. v.number, "font/bole_ttf.ttf", 25)
            num:setAnchorPoint(0.5,0.5)
            num:setTextColor({ r = 241, g = 235, b = 88})
            num:setPosition(0, -25)
            --]]
            lotteryIcon:setScale(2)
            self.rootNode:getChildByName("panel_" .. showIconIndex):getChildByName("icon"):addChild(lotteryIcon)
            self.rootNode:getChildByName("panel_" .. showIconIndex):getChildByName("num"):setString("+" .. v.number)
            --self.rootNode:getChildByName("panel_" .. showIconIndex):getChildByName("icon"):addChild(num)
            showIconIndex = showIconIndex + 1
         elseif v.type == 8 then --大厅加速券
            local jiasuIcon = cc.Sprite:create("shop_icon/shop_clockIcon.png")
            jiasuIcon:setScale(2)
            self.rootNode:getChildByName("panel_" .. showIconIndex):getChildByName("icon"):addChild(jiasuIcon)
            self.rootNode:getChildByName("panel_" .. showIconIndex):getChildByName("num"):setString("+" .. 1)
            showIconIndex = showIconIndex + 1
         elseif v.type == 1 then --双倍经验
            local shuangbeiIcon = cc.Sprite:create("shop_icon/shop_exp_24h.png")
            shuangbeiIcon:setScale(1.5)
            self.rootNode:getChildByName("panel_" .. showIconIndex):getChildByName("icon"):addChild(shuangbeiIcon)
            self.rootNode:getChildByName("panel_" .. showIconIndex):getChildByName("num"):setString("+" .. 1)
            showIconIndex = showIconIndex + 1
         end     
    end
end

function LoyalSaleDialog:startUpdate()
    local function update(dt)
        self:updateTime(dt)
    end
    self:onUpdate(update)
end

function LoyalSaleDialog:updateTime(dt)
    if not bole.loyal_surplus_time then
        return
    end

    if bole.loyal_surplus_time > 0 then
        local s = math.floor(bole.loyal_surplus_time) % 60
        local m = math.floor(bole.loyal_surplus_time / 60) % 60
        local h = math.floor(bole.loyal_surplus_time / 3600) % 24
        local d = math.floor(bole.loyal_surplus_time / 86400)
        if d == 0 then
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
            self.unit_1:setString("D")
            self.unit_2:setString("H")
            self.time_1:setString(d)
            self.time_2:setString(h)
        end
    end
end

function LoyalSaleDialog:onSure()
    bole:postEvent("purchase", self.buyData.commodity_id )
end

return LoyalSaleDialog
--endregion
