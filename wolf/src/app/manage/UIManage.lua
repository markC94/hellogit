-- region *.lua
-- Date
-- 此文件由[BabeLua]插件自动生成
local UIManage = class("UIManage");
local UI_NAME = {
    "MainScene",
    "LoginScene",
    "SlotsLobbyScene",
    "LobbyScene",
    "FairyGameLayer",
    "CollectNode",
    "LoadingLayer",
    "TopLayer",
    "KindLayer",
    "LoadingScene",
    "WitchGameLayer",
    "WitchDialogLayer",
    "EmeraldGameLayer",
    "EmeraldDialogLayer",
    "McDialogLayer",
    "HamsterGameLayer",
    "FlowerGameLayer",
    "FlowerDialogLayer",
    "MermaidLayer",
    "UplevelLayer",
    "Options",
    "InformationView",
    "InfoEditView",
    "TitleView",
    "GorillaLayer",
    "ClubProfileLayer",
    "ClubTipsLayer",
    "ClubInfoLayer",
    "ClubLeagueLayer"
}
function UIManage:ctor(...)
    -- body
    self:init()
    print("UIManage-ctor")
end
function UIManage:init()
    self.initTime = os.time()
    self._app = nil;
    self:initEnum()
    self.dialogs = { }
    self.dialogCount = 0
end

function UIManage:initListener()
    bole:addListener("dialog_push", self.pushDialog, self, nil, true)
    bole:addListener("dialog_pop", self.popDialog, self, nil, true)
    bole:addListener("dialog_clear", self.clearDialog, self, nil, true)
    bole:addListener("popupDialog", self.tryDialog, self, nil, true)
    bole:addListener("freespin_dialog", self.freeSpinDialog, self, nil, true)
    bole:addListener("mng_dialog", self.showMngDialog, self, nil, true)
    bole:addListener("mng_newDialog", self.showMngNewDialog, self, nil, true)
end
function UIManage:removeListener()
    bole:getEventCenter():removeEventWithTarget("dialog_push", self)
    bole:getEventCenter():removeEventWithTarget("dialog_pop", self)
    bole:getEventCenter():removeEventWithTarget("dialog_clear", self)
    bole:getEventCenter():removeEventWithTarget("popupDialog", self)
    bole:getEventCenter():removeEventWithTarget("freespin_dialog", self)
    bole:getEventCenter():removeEventWithTarget("mng_dialog", self)
    bole:getEventCenter():removeEventWithTarget("mng_newDialog", self)
end
function UIManage:setApp(app)
    self._app = app
end

function UIManage:initEnum()
    local enum_name = { }
    for _, v in ipairs(UI_NAME) do
        enum_name[v] = v
    end
    bole.UI_NAME = enum_name
end
-- 统一创建baseview子UI入口
function UIManage:getSimpleLayer(ui_name, isDialog,path)
    local view = self._app:createView(ui_name,path)
    view:setDialog(isDialog)
    return view
end

function UIManage:runUI(view)
    local scene = display.newScene("newScence")
    scene:addChild(view)
    display.runScene(scene)
end
-- 弹出对话框 openUI("name",{dialog=true})
function UIManage:openUI(ui_name, dialog, path)
    collectgarbage("collect")
    local view = self:getSimpleLayer(ui_name,dialog,path)
    if not dialog then
        self:runUI(view)
    else
        display.getRunningScene():addChild(view, bole.ZORDER_UI)
    end

    local clt = collectgarbage("count")
    print("memory open:" .. clt)
    return view
end

function UIManage:closeUI(ui_name)
    bole:postEvent(ui_name, { "ui_close" })
end

-- 开始连续弹窗
function UIManage:tryDialog(data)
    data = data.result
    self.free_spin_data = nil
    if bole:getAppManage():tryPop(data) then
        print("----------------------next1")
    else
        print("----------------------next2")
        bole:postEvent("next")
    end
end

-- freespinx需要延后延后弹窗
function UIManage:freeSpinDialog(data)
    self.free_spin_data = nil
    if bole:getAppManage():tryDelayPop(data.result.allData, false) then
        self.free_spin_data = { result = data.result }
    else
        self:tryMngDialog(data)
    end
