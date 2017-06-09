-- region *.lua
-- Date
-- 此文件由[BabeLua]插件自动生成
local LobbyScene = class("LobbyScene", cc.load("mvc").ViewBase)
function LobbyScene:onCreate()
    print("LobbyScene-onCreate")
    local root = self:getCsbNode():getChildByName("root")

    --    local node=bole:getEntity("app.command.GradientText"):create()
    --    node:setPosition(cc.p(500,300))
    --    root:addChild(node,10)

    --    local title=bole:getEntity("app.command.ShowFont"):create()
    --    self:addChild(title,1)

    self.bottom = root:getChildByName("bottom")
    self.node_collect = root:getChildByName("node_collect")
    local collect_data=bole:getUserDataByKey("lobby_bonus")
    local collect=bole:getEntity("app.views.lobby.LobbyCollect",collect_data)
    self.node_collect:addChild(collect)
    self.scroll = root:getChildByName("scroll")
    self.scroll_root = self.scroll:getChildByName("scroll_root")


    self.node_layer = root:getChildByName("node_layer")
    self.node_layer:setVisible(true)

    local center = self.scroll_root:getChildByName("center")
    self.txt_num = ccui.Helper:seekWidgetByName(center, "txt_num")
    self:updateNum(math.random(1000, 99999))
    local btn_slots = ccui.Helper:seekWidgetByName(self.scroll_root, "btn_slots")
    btn_slots:addTouchEventListener(handler(self, self.touchEvent))

    local btn_club = ccui.Helper:seekWidgetByName(self.scroll_root, "btn_club")
    btn_club:addTouchEventListener(handler(self, self.touchEvent))

    local btn_sales = ccui.Helper:seekWidgetByName(center, "btn_sales")
    btn_sales:addTouchEventListener(handler(self, self.touchEvent))

    self.scroll:setInnerContainerSize( { width = 2001, height = 537 })
    self.scroll_root:setPositionX(0)
    self.scroll_len = 0
    self:resetPos()
    self.isReload = 0
    self.scroll:addEventListener(handler(self, self.ScrollViewEvent))
    self.list_friend = self.scroll_root:getChildByName("list_friend")
    bole.recommend_index = 1
    for i = 1, 6 do
        local data = bole.recommend_users[bole.recommend_index]
        bole.recommend_index = bole.recommend_index + 1
        local head = bole:getNewHeadView(data)
        head:updatePos(head.POS_NONE)
        head:setSwallow(false)
        head:setPosition(cc.p(305 - 165 * math.floor((i - 1) / 3) - self.scroll_len * 330, 380 - 156 *((i - 1) % 3)))
        self.list_friend:addChild(head)
    end
    self.scroll:setScrollBarOpacity(0)
    self:initBottom(root)
    self:initTop(root)
    self:slotUI()
    bole:getNoticeCenter():open()
    -- self:openSkeletonAnimation(root)
end
function LobbyScene:onEnter()
    bole:addListener("nameChanged", self.eventName, self, nil, true)
    bole:addListener("openClubLayer", self.openClubLayer, self, nil, true)
    bole:addListener("backLobbyScene", self.backLobbyScene, self, nil, true)
    bole:addListener("diamondChanged", self.diamondChanged, self, nil, true)

    bole.socket:registerCmd("leave_club", self.leave_club, self)
    bole.socket:registerCmd("enter_club_lobby", self.reClub, self)
    bole.socket:registerCmd("out_of_club", self.out_of_club, self)
    bole.socket:registerCmd("club_application_result", self.club_application_result, self)
    bole.socket:registerCmd(bole.SERVER_LEAGUE_RANK, self.showRank, self)
end

function LobbyScene:onExit()
    bole:getEventCenter():removeEventWithTarget("nameChanged", self)
    bole:getEventCenter():removeEventWithTarget("openClubLayer", self)
    bole:getEventCenter():removeEventWithTarget("backLobbyScene", self)
    bole:getEventCenter():removeEventWithTarget("diamondChanged", self)

    bole.socket:unregisterCmd("leave_club")
    bole.socket:unregisterCmd("enter_club_lobby")
    bole.socket:unregisterCmd("out_of_club")
    bole.socket:unregisterCmd("club_application_result")
    bole.socket:unregisterCmd(bole.SERVER_LEAGUE_RANK)
