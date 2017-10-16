-- region *.lua
-- Date
-- 此文件由[BabeLua]插件自动生成

local ClubLeagueCell = class("ClubLeagueCell", ccui.Layout)
function ClubLeagueCell:ctor(index, data, nextData)
    dump("ClubLeagueCell-data")
    self.cell_type = 3
    self.node = cc.CSLoader:createNode("club/ClubLeagueCell.csb")
    self:addChild(self.node)
    local root = self.node:getChildByName("root")
    self:setContentSize(root:getContentSize())
    root:setTouchEnabled(true)
    root:setSwallowTouches(false)
    root:addTouchEventListener(handler(self, self.touchEvent))

    self.club_id = data.id
    local img_bg1 = root:getChildByName("img_bg1")
    local img_bg2 = root:getChildByName("img_bg2")
    local img_bg3 = root:getChildByName("img_bg3")
    local img_one = root:getChildByName("img_one")
    local img_two = root:getChildByName("img_two")
    img_bg1:setVisible(false)
    img_bg2:setVisible(false)
    img_bg3:setVisible(false)
    img_two:setVisible(false)
    img_one:setVisible(false)

    local txt_rank = root:getChildByName("txt_rank")
--    index=math.random(-5,5)
    txt_rank:setString(index)
    txt_rank:setVisible(false)
    if index == 1 then
        img_one:setVisible(true)
    elseif index == 2 then
        img_two:setVisible(true)
    else
        txt_rank:setVisible(true)
    end

    local txt_num = root:getChildByName("txt_num")
    txt_num:setString(data.current_u_count .. "/" .. data.max_u_count)
    local txt_name = root:getChildByName("txt_name")
    txt_name:setString(data.name)
    local txt_reward = root:getChildByName("txt_reward")
    txt_reward:setString(data.league_point)

    local img_level = root:getChildByName("img_level")
    local txt_level = img_level:getChildByName("txt_level")
    txt_level:setString(data.level)


    local img_change = root:getChildByName("img_change")
    local img_changeup = root:getChildByName("img_changeup")
    local img_changedown = root:getChildByName("img_changedown")
    img_change:setVisible(false)
    img_changeup:setVisible(false)
    img_changedown:setVisible(false)

    
    self.sp_tips = root:getChildByName("sp_tips")
    self.sp_tips:setVisible(false)
    if data.league_rank == 0 then
        img_change:setVisible(true)
    elseif index < data.league_rank then
        img_changedown:setVisible(true)
        local txt_num = img_changedown:getChildByName("txt_num")
        txt_num:setString(data.league_rank - index)
    elseif index > data.league_rank then
        img_changeup:setVisible(true)
        local txt_num = img_changeup:getChildByName("txt_num")
        txt_num:setString(index - data.league_rank)
    elseif index == data.league_rank then
        img_change:setVisible(true)
    end

    local img_icon = root:getChildByName("img_icon")
    img_icon:loadTexture(bole:getClubManage():getClubIconPath(data.icon))


    local club = bole:getUserDataByKey("club")
    if club == self.club_id then
        img_bg1:setVisible(true)
        if index ~= 1 then
            dump(nextData,"nextData")
            if nextData then
                self.sp_tips:setVisible(true)
                local txt_num_sp = self.sp_tips:getChildByName("txt_num")
                local txt_rank_sp = self.sp_tips:getChildByName("txt_rank")
                txt_rank_sp:setString(index - 1)
                txt_num_sp:setString(nextData.league_point - data.league_point)
            end

        end
    else
        if index % 2 == 1 then
            img_bg2:setVisible(true)
        else
            img_bg3:setVisible(true)
        end
    end
end

function ClubLeagueCell:touchEvent(sender, eventType)
    local name = sender:getName()
    local tag = sender:getTag()
    print("touchEvent:" .. name)
    if eventType == ccui.TouchEventType.began then
        print("Touch Down")

    elseif eventType == ccui.TouchEventType.moved then
        print("Touch Move")
    elseif eventType == ccui.TouchEventType.ended then
        print("Touch Up")
        local bPos = sender:getTouchBeganPosition()
        local ePos = sender:getTouchEndPosition()
        if math.abs(bPos.y - ePos.y) < 50 then
             bole:getUIManage():openClubInfoLayer(self.club_id)
        end
    elseif eventType == ccui.TouchEventType.canceled then
        print("Touch Cancelled")
    end
end
return ClubLeagueCell

-- endregion
