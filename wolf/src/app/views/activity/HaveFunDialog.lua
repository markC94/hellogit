--region *.lua
--Date
--此文件由[BabeLua]插件自动生成

local BaseActDialog = bole:getTable("app.views.activity.BaseActDialog")
local HaveFunDialog = class("HaveFunDialog", BaseActDialog)
function HaveFunDialog:ctor(data)
    self.rootNode = HaveFunDialog.super.ctor(self, "activity/FiveStarsLayer.csb")
    self:initView(data)
end

function HaveFunDialog:initView()
    local no_thanks = self.rootNode:getChildByName("no_thanks")
    no_thanks:addTouchEventListener(handler(self, self.touchEvent))
    local maybe_later = self.rootNode:getChildByName("maybe_later")
    maybe_later:addTouchEventListener(handler(self, self.touchEvent))
end


function HaveFunDialog:touchEvent(sender, eventType)
    local name = sender:getName()
    if eventType == ccui.TouchEventType.began then
        --sender:runAction(cc.ScaleTo:create(0.1, 1.05, 1.05))
    elseif eventType == ccui.TouchEventType.moved then

    elseif eventType == ccui.TouchEventType.ended then
        --sender:runAction(cc.ScaleTo:create(0.1, 1, 1))
        if name == "no_thanks" then
            self:closeUI()
        elseif name == "maybe_later" then
            self:closeUI()
        end
    elseif eventType == ccui.TouchEventType.canceled then
        --sender:runAction(cc.ScaleTo:create(0.1, 1, 1))
    end
end


function HaveFunDialog:onSure()
    bole:openGooglePlay()
end


return HaveFunDialog

--endregion
