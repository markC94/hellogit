--region *.lua
--Date
--此文件由[BabeLua]插件自动生成

local ClubTaskInfoLayer = class("ClubTaskInfoLayer", cc.load("mvc").ViewBase)

function ClubTaskInfoLayer:onCreate()
    print("ClubTaskInfoLayer-onCreate")
    local root = self:getCsbNode():getChildByName("root")
    self.topPanel_ = self:getCsbNode():getChildByName("topPanel")
    self.top_ = root:getChildByName("top")
    self.listView_ = root:getChildByName("ListView")
    self.listView_:addEventListener(handler(self, self.scrollViewEvent))

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
    self:initListView()
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
    theme:loadTexture("res/theme_icon/" .. theme_icons[self.taskInfo_.theme_id] .. ".png")

    topBg:getChildByName("title"):setString(self.taskInfo_.titleStr)

    topBg:getChildByName("bar_cell"):setPercent(tonumber(self.taskInfo_.stageAmount) / tonumber(self.taskInfo_.stageTotal) * 100)

    if self.taskInfo_.leave ~= nil then
        topBg:getChildByName("txt_time"):setString("ends in: " .. bole:timeFormat(self.taskInfo_.leave))
        if self.scheduler_ == nil then
            local function update()
                self.taskInfo_.leave = self.taskInfo_.leave - 1
            end
            self.scheduler_ = cc.Director:getInstance():getScheduler():scheduleScriptFunc(update, 1, false)
         end
    else
        topBg:getChildByName("txt_time"):setString("ended")
    end



    if self.taskInfo_.stage == 1 then
        topBg:getChildByName("sp_star1"):getChildByName("sp_star1_no"):setVisible(false)
        topBg:getChildByName("sp_star2"):getChildByName("sp_star2_no"):setVisible(false)
        topBg:getChildByName("sp_star3"):getChildByName("sp_star3_no"):setVisible(false)
    elseif self.taskInfo_.stage == 2 then
        topBg:getChildByName("sp_star2"):getChildByName("sp_star2_no"):setVisible(false)
        topBg:getChildByName("sp_star3"):getChildByName("sp_star3_no"):setVisible(false)
    elseif self.taskInfo_.stage == 3 then
        topBg:getChildByName("sp_star3"):getChildByName("sp_star3_no"):setVisible(false)
        if self.taskInfo_.finish then
            topBg:getChildByName("sp_star3"):getChildByName("sp_star3_no"):setVisible(true)
            topBg:getChildByName("isCom"):setVisible(true)
        else
            topBg:getChildByName("isCom"):setVisible(false)
        end
    end

end

