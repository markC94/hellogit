-- region *.lua
-- Date
-- 此文件由[BabeLua]插件自动生成

local SlotFuncView = class("SlotFuncView", cc.Node)

SlotFuncView.btnName_1 = { "Invite", "connect", "gift", "like", "profile" }
SlotFuncView.btnName_2 = { "connect", "gift", "like", "profile" }
SlotFuncView.btnName_2_pos = { cc.p(64, - 100), cc.p(115, - 40), cc.p(115, 40), cc.p(64, 100) }
SlotFuncView.btnName_3 = { "Invite", "gift", "like", "profile" }
SlotFuncView.btnName_4 = { "gift", "like", "profile" }
SlotFuncView.btnName_4_pos = { cc.p(80, - 70), cc.p(115, 0), cc.p(80, 70) }


local headRLenX = 55
local headRLenY = 40

function SlotFuncView:ctor(parent, theme)
    self:onEnter()

    self.parent_ = parent
    self.theme_ = theme

    self.touchLayer_ = ccui.Layout:create()
    self.touchLayer_:setAnchorPoint(0.5, 0.5)
    self.touchLayer_:setTouchEnabled(true)
    -- self.touchLayer_:setBackGroundColorType(1)
    self.touchLayer_:setBackGroundColor( { r = 6, g = 27, b = 46 })
    self.touchLayer_:setBackGroundColorOpacity(204)
    self.touchLayer_:addTouchEventListener(handler(self, self.touchLayerEvent))
    self:addChild(self.touchLayer_, 10)


    self.actIconLayer_ = { }
    for k, v in pairs(self.parent_.headNodes) do
        if v.head.info.user_id ~= nil then
            local actPanel = ccui.Layout:create()
            actPanel:setPosition(0, 0)
            self:addChild(actPanel, 5)
            self.actIconLayer_[v.head.info.user_id] = actPanel
        end
    end

    local actPanel = ccui.Layout:create()
    actPanel:setPosition(0, 0)
    self:addChild(actPanel, 5)
    self.actIconLayer_[bole:getUserDataByKey("user_id")] = actPanel

    self.btnPanel_ = ccui.Layout:create()
    -- self.btnPanel_:setTouchEnabled(true)
    self.btnPanel_:setAnchorPoint(0, 0)
    self.btnPanel_:setContentSize(200, 300)
    bole:autoOpacityC(self.btnPanel_)

    self.touchLayer_:addChild(self.btnPanel_)
    self:adaptScreen()
    self:setVisible(false)

    -- bole:getUIManage():flyCoin(cc.p(300,500),cc.p(1000,700),nil,5)
    -- self:saleActTest()
end

function SlotFuncView:openSlotFuncView(sender, headView)
    bole.socket:registerCmd("apply_for_friend", self.reApplyFriend, self, true)
    self:setVisible(true)
    self.btnPanel_:setVisible(true)
    self.btnPanel_:setOpacity(255)
    self.sender_ = sender
    self.headView_ = headView
    self.playerInfo_ = headView.info
    self.clubTitle_ = bole:getClubManage():getClubTitle() or 0
    local pos = sender:convertToWorldSpace(cc.p(0, 0))
    local size = sender:getContentSize()
    self.btnPanel_:setAnchorPoint(0, 0)
    self.btnPanel_:setPosition(pos.x + size.width / 2, pos.y + size.height / 2 - 15)
    local isRight = false
    if pos.x >= 900 then
        print(pos.x)
        self.btnPanel_:setAnchorPoint(1, 0)
        isRight = true
    end
    self:createFuncBtn(isRight)
    self.btnPanel_:stopAllActions()
    self.btnPanel_:setScale(0.01)
    self.btnPanel_:runAction(cc.Sequence:create(cc.ScaleTo:create(0.15, 1.3), cc.ScaleTo:create(0.05, 1)))

    self.touchLayer_:setTouchEnabled(true)
end

function SlotFuncView:onEnter()
    bole:addListener("closeSlotFuncUI", self.closeSlotFuncUI, self, nil, true)
    bole:addListener("likeToPlayer_chatView", self.likeToPlayer_chatView, self, nil, true)
    bole:addListener("addInfoInFuncView", self.showInfoInSlot, self, nil, true)
    bole:addListener("reLikeToPlayer", self.reLikeToPlayer, self, nil, true)
    bole:addListener("showSaleAct", self.saleActTest, self, nil, true)
    bole:addListener("showGiftAct", self.showGiftAct, self, nil, true)
    bole:addListener("showGiftActByOther", self.showGiftActByOther, self, nil, true)
    bole:addListener("showLikeAct", self.showLikeAct, self, nil, true)
    bole:addListener("showLikeActByOther", self.showLikeActByOther, self, nil, true)

    bole:addListener("saleTestAct", self.saleTestAct, self, nil, true)
    bole:addListener("userLeaveRoom", self.userLeaveRoom, self, nil, true)
    bole:addListener("userEnterRoom", self.userEnterRoom, self, nil, true)
    bole:addListener("openGiftLayer", self.openGiftLayer, self, nil, true)

    bole.socket:registerCmd("apply_for_friend", self.reApplyFriend, self, true)
    bole.socket:registerCmd("send_club_invitation", self.reInvitationClub, self, true)
end

function SlotFuncView:onExit()
    bole:removeListener("closeSlotFuncUI", self)
    bole:removeListener("likeToPlayer_chatView", self)
    bole:removeListener("addInfoInFuncView", self)
    bole:removeListener("reLikeToPlayer", self)
    bole:removeListener("showSaleAct", self)
    bole:removeListener("showGiftAct", self)
    bole:removeListener("showGiftActByOther", self)
    bole:removeListener("showLikeAct", self)
    bole:removeListener("showLikeActByOther", self)

    bole:removeListener("saleTestAct", self)
    bole:removeListener("userLeaveRoom", self)
    bole:removeListener("userEnterRoom", self)
    bole:removeListener("openGiftLayer", self)

    bole.socket:unregisterCmd("apply_for_friend")
    bole.socket:unregisterCmd("send_club_invitation")
    if self.scheduler then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.scheduler)
    end

    self.scheduler = nil
    self:removeFromParent()
