-- region *.lua
-- Date
-- 此文件由[BabeLua]插件自动生成
local MiniGameControl = class("MiniGameControl")
function MiniGameControl:ctor()
    print("MiniGameControl:init")
    self.theme_id = 0
    self.miniGame_id = 0
    self.isContinue = false
    self.nextData = { }
    bole.socket:registerCmd(bole.SRRVER_PLAY_MINI_GAME, self.oncmd, self)
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
end
function MiniGameControl:removeListener()
    bole:getEventCenter():removeEventWithTarget("miniGame", self)
    bole:getEventCenter():removeEventWithTarget("next_data", self)
    bole:getEventCenter():removeEventWithTarget("next_miniGame", self)
    bole:getEventCenter():removeEventWithTarget("remainMini", self)
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
    self.isContinue = true
    if not self.feature_data then
        self:tryNextMiniGame()
        return
    end
    self.continue_data = { }
    self.features = { }

    if self.theme_id == 7 then
        for k, v in pairs(self.feature_data) do
            if v.feature_items then
                dump(v.feature_items, "MiniGameControl:feature_items")
                local jsGame = bole:getEntity("app.views.minigame.JonesGame", v.feature_items)
                bole:getSpinApp():addMiniGame(jsGame)
                return
            else

            end
        end
    end

    for k, v in pairs(self.feature_data) do
        if v.completed == 0 then
            self.features[k] = tonumber(k)
            self.continue_data["" .. k] = v.feature_items
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
    if self.theme_id == 7 then
        bole:postEvent("JonesGame", data)
        return
    end
    if bole:getMiniGameControl():isMiniGame(self.miniGame_id) then
        -- minigame
        local ui_name = bole:getMngName(self.theme_id, self.miniGame_id)
        bole:postEvent(ui_name, data)
    else
        if self.theme_id == 1 then
            if self.miniGame_id == bole.MINIGAME_ID_WITCH then
                bole:postEvent(bole.UI_NAME.WitchGameLayer, data)
            elseif self.miniGame_id == bole.MINIGAME_ID_EMERALD then
                bole:postEvent(bole.UI_NAME.EmeraldDialogLayer, { msg = "minigame", chose = data })
            end
        else

            local ui_name = bole:getMngName(self.theme_id, self.miniGame_id)
            if not ui_name then
                print("--------------------tryMiniGame error not ui_name")
            else
                bole:postEvent(ui_name, data)
            end
        end
    end

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
        print("----------------------------remainMiniResult")
        self.isContinue = false
        bole:postEvent("remainMiniResult", self.nextData)
    else
        print("---------------------------next")
        bole:postEvent("next", self.nextData)
    end
    self.nextData = nil
    self.nextData = { }
end
-- 尝试进入下一个小游戏
function MiniGameControl:tryNextMiniGame()
    self:tryMiniGame( { result = { feature = self.features } })
end

-- 是否是 bounsgame
function MiniGameControl:isMiniGame(featrue_id)
    local theme = bole:getSpinApp():getTheme()
    local name = theme:getThemeName()
    local theme_features = bole:getConfigCenter():getConfig(name .. "_feature")
    local t_type = 5
    for k, v in pairs(theme_features) do
        if v.featrue_id == featrue_id then
            if v.featrue_type == t_type then
                return true
            end
        end
    end
end

-- 获得优先级最高的小游戏id
function MiniGameControl:getMiniGameId()
    if not self.features then return 0 end
    local gameid = 0
    local theme = bole:getSpinApp():getTheme()
    local name = theme:getThemeName()
    local theme_features = bole:getConfigCenter():getConfig(name .. "_feature")
    local t_key = nil
    -- 预留10中type类型
    local t_type = 10
    -- 排序找到优先级最高的feature
    for k, v in pairs(self.features) do
        for th_k, th_v in pairs(theme_features) do
            if th_v.featrue_id == v then
                if th_v.featrue_type <= t_type then
                    t_type = th_v.featrue_type
                    t_key = k
                end
            end
        end
    end
    if t_key then
        gameid = self.features[t_key]
        self.features[t_key] = 0
    end
    return gameid
end

