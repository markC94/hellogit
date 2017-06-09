-- region *.lua
-- Date
-- 此文件由[BabeLua]插件自动生成
local ClubJoinLayer = class("ClubJoinLayer", cc.load("mvc").ViewBase)
function ClubJoinLayer:onCreate()
    print("ClubJoinLayer-onCreate")
    local root = self:getCsbNode():getChildByName("root")
   
    local btn_close = root:getChildByName("btn_close")
    btn_close:addTouchEventListener(handler(self, self.touchEvent))

    local btn_search = root:getChildByName("sp_icon")
    btn_search:addTouchEventListener(handler(self, self.touchEvent))

    local btn_create = root:getChildByName("btn_create")
    btn_create:addTouchEventListener(handler(self, self.touchEvent))
    local node_edit = root:getChildByName("node_edit")
    self:initEditBox(node_edit)
    self.list_join = root:getChildByName("list_join")
end

function ClubJoinLayer:onEnter()
    bole:addListener("applyJoiningClub", self.applyJoiningClub, self, nil, true)
    bole:addListener("applyJoiningClubNow", self.applyJoiningClubNow, self, nil, true)
    bole:addListener("createClubSuccess", self.createClubSuccess, self, nil, false)
    bole.socket:registerCmd("search_club_by_name", self.search_club_by_name, self)
    bole.socket:registerCmd("enter_club_lobby", self.reClub, self)
end

function ClubJoinLayer:reClub(t, data)
    if t == "enter_club_lobby" then
        if data.in_club == 0 then
            --未加入联盟
            bole:postEvent("ClubJoinLayer",data)
        elseif data.in_club == 1 then

        end
    end
end

function ClubJoinLayer:initEditBox(node)
    local function editBoxTextEventHandle(strEventName, pSender)
        local edit = pSender
        local strFmt
        if strEventName == "began" then
            strFmt = string.format("editBox %p DidBegin !", edit)
            print(strFmt)
        elseif strEventName == "ended" then
            strFmt = string.format("editBox %p DidEnd !", edit)
            print(strFmt)
        elseif strEventName == "return" then
            strFmt = string.format("editBox %p was returned !", edit)
            if edit == EditName then
                TTFShowEditReturn:setString("Name EditBox return !")
            elseif edit == EditPassword then
                TTFShowEditReturn:setString("Password EditBox return !")
            elseif edit == EditEmail then
                TTFShowEditReturn:setString("Email EditBox return !")
            end
            print(strFmt)
        elseif strEventName == "changed" then
            strFmt = string.format("editBox %p TextChanged, text: %s ", edit, edit:getText())
            print(strFmt)
        end
    end
    self.editBox = cc.EditBox:create(cc.size(415, 61), "club/club_join_search.png")
    self.editBox:setPosition(0, 0)
    self.editBox:setFont("font/FZKTJW.TTF", 45)
    self.editBox:setFontColor(cc.c3b(0, 0, 0))
    self.editBox:setPlaceHolder("search")
    self.editBox:setMaxLength(30)
    self.editBox:setInputFlag(cc.EDITBOX_INPUT_FLAG_INITIAL_CAPS_WORD)
    self.editBox:setInputMode(cc.EDITBOX_INPUT_MODE_SINGLELINE)
    self.editBox:setReturnType(cc.KEYBOARD_RETURNTYPE_DONE)
    self.editBox:registerScriptEditBoxHandler(editBoxTextEventHandle)
    node:addChild(self.editBox)
end

function ClubJoinLayer:initList(data)
    dump(data,"ClubJoinLayer:initList")
    self.r_clubs=data.r_clubs
    for k,v in ipairs(self.r_clubs) do
        local cell=bole:getEntity("app.views.club.ClubJoinCell",v)
        self.list_join:pushBackCustomItem(cell)
        cell.id = v.id
    end
end

function ClubJoinLayer:updateUI(data)
    self:initList(data.result)
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
        if name== "btn_create" then
            if tonumber(bole:getUserDataByKey("club")) ~= 0 then
                bole:getUIManage():openClubTipsView(10,nil)
                return
            end
            bole:getUIManage():openUI("ClubCreateLayer",true,"csb/club")
        elseif name == "btn_close" then
            self:closeUI()
        elseif name == "sp_icon" then
            local txt =  self.editBox:getText()
            if txt == "" then
                bole:getUIManage():openClubTipsView(12,nil)
                return
            end

            if string.len(txt) > 15 then
                bole:getUIManage():openClubTipsView(12,nil)
                return
            end

            bole.socket:send("search_club_by_name", { search_name = self.editBox:getText() },true)
        end
    elseif eventType == ccui.TouchEventType.canceled then
        print("Touch Cancelled")
        sender:setScale(1)
    end
end

function ClubJoinLayer:applyJoiningClub(data)
    data = data.result
    for k , v in pairs(self.list_join:getItems()) do
        if tonumber(v.id) == tonumber(data) then
            v:refreshStatus()
        end
    end
end

function ClubJoinLayer:applyJoiningClubNow(data)
    data = data.result
    bole:postEvent("openClubLayer", data)
    self:closeUI()
end

function ClubJoinLayer:createClubSuccess(data)
    data = data.result
    bole:postEvent("openClubLayer", data)
    self:closeUI()
end

function ClubJoinLayer:search_club_by_name(t,data)
    if t == "search_club_by_name" then
         local searchClubTable = data.result
         if # searchClubTable == 0 then
              bole:getUIManage():openClubTipsView(12,nil)
         else
            self.list_join:removeAllChildren()
            self.r_clubs = searchClubTable
            for k,v in ipairs(searchClubTable) do
                local cell=bole:getEntity("app.views.club.ClubJoinCell",v)
                self.list_join:pushBackCustomItem(cell)
                cell.id = v.id
            end
         end
    end
end

function ClubJoinLayer:onExit()
    bole:removeListener("applyJoiningClub", self)
    bole:removeListener("createClubSuccess", self)
    bole:removeListener("applyJoiningClubNow", self)
    bole.socket:unregisterCmd("enter_club_lobby")
end


return ClubJoinLayer


-- endregion
