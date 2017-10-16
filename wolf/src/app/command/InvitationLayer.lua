--region *.lua
--Date
--此文件由[BabeLua]插件自动生成
local InvitationLayer = class("InvitationLayer", cc.Node)
--cell start
local InvitationCell = class("InvitationCell",ccui.Layout) 
function InvitationCell:ctor(node,data)
    self.node=node
    self:setContentSize({ width = 1194, height = 160 })
    self.data={}
    for k,v in ipairs(data)  do
        self:newCell(v,k)
    end
    self:setTouchEnabled(true)
    self:addTouchEventListener(handler(self, self.touchEvent))
end

function InvitationCell:touchEvent(sender, eventType)
    local name = sender:getName()
    local tag = sender:getTag()
    print("touchEvent:" .. name)
    if eventType == ccui.TouchEventType.began then
        print("Touch Down")
    elseif eventType == ccui.TouchEventType.moved then
        print("Touch Move")
    elseif eventType == ccui.TouchEventType.ended then
            local bPos=sender:getTouchBeganPosition()
--            print("ccui.TouchEventType.ended=".. bPos.x)
            if bPos.x>68+240*4 then
                self:clickCell(5)
--                 print("clickCell5="..240*4)
            elseif bPos.x>68+240*3 then
                self:clickCell(4)
--                print("clickCell4="..240*3)
            elseif bPos.x>68+240*2 then
                self:clickCell(3)
--                print("clickCell3="..240*2)
            elseif bPos.x>68+240*1 then
                self:clickCell(2)
--                print("clickCell2="..240*1)
            elseif bPos.x>0 then
                self:clickCell(1)
--                print("clickCell1="..0)
            end
    elseif eventType == ccui.TouchEventType.canceled then
        print("Touch Cancelled")
    end
end
function InvitationCell:newCell(data,index)
    dump(data,"newCell")
    local head=bole:getNewHeadView(data)
    self:addChild(head)
    head:setSwallow(false)
    head:updatePos(head.POS_INTIVE_FRIEND)
    head:setScale(0.8)
    local sp_bg=display.newSprite("friend/ui/MF_check02.png")
    self:addChild(sp_bg)
    local sp_select=display.newSprite("friend/ui/MY_check01.png")
    self:addChild(sp_select)
    sp_select:setVisible(false)
    self.data[index]={}
    self.data[index].user_id=data.user_id
    self.data[index].node=sp_select
    self.data[index].isSelect=false
    head:setPosition(100+(index-1)*240,80)
    sp_bg:setPosition(200+(index-1)*240,80)
    sp_select:setPosition(200+(index-1)*240,80)
end
function InvitationCell:clickCell(index)
    if self.data[index] then
        self.data[index].isSelect=not self.data[index].isSelect 
        self.data[index].node:setVisible(self.data[index].isSelect)
        self.node:setCell(self.data[index].user_id,self.data[index].isSelect)
    end
end

function InvitationCell:setAllselect(flag)
    dump(self.data,"setAllselect")
    for k, v in ipairs(self.data) do
        v.isSelect=flag 
        self.data[k].node:setVisible(flag)
        self.node:setCell(self.data[k].user_id,flag)
    end
end

--cell end


----------------------------------------start-------------------------------------
function InvitationLayer:ctor()
    self:init()
    local windowSize = cc.Director:getInstance():getWinSize()
    self.mask= bole:getUIManage():getNewMaskUI("InvitationLayer")
    self.mask:setPosition(cc.p(windowSize.width / 2, windowSize.height / 2))
    self:addChild(self.mask)

    self.node_input = cc.CSLoader:createNodeWithVisibleSize("csb/InvitationLayer.csb")
    self:addChild(self.node_input)
    self.node_input:setVisible(false)
    bole.socket:send(bole.GET_ROOM_INVITE_USERS,{},true)
end

