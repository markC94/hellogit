-- region *.lua
-- Date
-- 此文件由[BabeLua]插件自动生成
local LobbyScene = class("LobbyScene", cc.load("mvc").ViewBase)
function LobbyScene:onCreate()
    print("LobbyScene-onCreate")
    local root = self:getCsbNode():getChildByName("root")
    local img_bg = root:getChildByName("img_bg")
    self.bottom = root:getChildByName("bottom")
    self.node_collect = root:getChildByName("node_collect")

    self.scroll_root = root:getChildByName("scroll_root")
    self.node_scroll = self.scroll_root:getChildByName("node_scroll")


    self.node_layer = root:getChildByName("node_layer")
    self.node_layer:setVisible(true)

    local center = self.node_scroll:getChildByName("center")
    self:initBtnAct(center)
    self.txt_num = ccui.Helper:seekWidgetByName(center, "txt_num")
    self:updateNum(math.random(500, 2000))


    local act_center = center:getChildByName("act_center")
    act_center:setContentSize(750, 224)
    local act_addNode = act_center:getChildByName("act_addNode")
    bole:getEntity("app.views.activity.ActCenterView", act_addNode)

    self:initBottom(root)
    self:initTop(root)
    self:slotUI()
    self:initStarAct(img_bg)
    self:initLobbyScroll()
    bole:getNoticeCenter():open()

    local img_namebg = self.lobby_top:getChildByName("img_bg")
    local collect_data = bole:getUserDataByKey("lobby_bonus")
    img_namebg=nil
    local collect = bole:getEntity("app.views.lobby.LobbyCollect", collect_data,img_namebg)
    self.node_collect:addChild(collect)
    bole:getAudioManage():playLobby()
end

function LobbyScene:onKeyBack()
    local isShowLobby

    if self.lotteryLayer_ and self.lotteryLayer_:isVisible() then
        isShowLobby=true
    end

    if self.clubLayer_ and self.clubLayer_:isVisible() then
        isShowLobby=true
    end

    if self.slotLayer_ and self.slotLayer_:isVisible() then
        isShowLobby=true
    end

   if isShowLobby then
        self:showLobbyScene()
   else
        bole:popMsg( { msg = "Are you sure you want to close the game?", title = "Tips", cancle = true },function()  
            cc.Director:getInstance():endToLua()
        end)
   end
end

function LobbyScene:onEnter()
    print("---------addListener--------------")
    bole:addListener("update_lobby_league", self.update_lobby_league, self, nil, true)
    bole:addListener("nameChanged", self.eventName, self, nil, true)
    bole:addListener("openClubLayer", self.openClubLayer, self, nil, true)
    bole:addListener("backLobbyScene", self.backLobbyScene, self, nil, true)
    bole:addListener("show_f_reminder_lobbyScene", self.showFriendReminder, self, nil, true)
    bole:addListener("show_club_reminder_lobbyScene", self.showClubReminder, self, nil, true)
    bole:addListener("lobby_message", self.lobbyMessage, self, nil, true)
    bole.socket:registerCmd("leave_club", self.leave_club, self)
    bole.socket:registerCmd(bole.SERVER_LEAGUE_RANK, self.showRank, self)
end

function LobbyScene:onExit()
    bole:getEventCenter():removeEventWithTarget("update_lobby_league", self)
    bole:getEventCenter():removeEventWithTarget("nameChanged", self)
    bole:getEventCenter():removeEventWithTarget("openClubLayer", self)
    bole:getEventCenter():removeEventWithTarget("backLobbyScene", self)
    bole:getEventCenter():removeEventWithTarget("show_f_reminder_lobbyScene", self)
    bole:getEventCenter():removeEventWithTarget("show_club_reminder_lobbyScene", self)
    bole:getEventCenter():removeEventWithTarget("lobby_message", self)
    bole.socket:unregisterCmd("leave_club")
    bole.socket:unregisterCmd(bole.SERVER_LEAGUE_RANK)
end
function LobbyScene:eventName(event)
    local str_name = bole:getUserDataByKey("name")
    self.txt_name:setString(bole:limitStr(str_name, 12, "..."))
end
function LobbyScene:updateNum(num)
    self.txt_num:setString(bole:formatCoins(num, 4))
end

