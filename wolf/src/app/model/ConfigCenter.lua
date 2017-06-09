-- region *.lua
-- Date
-- 此文件由[BabeLua]插件自动生成

local ConfigCenter = class("ConfigCenter")

function ConfigCenter:ctor()
    self.data = {}
end

function ConfigCenter:getConfig(fileName, id, key)
    local content = self.data[fileName]
    if not content then
        local fileData = cc.FileUtils:getInstance():getStringFromFile(string.format("config/%s.json", fileName))
        if fileData == "" then
            return nil
        end
        content = json.decode(fileData)
        self.data[fileName] = content
    end

    if id then
        if type(id) == "number" then
            content = content[tostring(id)]
        else
            content = content[id]
        end
    end

    if key then
        content = content[key]
    end

    return content
end

function ConfigCenter:purgeByFileName(configName)
    if not self.data then
        return
    end

    self.data[configName] = nil
end

return ConfigCenter

-- endregion
