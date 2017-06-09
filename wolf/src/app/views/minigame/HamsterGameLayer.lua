-- region *.lua
-- Date
-- 此文件由[BabeLua]插件自动生成
local HamsterGameLayer = class("HamsterGameLayer", cc.load("mvc").ViewBase)
local HamsterCell = class("HamsterCell", cc.load("mvc").MiniCell)
local ACTION_IDLE = "idle"
local ACTION_CLICK = "click"
local ACTION_TRIGGET = "trigget"
local ACTION_OVER = "over"
local cells={"pic_radish_1","pic_carrot_1","pic_beet_1","pic_daikon_1","nangua","yanshu"}
function HamsterCell:onCreate()
    self.isEnable = true
    self:changeNode("csb/HamsterCell.csb")
    self:setTouchSize(160, 160)

    self.txt_coins = self.animaNode:getChildByName("txt_coins")
    self.txt_coins_over = self.animaNode:getChildByName("txt_coins_over")
    self.node_icon =self.animaNode:getChildByName("node_icon")
    self.skeletonNode=nil
    self.offy=0
    self.txt_coins:setVisible(false)
    self.txt_coins_over:setVisible(false)
end


function HamsterCell:openSkeletonAnimation(node)

end

function HamsterCell:timeCallback()
    self:showOver()
end
function HamsterCell:setRow(row)
    if self.skeletonNode then
        self.skeletonNode:removeFromParent()
    end
    
    
    if row==5 or row==6 then
        self.skeletonNode = sp.SkeletonAnimation:create("game_farm_act/"..cells[row].. ".json", "game_farm_act/"..cells[row].. ".atlas")
        if not self.over then
            self.skeletonNode:setAnimation(0, "animation", false)
        else
            self.skeletonNode:setColor({ r = 100, g = 100, b = 100})
        end
        
        if row == 6 then
            self.offy=30
            self.skeletonNode:setScale(0.37)
        elseif row == 5 then
            self.offy=15
            self.skeletonNode:setScale(0.35)
        end
    else
        self.skeletonNode=display.newSprite("#game_farm/"..cells[row]..".png")
        self.offy=-10
        if row == 2 then
            self.offy=-15
        elseif row == 4 then
            self.offy=-15
        end
        --self.skeletonNode:runAction(cc.MoveTo:create(0.5,cc.p(0,30)))
    end

    self.skeletonNode:setPosition(0,self.offy)
    self.node_icon:addChild(self.skeletonNode)
end
function HamsterCell:idle()
    self.status = ACTION_IDLE
    -- self.action:play(self.status, true)
end

function HamsterCell:click(data)
    if not self.isEnable then return end
    self.isEnable = false
    self.status = ACTION_CLICK
    self.data = data
    --self:setTimeCallback(40.0 / 60.0)
    if self.skeletonNode then
        if self.data == -1 or self.data == -2 then
            self.skeletonNode:runAction(cc.FadeOut:create(0.2))
            --self.skeletonNode:setAnimation(0, "animation2", false)
        else
            --self.skeletonNode:setAnimation(0, "animation", false)
            self.skeletonNode:runAction(cc.MoveTo:create(0.2,cc.p(0,25+self.offy)))
        end
    end
    -- self.action:play(self.status, false)
    self:timeCallback()
end
function HamsterCell:overClick(data)
    if not self.isEnable then return end
    self.isEnable = false
    self.over = true
    self.status = ACTION_OVER
    self.data = data
    -- self:setTimeCallback(25.0 / 60.0)
    -- self.action:play(self.status, false)
    self:timeCallback()
end
function HamsterCell:setEnable(enable)
    self.isEnable = enable
    if not enable then
        if self.skeletonNode then
            self.skeletonNode:runAction(cc.TintTo:create(0.5,100,100,100))
        end
    else
        if self.skeletonNode then
            self.skeletonNode:runAction(cc.TintTo:create(0.5,255,255,255))
        end
    end
    if enable then
        self.status = ACTION_IDLE
    else
        self.status = ACTION_OVER
    end
end
function HamsterCell:showOver()
    self.touch:setTouchEnabled(false)
    if self.data == -1 then
        self:setRow(5)
    elseif self.data == -2 then
        self:setRow(6)
    else
        if self.over then
            self.txt_coins_over:setVisible(true)
            self.txt_coins_over:setString("" .. self.data)
        else
            self.txt_coins:setVisible(true)
            self.txt_coins:setString("" .. self.data)
        end
    end

    if self.over then
        if self.skeletonNode then
--            self.skeletonNode:setColor({ r = 100, g = 100, b = 100})
            self.skeletonNode:runAction(cc.TintTo:create(0.5,100,100,100))
        end
    else
        if self.skeletonNode then
--            self.skeletonNode:setColor({ r = 255, g = 255, b = 255})
            self.skeletonNode:runAction(cc.TintTo:create(0.5,255,255,255))
        end
    end

end


