--region *.lua
--Date
--此文件由[BabeLua]插件自动生成
local InformationView = class("InformationView", cc.load("mvc").ViewBase)
function InformationView:onCreate()
    print("InformationView-onCreate")
    local root = self:getCsbNode():getChildByName("root")
    root:setVisible(false)
    root:setScale(0.01)
    self.data=nil
    self.isSelf=false
end
function InformationView:onEnter()
    bole:addListener("titleChanged", self.eventTitle, self, nil, true)
    bole:addListener("changeInfo", self.changeInfo, self, nil, true)
    bole.socket:registerCmd("remove_friend", self.reRemove_friend, self)
    bole.socket:registerCmd(bole.SYNC_USER_INFO, self.syncUserInfo, self)
end
--    self.info = { }
--    self.info[1] = data.icon
--    self.info[2] = data.signature .. ""
--    self.info[3] = data.name .. ""
--    self.info[4] = data.age
--    self.info[5] = data.gender
--    self.info[6] = data.marital_status
--    self.info[7] = data.country
--    self.info[8] = data.city .. ""
function InformationView:onExit()
    bole:getEventCenter():removeEventWithTarget("changeInfo", self)
    bole:getEventCenter():removeEventWithTarget("titleChanged", self)
    if self.dailyView ~= nil then
        self.dailyView:exit()
    end
    bole.socket:unregisterCmd(bole.SYNC_USER_INFO)
end


function InformationView:syncUserInfo(t,data)
    if t==bole.SYNC_USER_INFO then
        dump(data,"syncUserInfo")
        self:initSyncUserInfo(data)
    end
end
function InformationView:changeInfo(event)
    for k,v in pairs(bole:getUserData()) do
        self.data[k]=v
    end
    self:updateInfo()
end
function InformationView:eventTitle(event)
    local index=bole:getUserDataByKey("title", event.result)
    local name = bole:getConfig("title", index, "title_name")
    if not name then
        self.txt_title:setString("TITLE:无")
    else
        self.txt_title:setString("TITLE:"..name)
    end
end

function InformationView:showInfo(node)
    if not node then
        self:closeUI()
        return
    end
    self.data=node:getInfo()
    print(" InformationView:showInfo userid:"..self.data.user_id)
    bole.socket:send(bole.SYNC_USER_INFO,{user_id=self.data.user_id})
    self.isSelf=node.isSelf
    
end
function InformationView:initSyncUserInfo(data)
    self.data=data
    local root = self:getCsbNode():getChildByName("root")
    root:setVisible(true)
    root:runAction(cc.ScaleTo:create(0.2,1.0))

    local img_bg=root:getChildByName("img_bg")
    self.info=root:getChildByName("info")
    local money=root:getChildByName("money")
    local daily=root:getChildByName("daily")
    local other=root:getChildByName("other")


    local btn_close=root:getChildByName("btn_close")
    btn_close:addTouchEventListener(handler(self, self.touchEvent))

    self:initInfo()
    self:initMoney(money)
    self:initDaily(daily)
    self:initOther(other)
    self:initClub(self.info)
end
function InformationView:initInfo()
    local node_head=self.info:getChildByName("node_head")
    local nHead=bole:getNewHeadView(self.data)
    if self.isSelf then
        nHead:updatePos(nHead.POS_INFO_SELF)
    else
        nHead:updatePos(nHead.POS_INFO_FRIEND)
    end
    node_head:addChild(nHead)
    self:updateInfo()
end
function InformationView:updateInfo()
    self.txt_name=self.info:getChildByName("txt_name")
    self.txt_name:setString(self.data.name)

    local txt_id=self.info:getChildByName("txt_id")
    txt_id:setString("ID:"..self.data.user_id)
    txt_id:setVisible(self.isSelf)
    local txt_age=self.info:getChildByName("txt_age")
    txt_age:setString(self.data.age)
    local txt_city=self.info:getChildByName("txt_city")
    txt_city:setString(self.data.city)
    local txt_status=self.info:getChildByName("txt_status")
    local txts = { "single", "on-relationship", "married", "secret", "secret" }
    if self.data.marital_status then
        txt_status:setString(txts[self.data.marital_status+1])
    end
    local img_sex=self.info:getChildByName("img_sex")
    local sexs = { "information/female-nv.png","information/female-nan.png", "information/info_refresh.png","information/info_refresh.png"}
    if self.data.gender then
        img_sex:setTexture(sexs[self.data.gender+1])
    end

    local title=self.info:getChildByName("title")
    title:addTouchEventListener(handler(self, self.touchEvent))
    title:setTouchEnabled(self.isSelf)

    local img_editbg=self.info:getChildByName("img_editbg")
    img_editbg:addTouchEventListener(handler(self, self.touchEvent))
    img_editbg:setTouchEnabled(self.isSelf)

    self.txt_title=title:getChildByName("txt_title")
    local name=bole:getConfig("title",self.data.title,"title_name")
    if not name then
        self.txt_title:setString("TITLE:无")
    else
        self.txt_title:setString("TITLE:"..name)
    end
    self.txt_edit=self.info:getChildByName("txt_edit")
    self.txt_edit:setString(self.data.signature)
