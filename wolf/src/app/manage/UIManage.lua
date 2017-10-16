-- region *.lua
-- Date
-- 此文件由[BabeLua]插件自动生成
local UIManage = class("UIManage");
function UIManage:ctor(...)
    -- body
    self:init()
    print("UIManage-ctor")
end
function UIManage:init()
    self.initTime = os.time()
    self.dialogs = { }
    self.dialogCount = 0
    self.InfoList={}
end

function UIManage:initListener()
    bole:addListener("popupDialog", self.tryDialog, self, nil, true)
    bole.socket:registerCmd(bole.SYNC_HEAD_INFO, self.syncHeadInfo, self)
end
function UIManage:removeListener()
    bole:getEventCenter():removeEventWithTarget("popupDialog", self)
    bole.socket:unregisterCmd(bole.SYNC_HEAD_INFO)
end

-- 弹出对话框
function UIManage:createNewUI(name,uiPath,luaPath,data,isMaskUI)
    collectgarbage("collect")
    luaPath=luaPath.."."..name
    local view=bole:getEntity(luaPath,name,data,uiPath)
    view:setDialog(isMaskUI)
    local c1=collectgarbage("count")
    print("-------------------------------c1="..c1)
    return view
end

-- 统一创建baseview子UI入口
function UIManage:getSimpleLayer(name,isDialog,path)
    local  luaRoot="app.views"
    local  csbRoot="csb"
    if path then
        luaRoot="app.views."..path
        csbRoot="csb/"..path
    end
    local view=self:createNewUI(name,csbRoot,luaRoot,viewData,isDialog)
    return view
end

function UIManage:openNewSceneUI(view)
    local scene = display.newScene()
    scene:addChild(view)
    self:runScene(scene)
end

function UIManage:runScene(scene)
    display.runScene(scene)
    local listener = cc.EventListenerKeyboard:create()
    listener:registerScriptHandler(handler(self,self.onKeyboard), cc.Handler.EVENT_KEYBOARD_RELEASED)
    local eventDispatcher =scene:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener,scene)
    bole:getBoleEventKey():clearKeyBack()
end
function UIManage:onKeyboard(code, event)
    if code == cc.KeyCode.KEY_BACK then
        print("你点击了返回键")
        bole:getBoleEventKey():onKeyBack()
    elseif code == cc.KeyCode.KEY_HOME then
        print("你点击了HOME键")
    end
end

function UIManage:openScene(ui_name, path)
    local view = self:getSimpleLayer(ui_name,false,path)
    self:openNewSceneUI(view)
end

-- 弹出对话框 openUI("name",{dialog=true})
function UIManage:openUI(ui_name, dialog, path)
    local view = self:getSimpleLayer(ui_name,dialog,path)
    display.getRunningScene():addChild(view, bole.ZORDER_UI)
    return view
end
-- name名字(不可以传空) csbRootcsb路径 luaRootlua路径 viewData传入UIData   
function UIManage:openNewUI(name,dialog,csbRoot,luaRoot,viewData)
    if not csbRoot then
        csbRoot="csb"
    end
    if not luaRoot then
        luaRoot="app.views"
    end
    local view=self:createNewUI(name,csbRoot,luaRoot,viewData,dialog)
    display.getRunningScene():addChild(view, bole.ZORDER_UI)
    return view
end

function UIManage:closeUI(ui_name)
    bole:postEvent(ui_name, { "ui_close" })
end


------------------结算流程相关开始
-- 这里只弹bigwin
function UIManage:tryDialog(data)
    data = data.result
    if not self:tryBigWin(data) then
        bole:postEvent("next")
        return
    end
end
------------------结算流程相关开始

function UIManage:addSpinEFF(theme_id)
  
end

-- 游戏中提示
function UIManage:addTips(node,theme_id,x,y)
    self.tips = bole:getEntity("app.command.ShowTips",theme_id)
    if node then
        node:addChild(self.tips)
    else
        bole:getSpinApp():addMiniGame(self.tips)
    end
    self.tips:setPosition(x,y)
end

function UIManage:closeTips()
    if not self.tips then
        return
    end
    self.tips:removeFromParent()
    self.tips = nil
end
function UIManage:clearTips()
    self.tips = nil
end


function UIManage:getSymbolRes(theme_id, link_id)
    local symbol_name = bole:getSpinApp():getConfig(nil, "_link", link_id, "symbol_resource")
    return theme:getFrameNameById(symbol_name)