function LobbyScene:initBtnAct(root)
    local btn_league = root:getChildByName("btn_league")
    btn_league:setTouchEnabled(true)
    btn_league:setSwallowTouches(false)
    btn_league:addTouchEventListener(handler(self, self.touchEvent))

    local btn_slots = root:getChildByName("btn_slots")
    btn_slots:setTouchEnabled(true)
    btn_slots:setSwallowTouches(false)
    btn_slots:addTouchEventListener(handler(self, self.touchEvent))

    self.act_slots777 = sp.SkeletonAnimation:create("common_act/slots777.json", "common_act/slots777.atlas")
    self.act_league = sp.SkeletonAnimation:create("common_act/jiangbei_1.json", "common_act/jiangbei_1.atlas")
    local act_league_eff = sp.SkeletonAnimation:create("common_act/jiangbei_2.json", "common_act/jiangbei_2.atlas")

    self.act_slots777:setPosition(btn_slots:getContentSize().width / 2, btn_slots:getContentSize().height / 2)
    self.act_league:setPosition(btn_league:getContentSize().width / 2, btn_league:getContentSize().height / 2)
    act_league_eff:setPosition(0, 0)
    self.act_slots777:setAnimation(0, "animation", true)
    local tips = bole:getUserDataByKey("league_tips", 0)

    if tips == 1 then
        self.act_league:setAnimation(0, "trigger", true)
    else
        self.act_league:setAnimation(0, "idle", true)
    end
    act_league_eff:setAnimation(0, "idle", true)

    local sp_league_bg = display.newSprite("lobby_img/league.png")
    sp_league_bg:setPosition(0, 0 - 40)

    local sp_level = display.newSprite()
    sp_level:setPosition(0, 0- 63)


    local ttfConfig = {fontFilePath="font/bole_ttf.ttf",fontSize=42}
    local txt_top = cc.Label:createWithTTF(ttfConfig,"99")
    txt_top:setTextColor({r = 172, g = 80, b = 20})
    txt_top:setPosition(0, 0 + 70)

    btn_slots:addChild(self.act_slots777)
    btn_league:addChild(self.act_league)
    self.act_league:addChild(sp_level)
    self.act_league:addChild(sp_league_bg)
    self.act_league:addChild(act_league_eff)
    self.act_league:addChild(txt_top)

    self.up_sp_level=sp_level
    self.up_txt_top=txt_top

    self.league_mask = root:getChildByName("league_mask")
    self.slots_mask = root:getChildByName("slots_mask")
    self.league_mask_pos=cc.p(self.league_mask:getPosition())
    self.slots_mask_pos=cc.p(self.slots_mask:getPosition())
    self.act_slots_pos=cc.p(self.act_slots777:getPosition())
    self.act_league_pos=cc.p(self.act_league:getPosition())

    self:update_lobby_league()
end


function LobbyScene:update_lobby_league()
    dump(bole:getUserData(),"update_lobby_league")
    local level = bole:getUserDataByKey("league_level")
    if not level or level==0 then
        level=1
    end
    local str_index = string.format("%02d", level)
    local league = bole:getConfig("league", str_index)
    local str_file = string.format("club_level/club_level_%d.png", league.rank_level)
    self.up_sp_level:setTexture(str_file)
    
    local top = bole:getUserDataByKey("league_rank")
    if not top or top==0 then
        self.up_txt_top:setVisible(false)
    else
        self.up_txt_top:setVisible(true)
        self.up_txt_top:setString(top)
    end
end

function LobbyScene:clickBtn(index)
    if index == 1 then
        self.slots_mask:setVisible(true)
        self.slots_mask:setPosition(self.slots_mask_pos.x + 4, self.slots_mask_pos.y - 4)
        self.act_slots777:setPosition(self.act_slots_pos.x + 4, self.act_slots_pos.y - 4)
    else
        self.league_mask:setPosition(self.league_mask_pos.x + 4, self.league_mask_pos.y - 4)
        self.act_league:setPosition(self.act_league_pos.x + 4, self.act_league_pos.y - 4)
        self.league_mask:setVisible(true)
    end
end

