-- region *.lua
-- Date
-- 此文件由[BabeLua]插件自动生成

local ChatLayer = class("ChatLayer", cc.load("mvc").ViewBase)

ChatLayer.TagBtnStatus = "game_chat"
ChatLayer.MaxInputLenght = 120     -- 输入框最大输入长度
ChatLayer.MaxMsgNum = 30    -- 最大存储数
ChatLayer.InputBoxRow = 3   -- 聊天输入框行数
ChatLayer.Target = cc.Application:getInstance():getTargetPlatform()

function ChatLayer:onCreate()
    print("ChatLayer:onCreate")
    local root = self:getCsbNode():getChildByName("root")

    self.touchPanel_ = root:getChildByName("Panel_touch")
    self.touchPanel_:setVisible(false)

    local chatView = root:getChildByName("panel_chat")
    chatView:setPositionX(-720)
    chatView:stopAllActions()
    self:initTop(chatView)
    self:initMiddle(chatView)
    self:initBottom(chatView)
    self.chatView_ = chatView

    -- 适配
    self:adaptScreen(root)
    if bole:getUserDataByKey("club") ~= 0 then
        self:createClubBuyCell()
    end
    self.runTime_ = cc.Director:getInstance():getScheduler():scheduleScriptFunc(function() self:updateCell() end, 1, false)
    bole.socket:send("enter_club_lobby", { }, true)
end

function ChatLayer:onEnter()
    self.sendInfo_ = {}
    bole.socket:registerCmd("enter_club_lobby", self.reClub, self)
    bole:addListener("addChatToView", self.addChatToView, self, nil, true)
end

-- 初始化聊天记录
function ChatLayer:initChatListView()
    self.chatManager = bole:getInstance("app.views.chat.ChatManager")
    local chatTable = self.chatManager:getChatMsg()
    if chatTable ~= nil then
        for i = 1, #chatTable do
            if tonumber(chatTable[i].id) == tonumber(bole:getUserDataByKey("user_id")) then
                --self:addWidgetToListView(nil, chatTable[i].msg, chatTable[i])
            else
                self:addWidgetToListView(chatTable[i].id, chatTable[i].msg, chatTable[i])
            end
        end
    end
end

-- 聊天接收
function ChatLayer:reChat(t, chat)
    if t == "chat" then
        if chat.msg ~= nil then
            local msg = chat.msg
            if tonumber(chat.id) == tonumber(bole:getUserDataByKey("user_id")) then
                --self:addWidgetToListView(nil, msg, chat)
                dump(self.sendInfo_,"self.sendInfo_")
                if self.sendInfo_[msg] ~= nil then
                    self.sendInfo_[msg]:removeLoading()
                    self.sendInfo_[msg] = nil
                end
            else
                self:addWidgetToListView(chat.id, msg, chat)
            end
        end
    end
end

function ChatLayer:addChatToView(data)
    data = data.result
    self:reChat(data[1], data[2])
end

function ChatLayer:initTop(root)
    self.top_ = root:getChildByName("top")
    local btn_clubChat = self.top_:getChildByName("club_chat")
    btn_clubChat:addTouchEventListener(handler(self, self.touchEvent))
    btn_clubChat:getChildByName("text"):setString("CLUB CHAT")
    local btn_gameChat = self.top_:getChildByName("game_chat")
    btn_gameChat:addTouchEventListener(handler(self, self.touchEvent))
    btn_gameChat:getChildByName("text"):setString("GAME CHAT")
    local btn_back = self.top_:getChildByName("btn_back")
    btn_back:addTouchEventListener(handler(self, self.touchEvent))

    if bole:getUserDataByKey("club") == 0 then
        btn_clubChat:setTouchEnabled(false)
    end

    self:refreshTagBtnStatus(btn_gameChat)
end

function ChatLayer:initMiddle(root)
    self.middle_ = root:getChildByName("middle")
    self.bg_ = self.middle_:getChildByName("middlebg")
    self.chatListView_ = self.middle_:getChildByName("listView_chat")
    self.chatListView_:setScrollBarOpacity(0)
    self.clubChatListView_ =  self.middle_:getChildByName("listView_chat_club")
    self.clubChatListView_:setScrollBarOpacity(0)
    self:initChatListView()
end

