-- region *.lua
-- Date
-- 此文件由[BabeLua]插件自动生成

local ClubJoinCell = class("ClubJoinCell", ccui.Layout)
local COLOR_0 = { r = 22, g = 71, b = 137 }
local COLOR_1 = { r = 0, g = 29, b = 82 }
local COLOR_2 = { r = 255, g = 255, b = 255 }
local COLOR_3 = { r = 254, g = 174, b = 116 }
function ClubJoinCell:ctor(data,league_level)
    bole.socket:registerCmd("deal_club_invitation", self.reInvitation, self)
    self.data_ = data
    self.cell_type = 3
    self:setContentSize( { width = 1065, height = 114 })
    self.node = cc.CSLoader:createNode("csb/club_cell/ClubJoinCell.csb")
    self:addChild(self.node)
    self:setTouchEnabled(true)
    self:setSwallowTouches(false)
    self:addTouchEventListener(handler(self, self.touchEvent))
    self.league_level=league_level
    self.club_id=data.id
    local root = self.node:getChildByName("root")

    self.img_bg = root:getChildByName("img_bg")
    self.img_bg:loadTexture("club/club_join_item03.png")

    local txt_name = root:getChildByName("txt_name")
    txt_name:setString(data.name)

    local img_icon = root:getChildByName("img_icon")
    -- 测试代码
    
    local icon_path = bole:getClubIconStr(data.icon)
    if icon_path ~= nil then
        img_icon:loadTexture(icon_path)
    else
        img_icon:loadTexture(bole:getClubIconStr("10" ..(data.icon % 5 + 1)))
    end
    local txt_tips = root:getChildByName("txt_tips")
    local node_head = root:getChildByName("node_head")
    local nHead=bole:getNewHeadView({name="none",user_id=data.leader_id})
    nHead:updatePos(nHead.POS_CLUB_LEADER)
    node_head:addChild(nHead)
    local txt_num = root:getChildByName("txt_num")
    txt_num:setString(data.current_u_count .. "/" .. data.max_u_count)
    local img_rank = root:getChildByName("img_rank")
    local txt_rank = root:getChildByName("txt_rank")
    txt_rank:setString("Rank " .. data.league_rank)

    self.img_friend = root:getChildByName("img_friend")
    local txt_friend = self.img_friend:getChildByName("txt_friend")
    self.img_mail = root:getChildByName("img_mail")
    self.img_mail:setVisible(false)
    self.img_pending = root:getChildByName("img_pending")
    self.img_pending:setVisible(false)
    self.img_level = root:getChildByName("img_level")

    local txt_level = self.img_level:getChildByName("txt_level")
    txt_level:setString(data.require_level)

    local txt_tips = root:getChildByName("txt_tips")
    if tonumber(data.qualification)  == 0 then
        txt_tips:setString("Anyone can join")
    elseif tonumber(data.qualification)  == 1 then
        txt_tips:setString("Invite")
    end

    local txt_leader = root:getChildByName("txt_leader")
    local txt_member = root:getChildByName("txt_member")

    if self.cell_type ~= 1 then
        txt_name:setColor(COLOR_0)
        txt_leader:setColor(COLOR_3)
        txt_member:setColor(COLOR_3)
        txt_rank:setColor(COLOR_1)
    end

    if tonumber(data.applied) == 1 then
        self.img_level:setVisible(false)
        self.img_pending:setVisible(true)
        self.img_bg:loadTexture("club/club_join_item02.png")
    end

    if data.inviter == 1 then
        self.img_level:setVisible(false)
        self.img_mail:setVisible(true)
        self.img_bg:loadTexture("club/club_join_item01.png")
    end
end

function ClubJoinCell:touchEvent(sender, eventType)
    local name = sender:getName()
    local tag = sender:getTag()
    print("touchEvent:" .. name)
    if eventType == ccui.TouchEventType.began then
        print("Touch Down")
        
    elseif eventType == ccui.TouchEventType.moved then
        print("Touch Move")
    elseif eventType == ccui.TouchEventType.ended then
        print("Touch Up")
        local bPos=sender:getTouchBeganPosition()
        local ePos=sender:getTouchEndPosition()
        if math.abs(bPos.y-ePos.y)<50 then
            --bole:getClubControl():showClubInfo(self.club_id)
            if self.data_.inviter == 1 then
                bole:getUIManage():openClubTipsView(17,function() self:sendInviteApp(1) end, function() self:sendInviteApp(0) end) 
            else
                bole:getUIManage():openUI("ClubInfoLayer",true,"csb/club")
                bole:postEvent("initClubInfoId",self.club_id)
            end
        end
    elseif eventType == ccui.TouchEventType.canceled then
        print("Touch Cancelled")
    end
end

function ClubJoinCell:sendInviteApp(re)
    bole.socket:send("deal_club_invitation",{result = re , club_id = self.club_id},true) 
end

function ClubJoinCell:reInvitation(t,data)
        if data.error ~= nil then
            if data.error == 6 then
                bole:getUIManage():openClubTipsView(7,nil)
            end
        end

        if data.id ~= nil then
            bole:postEvent("applyJoiningClubNow", data)
        end
end

function ClubJoinCell:refreshStatus()
        self.img_level:setVisible(false)
        self.img_pending:setVisible(true)
        self.img_bg:loadTexture("club/club_join_item02.png")
end

return ClubJoinCell

-- endregion
