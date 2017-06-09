-- region *.lua
-- Date
-- 此文件由[BabeLua]插件自动生成
local ClubProfileLayer = class("ClubProfileLayer", cc.load("mvc").ViewBase)
function ClubProfileLayer:onCreate()
    print("ClubProfileLayer-onCreate")
    self.root_ = self:getCsbNode():getChildByName("root")

    self:initClubWall() 
    self:initMember()
    self:initRequest()

    self:adaptScreen()
end

function ClubProfileLayer:onEnter()
    bole:addListener("initClubInfo", self.initClubInfo, self, nil, true)
    bole:addListener("modifyClub", self.modifyClub, self, nil, true)
    bole:addListener("addMember", self.addMember, self, nil, true)
    bole:addListener("dealClubApp", self.dealClubApp, self, nil, true)
    bole:addListener("collectClubTask", self.collectClubTask, self, nil, true)
    bole.socket:registerCmd("club_donate", self.club_donate, self)
    bole.socket:registerCmd("get_club_application", self.get_club_application, self)
    bole.socket:registerCmd("m_apply_joining_club", self.m_apply_joining_club, self)
    bole.socket:registerCmd(bole.SERVER_LEAGUE_RANK, self.showRank, self)
end

function ClubProfileLayer:initClubInfo(data)
    self.clubInfo_ = data.result
    self:refreshClubWall(self.clubInfo_) 
    self:refreshClubTask(self.clubInfo_)
    self:refreshDonateShow(self.clubInfo_)
    self:refrushButton("wall")
    self:refrushClubBuy()
end

function ClubProfileLayer:initClubWall(data)
    self.scroll = self.root_:getChildByName("scroll")
    self.scroll_root = self.scroll:getChildByName("scroll_root")

    --联盟图标
    self.club_icon_ = self.scroll_root:getChildByName("img_icon")
    self.club_icon_:setTouchEnabled(false)
    self.club_icon_:addTouchEventListener(handler(self, self.touchEvent))

    --联盟名字
    self.img_name_bg_ = self.scroll_root:getChildByName("img_name_bg")

    --联盟描述
    self.img_edit_bg_ = self.scroll_root:getChildByName("img_edit_bg")
    self.img_edit_bg_:setTouchEnabled(false)
    self.img_edit_bg_:addTouchEventListener(handler(self, self.touchEvent))

    --联赛等级
    self.img_club_icon_ = self.scroll_root:getChildByName("img_club_icon")
    self.img_club_icon_:setTouchEnabled(true)
    self.img_club_icon_:addTouchEventListener(handler(self, self.touchEvent))

    --联盟捐献
    self.sp_pig_ = self.scroll_root:getChildByName("sp_pig")
    self.sp_pig_:setTouchEnabled(true)
    self.sp_pig_:addTouchEventListener(handler(self, self.touchEvent))
    self.loadingBar = self.scroll_root:getChildByName("LoadingBar")

    local btn_wall = self.root_:getChildByName("btn_wall")  
    btn_wall:addTouchEventListener(handler(self, self.touchEvent))

end


function ClubProfileLayer:refreshClubWall(data)
    self.club_icon_:loadTexture(bole:getClubIconStr(data.icon))
    self.club_icon_:getChildByName("txt_level"):setString(data.level)
    self.img_edit_bg_:getChildByName("txt_edit"):setString(data.description)
    if tonumber(data.users[1].club_title) == 1 then
        self.club_icon_:setTouchEnabled(true)
        self.img_edit_bg_:setTouchEnabled(true)
    else
        self.club_icon_:setTouchEnabled(false)
        self.img_edit_bg_:setTouchEnabled(false)
    end
    self.img_club_icon_:getChildByName("txt_rank_lv"):setString(data.league_level)
    self.img_name_bg_ :getChildByName("txt_name"):setString(data.name)

    local coins = tonumber(bole:getConfigCenter():getConfig("clubset", tonumber(data.level), "personaldonate"))
    self.sp_pig_:getChildByName("coins"):setString(bole:formatCoins(coins,5))

    if tonumber(data.has_msg) == 1 then 
        self.requestHint_:setVisible(true)
    end 

    self:showWallLayer()
end

function ClubProfileLayer:initMember()
    local btn_member = self.root_:getChildByName("btn_member")
    btn_member:addTouchEventListener(handler(self, self.touchEvent))

end

function ClubProfileLayer:initRequest()
    self.requestHint_ = self.root_:getChildByName("hint_manage")
    self.requestHint_:setVisible(false)
    local btn_manage = self.root_:getChildByName("btn_manage")
    btn_manage:addTouchEventListener(handler(self, self.touchEvent))
