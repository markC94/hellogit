--region *.lua
--Date
--此文件由[BabeLua]插件自动生成

--一切购买相关
local BuyManage = class("BuyManage")

function BuyManage:initLocalData()
    self.priceTable = bole:getConfigCenter():getConfig("price")
    self.coinstore_position = bole:getConfigCenter():getConfig("coinstore_position")
    self.diamondstore_position = bole:getConfigCenter():getConfig("diamondstore_position")
    self.vipTable = bole:getConfigCenter():getConfig("vip")
    self.out_of_coin_position = bole:getConfigCenter():getConfig("out_of_coin_position")
    self.reward = bole:getConfigCenter():getConfig("reward")
    self.givecoins = bole:getConfigCenter():getConfig("givecoins")
    self.buydrinks = bole:getConfigCenter():getConfig("buydrinks")
end

function BuyManage:initListener()
    bole:addListener("purchaseSuccess", self.purchaseSuccess, self, nil, true)
    bole.socket:registerCmd("collect_vip_reward", self.reCollect_vip_reward, self)
    bole.socket:registerCmd("collect_shop_bonus", self.reCollect_shop_bonus, self)
end

function BuyManage:cleanLocalData()
    self.priceTable = nil
    self.coinstore_position = nil
    self.diamondstore_position = nil
    self.vipTable = nil
    self.out_of_coin_position = nil
    self.reward = nil
    self.givecoins = nil
    self.buydrinks = nil
    self:removeListener()
end

function BuyManage:removeListener()
    bole:getEventCenter():removeEventWithTarget("purchaseSuccess", self)
    bole:getEventCenter():removeEventWithTarget("collect_vip_reward", self)
    bole:getEventCenter():removeEventWithTarget("collect_shop_bonus", self)
end

function BuyManage:getVipLevel()
    return tonumber(bole:getUserDataByKey("vip_level"))
end

function BuyManage:getVipMaxLevel()
    local num = 0
    for k ,v in pairs(self.vipTable) do
        num = num + 1
    end
    return num
end

function BuyManage:setVipLevel(lv)
    return bole:setUserDataByKey("vip_level", lv)
end

function BuyManage:getVipName()
    return self.vipTable[tostring(self:getVipLevel())]["vip_name"]
end

function BuyManage:getNextVipName()
    return self.vipTable[tostring( math.min(self:getVipLevel() + 1 , self:getVipMaxLevel()))]["vip_name"]
end

function BuyManage:getVipPoints()
    return tonumber(bole:getUserDataByKey("vip_points"))
end


function BuyManage:setVipPoints(point)
    return bole:setUserDataByKey("vip_points", lv)
end


function BuyManage:getVipRewardBoxIconPath(id)
    return "shop_icon/".. bole:getConfigCenter():getConfig("vip_reward", id, "vip_reward_con")  .. ".png"
end

function BuyManage:getVipIconStr(lv)
    lv = lv or self:getVipLevel()
    return "shop_icon/" .. self.vipTable[tostring(lv)].vip_icon .. ".png"
end

function BuyManage:getBuyLevel()
    return tonumber(bole:getUserDataByKey("purchase_level"))
end

function BuyManage:setBuyLevel(level)
    return bole:setUserDataByKey("purchase_level",level)
end

function BuyManage:getVipTable()
    return self.vipTable
end

--是否解锁全部主题
function BuyManage:isunlock()
    if self:getMultiplier("isunlock") == 1 then
        return true
    end
    return false
end

function BuyManage:getCoinShopData()
    local storeIdList = self:getPricePosItem( self.coinstore_position , "coinstore_item")
    if storeIdList == nil then
        storeIdList = {1001,1002,1003,1004,1006}
    end
    local coinsStoreInfo = {}
    for i = # storeIdList, 1 , -1 do
        local info = {}
        info.id = storeIdList[i]
        local buyList = self:getPriceDataById(info.id)
        info.commodity_id = buyList.commodity_id
        info.fakeNum = buyList.fakecoins_amount
        info.num = buyList.coins_amount
        info.price = buyList.price
        info.reward = buyList.item_id
        info.vipP = buyList.vipp_amount
        table.insert(coinsStoreInfo, info)
    end
    return coinsStoreInfo
