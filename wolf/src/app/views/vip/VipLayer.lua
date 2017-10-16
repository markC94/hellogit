--region *.lua
--Date
--此文件由[BabeLua]插件自动生成

local VipLayer = class("VipLayer", cc.load("mvc").ViewBase)

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

function VipLayer:onKeyBack()
   self:closeUI()
end

function VipLayer:onEnter()
    bole:addListener("refreshVipCollect", self.refreshCollect, self, nil, true)
end

function VipLayer:reVipInfo(t, data)
    if t == "vip_info" then
        self.vipdata_ = data
        self:refreshView()
    end
end

function VipLayer:initTop(root)
    self.vipIcon_ = root:getChildByName("icon")
    self.vipIcon_:addTouchEventListener(handler(self, self.touchEvent))
    root:getChildByName("txt_now"):setString("Your Status:")
    root:getChildByName("txt_next"):setString("Next Status:")
    self.vipTitleNow_ = root:getChildByName("txt_status_now")
    self.vipTitleNext_ = root:getChildByName("txt_status_next")
    self.vipInfo_ = root:getChildByName("txt_info")

    local btn_close = self.root_:getChildByName("btn_close")
    btn_close:addTouchEventListener(handler(self, self.touchEvent))

    local vip_expPanel = root:getChildByName("vip_exp")
    self.txt_exp_ = vip_expPanel:getChildByName("txt_exp")

    local expBg = cc.Sprite:create("shop_icon/vip_progressBar_frame.png")
    vip_expPanel:getChildByName("expSchedule"):addChild(expBg)  
  
    local expBody = cc.Sprite:create("shop_icon/vip_progressBar.png")  
 
    --创建进度条  
    local expProgress = cc.ProgressTimer:create(expBody)  
    expProgress:setType(cc.PROGRESS_TIMER_TYPE_BAR) --设置为条形 type:cc.PROGRESS_TIMER_TYPE_RADIAL  
    expProgress:setMidpoint(cc.p(0,0)) --设置起点为条形坐下方  
    expProgress:setBarChangeRate(cc.p(1,0))  --设置为竖直方向  
    expProgress:setPercentage(10) -- 设置初始进度为30  
    vip_expPanel:getChildByName("expSchedule"):addChild(expProgress)  
    self.expProgress_ = expProgress

    self.vip_progressBarlight_ = cc.Sprite:create("shop_icon/vip_progressBarlight.png")  
    local clipNode = cc.ClippingNode:create()
    clipNode:setAnchorPoint(0.5,0.5)
    clipNode:setAlphaThreshold(0)
    clipNode:setStencil(cc.Sprite:create("shop_icon/vip_progressBar.png"))
    vip_expPanel:getChildByName("expSchedule"):addChild(clipNode)  
    clipNode:addChild(self.vip_progressBarlight_)
    self.vip_progressBarlight_:setAnchorPoint(1,0.5)
    self.vip_progressBarlight_:setPosition(0,0)
end


function VipLayer:initBottom(root)
    self.txt_vipLv_ = root:getChildByName("txt_vipLv")
    self.reward_coins_ = root:getChildByName("reward_coins"):getChildByName("num")
    self.reward_diamond_ = root:getChildByName("reward_diamond"):getChildByName("num")
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
        local rewardId = showRewardList[i].vip_reward_id
        local rewardIcon = cc.Sprite:create(bole:getBuyManage():getVipRewardBoxIconPath(rewardId))
        rewardIcon:setScale(0.32)
        rewardIcon:setPosition(showRewardList[i].vip_reward_exp / vipUpExp * 740,34)
        self.top_:getChildByName("vip_exp"):addChild(rewardIcon)
    end

    self.vipIcon_:loadTexture(bole:getBuyManage():getVipIconStr())
    self.vipTitleNow_:setString(string.upper(bole:getBuyManage():getVipName()))
    self.vipTitleNext_:setString(string.upper(bole:getBuyManage():getNextVipName()))


    local percent = 1

    if vipLevel == 6 then
        self.txt_exp_:setString(vipPoints)
        self.expProgress_:setPercentage(percent * 100)
        self.txt_exp_:setString("Max Level")
    else
        percent = vipPoints / vipUpExp
        self.expProgress_:setPercentage( math.min(percent * 100,100))
        self.txt_exp_:setString(vipPoints .. "/" .. vipUpExp)
        self.vipInfo_:setString("Only " .. vipUpExp - vipPoints  .. " points left to reach " .. bole:getBuyManage():getNextVipName() .. "!")
    end

    --self.txt_vipLv_:setString("VIP " .. vipLevel + 1)

    self.vip_progressBarlight_:setPositionX(760 * percent - 380 )

    self:refreshCollect()
end

function VipLayer:refreshCollect()
    local vipLevel = bole:getUserDataByKey("vip_level")
    local vipPoints = bole:getUserDataByKey("vip_points")
    local vipReward = bole:getUserDataByKey("vip_reward")

    self.rewardContent_ = bole:getBuyManage():getReward(self.vipRewardTable_[tostring( math.min(vipReward + 1, 18))].vip_reward_content)
        
    self.reward_coins_:setString(bole:formatCoins( self.rewardContent_[1].number,15))
    self.reward_diamond_:setString(bole:formatCoins( self.rewardContent_[2].number,15))

    local maxRewardId = 0
    for k , v in pairs(self.vipRewardTable_) do
        if v.vip_reward_exp < vipPoints then
            if tonumber(k) > maxRewardId then
                maxRewardId = tonumber(k)
            end
        end
    end
    
    if vipReward + 1 <= maxRewardId then
        self.btn_collect_:setTouchEnabled(true)
        self.btn_collect_:setBright(true)
        self.btn_collect_:getChildByName("txt"):setTextColor({ r = 255, g = 255, b = 255})
    else
        self.btn_collect_:setTouchEnabled(false)
        self.btn_collect_:setBright(false)
        self.btn_collect_:getChildByName("txt"):setTextColor({ r = 237, g = 187, b = 255})
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
        elseif name == "icon" then
            bole:getUIManage():openNewUI("VipStatusLayer",true,"vip","app.views.vip")
        end
    elseif eventType == ccui.TouchEventType.canceled then
        sender:runAction(cc.ScaleTo:create(0.1, 1, 1))
    end
end


function VipLayer:collect()
    local vipReward = bole:getUserDataByKey("vip_reward")
    bole.socket:send("collect_vip_reward",{ reward_id = vipReward + 1},true)
end

function VipLayer:onExit()
    bole:removeListener("refreshVipCollect", self)
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
