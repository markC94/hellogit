--region *.lua
--Date
--此文件由[BabeLua]插件自动生成
local MiniGameBase =class("MiniGameBase",cc.Node)
local openActTime=1.5
function MiniGameBase:ctor(data,name,feature_id)
    if data then
        self.collect_coin_pool=data.collect_coin_pool
    end
    self.cells_row=1
    self.feature_id = feature_id
    self.name_=name
    self.click_index=nil
    self:initUI()
    self:init()
    self:openAct(data)
end

function MiniGameBase:initUI()
    local windowSize = cc.Director:getInstance():getWinSize()
    self.mask= bole:getUIManage():getNewMaskUI(self.name_)
    self.mask:setPosition(cc.p(windowSize.width / 2, windowSize.height / 2))
    self:addChild(self.mask)

    local path= bole:getSpinApp():getMiniRes(nil,"mini_game/MiniGame.csb")
    self.csbNode = cc.CSLoader:createNodeWithVisibleSize(path)
    self.csbAct = cc.CSLoader:createTimeline(path)

    self.csbNode:runAction(self.csbAct)
    self:addChild(self.csbNode)
    self.csbAct:gotoFrameAndPause(0)
    self:initView()
end

function MiniGameBase:initView()

end

function MiniGameBase:init()
    self:registerScriptHandler( function(tag)
        if "enter" == tag then
            self:onEnter()
        elseif "exit" == tag then
            self:onExit()
        end
    end )
end

function MiniGameBase:onEnter()
    bole:getBoleEventKey():addKeyBack(self)
    bole:addListener(self.name_, self.updateBaseUI, self, nil, true)

end
function MiniGameBase:onExit()
    bole:getBoleEventKey():removeKeyBack(self)
    bole:getEventCenter():removeEventWithTarget(self.name_, self)
end

function MiniGameBase:openAct(data)
    bole:autoOpacityC(self)
    self:setOpacity(0)
    self:runAction(cc.FadeIn:create(openActTime))
    performWithDelay(self, function()
        bole:getAudioManage():playFeatureForKey(self.feature_id, "feature_bgm")
        self:startGame(data)
    end , openActTime)
end

function MiniGameBase:onKeyBack()
   
end

function MiniGameBase:startGame(data)
    
    if not data then
        self:newGame()
        return
    end

    if #data == 0 then
        self:newGame()
        return
    end
    self:continueGame(data)
end

--接收服务器消息
function MiniGameBase:updateBaseUI(data)
    data=data.result
    dump(data,self.name_..":updateUI")
    local index=self.click_index
    self.click_index=nil
    if not data then return end
    if not data.status then return end
    self:nextStep(data,index)
    self:updateUI(data,index)
end

function MiniGameBase:updateUI(data,index)

end

--根据服务器消息下一步
function MiniGameBase:nextStep(data,index)
    if data.status == "START" then
       self:recvStart(data,index)
    elseif data.status == "OPEN" then
       self:recvStep(data,index)
    elseif data.status == "CLOSED" then
       self:recvOver(data,index)
    end
end

-----------子类可能用到的方法 start----------------
--小游戏开始
--加入可点击元素( 必须调用 )
function MiniGameBase:addCell(node,index,row)
    if not row then
        row=self.cells_row
    end
    
    if not self.cells then
        self.cells={}
    end
    if not self.cells[row] then
        self.cells[row]={}
    end
    self.cells[row][index]=node
end
--点击开始按钮 默认没有开始界面自动调用
function MiniGameBase:sendStart()
    if self.click_index then
        return
    end
    self.click_index=0
    bole:getMiniGameControl():minigame_start()
end
--点开箱子 下一步
function MiniGameBase:sendStep(index)
    if self.click_index then
        return
    end

    if self.isGameOver then
        return
    end

    self.click_index=index

    if not self.cells[self.cells_row] or not self.cells[self.cells_row][index] then
        return
    end

    self.cells[self.cells_row][index]:toClick()
    bole:getMiniGameControl():miniGame_step(index)
end

--结束当前步方法
function MiniGameBase:overStep()
    --如果是继续游戏则进行下一步
    if self.click_index == -1 then
        self.continueIndex = self.continueIndex + 1
        if self.continueIndex > self.continueMax then
            self.click_index = nil
            return
        end
        local data = self.continueData[self.continueIndex]
        local index=data.position
        self:updateUI(data,index)
        if index ~=0 then
            self.cells[self.cells_row][index]:toClick()
        end
        self:nextStep(data,index)
    end
end
--开始新的游戏
function MiniGameBase:newGame()
    self:sendStart()
end
--断线重连 默认自动调用下一步
function MiniGameBase:continueGame(data)
    self.continueData = data
    self.continueIndex=0
    self.continueMax=#data
    self.click_index=-1
    self:overStep()
end

--结束游戏 加金币并且退出界面
function MiniGameBase:collectOver(coins)
    bole:getAppManage():addCoins(coins)
    bole:postEvent("next_data", { isDeal = true})
    bole:postEvent("next_miniGame")
    bole:autoOpacityC(self)
    self:setOpacity(255)
    self:runAction(cc.FadeOut:create(1.5))
    performWithDelay(self, function()
        bole:getAudioManage():stopFeatureForKey(self.feature_id, "feature_bgm")
        self:removeFromParent()
    end , openActTime)
end

function MiniGameBase:clearSelect()
    self.selects=nil
end
--收到开始信息
function MiniGameBase:recvStart(data,index)
   self:overStep() 
end
--收到下一步信息
function MiniGameBase:recvStep(data,index)
   if not self.selects then
        self.selects={}
   end
   self.selects[#self.selects + 1] = index
   local feature_type=bole:getMiniGameControl():getFeatureType(self.feature_id)
   if feature_type==5 then
       self.cells[self.cells_row][index]:recvClick(data.minigame_content)
   elseif feature_type==2 then
       self.cells[self.cells_row][index]:recvClick(data.collection_content)
   end
   self:overStep()
end
--收到结束信息
function MiniGameBase:recvOver(data,index)
    self.isGameOver=true
    self:recvStep(data,index)
    self:showOver(data,index)
    bole:postEvent("miniEndPopup")
end
--展示结束界面
function MiniGameBase:showOver(data,index)
    
end

-----------子类可能用到的方法 over----------------
return MiniGameBase
--endregion
