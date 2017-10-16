-- region *.lua
-- Date
-- 此文件由[BabeLua]插件自动生成
local ClubJoinLayer = class("ClubJoinLayer", cc.load("mvc").ViewBase)
function ClubJoinLayer:onCreate()
    print("ClubJoinLayer-onCreate")
    local root = self:getCsbNode():getChildByName("root")
    self.root_ = root
    root:setVisible(false)
    self.btn_panel_ = root:getChildByName("Panel_btn")
    self.node_View_ = root:getChildByName("Node_View")
    self.joinView_ = self.node_View_:getChildByName("joinView")

    self:initBtnPanel()
    self:initJoinView()

    self:setAllBtnTouch(false)
    self:adaptScreen(root)
    bole:getClubManage():getClubInfo("open_r_club")
end

function ClubJoinLayer:onKeyBack()
    self:closeUI()
end

function ClubJoinLayer:onEnter()
    bole:addListener("applyJoiningClub", self.applyJoiningClub, self, nil, true)
    bole:addListener("closeClubJoinLayer", self.closeUI, self, nil, true)
    bole:addListener("refreshClubJoinLayer", self.refreshClubJoinLayer, self, nil, true)
    bole:addListener("initRecommendClubInfo", self.initRecommendClubInfo, self, nil, true)
    bole:addListener("refreshSearchClubInfo", self.refreshSearchClubInfo, self, nil, true)
    
    bole.socket:registerCmd("search_club_by_name", self.search_club_by_name, self)
end


function ClubJoinLayer:initRecommendClubInfo(data)
    data = data.result
    self.root_:setScale(0.01)
    self.root_:setVisible(true)
    self.root_:runAction(cc.ScaleTo:create(0.2, 1.0))
    self:initList(data)
    self.inviterList_ = { }
    self.appliedList_ = { }
    for k, v in pairs(data) do
        if v.applied == 1 then
            self.appliedList_[v.id] = 1
        end
        if v.inviter == 1 then
            self.inviterList_[v.id] = 1
        end
    end
    self:setAllBtnTouch(true)
    self:showJoinLayer()
end

function ClubJoinLayer:refreshClubJoinLayer()
    bole:getClubManage():getClubInfo("refreshClubJoinLayer")
end

function ClubJoinLayer:initBtnPanel()
    self.btn_create_ = self.btn_panel_:getChildByName("btn_create")
    self.btn_create_:addTouchEventListener(handler(self, self.touchEvent))
    self.btn_join_ = self.btn_panel_:getChildByName("btn_join")
    self.btn_join_:addTouchEventListener(handler(self, self.touchEvent))
    self.btn_close_ = self:getCsbNode():getChildByName("root"):getChildByName("btn_close")
    self.btn_close_:addTouchEventListener(handler(self, self.touchEvent))
end

function ClubJoinLayer:initJoinView()
    local node_edit = self.joinView_:getChildByName("node_edit")
    self:initEditBox(node_edit)
    self.btn_search_ = self.joinView_:getChildByName("sp_icon")
    self.btn_search_:addTouchEventListener(handler(self, self.touchEvent))
    self.list_join = self.joinView_:getChildByName("list_join")
    self.list_join:setScrollBarOpacity(0)

    local inputBg = self.joinView_:getChildByName("inputBg")
    inputBg:addTouchEventListener(handler(self, self.touchInputBgEvent))
    self.txt_input_ = self.joinView_:getChildByName("txt_input")
    self.txt_input_:setString("Input a club name.")
    self.txt_input_:setTextColor(cc.c3b(120, 120, 160))
end


function ClubJoinLayer:setAllBtnTouch(bool)
    self.btn_create_:setTouchEnabled(bool)
    self.btn_join_:setTouchEnabled(bool)
    self.btn_search_:setTouchEnabled(bool)
end

function ClubJoinLayer:initEditBox(node)
    local function editBoxTextEventHandle(strEventName, pSender)
        local edit = pSender
        local strFmt
        if strEventName == "began" then

        elseif strEventName == "ended" then

        elseif strEventName == "return" then
            self.txt_input_:setString(pSender:getText())
            if pSender:getText() == "" then
                self.txt_input_:setString("Input a club name.")
            end
        elseif strEventName == "changed" then
            self.txt_input_:setString(pSender:getText())
            if pSender:getText() == "" then
                self.txt_input_:setString("Input a club name.")
            end
        end
    end
    self.editBox = cc.EditBox:create(cc.size(30, 30), "loadImage/editBox_bg.png")
    self.editBox:setPosition(0, 0)
    self.editBox:setFont("font/bole_ttf.ttf", 3)
    self.editBox:setFontColor(cc.c3b(120, 120, 160))
    --self.editBox:setPlaceHolder("")
    self.editBox:setMaxLength(15)
    self.editBox:setInputFlag(cc.EDITBOX_INPUT_FLAG_INITIAL_CAPS_WORD)
    self.editBox:setInputMode(cc.EDITBOX_INPUT_MODE_SINGLELINE)
    self.editBox:setReturnType(cc.KEYBOARD_RETURNTYPE_DONE)
    self.editBox:registerScriptEditBoxHandler(editBoxTextEventHandle)
    node:addChild(self.editBox)
