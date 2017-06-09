-- region *.lua
-- Date
-- 此文件由[BabeLua]插件自动生成
local DailyGift = class("DailyGift", cc.Node)
function DailyGift:ctor()
    self.index = -1 
    self.oldRatateIndex=0
    self.p_type=0
    self:initOpen()
    self:initGame()
    self.isSkipEnable=true
    local function update(dt)
        self:updateTime(dt)
    end
    self:onUpdate(update)
        self:registerScriptHandler( function(tag)
        if "enter" == tag then
            self:onEnter()
        elseif "exit" == tag then
            self:onExit()
        end
    end )
end
function DailyGift:initOpen()
    self.openNode = cc.CSLoader:createNode("dailybonusloading/dailybonusloading.csb")
    self.openAct = cc.CSLoader:createTimeline("dailybonusloading/dailybonusloading.csb")
    self:addChild(self.openNode,1)
    self.openNode:runAction(self.openAct)
    self.openAct:play("start",false)
    performWithDelay(self,function()
        self.openNode:removeFromParent()
    end,2.5)
end
function DailyGift:initGame()
    self.csbNode = cc.CSLoader:createNodeWithVisibleSize("dailybonus/dailybonus.csb")
    self.csbAct = cc.CSLoader:createTimeline("dailybonus/dailybonus.csb")
    self:addChild(self.csbNode)
    self.csbNode:runAction(self.csbAct)
    self.csbAct:play("idle",true)

    self:initRoot()
    self:initPop()

    local dailybonus= self.csbNode:getChildByName("dailybonus")
    local bg= dailybonus:getChildByName("bg")
    local VIP_status= bg:getChildByName("VIP_status")
    local Image_role= bg:getChildByName("Image_role")
    self.spinit= bg:getChildByName("spinit")
    local f_zhuanpan= bg:getChildByName("zhuanpan")
    
    self.zhengzhao = f_zhuanpan:getChildByName("zhengzhao")
    self.zhengzhao:setVisible(false)
    self.zhuanpan = f_zhuanpan:getChildByName("zhuanpan")

    for i=1,20 do
        local num=self.zhuanpan:getChildByName("num_"..(i-1))
        num:setString((i*15).."K")
    end


    local anniu = f_zhuanpan:getChildByName("anniu")
    self.small_lights={}
    for i=1,12 do
        local light=anniu:getChildByName("light_"..i)
        self.small_lights[i]=light
    end

    self.lights={}
    for i=1,12 do
        local light_z=f_zhuanpan:getChildByName("light_z_"..i)
        self.lights[i]=light_z
    end
    self.baizhen=f_zhuanpan:getChildByName("baizhen")
    self.touch = f_zhuanpan:getChildByName("touch")
    self.touch:setTouchEnabled(true)
    self.touch:addTouchEventListener(handler(self,self.touchEvent))
    self:initVip(VIP_status)

    --btn_skip
    local btn_skip = bg:getChildByName("btn_skip")
    btn_skip:addTouchEventListener(handler(self,self.touchEvent))
end

function DailyGift:initVip(VIP_status)
    local vipInfos=bole:getConfigCenter():getConfig("vip")
    local vip_level=bole:getUserDataByKey("vip_level")
    for i=0,6 do
        local icon_VIP=VIP_status:getChildByName("icon_VIP_"..(i+1))
        local VIP=VIP_status:getChildByName("VIP_"..(i+1))
        local txt1=VIP:getChildByName("BitmapFontLabel_1")
        local VIP_activate=VIP:getChildByName("VIP_activate")
        local txt2=VIP_activate:getChildByName("BitmapFontLabel_1")
        txt1:setString(vipInfos[""..i].login_multiplier)
        txt2:setString(vipInfos[""..i].login_multiplier)
        if vip_level==i then
            icon_VIP:setVisible(true)
            VIP_activate:setVisible(true)
        else
            icon_VIP:setVisible(false)
            VIP_activate:setVisible(false)
        end
    end
end

function DailyGift:initRoot()
    self.pop=self.csbNode:getChildByName("pop")
    self.pop:setVisible(false)
    local btn_collect = self.pop:getChildByName("btn_collect")
    btn_collect:addTouchEventListener(handler(self,self.touchEvent))
end

function DailyGift:initPop()
    self.root=self.csbNode:getChildByName("root")
    self.root:setVisible(false)
