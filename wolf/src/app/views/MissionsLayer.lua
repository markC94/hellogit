--region *.lua
--Date
--此文件由[BabeLua]插件自动生成

local MissionsLayer = class("MissionsLayer", cc.load("mvc").ViewBase)
MissionsLayer.UncompletedStatus = 1     --1.未完成  
MissionsLayer.CompletedStatus = 2     --2.已完成未领取奖励 
MissionsLayer.GetRewardStatus = 3     --3.已领取奖励

function MissionsLayer:onCreate()
    print("MissionsLayer:onCreate")
    self.layer_ = self:getCsbNode():getChildByName("Panel_missions")
    self.missionWidget_ = self:getCsbNode():getChildByName("Panel_mission")
    self.missionListView_ = self.layer_:getChildByName("ListView")
    self.missionListView_:setScrollBarOpacity(0)
    self.missionWidget_:addTouchEventListener(handler(self, self.touchEvent))
    self:setPosition(50,100)

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
            for k , v in pairs(self.showTable_) do
                if tonumber(v.id) == tonumber(data[1]) then
                    self:completedStatus(self.missionListView_:getChildByTag(tonumber(v.id)),v)
                    self:refreshUserData(v.id,1,0)
                end
            end
        end
    end
end

function MissionsLayer:getTaskReward(t, data)
    if t == "collect_task_reward" then
        if data.success == 1 then
            print("领取成功")
            --bole:getAppManage():addCoins(tonumber(data.reward_coins))
            bole:getUserData():updateSceneInfo("coins")
            --bole:getUserData():updateSceneInfo("diamond")
        end
    end
end

function MissionsLayer:refreshUserData(id,isCompleted,isGetReward)
    --local taskTable = bole:getUserData():getDataByKey("daily_task")
    local taskTable = self.taskTable_
    for k , v in pairs(taskTable) do
        if tonumber(v.id) == tonumber(id) then
            v.is_completed = isCompleted
            v.collect_reward = isGetReward
        end
    end
    bole:getUserData():changeDataByKey("daily_task", taskTable)
end

function MissionsLayer:initTaskTable()
    --local taskTable = bole:getUserData():getDataByKey("daily_task")
    self.showTable_ = {}
    for k , v in pairs(self.taskTable_) do
        local task = {}
        task.id = v.id
        task.isCompleted = v.is_completed
        task.current = v.current
        task.isGetReward = v.collect_reward
        task.taskInfo = bole:getConfigCenter():getConfig("dailymission", v.id, "personaldailymission")
        task.taskReward = bole:getConfigCenter():getConfig("dailymission", v.id, "pdmreward")
        task.icon = bole:getConfigCenter():getConfig("dailymission", v.id, "missionicon")
        table.insert(self.showTable_, # self.showTable_ + 1, task)

        --[[
        print("==========================================")
        print("id:" ..  task.id )
        print("是否完成:" ..  task.isCompleted )
        print("次数:" ..  task.current )
        print("是否领取:" ..  task.isGetReward )
        print("内容:" ..  task.taskInfo )
        print("奖励:" ..  task.taskReward )
        print("图片:" ..  task.icon )
        print("==========================================")
        --]]
    end
end

function MissionsLayer:missionCompleted(data)
   --data.result
   --刷新状态
end

--初始化任务
function MissionsLayer:initMissions()
    self.missionListView_:removeAllChildren()
    for k , v in pairs(self.showTable_) do
        local missionWidget = self.missionWidget_:clone()
        missionWidget:setVisible(true)
        missionWidget:setTag(tonumber(v.id))
        self.missionListView_:pushBackCustomItem(missionWidget)
        self:uncompletedStatus(missionWidget,v)
        if v.isCompleted == 1 then
            if v.isGetReward == 0 then
                self:completedStatus(missionWidget,v)
            elseif v.isGetReward == 1 then
                self:getRewardStatus(missionWidget,v)
            end    
        end 
    end
end

function MissionsLayer:touchEvent(sender, eventType)
    if eventType == ccui.TouchEventType.began then
        sender:runAction(cc.ScaleTo:create(0.1, 1.05, 1.05))
    elseif eventType == ccui.TouchEventType.moved then

    elseif eventType == ccui.TouchEventType.ended then
        
        sender:runAction(cc.ScaleTo:create(0.1, 1, 1))
        --TODO
        if sender.status == MissionsLayer.CompletedStatus then
            print(tonumber(sender:getTag()))
            bole.socket:send("collect_task_reward", { id = sender:getTag()})
            self:getRewardStatus(sender)
            self:refreshUserData(sender:getTag(),1,1)
        end

         --self:removeFromParent()
    elseif eventType == ccui.TouchEventType.canceled then
        sender:runAction(cc.ScaleTo:create(0.1, 1, 1))
    end
end

--刷新任务信息
function MissionsLayer:refreshMissions(data)

end

--未完成任务状态
function MissionsLayer:uncompletedStatus(missionWidget,missionData)
    missionWidget.status = MissionsLayer.UncompletedStatus
    missionWidget:getChildByName("Text_missionInfo"):setString(missionData.taskInfo)
    missionWidget:getChildByName("Text_reward"):setString("+" .. bole:formatCoins(tonumber(missionData.taskReward),12))
    missionWidget:getChildByName("Image_missionBg"):loadTexture("res/mission/cmissionbg1.png")
    missionWidget:getChildByName("Image_infoBg"):loadTexture("res/mission/info_cmissionbg1.png")
    missionWidget:getChildByName("Image_check"):setVisible(false)
end

--完成任务未领取奖励状态
function MissionsLayer:completedStatus(missionWidget)
    missionWidget.status = MissionsLayer.CompletedStatus
    missionWidget:getChildByName("Image_missionBg"):loadTexture("res/mission/info_completed.png")
    missionWidget:getChildByName("Image_infoBg"):loadTexture("res/mission/info_completed_coins.png")
    missionWidget:getChildByName("Image_check"):setVisible(true)
    missionWidget:getChildByName("Image_check"):setPosition(127,92)
end

--已领取奖励状态
function MissionsLayer:getRewardStatus(missionWidget)
    missionWidget.status = MissionsLayer.GetRewardStatus
    missionWidget:getChildByName("Text_reward"):setVisible(false)
    missionWidget:getChildByName("Image_missionBg"):loadTexture("res/mission/cmissionbg01.png")
    missionWidget:getChildByName("Image_infoBg"):setVisible(false)
    missionWidget:getChildByName("Image_check"):setVisible(true)
    missionWidget:getChildByName("Image_check"):setPosition(127,34)
end

function MissionsLayer:exit()
    bole.socket:unregisterCmd("complete_task")
    bole.socket:unregisterCmd("collect_task_reward")
    bole:removeListener("initMissionsLayer", self)
    --self:closeUI()
end


return MissionsLayer

--endregion
