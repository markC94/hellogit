-- region *.lua
-- Date
-- 此文件由[BabeLua]插件自动生成
local ClubTipsLayer = class("ClubTipsLayer", cc.load("mvc").ViewBase)
ClubTipsLayer.MEMBERS_KICK_OUT = 1         --请出联盟确认
ClubTipsLayer.MEMBERS_ROOM_FULL = 2        --房间已满提示
ClubTipsLayer.MEMBERS_UNLOCK = 3           --主题未解锁提示
ClubTipsLayer.MEMBERS_DEGRADE = 4          --成员降级提示
ClubTipsLayer.REQUEST_DECLINE = 5          --拒绝联盟申请提示
ClubTipsLayer.REQUEST_DONATEONLYONE = 6    --今日已捐献提示
ClubTipsLayer.JOINLAYER_PENDING = 7        --已经申请过加入此联盟提示
ClubTipsLayer.JOINLAYER_FULL = 8           --申请联盟人数已满提示
ClubTipsLayer.JOINLAYER_UNLEVEL = 9        --申请联盟等级不足提示
ClubTipsLayer.ALREADY_JOINCLUB = 10        --已经加入联盟提示
ClubTipsLayer.ALREADY_BACKCLUB = 11        --已经退出联盟提示
ClubTipsLayer.JOINLAYER_SEARCHNOCLUB = 12  --未找到搜索联盟提示
ClubTipsLayer.CREATECLUB_REPETITION = 13   --创建重复名字联盟提示
ClubTipsLayer.LEAVECLUB = 14               --退出联盟提示
ClubTipsLayer.NO_ENOUGHCOINS = 15          --您没有足够的金币
ClubTipsLayer.NO_ENOUGHDIAMOND = 16        --您没有足够的钻石
ClubTipsLayer.INVITE_CLUB = 17             --是否接受邀请加入公会
ClubTipsLayer.INVITE_CLUB_SUCCEED = 18     --邀请加入公会成功
ClubTipsLayer.INVITE_CLUB_DEFEATED = 19    --邀请加入公会失败

function ClubTipsLayer:onCreate()
    print("ClubTipsLayer-onCreate")
    local root = self:getCsbNode():getChildByName("root")
    local btn_ok = root:getChildByName("btn_ok")
    btn_ok:addTouchEventListener(handler(self, self.touchEvent))
    local btn_no = root:getChildByName("btn_no")
    btn_no:addTouchEventListener(handler(self, self.touchEvent))

    local winSize = cc.Director:getInstance():getWinSize()
    root:setPosition(winSize.width / 2, winSize.height / 2)
end
function ClubTipsLayer:updateUI(event)
    local data= event.result
    self:changeUI(data.status,data.func)
end
function ClubTipsLayer:changeUI(status,func,func2)
    self.status=status
    self.func=func
    self.func2 = func2
    local root = self:getCsbNode():getChildByName("root")
    local btn_ok = root:getChildByName("btn_ok")
    local btn_no = root:getChildByName("btn_no")
    local txt_tips = root:getChildByName("sp_bg2"):getChildByName("txt_tips")
    local txt_title = root:getChildByName("txt_title")

    if status == self.MEMBERS_KICK_OUT then
        btn_no:setVisible(true)
        btn_no:setPositionX(500)
        btn_ok:setPositionX(830)
        txt_title:setString("Kick Out")
        txt_tips:setString("Are you sure you want to kick this\nplayer out from your club?")
    elseif status == self.MEMBERS_ROOM_FULL then
        txt_title:setString("Play Together")
        txt_tips:setString("Room is full.")
    elseif status == self.MEMBERS_UNLOCK then
        btn_no:setVisible(true)
        btn_no:setPositionX(500)
        btn_no:getChildByName("txt_name"):setString("Back")
        btn_ok:setPositionX(830)
        btn_ok:getChildByName("txt_name"):setString("Unlock 15 diamonds")
        txt_title:setString("Play Together")
        txt_tips:setString("Play more to reach 200 rank \n or 15 diamonds to unlock \n this game.")
    elseif status == self.MEMBERS_DEGRADE then
        btn_no:setVisible(true)
        btn_no:setPositionX(500)
        btn_ok:setPositionX(830)
        txt_title:setString("Degrade")
        txt_tips:setString("Are you sure you want to degrade this\nplayer ?")
    elseif status == self.REQUEST_DECLINE then
        btn_no:setVisible(true)
        btn_no:setPositionX(500)
        btn_ok:setPositionX(830)
        txt_title:setString("Decline")
        txt_tips:setString("Do you really want to decline this request?")
    elseif status == self.REQUEST_DONATEONLYONE then
        txt_title:setString("Donate")
        txt_tips:setString("Donate once a day")     
    elseif status == self.JOINLAYER_PENDING then
        txt_title:setString("Join Club")
        txt_tips:setString("applied")  
    elseif status == self.JOINLAYER_FULL then
        txt_title:setString("Join Club")
        txt_tips:setString("full")  
    elseif status == self.JOINLAYER_UNLEVEL then
        txt_title:setString("Join Club")
        txt_tips:setString("等级不足")  
    elseif status == self.ALREADY_JOINCLUB then
        txt_title:setString("Join Club")
        txt_tips:setString("已经加入联盟")
    elseif status == self.ALREADY_BACKCLUB then
        txt_title:setString("Join Club")
        txt_tips:setString("已经退出联盟")    
    elseif status == self.JOINLAYER_SEARCHNOCLUB then
        txt_title:setString("Search Club")
        txt_tips:setString("没有找到联盟")  
    elseif status == self.CREATECLUB_REPETITION then
        txt_title:setString("Create Club")
        txt_tips:setString("已存在的联盟名")
    elseif status == self.LEAVECLUB then
        btn_no:setVisible(true)
        btn_no:setPositionX(500)
        btn_ok:setPositionX(830)
        txt_title:setString("Leave Club")
        txt_tips:setString("确定退出联盟?")
    elseif status == self.NO_ENOUGHCOINS then
        txt_title:setString("Donate")
        txt_tips:setString("您没有足够的金币")
    elseif status == self.NO_ENOUGHDIAMOND then
        txt_title:setString("Gift")
        txt_tips:setString("您没有足够的钻石")  
    elseif status == self.INVITE_CLUB then 
        btn_no:setVisible(true)
        btn_no:setPositionX(500)
        btn_ok:setPositionX(830)
        txt_title:setString("Invite Club")
        txt_tips:setString("是否接受公会邀请")
    elseif status == self.INVITE_CLUB_SUCCEED then
        txt_title:setString("Invite Club")
        txt_tips:setString("邀请加入公会成功")  
    elseif status == self.INVITE_CLUB_DEFEATED then
        txt_title:setString("Invite Club")
        txt_tips:setString("该玩家已拥有公会")  
    end
end
function ClubTipsLayer:touchEvent(sender, eventType)
    local name = sender:getName()
    local tag = sender:getTag()
    print("touchEvent:" .. name)
    if eventType == ccui.TouchEventType.began then
        print("Touch Down")
        sender:setScale(1.05)
    elseif eventType == ccui.TouchEventType.moved then
        print("Touch Move")
    elseif eventType == ccui.TouchEventType.ended then
        print("Touch Up")
        sender:setScale(1)
        if name== "btn_ok" then
            if self.func then
                self.func()
            end
            self:closeUI()
        elseif name == "btn_no" then
            if self.func2 then
                self.func2()
            end
            self:closeUI()
        end
    elseif eventType == ccui.TouchEventType.canceled then
        print("Touch Cancelled")
        sender:setScale(1)
    end
end

return ClubTipsLayer
-- endregion
