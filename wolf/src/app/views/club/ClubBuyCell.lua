--region *.lua
--Date
--此文件由[BabeLua]插件自动生成
local ClubBuyCell = class("ClubBuyCell", cc.Node)
function ClubBuyCell:ctor(data,type)
    if type == "inClub" then
        self.node_ = cc.CSLoader:createNode("csb/club_cell/ClubBuyCell.csb")
    elseif type == "inChat" then
        self.node_ = cc.CSLoader:createNode("csb/chat/ChatClubBuyCell.csb")
    end

    self:addChild(self.node_)
    local root = self.node_:getChildByName("root")
    self.clubInfo_ = data

    local btn_buy = root:getChildByName("btn_buy")
    btn_buy:addTouchEventListener(handler(self, self.touchEvent))
    self.price_ = btn_buy:getChildByName("txt_buy")
    self.coinsNum_ = root:getChildByName("img_icon_bg"):getChildByName("txt_coins")
    self.multiplier_ = root:getChildByName("txt_buy_tips")
    --self:refrushClubBuy(data)
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


function ClubBuyCell:refrushClubBuy(data)
     self.clubInfo_ = data
    local id = tonumber(self.clubInfo_.level) + 1000
    self.rfm_ = tonumber(bole:getUserDataByKey("purchase_level"))
    self.showInfo_ = {}
    self.showInfo_.num = bole:getConfigCenter():getConfig("club_sale", id , "coins_amount")
    self.showInfo_.multiplier = bole:getConfigCenter():getConfig("club_sale", id , "gift_multiplier")
    self.showInfo_.price =  bole:getConfigCenter():getConfig("price", bole:getConfigCenter():getConfig("club_sale", id , "price_id"), "price")

    self.coinsNum_:setString( bole:formatCoins(self.showInfo_.num,15))
    self.price_:setString("$ " .. self.showInfo_.price)
    local multiplier = bole:getConfigCenter():getConfig("club_sale", id , "gift_multiplier")
    self.multiplier_:setString("Get a club offer and each member will receive free " .. bole:formatCoins(self.showInfo_.num * 0.1,15) .. " bonus chips.")

end


function ClubBuyCell:buy()

end


return ClubBuyCell


--endregion