end

function SlotFuncView:touchLayerEvent(sender, eventType)
    if eventType == ccui.TouchEventType.ended then
        self:closeSlotFuncUI()
    end
end

function SlotFuncView:createFuncBtn(isRight)
    local showTable = self.btnName_2
    local showTablePos = self.btnName_2_pos
    if bole:getFriendManage():isFriend(self.playerInfo_.user_id) then
        showTable = self.btnName_4
        showTablePos = self.btnName_4_pos
    end

    if self.scheduler then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.scheduler)
    end
    self.scheduler = nil
    self.btnPanel_:removeAllChildren()
    for i = 1, #showTable do
        local btnBg, btn = self:createBtn(showTable[i])
        self.btnPanel_:addChild(btnBg)
        self.btnPanel_:addChild(btn)
        btn:setPosition(showTablePos[i].x, showTablePos[i].y)
        btnBg:setPosition(showTablePos[i].x, showTablePos[i].y)
        if isRight then
            btn:setPositionX(195 - showTablePos[i].x)
            btnBg:setPositionX(195 - showTablePos[i].x)
        end
        if showTable[i] == "like" then
            self:createRunTime(btn)
            if self.likeToPlayer_ ~= nil then
                if self.likeToPlayer_ == self.playerInfo_.user_id then
                    btn:setTouchEnabled(false)
                end
            end
        end
    end

end

function SlotFuncView:createBtn(name)
    local btn = ccui.Button:create()
    local size = btn:getContentSize()
    btn:ignoreContentAdaptWithSize(false)
    local btnTexture = "inSlot_icon/" .. "inslots_hold_" .. name .. ".png"
    btn:loadTextureNormal(btnTexture, 0)
    btn:loadTexturePressed(btnTexture, 0)
    btn:loadTextureDisabled(btnTexture, 0)
    btn:setName(name)
    btn:setAnchorPoint(0.5, 0.5)
    btn:addTouchEventListener(handler(self, self.btnTouchEvent))

    local btnBg = ccui.ImageView:create("inSlot_icon/inslots_hold_frame.png")
    btnBg:setAnchorPoint(0.5, 0.5)
    btnBg:setPosition(size.width / 2, size.height / 2)
    btnBg:setTouchEnabled(true)

    return btnBg, btn
end

function SlotFuncView:btnTouchEvent(sender, eventType)
    local name = sender:getName()
    if eventType == ccui.TouchEventType.began then
        sender:runAction(cc.ScaleTo:create(0.25, 0.8))
    elseif eventType == ccui.TouchEventType.moved then

    elseif eventType == ccui.TouchEventType.ended then
        sender:runAction(cc.Sequence:create(cc.ScaleTo:create(0.1, 1), cc.CallFunc:create( function() 
            if name == "profile" then
                self:showInfoView()
            elseif name == "like" then
                bole.socket:send("like", { like_type = 1, target_id = self.playerInfo_.user_id }, true)
                self.likeToPlayer_ = self.playerInfo_.user_id
                self:showAct(bole:getUserDataByKey("user_id"), self.playerInfo_.user_id , "like",1)
            elseif name == "gift" then
                self:giveGift()
            elseif name == "connect" then
                if sender.toId ~= nil then
                    self:connect(sender.toId)
                else
                    self:connect()
                end
            end
        self:closeSlotFuncUI() end)))
    elseif eventType == ccui.TouchEventType.canceled then
        sender:runAction(cc.ScaleTo:create(0.1, 1))
    end
end

function SlotFuncView:createRunTime(btn)
    local likeToPlayerList = bole:getUserDataByKey("likeToPlayerList")
    if type(likeToPlayerList) == "table" then
        local time = likeToPlayerList[self.playerInfo_.user_id]
        if time ~= nil then
            local runTime = 3599 -(os.time() - time)
            if runTime > 0 then
                local s = math.floor(runTime) % 60
                local m = math.floor(runTime / 60) % 60
                self:createProgressTimer(btn, runTime)
                -- btn:getChildByName("text"):setString(m .. "m " .. s .. "s")
                btn:setTouchEnabled(false)
                if self.scheduler == nil then
                    local function update(dt)
                        runTime = runTime - 1
                        local s = math.floor(runTime) % 60
                        local m = math.floor(runTime / 60) % 60
                        -- btn:getChildByName("text"):setString(m .. "m " .. s .. "s")
                        if runTime <= 0 then
                            btn:setTouchEnabled(true)
                            -- btn:getChildByName("text"):setString("Like")
                            self:removeProgressTimer(btn)
                            cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.scheduler)
                        end
                    end
                    self.scheduler = cc.Director:getInstance():getScheduler():scheduleScriptFunc(update, 1, false)
                end
            end
        end
    end
end

function SlotFuncView:createProgressTimer(btn, runTime)
    local posX, posY = btn:getPosition()
    local mask = cc.Sprite:create("inSlot_icon/inslots_hold_likeMask.png")
    local progressTimer = cc.ProgressTimer:create(mask)
    mask:setFlippedX(true)
    progressTimer:setType(0)
    progressTimer:setPosition(posX, posY)
    self.btnPanel_:addChild(progressTimer)
    self.btnPanel_.progressTimer_ = progressTimer
    progressTimer:setPercentage(runTime / 3600 * 100)
    progressTimer:runAction(cc.ProgressTo:create(runTime, 0))
end

function SlotFuncView:removeProgressTimer(btn)
    if self.btnPanel_.progressTimer_ ~= nil then
        self.btnPanel_.progressTimer_:stopAllActions()
        self.btnPanel_.progressTimer_:removeFromParent()
        self.btnPanel_.progressTimer_ = nil
    end
end