end
-- freespin结束弹窗
function UIManage:tryMngDialog(data)
    local gameid = data.result["freeSpinFeatureId"]
    local theme_id = bole:getAppManage():getThemeId()
    if theme_id == 1 then
        if gameid == bole.MINIGAME_ID_WITCH then
            data.result.ui_name = bole.UI_NAME.WitchDialogLayer
            self:showMngDialog(data)
        elseif gameid == bole.MINIGAME_ID_MAGICIAN then
            data.result.ui_name = bole.UI_NAME.McDialogLayer
            self:showMngDialog(data)
        else
            bole:postEvent("free_spin_stop")
        end
    elseif theme_id == 3 then
        if gameid == bole.MINIGAME_ID_FLOWER_FREESPIN then
            data.result.ui_name = bole.UI_NAME.FlowerDialogLayer
            self:showMngDialog(data)
        else
            bole:postEvent("free_spin_stop")
        end
    else
        bole:postEvent("free_spin_stop")
    end

end

-- freespin 开始结束ui入口
function UIManage:showMngDialog(data)
    data = data.result
    local view = self:getSimpleLayer(data.ui_name, true)
    view:setDialog(true)
    bole:getSpinApp():addMiniGame(view)
    -- display.getRunningScene():addChild(view,bole.ZORDER_UI)
    bole:postEvent(data.ui_name, { msg = data.msg, chose = data.chose })
end
function UIManage:showMngNewDialog(data)
    data = data.result
    local jsGame=bole:getEntity("app.views.minigame."..data.ui_name)
    bole:getSpinApp():addMiniGame(jsGame)
    --display.getRunningScene():addChild(jsGame,bole.ZORDER_UI)
    bole:postEvent(data.ui_name, { msg = data.msg, chose = data.chose })
end
---- msg param  node(选填)
-- 存入需要连续UI入口
function UIManage:pushDialog(data)
    data = data.result
    self.dialogCount = self.dialogCount + 1
    self.dialogs[self.dialogCount] = { msg = data.msg, param = data.param, node = data.node, isInit = true }
end
-- 弹出一个连续UI
function UIManage:popDialog()
    if self.dialogCount >= 1 then
        for i = 1, self.dialogCount do
            if self.dialogs[i] and self.dialogs[i].isInit then
                self.dialogs[i].isInit = false
                self:showDialog(self.dialogs[i])
                return
            end
        end
        self:overDialog()
    else
        self:overDialog()
    end
end
-- 显示弹出的UI
function UIManage:showDialog(data)
    local param = nil

    if data.msg == "kind" then
        --param = self:getSymbolRes(data.param.theme_id, data.param.link_id)
        local view = self:getSimpleLayer(bole.UI_NAME.KindLayer)
        view:setDialog(true)
        --view:initView(data.msg, param)
        bole:getSpinApp():addMiniGame(view)
        return
    end
    if data.msg == "big_win" then
        self:openBigWin(nil, 1, data.param.score)
        return
    end

    if data.msg == "mega_win" then
        self:openBigWin(nil, 2, data.param.score)
        return
    end

    if data.msg == "uplevel" then
        self:showUpLevel(data.param)
        return
    end
end

-- 结束连续弹UI
function UIManage:overDialog()
    self:clearDialog()
    if self.free_spin_data then
        self:tryMngDialog(self.free_spin_data)
        self.free_spin_data = nil
    else
        bole:postEvent("next")
    end
end
-- 清理连续UI记录数据
function UIManage:clearDialog()
    self.dialogs = nil
    self.dialogs = { }
    self.dialogCount = 0
end

-- MNGADD
-- 小游戏ui入口
function UIManage:openMiniGame(gameid, data)
    if gameid <= 0 then return end
    local view = nil
    local theme_id = bole:getAppManage():getThemeId()

    if bole:getMiniGameControl():isMiniGame(gameid) then
        -- minigame
        local ui_name = bole:getMngName(theme_id, gameid)
        if not ui_name then
            bole:postEvent("next_miniGame")
            return
        end
        view = self:getSimpleLayer(ui_name, true)
        view:initData(data)
    else
        -- collectgame freespingame
        if theme_id == 1 then
            view = self:openOzGame(gameid, data)
        end
        if theme_id == 6 then
            view = self:openGorillaGame(gameid, data)
            view:initData(data)
        end
    end

    if view then
        view:setDialog(true)
        -- display.getRunningScene():addChild(view,bole.ZORDER_UI)
        bole:getSpinApp():addMiniGame(view)
    end
