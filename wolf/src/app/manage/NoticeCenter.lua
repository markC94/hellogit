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
        local node = bole:getNewHeadView({user_id = item.userId, user_name = item.userName or ""})
        node:updatePos(head.POS_NOTICE)
        headNode:addChild(node)
    end

    contentLabel:setString(item.content)

    gotoBtn:setVisible(item.clickFunc ~= nil)
    if item.clickFunc then
        local function onClick(event)
            if event.name == "ended" then
                self:close()
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
    local head = node:removeChildByName("head")
    local content = node:removeChildByName("content")
    local gotoBtn = node:removeChildByName("gotoBtn")
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
    local clickFunc  --点击跳转
    if "receive_club_application" == t then  --收到别人的公会申请{'user_id':0, 'name':""}
        --信息显示在request界面，保留一星期.
        noticeType = NoticeType.head_content_button
        content = "你收到了其他玩家的公会申请。"
        userId = data.user_id
        userName = data.name
        clickFunc = function()  --跳转到俱乐部的request页面（如果玩家当前在房间中，点击弹框要求玩家确认是否离开当前房间）
        end
    elseif "club_application_result" == t then  --收到leader的公会申请处理结果 {}
        
    elseif "receive_club_invitation" == t then  --收到leader的公会邀请 {}
        --信息显示在join club界面，保留一个月
        noticeType = NoticeType.content_button
        content = "有一家俱乐部想邀请你加入俱乐部"
        clickFunc = function()  --玩家点击后弹出该俱乐部详细信息界面（如果玩家当前在房间中，点击弹框要求玩家确认是否离开当前房间）
        end
    elseif "club_invitation_result" == t then  --玩家同意leader的公会邀请 {}
        
    elseif "receive_accreditation" == t then  --收到被委派为公会联合首领消息 {}
        noticeType = NoticeType.content_button
        content = "你已经被委派为联合首领了"
        clickFunc = function()  --玩家点击后跳转到俱乐部的members界面（如果玩家当前在房间中，点击弹框要求玩家确认是否离开当前房间）.
        end
    elseif "receive_demotion" == t then  --收到公会降职的消息 {}
        noticeType = NoticeType.content_button
        content = "你被公会首领降职了"
        clickFunc = function()  --玩家点击后跳转到俱乐部的members界面（如果玩家当前在房间中，点击弹框要求玩家确认是否离开当前房间）.
        end
    elseif "receive_kicked_out_from_club" == t then  --收到被公会踢出的消息 {}
        noticeType = NoticeType.content_button
        content = "你被公会首领移除了公会"
        clickFunc = function()  --玩家点击后跳转到俱乐部的join club界面（如果玩家当前在房间中，点击弹框要求玩家确认是否离开当前房间）.
        end
    elseif "receive_club_event_msg" == t then  --收到公会任务奖励可领的消息 {}
        noticeType = NoticeType.content_button
        content = "你完成了俱乐部的任务，可领取奖励"
        clickFunc = function()  --玩家点击后转到俱乐部的club wal界面（如果玩家当前在房间中，点击弹框要求玩家确认是否离开当前房间）.
        end
    elseif "receive_f_application" == t then  --收到好友请求 {'user_id':0, 'name':""}
        noticeType = NoticeType.head_content_button
        content = "想加你为好友"
        userId = data.user_id
        userName = data.name
        clickFunc = function()  --玩家点击后弹出好友系统的request界面
        end
    elseif "receive_f_application_result" == t then
        --好友请求的处理结果 {'sender_name': 发送人的名字，'sender': 发送人ID， 'result': 处理结果 0拒绝   1接受}
        noticeType = NoticeType.head_content_button
        if data.result == 0 then
            content = "同意了你的好友请求"
        else
            content = "拒绝了你的好友请求"
        end
        userId = data.sender
        userName = data.sender_name
        clickFunc = function()  --玩家点击后弹出好友系统的request界面
        end
    elseif "receive_club_league_reward" == t then  --收到联赛奖励可领的消息 {}
        noticeType = NoticeType.content_button
        content = "你有联赛奖励可以领取"
        clickFunc = function()  --玩家点击后跳转到League界面（如果玩家当前在房间中，点击弹框要求玩家确认是否离开当前房间）.
        end
    elseif "receive_friend_login" == t then  --收到好友登陆消息 {'user_id':0, 'name':""}
        --只在线玩家提示，服务器下发玩家头像和名字；如果玩家当前在老虎机内，提示可点击，显示玩家头像，名字，固定文本和按钮，；
        --如果玩家当前不在老虎机内，提示不可点击，显示玩家头像，名字和固定文本，信息不保留
        if bole:getSpinApp():isThemeAlive() then
            noticeType = NoticeType.head_content_button
            clickFunc = function()  --点击后向好友发送邀请加入此房间
                
            end
        else
            noticeType = NoticeType.head_content
        end
        content = "你的好友登录了游戏"
        userId = data.user_id
        userName = data.name
    elseif "complete_task" == t then  --完成日常任务 {'t_ids':[]} 完成任务的任务ID
        noticeType = NoticeType.content_button
        content = "完成任务奖励"
        clickFunc = function()  --玩家点击后弹出个人资料界面，信息在个人资料界面中保留一天
        end
    elseif "title_change" == t then
        --完成头衔任务 {'title':, 'coins':, 'win_total':} 
        --其中，title是现在玩家可用的最大title的ID， coins 是玩家当前coins， win_total 是玩家赢得的coins数量
        noticeType = NoticeType.content_button
        content = "完成任务奖励"
        clickFunc = function()  --玩家点击后弹出个人资料界面
        end
    end

    local item = {type = noticeType, content = content, clickFunc = clickFunc, userId = userId, userName = userName}
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
        "title_change"
    }

    for _, name in ipairs(listenerNames) do
        bole.socket:registerCmd(name, self.onResponse, self)
    end

    bole:addListener("openNotice", self.open, self, nil, true)
    bole:addListener("closeNotice", self.close, self, nil, true)
end

return NoticeCenter
--endregion
