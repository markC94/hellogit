-- region *.lua
-- Date
-- 此文件由[BabeLua]插件自动生成
local SlotsLobbyScene = class("SlotsLobbyScene", cc.load("mvc").ViewBase)
function SlotsLobbyScene:onCreate()
    print("SlotsLobbyScene-onCreate")
    local root = self:getCsbNode():getChildByName("root")
    self:initBtn(root)
end
function SlotsLobbyScene:initBtn(root)                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                             
    local scorll_mode = ccui.Helper:seekWidgetByName(root, "scorll_mode")
    local scorll_width = 0
    --一页最大数量
    local count=8
    --敬请期待数量
    local other=0

    local themes=bole:getConfigCenter():getConfig("theme")
    local newThemes={}

    for k,v in pairs(themes) do
        if v.order~=-1 then
            local index=#newThemes+1
            newThemes[index]={}
            newThemes[index].index=tonumber(k)
            newThemes[index].order=v.order
        end
    end
    table.sort(newThemes,function(a,b)
        return a.order<b.order
    end)
    --是否填充满当前页面 已经弃用
--    other=8-#newThemes%8
    local themeCount=#newThemes+other
    for i = 1,themeCount  do
        local page = math.floor((i - 1) / count)
        local index = math.floor((i - 1) % count)
        local temp_w = 0
        local themeid=0
        if i<=themeCount-other then
            themeid=newThemes[i].index
        end
        local cell = bole:getEntity("app.views.lobby.LobbyCell",themeid)
        if index < count/2 then
            temp_w = 190 + 320 *(index) + page * 1300
            cell:setPosition(temp_w, 410)
        else
            temp_w = 190 + 320 *(index - count/2) + page * 1300
            cell:setPosition(temp_w, 160)
        end
        if scorll_width < temp_w then
            scorll_width = temp_w + 190
        end
        scorll_mode:addChild(cell)
    end
    scorll_mode:setInnerContainerSize( { width = scorll_width, height = 555.0000 })
end

function SlotsLobbyScene:touchEvent(sender, eventType)
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
    elseif eventType == ccui.TouchEventType.canceled then
        print("Touch Cancelled")
        sender:setScale(1)
    end
end

return SlotsLobbyScene


-- endregion
