-- region *.lua
-- Date
-- 此文件由[BabeLua]插件自动生成

local MissionsLayer = class("MissionsLayer", cc.load("mvc").ViewBase)
MissionsLayer.UncompletedStatus = 1     -- 1.未完成  
MissionsLayer.CompletedStatus = 2     -- 2.已完成未领取奖励 
MissionsLayer.GetRewardStatus = 3     -- 3.已领取奖励

function MissionsLayer:onCreate()
    print("MissionsLayer:onCreate")
    self.layer_ = self:getCsbNode():getChildByName("Panel_missions")
    self.missionWidget_ = self:getCsbNode():getChildByName("Panel_mission")
    self.missionWidget_:setVisible(false)
    self.missionWidget_:addTouchEventListener(handler(self, self.touchEvent))

    self.missionListView_ = self.layer_:getChildByName("listView")
    self.missionListView_:setScrollBarOpacity(0)
    self:setPosition(50, 100)

    bole.socket:registerCmd("complete_task", self.reCompleteTask, self)
    bole.socket:registerCmd("collect_task_reward", self.getTaskReward, self)
    bole:addListener("initMissionsLayer", self.initMissionsLayer, self, nil, true)

end

function MissionsLayer:initMissionsLayer(data)
    data = data.result
    self.taskTable_ = data
    self:initTaskTable()
    self:initMissions()
end

function MissionsLayer:reCompleteTask(t, data)
    if t == "complete_task" then
        if data[1] ~= nil then
            self:initMissions()
            for k, v in pairs(self.showTable_) do
                if tonumber(v.id) == tonumber(data[1]) then
                    self:completedStatus(self.missionListView_:getChildByTag(tonumber(v.id)), v)
                    self:refreshUserData(v.id, 1, 0)
                end
            end
        end
    end
end

function MissionsLayer:getTaskReward(t, data)
    if t == "collect_task_reward" then
        if data.success == 1 then
            --bole:getAppManage():addCoins(data.reward_coins)
            --bole:postEvent("addTaskReward", data.reward_coins)
            --self:getRewardStatus(self.sender_, true, data.reward_coins)
            self:refreshUserData(self.showTable_[self.sender_:getTag()].id, 1, 1)
        end
    end
end

function MissionsLayer:refreshUserData(id, isCompleted, isGetReward)
    -- local taskTable = bole:getUserData():getDataByKey("daily_task")
    local taskTable = self.taskTable_
    for k, v in pairs(taskTable) do
        if tonumber(v.id) == tonumber(id) then
            v.is_completed = isCompleted
            v.collect_reward = isGetReward
        end
    end
    bole:getUserData():changeDataByKey("daily_task", taskTable)
end

function MissionsLayer:initTaskTable()
    self.showTable_ = { }
    for i = 1, #self.taskTable_ do
        local v = self.taskTable_[i]
        local task = { }
        task.id = v.id
        task.isCompleted = v.is_completed
        task.current = v.current
        task.isGetReward = v.collect_reward
        task.taskInfo = bole:getConfigCenter():getConfig("dailymission", v.id, "personaldailymission")
        task.taskReward = bole:getConfigCenter():getConfig("dailymission", v.id, "pdmreward")
        task.missioncounts = bole:getConfigCenter():getConfig("dailymission", v.id, "missioncounts")
        task.icon = bole:getConfigCenter():getConfig("dailymission", v.id, "missionicon")
        task.type = bole:getConfigCenter():getConfig("dailymission", v.id, "mission_type")
        table.insert(self.showTable_, task)
    end
end

function MissionsLayer:missionCompleted(data)
    -- data.result
    -- 刷新状态
end

-- 初始化任务
function MissionsLayer:initMissions()
    self.missionListView_:removeAllChildren()
    for i = 1, #self.showTable_ do
        local v = self.showTable_[i]
        local missionWidget = self.missionWidget_:clone()
        missionWidget:setVisible(true)
        missionWidget:setTag(i)
        self.missionListView_:pushBackCustomItem(missionWidget)
        self:uncompletedStatus(missionWidget, v)
        -- self:completedStatus(missionWidget,v)
        if v.isCompleted == 1 then
            if v.isGetReward == 0 then
                self:completedStatus(missionWidget, v)
            elseif v.isGetReward == 1 then
                self:getRewardStatus(missionWidget, false)
            end
        end
    end
