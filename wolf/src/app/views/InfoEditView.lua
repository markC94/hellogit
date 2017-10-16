-- region *.lua
-- Date
-- 此文件由[BabeLua]插件自动生成
local InfoEditView = class("InfoEditView", cc.load("mvc").ViewBase)
local titles = { "Edit Profile", "About Me", "Name", "Age", "Gender", "Status", "Country", "City" }
local txfs = { "", "What's on your mind?", "", "", "", "", "", "", "" }
local tips = { "", "16 Characters.", "30 Characters.", "", "", "", "","12 Characters." }

local maxs = { 0, 16, 30, 2, 0, 0, 0, 30 }
function InfoEditView:onCreate()
    print("InfoEditView-onCreate")
    local root = self:getCsbNode():getChildByName("root")
    root:setVisible(false)
    root:setScale(0.01)
    local btn_close = root:getChildByName("btn_close")
    btn_close:addTouchEventListener(handler(self, self.touchEvent))
    self.inputIndex = 1
end

function InfoEditView:onKeyBack()
   if self.inputIndex == 1 then
       self:closeUI()
   else
      self:openInput(1)
   end
end

function InfoEditView:onEnter()
    bole:addListener("changeInfo", self.changeInfo, self, nil, true)
end

function InfoEditView:onExit()
    bole:getEventCenter():removeEventWithTarget("changeInfo", self)
end
-- 修改个人信息通知
function InfoEditView:changeInfo(event)
    local data = event.result
    self.info[data.key] = data.value
    for i = 1, 8 do
        local btn = self.scroll:getChildByName("btn_item_" .. i)
        local txt_key = btn:getChildByName("txt_key")
        if txt_key then
            if i==2 then
                if self.info[i]=="" then
                    txt_key:setTextColor( {r = 68, g = 120, b = 146})
                    txt_key:setString(txfs[i])
                else
                    txt_key:setTextColor( {r = 211, g = 233, b = 244})
                    txt_key:setString(self.info[i])
                end
            elseif i == 3 or i==8 then
                local str = bole:limitStr(self.info[i], 14, "...")
                txt_key:setString(str)
            else
                txt_key:setString(self.info[i])
            end
        end
        self:updateBtnList(btn, i)
    end
    self:sendEditInfo()
end

-- 保存修改的个人信息并上传服务器
function InfoEditView:sendEditInfo()
    local newInfo = { icon = self.info[1], signature = self.info[2], name = self.info[3], age = tonumber(self.info[4]), gender = tonumber(self.info[5]), marital_status = tonumber(self.info[6]), country = tonumber(self.info[7]), city = self.info[8] }
    bole:getUserData():setData(newInfo)
    bole:uploadUserInfo()
end
-- 初始化
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
-- UI初始化
function InfoEditView:initUI(root)
    self.country_index = bole:getUserDataByKey("country")
    -- 背景UI
    self.btn_close = root:getChildByName("btn_close")
    self.btn_close:addTouchEventListener(handler(self, self.touchEvent))
    self.btn_close:setPressedActionEnabled(true)

    self.btn_input_save = root:getChildByName("btn_input_save")
    self.btn_input_save:addTouchEventListener(handler(self, self.touchEvent))
    self.btn_input_save:setPressedActionEnabled(true)

    self.btn_input_cancle = root:getChildByName("btn_input_cancle")
    self.btn_input_cancle:addTouchEventListener(handler(self, self.touchEvent))
    self.btn_input_cancle:setPressedActionEnabled(true)

    self.txt_name_1 = root:getChildByName("txt_name_1")
    self.txt_name_2 = root:getChildByName("txt_name_2")
    self.img_set_icon = root:getChildByName("img_set_icon")

    self.img_set_icon:setVisible(true)
    self.btn_close:setVisible(true)
    self.btn_input_save:setVisible(false)
    self.btn_input_cancle:setVisible(false)
    self.txt_name_1:setVisible(true)
    self.txt_name_2:setVisible(false)


    -- 头像
    self.select_head = root:getChildByName("select_head")
    self.select_head:setTouchEnabled(true)
    self.select_head:addTouchEventListener(handler(self, self.touchEvent))
    self.head_pos = self.select_head:getChildByName("img_bg")
    self.select_head:setVisible(false)
    self.head_pos:setScale(0.1)
    local camera = self.head_pos:getChildByName("camera")
    camera:addTouchEventListener(handler(self, self.touchEvent))
    camera:setTouchEnabled(true)
    local album = self.head_pos:getChildByName("album")
    album:addTouchEventListener(handler(self, self.touchEvent))
    album:setTouchEnabled(true)
    local fb = self.head_pos:getChildByName("fb")
    fb:addTouchEventListener(handler(self, self.touchEvent))
    fb:setTouchEnabled(true)

    -- 八个按钮
    local clip = root:getChildByName("clip")

    -- 输入页
    self.node_move = clip:getChildByName("node_move")
    self.input = self.node_move:getChildByName("input")
    self:initInput(self.input)
    self.scroll = self.node_move:getChildByName("scroll")

    for i = 1, 8 do
        local btn = self.scroll:getChildByName("btn_item_" .. i)
        btn:addTouchEventListener(handler(self, self.touchEvent))
        if i == 1 then
            local head = bole:getNewHeadView(bole:getUserData())
            head:updatePos(head.POS_EDIT_SELF)
            local node_head = btn:getChildByName("node_head")
            node_head:addChild(head)
        end
        local txt_key = btn:getChildByName("txt_key")
        if txt_key then
           if i==2 then
                if self.info[i]=="" then
                    txt_key:setTextColor( {r = 68, g = 120, b = 146})
                    txt_key:setString(txfs[i])
                else
                    txt_key:setTextColor( {r = 211, g = 233, b = 244})
                    txt_key:setString(self.info[i])
                end
            elseif i == 3 or i==8 then
                local str = bole:limitStr(self.info[i], 14, "...")
                txt_key:setString(str)
            else
                txt_key:setString(self.info[i])
            end
        end
        self:updateBtnList(btn, i)
    end
