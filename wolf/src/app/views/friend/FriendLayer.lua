 --region *.lua
--Date
--此文件由[BabeLua]插件自动生成

local FriendLayer = class("FriendLayer", cc.load("mvc").ViewBase)
local defaultShowNum = 24      --默认显示头像数量
local headSpace = 190          --头像间隔
local headSpaceHeight = 165    --头像间隔
local startHeadSpace = 100     --第一列头像位置
local startHeadSpaceHeight = 80     --第一列头像位置

local showMask = 10            --遮罩(加大可滑动长度)
local head_y_1 = 70            --第一排头像y坐标
local head_y_2 = 220           --第二排头像y坐标
local head_y_3 = 370           --第三排头像y坐标
local scrollViewHeight = 440   --滚动列表高
local scrollViewWidth = 1120   --滚动列表宽
local showNextHeadWidth = 100   --分页显示拉动距离

function FriendLayer:onCreate()
    print("FriendLayer:onCreate")
    self.root_ = self:getCsbNode():getChildByName("root")
    self.root_:setVisible(false)
    self.btn_panel_ = self.root_:getChildByName("Panel_btn")
    self.node_View_ = self.root_:getChildByName("Node_View")
    self.friendView_ = self.node_View_:getChildByName("friendView")
    self.friendsList_ = {}

    self:initBtnPanel()
    self:initFriendView()
    self:initTableView()

    self:showFriendView()
    self:setAllBtnTouch(false)
    self:adaptScreen()
    bole.socket:send("sync_friends_info",{},true) 
end

function FriendLayer:onKeyBack()
   self:closeUI()
end

function FriendLayer:onEnter()
    bole.socket:registerCmd("sync_friends_info", self.initFriendInfo, self)
    --bole.socket:registerCmd("send_application", self.reApplication, self)
    bole.socket:registerCmd("get_f_application", self.initRequestInfo, self)
    bole:addListener("addFriend", self.addFriendPanel, self, nil, true)
    bole:addListener("closeFriendLayer", self.closeUI, self, nil, true)     
    bole:addListener("facebook_binding_success", self.showInviteView, self, nil, true)
    bole:addListener("removeFriend", self.removeFriendPanel, self, nil, true)
    bole:addListener("show_f_reminder_friendLayer", self.showReminder, self, nil, true)
    bole:addListener("facebookControlInfo", self.refacebookControlInfo, self, nil, true)
end

function FriendLayer:onExit()
        if self.requestView_ ~= nil then
            self.requestView_:exit()
        end
    bole:removeListener("addFriend", self)
    bole:removeListener("facebook_binding_success", self)
    bole:removeListener("removeFriend", self)
    bole:removeListener("show_f_reminder_friendLayer", self)
    bole:removeListener("facebookControlInfo", self)
    bole:removeListener("closeFriendLayer", self)
    bole.socket:unregisterCmd("get_f_application")
    bole.socket:unregisterCmd("sync_friends_info")
    --bole.socket:unregisterCmd("send_application")
end


