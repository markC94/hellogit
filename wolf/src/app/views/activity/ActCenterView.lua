--region *.lua
--Date
--此文件由[BabeLua]插件自动生成
local ActCenterView = class("ActCenterView")

local space = 180
local pageWidth = 670
local pageHeight = 224
local zoom = 0.65
local stopTime = 2.5
local staticScrollTime = 1.5
local scrollNextTime = 0.5
local scrollProTime = 0.3
local scrollSpecialTime = 0.3

local scaleAnchor = cc.p(0.5,0.5)
local maxScrollAddPos = 300

local touchMoveDis = 15
local scrollMoveDis = 7

local actNum = 1
local backScrollTime = 2

function ActCenterView:ctor(pageViewNode)
    self.pageViewNode = pageViewNode
    self.control = bole:getActCenter()
    actNum = self.control:getActCount()
    backScrollTime = 0.5 / 3 * (actNum - 2) + staticScrollTime
    self.pageView = ccui.Layout:create()
    self.pageView:setContentSize( { width = pageWidth * actNum + (actNum - 1) * space, height = pageHeight })
    self.pageView:setPosition(0,0)
    pageViewNode:addChild(self.pageView)
    self:createUpdate()
    self:addPage()
    self:addTouchEvent()
    self:createIndicator()
end

function ActCenterView:createUpdate()
    self.time = 0
    self.idx = 1
    self.stop = true
    self.touching = false

    local function update(dt)
        if not self.stop then
            local pos = self.pageView:getPositionX()
            self:updataIndicator(pos)

            if pos >= 0 then
                 self.pageView:getChildByTag(1):setScale(zoom - (1 - zoom) / (pageWidth + space) * (pos - (pageWidth + space)))
            elseif pos < - (actNum - 1) * (pageWidth + space) then
                self.pageView:getChildByTag(actNum):setScale(1 + (1 - zoom) / (pageWidth + space) * (pos + (actNum - 1) *(pageWidth + space)))
            else
                for i = 1 , actNum - 1 do
                    if pos < - (i - 1) * (pageWidth + space) and pos >= - i * (pageWidth + space) then
                        self.pageView:getChildByTag(i):setScale(1 + (1 - zoom) / (pageWidth + space) * (pos + (pageWidth + space) * (i - 1)))
                        self.pageView:getChildByTag(i + 1):setScale(zoom - (1 - zoom) / (pageWidth + space) * (pos + (pageWidth + space) * (i - 1)))
                        break
                    end
                end
            end
        end
        if not self.touching then
            self.time = self.time + dt
        end
        if self.time > stopTime then
            self.stop = false
            self.idx = self.idx + 1
            self.time = 0
            if self.idx == actNum + 1 then
                self.pageView:runAction(cc.Sequence:create(cc.EaseSineInOut:create(cc.MoveTo:create(backScrollTime,cc.p(0 ,0))),cc.CallFunc:create( function() self.stop = true self.time = 0 end)))
                self.idx = 1
            else
                self.pageView:runAction( cc.Sequence:create(cc.EaseSineInOut:create(cc.MoveTo:create(staticScrollTime,cc.p( -(self.idx - 1) * (pageWidth + space) ,0))),cc.CallFunc:create( function() self.stop = true self.time = 0 end) ))
            end
        end
    end
    self.pageView:onUpdate(update)
end

function ActCenterView:addPage()
    self.pageTable = {}
    for i = 1, actNum do
        local sp = self.control:getPageByIndex(i)
        self.pageTable[i] = sp
        sp:setAnchorPoint(scaleAnchor)
        sp:setPosition(pageWidth * scaleAnchor.x + (i - 1) * (space + pageWidth) , pageHeight * scaleAnchor.y)
        sp:setTag(i)
        if i ~= 1 then
            sp:setScale(zoom)
        end
        self.pageView:addChild(sp)
    end
end

