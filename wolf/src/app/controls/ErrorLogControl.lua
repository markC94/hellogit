--region *.lua
--Date
--此文件由[BabeLua]插件自动生成
local ErrorLogControl = {}
function ErrorLogControl:create()
    if not self.handler then
        local function tick(dt)
            self:dealMsg()
        end
        self.handler = cc.Director:getInstance():getScheduler():scheduleScriptFunc(tick, 1, false)
    end
end

function ErrorLogControl:dealMsg()
    local errorLog = cc.AppInfo:getErrLog()
    if errorLog ~= "" then
        if Socket:isConnected() then
            self:sendMsg(errorLog)
            cc.AppInfo:clearErrLog()
        else
            if Socket:isEmptyDelegate() then
                Socket:connect()
            end
        end
    end
end

local function split(input, delimiter)
    local pos, arr = 0, {}
    for st,sp in function() return string.find(input, delimiter, pos, true) end do
        table.insert(arr, string.sub(input, pos, st - 1))
        pos = sp + 1
    end
    table.insert(arr, string.sub(input, pos))
    return arr
end

function ErrorLogControl:sendMsg(msg)
    release_print("ErrorLogControl:sendMsg")
    local allMsgs = split(msg, "*")
    local id
    if bole.getUserDataByKey then
        id = bole:getUserDataByKey("user_id")
    end
    if not id then
        id = "0"
    end
    for _, item in ipairs(allMsgs) do
        Socket:send("splunk_client", {info = string.format("id=%s %s", id, item)})
    end
end

return ErrorLogControl
--endregion
