--region *.lua
--Date
--此文件由[BabeLua]插件自动生成
--0126
local ClubTaskInfoLayer = class("ClubTaskInfoLayer", cc.load("mvc").ViewBase)

function ClubTaskInfoLayer:onCreate()
    print("ClubTaskInfoLayer-onCreate")
    local root = self:getCsbNode():getChildByName("root")
    self.root_ = root
    self.topPanel_ = self:getCsbNode():getChildByName("topPanel")
    self.topPanel_:setVisible(true)

    self.top_ = root:getChildByName("top")
    self.tableView_panel_ = root:getChildByName("ListView1")

    local btn_close = root:getChildByName("btn_close")
    btn_close:addTouchEventListener(handler(self, self.touchEvent))


    self:adaptScreen()
end

function ClubTaskInfoLayer:onEnter()
   bole:addListener("initClubTaskInfoLayer", self.initClubTaskInfoLayer, self, nil, true)
end

function ClubTaskInfoLayer:initClubTaskInfoLayer(data)
    data = data.result
    self.taskInfo_ = {}
    for k ,v in pairs(data.task) do
        self.taskInfo_[k] = v
    end

    self.usersInfo_ = {}
    for i = 1, #data.users do
        self.usersInfo_[i] = data.users[i]
    end
    self:initShowInfo()
    self:initTop()
    self:initTableView()
end

function ClubTaskInfoLayer:initShowInfo()
    self.showList_ = {}
    for i = 1, #self.taskInfo_.top do
        self.showList_[i] = self.taskInfo_.top[i]
        for j = 1, # self.usersInfo_ do
            if tonumber(self.taskInfo_.top[i][1]) == tonumber(self.usersInfo_[j].user_id) then
                table.remove(self.usersInfo_,j)
                break
            end
        end
    end
    if # self.usersInfo_ ~= 0 then
        table.sort(self.usersInfo_, function(a,b) return a.level > b.level end)
    end

    for i = 1, # self.usersInfo_ do
        table.insert(self.showList_ ,# self.showList_ + 1, self.usersInfo_[i])
    end

end


function ClubTaskInfoLayer:initTop()
    local topBg = self.top_:getChildByName("topBg")
    local theme_icons = { "oz_icon", "farm_icon", "elvis_icon","dragon_icon","sea_icon","chilli_icon","temple_icon" }
    local theme = topBg:getChildByName("theme")
    theme:loadTexture("theme_icon/" .. theme_icons[self.taskInfo_.theme_id] .. ".png")

    local num_coins = topBg:getChildByName("num_coins")
    num_coins:setString(bole:formatCoins(self.taskInfo_.stageTotal,25))
    local posX = num_coins:getPositionX() + num_coins:getContentSize().width + 8
    topBg:getChildByName("txt3"):setPosition(posX,146)

    topBg:getChildByName("slider"):setPercent(tonumber(self.taskInfo_.amount) / tonumber(self.taskInfo_.total) * 100)

    self.timeEnd_ = topBg:getChildByName("time_bg") 
    self.unit_1 = self.timeEnd_:getChildByName("panel_time"):getChildByName("time_1") 
    self.unit_2 = self.timeEnd_:getChildByName("panel_time"):getChildByName("time_2") 
    self.time_1 = self.timeEnd_:getChildByName("panel_time"):getChildByName("time_m") 
    self.time_2 = self.timeEnd_:getChildByName("panel_time"):getChildByName("time_s") 
    local clockAct = sp.SkeletonAnimation:create("shop_act/biao_1.json", "shop_act/biao_1.atlas")
    clockAct:setScale(0.42)
    clockAct:setAnimation(0, "animation", true)
    self.timeEnd_:getChildByName("panel_time"):getChildByName("node_act"):addChild(clockAct)
    self.timeEnd_:getChildByName("panel_end"):setVisible(false)
    if self.taskInfo_.leave ~= nil then
        --topBg:getChildByName("txt_time"):setString("ends in: " .. bole:timeFormat(self.taskInfo_.leave))
        self:setTime(self.taskInfo_.leave)
        if self.scheduler_ == nil then
            local function update()
                self:setTime(self.taskInfo_.leave)
                self.taskInfo_.leave = self.taskInfo_.leave - 1
            end
            self.scheduler_ = cc.Director:getInstance():getScheduler():scheduleScriptFunc(update, 1, false)
         end
    else
        self.timeEnd_:getChildByName("panel_time"):setVisible(false)
        self.timeEnd_:getChildByName("panel_end"):setVisible(true)
        if self.scheduler_ then
            cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.scheduler_)
            self.scheduler_ = nil
        end
    end

    if self.taskInfo_.stage == 1 then
        topBg:getChildByName("panel_star"):getChildByName("star_1"):setVisible(false)
        topBg:getChildByName("panel_star"):getChildByName("star_2"):setVisible(false)
        topBg:getChildByName("panel_star"):getChildByName("star_3"):setVisible(false)
    elseif self.taskInfo_.stage == 2 then
        topBg:getChildByName("panel_star"):getChildByName("star_2"):setVisible(false)
        topBg:getChildByName("panel_star"):getChildByName("star_3"):setVisible(false)
    elseif self.taskInfo_.stage == 3 then
        topBg:getChildByName("panel_star"):getChildByName("star_3"):setVisible(false)
        if self.taskInfo_.finish then
            topBg:getChildByName("panel_star"):getChildByName("star_3"):setVisible(true)
            theme:getChildByName("com"):setVisible(true)
        else
            theme:getChildByName("com"):setVisible(false)
        end
    end

    self.barlight_ = cc.Sprite:create("loadImage/club_event_info_progressba_light.png")  
    local clipNode = cc.ClippingNode:create()
    clipNode:setAnchorPoint(0.5,0.5)
    clipNode:setAlphaThreshold(0)
    clipNode:setStencil(cc.Sprite:create("loadImage/club_event_info_progressba.png"))
    topBg:getChildByName("slider_top"):addChild(clipNode)  
    clipNode:addChild(self.barlight_)
    self.barlight_:setAnchorPoint(1,0.5)
    self.barlight_:setPosition(tonumber(self.taskInfo_.amount) / tonumber(self.taskInfo_.total) * 672 - 336,0)