function InvitationLayer:initUI()
    print("---------------------------------------asdfsadf")
    self.node_input:setVisible(true)
    local root = self.node_input:getChildByName("root")
    self.bnt_intive = root:getChildByName("bnt_intive")
    self.bnt_intive:addTouchEventListener(handler(self, self.touchEvent))
    local btn_close = root:getChildByName("btn_close")
    btn_close:addTouchEventListener(handler(self, self.touchEvent))

    local img_friend = root:getChildByName("img_friend")
    img_friend:addTouchEventListener(handler(self, self.touchEvent))
    img_friend:setTouchEnabled(true)
    local img_club = root:getChildByName("img_club")
    img_club:addTouchEventListener(handler(self, self.touchEvent))
    img_club:setTouchEnabled(true)

    local img_select = root:getChildByName("img_select")
    img_select:addTouchEventListener(handler(self, self.touchEvent))
    img_select:setTouchEnabled(true)

    self.img_bottom= root:getChildByName("img_bottom")
    self.img_center= root:getChildByName("img_center")
    

    self.img_friend_mask = root:getChildByName("img_friend_mask")
    self.img_club_mask = root:getChildByName("img_club_mask")
    self.emty = root:getChildByName("emty")
    self.sp_select = root:getChildByName("sp_select")
    self.sp_select:setVisible(false)

    self.list_friends = root:getChildByName("list_friends")
    self.list_club = root:getChildByName("list_club")
    self.invite_list={}
    self.isAll={}
    self.friendsCount=0
    self.clubCount=0
    self.selectIndex=0
    self.user_id=bole:getUserDataByKey("user_id")
end

function InvitationLayer:init()
    self:registerScriptHandler( function(tag)
        if "enter" == tag then
            self:onEnter()
        elseif "exit" == tag then
            self:onExit()
        end
    end )
end

function InvitationLayer:onEnter()
    bole:getBoleEventKey():addKeyBack(self)
    bole.socket:registerCmd(bole.GET_ROOM_INVITE_USERS, self.initData, self)
end

function InvitationLayer:onExit()
    bole:getBoleEventKey():removeKeyBack(self)
    bole.socket:unregisterCmd(bole.GET_ROOM_INVITE_USERS)
end

function InvitationLayer:onKeyBack()
   self:closeUI()
end

function InvitationLayer:closeUI()
    bole:autoOpacityC(self)
    local sp=cc.FadeOut:create(0.2)
    local act = cc.RemoveSelf:create()
    self:runAction(cc.Sequence:create(sp, act))
end

