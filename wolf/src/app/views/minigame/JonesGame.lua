-- region *.lua
-- Date
-- 此文件由[BabeLua]插件自动生成
local JonesGame = class("JonesGame", cc.Node)
local JONES_BEGIN = 1
local JONES_OPEN = 2
local JONES_OVER = 3
local count = { 10, 12, 0, 15, 10, 15, 12, 25, 0, 10 }
function JonesGame:ctor(data)
    self.index = -1
    self.delayTime = 0
    self.isDelayTpe = 0
    schedule(self, self.updateWaitTime, 0.1)
    self:init()
    self.continueData = data
    self.isContinue = 0
    self.isAnimate = false
    if data then
        dump(data, "JonesGame:ctor")
        if #data == 0 then
            self.continueData = nil
            self:showGame()
        else
            print("JonesGame:ctor----------------------------------")
            self.isContinue = 1
            self:showGame()
        end
    else
        self:showSpin()
    end
end



function JonesGame:init()
    self:registerScriptHandler( function(tag)
        if "enter" == tag then
            self:onEnter()
        elseif "exit" == tag then
            self:onExit()
        end
    end )
end
function JonesGame:onEnter()
    bole:addListener("JonesGame", self.updateUI, self, nil, true)

end
function JonesGame:onExit()
    bole:getEventCenter():removeEventWithTarget("JonesGame", self)
end

function JonesGame:updateUI(event)
    local data = event.result
    if not data then
        return
    end
    self:isSpin(data)
    self:conitnue(data)
end

function JonesGame:isSpin(data)
    if not data.chose then
        return
    end

    if data.chose == 0 then
        self.index = 10
    else
        self.index = data.chose
    end
    bole:getAudioManage():playEff("w4")
    self.Button_1:setBright(false)
    self.Button_1:setTouchEnabled(false)
    self.isDelayTpe = 0
    self:rotaAction()
end

function JonesGame:updateWaitTime()
    if self.isDelayTpe == 0 then
        return
    end
    self.delayTime = self.delayTime + 0.1
    if self.isDelayTpe == 1 then
        if self.delayTime > 3 then
            self.delayTime = 0
            self.skeletonNode1:setVisible(true)
            self.skeletonNode1:setAnimation(0, "animation", false)
        end
    end
end
function JonesGame:showSpin()

    performWithDelay(self, function()
        bole:getAudioManage():playEff("w2")
    end , 0.5)
    local windowSize = cc.Director:getInstance():getWinSize()
    self.mask= bole:getUIManage():getNewMaskUI("PayTable")
    self.mask:setPosition(cc.p(windowSize.width / 2, windowSize.height / 2))
    self:addChild(self.mask)

    self.isDelayTpe = 1
    self.delayTime = 0
    local path= bole:getSpinApp():getMiniRes(nil,"mini_spin/MiniSpin.csb")
    self.spinNode = cc.CSLoader:createNodeWithVisibleSize(path)

    self.spinAction = cc.CSLoader:createTimeline(path)
    self.spinNode:runAction(self.spinAction)
    self.spinAction:play("start",false)
    self:addChild(self.spinNode)

    self.node_start = self.spinNode:getChildByName("node_start")
    self.rota_1 = self.node_start:getChildByName("nei")
    self.rota_2 = self.node_start:getChildByName("wai")
    self.rota_3 = self.node_start:getChildByName("jiagou")

    --    self.node_collect = self.spinNode:getChildByName("node_collect")
    --    self.node_collect:setVisible(false)
    self.Button_1 = self.node_start:getChildByName("Button_1")
    self.Button_1:addTouchEventListener(handler(self, self.touchEvent))

    local node_eff_1 = self.node_start:getChildByName("node_eff_1")
    local node_eff_2 = self.node_start:getChildByName("node_eff_2")
    local node_eff_3 = self.node_start:getChildByName("node_eff_3")

    self.skeletonNode1 = sp.SkeletonAnimation:create("util_act/saoguang.json", "util_act/saoguang.atlas")
    node_eff_1:addChild(self.skeletonNode1, 1)
    self.skeletonNode1:setBlendFunc( { src = 770, dst = 1 })
    self.skeletonNode2 = sp.SkeletonAnimation:create("util_act/xuanzhong.json", "util_act/xuanzhong.atlas")
    node_eff_2:addChild(self.skeletonNode2, 1)
    self.skeletonNode2:setBlendFunc( { src = 770, dst = 1 })
    self.skeletonNode3 = sp.SkeletonAnimation:create("util_act/yuanpan.json", "util_act/yuanpan.atlas")
    node_eff_3:addChild(self.skeletonNode3, 1)
    self.skeletonNode3:setBlendFunc( { src = 770, dst = 1 })
    self.skeletonNode2:setVisible(false)
    self.skeletonNode1:setVisible(false)
    self.skeletonNode3:setVisible(false)
    --    self.skeletonNode1:setAnimation(0, "animation", true)
    --    self.skeletonNode2:setAnimation(0, "animation", true)
    --    self.skeletonNode3:setAnimation(0, "animation", true)
    self.skeletonNode1:setScale(1.6)
    self.skeletonNode2:setScale(1.8)
    self.skeletonNode3:setScale(1.6)

    performWithDelay(self, function()
        self.skeletonNode1:setVisible(true)
        self.skeletonNode1:setAnimation(0, "animation", false)
    end , 1.5)
    