end


function UIManage:openPayTable()
    local theme_id=bole:getSpinApp():getTheme():getThemeId()
    local pop = bole:getEntity("app.views.minigame.PayTable",theme_id)
    display.getRunningScene():addChild(pop, bole.ZORDER_UI)
end

-- 弹出bigwin bole:getUIManage():openBigWin(type,score)
function UIManage:openBigWin(ui_type, score,node)
    local skeletonNode = sp.SkeletonAnimation:create("util_act/win.json", "util_act/win.atlas")
    local windowSize = cc.Director:getInstance():getWinSize()
    local big_node = cc.Node:create()
    local mask= self:getNewMaskUI("bigwin")

    local time=1
    local fator_score=0.6
    if ui_type == 0 then
        fator_score=0.8
        time=3.5
        skeletonNode:setAnimation(0, "bigwin", false)
        bole:getAudioManage():playEff("all_bigwin")
    elseif ui_type == 1 then
        fator_score=0.6
        time=4.5
        skeletonNode:setAnimation(0, "megawin", false)
        bole:getAudioManage():playEff("all_megawin")
    elseif ui_type == 2 then
        fator_score=0.4
        time=7
        skeletonNode:setAnimation(0, "crazywin", false)
        bole:getAudioManage():playEff("all_megawin")
    end
    performWithDelay(skeletonNode, function()
        skeletonNode:removeFromParent()
        mask:removeFromParent()
        bole:postEvent("next")
    end , time)
    performWithDelay(skeletonNode, function()
        big_node:removeFromParent()
    end , time+0.5)
    mask:setPosition(cc.p(windowSize.width / 2, windowSize.height / 2))
    skeletonNode:setPosition(cc.p(windowSize.width / 2, windowSize.height / 2))
    local node_score = bole:getCsbNode("csb/fonts/BigWinFont.csb")
    local txt_score=node_score:getChildByName("txt_name")
    skeletonNode:addChild(node_score,10)
    txt_score:setVisible(false)
    txt_score:setScale(0.1)
    txt_score:setPosition(0,15)
    performWithDelay(skeletonNode,function()
        txt_score:setVisible(true)
        txt_score:runAction(cc.ScaleTo:create(0.2,1))
        txt_score:setString( math.floor(score*fator_score))
    end,0.5)
    self:bigWinFlyCoin(ui_type,big_node,time-0.5,cc.p(windowSize.width / 2,0))
    self:bigWinEff(big_node,time)
    performWithDelay(skeletonNode,function()
        bole:runNum(txt_score, math.floor(score*fator_score),score,time-2,nil,{9},false)
    end,0.8)
    performWithDelay(skeletonNode, function()
        txt_score:runAction(cc.FadeOut:create(0.3))
    end , time-0.8)
    if node then
        node:addChild(mask)
        node:addChild(big_node)
        node:addChild(skeletonNode)
    else
        bole:getSpinApp():addMiniGame(mask)
        bole:getSpinApp():addMiniGame(big_node)
        bole:getSpinApp():addMiniGame(skeletonNode)
    end
end

--------------------UI界面弹出开始
-- 获得一个邀请界面
function UIManage:popInvitationInput()
    local pop = bole:getEntity("app.command.InvitationLayer")
    display.getRunningScene():addChild(pop, bole.ZORDER_UI)
end

-- 获取一个self经验条实例
function UIManage:getNewExpView(data)
    return bole:getEntity("app.views.lobby.LobbyExp", data)
end

-- 获取一个主题菜单
function UIManage:popLobbyMenu(node, theme_id)
    local pop = bole:getEntity("app.views.lobby.LobbyMenu", node, theme_id)
    local director = cc.Director:getInstance()
    local view = director:getOpenGLView()
    local dessize = view:getDesignResolutionSize()
    local w2, h2 = dessize.width, dessize.height
    pop:setPosition(w2 / 2, h2 / 2)
    display.getRunningScene():addChild(pop, bole.ZORDER_UI)
end

-- 获取一个每日登录礼包
function UIManage:popDailyGift(data)
    self:openNewUI("DailyGiftLayer", true, "daily_gift",nil,data)
end

-- 获得一个self金币实例
function UIManage:getNewCoinsView(data)
    return bole:getEntity("app.views.lobby.LobbyCoins", data)