function InvitationLayer:initData(t, data)
    self:initUI()
    if t == bole.GET_ROOM_INVITE_USERS then
        local friend = data.friend or { }
        local club = data.club or { }
        local players = bole:getSpinApp():getTheme().roomInfo.other_players

        for k1, v1 in pairs(players) do
            for k2, v2 in pairs(friend) do
                if v1.user_id == v2.user_id then
                    table.remove(friend, k2)
                end
            end
        end

        for k1, v1 in pairs(players) do
            for k2, v2 in pairs(club) do
                if v1.user_id == v2.user_id then
                    table.remove(club, k2)
                end
            end
        end

        self.friendsCount = #friend
        if self.friendsCount > 1 then
            table.sort(friend, function(a, b)
                return tonumber(a.level) > tonumber(b.level)
            end )
        else

        end

        self.clubCount = #club
        if self.clubCount > 1 then
            table.sort(club, function(a, b)
                return tonumber(a.level) > tonumber(b.level)
            end )
        else

        end
        self.tempCell = { }
        for k, v in ipairs(friend) do
            self.tempCell[#self.tempCell + 1] = v
            if #self.tempCell == 5 then
                self:addCell(self.tempCell, 1)
                self.tempCell = { }
            end
        end
        self:addCell(self.tempCell, 1)
        self.tempCell = { }

        for k, v in ipairs(club) do
            self.tempCell[#self.tempCell + 1] = v
            if #self.tempCell == 5 then
                self:addCell(self.tempCell, 2)
                self.tempCell = { }
            end
        end
        self:addCell(self.tempCell, 2)
        self.tempCell = { }
        self:selectList(1)
    end
end


function InvitationLayer:addCell(data, flag)
    local cell = InvitationCell:create(self, data)
    if flag == 1 then
        self.list_friends:pushBackCustomItem(cell)
    else
        self.list_club:pushBackCustomItem(cell)
    end
end

function InvitationLayer:selectList(flag)
    if self.selectIndex==flag then
        return
    end
    self.selectIndex=flag
    if self.selectIndex==1 then
        self.list_club:setVisible(false)
        self.list_friends:setVisible(true)
        self.img_friend_mask:setVisible(false)
        self.img_club_mask:setVisible(true)
        if self.friendsCount==0 then
            self.emty:setVisible(true)
            self.bnt_intive:setVisible(false)
            self.img_bottom:setVisible(false)
            self.img_center:setVisible(false)
            self.emty:getChildByName("txt_tips"):setString("Nobody Online.Add more friends or tell your friends to come and play!")
        else
            self.emty:setVisible(false)
            self.bnt_intive:setVisible(true)
            self.img_bottom:setVisible(true)
            self.img_center:setVisible(true)
        end
    elseif self.selectIndex==2 then
        self.list_club:setVisible(true)
        self.list_friends:setVisible(false)
        self.img_friend_mask:setVisible(true)
        self.img_club_mask:setVisible(false)
        if self.clubCount==0 then
            self.emty:setVisible(true)
            self.bnt_intive:setVisible(false)
            self.img_bottom:setVisible(false)
            self.img_center:setVisible(false)
            self.emty:getChildByName("txt_tips"):setString("None of your club members are currently online.")
        else
            self.emty:setVisible(false)
            self.bnt_intive:setVisible(true)
            self.img_bottom:setVisible(true)
            self.img_center:setVisible(true)
        end
    end
    self:updateSelect()
end

function InvitationLayer:changeSelect()
    self.isAll[self.selectIndex]=not self.isAll[self.selectIndex]
    self:updateSelect()
end

function InvitationLayer:updateSelect()
    self.sp_select:setVisible(self.isAll[self.selectIndex])
    local childs
    if self.selectIndex==1 then
        childs = self.list_friends:getChildren()
    else
        childs = self.list_club:getChildren()
    end

    for _, head in ipairs(childs) do
       head:setAllselect(self.isAll[self.selectIndex])
    end
end
function InvitationLayer:complete()
    local userId={}
    for k,v in pairs(self.invite_list) do
        if v then
            userId[#userId+1]=k
        end
    end
    if #userId>0 then 
        bole.socket:send(bole.SEND_ROOM_INVITATION,{target_uid=userId})
        self:removeFromParent()
    end
end
function InvitationLayer:setCell(user_id,isClick)
    self.invite_list[user_id]=isClick
    dump(self.invite_list,"self.invite_list")
end
function InvitationLayer:touchEvent(sender, eventType)
    local name = sender:getName()
    local tag = sender:getTag()
    print("touchEvent:" .. name)
    if eventType == ccui.TouchEventType.began then
        print("Touch Down")
    elseif eventType == ccui.TouchEventType.moved then
        print("Touch Move")
    elseif eventType == ccui.TouchEventType.ended then
        print("Touch Up")
        if name == "btn_close" then
            self:closeUI()
        elseif name == "bnt_intive" then
            self:complete()
        elseif name == "img_friend" then
            self:selectList(1)
        elseif name == "img_club" then
            self:selectList(2)
        elseif name == "img_select" then
            self:changeSelect()
        end
    elseif eventType == ccui.TouchEventType.canceled then
        print("Touch Cancelled")
    end
end

return InvitationLayer


--endregion
