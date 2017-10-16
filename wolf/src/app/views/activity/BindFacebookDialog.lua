--region *.lua
--Date
--此文件由[BabeLua]插件自动生成
local BaseActDialog = bole:getTable("app.views.activity.BaseActDialog")
local BindFacebookDialog = class("BindFacebookDialog", BaseActDialog)
function BindFacebookDialog:ctor()
    self.root = BindFacebookDialog.super.ctor(self, "activity/bindFacebookAct.csb")
end

function BindFacebookDialog:onSure()
    --self.root:getParent():onClose()
    bole:getFacebookCenter():bindFacebook()
    self:closeUI()
end

return BindFacebookDialog
--endregion
