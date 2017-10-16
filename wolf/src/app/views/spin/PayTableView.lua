--region *.lua
--Date
--此文件由[BabeLua]插件自动生成

local PayTableView = class("PayTableView", cc.load("mvc").ViewBase)
function PayTableView:ctor(themeId)
    self.themeId = themeId
    --临时
    self.themeId = 2
    local rootNode = cc.CSLoader:createNodeWithVisibleSize("csb/spin/payTableView.csb")
    self:addChild(rootNode)
    self.index = 1
    self:setViews(rootNode)
end

function PayTableView:setViews(rootNode)
    local bgNode = rootNode:getChildByName("bg")

    self.leftBtn = bgNode:getChildByName("leftBtn")
    self.rightBtn = bgNode:getChildByName("rightBtn")
    self.backGameBtn = bgNode:getChildByName("backGameBtn")
    self.bg = bgNode
    local function onClick(event)
        if event.name == "ended" then
            if event.target == self.leftBtn then
                self:addIndex(-1)
            elseif event.target == self.rightBtn then
                self:addIndex(1)
            elseif event.target == self.backGameBtn then
                self:removeFromParent(true)
            end
        end
    end

    self.leftBtn:onTouch(onClick)
    self.rightBtn:onTouch(onClick)
    self.backGameBtn:onTouch(onClick)

    self:setDialog(true)
    self:addIndex(0)

--    rootNode = tolua.cast(rootNode, "cc.Layer")
--    rootNode:onTouch(function(...) return true end, false, true)
end

function PayTableView:addIndex(num)
    self.index = self.index + num

    self.leftBtn:setEnabled(true)
    self.rightBtn:setEnabled(true)

    if self.index == 1 then
        self.leftBtn:setEnabled(false)
    elseif self.index == 3 then
        self.rightBtn:setEnabled(false)
    end

    self:changeView()
end

function PayTableView:changeView()
    local backView = self.backView
    if not backView then
        self.backView = cc.Sprite:create(bole:getSpinApp():getRes(self.themeId, "payTable/1.png"))
        self.bg:addChild(self.backView)
        self.backView:setPosition(self.bg:getContentSize().width/2, 240)
        return
    end

    backView:setTexture(bole:getSpinApp():getRes(self.themeId, string.format("payTable/%s.png", self.index)))
end

return PayTableView

--endregion
