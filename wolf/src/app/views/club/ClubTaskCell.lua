--region *.lua
--Date
--此文件由[BabeLua]插件自动生成
local ClubTaskCell = class("ClubTaskCell", cc.Node)
function ClubTaskCell:ctor(data,users,i)
    self.node = cc.CSLoader:createNode("csb/club_cell/ClubTaskCell.csb")

    self.taskInfo_ = data
    self.usersInfo_ = users
    self.finish_ = false
    self.date_ = i

    self.btn_show_ =  self.node:getChildByName("btn_show")
    self.btn_show_:addTouchEventListener(handler(self, self.touchEvent))

    bole.socket:registerCmd("club_collect", self.club_collect, self)

    self:initInfo()
    self:initShowInfo()
    self:initTop()
    self:initCollectStatus()

    self:addChild(self.node)
end


function ClubTaskCell:refrushTaskInfo(data,users)
    self.taskInfo_ = data
    self.usersInfo_ = users
    self.finish_ = false
    self:initInfo()
    self:initShowInfo()
    self:initTop()
    self:initCollectStatus()
end

function ClubTaskCell:initInfo()

    local total = tonumber(self.taskInfo_.total)
    local amount = tonumber(self.taskInfo_.amount)
    local level = tonumber(self.taskInfo_.level)
    local theme_id = bole:getConfigCenter():getConfig("clubevent", tonumber(self.taskInfo_.id), "clubevent_theme")
    self.taskInfo_.theme_id = tonumber(theme_id) % 1000

    if amount < total * 0.1 then
        self.taskInfo_.stage = 1
        self.taskInfo_.stageTotal = total * 0.1
        self.taskInfo_.stageAmount = amount
    elseif amount >= total * 0.1 and amount < total * 0.5 then
        self.taskInfo_.stage = 2
        self.taskInfo_.stageTotal = total * 0.4
        self.taskInfo_.stageAmount = amount - total * 0.1
    elseif amount >= total * 0.5 and amount < total then
        self.taskInfo_.stage = 3
        self.taskInfo_.stageTotal = total * 0.5
        self.taskInfo_.stageAmount = amount - total * 0.5
    elseif  amount >= total then
        self.taskInfo_.stage = 3
        self.taskInfo_.finish = true
        self.finish_ = true
        self.taskInfo_.stageTotal = total * 0.5
        self.taskInfo_.stageAmount = total * 0.5
    end
  
    self.taskInfo_.rewardStr = self:getRewardStr("clubevent_reward" .. self.taskInfo_.stage)
    local titleStr = bole:getConfigCenter():getConfig("clubevent", tonumber(self.taskInfo_.id), "clubevent_text")
    self.taskInfo_.titleStr = string.format(titleStr, bole:formatCoins(self.taskInfo_.stageTotal,5) ,self.taskInfo_.rewardStr)
    self.taskInfo_.percent = tonumber(self.taskInfo_.stageAmount) / tonumber(self.taskInfo_.stageTotal) * 100
    
    for i = 1, # self.taskInfo_.top do
        for j = 1, # self.usersInfo_ do
            if tonumber(self.taskInfo_.top[i][1]) == tonumber(self.usersInfo_[j].user_id) then
                self.taskInfo_.top[i].info = self.usersInfo_[j]
                break
            end
        end
    end
    
end


function ClubTaskCell:getRewardStr(stageStr)
    local rewardStr = ""
    local rewardIdTable = bole:getConfigCenter():getConfig("clubevent_reward", 100 + tonumber(self.taskInfo_.level) , stageStr )
    for i = 1, #rewardIdTable do
         local typeStr = ""
         local type = bole:getConfigCenter():getConfig("reward", rewardIdTable[i] , "bonus_type")
         local number = bole:getConfigCenter():getConfig("reward", rewardIdTable[i] , "bonus_number")
         if type == 10 then
            typeStr = "coins"
            self.taskInfo_.coinsRewards = number
         elseif type == 9 then
            typeStr = "diamond"
            self.taskInfo_.diamondRewards = number
         elseif type == 2 then
            typeStr = "铜卷"
         elseif type == 3 then
            typeStr = "银卷"
         elseif type == 4 then
            typeStr = "金券"
         elseif type == 8 then
            typeStr = "大厅加速券"
         else
            typeStr = "\"" .. type .. "\""
         end         

         rewardStr = rewardStr .. bole:formatCoins(number,5)  .. " " .. typeStr
         if i ~= #rewardIdTable then
            rewardStr = rewardStr .. ","
         end
    end
    return rewardStr
