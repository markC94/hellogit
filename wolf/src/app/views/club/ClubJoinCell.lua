-- region *.lua
-- Date
-- 此文件由[BabeLua]插件自动生成

local ClubJoinCell = class("ClubJoinCell", ccui.Layout)

local COLOR_0 = { r = 255, g = 255, b = 255 }
local COLOR_1 = { r = 3, g = 27, b = 84 }
local COLOR_2 = { r = 24, g = 50, b = 73 }

function ClubJoinCell:ctor(data)
    
    self.cell_type = 3
    self:setContentSize( { width = 1150 , height = 98 })
    self.node = cc.CSLoader:createNode("club/ClubJoinCell.csb")
    self:addChild(self.node)
    self:setTouchEnabled(true)
    self:setSwallowTouches(false)
    self:addTouchEventListener(handler(self, self.touchEvent))

    local root = self.node:getChildByName("root")
    self.img_bg = root:getChildByName("img_bg")
    self.txt_name = root:getChildByName("txt_name")
    self.img_icon = root:getChildByName("img_icon")
    self.txt_tips = root:getChildByName("txt_tips")
    self.node_head = root:getChildByName("node_head")
    self.img_friend = root:getChildByName("img_friend")
    self.txt_num = root:getChildByName("txt_num")
    self.img_rank = root:getChildByName("img_rank")
    self.txt_rank = root:getChildByName("txt_rank")
    self.img_mail = root:getChildByName("img_mail")
    self.img_pending = root:getChildByName("img_pending")
    self.img_level = root:getChildByName("img_level")
    self.txt_leader = root:getChildByName("txt_leader")
    self.txt_member = root:getChildByName("txt_member")

    self.friend_txt = self.img_friend:getChildByName("txt_friend")
    self.mail_txt = self.img_mail:getChildByName("txt_name")
    self.pending_txt = self.img_pending:getChildByName("txt_name")

    self:refreshClubInfo(data)
end

function ClubJoinCell:refreshClubInfo(data)
    self.data_ = data

    self.img_bg:loadTexture("loadImage/club_join_item_normal.png")
    self.txt_name:setString(self.data_.name)
    self.img_rank:loadTexture(bole:getClubManage():getLeagueIconPath(self.data_.league_level))

    self.img_icon:loadTexture(bole:getClubManage():getClubIconPath(data.icon))
 
    if tonumber(self.data_.qualification)  == 0 then
        self.txt_tips:setString("Anyone can join")
    elseif tonumber(self.data_.qualification)  == 1 then
        self.txt_tips:setString("Invite Only")
    end

    local nHead=bole:getNewHeadView({name="none",user_id=self.data_.leader_id,icon=self.data_.leader_icon})
    nHead:updatePos(nHead.POS_CLUB_LEADER)
    self.node_head:removeAllChildren()
    self.node_head:addChild(nHead)

    self.txt_num:setString(self.data_.current_u_count .. "/" .. self.data_.max_u_count)

    self.txt_rank:setString("Rank " .. self.data_.league_rank)

    if self.data_.friends_count ~= nil then
        self.img_friend:getChildByName("txt_friend"):setString(self.data_.friends_count)
    else
        self.img_friend:setVisible(false)
    end

    self.img_mail:setVisible(false)
    self.img_pending:setVisible(false)

    self.img_level:getChildByName("txt_level"):setString( self.data_.require_level)

    if tonumber(self.data_.applied) == 1 then
        self.img_level:setVisible(false)
        self.img_pending:setVisible(true)
        self.img_bg:loadTexture("loadImage/club_join_item_ask.png")
        self.cell_type = 1
    end

    if self.data_.inviter == 1 then
        self.img_level:setVisible(false)
        self.img_mail:setVisible(true)
        self.img_bg:loadTexture("loadImage/club_join_item_invited.png")
        self.cell_type = 1
    end

    if self.cell_type == 1 then
        --self.txt_name:setTextColor(COLOR_0)
        --self.txt_name:enableOutline(COLOR_0)
        --self.txt_tips:setTextColor(COLOR_0)
        --self.txt_num:setTextColor(COLOR_0)
        --self.txt_rank:setTextColor(COLOR_0)
        --self.txt_member:setTextColor(COLOR_0)
        --self.txt_member:enableOutline(COLOR_0)
        --self.friend_txt:setTextColor(COLOR_0)
        --self.mail_txt:setTextColor(COLOR_0)
        --self.pending_txt:setTextColor(COLOR_0)
        --self.img_friend:loadTexture("loadImage/club_join_friendIcon2.png")
    else
        --self.txt_name:setTextColor(COLOR_2)
        --self.txt_name:enableOutline(COLOR_2)
        --self.txt_tips:setTextColor(COLOR_1)
        --self.txt_num:setTextColor(COLOR_2)
        --self.txt_rank:setTextColor(COLOR_2)
        --self.txt_member:setTextColor(COLOR_2)
        --self.txt_member:enableOutline(COLOR_2)
        --self.friend_txt:setTextColor(COLOR_2)
        --self.mail_txt:setTextColor(COLOR_2)
        --self.pending_txt:setTextColor(COLOR_2)
        --self.img_friend:loadTexture("loadImage/club_join_friendIcon1.png")
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
            bole:getUIManage():openClubInfoLayer(self.data_.id)
        end
    elseif eventType == ccui.TouchEventType.canceled then
        print("Touch Cancelled")
    end
end


function ClubJoinCell:refreshStatus()
        self.img_level:setVisible(false)
        self.img_pending:setVisible(true)
        self.img_bg:loadTexture("loadImage/shop_itemBg2.png")
end

return ClubJoinCell

-- endregion
