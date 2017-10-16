-- region *.lua
-- Date
-- 此文件由[BabeLua]插件自动生成

local ChatLayer = class("ChatLayer", cc.load("mvc").ViewBase)

ChatLayer.TagBtnStatus = "game_chat"
ChatLayer.MaxInputLenght = 120     -- 输入框最大输入长度
ChatLayer.MaxMsgNum = 30    -- 最大存储数
ChatLayer.InputBoxRow = 3   -- 聊天输入框行数
ChatLayer.Target = cc.Application:getInstance():getTargetPlatform()
ChatLayer.fontHeight = 41

ChatLayer.ViewWidth = 580
ChatLayer.InputLabelWidth = 360.00
ChatLayer.InputLabelHeight = 40.00
ChatLayer.InputLabelFontSize = 36

ChatLayer.InputAddHeight = 40.00
ChatLayer.ListViewPosY = 110

function ChatLayer:onCreate()
    print("ChatLayer:onCreate")
    self.sendInfo_ = {}
    self.chatType_ = 1
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
    self:createClubBuyCell()
    self.runTime_ = cc.Director:getInstance():getScheduler():scheduleScriptFunc(function() self:updateCell() end, 1, false)

    bole:getClubManage():getClubInfo("getClubInfo_chat")
end
function ChatLayer:onKeyBack()
   self:backLayer()
end
function ChatLayer:onEnter()
    bole:addListener("getClubInfo_chat", self.initClubInfo_chat, self, nil, true)
    bole:addListener("addInfoInListView", self.addChatToView, self, nil, true)
    bole:addListener("addClubTaskCellToChat", self.addClubTaskToView, self, nil, true)
end

-- 初始化聊天记录
function ChatLayer:initChatListView()
    local chatTable = bole:getChatManage():getChatMsg(1)
    if chatTable ~= nil then
        for i = 1, #chatTable do
            self:addWidgetToListView(chatTable[i],true)
        end
    end

    chatTable = bole:getChatManage():getChatMsg(2)
    if chatTable ~= nil then
        for i = 1, #chatTable do
            self:addWidgetToListView(chatTable[i],true)
        end
    end
end


function ChatLayer:addChatToView(data)
    data = data.result
    if data.sender == bole:getUserDataByKey("user_id") then
        if self.sendInfo_[data.msg] ~= nil then
            self.sendInfo_[data.msg]:removeLoading()
            self.sendInfo_[data.msg] = nil
        end
    else
        self:addWidgetToListView(data)
    end

end

function ChatLayer:initTop(root)
    self.top_ = root:getChildByName("top")
    local btn_clubChat = self.top_:getChildByName("club_chat")
    btn_clubChat:addTouchEventListener(handler(self, self.touchEvent))
    local btn_gameChat = self.top_:getChildByName("game_chat")
    btn_gameChat:addTouchEventListener(handler(self, self.touchEvent))
    local btn_back = self.top_:getChildByName("btn_back")
    btn_back:addTouchEventListener(handler(self, self.touchEvent))

    if bole:getUserDataByKey("club") == 0 then
        btn_clubChat:setTouchEnabled(false)
    end

    self:refreshTagBtnStatus(btn_gameChat)
end

function ChatLayer:initMiddle(root)
    self.middle_ = root:getChildByName("middle")
    self.bg_ = root:getChildByName("middlebg")
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

    self.bottomBgSize_ = self.bottom_:getChildByName("bg"):getContentSize()
    self.bottomInputBgSize_ = self.bottom_:getChildByName("inputBg"):getContentSize()
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
            self.chatType_ = 2
        elseif name == "game_chat" then
            -- gamechat
            self.clubChatListView_:setVisible(false)
            self.chatListView_:setVisible(true)
            self:refreshTagBtnStatus(sender)
            self.clubBuyCell_:setVisible(false)
            self.chatType_ = 1
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
    btn_clubChat:getChildByName("txt"):setOpacity(117)
    btn_clubChat:getChildByName("icon"):setOpacity(117)

    if bole:getUserDataByKey("club") == 0 then
        btn_clubChat:setTouchEnabled(false)
    end
    local btn_gameChat = self.top_:getChildByName("game_chat")
    btn_gameChat:setBright(true)
    btn_gameChat:setTouchEnabled(true)
    btn_gameChat:getChildByName("txt"):setOpacity(117)
    btn_gameChat:getChildByName("icon"):setOpacity(117)

    btn:setBright(false)
    btn:setTouchEnabled(false)
    btn:getChildByName("txt"):setOpacity(255)
    btn:getChildByName("icon"):setOpacity(255)
