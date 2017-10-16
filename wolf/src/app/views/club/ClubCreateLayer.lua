--region *.lua
--Date
--此文件由[BabeLua]插件自动生成

local ClubCreateLayer = class("ClubCreateLayer", cc.load("mvc").ViewBase)
ClubCreateLayer.ClubNameMax = 15
ClubCreateLayer.ClubDesMax = 100

local clubMinLevel = bole:getClubManage():getClubLimitLevel()
local clubIcon =  bole:getClubManage():getClubIconIdTable()
function ClubCreateLayer:onCreate()
    print("ClubCreateLayer:onCreate")
    self.root_ = self:getCsbNode():getChildByName("createView")

    self.layerTag_ = "create"
    self.levelIndex_ = 1
    self.clubInfo_ = {}

    self:initClubName()
    self:initClubType()
    self:initClubMiniLevel()
    self:initClubSymbol()
    self:initClubDescription()
    self:initCreateBtn()
    self:initEditBox()
    --self:initSymbolView()
end

function ClubCreateLayer:onEnter()
    bole.socket:registerCmd("modify_club", self.modify_club, self)
    bole.socket:registerCmd("create_club", self.create_club, self)
    bole.socket:registerCmd("check_club_name", self.reCheck_club_name, self)
    bole:addListener("modifyClubLayer", self.modifyClubLayer, self, nil, true)
    bole:addListener("chooseClubSymbol", self.reChooseClubSymbol, self, nil, true)
    bole:addListener("closeClubCreateLayer", self.closeUI , self, nil, true)
end

function ClubCreateLayer:initClubName()
    local clubNameInputBg = self.root_:getChildByName("bg_name_input")
    clubNameInputBg:setTouchEnabled(true)
    clubNameInputBg:addTouchEventListener(handler(self, self.touchEvent))
    self.txt_clubName_ = self.root_:getChildByName("txt_name")
    self.nameInputError_ = self.root_:getChildByName("bg_name_input_error")
    self.nameInputError_:setVisible(false)
    self.panel_error_ = self.root_:getChildByName("panel_error")
    self.panel_error_:setVisible(false)
    self.txt_clubName_:setString("")
    self.clubInfo_.name = ""
end

function ClubCreateLayer:initClubType()
    local panel_clubType = self.root_:getChildByName("panel_clubType")
    local btn_type_left = panel_clubType:getChildByName("btn_type_left")
    btn_type_left:addTouchEventListener(handler(self, self.touchEvent))
    local btn_type_right = panel_clubType:getChildByName("btn_type_right")
    btn_type_right:addTouchEventListener(handler(self, self.touchEvent))
    self.txt_type_ = panel_clubType:getChildByName("txt_type")
    self.txt_type_:setString("Anyone can join")
    self.clubInfo_.qualification = 0
end

function ClubCreateLayer:initClubMiniLevel()
    local panel_clubType = self.root_:getChildByName("panel_clubMiniLevel")
    local btn_cml_left = panel_clubType:getChildByName("btn_cml_left")
    btn_cml_left:addTouchEventListener(handler(self, self.touchEvent))
    local btn_cml_right = panel_clubType:getChildByName("btn_cml_right")
    btn_cml_right:addTouchEventListener(handler(self, self.touchEvent))
    self.txt_level_ = panel_clubType:getChildByName("txt_level")
    self.txt_level_:setString("0")
    self.clubInfo_.require_level = 0
end

function ClubCreateLayer:initClubSymbol()
    self.icon_clubSymbol_ = self.root_:getChildByName("icon_clubSymbol") 
    local btn_select = self.root_:getChildByName("btn_select") 
    btn_select:addTouchEventListener(handler(self, self.touchEvent))
    local str,id = bole:getClubManage():getClubRandomIcon()
    self.icon_clubSymbol_:loadTexture(str)
    self.clubInfo_.icon = id
end

function ClubCreateLayer:initClubDescription()
    local clubDescriptionInputBg = self.root_:getChildByName("bg_description_input")
    self.clubInfo_.description = ""

    self.textListView_ = self.root_:getChildByName("textListView")
    self.textListView_:setScrollBarOpacity(0)
    self.txt_description_ = cc.Label:createWithTTF("", "font/bole_ttf.ttf", 30)
    self.txt_description_:setDimensions(410,0)
    self.txt_description_:setTextColor({ r = 255, g = 255, b = 255} )
    self.txt_description_:setAnchorPoint(0,1)
    self.textListView_:addChild(self.txt_description_)
    self.textListView_:addTouchEventListener(handler(self, self.touchTextListViewEvent))
end

function ClubCreateLayer:initCreateBtn()
    local btn_createClub = self.root_:getChildByName("btn_createClub")
    btn_createClub:addTouchEventListener(handler(self, self.touchEvent))
    if bole:getUserDataByKey("coins") < 2000000 then
        btn_createClub:setBright(false)
        btn_createClub:setTouchEnabled(true)
    end
    self.btn_createClub_ = btn_createClub
end

function ClubCreateLayer:initSymbolView()
    self.panel_symbol_ = self.root_:getChildByName("panel_symbol")
    self.panel_symbol_:setVisible(false)
    self.symbolView_ = self.panel_symbol_:getChildByName("ScrollView")
    --self.symbolView_:setScrollBarOpacity(0)
    local iconNum = # clubIcon
    local height = math.ceil(iconNum / 4) * 120 
    self.symbolView_:setInnerContainerSize(cc.size(480, height))
    for i = 1, iconNum do
        local path = bole:getClubManage():getClubIconPath(clubIcon[i])
        local icon = ccui.ImageView:create(path)
        self.symbolView_:addChild(icon)
        icon:setScale(0.42)
        icon:setAnchorPoint(0,0)
        icon:setTouchEnabled(true)
        icon:addTouchEventListener(handler(self, self.chooseClubIcon))
        icon:setTag(i)
        if i % 4 == 0 then 
            icon:setPosition( 3 * 120, height - math.ceil(i / 4) * 120 )
        else
            icon:setPosition(( math.ceil(i % 4) - 1) * 120, height - math.ceil(i / 4) * 120 )
        end
    end
    self.symbolView_:setInnerContainerSize(cc.size(480, math.ceil(iconNum / 4) * 120 ))
