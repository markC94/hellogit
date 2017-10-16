-- region *.lua
-- Date
-- 此文件由[BabeLua]插件自动生成
local InfoList = class("InfoList", cc.load("mvc").ViewBase)
function InfoList:onCreate(data)
    print("CountryLayer:onCreate")
    self.list_type=data
    self.root = self:getCsbNode():getChildByName("root")
    self.root:setTouchEnabled(true)
    self.root:addTouchEventListener(handler(self, self.touchEvent))
    self.root:setScale(0.01)
    self.root:runAction(cc.ScaleTo:create(0.2, 1.0))

    self.img_bg = self.root:getChildByName("img_bg")
    
    self.btn_cancle = self.root:getChildByName("btn_cancle")
    self.btn_cancle:setTouchEnabled(true)
    self.btn_cancle:addTouchEventListener(handler(self, self.touchEvent))

    self.clip = self.root:getChildByName("clip")
    self.list = self.clip:getChildByName("list")
    self.list:setBounceEnabled(true)
    self.list:setScrollBarOpacity(0)

    self.txt_title = self.root:getChildByName("txt_title")

    if self.list_type==1 then
        self:initListGender()
        self.txt_title:setString("Gender")
    elseif self.list_type==2 then
        self:initListStauts()
        self.txt_title:setString("Status")
    elseif self.list_type==3 then
        self:initListAge()
        self.txt_title:setString("Age")
    end

end

function InfoList:onKeyBack()
   self:closeUI()
end

function InfoList:setListHeight(h)
    self.img_bg:setContentSize({width=570,height=h+10})
    self.clip:setContentSize({width=570,height=h})
    self.list:setContentSize({width=570,height=h})
    self.list:setPosition(285.00,h)
end
function InfoList:initListGender()
    self:setListHeight(240)
    for i = 1, 3 do
        local cell = bole:getEntity("app.views.GenderCell", i-1)
        self.list:pushBackCustomItem(cell)
    end
    self.list:setBounceEnabled(false)
end

function InfoList:initListStauts()
    self:setListHeight(320)
    for i = 1,4 do
        local cell = bole:getEntity("app.views.StatusCell", i-1)
        self.list:pushBackCustomItem(cell)
    end
    self.list:setBounceEnabled(false)
end

function InfoList:initListAge()
    for i = 16, 100 do
        local cell = bole:getEntity("app.views.AgeCell", i)
        self.list:pushBackCustomItem(cell)
    end
    self.list:setBounceEnabled(false)
    self.list:stopAllActions()
    local age=bole:getUserDataByKey("age")
    if age>16 then
        self.list:jumpToItem(age-16, cc.p(0.5, 0.5), cc.p(0.5, 0.5))
    end
end

function InfoList:setListPosByIndex(index)
    self.list_country:jumpToItem(index, cc.p(0.5, 0.5), cc.p(0.5, 0.5))
end

function InfoList:changeSelect(event)
    local index=event.result
    if self.isClick then
        return
    end
    self.isClick=true

    if self.list_type==1 then
        bole:postEvent("changeInfo", { key = 5,value = index })
    elseif self.list_type==2 then
        bole:postEvent("changeInfo", { key = 6,value = index })
    elseif self.list_type==3 then
        bole:postEvent("changeInfo", { key = 4,value = index })
    end
    local childs = self.list:getChildren()
    for _, v in ipairs(childs) do
        v:updateStatus(index)
    end
    performWithDelay(self,function()
        self:closeUI()
    end,0.2)
end

function InfoList:updateUI(event)

end
function InfoList:onEnter()
    bole:addListener("changeAgeStutas", self.changeSelect, self, nil, true)
end

function InfoList:onExit()
    bole:getEventCenter():removeEventWithTarget("changeAgeStutas", self)
end
function InfoList:touchEvent(sender, eventType)
    local name = sender:getName()
    local tag = sender:getTag()
    if eventType == ccui.TouchEventType.began then
        print("Touch Down")
    elseif eventType == ccui.TouchEventType.moved then
    elseif eventType == ccui.TouchEventType.ended then
        print("Touch Up")
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
return InfoList
-- endregion
