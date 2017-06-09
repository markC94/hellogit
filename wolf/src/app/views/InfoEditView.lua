-- region *.lua
-- Date
-- 此文件由[BabeLua]插件自动生成
local InfoEditView = class("InfoEditView", cc.load("mvc").ViewBase)
local titles = { "Edit Profile", "Edit Signature", "Edit Name", "Edit age", "Edit Gender", "Edit Status", "Edit Country", "Edit City" }
local tips = { "4-30 Characters.", "0-90 Characters.", "4-30 Characters.", "4-30 Characters.", "4-30 Characters.", "4-30 Characters.", "4-30 Characters.", "4-30 Characters." }
local txfs = { "", "enjoy wolf slots.", "", "", "", "", "", "", "" }
local maxs = { 30, 90, 30, 2, 3, 3, 3, 30 }
function InfoEditView:onCreate()
    print("InfoEditView-onCreate")
    local root = self:getCsbNode():getChildByName("root")
    root:setVisible(false)
    root:setScale(0.01)
    local btn_close = root:getChildByName("btn_close")
    btn_close:addTouchEventListener(handler(self, self.touchEvent))
    self.inputIndex = 1
end

function InfoEditView:onEnter()
    bole:addListener("changeInfo", self.changeInfo, self, nil, true)
    bole:addListener("changeSelect", self.changeSelect, self, nil, true)
end

function InfoEditView:onExit()
    bole:getEventCenter():removeEventWithTarget("changeInfo", self)
    bole:getEventCenter():removeEventWithTarget("changeSelect", self)
end

function InfoEditView:changeInfo(event)
    local data = event.result 
    self.info[data.key] = data.value
    for i = 1, 8 do
        local btn = self.scroll:getChildByName("btn_item_" .. i)
        local txt_key = btn:getChildByName("txt_key")
        self:changeKey(txt_key,i)
        self:updateBtnList(btn, i)
    end
    self:sendEditInfo()
end

function InfoEditView:changeSelect(event)
    self.country_index = event.result
    self.img_bg:runAction(cc.ScaleTo:create(0.1, 0.1))
    self.select_country:runAction(cc.Sequence:create(cc.DelayTime:create(0.1), cc.Hide:create()))
    bole:postEvent("changeInfo", { key = 7, value = self.country_index })
end

function InfoEditView:changeKey(key,index)
    if not key then return end
    local _, count = string.gsub(self.info[index], "[^\128-\193]", "aa")
    if count>15 then
        local str=string.sub(self.info[index],1,15).."... ..."
        key:setString(str)
    else
        key:setString(self.info[index])
    end
end
function InfoEditView:sendEditInfo()
    local newInfo = { icon = self.info[1], signature = self.info[2], name = self.info[3], age = tonumber(self.info[4]), gender = tonumber(self.info[5]), marital_status = tonumber(self.info[6]), country = tonumber(self.info[7]), city = self.info[8] }
    bole:getUserData():setData(newInfo)
    bole.socket:send(bole.SERVER_MODIFY_USER, newInfo)
    bole:postEvent("eventInfo",newInfo)
end

function InfoEditView:showInfo(data)
    if not data then
        self:closeUI()
        return
    end
    self.info = { }
    self.info[1] = data.icon
    self.info[2] = data.signature .. ""
    self.info[3] = data.name .. ""
    self.info[4] = data.age
    self.info[5] = data.gender
    self.info[6] = data.marital_status
    self.info[7] = data.country
    self.info[8] = data.city .. ""

    dump(self.info, "showInfo")
    local root = self:getCsbNode():getChildByName("root")
    root:setVisible(true)
    root:runAction(cc.ScaleTo:create(0.2, 1.0))
    self:initUI(root)
    self:registerScriptHandler( function(state)
        if state == "enter" then
            self:onEnter()
        elseif state == "exit" then
            self:onExit()
        end
    end )


end