end

function ClubJoinLayer:initList(data)
    self.r_clubs = data
    self.list_join:removeAllChildren()
    for k, v in ipairs(self.r_clubs) do
        local cell = bole:getEntity("app.views.club.ClubJoinCell", v)
        self.list_join:pushBackCustomItem(cell)
        cell.id = v.id
    end
end

function ClubJoinLayer:touchEvent(sender, eventType)
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
        if name == "btn_create" then
            self:showCreateLayer()
        elseif name == "btn_close" then
            self:closeUI()
        elseif name == "sp_icon" then
            self:searchClub()
        elseif name == "btn_join" then
            self:showJoinLayer()
        end

    elseif eventType == ccui.TouchEventType.canceled then
        print("Touch Cancelled")
        sender:setScale(1)
    end
end

function ClubJoinLayer:touchInputBgEvent(sender, eventType)
    if eventType == ccui.TouchEventType.ended then
        self.editBox:touchDownAction(self.editBox, 2)
    end
end

function ClubJoinLayer:showCreateLayer()
    self:refrushButton("create")
    self.joinView_:setVisible(false)
    if bole:getClubManage():isInClub() then
        bole:popMsg( { msg = "you have joined a club", title = "join", cancle = false }, function() bole:postEvent("openClubLayer") return end)
        return
    end
    if self.createView_ == nil then
        self.createView_ = bole:getUIManage():createNewUI("ClubCreateLayer","club","app.views.club",nil,false)
        self.createView_:setPosition(0,0)
        self.node_View_:addChild(self.createView_)
    end
    self.createView_:setVisible(true)
end

function ClubJoinLayer:showJoinLayer()
    self:refrushButton("join")
    self.joinView_:setVisible(true)
    if self.createView_ ~= nil then
        self.createView_:setVisible(false)
    end
end

function ClubJoinLayer:searchClub()
    local txt = self.editBox:getText()
    if txt == "" then
        bole:popMsg({msg ="no search club." , title = "search" , cancle = false})
        return
    end

    if string.len(txt) > 15 then
        bole:popMsg({msg ="no search club." , title = "search" , cancle = false})
        return
    end

    bole.socket:send("search_club_by_name", { search_name = self.editBox:getText() }, true)
end



function ClubJoinLayer:applyJoiningClub(data)
    data = data.result
    for k, v in pairs(self.list_join:getItems()) do
        if tonumber(v.id) == tonumber(data) then
            v:refreshStatus()
        end
    end
end

function ClubJoinLayer:refreshSearchClubInfo(data)
    data = data.result
    for k, v in pairs(self.list_join:getItems()) do
        if v.id == data.id then
            v:refreshClubInfo(data)
        end
    end
end

function ClubJoinLayer:search_club_by_name(t, data)
    if t == "search_club_by_name" then
        local searchClubTable = data.result
        if #searchClubTable == 0 then
            bole:popMsg({msg ="no search club." , title = "search" , cancle = false})
        else
            self.list_join:removeAllChildren()
            self.r_clubs = searchClubTable
            for k, v in ipairs(searchClubTable) do
                if self.appliedList_[v.id] == 1 then
                    v.applied = 1
                end
                if self.inviterList_[v.id] == 1 then
                    v.applied = nil
                    v.inviter = 1
                end
                local cell = bole:getEntity("app.views.club.ClubJoinCell", v)
                self.list_join:pushBackCustomItem(cell)
                cell.id = v.id
            end
        end
    end
end
function ClubJoinLayer:refrushButton(str)
    self.btn_panel_:getChildByName("btn_join"):setTouchEnabled(true)
    self.btn_panel_:getChildByName("btn_create"):setTouchEnabled(true)

    self.btn_panel_:getChildByName("btn_join_light"):setVisible(false)
    self.btn_panel_:getChildByName("btn_create_light"):setVisible(false)

    self.btn_panel_:getChildByName("btn_" .. str):setTouchEnabled(false)
    self.btn_panel_:getChildByName("btn_" .. str .. "_light"):setVisible(true)
end


function ClubJoinLayer:onExit()
    bole:removeListener("applyJoiningClub", self)
    bole:removeListener("refreshSearchClubInfo", self)
    bole:removeListener("initRecommendClubInfo", self)
    bole:removeListener("closeClubJoinLayer", self)
    bole:removeListener("refreshClubJoinLayer", self)
    bole.socket:unregisterCmd("search_club_by_name")
end

function ClubJoinLayer:adaptScreen(root)
    local winSize = cc.Director:getInstance():getWinSize()
    self:setPosition(0, 0)
    root:setPosition(winSize.width / 2, winSize.height / 2)
end


return ClubJoinLayer


-- endregion
