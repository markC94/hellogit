-- region *.lua
-- Date
-- 此文件由[BabeLua]插件自动生成
local MermaidLayer = class("MermaidLayer", cc.load("mvc").ViewBase)
local MermaidCell = class("MermaidCell", cc.load("mvc").MiniCell)
local ACTION_IDLE = "idle"
local ACTION_CLICK = "click"
local ACTION_TRIGGET = "trigget"
local ACTION_OVER = "over"
function MermaidCell:onCreate()
    self.isEnable = true
    self:changeNode("csb/MermaidCell.csb")
    self:setTouchSize(120, 120)
    self.txt_coins = self.animaNode:getChildByName("txt_coins")
    self.txt_coins_over = self.animaNode:getChildByName("txt_coins_over")
    self.txt_coins:setVisible(false)
    self.txt_coins_over:setVisible(false)
    self.cell = self.animaNode:getChildByName("cell")
    self.img_1 = self.cell:getChildByName("img_1")
    self.img_2 = self.cell:getChildByName("img_2")
    self.img_1:setVisible(true)
    self.img_2:setVisible(false)
end

function MermaidCell:timeCallback()
    self:showOver()
end
function MermaidCell:idle()
    self.status = ACTION_IDLE
    -- self.action:play(self.status, true)
end

function MermaidCell:click(data)
    if not self.isEnable then return end
    self.isEnable = false
    self.status = ACTION_CLICK
    self.data = data
    -- self:setTimeCallback(40.0 / 60.0)
    -- self.action:play(self.status, false)
    self:timeCallback()
end
function MermaidCell:overClick(data)
    if not self.isEnable then return end
    self.isEnable = false
    self.over = true
    self.status = ACTION_OVER
    self.data = data
    -- self:setTimeCallback(25.0 / 60.0)
    -- self.action:play(self.status, false)
    self:timeCallback()
end
function MermaidCell:setEnable(enable)
    self.isEnable = enable
    self.img_1:setVisible(enable)
    self.img_2:setVisible(not enable)
    if enable then
        self.status = ACTION_IDLE
    else
        self.status = ACTION_OVER
    end
end
function MermaidCell:showOver()

    if self.over then
        self.txt_coins_over:setVisible(true)
        if self.data == -1 then
            self.txt_coins_over:setString("")
        elseif self.data == -2 then
            self.txt_coins_over:setString("")
        else
            self.txt_coins_over:setString("" .. self.data)
        end
    else
        self.txt_coins:setVisible(true)
        if self.data == -1 then
            self.txt_coins:setString("")
        elseif self.data == -2 then
            self.txt_coins:setString("")
        else
            self.txt_coins:setString("" .. self.data)
        end
    end

    if self.over then
        self.img_1:setVisible(true)
        self.img_2:setVisible(false)
    else
        self.img_1:setVisible(false)
        self.img_2:setVisible(true)
    end

end


function MermaidLayer:onCreate()

    local root = self:getCsbNode():getChildByName("root")
    --    self.txt_coins = root:getChildByName("txt_coins")
    --    self.txt_num = root:getChildByName("txt_num")
    --    self.txt_mul = root:getChildByName("txt_mul")
    self.fristIndex = 0
    local center = root:getChildByName("center")
    self.game_1 = center:getChildByName("game_1")
    self.cell_1 = self.game_1:getChildByName("cell_1")
    self.cell_2 = self.game_1:getChildByName("cell_2")
    self.cell_3 = self.game_1:getChildByName("cell_3")
    self.cell_1:addTouchEventListener(handler(self, self.touchEvent))
    self.cell_2:addTouchEventListener(handler(self, self.touchEvent))
    self.cell_3:addTouchEventListener(handler(self, self.touchEvent))
    self.game_2 = center:getChildByName("game_2")
    self.img_move=self.game_2:getChildByName("img_move")
    self.hp_1=self.game_2:getChildByName("cell_1")
    self.hp_2=self.game_2:getChildByName("cell_2")
    self.hp_3=self.game_2:getChildByName("cell_3")
    self.hp_4=self.game_2:getChildByName("cell_4")
    self.hp =0
    self.game_1:setVisible(true)
    self.game_2:setVisible(false)
    self:initCell(self.game_2)
    self:setTouch(false)
    self.scores={100,200,300,400,600,800,1500,3000,7500}
    self.over = root:getChildByName("over")
    self.over_coins = self.over:getChildByName("txt_coins")
    self.over:setVisible(false)
    self.btn_get = ccui.Helper:seekWidgetByName(self.over, "btn_get")
    self.btn_get:addTouchEventListener(handler(self, self.touchEvent))
    self.index = 0
    self.isContinue = false
    self.selects = { }
    self.coins = 0
end
function MermaidLayer:updateCoins(coins)
    for i,v in ipairs(self.scores) do
        if coins<v then
            local move_pos=cc.p(1055,187+(i-1)*40)
            self.img_move:setPosition(move_pos)
            return
        end
    end
end
function MermaidLayer:updateHP(hp)
    self.hp=hp
    self:setHPForIndex(1,hp)
    self:setHPForIndex(2,hp)
    self:setHPForIndex(3,hp)
    self:setHPForIndex(4,hp)
end

