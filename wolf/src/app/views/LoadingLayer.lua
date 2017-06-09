--region *.lua
--Date
--此文件由[BabeLua]插件自动生成
local LoadingLayer =class("LoadingLayer",cc.load("mvc").ViewBase)
function LoadingLayer:onCreate()
     local root = self:getResourceNode():getChildByName("root");
     self.img_bg = ccui.Helper:seekWidgetByName(root, "img_bg")
     self.bar_loading = ccui.Helper:seekWidgetByName(root, "bar_loading")
     self.progress=0
     self.newProgress=0
     schedule(self, self.updateTime, 0.1)
end
function LoadingLayer:setPercent(progress,isAnima)
    if isAnima then
        self.progress=progress
        self.bar_loading:setPercent(self.progress)
        return
    end
    self.newProgress=progress
end

function LoadingLayer:updateTime()
    if self.progress < progress then
        self.progress =math.floor(self.progress + math.random(10))
        if self.progress>self.newProgress then
            self.progress=self.newProgress
        end
        self.bar_loading:setPercent(self.progress)
        
    end
end
return LoadingLayer
--endregion