end

function ClubTaskCell:initShowInfo()
    --动画展示
    self.themeIcon_ = self.node:getChildByName("sp_syl")
    if self.bar_cell_ == nil then
        self.bar_cell_ =  self:createProgressTimer()
        self:addChild(self.bar_cell_)
    end
    self:showAction()

    self.titleTxt_ = self.node:getChildByName("txt_tips_1")
    self.titleTxt_:setString(self.taskInfo_.titleStr)
    --self.bar_cell_ =  self.node:getChildByName("bar_cell") 
   -- self.bar_cell_:setPercent(tonumber(self.taskInfo_.stageAmount) / tonumber(self.taskInfo_.stageTotal) * 100)

    self.timeEnd_ = self.node:getChildByName("txt_time") 
    if self.taskInfo_.leave ~= nil then
        self.timeEnd_:setString("ends in: " .. bole:timeFormat(self.taskInfo_.leave))
        if self.scheduler_ == nil then
            local function update()
                 self.timeEnd_:setString("ends in: " .. bole:timeFormat(self.taskInfo_.leave))
                self.taskInfo_.leave = self.taskInfo_.leave - 1
            end
            self.scheduler_ = cc.Director:getInstance():getScheduler():scheduleScriptFunc(update, 1, false)
        end
        
    else
        self.timeEnd_:setString("ended")
    end

    local theme_icons = { "oz_icon", "farm_icon", "elvis_icon","dragon_icon","sea_icon","chilli_icon","temple_icon" }
    self.themeIcon_:loadTexture("res/theme_icon/" .. theme_icons[self.taskInfo_.theme_id] .. ".png")
    self.themeIcon_:addTouchEventListener(handler(self, self.touchEvent))
    if self.date_ ~= 1 then
        self.themeIcon_:setTouchEnabled(false)
        self.themeIcon_:getChildByName("com"):setVisible(true)
    else
        --self.themeIcon_:getChildByName("com"):setVisible(false)
    end
end

function ClubTaskCell:initTop()
    for i = 1, 3 do
        self.node:getChildByName("Node_" .. i):removeAllChildren()
        if self.taskInfo_.top[i] ~= nil then
            if self.taskInfo_.top[i].info ~= nil then
                local head = bole:getNewHeadView(self.taskInfo_.top[i].info) 
                head:setScale(0.8)
                head:setSwallow(true)
                self.node:getChildByName("Node_" .. i):addChild(head)
            else
                local info = require("json").decode(self.taskInfo_.top[i][3])
                local head = bole:getNewHeadView({ user_id = self.taskInfo_.top[i][1], name = info[1], level = info[2], country = info[3] })
                head:setScale(0.8)
                head:setSwallow(true)
                head.Img_headbg:setTouchEnabled(false)
                self.node:getChildByName("Node_" .. i):addChild(head)
            end
        else
                local head = bole:getNewHeadView()
                head:setScale(0.8)
                head:setSwallow(true)
                head.Img_headbg:setTouchEnabled(false)
                self.node:getChildByName("Node_" .. i):addChild(head)
        end
    end

end



