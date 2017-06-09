--region *.lua
--Date
--此文件由[BabeLua]插件自动生成
local EmeraldGameLayer = class("EmeraldGameLayer", cc.load("mvc").ViewBase)
local EmeraldCell = class("EmeraldCell", cc.load("mvc").MiniCell)
local ACTION_IDLE = "idle"
local ACTION_CLICK = "click"
function EmeraldCell:onCreate()
    self.isEnable = true
    self:changeNode("csb/EmeraldCell.csb")
    self:setTouchSize(278, 243)

    self.img_box_2 = self.animaNode:getChildByName("img_box_2")
    self.img_box_1 = self.animaNode:getChildByName("img_box_1")
    
    self.txt = self.animaNode:getChildByName("txt")

    self.move = self.animaNode:getChildByName("move")
    self.cells={}
    self.index=1
    self.cells[2] = self.move:getChildByName("cell_2")
    

    for i=1,2 do
        self.cells[i] = self.move:getChildByName("cell_"..i)
        self.cells[i]:setVisible(false)
    end

    self.img_box_2:setVisible(false)
    self.move:setVisible(false)
    self.txt:setVisible(false)
end
function EmeraldCell:setGoold(index)
    if index<=0 or index>#self.cells then return end
    self.index=index
    self.cells[index]:setVisible(true)
end
function EmeraldCell:timeCallback()
    self:showOver()
end

function EmeraldCell:idle()
    self.status = ACTION_IDLE
    self.action:play(self.status, true)
end

function EmeraldCell:click(data)
    if not self.isEnable then return end
    self.isEnable = false
    self.status = ACTION_CLICK
    self.data = data
    self:setTimeCallback(0.5)
    self.action:play(self.status, false)

    --test 这里需要倍数对应关系
    local test_index=math.random(1,2)
    self:setGoold(test_index)

    if self.over then
        local img_1=self.cells[self.index]:getChildByName("img_1")
        img_1:setVisible(false)
        self.img_box_1:setVisible(false)
        self.img_box_2:setVisible(true)
    else
        local img_2=self.cells[self.index]:getChildByName("img_2")
        img_2:setVisible(false)
    end
    self.move:setVisible(true)
end
function EmeraldCell:overClick(data)
    if not self.isEnable then return end
    self.over = true
    self:click(data)
end

function EmeraldCell:showOver()
    self.txt:setVisible(true)
    local txt_1=self.txt:getChildByName("txt_1")
    local txt_2=self.txt:getChildByName("txt_2")
    local txt_cur=nil
    if self.over then
        txt_cur=txt_2
        txt_1:setVisible(false)
    else
        txt_cur=txt_1
        txt_2:setVisible(false)
    end
    txt_cur:setString("X" .. self.data)
end
function EmeraldGameLayer:onCreate()
    local root = self:getCsbNode():getChildByName("root")
    self.txt_coins=ccui.Helper:seekWidgetByName(root, "txt_coins")
    self:initCell(root)
    self:setTouch(false)
    self.collect_count=0
end
function EmeraldGameLayer:initCell(root)
    self.cells = { }
    for i = 1, 4 do
        local rootCell = root:getChildByName("node_cell_" .. i)
        local miniCell = EmeraldCell:create(bole.MINIGAME_ID_EMERALD, i, handler(self, self.clickCallback))
        rootCell:addChild(miniCell)
        self.cells[i] = miniCell
    end
end
function EmeraldGameLayer:setCoint(data)
    self.txt_coins:setString(data)
end
function EmeraldGameLayer:clickCallback(index)
    print("--------clickCallback")
    self.cells[index]:click(self.chose)
    self:setTouch(false)
    performWithDelay(self, function()
        self:showOther(index, self.other)
    end , 2)
    performWithDelay(self, function()
        self:GameOver()
    end , 4)
    self:setCoint(self.overCoins)
end
function EmeraldGameLayer:showOther(index, data)
    local pos = 1
    for i, v in ipairs(self.cells) do
        if (i ~= index) then
            if pos <= #data then
                v:overClick(data[pos])
                pos = pos + 1
            end
        end
    end
end

function EmeraldGameLayer:GameOver(data)
    bole:postEvent("mng_dialog",{msg="over",ui_name=bole.UI_NAME.EmeraldDialogLayer,chose={ self.curCoins,self.chose,self.collect_count}})
    self:removeFromParent()
end


function EmeraldGameLayer:updateUI(data)
    data = data.result
    self:initData(data)
end
function EmeraldGameLayer:initData(data)
    self.curCoins=data.collect_coin_pool
    self.overCoins=data.result_amont
    self.chose=data.collect_multiplier
    self.other=data.collect_other_multiplier
    self.collect_count=data.collect_count
    self:setCoint(self.curCoins)
    self:setTouch(true)
end
return EmeraldGameLayer


--endregion
