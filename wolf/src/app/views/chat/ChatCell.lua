--region *.lua
--Date
--此文件由[BabeLua]插件自动生成
local ChatCell = class("ChatCell", ccui.Layout)

ChatCell.ChatViewWidth = 355
ChatCell.ChatViewTxtSize = 28
ChatCell.ChatCellWidth = 580
ChatCell.NoticeCellWidth = 610

function ChatCell:ctor(chat,isInitMsg)
    --TODO自己还是别人说话
    local isMe = false
    if chat.sender == bole:getUserDataByKey("user_id") then
        isMe = true
    end

    self.data_ = chat
    self.isInitMsg_ = isInitMsg or false

    if chat.infoType == "chat" then
        self:createChatCell(chat,isMe)
    elseif chat.infoType == "gift" then
        self:createGiftCell(chat)
    elseif chat.infoType == "invite" then
        self:createInviteCell(chat)
    elseif chat.infoType == "like" then
        self:createLikeCell(chat)
    elseif chat.infoType == "bigWin" or chat.infoType == "megaWin" or chat.infoType == "crazyWin" or chat.infoType == "freeSpin"  then
        self:createBigWinCell(chat)
    elseif chat.infoType == "clubBuy" then
        self:createClubBuyCell(chat)
    end
end

function ChatCell:createChatCell(chat,isMe)
    local chatWidget = self
    local chatStrLabel = cc.Label:createWithTTF(chat.msg, "font/bole_ttf.ttf", self.ChatViewTxtSize)

    local chatBg = nil
    local head = nil
    local userName = nil
    
    --label设置
    local size = chatStrLabel:getContentSize()
    if size.width > self.ChatViewWidth then
        chatStrLabel:setDimensions(self.ChatViewWidth,0)
        chatStrLabel:setHorizontalAlignment(0)  --左对齐

            if chat.isFormat == false then
                print("字符串格式化")
                chat.msg = bole:getNewStr(chat.msg,self.ChatViewTxtSize,self.ChatViewWidth)
                chat.isFormat = true
            end

        chatStrLabel:setString(chat.msg)
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
    if string.sub(chat.msg,1,8) == "#emotion" then
        chatStrLabel = sp.SkeletonAnimation:create("emotion/skeleton.json", "emotion/skeleton.atlas")
        chatStrLabel:setAnimation(0, string.sub(chat.msg,9,-1), true)
        size = cc.size(56,60)
        isEmotion = true
    end

    if isMe then  
        --自己说话
        head = bole:getNewHeadView(bole:getUserData())
        if not isEmotion then
            chatStrLabel:setTextColor({ r = 0, g = 0, b = 0} )
        end
        chatBg = cc.Scale9Sprite:create("inSlot_icon/chat_dialog_self.png")
        chatBg:setCapInsets(cc.rect(50,50,200,10))
        chatBg:setContentSize(size.width + 36, math.max(size.height + 40, 70))
        chatWidget:setContentSize(self.NoticeCellWidth, chatBg:getContentSize().height)

        local chatWidgetSize = chatWidget:getContentSize()
        
        head:updatePos(head.POS_CHAT_SELF)
        head:setAnchorPoint(1,1)
        head:setScale(0.62)
        head:setPosition(self.ChatCellWidth - 37, chatWidget:getContentSize().height - 37)

        chatBg:setAnchorPoint(1,0.5)
        chatBg:setPosition(self.ChatCellWidth - 74 - 6, chatWidgetSize.height / 2)

        chatStrLabel:setAnchorPoint(1,0.5)
        chatStrLabel:setPosition(self.ChatCellWidth - 74 - 12 - 18, chatWidgetSize.height / 2)
        if isEmotion then
            chatStrLabel:setPosition(self.ChatCellWidth - 74 - 12 - 18 - 30, chatWidgetSize.height / 2)
        end
        if not self.isInitMsg_ then
            self:createLoading(chatBg:getPositionX() - chatBg:getContentSize().width - 45)
        end
    else 
        --别人说话
        if chat.userData ~= nil then
            head = bole:getNewHeadView(chat.userData)
            userName = chat.userData.name
        else
            head = bole:getNewHeadView({ user_id  = chat.sender })
            userName = chat.sender
        end
        if not isEmotion then
            chatStrLabel:setTextColor({ r = 255, g = 255, b = 255} )
        end

        chatBg = cc.Scale9Sprite:create("inSlot_icon/chat_dialog_others.png")
        chatBg:setCapInsets(cc.rect(50,50,200,10))
        chatBg:setFlippedX(true)
        chatBg:setContentSize(size.width + 36, math.max(size.height + 40, 70))
        chatWidget:setContentSize(self.NoticeCellWidth, chatBg:getContentSize().height + 35)

        local chatWidgetSize = chatWidget:getContentSize()
        head:updatePos(head.POS_CHAT_FRIEND)
        head:setAnchorPoint(0,1)
        head:setScale(0.6)
        head:setPosition(57, chatWidget:getContentSize().height - 37)

        chatBg:setAnchorPoint(1,0.5)
        chatBg:setPosition(94 + 6, chatWidgetSize.height / 2 - 17)

        chatStrLabel:setAnchorPoint(0,0.5)
        chatStrLabel:setPosition(94 + 12 + 18, chatWidgetSize.height / 2  - 17)
        if isEmotion then
            chatStrLabel:setPosition(94 + 12 + 18 + 30, chatWidgetSize.height / 2  - 17)
        end

        local userNameLabel = cc.Label:createWithTTF(userName, "font/bole_ttf.ttf", 28)
        userNameLabel:setAnchorPoint(0,1)
        userNameLabel:setPosition(108,chatWidget:getContentSize().height)
        chatWidget:addChild(userNameLabel)
    end
    chatWidget:addChild(head)
    chatWidget:addChild(chatBg)
    chatWidget:addChild(chatStrLabel)
