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
    bole:addListener("add_f_application_clubRequestLayer", self.addRequest, self, nil, true)
    bole.socket:registerCmd("deal_club_application", self.deal_club_application, self)
end

function ClubRequestLayer:initRequestInfo(data)
    self.requestList_ = data.result
    self.processInfo_ = {}
    dump(self.requestList_,"requestList_")
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
        if i % 2 == 1 then
            cell:getChildByName("bg"):loadTexture("loadImage/club_frame_requests_light.png")
        end
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
    data.coins = data.coins or 0
    cell:getChildByName("coin"):setString(bole:formatCoins(tonumber(data.coins),15))
    cell:getChildByName("Node_head"):addChild(head)
    return cell
end

function ClubRequestLayer:addRequest(data)
    data = data.result
    local cell = self:createMemberCell(data)
    --cell:getChildByName("num"):setString(i)
    self.listView_:pushBackCustomItem(cell)
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
    self.processInfo_.widget = widget
    if eventType == ccui.TouchEventType.began then
        sender:runAction(cc.ScaleTo:create(0.1, 1.05, 1.05))
    elseif eventType == ccui.TouchEventType.moved then

    elseif eventType == ccui.TouchEventType.ended then
        sender:runAction(cc.ScaleTo:create(0.1, 1, 1))
        if name == "btn_ok" then
            self.processInfo_.info = widget.info
            self.processInfo_.result = 1
            bole.socket:send("deal_club_application", { user_id = tonumber(widget.info.user_id), result = 1 }, true)
        elseif name == "btn_no" then
            bole:popMsg( { msg = "You are about to reject this request.Are you sure?", title = "Request", cancle = true }, function()
                self.processInfo_.info = widget.info
                self.processInfo_.result = 0
                bole.socket:send("deal_club_application", { user_id = tonumber(widget.info.user_id), result = 0 }, true)
            end )
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
          for i = 1, #self.requestList_ do
                if tonumber( self.requestList_[i].user_id )== tonumber(self.processInfo_.info.user_id) then
                    table.remove(self.requestList_ , i)
                    bole:postEvent("dealClubApp", self:isHaveRequest()) 
                    break
                end
          end

        if data.error == 3 then --他没申请
             bole:popMsg({msg="This player don't reque", title = "Request" , cancle = false})
        elseif data.error == 4 then -- 玩家已经加入联盟
            bole:popMsg({msg="This player now is another club’s member", title = "Request" , cancle = false},function()
            self.processInfo_.widget:removeFromParent()
            end)
        elseif data.error == 5 then --俱乐部满员
            bole:popMsg({msg="member num limit", title = "Request" , cancle = false})
        elseif data.error ~= nil then
             bole:popMsg({msg ="error:" .. data.error , title = "error" })
        elseif data.success == 1 then
              if self.processInfo_.result == 1 then
                   self:refreshRequestPanel(self.processInfo_.widget,2)
                   bole:postEvent("addMember", self.processInfo_.info) 
              elseif  self.processInfo_.result == 0 then
                    self:refreshRequestPanel(self.processInfo_.widget,3) 
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
    bole:removeListener("add_f_application_clubRequestLayer", self) 
    bole.socket:unregisterCmd("deal_club_application")
end

return ClubRequestLayer
--endregion