end

function InfoEditView:initInput(root)
    local node_edit = root:getChildByName("node_edit")
    self.txt_input_tips = root:getChildByName("txt_input_tips")
    
    self:initEditBox(node_edit)
    self:updateInputUI(self.inputIndex)
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
            print(strFmt)
        elseif strEventName == "changed" then
            strFmt = string.format("editBox %p TextChanged, text: %s ", edit, edit:getText())
            print(strFmt) 
        end
    end
    self.editBox = cc.EditBox:create(cc.size(748, 80), "information/edit_info_bg_input.png")
    self.editBox:setPosition(0, 0)
    self.editBox:setFont("font/bole_ttf.ttf", 36)
    self.editBox:setFontColor(cc.c4b(23, 51, 74, 255))
    self.editBox:setPlaceholderFont("font/bole_ttf.ttf", 36)
    self.editBox:setPlaceHolder(txfs[self.inputIndex])
    self.editBox:setMaxLength(maxs[self.inputIndex])
    print("self.setMaxLength:" .. maxs[self.inputIndex] .. "-----in dex=" .. self.inputIndex)
    self.editBox:setInputFlag(cc.EDITBOX_INPUT_FLAG_INITIAL_CAPS_WORD)
    self.editBox:setInputMode(cc.EDITBOX_INPUT_MODE_SINGLELINE)
    self.editBox:setReturnType(cc.KEYBOARD_RETURNTYPE_DONE)
    self.editBox:registerScriptEditBoxHandler(editBoxTextEventHandle)
    node:addChild(self.editBox)
end
-- 更新编辑面板
function InfoEditView:updateBtnList(btn, index)
    local txt_key = btn:getChildByName("txt_key")
    local sp_key = btn:getChildByName("sp_key")
    if index == 5 then
        local txts = { "Secret","Female", "Male"}
        txt_key:setString(txts[self.info[index] + 1])
    elseif index == 6 then
        local name = { "Secret" , "Single", "In a relationship", "Married"}
        txt_key:setString(name[self.info[index] + 1])
    elseif index == 7 then
        local country_index = self.info[index]
        local name = bole:getConfig("country", country_index, "countryname_en")
        txt_key:setString(name)
        sp_key:setScale(0.6)
        sp_key:setTexture("flag/flag_" .. country_index .. ".png")
        sp_key:setPositionX(txt_key:getPositionX() - txt_key:getAutoRenderSize().width - 30)
    end
end

function InfoEditView:updateTitle(flag)
    self.btn_close:setVisible(flag)
    self.txt_name_1:setVisible(flag)
    self.img_set_icon:setVisible(flag)

    self.txt_name_2:setVisible(not flag)
    self.btn_input_save:setVisible(not flag)
    self.btn_input_cancle:setVisible(not flag)
end

function InfoEditView:updateEdit()
    self.editBox:setFontColor(cc.c4b(23, 51, 74, 255))
    self.editBox:setPlaceholderFont("font/bole_ttf.ttf", 36)
    self.editBox:setPosition(0, 0)
    self.editBox:setInputMode(cc.EDITBOX_INPUT_MODE_SINGLELINE)
    self.editBox:setPlaceHolder(txfs[self.inputIndex])
    self.editBox:setMaxLength(maxs[self.inputIndex])
    self.editBox:setText(self.info[self.inputIndex])
end

function InfoEditView:updateInputUI(index)
    self.txt_name_2:setString(titles[self.inputIndex])
    if self.txt_input_tips then
        self.txt_input_tips:setVisible(false)
        self.txt_input_tips:setString(tips[self.inputIndex])
    end
end

