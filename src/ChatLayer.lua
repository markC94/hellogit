--region *.lua
--Date
--此文件由[BabeLua]插件自动生成

local ChatLayer = class("ChatLayer", cc.load("mvc").ViewBase)

ChatLayer.TagBtnStatus = "game_chat"
ChatLayer.InputBox = 3     --输入框种类 1.textField   2.editBox  3.自定义
ChatLayer.MaxInputLenght = 120     --输入框最大输入长度
ChatLayer.MaxMsgNum = 30    --最大存储数
ChatLayer.InputBoxRow = 3   --聊天输入框行数
ChatLayer.Target = cc.Application:getInstance():getTargetPlatform()


function ChatLayer:onCreate()
    print("ChatLayer:onCreate")
   
    self.root_ = self:getCsbNode():getChildByName("root")
    self.touchPanel_ = self.root_:getChildByName("Panel_touch")
    self.touchPanel_:setVisible(false)
    self.chatPanel_ = self.root_:getChildByName("panel_chat")
    self.chatPanel_:setPositionX(-720)
    self.chatPanel_:stopAllActions()
    self.chatPanel_:runAction(cc.MoveTo:create(0.2,cc.p(0,0)))
    self.top_ = self.chatPanel_:getChildByName("top") 
    self.middle_ = self.chatPanel_:getChildByName("middle")
    self.bg_ = self.middle_:getChildByName("middlebg")
    self.chatListView_ = self.middle_:getChildByName("listView_chat")
    self.chatListView_:setScrollBarOpacity(0)
    self.bottom_ = self.chatPanel_:getChildByName("bottom")

    self.clubChatBtn_ = self.top_:getChildByName("club_chat")
    self.clubChatBtn_:addTouchEventListener(handler(self, self.touchEvent))
    self.gameChatBtn_ = self.top_:getChildByName("game_chat")
    self.gameChatBtn_:addTouchEventListener(handler(self, self.touchEvent))
    self.backBtn_ = self.top_:getChildByName("btn_back")
    self.backBtn_:addTouchEventListener(handler(self, self.touchEvent))

    self.chatTextField_ = self.bottom_:getChildByName("TextField")
    self.inputBg_ = self.bottom_:getChildByName("inputBg")
    self.textListView_ = self.bottom_:getChildByName("textListView")
    self.textListView_:setScrollBarOpacity(0)

    self.guangbiao_ = self.bottom_:getChildByName("guangbiao")
    self.guangbiao_:setVisible(false)

    self.sendChatBtn_ = self.bottom_:getChildByName("btn_send")
    self.panelSend_ = self.bottom_:getChildByName("Panel_send")
    self.sendChatBtn_:addTouchEventListener(handler(self, self.touchEvent))
    self.emotionBtn_ = self.bottom_:getChildByName("btn_emotion")
    self.panelEmotion_ = self.bottom_:getChildByName("Panel_emotion")
    self.emotionBtn_:addTouchEventListener(handler(self, self.touchEvent))

    --self.root_:addTouchEventListener(handler(self, self.touchEvent))

    self:refreshTagBtnStatus(self.gameChatBtn_)

    --适配
    self:adaptScreen()                                  

    --初始化输入框
    if ChatLayer.InputBox == 1 then
        self:initTextField()
    elseif ChatLayer.InputBox == 2 then
        self:initEditBox()
    elseif ChatLayer.InputBox == 3 then
        self:initInputBox()
    end

    --初始化快捷聊天，表情
    self:initEmotion()

    self.chatManager = bole:getInstance("app.views.chat.ChatManager")
    self.chatManager:setChatLayer(self)

    --初始化聊天信息
    self:initChatListView()

    --创建键盘监听
    self:createEventListenerKeyboard()  
    
end

--初始化聊天记录
function ChatLayer:initChatListView()
    local chatTable = self.chatManager:getChatMsg()
    if chatTable ~= nil then
        for i = 1, # chatTable do
            if tonumber(chatTable[i].id) == tonumber(bole:getUserDataByKey("user_id")) then
                self:addWidgetToListView(nil,chatTable[i].msg,chatTable[i])
            else
                self:addWidgetToListView(chatTable[i].id,chatTable[i].msg,chatTable[i])
            end
        end
    end
