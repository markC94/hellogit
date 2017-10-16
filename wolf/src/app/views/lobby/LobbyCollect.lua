-- region *.lua
-- Date
-- 此文件由[BabeLua]插件自动生成
local LobbyCollect = class("LobbyCollect", cc.Node)
--大厅收集
LobbyCollect.POS_COINS_LOBBY = 1
LobbyCollect.POS_ZS_LOBBY = 2
LobbyCollect.POS_COINS_SPIN = 3
function LobbyCollect:ctor(data,node)
    self.node=node
    self.status = 0
    bole.login_bouns_time = nil
    self.csbNode = cc.CSLoader:createNode("csb/lobby/LobbyCollect.csb")
    self:addChild(self.csbNode)

    self:registerScriptHandler( function(state)
        if state == "enter" then
            self:onEnter()
        elseif state == "exit" then
            self:onExit()
        end
    end )
    self.img_collect = self.csbNode:getChildByName("img_collect") 
    self.img_collect:setTouchEnabled(true)
    self.img_collect:addTouchEventListener(handler(self, self.touchEvent))

    self.clip_collect=self.img_collect:getChildByName("clip")

    self.node_act = self.clip_collect:getChildByName("node_act")
    self.act_icon = sp.SkeletonAnimation:create("common_act/JBidle.json", "common_act/JBidle.atlas")
    self.act_icon:setAnimation(0, "animation", true)
    self.node_act:addChild(self.act_icon)

    self.img_vedio = self.csbNode:getChildByName("img_vedio")
    self.img_vedio:setTouchEnabled(true)
    self.img_vedio:addTouchEventListener(handler(self, self.touchEvent))
    self.clip_vedio=self.img_vedio:getChildByName("clip")


    self.img_wait = self.csbNode:getChildByName("img_wait")
    self.img_wait:setTouchEnabled(true)
    self.img_wait:addTouchEventListener(handler(self, self.touchEvent))

    self.isClick=false

    local function update(dt)
        self:updateTime(dt)
    end
    self:onUpdate(update)

    if not data then
        self:updateStatus( { result = { status = 1 } })
    else
        if data[1] > 0 then
            if data[2] == 0 then
                self:updateStatus( { result = { status = 2, time = data[1] } })
            else
                self:updateStatus( { result = { status = 3, time = data[1] } })
            end
        else
            self:updateStatus( { result = { status = 1 } })
        end
    end
end
function LobbyCollect:updateTime(dt)

    if not bole.login_bouns_time then
        return
    end

    local hour = math.floor(bole.login_bouns_time / 60)
    local s =string.format("%02d",math.floor(bole.login_bouns_time) % 60)
    if self.txt_time then
        self.txt_time:setString("IN "..hour .. " : " .. s)
    end

    if bole.login_bouns_time <= 0 then
        bole.login_bouns_time = nil
        bole:postEvent("LobbyCollect", { status = 1 })
    end

end
function LobbyCollect:updateStatus(event)
    local data = event.result
    dump(data, "updateStatus")
    self.status = data.status
    bole.login_bouns_time = data.time
    self.img_collect:setVisible(false)
    self.img_vedio:setVisible(false)
    self.img_wait:setVisible(false)
    if self.status == 1 then
        self.img_now = self.img_collect
    elseif self.status == 2 then
        self.img_now = self.img_vedio
    elseif self.status == 3 then
        self.img_now = self.img_wait
    end
    self.img_now:setVisible(true)
    self.txt_tips = self.img_now:getChildByName("txt_tips")
    self.txt_time = self.img_now:getChildByName("txt_time")
end
function LobbyCollect:onEnter()
    bole:addListener("LobbyCollect", self.updateStatus, self, nil, true)
    bole.socket:registerCmd(bole.RESET_LOBBY_BOUNS, self.oncmd, self)
    bole.socket:registerCmd(bole.COLLECT_LOBBY_BONUS, self.oncmd, self)
