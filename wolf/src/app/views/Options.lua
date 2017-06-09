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

    local btn_lobby = option:getChildByName("btn_lobby")
    btn_lobby:addTouchEventListener(handler(self, self.touchEvent))

    local btn_chips = option:getChildByName("btn_chips")
    btn_chips:addTouchEventListener(handler(self, self.touchEvent))

    local btn_sipport = option:getChildByName("btn_sipport")
    btn_sipport:addTouchEventListener(handler(self, self.touchEvent))

    local btn_func = option:getChildByName("btn_func")
    btn_func:addTouchEventListener(handler(self, self.touchEvent))
    self.btn_func_ = btn_func

    btn_close:setPressedActionEnabled(true)
    btn_lobby:setPressedActionEnabled(true)
    btn_chips:setPressedActionEnabled(true)
    btn_sipport:setPressedActionEnabled(true)
    btn_func:setPressedActionEnabled(true)
    self.txt_title_ = root:getChildByName("txt_title")
    self.btn_func_text_ = btn_func:getChildByName("txt")
    self.btn_func_icon_ = btn_func:getChildByName("icon")
    --[[
    local slider_music = ccui.Helper:seekWidgetByName(root, "slider_music")
    slider_music:addTouchEventListener(handler(self, self.audioEvent))
    slider_music:setPercent(bole:getAudioManage():getMusicVolume()*100)

    local slider_sound = ccui.Helper:seekWidgetByName(root, "slider_sound")
    slider_sound:addTouchEventListener(handler(self, self.audioEvent))
    slider_sound:setPercent(bole:getAudioManage():getSoundVolume()*100)
    --]]

    local node_music=option:getChildByName("node_music")
    local node_sound=option:getChildByName("node_sound")
    self.music=self:getNewSwitch("music")
    self.sound=self:getNewSwitch("sound")
    node_music:addChild(self.music)
    node_sound:addChild(self.sound)
    self.music:setOn(bole:getAudioManage():isMusic())
    self.sound:setOn(bole:getAudioManage():isSound())
    self.status = 1
    self:adaptScreen()
end


function Options:onEnter()
    bole:addListener("initOptions", self.initOptions, self, nil, true)
end

function Options:initOptions(data)
    data = data.result
    self.status = data
    self:updateUI()
end

function Options:updateUI()
    if self.status == self.SLOT_OPTIONS then
        self.txt_title_:setString("SLOT OPTION")
        self.btn_func_text_:setString("Pay Table")
        self.btn_func_text_:setTextColor({ r = 57, g = 61, b = 107})
        self.btn_func_:loadTextures("res/options/setting_button_yellow.png","res/options/setting_button_yellow.png","res/options/setting_button_yellow.png")
        self.btn_func_icon_:loadTexture("res/options/setting_paytable.png")
    elseif self.status == self.LOBBY_OPTIONS then
        self.txt_title_:setString("LOBBY OPTION")
        self.btn_func_text_:setString("Pay Table")
        self.btn_func_text_:setTextColor({ r = 57, g = 61, b = 107})
        self.btn_func_:loadTextures("res/options/setting_button_yellow.png","res/options/setting_button_yellow.png","res/options/setting_button_yellow.png")
        self.btn_func_icon_:loadTexture("res/options/setting_paytable.png")
    elseif self.status == self.CLUB_OPTIONS then
        self.txt_title_:setString("CLUB OPTION")
        self.btn_func_text_:setString("Leave Your Club")
        self.btn_func_text_:setTextColor({ r = 115, g = 17, b = 0})
        self.btn_func_:loadTextures("res/options/clubSetting_button_orange.png","res/options/clubSetting_button_orange.png","res/options/clubSetting_button_orange.png")
        self.btn_func_icon_:loadTexture("res/options/clubSetting_leave.png")
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
    local sp1=display.newSprite("options/setting_mask.png")
    local sp2=display.newSprite("options/setting_on.png")
    local sp3=display.newSprite("options/setting_off.png")
    local sp4=display.newSprite("options/setting_slide.png")
    local pSwitchControl = cc.ControlSwitch:create(
    sp1,sp2,sp3,sp4,
    cc.Label:createWithSystemFont("On", "Arial-BoldMT", 26),
    cc.Label:createWithSystemFont("Off", "Arial-BoldMT", 26)
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
    elseif eventType == ccui.TouchEventType.moved then
        print("Touch Move")
    elseif eventType == ccui.TouchEventType.ended then
        print("Touch Up")
        if name == "btn_close" then
            self:closeUI()
        elseif name == "btn_lobby" then
            self:btn_back()
        elseif name == "btn_func" then
            self:btn_func()
        elseif name == "btn_chips" then
            self:btn_chips()
        elseif name == "btn_sipport" then
            self:btn_sipport()
        end
    elseif eventType == ccui.TouchEventType.canceled then
        print("Touch Cancelled")
    end
end

function Options:btn_chips()
    print("btn_chips")
end

function Options:btn_func()
    if self.status == self.SLOT_OPTIONS then
	    bole:postEvent("showPayTable")
        self:closeUI()
    elseif self.status == self.LOBBY_OPTIONS then
	   
    elseif self.status == self.CLUB_OPTIONS then
        bole:getUIManage():openClubTipsView(14, function() bole.socket:send("leave_club",{},true) end)
        self:closeUI()
    end
end

function Options:btn_back()
    if self.status == self.SLOT_OPTIONS then
	    bole:postEvent("enterLobby")
    elseif self.status == self.LOBBY_OPTIONS then
        bole:postEvent("backLobbyScene")
        self:closeUI()
    elseif self.status == self.CLUB_OPTIONS then
        bole:postEvent("backLobbyScene")
        self:closeUI()
    end
end

function Options:btn_sipport()
    print("btn_sipport")
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
