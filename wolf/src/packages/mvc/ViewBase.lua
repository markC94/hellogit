
local ViewBase = class("ViewBase", cc.Node)

function ViewBase:ctor(name, ...)
    self:enableNodeEvents()
    self:init()

    if type(name) == "table" then
        self.name_ = name.name
        self:createResoueceNode(name.path .. "/" .. name.name .. ".csb")
    else
        self.name_ = name
        self:createResoueceNode("csb/" .. name .. ".csb")
    end
    self:toWait(false)
    self:setTouch(true)
    self.wait_time = 0
    schedule(self, self.updateWaitTime, 0.1)
    print("--------ViewBase:ctor" .. self.name_)
    if self.onCreate then self:onCreate(...) end
    bole:addListener(self.name_, self.baseUpdateUI, self, nil, true)
    
end
function ViewBase:init()
    self:registerScriptHandler( function(tag)
        if "enter" == tag then
            self:onBaseEnter()
        elseif "exit" == tag then
            self:onBaseExit()
        end
    end )
end
function ViewBase:initView(data)

end
function ViewBase:onBaseEnter()
    -- 这里太慢
    -- bole:addListener(self.name_, self.baseUpdateUI, self, nil, true)
    if self.onEnter then self:onEnter() end
end
function ViewBase:onBaseExit()
    bole:getEventCenter():removeEventWithTarget(self.name_, self)
    if self.onExit then self:onExit() end
end

function ViewBase:updateWaitTime()
    if self.wait_time == -1 then
        return
    end
    if self.wait_time <= 0 then
        self.wait_time = -1
        self:toWait(false)
        return
    end
    self.wait_time = self.wait_time - 0.1
end

function ViewBase:baseUpdateUI(data)
    local basedata = data.result
    if type(basedata) == "table" then
        if basedata[1] == "ui_close" then
            self:closeUI()
            return
        end
    end
    if self.updateUI then self:updateUI(data) end
end

function ViewBase:updateUI(data)
end
function ViewBase:closeUI()
    bole:autoOpacityC(self)
    local ac1 = cc.FadeOut:create(0.2)
    local ac2 = cc.CallFunc:create(handler(self, self.removeSelf))
    self:getCsbNode():runAction(cc.Sequence:create(ac1, ac2))
end

function ViewBase:removeSelf()
    self:removeFromParent()
end
function ViewBase:setDialog(isEnable)
    self:clearMask()
    if isEnable then
        self:addMaskUI(true)
    end
end
function ViewBase:clearMask()
    local mask = self:getChildByName("mask")
    if mask then
        mask:removeFromParent()
        mask = nil
    end
end
function ViewBase:addMaskUI(isColor)
    local mask = self:getSimpleLayout("mask", true)
    self:addChild(mask, -1)
end

-- 网络请求
function ViewBase:toWait(isShow)
    local net_work = self:getChildByName("net_work")
    if not net_work then
        net_work = self:getSimpleLayout("net_work", true)
        self:addChild(net_work, 100)
    end
    net_work:setVisible(isShow)
    if isShow then self.wait_time = 3 end
end
-- 区分ui和网络请求
function ViewBase:setTouch(isEanble)
    local touch = self:getChildByName("touch")
    if not touch then
        touch = self:getSimpleLayout("touch", false)
        self:addChild(touch, 99)
    end
    if isEanble then
        touch:setVisible(false)
    else
        touch:setVisible(true)
    end
end


function ViewBase:getSimpleLayout(name, isColor)
    local touch_layer = ccui.Layout:create()
    touch_layer:ignoreContentAdaptWithSize(false)
    touch_layer:setClippingEnabled(false)

    if isColor then
        touch_layer:setBackGroundColorType(1)
        touch_layer:setBackGroundColor( { r = 0, g = 0, b = 0 })
    end

    touch_layer:setBackGroundColorOpacity(50)
    touch_layer:setTouchEnabled(true);
    touch_layer:setLayoutComponentEnabled(true)
    touch_layer:setName(name)
    touch_layer:setCascadeColorEnabled(true)
    touch_layer:setCascadeOpacityEnabled(true)
    touch_layer:setAnchorPoint(0.5000, 0.5000)
    touch_layer:setPosition(1000.0000, 562.0000)
    local layout = ccui.LayoutComponent:bindLayoutComponent(touch_layer)
    layout:setPositionPercentX(0.5000)
    layout:setPositionPercentY(0.5000)
    --    layout:setPercentWidthEnabled(true)
    --    layout:setPercentHeightEnabled(true)
    layout:setPercentWidth(1.0000)
    layout:setPercentHeight(1.0000)
    layout:setSize( { width = 2001.0000, height = 1125.0000 })
    return touch_layer
end

function ViewBase:getName()
    return self.name_
end

function ViewBase:getCsbNode()
    return self.resourceNode_
end

function ViewBase:createResoueceNode(resourceFilename)
    if self.resourceNode_ then
        self.resourceNode_:removeSelf()
        self.resourceNode_ = nil
    end
    -- self.resourceNode_ = cc.CSLoader:createNode(resourceFilename)
    self.resourceNode_ = cc.CSLoader:createNodeWithVisibleSize(resourceFilename)
    assert(self.resourceNode_, string.format("ViewBase:createResoueceNode() - load resouce node from file \"%s\" failed", resourceFilename))
    self:addChild(self.resourceNode_)
end

return ViewBase
