-- region *.lua
-- Date
-- 此文件由[BabeLua]插件自动生成
local SeaDialog = class("SeaDialog", bole:getTable("app.views.minigame.FreeSpinDialog"))
function SeaDialog:initStart(num,isMore)
    SeaDialog.super.initStart(self,num,isMore)
    local btn_start = self.node_start:getChildByName("btn_start")
    if btn_start then
        bole:flash(btn_start,"free_spin/ui/anniu.png")
    end
end

function SeaDialog:initOver(chose)
    SeaDialog.super.initOver(self,chose)
    local btn_collect = self.node_collect:getChildByName("btn_collect")
    bole:flash(btn_collect,"free_spin/ui/back.png")
end

return SeaDialog
-- endregion
