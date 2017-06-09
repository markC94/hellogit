--region *.lua
--Date
--此文件由[BabeLua]插件自动生成

local FriendLayer = class("FriendLayer", cc.load("mvc").ViewBase)


function FriendLayer:onCreate()
    print("FriendLayer:onCreate")
    self.root_ = self:getCsbNode():getChildByName("root")
    self.top_ = self.root_:getChildByName("top")
    self.leftFunc_ = self.root_:getChildByName("func_btn")
    self.friendView_ = self.root_:getChildByName("friendView")

    self:initTop()
    self:initLeftFunc()
    self:initFriendView()

    self:adaptScreen()
    bole.socket:send("sync_friends_info",{},true)
end

function FriendLayer:onEnter()
    bole.socket:registerCmd("sync_friends_info", self.initFriendInfo, self)
    bole.socket:registerCmd("send_application", self.reApplication, self)
    bole:addListener("removeHint", self.removeHint, self, nil, true)
    bole:addListener("addFriend", self.addFriendPanel, self, nil, true)
    bole:addListener("removeFriend", self.removeFriendPanel, self, nil, true)
    bole:addListener("closeFriendRequestLayer", self.closeFriendRequestLayer, self, nil, true)
end


function FriendLayer:initFriendInfo(t, data)
    dump(data,"friend")
    if t == "sync_friends_info" then
        if data.f_applications ~= nil then
            self.applicationsList_ = data.f_applications
        end

        if data.friends ~= nil then
            self.friendsList_ = data.friends
            self:sortList()    --好友排序
        end

        if data.fbfriends ~= nil then
            self.fbFriendInfo_ = data.fbfriends
        end

        self:refreshFriendView()
        self:refreshHint()
        self:refreshLeftFunc()
    end
end


function FriendLayer:initTop()
    self.top_:getChildByName("title"):setString("My Friends")
    local btn_close = self.top_:getChildByName("btn_close")
    btn_close:addTouchEventListener(handler(self, self.touchEvent))
end

function FriendLayer:initLeftFunc()
    local btn_request = self.leftFunc_:getChildByName("btn_request")
    self.dian_ = btn_request:getChildByName("dian")
    btn_request:getChildByName("text"):setString("Friend Request")
    btn_request:addTouchEventListener(handler(self, self.touchEvent)) 

    local btn_invite = self.leftFunc_:getChildByName("btn_invite")
    btn_invite:getChildByName("text"):setString("Invite Friends")
    btn_invite:addTouchEventListener(handler(self, self.touchEvent))

    local btn_search = self.leftFunc_:getChildByName("btn_search")
    btn_search:getChildByName("text"):setString("Search")
    btn_search:addTouchEventListener(handler(self, self.touchEvent))

    btn_request:setTouchEnabled(false)
    btn_invite:setTouchEnabled(false)
    btn_search:setTouchEnabled(false)
end

function FriendLayer:initFriendView()
    self.friendScrollView_ = self.friendView_:getChildByName("friendScrollView")
    self.friendScrollView_:addEventListener(handler(self, self.scrollViewEvent))
    self.noFriendBg_ = self.friendView_:getChildByName("noF_bg")
    self.noFriendBg_:setVisible(false)
end


function FriendLayer:refreshLeftFunc()
    self.leftFunc_:getChildByName("btn_request"):setTouchEnabled(true)
    self.leftFunc_:getChildByName("btn_invite"):setTouchEnabled(true)
    self.leftFunc_:getChildByName("btn_search"):setTouchEnabled(true)
end


function FriendLayer:refreshFriendView()
    self.friendNum_ =  # self.friendsList_
    self.showNum_ = self.friendNum_ 
    self.showNum_ = math.min(12, self.friendNum_)

    self.friendScrollView_:removeAllChildren()
    if self.friendNum_ == 0 then
        self.noFriendBg_:setVisible(true)
        self.friendScrollView_:setVisible(false)
    else
        self.noFriendBg_:setVisible(false)
        self.friendScrollView_:setVisible(true)  
        for i = 1, self.showNum_ do
            local head = bole:getNewHeadView(self.friendsList_[i])
            head:updatePos(head.POS_NONE)
            if i % 3 == 0 then
                head:setPosition(cc.p( math.ceil(i / 3) * 200 - 100, 80))
            elseif i % 3 == 1 then
                head:setPosition(cc.p( math.ceil(i / 3) * 200 - 100, 420))
            elseif i % 3 == 2 then
                head:setPosition(cc.p( math.ceil(i / 3) * 200 - 100, 250))
            end

            self.friendScrollView_:addChild(head)
            head:setTag(i)
            head.id = self.friendsList_[i].user_id
            head:setSwallow(false)
            head:setScale(1.1)
            --[[
            head:setVisible(false)
            performWithDelay(self, function()
                head:setVisible(true)
                head:runAction(cc.ScaleTo:create(0.5, 1.1))
            end ,
            math.floor((i - 1) / 3) * 0.5)
            --]]
        end
    
        self.friendScrollView_:setInnerContainerSize(cc.size( math.ceil(self.showNum_ / 3) * 200, 500))
        self.friendScrollView_:scrollToBottom(0,true)
        self.friendScrollView_:setScrollBarOpacity(0)
    end
