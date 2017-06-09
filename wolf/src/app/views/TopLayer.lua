-- region *.lua
-- Date
-- 此文件由[BabeLua]插件自动生成
local TopLayer = class("TopLayer", cc.load("mvc").ViewBase)
function TopLayer:onCreate()

    print("TopLayer-onCreate");
    local root = self:getCsbNode():getChildByName("root");
    local top = root:getChildByName("top");

    local btn_back = ccui.Helper:seekWidgetByName(root, "btn_back")
    btn_back:addTouchEventListener(handler(self, self.touchEvent))
    local btn_menu = ccui.Helper:seekWidgetByName(root, "btn_menu")
    btn_menu:addTouchEventListener(handler(self, self.touchEvent))
    local btn_buy = ccui.Helper:seekWidgetByName(root, "btn_buy")
    btn_buy:addTouchEventListener(handler(self, self.touchEvent))
    local btn_pig = ccui.Helper:seekWidgetByName(root, "btn_pig")
    btn_pig:addTouchEventListener(handler(self, self.touchEvent))


    self.txt_userid = ccui.Helper:seekWidgetByName(root, "txt_userid")
    self.txt_level = ccui.Helper:seekWidgetByName(root, "txt_level")
    self.txt_money = ccui.Helper:seekWidgetByName(root, "txt_money")
    self.txt_money_win = ccui.Helper:seekWidgetByName(top, "txt_win")

    self.bar_level= ccui.Helper:seekWidgetByName(root,"bar_level")

    self.txt_userid:setString("ID:" .. bole:getUserDataByKey("user_id"))
    self.txt_level:setString(bole:getUserDataByKey("level"))

    self:addExp(self.bar_level)
    local conis=bole:getUserDataByKey("coins")
    self.txt_money:setString(bole:formatCoins(conis,12))
    --    schedule(coins, self.updateTime, 0.1)
end

function TopLayer:updateTime()

end


function TopLayer:onEnter()
    bole:addListener("coinsChanged", self.addCoinsEvent, self, nil, true)
    print("-------------TopLayer:enter")
end
function TopLayer:onExit()
    bole:getEventCenter():removeEventWithTarget("coinsChanged", self)
    print("-------------TopLayer:exit")
end
function TopLayer:addExp(node_bar)
    node_bar:setPercent(bole:getExpPercent())
end
function TopLayer:addCoinsEvent(event)
    if event.result.changed >= 0 then
        self:addCoins(self.txt_money_win, event.result.changed, 0)
    else
        self:addCoins(self.txt_money_win, 0, 0)
    end
    self:addCoins(self.txt_money, event.result.result, event.result.result - event.result.changed)
end
function TopLayer:addCoins(node_txt, new_coins, old_coins)
    if not node_txt then return end
    local cur_coins = old_coins
    if old_coins >= new_coins then
        node_txt:setString("" .. math.floor(new_coins))
        return
    end
    local add_coins =(new_coins - old_coins) * 0.1

    local function callback()
        cur_coins = cur_coins + add_coins
        node_txt:setString("" .. math.floor(cur_coins))
    end
    local function endCallback()
        node_txt:setString("" .. math.floor(new_coins))
    end
    local sequence = cc.Sequence:create(cc.DelayTime:create(0.05), cc.CallFunc:create(callback))
    local act1 = cc.Repeat:create(sequence, 10)
    local act2 = cc.Sequence:create(act1, cc.DelayTime:create(0.1), cc.CallFunc:create(endCallback))
    self:runAction(act2)
end


function TopLayer:updateUI(data)

    --    if bole.user_data then
    self.txt_userid:setString("ID:" .. bole:getUserDataByKey("user_id"))
    self.txt_level:setString(bole:getUserDataByKey("level"))
    self.txt_money:setString(math.floor(bole:getUserDataByKey("coins")))
    --    end

    if not data then return end
    if not data.result then return end

    self.txt_userid:setString("ID:" .. bole:getUserDataByKey("user_id"))
    self.txt_level:setString(bole:getUserDataByKey("level"))
    --    end
end
function TopLayer:touchEvent(sender, eventType)
    local name = sender:getName()
    local tag = sender:getTag()
    print("touchEvent:" .. name)
    if eventType == ccui.TouchEventType.began then
        print("Touch Down")
        sender:setScale(1.05)
    elseif eventType == ccui.TouchEventType.moved then
        print("Touch Move")
    elseif eventType == ccui.TouchEventType.ended then
        sender:setScale(1.0)
        print("Touch Up")
        if name == "btn_back" then
            bole:getUIManage():openUI(bole.UI_NAME.LobbyScene)
        end
    elseif eventType == ccui.TouchEventType.canceled then
        sender:setScale(1.0)
        print("Touch Cancelled")
    end
end
return TopLayer
-- endregion
