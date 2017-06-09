-- region *.lua
-- Date
-- 此文件由[BabeLua]插件自动生成
local LoginScene = class("LoginScene", cc.load("mvc").ViewBase)
function LoginScene:onCreate()
    print("LoginScene-onCreate")
    local root = self:getCsbNode():getChildByName("root")
    self._bar_load = ccui.Helper:seekWidgetByName(root, "bar_load")
    self._txt_load = ccui.Helper:seekWidgetByName(root, "txt_load")
    self.progress = 0
    self.isLogin = false
    schedule(self, self.updateTime, 0.1)
    self.initUI=false
end

function LoginScene:updateProgress()
    --加载资源
    self.progress = math.floor(self.progress + math.random(10))
    if self.progress>30 then
        if not self.initUI then
            self.initUI=true
            cc.CSLoader:createNodeWithVisibleSize("csb/LobbyScene.csb")
        end

    end
end


function LoginScene:updateTime()
    if self.progress < 100 then
        self:updateProgress()
        if self.progress > 100 then
            self.progress = 100
        end
        self._bar_load:setPercent(self.progress)
        self._txt_load:setString(self.progress .. "%")
    else
        self:gotoView()
    end
end

function LoginScene:updateUI(data)
    data = data.result
    if data[1] == "gotoView" then
        self.isLogin =true
        self:gotoView()
    end
end

function LoginScene:gotoView()
    if self.isLogin and self.progress >= 100 then
        --bole:getUIManage():openUI(bole.UI_NAME.SlotsLobbyScene)
        bole:getUIManage():openUI(bole.UI_NAME.LobbyScene)
    end
end
return LoginScene
-- endregion 