function SlotFuncView:touchEvent(sender, eventType)
    local name = sender:getName()
    if eventType == ccui.TouchEventType.began then
        sender:runAction(cc.ScaleTo:create(0.1, 1.05, 1.05))
    elseif eventType == ccui.TouchEventType.moved then

    elseif eventType == ccui.TouchEventType.ended then
        sender:runAction(cc.ScaleTo:create(0.1, 1, 1))
        if name == "like_sale" then
            bole.socket:send("like", { like_type = 2, target_id = sender.toId }, true)
            self.likeToPlayer_ = sender.toId
            self:showAct(bole:getUserDataByKey("user_id"), sender.toId, "like", 2)
        elseif name == "giveBg" then
            self.theme_:createChatView()
        elseif name == "like" then
            if sender.toId ~= nil then
                bole.socket:send("like", { like_type = 1, target_id = sender.toId }, true)
                self.likeToPlayer_ = sender.toId
                self:showAct(bole:getUserDataByKey("user_id"), sender.toId, "like", 1)
            end
        elseif name == "connect" then
            if sender.toId ~= nil then
                self:connect(sender.toId)
            end
        end
        self:closeSlotFuncUI()
    elseif eventType == ccui.TouchEventType.canceled then
        sender:runAction(cc.ScaleTo:create(0.1, 1, 1))
    end
end

function SlotFuncView:openGiftLayer()
    self:giveGift()
end


function SlotFuncView:showInfoView()
    bole:getUIManage():openInfoView(self.headView_)
end

function SlotFuncView:likeToPlayer_chatView(data)
    if data ~= nil then
        data = data.result
        bole.socket:send("like", { like_type = 1, target_id = data }, true)
        self.likeToPlayer_ = data
        self:showAct(bole:getUserDataByKey("user_id"), data, "like",1)
    end
end

function SlotFuncView:showLikeAct(data)
    if data ~= nil then
        data = data.result
        self.likeToPlayer_ = data
        self:showAct(bole:getUserDataByKey("user_id"), data, "like",1)
    end
end

function SlotFuncView:showLikeActByOther(data)
    data = data.result
    self:showAct(data.sender, data.target_id, "like",data.like_type)
end

