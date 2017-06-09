-- region *.lua
-- Date
-- 此文件由[BabeLua]插件自动生成
--oz
bole.MINIGAME_ID_FAIRY = 10101
bole.MINIGAME_ID_WITCH = 10102
bole.MINIGAME_ID_MAGICIAN = 10103
bole.MINIGAME_ID_EMERALD = 10104
--farm
bole.MINIGAME_ID_HAMSTER = 10101
--flower
bole.MINIGAME_ID_FLOWER = 10101
bole.MINIGAME_ID_FLOWER_FREESPIN = 10102

--
bole.MINIGAME_ID_MERMAID = 10101
--gorill
bole.MINIGAME_ID_GORILLALAYER_FREESPIN = 10101
bole.MINIGAME_ID_GORILLALAYER_COLLECT = 10103
--minigame_id
bole.MINIGAME_ID_SEA_FREESPIN = 10101
function bole:getMngName(theme_id, feature_id)

    if theme_id == 1 then
        if feature_id == bole.MINIGAME_ID_FAIRY then
            return bole.UI_NAME.FairyGameLayer
        elseif feature_id == bole.MINIGAME_ID_WITCH then
            return bole.UI_NAME.WitchGameLayer
        elseif feature_id == bole.MINIGAME_ID_EMERALD then
            return bole.UI_NAME.EmeraldGameLayer
        end
    elseif theme_id == 2 then
        if feature_id == bole.MINIGAME_ID_HAMSTER then
            return bole.UI_NAME.HamsterGameLayer
        end
    elseif theme_id == 3 then
        if feature_id == bole.MINIGAME_ID_FLOWER then
            return bole.UI_NAME.FlowerGameLayer
        end
    elseif theme_id == 4 then
        if feature_id == bole.MINIGAME_ID_MERMAID then
            return bole.UI_NAME.MermaidLayer
        end
     elseif theme_id == 6 then
        if feature_id == bole.MINIGAME_ID_GORILLALAYER_COLLECT then
            return bole.UI_NAME.GorillaLayer
        end
    end

end


local function _info(msg)
    print("-------------------memory_test:"..msg)
end
local findedObjMap = nil   
local function findObject(obj, findDest)  
    if findDest == nil then  
        return false  
    end  
    if findedObjMap[findDest] ~= nil then  
        return false  
    end  
    findedObjMap[findDest] = true  
  
    local destType = type(findDest)  
    if destType == "table" then  
        if findDest == cc.exports.CMemoryDebug then  
            return false  
        end  
        for key, value in pairs(findDest) do  
            if key == obj or value == obj then  
                _info("Finded Object")  
                return true  
            end  
            if findObject(obj, key) == true then  
                _info("table key")  
                return true  
            end  
            if findObject(obj, value) == true then  
                _info("key:["..tostring(key).."]")  
                return true  
            end  
        end  
    elseif destType == "function" then  
        local uvIndex = 1  
        while true do  
            local name, value = debug.getupvalue(findDest, uvIndex)  
            if name == nil then  
                break  
            end  
            if findObject(obj, value) == true then  
                _info("upvalue name:["..tostring(name).."]")  
                return true  
            end  
            uvIndex = uvIndex + 1  
        end  
    end  
    return false  
end  
  
function bole.findObjectInGlobal(obj)  
    findedObjMap = {}  
    setmetatable(findedObjMap, {__mode = "k"}) 
    findObject(obj, bole)  
end 



-- endregion