end

function BuyManage:getDiamondShopData()
    local storeIdList = self:getPricePosItem( self.diamondstore_position , "diamondstore_item")
    if storeIdList == nil then
        storeIdList = {1001,1002,1003,1004,1006}
    end
    local diamondStoreInfo = {}
    for i = # storeIdList, 1 , -1 do
        local info = {}
        info.id = storeIdList[i]
        local buyList = self:getPriceDataById(info.id)
        info.commodity_id = buyList.commodity_id
        info.num = buyList.diamonds_amount
        info.fakeNum = buyList.fakecoins_amount
        info.price = buyList.price
        info.reward = buyList.item_id
        info.vipP = buyList.vipp_amount
        table.insert(diamondStoreInfo, info)
    end
    return diamondStoreInfo
end

function BuyManage:getOOCShopData()
    local storeIdList = self:getPricePosItem( self.out_of_coin_position, "store_item")

    if storeIdList == nil then
        storeIdList = {1001,1002,1003}
    end

    local storeInfo = {}
    for i = 1, # storeIdList do
        local info = {}
        info.id = storeIdList[i]
        local buyList = self:getPriceDataById(info.id)
        info.num = buyList.coins_amount
        info.price = buyList.price
        info.reward = buyList.item_id
        info.commodity_id = buyList.commodity_id
        info.vipP = buyList.vipp_amount
        table.insert(storeInfo, info)
    end
    return storeInfo
end

function BuyManage:getGiftCoinsData()
    local coinsList = {}
    for k ,v in pairs(self.givecoins) do
        table.insert(coinsList,v)
    end
    table.sort(coinsList,function(a,b) return a.givecoins_id < b.givecoins_id end)
    return coinsList
end

function BuyManage:getGiftDrinkData()
    local drinkList = {}
    for k ,v in pairs(self.buydrinks) do
        table.insert(drinkList,v)
    end
    table.sort(drinkList,function(a,b) return a.drinks_id < b.drinks_id end)
    return drinkList
end

function BuyManage:getGiftIconStr(give_type,give_id)
    if give_type == 1 then
        return "inSlot_icon/" .. self.givecoins[tostring(give_id)].givecoins_pictureid .. ".png" 
    else
        return "inSlot_icon/" .. self.buydrinks[tostring(give_id)].buydrinks_pictureid .. ".png" 
    end
end

function BuyManage:getGiftIconActName(give_type,give_id)
    if give_type == 1 then
        --return "inSlot_icon/" .. self.givecoins[tostring(give_id)].aniname .. ".png" 
        return "animation1"
    else
        return self.buydrinks[tostring(give_id)].aniname
    end
end

function BuyManage:getFreeCoinsNum()
    local levelTable = bole:getConfigCenter():getConfig("level")
    local bonus = levelTable["" .. bole:getUserDataByKey("level")]["shop_bonus"]
    return bonus * self:getMultiplier("store_multiplier")
end

function BuyManage:getMultiplier(multiplierName)
    local vipLevel = self:getVipLevel()
    return self.vipTable[tostring(vipLevel)][multiplierName] or 1
end

function BuyManage:getShopVipMulShowNum()
    return (self:getMultiplier("buying_multiplier") - 1) * 100 .. "%More"
end

function BuyManage:getCoinsShopMul()
    return self:getMultiplier("buying_multiplier") * self:getLevelMultiplier()
end

