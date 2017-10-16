-- region *.lua
-- Date
-- 此文件由[BabeLua]插件自动生成
local InformationView = class("InformationView", cc.load("mvc").ViewBase)
function InformationView:onCreate()
    print("InformationView-onCreate")
    local root = self:getCsbNode():getChildByName("root")
    root:setVisible(false)
    root:setScale(0.01)
    self.data = nil
    self.isSelf = false
    bole:postEvent("exitNewbieInfo")
end

function InformationView:onKeyBack()
   self:closeUI()
end

function InformationView:onEnter()
    bole:addListener("titleChanged", self.eventTitle, self, nil, true)
    bole:addListener("changeInfo", self.changeInfo, self, nil, true)
    bole:addListener("closeInformationView", self.closeUI, self, nil, true)
    bole:addListener("changeClub", self.changeClub, self, nil, true)
    bole:addListener("updateClub_informationView", self.updateClubInfo, self, nil, true)
    bole:addListener("infoCoinsJump", self.infoCoinsJump, self, nil, true)
    bole.socket:registerCmd("remove_friend", self.reRemove_friend, self)
--    bole.socket:registerCmd(bole.SYNC_HEAD_INFO, self.syncHeadInfo, self)
    bole.socket:registerCmd("apply_for_friend", self.reApplyFriend, self)
    bole.socket:registerCmd("send_club_invitation", self.reInvitationClub, self, true)
end

function InformationView:onExit()
    bole:getEventCenter():removeEventWithTarget("changeInfo", self)
    bole:getEventCenter():removeEventWithTarget("titleChanged", self)
    bole:getEventCenter():removeEventWithTarget("closeInformationView", self)
    bole:getEventCenter():removeEventWithTarget("changeClub", self)
    bole:getEventCenter():removeEventWithTarget("updateClub_informationView", self)
    bole:getEventCenter():removeEventWithTarget("infoCoinsJump", self)
    if self.dailyView ~= nil then
        if self.dailyView.exit then
            self.dailyView:exit()
        end
        self.dailyView=nil
    end
    bole.socket:unregisterCmd("remove_friend")
--    bole.socket:unregisterCmd(bole.SYNC_HEAD_INFO)
    bole.socket:unregisterCmd("apply_for_friend")
    bole.socket:unregisterCmd("send_club_invitation")
    bole:postEvent("closeSlotFuncUI")
end

function InformationView:infoCoinsJump(data)
    data = data.result
    bole:getAudioManage():playMusic("common_cc",true)
    bole:getUIManage():flyCoin(data.pos,self.sp_money:getWorldPosition(),function() bole:getAudioManage():stopAudio("common_cc") end,data.randomNum)

    local bonusNode = sp.SkeletonAnimation:create("common_act/JBbaozha.json", "common_act/JBbaozha.atlas")
    bonusNode:setScale(0.7)
    self:addChild(bonusNode)
    bonusNode:setPosition(data.pos.x,data.pos.y)
    bonusNode:setAnimation(0, "animation", false)

--    local btn_collectAnima = sp.SkeletonAnimation:create("common_act/gaizhang_1.json", "common_act/gaizhang_1.atlas")
--    btn_collectAnima:setAnimation(1, "animation", false)
--    btn_collectAnima:setPosition(data.pos)
--    display.getRunningScene():addChild(btn_collectAnima,bole.ZORDER_UI)
    
    local time = 1
    performWithDelay(self, function()
        bole:jumpNode(self.sp_money, time)
        bole:runNum(self.txt_money, tonumber(self.txt_money:getString()),tonumber(self.txt_money:getString())+ data.coins, time, nil,nil,true)
        bole:getAppManage():addCoins(data.coins)
    end , time)
end

function InformationView:syncHeadInfo(t, data)
    if t == bole.SYNC_HEAD_INFO then
        dump(data, "syncHeadInfo")
        if self.onlyUpdateClubInfo_ then
            self.onlyUpdateClubInfo_ = false
            self.data = data
            self:initClub(self.info)
        else
            self:initSyncHeadInfo(data)
        end
    end
end
function InformationView:changeInfo(event)
    for k, v in pairs(bole:getUserData()) do
        self.data[k] = v
    end
    self:updateInfo()
