--region *.lua
--Date
--此文件由[BabeLua]插件自动生成
local NoticeType = 
{
    head_content_button = 1,
    head_content = 2,
    content_button = 3
}
local NoticeCenter = class("NoticeCenter")
function NoticeCenter:ctor()
    self:init()
    self:addListeners()
end

function NoticeCenter:init()
    self.isOpenNotice = false
    self.noticeList = {}
end

function NoticeCenter:open(event)
    self.isOpenNotice = true
end

function NoticeCenter:close(event)
    self.isOpenNotice = false
end

function NoticeCenter:pushOneNotice(info)
    table.insert(self.noticeList, info)
    self:popOneNotice()
end

function NoticeCenter:popOneNotice()
    if not self.isOpenNotice then return end
    if self.isShowingPopupNotice then return end
    if #self.noticeList == 0 then return end

    local item = table.remove(self.noticeList, 1)
    self:showPop(item)
end

function NoticeCenter:displayPopView(item)
    local views = self.views
    local headNode = views.head
    local contentLabel = views.content
    local gotoBtn = views.gotoBtn

    headNode:removeAllChildren(true)
    if item.userId then
        local node = bole:getNewHeadView({user_id = item.userId,icon=item.icon, user_name = item.userName or ""})
        node:updatePos(node.POS_NOTICE)
        headNode:addChild(node)
    end

    contentLabel:setString(item.content)

    gotoBtn:setVisible(item.clickFunc ~= nil)
    if item.clickFunc then
        local function onClick(event)
            if event.name == "ended" then
--                self:close()
                item.clickFunc()
            end
        end
        gotoBtn:onTouch(onClick)
    end
end

function NoticeCenter:showPop(item)
    if not self.showingPopupView then
        self:createPopView()
    end

    self.isShowingPopupNotice = true
    self.showingPopupViewAction:play("moveIn", false)
    self:displayPopView(item)
    local delayAct = cc.DelayTime:create(2)
    local callFunAct = cc.CallFunc:create(function()
        self.showingPopupViewAction:play("moveOut", false)

        local delayAct1 = cc.DelayTime:create(1)
        local callFunAct1 = cc.CallFunc:create(function()
            self.isShowingPopupNotice = false
            self:popOneNotice()
        end)
        self.showingPopupView:runAction(cc.Sequence:create(delayAct1, callFunAct1))
    end)
    self.showingPopupView:runAction(cc.Sequence:create(delayAct, callFunAct))
end

function NoticeCenter:createPopView()
    local rootNode = cc.CSLoader:createNode("csb/NoticePopupNode.csb")
    local actionTimeLine = cc.CSLoader:createTimeline("csb/NoticePopupNode.csb")
    rootNode:runAction(actionTimeLine)
    self.showingPopupView = rootNode
    self.showingPopupViewAction = actionTimeLine

    rootNode:setPosition(display.top_center.x, display.top_center.y)
    rootNode:registerScriptHandler(function(state)
        if state == "enter" then
            self:onEnter()
        elseif state == "exit" then
            self:onExit()
        end
    end)

    local scene = cc.Director:getInstance():getRunningScene()
    scene:addChild(rootNode, bole.ZORDER_TOP)

    local node = rootNode:getChildByName("clip"):getChildByName("icon")
    local head = node:getChildByName("head")
    local content = node:getChildByName("content")
    local gotoBtn = node:getChildByName("gotoBtn")
    local views = {head = head, content = content, gotoBtn = gotoBtn}
    self.views = views
end

function NoticeCenter:onEnter()
    self.isShowingPopupNotice = true
end

function NoticeCenter:onExit()
    self.isShowingPopupNotice = false

    self.showingPopupView = nil
    self.showingPopupViewAction = nil
end

