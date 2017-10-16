-- region *.lua
-- Date
-- 此文件由[BabeLua]插件自动生成
local ClubProfileLayer = class("ClubProfileLayer", cc.load("mvc").ViewBase)
local ClubManage = bole:getClubManage()
function ClubProfileLayer:onCreate()
    print("ClubProfileLayer-onCreate")
    ClubManage = bole:getClubManage()
    self.root_ = self:getCsbNode():getChildByName("root")

    self:initClubWall() 
    self:initMember()
    self:initRequest()

    self:adaptScreen()
    self:refrushButton("wall")
    self:setAllBtnTouch(false)
end

function ClubProfileLayer:onEnter()
    bole:addListener("initClubInfo", self.initClubInfo, self, nil, true)
    bole:addListener("modifyClub", self.modifyClub, self, nil, true)
    bole:addListener("addMember", self.addMember, self, nil, true)
    bole:addListener("dealClubApp", self.dealClubApp, self, nil, true)
    bole:addListener("collectClubTask", self.collectClubTask, self, nil, true)
    bole:addListener("collectClubBuy", self.collectClubBuy, self, nil, true)
    bole:addListener("show_club_reminder_clubProfileLayer", self.reClub_application_rem, self, nil, true)
    bole:addListener("club_kickOuted", self.reKickOuted, self, nil, true)

    bole.socket:registerCmd("club_donate", self.club_donate, self)
    bole.socket:registerCmd("collect_club_gift", self.reCollect_club_gift, self)
    bole.socket:registerCmd("get_club_application", self.get_club_application, self)
    bole.socket:registerCmd(bole.SERVER_LEAGUE_RANK, self.showRank, self)
end

function ClubProfileLayer:initClubInfo(data)
    self:setAllBtnTouch(true)
    self.clubInfo_ = data.result
    self.selfInfo_ = ClubManage:getSelfInfo()
    self.clubInfo_.selfInfo = self.selfInfo_
    bole:getAppManage():setClubInfo(self.clubInfo_)
    self:refreshClubWall() 
    self:refrushRequest()
    self:refreshClubTask()
    self:refreshDonateShow()
    self:refrushClubBuy()
    self:refrushView(true)
    bole:postEvent("initMemberInfo", self.clubInfo_)
end

function ClubProfileLayer:initClubWall()
    self.scroll = self.root_:getChildByName("scroll")
    self.scroll:setScrollBarOpacity(0)
    self.scroll_root = self.scroll:getChildByName("scroll_root")
    --联盟图标
    self.club_icon_ = self.scroll_root:getChildByName("img_icon")
    self.club_icon_:setTouchEnabled(false)
    self.club_icon_:addTouchEventListener(handler(self, self.touchEvent))

    --联盟名字
    self.img_name_bg_ = self.scroll_root:getChildByName("img_name_bg")
    self.club_name_ = self.img_name_bg_:getChildByName("panel_txt"):getChildByName("txt_name")

    --联盟描述
    --self.img_edit_bg_ = self.scroll_root:getChildByName("img_edit_bg")
    self.textListView_ = self.scroll_root:getChildByName("textListView")
    self.textListView_:setScrollBarOpacity(0)
    self.img_edit_txt_ = cc.Label:createWithTTF("", "font/bole_ttf.ttf", 22)
    self.img_edit_txt_:setDimensions(240,0)
    self.img_edit_txt_:setTextColor({ r = 255, g = 255, b = 255} )
    self.img_edit_txt_:setAnchorPoint(0,1)
    self.textListView_:addChild(self.img_edit_txt_)
    self.textListView_:setTouchEnabled(false)
    self.textListView_:addTouchEventListener(handler(self, self.touchTextListViewEvent))

    --联赛
    self.panel_league_ = self.scroll_root:getChildByName("panel_league")

    self.img_club_icon_ = self.panel_league_:getChildByName("img_club_icon")
    self.btn_league_ = self.panel_league_:getChildByName("btn_league")
    self.btn_league_:setTouchEnabled(true)
    self.btn_league_:addTouchEventListener(handler(self, self.touchEvent))

    --联盟捐献
    self.sp_pig_ = self.scroll_root:getChildByName("sp_pig")
    self.sp_pig_:setTouchEnabled(true)
    self.sp_pig_:addTouchEventListener(handler(self, self.touchEvent))
    self.loadingBar = self.scroll_root:getChildByName("LoadingBar")
    self.donateInfo_ = self.scroll_root:getChildByName("donateInfo")

    self.btn_wall_ = self.root_:getChildByName("btn_wall")  
    self.btn_wall_:addTouchEventListener(handler(self, self.touchEvent))
    self.btn_wall_light_ = self.root_:getChildByName("btn_wall_light")  

    --联赛倒计时
    local time = self.panel_league_:getChildByName("time")
    self.txt_d1 = time:getChildByName("txt_d1")
    self.txt_d2 = time:getChildByName("txt_d2")
    self.txt_h1 = time:getChildByName("txt_h1")
    self.txt_h2 = time:getChildByName("txt_h2")
    self.txt_m1 = time:getChildByName("txt_m1")
    self.txt_m2 = time:getChildByName("txt_m2")
    self.txt_s1 = time:getChildByName("txt_s1")
    self.txt_s2 = time:getChildByName("txt_s2")

   local function update(dt)
        self:updateTime(dt)
    end
    self:onUpdate(update)