end
function InformationView:eventTitle(event)
    local index = bole:getUserDataByKey("title", event.result)
    local name = bole:getConfig("title", index, "title_name")
    --    if not name then
    --        self.txt_title:setString("TITLE:无")
    --    else
    --        self.txt_title:setString("TITLE:"..name)
    --    end
end

function InformationView:showInfo(data)
    dump(data,"InformationView-showInfo")
    self.headNode=data[1]
    self.isSelf = data[2]
    self.pos = data[3]
end
function InformationView:initSyncHeadInfo(data)
    self.data = data
    local root = self:getCsbNode():getChildByName("root")
    root:setVisible(true)
    root:runAction(cc.ScaleTo:create(0.2, 1.0))

    self.info = root:getChildByName("info")
    local money = root:getChildByName("money")
    local daily = root:getChildByName("daily")
    local other = root:getChildByName("other")

    local btn_close = root:getChildByName("btn_close")
    btn_close:addTouchEventListener(handler(self, self.touchEvent))

    self:initInfo()
    self:initMoney(money)
    self:initDaily(daily)
    self:initOther(other)
    self:initClub(self.info)
end
function InformationView:initInfo()

    local node_head = self.info:getChildByName("node_head")
    local nHead = bole:getNewHeadView(self.data)
    node_head:addChild(nHead)
    local img_namebg = self.info:getChildByName("img_namebg")
    local ttfConfig = {fontFilePath="font/bole_ttf.ttf",fontSize=30}
    self.txt_name = cc.Label:createWithTTF(ttfConfig,"99")
    self.txt_name:setTextColor({r = 246, g = 215, b = 95 })
    local mask = display.newSprite("information/info_namebg.png")
    local clipNode = cc.ClippingNode:create()
    clipNode:setAlphaThreshold(0)
    clipNode:setStencil(mask)
    clipNode:setScale(0.95)
    clipNode:setPosition(102, 22.0000)
    clipNode:addChild(self.txt_name)
    img_namebg:addChild(clipNode)
    local sp_edit = self.info:getChildByName("sp_edit")
    if self.isSelf then
        nHead:updatePos(nHead.POS_INFO_SELF)
        sp_edit:setVisible(true)
    else
        sp_edit:setVisible(false)
        nHead:updatePos(nHead.POS_INFO_FRIEND)
        img_namebg:setPosition(162,40)
        node_head:setPosition(162,175)
    end

    self:updateInfo()
end

function InformationView:updateInfo()
    self.txt_name:setString(self.data.name)
    self.txt_name:setPosition(0,0)
    bole:moveStr(self.txt_name, 180)
    local txt_id = self.info:getChildByName("txt_id")
    txt_id:setString("ID:" .. self.data.user_id)
    txt_id:setVisible(self.isSelf)
    local txt_age = self.info:getChildByName("txt_age")
    txt_age:setString(self.data.age)
    local txt_city = self.info:getChildByName("txt_city")
    local strc = bole:limitStr(self.data.city, 10, "...")
    txt_city:setString(strc)

    local txt_status = self.info:getChildByName("txt_status")
    if self.data.marital_status then
        local name = {"Secret","Single","In a relationship","Married"}
        txt_status:setString(name[self.data.marital_status + 1])
    end
    local txt_gender = self.info:getChildByName("txt_gender")
    local sexs = {"Secret","Female", "Male"}
    if self.data.gender then
        txt_gender:setString(sexs[self.data.gender + 1])
    end
    

    self.info:addTouchEventListener(handler(self, self.touchEvent))
    self.info:setTouchEnabled(self.isSelf)

    local img_editbg = self.info:getChildByName("img_editbg")
--    img_editbg:addTouchEventListener(handler(self, self.touchEvent))
--    img_editbg:setTouchEnabled(self.isSelf)


    self.txt_edit = self.info:getChildByName("txt_edit")
--    self.txt_edit:setTextColor( {r = 28, g = 41, b = 77})
    if not bole:isStrExists(self.data.signature) then
        if self.isSelf then
            self.txt_edit:setTextColor( {r = 102, g = 102, b = 162})
            self.txt_edit:setString("What's on your mind?")
        else
            self.txt_edit:setString("Enjoy Slots with Friends.")
        end
    else
        self.txt_edit:setString(bole:getNewStr(self.data.signature, 30, 500) )
    end

