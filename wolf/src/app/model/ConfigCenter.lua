-- region *.lua
-- Date
-- 此文件由[BabeLua]插件自动生成

local ConfigCenter = class("ConfigCenter")
local CLIP_LEVEL = "level"
local CLIP_LEVEL_COUNT = 40
function ConfigCenter:ctor()
    self.data = { }
end

function ConfigCenter:getConfig(fileName, id, key)
    local content = self.data[fileName]
    if fileName == CLIP_LEVEL then
        if content then
            -- 特殊处理 level表是否需要更新
            local curlevel = tonumber(bole:getUserDataByKey("level"))
            local nextData = content["" ..(curlevel + 1)]
            --判断下一个等级是否加载
            if not nextData then
                content=nil
            end
        end
    end
    if not content then
        if fileName == CLIP_LEVEL then
            -- 特殊处理 level表
            content =self:getLevelContent()
        else
            --其他表读取
            local fileData = cc.FileUtils:getInstance():getStringFromFile(fileName .. ".json")
            if fileData == "" then
                return nil
            end
            content = json.decode(fileData)
        end
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

function ConfigCenter:getLevelContent()
    local curlevel = tonumber(bole:getUserDataByKey("level"))
    local index = math.ceil(curlevel / 40)
    local newName = "level_" .. index
    local fileData = cc.FileUtils:getInstance():getStringFromFile(string.format("levels/%s.json", newName))
    if fileData == "" then
        return nil
    end
    local content = json.decode(fileData)
    -- 边界值判断
    if curlevel ~= 1 then
        local tempName = nil
        if curlevel % 40 == 0 then
            -- 边界添加下一个表
            tempName = "level_" ..(index + 1)
        elseif (curlevel - 1) % 40 == 0 then
            -- 边界添加上一个表
            tempName = "level_" ..(index - 1)
        end
        if tempName then
            -- 边界值另一张表读取
            local tempData = cc.FileUtils:getInstance():getStringFromFile(string.format("levels/%s.json", tempName))
            if tempData ~= "" then
                local temp_content = json.decode(tempData)
                for k, v in pairs(temp_content) do
                    content[k] = v
                end
            end
        end
    end
--    dump(content,"content",1)
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
