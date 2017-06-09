--region *.lua
--Date
--此文件由[BabeLua]插件自动生成
local IAPControl = class("IAPControl")
function IAPControl:ctor(...)
    print("IAPControl:ctor")
    self.isInit = false

    self:clearData()
end

function IAPControl:init()
    print("IAPControl:init")
    if not self.isInit then
        sdkbox.IAP:init()
        self:setListeners()
        self.isInit = true
    end
end

function IAPControl:clearData()
    print("IAPControl:clearData")
end

function IAPControl:setDebug(flag)
    sdkbox.IAP:setDebug(flag)  --Enable/disable debug logging
end

function IAPControl:setListener()
    print("IAPControl:setListener")
    sdkbox.IAP:setListener(function(args)
        local eventName = args.event
        dump(args, "IAP:setListener=" .. eventName)
        if "onInitialized" == eventName then  --初始化成功
        elseif "onSuccess" == eventName then  --购买成功事件
        elseif "onFailure" == eventName then  --购买失败事件
        elseif "onCanceled" == eventName then  --用户取消购买,会触发这个事件
        elseif "onRestored" == eventName then  --恢复成功事件；注意: onRestored 可能被会多次触发
        elseif "onProductRequestSuccess" == eventName then  --最新的商品数据 获取成功会收到这个事件
        elseif "onProductRequestFailure" == eventName then  --获取失败收到这个事件
        elseif "onRestoreComplete" == eventName then  --Called when the restore completed
        end
    end)
end

function IAPControl:removeListener()
    print("IAPControl:removeListener")
    sdkbox.IAP:removeListener()
end

function IAPControl:requestProducts()
    print("IAPControl:requestProducts")
    sdkbox.IAP:refresh()  --最好在您的游戏开始前从服务器获取一次最新的商品数据。获取商品数据
end

function IAPControl:buy(item)
    --注意: name 是您工程的 IAP 配置文件中的 items 项下的名字,而不是您在 iTunes 或 GooglePlay Store中的商品名
    print("IAPControl:buy")
    sdkbox.IAP:purchase(name)
end

function IAPControl:restore()
    print("IAPControl:restore")
    sdkbox.IAP:restore()  --恢复购买调用
end

return IAPControl
--endregion
