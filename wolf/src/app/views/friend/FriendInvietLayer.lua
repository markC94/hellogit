--region *.lua
--Date
--此文件由[BabeLua]插件自动生成

local FriendInvietLayer = class("FriendInvietLayer", cc.load("mvc").ViewBase)
FriendInvietLayer.MaxInputLenght = 20

function FriendInvietLayer:onCreate()
    print("FriendInvietLayer:onCreate")

    self.facebookCenter_ = bole:getFacebookCenter()        
    self.friendPanel_ = self:getCsbNode():getChildByName("freind")
    self.friendPanel_:getChildByName("CheckBox"):addTouchEventListener(handler(self, self.checkBoxEvent))

    self.facebookView_ = self:getCsbNode():getChildByName("facebookView")
    self.fbFriendIdList_ = {}
    self:initFacebookView()
    self:initTableView()

    self:refreshFacebookView()
end


function FriendInvietLayer:onEnter()
    bole:addListener("refreshFBFriendView", self.refreshFBFriendView, self, nil, true)
end

function FriendInvietLayer:onExit()
    bole:removeListener("refreshFBFriendView", self)
end

function FriendInvietLayer:initFacebookView()
    self.scrollViewMask_ = self.facebookView_:getChildByName("mask") 
    self.scrollViewMask_:setVisible(false)
    
    self.fbFriendViewPanel_ = self.facebookView_:getChildByName("viewPanel") 

    self.noFriendBg_ = self.facebookView_:getChildByName("noF_bg")
    self.noFriendBg_:setVisible(true)
    self.noFriendBg_:getChildByName("txt_1"):setPosition(-335, 140)   --200
    self.sliderNode_ = cc.CSLoader:createNode("friend/SliderNode.csb")
    self.facebookView_:getChildByName("node_slider"):addChild(self.sliderNode_)
    self.sliderNode_:setVisible(false)
    self.slider_ = self.sliderNode_:getChildByName("root"):getChildByName("slider")
    self.slider_:setPercent(0)

    self.bg_bottom_ = self.facebookView_:getChildByName("bg_bottom")  
    local btn_send = self.bg_bottom_:getChildByName("btn_send")
    btn_send:addTouchEventListener(handler(self, self.touchEvent))
    local checkBox = self.bg_bottom_:getChildByName("input"):getChildByName("CheckBox_all")
    checkBox:addTouchEventListener(handler(self, self.checkBoxEvent))
    self.bg_bottom_:setVisible(false)
    
    self.btn_connctFB_ = self.facebookView_:getChildByName("btn_connctFB")  
    self.btn_connctFB_:addTouchEventListener(handler(self, self.touchEvent))
    self.btn_connctFB_:setVisible(true)

    self.fb_title_ = self.facebookView_:getChildByName("facebook_bg"):getChildByName("fb_title")  
    self.fb_title_:getChildByName("panel_no_fb"):setVisible(true)
    self.fb_title_:getChildByName("panel_fb"):setVisible(false)

end

function FriendInvietLayer:initTableView()
    self.m_tableView = cc.TableView:create( cc.size(1130.00, 380.00) )
    --TabelView添加到PanleMain  
    self.fbFriendViewPanel_:addChild(self.m_tableView)
    --设置滚动方向  
    self.m_tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)      
    --竖直从上往下排列  
    self.m_tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN) 
    --设置代理  
    self.m_tableView:setDelegate() 
    self.tableCellNum_  = 0

    local function scrollViewDidScroll(view)
        self.tableViewScroll_ = true
    end

    local function cellSizeForTable(view, idx)
        return 0, 150
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
            popItem:setContentSize(1130 , 150)
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
        return self.tableCellNum_
    end

    local function tableCellTouched(view, cell)
        
    end

    self.m_tableView:registerScriptHandler( scrollViewDidScroll,cc.SCROLLVIEW_SCRIPT_SCROLL);           --滚动时的回掉函数  
    self.m_tableView:registerScriptHandler( cellSizeForTable, cc.TABLECELL_SIZE_FOR_INDEX);             --列表项的尺寸  
    self.m_tableView:registerScriptHandler( tableCellAtIndex, cc.TABLECELL_SIZE_AT_INDEX);              --创建列表项  
    self.m_tableView:registerScriptHandler( numberOfCellsInTableView, cc.NUMBER_OF_CELLS_IN_TABLEVIEW); --列表项的数量  
    self.m_tableView:registerScriptHandler( tableCellTouched, cc.TABLECELL_TOUCHED);

    self.m_tableView:reloadData()