function SlotFuncView:showAct(startId, endId, actType, data)
    local myId = bole:getUserDataByKey("user_id")
    local myHead = self.theme_.myHead
    local myPos = myHead:convertToWorldSpace(cc.p(0, 0))
    local startPos = { }
    local endPos = { }
    local isShowMyChat = false
    local startHead
    local endHead

    if startId == myId then
        startPos = myPos
        startHead = myHead
        isShowMyChat = true
    else
        for k, v in pairs(self.parent_.headNodes) do
            if v.head.info.user_id == startId then
                startHead = v.head
                startPos = v.head:convertToWorldSpace(cc.p(0, 0))
            end
        end
    end

    if endId == myId then
        endPos.x = myPos.x
        endPos.y = myPos.y
        endHead = myHead
        if not isShowMyChat then
            isShowMyChat = false
        end
    else
        for k, v in pairs(self.parent_.headNodes) do
            if v.head.info.user_id == endId then
                endHead = v.head
                endPos = v.head:convertToWorldSpace(cc.p(0, 0))
            end
        end
    end

    if startPos == nil or endPos == nil or startHead == nil or endHead == nil then
        return
    else
        if endId == myId then
            headRLenX = 35
            headRLenY = 30
        end
        endPos.x = endPos.x + headRLenX
        endPos.y = endPos.y + headRLenY
    end

    local chatView = ccui.Layout:create()
    chatView:setName("chatView")
    chatView:setAnchorPoint(0.25, 1)

    local giveBg = ccui.ImageView:create()
    giveBg:ignoreContentAdaptWithSize(false)
    giveBg:loadTexture("loadImage/inSlot_funcBg2.png", 0)
    giveBg:setScale9Enabled(true)
    giveBg:setCapInsets(cc.rect(66, 21, 68, 44))
    giveBg:setTouchEnabled(true)
    giveBg:setName("giveBg")
    chatView:addChild(giveBg)

    local txt = cc.Label:createWithTTF(bole:getNewStr("Thumbs up!", 20, 150), "font/bole_ttf.ttf", 20)
    if actType == "like" then
        if data == 1 then
            if endId == myId then
                txt:setString("Have Fun")
            end
        elseif data == 2 then
            txt:setString("Thank you")
        end
    end
    if actType == "gift" then
        if data.give_type == 1 then
            txt:setString("Enjoy the game")
        else
            txt:setString("Cheers")
        end
    end
    txt:setDimensions(150, 0)
    txt:setAnchorPoint(0, 0)
    txt:setPosition(20, 10)
    chatView:addChild(txt)

    local btn = nil
    if endId == myId and not isShowMyChat then
        if not bole:getFriendManage():isFriend(startId) then
            btn = ccui.Button:create()
            btn:loadTextures("loadImage/inSlot_btn_connect.png", "loadImage/inSlot_btn_connect.png", "loadImage/inSlot_btn_connect.png")
            btn:setName("connect")
            btn.toId = startId
            btn:addTouchEventListener(handler(self, self.touchEvent))
            btn:setPosition(180, 27)
            chatView:addChild(btn)
        else
            local likeToPlayerList = bole:getUserDataByKey("likeToPlayerList")
            local isLikeBtn = true
            if type(likeToPlayerList) == "table" then
                if likeToPlayerList[startId] ~= nil then
                    isLikeBtn = false
                end
            end
            if isLikeBtn then
                btn = ccui.Button:create()
                btn:loadTextures("loadImage/inSlot_btn_like.png", "loadImage/inSlot_btn_like.png", "loadImage/inSlot_btn_like.png")
                btn:setName("like")
                btn.toId = startId
                btn:addTouchEventListener(handler(self, self.touchEvent))
                btn:setPosition(180, 27)
                chatView:addChild(btn)
            end
        end
    end
    local height = txt:getContentSize().height + 40
    giveBg:setContentSize(200, height)
    chatView:setContentSize(220, height + 5)
    if btn then
        local height = btn:getContentSize().height + 30
        giveBg:setContentSize(200, height)
        chatView:setContentSize(220, height + 5)
    end
    giveBg:setPosition(110,(height + 5) / 2)
    chatView:setPosition(0, -30)
    chatView:setScale(0.01)
    chatView:runAction(cc.Sequence:create(cc.ScaleTo:create(0.2, 1.2), cc.ScaleTo:create(0.1, 1)))
    local delay = cc.DelayTime:create(0.3 + 2.75)
    local scaleAct = cc.ScaleTo:create(0.3, 0.01)
    local hide = cc.CallFunc:create( function()
        chatView:removeFromParent()
        myHead.chatView = nil
        if startHead ~= nil then
            startHead.infoView = nil
        end
    end )
    chatView:runAction(cc.Sequence:create(delay, scaleAct, hide))

    if isShowMyChat then
        if myHead.chatView ~= nil then
            myHead.chatView:stopAllActions()
            myHead.chatView:removeFromParent()
            myHead.chatView = nil
        end
        myHead:addChild(chatView)
        myHead.chatView = chatView
    else
        if startHead.infoView ~= nil then
            startHead.infoView:removeFromParent()
            startHead.infoView = nil
        end
        startHead:addChild(chatView)
        startHead.infoView = chatView

        if startPos.x >= 900 then
            giveBg:setFlippedX(true)
            chatView:setAnchorPoint(0.75, 1)
        end
    end


    performWithDelay(self, function()
        self:setVisible(true)
        self.btnPanel_:setVisible(false)
        local actIcon
        local actPathStr
        if actType == "gift" then
            actPathStr = bole:getBuyManage():getGiftIconStr(data.give_type, data.give_id)
            actIcon = cc.Sprite:create(actPathStr)
            if self.actIconLayer_[endId] ~= nil then
                -- 在头像上的礼物处理
                if endHead.giftIcon ~= nil then
                    if data.give_type == 1 and endHead.give_type == 2 then
                        endHead.giftIcon:removeFromParent()
                        endHead.giftIcon = nil
                        endHead.giftId = nil
                        endHead.giftType = nil
                    elseif data.give_type == 2 and endHead.give_type == 1 then
                    else
                        if endHead.giftId <= data.give_id then
                            endHead.giftIcon:removeFromParent()
                            endHead.giftIcon = nil
                            endHead.giftId = nil
                            endHead.giftType = nil
                        end
                    end
                end
                -- 正在飞的礼物处理
                if self.actIconLayer_[endId].giftIcon ~= nil then
                    if data.give_type == 1 and endHead.give_type == 2 then
                        self.actIconLayer_[endId].giftIcon:removeFromParent()
                        self.actIconLayer_[endId].giftIcon = nil
                        self.actIconLayer_[endId].giftId = nil
                        self.actIconLayer_[endId].giftType = nil
                    elseif data.give_type == 2 and endHead.give_type == 1 then
                    else
                        if self.actIconLayer_[endId].giftId <= data.give_id then
                            self.actIconLayer_[endId].giftIcon:removeFromParent()
                            self.actIconLayer_[endId].giftIcon = nil
                            self.actIconLayer_[endId].giftId = nil
                            self.actIconLayer_[endId].giftType = nil
                        end
                    end
                end
                self.actIconLayer_[endId]:addChild(actIcon, 1)
                self.actIconLayer_[endId].giftIcon = actIcon
                self.actIconLayer_[endId].giftId = data.give_id
                self.actIconLayer_[endId].giftType = data.give_type
            end
        else
            actIcon = cc.Sprite:create("loadImage/P_info_o_icon_like.png")
            if self.actIconLayer_[endId] ~= nil then
                self.actIconLayer_[endId]:addChild(actIcon, 2)
            end
        end

        local iconConScale = 0.55
        actIcon:setPosition(startPos.x, startPos.y)
        actIcon:setOpacity(0)
        actIcon:setScale(iconConScale)
        actIcon:runAction(cc.FadeIn:create(0.25))
        local delay = cc.DelayTime:create(1)
        local scaleS = cc.CallFunc:create( function() actIcon:setScale(0.8 * iconConScale) end)

        local offsetX =(endPos.x - startPos.x) / 4
        local offsetY =(endPos.y - startPos.y) / 4

        local reel = 100
        local controlPos1
        local controlPos2
        if startPos.x < 500 and endPos.x < 500 then
            controlPos1 = cc.p(startPos.x + reel, startPos.y + offsetY)
            controlPos2 = cc.p(endPos.x + reel, endPos.y - offsetY)
        elseif startPos.x > 500 and endPos.x > 500 then
            controlPos1 = cc.p(startPos.x - reel, startPos.y + offsetY)
            controlPos2 = cc.p(endPos.x - reel, endPos.y - offsetY)
        else
            if math.abs(startPos.y - endPos.y) < 50 then
                controlPos1 = cc.p(startPos.x + offsetX, startPos.y - 200)
                controlPos2 = cc.p(endPos.x - offsetX, endPos.y - 200)
            else
                if startPos.x < 500 then
                    controlPos1 = cc.p(startPos.x + offsetX, endPos.y)
                    controlPos2 = cc.p(endPos.x - offsetX, endPos.y)
                else
                    controlPos1 = cc.p(startPos.x + offsetX, startPos.y)
                    controlPos2 = cc.p(endPos.x - offsetX, startPos.y)
                end
            end
        end


        local config = { controlPos1, controlPos2, endPos }
        local moveTo = cc.BezierTo:create(1.5, config)

        local scaleTo = cc.Sequence:create(cc.ScaleTo:create(0.9, 2 * iconConScale), cc.ScaleTo:create(0.6, 1 * iconConScale))
        local fadeOut = cc.FadeOut:create(0.25)

        local hide = cc.CallFunc:create( function()
            actIcon:removeFromParent()
            actIcon = nil
            if actType == "gift" then
                self.actIconLayer_[endId].giftId = nil
                self.actIconLayer_[endId].giftIcon = nil
                self.actIconLayer_[endId].giftType = nil
            end
        end )

        local addToHead = cc.CallFunc:create( function()
            if endHead.giftIcon ~= nil then
                if data.give_type == 1 and endHead.give_type == 2 then
                    endHead.giftIcon:removeFromParent()
                    endHead.giftIcon = nil
                    endHead.giftId = nil
                    endHead.giftType = nil
                elseif data.give_type == 2 and endHead.give_type == 1 then
                    return
                else
                    if endHead.giftId <= data.give_id then
                        endHead.giftIcon:removeFromParent()
                        endHead.giftIcon = nil
                        endHead.giftId = nil
                        endHead.giftType = nil
                    else
                        return
                    end
                end
            end

            if data.give_type == 1 then
                local sp = cc.Sprite:create(actPathStr)
                sp:setScale(0.5)
                endHead:addChild(sp)
                endHead.giftIcon = sp
                endHead.giftId = data.give_id
                endHead.giftType = data.give_type
                sp:setPosition(headRLenX, headRLenY)
            else
                local sp = sp.SkeletonAnimation:create("shop_act/gift_yinliao_1.json", "shop_act/gift_yinliao_1.atlas")
                -- sp:setScale(0.5)
                sp:setAnimation(0, bole:getBuyManage():getGiftIconActName(data.give_type, data.give_id), true)
                endHead:addChild(sp)
                endHead.giftIcon = sp
                endHead.giftId = data.give_id
                endHead.giftType = data.give_type
                sp:setPosition(headRLenX, headRLenY)

            end
        end )

        if actType == "gift" then
            actIcon:runAction(cc.Sequence:create(delay, scaleS, moveTo, hide, addToHead))
            actIcon:runAction(cc.Sequence:create(delay, scaleTo))
        else
            actIcon:runAction(cc.Sequence:create(delay, scaleS, moveTo, fadeOut, hide))
            actIcon:runAction(cc.Sequence:create(delay, scaleTo))
        end

    end , 0.1)
