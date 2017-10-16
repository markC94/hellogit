--region *.lua
--Date
--此文件由[BabeLua]插件自动生成
local BaseActDialog = bole:getTable("app.views.activity.BaseActDialog")
local VipSaleDialog = class("VipSaleDialog", BaseActDialog)
function VipSaleDialog:ctor()
    self.root = VipSaleDialog.super.ctor(self, "activity/VipSaleAct.csb")
end

function VipSaleDialog:onSure()
    self.root:getParent():onClose()
    bole:getUIManage():openUI("ShopLayer",true,"shop")
end

return VipSaleDialog
--endregion
