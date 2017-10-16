--region *.lua
--Date
--此文件由[BabeLua]插件自动生成

local ClubManage = class("ClubManage")
local InviteMaxNum = 20
local RequestMaxNum = 10

function ClubManage:initListener()
    self:initInfo()
    bole.socket:registerCmd("enter_club_lobby", self.reClub, self)
    bole:addListener("receive_club_application_toManage", self.reApplication, self, nil, true)
    bole:addListener("getClubInfo", self.getClubInfo, self, nil, true)
end

function ClubManage:removeListener()
    bole.socket:unregisterCmd("enter_club_lobby")
    bole:getEventCenter():removeEventWithTarget("receive_club_application_toManage", self)
    bole:getEventCenter():removeEventWithTarget("refreshClubInfo", self)
end

function ClubManage:cleanLocalData()
    self.refreshLayer_ = nil
    self.club_ = nil
    self.usersInfo_ = nil
    self.selfInfo_ = nil
    self.isInClub_ = nil
    self.club_title_ = nil
    self.inviteList_ = nil
    self.requestList_ = nil
    self.isShowCreateClubBtn_ = nil
    self.showRem_ = nil
    self.clubId_ = nil
    self.clubIcon_ = nil
    self.clubLimitLevel_ = nil
    self.clubSettingTabel_ = nil
    self:removeListener()
end


function ClubManage:initInfo()
    self.refreshLayer_ = nil
    self.club_ = nil
    self.usersInfo_ = nil
    self.selfInfo_ = nil
    self.isInClub_ = false
    self.club_title_ = 0
    self.inviteList_ = {}
    self.requestList_ = {}
    self.isShowCreateClubBtn_ = false
    self.showRem_ = false
    self.clubId_ = 0
    self:initConfigTable()
    self.clubSettingTabel_ = bole:getConfigCenter():getConfig("clubset")
end

function ClubManage:initConfigTable()
    self.clubIcon_ = {}
    for k , v in pairs(bole:getConfigCenter():getConfig("clubicon")) do
        table.insert(self.clubIcon_ , tonumber(k))
    end
    table.sort(self.clubIcon_)

    self.clubLimitLevel_ = {}
    for k , v in pairs(bole:getConfigCenter():getConfig("foundclub")) do
        table.insert(self.clubLimitLevel_ , tonumber(k))
    end
    table.sort(self.clubLimitLevel_)
end

function ClubManage:initLocalData()
    if bole:getUserDataByKey("club") ~= 0 then
        self.isInClub_ = true
        self.clubId_ = bole:getUserDataByKey("club")
    end
    if bole:getUserDataByKey("club_title") ~= 0 then
        self.club_title_ = bole:getUserDataByKey("club_title")
    end

    if bole:getUserDataByKey("club_flag") ~= 0 then
        self.isShowCreateClubBtn_ = true
    end

    if bole:getUserDataByKey("club_tips") ~= 0 then
        self.showRem_ = true
    end
end

function ClubManage:reClub(t,data)
    dump(data , self.refreshType_)
    if data.in_club == 0 then
        self.club_ = nil
        self.clubId_ = 0
        self.isInClub_ = false
        bole:setUserDataByKey("club",0)
    else
        self:setClubInfo(data.club_info)
    end

    if self.refreshType_ == "open_r_club" then
        --打开推荐工会页面
        if data.in_club == 0 then
            bole:postEvent("initRecommendClubInfo", data.r_clubs)
        else
            bole:popMsg({msg = "You have joined a club." , title = "error" , cancle = false }, function() bole:postEvent("closeClubJoinLayer") bole:postEvent("updateClub_informationView") end)
        end
    elseif self.refreshType_ == "openClub" then
        --打开公会页面
        if data.in_club == 1 then
            bole:postEvent("initClubInfo", data.club_info)
        else
            bole:popMsg({msg = "You have left the club." , title = "error" , cancle = false }, function() bole:postEvent("openClubLayer") end)
        end
    elseif self.refreshType_ == "refreshClubInfo" then
        --刷新公会信息
        bole:postEvent("refreshClubInfo",data)    
    elseif self.refreshType_ == "getClubInfo_league" then
         --获取公会信息,联赛a界面
        bole:postEvent("getClubInfo_league",data.club_info)        
    elseif self.refreshType_ == "getClubInfo_chat" then
        --获取公会信息,聊天界面
        bole:postEvent("getClubInfo_chat",data)
    elseif self.refreshType_ == "getClubInfo_invite" then
        --获取公会信息,邀请界面
        bole:postEvent("getClubInfo_invite",data)
    end
end

function ClubManage:setClubInfo(data)
    self.club_ = data
    self.clubId_ = self.club_.id
    self.usersInfo_ = self.club_.users
    self.selfInfo_ = self.usersInfo_[1]
    self.club_title_ = self.selfInfo_.club_title
    self.taskInfo_ = self.club_.rewards
    bole:setUserDataByKey("club", data.id)
    self.isInClub_ = true
    if data.league_level then
        bole:setUserDataByKey("league_level",data.league_level)
    end
    if data.league_rank then
        bole:setUserDataByKey("league_rank",data.league_rank)
    end
    bole:postEvent("update_lobby_league")
end

