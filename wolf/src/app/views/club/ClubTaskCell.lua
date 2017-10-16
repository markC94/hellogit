--region *.lua
--Date
--此文件由[BabeLua]插件自动生成
local ClubTaskCell = class("ClubTaskCell", cc.Node)
local ShowInfoBtnPath = "loadImage/club_wall_task_showInfoBtn.png"
local CollectBtnPath = "loadImage/club_wall_task_collectBtn.png"
function ClubTaskCell:ctor(data,users,i)
    local node = cc.CSLoader:createNode("club/ClubTaskCell.csb")
    self.node = node:getChildByName("root")
    self.bg =  self.node:getChildByName("bg")
    self.actTable_ = {}

    self.taskInfo_ = data
    self.usersInfo_ = users
    self.finish_ = false
    self.date_ = i

    bole.socket:registerCmd("club_collect", self.club_collect, self)

    self:initPanelTask()
    self:initActNode()
    self:initInfo() 
    self:initShowInfo()
    self:initTop()
    self:initCollectStatus()

    self:addChild(node)
end


function ClubTaskCell:refrushTaskInfo(data,users)
    self.taskInfo_ = data
    self.usersInfo_ = users
    self.finish_ = false
    self:initActNode()
    self:initInfo()
    self:initShowInfo()
    self:initTop()
    self:initCollectStatus()
end

function ClubTaskCell:initActNode()
    self.act_star1 = self.node:getChildByName("act_star1")
    self.act_star1:removeAllChildren()
    self.act_star2 = self.node:getChildByName("act_star2")
    self.act_star2:removeAllChildren()
    self.act_star3 = self.node:getChildByName("act_star3")
    self.act_star3:removeAllChildren()
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
    self.taskInfo_.isFinish = self.finish_
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
            self.collectInfo_:getChildByName("coinsNum"):setString(bole:formatCoins(number,3) )
         elseif type == 9 then
            typeStr = "diamond"
            self.taskInfo_.diamondRewards = number
         elseif type == 2 then
            typeStr = "铜卷"
            self.collectInfo_:getChildByName("lettoryNum"):setString(number)
         elseif type == 3 then
            typeStr = "银卷"
            self.collectInfo_:getChildByName("lettoryNum"):setString(number)
         elseif type == 4 then
            typeStr = "金券"
            self.collectInfo_:getChildByName("lettoryNum"):setString(number)
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

function ClubTaskCell:initPanelTask()
    local panel_task = self.node:getChildByName("panel_task")
    panel_task:addTouchEventListener(handler(self, self.touchEvent))
    self.collectInfo_ = panel_task:getChildByName("collectInfo_bg")
    self.noComp_showInfo_ = panel_task:getChildByName("noComp_showInfo")
    self.can_collect_ = panel_task:getChildByName("can_collect")
    self.comp_showInfo_ = panel_task:getChildByName("comp_showInfo")

    self.sp_star1_ = self.node:getChildByName("sp_star1"):getChildByName("sp_star1_no")
    self.sp_star2_ = self.node:getChildByName("sp_star2"):getChildByName("sp_star2_no")
    self.sp_star3_ = self.node:getChildByName("sp_star3"):getChildByName("sp_star3_no")
    self.themeIcon_ = self.node:getChildByName("sp_syl")
    self.comIcon_ = self.themeIcon_:getChildByName("com")

    self.collectInfo_:setVisible(false)
    self.noComp_showInfo_:setVisible(false)
    self.can_collect_:setVisible(false)
    self.comp_showInfo_:setVisible(false)
end

