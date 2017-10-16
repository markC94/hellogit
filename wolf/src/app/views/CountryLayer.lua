-- region *.lua
-- Date
-- 此文件由[BabeLua]插件自动生成
local CountryLayer = class("CountryLayer", cc.load("mvc").ViewBase)
function CountryLayer:onCreate()
    print("CountryLayer:onCreate")
    self.root = self:getCsbNode():getChildByName("root")
    self.root:setTouchEnabled(true)
    self.root:addTouchEventListener(handler(self, self.touchEvent))
    self.root:setScale(0.01)
    self.root:runAction(cc.ScaleTo:create(0.2, 1.0))

    self.btn_cancle = self.root:getChildByName("btn_cancle")
    self.btn_cancle:setTouchEnabled(true)
    self.btn_cancle:addTouchEventListener(handler(self, self.touchEvent))

    -- 国际
    self.clip = self.root:getChildByName("clip")
    self.list_country = self.clip:getChildByName("list_country")
    self.list_country:setTouchEnabled(true)
--    self.list_country:setBounceEnabled(false)
    self.list_country:setScrollBarOpacity(0)

    -- 表里从0开始的
    local countrys = bole:getConfig("country")
    local tempIndex=bole:getUserDataByKey("country")
    local newCountrys = { }
    for k, v in pairs(countrys) do
        newCountrys[tonumber(k) + 1] = v
    end

    --国籍排序
--    table.sort(newCountrys,function(a,b)
--        if a.countryname_en<b.countryname_en then
--            return true
--        end
--    end)
--     for k, v in pairs(countrys) do
--        if tempIndex==v.countryid then
--            tempIndex=k
--            break
--        end
--    end
     
    self.off_index = 0
    self.count = #newCountrys
    self.actIndex = 10
    self.list_len = 0

    -- 循环 or 列表 二选一
    self.isLoop = false
    if self.isLoop then
        self:initLoop(newCountrys)
    else
        self:initList(newCountrys)
    end

--    self.list_country:addScrollViewEventListener(handler(self, self.onScroll))
--    self.list_country:addEventListener(handler(self, self.ScrollTouch))
    self:setCountryIndex(tempIndex + self.off_index)

end

function CountryLayer:onKeyBack()
   self:closeUI()
end

-- 初始化循环模式
function CountryLayer:initLoop(newCountrys)
    for k, v in ipairs(newCountrys) do
        local cell = bole:getEntity("app.views.CountryCell", v.countryid,k)
        self.list_country:pushBackCustomItem(cell)
        self.list_len = self.list_len + cell:getContentSize().height
    end

    for k, v in ipairs(newCountrys) do
        local cell = bole:getEntity("app.views.CountryCell", v.countryid,k)
        self.list_country:pushBackCustomItem(cell)
        self.list_len = self.list_len + cell:getContentSize().height
    end
end
-- 初始化列表模式
function CountryLayer:initList(newCountrys)
    self.off_index = 0
    self.count = #newCountrys + self.off_index
--    for i = 1, self.off_index do
--        local cell = bole:getEntity("app.views.CountryCell", -1)
--        self.list_country:pushBackCustomItem(cell)
--        self.list_len = self.list_len + cell:getContentSize().height
--    end
    for k, v in ipairs(newCountrys) do
        local cell = bole:getEntity("app.views.CountryCell",v.countryid,k)
        self.list_country:pushBackCustomItem(cell)
        self.list_len = self.list_len + cell:getContentSize().height
    end
--    for i = 1, 3 do
--        local cell = bole:getEntity("app.views.CountryCell", -1)
--        self.list_country:pushBackCustomItem(cell)
--        self.list_len = self.list_len + cell:getContentSize().height
--    end
end
function CountryLayer:isBoundary()
    if self.loop then
        if self.index <= self.actIndex then
            self.index = self.index + self.count
            return true
        elseif self.index >= self.count * 2 - self.actIndex then
            self.index = self.index - self.count
            return true
        end
    else
        if self.index < self.off_index then
            self.index = self.off_index
            return true
        elseif self.index > self.count - 1 then
            self.index = self.count - 1
            return true
        end
    end
    return false
end
function CountryLayer:setCountryIndex(index)
    if not index then
        index = self:getListCurIndex()
    end
    self.index = index
    local isAct = self:isBoundary()
    self:setListPosByIndex(self.index, isAct)
end
function CountryLayer:getListCurIndex()
    local content = self.list_country:getInnerContainer()
    local newx, newy = content:getPosition()
    local neww = content:getContentSize().width
    local index = math.floor((self.list_len - math.abs(newy) -257.5) / 80)
    print("self.index=" .. self.index)
    return index
end
function CountryLayer:setListPosByIndex(index, isAction)
    if not isAction then
        self.list_country:stopAllActions()
    end
    self.list_country:jumpToItem(index, cc.p(0.5, 0.5), cc.p(0.5, 0.5))
    local content = self.list_country:getInnerContainer()
    local newx, newy = content:getPosition()
    print("newy-------------------:" .. newy)
end
function CountryLayer:ScrollTouch(sender, eventType)
    if eventType == 0 then
        self.movey = nil
    else
        self:setCountryIndex()
    end
end

function CountryLayer:onScroll(sender, eventType)
    local content = self.list_country:getInnerContainer()
    local newx, newy = content:getPosition()
    if eventType == 10 then
        self:setCountryIndex()
    end
    print("eventType:" .. eventType)
end
function CountryLayer:changeCountry(event)
--    self:setCountryIndex()
    self.index=event.result
--    if self.index<0 then
--        return
--    end
--    if self.index >= self.count then
--        self.index = self.index - self.count
--    end

    if self.isClick then
        return
    end
    self.isClick=true

    bole:postEvent("changeInfo", { key = 7,value = self.index })
    local childs = self.list_country:getChildren()
    for _, v in ipairs(childs) do
        v:updateStatus(index)
    end
    performWithDelay(self,function()
        self:closeUI()
    end,0.2)
end

function CountryLayer:updateUI(event)

end
function CountryLayer:onEnter()
    bole:addListener("changeCountry", self.changeCountry, self, nil, true)
end

function CountryLayer:onExit()
    bole:getEventCenter():removeEventWithTarget("changeCountry", self)
end
function CountryLayer:touchEvent(sender, eventType)
    local name = sender:getName()
    local tag = sender:getTag()
    if eventType == ccui.TouchEventType.began then
        print("Touch Down")
    elseif eventType == ccui.TouchEventType.moved then
    elseif eventType == ccui.TouchEventType.ended then
        print("Touch Up")
        if name == "btn_save" then
            if self.index >= self.count then
                self.index = self.index - self.count
            end
            bole:postEvent("changeInfo", { key = 7, value = self.index - self.off_index })
            self:closeUI()
        end
        if name == "btn_cancle" then
            self:closeUI()
        end
        if name == "root" then
            self:closeUI()
        end
    elseif eventType == ccui.TouchEventType.canceled then
        print("Touch Cancelled")
    end
end
return CountryLayer
-- endregion
