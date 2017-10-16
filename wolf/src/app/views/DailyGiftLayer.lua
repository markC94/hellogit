-- region *.lua
-- Date
-- 此文件由[BabeLua]插件自动生成
local DailyGiftLayer = class("DailyGiftLayer", cc.load("mvc").ViewBase)

function DailyGiftLayer:onCreate(data)
    self.info = data
    self.spinSpeed = 6
    local rewards = bole:getConfigCenter():getConfig("login_reward")
    self.num_pan = rewards["" .. data[1]].login_reward
    local vipInfos = bole:getConfigCenter():getConfig("vip")
    local vip_level = bole:getUserDataByKey("vip_level")
    self.mulit = vipInfos["" .. vip_level].login_multiplier
    self.num_friends = data[2]
    self.num_day = data[3]
    self.num_coins = self.num_pan + self.num_friends * 1000 + self.num_day * 100000

    self.index = data[1] -1
    self.oldRatateIndex = 0
    self.p_type = 0
    self:initOpen()
    self:initGame()
    self.isSkipEnable = true
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
    bole.socket:send("sync_friends_info", { }, true)
end

function DailyGiftLayer:initOpen()
--    self:getCsbNode():setVisible(false)
    self.openNode = cc.CSLoader:createNodeWithVisibleSize("dailybonusloading/dailybonusloading.csb")
    self.openAct = cc.CSLoader:createTimeline("dailybonusloading/dailybonusloading.csb")
    self:addChild(self.openNode, 1)
    self.openNode:runAction(self.openAct)
    self.openAct:play("start", false)
    performWithDelay(self, function()
        self.openNode:removeFromParent()
    end , 2.5)
end

function DailyGiftLayer:initGame()
--    self:getCsbNode():setVisible(true)
    self.csbAct = cc.CSLoader:createTimeline("daily_gift/DailyGiftLayer.csb")
    self:getCsbNode():runAction(self.csbAct)
    self.csbAct:play("idle", true)

    local root = self:getCsbNode():getChildByName("root")
    local node_vip = root:getChildByName("node_vip")
    local node_pan = root:getChildByName("node_pan")
    local node_hero = root:getChildByName("node_hero")
    self.node_reward = root:getChildByName("node_reward")
    self.node_start = self.node_reward:getChildByName("node_start")
    self.node_keep = self.node_reward:getChildByName("node_keep")
    self.mask = self.node_reward:getChildByName("mask")
    self.mask:setVisible(false)
    bole:autoOpacityC(self.node_start)
    self.node_start:setVisible(false)
    self.node_start:setOpacity(0)

    self.spinit = node_pan:getChildByName("sp_tips")

    self.sp_mask = node_pan:getChildByName("sp_mask")
    self.sp_mask:setVisible(false)
    self.sp_pan = node_pan:getChildByName("sp_pan")
    self.sp_pan2 = node_pan:getChildByName("sp_pan2")
    self.sp_panf = node_pan:getChildByName("sp_panf")

    local rewards = bole:getConfigCenter():getConfig("login_reward")
    for i = 1, 20 do
        local num = self.sp_pan:getChildByName("num_" ..(i - 1))
        num:setString(bole:formatCoins(rewards["" .. i].login_reward, 4))
    end

    self.lights = { }
    for i = 1, 20 do
        local light = self.sp_panf:getChildByName("sp_light" .. i)
        self.lights[i] = light
    end

    self.baizhen = node_pan:getChildByName("sp_select")
    self.btn_spin = node_pan:getChildByName("btn_spin")
    self.btn_spin:setTouchEnabled(true)
    self.btn_spin:addTouchEventListener(handler(self, self.touchEvent))

    -- btn_skip
    self.btn_skip = self.node_reward:getChildByName("btn_skip")
    self.btn_skip:addTouchEventListener(handler(self, self.touchEvent))

    self:initReward()
    self:initPop()
    self:initVip(node_vip)
end