function InfoEditView:initUI(root)
    self.country_index=bole:getUserDataByKey("country")

    local btn_close = root:getChildByName("btn_close")
    btn_close:addTouchEventListener(handler(self, self.touchEvent))
    btn_close:setPressedActionEnabled(true)
    local clip = root:getChildByName("clip")
    self.scroll = clip:getChildByName("scroll")
    self.txt_name_1 = root:getChildByName("txt_name_1")
    --    cc.loadLua("app.command.ClippingBigNode")
    --    bole:magnifier("information/info_frame.png",root,cc.p(668,355),self.scroll)
    -- 根据当前界面的适配方案修改
    local sHeight = 640 + root:getPositionY() -375
    if sHeight > 840 then
        sHeight = 840
    end
    self.scroll:setContentSize( { width = 648, height = sHeight })
    for i = 1, 8 do
        local btn = self.scroll:getChildByName("btn_item_" .. i)
        btn:addTouchEventListener(handler(self, self.touchEvent))
        btn:setPressedActionEnabled(true)
        if i == 1 then
            local head = bole:getNewHeadView(bole:getUserData())
            head:updatePos(head.POS_EDIT_SELF)
            local node_head = btn:getChildByName("node_head")
            node_head:addChild(head)
        end
        local txt_key = btn:getChildByName("txt_key")
        self:changeKey(txt_key,i)
        self:updateBtnList(btn, i)
    end
    -- 头像
    self.select_head = root:getChildByName("select_head")
    self.select_head:setTouchEnabled(true)
    self.select_head:addTouchEventListener(handler(self, self.touchEvent))
    self.sp_bg = self.select_head:getChildByName("sp_bg")
    self.select_head:setVisible(false)
    self.sp_bg:setScale(0.1)
    local btn_camera = self.sp_bg:getChildByName("btn_camera")
    btn_camera:addTouchEventListener(handler(self, self.touchEvent))
    btn_camera:setPressedActionEnabled(true)
    local btn_album = self.sp_bg:getChildByName("btn_album")
    btn_album:addTouchEventListener(handler(self, self.touchEvent))
    btn_album:setPressedActionEnabled(true)
    local btn_fb = self.sp_bg:getChildByName("btn_fb")
    btn_fb:addTouchEventListener(handler(self, self.touchEvent))
    btn_fb:setPressedActionEnabled(true)

    -- 性别
    self.select_gender = root:getChildByName("select_gender")
    self.select_gender:setTouchEnabled(true)
    self.select_gender:addTouchEventListener(handler(self, self.touchEvent))
    self.sp_g_bg = self.select_gender:getChildByName("sp_bg")
    self.select_gender:setVisible(false)
    self.sp_g_bg:setScale(0.1)
    self.cell_1 = self.sp_g_bg:getChildByName("cell_1")
    self.cell_1:setTouchEnabled(true)
    self.cell_1:addTouchEventListener(handler(self, self.touchEvent))
    self.cell_2 = self.sp_g_bg:getChildByName("cell_2")
    self.cell_2:setTouchEnabled(true)
    self.cell_2:addTouchEventListener(handler(self, self.touchEvent))
    self.cell_3 = self.sp_g_bg:getChildByName("cell_3")
    self.cell_3:setTouchEnabled(true)
    self.cell_3:addTouchEventListener(handler(self, self.touchEvent))
    -- 状态
    self.select_status = root:getChildByName("select_status")
    self.select_status:setTouchEnabled(true)
    self.select_status:addTouchEventListener(handler(self, self.touchEvent))
    self.img_s_bg = self.select_status:getChildByName("img_s_bg")
    self.select_status:setVisible(false)
    self.img_s_bg:setScale(0.1)
    self.list_select = self.select_status:getChildByName("list_select")
    self.list_select:setScale(0.1)
    
    self.btn_single = self.list_select:getChildByName("btn_single")
    self.btn_single:setPressedActionEnabled(true)
    self.btn_single:addTouchEventListener(handler(self, self.touchEvent))
    self.btn_noship = self.list_select:getChildByName("btn_noship")
    self.btn_noship:setPressedActionEnabled(true)
    self.btn_noship:addTouchEventListener(handler(self, self.touchEvent))
    self.btn_married = self.list_select:getChildByName("btn_married")
    self.btn_married:setPressedActionEnabled(true)
    self.btn_married:addTouchEventListener(handler(self, self.touchEvent))
    self.btn_secret = self.list_select:getChildByName("btn_secret")
    self.btn_secret:setPressedActionEnabled(true)
    self.btn_secret:addTouchEventListener(handler(self, self.touchEvent))
    -- 国际
    self.select_country = root:getChildByName("select_country")
    self.select_country:setTouchEnabled(true)
    self.select_country:addTouchEventListener(handler(self, self.touchEvent))
    self.select_country:setVisible(false)
    self.img_bg = self.select_country:getChildByName("img_bg")
    self.img_bg:setScale(0.1)

    self.list_country = self.img_bg:getChildByName("list_country")
    self.list_country:setTouchEnabled(true)
    self.list_country:setBounceEnabled(true)
    
    local countrys = bole:getConfig("country")
    for k, v in pairs(countrys) do
        local cell = bole:getEntity("app.views.CountryCell", k)
        self.list_country:addChild(cell)
    end


    self.input = clip:getChildByName("input")
    self:initInput(self.input)
