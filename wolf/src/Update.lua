local Update = {}
local UpdateLoadView = {}

local KEY_OF_VERSION = "verCode"
local KEY_OF_SQLPATH = "sqlCode"
local KEY_OF_BRANCH_TAG = "branchTag"
CDNSERVERURL = "http://d105xpbtjj9cjp.cloudfront.net/bolegames/wolf/"
local TEST_VERSION_SUFFIX = "test_"
local VERSION_FILE_NAME = "version_record.txt"
VERSION_TABLE_NAME = "vercurrent"
local THEME_TABLE_NAME = "themecurrent"
local KEY_OF_OWN_THEME = "themePackage"


function Update:create()
    print("Update:create")
    self:init()
    UpdateLoadView:createView()
end

function Update:init()
    print("Update:init")
    self.writablePath = cc.FileUtils:getInstance():getWritablePath()
    self:setVersion()
end

function Update:start(callback)
    print("Update:start")
    self.updateSuccessCallback = callback
    self:checkAssetsUpdate()
end

function Update:downloadFile(fileUrl, isDownLoadFile, callback)
    print("Update:downloadFile=" .. fileUrl)
    local downLoad
    if not isDownLoadFile then
        downLoad = cc.DownLoadFile:create(CDNSERVERURL .. fileUrl)
    else
        downLoad = cc.DownLoadFile:create(CDNSERVERURL .. fileUrl, self.writablePath .. fileUrl)
    end

    local function downloadCallback(eventCode, content)
        if eventCode == 0 then --createfile fail
            callback("error")
        elseif eventCode == 1 then --network fail
            callback("error")
        elseif eventCode == 4 then --prograss
            callback("progress", content)
        elseif eventCode == 5 then --获得内容
            callback("success", content)
        elseif eventCode == 6 then --下载成功
            print("Update:downloadFile ok=" .. content)
            callback("success", content)
        end
    end
    
    downLoad:addEventListener(downloadCallback)
    downLoad:startUpdate()
end

function Update:checkAssetsUpdate()
    local versionName = VERSION_FILE_NAME
    if BOLE_TEST_USER then
        versionName = TEST_VERSION_SUFFIX .. versionName
    end
    print("Update:checkAssetsUpdate=" .. versionName)

    self:downloadFile(versionName, false, function(code, content)
        if code == "success" then
            print("download version_record.txt content=" .. content)
            content = json.decode(content)
            local onlineVersion = content['version']
            if onlineVersion == self.curVersionNum then
--                self:enterGame()
                UpdateLoadView:sameVerToLogin()
            else
                self:setOnlineVersion(onlineVersion, content['sql'], content["tag"])
                self:downLoadVersionSql()
            end
        else
            --???无法下载
        end
    end)
end

function Update:downLoadVersionSql()
    print("Update:downLoadVersionSql ,onlineSqlPath=" .. self.onlineSqlPath .. ",version=" .. self.onlineVersion)
    if not cc.FileUtils:getInstance():isFileExist(self.writablePath .. self.onlineSqlPath) then
        UpdateLoadView:startDownLoadSqlFile()
        self:downloadFile(self.onlineSqlPath, true, function(code, content)
            if code == "success" then
                self:startUpdateCommonAssets(false)
            elseif code == "progress" then
                UpdateLoadView:downLoadSqlProgress(content)
            else
                --???无法下载
            end
        end)
    else
        self:startUpdateCommonAssets(true)
    end
end

function Update:startUpdateCommonAssets(isOldDownLoaded)
    local oldDb = cc.DbManage:getInstance()
    local newDb = cc.DbManage:create(self.writablePath .. self.onlineSqlPath, VERSION_TABLE_NAME)

    local themeSelect = ""
    local packageThemeNum = cc.UserDefault:getInstance():getStringForKey(KEY_OF_OWN_THEME, "")
    if packageThemeNum ~= "" then
        themeSelect = string.format("themeTag=%s or", packageThemeNum)
    end

    local selectSql
    if isOldDownLoaded then
        selectSql = string.format("SELECT key, url FROM %s WHERE %s (loadType='0' AND themeTag=0);", VERSION_TABLE_NAME, themeSelect, themeSelect)
    else
        selectSql = string.format("SELECT key, url FROM %s WHERE %s themeTag=0;", VERSION_TABLE_NAME, themeSelect)
    end

    local assetsUpdate = cc.AssetsUpdate:createDownLoadDiffFiles(CDNSERVERURL, oldDb, newDb, VERSION_TABLE_NAME, selectSql)

    local function allEnd()
        assetsUpdate:release()
        self:writeVersion()
        UpdateLoadView:updateFileEnd()