end

function ClubCreateLayer:chooseClubIcon(sender, eventType)
    if eventType == ccui.TouchEventType.ended then
        local id = clubIcon[sender:getTag()]
        self.clubInfo_.icon = id
        self.panel_symbol_:setVisible(false)
        self.icon_clubSymbol_:loadTexture(bole:getClubManage():getClubIconPath(id))
    end
end

function ClubCreateLayer:showClubSymbolView()
    self.panel_symbol_:setScale(0)
    self.panel_symbol_:setVisible(true)
    self.panel_symbol_:runAction(cc.ScaleTo:create(0.2,1,1))
end

function ClubCreateLayer:modifyClubLayer(data)
    local clubInfo = data.result
    local winSize = cc.Director:getInstance():getWinSize()
    self.root_:setPosition(winSize.width / 2, winSize.height / 2)

    local bg = self.root_:getChildByName("bg")
    bg:setVisible(true)
    local btn_close = bg:getChildByName("btn_close")
    btn_close:addTouchEventListener(handler(self, self.touchEvent))

    self.root_:getChildByName("bg_name_input"):setTouchEnabled(false)
    self.clubInfo_.name = clubInfo.name
    self.clubInfo_.description = clubInfo.description 
    self.clubInfo_.qualification = tonumber(clubInfo.qualification)
    self.clubInfo_.icon = clubInfo.icon
    self.clubInfo_.require_level = tonumber(clubInfo.require_level)

    self.txt_clubName_:setString(self.clubInfo_.name)
    self.editBox_name_:setText(self.clubInfo_.name)
    self:setEditTxt(self.clubInfo_.description)
    self.editBox_des_:setText(self.clubInfo_.description)

    if self.clubInfo_.qualification  == 0 then
        self.txt_type_:setString("Anyone can join")
    elseif self.clubInfo_.qualification  == 1 then
        self.txt_type_:setString("Invite Only")
    end

    self.icon_clubSymbol_:loadTexture(bole:getClubManage():getClubIconPath(self.clubInfo_.icon))
    self.txt_level_:setString(self.clubInfo_.require_level)
    for i = 1, #clubMinLevel do
        if clubMinLevel[i] == self.clubInfo_.require_level then
            self.levelIndex_ = i
        end
    end
    self.btn_createClub_:getChildByName("text1"):setString("Modify Club")
    self.btn_createClub_:getChildByName("text1"):setPosition(187,35)
    self.btn_createClub_:getChildByName("text_m"):setVisible(false)
    self.btn_createClub_:getChildByName("Image"):setVisible(false)

    self.btn_createClub_:setTouchEnabled(true)

    self.btn_createClub_:setBright(true)
    self.layerTag_ = "modify" 
end

function ClubCreateLayer:initEditBox()
    local editBoxPanel = self.root_:getChildByName("editBoxPanel")
    self.editBox_name_ = ccui.EditBox:create(cc.size(100,10),"loadImage/editBox_bg.png")
    self.editBox_name_:setAnchorPoint(0,0)
    self.editBox_name_:setInputMode(cc.EDITBOX_INPUT_MODE_SINGLELINE)
    self.editBox_name_:setInputFlag(cc.EDITBOX_INPUT_FLAG_INITIAL_CAPS_WORD)
    self.editBox_name_:setMaxLength(ClubCreateLayer.ClubNameMax)
    self.editBox_name_:setPosition(44,400)
    --self.editBox_name_:setReturnType(cc.KEYBOARD_RETURNTYPE_SEND )
    self.editBox_name_:registerScriptEditBoxHandler(handler(self, self.editBoxHandEvent))
    self.editBox_name_:setFontSize(0.001)
    self.editBox_name_:setName("editBox_name")
    editBoxPanel:addChild(self.editBox_name_)

    self.editBox_des_ = ccui.EditBox:create(cc.size(100,10),"loadImage/editBox_bg.png")
    self.editBox_des_:setAnchorPoint(0,0)
    self.editBox_des_:setInputMode(cc.EDITBOX_INPUT_MODE_SINGLELINE)
    self.editBox_des_:setInputFlag(cc.EDITBOX_INPUT_FLAG_INITIAL_CAPS_WORD)
    self.editBox_des_:setMaxLength(ClubCreateLayer.ClubDesMax)
    self.editBox_des_:setPosition(750,84)
    --self.editBox_des_:setReturnType(cc.KEYBOARD_RETURNTYPE_SEND )
    self.editBox_des_:registerScriptEditBoxHandler(handler(self, self.editBoxHandEvent))
    self.editBox_des_:setFontSize(0.001)
    self.editBox_des_:setName("editBox_des")
    editBoxPanel:addChild(self.editBox_des_)
end

function ClubCreateLayer:setEditTxt(txt)
    self.txt_description_:setString(bole:getNewStr(txt, 30, 410))
    local size = self.txt_description_:getContentSize()
    self.textListView_:setInnerContainerSize(cc.size(410, math.max(size.height, 170)))
    self.txt_description_:setPosition(0,math.max(size.height, 170))
    self.textListView_:scrollToTop(0,true)
end


