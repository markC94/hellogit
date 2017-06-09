--region *.lua
--Date
--此文件由[BabeLua]插件自动生成

local VipLayer = class("VipLayer", cc.load("mvc").ViewBase)
VipLayer.VipPowerInfo = {"VIP special reward.",
                         "Get extra coins when log in.",
                         "Get extra coins/diamonds from shop.",
                         "Earn more VIP points."}

function VipLayer:onCreate()
    print("VipLayer:onCreate")
    self.root_ = self:getCsbNode():getChildByName("root")
    self.top_ = self.root_:getChildByName("top")
    self.bottom_ = self.root_:getChildByName("bottom")

    self.vipRewardTable_ = bole:getConfigCenter():getConfig("vip_reward")
    self:initTop(self.top_)
    self:initBottom(self.bottom_)

    self:adaptScreen()

    self:reVipInfo("vip_info", data)
end

function VipLayer:onEnter()
    bole.socket:registerCmd("collect_vip_reward", self.reCollect, self)
    --bole:addListener("initFrirndList", self.initFrirndList, self, nil, true)
end

function VipLayer:reVipInfo(t, data)
    if t == "vip_info" then
        self.vipdata_ = data
        self:refreshView()
    end
end

function VipLayer:initTop(root)
    self.vipIcon_ = root:getChildByName("icon")
    root:getChildByName("txt_now"):setString("Your Status:")
    root:getChildByName("txt_next"):setString("Next Status:")
    self.vipTitleNow_ = root:getChildByName("txt_status_now")
    self.vipTitleNext_ = root:getChildByName("txt_status_next")

    local btn_close = self.root_:getChildByName("btn_close")
    btn_close:addTouchEventListener(handler(self, self.touchEvent))

    local vip_expPanel = root:getChildByName("vip_exp")
    self.txt_exp_ = vip_expPanel:getChildByName("txt_exp")
    local expBg = cc.Sprite:create("res/vip/VIP_progressbar01.png")
    vip_expPanel:getChildByName("expSchedule"):addChild(expBg)  
  
    local expBody = cc.Sprite:create("res/vip/VIP_progressbar02.png")  
 
    --创建进度条  
    local expProgress = cc.ProgressTimer:create(expBody)  
    expProgress:setType(cc.PROGRESS_TIMER_TYPE_BAR) --设置为条形 type:cc.PROGRESS_TIMER_TYPE_RADIAL  
    expProgress:setMidpoint(cc.p(0,0)) --设置起点为条形坐下方  
    expProgress:setBarChangeRate(cc.p(1,0))  --设置为竖直方向  
    expProgress:setPercentage(10) -- 设置初始进度为30  
    vip_expPanel:getChildByName("expSchedule"):addChild(expProgress)  
    self.expProgress_ = expProgress
end


function VipLayer:initBottom(root)
    self.txt_vipLv_ = root:getChildByName("txt_vipLv")
    self.reward_coins_ = root:getChildByName("reward_coins"):getChildByName("num")
    self.reward_diamond_ = root:getChildByName("reward_diamond"):getChildByName("num")
    self.reward_lotto_ = root:getChildByName("reward_lotto"):getChildByName("num")
    self.btn_collect_ = root:getChildByName("btn_collect")
    self.btn_collect_:addTouchEventListener(handler(self, self.touchEvent))
end

