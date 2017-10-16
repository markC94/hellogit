--region *.lua
--Date
--此文件由[BabeLua]插件自动生成

local VipStatusLayer = class("VipStatusLayer", cc.load("mvc").ViewBase)


function VipStatusLayer:onCreate()
    print("VipStatusLayer:onCreate")
    self.root_ = self:getCsbNode():getChildByName("root")
    self.cell_ = self:getCsbNode():getChildByName("cell")

    self:initTitle()
    self:initListView()
    self:adaptScreen()
end


function VipStatusLayer:initTitle()
    local title = self.root_:getChildByName("titlePanel")
    local btn_close = self.root_:getChildByName("btn_close")
    btn_close:addTouchEventListener(handler(self, self.touchEvent))
end

function VipStatusLayer:initListView()
    local listView = self.root_:getChildByName("listView")
    listView:setScrollBarOpacity(0)
    
    local vipTable = bole:getBuyManage():getVipTable()
    local showTable = {}
    for k , v in pairs(vipTable) do
        table.insert(showTable,v)
    end
    table.sort(showTable, function(a,b) return tonumber(a.vip_level) < tonumber(b.vip_level) end)

    for i = 1, #showTable do
        local cell = self:createVipStatusCell(showTable[i],i)
        listView:pushBackCustomItem(cell)
    end
end

function VipStatusLayer:createVipStatusCell(data,index)
    local cell = self.cell_:clone()
    cell:setVisible(true)
    local icon = cc.Sprite:create(bole:getBuyManage():getVipIconStr(tonumber(data.vip_level)))
    icon:setScale(0.4)
    cell:getChildByName("icon"):addChild(icon)
    cell:getChildByName("txt1"):setString(data.vip_level)
    cell:getChildByName("txt2"):setString("X" .. data.login_multiplier)
    cell:getChildByName("txt3"):setString("X" .. data.buying_multiplier)
    cell:getChildByName("txt4"):setString("X" .. data.store_multiplier)
    cell:getChildByName("txt5"):setString("X" .. data.vippoints_multiplier)
    if data.isunlock == 1 then
        cell:getChildByName("txt6"):setString("YES")
    else
        cell:getChildByName("txt6"):setString("NO")
    end
    if index % 2 == 1 then
        cell:getChildByName("bg2"):setVisible(false)
        cell:getChildByName("bg"):setVisible(true)
    else
        cell:getChildByName("bg2"):setVisible(true)
        cell:getChildByName("bg"):setVisible(false)
    end
    return cell
end


function VipStatusLayer:touchEvent(sender, eventType)
    local name = sender:getName()
    if eventType == ccui.TouchEventType.began then
        sender:runAction(cc.ScaleTo:create(0.1, 1.05, 1.05))
    elseif eventType == ccui.TouchEventType.moved then

    elseif eventType == ccui.TouchEventType.ended then
        sender:runAction(cc.ScaleTo:create(0.1, 1, 1))
        if name == "btn_close" then
            self:closeUI()
        end
    elseif eventType == ccui.TouchEventType.canceled then
        sender:runAction(cc.ScaleTo:create(0.1, 1, 1))
    end
end


function VipStatusLayer:adaptScreen()
    local winSize = cc.Director:getInstance():getWinSize()
    self:setPosition(0,0)
    self.root_:setPosition(winSize.width / 2, winSize.height / 2)
    self.root_:setScale(0.1)
    self.root_:runAction(cc.ScaleTo:create(0.2,1,1))
end

return VipStatusLayer

--endregion