function ClubTaskCell:initShowInfo()
    --动画展示
   
    if self.bar_cell_ == nil then
        self.bar_cell_ =  self:createProgressTimer()
        self.noComp_showInfo_:getChildByName("node_slider"):addChild(self.bar_cell_)
    end
   
    self:showAction()

    self.titleTxt_ = self.node:getChildByName("txt_tips_1")
    self.txt_coins_ = self.node:getChildByName("txt_coins")
    self.txt_coins_:setString(bole:formatCoins(self.taskInfo_.stageTotal,25))

    self.timeEnd_ = self.node:getChildByName("time_bg") 
    self.unit_1 = self.timeEnd_:getChildByName("panel_time"):getChildByName("time_1") 
    self.unit_2 = self.timeEnd_:getChildByName("panel_time"):getChildByName("time_2") 
    self.time_1 = self.timeEnd_:getChildByName("panel_time"):getChildByName("time_m") 
    self.time_2 = self.timeEnd_:getChildByName("panel_time"):getChildByName("time_s") 
    local clockAct = sp.SkeletonAnimation:create("shop_act/biao_1.json", "shop_act/biao_1.atlas")
    clockAct:setScale(0.42)
    clockAct:setAnimation(0, "animation", true)
    self.timeEnd_:getChildByName("panel_time"):getChildByName("node_act"):addChild(clockAct)

    self.timeEnd_:getChildByName("panel_end"):setVisible(false)
    if self.taskInfo_.leave ~= nil then
        bole.clubTask_surplus_time = self.taskInfo_.leave
        self:setTime(bole.clubTask_surplus_time)
        if self.scheduler_ == nil then
            local function update()
                self:setTime(bole.clubTask_surplus_time)
            end
            self.scheduler_ = cc.Director:getInstance():getScheduler():scheduleScriptFunc(update, 1, false)
        end        
    else
        self.timeEnd_:getChildByName("panel_time"):setVisible(false)
        self.timeEnd_:getChildByName("panel_end"):setVisible(true)
        if self.scheduler_ then
            cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.scheduler_)
            self.scheduler_ = nil
        end
    end

    local theme_icons = { "oz_icon", "farm_icon", "elvis_icon","dragon_icon","sea_icon","chilli_icon","temple_icon" }
    self.themeIcon_:loadTexture("theme_icon/theme_0" .. self.taskInfo_.theme_id .. ".png")
    self.themeIcon_:addTouchEventListener(handler(self, self.touchEvent))
    if self.date_ ~= 1 then
        self.themeIcon_:setTouchEnabled(false)
        self.themeIcon_:getChildByName("com"):setVisible(true)
    else
        --self.themeIcon_:getChildByName("com"):setVisible(false)
    end
end

function ClubTaskCell:setTime(time)
    if time > 0 then
        local s = math.floor(time) % 60
        local m = math.floor(time / 60) % 60
        local h = math.floor(time / 3600) % 24

        if h == 0 then
            self.unit_1:setString("M")
            self.unit_2:setString("S")
            self.time_1:setString(m)
            self.time_2:setString(s)
        else
            self.unit_1:setString("H")
            self.unit_2:setString("M")
            self.time_1:setString(h)
            self.time_2:setString(m)
        end
    else
        self.timeEnd_:getChildByName("panel_time"):setVisible(false)
        self.timeEnd_:getChildByName("panel_end"):setVisible(true)
        self.themeIcon_:setTouchEnabled(false)
        self.themeIcon_:getChildByName("com"):setVisible(true)
        if self.scheduler_ then
            cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.scheduler_)
            self.scheduler_ = nil
        end
    end
end


function ClubTaskCell:initTop()
    for i = 1, 3 do
        self.node:getChildByName("Node_" .. i):removeAllChildren()
        local head = nil
        if self.taskInfo_.top[i] ~= nil then
            if self.taskInfo_.top[i][1] == bole:getUserDataByKey("user_id") then
                head = bole:getNewHeadView(bole:getUserData())
                head:updatePos(head.POS_CLUB_SELF)
            else
                if self.taskInfo_.top[i].info ~= nil then
                    head = bole:getNewHeadView(self.taskInfo_.top[i].info)
                else
                    local info = require("json").decode(self.taskInfo_.top[i][3])
                    head = bole:getNewHeadView( { user_id = self.taskInfo_.top[i][1], name = info[1], icon = info[2], level = info[3], country = info[4] })
                end
            end
            head:setScale(0.8)
            head:setSwallow(true)
            head.Img_headbg:setTouchEnabled(false)
        else
            head = cc.Sprite:create("loadImage/club_wall_task_noPlayerIcon.png")
            head:setScale(0.8)
            --bole:getNewHeadView()
        end

        self.node:getChildByName("Node_" .. i):addChild(head)
    end
end



