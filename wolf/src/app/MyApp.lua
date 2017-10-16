
local MyApp = class("MyApp")
function MyApp:ctor()
    if CC_SHOW_FPS then
        cc.Director:getInstance():setDisplayStats(true)
    end
    math.randomseed(os.time())
    self:onCreate()
end
function MyApp:onCreate()
    -- ScrollView »¬¶¯ËÙ¶È
--    local userDefault = cc.UserDefault:getInstance()
--    userDefault:setFloatForKey("ScrollView_handleReleaseLogic_factor_time", 3)
--    userDefault:setFloatForKey("ScrollView_handleReleaseLogic_factor_pos", 1.5)
--    userDefault:setFloatForKey("ScrollView_MOVEMENT_FACTOR",0.95)
--    userDefault:flush()

    cc.loadLua("ServerConfig")
    cc.loadLua("app.command.JniUtil")
    bole.DownLoadThemes={}
    bole.headImgs={}
    bole.http_url_funcs={}
    bole:getAppManage()
    bole:getLoginControl():login()
    bole:setUpdate(true)
end
return MyApp