end

-- 获取一个异步加载资源节点data={plist={},png={}},func_update(progress,path),func_finsh()
function UIManage:getLoadingNode(data, updateFunc, finishFunc)
    return bole:getEntity("app.command.LoadingNode", data, updateFunc, finishFunc)
end

-- 通用弹窗
function UIManage:openInfoView(node)
    local user_id = node:getInfo().user_id
    self.InfoList[user_id] = { node, node.isSelf, node:getInfo().pos }
    bole.socket:send(bole.SYNC_HEAD_INFO, { user_id = user_id })
end

function UIManage:syncHeadInfo(t, data)
    local view = self:openNewUI("InformationView", true, "player_profile")
    view:showInfo(self.InfoList[data.user_id])
    view:syncHeadInfo(t, data)
end


function UIManage:openEditView(data)
    local view = self:openNewUI("InfoEditView", true, "player_edit")
    view:showInfo(data)
end
function UIManage:openTitleView()
    
end
function UIManage:openLeagueView(data)
    local view = bole:getUIManage():createNewUI("ClubLeagueLayer","club","app.views.club",nil,true)
    --self:getSimpleLayer("ClubLeagueLayer", true,"club")
    display.getRunningScene():addChild(view, bole.ZORDER_UI)
    bole:postEvent("ClubLeagueLayer",data)
end
function UIManage:openClubRankView(data)
    local view = bole:getUIManage():createNewUI("ClubRankLayer","club","app.views.club",nil,true)
    --self:getSimpleLayer("ClubRankLayer", true,"club")
    display.getRunningScene():addChild(view, bole.ZORDER_UI)
    bole:postEvent("ClubRankLayer",data)
end
function UIManage:openClubChestView(data)
    local view = bole:getUIManage():createNewUI("ClubChestLayer","club","app.views.club",nil,true)
    --self:getSimpleLayer("ClubChestLayer", true,"club")
    display.getRunningScene():addChild(view, bole.ZORDER_UI)
    bole:postEvent("ClubChestLayer",data)
end

function UIManage:openClubInfoLayer(id)
    local view = bole:getUIManage():createNewUI("ClubInfoLayer","club","app.views.club",nil,true)
    display.getRunningScene():addChild(view, bole.ZORDER_UI)
    bole:postEvent("initClubId",id)
end

function UIManage:jumpToClubView(layerStr)
    if bole:getSpinApp():isThemeAlive() then
        bole:popMsg( { msg = "Whether to leave the room", title = "leave", cancle = true }, function()
            bole.socket:send(bole.SERVER_LEAVE_THEME, { })
            bole:getAppManage():updateLobby()
            bole:getAppManage():enterLobbyAndOpenLayer(layerStr)
        end )
    else
        bole:postEvent("openClubLayer")
        if layerStr == "request" then
            bole:postEvent("showClubRequestLayer")
        end
    end
end

function UIManage:jumpToFriendView(layerStr)
    if bole:getSpinApp():isThemeAlive() then
        bole:popMsg( { msg = "Whether to leave the room", title = "leave", cancle = true }, function()
            bole.socket:send(bole.SERVER_LEAVE_THEME, { })
            bole:getAppManage():updateLobby()
            bole:getAppManage():enterLobbyAndOpenLayer(layerStr)
        end)
    else
        local view = bole:getUIManage():openNewUI("FriendLayer", true, "friend", "app.views.friend")
        if layerStr == "request" then
            view:showRequestView()
        end
    end
end

function UIManage:jumpToLeagueView(layerStr)
    if bole:getSpinApp():isThemeAlive() then
        bole:popMsg( { msg = "Whether to leave the room", title = "leave", cancle = true }, function()
            bole.socket:send(bole.SERVER_LEAVE_THEME, { })
            bole:getAppManage():updateLobby()
            bole:getAppManage():enterLobbyAndOpenLayer(layerStr)
        end )
    else
        bole.socket:send(bole.SERVER_LEAGUE_RANK, { }, true)
    end
end

-- 弹出升级 bole:getUIManage():showUpLevel(data["levelup"])

function UIManage:addUpLevelRoot(root)
    self.upLevelRoot=root
end
function UIManage:showUpLevel(data,level)
    bole:getEntity("app.command.UpLevel",self.upLevelRoot,data,level)
end

