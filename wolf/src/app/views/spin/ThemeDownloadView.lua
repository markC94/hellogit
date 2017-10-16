--region *.lua
--Date
--此文件由[BabeLua]插件自动生成
local ThemeDownloadView = class("ThemeDownloadView", cc.Layer)
function ThemeDownloadView:ctor(theme, endbackFunc)
    self.theme = theme
    self.endbackFunc = endbackFunc

    self:onTouch(function() return true end, false, true)
    self:enableNodeEvents()
    self:onEnter()

    local rootNode = cc.CSLoader:createNodeWithVisibleSize("themeInViews/loading/loadingView.csb")
    self:addChild(rootNode)

    local loadingNode = rootNode:getChildByName("barbg")
    local loadingBar = loadingNode:getChildByName("bar")
    loadingBar:setPercent(0)

    self.curMaxProgress = 5
    self.addProgressValue = 0.3
    self.curProgress = 0
    local startFlag = true
    local function update(dt)
        if self.curProgress < self.curMaxProgress then
            local curProgress = self.curProgress + self.addProgressValue
            local flag = false
            if curProgress > 99.99 then
                if self.curMaxProgress > 99.99 then
                    self.curProgress = 100
                    flag = true
                end
            else
                self.curProgress = curProgress
                flag = true
            end

            if flag then
                loadingBar:setPercent(self.curProgress)
            end
        end

        if startFlag and self.curProgress > self.addProgressValue then
            startFlag = false
            self:updateThemeFiles()
        end
    end
    self:onUpdate(update)
end

function ThemeDownloadView:enterThemeDataFunc(event)
    self.enterThemeData = event.result
end

function ThemeDownloadView:onEnter()
    if self.isAlive then return end

    self.isAlive = true
    bole:getBoleEventKey():addKeyBack(self)
    bole:addListener("enterThemeData", self.enterThemeDataFunc, self)
end

function ThemeDownloadView:onExit()
    bole:removeListener("enterThemeData", self)
    bole:getBoleEventKey():removeKeyBack(self)
    self.isAlive = false
end

function ThemeDownloadView:onKeyBack()
end

function ThemeDownloadView:updateThemeFiles()
    local function downloadFunc(result)
        if not self.isAlive then return end

        if result == "all" then
            local func = self.endbackFunc
            local theme = self.theme
            local data = self.enterThemeData

            self:removeFromParent(true)

            if func then
                func(theme, data)
            end
        else
            self:addImageCallback()
        end
    end

    local num = bole:getSpinApp():checkThemeFiles(self.theme:getThemeId(), downloadFunc)
    self.sumWeight = num
    self.eachProgress = 100/num
    self.loadedWeight = 0
    print("need update files, the count is " .. num)
end

function ThemeDownloadView:addImageCallback()
    self.loadedWeight = self.loadedWeight + 1
    local curMax = self.loadedWeight*self.eachProgress

    local subProgress = curMax - self.curProgress
    if subProgress > 15 then
        self.addProgressValue = subProgress/5
    elseif subProgress < 2 then
        self.addProgressValue = 0.3
    end

    self.curMaxProgress = curMax
    print("update files, downloadfile num=" .. self.loadedWeight)
end

return ThemeDownloadView
--endregion
