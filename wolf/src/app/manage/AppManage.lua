-- region *.lua
-- Date
-- 此文件由[BabeLua]插件自动生成
local AppManage = class("AppManage")
function AppManage:ctor(...)
    -- body
    self:init()
    print("AppManage-ctor")
end
function AppManage:init()

    local socket = cc.loadLua("network.Network")
    bole.socket = socket
    socket:onCreate(bole.SERVER_DEBUG_IP, bole.SERVER_PORT)
    socket:registerDelegate(self, self.serverStateChanged)
    bole.socket:registerCmd(bole.SERVER_ENTER_GAME, self.oncmd, self)
    bole.socket:registerCmd(bole.SERVER_B_SYNC, self.sync, self)
    bole.socket:registerCmd(bole.SERVER_PLAY_TOGETHER, self.room, self)
    bole.socket:registerCmd(bole.SEND_ROOM_INVITATION, self.room, self)
    bole.socket:registerCmd(bole.RECV_ROOM_INVITATION, self.room, self)
    bole.socket:registerCmd(bole.ACCEPT_ROOT_INVITATION, self.room, self)
    self.theme_id = 1
    self:initListener()
end 

function AppManage:initListener()

    bole:addListener("spin", self.spin, self, nil, true)
    bole:addListener("enterLobby", self.enterLobby, self, nil, true)
    bole:addListener("clear_scene", self.clearScene, self, nil, true)
    bole:addListener("facebookHeadImageUrl", self.fbUrl, self, nil, true)
    bole:getUIManage():initListener()
    bole:getAudioManage():initListener()
    bole:getMiniGameControl():initListener()
end
function AppManage:removeListener()
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
    bole:getUIManage():removeListener()
    bole:getAudioManage():removeListener()
    bole:getMiniGameControl():removeListener()
end

function AppManage:connectScoket()
    bole.socket:connect()
end
function AppManage:serverStateChanged(id, data)
    if id == MessageType.socket_open then
        print("-----------------------Sever Connect OK---------------------")
        self:login()
    elseif id == MessageType.socket_error then
        print("-----------------------Sever Connect ERROR---------------------")
--        bole:getLoginControl():openLoginView()
        self:connectScoket()
        bole:getLoginControl():openLoginView()
    elseif id == MessageType.socket_close then
        print("-----------------------Sever Connect CLOSE---------------------")
        self:connectScoket()
        bole:getLoginControl():openLoginView()
    end
end

function AppManage:getThemeId()
    return self.theme_id
end

function AppManage:getThemeData()
    --theme_cion theme_id
    return bole:getConfigCenter():getConfig("theme",self.theme_id)
end

-- login
function AppManage:login()
    bole:getLoginControl():login()
end
function AppManage:logout()

end
-- lobby
function AppManage:enterLobby()
    bole:postEvent("audio_stop_all_spin")
    bole:postEvent("clear_scene")
    bole:getUIManage():openUI(bole.UI_NAME.SlotsLobbyScene)
end
function AppManage:clearScene()
    bole:getUIManage():clearTips()
end
-- game
function AppManage:startGame(theme_id)
    -- 目前只有做完的主题
--    if theme_id ~= 1 and theme_id ~= 2 and theme_id ~= 3 and theme_id ~= 4 then return end
    self.theme_id = theme_id
    --test
--    if theme_id==4 then
--        bole:getUIManage():showUpLevel()
--        return
--    end

--    if theme_id ==5 then
--        local testm={"oz_prompt1","oz_prompt2"}
--        bole:postEvent("audio_prompt",testm)
--        return
--    end
--    if theme_id ==4 then
--        print("------------------------succecc")
--        local testm="oz_success"
--        bole:postEvent("audio_prompt_success",testm)
--        return
--    end
    
    self:continueGame()
end
function AppManage:overGame()

end

