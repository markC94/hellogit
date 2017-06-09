-- region *.lua
-- Date
-- 此文件由[BabeLua]插件自动生成
local NetSprite = class("NetSprite", cc.Sprite)
--根据url生成精灵
function NetSprite:ctor(url,tag)
    self:init(url,tag)
end

function NetSprite:init(url,tag)
    bole:getUrlImage(url,tag,function(fileName, tagNum)
        if tagNum==tag then
            self:updateTexture(fileName)
        end
    end)
end

function NetSprite:updateTexture(fileName)
    self:setTexture(fileName)
end

return NetSprite

-- endregion