function ChatLayer:initBottom(root)
    self.bottom_ = root:getChildByName("bottom")

    self.inputBg_ = self.bottom_:getChildByName("inputBg")
    self.inputBg_:addTouchEventListener(handler(self, self.inputBoxTouchEvent))

    self.textListView_ = self.bottom_:getChildByName("textListView")
    self.textListView_:setScrollBarOpacity(0)
    self.textListView_:addTouchEventListener(handler(self, self.inputBoxTouchEvent))

    local btn_sendChat = self.bottom_:getChildByName("btn_send")
    btn_sendChat:addTouchEventListener(handler(self, self.touchEvent))
    self.panelSend_ = self.bottom_:getChildByName("Panel_send")

    local btn_sendEmotion = self.bottom_:getChildByName("btn_emotion")
    btn_sendEmotion:addTouchEventListener(handler(self, self.touchEvent))
    self.panelEmotion_ = self.bottom_:getChildByName("Panel_emotion")

    -- 初始化输入框
    self:initInputBox()
    -- 初始化快捷聊天，表情
    self:initEmotion()
end

-- 聊天界面按钮
function ChatLayer:touchEvent(sender, eventType)
    local name = sender:getName()
    if eventType == ccui.TouchEventType.began then

    elseif eventType == ccui.TouchEventType.moved then

    elseif eventType == ccui.TouchEventType.ended then
        if name == "btn_send" then
            -- 快捷语发送
            if not self.panelSend_:isVisible() then
                self.panelEmotion_:stopAllActions()
                self.panelEmotion_:setScale(1)
                self.panelEmotion_:setVisible(false)
                self.panelSend_:setScale(0.1)
                self.panelSend_:setVisible(true)
                self.panelSend_:runAction(cc.ScaleTo:create(0.1, 1, 1))
            end
        elseif name == "btn_emotion" then
            -- 表情
            if not self.panelEmotion_:isVisible() then
                self.panelSend_:stopAllActions()
                self.panelSend_:setScale(1)
                self.panelSend_:setVisible(false)
                self.panelEmotion_:setScale(0.1)
                self.panelEmotion_:setVisible(true)
                self.panelEmotion_:runAction(cc.ScaleTo:create(0.1, 1, 1))
            end
        elseif name == "root" or name == "btn_back" then
            -- 退出
            self:backLayer()
        elseif name == "club_chat" then
            -- clubchat
            self.clubChatListView_:setVisible(true)
            self.chatListView_:setVisible(false)
            self:refreshTagBtnStatus(sender)
            self.clubBuyCell_:setVisible(true)
        elseif name == "game_chat" then
            -- gamechat
            self.clubChatListView_:setVisible(false)
            self.chatListView_:setVisible(true)
            self:refreshTagBtnStatus(sender)
            self.clubBuyCell_:setVisible(false)
        elseif name == "emotion" then
            self:sendChatContent("emotion",sender.tag)
        elseif name == "message" then
            self:sendChatContent("message",sender.tag)
        end
    elseif eventType == ccui.TouchEventType.canceled then

    end
end

-- 刷新标签按钮状态
function ChatLayer:refreshTagBtnStatus(btn)
    local btn_clubChat = self.top_:getChildByName("club_chat")
    btn_clubChat:setBright(true)
    btn_clubChat:setTouchEnabled(true)
    btn_clubChat:getChildByName("text"):setTextColor( { r = 146, g = 171, b = 230 })
    if bole:getUserDataByKey("club") == 0 then
        btn_clubChat:setTouchEnabled(false)
    end
    local btn_gameChat = self.top_:getChildByName("game_chat")
    btn_gameChat:setBright(true)
    btn_gameChat:setTouchEnabled(true)
    btn_gameChat:getChildByName("text"):setTextColor( { r = 146, g = 171, b = 230 })
    btn:setBright(false)
    btn:setTouchEnabled(false)
    btn:getChildByName("text"):setTextColor( { r = 227, g = 254, b = 255 })
end