function DailyGiftLayer:initReward()
    self.node_reward:setVisible(false)
    self.node_bottom = self.node_reward:getChildByName("node_bottom")
    self.btm_friends = self.node_bottom:getChildByName("sp_friends")
    self.btm_day = self.node_bottom:getChildByName("sp_day")
    self.btm_coins = self.node_bottom:getChildByName("node_coins")

    self.btm_fnum = self.btm_friends:getChildByName("txt_num")
    self.btm_dnum = self.btm_day:getChildByName("txt_day")
    self.btm_dnum_old = self.btm_day:getChildByName("txt_day_old")
    
    self.btm_fnum:setString(self.num_friends.."Friends")
    self.btm_dnum:setString(0)
    self.btm_dnum_old:setString(0)
    self.btm_dnum:setVisible(false)
    self.btm_dnum_old:setVisible(false)

    self.btm_coin1= self.btm_coins:getChildByName("txt_coins1")
    self.btm_coin2= self.btm_coins:getChildByName("txt_coins2")
    self.btm_coin3= self.btm_coins:getChildByName("txt_coins3")

    self.btm_coin1:setString(self.num_pan)
    self.btm_coin2:setString(self.num_friends * 1000)
    self.btm_coin3:setString(self.num_day * 100000)


    self.btm_act={}
    self.btm_act[1]= self.btm_coins:getChildByName("sp_icon1")
    self.btm_act[2]= self.btm_coins:getChildByName("txt_coins1")

    self.btm_act[3]= self.btm_coins:getChildByName("sp_add1")
    self.btm_act[4]= self.btm_coins:getChildByName("sp_icon2")
    self.btm_act[5]= self.btm_coins:getChildByName("txt_coins2")

    self.btm_act[6]= self.btm_coins:getChildByName("sp_add2")
    self.btm_act[7]= self.btm_coins:getChildByName("sp_icon3")
    self.btm_act[8]= self.btm_coins:getChildByName("txt_coins3")

    for i=1,8 do
        self.btm_act[i]:setVisible(false)
        self.btm_act[i]:setOpacity(0)
    end
end

function DailyGiftLayer:showRoot()
    if not self.isSkipEnable then return end
    
    self.node_start:setVisible(true)
    self.node_start:setOpacity(0)
    self.node_start:runAction(cc.Sequence:create(cc.FadeIn:create(0.5),cc.DelayTime:create(0.5), cc.FadeOut:create(0.5)))
    performWithDelay(self.node_keep, function()
        self.node_start:setVisible(false)
        self:changeFriends()
    end , 1.5)
    
    self.btm_act[1]:setVisible(true)
    self.btm_act[2]:setVisible(true)
    self.btm_act[3]:setVisible(true)
    self.btm_act[1]:setOpacity(0)
    self.btm_act[2]:setOpacity(0)
    self.btm_act[3]:setOpacity(0)
    
    local sp1 = cc.Spawn:create(cc.FadeIn:create(0.5), cc.ScaleTo:create(0.5, 1.1))
    local sp2 = cc.Spawn:create(cc.FadeIn:create(0.5), cc.ScaleTo:create(0.5, 0.85))
    local sp3 = cc.Sequence:create(cc.DelayTime:create(1.0), cc.FadeIn:create(0.5))
    self.btm_act[1]:runAction(cc.Sequence:create(sp1, cc.ScaleTo:create(0.2, 1.0)))
    self.btm_act[2]:runAction(cc.Sequence:create(sp2, cc.ScaleTo:create(0.2, 0.8)))
    self.btm_act[3]:runAction(sp3)
end

