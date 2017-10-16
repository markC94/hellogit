--region *.lua
--Date
--此文件由[BabeLua]插件自动生成


local FriendPopLayer = class("FriendPopLayer", cc.load("mvc").ViewBase)

function FriendPopLayer:onCreate()
    print("FriendPopLayer:onCreate")
    self.root_ = self:getCsbNode():getChildByName("root")
    self.top_ = self.root_:getChildByName("top")

    self:initTop()
    self:adaptScreen()
end

function FriendPopLayer:onEnter()

end

function FriendPopLayer:initTop()
    --self.top_:getChildByName("title"):setString("Search Friends")
    local btn_close = self.top_:getChildByName("btn_close")
    btn_close:addTouchEventListener(handler(self, self.touchEvent))

    local txt = self.root_:getChildByName("txt")
    txt:setString("Invite have been sent.")
end


function FriendPopLayer:touchEvent(sender, eventType)
    local name = sender:getName()
    if eventType == ccui.TouchEventType.began then
        sender:runAction(cc.ScaleTo:create(0.1, 1.05, 1.05))
    elseif eventType == ccui.TouchEventType.moved then

    elseif eventType == ccui.TouchEventType.ended then
        sender:runAction(cc.ScaleTo:create(0.1, 1, 1))
        if name == "btn_close" then
            self:closeUI()
        end
    elseif eventType == ccui.TouchEventType.canceled then
        sender:runAction(cc.ScaleTo:create(0.1, 1, 1))
    end
end

function FriendPopLayer:adaptScreen()
    local winSize = cc.Director:getInstance():getWinSize()
    self:setPosition(0,0)
    self.root_:setPosition(winSize.width / 2, winSize.height / 2)
    --self.root_:setScale(0.1)
    --self.root_:runAction(cc.ScaleTo:create(0.2,1,1))
end


return FriendPopLayer


--endregion