end
function LobbyScene:eventName(event)
    self.txt_name:setString(bole:getUserDataByKey("name"))
end
function LobbyScene:updateNum(num)
    self.txt_num:setString(bole:formatCoins(num, 4))
end

function LobbyScene:openSkeletonAnimation(node)
    local skeletonNode = sp.SkeletonAnimation:create("game_farm_act/bailuobo.json", "game_farm_act/bailuobo.atlas")
    skeletonNode:setScale(0.5)

    skeletonNode:registerSpineEventHandler( function(event)
        print(string.format("[spine] %d start: %s",
        event.trackIndex,
        event.animation))
    end , sp.EventType.ANIMATION_START)

    skeletonNode:registerSpineEventHandler( function(event)
        print(string.format("[spine] %d end:",
        event.trackIndex))
    end , sp.EventType.ANIMATION_END)

    skeletonNode:registerSpineEventHandler( function(event)
        print(string.format("[spine] %d complete: %d",
        event.trackIndex,
        event.loopCount))
    end , sp.EventType.ANIMATION_COMPLETE)

    skeletonNode:registerSpineEventHandler( function(event)
        print(string.format("[spine] %d event: %s, %d, %f, %s",
        event.trackIndex,
        event.eventData.name,
        event.eventData.intValue,
        event.eventData.floatValue,
        event.eventData.stringValue))
    end , sp.EventType.ANIMATION_EVENT)



    performWithDelay(skeletonNode, function()
        skeletonNode:setAnimation(0, "animation", false)
        -- skeletonNode:addAnimation(0, "animation2", false, 2)
        -- skeletonNode:removeFromParent()
    end , 2.5)
    local windowSize = cc.Director:getInstance():getWinSize()
    -- skeletonNode:setColor({ r = 50, g = 50, b = 50 })
    skeletonNode:setPosition(cc.p(windowSize.width / 2, windowSize.height / 2))
    --    local txtbg=skeletonNode:findBone("di")
    --    local txt=cc.Label:createWithSystemFont("12345677777","Aril",50)
    --    txtbg:addChild(txt)
    if node then
        node:addChild(skeletonNode)
    else
        bole:getSpinApp():addMiniGame(skeletonNode)
    end
    skeletonNode:runAction(cc.FadeOut:create(2))
    skeletonNode:runAction(cc.FadeOut:create(2))
end


function LobbyScene:initBottom(root)
    local bottom = root:getChildByName("bottom")
    self.btn_friends = bottom:getChildByName("btn_friends")
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
    self.btn_menu = top:getChildByName("btn_menu")
    self.txt_name = top:getChildByName("txt_name")
    self.node_head = top:getChildByName("node_head")
    self.node_progress = top:getChildByName("node_progress")
    self.btn_menu:setTouchEnabled(true)
    self.btn_menu:addTouchEventListener(handler(self, self.touchEvent))

    local img_diamond = top:getChildByName("img_diamond")
    self.btn_buyDiamond = img_diamond:getChildByName("btn_buyDiamond")
    self.btn_buyDiamond:addTouchEventListener(handler(self, self.touchEvent))

    self.txt_name = top:getChildByName("txt_name")
    self.txt_diamond = img_diamond:getChildByName("txt_diamond")
    self.txt_name:setString(bole:getUserDataByKey("name"))
    self.txt_diamond:setString(bole:getUserDataByKey("diamond"))

    local node_coins = top:getChildByName("node_coins")
    local nCoins = bole:getNewCoinsView()
    node_coins:addChild(nCoins)
    local head = bole:getNewHeadView(bole:getUserData())
    head:updatePos(head.POS_LOBBY_SELF)
    self.node_head:addChild(head)

    local newExp = bole:getNewExpView()
    self.node_progress:addChild(newExp)

    self.btn_club_back = top:getChildByName("btn_club_back")
    self.btn_club_back:addTouchEventListener(handler(self, self.touchEvent))
    self.node_vip = top:getChildByName("node_vip")
    self.node_vip:addTouchEventListener(handler(self, self.touchEvent))
end



