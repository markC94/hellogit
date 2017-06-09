-- region *.lua
-- Date
-- 此文件由[BabeLua]插件自动生成
local InfoInput = class("InfoInput", cc.Node)
local titles = { "Edit icon", "Edit Signature", "Edit Name", "Edit age", "Edit Gender", "Edit Status", "Edit Country", "Edit City" }
local tips = { "4-30 Characters.", "0-90 Characters.", "4-30 Characters.", "4-30 Characters.", "4-30 Characters.", "4-30 Characters.", "4-30 Characters.", "4-30 Characters." }
local txfs = { "", "I love Wolfslots.", "", "", "", "", "", "", "" }
local maxs = { 30, 90, 30, 3, 3, 3, 3, 30 }
function InfoInput:ctor(index)
    self.node_input = cc.CSLoader:createNode("csb/InfoInput.csb")
    self:addChild(self.node_input)
    self.index = index
    -- local other={"max 90 charactrs"}
    local root = self.node_input:getChildByName("root")
    local btn_ok = root:getChildByName("btn_ok")
    btn_ok:addTouchEventListener(handler(self, self.touchEvent))
    local btn_close = root:getChildByName("btn_close")
    btn_close:addTouchEventListener(handler(self, self.touchEvent))
    local txt_title = root:getChildByName("txt_title")
    txt_title:setString(titles[index])
    local txt_tips = root:getChildByName("txt_tips")
    txt_tips:setString(tips[index])
    local node_edit = root:getChildByName("node_edit")
    self:initEditBox(node_edit)
end

function InfoInput:initEditBox(node)
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
    self.editBox = cc.EditBox:create(cc.size(632, 90), "common/editboxbg.png") 
    self.editBox:setPosition(0, 0) 
    self.editBox:setFont("font/FZKTJW.TTF", 30)
    self.editBox:setFontColor(cc.c3b(0, 0, 0))
    self.editBox:setPlaceHolder(txfs[self.index])
    self.editBox:setMaxLength(maxs[self.index])
    self.editBox:setInputFlag(cc.EDITBOX_INPUT_FLAG_INITIAL_CAPS_WORD)
    if self.index == 4 then
        self.editBox:setInputMode(cc.EDITBOX_INPUT_MODE_DECIMAL)
    else
        self.editBox:setInputMode(cc.EDITBOX_INPUT_MODE_SINGLELINE)
    end
    self.editBox:setReturnType(cc.KEYBOARD_RETURNTYPE_DONE)
    self.editBox:registerScriptEditBoxHandler(editBoxTextEventHandle)
    node:addChild(self.editBox)
    self.editBox:touchDownAction(nil, 2)
end

function InfoInput:complete()
    local str = self.editBox:getText()
    local _, count = string.gsub(str, "[^\128-\193]", "")
    print("btn_ok:" .. count)
    if self.index==4 then
        local num = tonumber(str)
        if not num then
            
            return
        end
    else
        if count<3 then
            return
        end
    end
    bole:postEvent("changeInfo", { key = self.index, value = str })
    self:removeFromParent()
end

--    self.info[1] = data.icon
--    self.info[2] = data.signature .. ""
--    self.info[3] = data.name .. ""
--    self.info[4] = data.age
--    self.info[5] = data.gender
--    self.info[6] = data.marital_status
--    self.info[7] = data.country
--    self.info[8] = data.city .. ""

function InfoInput:touchEvent(sender, eventType)
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
            self:removeFromParent()
        elseif name == "btn_ok" then
            self:complete()
        end
    elseif eventType == ccui.TouchEventType.canceled then
        print("Touch Cancelled")
    end
end

return InfoInput
-- endregion