function NoticeCenter:onResponse(t, data)
    local content
    local noticeType
    local userId
    local userName
    local clickFunc
    -- 点击跳转
    if "receive_club_application" == t then
        -- 收到别人的公会申请{'user_id':0, 'name':""}
        -- 信息显示在request界面，保留一星期.
        noticeType = NoticeType.head_content_button
        content = "You have received applications from other guilds."
        userId = data.user_id
        userName = data.name
        bole:postEvent("receive_club_application_toManage", data)
        clickFunc = function()
            -- 跳转到俱乐部的request页面（如果玩家当前在房间中，点击弹框要求玩家确认是否离开当前房间）
            bole:getUIManage():jumpToClubView("club_request")
        end
    elseif "club_application_result" == t then
        -- 收到leader的公会申请处理结果 {}
        bole:getClubManage():joinClub()
        content = "Your club application is agreed."
    elseif "receive_club_invitation" == t then
        -- 收到leader的公会邀请 {}
        -- 信息显示在join club界面，保留一个月
        noticeType = NoticeType.content_button
        bole:postEvent("refreshClubJoinLayer")
        content = "There is a club that wants to invite you to join the club"
        clickFunc = function()
            -- 玩家点击后弹出该俱乐部详细信息界面（如果玩家当前在房间中，点击弹框要求玩家确认是否离开当前房间）
            bole:getUIManage():openClubInfoLayer(data.id)
        end
    elseif "club_invitation_result" == t then
        -- 玩家同意leader的公会邀请 {}
        content = "a player agree your invitation"
    elseif "receive_accreditation" == t then
        -- 收到被委派为公会联合首领消息 {}
        noticeType = NoticeType.content_button
        content = "You have been appointed as a joint leader"
        clickFunc = function()
            -- 玩家点击后跳转到俱乐部的members界面（如果玩家当前在房间中，点击弹框要求玩家确认是否离开当前房间）.
            bole:getUIManage():jumpToClubView("club_member")
        end
    elseif "receive_demotion" == t then
        -- 收到公会降职的消息 {}
        noticeType = NoticeType.content_button
        content = "You were demoted by the guild leader"
        clickFunc = function()
            -- 玩家点击后跳转到俱乐部的members界面（如果玩家当前在房间中，点击弹框要求玩家确认是否离开当前房间）.
            bole:getUIManage():jumpToClubView("club_member")
        end
    elseif "receive_kicked_out_from_club" == t then
        -- 收到被公会踢出的消息 {}
        noticeType = NoticeType.content_button
        content = "You were removed from the guild by the guild leader"
        bole:getClubManage():leaveClub()
        bole:postEvent("club_kickOuted")
        clickFunc = function()
            -- 玩家点击后跳转到俱乐部的join club界面（如果玩家当前在房间中，点击弹框要求玩家确认是否离开当前房间）.
            bole:getUIManage():jumpToClubView("club_wall")
        end
    elseif "receive_club_event_msg" == t then
        -- 收到公会任务奖励可领的消息 {}
        noticeType = NoticeType.content_button
        content = "You have completed the club's quest to receive a reward"
        bole:postEvent("addClubTaskCellToChat")
        clickFunc = function()
            -- 玩家点击后转到俱乐部的club wal界面（如果玩家当前在房间中，点击弹框要求玩家确认是否离开当前房间）.
            bole:getUIManage():jumpToClubView("club_wall")
        end
    elseif "receive_f_application" == t then
        -- 收到好友请求 {'user_id':0, 'name':""}
        if not bole:getFriendManage():isFriend(data.user_id) then
            noticeType = NoticeType.head_content_button
            content = "Want to add you as a friend"
            userId = data.user_id
            userName = data.name
            bole:postEvent("receive_f_application_toManage", data)
        else
            content = "Rejected your friend request"
            userId = data.user_id
            userName = data.name
        end
        clickFunc = function()
            -- 玩家点击后弹出好友系统的request界面
            bole:getUIManage():jumpToFriendView("friend_request")
        end
    elseif "receive_f_application_result" == t then
        -- 好友请求的处理结果 {'sender_name': 发送人的名字，'sender': 发送人ID， 'result': 处理结果 0拒绝   1接受}
        noticeType = NoticeType.head_content_button
        if data.result == 0 then
            bole:getFriendManage():removeTofriendIdList(data.user_id)
            content = "accepted your friend request"
        else
            bole:getFriendManage():addTofriendIdList(data.user_id)
            content = "Rejected your friend request"
            -- userId = data.sender
            -- userName = data.sender_name
            clickFunc = function()
                -- 玩家点击后弹出好友系统的request界面
                bole:getUIManage():jumpToFriendView("friend")
            end
        end
    elseif "receive_club_league_reward" == t then
        -- 收到联赛奖励可领的消息 {}
        noticeType = NoticeType.content_button
        content = "You have a league reward can receive"
        clickFunc = function()
            -- 玩家点击后跳转到League界面（如果玩家当前在房间中，点击弹框要求玩家确认是否离开当前房间）.
            bole:getUIManage():jumpToLeagueView("league")
        end
    elseif "receive_friend_login" == t then
        -- 收到好友登陆消息 {'user_id':0, 'name':""}
        -- 只在线玩家提示，服务器下发玩家头像和名字；如果玩家当前在老虎机内，提示可点击，显示玩家头像，名字，固定文本和按钮，；
        -- 如果玩家当前不在老虎机内，提示不可点击，显示玩家头像，名字和固定文本，信息不保留
        if bole:getSpinApp():isThemeAlive() then
            noticeType = NoticeType.head_content_button
            clickFunc = function()
                -- 点击后向好友发送邀请加入此房间
                bole.socket:send(bole.SEND_ROOM_INVITATION, { target_uid = { data.user_id } })
            end
        else
            noticeType = NoticeType.head_content
        end
        content = "Your friend has logged in the game"
        userId = data.user_id
        userName = data.name
    elseif "complete_task" == t then
        -- 完成日常任务 {'t_ids':[]} 完成任务的任务ID
        noticeType = NoticeType.content_button
        content = "Complete the task reward"
        clickFunc = function()
            -- 玩家点击后弹出个人资料界面，信息在个人资料界面中保留一天
        end
    elseif "title_change" == t then
        -- 完成头衔任务 {'title':, 'coins':, 'win_total':}
        -- 其中，title是现在玩家可用的最大title的ID， coins 是玩家当前coins， win_total 是玩家赢得的coins数量
        noticeType = NoticeType.content_button
        content = "Complete the task reward"
        clickFunc = function()
            -- 玩家点击后弹出个人资料界面
        end
    elseif "receive_club_gift_msg" == t then
        content = "Player buy a club offer"
        bole:postEvent("chat_clubBuy", data)
    elseif bole.RECV_ROOM_INVITATION == t then
        -- 收到好友请求 {'user_id':0, 'name':""}
        noticeType = NoticeType.head_content_button
        content = data.inviter_name.." invites you to play together"
        userId = data.inviter
        userName = data.inviter_name
        clickFunc = function()
            bole:getAppManage():sendAcceptIntive(data.inviter,data.room_id,data.theme_id)
        end
    end

    local item = { type = noticeType, content = content, clickFunc = clickFunc, userId = userId, userName = userName }
    self:pushOneNotice(item)
end

function NoticeCenter:addListeners()
    local listenerNames = {
        "receive_club_application",
        "club_application_result",
        "receive_club_invitation",
        "club_invitation_result",
        "receive_accreditation",
        "receive_demotion",
        "receive_kicked_out_from_club",
        "receive_club_event_msg",
        "receive_f_application",
        "receive_f_application_result",
        "receive_club_league_reward",
        "receive_friend_login",
        "complete_task",
        "title_change",
        "receive_club_gift_msg",
    }

    for _, name in ipairs(listenerNames) do
        bole.socket:registerCmd(name, self.onResponse, self)
    end

    bole:addListener("openNotice", self.open, self, nil, true)
    bole:addListener("closeNotice", self.close, self, nil, true)
end

return NoticeCenter
--endregion