end

function LobbyCollect:onExit()
    bole:getEventCenter():removeEventWithTarget("LobbyCollect", self)
    bole.socket:unregisterCmd(bole.RESET_LOBBY_BOUNS)
    bole.socket:unregisterCmd(bole.COLLECT_LOBBY_BONUS)
end
function LobbyCollect:oncmd(t, data)
    if not data then
        return
    end
    self.img_collect:setTouchEnabled(true)
    if data.error~=0 then
        bole:popMsg({msg="LobbyCollect error"..data.error})
        return
    end
    local data = data.lobby_bonus
    bole:setUserDataByKey("lobby_bonus",data)
    if data[1] > 0 then
        if data[2] == 0 then
            self:updateStatus( { result = { status = 2, time = data[1] } })
        else
            self:updateStatus( { result = { status = 3, time = data[1] } })
        end
    else
        self:updateStatus( { result = { status = 1 } })
    end
end
function LobbyCollect:getCollectCoins()
    local director = cc.Director:getInstance()
    local view = director:getOpenGLView()
    local dessize = view:getDesignResolutionSize()
    local w2, h2 = dessize.width, dessize.height
    local function addCoins()
        
    end
    
    bole:getAudioManage():playMusic("common_cc",true)
    local node_act
    if self.node then
        print("----------------------------------------------------------node")
        node_act = bole:getEntity("app.views.lobby.SpecialBonusWinCoin",true,cc.p(667-108, h2 - 48),addCoins)
        node_act:setPosition(667, -750)
        self.node:addChild(node_act, bole.ZORDER_TOP)
    else
        print("----------------------------------------------------------not node")
        node_act = bole:getEntity("app.views.lobby.SpecialBonusWinCoin",true,cc.p(667-108, h2 - 48),addCoins)
        node_act:setPosition(667, 80)
        display.getRunningScene():addChild(node_act, bole.ZORDER_TOP)
    end
    
    performWithDelay(self,function()
        local level = bole:getUserDataByKey("level")
        local levels = bole:getConfigCenter():getConfig("level")
        bole:getAppManage():addCoins(levels[""..level].lobby_bonus)
        bole:postEvent("coinsJump",{pos=LobbyCollect.POS_COINS_LOBBY,time=1})
    end,1.5)
    performWithDelay(self,function()
        bole:getAudioManage():stopAudio("common_cc")
        node_act:removeFromParent()
    end,3)
end

function LobbyCollect:click()
    self.isClick=true
    performWithDelay(self,function()
        self.isClick=false
    end,1)
end
function LobbyCollect:touchEvent(sender, eventType)
    local name = sender:getName()
    local tag = sender:getTag()
    print("touchEvent:" .. name)
    if self.isClick then
        return
    end
    if eventType == ccui.TouchEventType.began then
        print("Touch Down")
    elseif eventType == ccui.TouchEventType.moved then
        print("Touch Move")
    elseif eventType == ccui.TouchEventType.ended then
        print("Touch Up")
        if name == "img_collect" then
            self.img_collect:setVisible(false)
            self.img_vedio:setVisible(true)
            self:click()
            self:getCollectCoins()
            bole.socket:send(bole.COLLECT_LOBBY_BONUS, { })
            self.img_collect:setTouchEnabled(false)
        elseif name == "img_vedio" then
            self:click()
            bole:showADVideo( function(num)
                print("showADVideo--------------callback------------")
                if num then
                    local reward=tonumber(num)
                    if reward then
                        print("showADVideo--------------reward:" .. reward)
                        bole.socket:send(bole.RESET_LOBBY_BOUNS, { })
                    end
                    print("showADVideo--------------num:" .. num)
                end
            end )
            
        elseif name == "img_wait" then
--            self:getCollectCoins()
        end
    elseif eventType == ccui.TouchEventType.canceled then
        print("Touch Cancelled")
    end
end
return LobbyCollect

-- endregion