end

--聊天接收
function ChatLayer:reChat(t, chat)
    if t == "chat" then
        if chat.msg ~= nil then
            local msg = chat.msg
            if tonumber(chat.id) ==  tonumber(bole:getUserDataByKey("user_id")) then
                self:addWidgetToListView(nil,msg,chat)
            else
                self:addWidgetToListView(chat.id,msg,chat)
            end
        end
    end
end

--聊天界面按钮
function ChatLayer:touchEvent(sender, eventType)
   local name = sender:getName()
   if eventType == ccui.TouchEventType.began then
   
    elseif eventType == ccui.TouchEventType.moved then

    elseif eventType == ccui.TouchEventType.ended then
        if name == "btn_send" then --快捷语发送
            if not self.panelSend_:isVisible() then
                self.panelEmotion_:stopAllActions()
                self.panelEmotion_:setScale(1)
                self.panelEmotion_:setVisible(false)
                self.panelSend_:setScale(0.1)
                self.panelSend_:setVisible(true)
                self.panelSend_:runAction(cc.ScaleTo:create(0.1,1,1))
            end
        elseif name == "btn_emotion" then --表情
            if not self.panelEmotion_:isVisible() then
                self.panelSend_:stopAllActions()
                self.panelSend_:setScale(1)
                self.panelSend_:setVisible(false)
                self.panelEmotion_:setScale(0.1)
                self.panelEmotion_:setVisible(true)
                self.panelEmotion_:runAction(cc.ScaleTo:create(0.1,1,1))
            end
        elseif name == "root" or name == "btn_back" then --退出
            self:backLayer() 
        elseif name == "club_chat" then --clubchat
            self:refreshTagBtnStatus(self.clubChatBtn_)
        elseif name == "game_chat" then --gamechat
            self:refreshTagBtnStatus(self.gameChatBtn_)
        elseif name == "emotion" then
            bole.socket:send("chat", { c_type = 1, msg = sender.tag })
            self.panelEmotion_:setVisible(false)
            self.panelSend_:setVisible(false)
        end
    elseif eventType == ccui.TouchEventType.canceled then

    end
end

--刷新标签按钮状态
function ChatLayer:refreshTagBtnStatus(btn)
    self.clubChatBtn_:setBright(true)
    self.clubChatBtn_:setTouchEnabled(true)
    self.clubChatBtn_:getChildByName("text"):setTextColor({ r = 146, g = 171, b = 230})
    self.gameChatBtn_:setBright(true)
    self.gameChatBtn_:setTouchEnabled(true)
    self.gameChatBtn_:getChildByName("text"):setTextColor({ r = 146, g = 171, b = 230})
    btn:setBright(false)
    btn:setTouchEnabled(false)
    btn:getChildByName("text"):setTextColor({ r = 227, g = 254, b = 255})
end

--发送聊天信息
function ChatLayer:sendChatContent()
    local chatString = ""
    if ChatLayer.InputBox == 1 then
        chatString = self.chatTextField_:getString()
        self.chatTextField_:setString("")
        self:refreshCursorPos()
    elseif ChatLayer.InputBox == 2 then
        chatString = self.editBox_:getText()
        self.editBox_:setText("")
    elseif ChatLayer.InputBox == 3 then
        chatString = self.inputLabel_:getString()
        self.inputLabel_:setString("")
        self.editBox_:setText("")
        self:refreshInputBox("")
    end

    if chatString ~= "" then   --TODO非法输入
        chatString = string.gsub(chatString, "\n", "")
        bole.socket:send("chat", { c_type = 1, msg = chatString })
    else
        print("非法输入")
    end
end

--添加聊天信息
function ChatLayer:addWidgetToListView(uid,chatString,chatTable)
    local chatWidget = self:createChatWidget(uid,chatString,chatTable)
    self.chatListView_:pushBackCustomItem(chatWidget)
    if # self.chatListView_:getItems() > ChatLayer.MaxMsgNum  then
        self.chatListView_:removeItem(0)
    end
    self.chatListView_:jumpToBottom()
