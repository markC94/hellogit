-- region *.lua
-- Date
-- 此文件由[BabeLua]插件自动生成
local FreeSpinDialog = class("FreeSpinDialog", cc.Node)
function FreeSpinDialog:ctor(name,feature_id)
    self.feature_id=feature_id
    self.name_=name
    self:init()
    local windowSize = cc.Director:getInstance():getWinSize()
    self.mask= bole:getUIManage():getNewMaskUI("PayTable")
    self.mask:setPosition(cc.p(windowSize.width / 2, windowSize.height / 2))
    self:addChild(self.mask)

    local path= bole:getSpinApp():getMiniRes(nil,"free_spin/FSLayer.csb")
    self.csbNode = cc.CSLoader:createNodeWithVisibleSize(path)
    self.csbAct = cc.CSLoader:createTimeline(path)
    self.csbNode:runAction(self.csbAct)

    self.root = self.csbNode:getChildByName("root")
    self.node_start = self.root:getChildByName("node_start")
    self.node_collect = self.root:getChildByName("node_collect")
    self.node_start:setVisible(false)
    self.node_collect:setVisible(false)
    self:addChild(self.csbNode)
end
function FreeSpinDialog:init()
    self:registerScriptHandler( function(tag)
        if "enter" == tag then
            self:onEnter()
        elseif "exit" == tag then
            self:onExit()
        end
    end )
end
function FreeSpinDialog:updateUI(data)
    dump(data,"FreeSpinDialog:updateUI")
    data = data.result
    if not data.msg then return end
    self.chose=data.chose
    if data.msg == "start" then
       self:initStart(self.chose[1])
       if data.autoSpinning then
            performWithDelay(self, function()
                self:toStart()
            end , 6)
        end
    elseif data.msg == "more" then
       self:initStart(self.chose[1],true)
       performWithDelay(self, function()
           self:toStart()
       end , 2)
    elseif data.msg == "over" then
       self:initOver(self.chose)
       if data.autoSpinning then
            performWithDelay(self, function()
                self:toOver()
            end , 6)
        end
    end
end

function FreeSpinDialog:onEnter()
    bole:getBoleEventKey():addKeyBack(self)
    bole:addListener(self.name_, self.updateUI, self, nil, true)
end

function FreeSpinDialog:onExit()
    bole:getBoleEventKey():removeKeyBack(self)
    bole:getEventCenter():removeEventWithTarget(self.name_, self)
end

function FreeSpinDialog:onKeyBack()
   
end

function FreeSpinDialog:toStart()
    if self.isClick then
        return
    end
    self.isClick = true
    dump(self.chose, "self.chose")
    bole:postEvent("next_data", { freeSpin = self.chose[1] })
    bole:postEvent("next_miniGame")
    self:remove()
end

function FreeSpinDialog:toOver()
    if self.isClick then
        return
    end
    self.isClick = true
    bole:postEvent("free_spin_stop")
   self:remove()
end

function FreeSpinDialog:remove()
    self.csbAct:play("end", false)
    performWithDelay(self,function()
        self:removeFromParent()
    end,0.5)
end

function FreeSpinDialog:initStart(num,isMore)
    self.node_start:setVisible(true)
    self.csbAct:play("start", false)
    local btn_start = self.node_start:getChildByName("btn_start")
    btn_start:addTouchEventListener(handler(self, self.touchEvent))
    local label_count = self.node_start:getChildByName("label_count")
    label_count:setString(num)
    bole:getAudioManage():clearSpin()
    bole:getAudioManage():playFeatureForKey(self.feature_id,"feature_resource")
    if isMore then
        btn_start:setVisible(false)
    end
end

function FreeSpinDialog:initOver(chose)
    self.node_collect:setVisible(true)
    self.csbAct:play("start", false)
    local btn_collect = self.node_collect:getChildByName("btn_collect")
    btn_collect:addTouchEventListener(handler(self, self.touchEvent))
    local label_count = self.node_collect:getChildByName("label_count")
    if label_count then
        label_count:setString(chose[1])
    end
    local label_coins = self.node_collect:getChildByName("label_coins")
    if label_coins then
        label_coins:setString("$"..bole:formatCoins(chose[2],9))
    end
    bole:getAudioManage():playFeatureForKey(self.feature_id, "feature_end")
end

function FreeSpinDialog:touchEvent(sender, eventType)
    local name = sender:getName()
    local tag = sender:getTag()
    print("touchEvent:" .. name)
    if eventType == ccui.TouchEventType.began then
        print("Touch Down")
    elseif eventType == ccui.TouchEventType.moved then
        print("Touch Move")
    elseif eventType == ccui.TouchEventType.ended then
        print("Touch Up")
        if (name == "btn_collect") then
            bole:getAudioManage():stopFeatureForKey(self.feature_id, "feature_end")
            bole:getAudioManage():playFeatureForKey(self.feature_id,"feature_collect")
            self:toOver()
         elseif (name == "btn_start") then
            bole:getAudioManage():stopFeatureForKey(self.feature_id,"feature_resource")
            bole:getAudioManage():playFeatureForKey(self.feature_id,"feature_start")
            self:toStart()
        end
    elseif eventType == ccui.TouchEventType.canceled then
        print("Touch Cancelled")
    end
end

return FreeSpinDialog
-- endregion