end

function ClubProfileLayer:cleanViewTxt()
    self.club_icon_:loadTexture("common/common_touming.png")
    self.club_name_:setString("")
    self.club_name_:stopAllActions()
    self.club_name_:setPosition(90,18.5)
    self.img_edit_txt_:setString("")
    self.img_club_icon_:loadTexture("common/common_touming.png")
end

function ClubProfileLayer:updateTime(dt)
    if not self.delayTime then
        return
    end
    self.delayTime = self.delayTime - dt
    if self.delayTime > 0 then
        local s = math.floor(self.delayTime) % 60
        local m = math.floor(self.delayTime / 60) % 60
        local h = math.floor(self.delayTime / 3600) % 24
        local d = math.floor(self.delayTime / 3600 / 24)
        if d > 9 then
            self.txt_d1:setString(math.floor(d / 10))
            self.txt_d2:setString(d % 10)
        else
            self.txt_d1:setString("0")
            self.txt_d2:setString(d)
        end
        if h > 9 then
            self.txt_h1:setString(math.floor(h / 10))
            self.txt_h2:setString(h % 10)
        else
            self.txt_h1:setString("0")
            self.txt_h2:setString(h)
        end
        if m > 9 then
            self.txt_m1:setString(math.floor(m / 10))
            self.txt_m2:setString(m % 10)
        else
            self.txt_m1:setString("0")
            self.txt_m2:setString(m)
        end
        if s > 9 then
            self.txt_s1:setString(math.floor(s / 10))
            self.txt_s2:setString(s % 10)
        else
            self.txt_s1:setString("0")
            self.txt_s2:setString(s)
        end
    else
        self.txt_d1:setString("0")
        self.txt_d2:setString("0")
        self.txt_h1:setString("0")
        self.txt_h2:setString("0")
        self.txt_m1:setString("0")
        self.txt_m2:setString("0")
        self.txt_s1:setString("0")
        self.txt_s2:setString("0")
    end
end

function ClubProfileLayer:refreshClubWall()
    local data = self.clubInfo_
    self.club_icon_:loadTexture(bole:getClubManage():getClubIconPath(data.icon))
    self.club_icon_:getChildByName("txt_level"):setString(data.level)
    self:setEditTxt(data.description)

    if ClubManage:isClubLeader() then
        self.club_icon_:setTouchEnabled(true)
    else
        self.club_icon_:setTouchEnabled(false)
    end

    self.img_club_icon_:loadTexture(bole:getClubManage():getLeagueIconPath(data.league_level))
    self.panel_league_:getChildByName("txt_rank_lv"):setString(data.league_level)
    self.club_name_:setString(data.name)
    bole:moveStr(self.club_name_, 190)

    local coins = tonumber(bole:getConfigCenter():getConfig("clubset", tonumber(data.level), "personaldonate"))
    self.sp_pig_:getChildByName("coins"):setString(bole:formatCoins(coins,5))

    if ClubManage:isShowRem() then 
        self.requestHint_:setVisible(true)
    end 

    self.delayTime = data.leave
    --self:showWallLayer()