end

--在过长字符中间加入'\n'
--str 字符串
--fontSize 字符大小
--maxLen 每行最大长度
function ChatLayer:getNewStr(str, fontSize, maxLen)
--待优化
    str = str or ""
    fontSize = fontSize or 28
    maxLen = maxLen or 446
    local t = string.split(str," ")
    local newStr = ""
    for i = 1, #t do
        if cc.Label:createWithTTF(t[i], "res/font/FZKTJW.TTF", fontSize):getContentSize().width > maxLen then
            local idex = 1
            local time = 0
            for ii = 1, string.len(t[i]) do
                local len = cc.Label:createWithTTF( string.sub(t[i],idex,ii + time), "res/font/FZKTJW.TTF", fontSize):getContentSize().width
                if len > maxLen then
                    t[i] = string.sub(t[i],1,ii + time - 1) .. "\n" .. string.sub(t[i], ii + time , -1)
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

----editBox
function ChatLayer:initEditBox()
    self.editBox_ = ccui.EditBox:create(cc.size(486,64),"res/chat/chat_input.png")
    if ChatLayer.InputBox == 2 then
        self.bottom_:addChild(self.editBox_)
    elseif ChatLayer.InputBox == 3 then
        self.bottom_:getChildByName("Panel"):addChild(self.editBox_)
    end
    self.editBox_:setAnchorPoint(0,0)
    self.editBox_:setFontSize(36)
    self.editBox_:setFontColor(cc.c3b(255,255,255))
    self.editBox_:setInputMode(cc.EDITBOX_INPUT_MODE_SINGLELINE)
    --self.editBox_:setInputMode(cc.EDITBOX_INPUT_MODE_ANY)
    self.editBox_:setMaxLength(ChatLayer.MaxInputLenght)
    self.editBox_:setPosition(20,15)

    self.editBox_:setReturnType(cc.KEYBOARD_RETURNTYPE_SEND )
    --self.editBox_:setReturnType(cc.KEYBOARD_RETURNTYPE_DEFAULT )
    --self.editBox_:setReturnType(cc.KEYBOARD_RETURNTYPE_DONE )
    --self.editBox_:setReturnType(cc.KEYBOARD_RETURNTYPE_SEARCH )
    --self.editBox_:setReturnType(cc.KEYBOARD_RETURNTYPE_GO )

    self.editBox_:registerScriptEditBoxHandler(handler(self, self.editBoxHandEvent))
    self.chatTextField_:setVisible(false)
    self.inputBg_:setVisible(false)
end

function ChatLayer:editBoxHandEvent(eventName,sender)
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
        if ChatLayer.InputBox == 3 then
            self:refreshInputBox(sender:getText())
        end
    elseif eventName == "changed" then
        if ChatLayer.InputBox == 3 then
            self:refreshInputBox(sender:getText())
        end
    end
end

--自定义输入框
function ChatLayer:initInputBox()
    self.chatTextRow_ = 0
    self:initEditBox()
    self.inputLabel_ = cc.Label:createWithTTF(" ", "res/font/FZKTJW.TTF", 36)
    self.inputLabel_:setAnchorPoint(0,0)
    self.inputLabel_:setPosition(0,0)
    self.inputLabel_:setDimensions(446,0)
    self.inputLabel_:setHorizontalAlignment(0)  --左对齐
    --self.bottom_:addChild(self.inputLabel_)
    self.textListView_:addChild(self.inputLabel_)
    self.inputBg_:setVisible(true)
    self.editBox_:setPosition(1,0)
    self.editBox_:setContentSize(200,30)
    self.editBox_:setFontSize(0.001)
    self.textListView_:addTouchEventListener(handler(self, self.inputBoxTouchEvent))
    self.inputBg_:addTouchEventListener(handler(self, self.inputBoxTouchEvent))
end