--    local vip = self.info:getChildByName("node_vip")
--    vip:setTouchEnabled(self.isSelf)
--    vip:addTouchEventListener(handler(self, self.touchEvent))
end
function InformationView:changeClub(data)
    self.data.club_info = data.result
    self:initClub(self.info)
end

function InformationView:initClub(root)
    local club = root:getChildByName("sp_club")
    local not_club = root:getChildByName("img_notClub")
    if self.data.club_info then
        club:setVisible(true)
        not_club:setVisible(false)
        local sp_icon = club:getChildByName("sp_icon")
        local sp_league = club:getChildByName("sp_league")
        local txt_name = club:getChildByName("txt_name")
        local txt_member = club:getChildByName("txt_member")
        txt_name:setString(self.data.club_info.name)
        local str_index = string.format("%02d", self.data.club_info.league_level)
        local league = bole:getConfig("league", str_index)
        --排行目前没有图标

        local titles = { "leader", "co_leader", "member" }
        txt_member:setString(titles[self.data.club_info.club_title])
        sp_icon:loadTexture(bole:getClubManage():getClubIconPath(self.data.club_info.icon))
        club:loadTexture(bole:getClubManage():getLeagueBgPath(self.data.club_info.league_level))
        sp_league:loadTexture(bole:getClubManage():getLeagueIconPath(self.data.club_info.league_level))
        sp_icon:setTouchEnabled(true)
        sp_icon:addTouchEventListener(handler(self, self.touchEvent))
    else
        club:setVisible(false)
        not_club:setVisible(true)

        local txt_self = not_club:getChildByName("txt_self")
        local txt_self_2 = not_club:getChildByName("txt_self_2")
        local btn_club = not_club:getChildByName("btn_club")
        local btn_inviteClub = not_club:getChildByName("btn_inviteClub")
        btn_inviteClub:setVisible(false)
        btn_club:addTouchEventListener(handler(self, self.touchEvent))
        local txt_friend = not_club:getChildByName("txt_friend")
        txt_self:setVisible(self.isSelf)
        txt_self_2:setVisible(self.isSelf)
        btn_club:setVisible(self.isSelf)
        txt_friend:setVisible(not self.isSelf)
        if bole:getClubManage():isClubLeader() then
            btn_inviteClub:setVisible(true)
            btn_club:setVisible(false)
            btn_inviteClub:addTouchEventListener(handler(self, self.touchEvent))
        end
    end
end

function InformationView:initMoney(root)
    self.node_money=root:getChildByName("node_money")
    self.txt_zan = root:getChildByName("txt_zan")
    self.txt_money = self.node_money:getChildByName("txt_money")
    self.txt_diamond = root:getChildByName("txt_diamond")
    self.txt_zan:setString(self.data.likes)
    self.txt_money:setString(self.data.coins)
    self.txt_diamond:setString(self.data.diamond)
    self.sp_money = self.node_money:getChildByName("sp_money")
end

function InformationView:initDaily(root)
    root:setVisible(self.isSelf)
    self.dailyView = bole:getUIManage():createNewUI("MissionsLayer","player_profile","app.views")
    root:addChild(self.dailyView)
    if self.data.daily_task ~= nil then
        bole:postEvent("initMissionsLayer", self.data.daily_task)
    end
    self.dailyView:setPosition(0, 0)
end

