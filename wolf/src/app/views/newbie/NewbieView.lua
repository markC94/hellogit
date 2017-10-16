--region *.lua
--Date
--此文件由[BabeLua]插件自动生成
local NewbieView = class("NewbieView", cc.Layer)
function NewbieView:ctor(info)
    self.id = info.id
    self.info = info

    local rootNode = cc.CSLoader:createNodeWithVisibleSize("newbie/newbieStep.csb")
    self.rootNode = rootNode
    self:addChild(rootNode)

    self:enableNodeEvents()
    self:checkStep()
    self:setContents()
end

function NewbieView:onEnter()
    bole:getBoleEventKey():addKeyBack(self)
    bole:addListener("exitNewbieInfo", self.close, self, nil, true)
end

function NewbieView:onExit()
    bole:getBoleEventKey():removeKeyBack(self)
    bole:removeListener("exitNewbieInfo", self)
end

function NewbieView:onKeyBack()

end

function NewbieView:checkStep()
    self.upFrameNode = self.rootNode:getChildByName("upInfoFrame")
    self.downFrameNode = self.rootNode:getChildByName("downInfoFrame")
    self.spinFrameNode = self.rootNode:getChildByName("spinStep")

    if self.id == "noExp" then
        self.upFrameNode:setVisible(false)
        self.downFrameNode:setVisible(false)
    elseif self.id == "afterSpinNum" then  --up
        self.spinFrameNode:setVisible(false)
        self.downFrameNode:setVisible(false)

        self.scaleBg = self.upFrameNode:getChildByName("bg")
        self.infoLabel = self.scaleBg:getChildByName("infoLabel")
        self.arrow = self.upFrameNode:getChildByName("arrow")
    elseif self.id == "down" then
        self.spinFrameNode:setVisible(false)
        self.upFrameNode:setVisible(false)

        self.scaleBg = self.downFrameNode:getChildByName("bg")
        self.infoLabel = self.scaleBg:getChildByName("infoLabel")
        self.arrow = self.downFrameNode:getChildByName("arrow")
    end

    if self.scaleBg then
        local function onClick()
            self:close()
        end
        self.scaleBg:onTouch(onClick)
        self:runAction(cc.Sequence:create(cc.DelayTime:create(3), cc.CallFunc:create(onClick)))
    end
end

function NewbieView:close()
    self:removeFromParent(true)
end

function NewbieView:addBlackCover()
    local coverNode = self.rootNode:getChildByName("coverNode")
    local layerNode = cc.LayerColor:create(cc.c4b(0, 0, 0, 180))
    coverNode:addChild(layerNode)
end

function NewbieView:swallowTouches()
    self:onTouch(function() return true end, false, true)
end

function NewbieView:setContents()
    if self.id == "noExp" then
        self:addBlackCover()
        self:swallowTouches()
        local spinBtn = self.spinFrameNode:getChildByName("spin")
        local function clickSpin(event)
            if event.name == "ended" then
                self:removeFromParent(true)
                bole:postEvent("clickSpin", {autoSpin = false})
            end
        end
        spinBtn:onTouch(clickSpin)
    elseif self.id == "afterSpinNum" then
        local pos = self.info.pos
        pos = self.rootNode:convertToNodeSpace(pos)
        self.upFrameNode:setPosition(pos.x, pos.y-20)
        self.scaleBg:setPositionX(self.scaleBg:getPositionX()+50)
        self.infoLabel:setString("Click on a personal avatar to view and edit personal information.")
    end
end

function NewbieView:run()
    local scene = cc.Director:getInstance():getRunningScene()
    scene:addChild(self, bole.ZORDER_TOP)
end

return NewbieView
--endregion
