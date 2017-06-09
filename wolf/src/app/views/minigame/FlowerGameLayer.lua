-- region *.lua
-- Date
-- 此文件由[BabeLua]插件自动生成
local FlowerGameLayer = class("FlowerGameLayer", cc.load("mvc").ViewBase)
local FlowerCell = class("FlowerCell", cc.load("mvc").MiniCell)
local ACTION_IDLE = "idle"
local ACTION_CLICK = "click"
local ACTION_TRIGGET = "trigget"
local ACTION_OVER = "over"
function FlowerCell:onCreate()
    self.isEnable = true
    self:changeNode("csb/FlowerCell.csb")
    self:setTouchSize(120, 120)
    self.txt_coins = self.animaNode:getChildByName("txt_coins")
    self.txt_coins_over = self.animaNode:getChildByName("txt_coins_over")
    self.txt_coins:setVisible(false)
    self.txt_coins_over:setVisible(false)

    self.cell = self.animaNode:getChildByName("cell")
    self.img_1 = self.cell:getChildByName("img_1")
    self.img_2 = self.cell:getChildByName("img_2")
    if self:getTag() < 24 then
        local path = string.format("game_flower/love_miniFlower%02d", self:getTag())
        self.img_1:loadTexture(path)
        local path = string.format("game_flower/love_miniFlower%02d_gray", self:getTag())
        self.img_2:loadTexture(path)
    else
        local path = string.format("game_flower/love_miniFlower%02d", 1)
        self.img_1:loadTexture(path)
        local path = string.format("game_flower/love_miniFlower%02d_gray", 1)
        self.img_2:loadTexture(path)
    end
    self.img_1:setVisible(true)
    self.img_2:setVisible(false)
end

function FlowerCell:timeCallback()
    self:showOver()
end
function FlowerCell:idle()
    self.status = ACTION_IDLE
    -- self.action:play(self.status, true)
end

function FlowerCell:click(data)
    if not self.isEnable then return end
    self.isEnable = false
    self.status = ACTION_CLICK
    self.data = data
    -- self:setTimeCallback(40.0 / 60.0)
    -- self.action:play(self.status, false)
    self:timeCallback()
end
function FlowerCell:overClick(data)
    if not self.isEnable then return end
    self.isEnable = false
    self.over = true
    self.status = ACTION_OVER
    self.data = data
    -- self:setTimeCallback(25.0 / 60.0)
    -- self.action:play(self.status, false)
    self:timeCallback()
end
function FlowerCell:setEnable(enable)
    self.isEnable = enable
    self.img_1:setVisible(enable)
    self.img_2:setVisible(not enable)
    if enable then
        self.status = ACTION_IDLE
    else
        self.status = ACTION_OVER
    end
end
function FlowerCell:showOver()


    if self.over then
        self.txt_coins_over:setVisible(true)
        if self.data == -1 then
            self.txt_coins_over:setString("+" .. 3)
        elseif self.data == -2 then
            self.txt_coins_over:setString("x" .. 2)
        else
            self.txt_coins_over:setString("" .. self.data)
        end
    else
        self.txt_coins:setVisible(true)
        if self.data == -1 then
            self.txt_coins:setString("+" .. 3)
        elseif self.data == -2 then
            self.txt_coins:setString("x" .. 2)
        else
            self.txt_coins:setString("" .. self.data)
        end
    end

    if self.over then
        self.img_1:setVisible(false)
        self.img_2:setVisible(true)
    else
        self.img_1:setVisible(true)
        self.img_2:setVisible(false)
    end

end


function FlowerGameLayer:onCreate()
    local root = self:getCsbNode():getChildByName("root")
    self.txt_coins = root:getChildByName("txt_coins")
    self.txt_num = root:getChildByName("txt_num")
    self.txt_mul = root:getChildByName("txt_mul")

    local center = root:getChildByName("center")
    self:initCell(center)
    self:setTouch(false)

    self.start = root:getChildByName("start")
    self.over = root:getChildByName("over")
    self.over_coins = self.over:getChildByName("txt_coins")
    self.start:setVisible(true)
    self.over:setVisible(false)
    self.btn_start = ccui.Helper:seekWidgetByName(self.start, "btn_start")
    self.btn_start:addTouchEventListener(handler(self, self.touchEvent))
    self.btn_get = ccui.Helper:seekWidgetByName(self.over, "btn_get")
    self.btn_get:addTouchEventListener(handler(self, self.touchEvent))
    self.index = 0
    self.isContinue = false
    self.selects = { }
    self.coins=0
    -- start
    -- row chose other - row chose other
    -- over