end

function ClubProfileLayer:refrushClubBuy()
    if self.clubBuyCell_ == nil then
        self.clubBuyCell_ = bole:getEntity("app.views.club.ClubBuyCell",self.clubInfo_,"inClub")
        self.scroll_root:getChildByName("node_buy"):addChild(self.clubBuyCell_)
    end
    self.clubBuyCell_:refrushClubBuy(self.clubInfo_)
end

function ClubProfileLayer:refreshClubTask(data)
    self.taskInfo_ = data.rewards
    if self.taskLayer_ == nil then
        self.taskLayer_  = {}
    end
    local taskNum = 0
    for k ,v in pairs(self.taskInfo_) do
        taskNum = taskNum + 1
    end
    local pos = # self.taskInfo_
    for i = 1 ,# self.taskInfo_ do
        if self.taskLayer_[i] == nil then
            self.taskLayer_[i] = bole:getEntity("app.views.club.ClubTaskCell",self.taskInfo_[i],self.clubInfo_.users,i )
            self.scroll_root:getChildByName("node_task"):addChild(self.taskLayer_[i],i)
            self.taskLayer_[i]:setPositionY(0 - (pos - 1) * 170)
        else
            self.taskLayer_[i]:refrushTaskInfo(self.taskInfo_[i],self.clubInfo_.users,i )
        end
        pos = pos - 1
    end
    self.scroll:setInnerContainerSize(cc.size(1334, 596 + (taskNum - 1) * 170))
    self.scroll_root:setPositionY( 596 + (taskNum - 1) * 170)
    self.scroll:scrollToTop(0,true)
end

function ClubProfileLayer:saveTaskSchedule()
    if self.clubInfo_ ~= nil then
        local nowSchedule = {}
        if self.taskLayer_ ~= nil then
            for i = 1, #self.taskLayer_ do
                nowSchedule[self.taskLayer_[i].nowSchedule_.day] = self.taskLayer_[i].nowSchedule_
            end
        end
        cc.UserDefault:getInstance():setStringForKey("taskSchedule" ,require("json").encode(nowSchedule))
    end
end

function ClubProfileLayer:collectClubTask(data)
    data = data.result
    self:removeClubTask(data)
end