end

function SlotFuncView:showGiftAct(data)
    data = data.result
    for _, id in pairs(data.target_id) do
        self:showAct(bole:getUserDataByKey("user_id"), id, "gift", data)
    end
end

function SlotFuncView:showGiftActByOther(data)
    data = data.result
    for _, id in pairs(data.target_id) do
        self:showAct(data.sender, id, "gift", data)
    end
end


function SlotFuncView:reLikeToPlayer(data)
    if self.likeToPlayer_ ~= nil and self.btnPanel_:isVisible() then
        if self.likeToPlayer_ == self.playerInfo_.user_id then
            self:createRunTime(self.btnPanel_:getChildByName("like"))
        end
    end
    self.likeToPlayer_ = nil
end

function SlotFuncView:connect(data)
    local addFriendList = bole:getUserDataByKey("addFriend")
    local id = data or self.playerInfo_.user_id
    if addFriendList ~= 0 then
        for k, v in pairs(addFriendList) do
            if v == id then
                bole:popMsg( { msg = "已经发送过邀请", title = "Add Friend" })
                self:closeSlotFuncUI()
                return
            end
        end
    end
    bole.socket:send("apply_for_friend", { target_id = id }, true)
end

function SlotFuncView:inviteClub()
    local inviteClubList = bole:getUserDataByKey("inviteClub")
    if inviteClubList ~= 0 then
        for k, v in pairs(inviteClubList) do
            if v == self.playerInfo_.user_id then
                bole:popMsg( { msg = "已经发送过邀请", title = "Invite Club" })
                self:closeSlotFuncUI()
                return
            end
        end
    end
    bole.socket:send("send_club_invitation", { target_uid = self.playerInfo_.user_id }, true)
end


function SlotFuncView:reInvitationClub(t, data)
    if data.error ~= nil then
        if data.error == 4 then
            -- 玩家已经拥有工会
            bole:popMsg( { msg = "This player is not available now.", title = "invite", cancle = false })
        elseif data.error == 5 then
            -- 公会已满
            bole:popMsg( { msg = "Sorry,your club is full.", title = "invite", cancle = false })
        elseif data.error == 3 then
            -- 重复邀请
            bole:popMsg( { msg = "Invite has been sent before.", title = "invite", cancle = false })
        else
            bole:popMsg( { msg = "error: " .. data.error, title = "invite", cancle = false })
        end
        return
    end

    if data.success == 1 then
        bole:popMsg( { msg = "invite successfully", title = "invite", cancle = false })
        bole:getClubManage():addInvitePlayer(self.playerInfo_.user_id)
    end

    if data.in_club == 1 then

    end

    self:closeSlotFuncUI()
end

function SlotFuncView:reApplyFriend(t, data)
    if data.error ~= nil then
        if data.error == 1 then
            -- 没这个玩家
            bole:popMsg( { msg = "Couldnit find a player with the provided ID.", title = "connect", cancle = false })
        elseif data.error == 2 then
            -- 没这个玩家
            bole:popMsg( { msg = "Couldnit find a player with the provided ID.", title = "connect", cancle = false })
        elseif data.error == 3 then
            -- 已是好友
            bole:popMsg( { msg = "the player is your friend.", title = "connect", cancle = false })
        elseif data.error == 4 then
            -- 好友满了
            bole:popMsg( { msg = "Player list is full", title = "connect", cancle = false })
        elseif data.error == 5 then
            -- 对方把你加了黑名单
            bole:popMsg( { msg = "You can't add this player.", title = "connect", cancle = false })
        else
            bole:popMsg( { msg = "error: " .. data.error, title = "connect", cancle = false })
        end
        return
    end
    if data.success == 1 then
        bole:getFriendManage():addFriend(data.new_friend)
        bole:popMsg( { msg = "connect successfully", title = "connect", cancle = false })
        self:closeSlotFuncUI()
    end
end

function SlotFuncView:giveGift()
    bole:getUIManage():openNewUI("GiftLayer", true, "shop_gift", "app.views.shop")
    bole:postEvent("initGiftLayer", { self.playerInfo_.user_id, self.parent_.headNodes })
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
end