function ClubTaskCell:initCollectStatus()
    if self.taskInfo_.stage == 1 then
        self.themeIcon_:setTouchEnabled(true)
        self.sp_star1_:setVisible(false)
        self.sp_star2_:setVisible(false)
        self.sp_star3_:setVisible(false)
        self.comIcon_:setVisible(false)
    elseif self.taskInfo_.stage == 2 then
        self.themeIcon_:setTouchEnabled(true)
        self.sp_star1_:setVisible(true)
        self.sp_star2_:setVisible(false)
        self.sp_star3_:setVisible(false)
        self.comIcon_:setVisible(false)
    elseif self.taskInfo_.stage == 3 then
        self.themeIcon_:setTouchEnabled(true)
        self.sp_star1_:setVisible(true)
        self.sp_star2_:setVisible(true)
        self.sp_star3_:setVisible(false)
        self.comIcon_:setVisible(false)
        if self.finish_ then
            self.collectInfo_:setVisible(false)
            self.themeIcon_:setTouchEnabled(false)
            self.comIcon_:setVisible(true)
            self.sp_star3_:setVisible(true)
            self.bg:loadTexture("loadImage/club_frame_requests_dark.png")
        end
    end

    if self.date_ ~= 1 then
        self.themeIcon_:setTouchEnabled(false)
        self.themeIcon_:getChildByName("com"):setVisible(true)
    end

    if self.taskInfo_.collect == 0 then
        self.collectInfo_:setVisible(true)
        self.noComp_showInfo_:setVisible(true)
        self.can_collect_:setVisible(false)
        self.comp_showInfo_:setVisible(false)
        if self.finish_ then
            self.collectInfo_:setVisible(false)
            self.noComp_showInfo_:setVisible(false)
            self.comp_showInfo_:setVisible(true)
        end
    elseif self.taskInfo_.collect >= 1000 then
        --self.btn_show_:getChildByName("txt_key"):setString(self:getRewardStr("clubevent_reward1"))
        self:getRewardStr("clubevent_reward1")
        self.collectInfo_:setVisible(true)
        self.noComp_showInfo_:setVisible(false)
        self.can_collect_:setVisible(true)
        self.comp_showInfo_:setVisible(false)
    elseif self.taskInfo_.collect >= 100 and self.taskInfo_.collect < 1000 then
        --self.btn_show_:getChildByName("txt_key"):setString(self:getRewardStr("clubevent_reward2"))
        self:getRewardStr("clubevent_reward2")
        self.collectInfo_:setVisible(true)
        self.noComp_showInfo_:setVisible(false)
        self.can_collect_:setVisible(true)
        self.comp_showInfo_:setVisible(false)
    elseif self.taskInfo_.collect >= 10 and self.taskInfo_.collect < 100 then
        --self.btn_show_:getChildByName("txt_key"):setString(self:getRewardStr("clubevent_reward3"))
        self:getRewardStr("clubevent_reward3")
        self.collectInfo_:setVisible(true)
        self.noComp_showInfo_:setVisible(false)
        self.can_collect_:setVisible(true)
        self.comp_showInfo_:setVisible(false)
    elseif self.taskInfo_.collect >= 1 and self.taskInfo_.collect <= 3 then
        --self.btn_show_:getChildByName("txt_key"):setString(self:getRewardStr("clubevent_specialreward" .. self.taskInfo_.collect ))
        self:getRewardStr("clubevent_specialreward" .. math.min(2,self.taskInfo_.collect))
        --self.btn_show_:getChildByName("txt_key"):setString("Collect")
        self.collectInfo_:setVisible(true)
        self.noComp_showInfo_:setVisible(false)
        self.can_collect_:setVisible(true)
        self.comp_showInfo_:setVisible(false)
    end
    self.bar_cell_:setPercentage(self.taskInfo_.percent)
    self.vip_progressBarlight_:setPosition(206 * self.taskInfo_.percent / 100 - 103,0)
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
        elseif name == "panel_task" then
            if self.taskInfo_.collect == 0 then
                if bole:getClubManage():isInClub() then
                    self:showInfo()
                else
                    bole:popMsg({msg ="Sorry,you have left club." , title = "collect" , cancle = false})
                end
            else
                --self.btn_show_:setTouchEnabled(false)
                --self.btn_show_:setBright(false)
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
        bole:getAppManage():addCoins(tonumber(self.taskInfo_.coinsRewards))
     --   bole:getUserData():updateSceneInfo("diamond")
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
    if t == "club_collect" then  --
        if data.error == 0 then
            local collect = data.collect
            self:collectReward(collect)
        elseif data.error == 2 then  --已经退出联盟
            bole:popMsg({msg ="Sorry,you have left club." , title = "collect" , cancle = false})
        elseif data.error ~= nil then
            bole:popMsg({msg ="error:" .. data.error , title = "collect" })
        end
    end
