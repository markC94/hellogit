--region *.lua
--Date
--此文件由[BabeLua]插件自动生成
local ThemeLoadingView = class("ThemeLoadingView", cc.Layer)
function ThemeLoadingView:ctor(theme, themeData)
    self.theme = theme
    self.enterThemeData = themeData
    self.serverWeight = 0
    self:onTouch(function() return true end, false, true)

--    local ss = cc.Director:getInstance():getTextureCache():getCachedTextureInfo()
--    print(ss)

    local rootNode = cc.CSLoader:createNodeWithVisibleSize("themeInViews/loading/loadingView.csb")
    self:addChild(rootNode)

    self.loadingBar = rootNode:getChildByName("barbg"):getChildByName("bar")
    self.rootNode = rootNode
    
    self.loadingBar:setPercent(0)
    self:enableNodeEvents()
    self:onEnter()

    self:initView()
    self:asyncLoadRes()
end

function ThemeLoadingView:initView()
    local rootNode = self.rootNode
    local app = self.theme:getSpinApp()
    local themeId = self.theme:getThemeId()

    local bgSp = rootNode:getChildByName("bg")
    local bgImageName = app:getRes(themeId, string.format("%s_loading_bg", app:getThemeName(themeId)), "png")
    if cc.FileUtils:getInstance():isFileExist(bgImageName) then
        bgSp:setTexture(bgImageName)
        self.bgImageName = bgImageName
    end

    local iconNode = rootNode:getChildByName("iconNode")
    local iconImageName = app:getRes(themeId, string.format("%s_loading_icon", app:getThemeName(themeId)), "png")
    if cc.FileUtils:getInstance():isFileExist(iconImageName) then
        local iconSp = cc.Sprite:create(iconImageName)
        iconSp:setAnchorPoint(cc.p(0.5, 0))
        iconNode:addChild(iconSp)
        self.iconImageName = iconImageName
    end
end

function ThemeLoadingView:onKeyBack()
   
end

function ThemeLoadingView:onEnter()
    if self.isAlive then return end

    self.isAlive = true
    bole:getBoleEventKey():addKeyBack(self)
    bole:addListener("enterThemeData", self.enterThemeDataFunc, self, nil, true)
    bole:addListener("newbieStepForNoExp", self.newbieStepForNoExp, self, nil, true)
end

function ThemeLoadingView:onExit()
    bole:getBoleEventKey():removeKeyBack(self)
    bole:removeListener("enterThemeData", self)
    bole:removeListener("newbieStepForNoExp", self)
    self.isAlive = false
end

function ThemeLoadingView:setAsyncImageWeight()
    cc.Director:getInstance():getTextureCache():removeUnusedTextures()

    local app = self.theme:getSpinApp()
    local themeId = self.theme:getThemeId()

    local weights = {}
    table.insert(weights, app:getSymbol(themeId))
    table.insert(weights, app:getSymbolAnimImg(themeId, "kuang"))
    if self.bgImageName then
        table.insert(weights, self.bgImageName)
    end
    if self.iconImageName then
        table.insert(weights, self.iconImageName)
    end
    table.insert(weights, "util_act/win.png")
    for i=1,16 do
         table.insert(weights, string.format("5ofkindeffect/diguang/diguang_000%02d.png",i))
    end
    local setCheck = {}
    local configData = self.theme:getItemById()
    for _, item in pairs(configData) do
        for key, value in pairs(item) do
            if string.find(key, "_project") and (not setCheck[value]) then
                setCheck[value] = true
                table.insert(weights, app:getSymbolAnimImg(themeId, value))
            end
        end
    end

    local promptConfig = app:getConfig(themeId, "prompt")
    if promptConfig then
        for _, item in pairs(promptConfig) do
            local value = item.prompt_resource
            if value and (not setCheck[value]) then
                setCheck[value] = true
                table.insert(weights, app:getSymbolAnimImg(themeId, value))
            end
        end
    end

    self.theme:addOtherAsyncImage(weights)
    self.asyncImageWeights = weights
    self.theme:setCachedRes(weights)

    self.loadedWeight = 0  --已经完成了的权重
    self.loadedAsyncImageIndex = 0
    local sumWeight = #weights
    self.serverWeight = sumWeight/4  --请求到服务端的数据，占总权重的20%
    self.sumWeight = sumWeight + self.serverWeight
end

function ThemeLoadingView:asyncLoadRes()
    local elaspedTime = 0
    local function update(dt)
        if not self.asyncImageWeights then
            self:setAsyncImageWeight()
        end

        if self.enterThemeData and self.serverWeight > 0 then
            self:addImageCallback(self.serverWeight)
            self.serverWeight = 0
        elseif self.loadedAsyncImageIndex < #self.asyncImageWeights then
            self:dealAsynImagePerFrame()
        end

        elaspedTime = elaspedTime + dt
        if elaspedTime > 30 then
            self:unscheduleUpdate()
            local function startCalTimeForBackLobby()
                bole:postEvent("enterLobby", true)
            end
            bole:popMsg({msg = "Data connection is wrong, please try again.", title = "tips"}, startCalTimeForBackLobby)
        end
    end
    self:onUpdate(update)
end

function ThemeLoadingView:dealAsynImagePerFrame()
    local index = self.loadedAsyncImageIndex
    local images = self.asyncImageWeights

    local len = #images
    local function loadSymbolSuccess()
        if self.isAlive then
            self:addImageCallback(1)
        end
    end
    for i = index + 1, index + 4 do
        if i > len then
            break
        else
            cc.Director:getInstance():getTextureCache():addImageAsync(images[i], loadSymbolSuccess)
            index = i
        end
    end

    self.loadedAsyncImageIndex = index
end

function ThemeLoadingView:addImageCallback(weight)
    self.loadedWeight = self.loadedWeight + weight
    local rate = self.loadedWeight/self.sumWeight*100
    self.loadingBar:setPercent(rate)
    if self.loadedWeight == self.sumWeight then
        self.theme:displayTheme(self.enterThemeData)
        if self.isNewbieStep then
            bole:postEvent("newbieStepPopup", {id = "noExp"})
        end
        self:removeFromParent(true)
    end
end

function ThemeLoadingView:enterThemeDataFunc(event)
    self.enterThemeData = event.result
    if self.serverWeight > 0 then
        self:addImageCallback(self.serverWeight)
        self.serverWeight = 0
    end
end

function ThemeLoadingView:newbieStepForNoExp(event)
    self.isNewbieStep = true
end

return ThemeLoadingView
--endregion
