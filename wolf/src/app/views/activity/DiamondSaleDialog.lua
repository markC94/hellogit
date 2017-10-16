--region *.lua
--Date
--此文件由[BabeLua]插件自动生成
local BaseActDialog = bole:getTable("app.views.activity.BaseActDialog")
local DiamondSaleDialog = class("DiamondSaleDialog", BaseActDialog)
function DiamondSaleDialog:ctor(data)
    self.rootNode = DiamondSaleDialog.super.ctor(self, "activity/DiamondSaleAct.csb")
    self:initView(data)
end

function DiamondSaleDialog:initView(data)
    self.buyData = bole:getBuyManage():getPriceDataById(data)
    local saleNum = self.rootNode:getChildByName("saleNum")
    local money = self.rootNode:getChildByName("money")
    local extroAward = self.rootNode:getChildByName("extroAward")
    saleNum:setString(bole:formatCoins(self.buyData.coins_amount,15))
    extroAward:setString("+" .. self.buyData.vipp_amount)
    if self.buyData .coins_amount == 0 then
        saleNum:setString(bole:formatCoins(self.buyData.diamonds_amount,15))
    end

    money:setString("$" .. self.buyData.price)
end

function DiamondSaleDialog:onSure()
    bole:postEvent("purchase", self.buyData.commodity_id )
end

return DiamondSaleDialog
--endregion