function LobbyScene:resetBtn()
    self.league_mask:setPosition(self.league_mask_pos)
    self.slots_mask:setPosition(self.slots_mask_pos)
    self.act_slots777:setPosition(self.act_slots_pos)
    self.act_league :setPosition(self.act_league_pos)
    self.league_mask:setVisible(false)
    self.slots_mask:setVisible(false)
end

-- 大厅星星动画
function LobbyScene:initStarAct(root)
    local starNode = bole:getEntity("app.views.lobby.LobbyStarAct")
    root:addChild(starNode)
end

-- 大厅滑动和头像加载
function LobbyScene:initLobbyScroll()
    self.lobbyScroll = bole:getEntity("app.views.lobby.LobbyScroll", self.node_scroll)
end

-- 大厅滑动和头像加载
function LobbyScene:restScrollPos()
    if self.lobbyScroll then
        self.lobbyScroll:reset()
    end
end

function LobbyScene:initBottom(root)
    local bottom = root:getChildByName("bottom")
    self.btn_friends = bottom:getChildByName("btn_friends")
    self.friendReminder = self.btn_friends:getChildByName("dian")
    self.friendReminder:setVisible(bole:getFriendManage():isShowRem())
    self.btn_myClub = bottom:getChildByName("btn_myClub")
    self.clubReminder = self.btn_myClub:getChildByName("dian")
    self.clubReminder:setVisible(bole:getClubManage():isShowRem())
    self.btn_myClub = bottom:getChildByName("btn_myClub")
    self.btn_lottery = bottom:getChildByName("btn_lottery")
    self.btn_shop = bottom:getChildByName("btn_shop")

    self.friends = bottom:getChildByName("friends")
    self.myClub = bottom:getChildByName("myClub")
    self.lottery = bottom:getChildByName("lottery")
    self.shop = bottom:getChildByName("shop")

    self.friends:setTouchEnabled(true)
    self.friends:addTouchEventListener(handler(self, self.touchEvent))
    self.myClub:setTouchEnabled(true)
    self.myClub:addTouchEventListener(handler(self, self.touchEvent))
    self.lottery:setTouchEnabled(true)
    self.lottery:addTouchEventListener(handler(self, self.touchEvent))
    self.shop:setTouchEnabled(true)
    self.shop:addTouchEventListener(handler(self, self.touchEvent))
end

function LobbyScene:initTop(root)
    local top = root:getChildByName("top")
    self.lobby_top = top

    
    self.btn_menu = top:getChildByName("btn_menu")
    local img_namebg = top:getChildByName("img_bg")
    self.txt_name = top:getChildByName("txt_name")
    local str_name = bole:getUserDataByKey("name")
    self.txt_name:setString(bole:limitStr(str_name, 12, "..."))

    self.node_head = top:getChildByName("node_head")
    self.node_progress = top:getChildByName("node_progress")
    self.btn_menu:setTouchEnabled(true)
    self.btn_menu:addTouchEventListener(handler(self, self.touchEvent))



    local node_coins = top:getChildByName("node_coins")
    local nCoins = bole:getUIManage():getNewCoinsView()
    node_coins:addChild(nCoins)
    nCoins:updatePos(nCoins.POS_COINS_LOBBY)

    local node_zs = top:getChildByName("node_zs")
    local nZs = bole:getUIManage():getNewCoinsView()
    node_zs:addChild(nZs)
    nZs:updatePos(nZs.POS_ZS_LOBBY)

    local head = bole:getNewHeadView(bole:getUserData())
    head:updatePos(head.POS_LOBBY_SELF)
    self.node_head:addChild(head)

    local newExp = bole:getUIManage():getNewExpView()
    self.node_progress:addChild(newExp)

    self.btn_club_back = top:getChildByName("btn_club_back")
    self.btn_club_back:addTouchEventListener(handler(self, self.touchEvent))
    self.node_vip = top:getChildByName("node_vip")
    self.node_vip:addTouchEventListener(handler(self, self.touchEvent))
    self.node_vip:loadTexture(bole:getBuyManage():getVipIconStr())
end



