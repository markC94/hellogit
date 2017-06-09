-- region *.lua
-- Date
-- 此文件由[BabeLua]插件自动生成
local SeaDialog = class("SeaDialog", cc.Node)
function SeaDialog:ctor()
    print("SeaDialog:ctor")
    self:init()
    self.fsdlg = cc.CSLoader:createNode("theme40015/fsDlg/MainScene.csb")
    self.fsdlgAct = cc.CSLoader:createTimeline("theme40015/fsDlg/MainScene.csb")
    self.fsdlg:runAction(self.fsdlgAct)
    self.start = self.fsdlg:getChildByName("start")
    self.root_end = self.fsdlg:getChildByName("root_end")
    self.start:setVisible(false)
    self.root_end:setVisible(false)
    self:addChild(self.fsdlg)
end
function SeaDialog:init()
    self:registerScriptHandler( function(tag)
        if "enter" == tag then
            self:onEnter()
        elseif "exit" == tag then
            self:onExit()
        end
    end )
end
function SeaDialog:updateUI(data)
    dump(data,"SeaDialog:updateUI")
    data = data.result
    if not data.msg then return end
    self.chose=data.chose
    if data.msg == "start" then
       self:initStart(self.chose[1])
    elseif data.msg == "over" then
       self:initOver(self.chose)
    end
end
function SeaDialog:onEnter()
    bole:addListener("SeaDialog", self.updateUI, self, nil, true)

end
function SeaDialog:onExit()
    bole:getEventCenter():removeEventWithTarget("SeaDialog", self)
end


function SeaDialog:initStart(num)
    self.start:setVisible(true)
    self.fsdlgAct:gotoFrameAndPlay(0, 200, false)
    local btn_start = self.start:getChildByName("btn_start")
    btn_start:addTouchEventListener(handler(self, self.touchEvent))
    local txt_freespin = self.start:getChildByName("txt_freespin")
    txt_freespin:setString(num)
end

function SeaDialog:initOver(chose)
    self.root_end:setVisible(true)
    self.fsdlgAct:gotoFrameAndPlay(0, 200, false)
    local btn_back = self.start:getChildByName("btn_back")
    btn_back:addTouchEventListener(handler(self, self.touchEvent))
    local txt_freespin = self.start:getChildByName("txt_freespin")
    txt_freespin:setString(chose[1])
    local txt_win = self.start:getChildByName("txt_win")
    txt_win:setString(chose[2])
end
function SeaDialog:touchEvent(sender, eventType)
    local name = sender:getName()
    local tag = sender:getTag()
    print("touchEvent:" .. name)
    if eventType == ccui.TouchEventType.began then
        print("Touch Down")
    elseif eventType == ccui.TouchEventType.moved then
        print("Touch Move")
    elseif eventType == ccui.TouchEventType.ended then
        print("Touch Up")
        if (name == "btn_back") then
            bole:postEvent("free_spin_stop")
            self:removeFromParent()
         elseif (name == "btn_start") then
            dump(self.chose,"self.chose")
            bole:postEvent("next_data", { freeSpin = self.chose[1]})
            bole:postEvent("next_miniGame")
            self:removeFromParent()
        end
    elseif eventType == ccui.TouchEventType.canceled then
        print("Touch Cancelled")
    end
end

return SeaDialog
-- endregion
