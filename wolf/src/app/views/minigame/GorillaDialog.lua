-- region *.lua
-- Date
-- 此文件由[BabeLua]插件自动生成
local GorillaDialog = class("GorillaDialog", cc.Node)
function GorillaDialog:ctor()
    print("GorillaDialog:ctor")
    self:init()
    self.fsdlg = cc.CSLoader:createNode("theme40005/fsDlg/fsdlg.csb")
    self.fsdlgAct = cc.CSLoader:createTimeline("theme40005/fsDlg/fsdlg.csb")
    self.fsdlg:runAction(self.fsdlgAct)
    local root = self.fsdlg:getChildByName("root")
    self.node_start = root:getChildByName("node_start")
    self.node_collect = root:getChildByName("node_collect")
    self.node_more = root:getChildByName("node_more")
    self.node_start:setVisible(false)
    self.node_collect:setVisible(false)
    self.node_more:setVisible(false)
    self:addChild(self.fsdlg)
end
function GorillaDialog:init()
    self:registerScriptHandler( function(tag)
        if "enter" == tag then
            self:onEnter()
        elseif "exit" == tag then
            self:onExit()
        end
    end )
end
function GorillaDialog:updateUI(data)
    dump(data,"GorillaDialog:updateUI")
    data = data.result
    if not data.msg then return end
    self.chose=data.chose
    if data.msg == "start" then
       self:initStart(self.chose[1])
       bole:getAudioManage():playEff("fs",true)
    elseif data.msg == "more" then
       self:initMore(self.chose[1])
    end
end
function GorillaDialog:onEnter()
    bole:addListener("GorillaDialog", self.updateUI, self, nil, true)

end
function GorillaDialog:onExit()
    bole:getEventCenter():removeEventWithTarget("GorillaDialog", self)
end


function GorillaDialog:initStart(num)
    self.node_start:setVisible(true)
    self.fsdlgAct:gotoFrameAndPlay(0, 110, false)
    local btn_start = self.node_start:getChildByName("btn_start")
    btn_start:addTouchEventListener(handler(self, self.touchEvent))
    local txt_freespin = self.node_start:getChildByName("txt_freespin")
    txt_freespin:setString(num)
end

function GorillaDialog:initMore(num)
    self.node_more:setVisible(true)
    self.fsdlgAct:gotoFrameAndPlay(0, 110, false)
    local txt_freespin = self.start:getChildByName("txt_freespin")
    txt_freespin:setString(num)
end
function GorillaDialog:touchEvent(sender, eventType)
    local name = sender:getName()
    local tag = sender:getTag()
    print("touchEvent:" .. name)
    if eventType == ccui.TouchEventType.began then
        print("Touch Down")
    elseif eventType == ccui.TouchEventType.moved then
        print("Touch Move")
    elseif eventType == ccui.TouchEventType.ended then
        print("Touch Up")
       if (name == "btn_start") then
            dump(self.chose,"self.chose")
            bole:postEvent("next_data", { freeSpin = self.chose[1]})
            bole:postEvent("next_miniGame")
            bole:getAudioManage():stopAudio("fs")
            self:removeFromParent()
       end
    elseif eventType == ccui.TouchEventType.canceled then
        print("Touch Cancelled")
    end
end

return GorillaDialog
-- endregion