function FriendLayer:initFriendInfo(t,data)
    if data.error ~= nil and data.error ~= 0 then
        bole:popMsg({msg ="error: " .. data.error , title = "friend" , cancle = false})
        return
    end
    self.root_:setScale(0.01)
    self.root_:setVisible(true)
    self.root_:runAction(cc.ScaleTo:create(0.2, 1.0))
    self.friendsList_ = bole:getFriendManage():setFriend(data.friends)
    self.headNodeNum_ = math.ceil((# self.friendsList_ + 1 ) / 6)
    self.m_tableView:reloadData()
    self:refrushNoFriendBg()

    self:refreshNewMessage()
    self:setAllBtnTouch(true)
end

function FriendLayer:initBtnPanel()
    self.btn_friend_ = self.btn_panel_:getChildByName("btn_friend")
    self.btn_friend_light_ = self.btn_panel_:getChildByName("btn_friend_light")
    self.btn_friend_light_:setVisible(true)
    self.btn_friend_:addTouchEventListener(handler(self, self.touchEvent))

    self.btn_request_ = self.btn_panel_:getChildByName("btn_request")
    self.btn_request_light_ = self.btn_panel_:getChildByName("btn_request_light")
    self.btn_request_light_:setVisible(false)
    self.btn_request_:addTouchEventListener(handler(self, self.touchEvent))

    self.btn_facebook_ = self.btn_panel_:getChildByName("btn_facebook")
    self.btn_facebook_light_ = self.btn_panel_:getChildByName("btn_facebook_light")
    self.btn_facebook_light_:setVisible(false)
    self.btn_facebook_:addTouchEventListener(handler(self, self.touchEvent))

    self.btn_close_ = self.btn_panel_:getChildByName("btn_close")
    self.btn_close_:addTouchEventListener(handler(self, self.touchEvent))
    self.reminder_ = self.btn_panel_:getChildByName("new_message")
    self.reminder_:setVisible(false)
end


function FriendLayer:initFriendView()
    self.friendViewPanel_ = self.friendView_:getChildByName("viewPanel")
    self.noFriendBg_ = self.friendView_:getChildByName("noF_bg")
    self.noFriendBg_:setVisible(false)
    --self.noFriendBg_:getChildByName("txt"):setString("No Friends")
    self.sliderNode_ = cc.CSLoader:createNode("friend/SliderNode.csb")
    self.sliderNode_:setVisible(false)
    self.friendView_:getChildByName("node_slider"):addChild(self.sliderNode_)
    self.slider_ = self.sliderNode_:getChildByName("root"):getChildByName("slider")
    self.slider_:setPercent(0)
end

function FriendLayer:initTableView()
    self.m_tableView = cc.TableView:create( cc.size(1120, 570) )
    --TabelView添加到PanleMain  
    self.friendViewPanel_:addChild(self.m_tableView)
    --设置滚动方向  
    self.m_tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)      
    --竖直从上往下排列  
    self.m_tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN) 
    --设置代理 
    self.m_tableView:setDelegate() 
    self.headNodeNum_ = 0

    local function scrollViewDidScroll(view)
        
    end

    local function cellSizeForTable(view, idx)
        return 0, 170
    end

    local function tableCellAtIndex(view, idx)
        local index = idx + 1
        local cell = view:dequeueCell()

        local popItem = nil;  
        if nil == cell then  
            cell = cc.TableViewCell:new();  
            --创建列表项  
            local popItem = ccui.Layout:create()
            self:refrushTableView(popItem, index);
            popItem:setContentSize(1120 , 170)
            popItem:setPosition(cc.p(0, 0));  
            popItem:setTag(123);  
            cell:addChild(popItem);  
        else  
            popItem = cell:getChildByTag(123);  
            self:refrushTableView(popItem, index);  
        end  
        return cell
    end

    local function numberOfCellsInTableView(view)
        return self.headNodeNum_
    end

    local function tableCellTouched(view, cell)
        
    end

    self.m_tableView:registerScriptHandler( scrollViewDidScroll,cc.SCROLLVIEW_SCRIPT_SCROLL);           --滚动时的回掉函数  
    self.m_tableView:registerScriptHandler( cellSizeForTable, cc.TABLECELL_SIZE_FOR_INDEX);             --列表项的尺寸  
    self.m_tableView:registerScriptHandler( tableCellAtIndex, cc.TABLECELL_SIZE_AT_INDEX);              --创建列表项  
    self.m_tableView:registerScriptHandler( numberOfCellsInTableView, cc.NUMBER_OF_CELLS_IN_TABLEVIEW); --列表项的数量  
    self.m_tableView:registerScriptHandler( tableCellTouched, cc.TABLECELL_TOUCHED);

    self.m_tableView:reloadData()
    self:refrushNoFriendBg()
end

