--region *.lua
--Date
--此文件由[BabeLua]插件自动生成

local FriendRequestLayer = class("FriendRequestLayer", cc.load("mvc").ViewBase)
FriendRequestLayer.status_1 = 1
FriendRequestLayer.status_2 = 2
FriendRequestLayer.status_3 = 3

function FriendRequestLayer:onCreate()
    print("FriendRequestLayer:onCreate")
    self.root_ = self:getCsbNode():getChildByName("root")
    self.reqPanel_ = self:getCsbNode():getChildByName("Panel_req")
    self.top_ = self.root_:getChildByName("top")
    self.requestView_ = self.root_:getChildByName("requestView")

    self:initReqPanel()
    self:initTop()
    self:initRequestView()

    self:adaptScreen()
end

function FriendRequestLayer:onEnter()
    bole:addListener("initRequestInfo", self.initRequestInfo, self, nil, true)
    bole.socket:registerCmd("deal_f_application", self.reApplication, self)
end

function FriendRequestLayer:initRequestInfo(data)
    self.requestList_ = data.result
    self.reInfo = {}
    self:refreshRequestView(self.requestList_)
end

function FriendRequestLayer:initTop()
    self.top_:getChildByName("title"):setString("Request")
    local btn_close = self.top_:getChildByName("btn_close")
    btn_close:addTouchEventListener(handler(self, self.touchEvent))
end

function FriendRequestLayer:initReqPanel()
    local panel_1 = self.reqPanel_:getChildByName("Panel_1")
    local panel_2 = self.reqPanel_:getChildByName("Panel_2")
    local panel_3 = self.reqPanel_:getChildByName("Panel_3")
    panel_1:getChildByName("btn_ok"):addTouchEventListener(handler(self, self.reqPanelTouchEvent))
    panel_1:getChildByName("btn_no"):addTouchEventListener(handler(self, self.reqPanelTouchEvent))
    panel_2:getChildByName("btn_accepted"):addTouchEventListener(handler(self, self.reqPanelTouchEvent))
    panel_3:getChildByName("btn_refused"):addTouchEventListener(handler(self, self.reqPanelTouchEvent))
    panel_3:getChildByName("btn_return"):addTouchEventListener(handler(self, self.reqPanelTouchEvent))
end

function FriendRequestLayer:initRequestView()
    self.requestScrollView_ = self.requestView_:getChildByName("ScrollView")    
    self.slider_ = self.requestView_:getChildByName("Slider")
    self.noFriendBg_ = self.requestView_:getChildByName("noF_bg")
end