function ChatLayer:inputBoxTouchEvent(sender, eventType)
    if eventType == ccui.TouchEventType.began then
        self.moved_ = 0
    elseif eventType == ccui.TouchEventType.moved then
        self.moved_ = self.moved_ + 1
    elseif eventType == ccui.TouchEventType.ended then
        if  self.moved_ < 8 then
            self.editBox_:touchDownAction(self.editBox_, 2) 
            self.textListView_:scrollToBottom(0,true)
        end
        self.moved_ = 0
    elseif eventType == ccui.TouchEventType.canceled then
    end
end

function ChatLayer:refreshInputBox(str)
    self.inputLabel_:setString(self:getNewStr(str,36,458))
    --print(self.inputLabel_:getString())
    local height = self.inputLabel_:getContentSize().height

    if height > 50 and height <= 78 then
        if self.chatTextRow_ ~= 2 then
            self.chatTextRow_ = 2
            self.bottom_:getChildByName("bg"):setContentSize(670,130)
            self.bottom_:getChildByName("inputBg"):setContentSize(486,104)
            self.textListView_:setContentSize(460,80)
            self.textListView_:setInnerContainerSize(cc.size(460,80))
            self:upTextField(140)
            self.chatListView_:setContentSize(630,self.chatListViewHeight_ - 40)
            self.chatListView_:jumpToBottom()
        end
    elseif height > 78 and height <= 117 then
        if self.chatTextRow_ ~= 3 then
            self.chatTextRow_ = 3
            self.bottom_:getChildByName("bg"):setContentSize(670,170)
            self.bottom_:getChildByName("inputBg"):setContentSize(486,144)
            self.textListView_:setContentSize(460,120)
            self.textListView_:setInnerContainerSize(cc.size(460,120))
            self:upTextField(180)
            self.chatListView_:setContentSize(630,self.chatListViewHeight_ - 80)
            self.chatListView_:jumpToBottom()
        end
    elseif height > 117 and height <= 156 then
        if ChatLayer.InputBoxRow == 4 then
            if self.chatTextRow_ ~= 4 then
                self.chatTextRow_ = 4
                self.bottom_:getChildByName("bg"):setContentSize(670,210)
                self.bottom_:getChildByName("inputBg"):setContentSize(486,184)
                self.textListView_:setContentSize(460,160)
                self.textListView_:setInnerContainerSize(cc.size(460,160))
                self:upTextField(220)
                self.chatListView_:setContentSize(630,self.chatListViewHeight_ - 120)
                self.chatListView_:jumpToBottom()
            end
        elseif ChatLayer.InputBoxRow == 3 then
            if self.chatTextRow_ ~= 4 then
                self.chatTextRow_ = 4
                self.bottom_:getChildByName("bg"):setContentSize(670,170)
                self.bottom_:getChildByName("inputBg"):setContentSize(486,144)
                self.textListView_:setContentSize(460,120)
                self.textListView_:setInnerContainerSize(cc.size(460,120))
                self:upTextField(180)
                self.chatListView_:setContentSize(630,self.chatListViewHeight_ - 80)
                self.chatListView_:jumpToBottom()
            end
            self.textListView_:setInnerContainerSize(cc.size(460,height))
            self.textListView_:scrollToBottom(0,true)
        end
    elseif height > 156 then
        if ChatLayer.InputBoxRow == 4 then
            if self.chatTextRow_ ~= 5 then
                self.chatTextRow_ = 5
                self.bottom_:getChildByName("bg"):setContentSize(670,210)
                self.bottom_:getChildByName("inputBg"):setContentSize(486,184)
                self.textListView_:setContentSize(460,160)
                self:upTextField(220)
                self.chatListView_:setContentSize(630,self.chatListViewHeight_ - 120)
                self.chatListView_:jumpToBottom()
            end
        end
        self.textListView_:setInnerContainerSize(cc.size(460,height))
        self.textListView_:scrollToBottom(0,true)
        
    else
        if self.chatTextRow_ ~= 1 then
            self.chatTextRow_ = 1
            self.bottom_:getChildByName("bg"):setContentSize(670,90)
            self.bottom_:getChildByName("inputBg"):setContentSize(486,64)
            self.textListView_:setContentSize(460,40)
            self.textListView_:setInnerContainerSize(cc.size(460,40))
            self:upTextField(100)
            self.chatListView_:setContentSize(630,self.chatListViewHeight_)
            self.chatListView_:jumpToBottom()
        end
    end