function DailyGiftLayer:changeFriends()       
    if self.info[2] == 0 then
        self:showFriends()
        return
    end
    performWithDelay(self.node_keep, function()
        self:showFriends()
    end , 1.5)
    local node = cc.Node:create()
    self.node_keep:addChild(node, bole.ZORDER_TOP)
    local count= math.min(self.info[2],#self.friends)
    for i = 1, count do
        performWithDelay(self.node_keep, function()
            local test = bole:getNewHeadView( self.friends[i])
            test:updatePos(test.POS_SCALE_FRIEND)
            node:addChild(test, count - i)
            self:rotaFlyNode(test, cc.p(1100 - i * 3, 450 + i * 3), cc.p(669, 250), 1, 70, 0, count * 0.06 - i * 0.04)
        end , i * 0.02)
    end

--    test
--    performWithDelay(self.node_keep, function()
--        self:showFriends()
--    end , 1.5)
--    local node = cc.Node:create()
--    self.node_keep:addChild(node, bole.ZORDER_TOP)
--    local count=10
--    for i = 1, count do
--        performWithDelay(self.node_keep, function()
--            local test = bole:getNewHeadView(bole:getUserData())
--            test:updatePos(test.POS_SCALE_FRIEND)
--            node:addChild(test, count - i)
--            self:rotaFlyNode(test, cc.p(1100 - i * 3, 450 + i * 3), cc.p(669, 250), 1, 70, 0, count * 0.06 - i * 0.04)
--        end , i * 0.02)
--    end

end

-- 旋转飞行
function DailyGiftLayer:rotaFlyNode(node, beginPos, endPos, time, angle, offh, delytime)
    if not node then return end
    if not time then time = 1 end
    if not angle then angle = 60 end
    if not offh then offh = 0 end
    if not delytime then delytime = 0.1 end
    local radian = angle * 3.14159 / 180.0
    local x1 = beginPos.x +(endPos.x - beginPos.x) / 4.0
    local pos1 = cc.p(x1, offh + beginPos.y + math.cos(radian) * x1)

    local x2 = beginPos.x +(endPos.x - beginPos.x) / 2.0 - 600
    local pos2 = cc.p(x2, offh + beginPos.y + math.cos(radian) * x2)
    local bezier = {
        pos1,
        pos2,
        endPos
    }
    -- dump(bezier, "bezier")
    node:setPosition(beginPos)

    local br = cc.BezierTo:create(time, bezier)
    local sp = cc.Spawn:create(br, cc.RotateBy:create(time, 60))
    local dely = cc.DelayTime:create(delytime)
    node:runAction(cc.Sequence:create(dely, sp, cc.Hide:create()))
end

function DailyGiftLayer:showFriends()
    if not self.isSkipEnable then return end
    performWithDelay(self.node_keep, function()
        self:changeDays()
    end , 0.2)
    self.btm_act[4]:setVisible(true)
    self.btm_act[5]:setVisible(true)
    self.btm_act[6]:setVisible(true)
    self.btm_act[4]:setOpacity(0)
    self.btm_act[5]:setOpacity(0)
    self.btm_act[6]:setOpacity(0)
    
    local sp1 = cc.Spawn:create(cc.FadeIn:create(0.5), cc.ScaleTo:create(0.5, 1.1))
    local sp2 = cc.Spawn:create(cc.FadeIn:create(0.5), cc.ScaleTo:create(0.5, 0.85))
    local sp3 = cc.Sequence:create(cc.DelayTime:create(1.0), cc.FadeIn:create(0.5))
    self.btm_act[4]:runAction(cc.Sequence:create(sp1, cc.ScaleTo:create(0.2, 1.0)))
    self.btm_act[5]:runAction(cc.Sequence:create(sp2, cc.ScaleTo:create(0.2, 0.8)))
    self.btm_act[6]:runAction(sp3)
end
function DailyGiftLayer:changeDays()
    if not self.isSkipEnable then return end
    -- 1134 225 667 480
    local moveTime = 0.5
    local sp1 = cc.Spawn:create(cc.ScaleTo:create(moveTime, 1), cc.MoveTo:create(moveTime, cc.p(669, 459)))
    performWithDelay(self.node_keep, function()
        self.btm_dnum:setVisible(true)
    end , moveTime)
    self.btm_day:runAction(sp1)
    local time = 0
    performWithDelay(self.node_keep, function()
        local acts = { }
        local acts_old = { }
        local cellTime = 0.1
        local oldTime = 0.02
        for i = 0, self.info[3] do
            acts[#acts + 1] = cc.CallFunc:create( function()
                self.btm_dnum:setOpacity(100)
                self.btm_dnum:setString(i)
                self.btm_dnum:setScale(1.1)
            end )
            acts[#acts + 1] = cc.Spawn:create(cc.FadeIn:create(cellTime), cc.ScaleTo:create(cellTime, 1))

            acts_old[#acts_old + 1] = cc.CallFunc:create( function()
                self.btm_dnum_old:setOpacity(200)
                if i > 0 then
                    self.btm_dnum_old:setString(i - 1)
                else
                    self.btm_dnum_old:setString(0)
                end
                self.btm_dnum:setScale(1.1)
            end )
            acts_old[#acts_old + 1] = cc.Spawn:create(cc.ScaleTo:create(cellTime + oldTime, 0.8), cc.FadeOut:create(cellTime + oldTime))
            time = time + cellTime + oldTime
        end
        self.btm_dnum:runAction(cc.Sequence:create(acts))
        self.btm_dnum_old:setVisible(true)
        self.btm_dnum_old:runAction(cc.Sequence:create(acts_old))
        performWithDelay(self.node_keep, function()
            local sp2 = cc.Spawn:create(cc.ScaleTo:create(moveTime, 0.7), cc.MoveTo:create(moveTime, cc.p(1056, 252)))
            self.btm_day:runAction(sp2)
        end , time + 1)
        performWithDelay(self.node_keep, function()
            self.btm_dnum_old:setVisible(false)
            self:showDays()
        end , time + 1.3)
    end , moveTime + 0.5)
end
function DailyGiftLayer:showDays()
    if not self.isSkipEnable then return end
    performWithDelay(self, function()
        self:showPop()
    end , 1)
    self.mask:setVisible(true)
    self.btm_act[7]:setVisible(true)
    self.btm_act[8]:setVisible(true)
    self.btm_act[7]:setOpacity(0)
    self.btm_act[8]:setOpacity(0)
    
    local sp1 = cc.Spawn:create(cc.FadeIn:create(0.5), cc.ScaleTo:create(0.5, 1.1))
    local sp2 = cc.Spawn:create(cc.FadeIn:create(0.5), cc.ScaleTo:create(0.5, 0.85))

    self.btm_act[7]:runAction(cc.Sequence:create(sp1, cc.ScaleTo:create(0.2, 1.0)))
    self.btm_act[8]:runAction(cc.Sequence:create(sp2, cc.ScaleTo:create(0.2, 0.8)))

end

function DailyGiftLayer:initPop()
    self.node_over = self.node_reward:getChildByName("node_over")
    self.node_over:setVisible(false)

    self.over_coins = self.node_over:getChildByName("txt_coins")
    self.over_coins:setString(bole:formatCoins(self.num_coins * self.mulit, 4))

    local vip_level = bole:getUserDataByKey("vip_level")
    local path=bole:getBuyManage():getVipIconStr(vip_level)

    local sp_vipbg = self.node_over:getChildByName("sp_vipbg")
    local sp_vip = sp_vipbg:getChildByName("sp_vip")
    local txt_vip = sp_vipbg:getChildByName("txt_vip")
    local txt_mul = sp_vipbg:getChildByName("txt_mul")

    txt_vip:setString("VIP "..vip_level)
    txt_mul:setString("(X "..self.mulit..")")
    sp_vip:setTexture(path)

end

function DailyGiftLayer:showPop()
    if self.isSkipEnable then
        self:getCsbNode():stopAllActions()
        self.btm_dnum_old:setVisible(false)
        self.btm_dnum:setVisible(true)
        self.btm_dnum:setString(self.num_day)
        self.btm_day:setPosition(cc.p(1056, 252))
        self.btm_day:setScale(0.6)
        self.btn_skip:setVisible(false)
        self.node_start:setVisible(false)
        self.node_over:setVisible(true)
        local mul={1,0.8,1,1,0.8,1,1,0.8}
        for i=1,8 do
            self.btm_act[i]:setVisible(true)
            self.btm_act[i]:setOpacity(255)
            self.btm_act[i]:setScale(mul[i])
        end
         
        self.isSkipEnable = false
        self.node_keep:setVisible(false)
        self.node_keep:removeFromParent()
        performWithDelay(self, function()
            self:collect()
        end , 3)
    end
end

function DailyGiftLayer:initVip(node_vip)
    local vipInfos = bole:getConfigCenter():getConfig("vip")

    for i = 0, 6 do
        local sp_vipbg = node_vip:getChildByName("sp_vipbg" ..i)
        local txt1 = sp_vipbg:getChildByName("txt1")
        txt1:setString("VIP"..i)
        local txt2 = sp_vipbg:getChildByName("txt2")
        txt2:setString("x"..vipInfos["" .. i].login_multiplier)
    end

    local vip_level = bole:getUserDataByKey("vip_level")
    local sp_select = node_vip:getChildByName("sp_select")
    local sp_vip = sp_select:getChildByName("sp_vip")
    local txt_vip = sp_select:getChildByName("txt_vip")
    local path=bole:getBuyManage():getVipIconStr(vip_level)
    sp_vip:setTexture(path)
    txt_vip:setString("x"..vipInfos["" .. vip_level].login_multiplier)
    sp_select:setPosition(169,78+75*vip_level)
end


function DailyGiftLayer:onEnter()
    bole.socket:registerCmd("sync_friends_info", self.initFriendInfo, self)
end
function DailyGiftLayer:onExit()
    bole.socket:unregisterCmd("sync_friends_info")
end
function DailyGiftLayer:initFriendInfo(t, data)
    dump(data, "friend")
    if t == "sync_friends_info" then
        if data.f_applications ~= nil then

        end
        self.friends = { }
        if data.friends ~= nil then
            for k, v in ipairs(data.friends) do
                print("---icon=" .. v.icon)
                if v.icon=="self" then
                    self.friends[k] = v
                    bole:loadUserHead(v.user_id,true,function(path,code)
                        print("DailyGif tuser_id="..v.user_id)
                        print("DailyGift code="..code)
                    end)
                end
            end
        end

        if data.fbfriends ~= nil then

        end
    end
end
function DailyGiftLayer:updateUI(event)
    local data = event.result
    if not data then
        return
    end
    self:isSpin(data)
end

function DailyGiftLayer:collect()
    bole:getAppManage():addCoins(self.num_coins * self.mulit)
    self:removeFromParent()
    bole:getUIManage():openScene("LobbyScene")
end

function DailyGiftLayer:isSpin(data)
    -- 这里是接收服务器消息
    if not data.chose then
        return
    end
    self.csbAct:gotoFrameAndPause(0)
    local move = cc.MoveBy:create(0.5, cc.p(160, 80))
    local fade = cc.FadeOut:create(0.5)
    local sp = cc.Spawn:create(move, fade)
    self.spinit:runAction(sp)
    self.index = data.chose % 20
    self.btn_spin:setTouchEnabled(false)
    self:rotaAction()
end

function DailyGiftLayer:spin()
    self.btn_spin:setTouchEnabled(false)
    -- 这里是发送服务器消息
    self:isSpin( { chose = self.index })
end


function DailyGiftLayer:rotaAction()
    self.spinSpeed = 6
    bole:getAudioManage():playEff("jones_wheel2")
    
    self.sp_pan:setRotation(0)
    local sp1 = cc.EaseExponentialOut:create(cc.RotateBy:create(6.0, self.index * 18 + 360 * 6))
    self.sp_pan:runAction(sp1)

    self.sp_pan2:setRotation(0)
    local sp2 = cc.EaseExponentialOut:create(cc.RotateBy:create(6.0, self.index * 18 + 360 * 6))
    self.sp_pan2:runAction(sp2)

    performWithDelay(self, function()
        self:gotoView()
    end , 6.2)
    performWithDelay(self, function()
        self.spinSpeed = 4
        print("------------------------------seep")
    end , 4.5)
end
function DailyGiftLayer:updateTime(dt)
    if not self.sp_pan then
        return
    end
    local rotate = self.sp_pan:getRotation()
    local ratateIndex = math.floor((rotate - 7) / 18)
    if ratateIndex > self.oldRatateIndex then
        self.oldRatateIndex = ratateIndex
        self:toTrigger()
    end
    local rote = self.baizhen:getRotation()
    if self.p_type == 1 then
        if rote > -40 then
            rote = rote - self.spinSpeed
        else
            self.p_type = 2
            rote = -40
        end
        self.baizhen:setRotation(rote)
        return
    end
    if self.p_type >= 2 then
        if rote < 0 then
            rote = rote + self.spinSpeed * 2
            if rote > -35 then
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
function DailyGiftLayer:toTrigger()
    if not self.baizhen then
        return
    end
    if self.p_type == 3 or self.p_type == 0 then
        self.p_type = 1
    end
end
function DailyGiftLayer:gotoView()
    self.sp_mask:setVisible(true)
    self.csbAct:play("stop", true)
    for i = 1, 20 do
        self.lights[i]:runAction(cc.Blink:create(2.5, 5))
    end
    performWithDelay(self, function()
        self.csbAct:play("over", false)
    end , 2.0)
    performWithDelay(self, function()
        self.node_reward:setVisible(true)
        self.csbAct:play("show", false)
    end , 2.5)
    performWithDelay(self, function()
        self:showRoot()
    end , 3)
end

function DailyGiftLayer:touchEvent(sender, eventType)
    local name = sender:getName()
    local tag = sender:getTag()
    print("touchEvent:" .. name)
    if eventType == ccui.TouchEventType.began then
        print("Touch Down")
    elseif eventType == ccui.TouchEventType.moved then
        print("Touch Move")
    elseif eventType == ccui.TouchEventType.ended then
        print("Touch Up")
        if name == "btn_spin" then
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

return DailyGiftLayer
-- endregion
