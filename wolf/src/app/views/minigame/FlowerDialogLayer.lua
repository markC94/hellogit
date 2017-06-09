--region *.lua
--Date
--此文件由[BabeLua]插件自动生成
local FlowerDialogLayer = class("FlowerDialogLayer", cc.load("mvc").ViewBase)
function FlowerDialogLayer:onCreate()
    local root = self:getCsbNode():getChildByName("root")
    self.img_over = ccui.Helper:seekWidgetByName(root, "img_over")
    self.img_start = ccui.Helper:seekWidgetByName(root, "img_start")
    self.img_over:setVisible(false)
    self.img_start:setVisible(false)
    self.collect_count=0
end
function FlowerDialogLayer:updateUI(data)
    data = data.result
    if not data.msg then return end
    
    if data.msg == "start" then
       self.chose=data.chose
       self:initStart(data.chose)
    elseif data.msg == "over" then
       self:initOver(data.chose)
    end
end
function FlowerDialogLayer:initOver(data)
    self.img_over:setVisible(true)
    self.img_over:setScale(0.1)
    self.img_over:runAction(cc.ScaleTo:create(0.2,1.0))
    local txt_free = ccui.Helper:seekWidgetByName(self.img_over, "txt_free")
    local txt_coins = ccui.Helper:seekWidgetByName(self.img_over, "txt_coins")
    local btn_back = ccui.Helper:seekWidgetByName(self.img_over, "btn_back")
    btn_back:addTouchEventListener(handler(self, self.touchEvent))
    txt_free:setString(""..data[1])
    txt_coins:setString(""..data[2])
end
function FlowerDialogLayer:initStart(data)
    self.img_start:setVisible(true)
    self.img_start:setScale(0.1)
    self.img_start:runAction(cc.ScaleTo:create(0.2,1.0))
    local txt_free = ccui.Helper:seekWidgetByName(self.img_start, "txt_free")
    txt_free:setString(""..data[1])
    performWithDelay(self,function() 
        bole:postEvent("next_data",{ freeSpin = self.chose[1],feature_id=bole.MINIGAME_ID_FLOWER_FREESPIN})
        bole:postEvent("next_miniGame")
        self:removeFromParent()
    end,3)
end


function FlowerDialogLayer:touchEvent(sender, eventType)
    local name = sender:getName()
    local tag = sender:getTag()
    print("touchEvent:" .. name)
    if eventType == ccui.TouchEventType.began then
        print("Touch Down")
    elseif eventType == ccui.TouchEventType.moved then
        print("Touch Move")
    elseif eventType == ccui.TouchEventType.ended then
        print("Touch Up")
        if (name == "btn_back") then
            bole:postEvent("free_spin_stop")
            self:removeFromParent()
         elseif (name == "btn_start") then
            
        end
    elseif eventType == ccui.TouchEventType.canceled then
        print("Touch Cancelled")
    end
end
return FlowerDialogLayer
--endregion
