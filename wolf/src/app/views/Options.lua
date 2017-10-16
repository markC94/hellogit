-- region *.lua
-- Date
-- 此文件由[BabeLua]插件自动生成
local Options = class("Options", cc.load("mvc").ViewBase)

Options.SLOT_OPTIONS = 1     --老虎机内设置
Options.LOBBY_OPTIONS = 2     --大厅设置
Options.CLUB_OPTIONS = 3     --俱乐部设置

function Options:onCreate()
    print("Options-onCreate")
    local root = self:getCsbNode():getChildByName("root_1")

    local option = root:getChildByName("option")
    local btn_close = root:getChildByName("btn_close")
    btn_close:addTouchEventListener(handler(self, self.touchEvent))

    local listView = root:getChildByName("listView")
    listView:setScrollBarOpacity(0)
    self.listView = listView
    self.bg2 = root:getChildByName("bg2")
    self.mask_down = root:getChildByName("mask_down")

    self.cell_fb = listView:getChildByName("cell_fb")
    self.cell_lobby = listView:getChildByName("cell_lobby")
    self.cell_sounds = listView:getChildByName("cell_sounds")
    self.cell_music = listView:getChildByName("cell_music")
    self.cell_notifications = listView:getChildByName("cell_notifications")
    self.cell_paytable = listView:getChildByName("cell_paytable")
    self.cell_getChips = listView:getChildByName("cell_getChips")
    self.cell_contactUs = listView:getChildByName("cell_contactUs")
    self.cell_rateGame = listView:getChildByName("cell_rateGame")
    self.cell_leaveClub = listView:getChildByName("cell_leaveClub")
    self:initFbCell()

    self.cell_fb:setAnchorPoint(0.5,0.5)
    self.cell_lobby:setAnchorPoint(0.5,0.5)
    self.cell_sounds:setAnchorPoint(0.5,0.5)
    self.cell_music:setAnchorPoint(0.5,0.5)
    self.cell_notifications:setAnchorPoint(0.5,0.5)
    self.cell_paytable:setAnchorPoint(0.5,0.5)
    self.cell_getChips:setAnchorPoint(0.5,0.5)
    self.cell_contactUs:setAnchorPoint(0.5,0.5)
    self.cell_rateGame:setAnchorPoint(0.5,0.5)
    self.cell_leaveClub:setAnchorPoint(0.5,0.5)

    self.cell_fb:addTouchEventListener(handler(self, self.touchEvent))
    self.cell_lobby:addTouchEventListener(handler(self, self.touchEvent))
    self.cell_paytable:addTouchEventListener(handler(self, self.touchEvent))
    self.cell_getChips:addTouchEventListener(handler(self, self.touchEvent))
    self.cell_contactUs:addTouchEventListener(handler(self, self.touchEvent))
    self.cell_rateGame:addTouchEventListener(handler(self, self.touchEvent))
    self.cell_leaveClub:addTouchEventListener(handler(self, self.touchEvent))

    local node_music=self.cell_music:getChildByName("node_music")
    local node_sound=self.cell_sounds:getChildByName("node_sounds")
    local cell_notifications=self.cell_notifications:getChildByName("node_notifications")

    self.music=self:getNewSwitch("music")
    self.sound=self:getNewSwitch("sound")
    self.notification = self:getNewSwitch("notification")
    node_music:addChild(self.music)
    node_sound:addChild(self.sound)
    cell_notifications:addChild(self.notification)
    self.music:setOn(bole:getAudioManage():isMusic())
    self.sound:setOn(bole:getAudioManage():isSound())
    self.status = 1
    self:adaptScreen()
end


function Options:onEnter()
    bole:addListener("initOptions", self.initOptions, self, nil, true)
end
function Options:onKeyBack()
   self:closeUI()
end

function Options:initFbCell()
    self.cell_fb:getChildByName("connectFb"):setVisible(true)
    self.cell_fb:getChildByName("txt"):setVisible(false)
    if bole:getFacebookCenter():isLogin() then
        self.cell_fb:getChildByName("connectFb"):setVisible(false)
        self.cell_fb:getChildByName("txt"):setVisible(true)
    end
end

function Options:initOptions(data)
    data = data.result
    self.status = data
    self:updateUI()
end

function Options:updateUI()
    if self.status == self.SLOT_OPTIONS then
        self.bg2:setVisible(false)
        self.mask_down:setVisible(true)
        self.listView:removeChild(self.cell_fb)
        self.listView:removeChild(self.cell_leaveClub)   
    elseif self.status == self.LOBBY_OPTIONS then
        self.bg2:setVisible(true)
        self.mask_down:setVisible(false)
        self.listView:removeChild(self.cell_lobby)
        self.listView:removeChild(self.cell_paytable)
        self.listView:removeChild(self.cell_getChips)
        self.listView:removeChild(self.cell_leaveClub)
    elseif self.status == self.CLUB_OPTIONS then
        self.bg2:setVisible(false)
        self.mask_down:setVisible(true)
        self.listView:removeChild(self.cell_paytable)
        self.listView:removeChild(self.cell_fb)
    end
