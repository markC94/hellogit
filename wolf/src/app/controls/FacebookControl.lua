--region *.lua
--Date
--此文件由[BabeLua]插件自动生成
--sdkbox.PluginFacebook:setAppId("416175998751020")

local FacebookControl = class("FacebookControl")
function FacebookControl:ctor(...)
    print("FacebookControl:ctor")
    self.isInit = false

    self:clearData()

    bole.socket:registerCmd("facebook_connect", self.onFacebookConnect, self)
end

function FacebookControl:clearData()
    print("FacebookControl:clearData")
    self.fbId = nil
    self.fbPictureUrl = nil
    self.fbName = nil

    self.loginForSendFriends = false
    self.startBindFacebook = false
    self.isInvitableFriends = false
    self.updateFacebookUrl = false

    self.fbFriendInApp = nil
    self.invitableFriends = nil
    self.invitableFriendsCallback = nil
end

function FacebookControl:init()
    print("FacebookControl:init")
    if not self.isInit then
        sdkbox.PluginFacebook:init()
        self:setListeners()
        self.isInit = true
    end
end

function FacebookControl:setListeners()
    print("FacebookControl:setListeners")
    sdkbox.PluginFacebook:setListener(function(args)
        local name = args.name
        local jsonData = args.data
        dump(args, "FacebookControl:setListeners,name =" .. name)

        if "onLogin" == name then
            local flag = args.isLoggedIn and "success" == jsonData
            if self.loginForSendFriends then
                if flag then
                    self:featchFriendsInApp()
                end
                self.loginForSendFriends = false
            elseif self.isInvitableFriends then
                self.isInvitableFriends = false
                sdkbox.PluginFacebook:requestInvitableFriends()
            end

            if not flag then
                self:clearData()
            end
        elseif "onGetUserInfo" == name then
            local flag = false
            if jsonData and jsonData.id then
                local data = jsonData
                self.fbId = data.id
                self.fbName = data.name
                self.fbPictureUrl = data.picture_url

                flag = true
            end

            if self.startBindFacebook then
                self.startBindFacebook = false
                if flag then
                    self:bindToServer()
                else
                    if self.updateFacebookUrl then
                        self.updateFacebookUrl = false
                    end
                end
            end

--            if not flag and self.updateFacebookUrl then
--                self.updateFacebookUrl = false
--                if flag then
--                    self:updateHeadImage(self.fbPictureUrl)
--                end
--            end
        elseif "onFetchFriends" == name then
            if args.ok and jsonData then
                jsonData = string.gsub(jsonData, "\\", "")
                local data = json.decode(jsonData)
                local fbFriendInApp = {}
                local friendIds = {}
                for _, item in ipairs(data) do
                    local friendData = {}
                    friendData.id = item.id
                    friendData.name = item.name
                    friendData.pictureUrl = item.picture.data.url
                    table.insert(fbFriendInApp, friendData)
                    table.insert(friendIds, friendData.id)
                end
                self.fbFriendInApp = fbFriendInApp
                self:sendConfirmToServer(friendIds)
            end
        elseif "onRequestInvitableFriends" == name then
            local users = args.users
            if users and #users > 0 then
                local allInfo = {}
                for _, info in ipairs(users) do
                    local item = {}
                    item.id = info.id
                    item.name = info.name
                    item.pictureUrl = info.picture_url
                    table.insert(allInfo, item)
                end
                self.invitableFriends = allInfo
                if self.invitableFriendsCallback then
                    self.invitableFriendsCallback(allInfo)
                    self.invitableFriendsCallback = nil
                end
            end
        elseif "onInviteFriendsWithInviteIdsResult" == name then
            if args.ok then  --邀请朋友成功
            end
        elseif "onSharedSuccess" == name then  --分享成功
        elseif "onSharedFailed" == name then  --分享失败
        elseif "onSharedCancel" == name then  --分享取消
--        elseif "onPermission" == name then
--            if "success" == data and args.ok then
--            end
        end
    end)
end

function FacebookControl:login()
    print("FacebookControl:login")
    self:init()
    if not sdkbox.PluginFacebook:isLoggedIn() then
        print("sdkbox.PluginFacebook:login")
        sdkbox.PluginFacebook:login({"public_profile", "email", "user_friends"})
    end