end

function ChatCell:createLikeCell(chat)
    local chatWidget = self
    chatWidget:setContentSize(self.ChatCellWidth, 110)

    local widget = cc.CSLoader:createNode("inSlot_chat/ChatCell.csb")
    chatWidget:addChild(widget)

    self.cell_ = widget:getChildByName("root")
    self.cell_:getChildByName("bg"):loadTexture("loadImage/chat_notice_like.png")
    self.cell_:getChildByName("info"):setString(chat.msg)

    local head = bole:getNewHeadView(chat.userData) 
    head:updatePos(head.POS_CHAT_FRIEND)
    head:setAnchorPoint(0,1)
    head:setScale(0.7)
    self.cell_:getChildByName("head"):addChild(head)
    self.cell_:getChildByName("btn"):addTouchEventListener(handler(self, self.touchEvent))

    self:initLikeTime()
end

function ChatCell:createInviteCell(chat)
    local chatWidget = self
    chatWidget:setContentSize(self.ChatCellWidth, 110)

    local widget = cc.CSLoader:createNode("inSlot_chat/ChatCell.csb")
    chatWidget:addChild(widget)

    self.cell_ = widget:getChildByName("root")
    self.cell_:getChildByName("bg"):loadTexture("loadImage/chat_notice_invite.png")
    self.cell_:getChildByName("info"):setString(chat.msg)

    local head = bole:getNewHeadView(chat.userData) 
    head:updatePos(head.POS_CHAT_FRIEND)
    head:setAnchorPoint(0,1)
    head:setScale(0.7)
    self.cell_:getChildByName("head"):addChild(head)

    self.cell_:getChildByName("btn_accept"):addTouchEventListener(handler(self, self.touchEvent))
    self.cell_:getChildByName("btn_accept"):setVisible(true)
    self.cell_:getChildByName("btn"):setVisible(false)
end

