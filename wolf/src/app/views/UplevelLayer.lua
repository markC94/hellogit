-- region *.lua
-- Date
-- 此文件由[BabeLua]插件自动生成
local UplevelLayer = class("UplevelLayer", cc.load("mvc").ViewBase)

function UplevelLayer:onCreate()
    self.root = self:getCsbNode():getChildByName("root")
    self.root:setVisible(false)
    self.step = 0
    self.list_1 = { }
    self.list_2 = { }
    self.list_3 = { }

    self.len_1 = 0
    self.len_2 = 0
    self.len_3 = 0
    self.win_coins = 0

    local frame_1 = self.root:getChildByName("frame_1")
    local frame_2 = self.root:getChildByName("frame_2")
    local frame_3 = self.root:getChildByName("frame_3")

    self.cell_1 = frame_1:getChildByName("cell_1")
    self.cell_2 = frame_2:getChildByName("cell_2")
    self.cell_3 = frame_3:getChildByName("cell_3")

    self.node_head = self.root:getChildByName("node_head")

    self.head = bole:getNewHeadView(bole:getUserData())
    self.head:updatePos(self.head.POS_UPLEVEL)
    self.node_head:addChild(self.head)

    self.txt_uplevel = self.root:getChildByName("txt_uplevel")

    self.spin = self.root:getChildByName("spin")
    self.video = self.root:getChildByName("video")
    self.ok = self.root:getChildByName("ok")


    self.btn_spin = self.spin:getChildByName("btn_spin")
    self.btn_spin:addTouchEventListener(handler(self, self.touchEvent))
    self.img_left = self.root:getChildByName("img_left")
    self.img_right = self.root:getChildByName("img_right")


    self.btn_video = self.video:getChildByName("btn_video")
    self.btn_video:addTouchEventListener(handler(self, self.touchEvent))

    self.btn_ok = self.ok:getChildByName("btn_ok")
    self.btn_ok:addTouchEventListener(handler(self, self.touchEvent))


    self.uplevel = self.root:getChildByName("uplevel")
    local txt_reward = self.uplevel:getChildByName("txt_reward")
    self.txt_coin = txt_reward:getChildByName("txt_coin")
    self.img_icon1 = txt_reward:getChildByName("img_icon1")
    self.txt_coin:setVisible(false)
    self.img_icon1:setVisible(false)
    self.txt_result = txt_reward:getChildByName("txt_result")
    self.img_icon2 = txt_reward:getChildByName("img_icon2")
    self.txt_result:setVisible(false)
    self.img_icon2:setVisible(false)
    self.txt_add = txt_reward:getChildByName("txt_add")
    self.node_1 = txt_reward:getChildByName("node_1")
    self.txt_add:setVisible(false)
    self.node_1:setVisible(false)

end

