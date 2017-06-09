-- 放大镜效果
-- magnifier     放大镜图片
-- parent        放大镜父亲节点
-- point         放大镜的位置
-- magnifierNode 被放大的精灵
function bole:magnifier(magnifierImage, parent, point, magnifierNode)
    -- 放大镜的模板，也是放大区域
    local magnifierRect = display.newSprite(magnifierImage)
    magnifierRect:setPosition(point)
    parent:addChild(magnifierRect,1)
    if parent._mclip ~= nil then
        parent._mclip:removeFromParentAndCleanup(true)
        parent._mclip = nil
    end
    -- 创建ClippingNode，这里要将模板传进去
    parent._mclip = CCClippingNode:create(magnifierRect)
    parent._mclip:setInverted(false)
    parent._mclip:setAlphaThreshold(0)
    parent._mclip:setZOrder(1)
    parent:addChild(parent._mclip)
    -- 添加放大镜照片，盖在放大镜区域上
    parent.magnifierNode = magnifierNode:anchor(D.BOTTOM_LEFT):p(0, 0):to(layer._mclip)
    parent.magnifierNode:setScale(1.2)
    -- 真实的放大镜
    local magnifier = D.img(magnifierImage):p(point):to(parent, 2)
    -- 在放大镜上绑定点击功能
    magnifier:bindTouch()
    function magnifier:onTouchBegan(x, y, touches)
        return true
    end
    -- 移动的时候实时计算放大物件的锚点和位置，当然还有放大模板的位置
    function magnifier:onTouchMoved(x, y, touches)
        self:p(x, y)
        magnifierRect:p(x, y)
        local anchor1 = parent.magnifierNode:getAnchorPoint()
        -- 把锚点定位到要放大的位置
        parent.magnifierNode:setAnchorPoint(ccp(x / magnifierNode.width
        , y / magnifierNode.height))
        local anchor2 = parent.magnifierNode:getAnchorPoint()
        parent.magnifierNode:p(ccp(parent.magnifierNode:px() + parent.magnifierNode:px()
        *(anchor2.x - anchor1.x),
        parent.magnifierNode:py() + parent.magnifierNode:py()
        *(anchor2.y - anchor1.y)))
    end
    function magnifierRect:onTouchEnded(x, y, touches)
    end
end
-- 调用代码，要指定width和height，后面计算锚点用
-- local magnifierNode = mainLayer.new();
-- magnifierNode.width = 960
-- magnifierNode.height= 640
-- layer:magnifier("panda/panda_1.png",layer,ccp(480,320),magnifierNode)
