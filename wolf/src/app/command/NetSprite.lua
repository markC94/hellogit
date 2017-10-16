-- region *.lua
-- Date
-- 此文件由[BabeLua]插件自动生成
local NetSprite = class("NetSprite", cc.Sprite)
--根据url生成精灵
function NetSprite:ctor(url,isLocal)
    self.head = sp.SkeletonAnimation:create("util_act/loadingHead.json", "util_act/loadingHead.atlas")
    self.head:setAnimation(0, "animation", true)
    self:addChild(self.head)
    self:init(url,isLocal)
end

function NetSprite:init(url, isLocal)
    bole:getUrlImage(url, isLocal, function(fileName, eventCode)
        if tagNum == tag then
            if eventCode == 6 then
                self:updateTexture(fileName)
            else
                if self.head then
                    self.head:removeFromParent()
                    self.head = nil
                end
            end
        end
    end )
end

function NetSprite:updateTexture(fileName)
    print("fileName:"..fileName)
    self:setTexture(fileName)
    if self.head then
        self.head:removeFromParent()
        self.head=nil
    end
end

return NetSprite

-- endregion
