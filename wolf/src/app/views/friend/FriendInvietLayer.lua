--region *.lua
--Date
--此文件由[BabeLua]插件自动生成

local FriendInvietLayer = class("FriendInvietLayer", cc.load("mvc").ViewBase)
FriendInvietLayer.MaxInputLenght = 20

function FriendInvietLayer:onCreate()
    print("FriendInvietLayer:onCreate")
    self.root_ = self:getCsbNode():getChildByName("root")
    self.friendPanel_ = self:getCsbNode():getChildByName("freind")
    self:initFreindPanel()

    self.top_ = self.root_:getChildByName("top")
    self.view_ = self.root_:getChildByName("view")
    self.scrollViewScrollMaxLenght_ = 0
    self:initTop()
    self:initView()
    self:adaptScreen()

    bole:getFacebookCenter():getInvitableFriends(function(data) self:refreshInvitaInfo(data)  end)
end


function FriendInvietLayer:onEnter()
    bole:addListener("initFriendInfo", self.initFriendInfo, self, nil, true)
end

function FriendInvietLayer:initFriendInfo(data)
    data = data.result
    self.friendInfo_ = data
    --self:refreshFriendView(self.friendInfo_)
end


function FriendInvietLayer:initTop()
    self.top_:getChildByName("title"):setString("Invite FaceBook Friends")
    local btn_close = self.top_:getChildByName("btn_close")
    btn_close:addTouchEventListener(handler(self, self.touchEvent))
end

function FriendInvietLayer:initFreindPanel()
    --TODO
end

function FriendInvietLayer:createFriendPanel( data )
    local widget = self.friendPanel_:clone()
    widget:setVisible(true)

    local headData = { name = data.name ,head_url = data.pictureUrl}
    local head = bole:getNewHeadView(headData)
    head:setScale(0.8)
    head:updatePos(head.POS_FB_FRIEND)
    widget:getChildByName("head"):addChild(head)
    widget.id = data.id
    --[[
    local clipNode = cc.ClippingNode:create()
    local mask = cc.Sprite:create("res/friend/mask.png")
    clipNode:setAlphaThreshold(0)
    clipNode:setStencil(mask)
    clipNode:setScale(0.97)
    local icon = cc.Sprite:create("res/friend/icon.png")
    clipNode:addChild(icon)
    widget:getChildByName("head"):addChild(clipNode)
    widget.id = id
    widget.icon = icon
    widget.name = widget:getChildByName("name")
    if data ~= nil then
        if data.name ~= nil then
            widget.name:setString(data.name)
        end
    end
    --]]
    --widget.name:setString(data.name)
    return widget
end

function FriendInvietLayer:initView()
    local input = self.view_:getChildByName("input") 
    self:createEditBox(input)
    self.noFriendBg_ = self.view_:getChildByName("noF_bg")
    self.noFriendBg_:setVisible(false)

    self.scrollView_ = self.view_:getChildByName("ScrollView") 
    self.slider_ = self.view_:getChildByName("Slider") 

    local btn_send = self.view_:getChildByName("send")
    btn_send:addTouchEventListener(handler(self, self.touchEvent))
end

function FriendInvietLayer:refreshInvitaInfo(data)
    print("---------------------mk--------------------------")
    self.fbFriendInfo_ = data
    dump(self.fbFriendInfo_,"self.fbFriendInfo_")
    self.scrollView_:addEventListener(handler(self, self.scrollViewEvent))
    self.scrollView_:setScrollBarOpacity(0)
    if self.fbFriendInfo_ ~= nil then
        self:refreshFriendView(self.fbFriendInfo_)
    end
end


function FriendInvietLayer:refreshFriendView(data)
    self.scrollView_:removeAllChildren()
    --test
    self.showNum_ = # data
    for i = 1, self.showNum_  do
        local widget = self:createFriendPanel(data[i])
        self.scrollView_:addChild(widget)
        if i % 3 == 0 then
            widget:setPosition(cc.p( math.ceil(i / 3) * 365 - 350, 0))
        elseif i % 3 == 1 then
            widget:setPosition(cc.p( math.ceil(i / 3) * 365 - 350, 260))
        elseif i % 3 == 2 then
            widget:setPosition(cc.p( math.ceil(i / 3) * 365 - 350, 130))
        end
    end
    self.scrollView_:setInnerContainerSize(cc.size( math.ceil(self.showNum_  / 3) * 365, 390))
    self.scrollView_:scrollToBottom(0,true)
    self.scrollViewScrollMaxLenght_ = self.scrollView_:getInnerContainerSize().width -  self.scrollView_:getContentSize().width
end