end

function FlowerGameLayer:initCell(root)
    self.cells = { }
    for i = 1, 24 do
        local rootCell = root:getChildByName("cell_" .. i)
        local miniCell = FlowerCell:create(bole.MINIGAME_ID_FLOWER, i, handler(self, self.clickCallback))
        rootCell:addChild(miniCell)
        self.cells[i] = miniCell
    end
end

function FlowerGameLayer:initData(data)
    dump(data, "HamsterGameLayer:initData")
    self:setTouch(true)
    if not data then return end
    for k, v in ipairs(data) do
        self.isContinue = true
        self.index = v.position
        self:continue(v)
    end
    self.isContinue = false
end
function FlowerGameLayer:sendStart()
    bole:getMiniGameControl():minigame_start()
    self:toWait(true)
end
function FlowerGameLayer:sendStep(index)
    self.index = index
    bole:getMiniGameControl():miniGame_step(index)
    self:toWait(true)
end
function FlowerGameLayer:sendOver()
    -- bole:postEvent("next_data")
    bole:postEvent("next_miniGame")
    self:removeFromParent()
end

function FlowerGameLayer:toClick(index, data, isAnimal)
    self.selects[#self.selects + 1] = index
    self.cells[index]:click(data.minigame_content)
end
function FlowerGameLayer:continue(data)
    if not data then return end
    dump(data, "continue---")
    self.start:setVisible(false)
    self:updateCoins(data.minigame_amount)
    self:updateStep(data.hp)
    self:updateMul(data.featrue_multiplier)
    if data.status == "START" then
    elseif data.status == "OPEN" then
        self:toClick(self.index, data, not self.isContinue)
    elseif data.status == "CLOSED" then
        self.over_coins:setString("" .. data.minigame_amount)
        self:toClick(self.index, data, not self.isContinue)
        self:showOther(data.minigame_other_content)
        performWithDelay(self, function()
            self.over:setVisible(true)
        end , 3)
    end
end
function FlowerGameLayer:updateCoins(coins)
    if self.txt_coins and coins then
        self.coins=coins
        self.txt_coins:setString("" .. coins)
    end
end
function FlowerGameLayer:updateStep(num)
    if self.txt_num and num then
        self.txt_num:setString("" .. num)
    end
end
function FlowerGameLayer:updateMul(num)
    if self.txt_mul and num then
        self.txt_mul:setString("" .. num)
    end
end

function FlowerGameLayer:updateUI(data)
    data = data.result
    dump(data, "HamsterGameLayer:updateUI")
    self:toWait(false)
    self:continue(data)
end

function FlowerGameLayer:clickCallback(index)
    print("--------clickCallback" .. index)
    self:sendStep(index)
end

function FlowerGameLayer:showOther(data)
    local pos = 1
    dump(data,"showOther--1")
    dump(self.cells,"showOther--2")
    dump(self.selects,"showOther--3")
    for i, v in ipairs(self.cells) do
        local isSelect = false
        for _, index in ipairs(self.selects) do
            if (i == index) then
                isSelect = true
            end
        end
        if not isSelect then
            if pos <= #data then
                v:overClick(data[pos])
                pos = pos + 1
            end
        end
    end
end

function FlowerGameLayer:touchEvent(sender, eventType)
    if not sender then return end
    local name = sender:getName()
    if eventType == ccui.TouchEventType.began then
        print("Touch Down")
    elseif eventType == ccui.TouchEventType.moved then
        print("Touch Move")
    elseif eventType == ccui.TouchEventType.ended then
        print("Touch Up")
        if name == "btn_start" then
            self:sendStart()
        elseif (name == "btn_get") then
            bole:getAppManage():addCoins(self.coins)
            self:sendOver()
        end
    elseif eventType == ccui.TouchEventType.canceled then
        print("Touch Cancelled")
    end
end

return FlowerGameLayer
-- endregion