end

function FriendInvietLayer:refrushTableView(item,index)
    for i = 1, 5 do
        local friendCell = item:getChildByName("friendCell" .. i)
        local data = self.fbFriendInfo_[(index - 1) * 5 + i]
        if data == nil then
            if friendCell ~= nil then
                friendCell:setVisible(false)
            end
        else
            if friendCell == nil then
                friendCell = self:refurshFriendCell(friendCell,data)
                item:addChild(friendCell)
                friendCell:setName("friendCell" .. i)
                friendCell:setPosition((i - 1) * 230 + 10, 20)
            else
                self:refurshFriendCell(friendCell,data)
            end
            friendCell:setVisible(true)
        end
    end

end

function FriendInvietLayer:refurshFriendCell(cell,data)
    local headData = { name = data.name ,head_url = data.pictureUrl}
    if cell == nil then
        cell = self.friendPanel_:clone()
        local head = bole:getNewHeadView(headData)
        head:setScale(0.95)
        head.Img_headbg:setTouchEnabled(false)
        head:updatePos(head.POS_FB_FRIEND)
        head:setSwallow(false)
        head:setName("headNode")
        cell:getChildByName("head"):addChild(head)
    else
        cell:getChildByName("head"):getChildByName("headNode"):updateInfo(headData)
    end
    cell:setVisible(true)
    cell.id = data.id
    cell:getChildByName("CheckBox"):setSelected(false)
    --dump(self.fbFriendIdList_,"self.fbFriendIdList_")
    if self.fbFriendIdList_[data.id] ~= nil then
        if self.fbFriendIdList_[data.id] == 1 then
            cell:getChildByName("CheckBox"):setSelected(true)
        end
    end
    return cell
end

function FriendInvietLayer:refreshFacebookView()
    self.fbFriendViewPanel_:setVisible(false)
    self.scrollViewMask_:setVisible(false)
    self.fb_title_:getChildByName("panel_no_fb"):setVisible(true)
    self.fb_title_:getChildByName("panel_fb"):setVisible(false)
    self.btn_connctFB_:setVisible(true)
    self.noFriendBg_:setVisible(true)
    self.noFriendBg_:getChildByName("txt_1"):setPosition(-335, 140)
    self.bg_bottom_:setVisible(false)

    --已经绑定fb 
    if self.facebookCenter_.fbId ~= nil then
        self.fb_title_:getChildByName("panel_no_fb"):setVisible(false)
        self.fb_title_:getChildByName("panel_fb"):setVisible(true)  
        self.btn_connctFB_:setVisible(false)  
        self.noFriendBg_:getChildByName("txt_1"):setPosition(-335, 200)
        self.noFriendBg_:getChildByName("txt_1"):setString("You have no Facebook friends yet.")
    end
    bole:getFacebookCenter():getInvitableFriends(function(data) self:refreshInvitaInfo(data)  end)
    self:refreshInvitaInfo(data)
end