end

function FriendLayer:refreshHint()
    local hint = bole:getUserData():getDataByKey("friendHint")
    print("--------------" .. hint)
    if hint == 0 then
        if  #self.applicationsList_ ~= 0 then
            self.dian_:setVisible(true)
        else
            self.dian_:setVisible(false)
        end
    else
        if #self.applicationsList_ > hint then
            self.dian_:setVisible(true)
        else
            self.dian_:setVisible(false)
        end
    end
end

function FriendLayer:closeFriendRequestLayer()
    self.dian_:setVisible(false)
end

function FriendLayer:scrollViewEvent(sender, eventType)

    if eventType == 4 then
        local inner_pos = self.friendScrollView_:getInnerContainerPosition()
        local addFriend = false
        if inner_pos.x + 150 < 870 - math.ceil(self.showNum_ / 3) * 200 then
            for i = self.showNum_ + 1, math.min (self.friendNum_, self.showNum_ + 3) do
                addFriend = true
                local head = bole:getNewHeadView(self.friendsList_[i])
                head:updatePos(head.POS_NONE)
                if i % 3 == 0 then
                    head:setPosition(cc.p(math.ceil(i / 3) * 200 - 100, 80))
                elseif i % 3 == 1 then
                    head:setPosition(cc.p(math.ceil(i / 3) * 200 - 100, 420))
                elseif i % 3 == 2 then
                    head:setPosition(cc.p(math.ceil(i / 3) * 200 - 100, 250))
                end

                self.friendScrollView_:addChild(head)
                head:setTag(i)
                head.id = self.friendsList_[i].user_id
                head:setSwallow(false)
                head:setScale(0.1)
                head:setVisible(false)
                
                performWithDelay(self, function()
                    head:setVisible(true)
                    head:runAction(cc.ScaleTo:create(0.5, 1.1))
                end ,
                math.floor(0))
                
            end
            
            if addFriend then
                self.showNum_ = math.min(self.friendNum_, self.showNum_ + 3)
                self.friendScrollView_:setInnerContainerSize(cc.size(math.ceil(self.showNum_ / 3) * 200, 500))
                self.friendScrollView_:setInnerContainerPosition(cc.p(inner_pos.x , 0))
            end
           
        end

    end
   

end

function FriendLayer:addFriendPanel(data)
    data = data.result
    dump(data,"---------------------------")
    for i = 1, #data do
        local head = bole:getNewHeadView(data[i])
        head:updatePos(head.POS_NONE)
        head.id = data[i].user_id
        self.friendNum_ = self.friendNum_ + 1
        if self.friendNum_ % 3 == 0 then
            head:setPosition(cc.p(math.ceil(self.friendNum_ / 3) * 200 - 100, 80))
        elseif self.friendNum_ % 3 == 1 then
            head:setPosition(cc.p(math.ceil(self.friendNum_ / 3) * 200 - 100, 420))
        elseif self.friendNum_ % 3 == 2 then
            head:setPosition(cc.p(math.ceil(self.friendNum_ / 3) * 200 - 100, 250))
        end
        self.friendScrollView_:addChild(head)
        head:setSwallow(false)
        head:setScale(1.1)

        self:addFriendInfo(data[i])
        self:removeAppLicationInfo(data[i].user_id)
    end
    if self.friendNum_ == 1 then
        self.noFriendBg_:setVisible(false)
        self.friendScrollView_:setVisible(true)  
    end
    self.friendScrollView_:setInnerContainerSize(cc.size( math.ceil(self.friendNum_ / 3) * 200, 500))
    self.friendScrollView_:scrollToRight(0,true)
end

