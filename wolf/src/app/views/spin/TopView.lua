--region *.lua
--Date
--此文件由[BabeLua]插件自动生成

local TopView = class("TopView")
function TopView:ctor(theme, order)
    self.theme = theme
    self.sale_index=self.theme.roomInfo.sale_index
    self.sale_list=bole:getConfigCenter():getConfig("ingame_sale_random")
    local rootNode = cc.CSLoader:createNodeWithVisibleSize("themeInViews/top/topView.csb")
    local rootAct = cc.CSLoader:createTimeline("themeInViews/top/topView.csb")
    self.rootNode = rootNode

    --升级
    self.rootNode:runAction(rootAct)
    local xinzhuti_lizi = rootNode:getChildByName("xinzhuti_lizi")
    xinzhuti_lizi:setVisible(false)
    local uplevel = rootNode:getChildByName("uplevel")
    local uplevelRoot = uplevel:getChildByName("root")
    uplevelRoot:setVisible(false)
    uplevelRoot.rootAct=rootAct
    uplevelRoot.xinzhuti_lizi=xinzhuti_lizi
    bole:getUIManage():addUpLevelRoot(uplevelRoot)
    --

    self.node_tip = rootNode:getChildByName("node_tips")
    self:setViews(rootNode)
    self:setClickListener(rootNode)
    
    rootNode:registerScriptHandler(function(state)
        if state == "enter" then
            self:onEnter()
        elseif state == "exit" then
            self:onExit()
        end
    end)
    theme:addChild(rootNode, order, order)

    local function update(dt)
        self:updateTime(dt)
    end
    rootNode:onUpdate(update)
end

function TopView:updateTime(dt)
    if not bole.slot_sale_time then
        return
    end

    local hour = math.floor(bole.slot_sale_time / 60)
    local s =string.format("%02d",math.floor(bole.slot_sale_time) % 60)
    if self.saleNum then
        if  bole.slot_sale_time <= 0 then
        self.saleNum:setString("0:00")
        else
            self.saleNum:setString(hour .. ":" .. s)
        end
    end
    if bole.slot_sale_time <= 0 then
        self:showAct()
        self.sale_index=self.sale_index+1
        if not self.sale_list[""..self.sale_index] then
            self.sale_index=1
        end
    end
end

function TopView:onEnter()
    bole:addListener("putWinCoinToTop", self.onCoinsChangedSlot, self, nil, true)
    bole:addListener("popThemeTips", self.popThemeTip, self, nil, true)
    bole:addListener("newbieStepForPersonalInfo", self.onNewbiePersonalInfo, self, nil, true)
    bole:addListener("showSaleBtnAct", self.showSaleBtnAct, self, nil, true)
    bole:addListener("changeDiamond_topView",self.changeDiamond, self, nil, true)
    bole:addListener("changeLike_topView",self.changeLike, self, nil, true)
end

function TopView:onExit()
    bole:getEventCenter():removeEventWithTarget("putWinCoinToTop", self)
    bole:getEventCenter():removeEventWithTarget("popThemeTips", self) 
    bole:getEventCenter():removeEventWithTarget("showSaleBtnAct", self) 
    bole:getEventCenter():removeEventWithTarget("newbieStepForPersonalInfo", self)
    bole:getEventCenter():removeEventWithTarget("changeDiamond_topView", self) 
    bole:getEventCenter():removeEventWithTarget("changeLike_topView", self) 
end

function TopView:popThemeTip(event)
    local view =bole:getEntity("app.views.spin.ThemeTips",event.result)
    self.node_tip:addChild(view)
end

function TopView:changeDiamond(data)
    self.diamondNum:setString(data.result)
end

function TopView:changeLike(data)
    self.likeNum:setString(data.result)
end

function TopView:setClickListener()
    local rightPart = self.rootNode:getChildByName("rightInfo")

    self.saleBtn = rightPart:getChildByName("saleBt")
    self.saleTimeNum = self.saleBtn:getChildByName("saleNum")
--    self.filmBtn = rightPart:getChildByName("filmBt")
    self.menuBtn = rightPart:getChildByName("setupBt")
    self:addSaleAct()

    local function onClick(event)
        if event.name == "ended" then
            if event.target == self.menuBtn then
                local view = bole:getUIManage():createNewUI("Options","options","app.views",nil,false)
                view:setDialog(true)
                self.theme:addOptions(view)
            elseif event.target == self.saleBtn then
                self:openSaleView()
            elseif event.target == self.filmBtn then
                --bole:postEvent("saleTestAct")
            end
        end
    end

--    self.filmBtn:onTouch(onClick)
--    self.filmBtn:setPressedActionEnabled(true)

    self.saleBtn:onTouch(onClick)
    self.menuBtn:onTouch(onClick)

    --self.saleBtn:setPressedActionEnabled(true)
    self.menuBtn:setPressedActionEnabled(true)
end