function ClubProfileLayer:removeClubTask(i)
    if self.taskLayer_[i] ~= nil then
        self.taskLayer_[i]:exit()
        self.taskLayer_[i]:removeFromParent()
        table.remove(self.taskLayer_, i)
        table.remove(self.taskInfo_, i)
    end

    local pos = #self.taskLayer_
    for i = 1, #self.taskLayer_ do
        self.taskLayer_[i]:setPositionY(0 - (pos - 1) * 170)
        pos = pos - 1
    end
    self.scroll:setInnerContainerSize(cc.size(1334, 596 + (# self.taskInfo_ - 1) * 170))
    self.scroll_root:setPositionY( 596 + (# self.taskInfo_ - 1) * 170)
    self.scroll:scrollToBottom(0,true)
end

function ClubProfileLayer:refreshDonateShow(data)
    local expNow = tonumber(data.exp)
    local level = tonumber(data.level)
    local needExp = tonumber(bole:getConfigCenter():getConfig("clubset",level, "nextlevel_money"))

    self.loadingBar:setPercent(expNow / needExp * 100)

    local coins = tonumber(bole:getConfigCenter():getConfig("clubset", tonumber(self.clubInfo_.level), "personaldonate"))
    self.sp_pig_:getChildByName("coins"):setString(bole:formatCoins(coins,5))
end
function ClubProfileLayer:showRank(t,data)
    if t == bole.SERVER_LEAGUE_RANK then
        if data.error==0 then
            bole:getUIManage():openLeagueView(data)
        end
    end
end
function ClubProfileLayer:touchEvent(sender, eventType)
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
        if tonumber(bole:getUserDataByKey("club")) == 0 then
            bole:getUIManage():openClubTipsView(11,nil)
        else
            if name == "img_icon" then
                self:editClubInfo()
            elseif name == "img_edit_bg" then
                self:editClubInfo()
            elseif name == "img_club_icon" then --联赛
                self:clubLeague()
            elseif name == "sp_pig" then
                self:clubContribute()
            elseif name == "btn_wall" then
                self:showWallLayer()
            elseif name == "btn_member" then
                self:showMemberLayer()
            elseif name == "btn_manage" then
                self:showRequestLayer()
            end
        end
    elseif eventType == ccui.TouchEventType.canceled then
        print("Touch Cancelled")
        sender:setScale(1)
    end
end

function ClubProfileLayer:refrushButton(str)
    self.root_:getChildByName("btn_wall"):setTouchEnabled(true)
    self.root_:getChildByName("btn_member"):setTouchEnabled(true)
    self.root_:getChildByName("btn_manage"):setTouchEnabled(true)
    self.root_:getChildByName("img_wall"):setVisible(false)
    self.root_:getChildByName("img_member"):setVisible(false)
    self.root_:getChildByName("img_manage"):setVisible(false)
    self.root_:getChildByName("txt_wall"):setTextColor({ r = 119, g = 121, b = 159})
    self.root_:getChildByName("txt_member"):setTextColor({ r = 119, g = 121, b = 159})
    self.root_:getChildByName("txt_manage"):setTextColor({ r = 119, g = 121, b = 159})

    self.root_:getChildByName("btn_" .. str):setTouchEnabled(false)
    self.root_:getChildByName("img_" .. str):setVisible(true)
    self.root_:getChildByName("txt_" .. str):setTextColor({ r = 255, g = 255, b = 255})

    if tonumber(self.clubInfo_.users[1].club_title) ~= 1 then
        self.root_:getChildByName("btn_manage"):setVisible(false)
        self.root_:getChildByName("btn_manage"):setTouchEnabled(false)
        self.root_:getChildByName("img_manage"):setVisible(false)
        self.root_:getChildByName("txt_manage"):setVisible(false)
    else
        self.root_:getChildByName("btn_manage"):setVisible(true)
        self.root_:getChildByName("btn_manage"):setTouchEnabled(true)   
        self.root_:getChildByName("txt_manage"):setVisible(true)
    end
end

function ClubProfileLayer:editClubInfo()
    if tonumber(self.clubInfo_.users[1].club_title) == 1 then
        bole:getUIManage():openUI("ClubCreateLayer",true,"csb/club")
        bole:postEvent("modifyClubLayer", self.clubInfo_)
    end
end

function ClubProfileLayer:modifyClub(data)
    data = data.result
    self.clubInfo_.description = data.description or self.clubInfo_.description  
    self.clubInfo_.icon = data.icon or self.clubInfo_.icon 
    self.clubInfo_.require_level = data.require_level or self.clubInfo_.require_level 
    self.clubInfo_.qualification = data.qualification or self.clubInfo_.qualification 
    self.img_edit_bg_:getChildByName("txt_edit"):setString(data.description)
    self.club_icon_:loadTexture(bole:getClubIconStr(data.icon))
end

function ClubProfileLayer:clubContribute()
    for i = 1, # self.clubInfo_.users do
        if tonumber(bole:getUserDataByKey("user_id")) == tonumber(self.clubInfo_.users[i].user_id) then
            local coins = tonumber(bole:getConfigCenter():getConfig("clubset", tonumber(self.clubInfo_.level), "personaldonate"))
            if coins > tonumber(bole:getUserData():getDataByKey("coins")) then
                bole:getUIManage():openClubTipsView(15,nil)
                return 
            end
            if tonumber(self.clubInfo_.users[i].donate_daily) == 0 then
                self.subCoins_ = coins
                bole.socket:send("club_donate",{ coins = coins },true)
            else
                bole:getUIManage():openClubTipsView(6,nil)
            end
        end
        return
    end 
end

function ClubProfileLayer:club_donate(t,data)
    if t == "club_donate" then
        --TODO
        if data.error ~= nil then
            if data.error == 3 then 
                bole:getUIManage():openClubTipsView(6,nil)
            elseif data.error == 0 then 
                self.clubInfo_.level = tonumber(data.level)
                self.clubInfo_.max_u_count = tonumber(data.max_u_count)
                self.clubInfo_.exp = tonumber(data.exp)
                --bole:getAppManage():addCoins( - tonumber(self.subCoins_))
                bole:getUserData():updateSceneInfo("coins")
                for i = 1, # self.clubInfo_.users do
                    if tonumber(bole:getUserDataByKey("user_id")) == tonumber(self.clubInfo_.users[i].user_id) then
                        self.clubInfo_.users[i].donate = tonumber(self.clubInfo_.users[i].donate) + tonumber(self.subCoins_)
                        self.clubInfo_.users[i].donate_daily = 1000
                    end
                end
                self.scroll_root:getChildByName("img_icon"):getChildByName("txt_level"):setString(self.clubInfo_.level)
                self:refreshDonateShow(self.clubInfo_)
            elseif data.error == 4 then 
                 bole:getUIManage():openClubTipsView(11,nil)
            elseif data.error == 2 then 
                bole:getUIManage():openClubTipsView(15,nil)
            end
        end
    end
end

function ClubProfileLayer:addMember(data)
    data = data.result
    data.donate = 0
    data.league_point = 0
    table.insert(self.clubInfo_.users , # self.clubInfo_.users + 1, data)
end

function ClubProfileLayer:dealClubApp(data)
    data = data.result
        if data then
            self.requestHint_:setVisible(true)
        else
            self.requestHint_:setVisible(false)
        end
end

function ClubProfileLayer:enterClubLayer()
    if self.scroll ~= nil then
        self.scroll:setVisible(true)
    end
    if self.member ~= nil then
        self.member:setVisible(false)
    end
    if self.manage ~= nil then
        self.manage:setVisible(false)
    end
    self.root_:getChildByName("img_wall"):setVisible(true)
    self.root_:getChildByName("img_member"):setVisible(false)
    self.root_:getChildByName("img_manage"):setVisible(false)
    self.root_:getChildByName("txt_wall"):setTextColor({ r = 255, g = 255, b = 255})
    self.root_:getChildByName("txt_member"):setTextColor({ r = 119, g = 121, b = 159})
    self.root_:getChildByName("txt_manage"):setTextColor({ r = 119, g = 121, b = 159})
end


function ClubProfileLayer:clubLeague()
    bole.socket:send(bole.SERVER_LEAGUE_RANK,{},true)
end

function ClubProfileLayer:showWallLayer()
    self:refrushButton("wall")
    self.scroll:setVisible(true)
    if self.member ~= nil then
        self.member:setVisible(false)
    end
    if self.manage ~= nil then
        self.manage:setVisible(false)
    end
end

function ClubProfileLayer:showMemberLayer()
    self:refrushButton("member")
    if self.member == nil then
        self.member = bole:getUIManage():getSimpleLayer("ClubMemberLayer",false,"csb/club")
        self:addChild(self.member)
        self.member:setPositionY(self.addposY)
        bole:postEvent("initAdaptPos", self.addposY)   
    end
    self.scroll:setVisible(false)
    if self.manage ~= nil then
        self.manage:setVisible(false)
    end
    self.member:setVisible(true)
    bole:postEvent("initMemberInfo", self.clubInfo_)
end

function ClubProfileLayer:showRequestLayer()
    self:refrushButton("manage")
    if self.manage == nil then
        self.manage = bole:getUIManage():getSimpleLayer("ClubRequestLayer",false,"csb/club")
        self:addChild(self.manage)
        self.manage:setPositionY(self.addposY)
    end
    self.scroll:setVisible(false)
    if self.member ~= nil then
        self.member:setVisible(false)
    end 
    self.manage:setVisible(true)
    bole.socket:send("get_club_application",{id = tonumber(self.clubInfo_.id)},true)
end

function ClubProfileLayer:get_club_application(t,data)
    if t == "get_club_application" then
        bole:postEvent("initRequestInfo",data.applications)
    end
end

function ClubProfileLayer:m_apply_joining_club(t,data)
    if t == "m_apply_joining_club" then
        self.requestHint_:setVisible(true)
    end
end
function ClubProfileLayer:adaptScreen()
    local winSize = cc.Director:getInstance():getWinSize()
    self.addposY = math.abs(winSize.height - 100 - self.root_:getContentSize().height) / 2
    self.root_:setPositionY(self.addposY)
end

function ClubProfileLayer:onExit()
    self:saveTaskSchedule()
    bole:removeListener("initClubInfo", self)
    bole:removeListener("modifyClub", self)
    bole:removeListener("addMember", self)
    bole:removeListener("dealClubApp", self)
    bole:removeListener("collectClubTask", self)
    bole.socket:unregisterCmd("club_donate")
    bole.socket:unregisterCmd("get_club_application")
    bole.socket:unregisterCmd("m_apply_joining_club")
    bole.socket:unregisterCmd(bole.SERVER_LEAGUE_RANK)
    if self.member ~= nil then
        self.member:closeUI()
    end
    if self.manage ~= nil then
        self.manage:closeUI()
    end
    if  self.taskLayer_~= nil then
        for i = 1, # self.taskLayer_ do
            self.taskLayer_[i]:exit()
        end
    end
end

return ClubProfileLayer


-- endregion
