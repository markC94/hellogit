--region *.lua
--Date
--此文件由[BabeLua]插件自动生成

--cc.exports.ChatManager = ChatManager or {}
local ChatManager = class("ChatManager")
ChatManager.MaxMsgNum = 30    --最大存储数

--初始化聊天室管理器
function ChatManager:initChatManager()
    self.chatMsg_ = {}
    self.chatUserData_ = {}

    bole.socket:registerCmd("chat", self.reChat, self)
    
    bole:addListener("addUserDataToChat", self.reEnterPlayer, self, nil, true)
    bole:addListener("chat_giveGift", self.reGiveGift, self, nil, true)
    bole:addListener("chat_invitePlay", self.reInvitePlay, self, nil, true)
    bole:addListener("chat_clubBuy", self.reClubBuy, self, nil, true)
    bole:addListener("chat_bigWin", self.reBigWin, self, nil, true)
    bole:addListener("chat_like", self.reLike, self, nil, true)
end

--玩家进入房间
function ChatManager:reEnterPlayer(data)
    data = data.result
    self.chatUserData_[data.user_id] = data
end

--接收礼物
function ChatManager:reGiveGift(data)
    data = data.result
    local playerId = bole:getUserDataByKey("user_id")
    for k ,v in pairs(data.target_id) do
        if v == playerId then
            local chatData = {}
            chatData.c_type = 1
            chatData.sender = data.sender
            chatData.type = "gift"

            local name = data.sender
            if self.chatUserData_[data.sender] ~= nil then
                name = self.chatUserData_[data.sender].name
            end
            
            chatData.msg = name .. " 向你赠送了"
            if data.give_type == 1 then
                local num = bole:getConfigCenter():getConfig("givecoins", data.give_id, "givecoins_amount")
                chatData.msg =  chatData.msg .. bole:formatCoins(num,15) .. "金币"
            elseif data.give_type == 2 then
                local str = bole:getConfigCenter():getConfig("buydrinks", data.give_id, "drinks_name")
                chatData.msg = chatData.msg .. "一杯" .. str
            end

            bole:postEvent("showInfoInSlot",{type = "gift" , id = data.sender , msg = chatData.msg})

            self:addChatMsg("chat",chatData)
        end
    end
end

--接收房间聊天信息
function ChatManager:reChat(t, data)
    if t == "chat" then
       
            if data.msg ~= nil and data.sender ~= nil then
                data.type = "chat"
                 if data.c_type == 1 then
                    bole:postEvent("showInfoInSlot",{type = "chat" , id = data.sender , msg = data.msg})
                end
                self:addChatMsg(t,data)
       
        end
    end
end

--接收游戏邀请
function ChatManager:reInvitePlay(data)
    data = data.result
    local chatData = {}
    chatData.c_type = 1
    chatData.sender = data.inviter
    chatData.type = "invite"
    chatData.userData = {}
    chatData.userData.name = data.inviter_name
    chatData.userData.user_id = data.inviter
    chatData.msg = data.inviter_name .. " invites you to play together."
    chatData.otherInfo = data
    self:addChatMsg("chat",chatData)
end

--接收公会购买信息
function ChatManager:reClubBuy(data)

end

--接收big win/mega win
function ChatManager:reBigWin(data)
    data = data.result
    if data.win_type >0 then
        local chatData = {}
        chatData.c_type = 1
        chatData.sender = data.user_id
        if self.chatUserData_[data.user_id] ~= nil then
            chatData.userData = self.chatUserData_[data.user_id]
            if data.win_type==1 then
                chatData.type = "bigWin"
                chatData.msg = chatData.userData.name .. " Big Win"
            else
                chatData.type = "megaWin"
                chatData.msg = chatData.userData.name .. " Mega Win"
            end
        end
        self:addChatMsg("chat",chatData)
    end
end


--接收like
function ChatManager:reLike(data)
    data = data.result
    local playerId = bole:getUserDataByKey("user_id")
    if playerId == data.target_id then
        local chatData = {}
        chatData.c_type = 1
        chatData.sender = data.sender
        chatData.type = "like"
        if self.chatUserData_[data.sender] ~= nil then
            chatData.userData = self.chatUserData_[data.sender]
            chatData.msg = chatData.userData.name .. " gives you a like."
        end

        bole:postEvent("showInfoInSlot",{type = "like" , id = data.sender , msg = chatData.msg})

        self:addChatMsg("chat",chatData)
    end
end

--添加聊天信息
function ChatManager:addChatMsg(t,data)
    local chat = {}
    chat.chatType = data.c_type
    chat.type = data.type
    chat.id = tonumber(data.sender)
    chat.msg = data.msg
    chat.isFormat = false

    if data.userData ~= nil then
        chat.userData = data.userData
    elseif self.chatUserData_[chat.id] ~= nil then
        chat.userData = self.chatUserData_[chat.id]
    end

    if data.otherInfo ~= nil then
        chat.otherInfo = data.otherInfo
    end

    --bole:postEvent("ShowChatInfo",{msg = data.msg, userData = chat.userData})
    if chat.userData ~= nil then
        bole:postEvent("addChatToView",{t, chat})
    elseif chat.id == bole:getUserDataByKey("user_id") then
        bole:postEvent("addChatToView",{t, chat})
    end

    if # self.chatMsg_ == ChatManager.MaxMsgNum then
        table.remove(self.chatMsg_, 1)
    end

    table.insert(self.chatMsg_, # self.chatMsg_ + 1, chat)
end

--取出聊天信息
function ChatManager:getChatMsg()
    return self.chatMsg_
end

--移除聊天室管理器
function ChatManager:removeChatManager()
    bole.socket:unregisterCmd("chat")
    bole:getEventCenter():removeEventWithTarget("addUserDataToChat", self)
    bole:getEventCenter():removeEventWithTarget("chat_giveGift", self)
    bole:getEventCenter():removeEventWithTarget("chat_invitePlay", self)
    bole:getEventCenter():removeEventWithTarget("chat_clubBuy", self)
    bole:getEventCenter():removeEventWithTarget("chat_bigWin", self)
    bole:getEventCenter():removeEventWithTarget("chat_like", self)
    self.chatMsg_ = nil
end

return ChatManager

--endregion