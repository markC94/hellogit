
cc.FileUtils:getInstance():setPopupNotify(false)
cc.FileUtils:getInstance():addSearchPath("src/")
cc.FileUtils:getInstance():addSearchPath("res/")


require "config"
require "cocos.init"
require "bole"

local targetPlatform = cc.Application:getInstance():getTargetPlatform()
if cc.PLATFORM_OS_WINDOWS == targetPlatform then
    cc.FileUtils:getInstance():addSearchPath("E:/slots/WolfSlots/res", true)
end

local function main()
    if bole.debug >= 1 then
        if cc.FileUtils:getInstance():isFileExist("selfConfig.lua") or cc.FileUtils:getInstance():isFileExist("selfConfig.luac") then
            require "selfConfig"
        end
    end
    cc.loadLua("app.MyApp"):create()
end

local status, msg = xpcall(main, __G__TRACKBACK__)
if not status then
    print(msg)
end
