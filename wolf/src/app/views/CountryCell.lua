-- region *.lua
-- Date
-- 此文件由[BabeLua]插件自动生成
local CountryCell = class("CountryCell", ccui.Layout)
function CountryCell:ctor(index,bgIndex)
    self:setContentSize( { width = 570, height = 80 })
    self.index = index
    if index == -1 then
        index = 2
    end
    
    if bgIndex%2==1 then
        self.bg=ccui.ImageView:create("player_edit/ui/edit_profile_item_light.png")
    else
        self.bg=ccui.ImageView:create("player_edit/ui/edit_profile_item_dark.png")
    end
    self.bg:setScale(80 / self.bg:getContentSize().height)
    self.bg:setAnchorPoint(cc.p(0.5,0.5))
    self.bg:setPosition(285, 40)
    self:addChild(self.bg)

    local sp_icon=display.newSprite("flag/flag_" .. index .. ".png")
    sp_icon:setPosition(64,40)
    self:addChild(sp_icon)

    local name = bole:getConfig("country", index, "countryname_en")
    local ttfConfig = {fontFilePath="font/bole_ttf.ttf",fontSize=36}
    local txt_name = cc.Label:createWithTTF(ttfConfig,"99")
    txt_name:setAnchorPoint(cc.p(0,0.5))
    txt_name:setPosition(120,40)
    txt_name:setString(name)
    print("----------------------------------index:"..index)
    print("----------------------------------name:"..name)
    self:addChild(txt_name)

    self.img_icon = sp_icon
    self.txt_name = txt_name

    self:setTouchEnabled(true)
    self:addTouchEventListener(handler(self, self.touchEvent))
    local index = bole:getUserDataByKey("country")

    self.sp_select=display.newSprite("common/common_g5.png")
    self.sp_select:setPosition(515, 40)
    self:addChild(self.sp_select)
    self.sp_select:setVisible(false)

    self:updateStatus()
end
function CountryCell:touchEvent(sender, eventType)
    local name = sender:getName()
    local tag = sender:getTag()
    if eventType == ccui.TouchEventType.began then
        print("Touch Down")
    elseif eventType == ccui.TouchEventType.moved then
        print("Touch Move")
    elseif eventType == ccui.TouchEventType.ended then
        print("Touch ended")
        bole:postEvent("changeCountry", self.index)
    elseif eventType == ccui.TouchEventType.canceled then
        print("Touch Cancelled")
    end
end
function CountryCell:getIndex()
    return self.index
end
function CountryCell:updateStatus(index)
    local isSelf = false
    local selfIndex=bole:getUserDataByKey("country")
    if index then
        selfIndex=index
    end
    if selfIndex == self.index then
        isSelf = true
    end
    if self.index == -1 then
        self.img_icon:setVisible(false)
        self.txt_name:setVisible(false)
        return
    end
    if isSelf then
        self.img_icon:setScale(0.8)
--        self.txt_name:setScale(1.1)
        self.sp_select:setVisible(true)
    else
        self.img_icon:setScale(0.8)
        self.sp_select:setVisible(false)
--        self.txt_name:setScale(1)
    end
    
end
return CountryCell
-- endregion