function VipLayer:refreshView()
    local vipLevel = bole:getUserDataByKey("vip_level")
    local vipPoints = bole:getUserDataByKey("vip_points")
    local vipReward = bole:getUserDataByKey("vip_reward")

    local vipName = bole:getConfigCenter():getConfig("vip", vipLevel, "vip_name")
    local vipIcon = bole:getConfigCenter():getConfig("vip", vipLevel, "vip_icon")
    local vipUpExp = bole:getConfigCenter():getConfig("vip", vipLevel, "vip_exp")

    local showRewardList = {}
    for k , v in pairs(self.vipRewardTable_) do
        if v.vip_level == vipLevel then
            if v.vip_reward_exp > vipPoints then
                table.insert(showRewardList , # showRewardList + 1, v)
            end
        end
    end

    for i = 1, # showRewardList do
        local rewardIcon = cc.Sprite:create("vip/VIP_progress_gift.png")
        rewardIcon:setPosition(showRewardList[i].vip_reward_exp / vipUpExp * 740,30)
        self.top_:getChildByName("vip_exp"):addChild(rewardIcon)
    end

    self.vipIcon_:loadTexture("res/vip/" .. vipIcon .. ".png")
    self.vipTitleNow_:setString("SILVER")
    self.vipTitleNext_:setString("GOLD")

    local percent = 1

    if vipLevel == 6 then
        self.txt_exp_:setString(vipPoints)
        self.expProgress_:setPercentage(percent * 100)
    else
        percent = vipPoints / vipUpExp
        self.expProgress_:setPercentage(percent * 100)
        self.txt_exp_:setString(vipPoints .. "/" .. vipUpExp)
    end

    self.txt_vipLv_:setString("VIP " .. vipLevel + 1)
    self.txt_exp_:setPositionX(740 * percent)

    self:initVipPowerInfo()
    self:refreshCollect()
end

function VipLayer:refreshCollect()
    local vipLevel = bole:getUserDataByKey("vip_level")
    local vipPoints = bole:getUserDataByKey("vip_points")
    local vipReward = bole:getUserDataByKey("vip_reward")

    self.rewardContent_ = self:getReward(self.vipRewardTable_[tostring( math.min(vipReward + 1, 18))].vip_reward_content)
        
    self.reward_coins_:setString(self.rewardContent_[1].number)
    self.reward_diamond_:setString(self.rewardContent_[2].number)
    self.reward_lotto_:setString(self.rewardContent_[3].number)

    local maxRewardId = 0
    for k , v in pairs(self.vipRewardTable_) do
        if v.vip_reward_exp < vipPoints then
            if tonumber(k) > maxRewardId then
                maxRewardId = tonumber(k)
            end
        end
    end
    
    if vipReward + 1 < maxRewardId then
        self.btn_collect_:setTouchEnabled(true)
    else
        self.btn_collect_:setTouchEnabled(false)
    end
end



function VipLayer:initVipPowerInfo()
    for i = 1, # self.VipPowerInfo do
        local cell = ccui.Layout:create()
        cell:setContentSize(350,30)
        cell:setAnchorPoint(0,0.5)
        local icon = cc.Sprite:create("res/vip/VIP_star.png")
        icon:setAnchorPoint(0,0.5)
        icon:setPosition(0, 15)
        cell:addChild(icon)
        local text = cc.Label:createWithTTF(self.VipPowerInfo[i], "res/font/FZKTJW.TTF", 24)
        text:setAnchorPoint(0,0.5)
        text:setPosition(30, 15)
        cell:addChild(text)
        self.bottom_:getChildByName("vipPower_" .. i):addChild(cell)
    end
end

function VipLayer:touchEvent(sender, eventType)
    local name = sender:getName()
    if eventType == ccui.TouchEventType.began then
        sender:runAction(cc.ScaleTo:create(0.1, 1.05, 1.05))
    elseif eventType == ccui.TouchEventType.moved then

    elseif eventType == ccui.TouchEventType.ended then
        sender:runAction(cc.ScaleTo:create(0.1, 1, 1))
        if name == "btn_close" then
            self:closeUI()
        elseif name == "btn_collect" then
            sender:setTouchEnabled(false)
            self:collect()
        end
    elseif eventType == ccui.TouchEventType.canceled then
        sender:runAction(cc.ScaleTo:create(0.1, 1, 1))
    end
end


function VipLayer:collect()
    local vipReward = bole:getUserDataByKey("vip_reward")
    bole.socket:send("collect_vip_reward",{ reward_id = vipReward + 1},true)
end

function VipLayer:reCollect(t,data)
    bole:setUserDataByKey("vip_reward",data.vip_reward)
    bole:changeUserDataByKey("coins",self.rewardContent_[1].number)
    bole:changeUserDataByKey("diamond",self.rewardContent_[2].number)

    local vouchers = bole:getUserDataByKey("vouchers")
    vouchers[self.rewardContent_[3].type - 1] = vouchers[self.rewardContent_[3].type - 1] + self.rewardContent_[3].number
    bole:setUserDataByKey("vouchers",vouchers)

    self:refreshCollect()
end

function VipLayer:getReward(idList)
    local infoList = {}
    for i = 1, # idList do
        local info = {}
         info.typeStr = ""
         info.type = bole:getConfigCenter():getConfig("reward", idList[i] , "bonus_type")
         info.number = bole:getConfigCenter():getConfig("reward", idList[i] , "bonus_number")
         if type == 10 then
            info.typeStr = "coins"
         elseif type == 9 then
            info.typeStr = "diamond"
         elseif type == 2 then
            info.typeStr = "铜卷"
         elseif type == 3 then
            info.typeStr = "银卷"
         elseif type == 4 then
            info.typeStr = "金券"
         elseif type == 8 then
            info.typeStr = "大厅加速券"
         elseif type == 1 then
            info.typeStr = "双倍经验"
         end     
         table.insert(infoList, # infoList + 1, info)    
    end
    return infoList
end

function VipLayer:onExit()
    bole.socket:unregisterCmd("vip_info")
    --bole:removeListener("initFrirndList", self)
end

function VipLayer:adaptScreen()
    local winSize = cc.Director:getInstance():getWinSize()
    self:setPosition(0,0)
    self.root_:setPosition(winSize.width / 2, winSize.height / 2)
    self.root_:setScale(0.1)
    self.root_:runAction(cc.ScaleTo:create(0.2,1,1))
end

return VipLayer
--endregion