function TopView:addSaleAct()
    local btn_saleAct = sp.SkeletonAnimation:create("shop_act/sale_1.json", "shop_act/sale_1.atlas")
    local posX,posY =  self.saleBtn:getPosition()
    btn_saleAct:setPosition(posX,posY)
    btn_saleAct:setName("btn_sale")
    self.rootNode:getChildByName("rightInfo"):addChild(btn_saleAct)
    btn_saleAct:setAnimation(0, "animation", true)
    local label = cc.Label:createWithTTF("00:00", "font/bole_ttf.ttf", 20)
    label:setColor({ r = 102, g = 32, b = 37})
    self.saleNum = label
    btn_saleAct:addChild(label)
    label:setPosition(0, - 27)
    self.saleAct = btn_saleAct
    self.isBuySaleActShowing = false
    
    self.saleAct:registerSpineEventHandler( function(event)
            if event.animation == "animation2" then
                self.saleAct:setAnimation(0, "animation", true)
                self.isBuySaleActShowing = false
            end
            if event.animation == "animation3" then
                bole.slot_sale_time = 600
                self.saleBtn:setVisible(true)
                self.saleBtnDisappear = false
                self.saleAct:setAnimation(0, "animation", true)
            end
        end , sp.EventType.ANIMATION_COMPLETE)
        
end

function TopView:showAct()
        bole.slot_sale_time = 600
    if self.isBuySaleActShowing == false then
        self.saleNum:setString("0:00")
            bole.slot_sale_time = false
        self.saleBtnDisappear = true
        self.saleBtn:setVisible(false)
        self.saleAct:runAction(cc.Sequence:create(cc.FadeOut:create(0.5), cc.CallFunc:create( function()     
            self.saleAct:setToSetupPose()
            self.saleNum:setScale(0.01)
            self.saleNum:runAction(cc.ScaleTo:create(0.2, 1))
            self.saleAct:setAnimation(0, "animation3", false)
            self.saleAct:setOpacity(255)
            bole.slot_sale_time = 599.9
        end )))
    end
end

function TopView:showSaleBtnAct()
    self.isBuySaleActShowing = true
    self.saleAct:setToSetupPose()
    self.saleAct:setAnimation(0, "animation2", false)
end

function TopView:test()
    if not self.test_index then
        self.test_index=1
    else
        self.test_index=self.test_index+1
        if self.test_index>3 then
            self.test_index=1
        end
    end
    bole:getUIManage():openBigWin(self.test_index-1,math.random(9999,999999999))
end

function TopView:onCoinsChangedSlot(event)
    local coin=event.result.coin
    if coin then
        self:onCoinsChangedProgress(coin,1)
    end
end

function TopView:onCoinsChangedProgress(newCoin, useTime)
    local speed =(newCoin - self.coin) / useTime
    local spendTime = 0
    local function update(dt)
        if spendTime >= useTime then
            self.coinsNum:unscheduleUpdate()
        end
        spendTime = spendTime + dt
        if spendTime >= useTime then
            self.coin=newCoin
        else
            self.coin=self.coin+speed*dt
        end
        self.coinsNum:setString(bole:formatCoins(self.coin,9))
    end
    self.coinsNum:onUpdate(update)
end

function TopView:setViews(rootNode)
    local headPart = rootNode:getChildByName("headInfo")

    local coinsNum = headPart:getChildByName("coinsNum")
    self.coin=bole:getUserData():getDataByKey("coins")
    coinsNum:setString(bole:formatCoins(self.coin,9))
    self.coinsNum = coinsNum

    local headNode = headPart:getChildByName("headNode")
    local head = bole:getNewHeadView(bole:getUserData())
    self.theme.myHead = head
    headNode:addChild(head)
    head:updatePos(head.POS_SPIN_SELF)

    local expNode = headPart:getChildByName("expNode")
    local exp = bole:getUIManage():getNewExpView(true)
    expNode:addChild(exp)
    self.expNode = expNode

    local diamond = headPart:getChildByName("diamondNum")
    diamond:setString(bole:getUserData():getDataByKey("diamond"))
    self.diamondNum = diamond

    local like = headPart:getChildByName("zanNum")
    like:setString(bole:getUserData():getDataByKey("likes"))
    self.likeNum = like

    local rightInfo = rootNode:getChildByName("rightInfo")
    --self.saleNum = saleBt:getChildByName("saleNum")
    --self.saleNum:setString("00:00")


end

function TopView:openSaleView()
    local index=self.sale_list[""..self.sale_index].ingame_sale_id
    bole:getUIManage():openNewUI("SaleLayer",true,"shop_sale","app.views.shop")
    bole:postEvent("SaleLayer",{index=self.sale_index,plays=self.theme.roomInfo.other_players})
end

function TopView:onNewbiePersonalInfo(event)
    bole:postEvent("newbieStepPopup", {id = "afterSpinNum", pos = self.expNode:convertToWorldSpace(cc.p(0, 0))})
end

function TopView:removeFromParent(isCleanup)
    self.rootNode:removeFromParent(isCleanup)
end

return TopView


--endregion
