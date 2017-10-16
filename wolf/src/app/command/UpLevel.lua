-- region *.lua
-- Date
-- 此文件由[BabeLua]插件自动生成
local UpLevel = class("UpLevel")
function UpLevel:ctor(root,data,level)
   self.root=root
   if not root then
      return
   end
   self.rootAct=self.root.rootAct
   self.isUnlock=false
   self.data=data
   self.index=1
   self.count=#data
   self.lastLevel =level
   self.curLevel = self.lastLevel
   self.newLevel = self.lastLevel+self.count

   self.root:stopAllActions()
   self.rootAct:gotoFrameAndPause(0)

   self:initView()
   self:initLock()
   self:nextStep()
end

function UpLevel:initView()
    self.root:setVisible(true)
    self.xinzhuti_lizi = self.root.xinzhuti_lizi
    self.levelup_lizi = self.root:getChildByName("levelup_lizi")
    self.xinzhuti_lizi:setVisible(false)
    self.levelup_lizi:setVisible(false)

    local node_reward = self.root:getChildByName("node_reward")
    self.txt_coins = node_reward:getChildByName("txt_coins")
    self.sp_special = node_reward:getChildByName("sp_special")
    self.txt_item = node_reward:getChildByName("txt_item")
    self.txt_bet = node_reward:getChildByName("txt_bet")
    self.txt_points = node_reward:getChildByName("txt_points")
    local node_unLock = self.root:getChildByName("node_unLock")
    self.sp_theme_icon = node_unLock:getChildByName("sp_theme_icon")
end

function UpLevel:nextStep()
    if self.curLevel <self.newLevel then
        if self.index<=self.count then
            self:changeUI(self.data[self.index])
            return
        end
    end

    self.root:setVisible(false)
    self.xinzhuti_lizi:setVisible(false)
    self.levelup_lizi:setVisible(false)

    bole:postEvent("UpLevelOver")
end

function UpLevel:changeUI(data)
    local max_bet=999
    self.txt_coins:setString(bole:formatCoins(data.level_up_bonus,6))
    self.txt_item:setString("x1")
--    data.level_up_multiple

    local levels = bole:getConfigCenter():getConfig("level")
    local leveldats=levels["" .. (self.curLevel+1)]
    if leveldats then
        max_bet=leveldats.max_bet
    end

    if data.special_bonus==0 then
--        self.sp_special
    end
    self.txt_bet:setString(bole:formatCoins(max_bet,3))
    self.txt_points:setString(data.vip_points)
    
    self.index=self.index+1
    self.curLevel=self.curLevel+1
    self:tryLock()
    self:playAct(1)
end

function UpLevel:playAct(index)
    if index==1 then
        self.rootAct:play("start",false)
        performWithDelay(self.root,function()
            self.levelup_lizi:setVisible(true)
            self.levelup_lizi:resetSystem()
        end,0.48)
        if self.isUnlock then
            self.isUnlock=false
            performWithDelay(self.root,function()
                self:playAct(2)
            end,5.5)
        else
            performWithDelay(self.root,function()
                self:playAct(4)
            end,5.5)
        end
    elseif index==2 then
        
        self.rootAct:play("unlock",false)
        performWithDelay(self.root,function()
            self.xinzhuti_lizi:setVisible(true)
            self.xinzhuti_lizi:resetSystem()
        end,0.1)
        performWithDelay(self.root,function()
            self:playAct(3)
        end,3.67)
    elseif index==3 then
        self.rootAct:play("unlock_end",false)
        performWithDelay(self.root,function()
            self:nextStep()
        end,0.5)
    elseif index==4 then
        self.rootAct:play("end",false)
        performWithDelay(self.root,function()
            self:nextStep()
        end,0.5)
    end
end

function UpLevel:initLock()
    local themes=bole:getConfigCenter():getConfig("theme")
    local newThemes={}
    for k,v in pairs(themes) do
        if v.unlock_lv~=-1 then
            local index=#newThemes+1
            newThemes[index]={}
            newThemes[index].index=tonumber(k)
            newThemes[index].unlock_lv=v.unlock_lv
        end
    end
    table.sort(newThemes,function(a,b)
        return a.unlock_lv<b.unlock_lv
    end)
    self.newThemes=newThemes
    dump(self.newThemes,"self.newThemes")
end
function UpLevel:tryLock()
    if self.curLevel==60 then
        bole:toAdjustLevel()
    end

    local themeCount=#self.newThemes
    print("--------------------------------self.lastLevel:"..self.lastLevel)
    print("--------------------------------self.curLevel:"..self.curLevel)
    dump(self.newThemes,"self.newThemes")
    for i = 1,themeCount  do
        if self.newThemes[i].unlock_lv==self.curLevel then
            self.isUnlock=true
            self:changeLockTheme(self.newThemes[i].index)
            return
        end
    end
end

function UpLevel:changeLockTheme(index)
    local num = string.format("%02d", index)
    local themePath = "theme_icon/theme_" .. num .. ".png"
    self.sp_theme_icon:setTexture(themePath)
end

return UpLevel
-- endregion
