-- region *.lua
-- Date
-- 此文件由[BabeLua]插件自动生成
local LoginScene = class("LoginScene", cc.Scene)
function LoginScene:ctor(loginControl)
    self.loginControl = loginControl

    local rootNode = cc.CSLoader:createNodeWithVisibleSize("loading/loadingView.csb")
    self:addChild(rootNode)

    self.loadingBarBg = rootNode:getChildByName("barbg")
    self.loadingBar = self.loadingBarBg:getChildByName("bar")
    self.rootNode = rootNode

    self.curMaxProgress = 40
    self.curProgress = 0
    self.loadingBar:setPercent(0)

    self:enableNodeEvents()
    self:onEnter()

    local function update(dt)
        self:update(dt)
    end
    self:onUpdate(update)
end

function LoginScene:onEnter()
    if self.isAlive then return end

    self.isAlive = true
    bole:addListener("socketConnectOk", self.onConnectOk, self, nil, true)
    bole:addListener("loginGameSuccess", self.onLoginSuccess, self, nil, true)
    bole:addListener("sendMsgError", self.onLoginError, self, nil, true)
end

function LoginScene:onExit()
    self.isAlive = false
    bole:removeListener("socketConnectOk", self)
    bole:removeListener("loginGameSuccess", self)
    bole:removeListener("sendMsgError", self)
end

function LoginScene:onLoginError()
    print("LoginScene:onLoginError")
    self.loginControl:onLoginError()
end

function LoginScene:update(dt)
    if self.curProgress < self.curMaxProgress then
        self.curProgress = self.curProgress + 2
        if self.curProgress >= 100 then
            self.loginControl:enterLobbyView()
        else
            self.loadingBar:setPercent(self.curProgress)
        end
    end
end

function LoginScene:onConnectOk(event)
    self.isConnectSuccess = true
    self.curMaxProgress = 80
    self.loginControl:sendLoginMsg()
end

function LoginScene:onLoginSuccess(event)
    self.isLoginServerOk = true
    self.curMaxProgress = 100
end

return LoginScene



--local LoginScene = class("LoginScene", cc.load("mvc").ViewBase)
--function LoginScene:onCreate()
--    print("LoginScene-onCreate")
--    local root = self:getCsbNode():getChildByName("root")
--    self._bar_load = ccui.Helper:seekWidgetByName(root, "bar_load")
--    self._txt_load = ccui.Helper:seekWidgetByName(root, "txt_load")
--    self.txt_tips = ccui.Helper:seekWidgetByName(root, "txt_tips")
--    self.progress = 0
--    self.newProgress = 0
--    self.isLogin = false
--    local function update(dt)
--        self:updateTime(dt)
--    end
--    self:onUpdate(update)
--end
--function LoginScene:onEnter()
--    self:initLoading()
--end

--function LoginScene:onKeyBack()

--end

--function LoginScene:initLoading()
--    --需要加载的所有资源文件
----    self.isLoding=true
--    local paths={plist={"plist/Common","plist/Head","plist/Lobby","plist/MiniFarm","plist/Options"}}
--    local loadingNode=bole:getUIManage():getLoadingNode(paths,handler(self,self.updateLoading),handler(self,self.finishLoading))
--    self:addChild(loadingNode,1)
--end
--function LoginScene:updateLoading(progress,path)
--    self.newProgress=progress
--    performWithDelay(self,function()
--        self.txt_tips:setString("loading..."..path)
--    end,progress*0.01)
--end

--function LoginScene:finishLoading()
--    self.newProgress=100
--    --这里不处理 放在进度动画结束处理
--    print("--------------- LoginScene:finishLoading")
--end

--function LoginScene:updateTime(dt)
--    if self.isLoding then
--        return
--    end
--    if self.newProgress~=self.progress then
--        self.progress= math.floor(self.progress+dt*100+1)
--        if self.progress > self.newProgress then
--            self.progress = self.newProgress
--        end
--        self._bar_load:setPercent(self.progress)
--        self._txt_load:setString(self.progress .. "%")
--        if self.progress == 100 then
--            self.isLoding =true
--            self:gotoView()
--        end
--    end
--end

--function LoginScene:updateUI(data)
--    data = data.result
--    if data[1] == "gotoView" then
--        self.txt_tips:setString("loading...server")
--        self.isLogin =true
--        self:gotoView()
--    end
--end

--function LoginScene:gotoView()
--    if self.isLogin and self.isLoding then
--        local experience = bole:getUserDataByKey("experience")
--        local login_reward = bole:getUserDataByKey("login_reward")
--        if experience > 1 then
--            if login_reward == 1 then
--                bole:setUserDataByKey("login_reward", 0)
--                bole.socket:send(bole.COLLECT_LOGIN_REWARD, { })
--            else
--                bole:getUIManage():openScene("LobbyScene")
--            end
--        end
--        bole:getNewbieCenter():start()
--    end
--end
--return LoginScene
-- endregion 