--        self:enterGame()
    end
    local function downloadCallback(eventCode, content)
        if eventCode == 0 then --createfile fail
            
        elseif eventCode == 1 then --network fail
            
        elseif eventCode == 4 then --prograss
        elseif eventCode == 6 then --下载成功
            print("startUpdateCommonAssets update file=" .. content)
            newDb:setItem(content, "1")
            UpdateLoadView:downloadOneFile()
        elseif eventCode == 7 then --下载成功所有的文件
            allEnd()
        elseif eventCode == 8 then --下载失败超过三次被停了 网络原因
        elseif eventCode == 9 then --下载失败超过三次被停了 文件创建失败原因
        end
    end
    assetsUpdate:addEventListener(downloadCallback)

    self.onlineDb = newDb
    self.oldDb = oldDb

    local num = assetsUpdate:startUpdate()
    if num == 0 then
        allEnd()
    else
        UpdateLoadView:startDownLoadAssets(num)
    end
end

function Update:setOnlineVersion(version, path, tag)
    self.onlineVersion = version
    self.onlineSqlPath = path
    self.onlineTag = tag
end

function Update:setVersion()
    local instance = cc.UserDefault:getInstance()
    self.curVersionNum = instance:getIntegerForKey(KEY_OF_VERSION)
    self.curSqlPath = instance:getStringForKey(KEY_OF_SQLPATH)
    cc.AppInfo:setValue("version", tostring(self.curVersionNum))
    cc.AppInfo:setValue(KEY_OF_BRANCH_TAG, instance:getStringForKey(KEY_OF_BRANCH_TAG, "0"))
    print("Update:setVersion, curVersionNum=" .. self.curVersionNum .. ", curSqlPath=" .. self.curSqlPath)
end

function Update:writeVersion()
    print("Update:writeVersion")
    self.curVersionNum = self.onlineVersion
    self.curSqlPath = self.onlineSqlPath
    local instance = cc.UserDefault:getInstance()
    instance:setIntegerForKey(KEY_OF_VERSION, self.onlineVersion)
    instance:setStringForKey(KEY_OF_SQLPATH, self.onlineSqlPath)
    instance:setStringForKey(KEY_OF_BRANCH_TAG, self.onlineTag)
    instance:flush()
end

function Update:enterGame()
    print("Update:enterGame")
    if self.onlineDb then
        cc.DbManage:setInstance(self.onlineDb)
        cc.AppInfo:setValue("version", tostring(self.onlineVersion))
        cc.AppInfo:setValue(KEY_OF_BRANCH_TAG, self.onlineTag)

        self.onlineDb = nil
        if self.oldDb then
            self.oldDb:release()
            self.oldDb = nil
        end
    end

    cc.AppInfo:initDbThemeValue()
    local userDefault = cc.UserDefault:getInstance()
    local packageThemeNum = userDefault:getStringForKey(KEY_OF_OWN_THEME, "")
    if packageThemeNum ~= "" then
        userDefault:deleteValueForKey(KEY_OF_OWN_THEME)
        local versionmd5 = cc.AppInfo:getThemeValue(tonumber(packageThemeNum))
        userDefault:setStringForKey(string.format("theme%s", packageThemeNum), versionmd5)
        userDefault:flush()
    end

    if self.updateSuccessCallback then
        self.updateSuccessCallback()
    end
end




local CHECK_VERSION_WEIGHT = 30
local DOWNLOAD_SQL_WEIGHT = 20
local UPDATE_FILES_WEIGHT = 30
local CONNECT_SOCKET_WEIGHT = 90
local LOGIN_GAME_WEIGHT = 100
function UpdateLoadView:createView()
    print("UpdateLoadView:createView")
    local scene = cc.Scene:create()
    local rootNode = cc.CSLoader:createNodeWithVisibleSize("loading/loadingView.csb")
    scene:addChild(rootNode)
    if cc.Director:getInstance():getRunningScene() then
        cc.Director:getInstance():replaceScene(scene)
    else
        cc.Director:getInstance():runWithScene(scene)
    end

    local loadingBar = rootNode:getChildByName("barbg"):getChildByName("bar")
    loadingBar:setPercent(0)

    self.curMaxProgress = CHECK_VERSION_WEIGHT
    self.curProgress = 0
    self.addProgress = 0.2
    self.curFiles = 0

    local function update(dt)
        if self.curProgress < self.curMaxProgress then
            self.curProgress = self.curProgress + self.addProgress
            if self.curProgress >= 98 then
            else
                loadingBar:setPercent(self.curProgress)
            end
        end
    end
    rootNode:scheduleUpdateWithPriorityLua(update, 0)

    rootNode:registerScriptHandler(function(state)
        if state == "exit" then
            self:onExit()
        end
    end)