function SlotFuncView:showGiveInfo(id)
    for k, v in pairs(self.parent_.headNodes) do
        if v.head.info.user_id == id then
            local infoView = self:createGiveInfo(id, str)
            v.node:addChild(infoView)
            infoView:setPosition(0, -30)
            local delay = cc.DelayTime:create(4)
            local hide = cc.CallFunc:create( function() infoView:removeFromParent() end)
            infoView:runAction(cc.Sequence:create(delay, hide))
        end
    end
end

function SlotFuncView:userLeaveRoom(data)
    data = data.result
    -- 删除聊天框
    for k, v in pairs(self.parent_.headNodes) do
        if v.head.info.user_id == data.user_id then
            if v.node.infoView ~= nil then
                v.node.infoView:stopAllActions()
                v.node.infoView:removeFromParent()
                v.node.infoView = nil
            end
            if v.node.giftIcon ~= nil then
                v.node.giftIcon:removeFromParent()
                v.node.giftIcon = nil
                v.node.giftId = nil
            end
        end
    end

    -- 删除正在飞的iocn
    if self.actIconLayer_[data.user_id] ~= nil then
        self.actIconLayer_[data.user_id]:removeFromParent()
        self.actIconLayer_[data.user_id] = nil
    end

    if self:isVisible() then
        if self.playerInfo_ ~= nil then
            if self.playerInfo_.user_id == data.user_id then
                self:closeSlotFuncUI()
            end
        end
    end

    -- self.giftIconLayer_.iconList[data.user_id] = nil
end

function SlotFuncView:userEnterRoom(data)
    data = data.result
    local actPanel = ccui.Layout:create()
    actPanel:setPosition(0, 0)
    self:addChild(actPanel, 5)
    self.actIconLayer_[data.user_id] = actPanel
end

function SlotFuncView:showSaleChat(id)
    for k, v in pairs(self.parent_.headNodes) do
        if v.head.info.user_id == id then
            if v.node.infoView ~= nil then
                v.node.infoView:stopAllActions()
                v.node.infoView:removeFromParent()
                v.node.infoView = nil
            end
            local infoView
            local pos = v.head:convertToWorldSpace(cc.p(0, 0))
            if pos.x >= 900 then
                infoView = self:createSaleChatInfo(id, true)
            else
                infoView = self:createSaleChatInfo(id)
            end
            v.node:addChild(infoView)
            v.node.infoView = infoView
            infoView:setPosition(0, -30)
            infoView:setScale(0.01)
            infoView:runAction(cc.Sequence:create(cc.ScaleTo:create(0.2, 1.2), cc.ScaleTo:create(0.1, 1)))
            local delay = cc.DelayTime:create(0.3 + 2.75)
            local scaleAct = cc.ScaleTo:create(0.3, 0.01)
            local hide = cc.CallFunc:create( function()
                infoView:removeFromParent()
                v.node.infoView = nil
            end )
            infoView:runAction(cc.Sequence:create(delay, scaleAct, hide))
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
        if v.head.info.user_id == data.sender then
            if v.node.infoView ~= nil then
                v.node.infoView:stopAllActions()
                v.node.infoView:removeFromParent()
                v.node.infoView = nil
            end
            local infoView
            local pos = v.head:convertToWorldSpace(cc.p(0, 0))
            if pos.x >= 900 then
                infoView = self:createSlotInfo(data, true)
            else
                infoView = self:createSlotInfo(data)
            end
            v.node:addChild(infoView)
            v.node.infoView = infoView
            infoView:setPosition(0, -30)
            infoView:setScale(0.01)
            infoView:runAction(cc.Sequence:create(cc.ScaleTo:create(0.2, 1.2), cc.ScaleTo:create(0.1, 1)))
            local delay = cc.DelayTime:create(0.3 + 2.75)
            local scaleAct = cc.ScaleTo:create(0.3, 0.01)
            local hide = cc.CallFunc:create( function()
                infoView:removeFromParent()
                v.node.infoView = nil
            end )
            infoView:runAction(cc.Sequence:create(delay, scaleAct, hide))
        end
    end
end


function SlotFuncView:createSlotInfo(data, isRight)
    local playerId = data.sender

    local chatView = ccui.Layout:create()
    chatView:setName("chatView")
    chatView:setAnchorPoint(0.25, 1)

    local giveBg = ccui.ImageView:create()
    giveBg:ignoreContentAdaptWithSize(false)
    giveBg:loadTexture("loadImage/inSlot_funcBg2.png", 0)
    giveBg:setScale9Enabled(true)
    giveBg:setCapInsets(cc.rect(66, 21, 68, 44))
    giveBg:setTouchEnabled(true)
    giveBg:setName("giveBg")
    giveBg:addTouchEventListener(handler(self, self.touchEvent))
    chatView:addChild(giveBg)

    if string.sub(data.msg, 1, 8) == "#emotion" then
        local emotion = sp.SkeletonAnimation:create("emotion/skeleton.json", "emotion/skeleton.atlas")
        emotion:setAnimation(0, string.sub(data.msg, 9, -1), true)
        emotion:setPosition(50, 38)
        chatView:addChild(emotion)

        giveBg:setContentSize(200, 90)
        chatView:setContentSize(220, 90)
        giveBg:setPosition(110, 45)

        if isRight then
            giveBg:setFlippedX(true)
            chatView:setAnchorPoint(0.75, 1)
        end

        return chatView
    end

    local txt = nil
    data.msg = string.gsub(data.msg, "\n", "")
    if string.len(data.msg) > 40 then
        data.msg = string.sub(data.msg, 1, 40) .. "..."
    end

    if data.infoType == "chat" then
        txt = cc.Label:createWithTTF(bole:getNewStr(data.msg, 20, 180), "font/bole_ttf.ttf", 20)
        txt:setDimensions(180, 0)
    else
        local likeToPlayerList = bole:getUserDataByKey("likeToPlayerList")
        local isBtn = true
        if type(likeToPlayerList) == "table" then
            if likeToPlayerList[data.sender] ~= nil then
                isBtn = false
            end
        end

        if isBtn then
            local btn = ccui.Button:create()
            if bole:getFriendManage():isFriend(playerId) then
                btn:loadTextures("loadImage/inSlot_btn_like.png", "loadImage/inSlot_btn_like.png", "loadImage/inSlot_btn_like.png")
                btn:setName("like")
                btn.toId = data.sender
            else
                btn:loadTextures("loadImage/inSlot_btn_connect.png", "loadImage/inSlot_btn_connect.png", "loadImage/inSlot_btn_connect.png")
                btn:setName("connect")
                btn.toId = data.sender
            end
            btn:addTouchEventListener(handler(self, self.touchEvent))
            btn:setPosition(177, 35)
            chatView:addChild(btn)
            txt = cc.Label:createWithTTF(bole:getNewStr(data.msg, 20, 150), "font/bole_ttf.ttf", 20)
            txt:setDimensions(150, 0)
        else
            txt = cc.Label:createWithTTF(bole:getNewStr(data.msg, 20, 180), "font/bole_ttf.ttf", 20)
            txt:setDimensions(180, 0)
        end
    end

    txt:setAnchorPoint(0, 0)
    txt:setPosition(15, 14)
    chatView:addChild(txt)

    local height = txt:getContentSize().height + 40
    giveBg:setContentSize(200, height)
    chatView:setContentSize(220, height + 5)
    giveBg:setPosition(110,(height + 5) / 2)

    if isRight then
        giveBg:setFlippedX(true)
        chatView:setAnchorPoint(0.75, 1)
    end
    return chatView