function LobbyScene:slotUI()
    self.slot = self.scroll_root:getChildByName("slot")
    local scorll_width = 0
    local indexs={2,5,6,7}
    for i = 1, 4 do
        local page = math.floor((i - 1) / 2)
        local index = math.floor((i - 1) % 2)
        local cell = bole:getEntity("app.views.lobby.LobbyCell",indexs[i])
        cell:setPosition(cc.p(160 + 270 * index, 360 - 230 * page))
        self.slot:addChild(cell)
    end
end

function LobbyScene:ScrollViewEvent(sender, eventType)
    if eventType == ccui.ScrollviewEventType.bounceLeft then
        local inner_pos = self.scroll:getInnerContainerPosition()
        if inner_pos.x > 310 then
            if bole.recommend_index <= bole.recommend_max-6 then
                self:requestLeft()
                self:reloadLeft(0)
            elseif bole.recommend_index <= bole.recommend_max then
                if bole.recommend_max%100<=3 then
                    self:requestLeft()
                    self:reloadLeft(0)
                else
                    self:requestLeft()
                    self:reloadLeft(-160)
                end
            end
        end
    end
end
function LobbyScene:requestLeft()
    if self.isReload == 0 then
        self.isReload = 1
    end
end

function LobbyScene:addItem()
    for i = 1, 6 do
        local data = bole.recommend_users[bole.recommend_index]
        bole.recommend_index = bole.recommend_index + 1
        local head = bole:getNewHeadView(data)
        head:updatePos(head.POS_NONE)
        head:setPosition(cc.p(305 - 165 * math.floor((i - 1) / 3) - self.scroll_len * 330, 380 - 156 *((i - 1) % 3)))
        self.list_friend:addChild(head)
        head:setSwallow(false)
        head:setScale(0.1)
        head:setVisible(false)
        performWithDelay(self, function()
            head:setVisible(true)
            head:runAction(cc.ScaleTo:create(0.5, 1.0))
        end ,
        math.floor((i - 1) / 3) * 0.5)
        if bole.recommend_index > bole.recommend_max then
            return
        end
    end
end

function LobbyScene:reloadLeft(offx)
    if self.isReload ~= 1 then return end
    self.isReload = 2
    self.scroll_len = self.scroll_len + 1
    self.scroll:setInnerContainerSize( { width = 2001 + self.scroll_len * 330 - 100+offx, height = 537 })
    self.scroll_root:setPositionX(self.scroll_len * 330 - 100+offx)
    self:addItem()
    performWithDelay(self, function()
        self.isReload = 0
    end , 1)
end

function LobbyScene:resetPos()
    local inner_pos = self.scroll:getInnerContainerPosition()
    self.scroll:setInnerContainerPosition(cc.p(- self.scroll_len * 330 - 240, inner_pos.y))
end

function LobbyScene:touchEvent(sender, eventType)
    local name = sender:getName()
    local tag = sender:getTag()
    print("touchEvent:" .. name)
    if eventType == ccui.TouchEventType.began then
        print("Touch Down")
        sender:setScale(1.05)
        if name == "friends" then
            self.btn_friends:setScale(1.05)
        elseif name == "myClub" then
            self.btn_myClub:setScale(1.05)
        elseif name == "lottery" then
            self.btn_lottery:setScale(1.05)
        elseif name == "shop" then
            self.btn_shop:setScale(1.05)
        end
    elseif eventType == ccui.TouchEventType.moved then
        print("Touch Move")
    elseif eventType == ccui.TouchEventType.ended then
        print("Touch Up")
        sender:setScale(1)
        if name == "btn_club" then
           bole.socket:send(bole.SERVER_LEAGUE_RANK,{},true)
        elseif name == "btn_slots" then
            bole:getAppManage():enterLobby()
        elseif name == "btn_sales" then
            bole:getUIManage():openUI("SaleLayer",true,"csb/shop")
        elseif name == "friends" then
            bole:getUIManage():openUI("FriendLayer",true)
        elseif name == "myClub" then
            self:showClubLayer()
        elseif name == "lottery" then
            self:showLotteryLayer()
        elseif name == "shop" then
            bole:getUIManage():openUI("ShopLayer",true,"csb/shop")
        elseif name == "btn_menu" then
            self:showOptionsLayer()
        elseif name == "btn_club_back" then
            self:showLobbyScene()
        elseif name == "node_vip" then
            bole:getUIManage():openUI("VipLayer",true)
        end

    elseif eventType == ccui.TouchEventType.canceled then
        print("Touch Cancelled")
        sender:setScale(1)
    end
