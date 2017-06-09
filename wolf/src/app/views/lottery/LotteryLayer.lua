--region *.lua
--Date
--此文件由[BabeLua]插件自动生成

local LotteryLayer = class("LotteryLayer", cc.load("mvc").ViewBase)

function LotteryLayer:onCreate()
    print("LotteryLayer-onCreate")
    local root = self:getCsbNode():getChildByName("root")
    self.vouchersNum_ = bole:getUserDataByKey("vouchers")
    self.touchLayer_ = self:getCsbNode():getChildByName("Panel_touch")
    self.touchLayer_:addTouchEventListener(handler(self, self.touchLayerEvent))
    self.getVouchers_ = self.touchLayer_:getChildByName("Panel_get")
    
    self:initCollect(root)
    self:initFunc_btn(root)
    self:initFreeSchedule(root)
    self:initGetVouchers(root)
    self:adaptScreen(root)
end

function LotteryLayer:onEnter()
   bole.socket:registerCmd("enter_lottery", self.enter_lottery, self)
   bole.socket:registerCmd("use_lottery", self.use_lottery, self)
   bole:addListener("changeVouchers", self.changeVouchers, self, nil, true)
end


function LotteryLayer:enter_lottery(t,data)
    if t == "enter_lottery" then
        self.lotteryInfo_ = data
        self:refreshCollect()
        self:refreshFuncbtn()
        self:refreshFreeSchedule()
    end
end

function LotteryLayer:initCollect(root)
    local showInfo = root:getChildByName("showInfo")
    showInfo:addTouchEventListener(handler(self, self.touchEvent))
end

function LotteryLayer:initFunc_btn(root)
    local func_btn = root:getChildByName("func_btn")
    self.btn_golden_ = func_btn:getChildByName("btn_3")
    self.btn_golden_:addTouchEventListener(handler(self, self.touchEvent))
    self.btn_golden_:setTouchEnabled(false)
    self.btn_silver_ = func_btn:getChildByName("btn_2")
    self.btn_silver_:addTouchEventListener(handler(self, self.touchEvent))
    self.btn_silver_:setTouchEnabled(false)
    self.btn_copper_ = func_btn:getChildByName("btn_1")
    self.btn_copper_:addTouchEventListener(handler(self, self.touchEvent))
    self.btn_copper_:setTouchEnabled(false)
end

function LotteryLayer:initFreeSchedule(root)
    local schedule = root:getChildByName("schedule")
    self.schedule_ = self:createProgressTimer(schedule)
    self.collect_ = root:getChildByName("collect")
    self.copperCollect_ = root:getChildByName("collect"):getChildByName("collect_1")
    self.silverCollect_ = root:getChildByName("collect"):getChildByName("collect_2")
    self.goldenCollect_ = root:getChildByName("collect"):getChildByName("collect_3")
end

function LotteryLayer:initGetVouchers(root)
    local btn_buy1 = self.getVouchers_:getChildByName("buy1"):getChildByName("buy1")
    btn_buy1:addTouchEventListener(handler(self, self.touchEvent))
    local btn_buy2 = self.getVouchers_:getChildByName("buy2"):getChildByName("buy2")
    btn_buy2:addTouchEventListener(handler(self, self.touchEvent))
    local btn_buy3 = self.getVouchers_:getChildByName("buy3"):getChildByName("buy3")
    btn_buy3:addTouchEventListener(handler(self, self.touchEvent))
end

function LotteryLayer:refreshCollect()
    for j = 1, 3 do
        for i = 1, 4 do
            if i <= self.lotteryInfo_.coins_vouchers[j] then
                self.collect_:getChildByName("collect_" .. j):getChildByName("sp_star" .. i):getChildByName("sp_star_no"):setVisible(true)
            else
                self.collect_:getChildByName("collect_" .. j):getChildByName("sp_star" .. i):getChildByName("sp_star_no"):setVisible(false)
            end
        end
    end
end

function LotteryLayer:refreshFuncbtn()
    self.btn_golden_:getChildByName("num"):setString(self.vouchersNum_[3])
    self.btn_golden_:setTouchEnabled(true)
    self.btn_silver_:getChildByName("num"):setString(self.vouchersNum_[2])
    self.btn_silver_:setTouchEnabled(true)
    self.btn_copper_:getChildByName("num"):setString(self.vouchersNum_[1]) 
    self.btn_copper_:setTouchEnabled(true)
      
    if self.vouchersNum_[3] == 0 then
        self.btn_golden_:getChildByName("text"):setString("Get!")
    end
    if self.vouchersNum_[2] == 0 then
        self.btn_silver_:getChildByName("text"):setString("Get!")
    end
    if self.vouchersNum_[1] == 0 then
        self.btn_copper_:getChildByName("text"):setString("Get!")
    end
end

function LotteryLayer:refreshFreeSchedule()
    self.schedule_:setPercentage(self.lotteryInfo_.free_voucher * 10)
end



function LotteryLayer:touchEvent(sender, eventType)
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
        if name == "btn_close" then
            self:closeUI()
        elseif name == "btn_1" then
            self:playLottery(1,sender)
        elseif name == "btn_2" then
            self:playLottery(2,sender)
        elseif name == "btn_3" then
            self:playLottery(3,sender)
        elseif name == "showInfo" then
            bole:getUIManage():openUI("LotteryInfoLayer",true,"csb/lottery")
        elseif name == "buy1" then
            print(self.kindId_)
        elseif name == "buy2" then
            print(self.kindId_)
        elseif name == "buy3" then
            print(self.kindId_)
        end

    elseif eventType == ccui.TouchEventType.canceled then
        print("Touch Cancelled")
        sender:setScale(1)
    end
