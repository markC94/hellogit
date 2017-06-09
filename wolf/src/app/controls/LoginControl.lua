-- region *.lua
-- Date
-- 此文件由[BabeLua]插件自动生成
local LoginControl = class("LoginControl")
function LoginControl:ctor()
    print("LoginControl:init")
    bole.socket:registerCmd(bole.SERVER_LOGIN, self.oncmd, self)
end

function LoginControl:openLoginView()
    bole:getUIManage():openUI(bole.UI_NAME.LoginScene)
end

function LoginControl:oncmd(t, data)
    -- body
    if t == bole.SERVER_LOGIN then
        local userDefault = cc.UserDefault:getInstance()
        local credential = data.credential or ""
        userDefault:setStringForKey("credential", credential)
        userDefault:flush()
        bole:getUserData():setData(data)
        bole:setUserDataByKey("loginTime", os.time())   --临时记一下时间
        --dump(data, "userData-1")
        bole.recommend_users=data.recommend_users
        bole.recommend_index=1
        bole.recommend_max=#data.recommend_users
        print("data.recommend_users="..#data.recommend_users)
        bole:postEvent(bole.UI_NAME.LoginScene, { "gotoView" })

        bole:getFacebookCenter():onGameLoginSuccess()
    end
end
function LoginControl:login(extraData)
    if bole.socket:isConnected() then
        local data = { }
        -- 	extraData = extraData or {}
        -- 	for k,v in pairs(extraData) do
        -- 		data[k] = v
        -- 	end
        local userDefault = cc.UserDefault:getInstance()
        local credential = userDefault:getStringForKey("credential", "")
        if (credential == "") then
            data.macaddr = bole:getMacAddress()
            data.duid = bole:getDeviceId()
            data.package = "com.bole.wolf.slots"
            data.referrer = '';
            data.version = '1.0.0'
            data.relogin_with_local_user = 1
            dump(data, "frist")
        else
            data.package = 'com.bole.wolf.slots'
            data.credential = credential;
            data.version = '1.0.0'
            dump(data, "auto")
        end
        bole.socket:send(bole.SERVER_LOGIN, data)
    end
end


return LoginControl
-- endregion
