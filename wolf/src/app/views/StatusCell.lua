-- region *.lua
-- Date
-- 此文件由[BabeLua]插件自动生成
local StatusCell = class("StatusCell", ccui.Layout)
function StatusCell:ctor(index)
    self:setContentSize( { width = 570, height = 80 })
    self.index = index

    if self.index%2==1 then
        self.bg=ccui.ImageView:create("player_edit/ui/edit_profile_item_light.png")
    else
        self.bg=ccui.ImageView:create("player_edit/ui/edit_profile_item_dark.png")
    end
    self.bg:setScale(80 / self.bg:getContentSize().height)
    self.bg:setAnchorPoint(cc.p(0.5,0.5))
    self.bg:setPosition(285, 40.0000)
    self:addChild(self.bg)

    local name = {"Secret","Single","In a relationship","Married"}
    local ttfConfig = {fontFilePath="font/bole_ttf.ttf",fontSize=36}
    local txt_name = cc.Label:createWithTTF(ttfConfig,"99")
    txt_name:setTextColor({r = 211, g = 233, b = 244 })
    txt_name:setAnchorPoint(cc.p(0.5,0.5))
    txt_name:setPosition(285,40)
    txt_name:setString(name[index+1])
    self:addChild(txt_name)
    self.txt_name = txt_name

    self:setTouchEnabled(true)
    self:addTouchEventListener(handler(self, self.touchEvent))

    self.sp_select=display.newSprite("common/common_g5.png")
    self.sp_select:setAnchorPoint(cc.p(0,0.5))
    self.sp_select:setPosition(480, 40.0000)
    self:addChild(self.sp_select)
    self.sp_select:setVisible(false)
    self:updateStatus()
end
function StatusCell:touchEvent(sender, eventType)
    local name = sender:getName()
    local tag = sender:getTag()
    if eventType == ccui.TouchEventType.began then
        print("Touch Down")
    elseif eventType == ccui.TouchEventType.moved then
        print("Touch Move")
    elseif eventType == ccui.TouchEventType.ended then
        print("Touch ended")
        bole:postEvent("changeAgeStutas", self.index)
    elseif eventType == ccui.TouchEventType.canceled then
        print("Touch Cancelled")
    end
end
function StatusCell:getIndex()
    return self.index
end
function StatusCell:updateStatus(index)
    local isSelf = false
    local selfIndex=bole:getUserDataByKey("marital_status")
    if index then
        selfIndex=index
    end
    if selfIndex == self.index then
        isSelf = true
    end
    if isSelf then
--        self.txt_name:setTextColor({r = 211, g = 233, b = 244 })
        self.sp_select:setVisible(true)
    else
--        self.txt_name:setTextColor({r = 133, g = 179, b = 254 })
        self.sp_select:setVisible(false)
    end
end
return StatusCell
-- endregion
-- endregion
