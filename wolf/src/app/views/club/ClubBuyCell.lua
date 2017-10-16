--region *.lua
--Date
--此文件由[BabeLua]插件自动生成
local ClubBuyCell = class("ClubBuyCell", cc.Node)
local multiplier = 0.05
local clubBuyId = 1032

function ClubBuyCell:ctor(type)
    local buyCell 
    if type == "inClub" then
        buyCell = cc.CSLoader:createNode("club/ClubBuyCell.csb")
    elseif type == "inChat" then
        buyCell = cc.CSLoader:createNode("inSlot_chat/ChatClubBuyCell.csb")
    end

    self:addChild(buyCell)
    local root = buyCell:getChildByName("root")
    self.root_ = root
    local btn_buy = root:getChildByName("btn_buy")
    btn_buy:addTouchEventListener(handler(self, self.touchEvent))
    self.price_ = btn_buy:getChildByName("txt_buy")
    self.coinsNum_ = root:getChildByName("img_icon_bg"):getChildByName("txt_coins")
    self.multiplier_ = root:getChildByName("txt_buy_tips")
    self.multiplier2_ = root:getChildByName("txt_buy_tips2")
    self.num_coins_ = root:getChildByName("txt_coins_0")
    self.cellType_ = type
    --self:refrushClubBuy()
end

function ClubBuyCell:touchEvent(sender, eventType)
    local name = sender:getName()
    if eventType == ccui.TouchEventType.began then
        sender:runAction(cc.ScaleTo:create(0.1, 1.05, 1.05))
    elseif eventType == ccui.TouchEventType.moved then

    elseif eventType == ccui.TouchEventType.ended then
        sender:runAction(cc.ScaleTo:create(0.1, 1, 1))
        if name == "btn_close" then

        elseif name == "btn_buy" then
            self:buy()
        end
    elseif eventType == ccui.TouchEventType.canceled then
        sender:runAction(cc.ScaleTo:create(0.1, 1, 1))
    end
end


function ClubBuyCell:refrushClubBuy()
    self.rfm_ = tonumber(bole:getUserDataByKey("purchase_level"))
    self.showInfo_ = { }
    local buyList = bole:getBuyManage():getPriceDataById(clubBuyId)
    self.showInfo_.commodity_id = buyList.commodity_id
    self.showInfo_.num = buyList.coins_amount
    self.showInfo_.price = buyList.price
    self.showInfo_.multiplier = self.showInfo_.num * multiplier

    self.coinsNum_:setString(bole:formatCoins(self.showInfo_.num, 15))
    self.price_:setString("$ " .. self.showInfo_.price)

    if self.cellType_ == "inChat" then
        self.root_:getChildByName("txt_coins_re"):setString(bole:formatCoins(self.showInfo_.multiplier, 15))
        self.price_:setString("$" .. self.showInfo_.price)
    else
        self.multiplier_:setString("Get a club offer and each member will")
        self.multiplier2_:setString("receive")
        self.num_coins_:setString(bole:formatCoins(self.showInfo_.multiplier, 15))
    end
end


function ClubBuyCell:buy()
    bole:getBuyManage():buy(self.showInfo_.commodity_id)
end


return ClubBuyCell


--endregion
