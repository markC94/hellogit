-- region *.lua
-- Date
-- 此文件由[BabeLua]插件自动生成
local ClubInfoLayer = class("ClubInfoLayer", cc.load("mvc").ViewBase)
function ClubInfoLayer:onCreate()
    print("ClubInfoLayer-onCreate")
    local root = self:getCsbNode():getChildByName("root")
   
    local btn_close = root:getChildByName("btn_close")
    btn_close:addTouchEventListener(handler(self, self.touchEvent))

    local sp_info_bg = root:getChildByName("sp_info_bg")
    self.btn_jion = sp_info_bg:getChildByName("btn_jion")
    self.btn_jion:addTouchEventListener(handler(self, self.touchEvent))
    self.btn_jion:setTouchEnabled(false)

    self.scroll = root:getChildByName("scroll")
    self.slider = root:getChildByName("Slider")

end


function ClubInfoLayer:onEnter()
    bole.socket:registerCmd("apply_joining_club", self.apply_joining_club, self)
    bole.socket:registerCmd(bole.SERVER_GET_CLUB_INFO, self.oncmd, self)
    bole:addListener("initClubInfoId", self.initClubInfoId, self, nil, true)
end

function ClubInfoLayer:initClubInfoId(data)
    data = data.result
    bole.socket:send(bole.SERVER_GET_CLUB_INFO,{id=data})
end

function ClubInfoLayer:oncmd(t,data)
    bole:postEvent("ClubInfoLayer",data)
    self.btn_jion:setTouchEnabled(true)
    self.scroll :addEventListener(handler(self, self.scrollViewEvent))
end

function ClubInfoLayer:onExit()
    bole:removeListener("initClubInfoId", self)
    bole.socket:unregisterCmd("apply_joining_club")
end


function ClubInfoLayer:initList(data)
        --{160 326  470 326  160 116}
    dump(data,"ClubInfoLayer:initList")
    self.info=data
    local sp_info_bg = self:getCsbNode():getChildByName("root"):getChildByName("sp_info_bg")
    local iconPath = bole:getClubIconStr(data.icon)
    if iconPath~= nil then
        sp_info_bg:getChildByName("sp_icon"):loadTexture(iconPath)
    else
        sp_info_bg:getChildByName("sp_icon"):loadTexture(bole:getClubIconStr("10" ..(tonumber(data.icon) % 5 + 1)))
    end

    sp_info_bg:getChildByName("txt_name"):setString(data.name)

    if tonumber(data.qualification)  == 0 then
        sp_info_bg:getChildByName("txt_status"):setString("Anyone can join")
    elseif tonumber(data.qualification)  == 1 then
        sp_info_bg:getChildByName("txt_status"):setString("Invite only")
    end
   
   sp_info_bg:getChildByName("img_level"):getChildByName("txt_level"):setString(data.require_level)
   sp_info_bg:getChildByName("img_rank"):getChildByName("txt_name"):setString("Rank " .. data.league_rank)

   self.memberNum_ = # self.info.users
   self.showNum_ = math.min(8, self.memberNum_)
    for i = 1, self.showNum_ do
        local cell=bole:getEntity("app.views.club.ClubMemberCell",self.info.users[i],i)
        self.scroll:addChild(cell)
        if i % 2 == 0 then
            cell:setPosition(cc.p( math.ceil(i / 2) * 310 - 160, 120))
        elseif i % 2 == 1 then
            cell:setPosition(cc.p( math.ceil(i / 2) * 310 - 160, 320))
        end
    end
    self.scroll:setInnerContainerSize(cc.size( math.ceil(self.showNum_ / 2) * 310, 390))
    self.scroll:scrollToBottom(0,true)
    self.scrollViewScrollMaxLenght_ = self.scroll:getInnerContainerSize().width -  self.scroll:getContentSize().width

    self.btn_jion:setTouchEnabled(false)
end


function ClubInfoLayer:updateUI(data)
    self:initList(data.result)
end

function ClubInfoLayer:touchEvent(sender, eventType)
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
        if name == "btn_close" then
            self:closeUI()
        elseif name == "btn_jion" then
            self:jionClub()
        end
    elseif eventType == ccui.TouchEventType.canceled then
        print("Touch Cancelled")
        sender:setScale(1)
    end
end

function ClubInfoLayer:scrollViewEvent(sender, eventType)
    if eventType == 9 then
        local nowX = - self.scroll:getInnerContainerPosition().x 
        local posX = math.min( math.max(0 , nowX) , self.scrollViewScrollMaxLenght_)
        self.slider:setPercent(posX / self.scrollViewScrollMaxLenght_ * 100)
    end

    if eventType == 4 then
        local inner_pos = self.scroll:getInnerContainerPosition()
        local addMember = false
        if inner_pos.x + 150 < 1222 - math.ceil(self.showNum_ / 2) * 310 then
            for i = self.showNum_ + 1, math.min (self.memberNum_, self.showNum_ + 8) do
                addMember = true
                local cell=bole:getEntity("app.views.club.ClubMemberCell",self.info.users[i],i)
                self.scroll:addChild(cell)
                if i % 2 == 0 then
                    cell:setPosition(cc.p( math.ceil(i / 2) * 310 - 160, 120))
                elseif i % 2 == 1 then
                    cell:setPosition(cc.p( math.ceil(i / 2) * 310 - 160, 320))
                end
            end
            
            if addMember then
                self.showNum_ = math.min(self.memberNum_, self.showNum_ + 8)
                self.scroll:setInnerContainerSize(cc.size(math.ceil(self.showNum_ / 2) * 310, 436))
                self.scroll:setInnerContainerPosition(cc.p(inner_pos.x , 0))
                self.scrollViewScrollMaxLenght_ = self.scroll:getInnerContainerSize().width -  self.scroll:getContentSize().width
            end    
        end
    end
end

function ClubInfoLayer:jionClub()
    --self.info

    if tonumber(bole:getUserDataByKey("club")) ~= 0 then
        bole:getUIManage():openClubTipsView(10,nil)
        return
    end


    if  tonumber(self.info.current_u_count) == tonumber(self.info.max_u_count) then
        bole:getUIManage():openClubTipsView(8,nil)
        return
    end

    if tonumber(bole:getUserDataByKey("level")) < tonumber(self.info.require_level) then
        bole:getUIManage():openClubTipsView(9,nil)
        return
    end


    bole.socket:send("apply_joining_club", {id = tonumber(self.info.id) }, true)
end

function ClubInfoLayer:apply_joining_club(t, data)
   if t == "apply_joining_club" then
        --通过返回信息判断是否可以加入
        if data.error ~= nil then
            if data.error == 6 then
                bole:getUIManage():openClubTipsView(7,nil)
            end
        end
        --加入成功
        if data.success ~= nil then
            if data.success == 1 then
                bole:postEvent("applyJoiningClub", self.info.id) 
                self:closeUI()
            end
        end

        if data.id ~= nil then
            bole:postEvent("applyJoiningClubNow", data) 
            self:closeUI()
        end
   end
end


return ClubInfoLayer


-- endregion