end
-- 收集和freespin Game 
function UIManage:openOzGame(gameid, data)
    local view = nil
    if gameid == bole.MINIGAME_ID_WITCH then
        view = self:getSimpleLayer(bole.UI_NAME.WitchGameLayer, true)
    elseif gameid == bole.MINIGAME_ID_EMERALD then
        view = self:getSimpleLayer(bole.UI_NAME.EmeraldGameLayer, true)
    end
    return view
end
function UIManage:openGorillaGame(gameid, data)
    local view = self:getSimpleLayer(bole.UI_NAME.GorillaLayer, true)
    return view
end
-- 通用弹窗
function UIManage:openInfoView(node)
    local view = self:getSimpleLayer(bole.UI_NAME.InformationView, true)
    display.getRunningScene():addChild(view, bole.ZORDER_UI)
    view:showInfo(node)
end
function UIManage:openEditView(data)
    local view = self:getSimpleLayer(bole.UI_NAME.InfoEditView, true)
    display.getRunningScene():addChild(view, bole.ZORDER_UI)
    view:showInfo(data)
end
function UIManage:openTitleView()
    local view = self:getSimpleLayer(bole.UI_NAME.TitleView, true)
    display.getRunningScene():addChild(view, bole.ZORDER_UI)
end
function UIManage:openInputView(index)
    local view = bole:getNewInfoPut(index)
    display.getRunningScene():addChild(view, bole.ZORDER_UI)
end
function UIManage:openLeagueView(data)
    local view = self:getSimpleLayer(bole.UI_NAME.ClubLeagueLayer, true,"csb/club")
    display.getRunningScene():addChild(view, bole.ZORDER_UI)
    bole:postEvent(bole.UI_NAME.ClubLeagueLayer,data)
end
function UIManage:openClubRankView(data)
    local view = self:getSimpleLayer("ClubRankLayer", true,"csb/club")
    display.getRunningScene():addChild(view, bole.ZORDER_UI)
    bole:postEvent("ClubRankLayer",data)
end
function UIManage:openClubChestView(data)
    local view = self:getSimpleLayer("ClubChestLayer", true,"csb/club")
    display.getRunningScene():addChild(view, bole.ZORDER_UI)
    bole:postEvent("ClubChestLayer",data)
end

function UIManage:openClubTipsView(data, func, func2)
    local view = self:getSimpleLayer(bole.UI_NAME.ClubTipsLayer, true,"csb/club")
    display.getRunningScene():addChild(view, bole.ZORDER_UI)
    view:changeUI(data, func, func2)
end
-- 大厅顶部菜单
function UIManage:addTopLayer(node)
    local view = self:getSimpleLayer(bole.UI_NAME.TopLayer)
    if node then
        view:setDialog(false)
        node:addChild(view)
    else
        print("addTopLayer not node")
    end