function InfoEditView:openInput(index)
    if self.isMove then
        return
    end
    self.isMove = true
    self.inputIndex = index
    self:updateInputUI(index)
    local delayTime = 0.2
    print("self.inputIndex:" .. self.inputIndex)
    -- 返回编辑页面
    if self.inputIndex == 1 then
        self.node_move:runAction(cc.MoveTo:create(delayTime, cc.p(0, 0)))
        self:updateTitle(true)
    else
        -- 输入页面
        self.node_move:runAction(cc.MoveTo:create(delayTime, cc.p(-808, 0)))
        self:updateTitle(false)
        self:updateEdit()
    end
    -- 移动完成回调
    performWithDelay(self, function()
        self.isMove = false
        if self.inputIndex == 2 or self.inputIndex == 3 or self.inputIndex == 4 or self.inputIndex == 8 then
            self.editBox:touchDownAction(self.editBox, 2)
        end
    end , delayTime)
end

function InfoEditView:complete()
    local str = self.editBox:getText()
    local _, count = string.gsub(str, "[^\128-\193]", "")
    print("btn_ok:" .. count)
    -- 年龄
    if self.inputIndex == 4 then
        local num = tonumber(str)
        if not num then
            str = "0"
        else
            str = "" .. num
        end
        -- 名字
    elseif self.inputIndex == 3 then
        if not bole:isStrExists(str) then
            self.editBox:setText("")
            bole:popMsg( { msg = "Invalid string!" })
            return
        end
    end

    bole:postEvent("changeInfo", { key = self.inputIndex, value = str })
    self:openInput(1)
end
function InfoEditView:touchItems(name)
    -- 头像
    if name == "btn_item_1" then
        self.select_head:setVisible(true)
        self.head_pos:runAction(cc.ScaleTo:create(0.1, 1))
        local offY = self.scroll:getInnerContainerPosition().y
        local offH = 800 - self.scroll:getContentSize().height
        self.head_pos:setPositionY(538 + offY + offH)
        -- 分享
    elseif name == "btn_item_2" then
        self:openInput(2)
        -- 姓名
    elseif name == "btn_item_3" then
        self:openInput(3)
        -- 年龄
    elseif name == "btn_item_4" then
        bole:getUIManage():openNewUI("InfoList", true, "player_edit", nil, 3)
        -- 性别
    elseif name == "btn_item_5" then
        bole:getUIManage():openNewUI("InfoList", true, "player_edit", nil, 1)
        -- 状态
    elseif name == "btn_item_6" then
        bole:getUIManage():openNewUI("InfoList", true, "player_edit", nil, 2)
        -- 国家
    elseif name == "btn_item_7" then
        bole:getUIManage():openNewUI("CountryLayer", true, "player_edit")
        -- 城市
    elseif name == "btn_item_8" then
        self:openInput(8)
    end
end

function InfoEditView:touchEvent(sender, eventType)
    local name = sender:getName()
    local tag = sender:getTag()
    print("touchEvent:" .. name)
    if eventType == ccui.TouchEventType.began then
        print("Touch Down")
        if name == "camera" then
            sender:setScale(0.9)
        elseif name == "album" then
            sender:setScale(0.9)
        elseif name == "fb" then
            sender:setScale(0.9)
        end
    elseif eventType == ccui.TouchEventType.moved then
        print("Touch Move")
    elseif eventType == ccui.TouchEventType.ended then
        print("Touch Up")
        self:touchItems(name)
        if name == "btn_close" then
            self:closeUI()
            -- 头像功能
        elseif name == "select_head" then
            self.head_pos:runAction(cc.ScaleTo:create(0.1, 0.1))
            self.select_head:runAction(cc.Sequence:create(cc.DelayTime:create(0.1), cc.Hide:create()))
        elseif name == "camera" then
            sender:setScale(1)
            local key = bole:getUserDataByKey("user_id")
            bole:openCamera(key)
        elseif name == "album" then
            sender:setScale(1)
            local key = bole:getUserDataByKey("user_id")
            bole:openPhoto(key)
        elseif name == "fb" then
            sender:setScale(1)
            bole:getFacebookCenter():bindFacebook()
            -- 保存 取消 清理 弹键盘
        elseif name == "btn_input_cancle" then
            self:openInput(1)
        elseif name == "btn_input_save" then
            self:complete()
        elseif name == "btn_clear" then
            self.editBox:setText("")
            self.editBox:touchDownAction(nil, 2)
        elseif name == "img_edit" then
            self.editBox:touchDownAction(nil, 2)
        end


    elseif eventType == ccui.TouchEventType.canceled then
        print("Touch Cancelled")
        if name == "camera" then
            sender:setScale(1)
        elseif name == "album" then
            sender:setScale(1)
        elseif name == "fb" then
            sender:setScale(1)
        end
    end
end

return InfoEditView

-- endregion
