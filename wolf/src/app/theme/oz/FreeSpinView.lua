--region *.lua
--Date
--此文件由[BabeLua]插件自动生成
local FreeSpinView = class("FreeSpinView")
function FreeSpinView:ctor(theme, order, csbPath)
    if csbPath then
        local root = cc.CSLoader:createNode(csbPath)
        root:registerScriptHandler(function(state)
            if state == "enter" then
                self:onEnter()
            elseif state == "exit" then
                self:onExit()
            end
        end)
        self.rootNode = root
        theme:addChild(root, order, order)
        self.theme = theme
        self:setViews(root)
        self:initData()
    end
end

function FreeSpinView:onEnter()
    self.isDead = false
    bole:addListener("spin", self.onSpin, self, nil, true)
    bole:addListener("stop", self.onStop, self, nil, true)
    bole:addListener("spinStatus", self.onSpinStatus, self, nil, true)
end

function FreeSpinView:onExit()
    bole:getEventCenter():removeEventWithTarget("spin", self)
    bole:getEventCenter():removeEventWithTarget("stop", self)
    bole:getEventCenter():removeEventWithTarget("spinStatus", self)
    self.isDead = true
end

function FreeSpinView:onSpin(event)
    self:onSpinStatus("stopDisabled")
end

function FreeSpinView:onStop(event)
    self:onSpinStatus("stopDisabled")
end

function FreeSpinView:onSpinStatus(event)
    local status
    if type(event) == "table" then
        status = event.result
    else
        status = event
    end

    self.stopBtn:setVisible(false)
    self.spinBtn:setVisible(false)

    if status == "stopEnabled" then
        self.stopBtn:setVisible(true)
        self.stopBtn:setEnabled(true)
    elseif status == "spinEnabled" then
        self.spinBtn:setVisible(true)
        self.spinBtn:setEnabled(true)
    elseif status == "spinDisabled" then
        self.spinBtn:setVisible(true)
        self.spinBtn:setEnabled(false)
    elseif status == "stopDisabled" then
        self.stopBtn:setVisible(true)
        self.stopBtn:setEnabled(false)
    end
end

function FreeSpinView:setViews(root)
    self.stopBtn = root:getChildByName("stop")
    self.spinBtn = root:getChildByName("spin")

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
end

function FreeSpinView:initData()
end

function FreeSpinView:removeFromParent(isCleanup)
    self.rootNode:removeFromParent(isCleanup)
end

return FreeSpinView

--endregion
