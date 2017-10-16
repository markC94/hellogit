-- region *.lua
-- Date
-- 此文件由[BabeLua]插件自动生成
local LobbyMenu = class("LobbyMenu", cc.Node)
--主题私密房间
function LobbyMenu:ctor(node, theme_id)
    self.theme_id = theme_id
    self.node = node
    print("self.theme_id:" .. self.theme_id)
    local theme = bole:getConfigCenter():getConfig("theme", "" .. self.theme_id)
    self.menu = cc.CSLoader:createNode("csb/lobby/LobbyMenu.csb")
    self:addChild(self.menu)
    local root = self.menu:getChildByName("root")
    local txt_tips = root:getChildByName("txt_tips")
    txt_tips:setString(theme.theme_cion)
    local btn_start = root:getChildByName("btn_start")
    local btn_remove = root:getChildByName("btn_remove")
    local btn_close = root:getChildByName("btn_close")
    local function touchEvent(sender, eventType)
        local name = sender:getName()
        local tag = sender:getTag()
        if eventType == ccui.TouchEventType.began then
            sender:setScale(1.05)
        elseif eventType == ccui.TouchEventType.ended then
            sender:setScale(1)
            if name == "btn_close" then
                print("self.theme_id:" .. self.theme_id)
                self:closeUI()
            end
            if name == "btn_start" then
                print("self.theme_id:" .. self.theme_id)
                bole:getAppManage():startGame(self.theme_id, 1)
            end
            if name == "btn_remove" then
                print("self.theme_id:" .. self.theme_id)
                self:removeTheme()
            end
        elseif eventType == ccui.TouchEventType.canceled then
            sender:setScale(1)
        end
    end
    btn_start:addTouchEventListener(touchEvent)
    btn_remove:addTouchEventListener(touchEvent)
    btn_close:addTouchEventListener(touchEvent)
    self:init()
end

function LobbyMenu:init()
    self:registerScriptHandler( function(tag)
        if "enter" == tag then
            self:onEnter()
        elseif "exit" == tag then
            self:onExit()
        end
    end )
end

function LobbyMenu:removeTheme()
    bole:removeTheme(self.theme_id)
    self:closeUI()
end

function LobbyMenu:onEnter()
    bole:getBoleEventKey():addKeyBack(self)
end

function LobbyMenu:onExit()
    bole:getBoleEventKey():removeKeyBack(self)
end

function LobbyMenu:onKeyBack()
   self:closeUI()
end

function LobbyMenu:closeUI()
    if self.node.disTrigger then
        self.node:disTrigger()
    end
    bole:autoOpacityC(self)
    local ac1 = cc.FadeOut:create(0.2)
    local ac2 = cc.CallFunc:create(handler(self, self.removeSelf))
    self.menu:runAction(cc.Sequence:create(ac1, ac2))
end

function LobbyMenu:removeSelf()
    self:removeFromParent()
end
return LobbyMenu
-- endregion