end

function ClubTaskInfoLayer:setTime(time)
    if time > 0 then
        local s = math.floor(time) % 60
        local m = math.floor(time / 60) % 60
        local h = math.floor(time / 3600) % 24

        if h == 0 then
            self.unit_1:setString("M")
            self.unit_2:setString("S")
            self.time_1:setString(m)
            self.time_2:setString(s)
        else
            self.unit_1:setString("H")
            self.unit_2:setString("M")
            self.time_1:setString(h)
            self.time_2:setString(m)
        end
    else
        self.timeEnd_:getChildByName("panel_time"):setVisible(false)
        self.timeEnd_:getChildByName("panel_end"):setVisible(true)
        if self.scheduler_ then
            cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.scheduler_)
            self.scheduler_ = nil
        end
    end
end

function ClubTaskInfoLayer:initTableView()
    self.m_tableView = cc.TableView:create( cc.size(940, 385))
    --TabelView添加到PanleMain  
    self.tableView_panel_:addChild(self.m_tableView);  
    --self.m_tableView:setPosition(0 , 0);  
    --设置滚动方向  
    self.m_tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)      
    --竖直从上往下排列  
    self.m_tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN);  
    --设置代理  
    self.m_tableView:setDelegate();  

    self.m_tableView:registerScriptHandler( handler(self, self.scrollViewDidScroll),cc.SCROLLVIEW_SCRIPT_SCROLL);           --滚动时的回掉函数  
    self.m_tableView:registerScriptHandler( handler(self, self.cellSizeForTable), cc.TABLECELL_SIZE_FOR_INDEX);             --列表项的尺寸  
    self.m_tableView:registerScriptHandler( handler(self, self.tableCellAtIndex), cc.TABLECELL_SIZE_AT_INDEX);              --创建列表项  
    self.m_tableView:registerScriptHandler( handler(self, self.numberOfCellsInTableView), cc.NUMBER_OF_CELLS_IN_TABLEVIEW); --列表项的数量  
    self.m_tableView:registerScriptHandler( handler(self, self.tableCellTouched), cc.TABLECELL_TOUCHED);

    self.m_tableView:reloadData()