function FriendLayer:refrushTableView(popItem, index)
    for i = 1, 6 do
        local headNode = popItem:getChildByName("head" .. i)
        if index == 1 and i == 1 then
            local inviteNode = popItem:getChildByName("inviteNode")
            if inviteNode == nil then
                inviteNode = bole:getNewHeadView()
                inviteNode:updatePos(inviteNode.POS_FRIEND_INTIVE)
                inviteNode:setName("inviteNode")
                popItem:addChild(inviteNode)
                inviteNode:setPosition(i * 185 - 100, 90)
            end
            inviteNode:setVisible(true)
            if headNode ~= nil then
                headNode:setVisible(false)
            end
        else
            local data = self.friendsList_[(index - 1) * 6 + i - 1]
            if index ~= 1 then
                local inviteNode = popItem:getChildByName("inviteNode")
                if inviteNode ~= nil then
                    inviteNode:setVisible(false)
                end
            end
            if data == nil then
                if headNode ~= nil then
                    headNode:setVisible(false)
                end 
            else
                if headNode == nil then
                    headNode = bole:getNewHeadView(data)
                    headNode:setSwallow(false)
                    headNode:updatePos(headNode.POS_FRIEND)
                    popItem:addChild(headNode)
                    headNode:setPosition(i * 185 - 100, 90)
                    headNode:setName("head" .. i)
                else
                    headNode:updateInfo(data)
                    headNode.org_over= nil
                    headNode.org_start = nil
                    headNode:setScale(1)
                end
                headNode:setVisible(true)
            end
        end
    end
end


function FriendLayer:refreshNewMessage()
    if bole:getFriendManage():isShowRem() then
        self.reminder_:setVisible(true)
    end
end


