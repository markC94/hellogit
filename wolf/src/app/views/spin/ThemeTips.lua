-- region *.lua
-- Date
-- 此文件由[BabeLua]插件自动生成
local ThemeTips = class("ThemeTips", cc.Node)

function ThemeTips:ctor(theme_id)
    self.theme_id = theme_id
    self.node = cc.CSLoader:createNode("themetips/theme_unlock.csb")
    self.act = cc.CSLoader:createTimeline("themetips/theme_unlock.csb")
    self:addChild(self.node)
    self.node:runAction(self.act)
    local root = self.node:getChildByName("root")
    local panel_theme_unlock = root:getChildByName("panel_theme_unlock")
    local icon_theme = root:getChildByName("icon_theme")
    local num = string.format("%02d", self.theme_id)
    icon_theme:loadTexture("theme_icon/theme_" .. num .. ".png")
    self.act:play("pop",false)
    performWithDelay(self,function()
        self.act:play("over",false)
    end,3)
    performWithDelay(self,function()
        self:removeSelf()
    end,4)
end

function ThemeTips:removeSelf()
    self:removeFromParent()
end
return ThemeTips
-- endregion
