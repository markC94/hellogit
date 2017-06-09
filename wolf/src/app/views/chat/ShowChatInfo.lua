--region *.lua
--Date
--此文件由[BabeLua]插件自动生成

local ShowChatInfo = class("ShowChatInfo", cc.Node)

function ShowChatInfo:ctor( layer )
    self.spinLayer_ = layer
    local weghit = ccui.Layout:create()
    weghit:setBackGroundColorType(1)
    weghit:setBackGroundColor({r = 0, g = 0, b = 0})
    weghit:setBackGroundColorOpacity(102)
    weghit:setAnchorPoint(0.5,0.5)
    weghit:setSize(400,50)
    weghit:setTouchEnabled(true)
    weghit:addTouchEventListener(handler(self, self.touchEvent)) 

    self:addChild(weghit)

    self.label_ = cc.Label:createWithTTF("", "res/font/FZKTJW.TTF", 24)
    self.label_:setAnchorPoint(0,0.5)
    self.label_:setPosition(10,25)
    weghit:addChild(self.label_)

    --[[
    self.preLabel_ = cc.Label:createWithTTF("", "res/font/FZKTJW.TTF", 24)
    self.preLabel_:setAnchorPoint(0,0.5)
    self.preLabel_:setPosition(-10,25)
    weghit:addChild(self.preLabel_)
    --]]


    bole:addListener("ShowChatInfo", self.showStr, self, nil, true)
    self:setVisible(false)

    local winSize = cc.Director:getInstance():getWinSize()
    self:setPosition(winSize.width / 2, winSize.height - 100)
end

function ShowChatInfo:showStr(data)

    if self.spinLayer_.chatView_ ~= nil then
        if self.spinLayer_.chatView_:isVisible() then
            return
        end
    end

    local str = data.result.msg
    if data.result.userData ~= nil then
        str = "[" .. data.result.userData.name .. "]" .. data.result.msg
    end
    if string.len(str) > 27 then
        str = string.sub(str,1,27) .. "..."
    end
    self.label_:setString(str)

    self:setVisible(true)
    self.label_:stopAllActions()

    local delay = cc.DelayTime:create(3)
    local hide = cc.CallFunc:create(function()  self:setVisible(false)  end)
    self.label_:runAction(cc.Sequence:create(delay, hide))
end

function ShowChatInfo:touchEvent(sender, eventType)
    local name = sender:getName()
    if eventType == ccui.TouchEventType.began then

    elseif eventType == ccui.TouchEventType.moved then

    elseif eventType == ccui.TouchEventType.ended then
        self:setVisible(false)
        if self.spinLayer_.chatView_ == nil then
            self.spinLayer_:createChatView()
        end
        if not self.spinLayer_.chatView_:isVisible() then
            self.spinLayer_:createChatView()
        end
    elseif eventType == ccui.TouchEventType.canceled then

    end
end

function ShowChatInfo:removeNode()
    bole:getEventCenter():removeEventWithTarget("ShowChatInfo", self)
end



return ShowChatInfo

--endregion
