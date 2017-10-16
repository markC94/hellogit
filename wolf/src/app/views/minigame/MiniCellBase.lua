--region *.lua
--Date
--此文件由[BabeLua]插件自动生成
local MiniCellBase =class("MiniCellBase",cc.Node)
function MiniCellBase:ctor(index,func)
    self.index=index
    --点击宝箱回调传回index
    self.func=func
    self.clickType=0
    self.isClick=false
    self.isOver=false
    self.isEnable=true
    self.isTouchEnables=true
    self:initUI()
end
function MiniCellBase:initUI()
    local path= bole:getSpinApp():getMiniRes(nil,"mini_game/MiniCell.csb")
    self.csbNode = cc.CSLoader:createNodeWithVisibleSize(path)
    self.csbAct = cc.CSLoader:createTimeline(path)
    self.csbNode:runAction(self.csbAct)
    self:addChild(self.csbNode)
    self.csbAct:gotoFrameAndPause(0)

    local touch = self.csbNode:getChildByName("touch")
    touch:setTouchEnabled(true)
    touch:addTouchEventListener(handler(self, self.touchEvent))
    self:initView()
end
--子类初始化
function MiniCellBase:initView()
    
end

function MiniCellBase:touchEvent(sender, eventType)
    local name = sender:getName()
    local tag = sender:getTag()
    if eventType == ccui.TouchEventType.began then
        print("Touch Down")
    elseif eventType == ccui.TouchEventType.moved then
        print("Touch Move")
    elseif eventType == ccui.TouchEventType.ended then
        print("Touch ended")
        if self.isTouchEnables then
            if self.func then
                self.func(self.index)
            end
        end
    elseif eventType == ccui.TouchEventType.canceled then
        print("Touch Cancelled")
    end
end


function MiniCellBase:delayClick()
    if self.clickType ~= 2 then
        return
    end
    if not self.delayData then
        return
    end
    self.isEnable = false
    self:showCell(self.delayData)
end

--设置点击做动画的node
function MiniCellBase:setClickNode(node)
    self.click_node=node
end

--点开宝箱
function MiniCellBase:toClick()
    if self.clickType ~= 0 then
        return
    end
    if not self.click_node then
        self.clickType = 2
        self:delayClick()
        return 
    end
    local seq = cc.Sequence:create(cc.ScaleTo:create(0.2, 1.1), cc.DelayTime:create(0.1), cc.ScaleTo:create(0.2, 1))
    self.click_node:runAction(seq)
    self.clickType = 1
    performWithDelay(self, function()
        self.clickType = 2
        self:delayClick()
    end , 0.5)
end
--接收打开宝箱数据
function MiniCellBase:recvClick(data)
    if not self.isEnable then
        return
    end
    self.delayData = data
    self:delayClick()
    return
end
--接收游戏结束展开宝箱数据
function MiniCellBase:recvOver(data)
    if not self.isEnable then return end
    self.isEnable = false
    self:showCell(data,true)
end
--宝箱数据显示需要子类继承
function MiniCellBase:showCell(data,isOver)
    
end
return MiniCellBase
--endregion
