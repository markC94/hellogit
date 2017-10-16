--region *.lua
--Date
--此文件由[BabeLua]插件自动生成
local ActCenterControl = class("ActCenterControl")

local IconActPage = class("IconActPage", ccui.Widget)
local idTable = {
    [1] = "loyalSale",
    [2] = "coinSale",
    [3] = "clubSale",
    [4] = "vipSale",
    [5] = "diamondSale",
    [6] = "havingFun",
    [9] = "bindFacebook",
}
--local DiamondSalePage = class("DiamondSale", BaseActPage)
--local CoinSalePage = class("CoinSale", BaseActPage)
--local VipSalePage = class("VipSale", BaseActPage)
--local LoyalSalePage = class("LoyalSale", BaseActPage)
--local BindFacebookPage = class("BindFacebookPage", BaseActPage)
function ActCenterControl:ctor()
    self.actData = {}
    self:setListener()
end

function ActCenterControl:setListener()
    bole:addListener("startPopupActDialog", self.onPopupActDialog, self, nil, true)
    bole:addListener("loginActData", self.onParseActData, self, nil, true)
end

function ActCenterControl:onPopupActDialog(event)
    
end

function ActCenterControl:setActData()
end

function ActCenterControl:getActCount()
    return #self.actData
end

function ActCenterControl:insertAct(item, index)
end

function ActCenterControl:removeActById(id)
end

function ActCenterControl:getActItemById(id)
    for _, item in ipairs(self.actData) do
        if item.id == id then
            return item
        end
    end
    return nil
end

function ActCenterControl:getActDataByIndex(index)
    return self.actData[index]
end

function ActCenterControl:getActIdByIndex(index)
    return self.actData[index].id
end

function ActCenterControl:getActDataByTypeId(typeId)
    for k ,v in pairs(self.actData) do
        if v.id == typeId then
            return v
        end
    end
end

function ActCenterControl:getPageByIndex(index)
    local data = self:getActDataByIndex(index)
    return IconActPage:create(data.id, data.data, data.clickPage)
end

function ActCenterControl:onParseActData(event)
    local actData = {}
    local function clickPage(id,data)
        if id == 5 then  --钻石促销
            local dialog = bole:getEntity("app.views.activity.DiamondSaleDialog",data)
            dialog:run()
        elseif id == 2 then  --金币促销
            local dialog = bole:getEntity("app.views.activity.CoinSaleDialog",data)
            dialog:run()
        elseif id == 1 then --忠诚奖励
            local dialog = bole:getEntity("app.views.activity.LoyalSaleDialog",data)
            dialog:run()
        elseif id == 4 then --vip活动
            local dialog = bole:getEntity("app.views.activity.VipSaleDialog")
            dialog:run()
        elseif id == 9 then --facebook绑定
            local dialog = bole:getEntity("app.views.activity.BindFacebookDialog")
            dialog:run()
        elseif id == 6 then --faveing fun
            local dialog = bole:getEntity("app.views.activity.HaveFunDialog")
            dialog:run()
        end
    end
    
    local severTime = bole:string2time(bole:getUserDataByKey("server_time"))
    local player_rmf = tonumber(bole:getUserDataByKey("purchase_level"))
    local sale_match = bole:getConfigCenter():getConfig("game_sale_match")
    local new_activity = bole:getUserDataByKey("new_activity")
    if new_activity[1] ~= nil then
        sale_match["101"] = {
            promotion_id = 101,
            promotion_type = new_activity[1][1],
            promotion_start = new_activity[1][2],
            promotion_end = new_activity[1][2]
        }
    end

    --忠诚测试
    --[[
        sale_match["101"] = {
            promotion_id = 101,
            promotion_type = 1,
            promotion_start = "2017/07/01  00:00:00",
            promotion_end = "2018/10/01  00:00:00"
        }
    --]]

    local game_sale = bole:getConfigCenter():getConfig("game_sale")
    local actDataList = {}
    for k , v in pairs(game_sale) do
        local key = v.promotion_match_id
        if actDataList[key] == nil then
            actDataList[key] = {}
        end
        table.insert(actDataList[key], # actDataList[key] + 1, v)
    end

    local actIdList = {}
    for k, v in pairs(sale_match) do
        if severTime >= bole:string2time(v.promotion_start) and severTime < bole:string2time(v.promotion_end) then
            local actDataListTable = actDataList[tonumber(k)]
            if actDataListTable ~= nil then
                table.sort(actDataListTable, function(a, b) return a.player_rmf < b.player_rmf end)
                local storeIdt = actDataListTable[#actDataListTable].promotion_id
                for i = 1, #actDataListTable do
                    if player_rmf < tonumber(actDataListTable[i].player_rmf) then
                        storeIdt = actDataListTable[i].promotion_id
                        break
                    end
                end
                table.insert(actIdList,{promotion_id = v.promotion_id , promotion_type = v.promotion_type , purchase_id = storeIdt })
            else
                table.insert(actIdList,{promotion_id = v.promotion_id , promotion_type = v.promotion_type })
            end
        end
    end

    local item
    for i = 1, #actIdList do
        --俱乐部购买没有ui
        if actIdList[i].promotion_type ~= 3 then
            item = {
                id = actIdList[i].promotion_type,
                priority = actIdList[i].promotion_id,
                data = actIdList[i].purchase_id,
                clickPage = clickPage
            }
            table.insert(actData, item)
        end
    end

    --facebook
    table.insert(actData, {id = 9, priority =999, clickPage = clickPage})

    --loyal
    if sale_match["101"] ~= nil then
        bole.loyal_surplus_time = bole:string2time(sale_match["101"].promotion_end) - bole:string2time(bole:getUserDataByKey("server_time"))
    end

    --[[
    local item = {id = "diamondSale", priority = 3, data = {sale = 20000, money = 3.99}, clickPage = clickPage}
    table.insert(actData, item)
    --]]
    table.sort(actData, function(a, b)
        if a.priority < b.priority then
            return true
        end
        return false
    end)

    self.actData = actData
end

function IconActPage:isVipSale()
    for k ,v in pairs(self.actData) do
        if v.id == 4 then
            return true
        end
    end
    return false
end

function IconActPage:isClubBuySale()
    for k ,v in pairs(self.actData) do
        if v.id == 3 then
            return true
        end
    end
    return false
end


function IconActPage:ctor(id,data, clickFunc)
    self.id = id
    self.data = data
    self.clickFunc = clickFunc


    local sp = cc.Sprite:create(string.format("activityCenter/%s.png", idTable[id]))
     self:addChild(sp)
end

function IconActPage:setPageEnabled(flag)
    self.isPageEnabled = flag
end

function IconActPage:setClickFunc(clickFunc)
    self.clickFunc = clickFunc
end

function IconActPage:onClickPage()
    --if not self.isPageEnabled then return end

    if self.clickFunc then
        self.clickFunc(self.id,self.data)
    end
end

--function DiamondSalePage:ctor(id)
--    DiamondSalePage.super.ctor(self, id)
--end

--function CoinSalePage:ctor(id)
--    CoinSalePage.super.ctor(self, id)
--end

--function VipSalePage:ctor(id)
--    VipSalePage.super.ctor(self, id)
--end

--function LoyalSalePage:ctor(id)
--    LoyalSalePage.super.ctor(self, id)
--end

--function BindFacebookPage:ctor(id)
--    BindFacebookPage.super.ctor(self, id)
--end


return ActCenterControl
--endregion
