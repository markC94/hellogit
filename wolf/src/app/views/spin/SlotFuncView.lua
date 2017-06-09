--region *.lua
--Date
--此文件由[BabeLua]插件自动生成

local SlotFuncView = class("SlotFuncView", cc.Node)

SlotFuncView.btnName_1 = {"Invite", "Connect", "Gift", "Like", "Profile"}
SlotFuncView.btnName_2 = {"Connect", "Gift", "Like", "Profile"}
SlotFuncView.btnName_3 = {"Invite", "Gift", "Like", "Profile"}
SlotFuncView.btnName_4 = {"Gift", "Like", "Profile"}

function SlotFuncView:ctor(parent, theme)
    self:onEnter()

    self.parent_ = parent
    self.theme_ = theme

    self.touchLayer_ = ccui.Layout:create()
    self.touchLayer_:setAnchorPoint(0.5,0.5)
    self.touchLayer_:setTouchEnabled(true)
    --self.touchLayer_:setBackGroundColorType(1)
    self.touchLayer_:setBackGroundColor({r = 100, g = 100, b = 0})
    self.touchLayer_:setBackGroundColorOpacity(102)
    self.touchLayer_:addTouchEventListener(handler(self, self.touchLayerEvent))
    self:addChild(self.touchLayer_)

    
    self.bg_ = ccui.Layout:create()
    self.bg_:setTouchEnabled(true)
    self.bg_:setBackGroundColorType(1)
    self.bg_:setBackGroundColor({r = 0, g = 0, b = 0})
    self.bg_:setBackGroundColorOpacity(102)
    self.bg_:setAnchorPoint(0,0.5)
    self.bg_:setContentSize(200,300)

    
    local bg = ccui.ImageView:create()
    bg:loadTexture("res/giftshop/bg1.png",0)
    bg:setScale9Enabled(true)
    --bg:setFlippedX(true)
    bg:setCapInsets({x = 83, y = 170, width = 88, height = 94})
    bg:setLayoutComponentEnabled(true)
    bg:setName("bg")
    bg:setTag(6)
    bg:setCascadeColorEnabled(true)
    bg:setCascadeOpacityEnabled(true)
    bg:setAnchorPoint(0,0)
    bg:setPosition(- 40, - 20)
    bg:setContentSize(254,330)
    self.bg_:addChild(bg)
    
    local btnPanel = ccui.Layout:create()
    btnPanel:setContentSize(10,10)
    btnPanel:setAnchorPoint(0,0)
    btnPanel:setPosition(0, 0)
    btnPanel:setName("btnPanel")
    self.bg_:addChild(btnPanel)

    self.touchLayer_:addChild(self.bg_)
    self:adaptScreen()
    self:setVisible(false)
end

function SlotFuncView:openSlotFuncView(sender,headView,roomData)
    self:setVisible(true)

    self.sender_ = sender
    self.headView_ = headView
    self.playerInfo_ = headView.info
    self.clubTitle_ = 0
    if roomData ~= nil then
        self.clubTitle_ = roomData.club_title
    end
    local pos = sender:convertToWorldSpace(cc.p(0,0))
    self.bg_:setPosition(pos.x + 110 ,pos.y)
    if pos.x >= 900 then
       self.bg_:setAnchorPoint(1,0.5) 
       self.bg_:setPosition(pos.x ,pos.y)

       self.bg_:getChildByName("bg"):setFlippedX(true)
       bg:setPosition(244, - 20)
    end
    self:createFuncBtn()
    self.bg_:stopAllActions()
    self.bg_:setScale(0.1)
    self.bg_:runAction(cc.ScaleTo:create(0.2,1,1))

end

function SlotFuncView:onEnter()
    bole:addListener("closeSlotFuncUI", self.closeSlotFuncUI, self, nil, true)
    bole:addListener("likeToPlayer", self.likeToPlayer, self, nil, true)
    bole:addListener("showInfoInSlot", self.showInfoInSlot, self, nil, true)

    bole.socket:registerCmd("apply_for_friend", self.reApplyFriend, self, true)
    bole.socket:registerCmd("send_club_invitation", self.reInvitationClub, self, true)
    bole.socket:registerCmd("give", self.reGive, self, true)
    bole.socket:registerCmd("like", self.reLike, self, true)
end