end

function ClubProfileLayer:initMember()
    self.btn_member_ = self.root_:getChildByName("btn_member")
    self.btn_member_:addTouchEventListener(handler(self, self.touchEvent))
    self.btn_member_light_ = self.root_:getChildByName("btn_member_light") 
end

function ClubProfileLayer:initRequest()
    self.requestHint_ = self.root_:getChildByName("hint_manage")
    self.requestHint_:setVisible(false)
    if ClubManage:isShowRem() then 
        self.requestHint_:setVisible(true)
    end 
    self.btn_manage_ = self.root_:getChildByName("btn_manage")
    self.btn_manage_:addTouchEventListener(handler(self, self.touchEvent))
    self.btn_manage_light_ = self.root_:getChildByName("btn_manage_light")

    if ClubManage:isClubLeader() then
        self.btn_manage_:setVisible(true)
        --self.btn_manage_light_:setVisible(true)
    else
        self.btn_manage_:setVisible(false)
        self.btn_manage_light_:setVisible(false)
    end
end

function ClubProfileLayer:refrushRequest()
    if ClubManage:isShowRem() then 
        self.requestHint_:setVisible(true)
    end 
    if ClubManage:isClubLeader() then
        self.btn_manage_:setVisible(true)
        --self.btn_manage_light_ :setVisible(true)
    else
        self.btn_manage_:setVisible(false)
        self.btn_manage_light_ :setVisible(false)
    end
end

function ClubProfileLayer:refrushClubBuy()
    if self.clubBuyCell_ == nil then
        self.clubBuyCell_ = bole:getEntity("app.views.club.ClubBuyCell","inClub")
        self.scroll_root:getChildByName("node_buy"):addChild(self.clubBuyCell_)
    end
    self.clubBuyCell_:refrushClubBuy()

    --
    if self.clubBuyCollectCell_ ~= nil then
        for k ,v in pairs(self.clubBuyCollectCell_) do
            v:removeFromParent()
        end
    end
    self.clubBuyCollectCell_ = {}
    for i = 1,  # self.clubInfo_.gifts do
        self.clubBuyCollectCell_[i] = bole:getEntity("app.views.club.ClubBuyCollectCell",self.clubInfo_.gifts[i],i)
        self.scroll_root:getChildByName("node_buy"):addChild(self.clubBuyCollectCell_[i])
        self.clubBuyCollectCell_[i]:setPositionY(- (i - 1) * 100 - 100)
        self.clubBuyCollectCell_[i]:refrushClubBuy(self.clubInfo_.gifts[i],i)
    end
    self.club_buyNum_ = # self.clubInfo_.gifts
end

function ClubProfileLayer:collectClubBuy_view(data)
    local index = data
    self.clubBuyCollectCell_[index]:removeFromParent()
    table.remove(self.clubBuyCollectCell_ , index)
    self.club_buyNum_ =  self.club_buyNum_ - 1
    for i = 1,  self.club_buyNum_ do
        self.clubBuyCollectCell_[i]:refrushClubBuy(self.clubInfo_.gifts[i],i)
        self.clubBuyCollectCell_[i]:setPositionY(- (i - 1) * 100 - 100)
    end
    self:refrushView()
end

