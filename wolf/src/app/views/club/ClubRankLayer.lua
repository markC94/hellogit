-- region *.lua
-- Date
-- 此文件由[BabeLua]插件自动生成
local ClubRankLayer = class("ClubRankLayer", cc.load("mvc").ViewBase)
function ClubRankLayer:onCreate()
    print("ClubRankLayer-onCreate")
    local root = self:getCsbNode():getChildByName("root")
    local btn_close = root:getChildByName("btn_close")
    btn_close:addTouchEventListener(handler(self, self.touchEvent))
    self.txt_rank = root:getChildByName("txt_rank")
end
function ClubRankLayer:onKeyBack()
    self:closeUI()
end
function ClubRankLayer:updateUI(data)
    self:initRank(data.result)
end
function ClubRankLayer:initRank(name)
    self.txt_rank:setString("Rank:" .. name)
end

function ClubRankLayer:touchEvent(sender, eventType)
    local name = sender:getName()
    local tag = sender:getTag()
    print("touchEvent:" .. name)
    if eventType == ccui.TouchEventType.began then
        print("Touch Down")
        sender:setScale(1.05)
    elseif eventType == ccui.TouchEventType.moved then
        print("Touch Move")
    elseif eventType == ccui.TouchEventType.ended then
        print("Touch Up")
        sender:setScale(1)
        if name == "btn_close" then
            self:closeUI()
        end
    elseif eventType == ccui.TouchEventType.canceled then
        print("Touch Cancelled")
        sender:setScale(1)
    end
end
return ClubRankLayer
-- endregio