end

function JonesGame:spin()
    bole:getMiniGameControl():minigame_start()
--     self:isSpin({chose=1})
end

function JonesGame:rotaAction()
    bole:getAudioManage():playMusic("w3",true)
    self.rota_1:setRotation(0)
    self.rota_2:setRotation(0)
    self.rota_3:setRotation(0)
    self.skeletonNode2:setVisible(false)
    self.skeletonNode1:setVisible(false)
    self.skeletonNode3:setVisible(false)
    local sp1 = cc.EaseExponentialOut:create(cc.RotateBy:create(6.0, - self.index * 36 - 1080))
    local sp2 = cc.EaseExponentialOut:create(cc.RotateBy:create(6.0, - self.index * 36 - 1080))
    local sp3 = cc.EaseExponentialOut:create(cc.RotateBy:create(6.0, - self.index * 36 - 1080))
    self.rota_1:runAction(sp1)
    self.rota_2:runAction(sp2)
    self.rota_3:runAction(sp3)
    performWithDelay(self, function()
        self:gotoView()
    end , 6.0)
end


function JonesGame:gotoView()
    performWithDelay(self, function()
        self.skeletonNode2:setVisible(true)
        self.skeletonNode2:setOpacity(0)
        self.skeletonNode2:runAction(cc.FadeIn:create(0.5))
        self.skeletonNode2:setAnimation(0, "animation", true)
        bole:getAudioManage():playEff("w5")
    end , 0.8)

    bole:getAudioManage():stopAudio("w3")

    self.skeletonNode3:setVisible(true)
    self.skeletonNode3:setAnimation(0, "animation", false)
    
    print("self.index:" .. self.index)
    self.spinAction:play("select",false)
    performWithDelay(self, function()
        self.spinAction:play("end",false)
        bole:getAudioManage():playEff("w6")
    end , 1.7+0.5)

    performWithDelay(self, function()
        if self.spinNode then
            self.spinNode:removeFromParent()
            self.spinNode = nil
        end
        if count[self.index] == 0 then
            self:showGame()
        else
            self:showDialog()
        end

    end , 2.3+0.5)

end

function JonesGame:showDialog()
    print("showDialog:" .. self.index)
    if self.index == 1 or self.index == 6 then
        bole:getMiniGameControl():freeSpinJonesStart(count[self.index],true)
    else
        bole:getMiniGameControl():freeSpinJonesStart(count[self.index])
    end
    self:removeFromParent()
end

