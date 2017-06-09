-- region *.lua
-- Date
-- 此文件由[BabeLua]插件自动生成
local SlotsLobbyScene = class("SlotsLobbyScene", cc.load("mvc").ViewBase)
function SlotsLobbyScene:onCreate()
    print("SlotsLobbyScene-onCreate")
    local root = self:getCsbNode():getChildByName("root")
    self:initBtn(root)
    bole:getUIManage():addTopLayer(self)

    local btn_friend = ccui.Helper:seekWidgetByName(root, "btn_friend")
    btn_friend:addTouchEventListener(handler(self, self.touchEvent))

    local btn_ach = ccui.Helper:seekWidgetByName(root, "btn_ach")
    btn_ach:addTouchEventListener(handler(self, self.touchEvent))

    local btn_gift = ccui.Helper:seekWidgetByName(root, "btn_gift")
    btn_gift:addTouchEventListener(handler(self, self.touchEvent))
end
function SlotsLobbyScene:initBtn(root)                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                             
    local scorll_mode = ccui.Helper:seekWidgetByName(root, "scorll_mode")
    local scorll_width = 0
    local indexs={2,5,6,7} 
    for i = 1, 4 do
        local page = math.floor((i - 1) / 10)
        local index = math.floor((i - 1) % 10)
        local temp_w = 0
        local cell = bole:getEntity("app.views.lobby.LobbyCell",indexs[i])
        if index < 5 then
            temp_w = 140 + 260 *(index) + page * 1300
            cell:setPosition(temp_w, 410)
        else
            temp_w = 140 + 260 *(index - 5) + page * 1300
            cell:setPosition(temp_w, 160)
        end
        if scorll_width < temp_w then
            scorll_width = temp_w + 140
        end
        scorll_mode:addChild(cell)
    end
    scorll_mode:setInnerContainerSize( { width = scorll_width, height = 555.0000 })
end

function SlotsLobbyScene:touchEvent(sender, eventType)
    local name = sender:getName()
    local tag = sender:getTag()
    print("touchEvent:" .. name)
    if eventType == ccui.TouchEventType.began then
        print("Touch Down")
        sender:setScale(1.05)
    elseif eventType == ccui.TouchEventType.moved then
        print("Touch Move")
    elseif eventType == ccui.TouchEventType.ended then
        print("Touch Up")
        sender:setScale(1)
    elseif eventType == ccui.TouchEventType.canceled then
        print("Touch Cancelled")
        sender:setScale(1)
    end
end

return SlotsLobbyScene


-- endregion
