--region *.lua
--Date
--此文件由[BabeLua]插件自动生成
local InvitationLayer = class("InvitationLayer", cc.Node)
--cell start
local InvitationCell = class("InvitationCell",ccui.Layout)
function InvitationCell:ctor(node,data1,data2)
    self.node=node
    self:setContentSize({ width = 483, height = 140 })
    local index=0
    self.data={}
    if data1 then
        index=index+1
        self:newCell(data1,index)
    end
    if data2 then
        index=index+1
        self:newCell(data2,index)
    end
    local left=ccui.Layout:create()
    left:setName("left")
    left:setContentSize({ width = 241, height = 140 })
    left:setTouchEnabled(true)
    left:addTouchEventListener(handler(self, self.touchEvent))
    self:addChild(left,1)
    local right=ccui.Layout:create()
    right:setName("right")
    right:setContentSize({ width = 242, height = 140 })
    right:setTouchEnabled(true)
    right:addTouchEventListener(handler(self, self.touchEvent))
    right:setPosition(241,0)
    self:addChild(right,1)
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
        if name=="right"then
            self:clickCell(2)
        elseif name== "left" then
            self:clickCell(1)
        end
    elseif eventType == ccui.TouchEventType.canceled then
        print("Touch Cancelled")
    end
end
function InvitationCell:newCell(data,index)
    local head=bole:getNewHeadView(data)
    self:addChild(head)
    head:setSwallow(false)
    head:updatePos(head.POS_INTIVE_FRIEND)
    head:setScale(0.8)
    local sp_bg=display.newSprite("friend/MF_check02.png")
    self:addChild(sp_bg)
    local sp_select=display.newSprite("friend/MY_check01.png")
    self:addChild(sp_select)
    sp_select:setVisible(false)
    self.data[index]={}
    self.data[index].user_id=data.user_id
    self.data[index].node=sp_select
    self.data[index].isSelect=false
    if index==1 then
        head:setPosition(80,70)
        sp_bg:setPosition(188,62)
        sp_select:setPosition(190,60)
    else
        head:setPosition(310,70)
        sp_bg:setPosition(417,62)
        sp_select:setPosition(419,60)
    end
end
function InvitationCell:clickCell(index)
    if self.data[index] then
        self.data[index].isSelect=not self.data[index].isSelect 
        self.data[index].node:setVisible(self.data[index].isSelect)
        self.node:setCell(self.data[index].user_id,self.data[index].isSelect)
    end
end
--cell end


----------------------------------------start-------------------------------------
function InvitationLayer:ctor()
    self.node_input = cc.CSLoader:createNode("csb/InvitationLayer.csb")
    self:addChild(self.node_input)
    local root = self.node_input:getChildByName("root")
    local btn_ok = root:getChildByName("btn_ok")
    btn_ok:addTouchEventListener(handler(self, self.touchEvent))
    local btn_close = root:getChildByName("btn_close")
    btn_close:addTouchEventListener(handler(self, self.touchEvent))
    self.list_friends = root:getChildByName("list_friends")
    self.list_club = root:getChildByName("list_club")
    self.invite_list={}
    self:registerScriptHandler( function(tag)
        if "enter" == tag then
            self:onEnter()
        elseif "exit" == tag then
            self:onExit()
        end
    end )
    self.user_id=bole:getUserDataByKey("user_id")
    bole.socket:send("sync_friends_info",{},true)
    bole.socket:send("enter_club_lobby",{},true)
end
function InvitationLayer:onEnter()
    bole.socket:registerCmd("enter_club_lobby", self.reClub, self)
    bole.socket:registerCmd("sync_friends_info", self.initFriendInfo, self)
end

function InvitationLayer:onExit()
    bole.socket:unregisterCmd("sync_friends_info")
    bole.socket:unregisterCmd("enter_club_lobby")
end

function InvitationLayer:initFriendInfo(t, data)
    dump(data,"friend")
    if t == "sync_friends_info" then
        if data.f_applications ~= nil then

        end

        if data.friends ~= nil then
            for k,v in ipairs(data.friends) do
                self:addCell(v)
            end
            self:endCell()
        end

        if data.fbfriends ~= nil then
            for k,v in ipairs(data.fbfriends) do
                self:addCell(v)
            end
            self:endCell()
        end
    end
end

function InvitationLayer:reClub(t, data)
    if t == "enter_club_lobby" then
        if data.in_club == 0 then
            --未加入联盟
            
        elseif data.in_club == 1 then
            --已加入联盟
            for k,v in ipairs(data.club_info.users) do
                self:addCell(v,1)
            end
            self:endCell(1)
        end
    end
end
function InvitationLayer:addCell(data,flag)
    --如果没在线返回
    if data.online==0 then
        return
    end
    --如果是自己返回
    if data.user_id==self.user_id then
        return
    end
    if self.tempCell then
        local cell=InvitationCell:create(self,self.tempCell,data)
        if flag==1 then
            self.list_club:pushBackCustomItem(cell)
        else
            self.list_friends:pushBackCustomItem(cell)
        end
        self.tempCell=nil
    else
        self.tempCell=data
    end
end
function InvitationLayer:endCell(flag)
    if self.tempCell then
        local cell=InvitationCell:create(self,self.tempCell)
        if flag==1 then
            self.list_club:pushBackCustomItem(cell)
        else
            self.list_friends:pushBackCustomItem(cell)
        end
        self.tempCell=nil
    end
end


function InvitationLayer:complete()
    for k,v in pairs(self.invite_list) do
        if v then
            bole.socket:send(bole.SEND_ROOM_INVITATION,{target_uid=tonumber(k)})
        end
    end
    self:removeFromParent()
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
            self:removeFromParent()
        elseif name == "btn_ok" then
            self:complete()
        end
    elseif eventType == ccui.TouchEventType.canceled then
        print("Touch Cancelled")
    end
end

return InvitationLayer


--endregion