function ClubTaskCell:initCollectStatus()
    if self.taskInfo_.stage == 1 then
        --self.node:getChildByName("sp_star1"):getChildByName("sp_star1_no"):setVisible(false)
        --self.node:getChildByName("sp_star2"):getChildByName("sp_star2_no"):setVisible(false)
        --self.node:getChildByName("sp_star3"):getChildByName("sp_star3_no"):setVisible(false)
        self.themeIcon_:setTouchEnabled(true)
    elseif self.taskInfo_.stage == 2 then
        --self.node:getChildByName("sp_star1"):getChildByName("sp_star1_no"):setVisible(true)
        --self.node:getChildByName("sp_star2"):getChildByName("sp_star2_no"):setVisible(false)
        --self.node:getChildByName("sp_star3"):getChildByName("sp_star3_no"):setVisible(false)
        self.themeIcon_:setTouchEnabled(true)
    elseif self.taskInfo_.stage == 3 then
        --self.node:getChildByName("sp_star1"):getChildByName("sp_star1_no"):setVisible(true)
        --self.node:getChildByName("sp_star2"):getChildByName("sp_star2_no"):setVisible(true)
        --self.node:getChildByName("sp_star3"):getChildByName("sp_star3_no"):setVisible(false)
        self.themeIcon_:setTouchEnabled(true)
        if self.finish_ then
            --self.node:getChildByName("sp_star1"):getChildByName("sp_star1_no"):setVisible(true)
            --self.node:getChildByName("sp_star2"):getChildByName("sp_star2_no"):setVisible(true)
            --self.node:getChildByName("sp_star3"):getChildByName("sp_star3_no"):setVisible(true)
            self.btn_show_:getChildByName("txt_key"):setString("Show Info")
            self.themeIcon_:setTouchEnabled(false)
            --self.themeIcon_:getChildByName("com"):setVisible(true)
        end
    end

    if self.date_ ~= 1 then
        self.themeIcon_:setTouchEnabled(false)
        self.themeIcon_:getChildByName("com"):setVisible(true)
    end

    if self.taskInfo_.collect == 0 then
        self.btn_show_:getChildByName("txt_key"):setString("Show Info")
        self.btn_show_:setTouchEnabled(true)
        self.btn_show_:setBright(true)
    elseif self.taskInfo_.collect >= 1000 then
        self.btn_show_:getChildByName("txt_key"):setString(self:getRewardStr("clubevent_reward1"))
        self.btn_show_:setTouchEnabled(true)
        self.btn_show_:setBright(true)
    elseif self.taskInfo_.collect >= 100 and self.taskInfo_.collect < 1000 then
        self.btn_show_:getChildByName("txt_key"):setString(self:getRewardStr("clubevent_reward2"))
        self.btn_show_:setTouchEnabled(true)
        self.btn_show_:setBright(true)
    elseif self.taskInfo_.collect >= 10 and self.taskInfo_.collect < 100 then
        self.btn_show_:getChildByName("txt_key"):setString(self:getRewardStr("clubevent_reward3"))
        self.btn_show_:setTouchEnabled(true)
        self.btn_show_:setBright(true)
    elseif self.taskInfo_.collect >= 1 and self.taskInfo_.collect <= 3 then
        self.btn_show_:getChildByName("txt_key"):setString(self:getRewardStr("clubevent_specialreward" .. self.taskInfo_.collect ))
        self.btn_show_:setTouchEnabled(true)
        self.btn_show_:setBright(true)
    end

end


function ClubTaskCell:touchEvent(sender, eventType)
    local name = sender:getName()
    local tag = sender:getTag()
    print("touchEvent:" .. name)
    if eventType == ccui.TouchEventType.began then
        sender:runAction(cc.ScaleTo:create(0.1, 1.05, 1.05))
        print("Touch Down")
    elseif eventType == ccui.TouchEventType.moved then
        print("Touch Move")
    elseif eventType == ccui.TouchEventType.ended then
         sender:runAction(cc.ScaleTo:create(0.1, 1, 1))
        print("Touch Up")
        if name == "btn_close" then
            self:removeFromParent()
        elseif name == "btn_ok" then
            self:complete()
        elseif name == "sp_syl" then
            bole:getAppManage():startGame(self.taskInfo_.theme_id)
        elseif name == "btn_show" then
            if self.taskInfo_.collect == 0 then
                if tonumber(bole:getUserDataByKey("club")) == 0 then
                    bole:getUIManage():openClubTipsView(11,nil)
                else
                    self:showInfo()
                end
            else
                self.btn_show_:setTouchEnabled(false)
                self.btn_show_:setBright(false)
                bole.socket:send("club_collect",{date = self.taskInfo_.date },true)
                --self:collectReward(100)
            end
        end
    elseif eventType == ccui.TouchEventType.canceled then
         sender:runAction(cc.ScaleTo:create(0.1, 1, 1))
        print("Touch Cancelled")
    end
