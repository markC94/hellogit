--region *.lua
--Date
--此文件由[BabeLua]插件自动生成

local ClubControl = class("ClubControl")
function ClubControl:ctor()
    -- body
    self:init()
    print("ClubControl-ctor")
end
function ClubControl:init()
    bole.socket:registerCmd(bole.SERVER_GET_CLUB_INFO, self.oncmd, self)
    self:initListener()
end 

function ClubControl:initListener()
    
end

function ClubControl:oncmd(t, data)
    -- body
    if t == bole.SERVER_GET_CLUB_INFO then
       bole:getUIManage():openUI("ClubInfoLayer",true,"club")
       dump(data,"ClubInfoLayer ui")
       bole:postEvent("ClubInfoLayer",data)
    end
end 

function ClubControl:showClubInfo(clubid)
    print("clubid:"..clubid)

    bole.socket:send(bole.SERVER_GET_CLUB_INFO,{id=clubid})
end
return ClubControl
--endregion
