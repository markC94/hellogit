-- region *.lua
-- Date
-- 此文件由[BabeLua]插件自动生成
local GorillaLayer = class("GorillaLayer", bole:getTable("app.views.minigame.MiniGameBase"))
local GorillaCell = class("GorillaCell", bole:getTable("app.views.minigame.MiniCellBase"))

function GorillaCell:initView()
    self.bmf_mul = self.csbNode:getChildByName("bmf_mul")
    self.bmf_mul_over = self.csbNode:getChildByName("bmf_mul_over")
    self.bmf_mul:setVisible(false)
    self.bmf_mul_over:setVisible(false)
    self.img_1 = self.csbNode:getChildByName("img_icon_1") 
    self.img_2 = self.csbNode:getChildByName("img_icon_2")
    self.img_1:setVisible(true)
    self.img_2:setVisible(false)
    self.sp_tips = self.csbNode:getChildByName("sp_tips")
    self.sp_tips:setVisible(false)
    self:setClickNode(self.img_1)

end

function GorillaCell:showCell(data,isOver)
    if isOver then
        self.bmf_mul_over:setVisible(true)
        self.bmf_mul_over:setString("X" .. math.abs(data))
        if data < 0 then
            self.sp_tips:setVisible(true)
            self.sp_tips:setColor( { r = 127, g = 127, b = 127 })
        end
    else
        self.bmf_mul:setVisible(true)
        self.bmf_mul:setString("X" .. math.abs(data))
        bole:getAudioManage():playEff("w4")
        if data < 0 then
            self.sp_tips:setVisible(true)
        end
    end

    self.img_1:setVisible(false)
    self.img_2:setVisible(true)
    local skeletonNode = sp.SkeletonAnimation:create("util_act/box.json", "util_act/box.atlas")
    skeletonNode:setAnimation(0, "open", false)
    self:addChild(skeletonNode)
end
------------------------------------------------GorillaLayer
function GorillaLayer:initView()
    local root = self.csbNode:getChildByName("root")
    local title_bg = root:getChildByName("title_bg")
    self.bmf_mul = title_bg:getChildByName("bmf_mul")
    self.bmf_coins = title_bg:getChildByName("bmf_coins")
    if self.collect_coin_pool then
        self:updateCoins(self.collect_coin_pool)
    end

    self:initCell(root)

    self.over = root:getChildByName("over")
    self.over_mul = self.over:getChildByName("txt_mul")
    self.over_win = self.over:getChildByName("txt_win")
    self.over_total = self.over:getChildByName("txt_total")
    self.over:setVisible(false)
    self.btn_get = ccui.Helper:seekWidgetByName(self.over, "btn_get")
    self.btn_get:addTouchEventListener(handler(self, self.touchEvent))

    self.isContinue = false
    self.selects = { }
    self.total = 0
    self.mul = 0
    self.win = 0

    local x, y = title_bg:getPosition()
    self.title_pos = cc.p(x, y)
    self.click_act = sp.SkeletonAnimation:create("util_act/guang.json", "util_act/guang.atlas")
    root:addChild(self.click_act)
    self.click_act:setPosition(x, y + 24)

    self.mul_act = sp.SkeletonAnimation:create("util_act/guangshu.json", "util_act/guangshu.atlas")
    root:addChild(self.mul_act)
    self.mul_act:setPosition(x, y + 60)

    self.particle = cc.ParticleSystemQuad:create("util_act/boxFly.plist")
    root:addChild(self.particle)
    self.particle:setVisible(false)

    self.click_act:setBlendFunc( { src = 770, dst = 1 })
    self.mul_act:setBlendFunc( { src = 770, dst = 1 })
    self.particle:setBlendFunc( { src = 770, dst = 1 })

    --    self.click_act:setAnimation(0, "animation", true)
    --    self.mul_act:setAnimation(0, "animation", true)
end
--点击动画
function GorillaLayer:playClickAnima(index)
    if not index then
        return
    end
    if not self.cells then
        return
    end
    
    if not self.cells[self.cells_row] then
        return
    end

    self.particle:setVisible(true)
    self.particle:resetSystem()
    self.click_pos = cc.p(self.cells[self.cells_row][index]:getParent():getPosition())
    self.particle:setPosition(self.click_pos)
    self.click_pos = nil
    local time = 0.5
    local move = cc.MoveTo:create(time, self.title_pos)
    self.particle:runAction(move)
    performWithDelay(self, function()
        self.particle:setVisible(false)
        self.mul_act:setAnimation(0, "animation", false)
        self.click_act:setAnimation(0, "animation", false)
        self:updateCoins(self.win)
        self:updateMul(self.mul)
    end , time)
end
--初始化点击节点
function GorillaLayer:initCell(root)
    for i = 1, 10 do
        local rootCell = root:getChildByName("node_cell_" .. i)
        local miniCell = GorillaCell:create(i,handler(self, self.sendStep))
        rootCell:addChild(miniCell)
        self:addCell(miniCell,i)
    end
end
--下一步
function GorillaLayer:sendStep(index)
    if self.isPlayClickAnima then
        return
    end
    GorillaLayer.super.sendStep(self,index)
    bole:getAudioManage():playEff("w1")
    self.isPlayClickAnima=true
end
--更新UI
function GorillaLayer:updateUI(data,index)
    if self.isPlayClickAnima then
        self.mul = data.collection_amount
        self.win = data.collect_coin_pool
        performWithDelay(self, function()
            self.isPlayClickAnima=false
            self:playClickAnima(index)
        end , 0.7)
    else
        self:updateCoins(data.collect_coin_pool)
        self:updateMul(data.collection_amount)
    end
end

--显示结束
function GorillaLayer:showOver(data,index)
    self.over_mul:setString("X" .. bole:formatCoins(data.collection_amount, 5))
    self.over_win:setString(bole:formatCoins(data.collect_coin_pool, 9))
    self.over_total:setString(bole:formatCoins(tonumber(data.collect_coin_pool) * tonumber(data.collection_amount), 8))

    performWithDelay(self, function()
        self:showOther(data.collection_other_content)
    end , 2)
    performWithDelay(self, function()
        self.over:setVisible(true)
        self.csbAct:play("start", false)
        bole:getAudioManage():clearSpin()
    end , 4)
end

function GorillaLayer:updateCoins(coins)
    if self.bmf_coins and coins then
        self.coins = coins
        self.bmf_coins:setString("$" .. coins)
    end
end

function GorillaLayer:updateMul(num)
    if self.bmf_mul and num then
        self.mul = num
        self.bmf_mul:setString("X" .. num)
    end
end


function GorillaLayer:showOther(data)
    local pos = 1
    for i, v in ipairs(self.cells[self.cells_row]) do
        local isSelect = false
        for _, index in ipairs(self.selects) do
            if (i == index) then
                isSelect = true
            end
        end
        if not isSelect then
            if pos <= #data then
                v:recvOver(data[pos])
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
            self:collectOver(self.coins)
        end
    elseif eventType == ccui.TouchEventType.canceled then
        print("Touch Cancelled")
    end
end

return GorillaLayer
-- endregion
