--region *.lua
--Date
--此文件由[BabeLua]插件自动生成

local ChatClubBuyCollectCell = class("ChatClubBuyCollectCell", cc.Node)
local multiplier = 0.05

function ChatClubBuyCollectCell:ctor(data)
    bole.socket:registerCmd("collect_club_gift", self.reCollect_club_gift, self)
    self.data_ = data
    self.node_ = cc.CSLoader:createNode("inSlot_chat/ChatClubCollectOfferCell.csb")
    self:addChild(self.node_)

    local root = self.node_:getChildByName("root")
    local btn_collect = root:getChildByName("btn_collect")
    btn_collect:addTouchEventListener(handler(self, self.touchEvent))
    self.btn_collect = btn_collect

    self.info_ = root:getChildByName("info")
    self.head_ = root:getChildByName("head")

    self:refrushClubBuy(data)
end

function ChatClubBuyCollectCell:touchEvent(sender, eventType)
    local name = sender:getName()
    if eventType == ccui.TouchEventType.began then
        sender:runAction(cc.ScaleTo:create(0.1, 1.05, 1.05))
    elseif eventType == ccui.TouchEventType.moved then

    elseif eventType == ccui.TouchEventType.ended then
        sender:runAction(cc.ScaleTo:create(0.1, 1, 1))
        if name == "btn_close" then

        elseif name == "btn_collect" then
            self:collect()
        end
    elseif eventType == ccui.TouchEventType.canceled then
        sender:runAction(cc.ScaleTo:create(0.1, 1, 1))
    end
end


function ChatClubBuyCollectCell:refrushClubBuy(data)

    self.data_ = data
    --self.coinsNum_:setString( bole:formatCoins(self.data_.amount,15) )
    self.info_:setString( data.sender_name ..  " purchased a Club Offer and won 500,000 coins")

    local head = bole:getNewHeadView(data.userData)
    head:setScale(0.7)
    head:setSwallow(true)
    head.Img_headbg:setTouchEnabled(false)
    head:updatePos(head.POS_CHAT_FRIEND)
    self.head_:addChild(head)
end

function ChatClubBuyCollectCell:collect()
    print(self.data_.gift_id)
    bole.socket:send("collect_club_gift", { gift_id = self.data_.otherInfo.gift_id } )
end

function ChatClubBuyCollectCell:reCollect_club_gift()
    self.btn_collect:setTouchEnabled(false)
    self.btn_collect:getChildByName("txt"):setString("collected")
    local syncUserInfo = bole:getUserData():getSyncUserInfo()
    local coins = syncUserInfo.coins
    bole:postEvent("putWinCoinToTop", { coin = coins })
    --bole:getAppManage():addCoins( bole:getBuyManage():getPriceDataById(1032).coins_amount * 0.05)
end

return ChatClubBuyCollectCell

--endregion
