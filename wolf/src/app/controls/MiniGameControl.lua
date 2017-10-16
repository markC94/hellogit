-- region *.lua
-- Date
-- 此文件由[BabeLua]插件自动生成
local MiniGameControl = class("MiniGameControl")
--收集和小游戏 文件名字
local GameName={"1","FarmGame","3","4","5","GorillaLayer","JonesGame","8","9"}
--弹窗 freespin 文件名字
local FreeSpinDialogName={"1","FarmDialog","3","4","SeaDialog","GorillaDialog","JonesDialog","LongHurnDialog","9"}
function MiniGameControl:ctor()
    print("MiniGameControl:init")
    --小游戏对应的文件名
    self.theme_id = 0
    self.isContinue = false
    self.nextData = { }
    bole.socket:registerCmd(bole.SRRVER_PLAY_MINI_GAME, self.oncmd, self)
end
function MiniGameControl:getGameName()
    return GameName[self.theme_id]
end
function MiniGameControl:getFreeSpinName()
    return FreeSpinDialogName[self.theme_id]
end
function MiniGameControl:oncmd(t, data)
    if t == bole.SRRVER_PLAY_MINI_GAME then
        self:minigame_update(data)
    end
end

function MiniGameControl:initListener()
    bole:addListener("miniGame", self.tryMiniGame, self, nil, true)
    bole:addListener("next_data", self.setNextData, self, nil, true)
    bole:addListener("next_miniGame", self.tryNextMiniGame, self, nil, true)
    bole:addListener("remainMini", self.enterGame, self, nil, true)
    bole:addListener("freespin_dialog", self.freeSpinOver, self, nil, true)
end
function MiniGameControl:removeListener()
    bole:getEventCenter():removeEventWithTarget("miniGame", self)
    bole:getEventCenter():removeEventWithTarget("next_data", self)
    bole:getEventCenter():removeEventWithTarget("next_miniGame", self)
    bole:getEventCenter():removeEventWithTarget("remainMini", self)
    bole:getEventCenter():removeEventWithTarget("freespin_dialog", self)
end
function MiniGameControl:initTheme(theme_id)
    self.theme_id = theme_id
end

function MiniGameControl:enterFeature(data)
    self.feature_data = { }
    if data then
        self.feature_data = data
    end
end
-- 断线重连获得的数据
function MiniGameControl:enterGame(event)

    local data=event.result
    if not data then
        return
    end

    bole.slot_sale_time =600-data.room_info.create_time%600 
    local isWild = false
    if data.freespin_type == 1 or data.freespin_type == 6 then
        isWild = true
    end

    local newData = { freeSpin = data.free_spins, wild = isWild, freeMutiple = data.fs_multiple, freeCollect = data.fs_collect, feature_id = data.fs_type }
    bole:postEvent("next_data", newData)
    bole:getMiniGameControl():enterFeature(data.feature)

    self.isContinue = true
    if not self.feature_data then
        self:tryNextMiniGame() 
        return
    end

    self.continue_data = { }
    self.features = { }
    dump(self.feature_data,"self.feature_data",10)
    --琼斯有个转盘特殊处理
    if self.theme_id == 7 then
        for k, v in pairs(self.feature_data) do
            if v.feature_items then
                dump(v.feature_items, "MiniGameControl:feature_items")
                local jsGame = bole:getEntity("app.views.minigame.JonesGame", v.feature_items)
                bole:getSpinApp():addMiniGame(jsGame)
                return
            else
                --不处理
            end
        end
    end
    --继续上次的小游戏
    for k, v in pairs(self.feature_data) do
        if v.completed == 0 then
            self.features[k] = tonumber(k)
            self.continue_data["" .. k] = v.feature_items
            if data.collect_coin_pool then
                self.continue_data["" .. k].collect_coin_pool=data.collect_coin_pool
            end
        end
    end
    self:tryNextMiniGame()
end

-- minigame
function MiniGameControl:minigame_start()
    self:miniGame_step(0)
end
-- 请求向服务器请求下一步
function MiniGameControl:miniGame_step(index)
    bole.socket:send(bole.SRRVER_PLAY_MINI_GAME, { theme_id = self.theme_id, values = index })
end

-- MNGADD
-- 更新小游戏操作
function MiniGameControl:minigame_update(data)
    bole:postEvent(GameName[self.theme_id], data)
end
-- 小游戏过程中存储数据(结束时候发送给spin下一步)
function MiniGameControl:setNextData(data)
    data = data.result
    if not data then return end
    for k, v in pairs(data) do
        self.nextData[k] = v
    end
end
-- 小游戏完成执行spin下一步操作
function MiniGameControl:nextSpin()
    dump(self.nextData, "nextSpin")
    if self.isContinue then
        self.isContinue = false
        bole:postEvent("remainMiniResult", self.nextData)
    else
        bole:postEvent("next", self.nextData)
    end
    self.nextData = nil
    self.nextData = { }
end
-- 尝试进入下一个小游戏
function MiniGameControl:tryNextMiniGame()
    self:tryMiniGame( { result = { feature = self.features } })
end

function MiniGameControl:getFeatureType(featrue_id)
    local theme_features = bole:getSpinApp():getConfig(nil, "feature")
    for k, v in pairs(theme_features) do
        if v.featrue_id == featrue_id then
           return v.featrue_type
        end
    end
end

function MiniGameControl:getFeatureId(featrue_type)
    local theme_features = bole:getSpinApp():getConfig(nil, "feature")
    for k, v in pairs(theme_features) do
        if v.featrue_type == featrue_type then
           return v.featrue_id
        end
    end
end


