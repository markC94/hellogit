-- region *.lua
-- Date
-- 此文件由[BabeLua]插件自动生成
local ClubLeagueLayer = class("ClubLeagueLayer", cc.load("mvc").ViewBase)
function ClubLeagueLayer:onCreate()
    print("ClubLeagueLayer-onCreate")
    local root = self:getCsbNode():getChildByName("root")
    local btn_close = root:getChildByName("btn_close")
    btn_close:addTouchEventListener(handler(self, self.touchEvent))
    self.list_club = root:getChildByName("list_club")
    local top = root:getChildByName("top")
    self.list_reward = top:getChildByName("list_reward")
    local img_rankbg = top:getChildByName("img_rankbg")
    img_rankbg:setTouchEnabled(true)
    img_rankbg:addTouchEventListener(handler(self, self.touchEvent))

    local img_bg2 = top:getChildByName("img_bg2")

    self:initTime(img_bg2)

    local function update(dt)
        self:updateTime(dt)
    end
    self:onUpdate(update)
end

function ClubLeagueLayer:initTime(root)
    self.txt_day1 = root:getChildByName("txt_day1")
    self.txt_day2 = root:getChildByName("txt_day2")
    self.txt_hour1 = root:getChildByName("txt_hour1")
    self.txt_hour2 = root:getChildByName("txt_hour2")
    self.txt_minute1 = root:getChildByName("txt_minute1")
    self.txt_minute2 = root:getChildByName("txt_minute2")
    self.txt_second1 = root:getChildByName("txt_second1")
    self.txt_second2 = root:getChildByName("txt_second2")
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
        self.txt_second1:setString(math.floor(s / 10))
        self.txt_second2:setString(math.floor(s % 10))
        self.txt_minute1:setString(math.floor(m / 10))
        self.txt_minute2:setString(math.floor(m % 10))
        self.txt_hour1:setString(math.floor(h / 10))
        self.txt_hour2:setString(math.floor(h % 10))
        self.txt_day1:setString(math.floor(d / 10))
        self.txt_day2:setString(math.floor(d % 10))
    else
        self.txt_second1:setString(0)
        self.txt_second2:setString(0)
        self.txt_minute1:setString(0)
        self.txt_minute2:setString(0)
        self.txt_hour1:setString(0)
        self.txt_hour2:setString(0)
        self.txt_day1:setString(0)
        self.txt_day2:setString(0)
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
    bole:getUIManage():openClubChestView({level=data.reward_level,rank=data.reward_rank})
