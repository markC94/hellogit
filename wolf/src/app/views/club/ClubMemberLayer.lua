--region *.lua
--Date
--此文件由[BabeLua]插件自动生成

local ClubMemberLayer = class("ClubMemberLayer", cc.load("mvc").ViewBase)

function ClubMemberLayer:onCreate()
    self.root_ =  self:getCsbNode():getChildByName("root")
    self.member_ =  self:getCsbNode():getChildByName("Panel_member")
    self.member_:addTouchEventListener(handler(self, self.memberTouchEvent))
    self.memberfunc_ = self:getCsbNode():getChildByName("Panel_func")
    self.memberfunc_:addTouchEventListener(handler(self, self.memberTouchEvent))
    self.memberfunc_:setVisible(false)

    self.top_ = self.root_:getChildByName("top")
    self.scrollView_ = self.root_:getChildByName("ScrollView")
    self.scrollView_:addEventListener(handler(self, self.scrollViewEvent))
    self.scrollView_:setScrollBarOpacity(0)

    self.slider_ = self.root_:getChildByName("Slider")

    --self:initTop()
    --self:initScrollView()

end

function ClubMemberLayer:onEnter()
    bole:addListener("initMemberInfo", self.initMemberInfo, self, nil, true)
    bole:addListener("initAdaptPos", self.adaptScreen, self, nil, false)
    bole:addListener("addMemberPanel", self.addMemberPanel, self, nil, true)
    bole.socket:registerCmd("accredit_club_member", self.accredit_club_member, self)
    bole.socket:registerCmd("demote_club_member", self.demote_club_member, self)
    bole.socket:registerCmd("kick_out_member", self.kick_out_member, self)
end

function ClubMemberLayer:initMemberInfo(data)
    self:initTop(data.result)
    self.clubMemberList_ = data.result.users
    self.topMember_ = {}
    for i = 1, 3 do
        if data.result.rewards[1].top[i] ~= nil then
            self.topMember_[i] = data.result.rewards[1].top[i]
        end
    end
    self:initScrollView(self.clubMemberList_)
    --dump(self.clubMemberList_,"clubMember")
end


