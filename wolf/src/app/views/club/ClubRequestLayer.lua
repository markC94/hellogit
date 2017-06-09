--region *.lua
--Date
--此文件由[BabeLua]插件自动生成


local ClubRequestLayer = class("ClubRequestLayer", cc.load("mvc").ViewBase)

function ClubRequestLayer:onCreate()
    self.root_ =  self:getCsbNode():getChildByName("root")
    self.request_ =  self:getCsbNode():getChildByName("Panel_request")
    self.listView_ = self.root_:getChildByName("ListView")

    self:initRequest()
    --self:initListView()

    self:adaptScreen()
end

function ClubRequestLayer:onEnter()
    bole:addListener("initRequestInfo", self.initRequestInfo, self, nil, true)
    bole.socket:registerCmd("deal_club_application", self.deal_club_application, self)
end

function ClubRequestLayer:initRequestInfo(data)
    self.requestList_ = data.result
    self.processInfo_ = {}
    dump(self.requestList_,"mkmkmkmkmkmkmkmkmkmk")
    self:initListView(self.requestList_)
end



function ClubRequestLayer:initRequest()
    self.request_:getChildByName("Panel_1"):getChildByName("btn_ok"):addTouchEventListener(handler(self, self.touchEvent))
    self.request_:getChildByName("Panel_1"):getChildByName("btn_no"):addTouchEventListener(handler(self, self.touchEvent))
end

function ClubRequestLayer:initListView(data)
    self.listView_:setScrollBarOpacity(0)
    self.listView_:removeAllChildren()
    for i = 1, # data do
        local cell = self:createMemberCell(data[i])
        cell:getChildByName("num"):setString(i)
        self.listView_:pushBackCustomItem(cell)
    end
end


function ClubRequestLayer:createMemberCell(data)
    local cell = self.request_:clone()
    cell:setVisible(true)
    cell.info = data
    local head = bole:getNewHeadView(data)
    head:setScale(0.8)
    head:updatePos(head.POS_CLUB_REQUEST)   
    cell:getChildByName("coin"):setString(bole:formatCoins(tonumber(data.coins),5))
    cell:getChildByName("Node_head"):addChild(head)
    return cell
end


function ClubRequestLayer:requestTouchEvent(sender, eventType)
    local tag = sender:getTag()
    if eventType == ccui.TouchEventType.ended then
        print(tag)
    end
end

function ClubRequestLayer:touchEvent(sender, eventType)
    local name = sender:getName()
    local widget = sender:getParent():getParent()
    if eventType == ccui.TouchEventType.began then
        sender:runAction(cc.ScaleTo:create(0.1, 1.05, 1.05))
    elseif eventType == ccui.TouchEventType.moved then

    elseif eventType == ccui.TouchEventType.ended then
        sender:runAction(cc.ScaleTo:create(0.1, 1, 1))
        if name == "btn_ok" then
            self:refreshRequestPanel(widget,2)
            self.processInfo_.info = widget.info
            self.processInfo_.result = 1
            bole.socket:send("deal_club_application",{user_id = tonumber(widget.info.user_id), result = 1 },true)

        elseif name == "btn_no" then
            bole:getUIManage():openClubTipsView(5,function() 
                            self.processInfo_.info = widget.info
                            self.processInfo_.result = 0
                            bole.socket:send("deal_club_application",{user_id = tonumber(widget.info.user_id), result = 0 },true)
                            self:refreshRequestPanel(widget,3) 
            end)
        end

    elseif eventType == ccui.TouchEventType.canceled then
        sender:runAction(cc.ScaleTo:create(0.1, 1, 1))
    end
end

function ClubRequestLayer:refreshRequestPanel(widget,status)
    widget:getChildByName("Panel_1"):setVisible(false)
    widget:getChildByName("Image_dec"):setVisible(false)
    widget:getChildByName("Image_acc"):setVisible(false)

    if status == 1 then
        widget:getChildByName("Panel_1"):setVisible(true)
    elseif status == 2 then
        widget:getChildByName("Image_acc"):setVisible(true)
    elseif status == 3 then
        widget:getChildByName("Image_dec"):setVisible(true)
    end
end

function ClubRequestLayer:sendApplication()
    bole.socket:send("deal_club_application",{self.sendList_},true)
end


function ClubRequestLayer:deal_club_application(t,data)
    if t == "deal_club_application" then

          if self.processInfo_.result == 1 then
               bole:postEvent("addMember", self.processInfo_.info) 
               bole:postEvent("addMemberPanel", self.processInfo_.info) 
          end 

          for i = 1, #self.requestList_ do
                if tonumber( self.requestList_[i].user_id )== tonumber(self.processInfo_.info.user_id) then
                    table.remove(self.requestList_ , i)
                    bole:postEvent("dealClubApp", self:isHaveRequest()) 
                    return
                end
          end
    end
end

function ClubRequestLayer:isHaveRequest()
    if # self.requestList_ == 0 then
        return false
    else
        return true
    end
end

function ClubRequestLayer:adaptScreen()

end

function ClubRequestLayer:onExit()
    bole:removeListener("initRequestInfo", self)
    bole.socket:unregisterCmd("deal_club_application")
end

return ClubRequestLayer
--endregion