function JonesGame:showGame()
    bole:getAudioManage():playMusic("s2", true)
    self.level = 1
    self.clickIndex = 1
    self.isDelayTpe = 0
    self.delayTime = 0
    local path= bole:getSpinApp():getMiniRes(nil,"mini_game/MiniGame.csb")
    self.gameNode = cc.CSLoader:createNode(path)
    self.gameNodeAct = cc.CSLoader:createTimeline(path)
    self.gameNode:runAction(self.gameNodeAct)
    self.gameNodeAct:gotoFrameAndPlay(0, 105, false)
    self:addChild(self.gameNode)
    local director = cc.Director:getInstance()
    local view = director:getOpenGLView()
    local framesize = view:getFrameSize()
    self.node_1 = self.gameNode:getChildByName("node_1")
    self.node_2 = self.gameNode:getChildByName("node_2")
    self.node_3 = self.gameNode:getChildByName("node_3")
    self.node_1:setVisible(false)
    self.node_2:setVisible(false)
    self.node_3:setVisible(false)

    local director = cc.Director:getInstance()
    local view = director:getOpenGLView()
    local framesize = view:getFrameSize()
    local dessize = view:getDesignResolutionSize()
    local factor = director:getContentScaleFactor()

    local factor = dessize.height / 720
    local factor2 = dessize.width / 1200
    if factor < factor2 then
        self.gameNode:setScale(factor2)
        self.gameNode:setPosition((dessize.width - 1200 * factor2) * 0.5 - 27,(dessize.height - 720 * factor) * 0.5)
    else
        self.gameNode:setScale(factor)
        self.gameNode:setPosition((dessize.width - 1200 * factor) * 0.5 - 27,(dessize.height - 720 * factor) * 0.5)
    end


    self.node_1:setVisible(true)
    self.node_lock1 = self.node_1:getChildByName("node_lock")
    self.node_lock2 = self.node_2:getChildByName("node_lock")
    self.node_door1 = self.node_1:getChildByName("node_door")
    self.node_door2 = self.node_2:getChildByName("node_door")

    self.lock_1 = sp.SkeletonAnimation:create("util_act/yaoshi.json", "util_act/yaoshi.atlas")
    self.node_lock1:addChild(self.lock_1, 1)
    self.door_1 = sp.SkeletonAnimation:create("util_act/men.json", "util_act/men.atlas")
    self.node_door1:addChild(self.door_1, 1)

    self.lock_2 = sp.SkeletonAnimation:create("util_act/yaoshi.json", "util_act/yaoshi.atlas")
    self.node_lock2:addChild(self.lock_2, 1)
    self.door_2 = sp.SkeletonAnimation:create("util_act/men.json", "util_act/men.atlas")
    self.node_door2:addChild(self.door_2, 1)

    self.door_2:setVisible(false)
    self.lock_2:setScale(0.8)
    self.door_2:setScale(1.5)
    self.door_2:setPosition(0, -25)

    self.door_1:setVisible(false)
    self.lock_1:setScale(0.8)
    self.door_1:setScale(1.5)
    self.door_1:setPosition(0, -25)
    self.cells = { { }, { }, { } }


    self.mulit = { { }, { }, { },{ }}
    self.mulit[1][1] = self.node_1:getChildByName("x2")
    self.mulit[1][2] = self.node_1:getChildByName("x3")
    self.mulit[1][3] = self.node_1:getChildByName("x6")
    self.mulit[2][1] = self.node_2:getChildByName("x2")
    self.mulit[2][2] = self.node_2:getChildByName("x3")
    self.mulit[2][3] = self.node_2:getChildByName("x6")
    self.mulit[3][1] = self.node_3:getChildByName("x2")
    self.mulit[3][2] = self.node_3:getChildByName("x3")
    self.mulit[3][3] = self.node_3:getChildByName("x6")

    self.mulit[1][4] = self.node_1:getChildByName("x1")
    self.mulit[2][4] = self.node_2:getChildByName("x1")
    self.mulit[3][4] = self.node_3:getChildByName("x1")
    self:restMulit()

    self.mulit[1][4]:setVisible(true)
    self.mulit[2][4]:setVisible(true)
    self.mulit[3][4]:setVisible(true)
    local ren = self.node_1:getChildByName("ren")
    for i = 1, 5 do
        local ren_cell = ren:getChildByName("ren_" .. i)
        local touch = ren_cell:getChildByName("touch_" .. i)
        touch:setTouchEnabled(true)
        touch:addTouchEventListener(handler(self, self.touchEvent))
        local label = ren_cell:getChildByName("label")
        self.cells[1][i] = ren_cell
        label:setString(999999)
        self:changeCell(i, 1, JONES_BEGIN)
        
    end
    local ren2 = self.node_2:getChildByName("ren")
    for i = 1, 4 do
        local ren_cell = ren2:getChildByName("ren_" .. i)
        local touch = ren_cell:getChildByName("touch_" .. i)
        touch:setTouchEnabled(true)
        touch:addTouchEventListener(handler(self, self.touchEvent))
        local label = ren_cell:getChildByName("label")
        self.cells[2][i] = ren_cell
        label:setString(999999)
        self:changeCell(i, 2, JONES_BEGIN)
    end
    local ren3 = self.node_3:getChildByName("ren")
    for i = 1, 3 do
        local ren_cell = ren3:getChildByName("ren_" .. i)
        local touch = ren_cell:getChildByName("touch_" .. i)
        touch:setTouchEnabled(true)
        touch:addTouchEventListener(handler(self, self.touchEvent))
        local label = ren_cell:getChildByName("label")
        self.cells[3][i] = ren_cell
        label:setString(999999)
        self:changeCell(i, 3, JONES_BEGIN)
    end
    if self.isContinue == 0 then
        self.isAnimate = true
        bole:getMiniGameControl():minigame_start()
    else
        performWithDelay(self, function()
            self:nextContine()
        end , 2)
    end
