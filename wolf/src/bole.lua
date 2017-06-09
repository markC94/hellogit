-- region *.lua
-- Date
-- 此文件由[BabeLua]插件自动生成

bole.debug = bole.getDebugMode()
bole.requireTable = { }
bole.instanceTable = { }

-- 层级 使用位置：display.getRunningScene():addChild(XXXX,bole.ZORDER_XXX)
bole.ZORDER_TOP = 500-- 对话框 公告 系统提示
bole.ZORDER_UI = 200-- UI view layer 界面层
bole.ZORDER_BG = 10-- 背景层
bole.ZORDER_NONE = 0-- 默认层
bole.ZORDER_BOTTOM = -100-- 底层
-- 间隔方便加入其他层

function bole:getTable(name)
    local EntityTable = self.requireTable[name]
    if not EntityTable then
        EntityTable = require(name)
        self.requireTable[name] = EntityTable
    end
    return EntityTable
end

function bole:getEntity(name, ...)
    return bole:getTable(name):create(...)
end   

function bole:getInstance(name, ...)
    local entityIntance = self.instanceTable[name]
    if not entityIntance then
        entityIntance = self:getEntity(name, ...)
        self.instanceTable[name] = entityIntance
    end
    return entityIntance
end

function bole:getFacebookCenter()
    return self:getInstance("app.controls.FacebookControl")
end

function bole:getEventCenter()
    return self:getInstance("app.manage.EventCenter")
end

function bole:getUserData()
    return self:getInstance("app.model.UserData")
end

function bole:getSpinApp()
    return self:getInstance("app.command.SpinApp")
end

function bole:getConfigCenter()
    return self:getInstance("app.model.ConfigCenter")
end

function bole:getNoticeCenter()
    return self:getInstance("app.manage.NoticeCenter")
end

function bole:getAudioManage()
    return self:getInstance("app.manage.AudioManage")
end

function bole:getAppManage()
    return self:getInstance("app.manage.AppManage")
end

function bole:getUIManage()
    return self:getInstance("app.manage.UIManage")
end

function bole:getLoginControl()
    return self:getInstance("app.controls.LoginControl")
end

function bole:getMiniGameControl()
    return self:getInstance("app.controls.MiniGameControl")
end

function bole:getClubControl()
    return self:getInstance("app.controls.ClubControl")
end

function bole:getLobbyControl()
    return self:getInstance("app.controls.LobbyControl")
end
-- 弹出一个对话框
-- msg 信息 title 标题 cancle是否有取消按钮 func按钮回调
-- data={msg=nil,title=nil,cancle=false} 都可以为空
function bole:popMsg(data, funcOK, funcNo)
    local pop = bole:getEntity("app.command.DialogLayer", data, funcOK, funcNo)
    return display.getRunningScene():addChild(pop, bole.ZORDER_TOP)
end
-- 获得一个邀请界面
function bole:getInvitationInput()
    local pop = bole:getEntity("app.command.InvitationLayer")
    return display.getRunningScene():addChild(pop, bole.ZORDER_UI)
end
-- 获得一个新头像实例 data=nil获取self数据
function bole:getNewHeadView(data)
    return bole:getEntity("app.command.HeadView", data)
end
function bole:getNewInfoPut(index)
    return bole:getEntity("app.command.InfoInput", index)
end
-- 获取一个self经验条实例
function bole:getNewExpView(data)
    return bole:getEntity("app.views.lobby.LobbyExp", data)
end
-- 获得一个self金币实例
function bole:getNewCoinsView(data)
    return bole:getEntity("app.views.lobby.LobbyCoins", data)
end
-- 获取一个每日登录礼包
function bole:getDailyGift()
    local pop = bole:getEntity("app.views.DailyGift")
    return display.getRunningScene():addChild(pop, bole.ZORDER_UI)
end
function bole:getLanguageControl()
    return self:getInstance("app.command.LanguageControl")
end
function bole:getUserDataByKey(key)
    return self:getUserData():getDataByKey(key)
end

function bole:setUserDataByKey(key, value)
    self:getUserData():setDataByKey(key, value)
end