function HamsterGameLayer:onCreate()
    local root = self:getCsbNode():getChildByName("root")
    local img_bg=self:getCsbNode():getChildByName("img_bg")
    self.txt_coins=img_bg:getChildByName("txt_coins")
    local row_1 = root:getChildByName("row_1")
    local row_2 = root:getChildByName("row_2")
    local row_3 = root:getChildByName("row_3")
    local row_4 = root:getChildByName("row_4")
    self.cells = { }
    self:initCell(row_1, 1)
    self:initCell(row_2, 2)
    self:initCell(row_3, 3)
    self:initCell(row_4, 4)
    self:setTouch(false)

    self.start = root:getChildByName("start")
    self.over = root:getChildByName("over")
    self.over_coins=self.over:getChildByName("txt_coins")
    self.start:setVisible(true)
    self.over:setVisible(false)
    self.btn_start = ccui.Helper:seekWidgetByName(self.start, "btn_start")
    self.btn_start:addTouchEventListener(handler(self, self.touchEvent))
    self.btn_get = ccui.Helper:seekWidgetByName(self.over, "btn_get")
    self.btn_get:addTouchEventListener(handler(self, self.touchEvent))
    self.step = 1
    self.index = 0
    self.isContinue = false
    self.coins=0


    self.sp_tips=root:getChildByName("sp_tips")
    self.sp_txt=self.sp_tips:getChildByName("sp_txt")
    -- start
    -- row chose other - row chose other
    -- over
end

function HamsterGameLayer:initData(data)
    --    self.chose = data.chose
    --    self.other = data.other_chose
    self:setTouch(true)
    self:setRowEnable(1, true)
    if not data then return end
    for k, v in ipairs(data) do
        self.isContinue = true
        self.index = v.position
        self:continue(v)
    end
    self.isContinue = false
end
function HamsterGameLayer:sendStart()
    bole:getMiniGameControl():minigame_start()
    self:toWait(true)
end
function HamsterGameLayer:sendStep(index)
    self.index = index
    bole:getMiniGameControl():miniGame_step(index)
    self:toWait(true)
end
function HamsterGameLayer:sendOver()
    -- bole:postEvent("next_data")
    bole:postEvent("next_miniGame")
    self:removeFromParent()
end
function HamsterGameLayer:setRowEnable(row, enable, index)
    for i = 1, 7 do
        if index and i == index then

        else
            self.cells[row][i]:setEnable(enable)
        end
    end
    self.sp_tips:setVisible(true)
    if row ==1 then
        self.sp_tips:setPosition(667,150)
        self.sp_txt:setSpriteFrame("game_farm/tip_title_1.png")
    elseif row==2 then
        self.sp_tips:setPosition(667,280)
        self.sp_txt:setSpriteFrame("game_farm/tip_title_2.png")
    elseif row==3 then
        self.sp_tips:setPosition(667,425)
        self.sp_txt:setSpriteFrame("game_farm/tip_title_3.png")
    elseif row==4 then
        self.sp_tips:setPosition(667,533)
        self.sp_txt:setSpriteFrame("game_farm/tip_title_4.png")
    end

end
function HamsterGameLayer:toClick(index, step, data, isAnimal)
    self.sp_tips:setVisible(false)
    if isAnimal then
        self:setTouch(false)

        for i = 1, 7 do
            if i == index then
                self.cells[step][index]:click(data.minigame_content)
            else
                self.cells[step][i]:setEnable(false)
            end
        end

        performWithDelay(self, function()
            self:setTouch(true)
            if step < 4 then
                self:setRowEnable(step + 1, true)
            end
            local pos = 1
            for i = 1, 7 do
                if i ~= index then
                    self.cells[step][i]:setEnable(true)
                    self.cells[step][i]:overClick(data.minigame_other_content[pos])
                    pos = pos + 1
                end
            end
        end ,0.5)
    else
        self.cells[step][index]:click(data.minigame_content)
        if step < 4 then
            self:setRowEnable(step + 1, true)
        end
        local pos = 1
        for i = 1, 7 do
            if i ~= index then
                self.cells[step][i]:overClick(data.minigame_other_content[pos])
                pos = pos + 1
            end
        end
    end
end
function HamsterGameLayer:continue(data)
    if not data then return end
    self.start:setVisible(false)
    if data.status == "START" then
    elseif data.status == "OPEN" then
        self:updateCoins(data.minigame_amount)
        self:toClick(self.index,self.step, data, not self.isContinue)
        self.step = self.step + 1
    elseif data.status == "CLOSED" then
        self:updateCoins(data.minigame_amount)
        self:toClick(self.index, self.step, data, true)
        self.over_coins:setString(""..data.minigame_amount)
        performWithDelay(self, function()
            self.over:setVisible(true)
        end , 2)
    end
end
function HamsterGameLayer:updateCoins(coins)
    if self.txt_coins and coins then
        self.coins=coins
        self.txt_coins:setString(""..coins)
    end
end

function HamsterGameLayer:updateUI(data)
    data = data.result
    dump(data, "HamsterGameLayer:updateUI")
    self:toWait(false)
    self:continue(data)
end
function HamsterGameLayer:initCell(root, row)
    for i = 1, 7 do
        local rootCell = root:getChildByName("cell_" .. i)
        local miniCell = HamsterCell:create(bole.MINIGAME_ID_HAMSTER, i, handler(self, self.clickCallback))
        miniCell:setRow(row)
        miniCell:setEnable(false)
        miniCell:setPosition(0,0)
        rootCell:addChild(miniCell)
        if not self.cells[row] then
            self.cells[row] = { }
        end
        self.cells[row][i] = miniCell
    end
end
function HamsterGameLayer:clickCallback(index)
    print("--------clickCallback" .. index)
    self:sendStep(index)
end

function HamsterGameLayer:showOther(row, index, data)
    local pos = 1
    for i, v in ipairs(self.cells[row]) do
        if (i ~= index) then
            if pos <= #data then
                v:overClick(data[pos])
                pos = pos + 1
            end
        end
    end
end

function HamsterGameLayer:touchEvent(sender, eventType)
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

return HamsterGameLayer
-- endregion