function ChatCell:createGiftCell(chat)
    local chatWidget = self
    chatWidget:setContentSize(self.ChatCellWidth, 110)

    local widget = cc.CSLoader:createNode("inSlot_chat/ChatCell.csb")
    chatWidget:addChild(widget)

    self.cell_ = widget:getChildByName("root")
    self.cell_:getChildByName("bg"):loadTexture("loadImage/chat_notice_gift.png")
    self.cell_:getChildByName("info"):setString(chat.msg)

    --[[
    local richText = nil
    if chat.give_type == 1 then
        local num = bole:getConfigCenter():getConfig("givecoins", data.give_id, "givecoins_amount")
        local textTable = {
            { type = "text", info = " " .. chat.sender_name, color = cc.c3b(255, 255, 0) },
            { type = "text", info = " gives you" },
            { type = "image", imagePath = "giftshop/coin101.png" },
            { type = "text", info = " " .. bole:formatCoins(num, 15) }
        }
        richText = self:createRichText(textTable)
    elseif chat.give_type == 2 then
        local textTable = {
            { type = "text", info = " " .. chat.sender_name, color = cc.c3b(255, 255, 0) },
            { type = "text", info = " gives you a" },
            { type = "image", imagePath = "giftshop/drink" .. chat.give_id .. ".png" },
            { type = "text", info = " drink" }
        }
        richText = self:createRichText(textTable)
    end
    richText:setContentSize(380,80)
    richText:setAnchorPoint(0,0.5)
    richText:setPosition(115,50)
    self.cell_:addChild(richText)
    --]]
    local head = bole:getNewHeadView(chat.userData) 
    head:updatePos(head.POS_CHAT_FRIEND)
    head:setAnchorPoint(0,1)
    head:setScale(0.7)
    self.cell_:getChildByName("head"):addChild(head)
    --self.cell_:getChildByName("btn"):addTouchEventListener(handler(self, self.touchEvent))
    --self:initLikeTime()
end

function ChatCell:createBigWinCell(chat)
    local chatWidget = self
    chatWidget:setContentSize(self.ChatCellWidth, 110)

    local widget = cc.CSLoader:createNode("inSlot_chat/ChatCell.csb")
    chatWidget:addChild(widget)

    self.cell_ = widget:getChildByName("root")
    if chat.infoType == "bigWin" then
        self.cell_:getChildByName("bg"):loadTexture("loadImage/chat_notice_bigWin.png")
    else
        self.cell_:getChildByName("bg"):loadTexture("loadImage/chat_notice_megaWin.png")
    end
    self.cell_:getChildByName("info"):setString(chat.msg)

    local head = bole:getNewHeadView(chat.userData) 
    head:updatePos(head.POS_CHAT_FRIEND)
    head:setAnchorPoint(0,1)
    head:setScale(0.7)
    self.cell_:getChildByName("head"):addChild(head)
    --self.cell_:getChildByName("btn"):addTouchEventListener(handler(self, self.touchEvent))

    --self:initLikeTime()
end

function ChatCell:createClubBuyCell(chat)
    local chatWidget = self
    chatWidget:setContentSize(self.ChatCellWidth, 110)
    local widget = bole:getEntity("app.views.chat.ChatClubBuyCollectCell", chat)
    chatWidget:addChild(widget)
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
        elseif name == "loading" then
            self:reSendChat()
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
    bole:postEvent("likeToPlayer_chatView",self.data_.sender)
    self.cell_:getChildByName("btn"):setTouchEnabled(false)
    --self:createRunTime(3600)
end

function ChatCell:initLikeTime()
    local likeToPlayerList = bole:getUserDataByKey("likeToPlayerList")
    if type(likeToPlayerList) == "table" then
        local time = likeToPlayerList[self.data_.sender]
        if time ~= nil then
            local runTime = 3600 - (os.time() - time)
            if runTime > 0 then
                self:createRunTime(runTime)
            else
                likeToPlayerList[self.data_.sender] = nil
            end
        end
    end
end

function ChatCell:createRunTime(start)
    self.cell_:getChildByName("btn"):getChildByName("txt"):setVisible(false)
    self.cell_:getChildByName("btn"):setTouchEnabled(false)
    local runTime = self.cell_:getChildByName("runTime")
    --runTime:setVisible(true)
    runTime:setVisible(false)
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