function FriendInvietLayer:createEditBox(parentWidget)
    local inputBg = parentWidget:getChildByName("inputBg")
    local size = inputBg:getContentSize()
    local posX,posY = inputBg:getPosition()
    parentWidget:getChildByName("text"):setVisible(false)
    inputBg:setVisible(false)

    self.editBox_ = ccui.EditBox:create(size,"res/friend/MF_searchINPUT.png")
    self.editBox_:setAnchorPoint(0,0)
    self.editBox_:setFontSize(26)
    self.editBox_:setPlaceholderFontSize(26)
    self.editBox_:setFontName("res/font/FZKTJW.TTF")
    self.editBox_:setPlaceholderFontName("res/font/FZKTJW.TTF")
    self.editBox_:setFontColor(cc.c3b(111,122,152))
    self.editBox_:setPlaceholderFontColor(cc.c3b(111,122,152))
    self.editBox_:setPlaceHolder("Input Player ID")
    self.editBox_:setInputMode(cc.EDITBOX_INPUT_MODE_SINGLELINE)
    self.editBox_:setMaxLength(FriendInvietLayer.MaxInputLenght)
    self.editBox_:setPosition(0,0)
    self.editBox_:setReturnType(cc.KEYBOARD_RETURNTYPE_DONE )
    self.editBox_:registerScriptEditBoxHandler(handler(self, self.editBoxHandEvent))
    parentWidget:getChildByName("inputPanel"):addChild(self.editBox_)

    parentWidget:getChildByName("btn_search"):addTouchEventListener(handler(self, self.touchEvent))
    parentWidget:getChildByName("btn_input_close"):addTouchEventListener(handler(self, self.touchEvent))
    parentWidget:getChildByName("CheckBox"):addTouchEventListener(handler(self, self.checkBoxEvent))
end

function FriendInvietLayer:touchEvent(sender, eventType)
    local name = sender:getName()
    if eventType == ccui.TouchEventType.began then
        sender:runAction(cc.ScaleTo:create(0.1, 1.05, 1.05))
    elseif eventType == ccui.TouchEventType.moved then

    elseif eventType == ccui.TouchEventType.ended then
        sender:runAction(cc.ScaleTo:create(0.1, 1, 1))
        if name == "btn_close" then
            self:closeUI()
        elseif name == "send" then
            self:send()
        elseif name == "btn_search" then
            self:searchId()
            print("btn_search")
        elseif name == "btn_input_close" then
            print("btn_input_close")
        end
    elseif eventType == ccui.TouchEventType.canceled then
        sender:runAction(cc.ScaleTo:create(0.1, 1, 1))
    end
end

function FriendInvietLayer:searchId()
    local showId = {}
    local id = self.editBox_:getText()

    if id == "" then
        bole:popMsg({msg ="未找到该玩家" , title = "Search Friend" })
        return
    end

    for k ,v in pairs( self.fbFriendInfo_) do
        if string.find(v.name, id) ~= nil then
            print(v.name .. "      " ..  string.find(v.name, id))
            table.insert(showId , # showId + 1, v)
        end
    end

    dump(showId,"showId")

    if # showId ~= 0 then
        self:refreshFriendView(showId)
    else
        bole:popMsg({msg ="未找到该玩家" , title = "Search Friend" })
    end
end

function FriendInvietLayer:scrollViewEvent(sender,eventType)
    if eventType == 9 then
        local nowX = - self.scrollView_:getInnerContainerPosition().x 
        local posX = math.min( math.max(0 , nowX) , self.scrollViewScrollMaxLenght_)
        self.slider_:setPercent(posX / self.scrollViewScrollMaxLenght_ * 100)
    end
end

function FriendInvietLayer:checkBoxEvent(sender,eventType)
    if eventType == ccui.TouchEventType.began then

    elseif eventType == ccui.TouchEventType.moved then

    elseif eventType == ccui.TouchEventType.ended then
        local isSelected = sender:isSelected()
        for k,v in pairs(self.scrollView_:getChildren()) do
            local checkBox = v:getChildByName("CheckBox")
            if checkBox then
                checkBox:setSelected(isSelected)
            end
         end
    elseif eventType == ccui.TouchEventType.canceled then
        sender:setSelected(not sender:isSelected())
    end
end

function FriendInvietLayer:editBoxHandEvent(eventName,sender)
    if eventName == "began" then

    elseif eventName == "ended" then

    elseif eventName == "return" then

    elseif eventName == "changed" then

    end
end

function FriendInvietLayer:send()

    local inviteId = {}
     for k,v in pairs(self.scrollView_:getChildren()) do
         local checkBox = v:getChildByName("CheckBox")
         if checkBox:isSelected() then
            table.insert(inviteId, # inviteId + 1 ,v.id)
         end
    end 
    dump(inviteId,"inviteId")
    bole:getFacebookCenter():inviteOneFriend(inviteId)
end

function FriendInvietLayer:onExit()
    
end

function FriendInvietLayer:adaptScreen()
    local winSize = cc.Director:getInstance():getWinSize()
    self:setPosition(0,0)
    self.root_:setPosition(winSize.width / 2, winSize.height / 2)
    self.root_:setScale(0.1)
    self.root_:runAction(cc.ScaleTo:create(0.2,1,1))
end


return FriendInvietLayer
--endregion