function SlotFuncView:touchLayerEvent(sender, eventType)
    if eventType == ccui.TouchEventType.ended then
        self:closeSlotFuncUI()
    end
end

function SlotFuncView:createFuncBtn()
    local showTable = self.btnName_1
    local userFriendList = bole:getUserDataByKey("user_friends")

    local isFriend = 0
    for k ,v in pairs(userFriendList) do
        if v == self.playerInfo_.user_id then
            isFriend = 1
        end
    end

    if self.clubTitle_ == 1  then
        if isFriend == 0 then
            showTable = self.btnName_1
        elseif isFriend == 1 then
            showTable = self.btnName_3
        end
    else
        if isFriend == 0 then
            showTable = self.btnName_2
        elseif isFriend == 1 then
            showTable = self.btnName_4
        end
    end

    self.bg_:getChildByName("btnPanel"):removeAllChildren()
    for i = 1, # showTable do
        local btn = self:createBtn(showTable[i])
        self.bg_:getChildByName("btnPanel"):addChild(btn)
        btn:setPosition(100,30 + (i - 1) * 60)
    end
    self.bg_:setContentSize(200,# showTable * 60)
    self.bg_:getChildByName("bg"):setContentSize(254,# showTable * 60 + 30)
end

function SlotFuncView:createBtn(name)
    local btn = ccui.Button:create()
    btn:ignoreContentAdaptWithSize(false)
    btn:loadTextureNormal("res/club/button_profile.png",0)
    btn:loadTexturePressed("res/club/button_profile.png",0)
    btn:loadTextureDisabled("res/club/button_profile.png",0)
    btn:setScale9Enabled(true)
    btn:setCapInsets({x = 15, y = 11, width = 160, height = 32})
    btn:setName(name)
    btn:setAnchorPoint(0.5,0.5)
    btn:addTouchEventListener(handler(self, self.touchEvent))

    local iocn = cc.Sprite:create("res/giftshop/g_" .. name .. ".png")
    iocn:setName("iocn")
    iocn:setCascadeColorEnabled(true)
    iocn:setCascadeOpacityEnabled(true)
    iocn:setPosition(42.7420, 27.6042)
    btn:addChild(iocn)

    local text = ccui.Text:create()
    text:ignoreContentAdaptWithSize(true)
    text:setTextAreaSize({width = 0, height = 0})
    text:setFontName("res/font/FZKTJW.TTF")
    text:setFontSize(20)
    text:setString(name)
    text:setLayoutComponentEnabled(true)
    text:setName("text")
    text:setTag(5)
    text:setCascadeColorEnabled(true)
    text:setCascadeOpacityEnabled(true)
    text:setPosition(127.3352, 28.4945)
    btn:addChild(text)

    if name == "Like" then
        self:createRunTime(btn) 
        if self.likeToPlayer_ ~= nil then       
            if self.likeToPlayer_ == self.playerInfo_.user_id then
                btn:setTouchEnabled(false)
            end
        end
    end


    return btn
end

function SlotFuncView:createRunTime(btn)
        local likeToPlayerList = bole:getUserDataByKey("likeToPlayerList")
        if type(likeToPlayerList) == "table" then
            local time = likeToPlayerList[self.playerInfo_.user_id]
            if time ~= nil then
                local runTime = 3599 - ( os.time() - time)
                if runTime > 0 then
                    local s = math.floor(runTime) % 60
                    local m = math.floor(runTime / 60) % 60
                    btn:getChildByName("text"):setString(m .. "m " .. s .. "s")
                    btn:setTouchEnabled(false)
                    if self.scheduler == nil then
                        local function update(dt)
                            runTime = runTime - 1
                            local s = math.floor(runTime) % 60
                            local m = math.floor(runTime / 60) % 60
                            btn:getChildByName("text"):setString(m .. "m " .. s .. "s")
                            if runTime <= 0 then
                                btn:setTouchEnabled(true)
                                btn:getChildByName("text"):setString("Like")
                                cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.scheduler)
                            end
                        end
                        self.scheduler = cc.Director:getInstance():getScheduler():scheduleScriptFunc(update, 1, false)
                    end
                end
            end
        end
end

function SlotFuncView:touchEvent(sender, eventType)
    local name = sender:getName()
    if eventType == ccui.TouchEventType.began then
        sender:runAction(cc.ScaleTo:create(0.1, 1.05, 1.05))
    elseif eventType == ccui.TouchEventType.moved then

    elseif eventType == ccui.TouchEventType.ended then
            sender:runAction(cc.ScaleTo:create(0.1, 1, 1))
            if name == "Profile" then
                self:showInfoView()
            elseif name == "Like" then
                if sender.toId ~= nil then
                    local data = {}
                    data.result = sender.toId
                    self:likeToPlayer(data)
                    sender:setTouchEnabled(false)
                else
                    self:likeToPlayer()
                end
            elseif name == "Give" then
                self:giveCoins()
            elseif name == "Gift" then
                self:giveGift()
            elseif name == "Connect" then
                if sender.toId ~= nil then
                    self:connect(sender.toId)
                else
                    self:connect()
                end
            elseif name == "Invite" then
                self:inviteClub()
            elseif name == "giveBg" then
                self.theme_:createChatView()
            end
    elseif eventType == ccui.TouchEventType.canceled then
        sender:runAction(cc.ScaleTo:create(0.1, 1, 1))
    end
end

function SlotFuncView:showInfoView()
    bole:getUIManage():openInfoView(self.headView_)
    --local view = bole:getUIManage():getSimpleLayer(bole.UI_NAME.InformationView, true)
    --display.getRunningScene():addChild(view, 69)
    --view:showInfo(self.headView_)
end

function SlotFuncView:likeToPlayer(data)

    if data ~= nil then
        data = data.result
        bole.socket:send("like",{target_id = data},true) 
        self.likeToPlayer_ = data
        return
    end
    bole.socket:send("like",{target_id = self.playerInfo_.user_id},true) 
    self.likeToPlayer_ = self.playerInfo_.user_id
    self:closeSlotFuncUI()
end

function SlotFuncView:connect(data)
    local addFriendList = bole:getUserDataByKey("addFriend")
    local id = data or self.playerInfo_.user_id
    if addFriendList ~= 0 then
        for k ,v in pairs(addFriendList) do
            if v == id then
                 bole:popMsg({msg ="已经发送过邀请" , title = "Add Friend" })
                self:closeSlotFuncUI()
                return
            end
        end
    end
    bole.socket:send("apply_for_friend",{target_id = id},true) 
end

function SlotFuncView:inviteClub()
    local inviteClubList = bole:getUserDataByKey("inviteClub")
    if inviteClubList ~= 0 then
        for k ,v in pairs(inviteClubList) do
            if v == self.playerInfo_.user_id then
                bole:popMsg({msg ="已经发送过邀请" , title = "Invite Club" })
                self:closeSlotFuncUI()
                return
            end
        end
    end
    bole.socket:send("send_club_invitation",{target_uid = self.playerInfo_.user_id},true) 
end

function SlotFuncView:reInvitationClub(t,data)
    if data.success == 1 then
        bole:getUIManage():openClubTipsView(18,nil)
        local inviteClubList = bole:getUserDataByKey("inviteClub")
        if inviteClubList == 0 then
            inviteClubList = {}
        end
        table.insert(inviteClubList , #inviteClubList + 1, self.playerInfo_.user_id)
        bole:setUserDataByKey("inviteClub",inviteClubList)
    else
        bole:getUIManage():openClubTipsView(19,nil)
    end
    self:closeSlotFuncUI()
end

function SlotFuncView:reApplyFriend(t,data)
    local addFriendList = bole:getUserDataByKey("addFriend")
    if addFriendList == 0 then
        addFriendList = {}
    end
    table.insert(addFriendList , #addFriendList + 1, data.new_friend.user_id)
    bole:setUserDataByKey("addFriend",addFriendList)

    local userFriendList = bole:getUserDataByKey("user_friends")
    table.insert(userFriendList, # userFriendList + 1, tonumber(data.new_friend.user_id))
    bole:setUserDataByKey("user_friends", userFriendList)

    bole:popMsg({msg ="add friend successfully", title = "add friend" })

    self:closeSlotFuncUI()
end

function SlotFuncView:giveGift()
    bole:getUIManage():openUI("GiftLayer",true)

    --local view = bole:getUIManage():getSimpleLayer("GiftLayer", true)
    --display.getRunningScene():addChild(view, 69)

    bole:postEvent("initGiftLayer",self.playerInfo_.user_id)
end

function SlotFuncView:reGive(t,data)
    if t == "give" then
        if data.give_id ~= nil then
            bole:postEvent("closeGiftLayer",data)
            bole:postEvent("chat_giveGift",data)
            self:closeSlotFuncUI()
            --self:showGiveAction(data)
        elseif data.error == 6 then
            bole:getUIManage():openClubTipsView(16,nil)
        end
    end
end

function SlotFuncView:reLike(t,data)
    if t == "like" then
        if data.sender ~= nil then
            bole:postEvent("chat_like",data)
            if data.sender == bole:getUserDataByKey("user_id") then
                local likeToPlayerList = bole:getUserDataByKey("likeToPlayerList")
                if likeToPlayerList == 0 then
                    likeToPlayerList = {}
                end
                likeToPlayerList[data.target_id] = os.time()
                bole:setUserDataByKey("likeToPlayerList",likeToPlayerList)
                if self.likeToPlayer_ ~= nil and self:isVisible() then       
                    if self.likeToPlayer_ == self.playerInfo_.user_id then
                        self:createRunTime(self.bg_:getChildByName("btnPanel"):getChildByName("Like"))
                    end
                end
                self.likeToPlayer_ = nil
            end
        end
    end
end


function SlotFuncView:showGiveAction(data)
    local winSize = cc.Director:getInstance():getWinSize()
    local id = bole:getUserDataByKey("user_id")
    local targerList = data.target_id
    local userPos = cc.p(120, winSize.height - 60)
    local startPos = cc.p(120, winSize.height - 60)
    if data.sender == id then
        startPos = cc.p(120, winSize.height - 60)
    else
        self:showGiveInfo(data.sender)
    end
    --[[
    for i = 1, #targerList do
        for k, v in pairs(self.parent_.headNodes) do
            if v.head.info.user_id == targerList[i] then
                local iconPath = "res/giftshop/drink" .. data.give_id .. ".png"
                if data.give_type == 1 then
                    iconPath = "res/giftshop/coin" .. data.give_id .. ".png"
                    local add = bole:getConfigCenter():getConfig("givecoins", data.give_id, "givecoins_amount")
                    local speed = bole:getConfigCenter():getConfig("givecoins", data.give_id, "givecoins_spenddiamond")
                    v.head.txt_money:setString(bole:formatCoins(v.head.info.coins + add, 5))
                    bole:changeUserDataByKey("diamond", - speed)
                elseif data.give_type == 2 then
                    iconPath = "res/giftshop/drink" .. data.give_id .. ".png"
                    local speed = bole:getConfigCenter():getConfig("buydrinks", data.give_id, "drinks_spend")
                    bole:changeUserDataByKey("coins", - speed)
                end
                local sprite = cc.Sprite:create(iconPath)
                v.node:addChild(sprite)
                local delay = cc.DelayTime:create(2)
                local hide = cc.CallFunc:create( function() sprite:removeFromParent() end)
                sprite:runAction(cc.Sequence:create(delay, hide))
            end
        end
        if targerList[i] == id then
             local iconPath = "res/giftshop/drink" .. data.give_id .. ".png"
            if data.give_type == 1 then
                    iconPath = "res/giftshop/coin" .. data.give_id .. ".png"
                    local speed = bole:getConfigCenter():getConfig("givecoins", data.give_id, "givecoins_spenddiamond")
                    local add = bole:getConfigCenter():getConfig("givecoins", data.give_id, "givecoins_amount")
                    bole:changeUserDataByKey("coins", add)
                    bole:changeUserDataByKey("diamond", - speed)
                elseif data.give_type == 2 then
                    iconPath = "res/giftshop/drink" .. data.give_id .. ".png"
                    local speed = bole:getConfigCenter():getConfig("buydrinks", data.give_id, "drinks_spend")
                    bole:changeUserDataByKey("coins", - speed)
                end
            local sprite = cc.Sprite:create(iconPath)
            self.parent_.rootNode:addChild(sprite)
            sprite:setPosition(userPos.x, userPos.y)
            local delay = cc.DelayTime:create(2)
            local hide = cc.CallFunc:create( function() sprite:removeFromParent() end)
            sprite:runAction(cc.Sequence:create(delay, hide))
        end
    end
    --]]
end

function SlotFuncView:showGiveInfo(id)
    for k, v in pairs(self.parent_.headNodes) do
         if v.head.info.user_id == id then
                local infoView = self:createGiveInfo(id,str)
                v.node:addChild(infoView)
                infoView:setPosition(0, - 30)
                local delay = cc.DelayTime:create(4)
                local hide = cc.CallFunc:create( function() infoView:removeFromParent() end)
                infoView:runAction(cc.Sequence:create(delay, hide))
         end
    end
end


function SlotFuncView:showInfoInSlot(data)
    if self.theme_.chatView_ ~= nil then
        if self.theme_.chatView_:isVisible() then
            return
        end
    end
    data = data.result
    for k, v in pairs(self.parent_.headNodes) do
         if v.head.info.user_id == data.id then
             if v.node.infoView ~= nil then
                v.node.infoView:removeFromParent()
                v.node.infoView = nil
             end
                local infoView = self:createSlotInfo(data)
                v.node:addChild(infoView)
                v.node.infoView = infoView
                infoView:setPosition(0, - 30)
                local delay = cc.DelayTime:create(4)
                local hide = cc.CallFunc:create( function() infoView:removeFromParent() 
                                                            v.node.infoView = nil 
                                                            end)
                infoView:runAction(cc.Sequence:create(delay, hide))
         end
    end
end


function SlotFuncView:createSlotInfo(data)
    local id = data.id
    local userFriendList = bole:getUserDataByKey("user_friends")
    local isFriend = 0
    for k ,v in pairs(userFriendList) do
        if v == id then
            isFriend = 1
        end
    end

    local giveBg = ccui.ImageView:create()
    giveBg:ignoreContentAdaptWithSize(false)
    giveBg:loadTexture("res/giftshop/prompt_bg02.png",0)
    giveBg:setTouchEnabled(true)
    giveBg:setName("giveBg")
    giveBg:setAnchorPoint(0.25,1)
    giveBg:addTouchEventListener(handler(self, self.touchEvent))


    if string.len(data.msg) > 40 then
        data.msg = string.sub(data.msg,1,40) .. "..."
    end
    local txt = cc.Label:createWithTTF(data.msg, "res/font/FZKTJW.TTF", 20)
    txt:setDimensions(150,0)
    txt:setAnchorPoint(0,1)
    txt:setPosition(10,60)
    giveBg:addChild(txt)

    if data.type ~= "chat" then
        local likeToPlayerList = bole:getUserDataByKey("likeToPlayerList")
        local isBtn = true
        if type(likeToPlayerList) == "table" then
            if likeToPlayerList[data.id] ~= nil then
                isBtn = false
            end
        end

        if isBtn then
            local btn = ccui.Button:create()
            if isFriend == 0 then
                btn:loadTextures("res/giftshop/prompt_connect.png", "res/giftshop/prompt_connect.png", "res/giftshop/prompt_connect.png")
                btn:setName("Connect")
                btn.toId = data.id
            elseif isFriend == 1 then
                btn:loadTextures("res/giftshop/prompt_like.png", "res/giftshop/prompt_like.png", "res/giftshop/prompt_like.png")
                btn:setName("Like")
                btn.toId = data.id
            end
            txt:setDimensions(130,0)
            btn:addTouchEventListener(handler(self, self.touchEvent))
            btn:setPosition(170, 35)
            giveBg:addChild(btn)
        end
    end

    return giveBg
end



function SlotFuncView:closeSlotFuncUI(data)
    if self.scheduler then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.scheduler)
    end

    self.scheduler = nil
    self:setVisible(false)
end

function SlotFuncView:onExit()
    bole:removeListener("likeToPlayer", self)
    bole:removeListener("closeSlotFuncUI", self)
    bole:removeListener("showInfoInSlot", self)

    bole.socket:unregisterCmd("apply_for_friend")
    bole.socket:unregisterCmd("send_club_invitation")
    bole.socket:unregisterCmd("give")
    if self.scheduler then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.scheduler)
    end

    self.scheduler = nil
    self:removeFromParent()
end


function SlotFuncView:adaptScreen()
    local winSize = cc.Director:getInstance():getWinSize()
    self.touchLayer_:setContentSize(winSize)
    self.touchLayer_:setPosition(winSize.width / 2, winSize.height / 2)
end


return SlotFuncView

--endregion
