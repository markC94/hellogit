-- region *.lua
-- Date
-- 此文件由[BabeLua]插件自动生成
local DialogLayer = class("DialogLayer", cc.Node)
function DialogLayer:ctor(data, funcOk, funcNo)
    local node = cc.CSLoader:createNode("csb/DialogLayer.csb")
    self:addChild(node)
    self.root = node:getChildByName("root")
    self.funcOk = funcOk
    self.funcNo = funcNo
    self.root:setOpacity(0)
    self.root:setScale(0.1)
    local sp=cc.Spawn:create(cc.FadeIn:create(0.2),cc.ScaleTo:create(0.2,1))
    self.root:runAction(sp)
    local btn_ok = self.root:getChildByName("btn_ok")
    btn_ok:addTouchEventListener(handler(self,self.touchEvent))
    local btn_no = self.root:getChildByName("btn_no")
    btn_no:addTouchEventListener(handler(self,self.touchEvent))
    if not data then
        btn_ok:setPosition(667,260)
        btn_no:setVisible(false)
        return
    end
    --只有OK
    if not data.cancle then
        btn_ok:setPosition(667,260)
        btn_no:setVisible(false)
    end
    --显示信息
    if data.msg then
       local sp_bg2 = self.root:getChildByName("sp_bg2")
       local txt_tips = sp_bg2:getChildByName("txt_tips")
       txt_tips:setString(data.msg)
    end
    --标题
    if data.title then
       local txt_title = self.root:getChildByName("txt_title")
       txt_title:setString(data.title)
    end
end

function DialogLayer:closeUI()
    bole:autoOpacityC(self)
    local sp=cc.Spawn:create(cc.FadeOut:create(0.2),cc.ScaleTo:create(0.2,0.1))
    local act = cc.CallFunc:create(handler(self, self.removeSelf))
    self.root:runAction(cc.Sequence:create(sp, act))
end

function DialogLayer:removeSelf()
    self:removeFromParent()
end
function DialogLayer:touchEvent(sender, eventType)
    local name = sender:getName()
    local tag = sender:getTag()
    print("touchEvent:" .. name)
    if eventType == ccui.TouchEventType.began then
        print("Touch Down")
    elseif eventType == ccui.TouchEventType.moved then
        print("Touch Move")
    elseif eventType == ccui.TouchEventType.ended then
        print("Touch Up")
        if name == "btn_ok" then
            if self.funcOk then
                self.funcOk()
            end
            self:closeUI()
        end
        if name == "btn_no" then
            if self.funcNo then
                self.funcNo()
            end
            self:closeUI()
        end
    elseif eventType == ccui.TouchEventType.canceled then
        print("Touch Cancelled")
    end
end
return DialogLayer


-- endregion
