-- region *.lua
-- Date
-- 此文件由[BabeLua]插件自动生成
local AppManage = class("AppManage")
function AppManage:ctor(...)
    -- body
    self.uplevels_list=bole:newBoleList()
    self:init()
    print("AppManage-ctor")
end
function AppManage:init()
    bole.socket:registerCmd(bole.SERVER_ENTER_GAME, self.oncmd, self)
    bole.socket:registerCmd(bole.SERVER_B_SYNC, self.sync, self)
    bole.socket:registerCmd(bole.SERVER_PLAY_TOGETHER, self.room, self)
    bole.socket:registerCmd(bole.SEND_ROOM_INVITATION, self.room, self)
    bole.socket:registerCmd(bole.RECV_ROOM_INVITATION, self.room, self)
    bole.socket:registerCmd(bole.ACCEPT_ROOT_INVITATION, self.room, self)
    bole.socket:registerCmd(bole.COLLECT_LOGIN_REWARD, self.oncmd, self)
    bole.socket:registerCmd(bole.GET_RECOMMEND_USERS, self.oncmd, self)
    self.theme_id = 1
    self:initListener()
end 

function AppManage:initListener()
    bole:addListener("UpLevelOver", self.upLevelOver, self, nil, true)
    bole:addListener("spin", self.spin, self, nil, true)
    bole:addListener("enterLobby", self.enterLobby, self, nil, true)
    bole:addListener("clear_scene", self.clearScene, self, nil, true)
    bole:addListener("facebookHeadImageUrl", self.fbUrl, self, nil, true)
    bole:getUIManage():initListener()
    bole:getAudioManage():initListener()
    bole:getMiniGameControl():initListener()
    bole:getClubManage():initListener()
    bole:getFriendManage():initListener()
    bole:getBuyManage():initListener()
    bole:getChatManage():initListener()
end

function AppManage:removeListener()
    bole:getEventCenter():removeEventWithTarget("UpLevelOver", self)
    bole:getEventCenter():removeEventWithTarget("spin", self)
    bole:getEventCenter():removeEventWithTarget("enterLobby", self)
    bole:getEventCenter():removeEventWithTarget("clear_scene", self)
    bole:getEventCenter():removeEventWithTarget("facebookHeadImageUrl", self)
    bole.socket:unregisterCmd(bole.SERVER_ENTER_GAME)
    bole.socket:unregisterCmd(bole.SERVER_B_SYNC)
    bole.socket:unregisterCmd(bole.SERVER_PLAY_TOGETHER)
    bole.socket:unregisterCmd(bole.SEND_ROOM_INVITATION)
    bole.socket:unregisterCmd(bole.RECV_ROOM_INVITATION)
    bole.socket:unregisterCmd(bole.ACCEPT_ROOT_INVITATION)
    bole.socket:unregisterCmd(bole.COLLECT_LOGIN_REWARD)
    bole.socket:unregisterCmd(bole.GET_RECOMMEND_USERS)
    bole:getUIManage():removeListener()
    bole:getAudioManage():removeListener()
    bole:getMiniGameControl():removeListener()
    bole:getClubManage():removeListener()
    bole:getFreindManage():removeListener()
    bole:getChatManage():removeListener()
end

function AppManage:getThemeId()
    return self.theme_id
end

function AppManage:getThemeData()
    return bole:getConfigCenter():getConfig("theme", self.theme_id)
end
--level
function AppManage:addUpLevel(item)
    if not self.targetLevel then
        self.targetLevel=bole:getUserDataByKey("level")
    end
    item.level=self.targetLevel
    self.uplevels_list:push(item)
    self.targetLevel=item.level+1
--    bole:setUserDataByKey("experience",bole:getUserDataByKey("experience"))
end

function AppManage:popUpLevel()
    return self.uplevels_list:pop()
end

function AppManage:clearUpLevel()
    self.uplevels_list:clear()
    self.isTryShowUpLevel=false
    --中断调用升级
    if self.targetLevel then
        bole:setUserDataByKey("level",self.targetLevel)
        self.targetLevel=nil
    end
end

function AppManage:emptyUpLevel()
    return self.uplevels_list:empty()
end

function AppManage:tryShowUpLevel()
    --进度条满调用升级
    if self.targetLevel then
        local level=bole:getUserDataByKey("level")
        if self.targetLevel>level then
            bole:setUserDataByKey("level",level+1)
        end
    end

    if self.isTryShowUpLevel then
        return
    end
    self.isTryShowUpLevel=true
    self:upLevelOver()
end

function AppManage:upLevelOver()
    if self:emptyUpLevel() then
        self:clearUpLevel()
        return
    end
    local levelup = bole:getAppManage():popUpLevel()
    bole:getUIManage():showUpLevel( { levelup },levelup.level)
end

--
-- login
function AppManage:logout()

end
-- lobby
function AppManage:enterLobby(data)
    self:clearUpLevel()
    local isOpenScene
    if data then
        isOpenScene=data.result
    end
    bole:postEvent("clear_scene")
    if isOpenScene then 
        bole:getAudioManage():clearTheme()
        bole:getUIManage():openScene("LobbyScene")
    end
    bole:postEvent("LobbyScene","slot")
end
-- lobby
function AppManage:enterLobbyAndOpenLayer(layerName)
    bole:postEvent("clear_scene")
    bole:getAudioManage():clearTheme()
    bole:getUIManage():openScene("LobbyScene")
    bole:postEvent("LobbyScene",layerName)
