--region *.lua
--Date
--此文件由[BabeLua]插件自动生成

local RoommateView = class("RoommateView")
function RoommateView:ctor(theme, roomData, order)
    self.theme = theme
    self.roomData = roomData

    local rootNode = cc.CSLoader:createNodeWithVisibleSize("csb/spin/roommateView.csb")
    self.rootNode = rootNode

    self:setViews(rootNode, roomData)

    rootNode:registerScriptHandler(function(state)
        if state == "enter" then
            self:onEnter()
        elseif state == "exit" then
            self:onExit()
        end
    end)

    theme:addChild(rootNode, order, order)

    self:createSlotFuncView(self)
end

function RoommateView:onEnter()
    self.isDead = false
--    bole:addListener("coinsChanged", self.onCoinChanged, self, nil, true)
    bole:addListener("openSlotFuncView", self.openSlotFuncView, self, nil, true)
    bole.socket:registerCmd("b_enter_room", self.onEnterRoom, self)
    bole.socket:registerCmd("b_leave_room", self.onExitRoom, self)
    bole.socket:registerCmd(bole.SERVER_B_SYNC, self.sync, self)
end

function RoommateView:onExit()
--    bole:getEventCenter():removeEventWithTarget("coinsChanged", self)
    bole:getEventCenter():removeEventWithTarget("openSlotFuncView", self)
    if self.slotFuncView_ ~= nil then
        self.slotFuncView_:onExit()
    end
    bole.socket:unregisterCmd("b_enter_room")
    bole.socket:unregisterCmd("b_leave_room")
    bole.socket:unregisterCmd("bole.SERVER_B_SYNC")
    self.isDead = true
end

function RoommateView:onEnterRoom(t, data)
    dump(data, "RoommateView:onEnterRoom")
    bole:postEvent("addUserDataToChat", data)
    local user_id = data.user_id
    for index, v in ipairs(self.headNodes) do
        if user_id == v.user_id then
            return
        end
    end

    local site = data.site
    for index, v in ipairs(self.headNodes) do
        if not v.user_id and (not v.site or site <= v.site) then
            local parentNode = v.node
            parentNode:removeAllChildren()

            local headNode = bole:getNewHeadView(data)
            parentNode:addChild(headNode)
            headNode:updatePos(headNode.POS_SPIN_FRIEND)
            headNode:updateCoins(data.coins)
            v.user_id = data.user_id
            v.site = data.site
            v.head= headNode
--            v.info = data
            break
        end
    end
end

function RoommateView:sync(t, data)
    if t == bole.SERVER_B_SYNC then
        bole:postEvent("chat_bigWin",data)
        for index, v in ipairs(self.headNodes) do
            if v.head:getInfo().user_id==data.user_id then
                --data.win_type=1
                v.head:updateInfo(data)
            end
        end
    end
end

function RoommateView:onExitRoom(t, data)
    dump(data, "RoommateView:onExitRoom")
    local leaveId = data.user_id
    for index, v in ipairs(self.headNodes) do
        if v.user_id == leaveId then
            local parentNode = v.node
            parentNode:removeAllChildren()

            local headNode = bole:getNewHeadView()
            parentNode:addChild(headNode)
            headNode:updatePos(headNode.POS_SPIN_INTIVE)
            v.user_id = nil
            v.head= headNode
--            v.info = nil
            break
        end
    end
end

function RoommateView:setViews(rootNode, roomData)
    local otherPlayerInfo = roomData.other_players
    table.sort(otherPlayerInfo, function(a, b)
        if a.site < b.site then
            return true
        end
    end)

    self.headNodes = {}
    for i = 1, 4 do
        local playInfo = otherPlayerInfo[i]
        local posNodeInfo = {}

        local partNode = rootNode:getChildByName("head" .. i)
        local headNode = bole:getNewHeadView(playInfo)
        partNode:addChild(headNode)

        if playInfo then
            headNode:updatePos(headNode.POS_SPIN_FRIEND)
            posNodeInfo.site = playInfo.site
            posNodeInfo.user_id = playInfo.user_id
            headNode:updateCoins(playInfo.coins)
        else
            headNode:updatePos(headNode.POS_SPIN_INTIVE)
        end
        
        posNodeInfo.node = partNode
        posNodeInfo.head= headNode
--        posNodeInfo.info = playInfo
        self.headNodes[i] = posNodeInfo
    end
    self.site = roomData.site
end

function RoommateView:createSlotFuncView(root)
    self.slotFuncView_ = bole:getEntity("app.views.spin.SlotFuncView", root, self.theme)
    self.rootNode:addChild( self.slotFuncView_ , bole.ZORDER_UI)
    for _, v in pairs(self.roomData.other_players) do
        bole:postEvent("addUserDataToChat", v)
    end

end

function RoommateView:openSlotFuncView(data)
    data = data.result
    if  self.slotFuncView_ ~= nil then
        self.slotFuncView_:openSlotFuncView(data[1], data[2], self.roomData)
    end
end

function RoommateView:removeFromParent(isCleanup)
    self.rootNode:removeFromParent(isCleanup)
end

return RoommateView

--endregion