end


function InfoEditView:initEditBox(node)
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
            self.txt_edit:setString(edit:getText())
            print(strFmt)
        end
    end
    self.editBox = cc.EditBox:create(cc.size(632, 75), "common/editboxbg.png")
    self.editBox:setPosition(0, 0)
    self.editBox:setFont("font/FZKTJW.TTF", 45)
    self.editBox:setFontColor(cc.c3b(0, 0, 0))
    self.editBox:setPlaceHolder(txfs[self.inputIndex])
    self.editBox:setMaxLength(maxs[self.inputIndex])
    print("self.setMaxLength:"..maxs[self.inputIndex].."-----in dex="..self.inputIndex)
    self.editBox:setInputFlag(cc.EDITBOX_INPUT_FLAG_INITIAL_CAPS_WORD)
    if self.inputIndex == 4 then
        self.editBox:setInputMode(cc.EDITBOX_INPUT_MODE_DECIMAL)
    else
        self.editBox:setInputMode(cc.EDITBOX_INPUT_MODE_ANY)
    end
    self.editBox:setReturnType(cc.KEYBOARD_RETURNTYPE_DONE)
    self.editBox:registerScriptEditBoxHandler(editBoxTextEventHandle)
    node:addChild(self.editBox)
end

function InfoEditView:updateBtnList(btn, index)
    local txt_key = btn:getChildByName("txt_key")
    local sp_key = btn:getChildByName("sp_key")
    if index == 5 then
        if self.info[index] == 0 then
            txt_key:setString("female")
            sp_key:setTexture("information/female-nv.png")
            sp_key:setPositionX(450)
        elseif self.info[index] == 1 then
            txt_key:setString("male")
            sp_key:setTexture("information/female-nan.png")
            sp_key:setPositionX(470)
        elseif self.info[index] == 2 then
            txt_key:setString("secret")
            sp_key:setTexture("information/info_refresh.png")
            sp_key:setPositionX(450)
        end
    elseif index == 6 then
        local txts = { "single", "on-relationship", "married", "secret" }
        txt_key:setString(txts[self.info[index]+1])
    elseif index == 7 then
        if self.country_index==0 then
            local name=""
            txt_key:setString(name)
            sp_key:setPositionX(txt_key:getPositionX()-txt_key:getAutoRenderSize().width-30)
        else
            local name=bole:getConfig("country",self.country_index,"countryname_en")
            txt_key:setString(name)
            sp_key:setPositionX(txt_key:getPositionX()-txt_key:getAutoRenderSize().width-30)
        end
        
    end
end

function InfoEditView:updateGender(index)
    if index then
        self.sp_g_bg:runAction(cc.ScaleTo:create(0.1, 0.1))
        self.select_gender:runAction(cc.Sequence:create(cc.DelayTime:create(0.1), cc.Hide:create()))
    else
        index = self.info[5] + 1
        if index > 2 then
            index = 0
        end
    end
    bole:postEvent("changeInfo", { key = 5, value = index })
end
function InfoEditView:updateStatus(index)
    self.img_s_bg:runAction(cc.ScaleTo:create(0.1, 0.1))
    self.list_select:runAction(cc.ScaleTo:create(0.1, 0.1))
    self.select_status:runAction(cc.Sequence:create(cc.DelayTime:create(0.1), cc.Hide:create()))
    bole:postEvent("changeInfo", { key = 6, value = index })
