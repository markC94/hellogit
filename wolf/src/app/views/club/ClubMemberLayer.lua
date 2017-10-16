--region *.lua
--Date
--此文件由[BabeLua]插件自动生成

local ClubMemberLayer = class("ClubMemberLayer", cc.load("mvc").ViewBase)
local DefaultShowNum = 8      --默认显示头像数量
local HeadSpace = 310          --头像间隔
local startHeadSpace = 300     --第一列头像位置
local showMask = 0            --遮罩(加大可滑动长度)
local Head_y_1 = 2            --第一排头像y坐标
local Head_y_2 = 200           --第二排头像y坐标
local ScrollViewHeight = 390   --滚动列表高
local ScrollViewWidth = 1240   --滚动列表宽
local ShowNextHeadWidth = 100   --分页显示拉动距离
local SliderLength = 1200      --滚动条长度


function ClubMemberLayer:onCreate()
    self.root_ =  self:getCsbNode():getChildByName("root")
    self.member_ =  self:getCsbNode():getChildByName("Panel_member")
    self.member_:addTouchEventListener(handler(self, self.memberTouchEvent))
    self.memberfunc_ = self:getCsbNode():getChildByName("Panel_func")
    self.memberfunc_:addTouchEventListener(handler(self, self.memberTouchEvent))
    self.memberfunc_:setVisible(false)
    self:createMemberfunc()

    self.top_ = self.root_:getChildByName("top")
    self.clubMemberViewPanel_ = self.root_:getChildByName("viewPanel")
    self:initTableView()
    --self:initTop()
    --self:initScrollView()
end

function ClubMemberLayer:showClose()
    self.root_ =  self:getCsbNode():getChildByName("root")
    local img_bg =  self.root_:getChildByName("img_bg")
    img_bg:setVisible(true)
    local btn_close =  self.root_:getChildByName("btn_close")
    btn_close:setVisible(true)
    btn_close:addTouchEventListener(handler(self, self.memberTouchEvent))
    self:setDialog(true)
end

function ClubMemberLayer:onEnter()
    bole:addListener("initMemberInfo", self.initMemberInfo, self, nil, true)
    bole:addListener("initAdaptPos", self.adaptScreen, self, nil, false)
    bole:addListener("addMemberPanel", self.addMemberPanel, self, nil, true)
    bole:addListener("getClubInfo_league", self.initMemberInfo, self, nil, true)

    bole.socket:registerCmd("accredit_club_member", self.accredit_club_member, self)
    bole.socket:registerCmd("demote_club_member", self.demote_club_member, self)
    bole.socket:registerCmd("kick_out_member", self.kick_out_member, self)
end

function ClubMemberLayer:initTableView()
    self.m_tableView = cc.TableView:create( cc.size(1240, 460) )
    --TabelView添加到PanleMain  
    self.clubMemberViewPanel_:addChild(self.m_tableView)
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
        return 0, 200
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
            popItem:setContentSize(1240 , 190)
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

function ClubMemberLayer:refrushTableView(item, index)
    for i = 1, 4 do
        local memberCell = item:getChildByName("memberCell" .. i)
        local data = self.clubMemberList_[(index - 1) * 4 + i]
        if data == nil then
            if memberCell ~= nil then
                memberCell:setVisible(false)
            end
        else
            if memberCell == nil then
                memberCell = self:refurshMemberCell(memberCell,data)
                item:addChild(memberCell)
                memberCell:setName("memberCell" .. i)
                memberCell:setPosition((i - 1) * 310 + 10, 10)
            else
                self:refurshMemberCell(memberCell,data)
            end
            memberCell:getChildByName("Text_num"):setString((index - 1) * 4 + i)
            memberCell:setVisible(true)
        end
    end
end