-- 获得优先级最高的feature id
function MiniGameControl:getMiniGameId()
    if not self.features then return 0 end
    local feature_id = 0
    local theme_features = bole:getSpinApp():getConfig(nil, "feature")
    local t_key = nil
    -- 预留10中type类型
    local t_type = 10
    -- 排序找到优先级最高的feature
    local game_type = 5
    local game_id

    dump(self.features, "theme_features")
    for k, v in pairs(self.features) do
        if self:getFeatureType(v) == game_type then
            self:isSameGame(v)
        end
    end

    for k, v in pairs(self.features) do
        local cur_type = self:getFeatureType(v)
        if cur_type then 
            if cur_type <= t_type then
                t_type = cur_type
                t_key = k
            end
        end
    end

    dump(self.features, "self.features new")
    if t_key then
        feature_id = self.features[t_key]
        print("getMiniGameId features t_key=" .. t_key)
        self.features[t_key] = 0
    end

    print("getMiniGameId features feature_id=" .. feature_id)
    return feature_id
end

function MiniGameControl:isSameGame(game_id)
    local isSame=false
    for k, v in pairs(self.features) do
        if v == game_id then
            if not isSame then
                isSame=true
                print("getMiniGameId isSame=true")
            else
                self.features[k] = 0
                print("getMiniGameId k="..k)
            end
        end
    end
end
-- MNGADD
function MiniGameControl:tryMiniGame(data)
    -- 可断线重连的游戏需要的数据
    data = data.result
    self.features = data.feature
    local feature_id = self:getMiniGameId()
    print("--------------------tryMiniGame feature_id="..feature_id)
    if feature_id > 0 then
        self:popGame(feature_id,data)
        return
    else
        self.features = nil
    end
     print("--------------------tryMiniGame nextSpin")
    self:nextSpin()
end

function MiniGameControl:popGame(feature_id,data)
    dump(data,"freeSpinPop-data")
    local feature_type=self:getFeatureType(feature_id)
    if feature_type==5 or feature_type==2 then
        --小游戏和收集
        dump(self.features,"popGame")
        print("popGame-----------------------------------feature_id="..feature_id)
        self:miniGameStart(feature_id,data)
    elseif feature_type==6 then
        --freespin开始
        if self.theme_id == 8 then
            --猛犸特殊处理
            self:openhornGame(feature_id,data,feature_type)
            return
        end
        self:freeSpinStart(feature_id,data)
    elseif feature_type==7 then
        --freespin过程中freespin
        if self.theme_id == 8 then
            --猛犸特殊处理
            self:openhornGame(feature_id,data,feature_type)
            return
        end
        self:freeSpinMore(feature_id,data)
    else
        --其他不处理进入下一步
        print("----------------------feature_type="..feature_type)
        self:nextSpin()
    end
end
--小游戏和收集
function MiniGameControl:miniGameStart(feature_id, data)
    bole:postEvent("exitNewbieInfo")
    local newData
    if self.continue_data and self.continue_data["" .. feature_id] then
        newData = self.continue_data["" .. feature_id]
    end
    local view = bole:getEntity("app.views.minigame."..self:getGameName(), newData,self:getGameName(),feature_id)
    bole:getSpinApp():addMiniGame(view)
    self.continue_data = { }
end
--freespin开始
function MiniGameControl:freeSpinStart(feature_id,data)
    if not feature_id then
        feature_id=self:getFeatureId(6)
    end
   self:openFreeSpinUI("start",self:getFreeSpinName(),{ data.free_spins_total },data.autoSpinning,feature_id)
end
--freespin过程中freespin
function MiniGameControl:freeSpinMore(feature_id,data)
    if not feature_id then
        feature_id=self:getFeatureId(7)
    end
   self:openFreeSpinUI("more",self:getFreeSpinName(),{ data.free_spins},nil,feature_id)
end
--freespin结束
function MiniGameControl:freeSpinOver(event)
    local data=event.result.allData
    dump(data,"freeSpinOver-data")
    bole:getAudioManage():clearFreeSpin()
    self:openFreeSpinUI("over",self:getFreeSpinName(),{ data.free_spins_total,data.fs_coins },data.autoSpinning,self:getFeatureId(6))
end
--freespin UI弹出
function MiniGameControl:openFreeSpinUI(msg,ui_name,chose,autoSpinning,feature_id)
    if not feature_id then
        feature_id=10101
    end
    local fsDialog=bole:getEntity("app.views.minigame."..ui_name,ui_name,feature_id)
    bole:getSpinApp():addMiniGame(fsDialog)
--    display.getRunningScene():addChild(fsDialog,bole.ZORDER_UI)
    bole:postEvent(ui_name, { msg = msg, chose = chose ,autoSpinning=autoSpinning})
end

--猛犸需要做动画在弹窗 特殊处理
function MiniGameControl:openhornGame(feature_id, data,feature_type)
    local animNode = sp.SkeletonAnimation:create(bole:getSpinApp():getSymbolAnim(nil, "longhorn_run"))
    bole:getSpinApp():addMiniGame(animNode)
    animNode:setAnimation(0, "animation", false)
    animNode:setScale(1.2)
    animNode:setPosition(667, 375)
    local mask = bole:getUIManage():getNewMaskUI()

    animNode:addChild(mask, -1)
    bole:getAudioManage():playLongHurn()
    performWithDelay(animNode, function()
        animNode:removeFromParent()
        bole:getAudioManage():stopLongHurn()
        if feature_type== 6 then
            self:freeSpinStart(feature_id,data)
        else
            self:freeSpinMore(feature_id,data)
        end
    end , 2)
end
--琼斯 因为转盘和weild 特殊处理
function MiniGameControl:freeSpinJonesStart(num,weild)
    self:openFreeSpinUI("start",self:getFreeSpinName(),{num,weild},true,self:getFeatureId(6))
end

return MiniGameControl
-- endregion
