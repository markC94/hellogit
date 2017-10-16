--region *.lua
--Date
--此文件由[BabeLua]插件自动生成

local ChatManage = class("ChatManage")
ChatManage.MaxMsgNum = 30    --最大存储数

function ChatManage:initListener()
    self.userInfoList_ = {}
    self.gameChatMsg_ = {}
    self.clubChatMsg_ = {}
    self.notShowChatNum_ = 0

    bole.socket:registerCmd("chat", self.reChat, self, true)
    bole.socket:registerCmd("give", self.reGive, self, true)
    bole.socket:registerCmd("like", self.reLike, self, true)
    bole.socket:registerCmd("gift", self.reSale, self, true)

    bole:addListener("addUserDataToChat", self.reEnterPlayer, self, nil, true)
    bole:addListener("removeUserDataToChat", self.reLeavePlayer, self, nil, true)
    bole:addListener("chat_invitePlay", self.reInvitePlay, self, nil, true)
    bole:addListener("chat_clubBuy", self.reClubBuy, self, nil, true)
    bole:addListener("chat_clubTask", self.reClubTask, self, nil, true)
    bole:addListener("chat_bigWin", self.reBigWin, self, nil, true)
end

function ChatManage:cleanLocalData()
    self.userInfoList_ = nil
    self.gameChatMsg_ = nil
    self.clubChatMsg_ = nil
    self.notShowChatNum_ = nil
    self:removeListener()
end


function ChatManage:removeListener()
    bole.socket:unregisterCmd("chat")
    bole.socket:unregisterCmd("give")
    bole.socket:unregisterCmd("like")
    bole.socket:unregisterCmd("sale")

    bole:removeListener("addUserDataToChat", self)
    bole:removeListener("removeUserDataToChat", self)
    bole:removeListener("chat_invitePlay", self)
    bole:removeListener("chat_clubBuy", self)
    bole:removeListener("chat_clubTask", self)
    bole:removeListener("chat_bigWin", self)
end

function ChatManage:reEnterPlayer(data)
    data = data.result
    self.userInfoList_[data.user_id] = data
end

function ChatManage:reLeavePlayer(data)
    data = data.result
    self.userInfoList_[data.user_id] = nil
end

function ChatManage:reChat(t,data)
    if data.msg ~= nil and data.sender ~= nil then
        data.infoType = "chat"
        data.isFormat = false
        data.userData = {}
        data.userData.user_id = data.sender
        data.userData.name = data.sender_name
        data.userData.icon = data.sender_icon

        self:addInfoToList(data.c_type, data)
        bole:postEvent("addInfoInListView", data)
        if data.c_type == 1 then
            bole:postEvent("addInfoInFuncView", data)
            if data.sender ~= bole:getUserDataByKey("user_id") then
                self.notShowChatNum_  = math.min(self.notShowChatNum_  + 1,30)
                bole:postEvent("showNewMessageNum", self.notShowChatNum_)
            end
        end
    end
end

function ChatManage:reGive(t,data)
    if data.give_id ~= nil then
        local id_me = bole:getUserDataByKey("user_id")
        if id_me == data.sender then
            -- TODO 我赠别人
            bole:postEvent("closeGiftLayer",data)
            bole:postEvent("closeSlotFuncUI",data)
            bole:postEvent("showGiftAct",data)
            bole:refreshCoinsAndDiamondInSlot()
        else
            for _, id in pairs(data.target_id) do
                if id_me == id then
                    local chatData = { }
                    chatData.c_type = 1
                    chatData.sender = data.sender
                    chatData.infoType = "gift"
                    chatData.isFormat = false
                    chatData.sender_name = data.sender
                    chatData.give_type = data.give_type
                    chatData.give_id = data.give_id

                    if self.userInfoList_[data.sender] ~= nil then
                        chatData.sender_name = self.userInfoList_[data.sender].name
                        chatData.userData = self.userInfoList_[data.sender]
                    end

                    chatData.msg = chatData.sender_name .. " gives you "
                    if data.give_type == 1 then
                        local num = bole:getConfigCenter():getConfig("givecoins", data.give_id, "givecoins_amount")
                        chatData.msg = chatData.msg .. bole:formatCoins(num, 15) .. "coins"
                        bole:refreshCoinsAndDiamondInSlot()
                    elseif data.give_type == 2 then
                        local str = bole:getConfigCenter():getConfig("buydrinks", data.give_id, "drinks_name")
                        chatData.msg = chatData.msg .. "a " .. str
                    end

                    self:addInfoToList(1,chatData)
                    bole:postEvent("addInfoInListView", chatData)
                    --bole:postEvent("addInfoInFuncView", chatData)
                end
            end
            bole:postEvent("showGiftActByOther", data)
        end
    elseif data.error == 5 then
        bole:postEvent("showNoBuyLayer")
    end
end

