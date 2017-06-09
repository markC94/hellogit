--region *.lua
--Date
--此文件由[BabeLua]插件自动生成

local ClubLeagueCell = class("ClubLeagueCell", ccui.Layout)
function ClubLeagueCell:ctor(index,data)
    self.cell_type = 3
    self:setContentSize( { width = 1052, height = 110 })
    self.node = cc.CSLoader:createNode("csb/club_cell/ClubLeagueCell.csb")
    self:addChild(self.node)
    self:setTouchEnabled(true)
    self:setSwallowTouches(false)
    self:addTouchEventListener(handler(self, self.touchEvent))

    self.club_id=data.id
    local root = self.node:getChildByName("root")
    local txt_rank = root:getChildByName("txt_rank")
    txt_rank:setString(index)
    local txt_num = root:getChildByName("txt_num")
    txt_num:setString(data.current_u_count.."/"..data.max_u_count)
    local txt_name = root:getChildByName("txt_name")
    txt_name:setString(data.name)
    local txt_reward = root:getChildByName("txt_reward")
    txt_reward:setString(data.league_point)

    local img_level = root:getChildByName("img_level")
    local txt_level = img_level:getChildByName("txt_level")
    txt_level:setString(data.level)

    
    local img_change = root:getChildByName("img_change")
    if data.league_rank==0 then
        img_change:loadTexture("club/league_stay.png")
    elseif index>data.league_rank then
        img_change:loadTexture("club/down.png")
    elseif index<data.league_rank then
        img_change:loadTexture("club/up.png")
    elseif index==data.league_rank then
        img_change:loadTexture("club/league_stay.png")
    end

    local img_icon = root:getChildByName("img_icon")
    -- 测试代码
    
    local icon_path = bole:getClubIconStr(data.icon)
    if icon_path ~= nil then
        img_icon:loadTexture(icon_path)
    else
        img_icon:loadTexture(bole:getClubIconStr("10" ..(data.icon % 5 + 1)))
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
        local bPos=sender:getTouchBeganPosition()
        local ePos=sender:getTouchEndPosition()
        if math.abs(bPos.y-ePos.y)<50 then
            --bole:getClubControl():showClubInfo(self.club_id)
            bole:getUIManage():openUI("ClubInfoLayer",true,"csb/club")
            bole:postEvent("initClubInfoId",self.club_id)
        end
    elseif eventType == ccui.TouchEventType.canceled then
        print("Touch Cancelled")
    end
end
return ClubLeagueCell

--endregion
