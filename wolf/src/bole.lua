-- region *.lua
-- Date
-- 此文件由[BabeLua]插件自动生成

bole.requireTable = { }
bole.instanceTable = { }

-- 层级 使用位置：display.getRunningScene():addChild(XXXX,bole.ZORDER_XXX)
bole.ZORDER_ACT = 300 -- 最高层  活动的弹框（只活动中用）
bole.ZORDER_TOP = 500-- 对话框 公告 系统提示
bole.ZORDER_NET = 9999 -- 断线重连
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

function bole:getBoleEventKey()
    return self:getInstance("app.command.BoleEventKey")
end

function bole:getFacebookCenter()
    return self:getInstance("app.controls.FacebookControl")
end

function bole:initBuyCenter()
    return self:getInstance("app.controls.BuyControl")
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

function bole:getActCenter()
    return self:getInstance("app.controls.ActCenterControl")
end

function bole:getNewbieCenter()
    return self:getInstance("app.controls.NewbieControl")
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

function bole:getClubManage()
    return self:getInstance("app.manage.ClubManage")
end

function bole:getChatManage()
    return self:getInstance("app.manage.ChatManage")
end

function bole:getBuyManage()
    return self:getInstance("app.manage.BuyManage")
end

function bole:getFriendManage()
    return self:getInstance("app.manage.FriendManage")
end

-- 获得一个新的队列
function bole:newBoleList(startPos,errorCode)
    return bole:getEntity("app.command.BoleList",startPos,errorCode)
end

function bole:getCsbNode(fileName, isAutoSize)
    if isAutoSize then
        return cc.CSLoader:createNodeWithVisibleSize(fileName)
    else
        return cc.CSLoader:createNode(fileName)
    end
end

-- 弹出一个对话框
-- msg 信息 title 标题 cancle是否有取消按钮 func按钮回调
-- data={msg=nil,title=nil,cancle=false} 都可以为空
function bole:popMsg(data, funcOK, funcNo)
    local pop = bole:getEntity("app.command.DialogLayer", data, funcOK, funcNo)
    display.getRunningScene():addChild(pop, bole.ZORDER_TOP)
    return pop
end

-- 获得一个新头像实例 data=nil获取self数据
function bole:getNewHeadView(data)
    return bole:getEntity("app.command.HeadView", data)
end

-- 主题下载

function bole:checkDownLoadTheme()
    for k,v in ipairs(bole.DownLoadThemes) do
       bole:postEvent("LobbyCell",{theme_id=v,msg="waiting"})
    end
    if bole.isThemeDoading_id then
        bole:postEvent("LobbyCell",{theme_id=bole.isThemeDoading_id,msg="downLoad"})
        bole:postEvent("LobbyCell",{theme_id=bole.isThemeDoading_id,msg="updateProgress",progress=bole.downLoad_theme_num,max=bole.downLoad_theme_max})
    end
end

