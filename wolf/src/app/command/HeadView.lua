-- region *.lua
-- Date
-- 此文件由[BabeLua]插件自动生成
local HeadView = class("HeadView", cc.Node)
-- 1.大厅自己 2.大厅好友 3.升级 4.spin自己 5.spin好友 6 聊天自己 7 聊天好友
HeadView.POS_NONE = 0 --正常的头像
HeadView.POS_ONLY_HEAD = 1 --隐藏其他只显示头像
HeadView.POS_LOBBY_SELF = 2
HeadView.POS_UPLEVEL = 3
HeadView.POS_SPIN_SELF = 4
HeadView.POS_SPIN_FRIEND = 5
HeadView.POS_CHAT_SELF = 6
HeadView.POS_CHAT_FRIEND = 7
HeadView.POS_SPIN_INTIVE = 8
HeadView.POS_INFO_SELF = 9
HeadView.POS_INFO_FRIEND = 10
HeadView.POS_EDIT_SELF = 11
HeadView.POS_CLUB_FRIEND = 12
HeadView.POS_CLUB_LEADER = 13
HeadView.POS_CLUB_MEMBER = 14
HeadView.POS_CLUB_REQUEST = 15
HeadView.POS_INTIVE_FRIEND = 16
HeadView.POS_FB_FRIEND = 17
HeadView.POS_NOTICE = 18

HeadView.POS_SCALE_FRIEND = 20

HeadView.GOTO_INFO = 1 --点击显示个人信息
HeadView.GOTO_INTIVE = 2 --点击跳转邀请
HeadView.GOTO_EDIT= 3 --点击跳转编辑个人信息
HeadView.GOTO_NOTHING = 4 --点击头像无响应
HeadView.GOTO_SLOTFUNC = 5 --老虎机内菜单

local DEF_NAME_PATH = "#head/portrait_text.png"
function HeadView:ctor(data)
    if not data then
        data={}
        data.name="none"
        data.user_id=-1
    end
    self:initUI()
    self:initMove()
    self.goto_type = self.GOTO_INFO
    self.isSelf = false
    self.info={}
    if data.name then
        self:initName(data.name)
    end
    self:updateInfo(data)
    local function update(dt)
        self:updateTime(dt)
    end
    self:onUpdate(update)
end
function HeadView:initUI()
    self.headCSB = cc.CSLoader:createNode("csb/Head.csb")
    self:addChild(self.headCSB)
    self.node_head = self.headCSB:getChildByName("node_head")
    self.img_nationality = self.headCSB:getChildByName("img_nationality")
    self.img_nationality:setVisible(false)
    self.img_level = self.headCSB:getChildByName("img_level")
    self.img_level:setVisible(false)
    self.img_namebg = self.headCSB:getChildByName("img_namebg")
    self.img_namebg:setVisible(false)
    self.txt_level = self.img_level:getChildByName("txt_level")

    self.sp_money = self.headCSB:getChildByName("sp_money")
    self.txt_money = self.sp_money:getChildByName("txt_money")
    self.sp_money:setVisible(false)

    local function touchEvent(sender, eventType)
        if eventType == ccui.TouchEventType.began then
            if self.goto_type == self.GOTO_INTIVE then
                self.node_head:setScale(1.05)
            end
        elseif eventType == ccui.TouchEventType.ended then
             self:gotoView()
        elseif eventType == ccui.TouchEventType.canceled then
            if self.goto_type == self.GOTO_INTIVE then
                self.node_head:setScale(1)
            end
        end
    end

    self.Img_headbg = self.headCSB:getChildByName("Img_headbg")
    self.Img_headbg:setTouchEnabled(true)
    self.Img_headbg:addTouchEventListener(touchEvent)
end

function HeadView:gotoView()
    print("---------------show_UserInfo:" .. self.info.user_id)
    if self.goto_type == self.GOTO_INFO then
        bole:getUIManage():openInfoView(self)
    elseif self.goto_type == self.GOTO_INTIVE then
        self.node_head:setScale(1)
        bole:getInvitationInput()
    elseif self.goto_type == self.GOTO_EDIT then
        bole:getUIManage():openEditView(self.info)
    elseif self.goto_type == self.GOTO_NOTHING then
        print("HeadView:gotoView---nothing")
    elseif self.goto_type == self.GOTO_SLOTFUNC then
        bole:postEvent("openSlotFuncView", { self.Img_headbg, self })
    end
