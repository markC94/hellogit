--region *.lua
--Date
--此文件由[BabeLua]插件自动生成
local ChatCell = class("ChatCell", ccui.Layout)

--创建一条聊天信息(文字)
--info 说话人信息
--chatStr 说话内容 
--return 聊天信息panel
function ChatCell:ctor(uid,chatStr,chatTable)
    --TODO自己还是别人说话
    local isMe = true
    if uid then 
        isMe = false 
    end
    self.data_ = chatTable

    if chatTable.type == "chat" then
        self:createChatCell(uid,chatStr,chatTable,isMe)
    elseif chatTable.type == "gift" then
        self:createGiftCell(uid,chatStr,chatTable,isMe)
    elseif chatTable.type == "invite" then
        self:createInviteCell(uid,chatStr,chatTable)
    elseif chatTable.type == "like" then
        self:createLikeCell(uid,chatStr,chatTable)
    elseif chatTable.type == "bigWin" or chatTable.type == "megaWin" then
        self:createBigWinCell(uid,chatStr,chatTable)
    end
end

function ChatCell:createChatCell(uid,chatStr,chatTable,isMe)
    local chatWidget = self
    local chatStrLabel = cc.Label:createWithTTF(chatStr, "res/font/FZKTJW.TTF", 28)

    local chatBg = nil
    local head = nil
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


    local isEmotion = false
    if string.sub(chatStr,1,8) == "#emotion" then
        --chatStrLabel = cc.Sprite:create("res/chat/chat_button_emotion.png")
        --size = chatStrLabel:getContentSize()
        
        local s = cc.Sprite:create("res/chat/chat_button_emotion.png")
        chatStrLabel = sp.SkeletonAnimation:create("emotion/skeleton.json", "emotion/skeleton.atlas")
        chatStrLabel:setAnimation(0, string.sub(chatStr,9,-1), true)
        print(string.sub(chatStr,9,-1))
        size = s:getContentSize()
        isEmotion = true
    end

    if isMe then  
        --自己说话
        head = bole:getNewHeadView(bole:getUserData())

        chatBg = cc.Scale9Sprite:create("res/chat/chat_i_show.png")
        chatBg:setCapInsets(cc.rect(10,50,70,8))
        chatBg:setContentSize(size.width + 36, math.max(size.height + 40, 70))
        chatWidget:setContentSize(670, chatBg:getContentSize().height)

        local chatWidgetSize = chatWidget:getContentSize()
        
        head:updatePos(head.POS_CHAT_SELF)
        head:setAnchorPoint(1,1)
        head:setScale(0.62)
        head:setPosition(650 - 37, chatWidget:getContentSize().height - 37)

        chatBg:setAnchorPoint(1,0.5)
        chatBg:setPosition(650 - 74 - 6, chatWidgetSize.height / 2)

        chatStrLabel:setAnchorPoint(1,0.5)
        chatStrLabel:setPosition(650 - 74 - 12 - 18, chatWidgetSize.height / 2)
        if isEmotion then
            chatStrLabel:setPosition(650 - 74 - 12 - 18 - 30, chatWidgetSize.height / 2)
        end
        self:createLoading(chatBg:getPositionX() - chatBg:getContentSize().width - 45)
    else 
        --别人说话
        if chatTable.userData ~= nil then
            head = bole:getNewHeadView(chatTable.userData)
            userName = chatTable.userData.name
        else
            head = bole:getNewHeadView(bole:getUserData())
            userName = uid
        end

        chatBg = cc.Scale9Sprite:create("res/chat/chat_else_show.png")
        chatBg:setCapInsets(cc.rect(20,50,70,8))
        chatBg:setContentSize(size.width + 36, math.max(size.height + 40, 70))
        chatWidget:setContentSize(670, chatBg:getContentSize().height + 35)

        local chatWidgetSize = chatWidget:getContentSize()
        head:updatePos(head.POS_CHAT_FRIEND)
        head:setAnchorPoint(0,1)
        head:setScale(0.6)
        head:setPosition(57, chatWidget:getContentSize().height - 37)

        chatBg:setAnchorPoint(0,0.5)
        chatBg:setPosition(94 + 6, chatWidgetSize.height / 2 - 17)

        chatStrLabel:setAnchorPoint(0,0.5)
        chatStrLabel:setPosition(94 + 12 + 18, chatWidgetSize.height / 2  - 17)
        if isEmotion then
            chatStrLabel:setPosition(94 + 12 + 18 + 30, chatWidgetSize.height / 2  - 17)
        end

        local userNameLabel = cc.Label:createWithTTF(userName, "res/font/FZKTJW.TTF", 28)
        userNameLabel:setAnchorPoint(0,1)
        userNameLabel:setPosition(108,chatWidget:getContentSize().height)
        chatWidget:addChild(userNameLabel)
    end
    
    chatWidget:addChild(head)
    chatWidget:addChild(chatBg)
    chatWidget:addChild(chatStrLabel)