end

function MissionsLayer:touchEvent(sender, eventType)
    local showActSender = sender:getChildByName("node_btnAct"):getChildByName("btn_collect")
    local btn_collect = sender:getChildByName("btn_collect")
    --[[
    --打开测试动画
     if eventType == ccui.TouchEventType.ended then
        self:getRewardStatus(sender, true)
    end
    --]]
    --if showActSender ~= nil then
        if eventType == ccui.TouchEventType.began then
            btn_collect:runAction(cc.ScaleTo:create(0.1, 1.05, 1.05))
        elseif eventType == ccui.TouchEventType.moved then

        elseif eventType == ccui.TouchEventType.ended then

            btn_collect:runAction(cc.ScaleTo:create(0.1, 1, 1))
            -- TODO
            self.sender_ = sender

            if sender.status == MissionsLayer.CompletedStatus then
                local tag = sender:getTag()
                bole.socket:send("collect_task_reward", { id = self.showTable_[tag].id })
                if bole:getSpinApp():isThemeAlive() then 
                    performWithDelay(self, function()
                        local coins = bole:getUserDataByKey("coins") +  self.showTable_[tag].taskReward
                        bole:postEvent("putWinCoinToTop", { coin = coins})
                        bole:setUserDataByKey("coins",coins)
                    end,1)
                end
                self:getRewardStatus(self.sender_, true, self.showTable_[tag].taskReward)
            end

            -- self:removeFromParent()
        elseif eventType == ccui.TouchEventType.canceled then
            btn_collect:runAction(cc.ScaleTo:create(0.1, 1, 1))
        end
    --end
end

-- 刷新任务信息
function MissionsLayer:refreshMissions(data)

end

-- 未完成任务状态
function MissionsLayer:uncompletedStatus(missionWidget, missionData)
    missionWidget.status = MissionsLayer.UncompletedStatus
    missionWidget:getChildByName("Text_missionInfo"):setString(missionData.taskInfo)
    if string.len(missionData.taskInfo) <= 5 then
        missionWidget:getChildByName("Text_missionInfo"):setFontSize(30)
    end
    missionWidget:getChildByName("Text_reward"):setString(bole:formatCoins(tonumber(missionData.taskReward), 12))
    missionWidget:getChildByName("Image_missionBg"):loadTexture("loadImage/profile_frame_dailymission.png")
    missionWidget:getChildByName("icon"):loadTexture("mission_icon/profile_task_icon" ..  missionData.icon ..".png")

    local num = missionWidget:getChildByName("task_num")
    num:setScale(0.9)
    num:setStringValue(missionData.missioncounts)
    local addPos = -7

    if missionData.icon ~= 11 then
        missionWidget:getChildByName("task_num"):setPosition(145,131)
        addPos = -10
    end

    if missionData.type == 1 then
        num:setStringValue(1)
    elseif missionData.type == 2 then

    elseif missionData.type == 3 then
        num:setPosition(num:getPositionX() - 10,num:getPositionY())
        num:setScale(0.5)
        addPos = - 20
    end


    missionWidget:getChildByName("Text_missionInfo"):setPosition(num:getPositionX() + num:getContentSize().width * num:getScale() + addPos,131)

    missionWidget:getChildByName("current"):setString(missionData.current)
    missionWidget:getChildByName("current_f"):setString(missionData.missioncounts)
    local infoBg = missionWidget:getChildByName("Image_infoBg")
    infoBg:setVisible(true)
    infoBg:getChildByName("sch_panel"):getChildByName("currentSch"):setPercent(missionData.current / missionData.missioncounts * 100)
    infoBg:getChildByName("sch_panel"):getChildByName("currentTop"):setPosition(missionData.current / missionData.missioncounts * 236, 32.5)
    missionWidget:getChildByName("Image_finish"):setVisible(false)
    missionWidget:getChildByName("Image_finishMask"):setVisible(false)
    missionWidget:getChildByName("txt_collect"):setVisible(false)
    missionWidget:getChildByName("btn_collect"):setVisible(false)

