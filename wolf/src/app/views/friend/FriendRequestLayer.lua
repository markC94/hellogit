--region *.lua
--Date
--此文件由[BabeLua]插件自动生成

local FriendRequestLayer = class("FriendRequestLayer", cc.load("mvc").ViewBase)
FriendRequestLayer.status_1 = 1
FriendRequestLayer.status_2 = 2
FriendRequestLayer.status_3 = 3

function FriendRequestLayer:onCreate()
    print("FriendRequestLayer:onCreate")
    self.reqPanel_ = self:getCsbNode():getChildByName("Panel_req")
    self.requestView_ = self:getCsbNode():getChildByName("requestView")

    self:initReqPanel()
    self:initRequestView()
end

function FriendRequestLayer:onEnter()
    bole:addListener("initFriendRequestInfo", self.initRequestInfo, self, nil, true)
    bole:addListener("add_f_application_friendRequestLayer", self.addRequest, self, nil, true)
    bole.socket:registerCmd("deal_f_application", self.reApplication, self)
end

function FriendRequestLayer:enterLayer()
        self.noFriendBg_:setVisible(false)
        self.requestScrollView_:setVisible(false)
        self.sliderNode_:setVisible(false)
        self.requestScrollView_:removeAllChildren()
end

function FriendRequestLayer:initRequestInfo(data)
    self.requestList_ = data.result
    dump(self.requestList_ ,"self.requestList_ ")
    self.reInfo = {}
    self:refreshRequestView(self.requestList_)
end


function FriendRequestLayer:initReqPanel()
    local panel_1 = self.reqPanel_:getChildByName("Panel_1")
    local panel_2 = self.reqPanel_:getChildByName("Panel_2")
    panel_2:setVisible(false)
    local panel_3 = self.reqPanel_:getChildByName("Panel_3")
    panel_3:setVisible(false)
    panel_1:getChildByName("btn_ok"):addTouchEventListener(handler(self, self.reqPanelTouchEvent))
    panel_1:getChildByName("btn_no"):addTouchEventListener(handler(self, self.reqPanelTouchEvent))
    panel_2:getChildByName("btn_accepted"):addTouchEventListener(handler(self, self.reqPanelTouchEvent))
    panel_3:getChildByName("btn_refused"):addTouchEventListener(handler(self, self.reqPanelTouchEvent))
end

function FriendRequestLayer:initRequestView()
    self.requestScrollView_ = self.requestView_:getChildByName("requestScrollView")    
    self.noFriendBg_ = self.requestView_:getChildByName("noF_bg")
    self.noFriendBg_:setVisible(false)
    self.sliderNode_ = cc.CSLoader:createNode("friend/SliderNode.csb")
    self.sliderNode_:setVisible(false)
    self.requestView_:getChildByName("node_slider"):addChild(self.sliderNode_)
    self.slider_ = self.sliderNode_:getChildByName("root"):getChildByName("slider")
    self.slider_:setPercent(0)
end

function FriendRequestLayer:addRequest(data)
    data = data.result
    dump(data,"data")
        self.noFriendBg_:setVisible(false)
        self.requestScrollView_:setVisible(true)
        self.sliderNode_:setVisible(true)

        local num = # self.requestScrollView_:getChildren() + 1
         local widget = self:createRequestPanel(data)
            self.requestScrollView_:addChild(widget)
            widget:setPosition((num - 1) * 280 + 10 , 0)
            widget:setTag(num)

  self.requestScrollView_:setInnerContainerSize(cc.size( math.max( num * 280, 1140), 340))
        self.requestScrollView_:scrollToBottom(0,true)
        self.scrollViewScrollMaxLenght_ = self.requestScrollView_:getInnerContainerSize().width -  self.requestScrollView_:getContentSize().width
  
end

