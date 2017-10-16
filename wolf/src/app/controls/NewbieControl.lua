--region *.lua
--Date
--此文件由[BabeLua]插件自动生成
local NewbieControl = class("NewbieControl")
function NewbieControl:ctor()
    bole:addListener("checkNewbieStep", self.onCheckNewbieStep, self, nil, true)
    bole:addListener("newbieStepPopup", self.onPopupNewbie, self, nil, true)
end

function NewbieControl:start()
    self:onCheckNewbieStep({result = "noExp"})
    bole:initBuyCenter()
end

function NewbieControl:onCheckNewbieStep(event)
    local tag = event.result
    if tag == "noExp" then
        local exp = bole:getUserDataByKey("experience")
        if exp < 1 then
            bole:getAppManage():startGame(2)
            bole:postEvent("newbieStepForNoExp")
        end
    elseif tag == "afterSpinNum" then
        if bole:getUserDataByKey("level") < 3 then
            local userId = bole:getUserDataByKey("credential")
            local newKey = userId .. tag
            local userDefault = cc.UserDefault:getInstance()
            if not userDefault:getBoolForKey(newKey, false) then
                bole:postEvent("newbieStepForPersonalInfo")
                userDefault:setBoolForKey(newKey, true)
                userDefault:flush()
            end
        end
    elseif tag == "afterExpUpToValue" then
    elseif tag == "afterLevelUp" then
    elseif tag == "afterBetInfo" then
    elseif tag == "afterOpenTheme" then
    elseif tag == "afterBigWin" then
    elseif tag == "afterCoinLess" then
    end
end

function NewbieControl:onPopupNewbie(event)
    bole:getEntity("app.views.newbie.NewbieView", event.result):run()
end

return NewbieControl
--endregion
