-- region *.lua
-- Date
-- 此文件由[BabeLua]插件自动生成
local LobbyCell = class("LobbyCell", cc.Node)
local STATUS_SOON = 0-- 敬请期待
local STATUS_DL_UNLOCK = 1-- 已下载已解锁
local STATUS_DL_LOCK = 2 -- 已下载未解锁
local STATUS_UNLOCK = 3 -- 未下载已解锁
local STATUS_LOCK = 4 -- 未下载未解锁
local STATUS_LOADING = 5 -- 下载中
function LobbyCell:ctor(theme_id)
    self.theme_id = tonumber(theme_id)
    print("self.theme_id:" .. self.theme_id)
    self.cell = cc.CSLoader:createNode("csb/lobby/LobbyCell.csb")
    self:addChild(self.cell)
    self.touch = self.cell:getChildByName("touch")
    self.soon = self.cell:getChildByName("soon")
    self.img_icon = self.touch:getChildByName("img_icon")
    self.node_load = self.touch:getChildByName("node_load")
    self.img_down = self.touch:getChildByName("img_down")
    local lock = self.touch:getChildByName("lock")
    self.img_lockbg = lock:getChildByName("img_lockbg")
    self.txt_name = self.img_lockbg:getChildByName("txt_name")
    self.img_lock = self.touch:getChildByName("img_lock")
    self.sp_new = self.touch:getChildByName("sp_new")
    self.sp_hot = self.touch:getChildByName("sp_hot")
    self.sp_task = self.touch:getChildByName("sp_task")
    self.sp_soon = self.touch:getChildByName("sp_soon")
    self.delyTime = -1
    self.isMenu = false
    self.isBegin = false
    self.touch:setTouchEnabled(true)
    self.touch:addTouchEventListener(handler(self, self.touchEvent))
    self.touch:setSwallowTouches(false)

    self:updateImg()
    self:registerScriptHandler( function(tag)
        if "enter" == tag then
            self:onEnter()
        elseif "exit" == tag then
            self:onExit()
        end
    end )
    local function update(dt)
        self:updateTime(dt)
    end
    self:onUpdate(update)
    self:initProgress()
end


function LobbyCell:initProgress()
    if self.theme_id <= 0 then
        return
    end
    -- 创建进度条
    local num = string.format("%02d", self.theme_id)
    local themePath = "theme_icon/theme_" .. num .. ".png"
    local img = display.newSprite(themePath)
    self.loadingProgress = cc.ProgressTimer:create(img)
    self.loadingProgress:setType(cc.PROGRESS_TIMER_TYPE_RADIAL)
    self.loadingProgress:setPercentage(0)
    -- 设置初始进度为30
    self.loadingProgress:setPosition(0, 0)
    self.node_load:addChild(self.loadingProgress)
    self.loadingProgress:setVisible(false)
end

function LobbyCell:updateProgress(msg, max)
    print("LobbyCell:updateProgress-------------------msg="..msg.."/"..max)
    if msg >= max then
        msg = max
    end
    local progress = msg * 100 / max
    self.loadingProgress:setPercentage(progress)
end

function LobbyCell:touchEvent(sender, eventType)
    local name = sender:getName()
    local tag = sender:getTag()
    if eventType == ccui.TouchEventType.began then
        bole:clickScale(sender, 0.1, 0.9)
        if name == "touch" then
            self.isBegin = true
            if self.status == STATUS_DL_UNLOCK then
                -- 1.5秒后弹菜单
                self.delyTime = 1
            end
        end
    elseif eventType == ccui.TouchEventType.moved then
--        if name == "touch" then
--            local bPos = sender:getTouchBeganPosition()
--            local ePos = sender:getTouchEndPosition()
--            if math.abs(bPos.x - ePos.x) > 150 then
--                self.delyTime = -1
--                self.isBegin = false
--            end
--        end
    elseif eventType == ccui.TouchEventType.ended then
        sender:setScale(1)
        self.delyTime = -1
        if self.isMenu then
            bole:clickScale(sender, 0.1)
            return
        end

        if not self.isBegin then
            bole:clickScale(sender, 0.1)
            return
        end
        self.isBegin = false
--        local bPos = sender:getTouchBeganPosition()
--        local ePos = sender:getTouchEndPosition()
--        if math.abs(bPos.x - ePos.x) > 150 then
--            bole:clickScale(sender, 0.1)
--            return
--        end
        if name == "touch" then
            bole:clickScale(sender, 0.1, nil, function()
                self:toClick()
            end )
        end
    elseif eventType == ccui.TouchEventType.canceled then
        self.isBegin = false
        self.delyTime = -1
        bole:clickScale(sender, 0.1)
    end
end

function LobbyCell:toClick()
    print("self.theme_id:" .. self.theme_id)
    print("self.status:" .. self.status)
    if self.status == STATUS_DL_UNLOCK then

        bole:getAppManage():startGame(self.theme_id)
    elseif self.status == STATUS_DL_LOCK then
        -- 未解锁
--        bole:popMsg( { msg = "not unLock!" })
        self:showLock()
    elseif self.status == STATUS_UNLOCK then
        bole:downLoadTheme(self.theme_id)
    elseif self.status == STATUS_LOCK then
        -- 未解锁未下载
        self:showLock()
    elseif self.status == STATUS_SOON then
        -- 敬请期待
    elseif self.status == STATUS_LOADING then
        -- 下载中
    end
