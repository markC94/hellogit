-- region *.lua
-- Date
-- 此文件由[BabeLua]插件自动生成
local LongHurnDialog = class("LongHurnDialog", bole:getTable("app.views.minigame.FreeSpinDialog"))
function LongHurnDialog:initStart(num,isMore)
    LongHurnDialog.super.initStart(self,num,isMore)
    local Particle_1 = self.root:getChildByName("Particle_1")
    local Particle_2 = self.root:getChildByName("Particle_2")
    Particle_1:setVisible(true)
    Particle_1:resetSystem()
    Particle_2:setVisible(false)
    performWithDelay(self,function()
        Particle_2:setVisible(true)
        Particle_2:resetSystem()
    end,0.83)
    local btn_start = self.node_start:getChildByName("btn_start")
    if btn_start then
        bole:flash(btn_start,"free_spin/ui/anniu-s.png")
    end
end

function LongHurnDialog:initOver(chose)
    LongHurnDialog.super.initOver(self,chose)
    local Particle_1 = self.root:getChildByName("Particle_1")
    local Particle_2 = self.root:getChildByName("Particle_2")
    Particle_1:setVisible(true)
    Particle_1:resetSystem()
    Particle_2:setVisible(false)
    performWithDelay(self,function()
    Particle_2:setVisible(true)
    Particle_2:resetSystem()
    end,0.83)
    local btn_collect = self.node_collect:getChildByName("btn_collect")
    bole:flash(btn_collect,"free_spin/ui/anniu-c.png")
end

return LongHurnDialog
-- endregion