end
--更新大厅推荐
function AppManage:updateLobby()
    if not bole.lobby_update_time then
        bole.lobby_update_time=600
        bole.socket:send(bole.GET_RECOMMEND_USERS, {})
        return
    end
    if bole.lobby_update_time<=0 then
        bole.lobby_update_time=600
        bole.socket:send(bole.GET_RECOMMEND_USERS, {})
    end
end


function AppManage:setClubInfo(data)
   self.clubInfo=data
end

function AppManage:getClubInfo()
   return self.clubInfo
end

function AppManage:clearScene()
    bole:getUIManage():clearTips()
end
-- game
function AppManage:startGame(theme_id,is_private)
    print("AppManage:startGame")
    self.theme_id = theme_id
    self:continueGame(nil,is_private)
end

function AppManage:overGame()

end

--进入游戏
function AppManage:continueGame(data,is_private)
    self:clearUpLevel()
    if data then
        print("AppManage:continueGame have data")
        bole:getSpinApp():startTheme(self.theme_id)
        bole:postEvent("enterThemeData", data)
    else
        print("AppManage:continueGame nil data")
        bole:getSpinApp():startTheme(self.theme_id)

        self:sendEnterTheme(self.theme_id, is_private)
    end
end

function AppManage:sendEnterTheme(themeId, isPrivate)
    bole.socket:send(bole.SERVER_ENTER_GAME, {theme_id = themeId, is_private = isPrivate})
    self.isPrivate = isPrivate
end

function AppManage:oncmd(t, data)
    -- body
    if t == bole.SERVER_ENTER_GAME then
        -- 目前回来协议没有返回选择的主题自己记录
        if table.empty(data) then
            bole.socket:send(bole.SERVER_LEAVE_THEME, {})
            self:sendEnterTheme(self.theme_id, self.is_private)
        else
            bole:postEvent("enterThemeData", data)
        end
    elseif t== bole.COLLECT_LOGIN_REWARD then
        if data.error==0 then
            bole:getUIManage():popDailyGift(data.reward)
--            bole:getUIManage():openUI("LobbyScene")
        else
            bole:getUIManage():openUI("LobbyScene")
        end
    elseif t== bole.GET_RECOMMEND_USERS then
        bole.recommend_users=data
        bole.recommend_index=1
        bole.recommend_max=#data
    end
end 

--spin结果
function AppManage:spin(event)
    bole:getUIManage():closeTips()
end

function AppManage:addCoins(coins)
    bole:getUserData():changeDataByKey("coins", tonumber(coins))
end
function AppManage:addDiamond(diamond)
    bole:getUserData():changeDataByKey("diamond", tonumber(diamond))
end
--更新用户数据 目前放在弹窗之前
function AppManage:updateUser(data)
    dump(data,"AppManage:updateUser")
    if data and data.experience then
        bole:setUserDataByKey("experience",data.experience)
    end
end

function AppManage:sync(t, data)
    if t == bole.SERVER_B_SYNC then
        -- 目前回来协议没有返回选择的主题自己记录
        dump(data, "SERVER_B_SYNC", 10)
    end
end

function AppManage:sendPlayTogether(user_id,room_id,theme_id)
--    self.pt_themeid=theme_id
    bole.socket:send(bole.SERVER_PLAY_TOGETHER,{user_id=user_id,room_id=room_id,theme_id=theme_id})
end
function AppManage:sendAcceptIntive(user_id,room_id,theme_id)
--    self.acci_themeid=theme_id
    bole.socket:send(bole.ACCEPT_ROOT_INVITATION,{user_id=user_id,room_id=room_id,theme_id=theme_id})
end
function AppManage:room(t, data)
    dump(data,"AppManage:room:"..t)
    if t == bole.SERVER_PLAY_TOGETHER then
        if data.error then
            if data.error==2 then
                bole:popMsg({msg="The room is full"})
            else
                bole:popMsg({msg=bole.SERVER_PLAY_TOGETHER.."error code:"..data.error})
            end
            return
        end
        self.theme_id=tonumber(data.theme_id)
--        self.theme_id=tonumber(self.pt_themeid)
        self:continueGame(data)
    elseif t == bole.SEND_ROOM_INVITATION then
        if data.success then
            bole:popMsg({msg="invitation success!"})
        end
    elseif t == bole.RECV_ROOM_INVITATION then
        bole:postEvent("chat_invitePlay",data)
        bole:getNoticeCenter():onResponse(t,data)
--        bole:popMsg({msg=data.inviter_name.." invites you to play together",cancle=true},function()
--            self:sendAcceptIntive(data.inviter,data.room_id,data.theme_id)
--        end)
    elseif t == bole.ACCEPT_ROOT_INVITATION then
        if data.error then
            if data.error==2 then
                bole:popMsg({msg="The room is full"})
            else
                bole:popMsg({msg=bole.ACCEPT_ROOT_INVITATION.."error code:"..data.error})
            end
            return
        end
        self.theme_id=tonumber(data.theme_id)
--        self.theme_id=tonumber(self.acci_themeid)
        self:continueGame(data)
    end
end

function AppManage:fbUrl(event)
    local url = event.result
    local user_id = bole:getUserData().user_id
    bole:getUrlImage(url, false, function(fileName, eventCode)
        if eventCode == 6 then
            bole:postEvent("eventImgPath", {fileName,eventCode})
            bole:saveCdnUrl(user_id,fileName,true)
            bole:setUserDataByKey("icon", "self")
            bole:uploadUserInfo()
        end
    end )
end

return AppManage
-- endregion