end


function InfoEditView:initInput(root)
    self.txt_tips = root:getChildByName("txt_tips")
    local node_edit = root:getChildByName("node_edit")
    self:initEditBox(node_edit)
    local btn_inputOk = root:getChildByName("btn_inputOk")
    btn_inputOk:addTouchEventListener(handler(self, self.touchEvent))
    local btn_clear = root:getChildByName("btn_clear")
    btn_clear:addTouchEventListener(handler(self, self.touchEvent))
    self.txt_edit = root:getChildByName("txt_edit")
    self.txt_edit_bg=root:getChildByName("img_bg")
    self.txt_edit:setVisible(false)
    self.txt_edit_bg:setVisible(false)
    self:updateInputUI(self.inputIndex)
end

function InfoEditView:updateInputUI(index)
    self.txt_tips:setString(tips[self.inputIndex])
    self.txt_name_1:setString(titles[self.inputIndex])
end
function InfoEditView:openInput(index)
    if self.isMove then
        return
    end
    self.isMove = true
    self.inputIndex = index
    self:updateInputUI(index)
    local delayTime = 0.2
    print("self.inputIndex:"..self.inputIndex)
    if self.inputIndex == 1 then
        self.scroll:runAction(cc.MoveTo:create(delayTime, cc.p(325, 840)))
        self.input:runAction(cc.MoveTo:create(delayTime, cc.p(975, 840)))
        self.editBox:setText("")
        self.editBox:setPlaceHolder("")
        self.editBox:setMaxLength(3)
        print("self.setMaxLength:3")
    else
--        if self.inputIndex == 2 then
--            self.txt_edit:setVisible(true)
--            self.txt_edit_bg:setVisible(true)
--            self.txt_tips:setPosition(9,700)
--        else
            self.txt_edit:setVisible(false)
            self.txt_edit_bg:setVisible(false)
            self.txt_tips:setPosition(9,712)
--        end
        if self.inputIndex == 4 then
            self.editBox:setInputMode(cc.EDITBOX_INPUT_MODE_DECIMAL)
        else
            self.editBox:setInputMode(cc.EDITBOX_INPUT_MODE_ANY)
        end
        self.scroll:runAction(cc.MoveTo:create(delayTime, cc.p(325 - 648, 840)))
        self.input:runAction(cc.MoveTo:create(delayTime, cc.p(975 - 648, 840)))
        self.editBox:setText(self.info[self.inputIndex])    
        self.editBox:setPlaceHolder(txfs[self.inputIndex])
        self.editBox:setMaxLength(maxs[self.inputIndex])
        print("self.setMaxLength:"..maxs[self.inputIndex].."-----in dex="..self.inputIndex)
    end

    

    performWithDelay(self, function()
        self.isMove = false
        if self.inputIndex ~= 1 then
            self.editBox:touchDownAction(self.editBox, 2)
        end
    end , delayTime)
end

function InfoEditView:complete()
    local str = self.editBox:getText()
    if str=="" then
        str=self.editBox:getPlaceHolder()
    end
    local _, count = string.gsub(str, "[^\128-\193]", "")
    print("btn_ok:" .. count)
    if self.inputIndex == 4 then
        local num = tonumber(str)
        if not num then

            return
        end
    else
--        if count < 3 then
--            return
--        end
    end
    bole:postEvent("changeInfo", { key = self.inputIndex, value = str })
    self:openInput(1)
end