-- 弹出5king bole:getUIManage():showFiveKing()
function UIManage:showFiveKing(num)
    if not num then
        return
    end
    local view = self:getSimpleLayer("KindLayer", false)
    view:updateKindNum(num)
    bole:getSpinApp():addMiniGame(view)
--     display.getRunningScene():addChild(view,bole.ZORDER_UI)
    bole:getAudioManage():playKind()
end

function UIManage:tryBigWin(data)
--    dump(data, "tryBigWin")

    if data.win_amount == 0 then
        return false
    end
    local bet = bole:getSpinApp():getTheme():getEachLineBet() * bole:getSpinApp():getTheme():getCurBetValue()
    local mult = data.win_amount / bet
    bole:getAudioManage():setWin(mult)
    if data["big_win"] == 1 then
        bole:getAudioManage():playBigWin()
        bole:getUIManage():openBigWin(0, data.win_amount)
        return true
    elseif data["mega_win"] == 1 then
        bole:getAudioManage():playMegaWin()
        bole:getUIManage():openBigWin(1, data.win_amount)
        return true
    elseif data["crazy_win"] == 1 then
        bole:getAudioManage():playCrazyWin()
        bole:getUIManage():openBigWin(2, data.win_amount)
        return true
    else
        return false
    end
end

--------------------UI界面弹出结束
-- 大厅顶部菜单
function UIManage:addTopLayer(node)
    local view = self:getSimpleLayer("TopLayer")
    if node then
        view:setDialog(false)
        node:addChild(view)
    else
        print("addTopLayer not node")
    end
end

-- 一个超过屏幕大小的蒙板
function UIManage:getNewMaskUI(name)
    if not name then name = "newMask" end
    local touch_layer = ccui.Layout:create()
    touch_layer:ignoreContentAdaptWithSize(false)
    touch_layer:setClippingEnabled(false)
    touch_layer:setBackGroundColorType(1)
    touch_layer:setBackGroundColor( { r = 6, g = 27, b = 46 })
    touch_layer:setBackGroundColorOpacity(204)
    touch_layer:setTouchEnabled(true);
    touch_layer:setLayoutComponentEnabled(true)
    touch_layer:setName(name)
    touch_layer:setCascadeColorEnabled(true)
    touch_layer:setCascadeOpacityEnabled(true)
    touch_layer:setAnchorPoint(0.5000, 0.5000)
    --    touch_layer:setPosition(1000.0000, 562.0000)
    local layout = ccui.LayoutComponent:bindLayoutComponent(touch_layer)
    layout:setPositionPercentX(0.5000)
    layout:setPositionPercentY(0.5000)
    --    layout:setPercentWidthEnabled(true)
    --    layout:setPercentHeightEnabled(true)
    layout:setPercentWidth(1.0000)
    layout:setPercentHeight(1.0000)
    layout:setSize( { width = 2001.0000, height = 1125.0000 })
    return touch_layer
end