end
function JonesGame:restMulit()
    self.mulit[1][1]:setVisible(false)
    self.mulit[1][2]:setVisible(false)
    self.mulit[1][3]:setVisible(false)
    self.mulit[2][1]:setVisible(false)
    self.mulit[2][2]:setVisible(false)
    self.mulit[2][3]:setVisible(false)
    self.mulit[3][1]:setVisible(false)
    self.mulit[3][2]:setVisible(false)
    self.mulit[3][3]:setVisible(false)
    self.mulit[1][4]:setVisible(false)
    self.mulit[2][4]:setVisible(false)
    self.mulit[3][4]:setVisible(false)
end
function JonesGame:nextContine()
    if self.isContinue == 0 then
        return
    end

    self.isAnimate = true
    local data = self.continueData[self.isContinue]
    self.clickIndex = data.position
    self:conitnue(data)
    self.isContinue = self.isContinue + 1
    if self.isContinue > #self.continueData then
        self.isContinue = 0
    end
end

function JonesGame:conitnue(data)
    if not data then return end
    dump(data, "continue---")
    if not data.hp then
        self.isAnimate = false
        return
    end
   
    if data.status == "START" then
        self.isAnimate = false
    elseif data.status == "OPEN" then
        self:changeCell(self.clickIndex, data.minigame_content, JONES_OPEN,data.featrue_multiplier)
        performWithDelay(self, function()
            local index = 1
            dump(data.minigame_other_content, "data.minigame_other_content")
            dump(self.cells[self.level], "self.cells[self.level]")
            for i = 1, #self.cells[self.level] do

                if i == self.clickIndex then

                else
                    self:changeCell(i, data.minigame_other_content[index], JONES_OVER)
                    index = index + 1
                end
            end
        end , 0.5)
    elseif data.status == "CLOSED" then
        self:changeCell(self.clickIndex, data.minigame_content, JONES_OPEN)
        performWithDelay(self, function()
            local index = 1
            for i = 1, #self.cells[self.level] do
                if i == self.clickIndex then

                else
                    self:changeCell(i, data.minigame_other_content[index], JONES_OVER)
                    index = index + 1
                end
            end
        end , 0.5)
        performWithDelay(self, function()
            self:showOver(data)
        end , 2)
    end
end