end

--创建一条聊天信息(文字)
--info 说话人信息
--chatStr 说话内容 
--return 聊天信息panel
function ChatLayer:createChatWidget(uid,chatStr,chatTable)
    --TODO自己还是别人说话
    local isMe = true
    if uid then 
        isMe = false 
    end

    local chatWidget = ccui.Layout:create()
    local chatStrLabel = cc.Label:createWithTTF(chatStr, "res/font/FZKTJW.TTF", 28)
    local chatBg = nil

    --local head = cc.Sprite:create("res/head/portrait_text.png",cc.rect(0,0,74,74))
    local head = bole:getNewHeadView(bole:getUserData())

    local userName = nil

    --label设置
    local size = chatStrLabel:getContentSize()
    if size.width > 446 then
        chatStrLabel:setDimensions(446,0)
        chatStrLabel:setHorizontalAlignment(0)  --左对齐
        if chatTable ~= nil then
            if chatTable.isFormat == false then
                print("字符串格式化")
                chatStr = self:getNewStr(chatStr,28,446)
                chatTable.msg = chatStr
                chatTable.isFormat = true
            end
        end
        chatStrLabel:setString(chatStr)
        size = chatStrLabel:getContentSize()
    else
        if isMe then  
            chatStrLabel:setHorizontalAlignment(2)  --右对齐
        else
            chatStrLabel:setHorizontalAlignment(0)  --左对齐
        end
    end
    chatStrLabel:setTextColor({ r = 37, g = 54, b = 101} )

    if string.sub(chatStr,1,8) == "#emotion" then
        chatStrLabel = cc.Sprite:create("res/chat/chat_button_emotion.png")
        size = chatStrLabel:getContentSize()
    end

    if isMe then  
        --自己说话
            
        chatBg = cc.Scale9Sprite:create("res/chat/chat_i_show.png")
        chatBg:setCapInsets(cc.rect(10,50,70,8))
        chatBg:setContentSize(size.width + 36, math.max(size.height + 40, 70))
        chatWidget:setContentSize(670, chatBg:getContentSize().height)

        local chatWidgetSize = chatWidget:getContentSize()
        
        head:updatePos(head.POS_CHAT_SELF)
        head:setAnchorPoint(1,1)
        head:setScale(0.62)
        head:setPosition(630 - 37, chatWidget:getContentSize().height - 37)

        chatBg:setAnchorPoint(1,0.5)
        chatBg:setPosition(630 - 74 - 6, chatWidgetSize.height / 2)

        chatStrLabel:setAnchorPoint(1,0.5)
        chatStrLabel:setPosition(630 - 74 - 12 - 18, chatWidgetSize.height / 2)
    else 
        --别人说话
        userName = uid
        chatBg = cc.Scale9Sprite:create("res/chat/chat_else_show.png")
        chatBg:setCapInsets(cc.rect(20,50,70,8))
        chatBg:setContentSize(size.width + 36, math.max(size.height + 40, 70))
        chatWidget:setContentSize(670, chatBg:getContentSize().height + 35)

        local chatWidgetSize = chatWidget:getContentSize()
        head:updatePos(head.POS_CHAT_FRIEND)
        head:setAnchorPoint(0,1)
        head:setScale(0.6)
        head:setPosition(37, chatWidget:getContentSize().height - 37)

        chatBg:setAnchorPoint(0,0.5)
        chatBg:setPosition(74 + 6, chatWidgetSize.height / 2 - 17)

        chatStrLabel:setAnchorPoint(0,0.5)
        chatStrLabel:setPosition(74 + 12 + 18, chatWidgetSize.height / 2  - 17)

        local userNameLabel = cc.Label:createWithTTF(userName, "res/font/FZKTJW.TTF", 28)
        userNameLabel:setAnchorPoint(0,1)
        userNameLabel:setPosition(88,chatWidget:getContentSize().height)
        chatWidget:addChild(userNameLabel)
    end
    
    chatWidget:addChild(head)
    chatWidget:addChild(chatBg)
    chatWidget:addChild(chatStrLabel)

    return chatWidget
