-- region *.lua
-- Date
-- 此文件由[BabeLua]插件自动生成

local GradientText = class("GradientText", cc.Node)
function GradientText:ctor()
    local color self:getColorText("c03.png","你好世界ksdlfjsaodifjasdgo")
end

function GradientText:getColorText(imgPath,name)
    local clipNode = cc.ClippingNode:create()

    clipNode:setAlphaThreshold(0.5)
    local txt=self:getTxt(name)
    clipNode:setStencil(txt)

    local color = display.newSprite(imgPath)
    color:setScaleX(txt:getContentSize().width / color:getContentSize().width)
    color:setScaleY(txt:getContentSize().height / color:getContentSize().height)
    clipNode:addChild(color)
    clipNode:setInverted(false)
    
    self:addChild(clipNode)
end

function GradientText:getTxt(txt)
    local Text_1 = ccui.Text:create()
    Text_1:ignoreContentAdaptWithSize(true)
    Text_1:setTextAreaSize( { width = 0, height = 0 })
    Text_1:setFontName("font/FZKTJW.TTF")
    Text_1:setFontSize(100)
    Text_1:setString(txt)
    Text_1:setLayoutComponentEnabled(true)
    Text_1:setName("Text_1")
    Text_1:setTag(147)
    Text_1:setCascadeColorEnabled(true)
    Text_1:setCascadeOpacityEnabled(true)
    Text_1:setTextColor( { r = 223, g = 181, b = 50 })
    Text_1:enableShadow( { r = 110, g = 110, b = 110, a = 255 }, { width = 2, height = - 2 }, 0)
    Text_1:enableOutline( { r = 191, g = 191, b = 191, a = 255 }, 1)
    local layout = ccui.LayoutComponent:bindLayoutComponent(Text_1)
    layout:setSize( { width = 125.0000, height = 111.0000 })
    layout:setLeftMargin(-62.5000)
    layout:setRightMargin(-62.5000)
    layout:setTopMargin(-55.5000)
    layout:setBottomMargin(-55.5000)
    return Text_1
end
return GradientText

-- endregion
