-- region *.lua
-- Date
-- 此文件由[BabeLua]插件自动生成
local UserData = class("UserData")

local allNumberKeys = { "coins", "defaut_bet", "experience", "diamond" }
local checkNumberKeys
function UserData:ctor()
    --    self.coins = 0
    --    self.credential = 0
    --    self.defaut_bet = 0
    --    self.experience = 0
    --    self.level = 0
    --    self.login_count = 0
    --    self.register_time = 0
    --    self.store_video_left_times = 0
    --    self.user_id = 0
    --    self.video_left_times = 0
    --    self.vip_level = 0
    --    self.vip_points = 0
    checkNumberKeys = table.set(allNumberKeys)
    bole.socket:registerCmd("sync_user_info", self.updateUserInfo, self)
end

function UserData:setData(data)
    for k, v in pairs(data) do
--        if type(v)~= "table" then
--            self:setDataByKey(k, v)
--        end
        if k ~= "recommend_users" then
            self:setDataByKey(k, v)
        end
    end
    --dump(data,"setData")
end

function UserData:changeDataByKey(key, changedValue, noUpdate)
    if not changedValue then return false end

    local flag = false
    if checkNumberKeys[key] then
        changedValue = tonumber(changedValue)
        flag = true
    end

    local resultValue
    if flag or type(changedValue) == "number" then
        if not self[key] then
            self[key] = 0
        end

        resultValue = self[key] + changedValue
        if resultValue < 0 then
            return false
        end
    else
        resultValue = changedValue
        changedValue = nil
    end

    self[key] = resultValue

    if noUpdate then
        return true
    end

    bole:postEvent(key .. "Changed", { result = resultValue, changed = changedValue })
    return true
end

function UserData:setDataByKey(key, value, noUpdate)
    if not value then return end

    local flag = false
    if checkNumberKeys[key] then
        value = tonumber(value)
        flag = true
    end

    local changedValue
    if flag or type(value) == "number" then
        local lastValue = self[key]
        if not lastValue then
            changedValue = value
        else
            changedValue = value - lastValue
        end
    else
        changedValue = value
    end

    self:changeDataByKey(key, changedValue, noUpdate)
end

function UserData:getDataByKey(key)
    return self[key] or 0
end

function UserData:updateUserInfo(t,data)
    if t == "sync_user_info" then
        for k , v in pairs(data) do
            self:setDataByKey(k, v, true)
        end
    end
end

function UserData:updateSceneInfo(key)
    bole:postEvent(key .. "Changed", { result = self[key] })
end



return UserData
-- endregion