function InfoEditView:touchEvent(sender, eventType)
    local name = sender:getName()
    local tag = sender:getTag()
    print("touchEvent:" .. name)
    if eventType == ccui.TouchEventType.began then
        print("Touch Down")
    elseif eventType == ccui.TouchEventType.moved then
        print("Touch Move")
    elseif eventType == ccui.TouchEventType.ended then
        print("Touch Up")
        if name == "btn_close" then
            if self.inputIndex == 1 then
                self:closeUI()
            else
                self:openInput(1)
            end
        elseif name == "select_head" then
            self.sp_bg:runAction(cc.ScaleTo:create(0.1, 0.1))
            self.select_head:runAction(cc.Sequence:create(cc.DelayTime:create(0.1), cc.Hide:create()))
        elseif name == "select_gender" then
            self.sp_g_bg:runAction(cc.ScaleTo:create(0.1, 0.1))
            self.select_gender:runAction(cc.Sequence:create(cc.DelayTime:create(0.1), cc.Hide:create()))
        elseif name == "select_status" then
            self.img_s_bg:runAction(cc.ScaleTo:create(0.1, 0.1))
            self.list_select:runAction(cc.ScaleTo:create(0.1, 0.1))
            self.select_status:runAction(cc.Sequence:create(cc.DelayTime:create(0.1), cc.Hide:create()))
        elseif name == "select_country" then
            self.img_bg:runAction(cc.ScaleTo:create(0.1, 0.1))
            self.select_country:runAction(cc.Sequence:create(cc.DelayTime:create(0.1), cc.Hide:create()))
        elseif name == "cell_1" then
            self:updateGender(0)
        elseif name == "cell_2" then
            self:updateGender(1)
        elseif name == "cell_3" then
            self:updateGender(2)
        elseif name == "btn_single" then
            self:updateStatus(0)
        elseif name == "btn_noship" then
            self:updateStatus(1)
        elseif name == "btn_married" then
            self:updateStatus(2)
        elseif name == "btn_secret" then
            self:updateStatus(3)
        elseif name == "btn_camera" then
            local key = bole:getUserDataByKey("user_id")
            bole:openCamera(key)
            self.info[1] = "camera"
            self:sendEditInfo()
        elseif name == "btn_album" then
            local key = bole:getUserDataByKey("user_id")
            bole:openPhoto(key)
            self.info[1] = "album"
            self:sendEditInfo()
        elseif name == "btn_fb" then
            bole:getFacebookCenter():bindFacebook()
        elseif name == "btn_item_1" then
            self.select_head:setVisible(true)
            self.sp_bg:runAction(cc.ScaleTo:create(0.1, 1))
            local offY = self.scroll:getInnerContainerPosition().y
            local offH = 840 - self.scroll:getContentSize().height
            self.sp_bg:setPositionY(757 + offY + offH)
        elseif name == "btn_item_2" then
            self:openInput(2)
        elseif name == "btn_item_3" then
            self:openInput(3)
        elseif name == "btn_item_4" then
            self:openInput(4)
        elseif name == "btn_item_5" then
            self.select_gender:setVisible(true)
            self.sp_g_bg:runAction(cc.ScaleTo:create(0.1, 1))
            local offH = 840 - self.scroll:getContentSize().height
            local offY = self.scroll:getInnerContainerPosition().y
            self.sp_g_bg:setPositionY(362 + offY + offH)
            --            self:updateGender()
        elseif name == "btn_item_6" then
            self.select_status:setVisible(true)
            self.img_s_bg:runAction(cc.ScaleTo:create(0.1, 1))
            self.list_select:runAction(cc.ScaleTo:create(0.1, 1))
            local offY = self.scroll:getInnerContainerPosition().y
            local offH = 840 - self.scroll:getContentSize().height
            self.img_s_bg:setPositionY(316 + offY + offH)
            self.list_select:setPositionY(350 + offY + offH)
        elseif name == "btn_item_7" then
            self.select_country:setVisible(true)
            self.img_bg:runAction(cc.ScaleTo:create(0.1, 1))
            local offY = self.scroll:getInnerContainerPosition().y
            local offH = 840 - self.scroll:getContentSize().height
            self.img_bg:setPositionY(197 + offY + offH)
        elseif name == "btn_item_8" then
            self:openInput(8)
        elseif name == "btn_ok" then
            
        elseif name == "btn_cancle" then
            self.img_bg:runAction(cc.ScaleTo:create(0.1, 0.1))
            self.select_country:runAction(cc.Sequence:create(cc.DelayTime:create(0.1), cc.Hide:create()))
        elseif name == "btn_inputOk" then
            self:complete()
        elseif name == "btn_clear" then
            self.editBox:setText("")
            self.editBox:touchDownAction(nil, 2)
        end

        
    elseif eventType == ccui.TouchEventType.canceled then
        print("Touch Cancelled")
    end
end

return InfoEditView

-- endregion