end

function HeadView:initMove()
     -- 是否需要移动
    self.isEnableUpdate = false
    -- 等待时间
    self.delayTime = 1
    -- 左停留时间
    self.timel = 0.9
    -- 右停留时间
    self.timer = 0.5
    -- 起步加速度
    self.rate = 50
    -- 移动位置 根据文字长度修改
    self.space = 50
    -- 移动坐标
    self.posX = 0
    -- 最大移动速度
    self.speedMax = 40
    -- 移动速度
    self.speed = self.speedMax
    -- 移动方向
    self.dir = 0
    self.stop_space = self.speedMax * self.speedMax / self.rate / 2
    self.isStop = false
end
function HeadView:getInfo()
    return self.info
end

function HeadView:setSwallow(flag)
    self.Img_headbg:setSwallowTouches(flag)
end
-- 初始化名字信息
function HeadView:initName(name)
    self.img_namebg:setVisible(true)
    local clipNode = cc.ClippingNode:create()
    local mask = display.newSprite("#head/common_strager_name_onlineMASK.png")
    clipNode:setAlphaThreshold(0)
    clipNode:setStencil(mask)
    clipNode:setScale(0.95)
    clipNode:setPosition(57.0000, 17.0000)
    self.txt_name = ccui.Text:create()
    self.txt_name:ignoreContentAdaptWithSize(true)
    self.txt_name:setTextAreaSize( { width = 0, height = 0 })
    self.txt_name:setFontName("font/FZKTJW.TTF")
    self.txt_name:setFontSize(26)
    self.txt_name:setString(name)
    self.txt_name:setLayoutComponentEnabled(true)
    self.txt_name:setName("txt_name")
    self.txt_name:setTag(58)
    self.txt_name:setCascadeColorEnabled(true)
    self.txt_name:setCascadeOpacityEnabled(true)
    self.txt_name:setTextColor( { r = 255, g = 255, b = 255 })
    local layout = ccui.LayoutComponent:bindLayoutComponent(self.txt_name)
    layout:setPositionPercentXEnabled(true)
    layout:setPositionPercentYEnabled(true)
    layout:setPositionPercentX(0.5000)
    layout:setPositionPercentY(0.5000)
    layout:setPercentWidth(0.6300)
    layout:setPercentHeight(0.9655)
    layout:setSize( { width = 63.0000, height = 28.0000 })
    layout:setLeftMargin(18.5000)
    layout:setRightMargin(18.5000)
    layout:setTopMargin(0.5000)
    layout:setBottomMargin(0.5000)
    clipNode:addChild(self.txt_name)
    self.img_namebg:addChild(clipNode)
    local len = self.txt_name:getAutoRenderSize().width
    self.space =(len - 100) / 2
    if len >= 105 then
        self.isEnableUpdate = true
    end
end 

-- 名字移动逻辑
function HeadView:updateTime(dt)
    if not self.isEnableUpdate then
        return
    end
    if self.delayTime > 0 then
        self.delayTime = self.delayTime - dt
        return
    end

    if self.speed < self.speedMax then
        self.speed = self.speed + self.rate * dt
    else
        self.speed = self.speedMax
    end

    if self.dir == 0 then
        self.posX = self.posX + self.speed * dt
        if self.posX >= self.space then
            self.isStop = false
            self.delayTime = self.timel
            self.posX = self.space
            self.speed = 0
            self.dir = 1
        end
    else
        self.posX = self.posX - self.speed * dt
        if self.posX <= - self.space then
            self.isStop = false
            self.delayTime = self.timer
            self.posX = - self.space
            self.speed = 0
            self.dir = 0
        end
    end

    self.txt_name:setPosition(self.posX, 0)
end

-- 更新人头头像信息有几条更新几条
function HeadView:updateInfo(data)
    if not data then return end
    -- id不能更改唯一性,头像根据user_id生成
    if data.user_id then
        self:updateUserId(data.user_id)
    end
    -- 获取网络头像 head_url存在只读取网络头像
    if data.head_url then
        self.info.head_url=data.head_url
        self:updateHead()
    end
    if data.name then
        self:updateName(data.name)
    end

    if data.coins then
        self:updateCoins(data.coins)
    end

    if data.level then
        self:updateLevel(data.level)
    end

    if data.country then
        self:updateCountry(data.country)
    end
    if data.pos then
        self:updatePos(data.pos)
    end
    --这里开始显示特效
    if data.win_type then
        self:showBigWin(data.win_type)
    end
    --这里加载数据
    for k,v in pairs(data) do
        self.info[k]=v
    end