end


function SlotFuncView:createSaleChatInfo(id, isRight)
    local chatView = ccui.Layout:create()
    chatView:setName("chatView")
    chatView:setAnchorPoint(0.25, 1)

    local giveBg = ccui.ImageView:create()
    giveBg:ignoreContentAdaptWithSize(false)
    giveBg:loadTexture("loadImage/inSlot_funcBg2.png", 0)
    giveBg:setScale9Enabled(true)
    giveBg:setCapInsets(cc.rect(66, 21, 68, 44))
    giveBg:setTouchEnabled(true)
    giveBg:setName("giveBg")
    giveBg:addTouchEventListener(handler(self, self.touchEvent))
    chatView:addChild(giveBg)

    local btn = ccui.Button:create()
    btn:loadTextures("loadImage/inSlot_btn_like.png", "loadImage/inSlot_btn_like.png", "loadImage/inSlot_btn_like.png")
    btn:setName("like_sale")
    btn.toId = id
    btn:addTouchEventListener(handler(self, self.touchEvent))
    btn:setPosition(180, 35)
    chatView:addChild(btn)
    local txt = cc.Label:createWithTTF(bole:getNewStr("Enjoy the game.", 20, 150), "font/bole_ttf.ttf", 20)
    txt:setDimensions(150, 0)
    txt:setAnchorPoint(0, 0)
    txt:setPosition(15, 10)
    chatView:addChild(txt)
    giveBg:setContentSize(200, 85)
    chatView:setContentSize(220, 90)
    giveBg:setPosition(110, 45)

    if isRight then
        giveBg:setFlippedX(true)
        chatView:setAnchorPoint(0.75, 1)
    end
    return chatView
end

function SlotFuncView:saleActTest(data)
    data = data.result
    local winSize = cc.Director:getInstance():getWinSize()
    local id_me = bole:getUserDataByKey("user_id")
    local mePos = cc.p(114, winSize.height - 60)
    local startPos = cc.p(114, winSize.height - 60)
    if id_me ~= data.sender then
        for k, v in pairs(self.parent_.headNodes) do
            if v.user_id == data.sender then
                startPos = v.node:convertToWorldSpace(cc.p(0, 0))
                performWithDelay(self, function() self:showSaleChat(v.user_id) end, 3)
            end
        end
    end
    performWithDelay(self, function()
        bole:postEvent("showSaleBtnAct")
        if id_me == data.sender then
            for k, v in pairs(self.parent_.headNodes) do
                if v.user_id ~= nil then
                    if k == 2 then
                        self:flyCoin(startPos, v.node:convertToWorldSpace(cc.p(0, 0)), nil, 5, true)
                    else
                        self:flyCoin(startPos, v.node:convertToWorldSpace(cc.p(0, 0)), nil, 5)
                    end
                    performWithDelay(self, function() v.head:updateInfo( { win_type = 1 }) end, 1.3)
                end
            end
        else
            local pos = 1
            for k, v in pairs(self.parent_.headNodes) do
                if self.parent_.headNodes.user_id == data.sender then
                    pos = k
                end
            end
            if pos == 2 then
                for k, v in pairs(self.parent_.headNodes) do
                    if v.user_id ~= nil then
                        if k ~= pos then
                            self:flyCoin(startPos, v.node:convertToWorldSpace(cc.p(0, 0)), nil, 5)
                            performWithDelay(self, function() v.head:updateInfo( { win_type = 1 }) end, 1.3)
                        end
                    end
                end
                self:flyCoin(startPos, mePos, nil, 5, true)
                performWithDelay(self, function()
                    self.theme_.myHead:updateInfo( { win_type = 1 })
                    bole:refreshCoinsAndDiamondInSlot()
                end , 1.3)
            else
                for k, v in pairs(self.parent_.headNodes) do
                    if v.user_id ~= nil then
                        if k ~= pos then
                            self:flyCoin(startPos, v.node:convertToWorldSpace(cc.p(0, 0)), nil, 5)
                            performWithDelay(self, function() v.head:updateInfo( { win_type = 1 }) end, 1.3)
                        end
                    end
                end
                self:flyCoin(startPos, mePos, nil, 5)
                performWithDelay(self, function()
                    self.theme_.myHead:updateInfo( { win_type = 1 })
                    bole:refreshCoinsAndDiamondInSlot()
                end , 1.3)
            end

        end

    end , 0.5)
end

