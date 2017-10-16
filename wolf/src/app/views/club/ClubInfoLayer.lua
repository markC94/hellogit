-- region *.lua
-- Date
-- 此文件由[BabeLua]插件自动生成
local ClubInfoLayer = class("ClubInfoLayer", cc.load("mvc").ViewBase)
function ClubInfoLayer:onCreate()
    print("ClubInfoLayer-onCreate")
    local root = self:getCsbNode():getChildByName("root")
    self.root_ = root
    root:setVisible(false)

    local btn_close = root:getChildByName("btn_close")
    btn_close:addTouchEventListener(handler(self, self.touchEvent))

    local sp_info_bg = root:getChildByName("sp_info_bg")
    self.sp_info_bg = sp_info_bg
    self.btn_jion = sp_info_bg:getChildByName("btn_jion")
    self.btn_jion:getChildByName("txt_key"):setString("")
    self.btn_jion:addTouchEventListener(handler(self, self.touchEvent))
    self.btn_jion:setTouchEnabled(false)

    self.btn_jion_dark = sp_info_bg:getChildByName("btn_jion_dark")
    self.btn_jion_dark:setVisible(false)

    self.top = sp_info_bg:getChildByName("top")
    self.top:setVisible(false)

    self.clubInfoViewPanel_ = root:getChildByName("viewPanel")

    self:initTableView()
    self:adaptScreen(root)
end

function ClubInfoLayer:onKeyBack()
    self:closeUI()
end

function ClubInfoLayer:onEnter()
    bole:addListener("closeClubInfoLayer", self.closeUI, self, nil, true)
    bole:addListener("initClubId", self.initClubId, self, nil, true)
    bole.socket:registerCmd(bole.SERVER_GET_CLUB_INFO, self.initClubInfoLayer, self) 
    bole.socket:registerCmd("apply_joining_club", self.apply_joining_club, self)
end


function ClubInfoLayer:onExit()
    bole:removeListener("closeClubInfoLayer", self)
    bole:removeListener("initClubId", self)
    bole.socket:unregisterCmd(bole.SERVER_GET_CLUB_INFO)
    bole.socket:unregisterCmd("apply_joining_club")
end

function ClubInfoLayer:initTableView()
    self.m_tableView = cc.TableView:create( cc.size(1220, 510) )
    --TabelView添加到PanleMain  
    self.clubInfoViewPanel_:addChild(self.m_tableView)
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
        return 0, 195
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
            popItem:setContentSize(1220 , 195)
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

function ClubInfoLayer:refrushTableView(item, index)
  for i = 1, 4 do
        local memberCell = item:getChildByName("memberCell" .. i)
        local data = self.info.users [(index - 1) * 4 + i]
        if data == nil then
            if memberCell ~= nil then
                memberCell:setVisible(false)
            end
        else
            if memberCell == nil then
                memberCell = bole:getEntity("app.views.club.ClubMemberCell",data,(index - 1) * 4 + i)
                item:addChild(memberCell)
                memberCell:setName("memberCell" .. i)
                memberCell:setPosition((i - 1) * 305 + 150, 95)
            else
                --self:refurshMemberCell(memberCell,data)
                memberCell:updateInfo(data,(index - 1) * 4 + i)
            end
            --memberCell:getChildByName("Text_num"):setString((index - 1) * 4 + i)
            memberCell:setVisible(true)
        end
    end

end

function ClubInfoLayer:initClubId(data)
    data = data.result
    bole.socket:send(bole.SERVER_GET_CLUB_INFO,{id=data},true)
end

