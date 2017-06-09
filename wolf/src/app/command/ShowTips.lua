-- region *.lua
-- Date
-- 此文件由[BabeLua]插件自动生成
local ShowTips = class("ShowTips", cc.Node)

function ShowTips:ctor(path, theme_id)
    self.theme_id=theme_id
    self.sprite = cc.Sprite:create(path)
     
    if not self.sprite then
        print("show tips error path:" .. path)
--        return
        self.sprite = cc.Sprite:create("tips_test1.png")
    end

    self:addChild(self.sprite)
    local time = math.random(1, 5) / 10
    performWithDelay(self, function()
        local delayTime = 1.5
        local ac1 = cc.EaseInOut:create(cc.MoveTo:create(delayTime, cc.p(0, 6)), 1)
        local ac2 = cc.ScaleTo:create(delayTime, 1.01)

        local ac3 = cc.EaseInOut:create(cc.MoveTo:create(delayTime, cc.p(0, -6)), 1)
        local ac4 = cc.ScaleTo:create(delayTime, 1)

        local ac5 = cc.Spawn:create(ac1, ac2)
        local ac6 = cc.Spawn:create(ac3, ac4)
        local seq = cc.Sequence:create(ac5, ac6)

        self.sprite:runAction(cc.RepeatForever:create(seq))
    end , time)

end
return ShowTips
-- endregion