function bole:changeUserDataByKey(key, value)
    return self:getUserData():changeDataByKey(key, value)
end

function bole:addListener(eventName, func, target, args, notRemoveAfterExec)
    self:getEventCenter():registerEvent(eventName, func, target, args, notRemoveAfterExec)
end

function bole:removeListener(eventName, target)
    if target then
        self:getEventCenter():removeEventWithTarget(eventName, target)
    else
        self:getEventCenter():removeEventByName(eventName)
    end
end

function bole:postEvent(eventName, args)
    self:getEventCenter():postEvent(eventName, args)
end

function bole:getConfig(file, id, key)
    return self:getConfigCenter():getConfig(file, id, key)
end

function bole:getDeviceId()
    local imme = bole.getIMEI()
    if not imme or imme == "" then
        imme = "wangshuaijinxin8888"
    end
    return imme
end

function bole:getMacAddress()
    local macAddress = bole.getMacID()
    if not macAddress or macAddress == "" then
        macAddress = "787878787877899999"
    end
    return macAddress
end

-- @id icon id
-- @return icon路径
function bole:getClubIconStr(id)
    local icon = nil
    local iconStr = nil
    if id ~= nil then
        id = tonumber(id)
        if bole:getConfigCenter():getConfig("clubicon", id) == nil then
            return iconStr
        end
        iconStr = bole:getConfigCenter():getConfig("clubicon", id, "club_icon")
        iconStr = "res/clubIcon/" .. iconStr .. ".png"
        -- icon = cc.Sprite:create(iconStr)
        return iconStr
    else
        local iconList = bole:getConfigCenter():getConfig("clubicon")
        local randomList = { }
        for k, v in pairs(iconList) do
            if v.club_icontype == 1 then
                table.insert(randomList, #randomList + 1, tonumber(k))
            end
        end
        id = randomList[math.random(1, #randomList)]
        iconStr = bole:getConfigCenter():getConfig("clubicon", id, "club_icon")
        iconStr = "res/clubIcon/" .. iconStr .. ".png"
        -- icon = cc.Sprite:create(iconStr)
        return iconStr, id
    end

end

-- @label 文本标签cc.Label
-- @startValue 可以为空，默认会从label里取出
-- @endValue 最终的值
-- @useTime 所用的时间 可以为空，默认1s
-- @endCallback 结束时的回调，可以为空
function bole:runNum(label, startValue, endValue, useTime, endCallback)
    if not useTime then
        useTime = 1
    end

    if not startValue then
        local value = label:getString()
        if value == "" then
            startValue = 0
        else
            startValue = tonumber(value)
        end
    end

    local addValuePerSecond =(endValue - startValue) / useTime
    local spendTime = 0
    local function update(dt)
        if spendTime >= useTime then
            label:unscheduleUpdate()
            if endCallback then
                endCallback()
            end
            return
        end

        spendTime = spendTime + dt
        if spendTime >= useTime then
            label:setString(endValue)
        else
            label:setString(startValue + math.floor(addValuePerSecond * spendTime))
        end
    end
    label:onUpdate(update)
end

function bole:flyCoin(startPos, endPos, callbackFunc)
    local durationTime = 1.2
    local randomNum = 5
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

    local lightNode = sp.SkeletonAnimation:create("common/yellow_light.json", "common/yellow_light.atlas")
    node:addChild(lightNode)
    lightNode:setPosition(startPos.x, startPos.y)
    lightNode:setAnimation(0, "animation1", true)

    local particleNode = cc.ParticleSystemQuad:create("common/yellow_light.plist")
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
            coinNode = sp.SkeletonAnimation:create("common/coin_turnd.json", "common/coin_turnd.atlas")
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

function bole:bigWinFlyCoin(startPos, endCallback)
    local a = 400
    local speedY0 = 600
    local speedRandomY = 100
    local speedRandomX0 = 200
    local speedRandomX1 = 40
    local durationTime = 2
    local randomNum0 = 3
    local randomNum1 = 8
    local eachWaitTime = 0.1

    local node = cc.Node:create()
    local scene = cc.Director:getInstance():getRunningScene()
    scene:addChild(node, bole.ZORDER_TOP)

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
            launchFunc()
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
            coinNode = sp.SkeletonAnimation:create("common/coin_turnd.json", "common/coin_turnd.atlas")
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

    launchFunc = function()
        local num = math.random(randomNum0, randomNum1)
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

-- obligate:保留位数  默认，分割
-- 例:bole:formatCoins(999999.99,2)=0.9M
-- bole:formatCoins(999999.99,4)=999.9K
-- bole:formatCoins(999999.99,6)=999,999
-- bole:formatCoins(999999.99,6,true)=999999
-- bole:formatCoins(999999.99,7)=999,999
function bole:formatCoins(coins, obligate, notCut)
    if obligate < 1 then
        return coins
    end
    local isCut = true
    if notCut then
        isCut = false
    end
    local str_coins = nil
    coins = tonumber(coins)
    local nCoins = math.floor(coins)
    local count = math.floor(math.log10(nCoins)) + 1
    if count <= obligate then
        str_coins = self:cutCoins(nCoins, isCut)
    else
        if count < 3 then
            str_coins = self:cutCoins(nCoins / obK, isCut) .. "K"
        else
            local tCoins = nCoins
            local tNum = 0
            local units = { "K", "M", "G", "T" }
            local cell = 1000
            local index = 0
            while
                (1)
            do
                index = index + 1
                if index > 4 then
                    return self:cutCoins(tCoins, isCut) .. units[4]
                end
                tNum = tCoins % cell
                tCoins = tCoins / cell
                local num = math.floor(math.log10(tCoins)) + 1
                if num <= obligate then
                    return self:cutCoins(tCoins, isCut, obligate - num) .. units[index]
                end
            end
        end
    end
    return str_coins
end


function bole:clipStrFloat(str)
    local nChar = string.sub(str, -1, -1)
    if nChar == '0' then
        local nStr = string.sub(str, 1, -2)
        return self:clipStrFloat(nStr)
    elseif nChar == '.' then
        return ""
    else
        return str
    end
end
-- obligateF:小数保留位数
function bole:cutCoins(coins, isCut, obligateF)
    local nCoins = math.floor(coins)
    local fCoins = coins - nCoins
    local strF = ""
    -- 计算小数预留位
    if obligateF and obligateF ~= 0 then
        strF = string.sub(fCoins .. "", 2, 2 + obligateF)
        -- 去掉小数末尾的0
        strF = self:clipStrFloat(strF)
    end
    if not isCut then
        return nCoins .. strF
    end
    -- 添加分隔符
    local count = math.floor(math.log10(nCoins)) + 1
    local obK = math.pow(10, 3)
    local obM = math.pow(10, 6)
    local obG = math.pow(10, 9)
    local obT = math.pow(10, 12)
    if count <= 3 then
        return nCoins .. strF
    elseif count <= 6 then
        local s1 = math.floor(nCoins / obK)
        local s2 = nCoins % obK
        return string.format("%d,%03d%s", s1, s2, strF)
    elseif count <= 9 then
        local s1 = math.floor(nCoins / obM) % obK
        local s2 = math.floor(nCoins / obK) % obK
        local s3 = math.floor(nCoins) % obK
        return string.format("%d,%03d,%03d%s", s1, s2, s3, strF)
    elseif count <= 12 then
        local s1 = math.floor(nCoins / obG) % obK
        local s2 = math.floor(nCoins / obM) % obK
        local s3 = math.floor(nCoins / obK) % obK
        local s4 = math.floor(nCoins) % obK
        return string.format("%d,%03d,%03d,%03d%s", s1, s2, s3, s4, strF)
    else
        local s1 = math.floor(nCoins / obT) % obK
        local s2 = math.floor(nCoins / obG) % obK
        local s3 = math.floor(nCoins / obM) % obK
        local s4 = math.floor(nCoins / obK) % obK
        local s5 = math.floor(nCoins) % obK
        return string.format("%d,%03d,%03d,%03d,%03d%s", s1, s2, s3, s4, s5, strF)
    end
end

-- 当前人物经验百分比
function bole:getExpPercent()
    local curlevel = self:getUserDataByKey("level")
    local levels = self:getConfigCenter():getConfig("level")
    if not levels["" .. curlevel] then
        return 100
    end
    local expMax = levels["" .. curlevel].exp
    local exp = self:getUserDataByKey("experience")
    if curlevel > 1 then
        expMax = expMax - levels["" .. curlevel - 1].exp
        exp = exp - levels["" .. curlevel - 1].exp
    end
    if exp < 0 then
        exp = 0
    end
    local progress = math.floor(exp / expMax * 100)
    if progress >= 100 then
        progress = progress % 100
    end
    return progress
end

-- 根据url生成一个精灵
function bole:newNetSprite(url, tag)
    if not tag then
        tag = -1
    end
    local sp = bole:getEntity("app.command.NetSprite", url, tag)
    return sp
end

function bole:getUrlMd5(url)
    local tempMd5 = cc.UrlImage:getInstance():getMd5(url)
    local file = device.writablePath .. tempMd5 .. ".png"
    local isNewFile = cc.FileUtils:getInstance():isFileExist(file)
    return isNewFile, file
end
-- 获取网络图片回调返回路径和 tag
function bole:getUrlImage(url, tag, func)
    if not tag then
        tag = -1
    end
    local isExist, fileName = self:getUrlMd5(url)
    if isExist then
        -- 如果存在，直接回调
        if func then
            func(fileName, tag)
        end
    else
        -- 如果不存在，启动http下载
        local function HttpRequestCompleted(statusCode, tagNum, image)
            print("图片数据请求结果 statusCode:" .. statusCode .. "  tag:" .. tagNum)
            if statusCode == 200 then
                image:saveToFile(fileName)
                if func then
                    func(fileName, tagNum)
                end
            end

        end
        cc.UrlImage:getInstance():requestUrlImage(url, HttpRequestCompleted, tag)
    end
end

-- 绑定子类node继承父类透明度和颜色变化
function bole:autoOpacityC(node)
    local childs = node:getChildren()
    for _, v in ipairs(childs) do
        self:autoOpacityC(v)
    end
    self:setOpacityC(node, true)
end
function bole:setOpacityC(node, enable)
    if not node then return end
    node:setCascadeColorEnabled(enable)
    node:setCascadeOpacityEnabled(enable)
end
-- 获得主题下资源路径
function bole:getThemePath(theme_id, file)
    local newFile = "theme/theme" ..(theme_id) .. "/" .. file
    print("------------------newFile:" .. newFile)
    local isNewFile = cc.FileUtils:getInstance():isFileExist(newFile)
    if isNewFile then
        print("----------------isNewFile=true------------")
        return newFile
    else
        return file
    end
end

-- 秒数转化为小时分钟
function bole:timeFormat(s)
    local h = math.ceil(s / 3600)
    local m = math.ceil((s % 3600) / 60)
    return h .. "h. " .. m .. "m"
end

-- releaseMode == 1, 则在release模式下也会弹这个对话框
function bole:alert(title, content, releaseMode)
    if releaseMode and type(releaseMode) == "number" then
        if releaseMode > 0 then
            releaseMode = 1
        else
            releaseMode = 0
        end
        self.showMessageBox(content, title, releaseMode)
    else
        self.showMessageBox(content, title)
    end
end
-- 默认10秒
function bole:toWait(timeout)
    if not timeout then timeout = 10 end
    self:getUIManage():toWait(timeout)
end
function bole:closeWait()
    self:getUIManage():closeWait()
end

-- 是否开启全局update循环
function bole:setUpdate(isLoop)
    if isLoop then
        if not self.schedulerID then
            local scheduler = cc.Director:getInstance():getScheduler()
            self.schedulerID = scheduler:scheduleScriptFunc(self.update, 0.1, false)
        end
    else
        if self.schedulerID then
            local scheduler = cc.Director:getInstance():getScheduler()
            scheduler:unscheduleScriptEntry(self.schedulerID)
            self.schedulerID = nil
        end
    end
end
function bole:update(dt)
    -- ui循环
    -- bole:getUIManage():updateWaitTime()
end
-- endregion
