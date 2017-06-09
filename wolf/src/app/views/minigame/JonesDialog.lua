-- region *.lua
-- Date
-- 此文件由[BabeLua]插件自动生成
local JonesDialog = class("JonesDialog", cc.Node)
function JonesDialog:ctor()
    print("JonesDialog:ctor")
    self:init()
    self.fsdlg = cc.CSLoader:createNode("theme40009/fsDlg/fsdlg.csb")     
    self.fsdlgAct = cc.CSLoader:createTimeline("theme40009/fsDlg/fsdlg.csb")
    self.fsdlg:runAction(self.fsdlgAct)
    self.nodefd_start = self.fsdlg:getChildByName("node_start")
    self.nodefd_start1 = self.fsdlg:getChildByName("node_start1")
    self.nodefd_collect = self.fsdlg:getChildByName("node_collect")
    self.nodefd_collect_2 = self.fsdlg:getChildByName("node_collect_2")
    self.nodefd_morespin = self.fsdlg:getChildByName("node_morespin")
    self.nodefd_start:setVisible(false)
    self.nodefd_start1:setVisible(false)
    self.nodefd_collect:setVisible(false)
    self.nodefd_collect_2:setVisible(false)
    self.nodefd_morespin:setVisible(false)
    self:addChild(self.fsdlg)
end
function JonesDialog:init()
    self:registerScriptHandler( function(tag)
        if "enter" == tag then
            self:onEnter()
        elseif "exit" == tag then
            self:onExit()
        end
    end )
end
function JonesDialog:updateUI(data)
    dump(data,"JonesDialog:updateUI")
    data = data.result
    if not data.msg then return end
    self.chose=data.chose
    if data.msg == "more" then
       self:initMore(self.chose[1])  
    elseif data.msg == "start" then
        if self.chose[2] then
           self:initStartWild(self.chose[1])
       else
           self:initStart(self.chose[1])
       end
       bole:getAudioManage():playMusic("fs",true)
    elseif data.msg == "bounsGame" then
        bole:getAudioManage():playMusic("fs",true)
        self:initBouns(self.chose)
    end
end
function JonesDialog:onEnter()
    bole:addListener("JonesDialog", self.updateUI, self, nil, true)

end
function JonesDialog:onExit()
    bole:getEventCenter():removeEventWithTarget("JonesDialog", self)
    bole:getAudioManage():stopAudio("fs")
end

function JonesDialog:initMore(num)
    self.nodefd_morespin:setVisible(true)
    self.fsdlgAct:gotoFrameAndPlay(0, 130, false)
    local freeSpin = self.nodefd_morespin:getChildByName("freeSpin")
    local txt_spin = freeSpin:getChildByName("txt_spin")
    txt_spin:setString(num)
    performWithDelay(self, function()
        bole:postEvent("next_data", { freeSpin =self.chose[1]})
        bole:postEvent("next_miniGame")
        self:removeFromParent()
    end , 2)
end

function JonesDialog:initStart(num)
    self.nodefd_start1:setVisible(true)
    self.fsdlgAct:gotoFrameAndPlay(0, 130, false)
    local beijing_xiao = self.nodefd_start1:getChildByName("beijing_xiao")
    local btn_start = beijing_xiao:getChildByName("btn_start")
    btn_start:addTouchEventListener(handler(self, self.touchEvent))
    local BitmapFontLabel_6_Copy = beijing_xiao:getChildByName("BitmapFontLabel_6_Copy")
    BitmapFontLabel_6_Copy:setString(num)

    local Node_1=beijing_xiao:getChildByName("Node_1")
    self.skeletonOver = sp.SkeletonAnimation:create("common/congratylaions.json", "common/congratylaions.atlas")
    Node_1:addChild(self.skeletonOver, 1)
    self.skeletonOver:setBlendFunc({src = 770, dst = 1})
    
    performWithDelay(self,function ()
        self.skeletonOver:setAnimation(0, "animation", false)
    end,1)
end

function JonesDialog:initStartWild(num)
    self.nodefd_start:setVisible(true)
    self.fsdlgAct:gotoFrameAndPlay(0, 130, false)
    local beijing_xiao = self.nodefd_start:getChildByName("beijing_xiao")
    local btn_start = beijing_xiao:getChildByName("btn_start")
    btn_start:addTouchEventListener(handler(self, self.touchEvent))
    local BitmapFontLabel_6 = beijing_xiao:getChildByName("BitmapFontLabel_6")
    BitmapFontLabel_6:setString(num)
    local BitmapFontLabel_11 = beijing_xiao:getChildByName("BitmapFontLabel_11")
    BitmapFontLabel_11:setString(2)
    local Node_1=beijing_xiao:getChildByName("Node_1")
    self.skeletonOver = sp.SkeletonAnimation:create("common/congratylaions.json", "common/congratylaions.atlas")
    Node_1:addChild(self.skeletonOver, 1)
    self.skeletonOver:setBlendFunc({src = 770, dst = 1})
    
    performWithDelay(self,function ()
        self.skeletonOver:setAnimation(0, "animation", false)
    end,1)
end


function JonesDialog:initBouns(chose)
    
end
function JonesDialog:touchEvent(sender, eventType)
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
            if self.chose[2] then
                bole:postEvent("next_data", { freeSpin = self.chose[1],wild=true})
            else
                bole:postEvent("next_data", { freeSpin = self.chose[1]})
            end
            bole:postEvent("next_miniGame")
            self:removeFromParent()
        end
    elseif eventType == ccui.TouchEventType.canceled then
        print("Touch Cancelled")
    end
end

return JonesDialog
-- endregion
