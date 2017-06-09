--region *.lua
--Date
--此文件由[BabeLua]插件自动生成

local Theme_Sea = class("Theme_Sea", bole:getTable("app.theme.BaseTheme"))

function Theme_Sea:ctor(themeId, app)
    print("Theme_Sea:ctor")
    Theme_Sea.super.ctor(self, themeId, app)
end

function Theme_Sea:enterThemeDataFilter(data)
    print("Theme_Sea:enterThemeDataFilter")
    Theme_Sea.super.enterThemeDataFilter(self, data)
end

function Theme_Sea:onDataFilter(data)
    print("Theme_Sea:onDataFilter")
    Theme_Sea.super.onDataFilter(self, data)
    self.bigAnimPos = data.icon_positions
    self.bigAnimId = data.superstacks_iconid
end

function Theme_Sea:onPlayBigAnim(data)
    if not self.bigAnimId or not self.bigAnimPos or #self.bigAnimPos < 9 then 
        self:onPlayBigAnimEnd()
        return
    end

    local columnRecords = {}
    local columnIndexs = {}
    for _, pos in ipairs(self.bigAnimPos) do
        local column = pos[2]
        if not columnRecords[column] then
            table.insert(columnIndexs, column)
            columnRecords[column] = true
        end
    end

    local centerColumn = 3
    local startColumnIndex = 1
    local endColumnIndex = 5
    if #columnIndexs == 3 then
        if columnRecords[1] then
            centerColumn = 2
            startColumnIndex = 1
        elseif columnRecords[5] then
            centerColumn = 4
            startColumnIndex = 3
        else
            startColumnIndex = 2
        end
        endColumnIndex = startColumnIndex + 2
    elseif #columnIndexs == 4 then
        if columnRecords[1] then
            startColumnIndex = 1
        else
            startColumnIndex = 2
        end
        endColumnIndex = startColumnIndex + 3
    end
    
    local startPosX = self.matrix.coordinate[startColumnIndex].x - self.matrix.cell_size[1]/2
    local endPosx = self.matrix.coordinate[endColumnIndex].x + self.matrix.cell_size[1]/2
    local layoutPos = cc.p(startPosX, -10)
    local layoutWidth = endPosx - startPosX

    local layoutBottomY = self.matrix.coordinate[centerColumn].y - layoutPos.y - 1
    local layoutTopY = layoutBottomY + self.matrix.cell_size[2]*3 + 2
    
    local layout = ccui.Layout:create()
    layout:setContentSize(cc.size(layoutWidth, self.matrix.cell_size[2]*3+55))
    layout:setPosition(layoutPos.x, layoutPos.y)
    layout:setClippingEnabled(true)
    self.animNode:addChild(layout)

    local position = self:getSpinPositionByPos(centerColumn, 2, true)
    position.x = position.x - layoutPos.x
    position.y = position.y - layoutPos.y

    local imgName = self:getImgById(self.bigAnimId)
    local skeletonNode = self:getSkeletonNodeById(self.bigAnimId, "fusion")
    skeletonNode:setPosition(position.x, position.y)
    layout:addChild(skeletonNode)
    skeletonNode:setAnimation(1, skeletonNode.fusion, true)

    local isNeedRemove = false
    skeletonNode:registerSpineEventHandler(function(event)
        if event.animation == skeletonNode.fusion then
            if isNeedRemove then
                local function removeAndStartNext()
                    layout:removeFromParent(true)
                    self:onPlayBigAnimEnd()
                end
                self:addWaitEvent("removeAndStartNext", 0.001, removeAndStartNext)
                layout:setVisible(false)
            end
        end
    end , sp.EventType.ANIMATION_COMPLETE)

    local function playBigAnimEnd()
        isNeedRemove = true
    end
    self:addWaitEvent("playBigAnimEnd", 3, playBigAnimEnd)

    local frameNamePart = string.sub(imgName, 1, 6)
    local topStr = string.format("theme/theme%s/bigAnimFrame/%s_top.png", self.themeId, frameNamePart)
    if cc.FileUtils:getInstance():isFileExist(topStr) then
        local topSp = cc.Sprite:create(topStr)
        layout:addChild(topSp)
        topSp:setAnchorPoint(cc.p(0, 1))
        topSp:setPosition(0, layoutTopY)

        local btSp = cc.Sprite:create(topStr)
        btSp:setFlippedY(true)
        layout:addChild(btSp)
        btSp:setAnchorPoint(cc.p(0, 0))
        btSp:setPosition(0, layoutBottomY)

        local scaleX = layoutWidth/topSp:getContentSize().width
        topSp:setScaleX(scaleX)
        btSp:setScaleX(scaleX)
    end

    local leftStr = string.format("theme/theme%s/bigAnimFrame/%s_left.png", self.themeId, frameNamePart)
    if frameNamePart ~= "sea_h1" or startColumnIndex ~= 1 or (startColumnIndex == 1 and centerColumn == 2) then
        local lfSp = cc.Sprite:create(leftStr)
        layout:addChild(lfSp)
        lfSp:setAnchorPoint(cc.p(0, 0.5))
        lfSp:setPosition(0, position.y)
    end

    if frameNamePart ~= "sea_h1" or endColumnIndex ~= 5 or (endColumnIndex == 5 and centerColumn == 4) then
        local rtSp = cc.Sprite:create(leftStr)
        rtSp:setFlippedX(true)
        layout:addChild(rtSp)
        rtSp:setAnchorPoint(cc.p(1, 0.5))
        rtSp:setPosition(endPosx-startPosX, position.y)
    end
end

function Theme_Sea:onPlayBigAnimEnd(data)
    local eventName = "playBigAnim"
    self.curStepName = eventName
    self:onNext()
end

function Theme_Sea:setFreeSpinPosition(x, y)
    y = y - 23
    Theme_Sea.super.setFreeSpinPosition(self, x, y)
end

function Theme_Sea:addListeners()
    Theme_Sea.super.addListeners(self)
--    self:addListenerForNext("popupDialog", self.onMiniEffect)
    self:addListenerForNext("popupDialog", self.onPlayBigAnim)
    self:addListenerForNext("playBigAnim", self.onMiniEffect)
end

return Theme_Sea

--endregion
