--region *.lua
--Date
--此文件由[BabeLua]插件自动生成
local LobbyExp = class("LobbyExp", cc.Node)
--大厅经验
function LobbyExp:ctor(isSlot)
    self.isUpLevel=false
    self.isSlot=isSlot
    self.node_progress = cc.CSLoader:createNode("csb/lobby/LobbyExp.csb")
    self:addChild(self.node_progress)

    self:registerScriptHandler(function(state)
        if state == "enter" then
            self:onEnter()
        elseif state == "exit" then
            self:onExit()
        end
    end)
    self.tempProgress=0
    local clipNode = cc.ClippingNode:create()
    local mask = display.newSprite("common/common_lv_Pbar.png")
    clipNode:setAlphaThreshold(0)
    clipNode:setStencil(mask)
    self.move_eff = display.newSprite("common/common_lv_PbarLight.png")
    -- eff:setScale(mask:getContentSize().width / head:getContentSize().width)
    clipNode:addChild(self.move_eff)
    clipNode:setPosition(cc.p(106, 15))
    self.bar_exp = self.node_progress:getChildByName("bar_exp")
    self.bar_exp:addChild(clipNode)
    self.exp=bole:getUserDataByKey("experience")
    self:updateProgress(bole:getExpPercent())

    self.Particle_1 = self.node_progress:getChildByName("Particle_1")
    self.Particle_1:setVisible(false)

end
function LobbyExp:showUpLevel()
   print("--------------showUpLevel!!!")
   bole:getAppManage():tryShowUpLevel()
   self.isUpLevel=true
   self.Particle_1:setVisible(true)
   self.Particle_1:resetSystem()
   
   local endTime=0.5
   local updateTime=0
   local function update(dt)
        if updateTime>=endTime then
             self:endUpLevel()
             return
        end
        updateTime=updateTime+dt
        self:updateUpLevel((endTime-updateTime)*200)
    end
    self:onUpdate(update)
end

function LobbyExp:endUpLevel()
    print("--------------endUpLevel!!!")
    self:unscheduleUpdate()
    self.Particle_1:setVisible(false)
    self.Particle_1:setPosition(100, 0)
    self.isUpLevel = false
    if self.tempProgress>0 then
        print("--------------self.tempProgress="..self.tempProgress)
        local temp=self.tempProgress
        self.tempProgress=0
        self:updateProgress(temp)
    end
end

function LobbyExp:onEnter()
    
    if self.isSlot then
        bole:addListener("putWinCoinToTop", self.onExpChangedSlot, self, nil, true)
    else
        bole:addListener("experienceChanged", self.onExpChanged, self, nil, true)
    end
end

function LobbyExp:onExit()
    if self.isSlot then
        bole:getEventCenter():removeEventWithTarget("putWinCoinToTop", self)
    else
        bole:getEventCenter():removeEventWithTarget("experienceChanged", self)
    end
end

function LobbyExp:onExpChangedSlot(event)
    local exp=event.result.exp
    local levelup=event.result.levelup
    if levelup then
        for k,v in ipairs(levelup) do
            bole:getAppManage():addUpLevel(v)
        end
    end

    if exp then
        self:changeProgress(exp,1)
    end
end

function LobbyExp:onExpChanged(event)
    self:updateProgress(bole:getExpPercent())
end

function LobbyExp:changeProgress(newExp, useTime)
    local speed =(newExp - self.exp) / useTime
    local spendTime = 0
    local function update(dt)
        if spendTime >= useTime then
            self.bar_exp:unscheduleUpdate()
        end
        spendTime = spendTime + dt
        if spendTime >= useTime then
            self.exp=newExp
        else
            self.exp=self.exp+speed*dt
        end
        local percent=bole:getExpPercent(self.exp)
        self:updateProgress(percent)
    end
    self.bar_exp:onUpdate(update)
end

function LobbyExp:onExpChanged(event)
    self:updateProgress(bole:getExpPercent())
end

function LobbyExp:updateUpLevel(progress)
    self.bar_exp:setPercent(progress)
    local off = 3
    self.move_eff:setPosition(cc.p(-109 - 31 + 2.18 * progress + off, -2))
    if self.Particle_1 then
        self.Particle_1:setPosition(cc.p(-100+2*progress,0))
    end
end
function LobbyExp:updateProgress(progress)
    if self.isUpLevel then
        self.tempProgress=progress
        return
    end
    if progress >= 100 then
        self.tempProgress=progress-100
        self:showUpLevel()
        progress = 0
    end
    self.bar_exp:setPercent(progress)
    local off = 3
    self.move_eff:setPosition(cc.p(-109 - 31 + 2.18 * progress + off, -2))
end
return LobbyExp
--endregion
