-- region *.lua
-- Date
-- 此文件由[BabeLua]插件自动生成
function bole:openPhoto(key)
    key = tostring(key)
    if device.platform ~= "android" then
        bole:updateHeadImage("error",-1)
        return
    end
    local function callback(path)
        bole:setUserDataByKey("icon","self")
        bole:updateHeadImage(path,6)
        bole:uploadUserInfo()
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
        bole:updateHeadImage("error",-1)
        return
    end
    local function callback(path)
        bole:setUserDataByKey("icon","self")
        bole:updateHeadImage(path,6)
        bole:uploadUserInfo()
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


function bole:upLoadRobot()
    for i=1,96 do
        performWithDelay(display.getRunningScene(),function()
            bole:saveCdnPng("robot_" .. i,"res/head_icon/101_"..i..".png")
        end,i)
    end
end
function bole:saveCdnPng(user_id,fileName)
    user_id=tostring(user_id)
    if device.platform ~= "android" then
        return
    end
    local luaj = require("cocos.cocos2d.luaj")
    local className = "org/cocos2dx/bole/ImagePicker"
    local ok, ret = luaj.callStaticMethod(className, "saveCdnPng",{user_id,fileName})
    if not ok then
        print("==== luaj error ====:", ret)
        return false
    else
        print("==== The JNI return is:", ret)
        return ret
    end    
end
function bole:saveCdnUrl(user_id,fileName)
    user_id=tostring(user_id)
    if device.platform ~= "android" then
        return
    end
    local luaj = require("cocos.cocos2d.luaj")
    local className = "org/cocos2dx/bole/ImagePicker"
    local ok, ret = luaj.callStaticMethod(className, "tryUpLoad",{user_id,fileName})
    if not ok then
        print("==== luaj error ====:", ret)
        return false
    else
        print("==== The JNI return is:", ret)
        return ret
    end    
end

function bole:tryImageCircle(file,callback)
    if device.platform ~= "android" then
        callback(file)
        return
    end

    local luaj = require("cocos.cocos2d.luaj")
    local className = "org/cocos2dx/bole/ImagePicker"
    local ok, ret = luaj.callStaticMethod(className, "getCirClePath", { file, callback })
    if not ok then
        print("==== luaj error ====:", ret)
        return false
    else
        print("==== The JNI return is:", ret)
        return ret
    end
end

function bole:updateHeadImage(path,code)
    performWithDelay(display.getRunningScene(),function()
        bole:postEvent("eventImgPath",{path,code})
    end,0.5)
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


function bole:toAdjustPrice(order,data)
    if device.platform ~= "android" then
        return
    end
    local luaj = require("cocos.cocos2d.luaj")
    local className = "org/cocos2dx/bole/BLAdjust"
    local ok, ret = luaj.callStaticMethod(className,"toAdjustPrice",{order,data})
    if not ok then
        print("==== luaj error ==== : ", ret)
        return false
    else
        print("==== The JNI return is:", ret)
        return ret
    end
end
function bole:toAdjustPlayer()
    if device.platform ~= "android" then
        return
    end
    local luaj = require("cocos.cocos2d.luaj")
    local className = "org/cocos2dx/bole/BLAdjust"
    local ok, ret = luaj.callStaticMethod(className,"toAdjustPlayer",{})
    if not ok then
        print("==== luaj error ==== : ", ret)
        return false
    else
        print("==== The JNI return is:", ret)
        return ret
    end
end

function bole:toAdjustNoCoins()
    if device.platform ~= "android" then
        return
    end
    local luaj = require("cocos.cocos2d.luaj")
    local className = "org/cocos2dx/bole/BLAdjust"
    local ok, ret = luaj.callStaticMethod(className,"toAdjustNoCoins",{})
    if not ok then
        print("==== luaj error ==== : ", ret)
        return false
    else
        print("==== The JNI return is:", ret)
        return ret
    end
end

function bole:toAdjustLevel()
    if device.platform ~= "android" then
        return
    end
    local luaj = require("cocos.cocos2d.luaj")
    local className = "org/cocos2dx/bole/BLAdjust"
    local ok, ret = luaj.callStaticMethod(className,"toAdjustPlayer",{})
    if not ok then
        print("==== luaj error ==== : ", ret)
        return false
    else
        print("==== The JNI return is:", ret)
        return ret
    end
end

function bole:tohelpshift()
    if device.platform ~= "android" then
        return
    end
    local user_id=tostring(bole:getUserDataByKey("user_id"))
    local level=tostring(bole:getUserDataByKey("level"))
    local vip_level=tostring(bole:getUserDataByKey("vip_level"))
    local version=tostring(cc.AppInfo:getValue("version"))
    if not version or version=="" then
        version="10"
    end

    local luaj = require("cocos.cocos2d.luaj")
    local className = "org/cocos2dx/bole/BLHelpshift"
    local ok, ret = luaj.callStaticMethod(className,"toHelp",{user_id,level,vip_level,version})
    if not ok then
        print("==== luaj error ==== : ", ret)
        return false
    else
        print("==== The JNI return is:", ret)
        return ret
    end
end

function bole:openAndroidUtil(id)
    if device.platform ~= "android" then
        return
    end
    local luaj = require("cocos.cocos2d.luaj")
    local className = "org/cocos2dx/bole/BLUtil"
    local ok, ret = luaj.callStaticMethod(className,"openAndroidUtil",{id})
    if not ok then
        print("==== luaj error ==== : ", ret)
        return false
    else
        print("==== The JNI return is:", ret)
        return ret
    end
end

function bole:openGooglePlay()
    if device.platform ~= "android" then
        return
    end
    local luaj = require("cocos.cocos2d.luaj")
    local className = "org/cocos2dx/bole/HavingFun"
    local ok, ret = luaj.callStaticMethod(className,"openGooglePlay",{})
    if not ok then
        print("==== luaj error ==== : ", ret)
        return false
    else
        print("==== The JNI return is:", ret)
        return ret
    end
end



-- endregion
