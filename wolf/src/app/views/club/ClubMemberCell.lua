-- region *.lua
-- Date
-- 此文件由[BabeLua]插件自动生成

local ClubMemberCell = class("ClubMemberCell", cc.Node)
function ClubMemberCell:ctor(data,index)
    self.node = cc.CSLoader:createNode("club/ClubMemberCell.csb")
    self:addChild(self.node)
    local root = self.node:getChildByName("img_bg")
    self.bg_ = root
    self.txt_num = root:getChildByName("txt_num")
    self.txt_name = root:getChildByName("txt_name")

    if tonumber(data.club_title) == 1 then
        self.txt_name:setString("Leader")
        self.bg_:loadTexture("loadImage/club_members_bg1.png")
        self.txt_num:setTextColor({ r = 40, g = 51, b = 76})
    elseif tonumber(data.club_title) == 3 or tonumber(data.club_title) == 0 then
        self.txt_name:setString("Member")
        self.bg_:loadTexture("loadImage/club_members_bg2.png")
        self.txt_num:setTextColor({ r = 255, g = 255, b = 255})
    elseif tonumber(data.club_title) == 2 then
        self.txt_name:setString("Co_leader")
        self.bg_:loadTexture("loadImage/club_members_bg3.png")
        self.txt_num:setTextColor({ r = 40, g = 51, b = 76})
    end
    
    if data.user_id == bole:getUserDataByKey("user_id") then
        self.bg_:loadTexture("loadImage/club_frame_member_light.png")
    end

    local sp_cj = root:getChildByName("sp_cj")
    local sp_pig = root:getChildByName("sp_pig")
   
    self.txt_ach = root:getChildByName("sp_ach"):getChildByName("txt_ach")
    self.txt_pig = root:getChildByName("sp_pig"):getChildByName("txt_pig")
    if data.donate == nil then
        data.donate = 0
    end

    if data.league_point == nil then
        data.league_point = 0
    end
    self.txt_ach:setString((bole:formatCoins(tonumber(data.league_point),5)))
    self.txt_pig:setString((bole:formatCoins(tonumber(data.donate),5)))

    local node_head = root:getChildByName("node_head")
    local nHead = bole:getNewHeadView(data)
    nHead:updatePos(nHead.POS_CLUB_MEMBER)
    nHead:setScale(0.8)
    self.nHead_ = nHead
    node_head:addChild(nHead)
    self.txt_num:setString(index)
    
    self:updateInfo(data,index)
end

function ClubMemberCell:updateInfo(data,index)
     
    if tonumber(data.club_title) == 1 then
        self.txt_name:setString("Leader")
        self.bg_:loadTexture("loadImage/club_members_bg1.png")
        self.txt_num:setTextColor({ r = 40, g = 51, b = 76})
    elseif tonumber(data.club_title) == 3 or tonumber(data.club_title) == 0 then
        self.txt_name:setString("Member")
        self.bg_:loadTexture("loadImage/club_members_bg2.png")
        self.txt_num:setTextColor({ r = 255, g = 255, b = 255})
    elseif tonumber(data.club_title) == 2 then
        self.txt_name:setString("Co_leader")
        self.bg_:loadTexture("loadImage/club_members_bg3.png")
        self.txt_num:setTextColor({ r = 40, g = 51, b = 76})
    end
    if data.user_id == bole:getUserDataByKey("user_id") then
        self.bg_:loadTexture("loadImage/club_frame_member_light.png")
    end

    if data.donate == nil then
        data.donate = 0
    end

    if data.league_point == nil then
        data.league_point = 0
    end
    self.txt_ach:setString((bole:formatCoins(tonumber(data.league_point),5)))
    self.txt_pig:setString((bole:formatCoins(tonumber(data.donate),5)))

    if self.nHead_ ~= nil then
        self.nHead_:updateInfo(data)
    end
   
    self.txt_num:setString(index)
end

function ClubMemberCell:updateNum(num)
    self.txt_num:setString(num)
end

function ClubMemberCell:updateName(name,num)
    self.txt_name:setString(name)
end

function ClubMemberCell:updateAch(ach)
    self.txt_ach:setString((bole:formatCoins(ach,5)))
end
function ClubMemberCell:updatePig(pig)
    self.txt_pig:setString((bole:formatCoins(ach,5)))
end
function ClubMemberCell:touchEvent(sender, eventType)
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

return ClubMemberCell

-- endregion
