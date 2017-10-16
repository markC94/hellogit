--region *.lua
--Date
--此文件由[BabeLua]插件自动生成

local ClubSymbolLayer = class("ClubSymbolLayer", cc.load("mvc").ViewBase)

local clubIcon =  bole:getClubManage():getClubIconIdTable()
local scrollViewHeight = 310   --滚动列表高

function ClubSymbolLayer:onCreate()
    print("ClubSymbolLayer-onCreate")
    local root = self:getCsbNode():getChildByName("root")
    
    local btn_close = root:getChildByName("btn_close")
    btn_close:addTouchEventListener(handler(self, self.touchEvent))

    local btn_close = root:getChildByName("btn_ok")
    btn_close:addTouchEventListener(handler(self, self.touchEvent))

    self.symbolView_ = root:getChildByName("ScrollView")
    --self.symbolView_:setScrollBarOpacity(0)
    self.chooseBg_ = self.symbolView_:getChildByName("Image")
    self.chooseBg_:setZOrder(3)

    self:initSymbolView()
    self:initSlider(root)
    self:adaptScreen(root)
end


function ClubSymbolLayer:onEnter()
    bole:addListener("initClubSymbolInfo", self.initInfo, self, nil, true)
end

function ClubSymbolLayer:initInfo(data)
    data = data.result
    self.id_ = data
    for k , v in pairs(self.symbolView_:getChildren()) do
        if tonumber(clubIcon[v:getTag()]) == tonumber(self.id_) then
            local x, y = v:getPosition()
             self.chooseBg_:setPosition(x + 68,y + 70)
        end
    end
end

function ClubSymbolLayer:initSymbolView()
    local iconNum = # clubIcon
    local height = math.ceil(iconNum / 4) * 150 + 20
    self.symbolView_:setInnerContainerSize(cc.size(700, height ))
    self.symbolView_:setScrollBarOpacity(0)
   self.symbolView_:addEventListener(handler(self, self.scrollViewEvent))
    self.scrollViewScrollMaxLenght_ = self.symbolView_:getInnerContainerSize().height - scrollViewHeight
    for i = 1, iconNum do
        local path = bole:getClubManage():getClubIconPath(clubIcon[i])
        local icon = ccui.ImageView:create(path)
        self.symbolView_:addChild(icon)
        icon:setScale(0.6)
        icon:setAnchorPoint(0,0)
        icon:setTouchEnabled(true)
        icon:addTouchEventListener(handler(self, self.chooseClubIcon))
        icon:setTag(i)
        if i % 4 == 0 then 
            icon:setPosition( 3 * 185 + 10, height - math.ceil(i / 4) * 150 )
        else
            icon:setPosition(( math.ceil(i % 4) - 1) * 185 + 10, height - math.ceil(i / 4) * 150 )
        end
    end
end

function ClubSymbolLayer:scrollViewEvent(sender, eventType)
    if eventType == 9 then
        local nowY = - self.symbolView_:getInnerContainerPosition().y 
        local posY = math.min( math.max(0 , nowY) , self.scrollViewScrollMaxLenght_)
        self.slider_:setPercent(posY / self.scrollViewScrollMaxLenght_ * 100)
    end
end

function ClubSymbolLayer:initSlider(root)
    self.sliderNode_ = cc.CSLoader:createNode("friend/SliderNode.csb")
    root:getChildByName("node_slider"):addChild(self.sliderNode_)
    self.sliderNode_:setRotation(270)
    self.slider_ = self.sliderNode_:getChildByName("root"):getChildByName("slider")
    self.slider_:setPercent(100)
    self.slider_:setContentSize(172,14)
    local sliderbg = self.sliderNode_:getChildByName("root"):getChildByName("slider_bg")
    sliderbg:setContentSize(300,15)
end

function ClubSymbolLayer:chooseClubIcon(sender, eventType)
    if eventType == ccui.TouchEventType.ended then
        local id = clubIcon[sender:getTag()]
        self.id_  = id
        local x, y = sender:getPosition()
        self.chooseBg_:setPosition(x + 68,y + 70)
    end
end

function ClubSymbolLayer:touchEvent(sender, eventType)
    local name = sender:getName()
    if eventType == ccui.TouchEventType.began then
         sender:runAction(cc.ScaleTo:create(0.1, 1.02, 1.02))
    elseif eventType == ccui.TouchEventType.moved then

    elseif eventType == ccui.TouchEventType.ended then
         sender:runAction(cc.ScaleTo:create(0.1, 1, 1))
        if name == "btn_close" then
               self:closeUI()
        elseif name == "btn_ok" then
            bole:postEvent("chooseClubSymbol",self.id_)
            self:closeUI()
       end
        
    elseif eventType == ccui.TouchEventType.canceled then
         sender:runAction(cc.ScaleTo:create(0.1, 1, 1))
    end
end

function ClubSymbolLayer:onExit()
    bole:removeListener("initClubSymbolInfo", self)
end


function ClubSymbolLayer:adaptScreen(root)
    local winSize = cc.Director:getInstance():getWinSize()
    self:setPosition(0, 0)
    root:setPosition(winSize.width / 2, winSize.height / 2)
    root:setScale(0.1)
    root:runAction(cc.ScaleTo:create(0.2, 1, 1))
end


return ClubSymbolLayer




--endregion
