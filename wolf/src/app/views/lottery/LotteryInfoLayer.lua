--region *.lua
--Date
--此文件由[BabeLua]插件自动生成

local LotteryInfoLayer = class("LotteryInfoLayer", cc.load("mvc").ViewBase)

function LotteryInfoLayer:onCreate()
    print("LotteryInfoLayer-onCreate")
    local root = self:getCsbNode():getChildByName("root") 
    local btn_close = root:getChildByName("btn_close")
    btn_close:addTouchEventListener(handler(self, self.touchEvent))
    self:adaptScreen(root)
end

function LotteryInfoLayer:onEnter()
   
end

function LotteryInfoLayer:touchEvent(sender, eventType)
    local name = sender:getName()
    print("touchEvent:" .. name)
    if eventType == ccui.TouchEventType.began then
        print("Touch Down")
        sender:setScale(1.05)
    elseif eventType == ccui.TouchEventType.moved then
        print("Touch Move")
    elseif eventType == ccui.TouchEventType.ended then
        print("Touch Up")
        sender:setScale(1)
        if name == "btn_close" then
            self:closeUI()
        end
    elseif eventType == ccui.TouchEventType.canceled then
        print("Touch Cancelled")
        sender:setScale(1)
    end
end

function LotteryInfoLayer:adaptScreen(root)
    local winSize = cc.Director:getInstance():getWinSize()
    root:setPosition(winSize.width / 2, winSize.height / 2)
end

function LotteryInfoLayer:onExit()
    
end


return LotteryInfoLayer


--endregion
