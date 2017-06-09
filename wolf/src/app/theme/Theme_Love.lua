--region *.lua
--Date
--此文件由[BabeLua]插件自动生成

local Theme_Love = class("Theme_Love", bole:getTable("app.theme.BaseTheme"))

function Theme_Love:ctor(themeId, app, data)
    print("Theme_Love:ctor")
    self.symbols =
    {
        {0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11},
        {0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11},
        {0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11},
        {0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11},
        {0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11}
    }

    Theme_Love.super.ctor(self, themeId, app, data)
end

function Theme_Love:onEnter()
    print("Theme_Love:onEnter")
    Theme_Love.super.onEnter(self)
    bole:addListener("startFreeSpin", self.onStartSpin, self, nil, true)
    bole:addListener("stopFreeSpin", self.onStopSpin, self, nil, true)
    bole:addListener("free_spin_stop", self.onFreeSpinOver, self, nil, true)
end

function Theme_Love:onExit()
    print("Theme_Love:onExit")
    bole:removeListener("startFreeSpin", self)
    bole:removeListener("stopFreeSpin", self)
    bole:removeListener("free_spin_stop", self)
    Theme_Love.super.onExit(self)
end

function Theme_Love:onDealWithMiniGameData(data)
    print("Theme_Love:onDealWithMiniGameData")
    if data then
        if data.feature_id then
            self.freeSpinFeatureId = data.feature_id
            self.isHaveMiniGame = true
        end
    end
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

function Theme_Love:onStartSpin(event)
    print("Theme_Love:onStartSpin")
    self:changeMatrix(102)
    if self.freeSpinFeatureId == 10102 then
        self.framBg:setTexture(string.format("theme/theme%s/%s.png", self.themeId, "freeSpin_frame"))
    end
end

function Theme_Love:onStopSpin(event)
    print("Theme_Love:onStopSpin")
    bole:postEvent("freespin_dialog", {msg = "over", allData = self.thisReceiveData, freeSpinFeatureId = self.freeSpinFeatureId, chose = {self.freeSpinTotal, self.freeSpinCoins}})
    self:updateFrameTexture()
end

function Theme_Love:onFreeSpinOver(event)
    print("Theme_Love:onFreeSpinOver")
    self:changeMatrix(101)

    self.freeSpinFeatureId = nil
    self.freeSpinTotal = 0
    bole:postEvent("spinStatus", "spinEnabled")
end

function Theme_Love:enterThemeDataFilter(data)
    print("Theme_Love:enterThemeDataFilter")
    Theme_Love.super.enterThemeDataFilter(self, data)
end

function Theme_Love:onDataFilter(data)
    print("Theme_Love:onDataFilter")
    Theme_Love.super.onDataFilter(self, data)
end

function Theme_Love:addListeners()
    Theme_Love.super.addListeners(self)
    self:addListenerForNext("popupDialog", self.onMiniEffect)
end

return Theme_Love

--endregion