end

--初始化输入框
function ChatLayer:initTextField()
    --添加监听
    self.chatTextRow_ = 1
    self.row_2_sub_ = 460
    self.row_3_sub_ = 920
    self.chatTextField_:setTextHorizontalAlignment(0)
    self.chatTextField_:setMaxLength(10)
    self.chatTextField_:addEventListener(handler(self, self.textFieldEvent))
end

function ChatLayer:textFieldEvent(sender, eventType)
    if eventType == ccui.TextFiledEventType.attach_with_ime then --打开
        self.guangbiao_:setVisible(true)
    elseif eventType == ccui.TextFiledEventType.detach_with_ime then --关闭
        self.guangbiao_:setVisible(false)
    elseif eventType == ccui.TextFiledEventType.insert_text then --输入
        self:refreshCursorPos()
    elseif eventType == ccui.TextFiledEventType.delete_backward then --删除
        self:refreshCursorPos()
    end
end

--刷新输入框显示与光标位置
function ChatLayer:refreshCursorPos()
    local str = self.chatTextField_:getString()
    local label = cc.Label:createWithTTF(str, "res/font/FZKTJW.TTF", 36)
    local labelWidth = label:getContentSize().width
    if labelWidth >= 460 and labelWidth < self.row_2_sub_ + 460 then
        if self.chatTextRow_ ~= 2 then
            self.chatTextRow_ = 2
            self.row_2_sub_ = self.preLabelWidth_   
            self.chatTextField_:setContentSize(460,80)
            self.bottom_:getChildByName("bg"):setContentSize(670,130)
            self.bottom_:getChildByName("inputBg"):setContentSize(486,104)
        end
        self.guangbiao_:setPositionX(36 + labelWidth - self.row_2_sub_)
    elseif labelWidth >= self.row_2_sub_ + 460 and labelWidth < self.row_3_sub_ + 460 then
        if self.chatTextRow_ ~= 3 then
            self.chatTextRow_ = 3
            self.row_3_sub_ = self.preLabelWidth_
            self.chatTextField_:setContentSize(460,120)
            self.bottom_:getChildByName("bg"):setContentSize(670,170)
            self.bottom_:getChildByName("inputBg"):setContentSize(486,144)
        end
        self.guangbiao_:setPositionX(36 + labelWidth - self.row_3_sub_)
    elseif labelWidth >= self.row_3_sub_ + 460 then
        if self.chatTextRow_ ~= 4 then
            self.chatTextRow_ = 4
        end
    else
        if self.chatTextRow_ ~= 1 then
            self.chatTextRow_ = 1
            self.row_2_sub_ = 460
            self.row_3_sub_ = 920
            self.chatTextField_:setContentSize(460,40)
            self.bottom_:getChildByName("bg"):setContentSize(670,90)
            self.bottom_:getChildByName("inputBg"):setContentSize(486,64)
        end
        self.guangbiao_:setPositionX(36 + labelWidth)
    end
    
    self.preLabelWidth_ = labelWidth
end

--上移聊天界面
function ChatLayer:upTextField(posY)
    posY = posY or self.chatListView_:getPositionY()
    self.chatListView_:setPosition(self.chatListView_:getPositionX(), posY)
end

--下移聊天界面
function ChatLayer:downTextField(moveHeight)
    local keyboardHeight = 300
    self.bg_:runAction(cc.MoveTo:create(0.2, cc.p(self.bg_:getPositionX(), 0)))
    self.chatListView_:runAction(cc.MoveTo:create(0.2, cc.p(self.chatListView_:getPositionX(), 100)))
    self.bottom_:runAction(cc.MoveTo:create(0.2, cc.p(self.bottom_:getPositionX(), 0)))