function ClubTaskInfoLayer:initListView()
    self.listView_:removeAllChildren()
    self.topNum_ = # self.showList_
    self.showNum_ = math.min(self.topNum_, 10)
    for i = 1, self.showNum_ do
        local cell = self:createTopPanel(self.showList_[i])
        local topIcon = cell:getChildByName("topIcon")
        local rank = cell:getChildByName("rank")
        if i == 1 then
            topIcon:loadTexture("res/club/goldCrown.png")
            topIcon:setVisible(true)
            rank:setVisible(false)
        elseif i == 2 then
            topIcon:loadTexture("res/club/silverCrown.png")
            topIcon:setVisible(true)
            rank:setVisible(false)
        elseif i == 3 then
            topIcon:loadTexture("res/club/copperCrown.png")
            topIcon:setVisible(true)
            rank:setVisible(false)
        else
            topIcon:setVisible(false)
            rank:setVisible(true)
            rank:setString(i)
        end
        cell:setTag(i)
        self.listView_:addChild(cell)
        cell:setPosition(0, math.max(self.showNum_ * 100,455) - 100 * i)
    end
    self.listView_:setInnerContainerSize(cc.size(970, math.max(self.showNum_ * 100,455)))
    --[[
    local top = 0
    for i = 1, # self.taskInfo_.top do
        top = top + 1
        local cell = self:createTopPanel(self.taskInfo_.top[i])
        local topIcon = cell:getChildByName("topIcon")
        local rank = cell:getChildByName("rank")
        if top == 1 then
            topIcon:loadTexture("res/club/goldCrown.png")
            topIcon:setVisible(true)
            rank:setVisible(false)
        elseif top == 2 then
            topIcon:loadTexture("res/club/silverCrown.png")
            topIcon:setVisible(true)
            rank:setVisible(false)
        elseif top == 3 then
            topIcon:loadTexture("res/club/copperCrown.png")
            topIcon:setVisible(true)
            rank:setVisible(false)
        else
            topIcon:setVisible(false)
            rank:setVisible(true)
            rank:setString(top)
        end

        cell:setTag(i)
        self.listView_:pushBackCustomItem(cell)
    end
    
    for i = 1, # self.usersInfo_ do
        top = top + 1
        local cell = self:createTopAddPanel(self.usersInfo_[i])
        local topIcon = cell:getChildByName("topIcon")
        local rank = cell:getChildByName("rank")
        if top == 1 then
            topIcon:loadTexture("res/club/goldCrown.png")
            topIcon:setVisible(true)
            rank:setVisible(false)
        elseif top == 2 then
            topIcon:loadTexture("res/club/silverCrown.png")
            topIcon:setVisible(true)
            rank:setVisible(false)
        elseif top == 3 then
            topIcon:loadTexture("res/club/copperCrown.png")
            topIcon:setVisible(true)
            rank:setVisible(false)
        else
            topIcon:setVisible(false)
            rank:setVisible(true)
            rank:setString(top)
        end
        self.listView_:pushBackCustomItem(cell)
    end
    --]]
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
            head = bole:getNewHeadView({ user_id = data[1], name = info[1], level = info[2], country = info[3] })
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




   
   --[[
    if data.info ~= nil then
        local head = bole:getNewHeadView(data.info)
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
    else

        local info = require("json").decode(data[3])
        local head = bole:getNewHeadView({ user_id = data[1], name = info[1], level = info[2], country = info[3] })

        head:setScale(0.7)
        head:setSwallow(true)
        head.Img_headbg:setTouchEnabled(false)
        head:updatePos(head.POS_CLUB_REQUEST)
        cell:getChildByName("head"):addChild(head)
        cell:getChildByName("title"):setString("Member")
    end
    
    cell:getChildByName("coins"):setString(bole:formatCoins(tonumber(data[2]), 5))
    --]]
    return cell
end

function ClubTaskInfoLayer:createTopAddPanel(data)
    local cell = self.topPanel_:clone()
    cell:setVisible(true)
    local head = bole:getNewHeadView(data)
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
    return cell
end

function ClubTaskInfoLayer:scrollViewEvent(sender, eventType)
    if eventType == 4 then
        local inner_pos = self.listView_:getInnerContainerPosition()
        local addTop = false
        if inner_pos.y > 50 then
            local addNum = math.min(10, self.topNum_ - self.showNum_)
            for i = self.showNum_ + 1, math.min(self.topNum_, self.showNum_ + 10) do
                self.addPosY_ = inner_pos.y
                addTop = true
                self.showNum_ = self.showNum_ + 1
               
                local cell = self:createTopPanel(self.showList_[i])
                local topIcon = cell:getChildByName("topIcon")
                local rank = cell:getChildByName("rank")
                if i == 1 then
                    topIcon:loadTexture("res/club/goldCrown.png")
                    topIcon:setVisible(true)
                    rank:setVisible(false)
                elseif i == 2 then
                    topIcon:loadTexture("res/club/silverCrown.png")
                    topIcon:setVisible(true)
                    rank:setVisible(false)
                elseif i == 3 then
                    topIcon:loadTexture("res/club/copperCrown.png")
                    topIcon:setVisible(true)
                    rank:setVisible(false)
                else
                    topIcon:setVisible(false)
                    rank:setVisible(true)
                    rank:setString(i)
                end
                cell:setTag(i)
                self.listView_:addChild(cell)
                cell:setPosition(0, math.max(self.showNum_ * 100,455) - 100 * i)
            end

            if addTop then
                local height = math.max(self.showNum_ * 100,455)
                self.listView_:setInnerContainerSize(cc.size(970, height))
                self.listView_:setInnerContainerPosition(cc.p(0, self.addPosY_ - addNum * 100))
                local cellTable = self.listView_:getChildren()
                for i = 1, # cellTable do
                    local cell = cellTable[i]
                    local tag = cell:getTag()
                    cell:setPosition(0, height - 100 * tag)
                end
            end
        end

    end
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
