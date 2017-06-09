-- region *.lua
-- Date
-- 此文件由[BabeLua]插件自动生成
local KindLayer = class("KindLayer", cc.load("mvc").ViewBase)
function KindLayer:onCreate()
    print("KindLayer:onCreate")


    self.kindNode=self:getCsbNode():getChildByName("kindNode")
    self.kindAct=cc.CSLoader:createTimeline("5ofkindeffect/KindNode.csb")
    self.kindNode:runAction(self.kindAct)
    self.kindAct:play("start",false)
    performWithDelay(self,function() 
        self:over()
    end,4.5)


    self.kind = self:getCsbNode():getChildByName("root")
    self.kind:setVisible(false)
    --    self:initKind()
end
function KindLayer:initKind()
    self.kind:setVisible(false)
    self.kind:setScale(0.1)
    self.kind:runAction(cc.ScaleTo:create(0.2,1.0))
    local btn_ok = ccui.Helper:seekWidgetByName(self.kind, "btn_ok")
    btn_ok:addTouchEventListener(handler(self, self.touchEvent))
    local txt_body = ccui.Helper:seekWidgetByName(self.kind, "txt_body")
    self.node_icon = self.kind:getChildByName("node_icon")
    performWithDelay(self,function() 
        self:over()
    end,2)
end

function KindLayer:initView(msg, data)
--    if msg == "kind" then
--        if not data then return end
--        local sp = display.newSprite("#" .. data)
--        if sp then
--            self.node_icon:addChild(sp)
--        end
--    end
end
function KindLayer:over()
    self:removeFromParent()
    bole:postEvent("dialog_pop")
end
function KindLayer:touchEvent(sender, eventType)
    local name = sender:getName()
    local tag = sender:getTag()
    print("touchEvent:" .. name)
    if eventType == ccui.TouchEventType.began then
        print("Touch Down")
    elseif eventType == ccui.TouchEventType.moved then
        print("Touch Move")
    elseif eventType == ccui.TouchEventType.ended then
        print("Touch Up")
        self:over()
    elseif eventType == ccui.TouchEventType.canceled then
        print("Touch Cancelled")
    end
end
return KindLayer
-- endregion