function ClubCreateLayer:touchEvent(sender, eventType)
    local name = sender:getName()
    if eventType == ccui.TouchEventType.began then
        if name ~= "bg_name_input" and name ~= "bg_description_input" then
            sender:runAction(cc.ScaleTo:create(0.1, 1.02, 1.02))
        end
    elseif eventType == ccui.TouchEventType.moved then

    elseif eventType == ccui.TouchEventType.ended then
        if name ~= "bg_name_input" and name ~= "bg_description_input" then
            sender:runAction(cc.ScaleTo:create(0.1, 1, 1))
        end
        if name == "btn_createClub" then
            if self.layerTag_ == "create" then
                self:createClub()
            elseif self.layerTag_ == "modify" then
                self:modifyClub()
            end
        elseif name == "btn_type_left" then
            self:changeType("type", 0)
        elseif name == "btn_type_right" then
            self:changeType("type", 1)
        elseif name == "btn_cml_left" then
            self:changeType("cml", 0)
        elseif name == "btn_cml_right" then
            self:changeType("cml", 1)
        elseif name == "bg_name_input" then
            self.editBox_name_:touchDownAction(self.editBox_name_, 2)
        elseif name == "bg_description_input" then
            self.editBox_des_:touchDownAction(self.editBox_name_, 2)
        elseif name == "btn_close" then
            self:closeUI()
        elseif name == "btn_select" then
            bole:getUIManage():openNewUI("ClubSymbolLayer",true,"club","app.views.club")
            bole:postEvent("initClubSymbolInfo",self.clubInfo_.icon)
        end
        
    elseif eventType == ccui.TouchEventType.canceled then
        if name ~= "bg_name_input" and name ~= "bg_description_input" then
            sender:runAction(cc.ScaleTo:create(0.1, 1, 1))
        end
    end
end

function ClubCreateLayer:touchTextListViewEvent(sender,eventType)
    local name = sender:getName()
    if eventType == ccui.TouchEventType.began then
        self.moved_ = 0
    elseif eventType == ccui.TouchEventType.moved then
        self.moved_ = self.moved_ + 1
    elseif eventType == ccui.TouchEventType.ended then
        if self.moved_ < 5 then
            if name == "textListView" then
                 self.editBox_des_:touchDownAction(self.editBox_name_, 2)
            end
        end
        self.moved_ = 0
    elseif eventType == ccui.TouchEventType.canceled then
    end
end

function ClubCreateLayer:editBoxHandEvent(eventName,sender)
    local name = sender:getName()
    if eventName == "began" then

    elseif eventName == "ended" then

    elseif eventName == "return" then
        local txt = sender:getText()
        if name == "editBox_name" then
            self.txt_clubName_:setString(txt)
            self.clubInfo_.name = txt
            self:checkClubName()
        elseif name == "editBox_des" then
            self:setEditTxt(txt)
            self.textListView_:scrollToBottom(0,true)
            self.clubInfo_.description = txt
        end
    elseif eventName == "changed" then
        local txt = sender:getText()
        if name == "editBox_name" then
            if txt ~= self.clubInfo_.name then
                self.nameInputError_:setVisible(false)
                self.panel_error_:setVisible(false)
            end
            self.txt_clubName_:setString(txt)
            self.clubInfo_.name = txt
        elseif name == "editBox_des" then
            self:setEditTxt(txt)
            self.textListView_:scrollToBottom(0,true)
            self.clubInfo_.description = txt
        end
    end
end

function ClubCreateLayer:checkClubName()
    bole.socket:send("check_club_name", {name = self.clubInfo_.name})
end

function ClubCreateLayer:reCheck_club_name(t,data)
    if data.error == 0 then
        self.nameInputError_:setVisible(false)
        self.panel_error_:setVisible(false)
        self.btn_createClub_:setBright(true)
        self.btn_createClub_:setTouchEnabled(true)
        if bole:getUserDataByKey("coins") < 2000000 then
            self.btn_createClub_:setBright(false)
            self.btn_createClub_:setTouchEnabled(true)
        end
    elseif data.error == 2 then
        self.nameInputError_:setVisible(true)
        self.panel_error_:setVisible(true)
        self.btn_createClub_:setBright(false)
        self.btn_createClub_:setTouchEnabled(true)
        if bole:getUserDataByKey("coins") >= 2000000 then
            self.btn_createClub_:setTouchEnabled(false)
        end
        self.panel_error_:getChildByName("txt_name_error"):setString("duplicate name")
    end
end

function ClubCreateLayer:changeType(type,lr)
    if type == "type" then
    --[[
        if lr == 0 then
            self.txt_type_:setString("Anyone can join")
            self.clubInfo_.qualification = 0
        elseif lr == 1 then
            self.txt_type_:setString("Invite Only")
            self.clubInfo_.qualification = 1
        end
    --]]
        if self.clubInfo_.qualification == 0 then
            self.txt_type_:setString("Invite Only")
            self.clubInfo_.qualification = 1
        else
            self.txt_type_:setString("Anyone can join")
            self.clubInfo_.qualification = 0
        end
    end

    if type == "cml" then
        if lr == 0 then    
            if self.levelIndex_ == 1 then
                self.levelIndex_ = #clubMinLevel
            else
                self.levelIndex_ = self.levelIndex_ - 1
            end

            self.txt_level_:setString(clubMinLevel[self.levelIndex_])
            self.clubInfo_.require_level = clubMinLevel[self.levelIndex_]
        elseif lr == 1 then
            if self.levelIndex_ == #clubMinLevel then
                self.levelIndex_ = 1
            else
                self.levelIndex_ = self.levelIndex_ + 1
            end
            self.txt_level_:setString(clubMinLevel[self.levelIndex_])
            self.clubInfo_.require_level = clubMinLevel[self.levelIndex_]
        end
    end

end

