-- region *.lua
-- Date
-- 此文件由[BabeLua]插件自动生成
local WitchGameLayer = class("WitchGameLayer", cc.load("mvc").ViewBase)
local WitchCell = class("WitchCell", cc.load("mvc").MiniCell)
local ACTION_IDLE = "idle"
local ACTION_CLICK = "click"
local ACTION_TRIGGET = "trigget"
local ACTION_OVER = "over"
function WitchCell:onCreate()
    self.isEnable = true
    self:changeNode("csb/WitchCell.csb")
    self:setTouchSize(278, 243)
    self.img_win = self.animaNode:getChildByName("img_win")
    self.img_lose = self.animaNode:getChildByName("img_lose")
    self.img_win:setVisible(false)
    self.img_lose:setVisible(false)
end

function WitchCell:timeCallback()
    self:showOver()
end

function WitchCell:idle()
    self.status = ACTION_IDLE
    self.action:play(self.status, true)
end

function WitchCell:click(data)
    if not self.isEnable then return end
    self.isEnable = false
    self.status = ACTION_CLICK
    self.data = data
    self:setTimeCallback(40.0 / 60.0)
    self.action:play(self.status, false)
end
function WitchCell:overClick(data)
    if not self.isEnable then return end
    self.isEnable = false
    self.over = true
    self.status = ACTION_OVER
    self.data = data
    self:setTimeCallback(25.0 / 60.0)
    self.action:play(self.status, false)
end

function WitchCell:showOver()
    local root = nil
    if self.over then
        root = self.img_lose
    else
        root = self.img_win
    end
    root:setVisible(true)
    local txt_free = root:getChildByName("txt_free")
    local txt_all = root:getChildByName("txt_all")
    txt_free:setString("" .. self.data[2])
    txt_all:setString("x" .. self.data[3])
end


function WitchGameLayer:onCreate()
    local root = self:getCsbNode():getChildByName("root")
    self:initCell(root)
    self:setTouch(false)
end

function WitchGameLayer:initData(data)
    self.chose = data.chose
    self.other = data.other_chose
    self:setTouch(true)
end
function WitchGameLayer:initCell(root)
    self.cells = { }
    for i = 1, 5 do
        local rootCell = root:getChildByName("node_cell_" .. i)
        local miniCell = WitchCell:create(bole.MINIGAME_ID_WITCH, i, handler(self, self.clickCallback))
        rootCell:addChild(miniCell)
        self.cells[i] = miniCell
    end
end
function WitchGameLayer:clickCallback(index)
    print("--------clickCallback")
    self.cells[index]:click(self.chose)
    self:setTouch(false)
    performWithDelay(self, function()
        self:showOther(index, self.other)
    end , 2)
    performWithDelay(self, function()
        self:GameOver()
    end , 4)
end

function WitchGameLayer:showOther(index, data)
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

function WitchGameLayer:GameOver(data)
    bole:postEvent("mng_dialog",{msg="start",ui_name=bole.UI_NAME.WitchDialogLayer,chose={self.chose[2],self.chose[1],self.chose[3]}})
    self:removeFromParent()
end


function WitchGameLayer:updateUI(data)
    data = data.result
    self:initData(data)
end


return WitchGameLayer
-- endregion