end

function ClubTaskInfoLayer:tableCellTouched(view, cell)
    
end

function ClubTaskInfoLayer:scrollViewDidScroll(view)
    
end

function ClubTaskInfoLayer:cellSizeForTable(view, idx)
    return 0, 100
end

function ClubTaskInfoLayer:numberOfCellsInTableView(view)
    return  # self.showList_
end

function ClubTaskInfoLayer:tableCellAtIndex(view, idx)
    local index = idx + 1
    local cell = view:dequeueCell()

    local popItem = nil;  
    if nil == cell then  
        cell = cc.TableViewCell:new();  
        --创建列表项  
        local popItem = self.topPanel_:clone(); 
        self.topPanel_:setVisible(true)
        self:refrushTopView(popItem, index) 
        popItem:setPosition(cc.p(0, 0));  
        popItem:setTag(123);  
        cell:addChild(popItem);  
    else  
        popItem = cell:getChildByTag(123);  
        self:refrushTopView(popItem, index);  
    end  
    return cell
end

function ClubTaskInfoLayer:refrushTopView(popItem, index)
    local headPanel = popItem:getChildByName("head")
    local headNode = headPanel:getChildByName("headNode")
    local rank = popItem:getChildByName("rank")
    local topIcon = popItem:getChildByName("topIcon")
    local coins = popItem:getChildByName("coins")
    local title = popItem:getChildByName("title")
    rank:setString(index)

    local data = self.showList_[index]
    local userData = nil
    local titleType = 3
    if data.club_title == nil then
        if data.info ~= nil then
            userData = data.info
            titleType = data.info.club_title
        else
            userData = { user_id = data[1], name = info[1], icon = info[2] , level = info[3], country = info[4] }
        end
        coins:setString(bole:formatCoins(tonumber(data[2]), 5))
    else
        userData = data
        titleType = data.club_title
        coins:setString(0)
    end

    if headNode == nil then
        print(index .. " noheadNode")
        local headNode = bole:getNewHeadView(userData)
        headNode:setScale(0.7)
        headNode:setSwallow(true)
        headNode:updatePos(headNode.POS_CLUB_TASKINFO)
        headPanel:addChild(headNode)
        headNode:setName("headNode")
    else
        headNode:updateInfo(userData)
    end

    if index == 1 then
        if not topIcon:isVisible() then
            topIcon:loadTexture("loadImage/crown_gold.png")
            topIcon:setVisible(true)
            rank:setVisible(false)
        end
    elseif index == 2 then
        if not topIcon:isVisible() then
            topIcon:loadTexture("loadImage/crown_silver.png")
            topIcon:setVisible(true)
            rank:setVisible(false)
        end
    elseif index == 3 then
        if not topIcon:isVisible() then
            topIcon:loadTexture("loadImage/crown_copper.png")
            topIcon:setVisible(true)
            rank:setVisible(false)
        end
    else
        if not rank:isVisible() then
            topIcon:setVisible(false)
            rank:setVisible(true)
        end
    end

    if titleType == 1 then
        title:setString("Leader")
        --title:setTextColor( { r = 204, g = 152, b = 127 })
    elseif titleType == 3 or titleType == 0 then
        title:setString("Member")
        --title:setTextColor( { r = 39, g = 174, b = 23 })
    elseif titleType == 2 then
        title:setString("Co_leader")
        --title:setTextColor( { r = 52, g = 189, b = 255 })
    end

    if index % 2 == 1 then
        popItem:getChildByName("bg1"):setVisible(true)
        popItem:getChildByName("bg2"):setVisible(false)
    else
        popItem:getChildByName("bg1"):setVisible(false)
        popItem:getChildByName("bg2"):setVisible(true)
    end

    if userData.user_id == bole:getUserDataByKey("user_id") then
        popItem:getChildByName("bg3"):setVisible(true)
    else
        popItem:getChildByName("bg3"):setVisible(false)
    end