end

function LobbyScene:showLobbyScene()
    self.bottom:setVisible(true)
    self.node_collect:setVisible(true)
    self.scroll:setVisible(true)
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
end

function LobbyScene:hideAllLayer()
    self.bottom:setVisible(false)
    self.node_collect:setVisible(false)
    self.scroll:setVisible(false)
    self.btn_club_back:setVisible(true)
    self.node_vip:setVisible(false)
    if self.lotteryLayer_ ~= nil then
        self.lotteryLayer_:setVisible(false)
    end
    if self.clubLayer_ ~= nil then
        self.clubLayer_:setVisible(false)
    end
end

function LobbyScene:showClubLayer()
    if tonumber(bole:getUserDataByKey("club")) ~= 0 then
        self:hideAllLayer()
        if self.clubLayer_ == nil then
            self.clubLayer_=bole:getUIManage():getSimpleLayer(bole.UI_NAME.ClubProfileLayer,false,"csb/club")
            self.node_layer:addChild(self.clubLayer_)
        end
        self.clubLayer_:setVisible(true)
        self.clubLayer_:enterClubLayer()
    else
        bole:getUIManage():openUI("ClubJoinLayer", true, "csb/club")
    end
    bole.socket:send("enter_club_lobby", { }, true)
end


function LobbyScene:showLotteryLayer()
    self:hideAllLayer()
    if self.lotteryLayer_ == nil then
        self.lotteryLayer_ = bole:getUIManage():getSimpleLayer("LotteryLayer",false,"csb/lottery")
        self.node_layer:addChild(self.lotteryLayer_)
    end
    self.lotteryLayer_:setVisible(true)
    bole.socket:send("enter_lottery", { }, true)
end

function LobbyScene:showOptionsLayer()
    if self.clubLayer_ ~= nil and self.clubLayer_:isVisible() then
        if tonumber(bole:getUserDataByKey("club")) == 0 then
            self:showLobbyScene()
        else --公会设置
            bole:getUIManage():openUI("Options", true)
            bole:postEvent("initOptions", 3)
        end
    else --大厅设置
        bole:getUIManage():openUI("Options", true)
        bole:postEvent("initOptions", 2)
    end
end

function LobbyScene:openClubLayer(data)
    data = data.result
    self:hideAllLayer()
    if self.clubLayer_ == nil then
        self.clubLayer_ = bole:getUIManage():getSimpleLayer(bole.UI_NAME.ClubProfileLayer, false, "csb/club")
        self.node_layer:addChild(self.clubLayer_)
    end
    self.clubLayer_:setVisible(true)
    self.clubLayer_:enterClubLayer()
    bole:setUserDataByKey("club",1)
    bole:postEvent("initClubInfo", data)
end

function LobbyScene:reClub(t, data)
    if t == "enter_club_lobby" then
        if data.in_club == 0 then
            --未加入联盟
            
        elseif data.in_club == 1 then
            --已加入联盟
            bole:postEvent("initClubInfo", data.club_info)
        end
    end
end


function LobbyScene:club_application_result(t,data)
    if t == "club_application_result" then
        bole:setUserDataByKey("club",1)
    end
end

function LobbyScene:leave_club(t,data)
    if t == "leave_club" then
        self:showLobbyScene()
        bole:setUserDataByKey("club",0)
        cc.UserDefault:getInstance():deleteValueForKey("taskSchedule")
    end
end

function LobbyScene:out_of_club(t,data) 
    if t == "out_of_club" then
        bole:setUserDataByKey("club",0)
    end
end

function LobbyScene:showRank(t,data)
    if t == bole.SERVER_LEAGUE_RANK then
        if data.error==0 then
            bole:getUIManage():openLeagueView(data)
        else
            self:showClubLayer()
        end
    end
end

function LobbyScene:backLobbyScene(data)
    self:showLobbyScene()
end

function LobbyScene:diamondChanged(data)
    data = data.result.result
    self.txt_diamond:setString(data)
end

return LobbyScene


-- endregion
