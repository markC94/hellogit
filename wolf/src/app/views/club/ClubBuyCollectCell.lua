--region *.lua
--Date
--此文件由[BabeLua]插件自动生成
local ClubBuyCollectCell = class("ClubBuyCollectCell", cc.Node)
local multiplier = 0.05

function ClubBuyCollectCell:ctor(data,i)
    self.index_ = i
    self.data_ = data
    self.node_ = cc.CSLoader:createNode("club/ClubBuyCollectCell.csb")
    self:addChild(self.node_)

    local root = self.node_:getChildByName("root")
    local btn_collect = root:getChildByName("btn_collect")
    btn_collect:addTouchEventListener(handler(self, self.touchEvent))
  
    self.coinsNum_ = root:getChildByName("img_icon_bg"):getChildByName("txt_coins")
    self.multiplier_ = root:getChildByName("txt_collect_tips")
    self.icon_ = root:getChildByName("sp_collect_test")
end

function ClubBuyCollectCell:touchEvent(sender, eventType)
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


function ClubBuyCollectCell:refrushClubBuy(data,i)

     --self.clubInfo_ = data
      self.index_ = i
    self.data_ = data
    local info = require("json").decode(self.data_.user_data)
    self.coinsNum_:setString( bole:formatCoins(self.data_.amount,15) )
    self.multiplier_:setString( info[1] ..  " purchased a Club Offer and won 500,000 coins")

    local head = bole:getNewHeadView( { user_id = self.data_.user_id , name = info[1], icon = info[2], level = info[3], country = info[4] })
    head:setScale(0.7)
    head:setSwallow(true)
    head.Img_headbg:setTouchEnabled(false)
    head:updatePos(head.POS_CHAT_FRIEND)
    self.node_:getChildByName("root"):addChild(head)
    head:setPosition(70,55)
end

function ClubBuyCollectCell:collect()
    print(self.data_.gift_id)
    bole:postEvent("collectClubBuy",{self.data_.gift_id,self.index_})
end


return ClubBuyCollectCell
--endregion
