--region *.lua
--Date
--此文件由[BabeLua]插件自动生成

local FriendSearchLayer = class("FriendSearchLayer", cc.load("mvc").ViewBase)
FriendSearchLayer.MaxInputLenght = 10

function FriendSearchLayer:onCreate()
    print("FriendSearchLayer:onCreate")
    self.root_ = self:getCsbNode():getChildByName("root")
    self.top_ = self.root_:getChildByName("top")
    self.search_ = self.root_:getChildByName("search")

    self:initTop()
    self:initSearch()
    self:adaptScreen()
end

function FriendSearchLayer:onEnter()
    bole.socket:registerCmd("apply_for_friend", self.reApplyFriend, self)
    bole:addListener("initFrirndList", self.initFrirndList, self, nil, true)
end

function FriendSearchLayer:initFrirndList(data)
    data = data.result
    self.friendsList_ = data
end


function FriendSearchLayer:initTop()
    self.top_:getChildByName("title"):setString("Search Friends")
    local btn_close = self.top_:getChildByName("btn_close")
    btn_close:addTouchEventListener(handler(self, self.touchEvent))
end

function FriendSearchLayer:initSearch()
    local btn_send = self.search_:getChildByName("btn_send")
    btn_send:getChildByName("text"):setString("Send Request")
    btn_send:addTouchEventListener(handler(self, self.touchEvent))

    local input = self.search_:getChildByName("input")
    input:addTouchEventListener(handler(self, self.editBoxTouchEvent))
    local btn_close = input:getChildByName("btn_input_close")
    btn_close:addTouchEventListener(handler(self, self.touchEvent))

    self.text_unFind_ = self.search_:getChildByName("text_unFind")

    self:createEditBox(input)
end

function FriendSearchLayer:createEditBox(parentWidget)
    local inputBg = parentWidget:getChildByName("inputBg")
    local posX,posY = inputBg:getPosition()
    self.searchLabel_ = parentWidget:getChildByName("text")
    self.searchLabel_:setString("Input Player ID")

    self.editBox_ = ccui.EditBox:create(cc.size(100,10) ,"res/friend/MF_searchINPUT.png")
    self.editBox_:setAnchorPoint(0,0)
    self.editBox_:setFontSize(0.001)
    self.editBox_:setInputMode(cc.EDITBOX_INPUT_MODE_DECIMAL)
    self.editBox_:setMaxLength(FriendSearchLayer.MaxInputLenght)
    self.editBox_:setPosition(0,0)
    --self.editBox_:setScale(0.01)
    self.editBox_:setReturnType(cc.KEYBOARD_RETURNTYPE_DONE )
    self.editBox_:registerScriptEditBoxHandler(handler(self, self.editBoxHandEvent))
    parentWidget:getChildByName("inputPanel"):addChild(self.editBox_)
end


function FriendSearchLayer:touchEvent(sender, eventType)
    local name = sender:getName()
    if eventType == ccui.TouchEventType.began then
        sender:runAction(cc.ScaleTo:create(0.1, 1.05, 1.05))
    elseif eventType == ccui.TouchEventType.moved then

    elseif eventType == ccui.TouchEventType.ended then
        sender:runAction(cc.ScaleTo:create(0.1, 1, 1))
        if name == "btn_close" then
            self:closeUI()
        elseif name == "btn_send" then
            self:sendRequest()
        elseif name == "btn_input_close" then
            self.editBox_:setText("")
            self.searchLabel_:setString("Input Player ID")
        elseif name == "input" then
            self.editBox_:touchDownAction(self.editBox_, 2) 
        end
    elseif eventType == ccui.TouchEventType.canceled then
        sender:runAction(cc.ScaleTo:create(0.1, 1, 1))
    end
end

function FriendSearchLayer:editBoxTouchEvent(sender, eventType)
    if eventType == ccui.TouchEventType.ended then
         self.editBox_:touchDownAction(self.editBox_, 2) 
    end
end

function FriendSearchLayer:editBoxHandEvent(eventName,sender)
    if eventName == "began" then
        self.searchLabel_:setString(self.editBox_:getText())
    elseif eventName == "ended" then
        if self.editBox_:getText() == "" then
            self.searchLabel_:setString("Input Player ID")
        end
    elseif eventName == "return" then
        self.searchLabel_:setString(sender:getText())
        if self.searchLabel_:getString() == "" then
            self.searchLabel_:setString("Input Player ID")
        end
    elseif eventName == "changed" then
        self.searchLabel_:setString(sender:getText())
        if self.searchLabel_:getString() == "" then
            self.searchLabel_:setString("Input Player ID")
        end
    end
end

function FriendSearchLayer:sendRequest()
    local id = self.editBox_:getText() 
    for k ,v in pairs(self.friendsList_) do
        if tonumber(id) == tonumber(v.user_id) then
            self.text_unFind_:setVisible(true)
            self.text_unFind_:setString("friend added")
            return 
        end
    end

    if tonumber(id) == tonumber(bole:getUserDataByKey("user_id")) then
        self.text_unFind_:setVisible(true)
        self.text_unFind_:setString("can't request yourself")
        return
    end

    for i = 1, string.len(id) do
         if tonumber(string.sub(id , i , i )) == nil then
            self.text_unFind_:setVisible(true)
            self.text_unFind_:setString("error id")
            return
         end
    end

    if id == "" then
        self.text_unFind_:setVisible(true)
        self.text_unFind_:setString("please input id")
       return
    end

    bole.socket:send("apply_for_friend",{target_id = tonumber(id)},true) 
end

function FriendSearchLayer:reApplyFriend(t, data)
    if t == "apply_for_friend" then
        if data.success ~= nil then
            if data.success == 1 then
                if data.new_friend.user_id == nil then
                    self.text_unFind_:setVisible(true)
                    self.text_unFind_:setString("Couldnit find a player with the provided ID.")
                else
                    bole:postEvent("addFriend",{data.new_friend})
                    local userFriendList = bole:getUserDataByKey("user_friends")
                    table.insert(userFriendList, # userFriendList + 1, tonumber(data.user_id))
                    bole:setUserDataByKey("user_friends", userFriendList)
                    self:closeUI()
                end
                --发送消息
            end
        end
        if data.error ~= nil then
            if data.error == 1 then
                 self.text_unFind_:setVisible(true)
                 self.text_unFind_:setString("Couldnit find a player with the provided ID.")
            end
        end
    end
end

function FriendSearchLayer:onExit()   
    bole.socket:unregisterCmd("apply_for_friend")
    bole:removeListener("initFrirndList", self)

end

function FriendSearchLayer:adaptScreen()
    local winSize = cc.Director:getInstance():getWinSize()
    self:setPosition(0,0)
    self.root_:setPosition(winSize.width / 2, winSize.height / 2)
    self.root_:setScale(0.1)
    self.root_:runAction(cc.ScaleTo:create(0.2,1,1))
end

return FriendSearchLayer

--endregion