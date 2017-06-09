-- region *.lua
-- Date
-- 此文件由[BabeLua]插件自动生成
local LoadingControl = class("LoadingControl", cc.load("mvc").ControlBase)
local STATUS_INIT_UI =1
local STATUS_INIT_DATA =2
local STATUS_INIT_SERVER =3
function LoadingControl:init()
    self.progress = 0
    self.status=0
end
function LoadingControl:addPercent(progress)
    self.progress = self.progress + progress
    self:updateProgress(self.progress)
end
function LoadingControl:updateProgress(progress)
    self:getView():setPercent(progress)
end
function LoadingControl:gotoView()

end
return LoadingControl
-- endregion
