-- region *.lua
-- Date
-- 此文件由[BabeLua]插件自动生成
local SpinEventCenter = class("SpinEventCenter")

function SpinEventCenter:ctor()
    self.commands = { }
    local function update(dt)
        self:removeDeadEvent()
    end
    self.scheduler = cc.Director:getInstance():getScheduler():scheduleScriptFunc(update, 1, false)
end

-- @notRemoveAfterExec  执行完之后是否删除这个listener, 缺省 默认 删除
function SpinEventCenter:registerEvent(eventName, func, target, args, notRemoveAfterExec)
    local event = { }
    event.func = func
    event.target = target
    event.args = args
    event.isRemoveAfterExec = not notRemoveAfterExec

    local info = self.commands[eventName]
    if not info then
        info = { }
        self.commands[eventName] = info
    end
    table.insert(info, event)
end

function SpinEventCenter:removeEventByName(eventName)
    self.commands[eventName] = { }
end

function SpinEventCenter:removeEventWithTarget(eventName, target)
    local info = self.commands[eventName]
    if info and #info > 0 then
        for i = #info, 1, -1 do
            if info[i].target == target then
                table.remove(info, i)
            end
        end
    end
end

function SpinEventCenter:removeEventWithFunc(eventName, func)
    local info = self.commands[eventName]
    if info and #info > 0 then
        for i = #info, 1, -1 do
            if info[i].func == func then
                table.remove(info, i)
            end
        end
    end
end

function SpinEventCenter:postEvent(eventName, args)
    local events = self.commands[eventName]
    if events and #events > 0 then
        for k = #events, 1, -1 do
            local event = events[k]
            event.result = args
            if not event.isDead then
                if event.target then
                    event.func(event.target, event)
                else
                    event.func(event)
                end
                event.result = nil

                if event.isRemoveAfterExec then
                    event.isDead = true
                    self.isNeedToRemove = true
                end
            end
        end
    end
end

function SpinEventCenter:removeDeadEvent()
    for _, events in pairs(self.commands) do
        for k = #events, 1, -1 do
            if events[k].isNeedToRemove then
                table.remove(events, k)
            end
        end
    end
end

function SpinEventCenter:purge()
    if self.scheduler then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.scheduler)
    end

    self.scheduler = nil
end

return SpinEventCenter
-- endregion