function FriendRequestLayer:refreshRequestView(data)
    if #data == 0 then
        self.noFriendBg_:setVisible(true)
        self.requestScrollView_:setVisible(false)
        self.slider_:setVisible(false)
    else
        self.noFriendBg_:setVisible(false)
        self.requestScrollView_:setVisible(true)
        self.slider_:setVisible(true)

        for i = 1, #data do
            local widget = self:createRequestPanel(data[i])
            widget.id = tonumber(data[i].user_id)
 
            self.reInfo[i] = {}
            self.reInfo[i].id = widget.id
            self.reInfo[i].operation = 2 
            self.reInfo[i].data = data[i]

            self.requestScrollView_:addChild(widget)
            widget:setPosition((i - 1) * 280 + 10 , 0)
            widget:setTag(i)
        end

        self.requestScrollView_:setInnerContainerSize(cc.size( math.max( # data * 280, 1140), 340))
        self.requestScrollView_:scrollToBottom(0,true)
        self.requestScrollView_:setScrollBarOpacity(0)
        self.scrollViewScrollMaxLenght_ = self.requestScrollView_:getInnerContainerSize().width -  self.requestScrollView_:getContentSize().width
        self.requestScrollView_:addEventListener(handler(self, self.requestScrollViewEvent))

    end
end

function FriendRequestLayer:createRequestPanel(data)
    local widget = self.reqPanel_:clone()
    widget:setVisible(true)
    local head = bole:getNewHeadView(data)
    head:updatePos(head.POS_NONE)
    head:setSwallow(false)
    head:setScale(1.3)
    widget:getChildByName("head"):addChild(head)
    return widget
end

function FriendRequestLayer:refreshRequestPanel(widget,status)
    local id = tonumber(widget.id)
    widget:getChildByName("Panel_1"):setVisible(false)
    widget:getChildByName("Panel_2"):setVisible(false)
    widget:getChildByName("Panel_3"):setVisible(false)
    if status == FriendRequestLayer.status_1 then
        for i = 1 , #self.reInfo do
            if self.reInfo[i].id == id then
                self.reInfo[i].operation = 2
            end
        end
        widget:getChildByName("Panel_1"):setVisible(true)

    elseif status == FriendRequestLayer.status_2 then
        for i = 1 , #self.reInfo do
            if self.reInfo[i].id == id then
                self.reInfo[i].operation = 1
            end
        end
        widget:getChildByName("Panel_2"):setVisible(true)

    elseif status == FriendRequestLayer.status_3 then
        for i = 1 , #self.reInfo do
            if self.reInfo[i].id == id then
                self.reInfo[i].operation = 0
            end
        end
        widget:getChildByName("Panel_3"):setVisible(true)
    end
end


function FriendRequestLayer:touchEvent(sender, eventType)
    local name = sender:getName()
    if eventType == ccui.TouchEventType.began then
        sender:runAction(cc.ScaleTo:create(0.1, 1.05, 1.05))
    elseif eventType == ccui.TouchEventType.moved then

    elseif eventType == ccui.TouchEventType.ended then
        sender:runAction(cc.ScaleTo:create(0.1, 1, 1))
        if name == "btn_close" then
            self:exit()
        end
    elseif eventType == ccui.TouchEventType.canceled then
        sender:runAction(cc.ScaleTo:create(0.1, 1, 1))
    end
end

function FriendRequestLayer:reqPanelTouchEvent(sender, eventType)
    local name = sender:getName()
    local widget = sender:getParent():getParent()
    local tag = widget:getTag()
    if eventType == ccui.TouchEventType.began then
        sender:runAction(cc.ScaleTo:create(0.1, 1.05, 1.05))
    elseif eventType == ccui.TouchEventType.moved then

    elseif eventType == ccui.TouchEventType.ended then
        sender:runAction(cc.ScaleTo:create(0.1, 1, 1))
        if name == "btn_ok" then
            self:refreshRequestPanel(widget,2)
        elseif name == "btn_no" then
            self:refreshRequestPanel(widget,3)
        elseif name == "btn_return" then
            self:refreshRequestPanel(widget,1)
        end
    elseif eventType == ccui.TouchEventType.canceled then
        sender:runAction(cc.ScaleTo:create(0.1, 1, 1))
    end
end

function FriendRequestLayer:requestScrollViewEvent(sender, eventType)
    if eventType == 9 then
        local nowX = - self.requestScrollView_:getInnerContainerPosition().x 
        local posX = math.min( math.max(0 , nowX) , self.scrollViewScrollMaxLenght_)
        self.slider_:setPercent(posX / self.scrollViewScrollMaxLenght_ * 100)
    end
end

function FriendRequestLayer:exit()
    local resultsInfo = {}
    for i = 1 ,# self.reInfo do
        if self.reInfo[i].operation ~= 2 then
            local info = {}
            info.proposer = self.reInfo[i].id
            info.deal_result = self.reInfo[i].operation
            table.insert(resultsInfo, #resultsInfo + 1, info)
        end
    end
    
    if #resultsInfo ~= 0 then
        bole.socket:send("deal_f_application",{results = resultsInfo},true)
    else
        bole:getUserData():setDataByKey("friendHint",#self.requestList_)
        self:closeUI()
    end
    
end

function FriendRequestLayer:reApplication(t, data)
    if t == "deal_f_application" then
        local sendInfo = { }
        local dispose = 0
        local userFriendList = bole:getUserDataByKey("user_friends")
        for i = 1, #self.reInfo do
            if self.reInfo[i].operation == 1 then
                dispose = dispose + 1
                table.insert(sendInfo, #sendInfo + 1, self.reInfo[i].data)
                table.insert(userFriendList, # userFriendList + 1, tonumber(self.reInfo[i].data.user_id))
            elseif self.reInfo[i].operation == 0 then
                dispose = dispose + 1
                bole:postEvent("removeFriend",self.reInfo[i].id)
            end
        end
        bole:setUserDataByKey("user_friends", userFriendList)
        bole:postEvent("addFriend",sendInfo)
    end
    bole:getUserData():setDataByKey("friendHint",#self.requestList_ - 1)
    self:closeUI()
end

function FriendRequestLayer:adaptScreen()
    local winSize = cc.Director:getInstance():getWinSize()
    self:setPosition(0,0)
    self.root_:setPosition(winSize.width / 2, winSize.height / 2)
    self.root_:setScale(0.1)
    self.root_:runAction(cc.ScaleTo:create(0.2,1,1))
end

function FriendRequestLayer:onExit()
    bole:postEvent("closeFriendRequestLayer",{})
    bole:removeListener("initRequestInfo", self)
    bole.socket:unregisterCmd("deal_f_application")
end

return FriendRequestLayer

--endregion
