--region *.lua
--Date
--此文件由[BabeLua]插件自动生成

local ChatClubTaskCell = class("ChatClubTaskCell", ccui.Layout)


function ChatClubTaskCell:ctor()
    local chatWidget = self
    chatWidget:setContentSize(580, 100)

    local widget = cc.CSLoader:createNode("inSlot_chat/ChatClubTaskCell.csb")
    chatWidget:addChild(widget)

    local root = widget:getChildByName("root")
    self.themeIcon_ = root:getChildByName("icon")
    self.btn_show_ = root:getChildByName("btn_collect")
    self.btn_show_:addTouchEventListener(handler(self, self.touchEvent))
    self.txt_tips_ = root:getChildByName("txt_tips")
    --self.loadingBar_ = root:getChildByName("LoadingBar")
    self.txt_coins_ = root:getChildByName("img_icon_bg"):getChildByName("txt_coins")

    self.sp_star1_ = root:getChildByName("sp_star1"):getChildByName("sp_star1_no")
    self.sp_star2_ = root:getChildByName("sp_star2"):getChildByName("sp_star2_no")
    self.sp_star3_ = root:getChildByName("sp_star3"):getChildByName("sp_star3_no")

    bole.socket:registerCmd("club_collect", self.club_collect, self)
end

function ChatClubTaskCell:refreshInfo(clubInfo)
    self.taskInfo_ = clubInfo.rewards[1]
    self.usersInfo_ = clubInfo.users
    local total = tonumber(self.taskInfo_.total)
    local amount = tonumber(self.taskInfo_.amount)
    local level = tonumber(self.taskInfo_.level)
    local theme_id = bole:getConfigCenter():getConfig("clubevent", tonumber(self.taskInfo_.id), "clubevent_theme")
    self.taskInfo_.theme_id = tonumber(theme_id) % 1000
    self.taskInfo_.finish = false

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


    self:refreshView()
end

function ChatClubTaskCell:refreshView()
    local theme_icons = { "oz_icon", "farm_icon", "elvis_icon","dragon_icon","sea_icon","chilli_icon","temple_icon" }
    self.themeIcon_:loadTexture("theme_icon/theme_0" .. self.taskInfo_.theme_id .. ".png")
    --self.txt_tips_:setString("Your club achieved goal " .. self.taskInfo_.stage - 1)
    if self.taskInfo_.finish then
        --self.txt_tips_:setString("Your club achieved goal 3" .. self.taskInfo_.stage)
    end

    --self.loadingBar_:setPercent(self.taskInfo_.percent)
    --self.txt_coins_:setString( self.taskInfo_.rewardStr)
    self:initCollectStatus()
end


function ChatClubTaskCell:initCollectStatus()

    if self.taskInfo_.stage == 1 then
        self.themeIcon_:setTouchEnabled(false)
        self.sp_star1_:setVisible(false)
        self.sp_star2_:setVisible(false)
        self.sp_star3_:setVisible(false)
    elseif self.taskInfo_.stage == 2 then
        self.themeIcon_:setTouchEnabled(false)
        self.sp_star1_:setVisible(true)
        self.sp_star2_:setVisible(false)
        self.sp_star3_:setVisible(false)
    elseif self.taskInfo_.stage == 3 then
        self.themeIcon_:setTouchEnabled(false)
        self.sp_star1_:setVisible(true)
        self.sp_star2_:setVisible(true)
        self.sp_star3_:setVisible(false)
        if self.finish_ then
            self.sp_star3_:setVisible(true)
            self.btn_show_:getChildByName("txt_key"):setString("Collected") 
            self.themeIcon_:setTouchEnabled(false)
        end
    end

    if self.taskInfo_.collect == 0 then
        self.btn_show_:getChildByName("txt_key"):setString("Collected")
        self.btn_show_:setTouchEnabled(true)
        self.btn_show_:setBright(true)
    elseif self.taskInfo_.collect >= 1000 then
        self.btn_show_:getChildByName("txt_key"):setString("Collect")
        self.txt_coins_:setString(self:getRewardStr("clubevent_reward1"))
        self.btn_show_:setTouchEnabled(true)
        self.btn_show_:setBright(true)
    elseif self.taskInfo_.collect >= 100 and self.taskInfo_.collect < 1000 then
        self.btn_show_:getChildByName("txt_key"):setString("Collect")
        self.txt_coins_:setString(self:getRewardStr("clubevent_reward2"))
        self.btn_show_:setTouchEnabled(true)
        self.btn_show_:setBright(true)
    elseif self.taskInfo_.collect >= 10 and self.taskInfo_.collect < 100 then
        self.btn_show_:getChildByName("txt_key"):setString("Collect")
        self.txt_coins_:setString(self:getRewardStr("clubevent_reward3"))
        self.btn_show_:setTouchEnabled(true)
        self.btn_show_:setBright(true)
    elseif self.taskInfo_.collect >= 1 and self.taskInfo_.collect <= 3 then
        self.btn_show_:getChildByName("txt_key"):setString("Collect")
        self.txt_coins_:setString(self:getRewardStr("clubevent_specialreward" .. self.taskInfo_.collect ))
        self.btn_show_:setTouchEnabled(true)
        self.btn_show_:setBright(true)
    end
end

function ChatClubTaskCell:touchEvent(sender, eventType)
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
        if name == "btn_collect" then
            if self.taskInfo_.collect == 0 then
                if bole:getClubManage():isInClub() then
                    --self:showInfo()
                else
                    bole:popMsg({msg ="Sorry,you have left club." , title = "collect" , cancle = false})
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

function ChatClubTaskCell:getRewardStr(stageStr)
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
            typeStr = "copper coupon"
         elseif type == 3 then
            typeStr = "silver coupon"
         elseif type == 4 then
            typeStr = "golden coupon"
         elseif type == 8 then
            typeStr = "lobby coupon"
         else
            typeStr = "\"" .. type .. "\""
         end         

         rewardStr = rewardStr .. bole:formatCoins(number,5)  .. " " .. typeStr
         if i ~= #rewardIdTable then
            rewardStr = rewardStr .. ","
         end
    end
    return bole:formatCoins(self.taskInfo_.coinsRewards,15)
    --return rewardStr
end

function ChatClubTaskCell:club_collect(t,data)
    if t == "club_collect" then
        if data.error == 0 then
            local collect = data.collect
            self:collectReward(collect)
        elseif data.error == 2 then
            bole:popMsg({msg ="Sorry,you have left club." , title = "collect" , cancle = false})
        end
    end
end

function ChatClubTaskCell:collectReward(collect)
     --   bole:getUserData():updateSceneInfo("diamond")
     --bole:getAppManage():addCoins(tonumber(self.taskInfo_.coinsRewards))
    local syncUserInfo = bole:getUserData():getSyncUserInfo()
    local coins = syncUserInfo.coins
     bole:postEvent("putWinCoinToTop", { coin = coins })
    --TODO其他奖励
    self.taskInfo_.collect = self.taskInfo_.collect - collect
    self:initCollectStatus()

end

function ChatClubTaskCell:showInfo()
    bole:getUIManage():openUI("ClubTaskInfoLayer",true,"club")
    bole:postEvent("initClubTaskInfoLayer", {task = self.taskInfo_, users = self.usersInfo_})
end

function ChatClubTaskCell:removeListener()
    bole.socket:unregisterCmd("club_collect")
end

return ChatClubTaskCell
--endregion