-- 添加聊天信息
function ChatLayer:addWidgetToListView(uid, chatString, chatTable)
    local chatWidget = bole:getEntity("app.views.chat.ChatCell", uid, chatString, chatTable)
    if uid == nil then
        self.sendInfo_[chatString] = chatWidget
    end
    if chatTable.chatType == 1 then
        self.chatListView_:pushBackCustomItem(chatWidget)
        if #self.chatListView_:getItems() > ChatLayer.MaxMsgNum then
            self.chatListView_:removeItem(0)
        end
        self.chatListView_:jumpToBottom()
    elseif chatTable.chatType == 2 then
        self.clubChatListView_:pushBackCustomItem(chatWidget)
        if #self.clubChatListView_:getItems() > ChatLayer.MaxMsgNum then
            self.clubChatListView_:removeItem(0)
        end
        self.clubChatListView_:jumpToBottom()
    end
end

-- 在过长字符中间加入'\n'
-- str 字符串
-- fontSize 字符大小
-- maxLen 每行最大长度
function ChatLayer:getNewStr(str, fontSize, maxLen)
    -- 待优化
    str = str or ""
    fontSize = fontSize or 28
    maxLen = maxLen or 446
    local t = string.split(str, " ")
    local newStr = ""
    for i = 1, #t do
        if cc.Label:createWithTTF(t[i], "res/font/FZKTJW.TTF", fontSize):getContentSize().width > maxLen then
            local idex = 1
            local time = 0
            for ii = 1, string.len(t[i]) do
                local len = cc.Label:createWithTTF(string.sub(t[i], idex, ii + time), "res/font/FZKTJW.TTF", fontSize):getContentSize().width
                if len > maxLen then
                    t[i] = string.sub(t[i], 1, ii + time - 1) .. "\n" .. string.sub(t[i], ii + time, -1)
                    len = 0
                    idex = ii + 1
                    time = time + 1
                end
            end
        end
        if i == 1 then
            newStr = newStr .. t[i]
        else
            newStr = newStr .. " " .. t[i]
        end
    end
    return newStr
end

function ChatLayer:editBoxHandEvent(eventName, sender)
    if eventName == "began" then
        self.touchPanel_:setVisible(true)
        self.touchPanel_:stopAllActions()
        if self.panelEmotion_:isVisible() then
            self.panelEmotion_:setVisible(false)
        end
        if self.panelSend_:isVisible() then
            self.panelEmotion_:setVisible(false)
        end
    elseif eventName == "ended" then
        local function func()
            self.touchPanel_:setVisible(false)
        end
        local delay = cc.DelayTime:create(0.2)
        local sequence = cc.Sequence:create(delay, cc.CallFunc:create(func))
        self.touchPanel_:runAction(sequence)
    elseif eventName == "return" then
        self:refreshInputBox(sender:getText())
    elseif eventName == "changed" then
        self:refreshInputBox(sender:getText())
    end
end

-- 自定义输入框
function ChatLayer:initInputBox()
    self.chatTextRow_ = 0
    self.inputLabel_ = cc.Label:createWithTTF(" ", "res/font/FZKTJW.TTF", 36)
    self.inputLabel_:setAnchorPoint(0, 0)
    self.inputLabel_:setPosition(0, 0)
    self.inputLabel_:setDimensions(446, 0)
    self.inputLabel_:setHorizontalAlignment(0)
    -- 左对齐
    self.textListView_:addChild(self.inputLabel_)
    self.editBox_ = ccui.EditBox:create(cc.size(486, 64), "res/chat/chat_input.png")
    self.bottom_:getChildByName("Panel"):addChild(self.editBox_)
    self.editBox_:setAnchorPoint(0, 0)
    self.editBox_:setFontSize(36)
    self.editBox_:setFontColor(cc.c3b(255, 255, 255))
    self.editBox_:setInputMode(cc.EDITBOX_INPUT_MODE_SINGLELINE)
    self.editBox_:setMaxLength(ChatLayer.MaxInputLenght)
    self.editBox_:setPosition(20, 15)
    self.editBox_:setReturnType(cc.KEYBOARD_RETURNTYPE_SEND)
    self.editBox_:registerScriptEditBoxHandler(handler(self, self.editBoxHandEvent))
    self.editBox_:setPosition(1, 0)
    self.editBox_:setContentSize(200, 30)
    self.editBox_:setFontSize(0.001)

    -- 创建键盘监听
    self:createEventListenerKeyboard()
end

function ChatLayer:inputBoxTouchEvent(sender, eventType)
    if eventType == ccui.TouchEventType.began then
        self.moved_ = 0
    elseif eventType == ccui.TouchEventType.moved then
        self.moved_ = self.moved_ + 1
    elseif eventType == ccui.TouchEventType.ended then
        if self.moved_ < 8 then
            self.editBox_:touchDownAction(self.editBox_, 2)
            self.textListView_:scrollToBottom(0, true)
        end
        self.moved_ = 0
    elseif eventType == ccui.TouchEventType.canceled then
    end