end



-- 添加聊天信息
function ChatLayer:addWidgetToListView(chat,isInitMsg)
    local msg = chat.msg
    local chatWidget = bole:getEntity("app.views.chat.ChatCell", chat,isInitMsg)
    if chat.sender == bole:getUserDataByKey("user_id") then
        self.sendInfo_[msg] = chatWidget
    end

    if chat.c_type == 1 then
        self.chatListView_:pushBackCustomItem(chatWidget)
        if #self.chatListView_:getItems() > ChatLayer.MaxMsgNum then
            self.chatListView_:removeItem(0)
        end
        self.chatListView_:jumpToBottom()
    elseif chat.c_type == 2 then
        self.clubChatListView_:pushBackCustomItem(chatWidget)
        if #self.clubChatListView_:getItems() > ChatLayer.MaxMsgNum then
            self.clubChatListView_:removeItem(0)
        end
        self.clubChatListView_:jumpToBottom()
    end
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
    self.inputLabel_ = cc.Label:createWithTTF(" ", "font/bole_ttf.ttf", self.InputLabelFontSize)
    self.inputLabel_:setAnchorPoint(0, 0)
    self.inputLabel_:setPosition(0, 0)
    self.inputLabel_:setDimensions(self.InputLabelWidth, 0)
    self.inputLabel_:setHorizontalAlignment(0)
    -- 左对齐
    self.textListView_:addChild(self.inputLabel_)
    self.editBox_ = ccui.EditBox:create(cc.size(300, 30), "loadImage/editBox_bg.png")
    self.bottom_:getChildByName("Panel"):addChild(self.editBox_)
    self.editBox_:setAnchorPoint(0, 0)
    self.editBox_:setFontSize(36)
    self.editBox_:setFontColor(cc.c3b(255, 255, 255))
    self.editBox_:setInputMode(cc.EDITBOX_INPUT_MODE_SINGLELINE)
    self.editBox_:setInputFlag(cc.EDITBOX_INPUT_FLAG_INITIAL_CAPS_WORD)
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
        if self.moved_ < 5 then
            self.editBox_:touchDownAction(self.editBox_, 2)
            self.textListView_:scrollToBottom(0, true)
        end
        self.moved_ = 0
    elseif eventType == ccui.TouchEventType.canceled then
        
    end
end