function FriendLayer:addFriendPanel(data)
    self.headNodeNum_ = math.ceil((# self.friendsList_ + 1 ) / 6)
    self.m_tableView:reloadData()
    self:refrushNoFriendBg()
end

function FriendLayer:removeFriendPanel(data) 
    bole:postEvent("closeInformationView")
    data = data.result
    local posY = self.m_tableView:getContentOffset().y
    self.headNodeNum_ = math.ceil((# self.friendsList_ + 1 ) / 6)
    self.m_tableView:reloadData()
    self:refrushNoFriendBg()
    self.m_tableView:setContentOffset(cc.p(0,posY))
end

--[[
function FriendLayer:reApplication(t,data)
    if t == "send_application" then
        if self.applicationsList_ == nil then
            self.applicationsList_ = {}
        end
        bole:getFriendManage():addAppLication(data)
    end
end
--]]

function FriendLayer:addApplication(data)
    data = data.result
    bole:getFriendManage():addAppLication(data)
end

function FriendLayer:touchEvent(sender, eventType)
    local name = sender:getName()
    if eventType == ccui.TouchEventType.began then
        --sender:runAction(cc.ScaleTo:create(0.1, 1.05, 1.05))
    elseif eventType == ccui.TouchEventType.moved then

    elseif eventType == ccui.TouchEventType.ended then
        --sender:runAction(cc.ScaleTo:create(0.1, 1, 1))
        if name == "btn_close" then
            self:closeUI()
        elseif name == "btn_request" then
            self:showRequestView()
        elseif name == "btn_facebook" then
            self:showInviteView()
        elseif name == "btn_friend" then
            self:showFriendView()
        end
    elseif eventType == ccui.TouchEventType.canceled then
        --sender:runAction(cc.ScaleTo:create(0.1, 1, 1))
    end
end

function FriendLayer:initRequestInfo(t,data)
    self.applicationsList_ = bole:getFriendManage():setApplication(data.f_applications)
    bole:postEvent("initFriendRequestInfo",self.applicationsList_)
end

function FriendLayer:showRequestView()
    self:refrushButton("request")
    bole:getFriendManage():setIsShowRem(false)
    if self.requestView_ == nil then
        self.requestView_ = bole:getUIManage():createNewUI("FriendRequestLayer","friend","app.views.friend",nil,false)
        --bole:getUIManage():getSimpleLayer("FriendRequestLayer",false,"friend")
        self.node_View_:addChild(self.requestView_)
        self.requestView_:setPosition(0,0)
    end
    self.requestView_:enterLayer()
    self.requestView_:setVisible(true)
    bole.socket:send("get_f_application",{},true) 
    if self.friendView_ ~= nil then
        self.friendView_:setVisible(false)
    end
    if self.facebookView_ ~= nil then
        self.facebookView_:setVisible(false)
    end
end

function FriendLayer:showInviteView()
    --self:refrushButton("facebook")
    print(bole:getFacebookCenter():isLogin())
    print(bole:getFacebookCenter().fbId)

    --bole:getFacebookCenter():bindFacebook()

    
    --if bole:getFacebookCenter().fbId ~= nil then
         self:refrushButton("facebook")
        if self.facebookView_ == nil then
            self.facebookView_ = bole:getUIManage():createNewUI("FriendInvietLayer","friend","app.views.friend",nil,false)
            self.node_View_:addChild(self.facebookView_)
            self.facebookView_:setPosition(0,0)
        end
        self.facebookView_:setVisible(true)
        if self.friendView_ ~= nil then
            self.friendView_:setVisible(false)
        end
        if self.requestView_ ~= nil then
            self.requestView_:setVisible(false)
        end
        if self.requestView_ ~= nil then
            self.requestView_:exit()
        end
        if self.reminder_:isVisible() then
            self.reminder_:setVisible(false)
        end

   --end

end

function FriendLayer:showFriendView()
    self:refrushButton("friend")
    if self.friendView_ == nil then
        self.friendView_ = bole:getUIManage():getSimpleLayer("FriendLayer",false,"friend")
        self.friendView_:setPosition(0,0)
        self.node_View_:addChild(self.friendView_)
    end
    self.friendView_:setVisible(true)
    bole:postEvent("initFrirndList", self.friendsList_)
    if self.facebookView_ ~= nil then
        self.facebookView_:setVisible(false)
    end
    if self.requestView_ ~= nil then
        self.requestView_:setVisible(false)
    end
     if self.reminder_:isVisible() then
        self.reminder_:setVisible(false)
    end
        if self.requestView_ ~= nil then
            self.requestView_:exit()
        end
end


function FriendLayer:showReminder(data)
    data = data.result
    
    if self.requestView_ ~= nil then
        if  self.requestView_:isVisible() then
            bole:postEvent("show_f_reminder_lobbyScene",false)
            return
        end
    end

    self.reminder_:setVisible(data)
end

function FriendLayer:refrushButton(str)
    self.btn_panel_:getChildByName("btn_facebook"):setTouchEnabled(true)
    self.btn_panel_:getChildByName("btn_request"):setTouchEnabled(true)
    self.btn_panel_:getChildByName("btn_friend"):setTouchEnabled(true)

    self.btn_panel_:getChildByName("btn_facebook_light"):setVisible(false)
    self.btn_panel_:getChildByName("btn_request_light"):setVisible(false)
    self.btn_panel_:getChildByName("btn_friend_light"):setVisible(false)

    self.btn_panel_:getChildByName("btn_" .. str):setTouchEnabled(false)
    self.btn_panel_:getChildByName("btn_" .. str .. "_light"):setVisible(true)
end

function FriendLayer:refrushNoFriendBg()
    if # self.friendsList_ <= 0 then
        self.noFriendBg_:setVisible(true)
        self.m_tableView:setTouchEnabled(false)
    else
        self.noFriendBg_:setVisible(false)
        self.m_tableView:setTouchEnabled(true)
    end
end

function FriendLayer:setAllBtnTouch(isTouch)
   self.btn_friend_:setTouchEnabled(isTouch)
    self.btn_request_:setTouchEnabled(isTouch)
    self.btn_facebook_:setTouchEnabled(isTouch)
end

function FriendLayer:refacebookControlInfo(data)
    data = data.result
    if data.name == "onLogin" then
        if data.isLoggedIn == false then
            bole:popMsg({msg ="facebook login error" , title = "facebook", cancle = false })
        end
    end
end

function FriendLayer:adaptScreen()
    local winSize = cc.Director:getInstance():getWinSize()
    self:setPosition(0,0)
    self.root_:setPosition(winSize.width / 2, winSize.height / 2)
end

return FriendLayer
--endregion
