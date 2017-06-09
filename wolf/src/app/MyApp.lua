
local MyApp = class("MyApp", cc.load("mvc").AppBase)

function MyApp:onCreate()
    math.randomseed(os.time())
    cc.loadLua("AppConfig")
    cc.loadLua("ServerConfig")
    cc.loadLua("app.command.JniUtil")
    --cc.loadLua("app.command.NetUtil")
    bole:getUIManage():setApp(self)
    bole:getAppManage():connectScoket()
    bole.headImgs={}
    bole:getLoginControl():openLoginView()
    cc.SpriteFrameCache:getInstance():addSpriteFrames("plist/Common.plist")
    cc.SpriteFrameCache:getInstance():addSpriteFrames("plist/Head.plist")
    cc.SpriteFrameCache:getInstance():addSpriteFrames("plist/Lobby.plist")
    --bole:setUpdate(true)
end
-- 修改默认路径 view默认路径
function MyApp:changeConfig(config)
    config = config or self.configs_
    self.configs_.viewsRoot = config.viewsRoot or self.configs_.viewsRoot
    self.configs_.modelsRoot = config.modelsRoot or self.configs_.modelsRoot
end
return MyApp
