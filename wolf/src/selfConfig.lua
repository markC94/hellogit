--region *.lua
--Date
--此文件由[BabeLua]插件自动生成

function bole:getDeviceId()
    local imme = bole.getIMEI()
    if imme == "" then
        imme = "b12"
    end
    return imme
end 

function bole:getMacAddress()
    local macAddress = bole.getMacID()
    if macAddress == "" then
        macAddress = "787878787877899999"
    end
    return macAddress
end

--endregion