function ClubProfileLayer:refreshClubTask()
    self.taskInfo_ = ClubManage:getTaskInfo()
    if self.taskLayer_ == nil then
        self.taskLayer_  = {}
    end
    self.taskNum_ = 0
    for k ,v in pairs(self.taskInfo_) do
        self.taskNum_ = self.taskNum_ + 1
    end
    local pos = # self.taskInfo_
    for i = 1 ,# self.taskInfo_ do
        if self.taskLayer_[i] == nil then
            self.taskLayer_[i] = bole:getEntity("app.views.club.ClubTaskCell",self.taskInfo_[i],self.clubInfo_.users,i )
            self.scroll_root:getChildByName("node_task"):addChild(self.taskLayer_[i],i)
            self.taskLayer_[i]:setPositionY(0 - (pos - 1) * 185)
        else
            self.taskLayer_[i]:refrushTaskInfo(self.taskInfo_[i],self.clubInfo_.users,i )
            self.taskLayer_[i]:setPositionY(0 - (pos - 1) * 185)
        end
        pos = pos - 1
    end
    for i = # self.taskInfo_ + 1, # self.taskLayer_ do
        if self.taskLayer_[i] ~= nil then
            self.taskLayer_[i]:removeFromParent()
            self.taskLayer_[i] = nil
        end
    end
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
        self.taskLayer_[i]:setPositionY(0 - (pos - 1) * 185)
        pos = pos - 1
    end
    self.taskNum_ = self.taskNum_ - 1
    --[[
    self.scroll:setInnerContainerSize(cc.size(1334, 560 + (# self.taskInfo_ - 1) * 185))
    self.scroll_root:setPositionY( 560 + (# self.taskInfo_ - 1) * 185)
    self.scroll:scrollToBottom(0,true)
    --]]
    self:refrushView()
end

function ClubProfileLayer:refreshDonateShow(data)
    local data = self.clubInfo_
    local expNow = tonumber(data.exp)
    local level = tonumber(data.level)
    local needExp = tonumber(bole:getConfigCenter():getConfig("clubset",level, "nextlevel_money"))

    if level >= bole:getClubManage():getClubMaxLevel() then
        self.loadingBar:setPercent(100)
        self.donateInfo_:getChildByName("num_x"):setString(bole:formatCoins(expNow,4))
        self.donateInfo_:getChildByName("txt_nextLv"):setString(bole:getClubManage():getClubMaxLevel())
    else
        self.loadingBar:setPercent(expNow / needExp * 100)
        --self.donateInfo_:getChildByName("num1"):setString(bole:formatCoins(expNow,4))
        self.donateInfo_:getChildByName("num_x"):setString(bole:formatCoins(expNow,4) .. "/" .. bole:formatCoins(needExp,4))
        --self.donateInfo_:getChildByName("num2"):setString(bole:formatCoins(needExp,4))
        self.donateInfo_:getChildByName("txt_nextLv"):setString(data.level + 1)
    end
    local coins = tonumber(bole:getConfigCenter():getConfig("clubset", tonumber(self.clubInfo_.level), "personaldonate"))
    self.sp_pig_:getChildByName("coins"):setString(bole:formatCoins(coins,3))
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
        if not ClubManage:isInClub() then
            bole:popMsg({msg ="you have left club" , title = "club" , cancle = false})
        else
            if name == "img_icon" then
                self:editClubInfo()
            elseif name == "btn_league" then --联赛
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
--[[
function ClubProfileLayer:textListViewScrollEvent(sender,eventType)
    print(eventType)
end
--]]

function ClubProfileLayer:touchTextListViewEvent(sender, eventType)
    local name = sender:getName()
    if eventType == ccui.TouchEventType.began then
        self.moved_ = 0
    elseif eventType == ccui.TouchEventType.moved then
        self.moved_ = self.moved_ + 1
    elseif eventType == ccui.TouchEventType.ended then
        if self.moved_ < 5 then
            if not ClubManage:isInClub() then
                bole:popMsg({msg ="you have left club" , title = "club" , cancle = false})
            else
                if name == "textListView" then
                    self:editClubInfo()
                end
            end
        end
        self.moved_ = 0
    elseif eventType == ccui.TouchEventType.canceled then

    end
end

function ClubProfileLayer:refrushButton(str)
    self.root_:getChildByName("btn_wall"):setTouchEnabled(true)
    self.root_:getChildByName("btn_member"):setTouchEnabled(true)
    self.root_:getChildByName("btn_manage"):setTouchEnabled(true)
   
    self.root_:getChildByName("btn_wall_light"):setVisible(false)
    self.root_:getChildByName("btn_member_light"):setVisible(false)
    self.root_:getChildByName("btn_manage_light"):setVisible(false)

    self.root_:getChildByName("btn_" .. str):setTouchEnabled(false)
    self.root_:getChildByName("btn_" .. str .. "_light"):setVisible(true)

    if ClubManage:isClubLeader() then
        self.root_:getChildByName("btn_manage"):setVisible(true)
        self.root_:getChildByName("btn_manage"):setTouchEnabled(true)   

    else
        self.root_:getChildByName("btn_manage"):setVisible(false)
        self.root_:getChildByName("btn_manage"):setTouchEnabled(false)
        self.root_:getChildByName("btn_manage_light"):setVisible(false)
    end
end

function ClubProfileLayer:editClubInfo()
    if ClubManage:isClubLeader() then
        bole:getUIManage():openNewUI("ClubCreateLayer",true,"club","app.views.club")
        bole:postEvent("modifyClubLayer",self.clubInfo_)
    end
end

function ClubProfileLayer:modifyClub(data)
    data = data.result
    ClubManage:modifyClubInfo(data)
    self:setEditTxt(data.description)
    self.club_icon_:loadTexture(bole:getClubManage():getClubIconPath(data.icon))
end

function ClubProfileLayer:setEditTxt(txt)
    self.img_edit_txt_:setString(bole:getNewStr(txt, 22, 240))
    local size = self.img_edit_txt_:getContentSize()
    self.textListView_:setInnerContainerSize(cc.size(240, math.max(size.height, 70)))
    self.img_edit_txt_:setPosition(0,math.max(size.height, 70))
    self.textListView_:scrollToTop(0,true)
end

function ClubProfileLayer:clubContribute()
    local coins = tonumber(bole:getConfigCenter():getConfig("clubset", tonumber(self.clubInfo_.level), "personaldonate"))
    if tonumber(self.selfInfo_.donate_daily) == 0 then
        self.subCoins_ = coins
        bole.socket:send("club_donate", { coins = self.subCoins_ }, true)
    else
        bole:popMsg({msg = "Donate once a day" , title = "Donate" , cancle = false})
    end
end

function ClubProfileLayer:club_donate(t,data)
    if t == "club_donate" then
        --TODO
        if data.error ~= nil then
            if data.error == 3 then   --今日已捐献
                bole:popMsg({msg = "Donate once a day" , title = "donate" , cancle = false})
            elseif data.error == 0 then  
                self.clubInfo_.level = tonumber(data.level)
                self.clubInfo_.max_u_count = tonumber(data.max_u_count)
                self.clubInfo_.exp = tonumber(data.exp)
                bole:getAppManage():addCoins(-self.subCoins_)
                self.selfInfo_.donate = tonumber(self.selfInfo_.donate) + tonumber(self.subCoins_)
                self.selfInfo_.donate_daily = 1000
                self.scroll_root:getChildByName("img_icon"):getChildByName("txt_level"):setString(self.clubInfo_.level)
                self:refreshDonateShow(self.clubInfo_)
            elseif data.error == 4 then  --已经退出联盟
                bole:popMsg({msg ="you have left club" , title = "donate" , cancle = false})
            elseif data.error == 2 then  --没有足够的金币
                bole:popMsg({msg ="you don't have enough coins" , title = "donate" , cancle = false})
            elseif data.error ~= nil then --其他错误
                bole:popMsg({msg ="error:" .. data.error , title = "donate" , cancle = false })
            end 
        end
    end
end

function ClubProfileLayer:addMember(data)
    data = data.result
    data.donate = 0
    data.league_point = 0
    data.club_title = 3
    data.online = 1
                    for k ,v in pairs( self.clubInfo_.users) do
                        if v.user_id == data.user_id then
                            v.donate = 0
                            v.league_point = 0
                            v.club_title = 3
                            return
                        end
                    end


    table.insert(self.clubInfo_.users , # self.clubInfo_.users + 1, data)
    bole:postEvent("addMemberPanel", data) 
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
    --self.btn_wall_:setVisible(false)
    self.btn_wall_light_:setVisible(true)
    self.btn_member_light_:setVisible(false)
    self.btn_manage_light_:setVisible(false)
    self:cleanViewTxt()
    --self:refrushButton("wall")
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
        self.member = bole:getUIManage():createNewUI("ClubMemberLayer","club","app.views.club",nil,false)
        self:addChild(self.member)
        self.member:setPositionY(self.addposY)
        bole:postEvent("initAdaptPos", self.addposY)
    end
    self.scroll:setVisible(false)
    if self.manage ~= nil then
        self.manage:setVisible(false)
    end
    self.member:setVisible(true)
    if self.clubInfo_ ~= nil then
        bole:postEvent("initMemberInfo", self.clubInfo_)
    end
    self:saveTaskSchedule()
end

function ClubProfileLayer:showRequestLayer()
    self:refrushButton("manage")
    ClubManage:setIsShowRem(false)
    if self.manage == nil then
        self.manage = bole:getUIManage():createNewUI("ClubRequestLayer","club","app.views.club",nil,false)
        self:addChild(self.manage)
        self.manage:setPositionY(self.addposY)
    end
    self.scroll:setVisible(false)
    if self.member ~= nil then
        self.member:setVisible(false)
    end 
    self.manage:setVisible(true)
    self.manage.listView_:removeAllChildren()
    if self.clubInfo_ == nil then
        bole.socket:send("get_club_application",{id = tonumber(ClubManage:getClubId())},true)
    else
        bole.socket:send("get_club_application",{id = tonumber(self.clubInfo_.id)},true)
    end
    self:saveTaskSchedule()
end

function ClubProfileLayer:get_club_application(t,data)
    bole:postEvent("initRequestInfo",data.applications)
end

function ClubProfileLayer:reClub_application_rem(data)
    data = data.result
    if ClubManage:isClubLeader() then
        if self.manage ~= nil then
            if self.manage:isVisible() then
                 bole:postEvent("show_club_reminder_lobbyScene",false)
                return
            end
        end
        self.requestHint_:setVisible(data)
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
    bole:removeListener("collectClubBuy", self)
    bole:removeListener("show_club_reminder_clubProfileLayer", self)
    bole:removeListener("club_kickOuted", self)
   
    bole.socket:unregisterCmd("club_donate")
    bole.socket:unregisterCmd("get_club_application")
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

function ClubProfileLayer:refrushView(isScrollToTop)
    self.scroll_root:getChildByName("node_buy"):setPositionY(206)
    self.scroll_root:getChildByName("node_task"):setPositionY(50 - self.club_buyNum_  * 100)
    self.scroll:setInnerContainerSize(cc.size(1250, 565 + (self.taskNum_ - 1) * 185 + self.club_buyNum_ * 100 ))
    self.scroll_root:setPositionY( 565 + (self.taskNum_ - 1) * 185 + self.club_buyNum_ * 100)
    if isScrollToTop then
        self.scroll:scrollToTop(0,true)
    end
end
function ClubProfileLayer:collectClubBuy(data)
    data = data.result
    bole.socket:send("collect_club_gift", { gift_id = data[1] } )
    self.club_gift_index_ = data[2]

end

function ClubProfileLayer:reCollect_club_gift()
    self:collectClubBuy_view(self.club_gift_index_)
    bole:getAppManage():addCoins( bole:getBuyManage():getPriceDataById(1032).coins_amount * 0.05)
   -- bole:getUserData():updateSceneInfo("diamond")
end

function ClubProfileLayer:setAllBtnTouch(isTouch)
    self.club_icon_:setTouchEnabled(isTouch)
    self.textListView_:setTouchEnabled(isTouch)
    self.btn_league_:setTouchEnabled(isTouch)
    self.sp_pig_:setTouchEnabled(isTouch)
    self.btn_wall_:setTouchEnabled(isTouch)
    self.btn_member_:setTouchEnabled(isTouch)
    self.btn_manage_:setTouchEnabled(isTouch)
end

function ClubProfileLayer:reKickOuted(data)
    if self:isVisible() then
        bole:popMsg({msg ="you have left this club." , title = "error" , cancle = false}, function() bole:postEvent("openClubLayer") return end)
    end
end

return ClubProfileLayer


-- endregion
