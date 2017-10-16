--region *.lua
--Date
--此文件由[BabeLua]插件自动生成

local Theme_sea = class("Theme_sea", bole:getTable("app.theme.BaseTheme"))

function Theme_sea:ctor(themeId, app)
    print("Theme_sea:ctor")
    Theme_sea.super.ctor(self, themeId, app)
    self.closeFiveKind = true
end

function Theme_sea:onDataFilter(data)
    print("Theme_sea:onDataFilter")
    Theme_sea.super.onDataFilter(self, data)
    self.bigAnimPos = data.icon_positions
    self.bigAnimId = data.superstacks_iconid
end

function Theme_sea:onPlayBigAnim(data)
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
    local layoutSize = cc.size(layoutWidth, self.matrix.cell_size[2]*3+70)
    layout:setContentSize(layoutSize)
    layout:setAnchorPoint(cc.p(0.5, 0.5))
    layout:setPosition(layoutPos.x+layoutSize.width/2, layoutPos.y+layoutSize.height/2)
    layout:setClippingEnabled(true)
    self:getAnimLayer(false):addChild(layout)

    local position = self:getSpinPositionByPos(centerColumn, 2, true)
    position.x = position.x - layoutPos.x
    position.y = position.y - layoutPos.y

    local imgName = self:getImgById(self.bigAnimId)
    local skeletonNode = self:genSkeletonNodeById(self.bigAnimId, "fusion")
    skeletonNode:setPosition(position.x, position.y)
    layout:addChild(skeletonNode)
    skeletonNode:setAnimation(1, skeletonNode.fusion, true)

    local floatNode = sp.SkeletonAnimation:create(self.app:getSymbolAnim(self.themeId, "bianhua"))
    floatNode:setPosition(position.x, position.y)
    layout:addChild(floatNode)
    floatNode:setAnimation(1, "animation1", false)
    floatNode:registerSpineEventHandler(function(event)
        floatNode:setVisible(false)
    end , sp.EventType.ANIMATION_COMPLETE)

    local isNeedRemove = false
    skeletonNode:registerSpineEventHandler(function(event)
        if event.animation == skeletonNode.fusion then
            if isNeedRemove then
                skeletonNode:clearTracks()
                local function callback()
                    layout:removeFromParent(true)
                    self:onPlayBigAnimEnd()
                end
                layout:runAction(cc.Sequence:create(cc.FadeOut:create(0.25), cc.CallFunc:create(callback)))
            end
        end
    end , sp.EventType.ANIMATION_COMPLETE)

    local function playBigAnimEnd()
        isNeedRemove = true
    end
    self:addWaitEvent("playBigAnimEnd", 3, playBigAnimEnd)

    local frameNamePart = string.sub(imgName, 1, 6)
    local topStr = self.app:getRes(self.themeId, string.format("bigAnimFrame/%s_top.png", frameNamePart))
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

    local leftStr = self.app:getRes(self.themeId, string.format("bigAnimFrame/%s_left.png", frameNamePart))
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

    bole:autoOpacityC(layout)
    layout:setOpacity(0)
    layout:setScale(0.85)
    layout:runAction(cc.Spawn:create(cc.ScaleTo:create(0.2, 1), cc.FadeIn:create(0.2)))
    bole:getAudioManage():playBigSymbol()
end

function Theme_sea:onPlayBigAnimEnd(data)
    local eventName = "playBigAnim"
    self.curStepName = eventName
    self:onNext()
end

function Theme_sea:addListeners()
    Theme_sea.super.addListeners(self)
    self:addListenerForNext("popupDialog", self.onPlayBigAnim)
    self:addListenerForNext("playBigAnim", self.onMiniEffect)
end

function Theme_sea:addOtherAsyncImage(weights)
    table.insert(weights, self.app:getSymbolAnimImg(self.themeId, "bianhua"))
end

return Theme_sea

--endregion
