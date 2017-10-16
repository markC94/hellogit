--region *.lua
--Date
--此文件由[BabeLua]插件自动生成
local PayTable = class("PayTable", cc.Node)
function PayTable:ctor(theme_id)
    self.theme_id=theme_id
    local windowSize = cc.Director:getInstance():getWinSize()
    self.mask= bole:getUIManage():getNewMaskUI("PayTable")
    self.mask:setPosition(cc.p(windowSize.width / 2, windowSize.height / 2))
    self:addChild(self.mask)
    self:init()
    local path= bole:getSpinApp():getMiniRes(nil,"pay_table/PayTable.csb")
    self.pytNode = cc.CSLoader:createNodeWithVisibleSize(path)
    self:addChild(self.pytNode)
    self.pytAct = cc.CSLoader:createTimeline(path)
    self.pytNode:runAction(self.pytAct)
    self.pytAct:play("start",false)
    self.index=0
    self.maxCount=4
    if theme_id== 2 then
        self.maxCount=3
    elseif theme_id== 6 then
        self.maxCount=5
    end
    self.isClick=false
    self:initUI()
end
function PayTable:initUI()
    local root = self.pytNode:getChildByName("root")
    local node_act = root:getChildByName("node_act")
    self.page_root = node_act:getChildByName("page_root")


    local btn_root =node_act:getChildByName("btn_root")
    local node_back =btn_root:getChildByName("node_back")
    local node_left =btn_root:getChildByName("node_left")
    local node_right =btn_root:getChildByName("node_right")
    local btn_back =node_back:getChildByName("btn_back")
    local btn_left =node_left:getChildByName("btn_left")
    local btn_right =node_right:getChildByName("btn_right")

    btn_back:setTouchEnabled(true) 
    btn_back:addTouchEventListener(handler(self, self.touchEvent))

    btn_left:setTouchEnabled(true)
    btn_left:addTouchEventListener(handler(self, self.touchEvent))

    btn_right:setTouchEnabled(true)
    btn_right:addTouchEventListener(handler(self, self.touchEvent))
end


function PayTable:init()
    self:registerScriptHandler( function(tag)
        if "enter" == tag then
            self:onEnter()
        elseif "exit" == tag then
            self:onExit()
        end
    end )
end

function PayTable:onEnter()
    bole:getBoleEventKey():addKeyBack(self)
end

function PayTable:onExit()
    bole:getBoleEventKey():removeKeyBack(self)
end

function PayTable:onKeyBack()
   self:toBack()
end


function PayTable:updatePage(index)
    if index>=self.maxCount or index<0 then
        return
    end
    if index== self.index then
        return
    end                                                                                               
    if self.isClick then
        return
    end

    self.index=index
    self.isClick=true
    self.page_root:runAction(cc.MoveTo:create(0.3,cc.p(-self.index*1334,0)))
    performWithDelay(self,function()
        self.isClick=false
    end,0.3)
end

function PayTable:toBack()
    if self.isBack then
        return
    end
    self.isBack=true
    self.pytAct:play("end",false)
    self.mask:removeFromParent()
    performWithDelay(self,function()
        self:closeUI()
    end,0.4)
end

function PayTable:closeUI()
    bole:autoOpacityC(self)
    local ac1 = cc.FadeOut:create(0.2)
    local ac2 = cc.CallFunc:create(handler(self, self.removeSelf))
    self.pytNode:runAction(cc.Sequence:create(ac1,ac2))
end
function PayTable:removeSelf()
    self:removeFromParent()
end

function PayTable:toRight()
    self:updatePage(self.index+1)
end

function PayTable:toLeft()
    self:updatePage(self.index-1)
end

function PayTable:touchEvent(sender, eventType)
    local name = sender:getName()
    local tag = sender:getTag()
    print("touchEvent:" .. name)
    if eventType == ccui.TouchEventType.began then
        print("Touch Down")
    elseif eventType == ccui.TouchEventType.moved then
        print("Touch Move")
    elseif eventType == ccui.TouchEventType.ended then
        print("Touch Up")
        if (name == "btn_back") then
           self:toBack()
        elseif (name == "btn_right") then
           self:toRight()
        elseif (name == "btn_left") then
            self:toLeft()
        end
    elseif eventType == ccui.TouchEventType.canceled then
        print("Touch Cancelled")
    end
end

return PayTable


--endregion
