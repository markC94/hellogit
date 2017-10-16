--region *.lua
--Date
--此文件由[BabeLua]插件自动生成

local LotteryCollectLayer = class("LotteryCollectLayer", cc.load("mvc").ViewBase)

function LotteryCollectLayer:onCreate()
    print("LotteryCollectLayer-onCreate")
    local root = self:getCsbNode():getChildByName("root")
    self:initLayer(root)
    self:adaptScreen(root)
end


function LotteryCollectLayer:initLayer(root)
    root:getChildByName("txt_title"):setString("Congratulations")
    self.rewardText_ = root:getChildByName("txt_reward")
    local btn_collect = root:getChildByName("btn_collect")
    btn_collect:addTouchEventListener(handler(self, self.touchEvent))
end


function LotteryCollectLayer:onEnter()
    bole:addListener("initCollectInfo", self.initCollectInfo, self, nil, false)
end

function LotteryCollectLayer:initCollectInfo(data)
    data = data.result
    self.collectInfo_ = data
    self.rewardText_:setString(self:getCollect(data.reward_id))
end

function LotteryCollectLayer:touchEvent(sender, eventType)
    local name = sender:getName()
    print("touchEvent:" .. name)
    if eventType == ccui.TouchEventType.began then
        print("Touch Down")
        sender:setScale(1.05)
    elseif eventType == ccui.TouchEventType.moved then
        print("Touch Move")
    elseif eventType == ccui.TouchEventType.ended then
        print("Touch Up")
        sender:setScale(1)
        if name == "btn_collect" then
            self:collectReward()
            self:closeUI()
        end
    elseif eventType == ccui.TouchEventType.canceled then
        print("Touch Cancelled")
        sender:setScale(1)
    end
end

function LotteryCollectLayer:collectReward()
    local type = bole:getConfigCenter():getConfig("reward", self.collectInfo_.reward_id , "bonus_type")
    local number = tonumber(bole:getConfigCenter():getConfig("reward", self.collectInfo_.reward_id , "bonus_number"))

    if type == 10 then -- coins
       -- bole:getUserData():updateSceneInfo("coins")
    elseif type == 9 then -- diamond
       -- bole:getUserData():updateSceneInfo("diamond")
    elseif type == 2 then -- 铜卷
        bole:postEvent("changeVouchers",{index = 1, changeNum = number})
    elseif type == 3 then -- 银卷
        bole:postEvent("changeVouchers",{index = 2, changeNum = number})
    elseif type == 4 then -- 金券
        bole:postEvent("changeVouchers",{index = 3, changeNum = number})
    elseif type == 8 then -- 大厅加速券
    
    end  
    bole:postEvent("changeCollect",self.collectInfo_)
end

function LotteryCollectLayer:getCollect(id)
    local typeStr = ""
    local type = bole:getConfigCenter():getConfig("reward", id , "bonus_type")
    local number = bole:getConfigCenter():getConfig("reward", id , "bonus_number")
    if type == 10 then
        typeStr = "coins"
    elseif type == 9 then
        typeStr = "diamond"
    elseif type == 2 then
        typeStr = "铜卷"
    elseif type == 3 then
        typeStr = "银卷"
    elseif type == 4 then
        typeStr = "金券"
    elseif type == 8 then
        typeStr = "大厅加速券"
    elseif type == 1 then
        typeStr = "双倍经验"
    elseif type == 101 then
        typeStr = "100M奖励"
    elseif type == 102 then
        typeStr = "400M奖励"
    elseif type == 103 then
        typeStr = "1B奖励"
    else
        typeStr = "\"" .. type .. "\""
    end  
    return number .. " " .. typeStr
end

function LotteryCollectLayer:adaptScreen(root)
    root:setScale(0.1)
    root:runAction(cc.ScaleTo:create(0.2,1,1))
    local winSize = cc.Director:getInstance():getWinSize()
    root:setPosition(winSize.width / 2, winSize.height / 2)
end


function LotteryCollectLayer:onExit()
    bole.socket:unregisterCmd("initCollectInfo")
end

return LotteryCollectLayer

--endregion