function FriendRequestLayer:refreshRequestView(data)
    self.requestScrollView_:removeAllChildren()
    if #data == 0 then
        self.noFriendBg_:setVisible(true)
        self.requestScrollView_:setVisible(false)
        self.sliderNode_:setVisible(false)
    else
        self.noFriendBg_:setVisible(false)
        self.requestScrollView_:setVisible(true)
        self.sliderNode_:setVisible(true)

        for i = 1, #data do
            local widget = self:createRequestPanel(data[i])
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
    head:setScale(1.4)
    widget:getChildByName("head"):addChild(head)
    widget.id = data.user_id
    widget.userData = data
    return widget
end

function FriendRequestLayer:removeRequestPanel()
    self.operation_.widget:removeFromParent()
    local children = self.requestScrollView_:getChildren()
    for i = 1, # children do
        children[i]:setPosition((i - 1) * 280 + 10 , 0)
    end
end

function FriendRequestLayer:refreshRequestPanel(widget,status)
    local user_id = tonumber(widget.id)
    widget:getChildByName("Panel_1"):setVisible(false)
    widget:getChildByName("Panel_2"):setVisible(false)
    widget:getChildByName("Panel_3"):setVisible(false)
    if status == FriendRequestLayer.status_1 then
        widget:getChildByName("Panel_1"):setVisible(true)
    elseif status == FriendRequestLayer.status_2 then
        widget:getChildByName("Panel_2"):setVisible(true)

    elseif status == FriendRequestLayer.status_3 then
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
            self.operation_ = {widget = widget , deal_result = 1}
            bole.socket:send("deal_f_application",{proposer = widget.id , deal_result = 1},true)
            --self:refreshRequestPanel(widget,2)
        elseif name == "btn_no" then
             self.operation_ = {widget = widget , deal_result = 0}
              bole:popMsg( { msg = "You are about to reject this request.Are you sure?", title = "request", cancle = true },
               function() bole.socket:send("deal_f_application",{proposer = widget.id , deal_result = 0},true) end)
            --self:refreshRequestPanel(widget,3)
        elseif name == "btn_return" then
            --self:refreshRequestPanel(widget,1)
        end
    elseif eventType == ccui.TouchEventType.canceled then
        sender:runAction(cc.ScaleTo:create(0.1, 1, 1))
    end
end

function FriendRequestLayer:requestScrollViewEvent(sender, eventType)
    if eventType == 4 then
        local nowX = - self.requestScrollView_:getInnerContainerPosition().x 
        local posX = math.min( math.max(0 , nowX) , self.scrollViewScrollMaxLenght_)
        self.slider_:setPercent(posX / self.scrollViewScrollMaxLenght_ * 100)
    end
end

function FriendRequestLayer:exit()
--[[
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
    end
    --]]
end

function FriendRequestLayer:reApplication(t, data)
    if t == "deal_f_application" then
        if data.error ~= nil then
            if data.error == 2 then
                if self.operation_.deal_result == 0 then
                    self:refreshRequestPanel(self.operation_.widget,3)
                else
                    bole:popMsg( { msg = "Invalid Message", title = "application", cancle = false }, function() self:removeRequestPanel() end)
                end
                bole:getFriendManage():removeAppLication(self.operation_.widget.id)
            elseif data.error == 3 then
                bole:popMsg( { msg = "Player list is full", title = "application", cancle = false })
            else
                bole:popMsg( { msg = "error: " .. data.error, title = "application", cancle = false })
            end

            return
        end
        if self.operation_ ~= nil then
            if self.operation_.deal_result == 1 then
                self:refreshRequestPanel(self.operation_.widget,2)
                bole:getFriendManage():addFriend(self.operation_.widget.userData)
            elseif self.operation_.deal_result == 0 then
                self:refreshRequestPanel(self.operation_.widget,3)
                bole:getFriendManage():removeFriend(self.operation_.widget.id)
            end
        end
    end
end

function FriendRequestLayer:onExit()
    bole:removeListener("initFriendRequestInfo", self)
    bole:removeListener("add_f_application_friendRequestLayer", self)
    bole.socket:unregisterCmd("deal_f_application")
end

return FriendRequestLayer

--endregion
