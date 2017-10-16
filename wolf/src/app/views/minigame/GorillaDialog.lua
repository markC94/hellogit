-- region *.lua
-- Date
-- 此文件由[BabeLua]插件自动生成
local GorillaDialog = class("GorillaDialog", bole:getTable("app.views.minigame.FreeSpinDialog"))
function GorillaDialog:initStart(num,isMore)
    GorillaDialog.super.initStart(self,num,isMore)
    local btn_start = self.node_start:getChildByName("btn_start")
    if btn_start then
        bole:flash(btn_start,"free_spin/ui/anniu1.png")
    end
end

function GorillaDialog:initOver(chose)
    GorillaDialog.super.initOver(self,chose)
    local btn_collect = self.node_collect:getChildByName("btn_collect")
    bole:flash(btn_collect,"free_spin/ui/ee.png")
end

return GorillaDialog
-- endregion
