--region *.lua
--Date
--此文件由[BabeLua]插件自动生成
local BuyControl = class("BuyControl")
function BuyControl:ctor()
    print("BuyControl:ctor")
    if device.platform ~= "android" and device.platform ~= "ios" then return end

    self:init()
    self:setListeners()
end

function BuyControl:init()
    self.iap = bole:getInstance("app.controls.IAPControl")
    if device.platform == "ios" then
        self.platform = "appstore"
    else
        self.platform = "google"
    end
end

function BuyControl:setListeners()
    bole:registerCmd("verify_buy", self.onVerifyEnd, self)

    bole:addListener("platformPayBackSuccess", self.onPlatformBuySuccess, self, nil, true)
    bole:addListener("purchase", self.buy, self, nil, true)
end

function BuyControl:buy(event)
    
    if not self.iap then return end

    local name
    if type(event) == "table" then
        name = event.result
    else
        name = event
    end
    self.iap:buy(name)
end

function BuyControl:onPlatformBuySuccess(event)
    print("BuyControl:onPlatformBuySuccess")
    local result = event.result
    bole:sendMsg("verify_buy", {platform = self.platform, sign = result.receiptCipheredPayload, data = result.receipt})
end

function BuyControl:onVerifyEnd(t, data)
    dump(data, "BuyControl:onVerifyEnd")
    if data.error then return end
    
    bole:postEvent("purchaseSuccess",data)
end

return BuyControl
--endregion