end

function DailyGift:onEnter()
    bole:addListener("DailyGift", self.updateUI, self, nil, true)
end
function DailyGift:onExit()
    bole:getEventCenter():removeEventWithTarget("DailyGift", self)
end

function DailyGift:updateUI(event)
    local data = event.result
    if not data then
        return
    end
    self:isSpin(data)
end

function DailyGift:collect()
    self:removeFromParent()
end

function DailyGift:isSpin(data)
    --这里是接收服务器消息
    if not data.chose then
        return
    end
    self.csbAct:gotoFrameAndPause(0)
    local move=cc.MoveBy:create(0.5,cc.p(160,80))
    local fade=cc.FadeOut:create(0.5)
    local sp=cc.Spawn:create(move,fade)
    self.spinit:runAction(sp)
    if data.chose == 0 then
        self.index = 10
    else
        self.index = data.chose
    end
    self.touch:setTouchEnabled(false)
    self:rotaAction()
end

function DailyGift:spin()
    self.touch:setTouchEnabled(false)
    --这里是发送服务器消息
    self:isSpin({chose=6})
end

function DailyGift:rotaAction()
    bole:getAudioManage():playEff("jones_wheel2")
    self.zhuanpan:setRotation(0)
    local sp1 = cc.EaseExponentialOut:create(cc.RotateBy:create(6.0,self.index * 18 + 360*6))
    self.zhuanpan:runAction(sp1)
    performWithDelay(self, function()
        self:gotoView()
    end , 6.0)
end
function DailyGift:updateTime(dt)
    if not self.zhuanpan then
        return
    end
    local rotate = self.zhuanpan:getRotation()
    local ratateIndex = math.floor((rotate - 9) / 18)
    if ratateIndex > self.oldRatateIndex then
        self.oldRatateIndex = ratateIndex
        self:toTrigger()
    end
    local rote = self.baizhen:getRotation()
    if self.p_type == 1 then
        if rote > -40 then
            rote = rote - 8
        else
            self.p_type = 2
            rote = -40
        end
        self.baizhen:setRotation(rote)
        return
    end
    if self.p_type >= 2 then
        if rote < 0 then
            rote = rote + 15
            if rote >- 35 then
                self.p_type = 3
            end
            if rote > 0 then
                rote = 0
                self.p_type = 0
            end
            self.baizhen:setRotation(rote)
        end
    end
end
function DailyGift:toTrigger()
    if not self.baizhen then
        return
    end 
    if self.p_type==3 or self.p_type==0 then
        self.p_type=1
    end
end
function DailyGift:gotoView()
    self.zhengzhao:setVisible(true)
    self.csbAct:play("stop",true)
    for i=1,12 do
        self.lights[i]:runAction(cc.Blink:create(2.5,5))
        self.small_lights[i]:runAction(cc.Blink:create(3,5))
    end
    performWithDelay(self, function()
        self.csbAct:play("over",false)
    end , 2.0)
    performWithDelay(self,function()
        self.root:setVisible(true)
        self.csbAct:play("show",false)
    end,2.5)
    performWithDelay(self,function()
        self:showRoot()
    end,3)
    performWithDelay(self,function()
        self:showPop()
    end,6.5)
    
end

function DailyGift:showRoot()
    
end

function DailyGift:showPop()
    if self.isSkipEnable then
        self.isSkipEnable = false
        self.pop:setVisible(true)
        self.csbAct:play("pop", true)
        performWithDelay(self, function()
            self.csbAct:play("popIdle", true)
        end , 1.3)
    end
end

function DailyGift:touchEvent(sender, eventType)
    local name = sender:getName()
    local tag = sender:getTag()
    print("touchEvent:" .. name)
    if eventType == ccui.TouchEventType.began then
        print("Touch Down")
    elseif eventType == ccui.TouchEventType.moved then
        print("Touch Move")
    elseif eventType == ccui.TouchEventType.ended then
        print("Touch Up")
        if name == "touch" then
            self:spin()
        end
        if name == "btn_collect" then
            self:collect()
        end
        if name == "btn_skip" then
            self:showPop()
        end
        
    elseif eventType == ccui.TouchEventType.canceled then
        print("Touch Cancelled")
    end
end

return DailyGift
-- endregion
