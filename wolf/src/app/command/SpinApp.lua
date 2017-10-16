-- region *.lua
-- Date
-- 此文件由[BabeLua]插件自动生成
local THEMENAME = 
{
    "oz",
    "farm",
    "love",
    "mermaid",
    "sea",
    "gorilla",
    "jones",
    "longhorn"
}

local SpinApp = class("SpinApp")
function SpinApp:ctor()
end

function SpinApp:startTheme(themeId)
    print("SpinApp:startTheme themeId=" .. themeId)
    local themeTag = THEMENAME[themeId]
    self.theme = bole:getEntity(string.format("app.theme.Theme_%s", themeTag), themeId, self)
    self.theme:run()
end

function SpinApp:enterThemeData(data)
    self.theme:setThemeData(data)
end

function SpinApp:getTheme()
    return self.theme
end

function SpinApp:isThemeAlive()
    if self.theme and self.theme.isAlive then
        return true
    else
        return false
    end
end

function SpinApp:getThemeName(id)
    if not id then
        id = self.theme:getThemeId()
    end
    return THEMENAME[id]
end

function SpinApp:addMiniGame(view)
    self.theme:addMiniGame(view)
end

function SpinApp:addDialog()
    self.theme:addDialog(view)
end

function SpinApp:getRes(themeId, fileName, suffix)
    if not themeId then
        themeId = self.theme:getThemeId()
    end
    if suffix then
        return string.format("-theme%d/%s.%s", themeId, fileName, suffix)
    else
        return string.format("-theme%d/%s", themeId, fileName)
    end
end

function SpinApp:getSymbol(themeId)
    return self:getRes(themeId, "symbols", "png")
end

local configFindPath = "configs/%s_%s"
function SpinApp:getConfig(themeId, fileName, id, key)
    if not themeId then
        themeId = self.theme:getThemeId()
    end
    return bole:getConfig(self:getRes(themeId, string.format(configFindPath, THEMENAME[themeId], fileName)), id, key)
end

local symbolAnimFindPath = "symbolAnimal/"
function SpinApp:getSymbolAnim(themeId, fileName)
    local path = self:getRes(themeId, symbolAnimFindPath .. fileName)
    return path .. ".json", path .. ".atlas"
end

function SpinApp:getSymbolAnimImg(themeId, fileName)
    return self:getRes(themeId, symbolAnimFindPath .. fileName, "png")
end

local miniFindPath = "minigame/"
function SpinApp:getMiniRes(themeId, fileName)
    return self:getRes(themeId, miniFindPath .. fileName)
end

local soundFindPath = "sound/%s.mp3"
function SpinApp:getSound(themeId, fileName)
    if not themeId then
        if self.theme and self.theme.getThemeId then
            themeId = self.theme:getThemeId()
        end
    end

    local realSoundFile = string.format(soundFindPath, fileName)
    if not themeId then
        return realSoundFile
    end

    local themeSound = self:getRes(themeId, realSoundFile)
    if cc.FileUtils:getInstance():isFileExist(themeSound) then
        return themeSound
    else
        return realSoundFile
    end
end

function SpinApp:getDownloadedThemeVersion(themeId)
    local version = cc.UserDefault:getInstance():getStringForKey(string.format("theme%d", themeId), "")
    if version ~= "" then
        return version
    end
end

function SpinApp:recordThemeVersion(themeId)
    local instance = cc.UserDefault:getInstance()
    instance:setStringForKey(string.format("theme%d", themeId), cc.AppInfo:getThemeValue(themeId))
    instance:flush()
end

function SpinApp:removeThemeVersion(themeId)
    local instance = cc.UserDefault:getInstance()
    instance:deleteValueForKey(string.format("theme%d", themeId))
    instance:flush()
end

--是否使用更新
function SpinApp:isForbiddenUpdate()
    return not BOLE_USE_UPDATE_FILE
end

--当前这个主题是否已经下载过本地
function SpinApp:isThemeDownloaded(themeId)
    if self:isForbiddenUpdate() then
        return true
    end

    if self:getDownloadedThemeVersion(themeId) then
        return true
    else
        return false
    end
end

--当前是否可以下载到这个主题
function SpinApp:isThemeExist(themeId)
    if self:isForbiddenUpdate() then
        return true
    end

    if cc.AppInfo:getThemeValue(themeId) ~= "" then
        return true
    else
        return false
    end
end

--当前这个主题是否是最新的
function SpinApp:isThemeUpdated(themeId)
    if self:isForbiddenUpdate() then
        return true
    end

    local downloadVersion = self:getDownloadedThemeVersion(themeId)
    if downloadVersion and downloadVersion == cc.AppInfo:getThemeValue(themeId) then
        return true
    else
        return false
    end
end

--检查主题，并下载主题里更新的文件
function SpinApp:checkThemeFiles(themeId, callbackFunc)
    if self:isForbiddenUpdate() then
        callbackFunc("all")
        return 0
    end

    local downloadVersion = self:getDownloadedThemeVersion(themeId)
    if downloadVersion then
        local themeVersion = cc.AppInfo:getThemeValue(themeId)
        if themeVersion == downloadVersion then
            if callbackFunc then
                callbackFunc("all")
            end
            return 0
        else
            return self:downloadTheme(themeId, callbackFunc)
        end
    else
        return self:downloadTheme(themeId, callbackFunc)
    end
end

--下载主题最新的文件
function SpinApp:downloadTheme(themeId, callbackFunc)
    print("SpinApp:downloadTheme=" .. themeId)
    if self:isForbiddenUpdate() then
        callbackFunc("all")
    end

    local selectSql = string.format("SELECT key, url FROM %s WHERE themeTag=%d;", VERSION_TABLE_NAME, themeId)
    local assetsUpdate = cc.AssetsUpdate:createDownLoadThemeFiles(CDNSERVERURL, selectSql)

    local function allEnd()
        print("download themefile done themeId=" .. themeId)
        assetsUpdate:release()
        self:recordThemeVersion(themeId)
        if callbackFunc then
            callbackFunc("all")
        end
    end
    local function downloadCallback(eventCode, content)
        if eventCode == 0 then --createfile fail
        elseif eventCode == 1 then --network fail
        elseif eventCode == 4 then --prograss
        elseif eventCode == 6 then --下载成功
--            cc.DbManage:getInstance():setItem(content, "1")
            print(string.format("download themefile=%s,themeId=%d", content, themeId))
            if callbackFunc then
                callbackFunc(content)
            end
        elseif eventCode == 7 then --下载成功所有的文件
            allEnd()
        elseif eventCode == 8 then --下载失败超过三次被停了 网络原因
        elseif eventCode == 9 then --下载失败超过三次被停了 文件创建失败原因
        end
    end
    assetsUpdate:addEventListener(downloadCallback)

    local num = assetsUpdate:startUpdate()
    if num == 0 then
        allEnd()
    end
    return num
end

--删除主题
function SpinApp:removeTheme(themeId)
    print("SpinApp:removeTheme=" .. themeId)
    if self:isForbiddenUpdate() then
        return
    end

    local instance = cc.FileUtils:getInstance()
    local dirName = string.format("%spub/-theme%d/", instance:getWritablePath(), themeId)
    print("delete theme dir =" .. dirName)
    if instance:isDirectoryExist(dirName) then
        self:removeThemeVersion(themeId)
        instance:removeDirectory(dirName)
        return true
    end
    return false
end

return SpinApp
-- endregion