end
function ClubLeagueLayer:initList(data)
    dump(data, "ClubJoinLayer:initList")
    self.list_top = data.top
    local level=data.league_level
    if not level then
        level=1
    end
    local str_index = string.format("%02d",level)
    local league = bole:getConfig("league", str_index)
    self.rank_name=league.rank_name
    for k, v in ipairs(self.list_top) do
        local cell = bole:getEntity("app.views.club.ClubLeagueCell",k,v)
        self.list_club:pushBackCustomItem(cell)
        if k==2 then
            local tips = self:newTips(true)
            self.list_club:pushBackCustomItem(tips)
        elseif k==11 then
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
    local cell = ccui.Layout:create()
    cell:ignoreContentAdaptWithSize(false)
    cell:setClippingEnabled(false)
    cell:setBackGroundColorOpacity(102)
    cell:setTouchEnabled(true);
    cell:setLayoutComponentEnabled(true)
    cell:setName("cell3")
    cell:setTag(653)
    cell:setCascadeColorEnabled(true)
    cell:setCascadeOpacityEnabled(true)
    cell:setVisible(true)
    cell:setPosition(923.6571, 596.9800)
    local layout = ccui.LayoutComponent:bindLayoutComponent(cell)
    layout:setPositionPercentX(0.6924)
    layout:setPositionPercentY(0.7960)
    layout:setPercentWidth(0.1949)
    layout:setPercentHeight(0.0587)
    layout:setSize( { width = 260.0000, height = 44.0000 })
    layout:setLeftMargin(923.6571)
    layout:setRightMargin(150.3429)
    layout:setTopMargin(109.0200)
    layout:setBottomMargin(596.9800)

    -- Create txt_num
    local txt_num = ccui.Text:create()
    txt_num:ignoreContentAdaptWithSize(true)
    txt_num:setTextAreaSize( { width = 0, height = 0 })
    txt_num:setFontName("font/FZKTJW.TTF")
    txt_num:setFontSize(32)
    txt_num:setString(index)
    txt_num:enableOutline( { r = 208, g = 107, b = 4, a = 255 }, 1)
    txt_num:setLayoutComponentEnabled(true)
    txt_num:setName("txt_num")
    txt_num:setTag(654)
    txt_num:setCascadeColorEnabled(true)
    txt_num:setCascadeOpacityEnabled(true)
    txt_num:setPosition(27.7720, 24.4834)
    txt_num:setTextColor( { r = 208, g = 107, b = 4 })
    layout = ccui.LayoutComponent:bindLayoutComponent(txt_num)
    layout:setPositionPercentX(0.1068)
    layout:setPositionPercentY(0.5564)
    layout:setPercentWidth(0.0538)
    layout:setPercentHeight(0.8409)
    layout:setSize( { width = 14.0000, height = 37.0000 })
    layout:setLeftMargin(20.7720)
    layout:setRightMargin(225.2280)
    layout:setTopMargin(1.0166)
    layout:setBottomMargin(5.9834)
    cell:addChild(txt_num)

    -- Create txt_reward
    local txt_reward = ccui.Text:create()
    txt_reward:ignoreContentAdaptWithSize(true)
    txt_reward:setTextAreaSize( { width = 0, height = 0 })
    txt_reward:setFontName("font/FZKTJW.TTF")
    txt_reward:setFontSize(30)
    txt_reward:setString(str_reward)
    txt_reward:enableOutline( { r = 208, g = 107, b = 4, a = 255 }, 1)
    txt_reward:setLayoutComponentEnabled(true)
    txt_reward:setName("txt_reward")
    txt_reward:setTag(655)
    txt_reward:setCascadeColorEnabled(true)
    txt_reward:setCascadeOpacityEnabled(true)
    txt_reward:setAnchorPoint(1.0000, 0.5000)
    txt_reward:setPosition(239.9543, 22.3968)
    txt_reward:setTextColor( { r = 208, g = 107, b = 4 })
    layout = ccui.LayoutComponent:bindLayoutComponent(txt_reward)
    layout:setPositionPercentX(0.9229)
    layout:setPositionPercentY(0.5090)
    layout:setPercentWidth(0.3769)
    layout:setPercentHeight(0.7955)
    layout:setSize( { width = 98.0000, height = 35.0000 })
    layout:setLeftMargin(141.9543)
    layout:setRightMargin(20.0458)
    layout:setTopMargin(4.1032)
    layout:setBottomMargin(4.8968)
    cell:addChild(txt_reward)

    -- Create img_1
    local img_1 = ccui.ImageView:create()
    img_1:ignoreContentAdaptWithSize(false)
    img_1:loadTexture("common/common_coin.png", 1)
    img_1:setLayoutComponentEnabled(true)
    img_1:setName("img_1")
    img_1:setTag(656)
    img_1:setCascadeColorEnabled(true)
    img_1:setCascadeOpacityEnabled(true)
    img_1:setPosition(120.4565, 24.6786)
    img_1:setScaleX(0.5600)
    img_1:setScaleY(0.5600)
    layout = ccui.LayoutComponent:bindLayoutComponent(img_1)
    layout:setPositionPercentX(0.4633)
    layout:setPositionPercentY(0.5609)
    layout:setPercentWidth(0.2385)
    layout:setPercentHeight(1.4091)
    layout:setSize( { width = 62.0000, height = 62.0000 })
    layout:setLeftMargin(89.4565)
    layout:setRightMargin(108.5435)
    layout:setTopMargin(-11.6786)
    layout:setBottomMargin(-6.3214)
    cell:addChild(img_1)

    local img_line = ccui.ImageView:create()
    img_line:loadTexture("club/league_se.png")
    img_line:setPosition(130, 4)
    cell:addChild(img_line)
    return cell