end

function HeadView:showBigWin(flag)
    if flag == 0 then
        return
    end
    local skeletonNode = sp.SkeletonAnimation:create("common/skeleton.json", "common/skeleton.atlas")
     skeletonNode:setScale(0.95)
    performWithDelay(skeletonNode, function()
        skeletonNode:removeFromParent()
    end , 2.5)
    skeletonNode:setAnimation(0, "animation", false)
    skeletonNode:setPosition(cc.p(0,-75))
    self:addChild(skeletonNode,1)
end

----更新唯一id
function HeadView:updateUserId(user_id)
    if self.info.icon then
        print("updateUserId--icon:" .. self.info.icon)
    end
    self.info.user_id = user_id
    if user_id == -1 then
        self:updateHead("#head/slot_invitePlus.png")
    else
        if bole.headImgs[user_id] then
            self:updateHead(bole.headImgs[user_id])
        else
            self:updateHead(DEF_NAME_PATH)
            bole:getCdnUrl(self.info.user_id, handler(self, self.saveImgPath))
        end
    end
end

function HeadView:saveImgPath(path)
    print("HeadView:saveImgPath=" .. path)
    if path == "error" then
        performWithDelay(self, function()
            self:updateHead(DEF_NAME_PATH)
        end , 0.2)
        return
    end
    bole.headImgs[self.info.user_id] = path
    performWithDelay(self, function()
        self:updateHead(bole.headImgs[self.info.user_id])
    end , 0.2)
end

-- 更新名字 名字相同不刷新
function HeadView:updateName(name)
    self.img_namebg:setVisible(true)
    self.info.name = name
    self.txt_name:setString(name)
    local len = self.txt_name:getAutoRenderSize().width
    self.space =(len - 100) / 2
    self.txt_name:setPosition(0, 0)
    if len >= 105 then
        self.isEnableUpdate = true
    else
        self.isEnableUpdate = false
    end
end

-- 更新金币
function HeadView:updateCoins(coins)
    if self.info.pos == self.POS_SPIN_FRIEND then
        self.info.coins = coins
        self.sp_money:setVisible(true)
        self.txt_money:setString(bole:formatCoins(coins, 5))
    end
end

-- 更新等级
function HeadView:updateLevel(level)
    self.img_level:setVisible(true)
    self.info.level = level
    self.txt_level:setString(level)
end

-- 更新头像 头像相同不刷新
function HeadView:updateHead(imgPath)
    self.node_head:removeAllChildren()
    local clipNode = cc.ClippingNode:create()
    local mask = display.newSprite("#head/potrait_mask.png")
    clipNode:setAlphaThreshold(0)
    clipNode:setStencil(mask)
    local head=nil
    --优先获取url头像(目前只有fb好友使用)
    if self.info.head_url then
        head=bole:newNetSprite(self.info.head_url)
    elseif imgPath then
        head = display.newSprite(imgPath)
    end
    -- 邀请加号不缩放
    if self.info.pos ~= self.POS_SPIN_INTIVE then
        head:setScale(mask:getContentSize().width / head:getContentSize().width)
    end
    clipNode:addChild(head)
    self.node_head:addChild(clipNode)