end
function InformationView:initClub(root)
    local club = root:getChildByName("club")
    local not_club = root:getChildByName("not_club")

    if self.data.club_info then
        club:setVisible(true)
        not_club:setVisible(false)
        local sp_icon = club:getChildByName("sp_icon")
        local txt_league = club:getChildByName("txt_league")
        local txt_name = club:getChildByName("txt_name")
        local txt_member = club:getChildByName("txt_member")
        txt_name:setString(self.data.club_info.name)
        local str_index = string.format("%02d",self.data.club_info.league_level)
        local league = bole:getConfig("league", str_index)
        txt_league:setString(league.rank_name)
        local titles ={"leader","co_leader","member"}
        txt_member:setString(titles[self.data.club_info.club_title])
        
        local icon_path = bole:getClubIconStr(self.data.club_info.icon)
        if icon_path ~= nil then
            sp_icon:setTexture(icon_path)
        else
            sp_icon:setTexture(bole:getClubIconStr("10" ..(self.data.club_info.icon % 5 + 1)))
        end
    else
        club:setVisible(false)
        not_club:setVisible(true)

        local txt_self = not_club:getChildByName("txt_self")
        local btn_club = not_club:getChildByName("btn_club")
        btn_club:addTouchEventListener(handler(self, self.touchEvent))
        local txt_friend = not_club:getChildByName("txt_friend")
        txt_self:setVisible(self.isSelf)
        btn_club:setVisible(self.isSelf)
        txt_friend:setVisible(not self.isSelf)
    end
end

function InformationView:initMoney(root)
    local txt_zan=root:getChildByName("txt_zan")
    local txt_money=root:getChildByName("txt_money")
    txt_money:setString(self.data.coins)
    local txt_diamond=root:getChildByName("txt_diamond")
end

function InformationView:initDaily(root)
    root:setVisible(self.isSelf)
    self.dailyView = bole:getUIManage():getSimpleLayer("MissionsLayer")
    root:getChildByName("scroll_daily"):addChild(self.dailyView)
    if self.data.daily_task ~= nil then
        bole:postEvent("initMissionsLayer",self.data.daily_task)
    end
    self.dailyView:setPosition(0,0)
end

function InformationView:initOther(root)
    root:setVisible(not self.isSelf)
    local btn_remove=root:getChildByName("btn_remove")
    btn_remove:addTouchEventListener(handler(self, self.touchEvent))
    btn_remove:setVisible(false)
    local btn_together=root:getChildByName("btn_together")
    btn_together:addTouchEventListener(handler(self, self.touchEvent))
    btn_together:setPosition(550,26)

    local friendList = bole:getUserDataByKey("user_friends")
    for k ,v in pairs(friendList) do
        if v == self.data.user_id then
            btn_remove:setVisible(true)
            btn_together:setPosition(829,26)
            break
        end
    end
    if not self.data.room_id or not self.data.theme_id then
        --btn_together:setBright(false)
        btn_together:setTouchEnabled(false)
        --btn_together:setVisible(false)
        --btn_remove:setPosition(550,26)
    end
    if self.data.room_id==0 and self.data.theme_id==0 then
        --btn_together:setBright(false)
        btn_together:setTouchEnabled(false)
        --btn_together:setVisible(false)
        --btn_remove:setPosition(550,26)
    end
end

function InformationView:touchEvent(sender, eventType)
    local name = sender:getName()
    local tag = sender:getTag()
    print("touchEvent:" .. name)
    if eventType == ccui.TouchEventType.began then
        print("Touch Down")
        sender:setScale(1.05)
    elseif eventType == ccui.TouchEventType.moved then
        print("Touch Move")
    elseif eventType == ccui.TouchEventType.ended then
        print("Touch Up")
        sender:setScale(1)
        if name=="btn_close"then
            self.dailyView:exit()
            self:closeUI()
        elseif name == "btn_club" then
            bole:getUIManage():openUI("ClubJoinLayer", true, "csb/club")
            bole.socket:send("enter_club_lobby", { }, true)
        elseif name=="img_editbg" then
            bole:getUIManage():openEditView(self.data)
        elseif name=="title" then
            bole:getUIManage():openTitleView()
        elseif name=="btn_remove" then
            print("remove")
            bole.socket:send("remove_friend",{target_id = tonumber(self.data.user_id)},true) 
        elseif name=="btn_together" then
            bole.socket:send(bole.SERVER_PLAY_TOGETHER,{room_id=self.data.room_id,theme_id=self.data.theme_id})
        end
    elseif eventType == ccui.TouchEventType.canceled then
        print("Touch Cancelled")
        sender:setScale(1)
    end
end

function InformationView:reRemove_friend(t, data)
    if t == "remove_friend" then
        if data.success ~= nil then
            if data.success == 1 then
                self:removeFriend(data)
            end
        end
    end
end

function InformationView:removeFriend(t, data)
    bole:postEvent("removeFriend", tonumber(self.data.user_id))
    local userFriendList = bole:getUserDataByKey("user_friends")
    for i = 1, #userFriendList do
        if userFriendList[i] == tonumber(self.data.user_id) then
            table.remove(userFriendList, i)
        end
    end
    dump(userFriendList, "userFriendList")
    bole:setUserDataByKey("user_friends", userFriendList)
    bole:postEvent("closeSlotFuncUI", data)
    self:closeUI()
end

return InformationView


--endregion