function SlotFuncView:saleTestAct(data)
    local winSize = cc.Director:getInstance():getWinSize()
    local id_me = bole:getUserDataByKey("user_id")
    local mePos = cc.p(114, winSize.height - 60)
    local startPos = cc.p(114, winSize.height - 60)

    performWithDelay(self, function()
        bole:postEvent("showSaleBtnAct")
        for k, v in pairs(self.parent_.headNodes) do
            if k == 2 then
                self:flyCoin(startPos, v.node:convertToWorldSpace(cc.p(0, 0)), nil, 5, true)
            else
                self:flyCoin(startPos, v.node:convertToWorldSpace(cc.p(0, 0)), nil, 5)
            end
            performWithDelay(self, function() v.head:updateInfo( { win_type = 1 }) end, 1.3)

        end
    end , 0.5)
end

function SlotFuncView:closeSlotFuncUI(data)

    if self.scheduler then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.scheduler)
    end
    self.scheduler = nil

    self.btnPanel_:stopAllActions()
    local hide = cc.CallFunc:create( function() self.btnPanel_:setVisible(false) end)
    self.btnPanel_:runAction(cc.Sequence:create(cc.ScaleTo:create(0.3, 0.01), hide))
    self.btnPanel_:runAction(cc.FadeOut:create(0.3))
    self.touchLayer_:setTouchEnabled(false)
end

function SlotFuncView:adaptScreen()
    local winSize = cc.Director:getInstance():getWinSize()
    self.touchLayer_:setContentSize(winSize)
    self.touchLayer_:setPosition(winSize.width / 2, winSize.height / 2)
end


function SlotFuncView:flyCoin(startPos, endPos, callbackFunc, randomNum, isReel)
    local durationTime = 1.2
    randomNum = randomNum or 5
    local eachWaitTime = 0.1
    local actionTime = 1
    bole:getAudioManage():playEff("collect_coin")
    local node = cc.Node:create()
    local scene = cc.Director:getInstance():getRunningScene()
    scene:addChild(node, 64)

    local hideLaunchNodeFunc
    local launchFunc
    local flyEndFunc
    local cacheCoinNodes = { }
    local spendTime = 0
    local eachSpendTime = 0
    local stopLaunch = false
    local function update(dt)
        spendTime = spendTime + dt

        if spendTime > durationTime then
            stopLaunch = true
            hideLaunchNodeFunc()
            node:unscheduleUpdate()
            return
        end

        eachSpendTime = eachSpendTime + dt
        if eachSpendTime >= eachWaitTime then
            eachSpendTime = eachSpendTime - eachWaitTime
            launchFunc()
        end
    end
    node:onUpdate(update)

    local lightNode = sp.SkeletonAnimation:create("util_act/yellow_light.json", "util_act/yellow_light.atlas")
    node:addChild(lightNode)
    lightNode:setPosition(startPos.x, startPos.y)
    lightNode:setAnimation(0, "animation1", true)

    local particleNode = cc.ParticleSystemQuad:create("util_act/yellow_light.plist")
    node:addChild(particleNode)
    particleNode:setPosition(startPos.x, startPos.y)

    hideLaunchNodeFunc = function()
        if particleNode then
            local nodes = { particleNode, lightNode }
            for _, hideNode in ipairs(nodes) do
                local fadeOut = cc.FadeOut:create(0.3)
                local function endbackFunc()
                    hideNode:removeFromParent(true)
                end
                local callAction = cc.CallFunc:create(endbackFunc)
                hideNode:runAction(cc.Sequence:create(fadeOut, callAction))
            end
            particleNode = nil
        end
    end

    local function getCoinNode()
        local coinNode
        for _, skeletonNode in ipairs(cacheCoinNodes) do
            if not skeletonNode:isVisible() then
                skeletonNode:setVisible(true)
                skeletonNode:setToSetupPose()
                coinNode = skeletonNode
                break
            end
        end

        if not coinNode then
            coinNode = sp.SkeletonAnimation:create("util_act/coin_turnd.json", "util_act/coin_turnd.atlas")
            node:addChild(coinNode)
            table.insert(cacheCoinNodes, coinNode)
        end

        coinNode:setPosition(startPos.x + math.random(-15, 15), startPos.y + math.random(-15, 15))
        coinNode:setRotation(math.random(0, 360))
        coinNode:setAnimation(0, "animation" .. math.random(5), true)
        coinNode:setOpacity(0)

        return coinNode
    end

    local offsetX =(startPos.x - endPos.x) / 1.5
    local randomX = math.abs(offsetX) / 2
    local offsetY =(endPos.y - startPos.y) / 4
    local randomY = math.abs(offsetY) / 2

    local launchCount = 0
    launchFunc = function()
        local num = math.random(1, randomNum)
        launchCount = launchCount + num
        if num > 0 then
            for i = 1, num do
                local coinNode = getCoinNode()
                local fadeIn = cc.FadeIn:create(0.3)

                local reel = 0
                if isReel then reel = 100 end
                local controlPos1 = cc.p(startPos.x -(offsetX + math.random(- randomX, randomX)) + reel, startPos.y +(offsetY + math.random(- randomY, randomY)))
                local controlPos2 = cc.p(endPos.x +(offsetX + math.random(- randomX, randomX)) + reel, endPos.y -(offsetY + math.random(- randomY, randomY)))

                local config = { controlPos1, controlPos2, endPos }

                local action = cc.BezierTo:create(actionTime, config)
                local easeAction = cc.EaseInOut:create(action, 3)
                local fadeOut = cc.FadeOut:create(0.3)
                local function endCallFunc()
                    launchCount = launchCount - 1
                    coinNode:setVisible(false)
                    flyEndFunc()
                end
                local callAction = cc.CallFunc:create(endCallFunc)
                coinNode:runAction(cc.Sequence:create(cc.Spawn:create(easeAction, fadeIn), fadeOut, callAction))
            end
        else
            flyEndFunc()
        end
    end

    flyEndFunc = function()
        if launchCount == 0 and stopLaunch and node then
            node:removeFromParent(true)
            node = nil
            if callbackFunc then
                callbackFunc()
            end
        end
    end
end
return SlotFuncView

-- endregion
