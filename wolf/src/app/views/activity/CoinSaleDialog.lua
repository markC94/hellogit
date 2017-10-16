--region *.lua
--Date
--此文件由[BabeLua]插件自动生成
local BaseActDialog = bole:getTable("app.views.activity.BaseActDialog")
local CoinSaleDialog = class("CoinSaleDialog", BaseActDialog)
function CoinSaleDialog:ctor(data)
    self.rootNode = CoinSaleDialog.super.ctor(self, "activity/CoinSaleAct.csb")
    self:initView(data)
end

function CoinSaleDialog:initView(data)
    self.buyData = bole:getBuyManage():getPriceDataById(data)
    local saleNum = self.rootNode:getChildByName("saleNum")
    local money = self.rootNode:getChildByName("money")
    local saleThing = self.rootNode:getChildByName("saleThing")
    local extroAward = self.rootNode:getChildByName("extroAward")
    saleNum:setString(bole:formatCoins(self.buyData.coins_amount,15))
    if self.buyData .coins_amount == 0 then
        saleNum:setString(bole:formatCoins(self.buyData.diamonds_amount,15))
    end
    --saleThing:setPositionX(saleThing:getPositionX() + 100 - saleNum:getContentSize().width / 2)
    money:setString("$" .. self.buyData.price)
    extroAward:setString("+" .. self.buyData.vipp_amount ..  " VIP Points")
end

function CoinSaleDialog:onSure()
    bole:postEvent("purchase", self.buyData.commodity_id )
end


return CoinSaleDialog
--endregion