end
-- 游戏中提示
function UIManage:addTips(theme_id,path, posX, posY)
    local tip = cc.loadLua("app.command.ShowTips"):create(path, theme_id)
    bole:getSpinApp():addMiniGame(tip)
    tip:setPosition(cc.p(posX, posY))
    if not self.tips then
        self.tips={}
    end
    self.tips[#self.tips + 1] = tip
end

function UIManage:closeTips()
    if not self.tips then
        return
    end
    for k, v in ipairs(self.tips) do
        if v and v:getReferenceCount() > 0 then
            v:removeFromParent()
            self.tips[k] = nil
        end
    end
    self.tips = nil
end
function UIManage:clearTips()
    self.tips = nil
end

function UIManage:addSpinEFF(theme_id)
--    local data = bole:getConfigCenter():getConfig("theme", theme_id)
--    if data and data.drift then
--        for _, v in ipairs(data.drift) do
--            self:addTips(theme_id,v.name, v.x, v.y)
--        end
--    end
    self:addTips(theme_id,"tips_test1.png", 900, 250)
end


function UIManage:getSymbolRes(theme_id, link_id)
    local theme = bole:getSpinApp():getTheme()
    local name = theme:getThemeName()
    print("--------------------getSymbolRes=" .. name)
    local symbol_name = bole:getConfigCenter():getConfig(name .. "_link", link_id, "symbol_resource")
    return theme:getFrameNameById(symbol_name)
end


function UIManage:openBigWin(node, ui_type, score)
    local skeletonNode = sp.SkeletonAnimation:create("common/win.json", "common/win.atlas")
    -- skeletonNode:setScale(0.5)

    skeletonNode:registerSpineEventHandler( function(event)
        print(string.format("[spine] %d start: %s",
        event.trackIndex,
        event.animation))
    end , sp.EventType.ANIMATION_START)

    skeletonNode:registerSpineEventHandler( function(event)
        print(string.format("[spine] %d end:",
        event.trackIndex))
    end , sp.EventType.ANIMATION_END)

    skeletonNode:registerSpineEventHandler( function(event)
        print(string.format("[spine] %d complete: %d",
        event.trackIndex,
        event.loopCount))
    end , sp.EventType.ANIMATION_COMPLETE)

    skeletonNode:registerSpineEventHandler( function(event)
        print(string.format("[spine] %d event: %s, %d, %f, %s",
        event.trackIndex,
        event.eventData.name,
        event.eventData.intValue,
        event.eventData.floatValue,
        event.eventData.stringValue))
    end , sp.EventType.ANIMATION_EVENT)

    skeletonNode:setMix("big_trigger", "big_disappear", 0.2)
    skeletonNode:setMix("mega_trigger", "mega_disappear", 0.2)
    if ui_type == 1 then
        skeletonNode:setAnimation(0, "big_trigger", false)
        skeletonNode:addAnimation(0, "big_disappear", false, 2)
        bole:getAudioManage():playEff("all_bigwin")
    else
        skeletonNode:setAnimation(0, "mega_trigger", false)
        skeletonNode:addAnimation(0, "mega_disappear", false, 2)
        bole:getAudioManage():playEff("all_megawin")
    end
    performWithDelay(skeletonNode, function()
        skeletonNode:removeFromParent()
        bole:postEvent("dialog_pop")
    end , 2.5)
    local windowSize = cc.Director:getInstance():getWinSize()
    skeletonNode:setPosition(cc.p(windowSize.width / 2, windowSize.height / 2))
    --    local txtbg=skeletonNode:findBone("di")
    --    local txt=cc.Label:createWithSystemFont("12345677777","Aril",50)
    --    txtbg:addChild(txt)
    if node then
        node:addChild(skeletonNode)
    else
        bole:getSpinApp():addMiniGame(skeletonNode)
    end
end

-- 弹出升级
function UIManage:showUpLevel(data)
    local view = self:getSimpleLayer(bole.UI_NAME.UplevelLayer, true)
    bole:getSpinApp():addMiniGame(view)
    -- display.getRunningScene():addChild(view,bole.ZORDER_UI)
    bole:postEvent(bole.UI_NAME.UplevelLayer, data)
end

function UIManage:flyNode(node, start_pos, end_pos, fly_type)

end
-- 网络请求等待暂时没有使用
function UIManage:updateWaitTime()
    if not self.wait_time then return end
    if self.wait_time == -1 then
        return
    end
    if self.wait_time <= 0 then
        self:closeWait()
        bole:postEvent("timeout")
        return
    end
    self.wait_time = self.wait_time - 0.1
end
function UIManage:closeWait()
    self.wait_time = -1
    --    if self.waitUI and self.waitUI:getReferenceCount() > 0 then
    --        self.waitUI:setVisible(false)
    --    else
    --        self.waitUI = nil
    --    end
end

function UIManage:toWait(timeout)
    if self.waitUI and self.waitUI:getReferenceCount() > 0 then
        self.waitUI:setVisible(true)
    else
        self.waitUI = nil
        self.waitUI = ccui.Layout:create()
        self.waitUI:ignoreContentAdaptWithSize(false)
        self.waitUI:setClippingEnabled(false)
        local isColor = false
        if isColor then
            self.waitUI:setBackGroundColorType(1)
            self.waitUI:setBackGroundColor( { r = 0, g = 0, b = 0 })
        end

        self.waitUI:setBackGroundColorOpacity(50)
        self.waitUI:setTouchEnabled(true);
        self.waitUI:setLayoutComponentEnabled(true)
        self.waitUI:setName("UIManage")
        self.waitUI:setCascadeColorEnabled(true)
        self.waitUI:setCascadeOpacityEnabled(true)
        local layout = ccui.LayoutComponent:bindLayoutComponent(self.waitUI)
        layout:setPercentWidthEnabled(true)
        layout:setPercentHeightEnabled(true)
        layout:setPercentWidth(1.0000)
        layout:setPercentHeight(1.0000)
        layout:setSize( { width = 1334.0000, height = 750.0000 })
        display.getRunningScene():addChild(self.waitUI, bole.ZORDER_TOP)
        self.waitUI:setVisible(true)
    end
    if timeout then
        self.wait_time = timeout
    end

end
return UIManage
-- endregion
