-- region *.lua
-- Date
-- 此文件由[BabeLua]插件自动生成
local LoginControl = class("LoginControl")
function LoginControl:ctor()
    print("LoginControl:init")
    bole.socket:registerDelegate(self, self.onServerStateChanged)
    bole.socket:registerCmd("login", self.onLoginSuccess, self)
    self.loginError = 0
end

function LoginControl:onServerStateChanged(id, data)
    if id == MessageType.socket_open then
        print("-----------------------Sever Connect OK---------------------")
        if self.connectSoHandler then
            cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.connectSoHandler)
            self.connectSoHandler = nil
        end
        self:connectSuccess()
    elseif id == MessageType.socket_error then
        print("-----------------------Sever Connect ERROR---------------------")
        self:reConnect()
    elseif id == MessageType.socket_close then
        print("-----------------------Sever Connect CLOSE---------------------")
        self:relogin()
    end
end

function LoginControl:isLoginViewRunning()
    if self.loginView and self.loginView.isAlive then
        return true
    end

    return false
end

function LoginControl:setLoginView()
    bole:getBoleEventKey():clearKeyBack()
    bole:getAudioManage():stopAllMusic()

    local scene = bole:getEntity("app.views.LoginScene", self)
    display.runScene(scene)
    self.loginView = scene
end

function LoginControl:login()
    local flag = false
    if BOLE_USE_UPDATE_FILE and BOLE_UPDATE_FILE_ING then
        
    else
        if not self:isLoginViewRunning() then
            self:setLoginView()
        else
            flag = true
        end
    end

    if not Socket:isConnected() then
        if flag then
            self:connectSocket()
        else
            Socket:connect()
        end
    else
        self:connectSuccess()
    end
end

function LoginControl:connectSuccess()
    if not self.connectHandler then
        local function callback(dt)
            cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.connectHandler)
            self.connectHandler = nil
            bole:postEvent("socketConnectOk")
        end
        self.connectHandler = cc.Director:getInstance():getScheduler():scheduleScriptFunc(callback, 0.03, false)
    end
end

function LoginControl:relogin()
    self:login()
end

function LoginControl:connectSocket()
    if not self.connectSoHandler then
        local function callback(dt)
            cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.connectSoHandler)
            self.connectSoHandler = nil
            Socket:connect()
        end
        self.connectSoHandler = cc.Director:getInstance():getScheduler():scheduleScriptFunc(callback, 3, false)
    end
end

function LoginControl:reConnect()
    if BOLE_USE_UPDATE_FILE and BOLE_UPDATE_FILE_ING then  --更新文件
    else
        if self:isLoginViewRunning() then
            self:connectSocket()
        else
            local offlineView = bole:getEntity("app.views.loading.OfflineView")
            offlineView:run()
            self:connectSocket()
        end
    end
end

function LoginControl:sendLoginMsg()
    print("LoginControl:sendLoginMsg")
    if bole.socket:isConnected() then
        local data = {}
        data.macaddr = bole:getMacAddress()
        data.duid = bole:getDeviceId()
        data.package = "slots.swf.vegas.casino.games.free"
        data.version = '1.0.0'

        local credential = cc.UserDefault:getInstance():getStringForKey("credential", "")
        if (credential ~= "") then
            data.credential = credential
        end

        bole.socket:send("login", data)
        return true
    end

    return false
end

function LoginControl:onLoginError()
    print("LoginControl:onLoginError")
    if self.loginError > 5 then
        self.needToRelogin = true
        if not self.schedulerHandler then
            local function resetLoginError()
                self.loginError = 0
                cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.schedulerHandler)
                self.schedulerHandler = nil

                if self.needToRelogin then
                    self:onLoginError()
                end
            end
            self.schedulerHandler = cc.Director:getInstance():getScheduler():scheduleScriptFunc(resetLoginError, 20, false)
        end
        return
    end

    self.loginError = self.loginError + 1
    if not Socket:isConnected() then
        self:connectSocket()
    else
        self:sendLoginMsg()
    end
end

function LoginControl:onLoginSuccess(t, data)
    self.needToRelogin = false
    if data.is_kick then
        local kickHandler
        local function kickFunc()
            cc.Director:getInstance():getScheduler():unscheduleScriptEntry(kickHandler)
            self:sendLoginMsg()
        end
        kickHandler = cc.Director:getInstance():getScheduler():scheduleScriptFunc(kickFunc, 2, false)
        return
    end

    local userDefault = cc.UserDefault:getInstance()
    userDefault:setStringForKey("credential", data.credential or "")
    userDefault:flush()

    bole:getUserData():setData(data)
    bole:getClubManage():initLocalData()
    bole:getFriendManage():initLocalData()
    bole:getBuyManage():initLocalData()

    bole.shop_bonus_time = data.shop_bonus
    bole.recommend_users = data.recommend_users
    bole.recommend_index = 1
    bole.recommend_max = #data.recommend_users

    bole:getActCenter()
    bole:postEvent("loginActData")

    bole:getFacebookCenter():onGameLoginSuccess()

    bole:postEvent("loginGameSuccess")
end

function LoginControl:enterLobbyView()
    local experience = bole:getUserDataByKey("experience")
    local login_reward = bole:getUserDataByKey("login_reward")
    if experience > 1 then
        if login_reward == 1 then
            bole:setUserDataByKey("login_reward", 0)
            bole.socket:send(bole.COLLECT_LOGIN_REWARD, { })
        else
            bole:getUIManage():openScene("LobbyScene")
        end
    end
    bole:getNewbieCenter():start()
end

return LoginControl

-- endregion