function FriendInvietLayer:refreshInvitaInfo(data)
    self.fbFriendInfo_ = data or {}
    --[[
    for i = 1, 51 do
        table.insert(self.fbFriendInfo_,{ name = "123123123" ,head_url = "1321213" , id = i })
    end
    --]]
    dump(self.fbFriendInfo_,"self.fbFriendInfo_")
    if self.fbFriendInfo_ ~= nil then
        self.tableCellNum_ = math.ceil( # self.fbFriendInfo_ / 5 )
        for k ,v in pairs(self.fbFriendInfo_) do
            self.fbFriendIdList_[v.id] = 0
        end
        if # self.fbFriendInfo_ ~= 0 then
            self.fb_title_:getChildByName("panel_no_fb"):setVisible(false)
            self.fb_title_:getChildByName("panel_fb"):setVisible(true)  
            self.btn_connctFB_:setVisible(false)  
            self.noFriendBg_:getChildByName("txt_1"):setPosition(-335, 200)
            self.fbFriendViewPanel_:setVisible(true)
            self.scrollViewMask_:setVisible(true)
            self.noFriendBg_:setVisible(false)
            self.bg_bottom_:setVisible(true)
        end
    end
    self.m_tableView:reloadData()
end

function FriendInvietLayer:touchEvent(sender, eventType)
    local name = sender:getName()
    if eventType == ccui.TouchEventType.began then
        sender:runAction(cc.ScaleTo:create(0.1, 1.05, 1.05))
    elseif eventType == ccui.TouchEventType.moved then

    elseif eventType == ccui.TouchEventType.ended then
        sender:runAction(cc.ScaleTo:create(0.1, 1, 1))
        if name == "btn_close" then
            self:closeUI()
        elseif name == "btn_send" then
            self:send()
        elseif name == "btn_search" then
            self:searchId()
            print("btn_search")
        elseif name == "btn_input_close" then
            print("btn_input_close")
        elseif name == "btn_connctFB" then
            bole:getFacebookCenter():bindFacebook()
        end
    elseif eventType == ccui.TouchEventType.canceled then
        sender:runAction(cc.ScaleTo:create(0.1, 1, 1))
    end
end

function FriendInvietLayer:refreshFBFriendView()
    self.fb_title_:getChildByName("panel_no_fb"):setVisible(false)
    self.fb_title_:getChildByName("panel_fb"):setVisible(true)  
    self.btn_connctFB_:setVisible(false)  
    self.noFriendBg_:getChildByName("txt_1"):setPosition(-335, 200)
    bole:getFacebookCenter():getInvitableFriends(function(data) self:refreshInvitaInfo(data)  end)
    bole:popMsg({msg = "connect Facebook success", title = "success", cancle = false})
end

function FriendInvietLayer:checkBoxEvent(sender,eventType)
    local name = sender:getName()
    if eventType == ccui.TouchEventType.began then

    elseif eventType == ccui.TouchEventType.moved then

    elseif eventType == ccui.TouchEventType.ended then
        local isSelected = sender:isSelected()
        if name == "CheckBox_all" then
            local posY = self.m_tableView:getContentOffset().y
            self:setFbFreindChoose(isSelected)
            self.m_tableView:reloadData()
            self.m_tableView:setContentOffset(cc.p(0,posY))
        else
            sender:setSelected(isSelected)
            print(sender:getParent().id)
            self:setFbFreindChoose(isSelected,sender:getParent().id)
        end
    elseif eventType == ccui.TouchEventType.canceled then
        sender:setSelected(not sender:isSelected())
    end
end

function FriendInvietLayer:setFbFreindChoose(bool,id)
    if id == nil then
        if bool then  
            for k ,v in pairs(self.fbFriendIdList_) do
                self.fbFriendIdList_[k] = 1
            end
        else
            for k ,v in pairs(self.fbFriendIdList_) do
                self.fbFriendIdList_[k] = 0
            end
        end
    else
        if bool then
            self.fbFriendIdList_[id] = 1
        else
            self.fbFriendIdList_[id] = 0
        end
    end
end

function FriendInvietLayer:send()

    local inviteId = {}

    for k , v in pairs(self.fbFriendIdList_) do
        if self.fbFriendIdList_[k] == 1 then
            table.insert(inviteId ,k)
        end
    end
    dump(inviteId,"inviteId")

    bole:getFacebookCenter():inviteOneFriend(inviteId)
end

function FriendInvietLayer:adaptScreen()
    local winSize = cc.Director:getInstance():getWinSize()
    self:setPosition(0,0)
    self.root_:setPosition(winSize.width / 2, winSize.height / 2)
    self.root_:setScale(0.1)
    self.root_:runAction(cc.ScaleTo:create(0.2,1,1))
end


return FriendInvietLayer
--endregion