function ChatCell:createLoading(posX)
    local sprite = ccui.ImageView:create()
    sprite:setName("loading")
    sprite:loadTexture("loadImage/chat_loading_icon.png",0)
    sprite:addTouchEventListener(handler(self, self.touchEvent))
    sprite:setTouchEnabled(false)
    self:addChild(sprite)
    sprite:setPosition(posX, 35)
    sprite:runAction(cc.RepeatForever:create(cc.RotateBy:create(0.5, -360)))
    self.load_ = sprite
    local delay = cc.DelayTime:create(5)
    local hide = cc.CallFunc:create( function() self:reSend() end)
    sprite:runAction(cc.Sequence:create(delay, hide))
end

function ChatCell:reSend()
    self.load_:stopAllActions()
    self.load_:setTouchEnabled(true)
end

function ChatCell:reSendChat()
    self.load_:setTouchEnabled(false)
    bole.socket:send("chat", { c_type = self.data_.c_type , msg = self.data_.msg })
    self.load_:runAction(cc.RepeatForever:create(cc.RotateBy:create(0.5, -360)))
    local delay = cc.DelayTime:create(5)
    local hide = cc.CallFunc:create( function() self:reSend() end)
    self.load_:runAction(cc.Sequence:create(delay, hide))
end

function ChatCell:update()
    if self.data_.infoType == "chat" or self.data_.infoType == "invite" then
        return
    end
    local likeToPlayerList = bole:getUserDataByKey("likeToPlayerList")
    if type(likeToPlayerList) == "table" then
        local time = likeToPlayerList[self.data_.sender]
        if time ~= nil then
            local runTime = 3600 - ( os.time() - time )
            if runTime > 0 then
                --[[
                if not self.cell_:getChildByName("runTime"):isVisible() then
                    self.cell_:getChildByName("btn"):getChildByName("txt"):setVisible(false)
                    self.cell_:getChildByName("btn"):setTouchEnabled(false)
                    self.cell_:getChildByName("runTime"):setVisible(true)
                end
                --]]
                runTime = runTime - 1
                local s = math.floor(runTime) % 60
                local m = math.floor(runTime / 60) % 60
                --[[
                self.cell_:getChildByName("runTime"):getChildByName("txt_second1"):setString(math.floor(s / 10))
                self.cell_:getChildByName("runTime"):getChildByName("txt_second2"):setString(math.floor(s % 10))
                self.cell_:getChildByName("runTime"):getChildByName("txt_minute1"):setString(math.floor(m / 10))
                self.cell_:getChildByName("runTime"):getChildByName("txt_minute2"):setString(math.floor(m % 10))
                --]]
            else
                local likeToPlayerList = bole:getUserDataByKey("likeToPlayerList")
                likeToPlayerList[self.data_.sender] = nil
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

--[[  richText
{
    {type = "text" , info = "str" , color = cc.c3b(255, 255, 255) , opacity = 255 , fontSize = 26, fontPath = "font/bole_ttf.ttf"}
}
--]]
function ChatCell:createRichText(richTextTable)
    local richText = ccui.RichText:create()
    richText:ignoreContentAdaptWithSize(false)
    for i = 1, #richTextTable do
        local v = richTextTable[i]
        local re = nil
        v.color = v.color or cc.c3b(255, 255, 255)
        v.opacity = v.opacity or 255
        v.fontSize = v.fontSize or 26
        v.fontPath = v.fontPath or "font/bole_ttf.ttf"
        v.imagePath = v.imagePath or "giftshop/coin101.png"
        v.type = v.type or "text"
        if v.type == "text" then
            re = ccui.RichElementText:create(i, v.color, v.opacity, v.info, v.fontPath , v.fontSize)
        elseif v.type == "image" then
            re = ccui.RichElementImage:create(i, v.color, v.opacity , v.imagePath)
        end
        richText:pushBackElement(re)
    end
    return richText
end

return ChatCell
--endregion