function InformationView:initOther(root)
    root:setVisible(not self.isSelf)
    if self.isSelf then
        return
    end
    local btn_remove = root:getChildByName("btn_remove")
    btn_remove:addTouchEventListener(handler(self, self.touchEvent))
    btn_remove:setVisible(false)

    local btn_connect = root:getChildByName("btn_connect")
    btn_connect:addTouchEventListener(handler(self, self.touchEvent))
    btn_connect:setVisible(false)

    local btn_together = root:getChildByName("btn_together")
    btn_together:addTouchEventListener(handler(self, self.touchEvent))

    local btn_like = root:getChildByName("btn_like")
    btn_like:addTouchEventListener(handler(self, self.touchEvent))
    btn_like:setVisible(false)

    local btn_gift = root:getChildByName("btn_gift")
    btn_gift:addTouchEventListener(handler(self, self.touchEvent))
    btn_gift:setVisible(false)

    if not self.data.room_id or not self.data.theme_id then
        btn_together:setTouchEnabled(false)
    end
    if self.data.room_id == 0 and self.data.theme_id == 0 then
        btn_together:setTouchEnabled(false)
    end
    local img_tips = root:getChildByName("img_tips")
    local txt_off = img_tips:getChildByName("txt_off")
    local txt_lobby = img_tips:getChildByName("txt_lobby")
    local img_icon = img_tips:getChildByName("img_icon")
    local txt_slot = img_tips:getChildByName("txt_slot")
    txt_off:setVisible(false)
    txt_lobby:setVisible(false)
    img_icon:setVisible(false)
    txt_slot:setVisible(false)
    if self.data.room_id and self.data.theme_id and self.data.room_id ~= 0 and self.data.theme_id ~= 0 then
        img_icon:setVisible(true)
        local num = string.format("%02d", self.data.theme_id)
        img_icon:loadTexture("theme_icon/theme_" .. num .. ".png")
        txt_slot:setVisible(true)
    elseif self.data.online and self.data.online == 1 then
        txt_lobby:setVisible(true)
    else
        txt_off:setVisible(true)
    end

    local isFriend = bole:getFriendManage():isFriend(self.data.user_id)
    if self.pos==self.headNode.POS_FRIEND then
        btn_remove:setVisible(true)
        btn_connect:setVisible(false)
    elseif self.pos==self.headNode.POS_SPIN_FRIEND then
        btn_remove:setVisible(isFriend)
        btn_connect:setVisible(not isFriend)
        btn_like:setVisible(true)
        btn_gift:setVisible(true)
        img_tips:setVisible(false)
    elseif self.pos==self.headNode.POS_CLUB_MEMBER then
        btn_remove:setVisible(isFriend)
        btn_connect:setVisible(not isFriend)
    else
        btn_connect:setVisible(false)
    end
end

function InformationView:closeUI()
    if self.dailyView ~= nil then
        if self.dailyView.exit then
            self.dailyView:exit()
        end
    end
    self.dailyView=nil
    InformationView.super.closeUI(self)
end
function InformationView:touchEvent(sender, eventType)
    local name = sender:getName()
    local tag = sender:getTag()
    print("touchEvent:" .. name)
    if eventType == ccui.TouchEventType.began then
        print("Touch Down")
        if name ~= "info" then
            sender:setScale(1.05)
        end
    elseif eventType == ccui.TouchEventType.moved then
        print("Touch Move")
    elseif eventType == ccui.TouchEventType.ended then
        print("Touch Up")
        sender:setScale(1)
        if name == "btn_close" then
            self:closeUI()
        elseif name == "btn_club" then
            bole:getUIManage():openNewUI("ClubJoinLayer",true,"club","app.views.club")
        elseif name == "img_editbg" then
            bole:getUIManage():openEditView(self.data)
        elseif name == "info" then
            bole:getUIManage():openEditView(self.data)
        elseif name == "title" then
            bole:getUIManage():openTitleView()
        elseif name == "btn_remove" then
            bole:popMsg( { msg = "remove friend", title = "remove", cancle = true }, function() bole.socket:send("remove_friend", { target_id = self.data.user_id }, true) end)
        elseif name == "btn_together" then
            bole:getAppManage():sendPlayTogether(self.data.user_id, self.data.room_id, self.data.theme_id)
        elseif name == "node_vip" then
            bole:getUIManage():openUI("VipLayer", true, "vip")
        elseif name == "btn_connect" then
            bole.socket:send("apply_for_friend", { target_id = self.data.user_id }, true)
        elseif name == "btn_inviteClub" then
            self:inviteClub()
        elseif name == "sp_icon" then
            if not self.headNode.cannotOpenClubInfo then
                bole:getUIManage():openClubInfoLayer(self.data.club_info.id)
            end
        elseif name == "btn_like" then
            bole.socket:send("like",{target_id = self.data.user_id, like_type = 1},true) 
            bole:postEvent("showLikeAct",self.data.user_id)
            self:closeUI()
        elseif name == "btn_gift" then
            bole:postEvent("openGiftLayer")
            self:closeUI()
        end
    elseif eventType == ccui.TouchEventType.canceled then
        print("Touch Cancelled")
        sender:setScale(1)
    end
