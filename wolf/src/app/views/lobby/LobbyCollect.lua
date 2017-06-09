-- region *.lua
-- Date
-- 此文件由[BabeLua]插件自动生成

local LobbyCollect = class("LobbyCollect", cc.Node)
function LobbyCollect:ctor(data)
    self.status = 0
    self.delayTime = nil
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

    self.img_vedio = self.csbNode:getChildByName("img_vedio")
    self.img_vedio:setTouchEnabled(true)
    self.img_vedio:addTouchEventListener(handler(self, self.touchEvent))

    self.img_wait = self.csbNode:getChildByName("img_wait")
    self.img_wait:setTouchEnabled(true)
    self.img_wait:addTouchEventListener(handler(self, self.touchEvent))



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
    if not self.delayTime then
        return
    end

    self.delayTime = self.delayTime - dt
    local hour = math.floor(self.delayTime / 60)
    local s = math.floor(self.delayTime) % 60
    if self.txt_time then
        self.txt_time:setString(hour .. "  :  " .. s)
    end
    if self.delayTime <= 0 then
        self.delayTime = nil
        bole:postEvent("LobbyCollect", { status = 1 })
    end
end
function LobbyCollect:updateStatus(event)
    local data = event.result
    dump(data, "updateStatus")
    self.status = data.status
    self.delayTime = data.time
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
    if data.error~=0 then
        bole:popMsg({msg="LobbyCollect error"..data.error})
        return
    end
    local data = data.lobby_bonus
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
    -- bole:bigWinFlyCoin(cc.p(667,80))
    local director = cc.Director:getInstance()
    local view = director:getOpenGLView()
    local framesize = view:getFrameSize()
    local w, h = framesize.width, framesize.height
    local dessize = view:getDesignResolutionSize()
    local factor = director:getContentScaleFactor()
    local w2, h2 = dessize.width, dessize.height
    local function addCoins()
        local level = bole:getUserDataByKey("level")
        local levels = bole:getConfigCenter():getConfig("level")
        bole:getAppManage():addCoins(levels[""..level].lobby_bonus) 
    end
    local node = bole:getEntity("app.views.lobby.SpecialBonusWinCoin",true,cc.p(667, h2 - 50),addCoins)
    node:setPosition(667, 80)
    display.getRunningScene():addChild(node, bole.ZORDER_TOP)
end
function LobbyCollect:touchEvent(sender, eventType)
    local name = sender:getName()
    local tag = sender:getTag()
    print("touchEvent:" .. name)
    if eventType == ccui.TouchEventType.began then
        print("Touch Down")
    elseif eventType == ccui.TouchEventType.moved then
        print("Touch Move")
    elseif eventType == ccui.TouchEventType.ended then
        print("Touch Up")
        if name == "img_collect" then
            self:getCollectCoins()
            bole.socket:send(bole.COLLECT_LOBBY_BONUS, { })
        elseif name == "img_vedio" then
            bole:showADVideo( function(num)
                if num then
                    print("showADVideo--------------:" .. num)
                end
            end )
            bole.socket:send(bole.RESET_LOBBY_BOUNS, { })
        elseif name == "img_wait" then
            bole:getDailyGift()
        end
    elseif eventType == ccui.TouchEventType.canceled then
        print("Touch Cancelled")
    end
end
return LobbyCollect

-- endregion