function ClubManage:leaveClub()
    self.club_ = nil
    self.clubId_ = 0
    self.usersInfo_ = nil
    self.club_title_ = 0
    self.taskInfo_ = nil
    bole:setUserDataByKey("club", 0)
    self.isInClub_ = false
end

function ClubManage:getClubInfo(type)
    self.refreshType_ = type
    bole.socket:send("enter_club_lobby", { }, true)
end

function ClubManage:getLocalClubInfo()
    return self.club_
end

function ClubManage:getClubId()
    return self.clubId_
end

function ClubManage:isInClub()
    return self.isInClub_
end

function ClubManage:joinClub()
    self.club_ = nil
    self.isInClub_ = true
    self.club_title_ = 3
    bole:setUserDataByKey("club", 1)
end

function ClubManage:getSelfInfo()
    return self.selfInfo_
end

function ClubManage:isClubLeader()
    return self.club_title_ == 1 
end

function ClubManage:getClubTitle()
    return self.club_title_
end

function ClubManage:getClubUsersInfo()
    return self.usersInfo_
end

function ClubManage:getTaskInfo()
    return self.taskInfo_ 
end


function ClubManage:addUser(data)
    data = data.result
    for i = 1 ,# self.usersInfo_ do
        if self.usersInfo_[i].user_id == data.user_id then
            table.remove(self.usersInfo_, i)
        end
    end
    data.donate = 0
    data.league_point = 0
    data.club_title = 3
    data.online = 1
    table.insert(self.usersInfo_ , data)
end

function ClubManage:removeUser(id)
    for i = 1 ,# self.usersInfo_ do
        if self.usersInfo_[i].user_id == id then
            table.remove(self.usersInfo_, i)
        end
    end
end

function ClubManage:modifyClubInfo(data)
    self.club_.description = data.description or self.club_.description  
    self.club_.icon = data.icon or self.club_.icon 
    self.club_.require_level = data.require_level or self.club_.require_level 
    self.club_.qualification = data.qualification or self.club_.qualification 
end

function ClubManage:saveTaskSchedule(data)

end

function ClubManage:addInvitePlayer(id)
    table.insert(self.inviteList_ , id)
end

function ClubManage:isInvitePlayer(id)
    for k, v in pairs(self.inviteList_) do
        if v == id then
            return true
        end
    end
    return false
end

function ClubManage:isInviteLimit()
    if # self.inviteList_ >= InviteMaxNum then
        return true
    end
    return false
end


function ClubManage:addRequestClub(id)
    table.insert(self.requestList_ , id)
end

function ClubManage:isRequestClub(id)
    for k, v in pairs(self.requestList_) do
        if v == id then
            return true
        end
    end
    return false
end

function ClubManage:isRequestLimit()
    if # self.requestList_ >= RequestMaxNum then
        return true
    end
    return false
end

function ClubManage:isCanCreateClub()
    return self.isShowCreateClubBtn_
end

function ClubManage:isShowRem()
    return self.showRem_
end

function ClubManage:setIsShowRem(bool)
    self.showRem_ = bool 
    bole:postEvent("show_club_reminder_lobbyScene",bool)
    bole:postEvent("show_club_reminder_clubProfileLayer",bool)
end

function ClubManage:reApplication(data)
    data = data.result
    bole:postEvent("add_f_application_clubRequestLayer",data)
    self:setIsShowRem(true)
end

function ClubManage:getClubIconIdTable()
    return self.clubIcon_
end

--club icon id
function ClubManage:getClubIconPath(id)
    id = tonumber(id)
    for k ,v in pairs(self.clubIcon_) do
        if v == id then
            return "clubIcon/" .. id .. ".png"
        end
    end
    return "clubIcon/" .. 1 .. ".png"
end

--club League id
function ClubManage:getLeagueIconPath(lv)
    lv = tonumber(lv)
    return "league_rank/club_lvl_0" .. math.min(lv,6) .. ".png"
end

--club League id
function ClubManage:getLeagueBgPath(lv)
    lv = tonumber(lv)
    return "league_rank/profile_club_bg_0" .. math.min(lv,6) .. ".png"
end


function ClubManage:getClubRandomIcon()
    local id = self.clubIcon_[ math.random(1, #self.clubIcon_)]
    return "clubIcon/" ..id .. ".png" , id
end

function ClubManage:getClubLimitLevel()
    return self.clubLimitLevel_
end

function ClubManage:getMemberTipInfo()
    local level = 1
    if self.club_ ~= nil then
        if self.club_.level ~= nil then
            level = self.club_.level
        end
    end
    local now_num = self.clubSettingTabel_[tostring(level)]["max_members"]
    local pre_num = self.clubSettingTabel_[tostring( math.min(level + 1,self:getClubMaxLevel()))]["max_members"]
    if level >= self:getClubMaxLevel() then
        return "Club Level " .. level .. " -  Max " .. now_num .. " Members"
    end
    return "Club Level " .. level .. " -  Max " .. now_num .. " Members\nNext Club level - Max " .. pre_num .. " Members"
end

function ClubManage:getClubMaxLevel()
    local tip = 0
    for k , v in pairs(self.clubSettingTabel_) do
        tip = tip + 1
    end
    return tip
end

return ClubManage
--endregion