function ChatManage:reLike(t,data)
    if data.error ~= nil and data.error ~= 0 then
        if data.error == 1 then
            bole:popMsg({msg ="The player is not in the room" , title = "like" , cancle = false})
        else
            bole:popMsg({msg ="error: " .. data.error , title = "like" , cancle = false})
        end
        return
    end
    if data.sender ~= nil then
        local id_me = bole:getUserDataByKey("user_id")
        if id_me == data.sender then
            if data.like_type ~= 2 then
                local likeToPlayerList = bole:getUserDataByKey("likeToPlayerList")
                if likeToPlayerList == 0 then
                    likeToPlayerList = { }
                end
                likeToPlayerList[data.target_id] = os.time()
                bole:setUserDataByKey("likeToPlayerList", likeToPlayerList)
            end
            bole:postEvent("reLikeToPlayer", data)
        elseif id_me == data.target_id then
            local chatData = {}
            chatData.c_type = 1
            chatData.sender = data.sender
            chatData.infoType = "like"
            chatData.isFormat = false
            chatData.sender_name = data.sender
            if self.userInfoList_[data.sender] ~= nil then
                chatData.sender_name = self.userInfoList_[data.sender].name
                chatData.userData = self.userInfoList_[data.sender]
            end
            chatData.msg = chatData.userData.name .. " gives you a like."

            --self:addInfoToList(1,chatData)
            --bole:postEvent("addInfoInListView", chatData)
            --bole:postEvent("addInfoInFuncView", chatData)

            local syncUserInfo = bole:getUserData():getSyncUserInfo()
            local likes = syncUserInfo.likes
            bole:setUserDataByKey("likes",likes)
            bole:postEvent("changeLike_topView",likes) 
            bole:postEvent("showLikeActByOther",data)     
        else
            bole:postEvent("showLikeActByOther",data) 
        end
    end
end

function ChatManage:reSale(t,data)
    local sender = data.sender
    local coins = data.coins
    bole:postEvent("showSaleAct", data) 
end

function ChatManage:reInvitePlay(data)
    data = data.result
    local chatData = {}
    chatData.c_type = 1
    chatData.sender = data.inviter
    chatData.infoType = "invite"
    chatData.isFormat = false
    chatData.sender_name = data.inviter_name
    chatData.userData = {}
    chatData.userData.name = data.inviter_name
    chatData.userData.user_id = data.inviter
    chatData.msg = chatData.sender_name .. " invites you to play together."
    chatData.otherInfo = data

    --self:addInfoToList(1,chatData)
    --bole:postEvent("addInfoInListView", chatData)
end

function ChatManage:reClubBuy(data)
    data = data.result
    local chatData = {}
    chatData.c_type = 2
    chatData.sender = data.user_id
    chatData.infoType = "clubBuy"
    chatData.isFormat = false
    chatData.sender_name = data.name
    chatData.userData = {}
    chatData.userData.name = data.name
    chatData.userData.user_id = data.user_id
    chatData.userData.icon = data.icon
    chatData.msg = chatData.sender_name .. " purchased a Club Offer and won 50K coins."
    chatData.otherInfo = data

    self:addInfoToList(2,chatData)
    bole:postEvent("addInfoInListView", chatData)
end

function ChatManage:reClubTask(data)
    data = data.result
end

function ChatManage:reBigWin(data)
    data = data.result
    if data.win_type ~=0 then
        local chatData = {}
        chatData.c_type = 1
        chatData.sender = data.user_id
        chatData.sender_name = data.user_id
        chatData.infoType = "bigWin"
        chatData.isFormat = false
        chatData.msg = data.user_id .. " Big Win"
        chatData.win_coins = data.win_coins
        chatData.win_type = data.win_type

        if self.userInfoList_[data.user_id] ~= nil then
            chatData.userData = self.userInfoList_[data.user_id]
            if data.win_type==1 then
                chatData.infoType = "bigWin"
                chatData.sender_name = chatData.userData.name
                chatData.msg = chatData.userData.name .. " hit a Big Win and won " .. bole:formatCoins( chatData.win_coins, 15) .. " coins."
            elseif data.win_type==2 then
                chatData.infoType = "megaWin"
                chatData.sender_name = chatData.userData.name
                chatData.msg = chatData.userData.name .. " hit a Mega Win and won " .. bole:formatCoins( chatData.win_coins, 15) .. " coins."
            elseif data.win_type==3 then
                chatData.infoType = "crazyWin"
                chatData.sender_name = chatData.userData.name
                chatData.msg = chatData.userData.name .. " hit a Crazy Win and won " .. bole:formatCoins( chatData.win_coins, 15) .. " coins."
            elseif data.win_type==-1 then
                chatData.infoType = "freeSpin"
                chatData.sender_name = chatData.userData.name
                chatData.msg = chatData.userData.name .. " hit a FreeSpin and won " .. bole:formatCoins( chatData.win_coins, 15) .. " coins."               

            end
        end
        
        --self:addInfoToList(1,chatData)
        --bole:postEvent("addInfoInListView", chatData)
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

function ChatManage:cleanGameChatMsg()
    self.gameChatMsg_ = {}
end

function ChatManage:getNewMessageNum()
    return self.notShowChatNum_
end

function ChatManage:cleanNewMessageNum()
    self.notShowChatNum_ = 0
    bole:postEvent("showNewMessageNum", self.notShowChatNum_)
end


return ChatManage

--endregion