end

function InformationView:reRemove_friend(t, data)
    if t == "remove_friend" then
        if data.error ~= nil then
            if data.error == 2 then
                --bole:popMsg( { msg = "the player isn't your friend", title = "remove", cancle = false })
                self:removeFriend()
            else
                bole:popMsg( { msg = "error: " .. data.error, title = "remove", cancle = false })
            end
            return
        end
        if data.success == 1 then
            self:removeFriend()
        end
    end
end

function InformationView:removeFriend()
    bole:postEvent("closeSlotFuncUI")
    bole:getFriendManage():removeFriend(tonumber(self.data.user_id))
    self:closeUI()
    --local other = self:getCsbNode():getChildByName("root"):getChildByName("other")
    --other:getChildByName("btn_remove"):setVisible(false)
    --other:getChildByName("btn_connect"):setVisible(true)
end

function InformationView:reApplyFriend(t, data)
    if data.error ~= nil then
        if data.error == 1 then
            -- 没这个玩家
            bole:popMsg( { msg = "Couldnit find a player with the provided ID.", title = "connect", cancle = false })
        elseif data.error == 2 then
            -- 没这个玩家
            bole:popMsg( { msg = "Couldnit find a player with the provided ID.", title = "connect", cancle = false })
        elseif data.error == 3 then
            -- 已是好友
            bole:popMsg( { msg = "the player is your friend.", title = "connect", cancle = false })
        elseif data.error == 4 then
            -- 好友满了
            bole:popMsg( { msg = "Player list is full", title = "connect", cancle = false })
        elseif data.error == 5 then
            -- 对方把你加了黑名单
            bole:popMsg( { msg = "You can't add this player.", title = "connect", cancle = false })
        else
            bole:popMsg( { msg = "error: " .. data.error, title = "connect", cancle = false })
        end
        return
    end
    if data.success == 1 then
        bole:getFriendManage():addFriend(data.new_friend)
        bole:popMsg( { msg = "connect successfully", title = "connect", cancle = false }, function() self:closeUI() end)
        local other = self:getCsbNode():getChildByName("root"):getChildByName("other")
        other:getChildByName("btn_remove"):setVisible(true)
        other:getChildByName("btn_connect"):setVisible(false)
    end
end

function InformationView:reInvitationClub(t, data)
    if data.error ~= nil then
        if data.error == 4 then
            -- 玩家已经拥有工会
            bole:popMsg( { msg = "This player is not available now.", title = "invite", cancle = false }, function() self:updateClubInfo() end)
        elseif data.error == 5 then
            -- 公会已满
            bole:popMsg( { msg = "Sorry,your club is full.", title = "invite", cancle = false })
        elseif data.error == 3 then
            -- 重复邀请
            bole:popMsg( { msg = "Invite has been sent before.", title = "invite", cancle = false })
        else
            bole:popMsg( { msg = "error: " .. data.error, title = "invite", cancle = false })
        end
        return
    end

    if data.success == 1 then
        bole:popMsg( { msg = "invite successfully", title = "invite", cancle = false }, function()
            if data.in_club == 1 then
                self:updateClubInfo()
            end
        end )
        bole:getClubManage():addInvitePlayer(self.data.user_id)
    end
end

function InformationView:inviteClub()
    if bole:getClubManage():isInviteLimit() then
        bole:popMsg({msg ="Sorry,you have reached invitation limit." , title = "invite" , cancle = false }) 
    else
        bole.socket:send("send_club_invitation",{target_uid = self.data.user_id},true)
    end
end

function InformationView:updateClubInfo()
    self.onlyUpdateClubInfo_ = true
    bole.socket:send(bole.SYNC_HEAD_INFO, { user_id = self.data.user_id })
end

return InformationView


-- endregion
