-- region *.lua
-- Date
-- 此文件由[BabeLua]插件自动生成
local FairyGameLayer = class("FairyGameLayer", cc.load("mvc").ViewBase)
local FairyCell = class("FairyCell", cc.load("mvc").MiniCell)
local ACTION_IDLE = "idle"
local ACTION_CLICK = "click"
local ACTION_TRIGGET = "trigget"
local ACTION_OVER = "over"
function FairyCell:onCreate()
    self.isEnable = true
    self:changeNode("csb/red_egg.csb")
    self:setTouchSize(200, 200)
    self.level = 1
end

function FairyCell:timeCallback()
    if self.status == ACTION_CLICK then
        self:showOver()
    elseif self.status == ACTION_TRIGGET then
        local fileName = nil
        if (self.level == 2) then
            fileName = "csb/green_egg.csb"
        else
            fileName = "csb/blue_egg.csb"
        end
        self:changeNode(fileName)
        self:idle()
    end
end

function FairyCell:idle()
    self.status = ACTION_IDLE
    self.action:play(ACTION_IDLE, true)
end
function FairyCell:trigget(data)
    if not self.isEnable then return end
    self.level = data
    self.status = ACTION_TRIGGET
    self:setTimeCallback(0.7)
    self.action:play(ACTION_TRIGGET, false)
end
function FairyCell:click(values, content)
    if not self.isEnable then return end
    self.isEnable = false
    self.status = ACTION_CLICK
    self.values = values
    self.content = content
    self:setTimeCallback(0.7)
    self:changeNode("csb/click.csb")
    self.action:play(ACTION_CLICK, false)
end
function FairyCell:overClick(data)
    if not self.isEnable then return end
    self.over = true
    self:click(data)
end

function FairyCell:showOver()
    if self.animaNode then
        self.animaNode:removeFromParent()
        self.animaNode = nil
    end
    self.touch:setTouchEnabled(false)

    if self.content then
        self:magic()
        return
    end

    if self.values and self.values > 0 then
        local txtData = cc.Label:createWithSystemFont("" .. self.values, "Arial", 40)
        self:addChild(txtData)
        if self.over then
            txtData:setColor(cc.c3b(100, 100, 100))
        else
            txtData:setColor(cc.c3b(255, 0, 0))
        end
    else
        self:magic()
    end
end
function FairyCell:magic()
    self:changeNode("csb/mobang.csb")
    self:idle()
end



function FairyGameLayer:onCreate()
    print("FairyGameLayer-onCreate");

    self.delay_time = -1
    schedule(self, self.updateTime, 0.1)
    bole:getUIManage():addTopLayer(self)
    self:setTouch(false)
    local root_fairy = self:getCsbNode():getChildByName("root_fairy")
    root_fairy:setVisible(false)
    self:initFairy(root_fairy)

    self.index = 0
    self.isContinue = false
    self.selects = { }
    self.coins = 0
end
function FairyGameLayer:initFairy(root)
    root:setVisible(true)
    self._node_gril = root:getChildByName("node_gril")
    self._action_girl = cc.CSLoader:createTimeline("csb/girl.csb")
    self._node_gril:runAction(self._action_girl)
    self._action_girl:gotoFrameAndPause(0)
    self._action_girl:play("idle", true)

    self.txt_step = ccui.Helper:seekWidgetByName(root, "txt_step")
    self.txt_win_gold = ccui.Helper:seekWidgetByName(root, "txt_win_gold")

    self:initFairyCell(root)

    self.root_start = ccui.Helper:seekWidgetByName(root, "start")
    self.root_start:setScale(0.1)
    self.root_start:runAction(cc.ScaleTo:create(0.2, 1.0))
    self.btn_start = ccui.Helper:seekWidgetByName(root, "btn_start")
    self.btn_start:addTouchEventListener(handler(self, self.touchEvent))
    self.btn_start:setVisible(true)
    self.root_over = ccui.Helper:seekWidgetByName(root, "over")
    self.btn_get = ccui.Helper:seekWidgetByName(self.root_over, "btn_get")
    self.btn_get:addTouchEventListener(handler(self, self.touchEvent))
    self.txt_over_coins = ccui.Helper:seekWidgetByName(self.root_over, "txt_coins")
    self.root_over:setVisible(false)