function MermaidLayer:setHPForIndex(index,hp)
    local root=nil
    if index==1 then
        root=self.hp_1
    elseif index==2 then
        root=self.hp_2
    elseif index==3 then
        root=self.hp_3
    elseif index==4 then
        root=self.hp_4
    end
    local img_1 = root:getChildByName("img_1")
    local img_2 = root:getChildByName("img_2")
    if hp>=index then
        img_1:setVisible(true)
        img_2:setVisible(false)
    else
        img_1:setVisible(false)
        img_2:setVisible(true)
    end
end 

function MermaidLayer:clickGame1(index, data)
    if index == 1 then
        self:selectGame1(1, true, data.hp)
        performWithDelay(self, function()
            self:selectGame1(2, false, data.other_chose[1][1])
            self:selectGame1(3, false, data.other_chose[1][2])
        end , 1)
        performWithDelay(self, function()
            self.game_1:setVisible(false)
            self.game_2:setVisible(true)
        end , 2)
    elseif index == 2 then
        self:selectGame1(2, true, data.hp)
        performWithDelay(self, function()
            self:selectGame1(1, false, data.other_chose[1][1])
            self:selectGame1(3, false, data.other_chose[1][2])
        end , 1)
        performWithDelay(self, function()
            self.game_1:setVisible(false)
            self.game_2:setVisible(true)
        end , 2)
    elseif index == 3 then
        self:selectGame1(3, true, data.hp)
        performWithDelay(self, function()
            self:selectGame1(1, false, data.other_chose[1][1])
            self:selectGame1(2, false, data.other_chose[1][2])
        end , 1)
        performWithDelay(self, function()
            self.game_1:setVisible(false)
            self.game_2:setVisible(true)
        end , 2)
    end
end
function MermaidLayer:selectGame1(index, isClick, content)
    local cell = nil
    if index == 1 then
        cell = self.cell_1
    elseif index == 2 then
        cell = self.cell_2
    else
        cell = self.cell_3
    end
    local img_1 = cell:getChildByName("img_1")
    local img_2 = cell:getChildByName("img_2")
    local txt_all = cell:getChildByName("txt_all")
    img_1:setVisible(isClick)
    img_2:setVisible(not isClick)
    txt_all:setVisible(true)
    if not isClick then
        txt_all:setColor(cc.c3b(191, 191, 191))
    end
    txt_all:setString(content)
end

function MermaidLayer:initCell(root)
    self.cells = { }
    for i = 1, 15 do
        local col =(i - 1) % 5
        local raw = math.floor((i - 1) / 5)
        local miniCell = MermaidCell:create(bole.MINIGAME_ID_MERMAID, i, handler(self, self.clickCallback))
        root:addChild(miniCell)
        miniCell:setPosition(cc.p(398 +(col) * 120, 455 -(raw) * 100))
        self.cells[i] = miniCell
    end
end

function MermaidLayer:initData(data)
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
function MermaidLayer:sendStart()
    self.cell_1:setTouchEnabled(false)
    self.cell_2:setTouchEnabled(false)
    self.cell_3:setTouchEnabled(false)
    bole:getMiniGameControl():minigame_start()
    self:toWait(true)
end
function MermaidLayer:sendStep(index)
    self.index = index
    bole:getMiniGameControl():miniGame_step(index)
    self:toWait(true)
end
function MermaidLayer:sendOver()
    -- bole:postEvent("next_data")
    bole:postEvent("next_miniGame")
    self:removeFromParent()
end

function MermaidLayer:toClick(index, data, isAnimal)
    self.selects[#self.selects + 1] = index
    self.cells[index]:click(data.minigame_win)
end 
function MermaidLayer:continue(data)
    if not data then return end
    dump(data, "continue---") 
    self:updateHP(data.hp)
    self:updateCoins(data.minigame_amount)
    if data.status == "START" then
        if self.isContinue then
            self.game_1:setVisible(false)
            self.game_2:setVisible(true)
        else
            self:clickGame1(self.fristIndex,data)
        end
    elseif data.status == "OPEN" then
        self.game_1:setVisible(false)
        self.game_2:setVisible(true)
        --        self:updateCoins(data.minigame_amount)
        --        self:updateStep(data.hp)
        --        self:updateMul(data.featrue_multiplier)
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


function MermaidLayer:updateUI(data)
    data = data.result
    dump(data, "HamsterGameLayer:updateUI")
    self:toWait(false)
    self:continue(data)
end

function MermaidLayer:clickCallback(index)
    print("--------clickCallback" .. index)
    self:sendStep(index)
end

function MermaidLayer:showOther(data)
    local pos = 1
    dump(data, "showOther--1")
    dump(self.cells, "showOther--2")
    dump(self.selects, "showOther--3")
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

function MermaidLayer:touchEvent(sender, eventType)
    if not sender then return end
    local name = sender:getName()
    if eventType == ccui.TouchEventType.began then
        print("Touch Down")
    elseif eventType == ccui.TouchEventType.moved then
        print("Touch Move")
    elseif eventType == ccui.TouchEventType.ended then
        print("Touch Up")
        if name == "cell_1" then
            self.fristIndex = 1
            self:sendStart()
        elseif name == "cell_2" then
            self.fristIndex = 2
            self:sendStart()
        elseif name == "cell_3" then
            self.fristIndex = 3
            self:sendStart()
        elseif (name == "btn_get") then
            bole:getAppManage():addCoins(self.coins)
            self:sendOver()
        end
    elseif eventType == ccui.TouchEventType.canceled then
        print("Touch Cancelled")
    end
end

return MermaidLayer
-- endregion