function bole:downLoadTheme(themeid)
    if bole.isThemeDoading_id then
        bole.DownLoadThemes[#bole.DownLoadThemes+1]=themeid
        bole:postEvent("LobbyCell",{theme_id=themeid,msg="waiting"})
    else
        bole.isThemeDoading_id=themeid
        bole:postEvent("LobbyCell",{theme_id=themeid,msg="downLoad"})
        local function update(msg)
            bole:updateProgress(msg)
        end
        bole.downLoad_theme_num = 0
        bole.downLoad_theme_max = bole:getSpinApp():downloadTheme(themeid,update)
--        bole.downLoad_theme_max=10
--        bole:updateProgress()
--        bole:updateProgress()
--        bole:updateProgress()
--        bole:updateProgress()
   end
end

function bole:updateProgress(msg)
    if msg == "all" then
        bole.downLoad_theme_num=0
        bole.downLoad_theme_max=0
        bole:postEvent("LobbyCell",{theme_id=bole.isThemeDoading_id})
        bole:nextDownLoad()
    else
        bole.downLoad_theme_num=bole.downLoad_theme_num+1
        bole:postEvent("LobbyCell",{theme_id=bole.isThemeDoading_id,msg="updateProgress",progress=bole.downLoad_theme_num,max=bole.downLoad_theme_max})
    end
end

function bole:nextDownLoad()
    if not bole.isThemeDoading_id then
        return
    end
    bole.isThemeDoading_id=nil
    local count=#bole.DownLoadThemes
    if count>0 then
        local themeid=table.remove(bole.DownLoadThemes,1)
        bole:downLoadTheme(themeid)
    end
end

-- 主题删除
function bole:removeTheme(themeid)
    self:getSpinApp():removeTheme(themeid)
    bole:postEvent("LobbyCell",{theme_id=themeid,msg="remove"})
end

-- 主题是否下载
function bole:isDownLoadTheme(themeid)
    return self:getSpinApp():isThemeDownloaded(themeid)
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

function bole:getRoundImg(user_id)
    local isExist, fileName = self:getHeadMd5(user_id)
    if isExist then
        return display.newSprite(fileName)
    end
end

function bole:jumpNode(node, endTime, endCallback)
    -- 文字跳动

    if node.isJumpInit then
        node:setPosition(node.JumpPosX, node.JumpPosY)
        node:setScale(node.JumpScale)
    else
        node.isJumpInit = true
        node.JumpPosX, node.JumpPosY = node:getPosition()
        node.JumpScale = node:getScale()
    end
    local time = 0.0666
    local time2 = 0.1666
    local updateTime = 0
    local oldX, oldY = node:getPosition()
    local oldScale = node:getScale()
    local jumpTime = 0
    local function update(dt)
        if updateTime >= endTime then
            node:unscheduleUpdate()
            if endCallback then
                endCallback()
            end
            return
        end
        updateTime = updateTime + dt
        jumpTime = jumpTime + dt
        if jumpTime >= time2 then
            jumpTime = jumpTime - time2
            node:setScale(oldScale)
            node:setPosition(oldX, oldY)
        elseif jumpTime >= time then
            node:setPosition(oldX - 1.47, oldY + 1.73)
            node:setScale(oldScale * 1.015)
        end
    end
    node:onUpdate(update)
end
-- @label 文本标签cc.Label
-- @startValue 可以为空，默认会从label里取出
-- @endValue 最终的值
-- @useTime 所用的时间 可以为空，默认1s
-- @endCallback 结束时的回调，可以为空
-- @data 是否为bole:formatCoins数字data={限制大小,是否添加分隔符} 例 data={5},data={12,true})，可以为空
-- @jsJump 是否抖动，可以为空
-- @char 前置符号 例如 数字前面的$
function bole:runNum(label, startValue, endValue, useTime, endCallback, data, jsJump,char)
    if not useTime then
        useTime = 1
    end
    if not char then
       char=""
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

    local delayIndex = 0



    if label.isJumpInit then
        label:setPosition(label.JumpPosX, label.JumpPosY)
        label:setScale(label.JumpScale)
    else
        label.isJumpInit = true
        label.JumpPosX, label.JumpPosY = label:getPosition()
        label.JumpScale = label:getScale()
    end


    -- 文字跳动
    local time = 0.0666
    local time2 = 0.1666
    local oldX, oldY = label:getPosition()
    local oldScale = label:getScale()
    local jumpTime = 0


    local function update(dt)
        if spendTime >= useTime then
            label:unscheduleUpdate()
            if data then
                label:setString(char..bole:formatCoins(endValue, data[1], data[2], data[3]))
            else
                label:setString(char..endValue)
            end
            if endCallback then
                endCallback()
            end
            return
        end

        spendTime = spendTime + dt

        if delayIndex < 2 then
            delayIndex = delayIndex + 1
            return
        end
        delayIndex = 0
        if spendTime >= useTime then
            if data then
                label:setString(char..bole:formatCoins(endValue, data[1], data[2], data[3]))
            else
                label:setString(char..endValue)
            end
        else
            if data then
                label:setString(char..bole:formatCoins(startValue + math.floor(addValuePerSecond * spendTime), data[1], data[2], data[3]))
            else
                label:setString(char..startValue + math.floor(addValuePerSecond * spendTime))
            end
        end
        if jsJump then
            -- 数字跳远
            jumpTime = jumpTime + dt
            if jumpTime >= time2 then
                jumpTime = jumpTime - time2
                label:setScale(oldScale)
                label:setPosition(oldX, oldY)
            elseif jumpTime >= time then
                label:setPosition(oldX - 1.47, oldY + 1.73)
                label:setScale(oldScale * 1.015)
            end
        end
    end
    label:onUpdate(update)