function UplevelLayer:updateUI(data)
    self.data = data.result
     dump(self.data, "UplevelLayer:updateUI")
    if not self.data then
        -- test
        self.data = { { level_up_bonus = 9000, level_up_multiple = 4, special_bonus = 2, vip_points = 50 } }
    end
    if #self.data > 0 then
        self.level = bole:getUserDataByKey("level")
        bole:setUserDataByKey("level", #self.data + self.level)
        bole:setUserDataByKey("experience",bole:getUserDataByKey("experience"))
    end
    self:nextStep()
end
function UplevelLayer:nextStep()
    self.step = self.step + 1
    if self.step <= #self.data then
        local curLevel = self.level + self.step
        self:initData(self.data[self.step])
        self:restUI(curLevel)
    else
        bole:getAppManage():addCoins(self.win_coins)
        self:closeUI()
        bole:postEvent("dialog_pop")
    end
end

function UplevelLayer:restUI(level)
    self.root:setVisible(true)
    self.root:setScale(0.1)
    self.root:runAction(cc.ScaleTo:create(0.2, 1.0))

    self.txt_uplevel:setVisible(true)
    self.spin:setScale(1)
    self.spin:setOpacity(255)
    self.spin:setVisible(true)
    self.img_left:setScale(1)
    self.img_left:setOpacity(255)
    self.img_left:setVisible(true)
    self.img_right:setScale(1)
    self.img_right:setOpacity(255)
    self.img_right:setVisible(true)

    self.uplevel:setVisible(false)
    self.video:setVisible(false)
    self.ok:setVisible(false)

    self.btn_spin:setScale(1)
    self.btn_spin:setOpacity(255)
    self.btn_spin:setBright(true)
    self.btn_spin:setTouchEnabled(true)

    self.txt_coin:setVisible(false)
    self.img_icon1:setVisible(false)
    self.txt_result:setVisible(false)
    self.img_icon2:setVisible(false)
    self.txt_add:setVisible(false)
    self.node_1:setVisible(false)
    self.node_1:removeAllChildren()
    self.head:updateLevel(level)
end

function UplevelLayer:initData(data)

    self.list_1 = { }
    self.list_2 = { }
    self.list_3 = { }

    self.len_1 = 0
    self.len_2 = 0
    self.len_3 = 0

    local level_data = bole:getConfigCenter():getConfig("levelupbonusfakeroller", "1")

    self.list_1 = level_data.fakeroller_chips
    self.list_2 = level_data.fakeroller_multiply
    self.list_3 = level_data.fakeroller_specialbonus

    self:RandSort(self.list_1)
    self:RandSort(self.list_2)
    self:RandSort(self.list_3)

    self.list_1[#self.list_1 + 1] = data.level_up_bonus / 1000
    self.list_2[#self.list_2 + 1] = data.level_up_multiple
    self.list_3[#self.list_3 + 1] = data.special_bonus

    self:initSpin()
    self.win_coins = data.level_up_bonus * data.level_up_multiple
    self.txt_coin:setString((data.level_up_bonus / 1000) .. "K")
    self.txt_result:setString("x" .. data.level_up_multiple .. " = " ..(self.win_coins / 1000) .. "K")
    

    local pos1 = -100
    local pos2 = pos1 + self.txt_coin:getContentSize().width + 10
    local pos3 = pos2 + self.img_icon1:getContentSize().width + 10
    local pos4 = pos3 + self.txt_result:getContentSize().width + 10
    local pos5 = pos4 + self.img_icon2:getContentSize().width + 10
    local pos6 = pos5 + self.txt_add:getContentSize().width + 30
    print("----------------------------pos"..pos6)
    local addpos=math.abs(250-pos6+170)/2-70
    print("----------------------------addpos"..addpos)
    self.txt_coin:setPosition(cc.p(pos1+addpos, -36))
    self.img_icon1:setPosition(cc.p(pos2+addpos, -33))

    self.txt_result:setPosition(cc.p(pos3+addpos, -36))
    self.img_icon2:setPosition(cc.p(pos4+addpos, -33))

    self.txt_add:setPosition(cc.p(pos5+addpos, -36))
    self.node_1:setPosition(cc.p(pos6+addpos, -33))
end

function UplevelLayer:RandSort(t)
    local len = #t
    for i = len, 1, -1 do
        local index = math.random(1, len);
        local tempNum = t[i];
        t[i] = t[index];
        t[index] = tempNum;
    end
end

function UplevelLayer:initSpin()
    local f_1 = bole:getEntity("app.views.UplevelCell", { type = 1 })
    local f_2 = bole:getEntity("app.views.UplevelCell", { type = 2 })
    local f_3 = bole:getEntity("app.views.UplevelCell", { type = 1 })
    self.cell_1:removeAllChildren()
    self.cell_1:setPosition(cc.p(100,100))
    self.cell_2:removeAllChildren()
    self.cell_2:setPosition(cc.p(100,100))
    self.cell_3:removeAllChildren()
    self.cell_3:setPosition(cc.p(100,100))
    self.cell_1:addChild(f_1)
    self.cell_2:addChild(f_2)
    self.cell_3:addChild(f_3)
    for k, v in ipairs(self.list_1) do
        local cell = bole:getEntity("app.views.UplevelCell", { type = 3, value = v })
        self:pushCell(1, cell)
    end
    for k, v in ipairs(self.list_2) do
        local cell = bole:getEntity("app.views.UplevelCell", { type = 4, value = v })
        self:pushCell(2, cell)
    end
    for k, v in ipairs(self.list_3) do
        local cell = bole:getEntity("app.views.UplevelCell", { type = 5, value = v })
        self:pushCell(3, cell)
    end
end

function UplevelLayer:pushCell(raw, node)
    if raw == 1 then
        self.len_1 = self.len_1 + 1
        node:setPosition(cc.p(0, self.len_1 * 200))
        self.cell_1:addChild(node)
    elseif raw == 2 then
        self.len_2 = self.len_2 + 1
        node:setPosition(cc.p(0, self.len_2 * 200))
        self.cell_2:addChild(node)
    elseif raw == 3 then
        self.len_3 = self.len_3 + 1
        node:setPosition(cc.p(0, self.len_3 * 200))
        self.cell_3:addChild(node)
    end
end

function UplevelLayer:spinReward()
    self.txt_uplevel:setVisible(false)
    self.uplevel:setVisible(true)
    self.ok:setScale(0.1)
    self.ok:setOpacity(0)
    local act = cc.Spawn:create(cc.ScaleTo:create(0.2, 1), cc.FadeIn:create(0.2))
    self.uplevel:runAction(act)

    self.btn_spin:setBright(false)
    self.btn_spin:setTouchEnabled(false)

    local data_1 = { }
    data_1.time = 0
    data_1.maxPos =(self.len_1) * 200 - 100
    data_1.X = self.cell_1:getPositionX()
    data_1.Y = self.cell_1:getPositionY()
    data_1.addY = 200
    data_1.callFun = handler(self, self.stopOne)
    self.moveNode_1 = bole:getEntity("app.command.SimpleMoveAction", data_1, self.cell_1)
    self:addChild(self.moveNode_1)

    local data_2 = { }
    data_2.time = 0.8
    data_2.maxPos =(self.len_2) * 200 - 100
    data_2.X = self.cell_2:getPositionX()
    data_2.Y = self.cell_2:getPositionY()
    data_2.addY = 200
    data_2.callFun = handler(self, self.stopTwo)
    self.moveNode_2 = bole:getEntity("app.command.SimpleMoveAction", data_2, self.cell_2)
    self:addChild(self.moveNode_2)

    local data_3 = { }
    data_3.time = 1.4
    data_3.maxPos =(self.len_3) * 200 - 100
    data_3.X = self.cell_3:getPositionX()
    data_3.Y = self.cell_3:getPositionY()
    data_3.addY = 200
    data_3.callFun = handler(self, self.stopThree)
    self.moveNode_3 = bole:getEntity("app.command.SimpleMoveAction", data_3, self.cell_3)
    self:addChild(self.moveNode_3)
end

function UplevelLayer:stopOne()
    self.txt_coin:setVisible(true)
    self.img_icon1:setVisible(true)
end
function UplevelLayer:stopTwo()
    self.txt_result:setVisible(true)
    self.img_icon2:setVisible(true)
end
function UplevelLayer:stopThree()
    self.txt_add:setVisible(true)
    self.node_1:setVisible(true)
    local cell = bole:getEntity("app.views.UplevelCell", { type = 5, value = self.list_3[#self.list_3] })
    cell:setScale(0.3)
    self.node_1:addChild(cell)
    local act1 = cc.Spawn:create(cc.ScaleTo:create(0.2, 0.1), cc.FadeOut:create(0.2))
    local act2 = cc.Spawn:create(cc.ScaleTo:create(0.2, 0.1), cc.FadeOut:create(0.2))
    local act3 = cc.Spawn:create(cc.ScaleTo:create(0.2, 0.1), cc.FadeOut:create(0.2))
    self.txt_uplevel:setVisible(false)
    self.spin:runAction(act1)
    self.img_left:runAction(act2)
    self.img_right:runAction(act3)

    self.video:setVisible(true)
    self.ok:setVisible(true)
    self.video:setScale(0.1)
    self.video:setOpacity(0)
    self.ok:setScale(0.1)
    self.ok:setOpacity(0)
    local act4 = cc.Spawn:create(cc.ScaleTo:create(0.2, 1), cc.FadeIn:create(0.2))
    local act5 = cc.Spawn:create(cc.ScaleTo:create(0.2, 1), cc.FadeIn:create(0.2))

    self.video:runAction(act4)
    self.ok:runAction(act5)
end


function UplevelLayer:touchEvent(sender, eventType)
    local name = sender:getName()
    local tag = sender:getTag()
    print("touchEvent:" .. name)
    if eventType == ccui.TouchEventType.began then
        print("Touch Down")
        sender:setScale(1.05)
    elseif eventType == ccui.TouchEventType.moved then
        print("Touch Move")
    elseif eventType == ccui.TouchEventType.ended then
        sender:setScale(1.0)
        print("Touch Up")
        if name == "btn_spin" then
            self:spinReward()
        elseif name == "btn_vedio" then
            self:nextStep()
        elseif name == "btn_ok" then
            self:nextStep()
        end
    elseif eventType == ccui.TouchEventType.canceled then
        sender:setScale(1.0)
        print("Touch Cancelled")
    end
end
return UplevelLayer
-- endregion
