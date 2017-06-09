--region *.lua
--Date
--此文件由[BabeLua]插件自动生成

local SaleLayer = class("SaleLayer", cc.load("mvc").ViewBase)

function SaleLayer:onCreate()
    print("SaleLayer:onCreate")
    local root = self:getCsbNode():getChildByName("root")
    local head=bole:getNewHeadView({user_id=bole:getUserDataByKey("user_id")})
    local Node_me=root:getChildByName("Node_me")
    head:updatePos(head.POS_ONLY_HEAD)
    Node_me:addChild(head)

    local bg= root:getChildByName("bg")
    local bg2= root:getChildByName("bg2")
    local bg3= root:getChildByName("bg3")
    local bg4= root:getChildByName("bg4")
    
    self.player1= root:getChildByName("player1")
    self.player2= root:getChildByName("player2")
    self.player3= root:getChildByName("player3")
    self.player4= root:getChildByName("player4")
    
    self.tips= root:getChildByName("txt_info")

    local btn_close= root:getChildByName("btn_close")
    btn_close:addTouchEventListener(handler(self,self.touchEvent))
    local btn_get= root:getChildByName("btn_get")
    btn_get:addTouchEventListener(handler(self,self.touchEvent))
    self.coins= bg2:getChildByName("txt_num")
    local time= bg3:getChildByName("time")
    self:initTime(time)
    self.price= bg4:getChildByName("txt")
    local function update(dt)
        self:updateTime(dt)
    end
    self:onUpdate(update)
    self:updateInfo({
    time=900,
    tips="Get sale and every player in this room willrecive free 31,000,000 bonus Coins.",
    coins=bole:formatCoins(30775000,12),price="Now only 198.00",
    plays=true
    })
end

function SaleLayer:initTime(root)
    self.txt_hour1 = root:getChildByName("txt_hour1")
    self.txt_hour2 = root:getChildByName("txt_hour2")
    self.txt_minute1 = root:getChildByName("txt_minute1")
    self.txt_minute2 = root:getChildByName("txt_minute2")
    self.txt_second1 = root:getChildByName("txt_second1")
    self.txt_second2 = root:getChildByName("txt_second2")
end

function SaleLayer:updateTime(dt)
    if not self.delayTime then
        return
    end
    self.delayTime = self.delayTime - dt
    if self.delayTime > 0 then
        local s = math.floor(self.delayTime) % 60
        local m = math.floor(self.delayTime / 60) % 60
        local h = math.floor(self.delayTime / 3600) % 24
        self.txt_second1:setString(math.floor(s / 10))
        self.txt_second2:setString(math.floor(s % 10))
        self.txt_minute1:setString(math.floor(m / 10))
        self.txt_minute2:setString(math.floor(m % 10))
        self.txt_hour1:setString(math.floor(h / 10))
        self.txt_hour2:setString(math.floor(h % 10))
    else
        self.txt_second1:setString(0)
        self.txt_second2:setString(0)
        self.txt_minute1:setString(0)
        self.txt_minute2:setString(0)
        self.txt_hour1:setString(0)
        self.txt_hour2:setString(0)
    end
end

function SaleLayer:updateUI(event)
    local data=events.result
    self.updateInfo(data)
end
function SaleLayer:updateInfo(data)
    if data.tips then
        self.tips:setString(data.tips)
    end
    if data.coins then
        self.coins:setString(data.coins)
    end
    if data.coins then
        self.coins:setString(data.coins)
    end
    if data.price then
        self.price:setString(data.price)
    end
    if data.time then
        self.delayTime=data.time
    end
    if data.plays then
        self:initPlayer(data.plays)
    end
end
function SaleLayer:initPlayer(data)
    local pl1=bole:getNewHeadView({user_id=bole:getUserDataByKey("user_id"),name="test1"})
    pl1:updatePos(pl1.POS_SCALE_FRIEND)
    self.player1:addChild(pl1)
    local pl2=bole:getNewHeadView({user_id=bole:getUserDataByKey("user_id"),name="test2"})
    pl2:updatePos(pl2.POS_SCALE_FRIEND)
    self.player2:addChild(pl2)
    local pl3=bole:getNewHeadView({user_id=bole:getUserDataByKey("user_id"),name="test3"})
    pl3:updatePos(pl3.POS_SCALE_FRIEND)
    self.player3:addChild(pl3)
    local pl4=bole:getNewHeadView({user_id=bole:getUserDataByKey("user_id"),name="test4"})
    pl4:updatePos(pl4.POS_SCALE_FRIEND)
    self.player4:addChild(pl4)
end

function SaleLayer:touchEvent(sender, eventType)
    local name = sender:getName()
    local tag = sender:getTag()
    print("touchEvent:" .. name)
    if eventType == ccui.TouchEventType.began then
        sender:setScale(1.05)
        print("Touch Down")
    elseif eventType == ccui.TouchEventType.moved then
        print("Touch Move")
    elseif eventType == ccui.TouchEventType.ended then
        sender:setScale(1)
        print("Touch Up")
        if name == "btn_close" then
           self:closeUI()
        end
    elseif eventType == ccui.TouchEventType.canceled then
        print("Touch Cancelled")
    end
end

function SaleLayer:onEnter()
    
end

function SaleLayer:onExit()
  
end


return SaleLayer
--endregion