end
function FairyGameLayer:initFairyCell(root)
    self.cells = { }

    for i = 1, 9 do
        local raw = math.floor((i - 1) / 3) + 1
        local col = math.floor((i - 1) % 3) + 1
        print("raw:" .. raw .. " col:" .. col)
        local rootCell = ccui.Helper:seekWidgetByName(root, "cell_" .. i)
        rootCell:setAnchorPoint(cc.p(0.5, 0.5))
        rootCell:setPosition(cc.p(60 +(col - 1) * 250, 480 -(raw - 1) * 150))
        local miniCell = FairyCell:create(bole.MINIGAME_ID_FAIRY, i, handler(self, self.clickCallback))
        rootCell:addChild(miniCell)
        self.cells[i] = miniCell
    end
end
function FairyGameLayer:initData(data)
    dump(data, "FairyGameLayer:initData")
    self:setTouch(true)
    if not data then return end
    for _, v in ipairs(data) do
        self.coins = v.minigame_amount
        self.step = v.hp
        self.index = v.position
        self:continueGame(v)
        self.selects[v.position] = 1
    end
end

function FairyGameLayer:start()
    bole:getMiniGameControl():minigame_start(0)
end
function FairyGameLayer:continueGame(data)
    if not data then return end
    dump(data, "FairyGameLayer:continueGame")
    self.root_start:setVisible(false)
    if data.status == "START" then
        self:updateMode(data)
    elseif data.status == "OPEN" then
        self:nextStep(data)
    elseif data.status == "CLOSED" then
        self:setTouch(false)
        self:nextStep(data)
        performWithDelay(self, function()
            self:gameFairyOver(data)
        end , 1.5)
    end

end
function FairyGameLayer:updateUI(data)
    data = data.result
    self:toWait(false)
    self:continueGame(data)
end

function FairyGameLayer:nextStep(data)
    self:clickCell(self.index, data.minigame_win, data.minigame_content)
    if data.minigame_content and data.minigame_content < 0 then
        self:updateLevel(self.index, data.game_level + 1)
        self:toTrigget()
    end
    self:updateMode(data)
end

function FairyGameLayer:updateMode(data)
    self.txt_step:setString("" .. data.hp)
    self.txt_win_gold:setString("" .. data.minigame_amount)
end
function FairyGameLayer:updateTime()
    if self.delay_time == -1 then
        return
    end
    if self.delay_time <= 0 then
        self.delay_time = -1
        self:timeCallback()
        return
    end
    self.delay_time = self.delay_time - 0.1
end
function FairyGameLayer:timeCallback()
    print("timeCallback:")
    self._action_girl:play("idle", false)
end


function FairyGameLayer:clickCallback(index)
    self.index = index
    bole:getMiniGameControl():miniGame_step(index)
    self:toWait(true)
end



function FairyGameLayer:updateLevel(index, level)
    print("--------------"..level)
    for i, v in ipairs(self.cells) do
        --if (i ~= index) then
            if (self.selects[i] ~=1) then
                v:trigget(level)
            end
        --else

        --end
    end
end

function FairyGameLayer:toTrigget()
    self._action_girl:gotoFrameAndPause(0)
    self._action_girl:play("trigget", false)
    self.delay_time = 0.3
end

function FairyGameLayer:clickCell(index, serverData)
    print("clickCell:" .. index)
    self.selects[#self.selects + 1] = index
    self.cells[index]:click(serverData)
end

function FairyGameLayer:gameFairyOver(data)
    self.cells = self.cells or { }
    local over_data = data.minigame_other_content
    local index = 1
    for i, v in ipairs(self.cells) do
        if self.selects[i] ~= 1 then
            if index <= #over_data then
                v:overClick(over_data[index])
                index = index + 1
            else
                v:overClick(100)
            end
        end
    end
    self.txt_over_coins:setString("" .. data.minigame_amount)
    performWithDelay(self, function()
        self.root_over:setVisible(true)
        self.root_over:setScale(0.1)
        self.root_over:runAction(cc.ScaleTo:create(0.2, 1.0))
        self:setTouch(true)
    end , 2)
end

function FairyGameLayer:touchEvent(sender, eventType)
    if not sender then return end
    local name = sender:getName()
    if eventType == ccui.TouchEventType.began then
        print("Touch Down")
    elseif eventType == ccui.TouchEventType.moved then
        print("Touch Move")
    elseif eventType == ccui.TouchEventType.ended then
        print("Touch Up")
        if name == "btn_start" then
            self:toWait(true)
            self:start()
        elseif (name == "btn_get") then
            bole:getAppManage():addCoins(self.coins)
            bole:postEvent("next_miniGame")
            self:removeFromParent()
        end
    elseif eventType == ccui.TouchEventType.canceled then
        print("Touch Cancelled")
    end
end
return FairyGameLayer
-- endregion