end

function ClubTaskInfoLayer:createTopPanel(data)
    local cell = self.topPanel_:clone()
    cell:setVisible(true)
    
    local head = nil
    if data.club_title == nil then
        if data.info ~= nil then
            head = bole:getNewHeadView(data.info)
            head:setScale(0.7)
            head:setSwallow(true)
            head.Img_headbg:setTouchEnabled(false)
            head:updatePos(head.POS_CLUB_REQUEST)
            cell:getChildByName("head"):addChild(head)

            if tonumber(data.info.club_title) == 1 then
                cell:getChildByName("title"):setString("Leader")
                cell:getChildByName("title"):setTextColor({ r = 204, g = 152, b = 127})
                cell.club_title = 1
            elseif tonumber(data.info.club_title) == 3 or tonumber(data.info.club_title) == 0 then
                cell:getChildByName("title"):setString("Member")
                cell:getChildByName("title"):setTextColor( { r = 39, g = 174, b = 23 })
                cell.club_title = 3
            elseif tonumber(data.info.club_title) == 2 then
                cell:getChildByName("title"):setString("Co_leader")
                cell:getChildByName("title"):setTextColor( { r = 52, g = 189, b = 255 })
                cell.club_title = 2
            end
            cell:getChildByName("coins"):setString(bole:formatCoins(tonumber(data[2]), 5))
        else
            local info = require("json").decode(data[3])
            head = bole:getNewHeadView({ user_id = data[1], name = info[1], icon = info[2] , level = info[3], country = info[4] })
            head:setScale(0.7)
            head:setSwallow(true)
            head.Img_headbg:setTouchEnabled(false)
            head:updatePos(head.POS_CLUB_REQUEST)
            cell:getChildByName("head"):addChild(head)
            cell:getChildByName("title"):setString("Member")
            cell:getChildByName("coins"):setString(bole:formatCoins(tonumber(data[2]), 5))
        end
    else
            head = bole:getNewHeadView(data)
            head:setScale(0.7)
            head:setSwallow(true)
            head.Img_headbg:setTouchEnabled(false)
            head:updatePos(head.POS_CLUB_REQUEST)
            cell:getChildByName("head"):addChild(head)

            if tonumber(data.club_title) == 1 then
                cell:getChildByName("title"):setString("Leader")
                cell:getChildByName("title"):setTextColor({ r = 204, g = 152, b = 127})
                cell.club_title = 1
            elseif tonumber(data.club_title) == 3 or tonumber(data.club_title) == 0 then
                cell:getChildByName("title"):setString("Member")
                cell:getChildByName("title"):setTextColor( { r = 39, g = 174, b = 23 })
                cell.club_title = 3
            elseif tonumber(data.club_title) == 2 then
                cell:getChildByName("title"):setString("Co_leader")
                cell:getChildByName("title"):setTextColor( { r = 52, g = 189, b = 255 })
                cell.club_title = 2
            end
            cell:getChildByName("coins"):setString(0)

    end

    return cell
end

function ClubTaskInfoLayer:touchEvent(sender, eventType)
    local name = sender:getName()
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



function ClubTaskInfoLayer:onExit()
    bole:removeListener("initClubTaskInfoLayer", self)
    if self.scheduler_ then
        print("remove scheduler --------------------------------------------------------")
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.scheduler_)
        self.scheduler_ = nil
    end
end

function ClubTaskInfoLayer:adaptScreen()

end

return ClubTaskInfoLayer

--endregion
