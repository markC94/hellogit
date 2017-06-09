-- region *.lua
-- Date
-- 此文件由[BabeLua]插件自动生成
local TitleView = class("TitleView", cc.load("mvc").ViewBase)
function TitleView:onCreate()
    print("TitleView-onCreate")
    local root = self:getCsbNode():getChildByName("root")

    local btn_close = root:getChildByName("btn_close")
    btn_close:addTouchEventListener(handler(self, self.touchEvent))

    local btn_title = root:getChildByName("btn_title")
    btn_title:addTouchEventListener(handler(self, self.touchEvent))

    self.select_key = btn_title:getChildByName("txt_key")
    local data = bole:getUserData()
    local name = bole:getConfig("title", data.title, "title_name")
    self.select_key:setString(name)
    local btn_lock_1 = root:getChildByName("btn_lock_1")
    self.next_name = btn_lock_1:getChildByName("txt_name")
    local next_data = bole:getConfig("title", data.title_max + 1)
    self.next_name:setString("Next Title:" .. next_data.title_name)
    self.next_key = btn_lock_1:getChildByName("txt_key")
    self.next_key:setString("Reach level " .. next_data.unlock_level)
    self.next_icon = btn_lock_1:getChildByName("sp_icon")


    local task_data_1 = bole:getConfig("title_mission", next_data.title_mission1)
    local task_data_2 = bole:getConfig("title_mission", next_data.title_mission2)

    local btn_lock_2 = root:getChildByName("btn_lock_2")
    self.task_name_1 = btn_lock_2:getChildByName("txt_name")
    self.task_key_1 = btn_lock_2:getChildByName("txt_key")
    self.task_max_1 = btn_lock_2:getChildByName("txt_max")
    self.task_name_1:setString(task_data_1.title_mission_des)
    if task_data_1.title_mission_type == 1 then
        self.task_key_1:setString(bole:formatCoins(data.win_total, 2))
    else
        self.task_key_1:setString(bole:formatCoins(data.coins, 2))
    end
    self.task_max_1:setString("/"..bole:formatCoins(task_data_1.title_missioncounts, 2))


    local btn_lock_3 = root:getChildByName("btn_lock_3")
    self.task_name_2 = btn_lock_3:getChildByName("txt_name")
    self.task_key_2 = btn_lock_3:getChildByName("txt_key")
    self.task_max_2 = btn_lock_3:getChildByName("txt_max")

    self.select_country = root:getChildByName("select_country")
    self.select_country:addTouchEventListener(handler(self, self.touchEvent))
    self.select_country:setTouchEnabled(true)

    self.img_bg = self.select_country:getChildByName("img_bg")
    self.list_country = self.select_country:getChildByName("list_country")
    self.select_country:setVisible(false)
    self.img_bg:setScale(0.1)
    if task_data_2.title_mission_des then
        self.task_name_2:setString(task_data_2.title_mission_des)
        if task_data_2.title_mission_type == 1 then
            self.task_key_2:setString(bole:formatCoins(data.win_total, 2))
        else
            self.task_key_2:setString(bole:formatCoins(data.coins, 2))
        end
        self.task_max_2:setString("/"..bole:formatCoins(task_data_2.title_missioncounts, 2))
    else
        btn_lock_2:setPosition(637, 170)
        btn_lock_3:setVisible(false)
    end

    local titles = bole:getConfig("title")
    for k, v in pairs(titles) do
        local cell = bole:getEntity("app.views.TitleCell", k)
        self.list_country:addChild(cell)
    end
    local function scrollViewEvent(sender, evenType)
        if evenType == ccui.ScrollviewEventType.scrollToBottom then
            print("SCROLL_TO_BOTTOM")
        elseif evenType == ccui.ScrollviewEventType.scrollToTop then
            print("SCROLL_TO_TOP")
        end
    end
    self.list_country:addScrollViewEventListener(scrollViewEvent)

end

function TitleView:onEnter()
    bole:addListener("changeTitle", self.changeTitle, self, nil, true)
end

function TitleView:onExit()
    bole:getEventCenter():removeEventWithTarget("changeTitle", self)
end

function TitleView:changeTitle(event)
    local index = event.result
    self.img_bg:runAction(cc.ScaleTo:create(0.1, 0.1))
    self.select_country:runAction(cc.Sequence:create(cc.DelayTime:create(0.1), cc.Hide:create()))
    bole:setUserDataByKey("title", index)
    local name = bole:getConfig("title", index, "title_name")
    self.select_key:setString(name)
end
function TitleView:touchEvent(sender, eventType)
    local name = sender:getName()
    local tag = sender:getTag()
    print("touchEvent:" .. name)
    if eventType == ccui.TouchEventType.began then
        print("Touch Down")
        sender:setScale(1.05)
        if name == "select_country" then
            sender:setScale(1)
        end
    elseif eventType == ccui.TouchEventType.moved then
        print("Touch Move")
    elseif eventType == ccui.TouchEventType.ended then
        print("Touch Up")
        sender:setScale(1)
        if name == "btn_close" then
            self:closeUI()
        elseif name == "btn_title" then
            self.select_country:setVisible(true)
            self.img_bg:runAction(cc.ScaleTo:create(0.1, 1))
        elseif name == "select_country" then
            self.img_bg:runAction(cc.ScaleTo:create(0.1, 0.1))
            self.select_country:runAction(cc.Sequence:create(cc.DelayTime:create(0.1), cc.Hide:create()))
        end
    elseif eventType == ccui.TouchEventType.canceled then
        print("Touch Cancelled")
        sender:setScale(1)
    end
end

return TitleView
-- endregion