function LobbyScene:slotUI()
    self.slot = self.node_scroll:getChildByName("slot")
    local themes = bole:getConfigCenter():getConfig("theme")
    local newThemes = { }
    local newThemeId = 0
    -- MAP变数组 去掉无用数据
    for k, v in pairs(themes) do
        if v.order ~= -1 and v.isnew ~= 3 then
            local index = #newThemes + 1
            newThemes[index] = { }
            newThemes[index].index = tonumber(k)
            newThemes[index].order = v.order
            if v.isnew ~= 0 then
                newThemeId = tonumber(k)
            end
        end
    end

    local themeIds = bole:getUserDataByKey("theme_id")
    themeIds[4] = newThemeId
    self.indexs = { }
    -- 排除0和相同主题
    self:addIndexs(themeIds, 1)
    --    dump(self.indexs, "self.indexs-begin")
    local count = #self.indexs

    -- 如果主题数量小于最大值补全
    if count < 4 then
        local randomTheme = { }
        -- 筛选
        for k, v in pairs(newThemes) do
            local isSame = false
            for i = 1, count do
                if self.indexs[i] == v.index then
                    isSame = true
                end
            end
            if not isSame then
                randomTheme[#randomTheme + 1] = v.index
            end
        end
        -- 随机排序剩余主题
        bole:randSort(randomTheme)

        local level = bole:getUserDataByKey("level")
        local dlThemeIds = { }
        local ulThemeIds = { }
        local otThemeIds = { }

        for k, v in pairs(randomTheme) do
            if bole:isDownLoadTheme(v) then
                dlThemeIds[#dlThemeIds + 1] = v
            elseif level > themes["" .. v].unlock_lv then
                ulThemeIds[#dlThemeIds + 1] = v
            else
                otThemeIds[#otThemeIds + 1] = v
            end
        end
        --        dump(dlThemeIds,"dlThemeIds")
        --        dump(ulThemeIds,"ulThemeIds")
        --        dump(otThemeIds,"otThemeIds")
        local other = 4 - count
        if other > 0 then
            -- 筛选已下载主题
            for k, v in ipairs(dlThemeIds) do
                if other > 0 then
                    other = other - 1
                    self.indexs[#self.indexs + 1] = v
                end
            end
        end
        if other > 0 then
            -- 筛选已解锁主题
            for k, v in ipairs(ulThemeIds) do
                if other > 0 then
                    other = other - 1
                    self.indexs[#self.indexs + 1] = v
                end
            end
        end
        if other > 0 then
            -- 剩余主题
            for k, v in ipairs(otThemeIds) do
                if other > 0 then
                    other = other - 1
                    self.indexs[#self.indexs + 1] = v
                end
            end
        end
    end
    --    dump(self.indexs, "self.indexs-end")
    for i = 1, #self.indexs do
        local page = math.floor((i - 1) / 2)
        local index = math.floor((i - 1) % 2)
        local cell = bole:getEntity("app.views.lobby.LobbyCell", self.indexs[i])
        cell:setPosition(cc.p(136 + 265 * index, 364 - 244 * page))
        self.slot:addChild(cell)
    end
    performWithDelay(self,function()
        bole:checkDownLoadTheme()
    end,0.2)
end
function LobbyScene:addIndexs(themeIds, n_index)
    if n_index > #themeIds then
        return
    end
    if themeIds[n_index] ~= 0 then
        local isSame = false
        if n_index ~= 1 then
            for i = 1, n_index - 1 do
                if themeIds[i] == themeIds[n_index] then
                    isSame = true
                end
            end
        end
        if not isSame then
            self.indexs[#self.indexs + 1] = themeIds[n_index]
        end

    end
    self:addIndexs(themeIds, n_index + 1)
end

function LobbyScene:touchEvent(sender, eventType)
    local name = sender:getName()
    local tag = sender:getTag()
    --    print("touchEvent:" .. name)
    if eventType == ccui.TouchEventType.began then
        print("Touch Down")
        sender:setScale(1.05)
        self:bottomClick(name,0)
        if name == "btn_slots" then
            sender:setScale(1)
            self:clickBtn(1)
        elseif name == "btn_league" then
            sender:setScale(1)
            self:clickBtn(2)
        end
    elseif eventType == ccui.TouchEventType.moved then
        --        print("Touch Move")
    elseif eventType == ccui.TouchEventType.ended then
        print("Touch Up")
        sender:setScale(1)
        if name == "btn_slots" then
            self.act_slots777:setScale(1)
            local bPos = sender:getTouchBeganPosition()
            local ePos = sender:getTouchEndPosition()
            if math.abs(bPos.x - ePos.x) < 100 then
                bole:getAppManage():enterLobby()
            end
            self:resetBtn()
        elseif name == "btn_league" then
            local bPos = sender:getTouchBeganPosition()
            local ePos = sender:getTouchEndPosition()
            self.act_league:setScale(1)
            if math.abs(bPos.x - ePos.x) < 100 then
                if bole:getClubManage():isInClub() then
                    bole.socket:send(bole.SERVER_LEAGUE_RANK, { }, true)
                else
                    self:showClubLayer()
                end
            end
            self:resetBtn()
        elseif name == "friends" then
              self:bottomClick(name,1,function()
                 self:showFriendLayer()
              end)
        elseif name == "myClub" then
             self:bottomClick(name,1,function()
                 self:showClubLayer()
              end)
        elseif name == "lottery" then
            self:bottomClick(name,1,function()
--                self:showLotteryLayer()
            end)
        elseif name == "shop" then
            self:bottomClick(name,1,function()
                bole:getUIManage():openNewUI("ShopLayer",true,"shop_lobby","app.views.shop")
            end)
        elseif name == "btn_menu" then
--            bole:getUIManage():popDailyGift({6,16,6})
            self:showOptionsLayer()
        elseif name == "btn_club_back" then
            self:showLobbyScene()
        elseif name == "node_vip" then
            bole:getUIManage():openNewUI("VipLayer",true,"vip","app.views.vip")
        end
    elseif eventType == ccui.TouchEventType.canceled then
        print("Touch Cancelled")
        sender:setScale(1)
        self:bottomClick(name,2)
        if name == "btn_slots" then
            self:resetBtn()
        elseif name == "btn_league" then
            self:resetBtn()
        end
    end
end

function LobbyScene:bottomClick(name, index,func)
    local time
    local scale
    if index == 0 then
        time = 0.1
        scale = 0.9
    else
        time = 0.1
        scale = nil
    end

    if name == "friends" then
        bole:clickScale(self.btn_friends, time, scale,func)
    elseif name == "myClub" then
        bole:clickScale(self.btn_myClub, time, scale,func)
    elseif name == "lottery" then
        bole:clickScale(self.btn_lottery, time, scale,func)
    elseif name == "shop" then
        bole:clickScale(self.btn_shop, time, scale,func)
    end
end


function LobbyScene:showLobbyScene()
    self.bottom:setVisible(true)
    self.node_collect:setVisible(true)
    self.scroll_root:setVisible(true)
    self:restScrollPos()
    self.btn_club_back:setVisible(false)
    self.node_vip:setVisible(true)
    if self.lotteryLayer_ ~= nil then
        self.lotteryLayer_:setVisible(false)
    end
    if self.clubLayer_ ~= nil then
        self.clubLayer_:saveTaskSchedule()
        self.clubLayer_:setVisible(false)
    end
    if self.shopLayer_ ~= nil then
        self.shopLayer_:setVisible(false)
    end
    if self.slotLayer_ ~= nil then
        self.slotLayer_:setVisible(false)
    end
end

function LobbyScene:hideAllLayer()
    self.bottom:setVisible(false)
    self.node_collect:setVisible(false)
    self.scroll_root:setVisible(false)
    self.btn_club_back:setVisible(true)
    self.node_vip:setVisible(false)
    if self.lotteryLayer_ ~= nil then
        self.lotteryLayer_:setVisible(false)
    end
    if self.clubLayer_ ~= nil then
        self.clubLayer_:setVisible(false)
    end
    if self.slotLayer_ ~= nil then
        self.slotLayer_:setVisible(false)
    end
end

function LobbyScene:updateUI(event)
    local data = event.result
    if data == "slot" then
        self:showSlotLayer()
    elseif data == "friend" then
        performWithDelay(self, function() self:showFriendLayer() end , 0.5)
    elseif data == "friend_request" then
        performWithDelay(self, function() self:showFriendLayer(data) end , 0.5)
    elseif data == "club_wall" then
        performWithDelay(self, function() self:showClubLayer() end , 0.5)
    elseif data == "club_member" then
        performWithDelay(self, function() self:showClubLayer(data) end , 0.5)
    elseif data == "club_request" then
        performWithDelay(self, function() self:showClubLayer(data) end , 0.5)
    elseif data == "league" then
        bole.socket:send(bole.SERVER_LEAGUE_RANK, { }, true)
    end
end

function LobbyScene:showFriendReminder(data)
    self.friendReminder:setVisible(data.result)
end

function LobbyScene:showClubReminder(data)
    self.clubReminder:setVisible(data.result)
end

function LobbyScene:showClubLayer(layerStr)
    if bole:getClubManage():isInClub() then
        self:hideAllLayer()
        if self.clubLayer_ == nil then
            self.clubLayer_ = bole:getUIManage():createNewUI("ClubProfileLayer","club","app.views.club",nil,false)
            self.node_layer:addChild(self.clubLayer_)
        end
        self.clubLayer_:setVisible(true)
        self.clubLayer_:setAllBtnTouch(false)
        self.clubLayer_:enterClubLayer()
        if layerStr == "club_member" then
            self.clubLayer_:showMemberLayer()
        elseif layerStr == "club_request" then
            self.clubLayer_:showRequestLayer()
        end
        bole:getClubManage():getClubInfo("openClub")
    else
        bole:getUIManage():openNewUI("ClubJoinLayer",true,"club","app.views.club")
    end
end

function LobbyScene:showLotteryLayer()
    self:hideAllLayer()
    if self.lotteryLayer_ == nil then
        self.lotteryLayer_ = bole:getUIManage():createNewUI("LotteryLayer","lottery","app.views.lottery",nil,false)
        self.node_layer:addChild(self.lotteryLayer_)
    end
    self.lotteryLayer_:setVisible(true)
    bole.socket:send("enter_lottery", { }, true)
end

function LobbyScene:showSlotLayer()
    self:hideAllLayer()
    self.bottom:setVisible(true)
    self.node_collect:setVisible(true)
    if self.slotLayer_ == nil then
        self.slotLayer_ = bole:getUIManage():getSimpleLayer("SlotsLobbyScene", false)
        self.node_layer:addChild(self.slotLayer_)
    end
    self.slotLayer_:setVisible(true)
end

function LobbyScene:showOptionsLayer()
    if self.clubLayer_ ~= nil and self.clubLayer_:isVisible() then
        if tonumber(bole:getUserDataByKey("club")) == 0 then
            self:showLobbyScene()
        else
            -- 公会设置
            bole:getUIManage():openNewUI("Options",true,"options","app.views")
            bole:postEvent("initOptions", 3)
        end
    else
        -- 大厅设置
        bole:getUIManage():openNewUI("Options",true,"options","app.views")
        bole:postEvent("initOptions", 2)
    end
end

function LobbyScene:showFriendLayer(layerStr)
    local view = bole:getUIManage():openNewUI("FriendLayer",true,"friend","app.views.friend")
    if layerStr =="friend_request" then
        view:showRequestView()
    end
end


function LobbyScene:openClubLayer(data)
    self:showLobbyScene()
    bole:postEvent("closeFriendLayer")
    bole:postEvent("closeInformationView")
    bole:postEvent("closeClubCreateLayer")
    bole:postEvent("closeClubInfoLayer")
    bole:postEvent("closeClubJoinLayer")
    data = data.result
    if data == nil then
        self:showClubLayer()
        return
    end
    self:hideAllLayer()
    if self.clubLayer_ == nil then
        self.clubLayer_ = bole:getUIManage():createNewUI("ClubProfileLayer","club","app.views.club",nil,false)
        self.node_layer:addChild(self.clubLayer_)
    end
    self.clubLayer_:setVisible(true)
    self.clubLayer_:enterClubLayer()
    bole:postEvent("initClubInfo", data)
end

function LobbyScene:leave_club(t, data)
    bole:getClubManage():leaveClub()
    bole:postEvent("openClubLayer")
    cc.UserDefault:getInstance():deleteValueForKey("taskSchedule")
end

function LobbyScene:showRank(t, data)
    if t == bole.SERVER_LEAGUE_RANK then
        if data.error == 0 then
            bole:getUIManage():openLeagueView(data)
        else
            self:showClubLayer()
        end
    end
end

function LobbyScene:backLobbyScene(data)
    self:showLobbyScene()
end

return LobbyScene


-- endregion