end

function FacebookControl:isLogin()
    print("FacebookControl:isLogin")
    if device.platform == "android" or device.platform == "ios" then
        return sdkbox.PluginFacebook:isLoggedIn()
    end

    return false
end

function FacebookControl:sendConfirmToServer(friendIds)
    dump(friendIds, "FacebookControl:sendConfirmToServer friendIds =" .. self.fbId)
    bole.socket:send("confirm_fb_after_login", {fb_id = self.fbId, fb_friends_id = friendIds})
end

function FacebookControl:featchFriendsInApp()
    local facebookId = self:getCacheFacebookId()
    print("FacebookControl:featchFriendsInApp facebookId=" .. facebookId)
    if "" ~= facebookId then
        sdkbox.PluginFacebook:fetchFriends()
    end
end

function FacebookControl:bindToServer()
    print("FacebookControl:bindToServer")
    local facebookId = self:getCacheFacebookId() 
    if facebookId ~= self.fbId then
        bole.socket:send("facebook_connect", {facebook_id = self.fbId, facebook_name = self.fbName})
    else
        if self.updateFacebookUrl then
            self.updateFacebookUrl = false
            self:updateHeadImage(self.fbPictureUrl)
        end
    end
end

function FacebookControl:setDataFromCache()
    self.fbId, self.fbName, self.fbPictureUrl = self:getCacheFacebookInfo()
    if self.updateFacebookUrl then
        self:updateHeadImage(self.fbPictureUrl)
        self.updateFacebookUrl = false
    end
end

function FacebookControl:onFacebookConnect(t, data)
    print("FacebookControl:onFacebookConnect")
    if data["error"] then
        print("server error。。。。FacebookControl:onFacebookConnect")
        if self.updateFacebookUrl then
            self.updateFacebookUrl = false
            self:updateHeadImage(self.fbPictureUrl)
        end
        return
    end
    if 1 == data.same_facebook_id or 1 == data.bind_fb then  --绑定成功，存储一下facebookId
        self:cacheUserId()
    elseif 1 == data.need_re_login and data.credential then  --切换账号，用户切换了一个新的facebook账号
        self:cacheUserId(data.credential)  --存储新的账号信息（userId, facebookId）
        self:relogin()  --断开重新连接登录游戏
    elseif 1 == data.need_confirm and data.credential then   --自己没有绑定过账号，却切换了一个新的facebook账号
        --需要用户确认，如果确定，就废弃以前的账号，采用新账号，存储新账号并重新登录；如果用户取消，则需要登出facebook sdk的账号。
        self:needConfirm(data.credential)
    end
end

function FacebookControl:getCacheFacebookId()
    local facebookId = cc.UserDefault:getInstance():getStringForKey("facebookId", "")
    print("FacebookControl:getCacheFacebookId facebookId=" .. facebookId)
    return facebookId
end

function FacebookControl:getFacebookUserId()
    local userId = sdkbox.PluginFacebook:getUserID()
    print("FacebookControl:getFacebookUserId userId=" .. userId or "nil")
    return userId
end

function FacebookControl:getCacheFacebookInfo()
    local userDefault = cc.UserDefault:getInstance()
    local facebookId = userDefault:getStringForKey("facebookId", "")
    local facebookName = userDefault:getStringForKey("facebookName", "")
    local pictureUrl = userDefault:getStringForKey("facebookPictureUrl", "")
    return facebookId, facebookName, pictureUrl
end

function FacebookControl:removeCacheFacebookId()
    print("FacebookControl:removeCacheFacebookId")
    local userDefault = cc.UserDefault:getInstance()
    userDefault:deleteValueForKey("facebookId")
    userDefault:deleteValueForKey("facebookName")
    userDefault:deleteValueForKey("facebookPictureUrl")
    userDefault:flush()
end

function FacebookControl:cacheUserId(new_credential)
    print("FacebookControl:cacheUserId")
    local userDefault = cc.UserDefault:getInstance()
    userDefault:setStringForKey("facebookId", self.fbId)

    if self.fbName then
        userDefault:setStringForKey("facebookName", self.fbName)
    end

    if self.fbPictureUrl then
        userDefault:setStringForKey("facebookPictureUrl", self.fbPictureUrl)
        bole:postEvent("facebookHeadImageUrl", self.fbPictureUrl)
    end

    if new_credential then
        userDefault:setStringForKey("credential", new_credential)
    end

    userDefault:flush()