function JonesGame:changeCell(index, data, status,featrue_multiplier)
    local level = self.level
    if status == JONES_BEGIN then
        level = data
    end
    if data then
        print("changeCell data:" .. data)
    end

    local cell = self.cells[level][index]
    local label = cell:getChildByName("label")
    local ren_hui = cell:getChildByName("ren_hui")
    local ren = cell:getChildByName("ren")

    local key_hui = cell:getChildByName("key_hui")
    local key = cell:getChildByName("key")
    
    local x2_hui = cell:getChildByName("x2_hui")
    local x2 = cell:getChildByName("x2")
    local x3_hui = cell:getChildByName("x3_hui")
    local x3 = cell:getChildByName("x3")
    local x6_hui = cell:getChildByName("x6_hui")
    local x6 = cell:getChildByName("x6")
    if level ~= 3 then
            key:setScale(0.8)
            key_hui:setScale(0.8)
            key_hui:setVisible(false)
            key:setVisible(false)
            x2_hui:setVisible(false)
            x2:setVisible(false)
            x3_hui:setVisible(false)
            x3:setVisible(false)
            x6_hui:setVisible(false)
            x6:setVisible(false)
    end
    if status == JONES_BEGIN then
        label:setVisible(false)
        ren:setVisible(true)
        bole:toLight(ren)
        ren_hui:setVisible(false)
        return
    end

    if status == JONES_OPEN then
        if level ~= 3 then
            key_hui:setVisible(false)
            key:setVisible(true)
            local mulit
            if data == -2 then
                bole:getAudioManage():playEff("w11")
                x2:setVisible(true)
                mulit=x2
            elseif data == -3 then
                bole:getAudioManage():playEff("w11")
                x3:setVisible(true)
                mulit=x3
            elseif data == -6 then
                bole:getAudioManage():playEff("w11")
                x6:setVisible(true)
                mulit=x6
            else
                bole:getAudioManage():playEff("w12")
                label:setVisible(true)
                label:setString("$".. bole:formatCoins(data,8))
                key:setVisible(false)
            end

            if mulit then
                performWithDelay(cell, function()
                    self:flyKey(key,mulit,featrue_multiplier)
                end , 0.5)
            end
        else
            label:setVisible(true)
            label:setString("$".. bole:formatCoins(data,8))
        end
        ren:setVisible(true)
        ren:setOpacity(50)
        ren_hui:setVisible(false)
        bole:clearLight(ren)
        return
    end
    if status == JONES_OVER then
        if level ~= 3 then
            key_hui:setVisible(true)
            key:setVisible(false)
            if data == -2 then
                x2_hui:setVisible(true)
            elseif data == -3 then
                x3_hui:setVisible(true)
            elseif data == -6 then
                x6_hui:setVisible(true)
            else
                label:setVisible(true)
                label:setColor(cc.c3b(100, 100, 100))
                label:setString("$".. bole:formatCoins(data,8))
                key_hui:setVisible(false)
            end
        else
            label:setVisible(true)
            label:setColor(cc.c3b(100, 100, 100))
            label:setString("$".. bole:formatCoins(data,8))
        end
        bole:clearLight(ren)
        ren:setVisible(false)
        ren_hui:setVisible(true)
        return
    end
end
function JonesGame:changeMulit(featrue_multiplier)
    self:restMulit()
    if featrue_multiplier == 2 then
        self:restMulit()
        self.mulit[self.level][1]:setVisible(true)
        if self.level ~= 3 then
            self.mulit[self.level + 1][1]:setVisible(true)
        end
    elseif featrue_multiplier == 3 then
        self:restMulit()
        self.mulit[self.level][2]:setVisible(true)
        if self.level ~= 3 then
            self.mulit[self.level + 1][2]:setVisible(true)
        end
    elseif featrue_multiplier == 6 then
        self:restMulit()
        self.mulit[self.level][3]:setVisible(true)
        if self.level ~= 3 then
            self.mulit[self.level + 1][3]:setVisible(true)
        end
    else
        self.mulit[1][4]:setVisible(true)
        self.mulit[2][4]:setVisible(true)
        self.mulit[3][4]:setVisible(true)
    end
end

