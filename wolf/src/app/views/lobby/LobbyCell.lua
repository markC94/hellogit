-- region *.lua
-- Date
-- 此文件由[BabeLua]插件自动生成
local LobbyCell = class("LobbyCell", cc.Node)

function LobbyCell:ctor(theme_id)
    self.theme_id = theme_id
    print("self.theme_id:"..self.theme_id)
    self.cell = cc.CSLoader:createNode("csb/lobby/LobbyCell.csb")
    self:addChild(self.cell)
    self.img_icon = self.cell:getChildByName("img_icon")
    local function touchEvent(sender, eventType)
        if eventType == ccui.TouchEventType.began then
            sender:setScale(1.05)
        elseif eventType == ccui.TouchEventType.ended then
            sender:setScale(1)
            print("self.theme_id:"..self.theme_id)
            bole:getAppManage():startGame(self.theme_id)
        elseif eventType == ccui.TouchEventType.canceled then
            sender:setScale(1)
        end
    end

    self.img_icon:setTouchEnabled(true)
    self.img_icon:addTouchEventListener(touchEvent)
    self.img_icon:setSwallowTouches(false)
    self:updateImg()
end

function LobbyCell:updateImg()
    if self.theme_id <= 10 then
        local num=string.format("%02d",self.theme_id)
        self.img_icon:loadTexture("theme_icon/theme_"..num..".png")
    else
        local num=string.format("%02d",math.random(1,10))
        self.img_icon:loadTexture("theme_icon/theme_"..num..".png")
    end
end

return LobbyCell
-- endregion
