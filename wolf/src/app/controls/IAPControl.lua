--region *.lua
--Date
--此文件由[BabeLua]插件自动生成
local IAPControl = class("IAPControl")
function IAPControl:ctor(...)
    print("IAPControl:ctor")
    self.isInit = false
    self:init()
end

function IAPControl:init()
    print("IAPControl:init")
    if not self.isInit then
--        self:setDebug(true)
        self:setListeners()
        self:initContent()
        self.isInit = true
    end
end

function IAPControl:initContent()
    print("IAPControl:initContent filepath=" .. cc.FileUtils:getInstance():fullPathForFilename("sdkbox_config.json"))
    local fileContent = cc.FileUtils:getInstance():getStringFromFile("sdkbox_config.json")
    sdkbox.IAP:init(fileContent)
end

function IAPControl:setDebug(flag)
    sdkbox.IAP:setDebug(flag)  --Enable/disable debug logging
end

function IAPControl:setListeners()
    print("IAPControl:setListener")
    sdkbox.IAP:setListener(function(args)
        local eventName = args.event
        dump(args, "IAP:setListener=" .. eventName)
        if "onInitialized" == eventName then  --初始化成功
            if args.ok then
                self.initOk = true
            end
        elseif "onProductRequestSuccess" == eventName then  --最新的商品数据 获取成功会收到这个事件
            self.initOk = true
        elseif "onSuccess" == eventName then  --购买成功事件
            bole:postEvent("platformPayBackSuccess", args.product)
        elseif "onFailure" == eventName then  --购买失败事件
            bole:popMsg({msg = "Your purchase failed." , title = "Failure" , cancle = false})
        elseif "onCanceled" == eventName then  --用户取消购买,会触发这个事件
            bole:popMsg({msg = "Your purchase failed." , title = "Failure" , cancle = false})
        elseif "onRestored" == eventName then  --恢复成功事件；注意: onRestored 可能被会多次触发
        elseif "onProductRequestFailure" == eventName then  --获取失败收到这个事件
        elseif "onRestoreComplete" == eventName then  --Called when the restore completed
        end
    end)
end

function IAPControl:removeListener()
    print("IAPControl:removeListener")
    sdkbox.IAP:removeListener()
end

function IAPControl:requestProducts(event)
    print("IAPControl:requestProducts")
    sdkbox.IAP:refresh()  --最好在您的游戏开始前从服务器获取一次最新的商品数据。获取商品数据
end

function IAPControl:buy(name)
    --注意: name 是您工程的 IAP 配置文件中的 items 项下的名字,而不是您在 iTunes 或 GooglePlay Store中的商品名
    print("IAPControl:buy")
    
    if not self.initOk then
        self:initContent()
    end
    sdkbox.IAP:purchase(name)
end

function IAPControl:restore()
    print("IAPControl:restore")
    sdkbox.IAP:restore()  --恢复购买调用
end

return IAPControl

--onProductRequestSuccess" = {
--	"event"    = "onProductRequestSuccess"
--	"products" = {
--		1 = {
--			"currencyCode"           = "HKD"
--			"description"            = "a1"
--			"id"                     = "slots.swf.vegas.casino.games.free.099"
--			"name"                   = "a1"
--			"price"                  = "HK$8.00"
--			"priceValue"             = 8
--			"receipt"                = ""
--			"receiptCipheredPayload" = ""
--			"title"                  = "a1 (Slots With Friends - Vegas Casino Slot Machines)"
--			"transactionID"          = ""
--			"type"                   = "CONSUMABLE"
--		},
--		2 = {
--			"currencyCode"           = "HKD"
--			"description"            = "a2"
--			"id"                     = "slots.swf.vegas.casino.games.free.199"
--			"name"                   = "a2"
--			"price"                  = "HK$15.00"
--			"priceValue"             = 15
--			"receipt"                = ""
--			"receiptCipheredPayload" = ""
--			"title"                  = "a2 (Slots With Friends - Vegas Casino Slot Machines)"
--			"transactionID"          = ""
--			"type"                   = "CONSUMABLE"
--		}
--	}
--}

--onSuccess" = {
--	"event"   = "onSuccess"
--	"product" = {
--		"currencyCode"           = "HKD"
--		"description"            = "a1"
--		"id"                     = "slots.swf.vegas.casino.games.free.099"
--		"name"                   = "a1"
--		"price"                  = "HK$8.00"
--		"priceValue"             = 8
--		"receipt"                = "{"packageName":"slots.swf.vegas.casino.games.free","productId":"slots.swf.vegas.casino.games.free.099","purchaseTime":1498203497547,"purchaseState":0,"purchaseToken":"eijdjkelpeomfbicfdjjlmep.AO-J1Ow2xiGk7iYOLWP9ZoODt9r2kMtnpldhJByXYaFka31k59IcSq0DyIkN11-kW53781EslR1uunAiIHpJsCi8k7bT9nHA7wFB0d_qbpDtTsHxsNystYkW9wYXfcomtzQDcGF3ED6WsvpD3uJ1BYfImQ23bpBFtDr-xtMQsHsDR3W9f0ixu7s"}"
--		"receiptCipheredPayload" = "lL+KWNlv/lZB7253ZyQUajlUMLnP906htkAqNSuUI7N6dRDBq85u0GnUvTJC7XLTUMQ0zff1CjxkC08uy04+2gOoRJg2vY5GiSvWlM8wCO8EeCXqEX8CGvnmfZWd3r+Y3NeAMuEXyC8ofEHIKiHrF1JXGdXy/8n7wS3ZCsnQ/QxstiHk+rdk3kpgzZ1Jc79L/mwJiV7FFzwPrM6EmLlwvZeB8vZJq249FWJtQ1rVyKb6DD7zO+xHn/czvjvASIm8OcwFXQAg5SbboKUfVWLOPigKODa0MoiWE4Fu48FiaiIQwOR2/h4n8Dnc9Jn+Qg1BQrN86X09ZrswiEj3Of4VYg=="
--		"title"                  = "a1 (Slots With Friends - Vegas Casino Slot Machines)"
--		"transactionID"          = ""
--		"type"                   = "CONSUMABLE"
--	}
--}

--endregion