function ActCenterView:addTouchEvent()
    local function onTouchBegin(touch, event)
        local touchPos = touch:getLocation()
        local pagePos = self.pageViewNode:getWorldPosition()
        if cc.rectContainsPoint(cc.rect(pagePos.x, pagePos.y, pageWidth, pageHeight), touchPos) then
            self.touching = true
            self.stop = false
            self.pageView:stopAllActions()
            self.time = 0
            self.disX = 0
            return true
        end
    end

    local function onTouchMove(touch, event)
        local pagePosX = self.pageView:getPositionX()
        local disX = touch:getLocation().x - touch:getPreviousLocation().x
        self.disX = disX
        local addPos = 0

        if pagePosX >= 0 then
            addPos = disX * 0.5
        elseif pagePosX < - (actNum - 1) * (pageWidth + space) then
            addPos = disX * 0.5
        else
            addPos = disX * 1.25
        end
    self.pageView:setPosition(math.max(math.min(maxScrollAddPos, pagePosX + addPos), -((actNum - 1) *(pageWidth + space) + maxScrollAddPos)), 0)

    end

    local function onTouchEnd(touch, event)

        self.time = 0
        self.touching = false
        local endLocation = touch:getLocation()
        local pagePos = self.pageViewNode:getWorldPosition()
        local comDis = cc.pGetDistance(touch:getStartLocation(), endLocation)

        local pos = self.pageView:getPositionX()

        if comDis > pageWidth + space then
            self.idx = self:getIdx(pos)
            self.pageView:runAction( cc.Sequence:create(cc.EaseSineOut:create(cc.MoveTo:create(scrollSpecialTime,cc.p( - (self.idx - 1) * (pageWidth + space) ,0))),cc.CallFunc:create( function() self.stop = true end) ))
        else
            if self.disX > scrollMoveDis and self.idx ~= 1 then
                self.idx = self.idx - 1
                self.pageView:runAction( cc.Sequence:create(cc.EaseSineOut:create(cc.MoveTo:create(scrollNextTime,cc.p( - (self.idx - 1) * (pageWidth + space) ,0))),cc.CallFunc:create( function() self.stop = true end) ))
            elseif self.disX < - scrollMoveDis and self.idx ~= actNum then
                self.idx = self.idx + 1
                self.pageView:runAction( cc.Sequence:create(cc.EaseSineOut:create(cc.MoveTo:create(scrollNextTime,cc.p( - (self.idx - 1) * (pageWidth + space) ,0))),cc.CallFunc:create( function() self.stop = true end) ))
            else
                self.idx = self:getIdx(pos)
                self.pageView:runAction( cc.Sequence:create(cc.EaseSineOut:create(cc.MoveTo:create(scrollProTime,cc.p( - (self.idx - 1) * (pageWidth + space) ,0))),cc.CallFunc:create( function() self.stop = true end) ))
            end
        end

        if not cc.rectContainsPoint(cc.rect(pagePos.x, pagePos.y, pageWidth, pageHeight), endLocation) then return end
        if comDis > touchMoveDis then return end
        self.pageTable[self.idx]:onClickPage()
        --]]
    end

    local function onTouchCancelled()
        print("onTouchCancelled")
         self.touching = false
         self.stop = true
    end

    self.touchListener_ = cc.EventListenerTouchOneByOne:create()
    self.touchListener_:setSwallowTouches(true)
    self.touchListener_:registerScriptHandler(onTouchBegin, cc.Handler.EVENT_TOUCH_BEGAN)
    self.touchListener_:registerScriptHandler(onTouchMove, cc.Handler.EVENT_TOUCH_MOVED)
    self.touchListener_:registerScriptHandler(onTouchEnd, cc.Handler.EVENT_TOUCH_ENDED)
    self.touchListener_:registerScriptHandler(onTouchCancelled, cc.Handler.EVENT_TOUCH_CANCELLED)
    self.pageViewNode:getEventDispatcher():addEventListenerWithSceneGraphPriority(self.touchListener_, self.pageViewNode);
end

function ActCenterView:getIdx(pos)
    if pos >= - (pageWidth + space) / 2 then
        return 1
    elseif pos < - (pageWidth + space) * (actNum - 1) + (pageWidth + space) / 2 then
        return actNum
    else
        for i = 2, actNum - 1 do
            if pos < - (pageWidth + space) * (i - 1) + (pageWidth + space) / 2 and pos >= - (pageWidth + space) * i + (pageWidth + space) / 2 then
                return i
            end
        end
    end
    return 1
end

function ActCenterView:createIndicator()
    self.indicator = ccui.Layout:create()
    self.indicator:setContentSize( 32 * actNum + 4 * (actNum - 1) , 24)
    self.indicator:setAnchorPoint(0.5,0.5)
    self.indicator:setPosition(335,20)
    self.indicator:setClippingEnabled(false)
    self.pageViewNode:addChild(self.indicator)

    for i = 1, actNum do
        local sp = cc.Sprite:create("loadImage/indicatorBg.png")
        sp:setPosition( 12 + (i - 1) * 38 ,12) 
        self.indicator:addChild(sp)
    end

    self.indicatorTable = {}
    for i = 1, actNum do
        local sp = cc.Sprite:create("loadImage/indicator.png")
        self.indicatorTable[i] = sp
        sp:setPosition( 12 + (i - 1) * 38 ,12) 
        self.indicator:addChild(sp)
        if i ~= 1 then
            sp:setVisible(false)
        end
    end
end

function ActCenterView:updataIndicator(pos)
    if pos >= - (pageWidth + space) / 2 then
        self:setIndicatorShow(1)
    elseif pos < - (pageWidth + space) * (actNum - 1) + (pageWidth + space) / 2 then
        self:setIndicatorShow(actNum)
    else
        for i = 2, actNum - 1 do
            if pos < - (pageWidth + space) * (i - 1) + (pageWidth + space) / 2 and pos >= - (pageWidth + space) * i + (pageWidth + space) / 2 then
                self:setIndicatorShow(i)
            end
        end
    end
    return 1
end

