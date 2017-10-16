-- region *.lua
-- Date
-- 此文件由[BabeLua]插件自动生成
local FarmDialog = class("FarmDialog", bole:getTable("app.views.minigame.FreeSpinDialog"))
function FarmDialog:initStart(num,isMore)
    FarmDialog.super.initStart(self,num,isMore)
    local btn_start = self.node_start:getChildByName("btn_start")
    local Particle_1 = btn_start:getChildByName("Particle_1")
    performWithDelay(self,function()
        Particle_1:setVisible(true)
    end,0.8)
end

function FarmDialog:initOver(chose)
    FarmDialog.super.initOver(self,chose)
    performWithDelay(self,function()
        self.csbAct:play("loop", true)
    end,0.84)
end

return FarmDialog
-- endregion