end
function ClubLeagueLayer:newTips(isTop)
    -- Create cell1
    local cell = ccui.Layout:create()
    cell:ignoreContentAdaptWithSize(false)
    cell:setClippingEnabled(false)
    cell:setBackGroundColorType(1)
    cell:setBackGroundColor( { r = 51, g = 117, b = 181 })
    cell:setTouchEnabled(true)
    cell:setLayoutComponentEnabled(true)
    cell:setName("cell1")
    cell:setTag(443)
    cell:setCascadeColorEnabled(true)
    cell:setCascadeOpacityEnabled(true)
    cell:setVisible(true)
    cell:setAnchorPoint(0.5000, 0.5000)
    cell:setPosition(684.4627, 231.3400)
    local layout = ccui.LayoutComponent:bindLayoutComponent(cell)
    layout:setPositionPercentX(0.5131)
    layout:setPositionPercentY(0.3085)
    layout:setPercentWidth(0.7886)
    layout:setPercentHeight(0.0267)
    layout:setSize( { width = 1052.0000, height = 20.0000 })
    layout:setLeftMargin(158.4627)
    layout:setRightMargin(123.5374)
    layout:setTopMargin(508.6600)
    layout:setBottomMargin(221.3400)

    -- Create Image_101
    local img_01 = ccui.ImageView:create()
    img_01:ignoreContentAdaptWithSize(false)
    if isTop then
        img_01:loadTexture("club/up.png", 0)
    else
        img_01:loadTexture("club/down.png", 0)
    end
    img_01:setLayoutComponentEnabled(true)
    img_01:setName("Image_101")
    img_01:setTag(646)
    img_01:setCascadeColorEnabled(true)
    img_01:setCascadeOpacityEnabled(true)
    img_01:setPosition(249.7701, 8.6513)
    layout = ccui.LayoutComponent:bindLayoutComponent(img_01)
    layout:setPositionPercentX(0.2374)
    layout:setPositionPercentY(0.4326)
    layout:setPercentWidth(0.0171)
    layout:setPercentHeight(0.9000)
    layout:setSize( { width = 18.0000, height = 18.0000 })
    layout:setLeftMargin(240.7701)
    layout:setRightMargin(793.2299)
    layout:setTopMargin(2.3487)
    layout:setBottomMargin(-0.3487)
    cell:addChild(img_01)

    -- Create txt_key
    local txt_key = ccui.Text:create()
    txt_key:ignoreContentAdaptWithSize(true)
    txt_key:setTextAreaSize( { width = 0, height = 0 })
    txt_key:setFontName("font/FZKTJW.TTF")
    txt_key:setFontSize(24)
    if isTop then
        txt_key:setString([[xxxxxxx]])
    else
        txt_key:setString([[xxxxxxx]])
    end
    txt_key:setLayoutComponentEnabled(true)
    txt_key:setName("txt_key")
    txt_key:setTag(648)
    txt_key:setCascadeColorEnabled(true)
    txt_key:setCascadeOpacityEnabled(true)
    txt_key:setPosition(553.9939, 12.5678)
    layout = ccui.LayoutComponent:bindLayoutComponent(txt_key)
    layout:setPositionPercentX(0.5266)
    layout:setPositionPercentY(0.6284)
    layout:setPercentWidth(0.0827)
    layout:setPercentHeight(1.3000)
    layout:setSize( { width = 87.0000, height = 26.0000 })
    layout:setLeftMargin(510.4939)
    layout:setRightMargin(454.5061)
    layout:setTopMargin(-5.5678)
    layout:setBottomMargin(-0.4322)
    cell:addChild(txt_key)

    -- Create Image_101_0
    local img_02 = ccui.ImageView:create()
    img_02:ignoreContentAdaptWithSize(false)
    if isTop then
        img_02:loadTexture("club/up.png", 0)
    else
        img_02:loadTexture("club/down.png", 0)
    end
    img_02:setLayoutComponentEnabled(true)
    img_02:setName("Image_101_0")
    img_02:setTag(647)
    img_02:setCascadeColorEnabled(true)
    img_02:setCascadeOpacityEnabled(true)
    img_02:setPosition(841.1044, 8.7515)
    layout = ccui.LayoutComponent:bindLayoutComponent(img_02)
    layout:setPositionPercentX(0.7995)
    layout:setPositionPercentY(0.4376)
    layout:setPercentWidth(0.0171)
    layout:setPercentHeight(0.9000)
    layout:setSize( { width = 18.0000, height = 18.0000 })
    layout:setLeftMargin(832.1044)
    layout:setRightMargin(201.8956)
    layout:setTopMargin(2.2485)
    layout:setBottomMargin(-0.2485)
    cell:addChild(img_02)
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
        elseif name == "img_rankbg" then
            bole:getUIManage():openClubRankView(self.rank_name)
        end
    elseif eventType == ccui.TouchEventType.canceled then
        print("Touch Cancelled")
        sender:setScale(1)
    end
end
return ClubLeagueLayer
-- endregio