function JonesGame:flyKey(key, mulit, data)
    if self.level == 3 then
        return
    end
    local poslock
    local posMulitEnd
    if self.level == 1 then
        poslock =self.lock_1:getParent():convertToWorldSpace(cc.p(self.lock_1:getPosition()))
        posMulitEnd =self.mulit[1][4]:getParent():convertToWorldSpace(cc.p(self.mulit[1][4]:getPosition()))
    else
        poslock =self.lock_2:getParent():convertToWorldSpace(cc.p(self.lock_2:getPosition()))
        posMulitEnd =self.mulit[1][4]:getParent():convertToWorldSpace(cc.p(self.mulit[1][4]:getPosition()))
    end
    local pos = key:getParent():convertToNodeSpace(poslock)
    local exIn = cc.EaseExponentialIn:create(cc.MoveTo:create(1.0, pos))
    key:runAction(exIn)

    local posMulit = mulit:getParent():convertToWorldSpace(cc.p(mulit:getPosition()))
    local newMuli = display.newSprite(mulit:getTexture())
    display.getRunningScene():addChild(newMuli, bole.ZORDER_UI)
    newMuli:setPosition(posMulit)

    local pos2 = newMuli:getParent():convertToNodeSpace(posMulitEnd)
    local exIn2 = cc.EaseExponentialIn:create(cc.MoveTo:create(1.0, cc.p(pos2)))
    newMuli:runAction(exIn2)
    newMuli:setScale(1.3)
    mulit:setVisible(false)
    bole:getAudioManage():playEff("w13")
    performWithDelay(key, function()
        self:changeMulit(data)
        key:setVisible(false)
        newMuli:removeFromParent()
        bole:getAudioManage():playEff("w13")
        if self.level == 1 then
            self.lock_1:setVisible(true)
            self.lock_1:setAnimation(0, "animation", false)
            performWithDelay(self, function()
                bole:getAudioManage():playEff("w14")
            end , 1.5)
        else
            self.lock_2:setVisible(true)
            self.lock_2:setAnimation(0, "animation", false)
            performWithDelay(self, function()
                bole:getAudioManage():playEff("w14")
            end , 1.5)
        end
        self:nextGame()
    end , 1.1)
end

function JonesGame:clickCell(index)
    if self.isAnimate then
        print("self.isAnimate...-----------------------true")
        return
    end
    if self.isContinue ~= 0 then
        print("self.isContinue...-----------------------:" .. self.isContinue)
        return
    end
    bole:getAudioManage():playEff("w10")
    self.isAnimate = true
    self.clickIndex = index
    print("JonesGame:clickCell:" .. index)
    local s1=cc.ScaleTo:create(0.2,1.1)
    local s2=cc.ScaleTo:create(0.1,1.0)
    local func=cc.CallFunc:create(function()
        bole:getMiniGameControl():miniGame_step(index)
    end)
    local cell=self.cells[self.level][index]
    local ren = cell:getChildByName("ren")
    ren:runAction(cc.Sequence:create(s1,s2,func))
    
end
function JonesGame:nextGame()

    if self.level == 1 then
        performWithDelay(self, function()
            bole:getAudioManage():playEff("w15")
            self.door_1:setVisible(true)
            self.door_1:runAction(cc.FadeOut:create(1.5))
            self.door_1:setAnimation(0, "animation", false)
            self.gameNodeAct:gotoFrameAndPlay(105, 185, false)
        end , 3.2)
        performWithDelay(self, function()
            self.node_1:setVisible(false)
            self.node_2:setVisible(true)
            self.level = self.level + 1
            self.gameNodeAct:gotoFrameAndPlay(20, 105, false)
            bole:getAudioManage():stopAudio("s2")
            bole:getAudioManage():playMusic("s3", true)
        end , 4.4)
        performWithDelay(self, function()
            if self.isContinue ~= 0 then
                self:nextContine()
            else
                self.isAnimate = false
            end
        end , 5.4)

    elseif self.level == 2 then
        performWithDelay(self, function()
            bole:getAudioManage():playEff("w15")
            self.door_2:setVisible(true)
            self.door_2:setAnimation(0, "animation", false)
            self.gameNodeAct:gotoFrameAndPlay(105, 185, false)
        end , 3.2)
        performWithDelay(self, function()
            self.node_2:setVisible(false)
            self.node_3:setVisible(true)
            self.level = self.level + 1
            self.gameNodeAct:gotoFrameAndPlay(20, 105, false)
            bole:getAudioManage():stopAudio("s3")
            bole:getAudioManage():playMusic("s4", true)
        end , 4.4)
        performWithDelay(self, function()
            print("------------------------------------1:" .. self.isContinue)
            if self.isContinue ~= 0 then
                print("------------------------------------2")
                self:nextContine()
            else
                print("------------------------------------3")
                self.isAnimate = false
            end
        end , 5.4)
    elseif self.level == 3 then
        self.level = self.level + 1
        self:gameOver()
    end