function ClubMemberLayer:initMemberInfo(data)
    --dump(data.result,"data.result")
    self:initTop(data.result)
    self.clubMemberList_ = data.result.users
    self.selfTitle_ = bole:getClubManage():getClubTitle()

    if self.selfTitle_ == 0 then
        self.selfTitle_ = 3
    end

    table.sort(self.clubMemberList_, function(a,b)
        if tonumber(a.club_title) == tonumber(b.club_title) then
            if a.club_title ~= 3 then
                return tonumber(a.level) < tonumber(b.level)
            else
                if a.online == b.online then
                    return tonumber(a.level) > tonumber(b.level)
                else
                    return tonumber(a.online) > tonumber(b.online)
                end
            end
        else
            return tonumber(a.club_title) < tonumber(b.club_title)
        end
    end)

    self.topMember_ = {}
    for i = 1, 3 do
        if data.result.rewards[1].top[i] ~= nil then
            self.topMember_[i] = data.result.rewards[1].top[i]
        end
    end

    self.tableCellNum_ = math.ceil(# self.clubMemberList_ / 4)
    self.m_tableView:reloadData()
end


function ClubMemberLayer:initTop(data)
    self.top_:getChildByName("icon"):loadTexture(bole:getClubManage():getClubIconPath(data.icon))
    self.top_:getChildByName("Image_bg_1"):getChildByName("Text_1"):setString( math.min(# data.users , data.max_u_count))
    self.top_:getChildByName("Image_bg_1"):getChildByName("Text_2"):setString(data.max_u_count)
    self.top_:getChildByName("Button_1"):addTouchEventListener(handler(self, self.touchEvent))
    self.info1_ =  self.top_:getChildByName("Button_1"):getChildByName("info")
    self.info1_:getChildByName("text"):setString(bole:getClubManage():getMemberTipInfo())

    self.top_:getChildByName("Image_bg_2"):getChildByName("Text_1"):setString(bole:formatCoins(tonumber(data.exp),5))
    self.top_:getChildByName("Button_2"):addTouchEventListener(handler(self, self.touchEvent))
    self.info2_ =  self.top_:getChildByName("Button_2"):getChildByName("info")

    self.top_:getChildByName("Image_bg_3"):getChildByName("Text_1"):setString(bole:formatCoins(tonumber(data.league_point),5))
    self.top_:getChildByName("Button_3"):addTouchEventListener(handler(self, self.touchEvent))
    self.info3_ =  self.top_:getChildByName("Button_3"):getChildByName("info")
end

function ClubMemberLayer:refurshMemberCell(cell,data)
    if cell == nil then
        cell = self.member_:clone()
        local head = bole:getNewHeadView(data) 
        head:setScale(0.8)
        head:updatePos(head.POS_CLUB_MEMBER)
        head.touch:setTouchEnabled(false)
        head:setPosition(15,5)
        head:setSwallow(true)
        head:setName("head")
        cell:getChildByName("Node_head"):addChild(head)
        cell.head = head
    else
        cell:getChildByName("Node_head"):getChildByName("head"):updateInfo(data)
    end
    cell:setVisible(true)

    data.donate = data.donate or 0
    data.league_point = data.league_point or 0
    data.club_title = data.club_title or 3

    cell:getChildByName("Image_bg_1"):getChildByName("Text_1"):setString((bole:formatCoins(tonumber(data.donate),5)))
    cell:getChildByName("Image_bg_2"):getChildByName("Text_1"):setString(bole:formatCoins(tonumber(data.league_point),5))
    if tonumber(data.club_title) == 1 then
        cell:getChildByName("Text_lv"):setString("Leader")
        cell:getChildByName("bg"):loadTexture("loadImage/club_members_bg1.png")
        cell:getChildByName("Text_num"):setTextColor({ r = 40, g = 51, b = 76})
        cell.club_title = 1
    elseif tonumber(data.club_title) == 3 or tonumber(data.club_title) == 0 then
        cell:getChildByName("Text_lv"):setString("Member")
        cell:getChildByName("bg"):loadTexture("loadImage/club_members_bg2.png")
        cell:getChildByName("Text_num"):setTextColor({ r = 255, g = 255, b = 255})
        cell.club_title = 3
    elseif tonumber(data.club_title) == 2 then
        cell:getChildByName("Text_lv"):setString("Co-leader") 
        cell:getChildByName("bg"):loadTexture("loadImage/club_members_bg3.png")
        cell:getChildByName("Text_num"):setTextColor({ r = 40, g = 51, b = 76})
        cell.club_title = 2
    end
    cell.user_id = data.user_id

    if data.user_id == bole:getUserDataByKey("user_id") then
        cell:getChildByName("bg"):loadTexture("loadImage/club_frame_member_light.png")
    end

    cell:getChildByName("topIcon"):setVisible(false)
    for i = 1, # self.topMember_ do
         if self.topMember_[i][1] == data.user_id then
            cell:getChildByName("topIcon"):setVisible(true)
            if i == 1 then
                cell:getChildByName("topIcon"):loadTexture("loadImage/crown_gold.png")
            elseif i == 2 then
                cell:getChildByName("topIcon"):loadTexture("loadImage/crown_silver.png")
            elseif i == 3 then
                cell:getChildByName("topIcon"):loadTexture("loadImage/crown_copper.png")
            end
         end
    end

    cell:setTouchEnabled(true)
    cell:setSwallowTouches(false)
    return cell
end

function ClubMemberLayer:memberTouchEvent(sender, eventType)
    local tag = sender:getTag()
    local name = sender:getName()
    if eventType == ccui.TouchEventType.began then
        self.tableViewScroll_ = false
    elseif eventType == ccui.TouchEventType.ended then
        local memberTile = sender.club_title
        if name == "Panel_func" then
            self:hideHintInfo()
            if self.memberfunc_:isVisible() then
                self.memberfunc_:setVisible(false)
            end
        elseif name == "btn_close" then
            self:closeUI()
        elseif string.sub(name,1,-2) == "memberCell" then
            if not self.tableViewScroll_  then
            if not bole:getClubManage():isInClub() then
                bole:popMsg({msg ="Sorry,you have left club." , title = "collect" , cancle = false})
            else
            
                if self.preCell_ == nil then
                    self.preCell_ = sender
                    --sender:getChildByName("bg"):loadTexture("club/club_members_self.png")
                else
                    if self.preCell_ ~= sender then
                        --self.preCell_:getChildByName("bg"):loadTexture("club/club_join_member01.png")
                        --sender:getChildByName("bg"):loadTexture("club/club_members_self.png")
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
end

function ClubMemberLayer:touchEvent(sender, eventType)
    local name = sender:getName()
    if eventType == ccui.TouchEventType.began then
        sender:runAction(cc.ScaleTo:create(0.1, 1.05, 1.05))
    elseif eventType == ccui.TouchEventType.moved then

    elseif eventType == ccui.TouchEventType.ended then
        sender:runAction(cc.ScaleTo:create(0.1, 1, 1))
        if not bole:getClubManage():isInClub() then
            bole:popMsg({msg ="Sorry,you have left club." , title = "Collect" , cancle = false})
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
                
            elseif name == "btn_upgrade" then
                bole.socket:send("accredit_club_member", { target_uid = tonumber(self.preCell_.user_id) },true)
                self:hideFuncInfo()
            elseif name == "btn_kickout" then
                bole:popMsg({msg ="kick out the member." , title = "KickOut" , cancle = true},function() 
                                                       self:hideFuncInfo()
                                                       bole.socket:send("kick_out_member", { target_uid = tonumber(self.preCell_.user_id) },true)
                                                       end)
            elseif name == "btn_degrade" then
                 bole:popMsg({msg ="degrade the member." , title = "Demote" , cancle = true},  function() 
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
    if data.error == 2 then
        bole:popMsg({msg ="Sorry,you can't upGrade a member now." , title = "Promote" , cancle = false})
    elseif data.error == 3 then
        bole:popMsg({msg ="This player is not in club." , title = "Promote", cancle = false })
    elseif data.error == 4 then
        bole:popMsg({msg ="This player is a co-leader now." , title = "Promote" , cancle = false})
    elseif data.error == 5 then
        bole:popMsg({msg ="Sorry,you can't appoint more co-leader." , title = "Promote" , cancle = false})
    elseif data.error ~= nil then
        bole:popMsg({msg ="error: " .. data.error , title = "Promote" , cancle = false})
    elseif data.success == 1 then
        self:upGrade()
    end
end

--踢出玩家
function ClubMemberLayer:kick_out_member(t,data)
    if data.error == 2 then
        bole:popMsg({msg ="Sorry,you can't kick a member now." , title = "KickOut" , cancle = false})
    elseif data.error == 3 then
        self:kickOut()
        --bole:popMsg({msg ="This player is not in club." , title = "KickOut" , cancle = false})
    elseif data.error == 4 then
        bole:popMsg({msg ="This player is a co-leader now." , title = "KickOut" , cancle = false})
    elseif data.error ~= nil then
        bole:popMsg({msg ="error: " .. data.error , title = "KickOut" , cancle = false})
    elseif data.success == 1 then
        self:kickOut()
    end
end

--降级联合首领
function ClubMemberLayer:demote_club_member(t,data)
    if data.error == 2 then
        bole:popMsg({msg ="Sorry,you can't reGrade a member now." , title = "Demote" , cancle = false })
    elseif data.error == 3 then
        bole:popMsg({msg ="This player is not in club." , title = "Demote" , cancle = false})
    elseif data.error == 4 then
        bole:popMsg({msg ="This player is a member now." , title = "Demote" , cancle = false})
    elseif data.error ~= nil then
        bole:popMsg({msg ="error: " .. data.error , title = "Demote" , cancle = false})
    elseif  data.success == 1 then
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
    self.preCell_:getChildByName("bg"):loadTexture("loadImage/club_members_bg3.png")
    self.preCell_:getChildByName("Text_num"):setTextColor({ r = 40, g = 51, b = 76})
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
    self.preCell_:getChildByName("bg"):loadTexture("loadImage/club_members_bg2.png")
    self.preCell_:getChildByName("Text_num"):setTextColor({ r = 255, g = 255, b = 255})
    self.preCell_.club_title = 3
end

function ClubMemberLayer:kickOut()
    local id = tonumber(self.preCell_.user_id)
    self.preCell_ = nil
    for i = 1 ,# self.clubMemberList_ do
        if tonumber(self.clubMemberList_[i].user_id) == id then
            table.remove(self.clubMemberList_,i)
            break
        end
    end
    self.tableCellNum_ = # self.clubMemberList_
    self.m_tableView:reloadData()
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
    if self.memberfunc_.funcPanel ~= nil then
        self.memberfunc_.funcPanel:setVisible(false)
    end
end

function ClubMemberLayer:hideFuncInfo()
    self.memberfunc_:setVisible(false)
end

function ClubMemberLayer:createMemberfunc()
    local funcPanel_1 = self.memberfunc_:getChildByName("panel_1")
    local funcPanel_2 = self.memberfunc_:getChildByName("panel_2")
    local funcPanel_3 = self.memberfunc_:getChildByName("panel_3")
    funcPanel_1:setVisible(false)
    funcPanel_2:setVisible(false)
    funcPanel_3:setVisible(false)

    funcPanel_1:getChildByName("btn_profile"):addTouchEventListener(handler(self, self.touchEvent))
    funcPanel_1:getChildByName("btn_upgrade"):addTouchEventListener(handler(self, self.touchEvent))
    funcPanel_1:getChildByName("btn_kickout"):addTouchEventListener(handler(self, self.touchEvent))

    funcPanel_2:getChildByName("btn_profile"):addTouchEventListener(handler(self, self.touchEvent))
    funcPanel_2:getChildByName("btn_degrade"):addTouchEventListener(handler(self, self.touchEvent))

    funcPanel_3:getChildByName("btn_profile"):addTouchEventListener(handler(self, self.touchEvent))
    funcPanel_3:getChildByName("btn_kickout"):addTouchEventListener(handler(self, self.touchEvent))
end

function ClubMemberLayer:showFuncInfo(status,sender)
    local funcPanel_1 = self.memberfunc_:getChildByName("panel_1")
    local funcPanel_2 = self.memberfunc_:getChildByName("panel_2")
    local funcPanel_3 = self.memberfunc_:getChildByName("panel_3")
    funcPanel_1:setVisible(false)
    funcPanel_2:setVisible(false)
    funcPanel_3:setVisible(false)
    local funcPanel = funcPanel_1
    if status == 1 then  
        funcPanel = funcPanel_1
        funcPanel_1:setVisible(true)
    elseif status == 2 then
        funcPanel = funcPanel_2
        funcPanel_2:setVisible(true)
    elseif status == 3 then
        funcPanel = funcPanel_3
        funcPanel_3:setVisible(true)
    elseif status == 4 then
        bole:getUIManage():openInfoView(self.preCell_.head)
        return
    end
    self.memberfunc_.funcPanel = funcPanel
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
    self.tableCellNum_ = # self.clubMemberList_
    self.m_tableView:reloadData()
end

function ClubMemberLayer:removeMember(data)

end

function ClubMemberLayer:onExit()
    bole:removeListener("initMemberInfo", self)
    bole:removeListener("initAdaptPos", self)
    bole:removeListener("addMemberPanel", self)
    bole:removeListener("getClubInfo_league", self)
    bole.socket:unregisterCmd("accredit_club_member")
    bole.socket:unregisterCmd("demote_club_member")
    bole.socket:unregisterCmd("kick_out_member")
end


return ClubMemberLayer

--endregion
