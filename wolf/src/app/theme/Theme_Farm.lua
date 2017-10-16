--region *.lua
--Date
--此文件由[BabeLua]插件自动生成

local Theme_farm = class("Theme_farm", bole:getTable("app.theme.BaseTheme"))

function Theme_farm:ctor(themeId, app)
    print("Theme_farm:ctor")
    Theme_farm.super.ctor(self, themeId, app)
end

function Theme_farm:createOtherNodes(spinBg, orderTable)
    local frameBgSize = spinBg:getContentSize()
    local flowerSp = cc.Sprite:create(self.app:getRes(self.themeId, "farm_top_flower", "png"))
    flowerSp:setPosition(frameBgSize.width/2, frameBgSize.height + 40)
    spinBg:addChild(flowerSp)
end

function Theme_farm:addOtherAsyncImage(weights)
    table.insert(weights, self.app:getRes(self.themeId, "farm_top_flower", "png"))
    table.insert(weights, self.app:getSymbolAnimImg(self.themeId, "tishi"))
end

return Theme_farm

--endregion
