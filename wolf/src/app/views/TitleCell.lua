-- region *.lua
-- Date
-- 此文件由[BabeLua]插件自动生成
local TitleCell = class("TitleCell", ccui.Layout)
function TitleCell:ctor(index)
    self:setContentSize( { width = 430, height = 70 })
    -- Create txt_name
    self.index = index
    self:setTouchEnabled(true)
    self:addTouchEventListener(handler(self, self.touchEvent))
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
    txt_name:setPosition(215.0000, 35.0000)
    txt_name:setAnchorPoint(0.5000, 0.5000)
    txt_name:setTextColor( { r = 85, g = 129, b = 168 })
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
    self.txt_name = txt_name
    -- Create sp_icon
    cc.SpriteFrameCache:getInstance():addSpriteFrames("plist/Head.plist")
    self:initCell(index)
end
function TitleCell:initCell(index)
    print("initCell:" .. index)
    local name = bole:getConfig("title", index, "title_name")
    local data = bole:getUserData()
    if tonumber(index) <= tonumber(data.title_max) then
        self.txt_name:setString(name)
    else
        self.txt_name:setString(name)
        self.txt_name:setTextColor( { r = 190, g = 190, b = 190 })
    end
end
function TitleCell:touchEvent(sender, eventType)
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
        local data = bole:getUserData()
        if tonumber(self.index) <= tonumber(data.title_max) then
            bole:postEvent("changeTitle", self.index)
        end
    elseif eventType == ccui.TouchEventType.canceled then
        print("Touch Cancelled")
        sender:setScale(1)
    end
end
return TitleCell
-- endregion