end

function ChatCell:createLikeCell(uid,chatStr,chatTable)
    local chatWidget = self
    chatWidget:setContentSize(670, 110)

    local widget = cc.CSLoader:createNode("csb/chat/ChatCell.csb")
    chatWidget:addChild(widget)

    self.cell_ = widget:getChildByName("root")
    self.cell_:getChildByName("bg"):loadTexture("chat/chat_club_giftlike.png")
    self.cell_:getChildByName("info"):setString(chatStr)

    local head = bole:getNewHeadView(chatTable.userData) 
    head:updatePos(head.POS_CHAT_FRIEND)
    head:setAnchorPoint(0,1)
    head:setScale(0.7)
    self.cell_:getChildByName("head"):addChild(head)
    self.cell_:getChildByName("btn"):addTouchEventListener(handler(self, self.touchEvent))

    self:initLikeTime()
end

function ChatCell:createInviteCell(uid,chatStr,chatTable)
    local chatWidget = self
    chatWidget:setContentSize(670, 110)

    local widget = cc.CSLoader:createNode("csb/chat/ChatCell.csb")
    chatWidget:addChild(widget)

    self.cell_ = widget:getChildByName("root")
    self.cell_:getChildByName("bg"):loadTexture("chat/chat_club_clubofferBG.png")
    self.cell_:getChildByName("info"):setString(chatStr)

    local head = bole:getNewHeadView(chatTable.userData) 
    head:updatePos(head.POS_CHAT_FRIEND)
    head:setAnchorPoint(0,1)
    head:setScale(0.7)
    self.cell_:getChildByName("head"):addChild(head)

    self.cell_:getChildByName("btn_accept"):addTouchEventListener(handler(self, self.touchEvent))
    self.cell_:getChildByName("btn_accept"):setVisible(true)
    self.cell_:getChildByName("btn"):setVisible(false)
end

function ChatCell:createGiftCell(uid,chatStr,chatTable)
    local chatWidget = self
    chatWidget:setContentSize(670, 110)

    local widget = cc.CSLoader:createNode("csb/chat/ChatCell.csb")
    chatWidget:addChild(widget)

    self.cell_ = widget:getChildByName("root")
    self.cell_:getChildByName("bg"):loadTexture("chat/chat_club_giftlikeBG.png")
    self.cell_:getChildByName("info"):setString(chatStr)

    local head = bole:getNewHeadView(chatTable.userData) 
    head:updatePos(head.POS_CHAT_FRIEND)
    head:setAnchorPoint(0,1)
    head:setScale(0.7)
    self.cell_:getChildByName("head"):addChild(head)
    self.cell_:getChildByName("btn"):addTouchEventListener(handler(self, self.touchEvent))

    self:initLikeTime()
end

function ChatCell:createBigWinCell(uid,chatStr,chatTable)
    local chatWidget = self
    chatWidget:setContentSize(670, 110)

    local widget = cc.CSLoader:createNode("csb/chat/ChatCell.csb")
    chatWidget:addChild(widget)

    self.cell_ = widget:getChildByName("root")
    if chatTable.type == "bigWin" then
        self.cell_:getChildByName("bg"):loadTexture("chat/big win.png")
    else
        self.cell_:getChildByName("bg"):loadTexture("chat/megawin.png")
    end
    self.cell_:getChildByName("info"):setString(chatStr)

    local head = bole:getNewHeadView(chatTable.userData) 
    head:updatePos(head.POS_CHAT_FRIEND)
    head:setAnchorPoint(0,1)
    head:setScale(0.7)
    self.cell_:getChildByName("head"):addChild(head)
    self.cell_:getChildByName("btn"):addTouchEventListener(handler(self, self.touchEvent))

    self:initLikeTime()
end

function ChatCell:touchEvent(sender, eventType)
    local name = sender:getName()
    if eventType == ccui.TouchEventType.began then
        sender:runAction(cc.ScaleTo:create(0.1, 1.05, 1.05))
    elseif eventType == ccui.TouchEventType.moved then

    elseif eventType == ccui.TouchEventType.ended then
        sender:runAction(cc.ScaleTo:create(0.1, 1, 1))
        if name == "btn" then
            self:like(sender)
        elseif name == "btn_accept" then
            self:accept()
        end
    elseif eventType == ccui.TouchEventType.canceled then
        sender:runAction(cc.ScaleTo:create(0.1, 1, 1))
    end
