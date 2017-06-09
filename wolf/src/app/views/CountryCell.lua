-- region *.lua
-- Date
-- 此文件由[BabeLua]插件自动生成
local CountryCell = class("CountryCell",ccui.Layout)
function CountryCell:ctor(index)
    self:setContentSize({ width = 430, height = 70 })
    -- Create txt_name
    self.index=index
    local txt_name = ccui.Text:create()
    txt_name:ignoreContentAdaptWithSize(true)
    txt_name:setTextAreaSize( { width = 0, height = 0 })
    txt_name:setFontName("font/FZKTJW.TTF")
    txt_name:setFontSize(26)
    txt_name:setString([[Algeria]])
    txt_name:setLayoutComponentEnabled(true)
    txt_name:setName("txt_name")
    txt_name:setTag(289)
    txt_name:setCascadeColorEnabled(true)
    txt_name:setCascadeOpacityEnabled(true)
    txt_name:setPosition(62.2800, 35.0000)
    txt_name:setAnchorPoint(0,0.5000)
    txt_name:setTextColor( { r = 95, g = 129, b = 158 })
    local layout = ccui.LayoutComponent:bindLayoutComponent(txt_name)
    layout:setPositionPercentX(0.1415)
    layout:setPositionPercentY(0.5000)
    layout:setPercentWidth(0.1705)
    layout:setPercentHeight(0.4000)
    layout:setSize( { width = 75.0000, height = 28.0000 })
    layout:setLeftMargin(24.7800)
    layout:setRightMargin(340.2200)
    layout:setTopMargin(21.0000)
    layout:setBottomMargin(21.0000)
    self:addChild(txt_name)
    self.txt_name=txt_name
    -- Create sp_icon
    cc.SpriteFrameCache:getInstance():addSpriteFrames("plist/Head.plist")
    local sp_icon = cc.Sprite:createWithSpriteFrameName("head/levelup_N_CN.png")
    sp_icon:setName("sp_icon")
    sp_icon:setTag(290)
    sp_icon:setCascadeColorEnabled(true)
    sp_icon:setCascadeOpacityEnabled(true)
    sp_icon:setPosition(373.7934, 35.0000)
    layout = ccui.LayoutComponent:bindLayoutComponent(sp_icon)
    layout:setPositionPercentX(0.8495)
    layout:setPositionPercentY(0.5000)
    layout:setPercentWidth(0.1023)
    layout:setPercentHeight(0.6286)
    layout:setSize( { width = 45.0000, height = 44.0000 })
    layout:setLeftMargin(351.2934)
    layout:setRightMargin(43.7066)
    layout:setTopMargin(13.0000)
    layout:setBottomMargin(13.0000)
    sp_icon:setBlendFunc( { src = 1, dst = 771 })
    self:addChild(sp_icon)
    self.sp_icon=sp_icon
    self:initCell(index)
    self:setTouchEnabled(true)
    self:addTouchEventListener(handler(self, self.touchEvent))
end
function CountryCell:touchEvent(sender, eventType)
    local name = sender:getName()
    local tag = sender:getTag()
    print("touchEvent:" .. name)
    if eventType == ccui.TouchEventType.began then
        print("Touch Down")
    elseif eventType == ccui.TouchEventType.moved then
        print("Touch Move")
    elseif eventType == ccui.TouchEventType.ended then
        bole:postEvent("changeSelect", self.index)
    elseif eventType == ccui.TouchEventType.canceled then
        print("Touch Cancelled")
    end
end
function CountryCell:initCell(index)
    local name=bole:getConfig("country",index,"countryname_en")
    self.txt_name:setString(name)
end
return CountryCell
-- endregion