function BuyManage:getCoinsShopMulShowNum(commodity_id)
    local price = self.priceTable[commodity_id].price + 0.01
    local coins_amount = self.priceTable[commodity_id].coins_amount
    local diamonds_amount = self.priceTable[commodity_id].diamonds_amount
    local moreMul
    if coins_amount ~= 0 then
         moreMul = (coins_amount / price) / self:getPriceVarcharDataById(1001,"coins_amount")
         return math.floor((self:getCoinsShopMul() * moreMul - 1) * 100) .. "%"
    end
    if diamonds_amount ~= 0 then
         moreMul = (diamonds_amount / price) / self:getPriceVarcharDataById(1011,"diamonds_amount")
         return math.floor( (moreMul - 1) * 100 ).. "%"
    end
end

function BuyManage:getLevelMultiplier()
    local levelTable = bole:getConfigCenter():getConfig("level")
    return levelTable["" .. bole:getUserDataByKey("level")]["store_multiplier"]
end


--@param  购买id(purchase_id)
--@return price表中对应行
function BuyManage:getPriceDataById(id)
    for k , v in pairs(self.priceTable) do
        if id == v.purchase_id then
            return v
        end
    end
end

--@param  购买id(purchase_id)
--@param  varchar
--@return price表中对应行varchar字段
function BuyManage:getPriceVarcharDataById(id,varchar)
    for k , v in pairs(self.priceTable) do
        if id == v.purchase_id then
            return v[varchar]
        end
    end
end


