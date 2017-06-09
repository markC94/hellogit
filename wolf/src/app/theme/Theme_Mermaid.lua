--region *.lua
--Date
--此文件由[BabeLua]插件自动生成

local Theme_Mermaid = class("Theme_Mermaid", bole:getTable("app.theme.BaseTheme"))

function Theme_Mermaid:ctor(themeId, app, data)
    print("Theme_Mermaid:ctor")
    self.symbols =
    {
        {0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14},
        {0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14},
        {0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14},
        {0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14},
        {0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14}
    }

    Theme_Mermaid.super.ctor(self, themeId, app, data)
end

function Theme_Mermaid:onEnter()
    print("Theme_Mermaid:onEnter")
    Theme_Mermaid.super.onEnter(self)
    bole:addListener("startFreeSpin", self.onStartSpin, self, nil, true)
    bole:addListener("stopFreeSpin", self.onStopSpin, self, nil, true)
    bole:addListener("free_spin_stop", self.onFreeSpinOver, self, nil, true)
end

function Theme_Mermaid:onExit()
    print("Theme_Mermaid:onExit")
    bole:removeListener("startFreeSpin", self)
    bole:removeListener("stopFreeSpin", self)
    bole:removeListener("free_spin_stop", self)
    Theme_Mermaid.super.onExit(self)
end

function Theme_Mermaid:onDealWithMiniGameData(data)
    print("Theme_Mermaid:onDealWithMiniGameData")
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

function Theme_Mermaid:onStartSpin(event)
    print("Theme_Mermaid:onStartSpin")
    self:changeMatrix(102)
end

function Theme_Mermaid:onStopSpin(event)
    print("Theme_Mermaid:onStopSpin")
    bole:postEvent("freespin_dialog", {allData = self.thisReceiveData})
end

function Theme_Mermaid:onFreeSpinOver(event)
    print("Theme_Mermaid:onFreeSpinOver")
    self:changeMatrix(101)
    bole:postEvent("spinStatus", "spinEnabled")
end

function Theme_Mermaid:enterThemeDataFilter(data)
    print("Theme_Mermaid:enterThemeDataFilter")
    Theme_Mermaid.super.enterThemeDataFilter(self, data)
end

function Theme_Mermaid:onDataFilter(data)
    print("Theme_Mermaid:onDataFilter")
    Theme_Mermaid.super.onDataFilter(self, data)
    data.win_lines = {}
end

function Theme_Mermaid:addListeners()
    Theme_Mermaid.super.addListeners(self)
    self:addListenerForNext("popupDialog", self.onMiniEffect)
end

return Theme_Mermaid

--endregion