function ClubMemberLayer:initTop(data)
    local str,id = bole:getClubIconStr()
    self.top_:getChildByName("icon"):loadTexture(str)
    self.top_:getChildByName("Image_bg_1"):getChildByName("Text_1"):setString(# data.users)
    self.top_:getChildByName("Image_bg_1"):getChildByName("Text_2"):setString(data.max_u_count)
    self.top_:getChildByName("Button_1"):addTouchEventListener(handler(self, self.touchEvent))
    self.info1_ =  self.top_:getChildByName("Button_1"):getChildByName("info")

    self.top_:getChildByName("Image_bg_2"):getChildByName("Text_1"):setString(bole:formatCoins(tonumber(data.exp),5))
    self.top_:getChildByName("Button_2"):addTouchEventListener(handler(self, self.touchEvent))
    self.info2_ =  self.top_:getChildByName("Button_2"):getChildByName("info")

    self.top_:getChildByName("Image_bg_3"):getChildByName("Text_1"):setString(data.league_point)
    self.top_:getChildByName("Button_3"):addTouchEventListener(handler(self, self.touchEvent))
    self.info3_ =  self.top_:getChildByName("Button_3"):getChildByName("info")
end

function ClubMemberLayer:initScrollView(data)
    self.scrollView_:removeAllChildren()

    self.memberNum_ =  # data
    self.showNum_ = math.min(8, self.memberNum_)

    for i = 1 , self.showNum_ do
        local cell = self:createMemberCell(data[i])
        self.scrollView_:addChild(cell)
        cell:setTag(i)
        cell:getChildByName("Text_num"):setString(i)
        if i % 2 == 0 then
            cell:setPosition(cc.p( math.ceil(i / 2) * 310 - 310, 2))
        elseif i % 2 == 1 then
            cell:setPosition(cc.p( math.ceil(i / 2) * 310 - 310, 190))
        end
    end

    self.scrollView_:setInnerContainerSize(cc.size( math.ceil(self.showNum_ / 2) * 310, 390))
    self.scrollView_:scrollToBottom(0,true)
    self.scrollViewScrollMaxLenght_ = self.scrollView_:getInnerContainerSize().width -  self.scrollView_:getContentSize().width
    self.preCell_ = nil 

    self.selfTitle_ = data[1].club_title

    if self.selfTitle_ == 0 then
        self.selfTitle_ = 3
    end
end

function ClubMemberLayer:createMemberCell(data)
    local cell = self.member_:clone()
    cell:setVisible(true)

    data.donate = data.donate or 0
    data.league_point = data.league_point or 0
    data.club_title = data.club_title or 3

    cell:getChildByName("Image_bg_1"):getChildByName("Text_1"):setString((bole:formatCoins(tonumber(data.donate),5)))
    cell:getChildByName("Image_bg_2"):getChildByName("Text_1"):setString(data.league_point)
    if tonumber(data.club_title) == 1 then
        cell:getChildByName("Text_lv"):setString("Leader")
        cell.club_title = 1
    elseif tonumber(data.club_title) == 3 or tonumber(data.club_title) == 0 then
        cell:getChildByName("Text_lv"):setString("Member")
        cell:getChildByName("Text_lv"):setTextColor({ r = 39, g = 174, b = 23})
        cell.club_title = 3
    elseif tonumber(data.club_title) == 2 then
        cell:getChildByName("Text_lv"):setString("Co_leader")
        cell:getChildByName("Text_lv"):setTextColor({ r = 52, g = 189, b = 255})
        cell.club_title = 2
    end
    cell.user_id = data.user_id

    cell:getChildByName("topIcon"):setVisible(false)
    for i = 1, # self.topMember_ do
         if self.topMember_[i][1] == data.user_id then
            cell:getChildByName("topIcon"):setVisible(true)
            if i == 1 then
                cell:getChildByName("topIcon"):loadTexture("res/club/goldCrown.png")
            elseif i == 2 then
                cell:getChildByName("topIcon"):loadTexture("res/club/silverCrown.png")
            elseif i == 3 then
                cell:getChildByName("topIcon"):loadTexture("res/club/copperCrown.png")
            end
         end
    end

    local head = bole:getNewHeadView(data) 
    head:setScale(0.8)
    head:updatePos(head.POS_CLUB_MEMBER)
    head:setPosition(15,5)
    head:setSwallow(true)
    cell:getChildByName("Node_head"):addChild(head)
    cell.head = head
    return cell
end

function ClubMemberLayer:memberTouchEvent(sender, eventType)
    local tag = sender:getTag()
    local name = sender:getName()
    if eventType == ccui.TouchEventType.ended then
        local memberTile = sender.club_title
        if name == "Panel_func" then
            self:hideHintInfo()
            if self.memberfunc_:isVisible() then
                self.memberfunc_:setVisible(false)
            end
        elseif name == "Panel_member" then
            if tonumber(bole:getUserDataByKey("club")) == 0 then
                bole:getUIManage():openClubTipsView(11,nil)
            else
                if self.preCell_ == nil then
                    self.preCell_ = sender
                    sender:getChildByName("bg"):loadTexture("res/club/club_members_self.png")
                else
                    if self.preCell_ ~= sender then
                        self.preCell_:getChildByName("bg"):loadTexture("res/club/club_join_member01.png")
                        sender:getChildByName("bg"):loadTexture("res/club/club_members_self.png")
                        self.preCell_ = sender
                    end
                end

                if sender.user_id ~= bole:getUserDataByKey("user_id") then
                    if self.selfTitle_ == 1 then
                        if memberTile == 2 then
                            self:showFuncInfo(2,sender)
                        elseif memberTile == 3 then
                            self:showFuncInfo(1,sender)
                        end
                    elseif self.selfTitle_ == 2 then
                        if memberTile == 1 then
                            self:showFuncInfo(4,sender)  
                        elseif memberTile == 2 then
                            self:showFuncInfo(4,sender) 
                        elseif memberTile == 3 then
                            self:showFuncInfo(3,sender) 
                        end
                    elseif self.selfTitle_ == 3 then
                        self:showFuncInfo(4,sender)     
                    end
                end
            end
        end
    end
end

function ClubMemberLayer:touchEvent(sender, eventType)
    local name = sender:getName()
    if eventType == ccui.TouchEventType.began then
        sender:runAction(cc.ScaleTo:create(0.1, 1.05, 1.05))
    elseif eventType == ccui.TouchEventType.moved then

    elseif eventType == ccui.TouchEventType.ended then
        sender:runAction(cc.ScaleTo:create(0.1, 1, 1))
        if tonumber(bole:getUserDataByKey("club")) == 0 then
            bole:getUIManage():openClubTipsView(11,nil)
        else
            if name == "Button_1" then
                self:showHintInfo(sender)
            elseif name == "Button_2" then
                self:showHintInfo(sender)
            elseif name == "Button_3" then
                self:showHintInfo(sender)
            elseif name == "btn_profile" then
                bole:getUIManage():openInfoView(self.preCell_.head)
                self:hideFuncInfo()
            elseif name == "btn_playTogether" then
                bole:getUIManage():openClubTipsView(2, nil)
            elseif name == "btn_upgrade" then
                bole.socket:send("accredit_club_member", { target_uid = tonumber(self.preCell_.user_id) },true)
                self:hideFuncInfo()
            elseif name == "btn_kickout" then
                bole:getUIManage():openClubTipsView(1, function() 
                                                       self:hideFuncInfo()
                                                       bole.socket:send("kick_out_member", { target_uid = tonumber(self.preCell_.user_id) },true)
                                                       end)
            elseif name == "btn_degrade" then
                bole:getUIManage():openClubTipsView(4, function() 
                                                       self:hideFuncInfo()
                                                       bole.socket:send("demote_club_member", { target_uid = tonumber(self.preCell_.user_id) },true)
                                                       end)
            end
        end
    elseif eventType == ccui.TouchEventType.canceled then
        sender:runAction(cc.ScaleTo:create(0.1, 1, 1))
    end
end

--升为联合首领
function ClubMemberLayer:accredit_club_member(t,data)
    if t == "accredit_club_member" then
        self:upGrade()
    end
end

--踢出玩家
function ClubMemberLayer:kick_out_member(t,data)
    if t == "kick_out_member" then
        self:kickOut()
    end
end

--降级联合首领
function ClubMemberLayer:demote_club_member(t,data)
    if t == "demote_club_member" then
        self:deGrade()
    end
end

function ClubMemberLayer:upGrade()
    local id = tonumber(self.preCell_.user_id)
    for k ,v in pairs(self.clubMemberList_) do
        if tonumber(v.user_id) == id then
            v.club_title = 2
        end
    end
    self.preCell_:getChildByName("Text_lv"):setString("Co_leader")
    self.preCell_:getChildByName("Text_lv"):setTextColor({ r = 52, g = 189, b = 255})
    self.preCell_.club_title = 2
end

function ClubMemberLayer:deGrade()
    local id = tonumber(self.preCell_.user_id)
    for k ,v in pairs(self.clubMemberList_) do
        if tonumber(v.user_id) == id then
            v.club_title = 3
        end
    end
    self.preCell_:getChildByName("Text_lv"):setString("Member")
    self.preCell_:getChildByName("Text_lv"):setTextColor({ r = 39, g = 174, b = 23})
    self.preCell_.club_title = 3
end

function ClubMemberLayer:kickOut()
    local id = tonumber(self.preCell_.user_id)
    self.preCell_:removeFromParent()
    self.preCell_ = nil
    for i = 1 ,# self.clubMemberList_ do
        if tonumber(self.clubMemberList_[i].user_id) == id then
            table.remove(self.clubMemberList_,i)
            break
        end
    end

    local children = self.scrollView_:getChildren()
    for i = 1 , #children do
        local cell = children[i]
        cell:getChildByName("Text_num"):setString(i)
            if i % 2 == 0 then
                cell:setPosition(cc.p( math.ceil(i / 2) * 310 - 310, 2))
            elseif i % 2 == 1 then
                cell:setPosition(cc.p( math.ceil(i / 2) * 310 - 310, 190))
            end
    end
end

function ClubMemberLayer:scrollViewEvent(sender, eventType)
    if eventType == 9 then
        local nowX = - self.scrollView_:getInnerContainerPosition().x 
        local posX = math.min( math.max(0 , nowX) , self.scrollViewScrollMaxLenght_)
        self.slider_:setPercent(posX / self.scrollViewScrollMaxLenght_ * 100)
    end

    if eventType == 4 then
        local inner_pos = self.scrollView_:getInnerContainerPosition()
        local addMember = false
        if inner_pos.x + 150 < 1222 - math.ceil(self.showNum_ / 2) * 310 then
            for i = self.showNum_ + 1, math.min (self.memberNum_, self.showNum_ + 8) do
                addMember = true
                local cell = self:createMemberCell(self.clubMemberList_[i])
                self.scrollView_:addChild(cell)
                cell:setTag(i)
                cell:getChildByName("Text_num"):setString(i)
                if i % 2 == 0 then
                    cell:setPosition(cc.p( math.ceil(i / 2) * 310 - 310, 2))
                elseif i % 2 == 1 then
                    cell:setPosition(cc.p( math.ceil(i / 2) * 310 - 310, 190))
                end
            end
            
            if addMember then
                self.showNum_ = math.min(self.memberNum_, self.showNum_ + 8)
                self.scrollView_:setInnerContainerSize(cc.size(math.ceil(self.showNum_ / 2) * 310, 436))
                self.scrollView_:setInnerContainerPosition(cc.p(inner_pos.x , 0))
                self.scrollViewScrollMaxLenght_ = self.scrollView_:getInnerContainerSize().width -  self.scrollView_:getContentSize().width
            end    
        end
    end
end

function ClubMemberLayer:hideHintInfo()
    if self.info1_:isVisible() then
        self.info1_:setVisible(false)
    end
    if self.info2_:isVisible() then
        self.info2_:setVisible(false)
    end
    if self.info3_:isVisible() then
        self.info3_:setVisible(false)
    end
end

function ClubMemberLayer:showHintInfo(sender)
    local showInfo = sender:getChildByName("info")
    showInfo:setVisible(true)
    showInfo:setScale(0.1)
    showInfo:runAction(cc.ScaleTo:create(0.2,1,1))
    self.memberfunc_:setVisible(true)
    self.memberfunc_:getChildByName("panel"):setVisible(false)
end

function ClubMemberLayer:hideFuncInfo()
    self.memberfunc_:setVisible(false)
end

function ClubMemberLayer:showFuncInfo(status,sender)
    local funcPanel = self.memberfunc_:getChildByName("panel")
    funcPanel:setVisible(true)

    local bg = funcPanel:getChildByName("bg")
    local btn_profile = funcPanel:getChildByName("btn_profile")
    local btn_playTogether = funcPanel:getChildByName("btn_playTogether")
    local btn_upgrade = funcPanel:getChildByName("btn_upgrade")
    local btn_kickout = funcPanel:getChildByName("btn_kickout")
    local btn_degrade = funcPanel:getChildByName("btn_degrade")
    btn_profile:addTouchEventListener(handler(self, self.touchEvent))
    btn_playTogether:addTouchEventListener(handler(self, self.touchEvent))
    btn_upgrade:addTouchEventListener(handler(self, self.touchEvent))
    btn_kickout:addTouchEventListener(handler(self, self.touchEvent))
    btn_degrade:addTouchEventListener(handler(self, self.touchEvent))

    if status == 1 then  
        funcPanel:setContentSize(228,250)
        bg:setContentSize(228,250)
        bg:setPosition(0,125)
        btn_profile:setVisible(true)
        btn_playTogether:setVisible(true)
        btn_upgrade:setVisible(true)
        btn_kickout:setVisible(true)
        btn_degrade:setVisible(false)
        btn_profile:setPosition(126,214)
        btn_playTogether:setPosition(126,154)
        btn_upgrade:setPosition(126,95)
        btn_kickout:setPosition(126,35)
    elseif status == 2 then
        funcPanel:setContentSize(228,187)
        bg:setContentSize(228,187)
        bg:setPosition(0,95)
        btn_profile:setVisible(true)
        btn_playTogether:setVisible(true)
        btn_upgrade:setVisible(false)
        btn_kickout:setVisible(false)
        btn_degrade:setVisible(true)
        btn_profile:setPosition(126,154)
        btn_playTogether:setPosition(126,95)
        btn_degrade:setPosition(126,35)
    elseif status == 3 then
        funcPanel:setContentSize(228,187)
        bg:setContentSize(228,187)
        bg:setPosition(0,95)
        btn_profile:setVisible(true)
        btn_playTogether:setVisible(true)
        btn_upgrade:setVisible(false)
        btn_kickout:setVisible(true)
        btn_degrade:setVisible(false)
        btn_profile:setPosition(126,154)
        btn_playTogether:setPosition(126,95)
        btn_kickout:setPosition(126,35)
    elseif status == 4 then
        funcPanel:setContentSize(228,125)
        bg:setContentSize(228,125)
        bg:setPosition(0,65)
        btn_profile:setVisible(true)
        btn_playTogether:setVisible(true)
        btn_upgrade:setVisible(false)
        btn_kickout:setVisible(false)
        btn_degrade:setVisible(false)
        btn_profile:setPosition(126,95)
        btn_playTogether:setPosition(126,35)
    end

    local pos = sender:convertToWorldSpace(cc.p(0,0))
    funcPanel:setPosition(pos.x + 100,pos.y + 80)
    self.memberfunc_:setVisible(true)
    funcPanel:setScale(0.1)
    funcPanel:runAction(cc.ScaleTo:create(0.2,1,1))

end

function ClubMemberLayer:adaptScreen(data)
    local winSize = cc.Director:getInstance():getWinSize()
    self.memberfunc_:setContentSize(winSize)
    self.memberfunc_:setPositionY(0 - data.result)
end

function ClubMemberLayer:addMemberPanel(data)
    data = data.result
        for i = self.showNum_ + 1 , self.showNum_ + 1 do
            local cell = self:createMemberCell(data)
            self.scrollView_:addChild(cell)
            cell:setTag(i)
            cell:getChildByName("Text_num"):setString(i)
            if i % 2 == 0 then
                cell:setPosition(cc.p( math.ceil(i / 2) * 310 - 310, 2))
            elseif i % 2 == 1 then
                cell:setPosition(cc.p( math.ceil(i / 2) * 310 - 310, 190))
            end
        end

    self.showNum_ = self.showNum_ + 1
    self.scrollView_:setInnerContainerSize(cc.size( math.ceil(self.showNum_ / 2) * 310, 390))
    self.scrollView_:scrollToRight(0,true)
    self.scrollViewScrollMaxLenght_ = self.scrollView_:getInnerContainerSize().width -  self.scrollView_:getContentSize().width
end

function ClubMemberLayer:removeMember(data)

end

function ClubMemberLayer:onExit()
    bole:removeListener("initMemberInfo", self)
    bole:removeListener("initAdaptPos", self)
    bole:removeListener("addMemberPanel", self)
    bole.socket:unregisterCmd("accredit_club_member")
    bole.socket:unregisterCmd("demote_club_member")
    bole.socket:unregisterCmd("kick_out_member")
end


return ClubMemberLayer

--endregion
