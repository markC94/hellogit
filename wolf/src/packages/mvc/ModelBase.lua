-- region *.lua
-- Date
-- 此文件由[BabeLua]插件自动生成

local ModelBase = class("ModelBase")

function ModelBase:ctor()
end

function ModelBase:getConfig(tableName, id)
    local configData = cc.load("mvc").ConfigCenter:getIntance()
    return configData:getConfig(tableName, id)
end

return ModelBase
-- endregion