end

function ChatLayer:refreshInputBox(str)
    self.inputLabel_:setString(self:getNewStr(str, 36, 458))
    -- print(self.inputLabel_:getString())
    local height = self.inputLabel_:getContentSize().height

    local listView = self.chatListView_
    local listViewHeight = self.chatListViewHeight_
    if self.chatListView_:isVisible() then
        listView = self.chatListView_
        listViewHeight = self.chatListViewHeight_
    elseif self.clubChatListView_:isVisible() then
        listView = self.clubChatListView_
        listViewHeight = self.clubChatListViewHeight_
    end

    if height > 50 and height <= 78 then
        if self.chatTextRow_ ~= 2 then
            self.chatTextRow_ = 2
            self.bottom_:getChildByName("bg"):setContentSize(670, 130)
            self.bottom_:getChildByName("inputBg"):setContentSize(486, 104)
            self.textListView_:setContentSize(460, 80)
            self.textListView_:setInnerContainerSize(cc.size(460, 80))
            self:upTextField(140,listView)
            listView:setContentSize(670, listViewHeight - 40)
            listView:jumpToBottom()
        end
    elseif height > 78 and height <= 117 then
        if self.chatTextRow_ ~= 3 then
            self.chatTextRow_ = 3
            self.bottom_:getChildByName("bg"):setContentSize(670, 170)
            self.bottom_:getChildByName("inputBg"):setContentSize(486, 144)
            self.textListView_:setContentSize(460, 120)
            self.textListView_:setInnerContainerSize(cc.size(460, 120))
            self:upTextField(180,listView)
            listView:setContentSize(670, listViewHeight - 80)
            listView:jumpToBottom()
        end
    elseif height > 117 and height <= 156 then
        if ChatLayer.InputBoxRow == 4 then
            if self.chatTextRow_ ~= 4 then
                self.chatTextRow_ = 4
                self.bottom_:getChildByName("bg"):setContentSize(670, 210)
                self.bottom_:getChildByName("inputBg"):setContentSize(486, 184)
                self.textListView_:setContentSize(460, 160)
                self.textListView_:setInnerContainerSize(cc.size(460, 160))
                self:upTextField(220,listView)
                listView:setContentSize(670, listViewHeight - 120)
                listView:jumpToBottom()
            end
        elseif ChatLayer.InputBoxRow == 3 then
            if self.chatTextRow_ ~= 4 then
                self.chatTextRow_ = 4
                self.bottom_:getChildByName("bg"):setContentSize(670, 170)
                self.bottom_:getChildByName("inputBg"):setContentSize(486, 144)
                self.textListView_:setContentSize(460, 120)
                self.textListView_:setInnerContainerSize(cc.size(460, 120))
                self:upTextField(180,listView)
                listView:setContentSize(670, listViewHeight - 80)
                listView:jumpToBottom()
            end
            self.textListView_:setInnerContainerSize(cc.size(460, height))
            self.textListView_:scrollToBottom(0, true)
        end
    elseif height > 156 then
        if ChatLayer.InputBoxRow == 4 then
            if self.chatTextRow_ ~= 5 then
                self.chatTextRow_ = 5
                self.bottom_:getChildByName("bg"):setContentSize(670, 210)
                self.bottom_:getChildByName("inputBg"):setContentSize(486, 184)
                self.textListView_:setContentSize(460, 160)
                self:upTextField(220,listView)
                listView:setContentSize(670, listViewHeight - 120)
                listView:jumpToBottom()
            end
        end
        self.textListView_:setInnerContainerSize(cc.size(460, height))
        self.textListView_:scrollToBottom(0, true)

    else
        if self.chatTextRow_ ~= 1 then
            self.chatTextRow_ = 1
            self.bottom_:getChildByName("bg"):setContentSize(670, 90)
            self.bottom_:getChildByName("inputBg"):setContentSize(486, 64)
            self.textListView_:setContentSize(460, 40)
            self.textListView_:setInnerContainerSize(cc.size(460, 40))
            self:upTextField(100,listView)
            listView:setContentSize(670, listViewHeight)
            listView:jumpToBottom()
        end
    end