end


function ClubTaskCell:collectReward(collect)
    print(self.taskInfo_.coinsRewards)
    if self.taskInfo_.coinsRewards ~= nil then
        --bole:getAppManage():addCoins(tonumber(self.taskInfo_.coinsRewards))
        bole:getUserData():updateSceneInfo("coins")
        bole:getUserData():updateSceneInfo("diamond")
    end
    --TODO其他奖励
    self.taskInfo_.collect = self.taskInfo_.collect - collect
    self:initCollectStatus()

    if self.date_ ~= 1 then
        if self.taskInfo_.collect == 0 then
            bole:postEvent("collectClubTask", self.date_)
        end
    end
end



function ClubTaskCell:club_collect(t,data)
    if t == "club_collect" then
        if data.error == 0 then
            local collect = data.collect
            self:collectReward(collect)
        elseif data.error == 2 then
            bole:getUIManage():openClubTipsView(11,nil)
        end
    end
end

function ClubTaskCell:showInfo()
    bole:getUIManage():openUI("ClubTaskInfoLayer",true,"csb/club")
    bole:postEvent("initClubTaskInfoLayer", {task = self.taskInfo_, users = self.usersInfo_})
end


function ClubTaskCell:showAction()
    local str = cc.UserDefault:getInstance():getStringForKey("taskSchedule")
    local date = self.date_
    local stage = 1
    local percent = 0
    local finish = 0
    if str ~= "" then
        local preTaskSchedule = require("json").decode(str)
        if preTaskSchedule ~= nil then
            for k , v in pairs(preTaskSchedule) do
                if k == self.taskInfo_.date then
                    date = v.date
                    stage = v.stage
                    percent = v.percent
                    finish = v.finish
                end
            end
        end
    end

      if stage == 1 then
            self.node:getChildByName("sp_star1"):getChildByName("sp_star1_no"):setVisible(false)
            self.node:getChildByName("sp_star2"):getChildByName("sp_star2_no"):setVisible(false)
            self.node:getChildByName("sp_star3"):getChildByName("sp_star3_no"):setVisible(false)
            self.themeIcon_:getChildByName("com"):setVisible(false)
        elseif stage == 2 then
            self.node:getChildByName("sp_star1"):getChildByName("sp_star1_no"):setVisible(true)
            self.node:getChildByName("sp_star2"):getChildByName("sp_star2_no"):setVisible(false)
            self.node:getChildByName("sp_star3"):getChildByName("sp_star3_no"):setVisible(false)
            self.themeIcon_:getChildByName("com"):setVisible(false)
        elseif stage == 3 then
            self.node:getChildByName("sp_star1"):getChildByName("sp_star1_no"):setVisible(true)
            self.node:getChildByName("sp_star2"):getChildByName("sp_star2_no"):setVisible(true)
            self.node:getChildByName("sp_star3"):getChildByName("sp_star3_no"):setVisible(false)
            self.themeIcon_:getChildByName("com"):setVisible(false)
             if finish == 1 then
                self.node:getChildByName("sp_star1"):getChildByName("sp_star1_no"):setVisible(true)
                self.node:getChildByName("sp_star2"):getChildByName("sp_star2_no"):setVisible(true)
                self.node:getChildByName("sp_star3"):getChildByName("sp_star3_no"):setVisible(true)
                self.themeIcon_:getChildByName("com"):setVisible(true)
            end
       end

    self.bar_cell_:setPercentage(percent)

    local progressTo1 = cc.ProgressTo:create( (self.taskInfo_.percent - percent) / 100, self.taskInfo_.percent)  
    local progressTo2 = cc.ProgressTo:create( (100 - percent) / 100, 100)
    local progressTo3 = cc.ProgressTo:create( 1, 100) 
    local clear = cc.CallFunc:create(function() self.bar_cell_:setPercentage(0) end)  
    local opemStar1 = cc.CallFunc:create(function() self.node:getChildByName("sp_star1"):getChildByName("sp_star1_no"):setVisible(true) end) 
    local opemStar2 = cc.CallFunc:create(function() self.node:getChildByName("sp_star2"):getChildByName("sp_star2_no"):setVisible(true) end) 
    local opemStar3 = cc.CallFunc:create(function() self.node:getChildByName("sp_star3"):getChildByName("sp_star3_no"):setVisible(true) self.themeIcon_:getChildByName("com"):setVisible(true) end) 

    if stage == self.taskInfo_.stage then
        if percent < self.taskInfo_.percent then
            if self.finish_ then
                self.bar_cell_ :runAction(cc.Sequence:create(progressTo1,opemStar3)) 
            else
                self.bar_cell_ :runAction(cc.Sequence:create(progressTo1)) 
            end 
        end
    else
        if self.taskInfo_.stage - stage == 1 then
            if self.finish_ then
                self.bar_cell_:runAction(cc.Sequence:create(progressTo2,opemStar2,clear,progressTo1,opemStar3)) 
            else
                if self.taskInfo_.stage == 3 then
                    self.bar_cell_:runAction(cc.Sequence:create(progressTo2,opemStar2,clear,progressTo1)) 
                elseif self.taskInfo_.stage == 2 then
                    self.bar_cell_:runAction(cc.Sequence:create(progressTo2,opemStar1,clear,progressTo1)) 
                end
            end
        elseif self.taskInfo_.stage - stage == 2 then
            if self.finish_ then
                self.bar_cell_:runAction(cc.Sequence:create(progressTo2,opemStar1,clear,progressTo3,opemStar2,clear,progressTo1,opemStar3)) 
            else
                self.bar_cell_:runAction(cc.Sequence:create(progressTo2,opemStar1,clear,progressTo3,opemStar2,clear,progressTo1)  ) 
            end
        end
    end

    self.nowSchedule_ = {}
    self.nowSchedule_.date = self.date_
    self.nowSchedule_.stage = self.taskInfo_.stage
    self.nowSchedule_.percent = self.taskInfo_.percent
    self.nowSchedule_.day = self.taskInfo_.date
    if self.finish_ then
        self.nowSchedule_.finish = 1
    else
        self.nowSchedule_.finish = 0
    end
end


function ClubTaskCell:createProgressTimer()
       
    local bloodEmptyBg = cc.Sprite:create("res/club/club_progressbar01.png")
    bloodEmptyBg:setPosition(-222,-27)
    self:addChild(bloodEmptyBg)  
  
    local bloodBody = cc.Sprite:create("res/club/club_progressbar02.png")  
 
    --创建进度条  
    local bloodProgress = cc.ProgressTimer:create(bloodBody)  
    bloodProgress:setType(cc.PROGRESS_TIMER_TYPE_BAR) --设置为条形 type:cc.PROGRESS_TIMER_TYPE_RADIAL  
    bloodProgress:setMidpoint(cc.p(0,0)) --设置起点为条形坐下方  
    bloodProgress:setBarChangeRate(cc.p(1,0))  --设置为竖直方向  
    bloodProgress:setPercentage(10) -- 设置初始进度为30  
    bloodProgress:setPosition(-222,-27)  
    return bloodProgress
end

function ClubTaskCell:exit()
    if self.scheduler_ then
        print("remove scheduler --------------------------------------------------------")
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.scheduler_)
        self.scheduler_ = nil
    end
    bole.socket:unregisterCmd("club_collect")
end


return ClubTaskCell


--endregion
