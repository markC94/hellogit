-- region *.lua
-- Date
-- 此文件由[BabeLua]插件自动生成
local ClubChestLayer = class("ClubChestLayer", cc.load("mvc").ViewBase)
function ClubChestLayer:onCreate()
    print("ClubChestLayer-onCreate")
    local root = self:getCsbNode():getChildByName("root")
    root:setTouchEnabled(true)
    root:addTouchEventListener(handler(self, self.touchEvent))
    self.txt_rank = root:getChildByName("txt_rank")
end

function ClubChestLayer:updateUI(data)
    self:initRank(data.result)
end
function ClubChestLayer:initRank(data)
    self.txt_rank:setString("Rank:"..data.rank.."---------------level:"..data.level)
end

function ClubChestLayer:touchEvent(sender, eventType)
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
        if name == "root" then
            self:closeUI()
            bole.socket:send(bole.SERVER_LEAGUE_REWARD, { })
        end
    elseif eventType == ccui.TouchEventType.canceled then
        print("Touch Cancelled")
        sender:setScale(1)
    end
end
return ClubChestLayer
-- endregio