function ChatLayer:refreshInputBox(str)
    self.inputLabel_:setString( bole:getNewStr(str, self.InputLabelFontSize, self.InputLabelWidth))
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
    print(height)
    if height > 50 and height <= self.fontHeight * 2 then
        if self.chatTextRow_ ~= 2 then
            self.chatTextRow_ = 2
            self.bottom_:getChildByName("bg"):setContentSize(self.bottomBgSize_.width, self.bottomBgSize_.height + self.InputAddHeight)
            self.bottom_:getChildByName("inputBg"):setContentSize(self.bottomInputBgSize_.width, self.bottomInputBgSize_.height + self.InputAddHeight)
            self.textListView_:setContentSize(self.InputLabelWidth, self.InputLabelHeight + self.InputAddHeight)
            self.textListView_:setInnerContainerSize(cc.size(self.InputLabelWidth, self.InputLabelHeight + self.InputAddHeight))
            self:upTextField(self.ListViewPosY + self.InputAddHeight,listView)
            listView:setContentSize(self.ViewWidth, listViewHeight - self.InputAddHeight)
            listView:jumpToBottom()
        end
    elseif height > self.fontHeight * 2 and height <= self.fontHeight * 3 then
        if self.chatTextRow_ ~= 3 then
            self.chatTextRow_ = 3
            self.bottom_:getChildByName("bg"):setContentSize(self.bottomBgSize_.width, self.bottomBgSize_.height + self.InputAddHeight * 2)
            self.bottom_:getChildByName("inputBg"):setContentSize(self.bottomInputBgSize_.width, self.bottomInputBgSize_.height + self.InputAddHeight * 2)
            self.textListView_:setContentSize(self.InputLabelWidth, self.InputLabelHeight + self.InputAddHeight * 2)
            self.textListView_:setInnerContainerSize(cc.size(self.InputLabelWidth, self.InputLabelHeight + self.InputAddHeight * 2))
            self:upTextField(self.ListViewPosY + self.InputAddHeight * 2,listView)
            listView:setContentSize(self.ViewWidth, listViewHeight - self.InputAddHeight * 2)
            listView:jumpToBottom()
        end
    elseif height > self.fontHeight * 3 and height <= self.fontHeight * 4 then
        if ChatLayer.InputBoxRow == 4 then
            if self.chatTextRow_ ~= 4 then
                self.chatTextRow_ = 4
                self.bottom_:getChildByName("bg"):setContentSize(self.bottomBgSize_.width, self.bottomBgSize_.height + self.InputAddHeight * 3)
                self.bottom_:getChildByName("inputBg"):setContentSize(self.bottomInputBgSize_.width, self.bottomInputBgSize_.height + self.InputAddHeight * 3)
                self.textListView_:setContentSize(self.InputLabelWidth, self.InputLabelHeight + self.InputAddHeight * 3)
                self.textListView_:setInnerContainerSize(cc.size(self.InputLabelWidth, self.InputLabelHeight + self.InputAddHeight * 3))
                self:upTextField(self.ListViewPosY + self.InputAddHeight * 3,listView)
                listView:setContentSize(self.ViewWidth, listViewHeight - self.InputAddHeight * 3)
                listView:jumpToBottom()
            end
        elseif ChatLayer.InputBoxRow == 3 then
            if self.chatTextRow_ ~= 4 then
                self.chatTextRow_ = 4
                self.bottom_:getChildByName("bg"):setContentSize(self.bottomBgSize_.width, self.bottomBgSize_.height + self.InputAddHeight * 2)
                self.bottom_:getChildByName("inputBg"):setContentSize(self.bottomInputBgSize_.width, self.bottomInputBgSize_.height + self.InputAddHeight * 2)
                self.textListView_:setContentSize(self.InputLabelWidth, self.InputLabelHeight + self.InputAddHeight * 2)
                self.textListView_:setInnerContainerSize(cc.size(self.InputLabelWidth, self.InputLabelHeight + self.InputAddHeight * 2))
                self:upTextField(self.ListViewPosY + self.InputAddHeight * 2,listView)
                listView:setContentSize(self.ViewWidth, listViewHeight - self.InputAddHeight * 2)
                listView:jumpToBottom()
            end
            self.textListView_:setInnerContainerSize(cc.size(self.InputLabelWidth, height))
            self.textListView_:scrollToBottom(0, true)
        end
    elseif height > self.fontHeight * 4 then
        if ChatLayer.InputBoxRow == 4 then
            if self.chatTextRow_ ~= 5 then
                self.chatTextRow_ = 5
                self.bottom_:getChildByName("bg"):setContentSize(self.bottomBgSize_.width, self.bottomBgSize_.height + self.InputAddHeight * 3)
                self.bottom_:getChildByName("inputBg"):setContentSize(self.bottomInputBgSize_.width, self.bottomInputBgSize_.height + self.InputAddHeight * 3)
                self.textListView_:setContentSize(self.InputLabelWidth, self.InputLabelHeight + self.InputAddHeight * 3)
                self:upTextField(self.ListViewPosY + self.InputAddHeight * 3,listView)
                listView:setContentSize(self.ViewWidth, listViewHeight - self.InputAddHeight * 3)
                listView:jumpToBottom()
            end
        end
        self.textListView_:setInnerContainerSize(cc.size(self.InputLabelWidth, height))
        self.textListView_:scrollToBottom(0, true)

    else
        if self.chatTextRow_ ~= 1 then
            self.chatTextRow_ = 1
            self.bottom_:getChildByName("bg"):setContentSize(self.bottomBgSize_.width, self.bottomBgSize_.height)
            self.bottom_:getChildByName("inputBg"):setContentSize(self.bottomInputBgSize_.width, self.bottomInputBgSize_.height)
            self.textListView_:setContentSize(self.InputLabelWidth, self.InputLabelHeight)
            self.textListView_:setInnerContainerSize(cc.size(self.InputLabelWidth, self.InputLabelHeight))
            self:upTextField(self.ListViewPosY,listView)
            listView:setContentSize(self.ViewWidth, listViewHeight)
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
            if not cc.rectContainsPoint(cc.rect(320, 95, 260, 350), touchPos) then
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
    self:createEmotionView()
    self:createChatView()
