-- region *.lua
-- Date
-- 此文件由[BabeLua]插件自动生成
local GorillaLayer = class("GorillaLayer", cc.load("mvc").ViewBase)
local GorillaCell = class("GorillaCell", cc.load("mvc").MiniCell)
local ACTION_IDLE = "idle"
local ACTION_CLICK = "click"
local ACTION_TRIGGET = "trigget"
local ACTION_OVER = "over"
function GorillaCell:onCreate()
    self.isEnable = true
    self:changeNode("csb/GorillaCell.csb")
    self:setTouchSize(180, 150)
    self.bmf_mul = self.animaNode:getChildByName("bmf_mul")
    self.bmf_mul_over = self.animaNode:getChildByName("bmf_mul_over")
    self.bmf_mul:setVisible(false)
    self.bmf_mul_over:setVisible(false)

    self.img_1 = self.animaNode:getChildByName("img_icon_1")
    self.img_2 = self.animaNode:getChildByName("img_icon_2")

    self.img_1:setVisible(true)
    self.img_2:setVisible(false)

    self.sp_tips = self.animaNode:getChildByName("sp_tips")
    self.sp_tips:setVisible(false)
    bole:getAudioManage():playMusic("gorilla_freespin",true)
end

function GorillaCell:timeCallback()
    self:showOver()
end
function GorillaCell:idle()
    self.status = ACTION_IDLE
    -- self.action:play(self.status, true)
end

function GorillaCell:click(data)
    if not self.isEnable then return end
    self.isEnable = false
    self.status = ACTION_CLICK
    self.data = data
    -- self:setTimeCallback(40.0 / 60.0)
    -- self.action:play(self.status, false)
    self:timeCallback()
    bole:getAudioManage():playEff("gorilla_box1")
end
function GorillaCell:overClick(data)
    if not self.isEnable then return end
    self.isEnable = false
    self.over = true
    self.status = ACTION_OVER
    self.data = data
    -- self:setTimeCallback(25.0 / 60.0)
    -- self.action:play(self.status, false)
    self:timeCallback()
end

function GorillaCell:showOver()

    if self.over then
        self.bmf_mul_over:setVisible(true)
        self.bmf_mul_over:setString("X" .. math.abs(self.data))
    else
        self.bmf_mul:setVisible(true)
        self.bmf_mul:setString("X" .. math.abs(self.data))
        bole:getAudioManage():playEff("gorilla_box2")
        if self.data < 0 then
           self.sp_tips:setVisible(true)
        end
    end

    self.img_1:setVisible(false)
    self.img_2:setVisible(true)
    if not self.over then
        local skeletonNode = sp.SkeletonAnimation:create("common/box.json", "common/box.atlas")
        skeletonNode:setAnimation(0, "open", false)
        self:addChild(skeletonNode)
    end
end


function GorillaLayer:onCreate()
    local root = self:getCsbNode():getChildByName("root")
    local title_bg = root:getChildByName("title_bg")
    self.bmf_mul = title_bg:getChildByName("bmf_mul")
    self.bmf_coins = title_bg:getChildByName("bmf_coins")

    self:initCell(root)
    self:setTouch(false)

    self.over = root:getChildByName("over")
    self.over_mul = self.over:getChildByName("txt_mul")
    self.over_win = self.over:getChildByName("txt_win")
    self.over_total = self.over:getChildByName("txt_total")
    self.over:setVisible(false)
    self.btn_get = ccui.Helper:seekWidgetByName(self.over, "btn_get")
    self.btn_get:addTouchEventListener(handler(self, self.touchEvent))
    self.index = 0
    self.isContinue = false
    self.selects = { }
    self.total = 0
    self.mul = 0
    self.win = 0
end

function GorillaLayer:initCell(root)
    self.cells = { }
        for i = 1, 10 do
            local rootCell = root:getChildByName("node_cell_" .. i)
            local miniCell = GorillaCell:create(bole.MINIGAME_ID_GORILLALAYER_COLLECT, i, handler(self, self.clickCallback))
            rootCell:addChild(miniCell)
            self.cells[i] = miniCell
        end
end

function GorillaLayer:initData(data)
    dump(data, "GorillaLayer:initData")
    self:setTouch(true)
    if not data then 
        self:sendStart()
        return 
    end

    if #data==0 then
        self:sendStart()
        return 
    end

    for k, v in ipairs(data) do
        self.isContinue = true
        self.index = v.position
        self:continue(v)
    end
    self.isContinue = false
end
function GorillaLayer:sendStart()
    bole:getMiniGameControl():minigame_start()
    self:toWait(true)
end
function GorillaLayer:sendStep(index)
    self.index = index
    bole:getMiniGameControl():miniGame_step(index)
    self:toWait(true)
end
function GorillaLayer:sendOver()
    bole:postEvent("next_data",{ isDeal = true})
    bole:postEvent("next_miniGame")
    bole:getAudioManage():stopAudio("gorilla_freespin")
    self:removeFromParent()
end

function GorillaLayer:toClick(index, data, isAnimal)
    self.selects[#self.selects + 1] = index
    self.cells[index]:click(data.collection_content)
end
function GorillaLayer:continue(data)
    if not data then return end
    self:updateCoins(data.collect_coin_pool)
    self:updateMul(data.collection_amount)
    if data.status == "START" then
    elseif data.status == "OPEN" then
        self:toClick(self.index, data, not self.isContinue)
    elseif data.status == "CLOSED" then
        self.over_mul:setString("" .. data.collection_amount)
        self.over_win:setString("" .. data.collect_coin_pool)
        self.over_total:setString("" .. tonumber(data.collect_coin_pool)*tonumber(data.collection_amount))
        self:toClick(self.index, data, not self.isContinue)
        self:showOther(data.collection_other_content)
        performWithDelay(self, function()
            self.over:setVisible(true)
        end , 3)
    end
end
function GorillaLayer:updateCoins(coins)
    if self.bmf_coins and coins then
        self.win = coins
        self.bmf_coins:setString("" .. coins)
    end
end

function GorillaLayer:updateMul(num)
    if self.bmf_mul and num then
        self.mul = num
        self.bmf_mul:setString("" .. num)
    end
end

function GorillaLayer:updateUI(data)
    data = data.result
    dump(data, "GorillaLayer:updateUI")
    self:toWait(false)
    self:continue(data)
end

function GorillaLayer:clickCallback(index)
    print("--------clickCallback" .. index)
    self:sendStep(index)
end

function GorillaLayer:showOther(data)
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

function GorillaLayer:touchEvent(sender, eventType)
    if not sender then return end
    local name = sender:getName()
    if eventType == ccui.TouchEventType.began then
        print("Touch Down")
    elseif eventType == ccui.TouchEventType.moved then
        print("Touch Move")
    elseif eventType == ccui.TouchEventType.ended then
        print("Touch Up")
        if (name == "btn_get") then
            bole:getAppManage():addCoins(self.coins)
            self:sendOver()
        end
    elseif eventType == ccui.TouchEventType.canceled then
        print("Touch Cancelled")
    end
end

return GorillaLayer
-- endregion