--@function 返回指定档位表中的购买id列表
--@param positionTable 档位表, itemName 返回列的字段名, rfm 玩家购买等级
--@return 购买id列表
function BuyManage:getPricePosItem(positionTable, itemName ,rfm)
    rfm = rfm or tonumber(bole:getUserDataByKey("purchase_level"))
    local price_position = {}
    local storeIdList

    if type(positionTable) ~= "table" then
        positionTable = bole:getConfigCenter():getConfig(positionTable)
    end

    for k ,v in pairs( positionTable ) do
        table.insert(price_position , # price_position + 1 , v)
    end
    table.sort(price_position, function(a,b) return a.price_position < b.price_position end)

    storeIdList = price_position[# price_position][itemName]
    for i = 1, # price_position do
        if rfm < tonumber(price_position[i].price_position) then
            storeIdList = price_position[i][itemName]
            break
        end
    end
    return storeIdList
end

function BuyManage:getReward(idList)
    local infoList = {}
    if idList == nil then
        return infoList
    end
    for i = 1, # idList do
        local info = {}
         info.typeStr = ""
         info.type = self.reward[tostring(idList[i])]["bonus_type"]
         info.number = self.reward[tostring(idList[i])]["bonus_number"]
         if type == 10 then
            info.typeStr = "coins"
         elseif type == 9 then
            info.typeStr = "diamond"
         elseif type == 8 then
            info.typeStr = "大厅加速券"
         elseif type == 5 then
            info.typeStr = "vip积分"
            info.number = info.number * self:getMultiplier("vippoints_multiplier")
         elseif type == 4 then
            info.typeStr = "金券"
         elseif type == 3 then
            info.typeStr = "银卷"
         elseif type == 2 then
            info.typeStr = "铜卷"
         elseif type == 1 then
            info.typeStr = "双倍经验"
         elseif type == 101 then
            info.typeStr = "100M奖励"
         elseif type == 102 then
            info.typeStr = "400M奖励"
         elseif type == 103 then
            info.typeStr = "1B奖励"
         end 
            
         table.insert(infoList, # infoList + 1, info)    
    end
    return infoList
end

function BuyManage:refreshUseData(data)
    if data.vip_level ~= nil then
        bole:setUserDataByKey("vip_level",data.vip_level)
    end
    if data.vip_points ~= nil then
        bole:setUserDataByKey("vip_points",data.vip_points)
    end
    if data.purchase_level ~= nil then
        bole:setUserDataByKey("purchase_level",data.purchase_level)
    end
    if data.coins ~= nil then
        bole:getAppManage():addCoins(data.coins)
    end
    --bole:getUserData():updateSceneInfo("coins")
    --bole:getUserData():updateSceneInfo("diamond")
end

function BuyManage:buy(commodity_id)
    bole:postEvent("purchase",commodity_id)
end

function BuyManage:purchaseSuccess(data)
    data = data.result
    dump(data,"purchaseSuccess")

    print(tonumber(self.priceTable[data.productId]["price"]))
    bole:toAdjustPrice(data.productId,tonumber(self.priceTable[data.productId]["price"]) )
    bole:toAdjustPlayer()

    local purchase_id = 0
    if data.productId ~= nil then
        purchase_id = self.priceTable[data.productId]["purchase_id"] 
        local multiplier = 1
        if purchase_id >= 1001 and purchase_id <= 1010 then
            local multiplier_level = bole:getConfigCenter():getConfig("level", "" .. bole:getUserDataByKey("level"), "store_multiplier")
            multiplier = self:getMultiplier("buying_multiplier") * multiplier_level
        end
        local addCoins = self.priceTable[data.productId]["coins_amount"] * multiplier
        local addDiamond = self.priceTable[data.productId]["diamonds_amount"] * multiplier
        if addCoins ~= nil then
            bole:getAppManage():addCoins(addCoins)
        end
        if addDiamond ~= nil then
            bole:getAppManage():addDiamond(addDiamond)
        end
    end

    if data.vip_level ~= nil then
        self:setVipLevel(data.vip_level)
    end
    if data.vip_points ~= nil then
        self:setVipPoints(data.vip_points)
    end
    if data.purchase_level ~= nil then
        self:setBuyLevel(data.purchase_level)
    end


    --inslot
    bole:refreshCoinsAndDiamondInSlot()

    --act
    if 1001 <= purchase_id and purchase_id <= 1020 then    --商店
        bole:postEvent("showBuyAct_shopLayer")
    elseif 1021 <= purchase_id and purchase_id <= 1026 then  --outofcoins
         bole:postEvent("closeOutOfCoinsLayer")
    elseif 1027 <= purchase_id and purchase_id <= 1031 then --sale
        bole:postEvent("closeSaleLayer")
        bole:postEvent("showSaleAct", { sender = bole:getUserDataByKey("user_id") , coins = 0 })
    elseif 1031 == purchase_id then   --clubbuy

    elseif 1033 <= purchase_id and purchase_id <= 1044 then  --act
        
    end
end

function BuyManage:reCollect_vip_reward(t,data)
    if data.error ~= 0 then
        bole:popMsg({msg ="error " .. data.error  , title = "vip" , cancle = false })
    else
        bole:setUserDataByKey("vip_reward",data.vip_reward)
        local syncUserInfo = bole:getUserData():getSyncUserInfo()
        local coins = syncUserInfo.coins
        local diamond = syncUserInfo.diamond
        local vouchers = syncUserInfo.vouchers
        bole:getAppManage():addCoins(coins - bole:getUserDataByKey("coins"))
        bole:getAppManage():addDiamond(diamond - bole:getUserDataByKey("diamond"))
        bole:refreshCoinsAndDiamondInSlot()
        bole:setUserDataByKey("vouchers",vouchers)
        bole:postEvent("refreshVipCollect")
    end
end

function BuyManage:reCollect_shop_bonus(t,data)
    if data.error ~= 0 then
        bole:popMsg({msg ="error " .. data.error  , title = "vip" , cancle = false })
    else
        local syncUserInfo = bole:getUserData():getSyncUserInfo()
        local coins = syncUserInfo.coins
        bole:getAppManage():addCoins(coins - bole:getUserDataByKey("coins"))
        bole:refreshCoinsAndDiamondInSlot()
        bole.shop_bonus_time = 28800
        bole:postEvent("show_collect_shop_bonus_act")
    end
end

return BuyManage
--endregion
