--region *.lua
--Date
--此文件由[BabeLua]插件自动生成
local WitchFreeSpinView = class("WitchFreeSpinView", bole:getTable("app.theme.oz.FreeSpinView"))
function WitchFreeSpinView:ctor(theme, freeSpinMultiple, freeSpinCoins, order)
    self.freeSpinMultiple = freeSpinMultiple
    self.freeSpinCoins = freeSpinCoins
    WitchFreeSpinView.super.ctor(self, theme, order, "csb/theme/oz/WitchFreeSpinView.csb")
end

function WitchFreeSpinView:onEnter()
    WitchFreeSpinView.super.onEnter(self)
    bole:addListener("coinsChanged", self.onCoinChanged, self, nil, true)
    bole:addListener("freeSpinTotalWin", self.onFreeSpinTotalWin, self, nil, true)
    bole:addListener("winAmount", self.onWinThisSpin, self, nil, true)
    bole:addListener("mng_dialog", self.onStopSpin, self, nil, true)
end

function WitchFreeSpinView:onExit()
    bole:removeListener("coinsChanged", self)
    bole:removeListener("freeSpinTotalWin", self)
    bole:removeListener("winAmount", self)
    bole:removeListener("mng_dialog", self)
    
    WitchFreeSpinView.super.onExit(self)
end

function WitchFreeSpinView:initData()
    WitchFreeSpinView.super.initData(self)
    self.byNum:setString("X" .. self.freeSpinMultiple)
    self.totalWinNum:setString(self.freeSpinCoins)
    self.balanceNum:setString(bole:getUserDataByKey("coins"))
    self.winNum:setString(0)
end

function WitchFreeSpinView:setViews(root)
    local bgNode = root:getChildByName("bg")

    self.stopBtn = bgNode:getChildByName("stop")
    self.spinBtn = bgNode:getChildByName("spin")

    local function onClick(event)
        if event.name == "ended" then
            if self.spinForbidden then
                return
            end
            if event.target == self.spinBtn then
                bole:postEvent("clickSpin")
            elseif event.target == self.stopBtn then
                bole:postEvent("clickStop")
            end
        end
    end

    self.stopBtn:onTouch(onClick)
    self.spinBtn:onTouch(onClick)

    self.balanceNum = bgNode:getChildByName("balanceNum")
    self.byNum = bgNode:getChildByName("byNum")
    self.winNum = bgNode:getChildByName("winNum")
    self.totalWinNum = bgNode:getChildByName("totalWinNum")
end

function WitchFreeSpinView:onSpin(event)
    WitchFreeSpinView.super.onSpin(self, event)
    self.winNum:setString(0)
end

function WitchFreeSpinView:onCoinChanged(event)
    self.balanceNum:setString(event.result.result)
end

function WitchFreeSpinView:onFreeSpinTotalWin(event)
    self.totalWinNum:setString(event.result)
end

function WitchFreeSpinView:onWinThisSpin(event)
    self.winNum:setString(event.result)
end

function WitchFreeSpinView:onStopSpin(event)
    self.spinForbidden = true
end

return WitchFreeSpinView
--endregion