-- MNGADD
function MiniGameControl:tryMiniGame(data)
    -- 可断线重连的游戏需要的数据
    data = data.result
    dump(data, "MiniGameControl")
    self.features = data.feature
    local gameid = self:getMiniGameId()
    if gameid > 0 then
        self.miniGame_id = gameid
        print("------------------------------------- self.miniGame_id" .. self.miniGame_id)

        if bole:getMiniGameControl():isMiniGame(gameid) then
            -- minigame
            if self.theme_id == 7 then
                if self.continue_data and self.continue_data["" .. gameid] then
                    local newData = self.continue_data["" .. gameid]
                    local jsGame = bole:getEntity("app.views.minigame.JonesGame", newData)
                    bole:getSpinApp():addMiniGame(jsGame)
                else
                    local jsGame = bole:getEntity("app.views.minigame.JonesGame")
                    bole:getSpinApp():addMiniGame(jsGame)
                end
            else
                if self.continue_data and self.continue_data["" .. gameid] then
                    local newData = self.continue_data["" .. gameid]
                    bole:getUIManage():openMiniGame(gameid, newData)
                    self.continue_data = { }
                else
                    bole:getUIManage():openMiniGame(gameid)
                end
            end
        else
            -- collectgame freespingame
            if self.theme_id == 1 then
                self:openOzGame(gameid, data)
            elseif self.theme_id == 2 then
                self:openFarmGame(gameid, data)
            elseif self.theme_id == 3 then
                self:openLoveGame(gameid, data)
            elseif self.theme_id == 4 then
                self:openMermaidGame(gameid, data)
            elseif self.theme_id == 5 then
                self:openSeaGame(gameid, data)
            elseif self.theme_id == 6 then
                self:openGorillaGame(gameid, data)
            elseif self.theme_id == 7 then
                self:openJonesGame(gameid, data)
            else
                self:nextSpin()
                print("--------------------tryMiniGame error")
            end
        end
        return
    else
        self.features = nil
    end
    self:nextSpin()
end
-- 除bounsGame外 其他类型小游戏
function MiniGameControl:openOzGame(gameid, data)
    if gameid == bole.MINIGAME_ID_EMERALD then
        bole:postEvent("mng_dialog", { msg = "start", ui_name = bole.UI_NAME.EmeraldDialogLayer })
    elseif gameid == bole.MINIGAME_ID_WITCH then
        self:miniGame_step(0)
        bole:getUIManage():openMiniGame(gameid)
    elseif gameid == bole.MINIGAME_ID_MAGICIAN then
        if data.free_spins then
            bole:postEvent("mng_dialog", { msg = "start", ui_name = bole.UI_NAME.McDialogLayer, chose = { data.free_spins } })
        else
            bole:postEvent("mng_dialog", { msg = "start", ui_name = bole.UI_NAME.McDialogLayer, chose = { 15 } })
        end
    else
        self:nextSpin()
    end
end
function MiniGameControl:openFarmGame(gameid, data)
    self:nextSpin()
end
function MiniGameControl:openLoveGame(gameid, data)
    if gameid == bole.MINIGAME_ID_FLOWER_FREESPIN then
        if data.free_spins then
            bole:postEvent("mng_dialog", { msg = "start", ui_name = bole.UI_NAME.FlowerDialogLayer, chose = { data.free_spins } })
        else
            bole:postEvent("mng_dialog", { msg = "start", ui_name = bole.UI_NAME.FlowerDialogLayer, chose = { 15 } })
        end
    else
        self:nextSpin()
    end
end

function MiniGameControl:openJonesGame(gameid, data)
    if gameid == "10103" then
        bole:postEvent("mng_newDialog", { msg = "more", ui_name = "JonesDialog", chose = { data.free_spins } })
    else
        self:nextSpin()
    end
end
function MiniGameControl:openMermaidGame(gameid, data)
    self:nextSpin()
end
function MiniGameControl:openSeaGame(gameid, data)
    if gameid == bole.MINIGAME_ID_SEA_FREESPIN then
        bole:postEvent("mng_newDialog", { msg = "start", ui_name = "SeaDialog", chose = { data.free_spins } })
    else
        self:nextSpin()
    end
end
function MiniGameControl:openGorillaGame(gameid, data)
    -- self:miniGame_step(0)
    if gameid == bole.MINIGAME_ID_GORILLALAYER_COLLECT then
        if self.continue_data and self.continue_data["" .. gameid] then
            local newData = self.continue_data["" .. gameid]
            bole:getUIManage():openMiniGame(gameid, newData)
            self.continue_data = { }
        else
            bole:getUIManage():openMiniGame(gameid)
        end
    elseif gameid == bole.MINIGAME_ID_GORILLALAYER_FREESPIN then
        bole:postEvent("mng_newDialog", { msg = "start", ui_name = "GorillaDialog", chose = { data.free_spins } })
    else
        self:nextSpin()
    end
end
return MiniGameControl
-- endregion
