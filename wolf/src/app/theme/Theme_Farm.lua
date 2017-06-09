--region *.lua
--Date
--此文件由[BabeLua]插件自动生成

local Theme_Farm = class("Theme_Farm", bole:getTable("app.theme.BaseTheme"))

function Theme_Farm:ctor(themeId, app)
    print("Theme_Farm:ctor")
    Theme_Farm.super.ctor(self, themeId, app)
end

function Theme_Farm:onDealWithMiniGameData(data)
    print("Theme_Farm:onDealWithMiniGameData")
--    if data then
--        if data.freeSpin and data.freeSpin > 0 then
--            self.isHaveMiniGame = true
--            self.freeSpinCount = data.freeSpin
--            self.freeSpinFeatureId = data.feature_id
--            self.freeSpinMultiple = data.multiple

--            self.freeSpinCoins = 0
--            self.freeSpinCollect = 0
--        end
--    end
end

function Theme_Farm:enterThemeDataFilter(data)
    print("Theme_Farm:enterThemeDataFilter")
    Theme_Farm.super.enterThemeDataFilter(self, data)
end

function Theme_Farm:onDataFilter(data)
    print("Theme_Farm:onDataFilter")
    Theme_Farm.super.onDataFilter(self, data)
end

function Theme_Farm:addListeners()
    Theme_Farm.super.addListeners(self)
    self:addListenerForNext("popupDialog", self.onMiniEffect)
end

function Theme_Farm:setFreeSpinPosition(x, y)
    y = y - 16
    Theme_Farm.super.setFreeSpinPosition(self, x, y)
end

function Theme_Farm:addOtherAsyncImage(weights)
    local promptKey = string.format("theme/theme%d/tishi.png", self.themeId)
    table.insert(weights, promptKey)
end

return Theme_Farm

--endregion