end

-- 上移聊天界面
function ChatLayer:upTextField(posY,listView)
    posY = posY or listView:getPositionY()
    listView:setPosition(listView:getPositionX(), posY)
end

-- 初始化快捷聊天，表情
function ChatLayer:initEmotion()
    local layer = cc.Layer:create()
    local function onTouchBegin(touch, event)
        return true
    end
    local function onTouchMove(touch, event)

    end
    local function onTouchEnd(touch, event)
        local touchPos = touch:getLocation()
        if self.panelEmotion_:isVisible() then
            if not cc.rectContainsPoint(cc.rect(0, 70, 680, 100), touchPos) then
                self.panelEmotion_:setVisible(false)
            end
        end
        if self.panelSend_:isVisible() then
            if not cc.rectContainsPoint(cc.rect(400, 70, 280, 380), touchPos) then
                self.panelSend_:setVisible(false)
            end
        end
    end
    self.touchListener_ = cc.EventListenerTouchOneByOne:create()
    self.touchListener_:registerScriptHandler(onTouchBegin, cc.Handler.EVENT_TOUCH_BEGAN)
    self.touchListener_:registerScriptHandler(onTouchMove, cc.Handler.EVENT_TOUCH_MOVED)
    self.touchListener_:registerScriptHandler(onTouchEnd, cc.Handler.EVENT_TOUCH_ENDED)
    self:getEventDispatcher():addEventListenerWithSceneGraphPriority(self.touchListener_, layer);
    self:addChild(layer)

    -- TODO初始化表情,快捷语句
    self.emotionListView_ = self.panelEmotion_:getChildByName("ListView")
    self.emotionListView_:setScrollBarOpacity(0)
    self:createEmotionView()
    self.sendListView_ = self.panelSend_:getChildByName("ListView")
    self.sendListView_:setScrollBarOpacity(0)
    self:createChatView()
end

function ChatLayer:createEmotionView()
    for i = 1, 8 do
        local emotionWidget = ccui.Layout:create()
        --self.panelEmotion_:getChildByName("emotion"):clone()
        emotionWidget:setContentSize(80,70)
        emotionWidget:setVisible(true)
        emotionWidget:setTouchEnabled(true)
        emotionWidget:setName("emotion")
        --[[
        local image = ccui.ImageView:create()
        image:setName("Image")
        image:setPosition(40,35)
        emotionWidget:addChild(image)
        emotionWidget:getChildByName("Image"):loadTexture("res/chat/chat_button_emotion.png")
        --emotionWidget:getChildByName("Image"):loadTexture("res/emotion/" .. i ..  ".png")
        --]]
        emotionWidget.tag = "#emotion" .. i
        emotionWidget:addTouchEventListener(handler(self, self.touchEvent))


        local skeletonNode = sp.SkeletonAnimation:create("emotion/skeleton.json", "emotion/skeleton.atlas")
        skeletonNode:setAnimation(0, i, true)
        skeletonNode:setPosition(cc.p(40,35))
        emotionWidget:addChild(skeletonNode,1)


        self.emotionListView_:pushBackCustomItem(emotionWidget)
    end
end

function ChatLayer:createChatView()
    local message = bole:getConfigCenter():getConfig("short_message")
    for k, v in pairs(message) do
        local sendWidget = self.panelSend_:getChildByName("send"):clone()
        sendWidget:setVisible(true)
        sendWidget:setName("message")
        sendWidget.tag = v.message_texts
        sendWidget:getChildByName("Text"):setString(v.key_words)
        sendWidget:addTouchEventListener(handler(self, self.touchEvent))
        self.sendListView_:pushBackCustomItem(sendWidget)
    end
end

-- 退出
function ChatLayer:backLayer()

    local removeFunc = function()
        -- 移除监听
        --[[
        if self.touchListener_ ~= nil then
            self:getEventDispatcher():removeEventListener(self.touchListener_)
            self.touchListener_ = nil
        end
        self.chatManager:removeChatLayer()
        self:removeFromParent()
        --]]
        self:setVisible(false)
    end

    self.chatView_:runAction(cc.Sequence:create(cc.MoveTo:create(0.2, cc.p(-720, 0)), cc.CallFunc:create(removeFunc)))


end

