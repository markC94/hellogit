--region *.lua
--Date
--此文件由[BabeLua]插件自动生成
local EmeraldDialogLayer = class("EmeraldDialogLayer", cc.load("mvc").ViewBase)
function EmeraldDialogLayer:onCreate()
    local root = self:getCsbNode():getChildByName("root")
    self.img_over = ccui.Helper:seekWidgetByName(root, "img_over")
    self.img_start = ccui.Helper:seekWidgetByName(root, "img_start")
    self.img_over:setVisible(false)
    self.img_start:setVisible(false)
    self.collect_count=0
    self.coins=0
end
function EmeraldDialogLayer:updateUI(data)
    data = data.result
    if not data.msg then return end
    
    if data.msg == "start" then
       self.chose=data.chose
       self:initStart(data.chose)
    elseif data.msg == "over" then
       self:initOver(data.chose)
    elseif data.msg == "minigame" then
        --获得数据并开启收集minigame
       self:initMiniGame(data.chose)
    end
end
function EmeraldDialogLayer:initOver(data)
    self.img_over:setVisible(true)
    self.img_over:setScale(0.1)
    self.img_over:runAction(cc.ScaleTo:create(0.2,1.0))
    local txt_coins = ccui.Helper:seekWidgetByName(self.img_over, "txt_coins")
    local txt_tips = ccui.Helper:seekWidgetByName(self.img_over, "txt_tips")
    local txt_all = ccui.Helper:seekWidgetByName(self.img_over, "txt_all")
    local btn_back = ccui.Helper:seekWidgetByName(self.img_over, "btn_back")
    btn_back:addTouchEventListener(handler(self, self.touchEvent))
    txt_coins:setString(""..data[1])
    txt_tips:setString(data[1].."x1="..data[1])
    txt_all:setString("X"..data[2])
    self.collect_count=data[3]
    self.coins=data[1]
end
function EmeraldDialogLayer:initStart(data)
    self.img_start:setVisible(true)
    self.img_start:setScale(0.1)
    self.img_start:runAction(cc.ScaleTo:create(0.2,1.0))
    bole:getMiniGameControl():miniGame_step(0)
end

function EmeraldDialogLayer:initMiniGame(data)
    performWithDelay(self,function()
        bole:getUIManage():openMiniGame(bole.MINIGAME_ID_EMERALD)
        bole:postEvent(bole.UI_NAME.EmeraldGameLayer,data)
        self:removeFromParent()
    end,2)
end

function EmeraldDialogLayer:touchEvent(sender, eventType)
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
            bole:postEvent("next_data",{ collect_count = self.collect_count})
            bole:postEvent("next_miniGame")
            bole:getAppManage():addCoins(self.coins)      
            self:removeFromParent()
        end
    elseif eventType == ccui.TouchEventType.canceled then
        print("Touch Cancelled")
    end
end
return EmeraldDialogLayer
--endregion
