-- region *.lua
-- Date
-- 此文件由[BabeLua]插件自动生成
local ShowTips = class("ShowTips", cc.Node)

function ShowTips:ctor(theme_id)
    if theme_id == 6 then
        local path = bole:getSpinApp():getRes(nil,"tips_bg.png")
        self.sprite = display.newSprite(path)
        local path_txt = bole:getSpinApp():getRes(nil,"tips_txt.png")
        local txt=display.newSprite(path_txt)
        self.sprite:addChild(txt)
        txt:setPosition(self.sprite:getContentSize().width/2,self.sprite:getContentSize().height/2)
    end

    if not self.sprite then
        return
    end

    self.theme_id = theme_id
    self:addChild(self.sprite)
    performWithDelay(self, function()
        bole:autoOpacityC(self.sprite)
        self.sprite:runAction(cc.FadeOut:create(0.5))
    end , 8)
--    self:runAct(self.sprite)
end
function ShowTips:runAct(node)
    local delayTime = 1.5
    local ac1 = cc.EaseInOut:create(cc.MoveTo:create(delayTime, cc.p(1, 4)), 1)
    local ac2 = cc.ScaleTo:create(delayTime, 1.01)

    local ac3 = cc.EaseInOut:create(cc.MoveTo:create(delayTime, cc.p(-1, -2)), 1)
    local ac4 = cc.ScaleTo:create(delayTime, 1)

    local ac5 = cc.Spawn:create(ac1, ac2)
    local ac6 = cc.Spawn:create(ac3, ac4)
    local seq = cc.Sequence:create(ac5, ac6)

    node:runAction(cc.RepeatForever:create(seq))
end
return ShowTips
-- endregion