end

function ClubTaskCell:showInfo()
    bole:getUIManage():openNewUI("ClubTaskInfoLayer",true,"club","app.views.club")
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
    --[[
     --self.btn_show_
    --self.infoShow_

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
    local opemStar1 = cc.CallFunc:create( function()
        local starAct = sp.SkeletonAnimation:create("club_act/xingxing_1.json", "club_act/xingxing_1.atlas")
        starAct:setAnimation(0, "animation", false)
        self.act_star1:addChild(starAct)
        
        self.actTable_[1] = starAct
    end )
    local opemStar2 = cc.CallFunc:create( function()
        local starAct = sp.SkeletonAnimation:create("club_act/xingxing_1.json", "club_act/xingxing_1.atlas")
        starAct:setAnimation(0, "animation", false)
        self.act_star2:addChild(starAct)
        
        self.actTable_[2] = starAct
    end )
    local opemStar3 = cc.CallFunc:create( function()
        local starAct = sp.SkeletonAnimation:create("club_act/xingxing_1.json", "club_act/xingxing_1.atlas")
        starAct:setAnimation(0, "animation", false)
        self.act_star3:addChild(starAct)
        self.themeIcon_:getChildByName("com"):setVisible(true)
        
        self.actTable_[3] = starAct
    end ) 

    local collectBtnAct = cc.CallFunc:create( function()
        local collectBtnAct = sp.SkeletonAnimation:create("club_act/julebu_jindutiao_1.json", "club_act/julebu_jindutiao_1.atlas")
        collectBtnAct:setAnimation(0, "zhangman", false)
        collectBtnAct:setPosition(1108.00, 36.00)
        self.node:addChild(collectBtnAct)

        self.actTable_[4] = collectBtnAct
    end ) 

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

    --self.bar_cell_:runAction(cc.Sequence:create(progressTo2,opemStar1,clear,progressTo3,opemStar2,clear,progressTo3,opemStar3,collectBtnAct)) 
    --]]
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
    local bloodBody = cc.Sprite:create("loadImage/club_wall_task_progressbar01.png")  
 
    --创建进度条  
    local bloodProgress = cc.ProgressTimer:create(bloodBody)  
    bloodProgress:setType(cc.PROGRESS_TIMER_TYPE_BAR) --设置为条形 type:cc.PROGRESS_TIMER_TYPE_RADIAL  
    bloodProgress:setMidpoint(cc.p(0,0)) --设置起点为条形坐下方  
    bloodProgress:setBarChangeRate(cc.p(1,0))  --设置为竖直方向  
    bloodProgress:setPercentage(100) -- 设置初始进度为30  
    bloodProgress:setPosition(0,0)  

    self.vip_progressBarlight_ = cc.Sprite:create("loadImage/club_wall_progressbar_light.png")  
    local clipNode = cc.ClippingNode:create()
    clipNode:setAnchorPoint(0.5,0.5)
    clipNode:setAlphaThreshold(0)
    clipNode:setStencil(cc.Sprite:create("loadImage/club_wall_task_progressbar01.png"))
    self.noComp_showInfo_:getChildByName("node_slider"):addChild(clipNode)  
    clipNode:addChild(self.vip_progressBarlight_)
    self.vip_progressBarlight_:setAnchorPoint(1,0.5)
    self.vip_progressBarlight_:setPosition(0,0)


    return bloodProgress
end

function ClubTaskCell:exit()
    if self.scheduler_ then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.scheduler_)
        self.scheduler_ = nil
    end
    bole.socket:unregisterCmd("club_collect")
end


return ClubTaskCell


--endregion