--进入游戏
function AppManage:continueGame(data)
    if data then
        bole:getSpinApp():startTheme(self.theme_id)
        bole:postEvent("enterThemeData", data)
    else
        bole:getSpinApp():startTheme(self.theme_id)
        local data = {}
        data.theme_id = self.theme_id
        bole.socket:send(bole.SERVER_ENTER_GAME, data, true)
    end
end

function AppManage:oncmd(t, data)
    -- body
    if t == bole.SERVER_ENTER_GAME then
        -- 目前回来协议没有返回选择的主题自己记录
        dump(data, "AppManage", 10)
        local isWild=false
        if data.freespin_type==1 or data.freespin_type==6 then
            isWild=true
        end
        local newData = { freeSpin = data.free_spins,wild=isWild,freeMutiple = data.fs_multiple, freeCollect = data.fs_collect, feature_id = data.fs_type }
        bole:postEvent("next_data", newData)
        bole:getMiniGameControl():enterFeature(data.feature)
        
        bole:postEvent("enterThemeData", data)
    end
end 

function AppManage:tryPop(data)
    self:updateUser(data)

    local isPop = false
    -- 5连
    if data["5ofakind"] == 1 then
        if self.theme_id ~= 5 then
--            local isCatch = { }
--            local spinApp = bole:getSpinApp()
--            for _, v in ipairs(data.win_lines) do
--                if v.feature == 0 and #v.icons >= 5 then
--                    if not isCatch[v.link] then
--                        isCatch[v.link] = v.link
--                        bole:postEvent("dialog_push", { msg = "kind", param = { theme_id = self.theme_id, link_id = v.link } })
--                    end
--                end
--            end
            bole:postEvent("dialog_push", { msg = "kind"})
            isPop = true
        end
    end
    -- 升级
    if data["levelup"] then
        bole:postEvent("dialog_push", { msg = "uplevel", param = data["levelup"] })
        isPop = true
    end
    -- 如果是freespin 直接返回
    if data["isFreeSpining"] then
        self:postDialog(isPop)
        return isPop
    end
    -- freeSpin 延后事件
    return self:tryDelayPop(data, isPop)

end
--延后处理
function AppManage:tryDelayPop(data, isPop)
    if data["big_win"] == 1 then
        bole:postEvent("dialog_push", { msg = "big_win", param = { score = data.fs_coins } })
        isPop = true
    elseif data["mega_win"] == 1 then
        bole:postEvent("dialog_push", { msg = "mega_win", param = { score = data.fs_coins } })
        isPop = true
    end

    self:postDialog(isPop)
    return isPop
end
--开始连续弹窗
function AppManage:postDialog(isPop)
    if isPop then
        bole:postEvent("dialog_pop")
    end
end
--spin结果
function AppManage:spin(event)
    bole:getUIManage():closeTips()
end

function AppManage:addCoins(coins)
    bole:getUserData():changeDataByKey("coins", tonumber(coins))
end
--更新用户数据 目前放在弹窗之前
function AppManage:updateUser(data)
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
        self:continueGame(data)
    elseif t == bole.SEND_ROOM_INVITATION then
        if data.success then
            bole:popMsg({msg="invitation success!"})
        end
    elseif t == bole.RECV_ROOM_INVITATION then
        bole:postEvent("chat_invitePlay",data)
        bole:popMsg({msg=data.inviter_name.." invites you to play togethe",cancle=true},function()
            bole.socket:send(bole.ACCEPT_ROOT_INVITATION,{room_id=data.room_id,theme_id=data.theme_id})
        end)
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
        self:continueGame(data)
    end
end

function AppManage:fbUrl(event)
    local url=event.result
    local user_id=bole:getUserData().user_id
    bole:getUrlImage(url,user_id,function(fileName, tagNum)
        if tagNum==user_id then
             bole:postEvent("eventImgPath",fileName)
             bole:saveCdnUrl(fileName,user_id)
        end
    end)
end

return AppManage
-- endregion
