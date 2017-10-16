-- region *.lua
-- Date
-- 此文件由[BabeLua]插件自动生成
local FarmGame = class("FarmGame", bole:getTable("app.views.minigame.MiniGameBase"))
local FarmCell = class("FarmCell", bole:getTable("app.views.minigame.MiniCellBase"))
local cells={"pic_radish_1","pic_carrot_1","pic_beet_1","pic_daikon_1","nangua","yanshu"}
function FarmCell:initView()
    self.txt_coins = self.csbNode:getChildByName("txt_coins")
    self.txt_coins_over = self.csbNode:getChildByName("txt_coins_over")
    self.node_icon =self.csbNode:getChildByName("node_icon")
    self.skeletonNode=nil
    self.offy=0
    self.txt_coins:setVisible(false)
    self.txt_coins_over:setVisible(false)
    self.isTouchEnables=true
end

function FarmCell:setRow(row,isOver)
    if self.skeletonNode then
        self.skeletonNode:removeFromParent()
    end

    if row==5 or row==6 then
        self.skeletonNode = sp.SkeletonAnimation:create("game_farm_act/"..cells[row].. ".json", "game_farm_act/"..cells[row].. ".atlas")
        if not isOver then
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
        local path= bole:getSpinApp():getMiniRes(nil,"mini_game/ui/")
        self.skeletonNode=display.newSprite(path..cells[row]..".png")
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

function FarmCell:delayClick()
    if not self.isEnable then
        return
    end
    if self.clickType ~= 2 then
        return
    end
    if not self.delayData then
        return
    end
    self.isEnable = false
    if self.skeletonNode then
        if self.data == -1 or self.data == -2 then
            self.skeletonNode:setVisible(false)
            self:showCell(self.delayData)
        else
            self.skeletonNode:runAction(cc.MoveTo:create(0.2,cc.p(0,25+self.offy)))
            performWithDelay(self,function()
               self:showCell(self.delayData)
            end,0.2)
        end
    end
   
end

function FarmCell:setEnable(enable)
    self.isTouchEnables = enable
    if not enable then
        if self.skeletonNode then
            self.skeletonNode:setColor({ r = 100, g = 100, b = 100})
            bole:clearLight(self.skeletonNode)
        end
    else
        if self.skeletonNode then
            self.skeletonNode:runAction(cc.TintTo:create(0.5,255,255,255))
            bole:toLight(self.skeletonNode)
        end
    end
end

function FarmCell:touchEvent(sender, eventType)
    local name = sender:getName()
    local tag = sender:getTag()
    if eventType == ccui.TouchEventType.began then
        print("Touch Down")
    elseif eventType == ccui.TouchEventType.moved then
        print("Touch Move")
    elseif eventType == ccui.TouchEventType.ended then
        print("Touch ended")
        if self.isTouchEnables then
            self.isTouchEnables=false
            if self.func then
                self.func(self.index)
            end
        end
    elseif eventType == ccui.TouchEventType.canceled then
        print("Touch Cancelled")
    end
end

function FarmCell:showCell(data,isOver)
    self.isTouchEnables=false
    if data == -1 then
        self:setRow(5,isOver)
        bole:getAudioManage():playEff("w2")
    elseif data == -2 then
        self:setRow(6,isOver)
        bole:getAudioManage():playEff("w3")
    else
        if isOver then
            self.txt_coins_over:setVisible(true)
            self.txt_coins_over:setString("" .. data)
            self.txt_coins_over:setOpacity(127)
            self.txt_coins_over:setPosition(0,-10)
--            local sp=cc.Spawn:create(cc.FadeIn:create(0.5),))
            self.txt_coins_over:runAction(cc.MoveTo:create(0.1,cc.p(0,7)))
            self.txt_coins_over:runAction(cc.FadeIn:create(0.3))
            self.txt_coins_over:setScale(1.2)
        else
            bole:getAudioManage():playEff("w1")
            self.txt_coins:setScale(0.3)
            local seq=cc.Sequence:create(cc.ScaleTo:create(0.2,1.4),cc.ScaleTo:create(0.2,1.2))
            self.txt_coins:runAction(seq)
            self.txt_coins:setVisible(true)
            self.txt_coins:setString("" .. data)
        end
    end
    bole:clearLight(self.skeletonNode)
    if isOver then
        if self.skeletonNode then
            self.skeletonNode:setColor({ r = 100, g = 100, b = 100})
        end
    else
        if self.skeletonNode then
            self.skeletonNode:runAction(cc.TintTo:create(0.5,255,255,255))
        end
    end

end