function UIManage:flyCoin(startPos, endPos, callbackFunc, randomNum)
    local durationTime = 1.2
    randomNum = randomNum or 5
    local eachWaitTime = 0.1
    local actionTime = 1
    bole:getAudioManage():playEff("collect_coin")
    local node = cc.Node:create()
    local scene = cc.Director:getInstance():getRunningScene()
    scene:addChild(node, bole.ZORDER_TOP)

    local hideLaunchNodeFunc
    local launchFunc
    local flyEndFunc
    local cacheCoinNodes = { }
    local spendTime = 0
    local eachSpendTime = 0
    local stopLaunch = false
    local function update(dt)
        spendTime = spendTime + dt

        if spendTime > durationTime then
            stopLaunch = true
            hideLaunchNodeFunc()
            node:unscheduleUpdate()
            return
        end

        eachSpendTime = eachSpendTime + dt
        if eachSpendTime >= eachWaitTime then
            eachSpendTime = eachSpendTime - eachWaitTime
            launchFunc()
        end
    end
    node:onUpdate(update)

    local lightNode = sp.SkeletonAnimation:create("util_act/yellow_light.json", "util_act/yellow_light.atlas")
    node:addChild(lightNode)
    lightNode:setPosition(startPos.x, startPos.y)
    lightNode:setAnimation(0, "animation1", true)

    local particleNode = cc.ParticleSystemQuad:create("util_act/yellow_light.plist")
    node:addChild(particleNode)
    particleNode:setPosition(startPos.x, startPos.y)

    hideLaunchNodeFunc = function()
        if particleNode then
            local nodes = { particleNode, lightNode }
            for _, hideNode in ipairs(nodes) do
                local fadeOut = cc.FadeOut:create(0.3)
                local function endbackFunc()
                    hideNode:removeFromParent(true)
                end
                local callAction = cc.CallFunc:create(endbackFunc)
                hideNode:runAction(cc.Sequence:create(fadeOut, callAction))
            end
            particleNode = nil
        end
    end

    local function getCoinNode()
        local coinNode
        for _, skeletonNode in ipairs(cacheCoinNodes) do
            if not skeletonNode:isVisible() then
                skeletonNode:setVisible(true)
                skeletonNode:setToSetupPose()
                coinNode = skeletonNode
                break
            end
        end

        if not coinNode then
            coinNode = sp.SkeletonAnimation:create("util_act/coin_turnd.json", "util_act/coin_turnd.atlas")
            node:addChild(coinNode)
            table.insert(cacheCoinNodes, coinNode)
        end

        coinNode:setPosition(startPos.x + math.random(-15, 15), startPos.y + math.random(-15, 15))
        coinNode:setRotation(math.random(0, 360))
        coinNode:setAnimation(0, "animation" .. math.random(5), true)
        coinNode:setOpacity(0)

        return coinNode
    end

    local offsetX =(startPos.x - endPos.x) / 1.5
    local randomX = math.abs(offsetX) / 2
    local offsetY =(endPos.y - startPos.y) / 4
    local randomY = math.abs(offsetY) / 2

    local launchCount = 0
    launchFunc = function()
        local num = math.random(1, randomNum)
        launchCount = launchCount + num
        if num > 0 then
            for i = 1, num do
                local coinNode = getCoinNode()
                local fadeIn = cc.FadeIn:create(0.3)

                local controlPos1 = cc.p(startPos.x -(offsetX + math.random(- randomX, randomX)), startPos.y +(offsetY + math.random(- randomY, randomY)))
                local controlPos2 = cc.p(endPos.x +(offsetX + math.random(- randomX, randomX)), endPos.y -(offsetY + math.random(- randomY, randomY)))
                local config = { controlPos1, controlPos2, endPos }

                local action = cc.BezierTo:create(actionTime, config)
                local easeAction = cc.EaseInOut:create(action, 3)
                local fadeOut = cc.FadeOut:create(0.3)
                local function endCallFunc()
                    launchCount = launchCount - 1
                    coinNode:setVisible(false)
                    flyEndFunc()
                end
                local callAction = cc.CallFunc:create(endCallFunc)
                coinNode:runAction(cc.Sequence:create(cc.Spawn:create(easeAction, fadeIn), fadeOut, callAction))
            end
        else
            flyEndFunc()
        end
    end

    flyEndFunc = function()
        if launchCount == 0 and stopLaunch and node then
            node:removeFromParent(true)
            node = nil
            if callbackFunc then
                callbackFunc()
            end
        end
    end
end
function UIManage:bigWinEff(target, totalTime)
    local spendTime = 0
    local curTime = 0
    local node = cc.Node:create()
    local scene
    if not target then
        local scene = cc.Director:getInstance():getRunningScene()
        scene:addChild(node, bole.ZORDER_TOP)
    else
        scene = target
        scene:addChild(node)
    end
    local eff_pos={cc.p(360,750-194),cc.p(400,750-400),cc.p(1000,750-200),cc.p(1000,750-400),cc.p(444,750-90),cc.p(667,750-90)}
    local index=1
    local function update(dt)
        spendTime = spendTime + dt
        curTime = curTime + dt
        if curTime>=totalTime then
            curTime=0
            node:removeAllChildren(true)
            local function removeFunc()
                scene:removeChild(node, true)
                node = nil
            end
            scene:runAction(cc.Sequence:create(cc.DelayTime:create(0.01), cc.CallFunc:create(removeFunc)))
            return
        end
        if spendTime > 0.3 then
            spendTime = spendTime - 0.3
            local particle = cc.ParticleSystemQuad:create("util_act/yanhua.plist")
            node:addChild(particle)
            particle:setPosition(eff_pos[index].x+math.random(-110, 110),eff_pos[index].y+math.random(-110, 110))
            index=index+1
            if index >6 then
                index=1
            end
            --       node:setBlendFunc({src = 770, dst = 1})
        end
    end
    node:onUpdate(update)