function ClubCreateLayer:createClub()
        if bole:getUserDataByKey("coins") < 2000000 then
            bole:getUIManage():openNewUI("ShopLayer",true,"shop_lobby","app.views.shop")
            return
        end

    if self.clubInfo_.name == nil then
        bole:popMsg({msg ="please input club name" , title = "create" , cancle = false})
        return
    end

    if self.clubInfo_.name == "" then
        bole:popMsg({msg ="please input club name" , title = "create" , cancle = false})
        return
    end

    if bole:getClubManage():isInClub() then
        bole:popMsg({msg ="you have joined a club" , title = "create" , cancle = false}, function() bole:postEvent("openClubLayer") return end)
        return
    end

    if not bole:isStrExists(self.clubInfo_.name) then 
        bole:popMsg({msg ="Invalid string!" , title = "create" , cancle = false})
        return
    end

    if string.sub(self.clubInfo_.name, 1, 1) == " " then
        bole:popMsg({msg ="Invalid string!" , title = "create" , cancle = false})
        return
    end

    if string.sub(self.clubInfo_.name, -1, -1) == " " then
        bole:popMsg({msg ="Invalid string!" , title = "create" , cancle = false})
        return
    end

    bole.socket:send("create_club", self.clubInfo_)
end

function ClubCreateLayer:modifyClub()
    self.clubInfo_.name = nil
    bole.socket:send("modify_club", self.clubInfo_)
end

function ClubCreateLayer:modify_club(t,data)
    if t == "modify_club" then
        bole:postEvent("modifyClub",  self.clubInfo_)
        self:closeUI()
    end
end

function ClubCreateLayer:reChooseClubSymbol(data)
    data = data.result
    self.clubInfo_.icon = data
    self.icon_clubSymbol_:loadTexture(bole:getClubManage():getClubIconPath(self.clubInfo_.icon))
end

function ClubCreateLayer:create_club(t,data)
        if data.error == 2 then --已经加入公会
            bole:popMsg({msg ="you have joined a club." , title = "join" , cancle = false}, function() bole:postEvent("openClubLayer") return end)
        elseif data.error == 3 then --钱不够
            bole:popMsg({msg ="Don't have enough coins" , title = "create_club" , cancle = false})
        elseif data.error == 4 then --重名
            bole:popMsg({msg ="duplication of name" , title = "create_club" , cancle = false})  
        elseif data.error ~= nil then
            bole:popMsg({msg ="error:" .. data.error , title = "create_club" , cancle = false})
        elseif data.id ~= nil then
            bole:getAppManage():addCoins(-2000000)
            bole:getClubManage():setClubInfo(data)
            dump(data,"data")
            bole:postEvent("openClubLayer",data) 
        end
end


function ClubCreateLayer:onExit()
    bole.socket:unregisterCmd("modify_club")
    bole.socket:unregisterCmd("create_club")
    bole.socket:unregisterCmd("check_club_name")
    bole:removeListener("closeClubCreateLayer", self)
    bole:removeListener("modifyClubLayer", self)
    bole:removeListener("chooseClubSymbol", self) 
end


