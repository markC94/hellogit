-- region *.lua
-- Date
-- 此文件由[BabeLua]插件自动生成

local ClubMemberCell = class("ClubMemberCell", cc.Node)
function ClubMemberCell:ctor(data,i)
    self.node = cc.CSLoader:createNode("csb/club_cell/ClubMemberCell.csb")
    self:addChild(self.node)
    local root = self.node:getChildByName("img_bg")
    self.txt_num = root:getChildByName("txt_num")
    self.txt_name = root:getChildByName("txt_name")

    if tonumber(data.club_title) == 1 then
        self.txt_name:setString("Leader")
        self.txt_name:setTextColor({ r = 39, g = 174, b = 23})
    elseif tonumber(data.club_title) == 3 or tonumber(data.club_title) == 0 then
        self.txt_name:setString("Member")
        self.txt_name:setTextColor({ r = 39, g = 174, b = 23})
    elseif tonumber(data.club_title) == 2 then
        self.txt_name:setString("Co_leader")
       self.txt_name:setTextColor({ r = 52, g = 189, b = 255})

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
    self.txt_ach:setString(data.donate)
    self.txt_pig:setString(data.league_point)



    self.txt_pig = root:getChildByName("txt_pig")
    local node_head = root:getChildByName("node_head")
    local nHead = bole:getNewHeadView(data)
    --nHead:updatePos(nHead.POS_CLUB_LEADER)
    node_head:addChild(nHead)
    root:getChildByName("txt_num"):setString(i)
    




    self:updateInfo(data)
end

function ClubMemberCell:updateInfo(data)
       
end

function ClubMemberCell:updateNum(num)
    self.txt_num:setString(num)
end

function ClubMemberCell:updateName(name,num)
    self.txt_name:setString(name)
end

function ClubMemberCell:updateAch(ach)
    self.txt_ach:setString(ach)
end
function ClubMemberCell:updatePig(pig)
    self.txt_pig:setString(pig)
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
