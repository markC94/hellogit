-- region *.lua
-- Date
-- 此文件由[BabeLua]插件自动生成
local ClubLeagueLayer = class("ClubLeagueLayer", cc.load("mvc").ViewBase)
function ClubLeagueLayer:onCreate()
    print("ClubLeagueLayer-onCreate")
    local root = self:getCsbNode():getChildByName("root")
    self.cell1 = root:getChildByName("cell1")
    self.cell2 = root:getChildByName("cell2")
    self.cell3 = root:getChildByName("cell3")
    self.cell4 = root:getChildByName("cell4")
    local btn_close = root:getChildByName("btn_close")
    btn_close:addTouchEventListener(handler(self, self.touchEvent))
    self.list_club = root:getChildByName("list_club")
    local top = root:getChildByName("top")
    self.list_reward = top:getChildByName("list_reward")

    local node_rank = top:getChildByName("node_rank")
    self.img_rank = node_rank:getChildByName("img_rank")
    self.img_rank:setTouchEnabled(true)
    self.img_rank:addTouchEventListener(handler(self, self.touchEvent))

    local time = top:getChildByName("time")

    self:initTime(time)

    local function update(dt)
        self:updateTime(dt)
    end
    self:onUpdate(update)

end

function ClubLeagueLayer:onKeyBack()
    self:closeUI()
end

function ClubLeagueLayer:initTime(root)
    self.txt_d1 = root:getChildByName("txt_d1")
    self.txt_d2 = root:getChildByName("txt_d2")
    self.txt_h1 = root:getChildByName("txt_h1")
    self.txt_h2 = root:getChildByName("txt_h2")
    self.txt_m1 = root:getChildByName("txt_m1")
    self.txt_m2 = root:getChildByName("txt_m2")
    self.txt_s1 = root:getChildByName("txt_s1")
    self.txt_s2 = root:getChildByName("txt_s2")
end
function ClubLeagueLayer:updateTime(dt)
    if not self.delayTime then
        return
    end
    self.delayTime = self.delayTime - dt
    if self.delayTime > 0 then
        local s = math.floor(self.delayTime) % 60
        local m = math.floor(self.delayTime / 60) % 60
        local h = math.floor(self.delayTime / 3600) % 24
        local d = math.floor(self.delayTime / 3600 / 24)
        if d > 9 then
            self.txt_d1:setString(math.floor(d / 10))
            self.txt_d2:setString(d % 10)
        else
            self.txt_d1:setString("0")
            self.txt_d2:setString(d)
        end
        if h > 9 then
            self.txt_h1:setString(math.floor(h / 10))
            self.txt_h2:setString(h % 10)
        else
            self.txt_h1:setString("0")
            self.txt_h2:setString(h)
        end
        if m > 9 then
            self.txt_m1:setString(math.floor(m / 10))
            self.txt_m2:setString(m % 10)
        else
            self.txt_m1:setString("0")
            self.txt_m2:setString(m)
        end
        if s > 9 then
            self.txt_s1:setString(math.floor(s / 10))
            self.txt_s2:setString(s % 10)
        else
            self.txt_s1:setString("0")
            self.txt_s2:setString(s)
        end
    else
        self.txt_d1:setString("0")
        self.txt_d2:setString("0")
        self.txt_h1:setString("0")
        self.txt_h2:setString("0")
        self.txt_m1:setString("0")
        self.txt_m2:setString("0")
        self.txt_s1:setString("0")
        self.txt_s2:setString("0")
    end
end
function ClubLeagueLayer:updateUI(data)
    self:initList(data.result)
    self:initReward(data.result)
end
function ClubLeagueLayer:initReward(data)
    if data.reward_level == 0 then
        return
    end
    bole:getUIManage():openClubChestView( { level = data.reward_level, rank = data.reward_rank })
end
function ClubLeagueLayer:initList(data)
    dump(data, "ClubJoinLayer:initList")
    self.list_top = data.top
    local level = data.league_level
    if not level then
        level = 1
    end
    if data.league_level then
        bole:setUserDataByKey("league_level",data.league_level)
    end
    if data.league_rank then
        bole:setUserDataByKey("league_rank",data.league_rank)
    end
    bole:postEvent("update_lobby_league")

    local str_index = string.format("%02d", level)
    local league = bole:getConfig("league", str_index)
    self.rank_name = league.rank_name
    local rank_path="league_rank/club_lvl_0" .. league.rank_level .. ".png"
    print(rank_path)
    self.img_rank:loadTexture(rank_path)
    for k, v in ipairs(self.list_top) do
        local cell = bole:getEntity("app.views.club.ClubLeagueCell", k, v,self.list_top[k-1])
        self.list_club:pushBackCustomItem(cell)
        if k == 2 then
            local tips = self:newTips(true)
            self.list_club:pushBackCustomItem(tips)
        elseif k == 11 then
            local tips = self:newTips(false)
            self.list_club:pushBackCustomItem(tips)
        end
    end

    for i = 1, 15 do
        local reward = 0
        if i < 3 then
            reward = league.rank1bonus
        elseif i < 6 then
            reward = league.rank2bonus
        elseif i < 12 then
            reward = league.rank3bonus
        else
            reward = league.rank4bonus
        end
        local cell = self:newCell(i, bole:formatCoins(reward, 4))
        self.list_reward:pushBackCustomItem(cell)
    end

    self.delayTime = data.leave
end
function ClubLeagueLayer:newCell(index, str_reward)
    -- Create cell
    local cell
    if index >= 3 then
        cell = self.cell4:clone()
        local txt_num = cell:getChildByName("txt_num")
        txt_num:setString(index)
    else
        cell = self.cell3:clone()
        if index == 1 then
            local img_two = cell:getChildByName("img_two")
            img_two:setVisible(false)
        else
            local img_one = cell:getChildByName("img_one")
            img_one:setVisible(false)
        end
    end
    cell:setVisible(true)
    local txt_reward = cell:getChildByName("txt_reward")
    txt_reward:setString(str_reward)
    return cell
    
end
function ClubLeagueLayer:newTips(isTop)
    -- Create cell1
    local cell
    if isTop then
        cell = self.cell1:clone()
--        local tipAct = sp.SkeletonAnimation:create("club_act/up_1.json", "club_act/up_1.atlas")
--        tipAct:setAnimation(0, "animation", true)
--        tipAct:setPosition(526, 10)
--        cell:addChild(tipAct)
    else
        cell = self.cell2:clone()
--        local tipAct = sp.SkeletonAnimation:create("club_act/down_1.json", "club_act/down_1.atlas")
--        tipAct:setAnimation(0, "animation", true)
--        tipAct:setPosition(526, 10)
--        cell:addChild(tipAct)
    end
    cell:setVisible(true)
    return cell
end

function ClubLeagueLayer:touchEvent(sender, eventType)
    local name = sender:getName()
    local tag = sender:getTag()
    print("touchEvent:" .. name)
    if eventType == ccui.TouchEventType.began then
        print("Touch Down")
        sender:setScale(1.05)
    elseif eventType == ccui.TouchEventType.moved then
        print("Touch Move")
    elseif eventType == ccui.TouchEventType.ended then
        print("Touch Up")
        sender:setScale(1)
        if name == "btn_close" then
            self:closeUI()
        elseif name == "img_rank" then
            bole:getUIManage():openClubRankView(self.rank_name)
        end
    elseif eventType == ccui.TouchEventType.canceled then
        print("Touch Cancelled")
        sender:setScale(1)
    end
end
return ClubLeagueLayer
-- endregio