--[[
function ClubCreateLayer:onCreate()
    print("ClubCreateLayer:onCreate")
    self.root_ = self:getCsbNode():getChildByName("root")
    self.panel_btn_ = self.root_:getChildByName("Panel_btn"):getChildByName("Panel_con")
    self.rootTitle_ = self.root_:getChildByName("Text_title")
    self.rootTitle_:setString("Create Club")

    self.name_ = self.panel_btn_:getChildByName("btn_name")
    self.des_ = self.panel_btn_:getChildByName("btn_des")
    self.symbol_ = self.panel_btn_:getChildByName("btn_symbol")
    self.type_ = self.panel_btn_:getChildByName("btn_type")
    self.minJoin_ = self.panel_btn_:getChildByName("btn_minJoin")
    self.panel_input_ = self.root_:getChildByName("Panel_btn"):getChildByName("Panel_input")

    self.touchPanel_ = self.root_:getChildByName("Panel_touch")
    self.touchPanel_:addTouchEventListener(handler(self, self.touchEvent))
    self.touchPanel_:setVisible(false)

    self.btn_close_ = self.root_:getChildByName("btn_close")
    self.btn_create_ = self.panel_btn_:getChildByName("btn_create")
    self.btn_close_:addTouchEventListener(handler(self, self.touchEvent))
    self.btn_create_:addTouchEventListener(handler(self, self.touchEvent))
    self.btn_create_:setBright(false)
    self.btn_create_:setTouchEnabled(false)
      if bole:getUserDataByKey("coins") < 2000000 then
            self.btn_create_:setBright(false)
            self.btn_create_:setTouchEnabled(true)
        end
    self.symbolPanel_ =  self.root_:getChildByName("Panel_symbol")
    self.typePanel_ =  self.root_:getChildByName("Panel_type")
    self.minJoinPanel_ =  self.root_:getChildByName("Panel_minJoin")


    self.btn_symbol_P_ = self:getCsbNode():getChildByName("btn_symbol_P")
    self.btn_symbol_P_ :addTouchEventListener(handler(self, self.btn_P_touchEvent))
    self.btn_symbol_P_:setVisible(false)
    self.btn_minJoin_P_ = self:getCsbNode():getChildByName("btn_minJoin_P")
    self.btn_minJoin_P_ :addTouchEventListener(handler(self, self.btn_P_touchEvent))
    self.btn_minJoin_P_:setVisible(false)

    --记录club信息
    self.clubInfo_={}
    self.clubInfo_.type = 0
    self.clubInfo_.symbolId = 1
    self.clubInfo_.lv = 0
    self.levelTable_={}
    local levelTable = bole:getConfigCenter():getConfig("foundclub", nil, nil)
    for k ,v in pairs(levelTable) do
       table.insert(self.levelTable_, # self.levelTable_ + 1, tonumber(k))
    end
    table.sort(self.levelTable_)

    self.layerTag_ = "create" 

    self:initName()
    self:initDescription()
    self:initSymbol()
    self:initType()
    self:initMinJoin()
    self:initPanel_input()
    self:initEditBox()

    self:adaptScreen()

end


function ClubCreateLayer:onEnter()
    bole.socket:registerCmd("modify_club", self.modify_club, self)
    bole.socket:registerCmd("create_club", self.create_club, self)
    bole:addListener("modifyClubLayer", self.modifyClubLayer, self, nil, true)
    bole:addListener("closeClubCreateLayer", self.closeUI , self, nil, true)
end

function ClubCreateLayer:reModifyClub(data)
    self:modifyClubLayer(data.result)
end

function ClubCreateLayer:modifyClubLayer(clubInfo)
    clubInfo = clubInfo.result
    self.rootTitle_:setString("Modify Club")
    self.name_:setTouchEnabled(false)
    self.clubInfo_.name = clubInfo.name
    self.clubInfo_.des = clubInfo.description 
    self.clubInfo_.type = tonumber(clubInfo.qualification)
    self.clubInfo_.symbolId = clubInfo.icon
    self.clubInfo_.lv = tonumber(clubInfo.require_level)

    self.nameContent_:setString(self.clubInfo_.name)

    if self.clubInfo_.des == nil then
        self.clubInfo_.des = "Enjoy the Game!"
    end

    if string.len(self.clubInfo_.des) > 10 then
        self.desContent_:setString( string.sub(self.clubInfo_.des,1,10) .. "...")
    else
        self.desContent_:setString(self.clubInfo_.des)
    end
    self.editBox_des_:setText(self.clubInfo_.des)

    if self.clubInfo_.type  == 0 then
        self.typeText_:setString("Anyone can join")
    elseif self.clubInfo_.type  == 1 then
        self.typeText_:setString("Invite only")
    end

    self.symbolIcon_:loadTexture(bole:getClubManage():getClubIconPath(self.clubInfo_.symbolId))
    self.showLv_:setString(self.clubInfo_.lv)
    self.btn_create_:getChildByName("text1"):setString("Modify")
    self.btn_create_:setTouchEnabled(true)
    self.btn_create_:setBright(true)
    self.layerTag_ = "modify" 
end

function ClubCreateLayer:initName()
    self.name_:getChildByName("title"):setString("Club Name")
    self.nameContent_ = self.name_:getChildByName("content")
    self.nameContent_:setString("")
    self.name_:addTouchEventListener(handler(self, self.touchEvent))
end

function ClubCreateLayer:initDescription()
    self.des_:getChildByName("title"):setString("Description")
    self.desContent_ = self.des_:getChildByName("content")
    self.desContent_:setString("")
    self.des_:addTouchEventListener(handler(self, self.touchEvent))
end

function ClubCreateLayer:initSymbol()
    self.symbol_:getChildByName("title"):setString("Symbol")
    self.symbol_:addTouchEventListener(handler(self, self.touchEvent))
    self.symbolPanel_:getChildByName("btn_symbol_ok"):addTouchEventListener(handler(self, self.touchEvent))

    self.symbolIcon_ = self.symbol_:getChildByName("symbol")
    local str,id = bole:getClubManage():getClubRandomIcon()
    self.symbolIcon_:loadTexture(str)
    self.clubInfo_.symbolId = id
    --self.showSymbolId_ = id

    local clubiconList = bole:getConfigCenter():getConfig("clubicon")
    local iconList = {}
    for k ,v in pairs(clubiconList) do
        table.insert(iconList, # iconList + 1, tonumber(k))
    end
    table.sort(iconList)
    local scrollView = self.symbolPanel_:getChildByName("ScrollView")
    for i = 1, # iconList do
        local widget = self.btn_symbol_P_:clone()
        widget:setTag(iconList[i])
        widget:setVisible(true)
        widget:getChildByName("symbol"):loadTexture(bole:getClubManage():getClubIconPath(iconList[i]))
        scrollView:addChild(widget)
        if i % 4 == 0 then 
            widget:setPosition( 3 * 120, 360 - math.ceil(i / 4) * 120 )
        else
            widget:setPosition(( math.ceil(i % 4) - 1) * 120, 360 - math.ceil(i / 4) * 120 )
        end

--        if tonumber(iconList[i]) == id then
--            self.preSymbol_ = widget
--        end
        
    end
end

function ClubCreateLayer:initType()
    self.type_:getChildByName("title"):setString("Club Type")
    self.type_:getChildByName("content"):setString("Anyone can join")
    self.type_:addTouchEventListener(handler(self, self.touchEvent))
    self.typeText_ = self.type_:getChildByName("content")
    self.typePanel_:getChildByName("btn_1"):addTouchEventListener(handler(self, self.touchEvent))
    self.typePanel_:getChildByName("btn_2"):addTouchEventListener(handler(self, self.touchEvent))
end   

function ClubCreateLayer:initMinJoin()
    self.minJoin_:getChildByName("title"):setString("Min.Fame to Join")
    self.showLv_ = self.minJoin_:getChildByName("lv_txt")
    self.showLv_:setString("0")
    self.minJoin_:addTouchEventListener(handler(self, self.touchEvent))
    self.minJoinPanel_:getChildByName("btn_minJoin_ok"):addTouchEventListener(handler(self, self.touchEvent))
    self.showLvNum_ = 0
    local listView = self.minJoinPanel_:getChildByName("ListView")
    for i = 1, #self.levelTable_ do
        local widget = self.btn_minJoin_P_:clone()
        widget:setTag(i)
        widget:setVisible(true)
        widget:getChildByName("lv"):setString(self.levelTable_[i])
        listView:addChild(widget)
        if i == 1 then
            self.preMinJoin_ = widget
        end
    end
end

function ClubCreateLayer:initPanel_input()
    self.isOpenEditPanel_ = false
    self.editNamePanel_ = self.panel_input_:getChildByName("Panel_name")
    self.editDesPanel_ = self.panel_input_:getChildByName("Panel_des")
    self.editNamePanel_:getChildByName("btn_edit_name_ok"):addTouchEventListener(handler(self, self.touchEvent))
    self.editNamePanel_:getChildByName("btn_quxiao"):addTouchEventListener(handler(self, self.touchEvent))
    self.editDesPanel_:getChildByName("btn_edit_des_ok"):addTouchEventListener(handler(self, self.touchEvent))
end


function ClubCreateLayer:btn_P_touchEvent(sender, eventType)
   local name = sender:getName()
   local tag = sender:getTag()
   if eventType == ccui.TouchEventType.began then
        sender:runAction(cc.ScaleTo:create(0.1, 1.02, 1.02))
    elseif eventType == ccui.TouchEventType.moved then

    elseif eventType == ccui.TouchEventType.ended then
        sender:runAction(cc.ScaleTo:create(0.1, 1, 1))
        if name == "btn_minJoin_P" then
            self.clubInfo_.lv = self.levelTable_[tonumber(tag)]
            self.showLv_:setString(self.clubInfo_.lv)
        elseif name == "btn_symbol_P" then
            self.clubInfo_.symbolId = tonumber(tag)
            self.symbolIcon_:loadTexture(bole:getClubManage():getClubIconPath(self.clubInfo_.symbolId))
        end
        self.touchPanel_:setVisible(false)
        self.symbolPanel_:setVisible(false)
        self.minJoinPanel_:setVisible(false)
    elseif eventType == ccui.TouchEventType.canceled then
        sender:runAction(cc.ScaleTo:create(0.1, 1, 1))
    end

end


function ClubCreateLayer:touchEvent(sender, eventType)
   local name = sender:getName()
   if eventType == ccui.TouchEventType.began then
        sender:runAction(cc.ScaleTo:create(0.1, 1.02, 1.02))
    elseif eventType == ccui.TouchEventType.moved then

    elseif eventType == ccui.TouchEventType.ended then
        sender:runAction(cc.ScaleTo:create(0.1, 1, 1))
        if name == "btn_close" then
            if self.isOpenEditPanel_ then
                self:closeEditPanel()
            else 
                self:closeUI()
            end
        elseif name == "btn_create" then 
            if self.layerTag_ == "create" then
                self:createClub()
            elseif self.layerTag_ == "modify" then
                self:modifyClub()
            end
        elseif name == "btn_name" then 
            self:openEditPanel("name")
            self.editBox_name_:touchDownAction(self.editBox_name_, 2)
        elseif name == "btn_des" then 
            self:openEditPanel("des")
            self.editBox_des_:touchDownAction(self.editBox_name_, 2) 
        elseif name == "btn_symbol" then 
            self:openSymbol()
        elseif name == "btn_type" then 
            self:openType()
        elseif name == "btn_minJoin" then 
            self:openMinJoin()
        elseif name == "Panel_touch" then 
            if self.symbolPanel_:isVisible() then
                self.symbolPanel_:setVisible(false)
            end
            if self.typePanel_:isVisible() then
                self.typePanel_:setVisible(false)
            end
            if self.minJoinPanel_:isVisible() then
                self.minJoinPanel_:setVisible(false)
            end
            self.touchPanel_:setVisible(false)
        elseif name == "btn_1" then 
            self:changeType(0)
        elseif name == "btn_2" then 
            self:changeType(1)
        elseif name == "btn_minJoin_ok" then 
            self.minJoinPanel_:setVisible(false)
            self.touchPanel_:setVisible(false)
            self.clubInfo_.lv = self.showLvNum_
            self.showLv_:setString(self.clubInfo_.lv)
        elseif name == "btn_symbol_ok" then 
            self.symbolPanel_:setVisible(false)
            self.touchPanel_:setVisible(false)
            self.clubInfo_.symbolId = self.showSymbolId_
            self.symbolIcon_:loadTexture(bole:getClubManage():getClubIconPath(self.clubInfo_.symbolId))
        elseif name == "btn_edit_name_ok" then 
            local str = self.editBox_name_:getText()
            self.clubInfo_.name = str
            self.nameContent_:setString(str)
            self:closeEditPanel()
        elseif name == "btn_quxiao" then 
            self.editBox_name_:setText("")
            self.nameLabel_:setText("")
        elseif name == "btn_edit_des_ok" then 
            local str = self.editBox_des_:getText()
            self.clubInfo_.des = str
            if string.len(str) > 10 then
                self.desContent_:setString( string.sub(str,1,10) .. "...")
            else
                self.desContent_:setString(str)
            end
            self:closeEditPanel()
        end 

    elseif eventType == ccui.TouchEventType.canceled then
        sender:runAction(cc.ScaleTo:create(0.1, 1, 1))
    end
end

function ClubCreateLayer:openEditPanel(type)
    self.isOpenEditPanel_ = true
    self.editNamePanel_:setVisible(false)
    self.editDesPanel_:setVisible(false)
    if type == "name" then
        self.editNamePanel_:setVisible(true)
        self.rootTitle_:setString("Club Name")
    elseif type == "des" then
        self.editDesPanel_:setVisible(true)
        self.rootTitle_:setString("Description")
    end
    self.panel_btn_:stopAllActions()
    self.panel_input_:stopAllActions()
    self.panel_btn_:runAction(cc.MoveTo:create(0.2,cc.p(-670,0)))
    self.panel_input_:runAction(cc.MoveTo:create(0.2,cc.p(0,0)))
end

function ClubCreateLayer:closeEditPanel()
    self.isOpenEditPanel_ = false
    self.panel_btn_:stopAllActions()
    self.panel_input_:stopAllActions()
    self.panel_btn_:runAction(cc.MoveTo:create(0.2,cc.p(0,0)))
    self.panel_input_:runAction(cc.MoveTo:create(0.2,cc.p(670,0)))  

    if self.layerTag_ == "create" then
        self.rootTitle_:setString("Create Club")
    elseif self.layerTag_ == "modify" then
        self.rootTitle_:setString("Modify Club")
    end

    self.editBox_name_:setText(self.clubInfo_.name)
    self.editBox_des_:setText(self.clubInfo_.des)
    self.nameLabel_:setString(self.clubInfo_.name)
    self.desLabel_ :setString(self.clubInfo_.des)

    if self.clubInfo_.name == "" then
        self.btn_create_:setBright(false)
        self.btn_create_:setTouchEnabled(false)
    else
        self.btn_create_:setBright(true)
        self.btn_create_:setTouchEnabled(true)
    end

    if self.clubInfo_.name == nil then 
        self.btn_create_:setBright(false)
        self.btn_create_:setTouchEnabled(false)
    end

    if self.layerTag_ == "create"  then
        if bole:getUserDataByKey("coins") < 2000000 then
            self.btn_create_:setBright(false)
            self.btn_create_:setTouchEnabled(true)
        end
    end
end

function ClubCreateLayer:openSymbol()
    self.touchPanel_:setVisible(true)
    self.symbolPanel_:setVisible(true)
    self.symbolPanel_:setScale(0.1)
    self.symbolPanel_:runAction(cc.ScaleTo:create(0.2,1,1))
end

function ClubCreateLayer:openType()
    self.touchPanel_:setVisible(true)
    self.typePanel_:setVisible(true)
    self.typePanel_:setScale(0.1)
    self.typePanel_:runAction(cc.ScaleTo:create(0.2,1,1))
end

function ClubCreateLayer:openMinJoin()
    self.touchPanel_:setVisible(true)
    self.minJoinPanel_:setVisible(true)
    self.minJoinPanel_:setScale(0.1)
    self.minJoinPanel_:runAction(cc.ScaleTo:create(0.2,1,1))
end

function ClubCreateLayer:changeType(type)
    if self.typePanel_:isVisible() then
        self.typePanel_:setVisible(false)
    end
    if type == 0 then
        self.typeText_:setString("Anyone can join")
    elseif type == 1 then
        self.typeText_:setString("Invite only")
    end
    self.clubInfo_.type = type
    self.touchPanel_:setVisible(false)
end

function ClubCreateLayer:editBoxHandEvent(eventName,sender)
    local name = sender:getName()
    if eventName == "began" then
        self.editBoxTouchPanel_:setVisible(true)
    elseif eventName == "ended" then
        local function func()
            self.editBoxTouchPanel_:setVisible(false)
        end
        local delay = cc.DelayTime:create(0.2)
        local sequence = cc.Sequence:create(delay, cc.CallFunc:create(func))
        self.editBoxTouchPanel_:runAction(sequence)
    elseif eventName == "return" then
        if name == "editBox_name" then
            self.nameLabel_:setString(sender:getText())
        elseif name == "editBox_des" then
            self:refreshEditBox(sender:getText())
        end
        self.editBoxTouchPanel_:setVisible(false)
    elseif eventName == "changed" then
        if name == "editBox_name" then
            self.nameLabel_:setString(sender:getText())
        elseif name == "editBox_des" then
            self:refreshEditBox(sender:getText())
        end
    end
end

function ClubCreateLayer:refreshEditBox(text)
    self.desLabel_:setString(text)
    local height = self.desLabel_:getContentSize().height
    if self.textTag_ ~= height / 35 then
        self.desScrollView_:setInnerContainerSize(cc.size(630, math.max(2, height / 35) * 37))
        self.desScrollView_:jumpToBottom()
        self.desLabel_ :setPosition(0, math.max(2, height / 35) * 37)
    end
    self.textTag_ = height / 35
end


function ClubCreateLayer:initEditBox()
    local editBoxPanel = self.root_:getChildByName("editBoxPanel")
    self.editBox_name_ = ccui.EditBox:create(cc.size(100,10),"chat/chat_input.png")
    self.editBox_name_:setAnchorPoint(0,0)
    self.editBox_name_:setInputMode(cc.EDITBOX_INPUT_MODE_SINGLELINE)
    self.editBox_name_:setMaxLength(ClubCreateLayer.ClubNameMax)
    self.editBox_name_:setPosition(0,500)
    --self.editBox_name_:setReturnType(cc.KEYBOARD_RETURNTYPE_SEND )
    self.editBox_name_:registerScriptEditBoxHandler(handler(self, self.editBoxHandEvent))
    self.editBox_name_:setFontSize(0.001)
    self.editBox_name_:setName("editBox_name")
    editBoxPanel:addChild(self.editBox_name_)

    self.editBox_des_ = ccui.EditBox:create(cc.size(100,10),"chat/chat_input.png")
    self.editBox_des_:setAnchorPoint(0,0)
    self.editBox_des_:setInputMode(cc.EDITBOX_INPUT_MODE_SINGLELINE)
    self.editBox_des_:setMaxLength(ClubCreateLayer.ClubDesMax)
    self.editBox_des_:setPosition(0,500)
    --self.editBox_des_:setReturnType(cc.KEYBOARD_RETURNTYPE_SEND )
    self.editBox_des_:registerScriptEditBoxHandler(handler(self, self.editBoxHandEvent))
    self.editBox_des_:setFontSize(0.001)
    self.editBox_des_:setName("editBox_des")
    editBoxPanel:addChild(self.editBox_des_)

    local nameTouchPabel = self.panel_input_:getChildByName("Panel_name")
    nameTouchPabel:addTouchEventListener(handler(self, self.editBoxTouchEvent))
    local desTouchPabel = self.panel_input_:getChildByName("Panel_des")
    desTouchPabel:addTouchEventListener(handler(self, self.editBoxTouchEvent))

    self.nameLabel_ = nameTouchPabel:getChildByName("text")
    self.desLabel_  = cc.Label:createWithTTF("", "font/bole_ttf.ttf", 32)
    self.desLabel_ :setDimensions(630,0)
    self.desLabel_ :setAnchorPoint(0,1)
    self.desLabel_ :setTextColor({ r = 0, g = 0, b = 0})
    self.textTag_ = 1
    self.desScrollView_ = desTouchPabel:getChildByName("textScrollView")
    self.desScrollView_:addTouchEventListener(handler(self, self.inputBoxTouchEvent))
    self.desScrollView_:setScrollBarOpacity(0)
    self.desScrollView_:addChild(self.desLabel_)

    self.editBoxTouchPanel_ = self.root_:getChildByName("editBoxTouchPanel")
    self.editBoxTouchPanel_:setVisible(false)
end

function ClubCreateLayer:inputBoxTouchEvent(sender, eventType)
    if eventType == ccui.TouchEventType.began then
        self.moved_ = 0
    elseif eventType == ccui.TouchEventType.moved then
        self.moved_ = self.moved_ + 1
    elseif eventType == ccui.TouchEventType.ended then
        if  self.moved_ < 8 then
            self.editBox_des_:touchDownAction(self.editBox_des_, 2) 
            self.desScrollView_:scrollToBottom(0,true)
        end
        self.moved_ = 0
    elseif eventType == ccui.TouchEventType.canceled then
    end
end

function ClubCreateLayer:editBoxTouchEvent(sender, eventType)
    local name = sender:getName()
    if eventType == ccui.TouchEventType.ended then
        if name == "Panel_name" then 
            self.editBox_name_:touchDownAction(self.editBox_name_, 2) 
        elseif name == "Panel_des" then 
            self.editBox_des_:touchDownAction(self.editBox_des_, 2) 
        end
    end
end


function ClubCreateLayer:modifyClub()

--    if not bole:getClubManage():isInClub() then
--        bole:popMsg({msg ="you have left your club" , title = "create" , cancle = false})
--        return
--    end

    local clubInfo = {}
    clubInfo.qualification = self.clubInfo_.type
    clubInfo.require_level = tonumber(self.clubInfo_.lv)
    clubInfo.description = self.clubInfo_.des
    clubInfo.icon = tonumber(self.clubInfo_.symbolId)
    bole.socket:send("modify_club", clubInfo)
end

function ClubCreateLayer:createClub()
        if bole:getUserDataByKey("coins") < 2000000 then
            bole:getUIManage():openUI("ShopLayer", true, "shop")
            return
        end

    if self.clubInfo_.name == nil then
        bole:popMsg({msg ="please input club name" , title = "create" , cancle = false})
        return
    end

    if self.clubInfo_.name == "" then
        bole:popMsg({msg ="please input club name" , title = "create" , cancle = false})
        return
    end

    if bole:getClubManage():isInClub() then
        bole:popMsg({msg ="you have joined a club" , title = "create" , cancle = false}, function() bole:postEvent("openClubLayer") return end)
        return
    end

    if not bole:isStrExists(self.clubInfo_.name) then 
        bole:popMsg({msg ="Invalid string!" , title = "create" , cancle = false})
        return
    end

    if string.sub(self.clubInfo_.name, 1, 1) == " " then
        bole:popMsg({msg ="Invalid string!" , title = "create" , cancle = false})
        return
    end

    if string.sub(self.clubInfo_.name, -1, -1) == " " then
        bole:popMsg({msg ="Invalid string!" , title = "create" , cancle = false})
        return
    end

    local clubInfo = {}
    clubInfo.name = self.clubInfo_.name
    clubInfo.qualification = tonumber(self.clubInfo_.type)
    clubInfo.require_level = tonumber(self.clubInfo_.lv)
    clubInfo.description = self.clubInfo_.des
    clubInfo.icon = tonumber(self.clubInfo_.symbolId)
    bole.socket:send("create_club", clubInfo)
end

function ClubCreateLayer:modify_club(t,data)
    if t == "modify_club" then
        bole:postEvent("modifyClub", {icon = self.clubInfo_.symbolId, 
                                      description = self.clubInfo_.des, 
                                      require_level = self.clubInfo_.lv, 
                                      qualification = self.clubInfo_.type})
        self:exit()
    end
end

function ClubCreateLayer:create_club(t,data)
        if data.error == 2 then --已经加入公会
            bole:popMsg({msg ="you have joined a club." , title = "join" , cancle = false}, function() bole:postEvent("openClubLayer") return end)
        elseif data.error == 3 then --钱不够
            bole:popMsg({msg ="Don't have enough coins" , title = "create_club" , cancle = false})
        elseif data.error == 4 then --重名
            bole:popMsg({msg ="duplication of name" , title = "create_club" , cancle = false})  
        elseif data.error ~= nil then
            bole:popMsg({msg ="error:" .. data.error , title = "create_club" , cancle = false})
        elseif data.id ~= nil then
            bole:getAppManage():addCoins(-2000000)
            bole:getClubManage():setClubInfo(data)
            bole:postEvent("openClubLayer",data) 
        end
end

function ClubCreateLayer:exit()
    bole.socket:unregisterCmd("modify_club")
    bole.socket:unregisterCmd("create_club")
    bole:removeListener("modifyClubLayer", self)
    self:closeUI()
end

function ClubCreateLayer:onExit()
    bole.socket:unregisterCmd("modify_club")
    bole.socket:unregisterCmd("create_club")
    bole:removeListener("closeClubCreateLayer", self)
    bole:removeListener("modifyClubLayer", self)
end

function ClubCreateLayer:openKeyboard(sender, eventType)
    local name = sender:getName()
    if eventType == ccui.TouchEventType.ended then
        if name == "inputBg_name" then
            self.editBox_name_:touchDownAction(self.editBox_name_, 2)
        elseif name == "inputBg_des" then
            self.editBox_des_:touchDownAction(self.editBox_des_, 2)
        end
    end
end

function ClubCreateLayer:adaptScreen()
    local winSize = cc.Director:getInstance():getWinSize()
    self.root_:setPosition(winSize.width / 2, winSize.height / 2)
    self:setPosition(0,0)
    self.root_:setScale(0.1)
    self.root_:runAction(cc.ScaleTo:create(0.2,1,1))
end
--]]


return ClubCreateLayer

--endregion
