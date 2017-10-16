--region *.lua
--Date
--此文件由[BabeLua]插件自动生成

local FriendManage = class("FriendManage")

function FriendManage:initListener()
    self:initInfo()
    

    bole.socket:registerCmd("receive_f_remove", self.reSORemoveMe, self)     --我被其他人删除好友
    --bole.socket:registerCmd("deal_f_application", self.reApplication, self)  --处理好友申请
    bole:addListener("receive_f_application_toManage", self.reR_application, self, nil, true)
end

function FriendManage:initInfo()
    self.friends_ = nil              --好友信息列表
    self.applicationsList_ = nil     --好友申请信息列表
    self.connectList_ = false        --已发送好友申请列表(id)
    self.friendIdList_ = nil         --好友id列表(id)
    self.showRem_ = false            --是否显示申请提示
end

function FriendManage:removeListener()
    bole.socket:unregisterCmd("receive_f_remove")
   -- bole.socket:unregisterCmd("deal_f_application")
    bole:removeListener("receive_f_application_toManage", self)
end

function FriendManage:cleanLocalData()
    self.friends_ = nil
    self.applicationsList_ = nil
    self.connectList_ = nil
    self.friendIdList_ = nil
    self.showRem_ = nil
    self:removeListener()
end

--初始化本地数据
function FriendManage:initLocalData()
        local friendIdList = bole:getUserDataByKey("user_friends")
        if type(friendIdList) == "table" then
             self.friendIdList_ = {}
            for k ,v in pairs( friendIdList) do
                self.friendIdList_[v] = 1
            end
        end

    if bole:getUserDataByKey("friend_tips") ~= 0 then
        self.showRem_ = true
    end
end

--我被其他人删除好友
function FriendManage:reSORemoveMe(t,data)
    if data.user_id ~= nil then
        local id = data.user_id
        if self.friends_ ~= nil then
            for i = 1, #self.friends_ do
                if tonumber(self.friends_[i].user_id) == tonumber(id) then
                    table.remove(self.friends_, i)
                    break
                end
            end
        end
        self.friendIdList_ = self.friendIdList_ or {}
        self.friendIdList_[id] = nil
        self:removeAppLication(id)
    end
end

--好友信息列表
function FriendManage:setFriend(data)
    self.friends_ = data
    self.friendIdList_ = {}
    for k ,v in pairs(self.friends_) do
        self.friendIdList_[v.user_id] = 1
    end
    self:sortList() 
    return self.friends_
end

function FriendManage:getFriend()
    return self.friends_
end

--好友申请列表
function FriendManage:setApplication(data)
    self.applicationsList_ = data
    return self.applicationsList_
end

function FriendManage:getApplication()
    return self.applicationsList_
end


function FriendManage:reR_application(data)
    data = data.result
    self:addAppLication(data)  
    dump(data,"reR_application")
    bole:postEvent("add_f_application_friendRequestLayer",data)
    self:setIsShowRem(true)
end

--好友申请提示相关
function FriendManage:isShowRem()
    return self.showRem_
end

function FriendManage:setIsShowRem(bool)
    self.showRem_ = bool
    bole:postEvent("show_f_reminder_lobbyScene", bool)
    bole:postEvent("show_f_reminder_friendLayer", bool)
end

--是否为好友
function FriendManage:isFriend(id)
    if self.friendIdList_ == nil then
        self.friendIdList_ = {}
        local friendIdList = bole:getUserDataByKey("user_friends")
        if type(friendIdList) == "table" then
            for k ,v in pairs( friendIdList) do
                self.friendIdList_[v] = 1
            end
        end
    end
    return self.friendIdList_[id] ~= nil
end

--添加好友
function FriendManage:addFriend(data)
    if self.friends_ ~= nil then
        if # self.friends_ == 0 then
            table.insert(self.friends_, data)
        else
            if data.online == 1 then
                table.insert(self.friends_, 1,data)
            else
                for i = 1, # self.friends_ do
                    if i == # self.friends_ then
                        if self.friends_[i].online ~= 0 then
                            table.insert(self.friends_, data)
                            break
                        end
                    end
                    if self.friends_[i].online == 0 then
                        table.insert(self.friends_, i , data)
                        break
                    end
                end
            end
        end
    end
    self.friendIdList_ = self.friendIdList_ or {}
    self.friendIdList_[data.user_id] = 1
    self:removeAppLication(data.user_id)
    bole:postEvent("addFriend",{data})
end

--添加好友，参数为table
--{data}
function FriendManage:addFriendTable(data)
    for i = 1, # data do
        if self.friends_ ~= nil then
            table.insert(self.friends_, data[i])
        end
        self.friendIdList_ = self.friendIdList_ or {}
        self.friendIdList_[data[i].user_id] = 1
        self:removeAppLication(data[i].user_id)
    end
    bole:postEvent("addFriend", data)
end


function FriendManage:addTofriendIdList(id)
    self.friendIdList_ = self.friendIdList_ or {}
    self.friendIdList_[id] = 1
end

function FriendManage:removeTofriendIdList(id)
    if self.friendIdList_ == nil then
        return
    end
    self.friendIdList_[id] = nil
end

function FriendManage:removeFriend(id)
    if self.friends_ ~= nil then
        for i = 1, #self.friends_ do
            if tonumber(self.friends_[i].user_id) == tonumber(id) then
                table.remove(self.friends_, i)
                break
            end
        end
    end
    self.friendIdList_ = self.friendIdList_ or {}
    self.friendIdList_[id] = nil
    self:removeAppLication(id)
    bole:postEvent("removeFriend", id)
end

function FriendManage:addAppLication(data)  
    if not self:isFriend(data.user_id) then
        if self.applicationsList_ ~= nil then
            table.insert(self.applicationsList_, data)
        end
    end
end

function FriendManage:removeAppLication(id)
    if self.applicationsList_ ~= nil then
        for i = 1, #self.applicationsList_ do
            if tonumber(self.applicationsList_[i].user_id) == tonumber(id) then
                table.remove(self.applicationsList_, i)
                return
            end
        end
    end
end

function FriendManage:sortList() 
    local test = {}
    table.sort(self.friends_, function(a,b)
        if tonumber(a.online) == tonumber(b.online) then
            return tonumber(bole:string2time(a.login)) > tonumber(bole:string2time(b.login))
        else
            return tonumber(a.online) > tonumber(b.online)
        end
    end)
end

function FriendManage:addConnect(id)
    self.connectList_[id] = 1
end

function FriendManage:removeConnect(id)
    self.connectList_[id] = nil
end

function FriendManage:isConnect(id)
    return self.connectList_[id] ~= nil
end

--[[
function FriendManage:reApplication(t,data)

end

function FriendManage:reApplication(t,data)

end

--]]






return FriendManage



--endregion