end

-- SwitchTest
function Options:getNewSwitch(name)
    -- Create the switch
    local function valueChanged(pSender)
        if nil == pSender then
            return
        end
        local pControl = pSender
        print("pControl:getName():"..pControl:getName())
        if pControl:getName()=="sound" then
            bole:getAudioManage():setSound(pControl:isOn())
        elseif pControl:getName()=="music" then
            bole:getAudioManage():setMusic(pControl:isOn())
        end
    end
    local sp1=display.newSprite("setting/setting_mask.png")
    local sp2=display.newSprite("setting/setting_on.png")
    local sp3=display.newSprite("setting/setting_off.png")
    local sp4=display.newSprite("setting/setting_slide.png")
    local pSwitchControl = cc.ControlSwitch:create(
    sp1,sp2,sp3,sp4,
    cc.Label:createWithTTF("ON", "font/bole_ttf.ttf", 26),
    cc.Label:createWithTTF("OFF", "font/bole_ttf.ttf", 26)
    --cc.Label:createWithSystemFont("ON", "font/bole_ttf.ttf", 28),
    --cc.Label:createWithSystemFont("OFF", "font/bole_ttf.ttf", 28)
    )
    pSwitchControl:setName(name)
    pSwitchControl:registerControlEventHandler(valueChanged, cc.CONTROL_EVENTTYPE_VALUE_CHANGED)
    --valueChanged(pSwitchControl)
    return pSwitchControl
end

function Options:audioEvent(sender, eventType)
        local slider = sender
        if slider:getName()=="slider_music" then
             bole:getAudioManage():setMusicVolume(slider:getPercent()*0.01)
        elseif slider:getName()=="slider_sound" then
            bole:getAudioManage():setSoundVolume(slider:getPercent()*0.01)
        end
end

function Options:touchEvent(sender, eventType)
    local name = sender:getName()
    local tag = sender:getTag() 
    print("touchEvent:" .. name)
    if eventType == ccui.TouchEventType.began then
        print("Touch Down")
        sender:runAction(cc.ScaleTo:create(0.1,0.98,0.98))
    elseif eventType == ccui.TouchEventType.moved then
        print("Touch Move")
    elseif eventType == ccui.TouchEventType.ended then
        sender:runAction(cc.ScaleTo:create(0.1,1,1))
        print("Touch Up")
        if name == "btn_close" then
            self:closeUI()
        elseif name == "cell_fb" then
            self:fb()
        elseif name == "cell_lobby" then
            self:lobby()
        elseif name == "cell_paytable" then
            self:payTable()
        elseif name == "cell_getChips" then
            self:getChips()
        elseif name == "cell_contactUs" then
            self:contactUs()
        elseif name == "cell_rateGame" then
            self:rateGame()
        elseif name == "cell_leaveClub" then
            self:leaveClub()
        end
    elseif eventType == ccui.TouchEventType.canceled then
        print("Touch Cancelled")
        sender:runAction(cc.ScaleTo:create(0.1,1,1))
    end
end

function Options:fb()
    bole:getFacebookCenter():bindFacebook()
end

function Options:lobby()
    if bole:getSpinApp():isThemeAlive() then
        --bole:popMsg( { msg = "Leave the slot and return to lobby?", title = "leave slot", cancle = true },
        --function()
            bole.socket:send(bole.SERVER_LEAVE_THEME, { })
            bole:getAppManage():updateLobby()
            bole:postEvent("enterLobby", true)
        --end )
    else
        bole:postEvent("backLobbyScene", true)
    end
    self:closeUI()
end

function Options:payTable()
    bole:getUIManage():openPayTable()
    self:closeUI()
end

function Options:getChips()
    bole:getUIManage():openNewUI("ShopLayer",true,"shop_lobby","app.views.shop")
    self:closeUI()
end


function Options:contactUs()
    print("contactUs")
    self:closeUI()
    bole:tohelpshift()
end

function Options:rateGame()
    print("rateGame")
    self:closeUI()
--    local index =math.random(1,4)
--    if index== 1 then 
--        bole:toAdjustPrice(os.time().."",0.99)
--    end
--    if index== 2 then 
--        bole:toAdjustPlayer()
--    end
--    if index== 3 then 
--        bole:toAdjustNoCoins()
--    end
--    if index== 4 then 
--        bole:toAdjustLevel()
--    end
end

function Options:leaveClub()
    bole:popMsg( { msg = "Your are about to leave your club.Are you sure?", title = "leave club", cancle = true }, function() bole.socket:send("leave_club", { }, true) end)
    self:closeUI()
end

function Options:adaptScreen()
    local winSize = cc.Director:getInstance():getWinSize()
    local root = self:getCsbNode():getChildByName("root_1")
    self:setPosition(0,0)
    root:setPosition(winSize.width / 2, winSize.height / 2)
    root:setScale(0.1)
    root:runAction(cc.ScaleTo:create(0.2,1,1))
end

function Options:onExit()
    bole:removeListener("initOptions", self)
end

return Options


-- endregion
