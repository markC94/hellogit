--region *.lua
--Date
--此文件由[BabeLua]插件自动生成
local OfflineView = class("OfflineView", cc.LayerColor)
function OfflineView:ctor()
    self:onTouch(function() return true end, false, true)
    self:initWithColor(cc.c4b(0, 0, 0, 200))

    local animNode = sp.SkeletonAnimation:create("netloading/loading.json", "netloading/loading.atlas")
    self:addChild(animNode)
    animNode:setPosition(display.cx,display.cy)
    animNode:setAnimation(0, "animation", true)

    self:enableNodeEvents()

    bole:getBoleEventKey():clearKeyBack()
    bole:getAudioManage():stopAllMusic()
end

function OfflineView:onEnter()
    bole:getBoleEventKey():addKeyBack(self)
    bole:addListener("socketConnectOk", self.onConnectOk, self, nil, true)
    bole:addListener("loginGameSuccess", self.onLoginSuccess, self, nil, true)
    bole:addListener("sendMsgError", self.onLoginError, self, nil, true)
    bole:addListener("runOfflineView", self.onRemoveSelf, self, nil, true)
end

function OfflineView:onExit()
    bole:getBoleEventKey():removeKeyBack(self)
    bole:removeListener("socketConnectOk", self)
    bole:removeListener("loginGameSuccess", self)
    bole:removeListener("sendMsgError", self)
    bole:removeListener("runOfflineView", self)
end

function OfflineView:onKeyBack()
end

function OfflineView:run()
    bole:postEvent("runOfflineView")
    cc.Director:getInstance():getRunningScene():addChild(self, bole.ZORDER_NET)
end

function OfflineView:onRemoveSelf()
    self:removeFromParent(true)
end

function OfflineView:onConnectOk(event)
    print("OfflineView:onConnectOk")
    bole:getLoginControl():sendLoginMsg()
end

function OfflineView:onLoginSuccess(event)
    print("OfflineView:onLoginSuccess")
    bole:getLoginControl():enterLobbyView()
end

function OfflineView:onLoginError()
    print("OfflineView:onLoginError")
    bole:getLoginControl():onLoginError()
end

return OfflineView
--endregion