end
function UIManage:bigWinFlyCoin(ui_type, target, totalTime, startPos, endCallback)
    
    local a = 1500
    local speedY0 = 1500
    local speedRandomY = 100
    local speedRandomX0 = 300
    local speedRandomX1 = 50 
    local durationTime = totalTime
    local randomNum0 = 2
    local randomNum1 = 3
    local eachWaitTime = 0.1

    local node = cc.Node:create()
    local scene
    if not target then
        local scene = cc.Director:getInstance():getRunningScene()
        scene:addChild(node, bole.ZORDER_TOP)
    else
        scene = target
        scene:addChild(node)
    end

    local hideLaunchNodeFunc
    local launchFunc
    local flyEndFunc
    local step
    local cacheCoinNodes = { }
    local spendTime = 0
    local eachSpendTime = 0
    local stopLaunch = false
    local launchCount = 0
    local function update(dt)
        step(dt)
        if stopLaunch then
            return
        end

        spendTime = spendTime + dt
        if spendTime > durationTime then
            stopLaunch = true
            hideLaunchNodeFunc()
            return
        end

        eachSpendTime = eachSpendTime + dt
        if eachSpendTime >= eachWaitTime then
            eachSpendTime = eachSpendTime - eachWaitTime
            launchFunc(spendTime)
        end
    end
    node:onUpdate(update)

    step = function(dt)
        for _, obj in ipairs(cacheCoinNodes) do
            obj:step(dt)
        end
    end

    local ParabolaNode = bole:getTable("app.model.ParabolaNode")
    local function genCoinNode()
        local vx0
        if math.random(0, 2) == 0 then
            vx0 = math.random(- speedRandomX1, speedRandomX1)
        else
            vx0 = math.random(- speedRandomX0, speedRandomX0)
        end
        local vy0 = speedY0 + math.random(- speedRandomY, speedRandomY)
        local x = startPos.x + math.random(-20, 20)

        local coinNode
        for _, coinObj in ipairs(cacheCoinNodes) do
            if coinObj:isDead() then
                coinNode = coinObj.node

                coinNode:setToSetupPose()
                coinObj:reset(vx0, vy0, x, startPos.y)
                break
            end
        end

        if not coinNode then
            coinNode = sp.SkeletonAnimation:create("util_act/coin_turnd.json", "util_act/coin_turnd.atlas")
            node:addChild(coinNode)
            local function downOverFunc()
                launchCount = launchCount - 1
                flyEndFunc()
            end
            local coinObj = ParabolaNode:create(coinNode, a, vx0, vy0, x, startPos.y, downOverFunc)
            table.insert(cacheCoinNodes, coinObj)
        end

        coinNode:setRotation(math.random(0, 360))
        coinNode:setAnimation(0, "animation" .. math.random(5), true)
    end

    launchFunc = function(time)
        local num = 1
        if ui_type == 0 then
            if time >= 1 and time < 2.5-0.5 then
                num = math.random(randomNum0, randomNum1)
            elseif  time >2.5-0.5 and time < 2.5 then
                num = math.random(6, 10)
            end
        elseif ui_type == 1 then
            if time >= 1.5 and time < 3.6-0.5 then
                num = math.random(randomNum0, randomNum1)
            elseif  time >3.3-0.5 and time <3.6 then
                num = math.random(6, 10)
            end
        else
            if time >= 2.1 and time < 6.1-0.5 then
                num = math.random(randomNum0, randomNum1)
            elseif  time >6.1-0.5 and time < 6.1 then
                num = math.random(6, 10)
            end
        end
        launchCount = launchCount + num
        if num > 0 then
            for i = 1, num do
                genCoinNode()
            end
        end
    end

    hideLaunchNodeFunc = function()
    end

    flyEndFunc = function()
        if launchCount == 0 and stopLaunch and node then
            node:removeAllChildren(true)
            local function removeFunc()
                scene:removeChild(node, true)
                node = nil
            end
            scene:runAction(cc.Sequence:create(cc.DelayTime:create(0.01), cc.CallFunc:create(removeFunc)))
            if endCallback then
                endCallback()
            end
        end
    end
end

return UIManage
-- endregion