end

function LotteryLayer:touchLayerEvent(sender, eventType)
    if eventType == ccui.TouchEventType.ended then
        self.touchLayer_:setVisible(false)
    end
end

function LotteryLayer:playLottery(kindId,sender)
    self.kindId_ = kindId
    if self.vouchersNum_[kindId] == 0 then
        local pos = sender:convertToWorldSpace(cc.p(0,0))
        self.pos_ = pos
        self:refreshBuyView(kindId,pos)
    else
        self.useLottery_ = kindId
        bole.socket:send("use_lottery", { kind = kindId }, true)
    end
end

function LotteryLayer:use_lottery(t,data)
    if t == "use_lottery" then
        --TODO
        if data.error == 0 then
            if self.useLottery_ ~= nil then
                self.vouchersNum_[self.useLottery_] = self.vouchersNum_[self.useLottery_] - 1
            end
            --bole:setUserDataByKey("vouchers",self.vouchersNum_)
            bole:getUIManage():openUI("LotteryCollectLayer",true,"csb/lottery")
            bole:postEvent("initCollectInfo",data)
            self:showAction(data)
            self:refreshFuncbtn()
            for i = 1, 3 do
                if self.lotteryInfo_.coins_vouchers[i] == 3 and data.coins_vouchers[i] == 0 then
                    --TODO 收集齐了
                    bole:getUserData():updateSceneInfo("coins")
                    self.lotteryInfo_.coins_vouchers[i] = 0
                end
            end
            self.lotteryInfo_.coins_vouchers = data.coins_vouchers
            self:refreshCollect()
        elseif data.error == 3 then
            self:refreshBuyView(self.kindId_,self.pos)
        end
    end
end

function LotteryLayer:showAction(data)
    if data.free_voucher ~= 0 then
        local progressTo1 = cc.ProgressTo:create(0.2,data.free_voucher * 10)  
        self.schedule_:runAction(progressTo1) 
    else
        local progressTo1 = cc.ProgressTo:create(0.2,100)  
        local clear = cc.CallFunc:create(function() self.schedule_:setPercentage(0) end)  
        self.schedule_:runAction(cc.Sequence:create(progressTo1,clear)) 
        self.vouchersNum_[2] = self.vouchersNum_[2] + 1
        --bole:setUserDataByKey("vouchers",self.vouchersNum_)
        self:refreshFuncbtn()
    end
end

function LotteryLayer:changeVouchers(data)
    data = data.result

    if self.vouchersNum_[data.index] ~= nil then
        self.vouchersNum_[data.index] = self.vouchersNum_[data.index] + data.changeNum
    end
    --bole:setUserDataByKey("vouchers",self.vouchersNum_)
    self:refreshFuncbtn()
end

function LotteryLayer:refreshBuyView(kindId,pos)
    self.touchLayer_:setVisible(true)
    self.getVouchers_:setPosition(pos.x + 20,pos.y + 60)
    self.getVouchers_:setScale(0.1)
    self.getVouchers_:runAction(cc.ScaleTo:create(0.2,1,1))
    local iconPath = {"res/lottery/levelup_lottoBronze.png", "res/lottery/levelup_lottoSilver.png", "res/lottery/levelup_lottoGold.png"}
    local num = {{5,25,75},{5,25,75},{5,25,75}}
    local money = {{30,128,258},{30,128,258},{30,128,258}}

    for i = 1, 3 do
        self.getVouchers_:getChildByName("buy" .. i):getChildByName("icon"):loadTexture(iconPath[kindId])
        self.getVouchers_:getChildByName("buy" .. i):getChildByName("icon"):getChildByName("text"):setString("x" .. num[kindId][i])
        self.getVouchers_:getChildByName("buy" .. i):getChildByName("buy" .. i):getChildByName("money"):setString(money[kindId][i])
    end
end

function LotteryLayer:createProgressTimer(schedule)      
    local bloodEmptyBg = cc.Sprite:create("res/club/club_progressbar01.png")
    bloodEmptyBg:setPosition(500,40)
    schedule:addChild(bloodEmptyBg)

    local bloodBody = cc.Sprite:create("res/club/club_progressbar02.png")  
    local bloodProgress = cc.ProgressTimer:create(bloodBody)  
    bloodProgress:setType(cc.PROGRESS_TIMER_TYPE_BAR) --设置为条形 type:cc.PROGRESS_TIMER_TYPE_RADIAL  
    bloodProgress:setMidpoint(cc.p(0,0)) --设置起点为条形坐下方  
    bloodProgress:setBarChangeRate(cc.p(1,0))  --设置为竖直方向  
    bloodProgress:setPercentage(0) -- 设置初始进度为30  
    bloodProgress:setPosition(500,40)  
    schedule:addChild(bloodProgress)
    return bloodProgress
end


function LotteryLayer:adaptScreen(root)
    local winSize = cc.Director:getInstance():getWinSize()
    self.touchLayer_:setContentSize(winSize)
    self.addposY_ = math.abs(winSize.height - 100 - root:getContentSize().height) / 2
    root:setPositionY(self.addposY_)
end

function LotteryLayer:onExit()
    bole.socket:unregisterCmd("enter_lottery")
    bole.socket:unregisterCmd("use_lottery")
    bole:removeListener("changeVouchers", self)
end

return LotteryLayer
--endregion