end

function FacebookControl:logout()
    print("FacebookControl:logout")
    self:clearData()
    sdkbox.PluginFacebook:logout()
    
    self:removeCacheFacebookId()
end

function FacebookControl:needConfirm(new_credential)
    print("FacebookControl:needConfirm")
    bole:popMsg({msg = "切换账号将会丢弃现有的账号，确定要切换吗？", title = "注意", cancle = true},
    function()
        self:cacheUserId(new_credential)
        self:relogin()
    end,
    function()
        self:logout()
    end)
end

function FacebookControl:relogin()
    print("FacebookControl:relogin")
    self:clearData()
    bole.socket:close()
end

function FacebookControl:purge()
    bole:removeListener("loginSuccess", self)
end

function FacebookControl:bindFacebook()
    print("FacebookControl:bindFacebook")
    if device.platform ~= "android" and device.platform ~= "ios" then return end
    if self.startBindFacebook then return end

    if self.fbId then return end
    self:init()
    if sdkbox.PluginFacebook:isLoggedIn() then
        local facebookId = self:getCacheFacebookId()
        if facebookId ~= "" and facebookId == self:getFacebookUserId() then
            self:setDataFromCache()
            return
        else
            self:logout()
        end
    end

    self.startBindFacebook = true
    self:login()
end

function FacebookControl:updateHeadImage(fbPictureUrl)
    bole:postEvent("facebookHeadImageUrl", fbPictureUrl)
end

function FacebookControl:getFacebookHeadImage()
    print("FacebookControl:getFacebookHeadImage")
    if device.platform ~= "android" and device.platform ~= "ios" then return end
    if self.updateFacebookUrl then return end

    if self.fbPictureUrl then
        self:updateHeadImage(self.fbPictureUrl)
    else
        self.updateFacebookUrl = true
        self:bindFacebook()
    end
end

function FacebookControl:onGameLoginSuccess(event)
    print("FacebookControl:onGameLoginSuccess")
    if device.platform ~= "android" and device.platform ~= "ios" then return end
    if self.loginForSendFriends then return end

    local facebookId = self:getCacheFacebookId()
    if facebookId ~= "" then
        self:init()

        if sdkbox.PluginFacebook:isLoggedIn() then
            if facebookId == self:getFacebookUserId() then
                self:setDataFromCache()
                self:featchFriendsInApp()
                return
            else
                self:logout()
            end
        end

        self.loginForSendFriends = true
        self:login()
    end
end

function FacebookControl:getInvitableFriends(callback)
    if device.platform ~= "android" and device.platform ~= "ios" then return end
    if self.isInvitableFriends then return end

    self.invitableFriendsCallback = nil

    if self.invitableFriends then
        if callback then
            callback(self.invitableFriends)
        end
        return
    end

    if self.fbId then
        self:init()
        self.invitableFriendsCallback = callback
        if sdkbox.PluginFacebook:isLoggedIn() then
            sdkbox.PluginFacebook:requestInvitableFriends()
        else
            self.isInvitableFriends = true
            self:login()
        end
    else
        if callback then
            callback()
        end
        return
    end
end

function FacebookControl:inviteOneFriend(friendIds)
    if device.platform ~= "android" and device.platform ~= "ios" then return end

    sdkbox.PluginFacebook:inviteFriendsWithInviteIds(friendIds, "新的老虎机", "快来跟我一起玩吧，我们可以加入一个房间，并肩作战。")
end

function FacebookControl:share()
    if device.platform ~= "android" and device.platform ~= "ios" then return end

    --    显示一个分享对话框
--    local info
--    info.type  = "link"
--    info.link  = "http://www.cocos2d-x.org"
--    info.title = "cocos2d-x"
--    info.text  = "Best Game Engine"
--    info.image = "http://cocos2d-x.org/images/logo.png"
--    sdkbox.PluginFacebook:dialog(info)

--    分享一个带文字注解的图片
--    local info
--    info.type  = "photo"
--    info.title = "My Photo"
--    info.image = __path to image__
--    sdkbox.PluginFacebook:dialog(info)
end

return FacebookControl
--endregion