end

-- 完成任务未领取奖励状态
function MissionsLayer:completedStatus(missionWidget)
    missionWidget.status = MissionsLayer.CompletedStatus
    missionWidget:getChildByName("Image_missionBg"):loadTexture("loadImage/profile_frame_dailymission_finished.png")
    missionWidget:getChildByName("Image_infoBg"):setVisible(false)
    missionWidget:getChildByName("current"):setVisible(false)
    missionWidget:getChildByName("current_f"):setVisible(false)
    missionWidget:getChildByName("current_g"):setVisible(false)
    missionWidget:getChildByName("Image_finish"):setVisible(false)
    missionWidget:getChildByName("Image_finishMask"):setVisible(false)
    missionWidget:getChildByName("txt_collect"):setVisible(true)
    missionWidget:getChildByName("btn_collect"):setVisible(true)
    --[[
    local btn_collectAnima = sp.SkeletonAnimation:create("common_act/collect.json", "common_act/collect.atlas")
    btn_collectAnima:setPosition(0, 0)
    missionWidget:getChildByName("node_btnAct"):addChild(btn_collectAnima)
    --]]
    --btn_collectAnima:setName("btn_collect"):setVisible(true)
    --btn_collectAnima:setAnimation(0, "animation", true)

end

-- 已领取奖励状态
function MissionsLayer:getRewardStatus(missionWidget, isShowAnima, coinsNum)
    local id = missionWidget:getTag()
    missionWidget.status = MissionsLayer.GetRewardStatus
    missionWidget:getChildByName("Text_reward"):setString(bole:formatCoins(self.showTable_[id].taskReward, 12))
    missionWidget:getChildByName("Image_missionBg"):loadTexture("loadImage/profile_frame_dailymission_finished.png")
    missionWidget:getChildByName("Image_infoBg"):setVisible(false)
    missionWidget:getChildByName("current"):setVisible(true)
    missionWidget:getChildByName("current_f"):setVisible(true)
    missionWidget:getChildByName("current_g"):setVisible(true)
    missionWidget:getChildByName("current"):setString(self.showTable_[id].missioncounts)
    missionWidget:getChildByName("current_f"):setString(self.showTable_[id].missioncounts)
    missionWidget:getChildByName("Image_finish"):setVisible(true)
    missionWidget:getChildByName("Image_finishMask"):setVisible(true)
    missionWidget:getChildByName("txt_collect"):setVisible(false)
    missionWidget:getChildByName("btn_collect"):setVisible(false)

    if isShowAnima then
        local tag = missionWidget:getTag()
        if tag == 1 or tag == 2 then
            bole:postEvent("infoCoinsJump", { pos = missionWidget:getWorldPosition(), coins = coinsNum, randomNum = 2 })
        else
            bole:postEvent("infoCoinsJump", { pos = missionWidget:getWorldPosition(), coins = coinsNum, randomNum = 3 })
        end
    end
    --[[
    local btn_collect = missionWidget:getChildByName("node_btnAct"):getChildByName("btn_collect")
    if btn_collect then
        btn_collect:removeFromParent()
    end

    if isShowAnima then
        missionWidget:getChildByName("Image_finish"):setVisible(false)
        missionWidget:getChildByName("Image_finishMask"):setVisible(false)
        local btn_collectAnima = sp.SkeletonAnimation:create("common_act/gaizhang_1.json", "common_act/gaizhang_1.atlas")
        btn_collectAnima:setAnimation(0, "animation", false)
        missionWidget:addChild(btn_collectAnima)
        btn_collectAnima:setPosition(130, 85)

        btn_collectAnima:registerSpineEventHandler( function(event)
            if event.animation == "animation" then
                bole:postEvent("infoCoinsJump", { pos = missionWidget:getWorldPosition(), coins = coinsNum })
            end
        end , sp.EventType.ANIMATION_COMPLETE)
    end
    --]]
end

function MissionsLayer:exit()
    bole.socket:unregisterCmd("complete_task")
    bole.socket:unregisterCmd("collect_task_reward")
    bole:removeListener("initMissionsLayer", self)
    -- self:closeUI()
end


return MissionsLayer

-- endregion