end

function ChatLayer:createEmotionView()
    for i = 1, 8 do
        local emotionWidget = ccui.Layout:create()
        emotionWidget:setContentSize(80,80)
        emotionWidget:setVisible(true)
        emotionWidget:setAnchorPoint(0,0)
        emotionWidget:setTouchEnabled(true)
        emotionWidget:setName("emotion")
        emotionWidget.tag = "#emotion" .. i
        emotionWidget:addTouchEventListener(handler(self, self.touchEvent))

        local skeletonNode = sp.SkeletonAnimation:create("emotion/skeleton.json", "emotion/skeleton.atlas")
        skeletonNode:setAnimation(0, i, true)
        skeletonNode:setPosition(cc.p(40,35))
        emotionWidget:addChild(skeletonNode,1)

        self.panelEmotion_:addChild(emotionWidget)
        if i <= 4 then
            emotionWidget:setPosition((i - 1) * 80, 100)
        else
            emotionWidget:setPosition((i - 5) * 80, 20)
        end
    end
end

function ChatLayer:createChatView()
    local message = bole:getConfigCenter():getConfig("short_message")
    local i = 0
    for k, v in pairs(message) do
        i = i + 1
        local sendWidget = self.panelSend_:getChildByName("txt_" .. i)
        if sendWidget ~= nil then
            sendWidget:getChildByName("txt"):setString(v.key_words)
            sendWidget:setVisible(true)
            sendWidget:setName("message")
            sendWidget.tag = v.message_texts
            sendWidget:addTouchEventListener(handler(self, self.touchEvent))
        end
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
        self.chatManage:removeChatLayer()
        self:removeFromParent()
        --]]
        self:setVisible(false)
    end
    bole:getChatManage():cleanNewMessageNum()
    self.chatView_:runAction(cc.Sequence:create(cc.MoveTo:create(0.2, cc.p(-720, 0)), cc.CallFunc:create(removeFunc)))


end

-- 创建键盘监听
function ChatLayer:createEventListenerKeyboard()
    local listener = cc.EventListenerKeyboard:create()
    local function onKeyReleased(keyCode, event)
        print(keyCode)
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

            if chatString == "+===+" then
                bole:setTestUser()
                return
            end

            if chatString == "-===-" then
                bole:removeTestUser()
                return
            end

            if chatString ~= "" then
                chatString = string.gsub(chatString, "\n", "")
                self:addWidgetToListView({ c_type = self.chatType_ , sender = bole:getUserDataByKey("user_id") , msg = chatString, isFormat = false , infoType = "chat"})
                bole.socket:send("chat", { c_type = self.chatType_ , msg = chatString })
            else
                print("非法输入")
            end
          
        end
    
        if str == "emotion" or str ==  "message" then
            self:addWidgetToListView({ c_type = self.chatType_ , sender = bole:getUserDataByKey("user_id") , msg = data, isFormat = false, infoType = "chat"})
            bole.socket:send("chat", { c_type = self.chatType_, msg = data })
      
            self.panelEmotion_:setVisible(false)
            self.panelSend_:setVisible(false)
        end


    end