end

function UpdateLoadView:onExit()
    print("UpdateLoadView:onExit")
    if bole then
        if bole.removeListener then
            bole:removeListener("socketConnectOk", self)
            bole:removeListener("loginGameSuccess", self)
            bole:removeListener("sendMsgError", self)
        end
    end
end

function UpdateLoadView:startListener()
    print("UpdateLoadView:startListener")
    bole:addListener("socketConnectOk", self.onConnectOk, self, nil, true)
    bole:addListener("loginGameSuccess", self.onLoginSuccess, self, nil, true)
    bole:addListener("sendMsgError", self.onLoginError, self, nil, true)
end

function UpdateLoadView:onConnectOk()
    print("UpdateLoadView:onConnectOk")
    self.curMaxProgress = LOGIN_GAME_WEIGHT
    bole:getLoginControl():sendLoginMsg()
end

function UpdateLoadView:onLoginSuccess()
    print("UpdateLoadView:onLoginSuccess")
    BOLE_UPDATE_FILE_ING = false
    bole:getLoginControl():enterLobbyView()
end

function UpdateLoadView:onLoginError()
    print("UpdateLoadView:onLoginError")
    bole:getLoginControl():onLoginError()
end

function UpdateLoadView:startDownLoadSqlFile()
    print("UpdateLoadView:startDownLoadSqlFile")
    self.addProgress = 0.2
end

function UpdateLoadView:sameVerToLogin()
    print("UpdateLoadView:sameVerToLogin")
    self.addProgress = (LOGIN_GAME_WEIGHT-self.curProgress)/100
    self.curMaxProgress = CONNECT_SOCKET_WEIGHT
    
    self:startLogin()
end

function UpdateLoadView:updateFileEnd()
    print("UpdateLoadView:updateFileEnd")
    self.addProgress = (LOGIN_GAME_WEIGHT-self.curProgress)/100
    self.curMaxProgress = CONNECT_SOCKET_WEIGHT

    self:startLogin()
end

function UpdateLoadView:startLogin()
    print("UpdateLoadView:startLogin")
    BOLE_UPDATE_FILE_ING = true
    Update:enterGame()
    self:startListener()
end

function UpdateLoadView:downLoadSqlProgress(percent)
    self.curMaxProgress = CHECK_VERSION_WEIGHT + (DOWNLOAD_SQL_WEIGHT * percent * 0.01)
end

function UpdateLoadView:startDownLoadAssets(sumCount)
    print("UpdateLoadView:startDownLoadAssets sumCount=" .. sumCount)
    self.curFiles = 0
    local curMax = CHECK_VERSION_WEIGHT + DOWNLOAD_SQL_WEIGHT + UPDATE_FILES_WEIGHT
    self.oneFileProgress = (curMax-self.curProgress)/sumCount
    self.addProgress = self.oneFileProgress/20
end

function UpdateLoadView:downloadOneFile()
    self.curFiles = self.curFiles + 1
    self.curMaxProgress = CHECK_VERSION_WEIGHT + DOWNLOAD_SQL_WEIGHT + self.curFiles*self.oneFileProgress
end


return Update







--function Update:checkCurVersion()
--    local instance = cc.UserDefault:getInstance()
--    local curVersion = instance:getIntegerForKey(KEY_OF_VERSION, -1)
--    if curVersion == -1 then
--        self:startGameForFirstTime()
--    else
--        local sqlPath = instance:getStringForKey(KEY_OF_SQLPATH)
--        if string.len(sqlPath) > 0 and cc.FileUtils:getInstance():isFileExist(self.writablePath .. sqlPath) then
--            self:setVersion(curVersion, sqlPath)
--        else
--            self:startGameForFirstTime()
--        end
--    end
--end

--第一次登陆游戏需要做的初始化操作
--如果后面有些文件发现异常也可以按第一次进入游戏去做处理
--1，读自带的版本文件，设置版本号和版本库路径
--2，拷贝版本库文件到可写目录
--function Update:startGameForFirstTime()
--    local fileInstance = cc.FileUtils:getInstance()

--    local fileData = fileInstance:getStringFromFile("pub/version_record.txt")
--    local content = json.decode(fileData)

--    local versionNum = content["version"]
--    local sqlPath = content["sql"]

--    local isWriteOk = fileInstance:copyFile(sqlPath, self.writablePath .. sqlPath)

--    self:writeVersion(versionNum, sqlPath)
--    self:setVersion(versionNum, sqlPath)

--    if not isWriteOk then
--        --closeGame ???
--        print("Error : write sqlfile to writable path failed ..........")
--    end
--end