end

-- bole:formatCoins(数值,限制大小,是否添加分隔符','}
-- obligate:保留位数 限制大小  notCut=true（不添加分隔符'.'）
-- 例:bole:formatCoins(999999.99,2)   = 0.9M
-- bole:formatCoins(999999.99,4)      = 999.9K
-- bole:formatCoins(999999.99,6)      = 999,999
-- bole:formatCoins(999999.99,6,true) = 999999
-- bole:formatCoins(999999.99,7)      = 999,999
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
function bole:getExpPercent(exp)
    local curlevel = self:getUserDataByKey("level")
    local levels = self:getConfigCenter():getConfig("level")
    if not levels["" .. curlevel] then
        return 100
    end
    local expMax = levels["" .. curlevel].exp
    if not exp then
        exp = self:getUserDataByKey("experience")
    end
    
    if curlevel > 1 then
        expMax = expMax - levels["" .. curlevel - 1].exp
        exp = exp - levels["" .. curlevel - 1].exp
    end
    if exp < 0 then
        exp = 0
    end
    local progress = math.floor(exp / expMax * 100)
--    if progress >= 100 then
--        progress = progress % 100
--    end
    return progress
end

-- 上传个人信息
function bole:uploadUserInfo()
    print("bole:uploadUserInfo")
    local data = bole:getUserData()
    local newInfo = { icon = data.icon, signature = data.signature, name = data.name, age = data.age, gender = data.gender, marital_status = data.marital_status, country = data.country, city = data.city }
    bole:getUserData():setData(newInfo)
    bole.socket:send(bole.SERVER_MODIFY_USER, newInfo)
    bole:postEvent("eventInfo", data)
end

-- 根据url生成一个精灵 默认是圆形图片
function bole:newNetSprite(url, isLocal)
    local sp = bole:getEntity("app.command.NetSprite", url, isLocal)
    return sp
end

-- 加载游戏头像 isLocal=是否使用缓存头像
function bole:loadUserHead(user_id, isLocal, callback)
    bole:getUrlImage("http://s3.amazonaws.com/bolegames/wolf/" .. user_id, isLocal, callback)
end

function bole:getUrlMd5(url)
    local tempMd5 = cc.UrlImage:getInstance():getMd5(url)
    local file = device.writablePath .. "pub/head/" .. tempMd5
    local isNewFile = cc.FileUtils:getInstance():isFileExist(file)
    return isNewFile, file
end
function bole:getHeadMd5(url)
    local tempMd5 = cc.UrlImage:getInstance():getMd5(url)
    local path = device.writablePath .. "pub/head"
    local file = path .. "/" .. tempMd5 .. ".png"
    local isNewFile = cc.FileUtils:getInstance():isFileExist(file)
    return isNewFile, file
end

-- 获取网络图片回调返回路径和 tag


function bole:getUrlImage(url, isLocal, func)
    print("url=:" .. url)
    local isExist, fileName
    -- 使用DownLoadFile还是http
    local isDownLoad = false

    if isDownLoad then
        isExist, fileName = self:getUrlMd5(url)
    else
        isExist, fileName = self:getHeadMd5(url)
    end

    -- 这里是否使用本地文件
    if isLocal then
        if isExist then
            -- 如果存在，直接回调
            if func then
                func(fileName, 6)
            end
            return
        end
    end



    if isDownLoad then
        local downLoad = cc.DownLoadFile:create(url)
        local function downloadCallback(eventCode, content)
            if eventCode == 6 then
                -- 下载成功
                if func then
                    func(fileName, eventCode)
                end
            else
                if func then
                    func("error", eventCode)
                end
            end
        end
        downLoad:addEventListener(downloadCallback)
        downLoad:startUpdate()
    else
        -- 如果不存在，启动http下载 status==1（保存本地） status==2 （加入缓存） status==3（ 保存本地并加入缓存）
        local function HttpRequestCompleted(statusCode, status)
