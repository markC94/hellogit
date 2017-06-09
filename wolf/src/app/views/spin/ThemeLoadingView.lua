--region *.lua
--Date
--此文件由[BabeLua]插件自动生成
local ThemeLoadingView = class("ThemeLoadingView", cc.Layer)
function ThemeLoadingView:ctor(theme)
    self.theme = theme
    self.themeId = theme:getThemeId()
    self:onTouch(function() return true end, false, true)

    local rootNode = cc.CSLoader:createNodeWithVisibleSize("csb/LoadingView.csb")
    self:addChild(rootNode)

    self.loadingBar = rootNode:getChildByName("barBg"):getChildByName("bar")
    self.rootNode = rootNode

    self.loadingBar:setPercent(0)
    self:asyncLoadRes()
    self:enableNodeEvents()
end

function ThemeLoadingView:onEnter()
    self.isDead = false
    bole:addListener("enterThemeData", self.enterThemeData, self, nil, true)
end

function ThemeLoadingView:onExit()
    bole:removeListener("enterThemeData", self)
    self.isDead = true
end

function ThemeLoadingView:setAsyncImageWeight()
    local weights = {}
    local symbolKey = string.format("theme/theme%d/symbols.png", self.themeId)
    table.insert(weights, symbolKey)

    local tag = self.theme:getThemeName() .. "_symbol"
    local configData = bole:getConfig(tag)
    for _, item in pairs(configData) do
        for key, value in pairs(item) do
            if string.find(key, "_project") and value ~= "" then
                local filePath = string.format("theme/theme%s/symbolAnimal/%s.png", self.themeId, value)
                table.insert(weights, filePath)
            end
        end
    end
    self.theme:addOtherAsyncImage(weights)
    self.asyncImageWeights = weights
    self.theme:setCachedRes(weights)
end

function ThemeLoadingView:asyncLoadRes()
    self:setAsyncImageWeight()

    self.loadedWeight = 0  --已经完成了的权重
    self.loadedAsyncImageIndex = 0
    local sumWeight = #self.asyncImageWeights
    self.serverWeight = sumWeight/4  --请求到服务端的数据，占总权重的30%
    self.sumWeight = sumWeight + self.serverWeight

    local elaspedTime = 0
    local function update(dt)
        if self.loadedAsyncImageIndex < sumWeight then
            self:dealAsynImagePerFrame()
        end
        elaspedTime = elaspedTime + dt
        if elaspedTime > 5 then
            self:unscheduleUpdate()

            local function startCalTimeForBackLobby()
                bole:postEvent("enterLobby")
            end
            bole:popMsg({msg = "数据连接出错了，请重试。", title = "提示"}, startCalTimeForBackLobby)
        end
    end
    self:onUpdate(update)
end

function ThemeLoadingView:dealAsynImagePerFrame()
    local index = self.loadedAsyncImageIndex
    local images = self.asyncImageWeights

    local len = #images
    local function loadSymbolSuccess()
        self:addImageCallback(1)
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
    if self.isDead then return end

    self.loadedWeight = self.loadedWeight + weight
    local rate = self.loadedWeight/self.sumWeight
    if rate > 0.9 and not self.runThemeOk and self.enterThemeData then
        self.runThemeOk = true
        self.theme:displayTheme(self.enterThemeData)
    end
    self.loadingBar:setPercent(rate*100)
    if rate > 0.99 then
        self:removeFromParent(true)
    end
end

function ThemeLoadingView:enterThemeData(event)
    self.enterThemeData = event.result
    self:addImageCallback(self.serverWeight)
end

return ThemeLoadingView
--endregion
