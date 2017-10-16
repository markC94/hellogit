-- use framework, will disable all deprecated API, false - use legacy API
CC_USE_FRAMEWORK = true

-- disable create unexpected global variable
CC_DISABLE_GLOBAL = true


release_print("#updategamebegin#")



-- 0 - disable debug info, 2 - verbose debug info
DEBUG = bole.getDebugMode()
-- show FPS on screen
CC_SHOW_FPS = false
--update file by wangshuai
BOLE_USE_UPDATE_FILE = true
BOLE_USE_SQLITE = true
BOLE_UPDATE_FILE_ING = true
KEY_OF_TEST_USER = "boslot"
BOLE_TEST_USER = cc.UserDefault:getInstance():getIntegerForKey(KEY_OF_TEST_USER, 0) == 1
SERVER_IP = "potpwolf.bolegames.com"
SERVER_PORT = 1237

cc.FileUtils:getInstance():setPopupNotify(false)

cc.ResolutionPolicy =
{
    EXACT_FIT = 0,
    NO_BORDER = 1,
    SHOW_ALL  = 2,
    FIXED_HEIGHT  = 3,
    FIXED_WIDTH  = 4,
    UNKNOWN  = 5,
}

-- for module display
local CC_DESIGN_RESOLUTION = {
    width = 1334,
    height = 750,
    autoscale = "FIXED_WIDTH",
    callback = function(framesize)
        local ratio = framesize.width / framesize.height
        if ratio <= 1.34 then
            bole.isPadScreen = true
        end
    end
}





local view = cc.Director:getInstance():getOpenGLView()
if not view then
    local width = 960
    local height = 640
    if CC_DESIGN_RESOLUTION then
        if CC_DESIGN_RESOLUTION.width then
            width = CC_DESIGN_RESOLUTION.width
        end
        if CC_DESIGN_RESOLUTION.height then
            height = CC_DESIGN_RESOLUTION.height
        end
    end
    view = cc.GLViewImpl:createWithRect("Cocos2d-Lua", cc.rect(0, 0, width, height))
    director:setOpenGLView(view)
end

local function setDesignResolution(r, framesize)
    if r.autoscale == "FILL_ALL" then
        view:setDesignResolutionSize(framesize.width, framesize.height, cc.ResolutionPolicy.FILL_ALL)
    else
        local scaleX, scaleY = framesize.width / r.width, framesize.height / r.height
        local width, height = framesize.width, framesize.height
        if r.autoscale == "FIXED_WIDTH" then
            width = framesize.width / scaleX
            height = framesize.height / scaleX
            view:setDesignResolutionSize(width, height, cc.ResolutionPolicy.NO_BORDER)
        elseif r.autoscale == "FIXED_HEIGHT" then
            width = framesize.width / scaleY
            height = framesize.height / scaleY
            view:setDesignResolutionSize(width, height, cc.ResolutionPolicy.NO_BORDER)
        elseif r.autoscale == "EXACT_FIT" then
            view:setDesignResolutionSize(r.width, r.height, cc.ResolutionPolicy.EXACT_FIT)
        elseif r.autoscale == "NO_BORDER" then
            view:setDesignResolutionSize(r.width, r.height, cc.ResolutionPolicy.NO_BORDER)
        elseif r.autoscale == "SHOW_ALL" then
            view:setDesignResolutionSize(r.width, r.height, cc.ResolutionPolicy.SHOW_ALL)
        else
            release_print(string.format("display - invalid r.autoscale \"%s\"", r.autoscale))
        end
    end
end

function setAutoScale(configs)
    if type(configs) ~= "table" then return end

    local framesize = view:getFrameSize()
    if type(configs.callback) == "function" then
        local c = configs.callback(framesize)
        for k, v in pairs(c or {}) do
            configs[k] = v
        end
    end

    setDesignResolution(configs, framesize)

    release_print(string.format("# design resolution size       = {width = %0.2f, height = %0.2f}", configs.width, configs.height))
    release_print(string.format("# design resolution autoscale  = %s", configs.autoscale))
end




release_print("#game mode begin=" .. DEBUG .. ",userStatus=" .. tostring(BOLE_TEST_USER))
if DEBUG == 0 then
    CC_SHOW_FPS = false
    BOLE_USE_UPDATE_FILE = true
    BOLE_USE_SQLITE = true
    BOLE_UPDATE_FILE_ING = true

    if BOLE_TEST_USER then
        DEBUG = 3
        CC_SHOW_FPS = true
        print = release_print

        local target = cc.Application:getInstance():getTargetPlatform()
        if target == 3 then
            cc.FileUtils:getInstance():addSearchPath("/sdcard/.momo.bole.wolf", true)
        end

        if cc.FileUtils:getInstance():isFileExist("pub/changeRelease.lua") then
            require "pub.changeRelease"
        end
    end
elseif DEBUG < 3 then
    DEBUG = 2
    CC_SHOW_FPS = true
    BOLE_USE_UPDATE_FILE = false
    BOLE_USE_SQLITE = false
    BOLE_UPDATE_FILE_ING = false
    if cc.FileUtils:getInstance():isFileExist("selfUpdate.lua") then
        require "selfUpdate"
    end

    if BOLE_TEST_USER then
        local target = cc.Application:getInstance():getTargetPlatform()
        if target == 3 then
            cc.FileUtils:getInstance():addSearchPath("/sdcard/.momo.bole.wolf", true)
        end

        if cc.FileUtils:getInstance():isFileExist("pub/changeRelease.lua") then
            require "pub.changeRelease"
        end
    end

    if BOLE_USE_UPDATE_FILE and not BOLE_USE_SQLITE then
        BOLE_USE_SQLITE = true
    end

    if not BOLE_USE_SQLITE then
        local db = cc.DbManage:getInstance()
        if db then
            db:release()
            cc.DbManage:setInstance()
        end
    end
end
release_print("#game mode end=" .. DEBUG .. ",userStatus=" .. tostring(BOLE_TEST_USER))




local function commonFunc()
    setAutoScale(CC_DESIGN_RESOLUTION)

    require "cocos.cocos2d.json"
    require "network.Network"
    Socket:create()
    bole.socket = Socket

    local entry = require "app.controls.ErrorLogControl"
    entry:create()
end

local function updateSuccess()
    release_print("#updategameend#")
    cc.FileUtils:getInstance():purgeCachedEntries()
    require "cocos.init"
    require "bole"

    if DEBUG > 0 and DEBUG < 3 then
        if cc.FileUtils:getInstance():isFileExist("selfConfig.lua") then
            require "selfConfig"
        end
    end

    cc.loadLua("app.MyApp"):create()
end

local main
if BOLE_USE_UPDATE_FILE then
    main = function()
        commonFunc()

        local update = require "Update"
        update:create()
        update:start(updateSuccess)
    end
else
    main = function()
        commonFunc()

        updateSuccess()
    end
end

__G__TRACKBACK__ = function(msg)
    local msg = debug.traceback(msg, 3)
    release_print("#[LUA ERROR]#" .. msg)
    bole.showMessageBox(msg, "[LUA ERROR]")
    return msg
end

local status, msg = xpcall(main, __G__TRACKBACK__)
if not status then
    release_print(msg)
end