--            if statusCode == 200 then
--                if func then
--                    func(fileName, 6)
--                end
--            else
--                if func then
--                    func("error", -2)
--                end
--            end
            bole.popHttpFunc(url, fileName, statusCode)
        end
        local status = 3
        if bole.getHttpFunc(url) == 0 then
            bole.setHttpFunc(url, func)
            cc.UrlImage:getInstance():requestUrlImage(url, HttpRequestCompleted, status)
        else
            bole.setHttpFunc(url, func)
        end

    end
end

function bole.clearHttpFunc(url, all)
    if bole.http_url_funcs[url] then
        bole.http_url_funcs[url] = { }
    end
    if all then
        bole.http_url_funcs = { }
    end
end

function bole.setHttpFunc(url, func)
    if not bole.http_url_funcs[url] then
        bole.http_url_funcs[url] = { }
    end
    bole.http_url_funcs[url][#bole.http_url_funcs[url] + 1] = func
end

function bole.getHttpFunc(url)
    if not bole.http_url_funcs[url] then
        return 0
    end
    return #bole.http_url_funcs[url]
end

function bole.popHttpFunc(url, fileName, statusCode)
    if not bole.http_url_funcs[url] then
        return
    end
        for k, func in ipairs(bole.http_url_funcs[url]) do
            if statusCode == 200 then
                if func then
                    func(fileName, 6)
                end
            else
                if func then
                    func("error", -2)
                end
            end
        end
    bole.clearHttpFunc(url)
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
--清理光效
function bole:clearLight(node)
    if not node then return end
    if node._light then
         node._light:removeFromParent()
         node._light=nil
    end
end
--添加光效 结点 闪烁速度  顺序
function bole:toLight(node,speed,zorder)
    if not node then return end
    local data
    local fx
    local fy
   
    if tolua.type(node)== "sp.SkeletonAnimation" then
        return
    end

    if tolua.type(node)=="cc.Sprite" then 
        data=node:getTexture()
        fx=node:isFlippedX()
        fy=node:isFlippedY()
    else
        print("tolua.type(node)="..tolua.type(node))
        local new_node=node:getVirtualRenderer()
        if new_node then
            local new_Sprite=new_node:getSprite()
            if new_Sprite then
                data=new_Sprite:getTexture()
                 fx=new_Sprite:isFlippedX()
                 fy=new_Sprite:isFlippedY()
            end
        end
    end
    if not data then
        return
    end
    if not zorder then
        zorder=1
    end
    if not speed then
        speed=1
    end
    local sp_light=display.newSprite(data)
    sp_light:setBlendFunc( { src = 770, dst = 1 })
    node:addChild(sp_light,zorder)
    sp_light:setFlippedX(fx)
    sp_light:setFlippedY(fy)
    sp_light:setPosition(node:getContentSize().width/2,node:getContentSize().height/2)
    local seq=cc.Sequence:create(cc.FadeOut:create(speed),cc.FadeIn:create(speed))
    local req=cc.RepeatForever:create(seq)
    sp_light:runAction(req)
    node._light=sp_light
end

function bole:flash(node,maskPath)
    local clip_node = cc.ClippingNode:create()
    local path= bole:getSpinApp():getMiniRes(nil,maskPath)
    local mask = display.newSprite(path)
    mask:setScale(0.9)
    clip_node:setAlphaThreshold(0)
    clip_node:setStencil(mask)
    node:addChild(clip_node)
    local w,h=node:getContentSize().width/2,node:getContentSize().height/2
    clip_node:setPosition(w,h)
    local sp = display.newSprite("common/common_flash.png")
    clip_node:addChild(sp)
    sp:setPosition(-200,0)
    local m1=cc.MoveTo:create(1,cc.p(250,0))
    local m2=cc.MoveTo:create(1,cc.p(250,-300))
    local m3=cc.MoveTo:create(1,cc.p(-200,-300))
    local m4=cc.MoveTo:create(1,cc.p(-200,0))

    local seq=cc.Sequence:create(m1,m2,m3,m4)
    local rep=cc.RepeatForever:create(seq)
    sp:runAction(rep)
    sp:setBlendFunc( { src = 770, dst = 1 })
end


-- node 控件 time 时间 scale缩放值(弹起不填)
-- 按下 bole:clickScale(node,0.1,0.9)
-- 弹起 bole:clickScale(node,0.1) or bole:clickScale(node,0.1,nil,function() end)
--node.org_click_delay_time 下次响应点击时间回调时间防止连点默认1秒
function bole:clickScale(node, time, scale, func)
--    if node.org_click_delay_time then
--        return
--    end
    local function boleRunScale(node, time, scale, func)
        local updateTime = 0
        local endTime = time
        local startScale = node:getScale()
        local endScale = scale
        local speed =(endScale - startScale) / time
        local function update(dt)
--            if node.org_click_delay_time then
--                node.org_click_delay_time=node.org_click_delay_time-dt
--                if node.org_click_delay_time<=0 then
--                    node.org_click_delay_time=nil
--                end
--                return
--            end
            if updateTime >= endTime then
                node:unscheduleUpdate()
                node:setScale(endScale)
                node.org_start = nil
                node.org_over= nil
                if node.org_func then
                    node.org_func()
                    node.org_func = nil
                end
                if func then
--                    node.org_click_delay_time=1
                    func()
                end
                return
            end
            updateTime = updateTime + dt
            node:setScale(startScale + updateTime * speed)
        end
        node:onUpdate(update)
    end

    if not scale then
        if node.org_scale then
            if node.org_start then
                if not node.org_func then
                    node.org_func = function()
                        node.org_over=true
                        boleRunScale(node, time, node.org_scale,func)
                        node.org_scale = nil
                    end
                end
            else
                -- 普通弹起
                node.org_func = nil
                node:unscheduleUpdate()
                node.org_over=true
                boleRunScale(node, time, node.org_scale, func)
                node.org_scale = nil
            end
        end
    else
        if node.org_over then
            return
        end
        if node.org_start then
            return
        end
        if not node.org_scale then
            -- 按下状态时的缩放值
            node.org_scale = node:getScale()
            -- 按下状态
            node.org_start = true
            -- 按下结束回调
            node.org_func = nil
            node:unscheduleUpdate()
            boleRunScale(node, time, node.org_scale * scale)
        end

    end
end

-- table 随即排序
function bole:randSort(rand_table)
    if not rand_table then
        return
    end
    local count = #rand_table
    if count == 0 then
        return
    end
    for i = 1, count do
        local j = math.random(1, count)
        local temp = rand_table[i]
        rand_table[i] = rand_table[j]
        rand_table[j] = temp
    end
end

-- 秒数转化为小时分钟
function bole:timeFormat(s)
    local h = math.ceil(s / 3600)
    local m = math.ceil((s % 3600) / 60)
    return h .. "H  " .. m .. "M"
end

-- 默认10秒
function bole:toWait(timeout)
    if not timeout then timeout = 10 end
    self:getUIManage():toWait(timeout)
end
function bole:closeWait()
    self:getUIManage():closeWait()
end

----游戏暂停
-- local appPause=function()
--    bole.pause_time= os.time()
-- end
----游戏恢复
-- local appResume=function()
--    if bole.pause_time then
--        bole.resume_time=os.time()-bole.pause_time
--    end
-- end
-- cc.exports.appPause=appPause
-- cc.exports.appResume=appResume

-- 是否开启全局update循环 配合倒计时使用
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
-- 客户端倒计时
function bole:update()
    -- 时间间隔
    local delaytime = 0.1
    if bole.resume_time then
        delaytime = delaytime + bole.resume_time
        bole.resume_time = nil
    end
    -- 登录奖励时间倒计时
    if bole.login_bouns_time then
        local collect_data = bole:getUserDataByKey("lobby_bonus")
        if bole.login_bouns_time > 0 then
            bole.login_bouns_time = bole.login_bouns_time - delaytime
            if bole.login_bouns_time < 0 then
                bole.login_bouns_time = 0
            end
            bole:setUserDataByKey("lobby_bonus", { bole.login_bouns_time, collect_data[2] })
        end
    end

    -- 促销倒计时
    if bole.slot_sale_time then
        if bole.slot_sale_time > 0 then
            bole.slot_sale_time = bole.slot_sale_time - delaytime
        end
    end

    -- 更新大厅推荐
    if bole.lobby_update_time then
        if bole.lobby_update_time > 0 then
            bole.lobby_update_time = bole.lobby_update_time - delaytime
        end
    end

    --商店倒计时
    if bole.shop_bonus_time then
        if bole.shop_bonus_time > 0 then
            bole.shop_bonus_time = bole.shop_bonus_time - delaytime
        end
    end

   --忠诚奖励倒计时
    if bole.loyal_surplus_time then
        if bole.loyal_surplus_time > 0 then
            bole.loyal_surplus_time = bole.loyal_surplus_time - delaytime
        end
    end

    --公会任务倒计时
    if bole.clubTask_surplus_time then
        if bole.clubTask_surplus_time > 0 then
            bole.clubTask_surplus_time = bole.clubTask_surplus_time - delaytime
        end
    end
end

function bole:getNodeByName(node, name)
    if node:getName() == name then
        return node
    else
        local child = node:getChildByName(name)
        if child then
            return child
        else
            local children = node:getChildren()
            if children and #children > 0 then
                for _, child in ipairs(children) do
                    local findNode = bole:getNodeByName(child, name)
                    if findNode then
                        return findNode
                    end
                end
            end
        end
    end
end

function bole:strRemove(str, remove)
    local lcSubStrTab = { }
    while true do
        local lcPos = string.find(str, remove)
        if not lcPos then
            lcSubStrTab[#lcSubStrTab + 1] = str
            break
        end
        local lcSubStr = string.sub(str, 1, lcPos - 1)
        lcSubStrTab[#lcSubStrTab + 1] = lcSubStr
        str = string.sub(str, lcPos + 1, #str)
    end
    local lcMergeStr = ""
    local lci = 1
    while true do
        if lcSubStrTab[lci] then
            lcMergeStr = lcMergeStr .. lcSubStrTab[lci]
            lci = lci + 1
        else
            break
        end
    end
    return lcMergeStr
end

-- 分析字符串 目前只判断空
function bole:isStrExists(str)
    str = tostring(str)
    if not str then
        return false
    end
    local lenInByte = #str
    local count = 0
    for i = 1, lenInByte do
        local curByte = string.byte(str, i)
        local byteCount = 1;
        if curByte > 0 and curByte <= 127 then
            byteCount = 1
            if curByte > 47 and curByte <= 58 then
                -- 数字
            elseif curByte > 64 and curByte <= 91 then
                -- 大写字母
            elseif curByte > 96 and curByte <= 123 then
                -- 小写字母
            elseif curByte == 0 or curByte == 32 then
                -- 空格
                count = count + 1
            end
        elseif curByte >= 192 and curByte < 223 then
            byteCount = 2
        elseif curByte >= 224 and curByte < 239 then
            byteCount = 3
        elseif curByte >= 240 and curByte <= 247 then
            byteCount = 4
        else
--            print("isStrExists curByte>247 ----=" .. curByte)
            byteCount = 1
        end
        local char = string.sub(str, i, i + byteCount - 1)
        i = i + byteCount - 1
--        print("isStrExists[" .. i .. "]:" .. char)
    end
    if lenInByte == count then
        return false
    end
    return true
end
-- 在过长字符中间加入'\n'
-- str 字符串 , fontSize 字符大小 , maxLen 每行最大长度
-- 只适用非中文字符串，待优化
function bole:getNewStr(str, fontSize, maxLen)
    str = str or ""
    fontSize = fontSize or 28
    maxLen = maxLen or 446
    local t = string.split(str, " ")
    local newStr = ""
    local label1 = cc.Label:createWithTTF("", "font/bole_ttf.ttf", fontSize)
    for i = 1, #t do
        label1:setString(t[i])
        if label1:getContentSize().width > maxLen then
            local idex = 1
            local time = 0
            local label2 = cc.Label:createWithTTF("", "font/bole_ttf.ttf", fontSize)
            for ii = 1, string.len(t[i]) do
                label2:setString(string.sub(t[i], idex, ii + time))
                local len = label2:getContentSize().width
                if len > maxLen then
                    t[i] = string.sub(t[i], 1, ii + time - 1) .. "\n" .. string.sub(t[i], ii + time, -1)
                    len = 0
                    idex = ii + 1
                    time = time + 1
                end
            end
        end
        if i == 1 then
            newStr = newStr .. t[i]
        else
            newStr = newStr .. " " .. t[i]
        end
    end
    return newStr
end
-- 限制长度缩进 num=限制长度  sign 缩进后代替符号
function bole:limitStr(str, num, sign)
    local _, count = string.gsub(str, "[^\128-\193]", "aa")
    if count > num then
        return string.sub(str, 1, num) .. sign
    else
        return str
    end
end
-- 字符串超过指定长度自动滚动逻辑
function bole:moveStr(label, lenMax)
    if not label then return end
    label:stopAllActions()
    local len = 0
    if tolua.type(node) == "ccui.Text" then
        len = label:getAutoRenderSize().width
    else
        len = label:getContentSize().width
    end
    if len <= lenMax then return end
    local posX, posY = label:getPosition()
    -- 等待时间
    local delayTime = 1
    local space = len - lenMax
    -- 左停留时间
    local timel = 1
    -- 右停留时间
    local timer = 0.5
    local speed = 50
    local moveTime = space / speed
    local left_x = posX - len * 0.5 + lenMax * 0.5
    local right_x = posX + len * 0.5 - lenMax * 0.5
    local fristTime =(space - lenMax * 0.5) / speed
    label:setPosition(right_x, posY)
    fristTime = 0
    --    label:runAction(cc.Sequence:create(cc.DelayTime:create(delayTime), cc.MoveTo:create(fristTime, cc.p(left_x, posY))))
    performWithDelay(label, function()
        local moveL = cc.MoveTo:create(moveTime, cc.p(left_x, posY))
        local moveR = cc.MoveTo:create(moveTime, cc.p(right_x, posY))
        --        local sp = cc.Sequence:create(moveR, cc.DelayTime:create(timer), moveL, cc.DelayTime:create(timel))
        local sp = cc.Sequence:create(moveL, cc.DelayTime:create(timel), moveR, cc.DelayTime:create(timer))
        label:runAction(cc.RepeatForever:create(sp))
    end , delayTime + fristTime + timel)
end 

-- @param "2017/07/05 05:44:30"
-- @return 1499051070
function bole:string2time(tiemStr)
    if tiemStr == nil or tiemStr == "" then
        return 0
    end
    local key = { "year", "month", "day", "hour", "min", "sec" }
    local index = 1
    local timeTable = { }
    for v in string.gmatch(tiemStr, "%d+") do
        timeTable[key[index]] = v
        index = index + 1
    end
    return os.time(timeTable)
end

function bole:getTodaySurplusTime(tiemStr)
    local index = 1
    local time = 0
    for v in string.gmatch(tiemStr, "%d+") do
        if index == 4 then
            time = time + v * 3600
        elseif index == 5 then
            time = time + v * 60
        elseif index == 6 then
            time = time + v
        end
        index = index + 1
    end
    return math.max(0,86400 - time)
end

function bole:refreshCoinsAndDiamondInSlot()
    if self:getSpinApp():isThemeAlive() then 
        local syncUserInfo = self:getUserData():getSyncUserInfo()
        if syncUserInfo ~= nil then
            local coins = syncUserInfo.coins
            local diamond = syncUserInfo.diamond
            self:setUserDataByKey("coins",coins)
            self:setUserDataByKey("diamond",diamond)
            self:postEvent("putWinCoinToTop", { coin = coins })
            self:postEvent("changeDiamond_topView",diamond)
        end
    end
end

--是否解锁全部主题
function bole:isLockAllTheme()
    return self:getBuyManage():isunlock()
end

function bole:sendMsg(cmd, data)
    bole.socket:send(cmd, data)
end

function bole:registerCmd(cmd, callbackFunc, target)
    bole.socket:registerCmd(cmd, callbackFunc, target)
end

function bole:setTestUser()
    release_print("bole:setTestUser")
    if not BOLE_TEST_USER then
        BOLE_TEST_USER = true
        setDebugForPrint(3)
        local instance = cc.UserDefault:getInstance()
        instance:setIntegerForKey(KEY_OF_TEST_USER, 1)
        instance:flush()
    end
    bole:popMsg({msg = "You can test the update.", title = "tips"})
end

function bole:removeTestUser()
    release_print("bole:removeTestUser")
    if BOLE_TEST_USER then
        BOLE_TEST_USER = false
        local instance = cc.UserDefault:getInstance()
        instance:deleteValueForKey(KEY_OF_TEST_USER)
        instance:flush()
    end
    bole:popMsg({msg = "You cancelled the test update.", title = "tips"})
end

-- endregion