function ClubInfoLayer:refreshList(data)
        --{160 326  470 326  160 116}
    table.sort(self.info.users, function(a,b)
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

    local sp_info_bg = self:getCsbNode():getChildByName("root"):getChildByName("sp_info_bg")
    sp_info_bg:getChildByName("sp_icon"):loadTexture(bole:getClubManage():getClubIconPath(data.icon))

    sp_info_bg:getChildByName("txt_name"):setString(data.name)

    if tonumber(data.qualification)  == 0 then
        sp_info_bg:getChildByName("txt_status"):setString("Anyone can join")
    elseif tonumber(data.qualification)  == 1 then
        sp_info_bg:getChildByName("txt_status"):setString("Invite Only")
    end
   
   sp_info_bg:getChildByName("img_level"):getChildByName("txt_level"):setString(data.require_level)
   sp_info_bg:getChildByName("img_rank"):getChildByName("txt_name"):setString("Rank " .. data.league_rank)
   sp_info_bg:getChildByName("img_rank"):loadTexture(bole:getClubManage():getLeagueIconPath(data.league_level))

   self.tableCellNum_ = math.ceil(# self.info.users / 4)
   self.m_tableView:reloadData()
end

function ClubInfoLayer:initClubInfoLayer(t,data)
dump(data)
    if bole:getClubManage():isInClub() then
        self.btn_jion:setVisible(false)
        self.btn_jion_dark:setVisible(true)
    else
        self.btn_jion:setVisible(true)
        self.btn_jion_dark:setVisible(false)
    end
    self.root_:setScale(0.01)
    self.root_:setVisible(true)
    self.root_:runAction(cc.ScaleTo:create(0.2, 1.0))

    self.info=data
    self.clubId_ = data.id
    self:refreshTop(data)
    self:refreshList(data)
end

function ClubInfoLayer:refreshTop(data)
    if tonumber(data.qualification)  == 0 then
        self.btn_jion:getChildByName("txt_key"):setString("Join Club")
        self.btn_jion:getChildByName("txt_key"):setFontSize(36)
    elseif tonumber(data.qualification)  == 1 then
        self.btn_jion:getChildByName("txt_key"):setString("Request an\nInvitation")
        self.btn_jion:getChildByName("txt_key"):setFontSize(28)
    end
    self.btn_jion:setTouchEnabled(true)

    if bole:getClubManage():isInClub() then
        self.btn_jion:setVisible(false)
        self.btn_jion_dark:setVisible(true)
    else
        self.btn_jion:setVisible(true)
        self.btn_jion_dark:setVisible(false)
    end

    if data.applied == 1 then
        self.btn_jion:getChildByName("txt_key"):setString("Applied")
        self.btn_jion:getChildByName("txt_key"):setFontSize(36)
        self.btn_jion:setTouchEnabled(false)
    end

    if data.inviter == 1 then
        self.btn_jion:getChildByName("txt_key"):setString("Join")
        self.btn_jion:getChildByName("txt_key"):setFontSize(36)
        self.btn_jion:setTouchEnabled(true)
    end

    if self.clubId_ == bole:getClubManage():getClubId() then
         self.top:setVisible(true)
         self.top:getChildByName("Image_bg_1"):getChildByName("Text_1"):setString(data.current_u_count)
         self.top:getChildByName("Image_bg_1"):getChildByName("Text_2"):setString(data.max_u_count)
         self.top:getChildByName("Image_bg_2"):getChildByName("Text_1"):setString(bole:formatCoins(tonumber(data.exp),5))
         self.top:getChildByName("Image_bg_3"):getChildByName("Text_1"):setString(bole:formatCoins(tonumber(data.league_point),5))
         self.sp_info_bg:getChildByName("img_level"):setVisible(false)
         self.sp_info_bg:getChildByName("btn_jion_dark"):setVisible(false)
         self.sp_info_bg:getChildByName("btn_jion"):setVisible(false)
         self.sp_info_bg:getChildByName("img_rank"):setVisible(false)
    end
end

function ClubInfoLayer:touchEvent(sender, eventType)
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
        if name == "btn_close" then
            self:closeUI()
        elseif name == "btn_jion" then
            self:jionClub()
        end
    elseif eventType == ccui.TouchEventType.canceled then
        print("Touch Cancelled")
        sender:setScale(1)
    end
end


function ClubInfoLayer:jionClub()
    if bole:getClubManage():isInClub() then
        bole:popMsg({msg ="you have joined a club" , title = "join" , cancle = false}, function() bole:postEvent("openClubLayer") return end)
        return
    end

    if bole:getClubManage():isRequestLimit() then
        bole:popMsg({msg ="Sorry,you have reached request limit." , title = "join" , cancle = false})
        return
    end

    bole.socket:send("apply_joining_club", {id = tonumber(self.info.id) }, true)
end

function ClubInfoLayer:apply_joining_club(t, data)
   if t == "apply_joining_club" then
        if data.error ~= nil then
            if data.error == 2 then  --已经加入联盟
                bole:popMsg({msg ="you have joined a club." , title = "join" , cancle = false}, function() bole:postEvent("openClubLayer") return end)
            elseif data.error == 3 then  --你在黑名单里
                bole:popMsg({msg ="Sorry,you can't join this club." , title = "join" , cancle = false})
            elseif data.error == 4 then  --公会不存在
                bole:popMsg( { msg = "Sorry,this club doesn't exist.", title = "error", cancle = false }, function() bole:postEvent("openClubLayer") return end )
            elseif data.error == 5 then  --你的等级不足
                bole:popMsg({msg ="Your level is too low to join this club.Level up or join another club!" , title = "join" , cancle = false})
            elseif data.error == 6 then  --已经申请过
                bole:popMsg({msg ="You have applied for this club." , title = "join" , cancle = false})
            elseif data.error == 7 then  --公会满了
                bole:popMsg({msg ="Sorry,this club is currently full.Try another club!" , title = "join" , cancle = false})
                bole.socket:send(bole.SERVER_GET_CLUB_INFO,{id=self.clubId_})
            end
            return
        end
        --申请成功
            if data.success == 1 then
                bole:getClubManage():addRequestClub(self.info.id)
                bole:postEvent("applyJoiningClub", self.info.id) 
                bole:popMsg({msg ="Your request was sent successfully." , title = "join" , cancle = false})
                self:closeUI()
            end

        --加入成功
        if data.id ~= nil then
            bole:getClubManage():setClubInfo(data)
            bole:postEvent("changeClub", data) 
            bole:postEvent("openClubLayer",data) 
            self:closeUI()
        end
   end
end

function ClubInfoLayer:adaptScreen(root)
    local winSize = cc.Director:getInstance():getWinSize()
    self:setPosition(0, 0)
    root:setPosition(winSize.width / 2, winSize.height / 2)
end

return ClubInfoLayer


-- endregion
