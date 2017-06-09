--region *.lua
--Date
--此文件由[BabeLua]插件自动生成

local ChatManage = class("ChatManage")
ChatManage.MaxMsgNum = 30    --最大存储数

function ChatManage:ctor(...)
    print("ChatManage-ctor")
    self:init()
    self:initListener()
end

function ChatManage:init()
    self.userInfoList_ = {}
    self.gameChatMsg_ = {}
    self.clubChatMsg_ = {}
end

function ChatManage:initListener()
    bole.socket:registerCmd("chat", self.reChat, self)
    bole.socket:registerCmd("send_club_invitation", self.reInvitationClub, self, true)
    bole.socket:registerCmd("give", self.reGive, self, true)
    bole.socket:registerCmd("like", self.reLike, self, true)

    bole:addListener("addUserDataToChat", self.reEnterPlayer, self, nil, true)
    bole:addListener("chat_invitePlay", self.reInvitePlay, self, nil, true)
    bole:addListener("chat_clubBuy", self.reClubBuy, self, nil, true)
    bole:addListener("chat_clubTask", self.reClubTask, self, nil, true)
    bole:addListener("chat_bigWin", self.reBigWin, self, nil, true)
end

function ChatManage:removeListener()
    bole.socket:unregisterCmd("chat")
    bole.socket:unregisterCmd("send_club_invitation")
    bole.socket:unregisterCmd("give")
    bole.socket:unregisterCmd("like")
    bole:removeListener("addUserDataToChat", self)
    bole:removeListener("chat_invitePlay", self)
    bole:removeListener("chat_clubBuy", self)
    bole:removeListener("chat_clubTask", self)
    bole:removeListener("chat_bigWin", self)
end

function ChatManage:reEnterPlayer(data)
    data = data.result
    self.userInfoList_[data.user_id] = data
end

--{c_type = 1 , msg = "123" , sender = 10000 , sender_name = "name"}
function ChatManage:reChat(t,data)
    if self.userInfoList_[data.sender] ~= nil then
       data.userData = self.userInfoList_[data.sender]
    end
    data.infoType = "chat"
    self:addInfoToList(1,data)
    bole:postEvent("addInfoInListView", data)
    bole:postEvent("addInfoInFuncView", data)
end

function ChatManage:reInvitationClub(t,data)
    if data.success == 1 then
        bole:postEvent("invitePlayerClub", { success = 1 })
    else
        bole:postEvent("invitePlayerClub", { success = 0 })
    end
end

function ChatManage:reGive(t,data)
    if data.give_id ~= nil then
        local id_me = bole:getUserDataByKey("user_id")
        if id_me == data.sender then
            -- TODO 我赠别人
        else
            for _, id in pairs(data.target_id) do
                if id_me == id then
                    local chatData = { }
                    chatData.c_type = 1
                    chatData.sender = data.sender
                    chatData.infoType = "gift"
                    chatData.sender_name = data.sender
                    if self.userInfoList_[data.sender] ~= nil then
                        chatData.sender_name = self.userInfoList_[data.sender].name
                        chatData.userData = self.userInfoList_[data.sender]
                    end

                    chatData.msg = name .. " 向你赠送了"
                    if data.give_type == 1 then
                        local num = bole:getConfigCenter():getConfig("givecoins", data.give_id, "givecoins_amount")
                        chatData.msg = chatData.msg .. bole:formatCoins(num, 15) .. "金币"
                    elseif data.give_type == 2 then
                        local str = bole:getConfigCenter():getConfig("buydrinks", data.give_id, "drinks_name")
                        chatData.msg = chatData.msg .. "一杯" .. str
                    end

                    self:addInfoToList(1,chatData)
                    bole:postEvent("addInfoInListView", chatData)
                    bole:postEvent("addInfoInFuncView", chatData)
                end
            end
        end
    elseif data.error == 6 then
        if data.give_type == 1 then
            bole:popMsg( { msg = "钻石不足", title = "Gift" })
        elseif data.give_type == 2 then
            bole:popMsg( { msg = "金币不足", title = "Gift" })
        end
    end

end

function ChatManage:reLike(t,data)

    if data.sender ~= nil then
        local id_me = bole:getUserDataByKey("user_id")
        if id_me == data.sender then
            local likeToPlayerList = bole:getUserDataByKey("likeToPlayerList")
            if likeToPlayerList == 0 then
                likeToPlayerList = { }
            end
            likeToPlayerList[data.target_id] = os.time()
            bole:setUserDataByKey("likeToPlayerList", likeToPlayerList)
            bole:postEvent("likeToPlayer", chatData)
        elseif id_me == data.target_id then
            local chatData = {}
            chatData.c_type = 1
            chatData.sender = data.sender
            chatData.infoType = "like"
            chatData.sender_name = data.sender
            if self.userInfoList_[data.sender] ~= nil then
                chatData.sender_name = self.userInfoList_[data.sender].name
                chatData.userData = self.userInfoList_[data.sender]
            end
            chatData.msg = chatData.userData.name .. " gives you a like."

            self:addInfoToList(1,chatData)
            bole:postEvent("addInfoInListView", chatData)
            bole:postEvent("addInfoInFuncView", chatData)
        end
    end
end

function ChatManage:reInvitePlay(data)
    data = data.result
    local chatData = {}
    chatData.c_type = 1
    chatData.sender = data.inviter
    chatData.infoType = "invite"
    chatData.sender_name = data.inviter_name
    chatData.userData.name = {}
    chatData.userData.name = data.inviter_name
    chatData.userData.user_id = data.inviter
    chatData.msg = chatData.sender_name .. " invites you to play together."
    chatData.otherInfo = data

    self:addInfoToList(1,chatData)
    bole:postEvent("addInfoInListView", chatData)
end

function ChatManage:reClubBuy(data)


end

function ChatManage:reClubTask(data)

end

function ChatManage:chat_bigWin(data)
    data = data.result
    if data.win_type >0 then
        local chatData = {}
        chatData.c_type = 1
        chatData.sender = data.sender
        chatData.sender_name = data.sender
        chatData.infoType = "bigWin"
        chatData.msg = data.sendere .. " Big Win"

        if self.chatUserData_[data.user_id] ~= nil then
            chatData.userData = self.chatUserData_[data.user_id]
            if data.win_type==1 then
                chatData.infoType = "bigWin"
                chatData.sender_name = chatData.userData.name
                chatData.msg = chatData.userData.name .. " Big Win"
            else
                chatData.infoType = "megaWin"
                chatData.sender_name = chatData.userData.name
                chatData.msg = chatData.userData.name .. " Mega Win"
            end
        end
        
        self:addInfoToList(1,chatData)
        bole:postEvent("addInfoInListView", chatData)
        bole:postEvent("addInfoInFuncView", chatData)
    end
end

function ChatManage:addInfoToList(type,data)
    if type == 1 then
        if # self.gameChatMsg_ == ChatManage.MaxMsgNum then
            table.remove(self.gameChatMsg_, 1)
        end
        table.insert(self.gameChatMsg_, #self.gameChatMsg_ + 1, data)
    elseif type == 2 then
        if # self.clubChatMsg_ == ChatManage.MaxMsgNum then
            table.remove(self.clubChatMsg_, 1)
        end
        table.insert(self.clubChatMsg_, #self.clubChatMsg_ + 1, data)
    end
end

function ChatManage:getChatMsg(type)
    if type == 1 then
        return self.gameChatMsg_
    elseif type == 2 then
        return self.clubChatMsg_
    end
end

return ChatManage

--endregion