-- 创建键盘监听
function ChatLayer:createEventListenerKeyboard()
    local listener = cc.EventListenerKeyboard:create()
    local function onKeyReleased(keyCode, event)
        if keyCode == 164 then
            self:sendChatContent("str")
        end
       
    end
    listener:registerScriptHandler(onKeyReleased, cc.Handler.EVENT_KEYBOARD_RELEASED)
    cc.Director:getInstance():getEventDispatcher():addEventListenerWithSceneGraphPriority(listener, self)
end

-- 发送聊天信息
function ChatLayer:sendChatContent(str,data)

    local isSend = false
    if self.preSendTime_ == nil then
        self.preSendTime_ = os.time()
        isSend = true
    else
        if os.time() - self.preSendTime_ >= 2 then
            self.preSendTime_ = os.time()
            isSend = true
        end
    end
   
    if isSend then   
        if str == "str" then 
            local chatString = ""
            chatString = self.inputLabel_:getString()
            self.inputLabel_:setString("")
            self.editBox_:setText("")
            self:refreshInputBox("")
            if chatString ~= "" then
                chatString = string.gsub(chatString, "\n", "")
                local t = 1
                if self.chatListView_:isVisible() then
                    t = 1
                elseif self.clubChatListView_:isVisible() then
                    t = 2
                end
                self:addWidgetToListView(nil, chatString,{ type = "chat" , chatType = t, id = bole:getUserDataByKey("user_id") , msg = chatString, isFormat = false})
                bole.socket:send("chat", { c_type = t, msg = chatString })
            else
                print("非法输入")
            end
          
        end
    
        if str == "emotion" or str ==  "message" then
           local t = 1
           if self.chatListView_:isVisible() then
                t = 1
           elseif self.clubChatListView_:isVisible() then
                t = 2
           end
            self:addWidgetToListView(nil, data,{ type = "chat" , chatType = t, id = bole:getUserDataByKey("user_id") , msg = data, isFormat = false})
            bole.socket:send("chat", { c_type = t, msg = data })
      
            self.panelEmotion_:setVisible(false)
            self.panelSend_:setVisible(false)
        end
    
    end
    
end

function ChatLayer:onExit()
    bole:getEventCenter():removeEventWithTarget("addChatToView", self)
    bole.socket:unregisterCmd("enter_club_lobby")
    for _,v in pairs(self.chatListView_:getItems()) do
        if v.removeLoading ~= nil then
            v:removeLoading()
        end
    end
    if self.runTime_ ~= nil then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.runTime_)
    end
end

function ChatLayer:reClub(t,data)
    if data.in_club == 1 then
        self.clubBuyCell_:refrushClubBuy(data.club_info)
    end
end

function ChatLayer:createClubBuyCell(data)
    self.clubBuyCell_ = bole:getEntity("app.views.club.ClubBuyCell",data,"inChat")
    self.middle_:addChild(self.clubBuyCell_)
    self.clubBuyCell_:setPositionY(110 + self.clubChatListViewHeight_)
    self.clubBuyCell_:setVisible(false)
end

-- 适配
function ChatLayer:adaptScreen(root)
    local winSize = cc.Director:getInstance():getWinSize()
    local test = cc.Director:getInstance():getOpenGLView():getFrameSize()
    self.bottom_:setPosition(0, 0)
    self.middle_:setPosition(0, 0)
    self.middle_:setContentSize(670, winSize.height - 62)
    self.top_:setPosition(0, winSize.height)
    self.bg_:setContentSize(670, winSize.height - 62)
    self.chatListViewHeight_ = winSize.height - 100 - 62 - 15
    self.clubChatListViewHeight_ = winSize.height - 100 - 62 - 15 - 110
    self.chatListView_:setPosition(0, 100)
    self.chatListView_:setContentSize(670, self.chatListViewHeight_)
    self.clubChatListView_:setPosition(0, 100)
    self.clubChatListView_:setContentSize(670, self.clubChatListViewHeight_)
    
    root:setContentSize(winSize)
    self.touchPanel_:setContentSize(winSize)
end

function ChatLayer:updateCell()
    for _,v in pairs(self.chatListView_:getItems()) do
        if v.update ~= nil then
            v:update()
        end
    end
    for _,v in pairs(self.clubChatListView_:getItems()) do
        if v.update ~= nil then
            v:update()
        end
    end
end




return ChatLayer

-- endregion