function FriendLayer:removeFriendPanel(data)
    data = data.result
    for k ,v in pairs(self.friendScrollView_:getChildren()) do
        if tonumber(v.id) == tonumber(data) then
            self:removeFriendInfo(tonumber(v.id))
            v:removeFromParent()
            self.friendNum_ = self.friendNum_ - 1
        end
    end

    local children = self.friendScrollView_:getChildren()
    for i = 1, # children do
        local head = children[i]
        if i % 3 == 0 then
            head:setPosition(cc.p(math.ceil(i / 3) * 200 - 100, 80))
        elseif i % 3 == 1 then
            head:setPosition(cc.p(math.ceil(i / 3) * 200 - 100, 420))
        elseif i % 3 == 2 then
            head:setPosition(cc.p(math.ceil(i / 3) * 200 - 100, 250))
        end
    end

    if self.friendNum_ == 0 then
        self.noFriendBg_:setVisible(true)
        self.friendScrollView_:setVisible(false)  
    end

    self.friendScrollView_:setInnerContainerSize(cc.size( math.ceil(self.friendNum_ / 3) * 200, 500))
    self.friendScrollView_:scrollToRight(0,true)

end


function FriendLayer:reApplication(t,data)
    if t == "send_application" then
        if self.applicationsList_ == nil then
            self.applicationsList_ = {}
        end
        self:addAppLicationInfo(data)
    end
end

function FriendLayer:touchEvent(sender, eventType)
    local name = sender:getName()
    if eventType == ccui.TouchEventType.began then
        sender:runAction(cc.ScaleTo:create(0.1, 1.05, 1.05))
    elseif eventType == ccui.TouchEventType.moved then

    elseif eventType == ccui.TouchEventType.ended then
        sender:runAction(cc.ScaleTo:create(0.1, 1, 1))
        if name == "btn_close" then
            self:closeUI()
        elseif name == "btn_request" then
            self:openRequestLayer()
        elseif name == "btn_invite" then
            self:openInviteLayer()
        elseif name == "btn_search" then
            self:openSearchLayer()
        end
    elseif eventType == ccui.TouchEventType.canceled then
        sender:runAction(cc.ScaleTo:create(0.1, 1, 1))
    end
end

function FriendLayer:openRequestLayer()
    bole:getUIManage():openUI("FriendRequestLayer",true)
    bole:postEvent("initRequestInfo",self.applicationsList_)
end

function FriendLayer:openInviteLayer()
    --print(bole:getFacebookCenter().isInit)
    --print(bole:getFacebookCenter().loginForSendFriends)
    --print(bole:getFacebookCenter().startBindFacebook)
    if bole:getFacebookCenter().loginForSendFriends == false then
        bole:getFacebookCenter():bindFacebook()
    end
 
    bole:getUIManage():openUI("FriendInvietLayer",true)
    bole:postEvent("initFriendInfo", self.fbFriendInfo_)

end

function FriendLayer:openSearchLayer()
    bole:getUIManage():openUI("FriendSearchLayer",true) 
    bole:postEvent("initFrirndList",self.friendsList_)
end

function FriendLayer:removeFriendInfo(id)
    for i = 1, #self.friendsList_ do
            if tonumber(self.friendsList_[i].user_id) == tonumber(id) then
                table.remove(self.friendsList_, i)
                return
            end
    end
    self:refreshHint()
end

function FriendLayer:removeAppLicationInfo(id)
    for i = 1, #self.applicationsList_ do
        if tonumber(self.applicationsList_[i].user_id) == tonumber(id) then
            table.remove(self.applicationsList_, i)
            return
        end
    end
    self:refreshHint()
end

function FriendLayer:addFriendInfo(data)
    table.insert(self.friendsList_, # self.friendsList_ + 1, data)
    self:refreshHint()
end

function FriendLayer:addAppLicationInfo(data)
    table.insert(self.applicationsList_, # self.applicationsList_ + 1, data)
    self:refreshHint()
end
function FriendLayer:sortList() 
    local test = {}
    table.sort(self.friendsList_, function(a,b)
        if tonumber(a.online) == tonumber(b.online) then
            return tonumber(a.level) > tonumber(b.level)
        else
            return tonumber(a.online) > tonumber(b.online)
        end
    end)
end

function FriendLayer:removeHint(data)
    data = data.result
end

function FriendLayer:onExit()
    bole:removeListener("addFriend", self)
    bole:removeListener("removeFriend", self)
    bole:removeListener("removeHint", self)
    bole:removeListener("closeFriendRequestLayer", self)
    bole.socket:unregisterCmd("sync_friends_info")
    bole.socket:unregisterCmd("send_application")
end

function FriendLayer:adaptScreen()
    local winSize = cc.Director:getInstance():getWinSize()
    self:setPosition(0,0)
    self.root_:setPosition(winSize.width / 2, winSize.height / 2)
    self.root_:setScale(0.1)
    self.root_:runAction(cc.ScaleTo:create(0.2,1,1))
end

return FriendLayer
--endregion