end

--初始化快捷聊天，表情
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
            if not cc.rectContainsPoint(cc.rect(0,70,680,100),touchPos) then
                self.panelEmotion_:setVisible(false)
            end
        end
        if self.panelSend_:isVisible() then
            if not cc.rectContainsPoint(cc.rect(400,70,280,380),touchPos) then
                self.panelSend_:setVisible(false)
            end
        end
    end
    local listener = cc.EventListenerTouchOneByOne:create()
    listener:registerScriptHandler(onTouchBegin, cc.Handler.EVENT_TOUCH_BEGAN)
    listener:registerScriptHandler(onTouchMove, cc.Handler.EVENT_TOUCH_MOVED)
    listener:registerScriptHandler(onTouchEnd, cc.Handler.EVENT_TOUCH_ENDED)
    cc.Director:getInstance():getEventDispatcher():addEventListenerWithSceneGraphPriority(listener, layer);
    self:addChild(layer)

    --TODO初始化表情,快捷语句
    self.emotionListView_ = self.panelEmotion_:getChildByName("ListView")
    self.emotionListView_:setScrollBarOpacity(0)
    self:createEmotionView()
    self.sendListView_ = self.panelSend_:getChildByName("ListView")
    self.sendListView_:setScrollBarOpacity(0)
    self:sendEmotionView()
end

function ChatLayer:createEmotionView()
    for i = 1, 14 do
        local emotionWidget = self.panelEmotion_:getChildByName("emotion"):clone()
        emotionWidget:setVisible(true)
        emotionWidget:setName("emotion")
        emotionWidget:getChildByName("Image"):loadTexture("res/chat/chat_button_emotion.png")
        emotionWidget.tag = "#emotion" .. i
        emotionWidget:addTouchEventListener(handler(self,self.touchEvent))
        self.emotionListView_:pushBackCustomItem(emotionWidget)
    end
end

function ChatLayer:sendEmotionView()
    for i = 1, 10 do
        local sendWidget = self.panelSend_:getChildByName("send"):clone()
        sendWidget:setVisible(true)
        sendWidget:setName("emotion")
        sendWidget.tag = "快捷语句" .. i
        sendWidget:getChildByName("Text"):setString(sendWidget.tag)
        sendWidget:addTouchEventListener(handler(self, self.touchEvent))
        self.sendListView_:pushBackCustomItem(sendWidget)
    end
end

--退出
function ChatLayer:backLayer()
    local removeFunc = function()
        --移除监听
        self.chatManager:removeChatLayer()
        self:removeFromParent()
    end
    self.chatPanel_:runAction(cc.Sequence:create(cc.MoveTo:create(0.2,cc.p(-720,0)), cc.CallFunc:create(removeFunc)))
end

--创建键盘监听
function ChatLayer:createEventListenerKeyboard()
    local listener = cc.EventListenerKeyboard:create()
    local function onKeyReleased(keyCode, event)
        if keyCode == 164 then
            self:sendChatContent()
        end
    end
    listener:registerScriptHandler(onKeyReleased, cc.Handler.EVENT_KEYBOARD_RELEASED)
    cc.Director:getInstance():getEventDispatcher():addEventListenerWithSceneGraphPriority(listener, self)
end

--适配
function ChatLayer:adaptScreen()
    local winSize = cc.Director:getInstance():getWinSize()
    local test = cc.Director:getInstance():getOpenGLView():getFrameSize()
    self.bottom_:setPosition(0,0)
    self.middle_:setPosition(0,0)
    self.middle_:setContentSize(670,winSize.height - 62)
    self.top_:setPosition(0,winSize.height)
    self.bg_:setContentSize(670,winSize.height - 62)
    self.chatListView_:setPosition(20,100)
    self.chatListView_:setContentSize(630,winSize.height - 100 - 62 - 15)
    self.chatListViewHeight_ = winSize.height - 100 - 62 - 15
    self.root_:setContentSize(winSize)
    self.touchPanel_:setContentSize(winSize)
end

return ChatLayer

--endregion