end
function JonesGame:showOver(data)
    bole:getAppManage():addCoins(data.minigame_win)
    local path= bole:getSpinApp():getMiniRes(nil,"free_spin/FSLayer.csb")
    self.csbNode = cc.CSLoader:createNodeWithVisibleSize(path)
    self.csbAct = cc.CSLoader:createTimeline(path)
    self.csbNode:runAction(self.csbAct)
    local root = self.csbNode:getChildByName("root")
    self.node_start = root:getChildByName("node_start")
    self.node_collect = root:getChildByName("node_collect")
    self.node_start_weild = root:getChildByName("node_start_weild")
    self.node_more = root:getChildByName("node_more")
    self.node_start_weild:setVisible(false)
    self.node_more:setVisible(false)
    self.node_start:setVisible(false)
    self.node_collect:setVisible(false)
    self:addChild(self.csbNode)
    self:initOver(data)
end

function JonesGame:initOver(data)
    self.node_collect:setVisible(true)
    self.csbAct:play("start", false)
    local bg = self.node_collect:getChildByName("bg")
    local btn_collect = bg:getChildByName("btn_collect")
    btn_collect:addTouchEventListener(handler(self, self.touchEvent))
    local label_coins = bg:getChildByName("label_coins")
    label_coins:setString(bole:formatCoins(data.minigame_win,9))
    bole:getAudioManage():playFeatureForKey(self.feature_id, "feature_end")
    bole:flash(btn_collect,"free_spin/ui/anniu2.png")
    self:addTitleEff(bg)
end

function JonesGame:addTitleEff(bg)
    local Node_1 = bg:getChildByName("Node_1")
    self.skeletonOver = sp.SkeletonAnimation:create("util_act/congratylaions.json", "util_act/congratylaions.atlas")
    Node_1:addChild(self.skeletonOver, 1)
    self.skeletonOver:setBlendFunc( { src = 770, dst = 1 })

    performWithDelay(self, function()
        self.skeletonOver:setAnimation(0, "animation", false)
    end , 1)
end
function JonesGame:gameOver()
    bole:postEvent("next_data", { isDeal = true})
    bole:postEvent("next_miniGame")
    bole:getAudioManage():stopAudio("s2")
    bole:getAudioManage():stopAudio("s3")
    bole:getAudioManage():stopAudio("s4")
    bole:getAudioManage():stopAudio("w3")
    self:removeFromParent()
end

function JonesGame:touchEvent(sender, eventType)
    local name = sender:getName()
    local tag = sender:getTag()
    print("touchEvent:" .. name)
    if eventType == ccui.TouchEventType.began then
        print("Touch Down")
    elseif eventType == ccui.TouchEventType.moved then
        print("Touch Move")
    elseif eventType == ccui.TouchEventType.ended then
        print("Touch Up")
        if name == "Button_1" then
            self:spin()
            self.Button_1:setBright(false);
            self.Button_1:setTouchEnabled(false);
        end
        if name == "touch_1" then
            self:clickCell(1)
        elseif name == "touch_2" then
            self:clickCell(2)
        elseif name == "touch_3" then
            self:clickCell(3)
        elseif name == "touch_4" then
            self:clickCell(4)
        elseif name == "touch_5" then
            self:clickCell(5)
        elseif name == "btn_collect" then
            self:gameOver()
        end
    elseif eventType == ccui.TouchEventType.canceled then
        print("Touch Cancelled")
    end
end

return JonesGame
-- endregion
