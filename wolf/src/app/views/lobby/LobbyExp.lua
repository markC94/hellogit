--region *.lua
--Date
--此文件由[BabeLua]插件自动生成
local LobbyExp = class("LobbyExp", cc.Node)

function LobbyExp:ctor(node)
    if not node then
        self.node_progress = cc.CSLoader:createNode("csb/lobby/LobbyExp.csb")
    else
        node:removeFromParent()
        self.node_progress = node
    end
    self:addChild(self.node_progress)

    self:registerScriptHandler(function(state)
        if state == "enter" then
            self:onEnter()
        elseif state == "exit" then
            self:onExit()
        end
    end)

    local clipNode = cc.ClippingNode:create()
    local mask = display.newSprite("#common/common_lv_Pbar.png")
    clipNode:setAlphaThreshold(0)
    clipNode:setStencil(mask)
    self.move_eff = display.newSprite("#common/common_lv_PbarLight.png")
    -- eff:setScale(mask:getContentSize().width / head:getContentSize().width)
    clipNode:addChild(self.move_eff)
    clipNode:setPosition(cc.p(106, 15))
    self.bar_exp = self.node_progress:getChildByName("bar_exp")
    self.bar_exp:addChild(clipNode)
    self:updateProgress(bole:getExpPercent())
end

function LobbyExp:onEnter()
    bole:addListener("experienceChanged", self.onExpChanged, self, nil, true)
end

function LobbyExp:onExit()
    bole:getEventCenter():removeEventWithTarget("experienceChanged", self)
end


function LobbyExp:onExpChanged(event)
    self:updateProgress(bole:getExpPercent())
end

function LobbyExp:updateProgress(progress)
    if progress >= 100 then
        progress = 100
    end
    self.bar_exp:setPercent(progress)
    local off = 1
    self.move_eff:setPosition(cc.p(-106 - 23 + 2.12 * progress + off, 0))
end
return LobbyExp
--endregion