end

function ChatLayer:onExit()
    bole:getEventCenter():removeEventWithTarget("addInfoInListView", self)
    bole:getEventCenter():removeEventWithTarget("getClubInfo_chat", self)
    bole:getEventCenter():removeEventWithTarget("addClubTaskCellToChat", self)
    
    if self.chatClubTaskCell_ ~= nil then
        self.chatClubTaskCell_:removeListener()
    end
    for _,v in pairs(self.chatListView_:getItems()) do
        if v.removeLoading ~= nil then
            v:removeLoading()
        end
    end
    if self.runTime_ ~= nil then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.runTime_)
    end
end

function ChatLayer:initClubInfo_chat(data)
    data = data.result
    if data.in_club == 1 then
        if self.addChatClubTaskCell_ then
            self.chatClubTaskCell_:refreshInfo(data.club_info)
            self.addChatClubTaskCell_ = false
            return
        end
        self.clubBuyCell_:refrushClubBuy(data.club_info)
        if data.club_info.rewards[1].collect ~= 0 then
           self.chatClubTaskCell_ = bole:getEntity("app.views.chat.ChatClubTaskCell")
           self.chatClubTaskCell_:refreshInfo(data.club_info)
           self.clubChatListView_:pushBackCustomItem(self.chatClubTaskCell_)
           self.clubChatListView_:jumpToBottom()
        end
    end
end

function ChatLayer:createClubBuyCell(data)
    if bole:getUserDataByKey("club") ~= 0 then
        self.clubBuyCell_ = bole:getEntity("app.views.club.ClubBuyCell","inChat")
        self.middle_:addChild(self.clubBuyCell_)
        self.clubBuyCell_:setPositionY(110 + self.clubChatListViewHeight_ + 20)
        self.clubBuyCell_:setVisible(false)
    end
end

-- 适配
function ChatLayer:adaptScreen(root)
    local winSize = cc.Director:getInstance():getWinSize()
    local test = cc.Director:getInstance():getOpenGLView():getFrameSize()
    self.bottom_:setPosition(0, 0)
    self.middle_:setPosition(0, 0)
    self.middle_:setContentSize(self.ViewWidth, winSize.height - 62)
    self.top_:setPosition(0, winSize.height)
    self.bg_:setContentSize(self.ViewWidth, winSize.height)
    self.chatListViewHeight_ = winSize.height - self.ListViewPosY - 62 - 15
    self.clubChatListViewHeight_ = winSize.height - self.ListViewPosY - 62 - 15 - 110
    self.chatListView_:setPosition(0, self.ListViewPosY)
    self.chatListView_:setContentSize(self.ViewWidth, self.chatListViewHeight_)
    self.clubChatListView_:setPosition(0, self.ListViewPosY)
    self.clubChatListView_:setContentSize(self.ViewWidth, self.clubChatListViewHeight_)
    
    self.chatView_:setContentSize(640,winSize.height)
    root:setContentSize(640,winSize.height)
    self.touchPanel_:setContentSize(640,winSize.height)
end

function ChatLayer:updateCell()
    for _,v in pairs(self.chatListView_:getItems()) do
        if v.update ~= nil then
            v:update()
        end
    end
end

function ChatLayer:addClubTaskToView(data)
   if self.chatClubTaskCell_ ~= nil then
        self.chatClubTaskCell_:removeFromParent()
        self.chatClubTaskCell_ = nil
   end
   if self.clubChatListView_ ~= nil then
       self.chatClubTaskCell_ = bole:getEntity("app.views.chat.ChatClubTaskCell")
       self.clubChatListView_:pushBackCustomItem(self.chatClubTaskCell_)
       self.clubChatListView_:jumpToBottom()
       self.addChatClubTaskCell_ = true
       bole:getClubManage():getClubInfo("getClubInfo_chat")
   end
end


return ChatLayer

-- endregion