end
-- 更新位置状态
function HeadView:updatePos(pos)
    self.info.pos = pos
    if pos == self.POS_ONLY_HEAD then
        self.img_nationality:setVisible(false)
        self.img_level:setVisible(false)
        self.img_namebg:setVisible(false)
        self.goto_type = self.GOTO_NOTHING
    elseif pos == self.POS_LOBBY_SELF then
        self.img_namebg:setVisible(false)
        self.img_nationality:setPosition(-50, -30)
        self.img_level:setPosition(57, -26)
        self:setSelf()
    elseif pos == self.POS_SPIN_SELF then
        self.img_namebg:setVisible(false)
        self:setSelf()
    elseif pos == self.POS_SPIN_FRIEND then
        self.goto_type = self.GOTO_SLOTFUNC
        self:updateCoins(self.info.coins)
    elseif pos == self.POS_UPLEVEL then

    elseif pos == self.POS_CHAT_SELF then
        self.img_namebg:setVisible(false)
        self.img_nationality:setVisible(false)
        self.img_level:setVisible(false)
        self:setSelf()
    elseif pos == self.POS_CHAT_FRIEND then
        self.img_namebg:setVisible(false)
        self.img_nationality:setVisible(false)
        self.img_level:setVisible(false)
    elseif pos == self.POS_SPIN_INTIVE then
        self.goto_type = self.GOTO_INTIVE
        self:updateUserId(-1)
        self:updateName("INTIVE")
        self.Img_headbg:loadTexture("head/common_strager_portraitFrame_invite.png", ccui.TextureResType.plistType)
        self.img_nationality:setVisible(false)
        self.img_level:setVisible(false)
    elseif pos == self.POS_INFO_SELF then
        self.goto_type = self.GOTO_EDIT
        self.img_namebg:setVisible(false)
        self:setSelf()
        self.img_nationality:setPosition(-50, -30)
        self.img_level:setPosition(57, -26)
    elseif pos == self.POS_INFO_FRIEND then
        self.goto_type = self.GOTO_NOTHING
        self.img_namebg:setVisible(false)
        self.img_nationality:setPosition(-50, -30)
        self.img_level:setPosition(57, -26)
    elseif pos == self.POS_EDIT_SELF then
        self.Img_headbg:setTouchEnabled(false)
        self.goto_type = self.GOTO_NOTHING
        self:setSelf()
        self.img_nationality:setVisible(false)
        self.img_level:setVisible(false)
        self.img_namebg:setVisible(false)
    elseif pos == self.POS_CLUB_FRIEND then
        self.img_nationality:setVisible(true)
        self.img_level:setVisible(true)
    elseif pos == self.POS_CLUB_LEADER then
        self.img_nationality:setVisible(false)
        self.img_level:setVisible(false)
        self.img_namebg:setVisible(false)
        self.goto_type = self.GOTO_NOTHING
    elseif pos == self.POS_CLUB_MEMBER then
        self.Img_headbg:setTouchEnabled(false)
    elseif pos == self.POS_CLUB_REQUEST then
        self.img_namebg:setPosition(180,0)
        self.img_namebg:setScale(1.5)
    elseif pos == self.POS_INTIVE_FRIEND then
        self.goto_type = self.GOTO_NOTHING
    elseif pos == self.POS_FB_FRIEND then
        self.img_namebg:setPosition(180,0)
        self.img_nationality:setVisible(false)
        self.img_level:setVisible(false)
        self.img_namebg:setScale(1.5)
        self.goto_type = self.GOTO_NOTHING
     elseif pos == self.POS_NOTICE then
        self.img_nationality:setVisible(false)
        self.img_level:setVisible(false)
        self.img_namebg:setVisible(false)
        self.goto_type = self.GOTO_NOTHING
    elseif pos == self.POS_SCALE_FRIEND then
        self.img_nationality:setVisible(false)
        self.img_level:setVisible(false)
        self.goto_type = self.GOTO_NOTHING
    end
    self:registerScriptHandler( function(state)
        if state == "enter" then
            self:onEnter()
        elseif state == "exit" then
            self:onExit()
        end
    end )
end

function HeadView:setSelf()
    self.Img_headbg:loadTexture("head/common_strager_portrait.png", ccui.TextureResType.plistType)
    self.isSelf = true
    self:onEnter()
end

function HeadView:onEnter()
    if self.isSelf then
        bole:addListener("levelChanged", self.eventLevel, self, nil, true)
        bole:addListener("eventInfo", self.eventInfo, self, nil, true)
        bole:addListener("eventImgPath", self.eventImgPath, self, nil, true)
    end
end

function HeadView:onExit()
    if self.isSelf then
        bole:getEventCenter():removeEventWithTarget("levelChanged", self)
        bole:getEventCenter():removeEventWithTarget("eventInfo", self)
        bole:getEventCenter():removeEventWithTarget("eventImgPath", self)
    end
end

function HeadView:eventInfo(event)
    self:updateInfo(event.result)
end

-- 更新国籍
function HeadView:updateCountry(country)
    self.img_nationality:setVisible(true)
    self.info.country = country
end

function HeadView:eventLevel(event)
    self:updateLevel(bole:getUserDataByKey("level"))
end

function HeadView:eventInfo(event)
    self:updateInfo(bole:getUserData())
end

function HeadView:eventImgPath(event)
   self:saveImgPath(event.result)
end

return HeadView

-- endregion