end

function LobbyCell:onEnter()
    bole:addListener("LobbyCell", self.updateUI, self, nil, true)
end
function LobbyCell:onExit()
    bole:getEventCenter():removeEventWithTarget("LobbyCell", self)
end
function LobbyCell:updateUI(event)
    local data = event.result
    dump(data,"LobbyCell:-------------------updateUI")
    -- 改变状态
    if data.theme_id == self.theme_id then
        if data.msg == "downLoad" then
            self:setStatus(STATUS_LOADING)
        elseif data.msg == "waiting" then
            self:setStatus(STATUS_LOADING)
        elseif data.msg == "updateProgress" then
            self:updateProgress(data.progress, data.max)
        else
            self:updateImg()
        end
    end
end
function LobbyCell:updateTime(dt)
    if self.delyTime == -1 then return end
    if self.delyTime > 0 then
        self.delyTime = self.delyTime - dt
        if self.delyTime <= 0 then
            self:toTrigger()
            self.delyTime = -1
        end
    end
end

function LobbyCell:toTrigger()
    self.touch:setScale(1)
    bole:getUIManage():popLobbyMenu(self, self.theme_id)
    self.isMenu = true
end
function LobbyCell:disTrigger()
    self.isMenu = false
end
function LobbyCell:setStatus(status)
    self.status = status
    if self.img_icon then
        self.img_icon:setOpacity(255)
    end
    if self.img_lock then
        self.img_lock:setVisible(false)
    end
    if self.img_lockbg then
        self.img_lockbg:setVisible(false)
    end
    if self.img_down then
        self.img_down:setVisible(false)
    end
    if self.loadingProgress then
        self.loadingProgress:setVisible(false)
    end

    if self.status == STATUS_DL_LOCK then
        self.img_icon:setOpacity(255 * 0.6)
        self.img_lock:setVisible(true)
        self.img_lockbg:setVisible(true)
    elseif self.status == STATUS_DL_UNLOCK then

    elseif self.status == STATUS_LOCK then
        self.img_icon:setOpacity(255 * 0.6)
        self.img_lock:setVisible(true)
        self.img_lockbg:setVisible(true)
        self.img_down:setVisible(true)
    elseif self.status == STATUS_UNLOCK then
        self.img_down:setVisible(true)

    elseif self.status == STATUS_LOADING then
        if self.loadingProgress then
            self.loadingProgress:setVisible(true)
        end
        self.img_icon:setOpacity(255*0.3)

    elseif self.status == STATUS_SOON then
        
    end
end
function LobbyCell:updateImg()
    if self.theme_id <= 0 then
        self:setStatus(STATUS_SOON)
        self.touch:setVisible(false)
        self.soon:setVisible(true)
        return
    end
    local theme = bole:getConfigCenter():getConfig("theme", "" .. self.theme_id)

    self.touch:setVisible(true)
    self.soon:setVisible(false)

    local num = string.format("%02d", self.theme_id)
    
    local isNew = theme.isnew
    if isNew ~= 3 then
        local themePath = "theme_icon/theme_" .. num .. ".png"
        self.img_icon:loadTexture(themePath)
        local level = bole:getUserDataByKey("level")
        local isDL = bole:isDownLoadTheme(self.theme_id)
        local unlock_lv=theme.unlock_lv
--        unlock_lv=1
--        if self.theme_id~=2 then
--            unlock_lv=999
--        end
        self.txt_name:setString(""..unlock_lv)
        if level >= unlock_lv then
            if isDL then
                self:setStatus(STATUS_DL_UNLOCK)
            else
                self:setStatus(STATUS_UNLOCK)
            end
        else
            if isDL then
                self:setStatus(STATUS_DL_LOCK)
            else
                self:setStatus(STATUS_LOCK)
            end
        end
    else
        self:setStatus(STATUS_SOON)
        local themePath = "theme_icon/theme_" .. num .. "_s.png"
        self.img_icon:loadTexture(themePath)
    end

    self.sp_new:setVisible(false)
    self.sp_hot:setVisible(false)
    self.sp_soon:setVisible(false)

    if isNew == 1 then
        self.sp_new:setVisible(true)
    elseif isNew == 2 then
        self.sp_hot:setVisible(true)
    elseif isNew == 3 then
        self.sp_soon:setVisible(true)
    end
    local club = bole:getUserDataByKey("club")
    local themeIds = bole:getUserDataByKey("theme_id")

    if self.theme_id == themeIds[3] then
        self.sp_task:setVisible(true)
    else
        self.sp_task:setVisible(false)
    end
end

function LobbyCell:showLock()
    if self.isShowLock then
        return
    end
    self.isShowLock = true
    local exIn=cc.EaseExponentialIn:create(cc.MoveTo:create(0.5, cc.p(35, 31 - 5)))
    local seq = cc.Sequence:create(exIn, cc.MoveTo:create(0.05, cc.p(35, 31)))
    self.img_lockbg:runAction(seq)
    performWithDelay(self, function()
        self:hideLock()
    end , 2)
end

function LobbyCell:hideLock()
    self.isShowLock = false
    local exIn=cc.EaseExponentialIn:create(cc.MoveTo:create(0.5, cc.p(35, 101)))
    local seq = cc.Sequence:create(cc.MoveTo:create(0.05, cc.p(35, 31-5)),exIn)
    self.img_lockbg:runAction(exIn)
end

return LobbyCell
-- endregion
