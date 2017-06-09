-- region *.lua
-- Date
-- 此文件由[BabeLua]插件自动生成
function bole:openPhoto(key)
    key = tostring(key)
    if device.platform ~= "android" then
        bole:saveImgPath("error")
        return
    end
    local function callback(path)
        bole:saveImgPath(path)
    end
    
    local luaj = require("cocos.cocos2d.luaj")

    local className = "org/cocos2dx/bole/ImagePicker"
    local ok, ret = luaj.callStaticMethod(className, "openPhoto", { key, callback })
    if not ok then
        print("==== luaj error ==== : ", ret)
        return false
    else
        print("==== The JNI return is:", ret)
        return ret
    end
end
function bole:openCamera(key)
    key = tostring(key)
    if device.platform ~= "android" then
        bole:saveImgPath("error")
        return
    end
    local function callback(path)
        bole:saveImgPath(path)
    end
    local luaj = require("cocos.cocos2d.luaj")
    local className = "org/cocos2dx/bole/ImagePicker"
    local ok, ret = luaj.callStaticMethod(className, "openCamera", { key, callback })
    if not ok then
        print("==== luaj error ====:", ret)
        return false
    else
        print("==== The JNI return is:", ret)
        return ret
    end
end
function bole:saveCdnUrl(fileName,user_id)
    if device.platform ~= "android" then
        callback("error")
        return
    end
    user_id=tostring(user_id)
    local luaj = require("cocos.cocos2d.luaj")
    local className = "org/cocos2dx/bole/ImagePicker"
    local ok, ret = luaj.callStaticMethod(className, "tryUpLoad",user_id,fileName)
    if not ok then
        print("==== luaj error ====:", ret)
        return false
    else
        print("==== The JNI return is:", ret)
        return ret
    end    
end
function bole:getCdnUrl(key,callback)
    key = tostring(key)
    if device.platform ~= "android" then
        callback("error")
        return
    end
--    local function callback(path)
--        bole:saveImgPath(path)
--    end
    local luaj = require("cocos.cocos2d.luaj")
    local className = "org/cocos2dx/bole/ImagePicker"
    local ok, ret = luaj.callStaticMethod(className, "getImageUrl", { key, callback })
    if not ok then
        print("==== luaj error ====:", ret)
        return false
    else
        print("==== The JNI return is:", ret)
        return ret
    end
end

function bole:saveImgPath(path)
    print(path)
    bole:postEvent("eventImgPath",path)
end

function bole:showADVideo(func)
    if device.platform ~= "android" then
        if func then
            func()
        end
        return
    end
    local function callback(num)
        if func then
            func(num)
        end
    end
    
    local luaj = require("cocos.cocos2d.luaj")

    local className = "org/cocos2dx/bole/BoleAdView"
    local ok, ret = luaj.callStaticMethod(className, "showAds", { 3, callback })
    if not ok then
        print("==== luaj error ==== : ", ret)
        return false
    else
        print("==== The JNI return is:", ret)
        return ret
    end
end
-- endregion