function ActCenterView:setIndicatorShow(idx)
    if self.proIndicator == self.indicatorTable[idx] then
        return
    else
        for i = 1, actNum do
            self.indicatorTable[i]:setVisible(false)
        end
        self.indicatorTable[idx]:setVisible(true)
        self.proIndicator = self.indicatorTable[idx]
    end
   
end



--[[
function ActCenterView:ctor(pageView)
    self.pageView = pageView
    self.control = bole:getActCenter()
    self:setPageView(pageView)
    
    self:setListeners()
end

function ActCenterView:setListeners()
    bole:addListener("ActDialogPopUp", self.onCloseActAutoScroll, self, nil, true)
    bole:addListener("ActDialogClosed", self.onOpenActAutoScroll, self, nil, true)
end

function ActCenterView:removeListeners()
    bole:removeListener("ActDialogPopUp", self)
    bole:removeListener("ActDialogClosed", self)
end

function ActCenterView:setPageView(pageView)
    self.pages = {}

    pageView:setIndicatorEnabled(true)
    pageView:setItemsMargin(35)
    pageView:setBounceEnabled(true)
    local function onPageTurn(sender, eventType)
        --print("onPageTurn=" .. eventType)
        if eventType == 0 then
            self:setPageTouchEnabled()
        end
    end
    --pageView:addEventListener(onPageTurn)
    pageView:addTouchEventListener(onPageTurn)

    local pageCnt = self.control:getActCount()
    dump(pageCnt,"pageCnt")
    for i = 1, pageCnt do
        local page = self.control:getPageByIndex(i)
        pageView:addPage(page)
        table.insert(self.pages, page)
    end
    self:setTouchEvent(pageView)
    self:setPageTouchEnabled()
end

function ActCenterView:onPageClick()
    local curIndex = self:getCurPageIndex()
    self.pages[curIndex]:onClickPage()
end

function ActCenterView:getCurPageIndex()
    local index = self.pageView:getCurrentPageIndex()
    if index == -1 and #self.pages > 0 then
        index = 0
    end
    index = index + 1
    return index
end

function ActCenterView:onAutoScroll()
    local pageCnt = self:getPageCnt()
    if pageCnt < 2 then return end

    local curIndex = self:getCurPageIndex()
    if curIndex < pageCnt then
        curIndex = curIndex + 1
    else
        curIndex = 1
    end
    self.pageView:scrollToItem(curIndex - 1)
end

function ActCenterView:getPageCnt()
    return #self.pages
end

function ActCenterView:onCloseActAutoScroll(event)
    self.isCloseAutoScroll = true
end

function ActCenterView:onOpenActAutoScroll(event)
    self.isCloseAutoScroll = false
    self.elapsed = 0
end

function ActCenterView:setTouchEvent(pageView)
    local calSize = pageView:getContentSize()
    local calRect = cc.rect(0, 0, calSize.width, calSize.height)

    local function onTouchBegan(touch, event)
        local startPoint = pageView:convertToNodeSpace(touch:getLocation())
        if cc.rectContainsPoint(calRect, startPoint) then
            self:onCloseActAutoScroll()
            return true
        end
    end
    local function onTouchEnded(touch, event)
        self:onOpenActAutoScroll()

        local endLocation = touch:getLocation()
        if not cc.rectContainsPoint(calRect, pageView:convertToNodeSpace(endLocation)) then return end
        if cc.pGetDistance(touch:getStartLocation(), endLocation) > 15 then return end

        self:onPageClick()
    end
    local function onTouchCancelled(touch, event)
        self:onOpenActAutoScroll()
    end
    local listener = cc.EventListenerTouchOneByOne:create()
    listener:setSwallowTouches(false)
    listener:registerScriptHandler(onTouchBegan, cc.Handler.EVENT_TOUCH_BEGAN)
    listener:registerScriptHandler(onTouchEnded, cc.Handler.EVENT_TOUCH_ENDED)
    listener:registerScriptHandler(onTouchCancelled, cc.Handler.EVENT_TOUCH_CANCELLED)

    local node = cc.Node:create()
    pageView:addChild(node, 1000)
    local eventDispatcher = node:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, node)

    self:setEvtForAutoScroll(node)
end

function ActCenterView:setEvtForAutoScroll(node)
    self.elapsed = 0
    local function update(dt)
        if self.isCloseAutoScroll then return end
        self.elapsed = self.elapsed + dt
        if self.elapsed > 3.5 then
            self.elapsed = 0
            self:onAutoScroll()
        end
    end
    node:onUpdate(update)

    node:registerScriptHandler(function(state)
        if state == "cleanup" then
            self:removeListeners()
        end
    end)
end

function ActCenterView:removePageById(id)
    for i = #self.pages, 1, -1 do
        local page = self.pages[i]
        if page.id == id then
            self.pageView:removePage(page)
            table.remove(self.pages, i)
        end
    end
end

function ActCenterView:setPageTouchEnabled()
    local curIndex = self:getCurPageIndex()
    for i, page in ipairs(self.pages) do 
        if i == curIndex then
            page:setPageEnabled(true)
        else
            page:setPageEnabled(false)
        end
    end
end
--]]

return ActCenterView
--endregion
