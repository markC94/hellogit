--region *.lua
--Date
--此文件由[BabeLua]插件自动生成
local BaseActDialog = class("BaseActDialog", cc.Layer)
function BaseActDialog:ctor(csbFile)
    local bgLayer = cc.LayerColor:create(cc.c4b(0, 0, 0, 100))   --设置半透明
    self:addChild(bgLayer)

    self:onTouch(function() return true end, false, true)  --点击不可穿透

    local rootNode = cc.CSLoader:createNode(csbFile)
    self:addChild(rootNode)
    local winSize = cc.Director:getInstance():getWinSize()
    --self:setPosition(0,0)
    rootNode:setAnchorPoint(0.5,0.5)
    rootNode:setPosition(winSize.width / 2, winSize.height / 2)
    self.rootNode = rootNode
    self:setSureAndClose()
    self:enableNodeEvents()
    return rootNode
end

function BaseActDialog:init()
    self:registerScriptHandler( function(tag)
        if "enter" == tag then
            self:onEnter()
        elseif "exit" == tag then
            self:onExit()
        end
    end )
end

--Node监听返回键需要实现
function BaseActDialog:onEnter()
    --添加返回键监听
    bole:getBoleEventKey():addKeyBack(self)
end

function BaseActDialog:onExit()
    --移除返回键监听
    bole:getBoleEventKey():removeKeyBack(self)
end
-- 返回键监听 吞噬不向下传递
function BaseActDialog:onKeyBack()
   self:closeUI()
end
--
function BaseActDialog:closeUI()
    bole:autoOpacityC(self)
    local sp=cc.FadeOut:create(0.2)
    local act = cc.RemoveSelf:create()
    self:runAction(cc.Sequence:create(sp, act))
end


function BaseActDialog:setUpdate()
    if self.isOpenUpdate then return end
    self.isOpenUpdate = true
    local function update(dt)
        if self.updateEnabled then
            self:update(dt)
        end

        if not self.waitEvents then return end

        for name, event in pairs(self.waitEvents) do
            if not event.isDone then
                event.elapsed = event.elapsed + dt
                if event.duration <= event.elapsed then
                    if event.isLoop then
                        event.elapsed = event.elapsed - event.duration
                    else
                        event.isDone = true
                    end
                    event.func()
                end
            end
        end

        local isEmpty = true
        for name, event in pairs(self.waitEvents) do
            if event.isDone then
                self.waitEvents[name] = nil
            else
                isEmpty = false
            end
        end

        if isEmpty then
            self.waitEvents = nil
        end
    end
    self:onUpdate(update)
end

function BaseActDialog:removeWaitEventByName(name)
    if self.waitEvents then
        self.waitEvents[name] = nil
    end
end

function BaseActDialog:addWaitEvent(name, duration, func)
    self:setUpdate()
    local event = {duration = duration, func = func, elapsed = 0}
    if not self.waitEvents then self.waitEvents = {} end
    self.waitEvents[name] = event
end

function BaseActDialog:onCleanup()
    bole:postEvent("ActDialogClosed")
end

function BaseActDialog:update(dt)
end

function BaseActDialog:setUpdateEnabled(isEnabled)
    self.updateEnabled = isEnabled
    if isEnabled then
        self:setUpdate()
    end
end

function BaseActDialog:run()
    bole:postEvent("ActDialogPopUp")
    local scene = cc.Director:getInstance():getRunningScene()
    scene:addChild(self, bole.ZORDER_ACT)
end

function BaseActDialog:close()
    self:closeUI()
end

function BaseActDialog:setSureAndClose(sureName, closeName)
    local sureBtn = bole:getNodeByName(self.rootNode, sureName or "sure")
    local closeBtn = bole:getNodeByName(self.rootNode, closeName or "close")
    
    local function onClick(event)
        if event.name == "ended" then
            local target = event.target
            if target == sureBtn then
                self:onSure()
            elseif target == closeBtn then
                self:onClose()
            end
        end
    end

    if sureBtn then
        sureBtn:onTouch(onClick)
    end
    if closeBtn then
        closeBtn:onTouch(onClick)
    end
end

function BaseActDialog:onSure()
    
end

function BaseActDialog:onClose()
    self:closeUI()
end

return BaseActDialog
--endregion