end

function ChatCell:accept()
    local data = self.data_.otherInfo
    bole:popMsg({msg=data.inviter_name.." play togethe",cancle=true},function()
    bole.socket:send(bole.ACCEPT_ROOT_INVITATION,{room_id=data.room_id,theme_id=data.theme_id})
        end)
end

function ChatCell:like(sender)
    bole:postEvent("likeToPlayer",self.data_.id)
    self.cell_:getChildByName("btn"):setTouchEnabled(false)
    --self:createRunTime(3600)
end

function ChatCell:initLikeTime()
    local likeToPlayerList = bole:getUserDataByKey("likeToPlayerList")
    if type(likeToPlayerList) == "table" then
        local time = likeToPlayerList[self.data_.id]
        if time ~= nil then
            local runTime = 3600 - (os.time() - time)
            if runTime > 0 then
                self:createRunTime(runTime)
            else
                likeToPlayerList[self.data_.id] = nil
            end
        end
    end
end

function ChatCell:createRunTime(start)
    self.cell_:getChildByName("btn"):getChildByName("txt"):setVisible(false)
    self.cell_:getChildByName("btn"):setTouchEnabled(false)
    local runTime = self.cell_:getChildByName("runTime")
    runTime:setVisible(true)
    local txt_second1 = runTime:getChildByName("txt_second1")
    local txt_second2 = runTime:getChildByName("txt_second2")
    local txt_minute1 = runTime:getChildByName("txt_minute1")
    local txt_minute2 = runTime:getChildByName("txt_minute2")
    local runTime = start
    local s = math.floor(runTime) % 60
    local m = math.floor(runTime / 60) % 60
    txt_second1:setString(math.floor(s / 10))
    txt_second2:setString(math.floor(s % 10))
    txt_minute1:setString(math.floor(m / 10))
    txt_minute2:setString(math.floor(m % 10))
end

--在过长字符中间加入'\n'
--str 字符串
--fontSize 字符大小
--maxLen 每行最大长度
function ChatCell:getNewStr(str, fontSize, maxLen)
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

function ChatCell:createLoading(posX)
    local sprite = cc.Sprite:create("res/chat/chat_button_emotion.png")
    self:addChild(sprite)
    sprite:setPosition(posX, 35)
    sprite:runAction(cc.RepeatForever:create(cc.RotateBy:create(2, -360)))
    self.load_ = sprite
end

function ChatCell:update()
    if self.data_.type == "chat" or self.data_.type == "invite" then
        return
    end
    local likeToPlayerList = bole:getUserDataByKey("likeToPlayerList")
    if type(likeToPlayerList) == "table" then
        local time = likeToPlayerList[self.data_.id]
        if time ~= nil then
            local runTime = 3600 - ( os.time() - time )
            if runTime > 0 then
                if not self.cell_:getChildByName("runTime"):isVisible() then
                    self.cell_:getChildByName("btn"):getChildByName("txt"):setVisible(false)
                    self.cell_:getChildByName("btn"):setTouchEnabled(false)
                    self.cell_:getChildByName("runTime"):setVisible(true)
                end
                runTime = runTime - 1
                local s = math.floor(runTime) % 60
                local m = math.floor(runTime / 60) % 60
                self.cell_:getChildByName("runTime"):getChildByName("txt_second1"):setString(math.floor(s / 10))
                self.cell_:getChildByName("runTime"):getChildByName("txt_second2"):setString(math.floor(s % 10))
                self.cell_:getChildByName("runTime"):getChildByName("txt_minute1"):setString(math.floor(m / 10))
                self.cell_:getChildByName("runTime"):getChildByName("txt_minute2"):setString(math.floor(m % 10))
            else
                local likeToPlayerList = bole:getUserDataByKey("likeToPlayerList")
                likeToPlayerList[self.data_.id] = nil
                bole:setUserDataByKey("likeToPlayerList",likeToPlayerList)
                self.cell_:getChildByName("btn"):getChildByName("txt"):setVisible(true)
                self.cell_:getChildByName("btn"):setTouchEnabled(true)
                self.cell_:getChildByName("runTime"):setVisible(false)
            end
        end
    end
end

function ChatCell:removeLoading()
    if self.load_ ~= nil then
        self.load_:removeFromParent()
        self.load_ = nil
    end
end

return ChatCell
--endregion