------------------------------------------------FarmGame
function FarmGame:initView()
    local root = self.csbNode:getChildByName("root")
    local img_bg = self.csbNode:getChildByName("img_bg")
    self.txt_coins=img_bg:getChildByName("txt_coins")

    local row_1 = root:getChildByName("row_1")
    local row_2 = root:getChildByName("row_2")
    local row_3 = root:getChildByName("row_3")
    local row_4 = root:getChildByName("row_4")
    self:initCell(row_1, 1)
    self:initCell(row_2, 2)
    self:initCell(row_3, 3)
    self:initCell(row_4, 4)

    self.start = self.csbNode:getChildByName("node_start")
    self.over = self.csbNode:getChildByName("node_collect")
    self.over_coins=self.over:getChildByName("label_coins")
    self.start:setVisible(true)
    self.over:setVisible(false)
    self.btn_start = self.start:getChildByName("btn_start")
    self.btn_start:addTouchEventListener(handler(self, self.touchEvent))
    self.btn_get = self.over:getChildByName("btn_collect")
    self.btn_get:addTouchEventListener(handler(self, self.touchEvent))
    self.step = 1
    self.index = 0
    self.coins=0
    self.Particle_1 = self.btn_start:getChildByName("Particle_1")
    self.Particle_1:setVisible(false)
    self.sp_tips=root:getChildByName("sp_tips")
    self.sp_txt=self.sp_tips:getChildByName("sp_txt")
    bole:getAudioManage():playMusic("bgm3_music",true)
end

function FarmGame:initCell(root, row)
    for i = 1, 7 do
        local rootCell = root:getChildByName("cell_" .. i)
        local miniCell = FarmCell:create(i,handler(self, self.sendStep))
        miniCell:setRow(row)
        miniCell:setEnable(false)
        miniCell:setPosition(0,0)
        rootCell:addChild(miniCell)
        self:addCell(miniCell,i,row)
    end
end

--开始新的游戏
function FarmGame:newGame()
    self.csbAct:play("start",false)
    performWithDelay(self,function()
        self.Particle_1:setVisible(true)
    end,0.8)
end
function FarmGame:clickStart()
    self.csbAct:play("end",false)
    self.sp_tips:setVisible(true)
    self:sendStart()
    self.Particle_1:setVisible(false)
    performWithDelay(self,function()
        self.start:setVisible(false)
        self:setRowEnable(1, true)
    end,0.6)
end
function FarmGame:continueGame(data)
    self.start:setVisible(false)
    self:setRowEnable(1, true)
    FarmGame.super.continueGame(self,data)
end

function FarmGame:showOver(data, index)
    self.over_coins:setString("" .. data.minigame_amount)
    performWithDelay(self, function()
        bole:getAudioManage():stopAudio("bgm3_music")
        self.over:setVisible(true)
        self.csbAct:play("start", false)
    end , 3.5)
     performWithDelay(self,function()
        self.csbAct:play("loop", true)
    end,4.5)
end

function FarmGame:updateUI(data,index)
    self:updateCoins(data.minigame_amount)
end

function FarmGame:updateCoins(coins)
    if self.txt_coins and coins then
        self.coins=coins
        self.txt_coins:setString(""..coins)
    end
end

function FarmGame:setRowEnable(row, enable, index)
    for i = 1, 7 do
        if index and i == index then

        else
            self.cells[row][i]:setEnable(enable)
        end
    end
    self.sp_tips:setVisible(true)
    local path= bole:getSpinApp():getMiniRes(nil,"mini_game/ui/")
    self.sp_txt:setTexture(path.."tip_title_"..row..".png")
    if row ==1 then
--        self.sp_tips:setPosition(667,150)
    elseif row==2 then
        self.sp_tips:setPosition(667,280)
    elseif row==3 then
        self.sp_tips:setPosition(667,425)
    elseif row==4 then
        self.sp_tips:setPosition(667,533)
    end

end

function FarmGame:recvStep(data,index)
   self:changeClickCell(index,self.cells_row,data,true)
   if data.status=="OPEN" then
      self.cells_row=self.cells_row+1
   end
   self:overStep()
end

function FarmGame:changeClickCell(index, step, data)
    self.sp_tips:setVisible(false)
    for i = 1, 7 do
        if i == index then
--            self.cells[step][index]:recvClick(30)
            self.cells[step][index]:recvClick(data.minigame_content)
        else
            self.cells[step][i]:setEnable(false)
        end
    end
    performWithDelay(self, function()
        
        local pos = 1
        for i = 1, 7 do
            if i ~= index then
                self.cells[step][i]:setEnable(true)
                self.cells[step][i]:recvOver(data.minigame_other_content[pos])
                pos = pos + 1
            end
        end
    end , 1.0)
    performWithDelay(self, function()
        if step < 4 then
            if data.status=="OPEN" then
                self:setRowEnable(step + 1, true)
            end
            
        end
    end , 1.3)

end

function FarmGame:touchEvent(sender, eventType)
    if not sender then return end
    local name = sender:getName()
    if eventType == ccui.TouchEventType.began then
        print("Touch Down")
    elseif eventType == ccui.TouchEventType.moved then
        print("Touch Move")
    elseif eventType == ccui.TouchEventType.ended then
        print("Touch Up")
        if name == "btn_start" then
            sender:setTouchEnabled(false)
            self:clickStart()
        elseif (name == "btn_collect") then
            bole:getAudioManage():stopAudio("bgm3_music")
            sender:setTouchEnabled(false)
            self:collectOver(self.coins)
        end
    elseif eventType == ccui.TouchEventType.canceled then
        print("Touch Cancelled")
    end
end

return FarmGame
-- endregion
