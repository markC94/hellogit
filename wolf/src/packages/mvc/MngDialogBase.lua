--region *.lua
--Date
--此文件由[BabeLua]插件自动生成
local MngDialogBase = class("MngDialogBase", cc.load("mvc").ViewBase)
function MngDialogBase:onCreate()
    local root = self:getCsbNode():getChildByName("root")
    if not root then return end
    self.img_over = ccui.Helper:seekWidgetByName(root, "img_over")
    self.img_start = ccui.Helper:seekWidgetByName(root, "img_start")
    if self.img_over then
        self.img_over:setVisible(false)
    else
        print("error----not img_over")
    end
    if self.img_start then
        self.img_start:setVisible(false)
    else
        print("error----not img_start")
    end
    self.game_id=0
    self:initDialog()
end

function MngDialogBase:initDialog()
   
end

function MngDialogBase:back()
    bole:postEvent("free_spin_stop")
    self:removeFromParent()
end

function MngDialogBase:start()
    bole:postEvent("next_data",{ freeSpin = self.chose[1],feature_id=self.game_id})
    bole:postEvent("next_miniGame")
    self:removeFromParent()
end

function MngDialogBase:updateUI(data)
    data = data.result
    if not data.msg then return end
    
    if data.msg == "start" then
       self.chose=data.chose
       self:initStart(data.chose)
    elseif data.msg == "over" then
       self:initOver(data.chose)
    end
end
function MngDialogBase:initOver(data)
    if not self.img_over then return end
    self.img_over:setVisible(true)
    self.img_over:setScale(0.1)
    self.img_over:runAction(cc.ScaleTo:create(0.2,1.0))
    local txt_free = ccui.Helper:seekWidgetByName(self.img_over, "txt_free")
    local txt_coins = ccui.Helper:seekWidgetByName(self.img_over, "txt_coins") b
    local txt_all = ccui.Helper:seekWidgetByName(self.img_over, "txt_all")
    local btn_back = ccui.Helper:seekWidgetByName(self.img_over, "btn_back")
    if btn_back then
        btn_back:addTouchEventListener(handler(self, self.touchEvent))
    end
    if txt_free then
        txt_free:setString(""..data[1])
    end
    if txt_coins then
        txt_coins:setString(""..data[2])
    end
    if txt_all then
        txt_all:setString("X"..data[3])
    end
end
function MngDialogBase:initStart(data)
    if not self.img_start then return end
    self.img_start:setVisible(true)
    self.img_start:setScale(0.1)
    self.img_start:runAction(cc.ScaleTo:create(0.2,1.0))
    local txt_free = ccui.Helper:seekWidgetByName(self.img_start, "txt_free")
    local txt_all = ccui.Helper:seekWidgetByName(self.img_start, "txt_all")
    local btn_start = ccui.Helper:seekWidgetByName(self.img_start, "btn_start")
    if btn_start then
        btn_start:addTouchEventListener(handler(self, self.touchEvent))
    end
    if txt_free then
        txt_free:setString(""..data[1])
    end
    if txt_coins then
        txt_coins:setString(""..data[2])
    end
    if txt_all then
        txt_all:setString("X"..data[3])
    end
end

function MngDialogBase:touchEvent(sender, eventType)
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
            self:back()
         elseif (name == "btn_start") then
            self:start()
        end
    elseif eventType == ccui.TouchEventType.canceled then
        print("Touch Cancelled")
    end
end
return MngDialogBase


--endregion
