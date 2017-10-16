-- region *.lua
-- Date
-- 此文件由[BabeLua]插件自动生成

local LobbyScrollHead = class("LobbyScrollHead")
--大厅陌生人头像
local START_POS = cc.p(326, 419)  -- 初始坐标 270 287 281 281
local WIDTH = 183                 -- 宽度间隔
local HEIGHT = 177                -- 高度间隔
local MAX = 27                    -- 缓存数量
local INDEX_OFF_X = 1334          -- 索引偏移量
local BOUNDARY_OFF_X = 30        -- 边界偏移量
function LobbyScrollHead:ctor(content)
    self.recommend_users = bole.recommend_users
    self.recommend_max = #self.recommend_users
    self.data_max=#self.recommend_users
    self.content = content
    self.curIndex = 0
    self.targetIndex = 0
    self.position = 0
    self.dir = 0
    self:initHead()
    schedule(content, handler(self, self.updateBigWin), 1)
    schedule(content, handler(self, self.updateChat), 5)
    self.randList={}
    for i = 1, self.data_max do
        self.randList[i] = i
    end
end

function LobbyScrollHead:setHeadCount(count)
    if count>=#self.recommend_users then
        self.recommend_max = #self.recommend_users
    else
        self.recommend_max=count
    end
    self:resetMax()
end

function LobbyScrollHead:resetMax()
    local childs = self.content:getChildren()
    local i=1
    for _, head in ipairs(childs) do
        self:changeHeadVisible(head)
    end
end

function LobbyScrollHead:getMaxHeadCount()
    return #self.recommend_users
end
--边界值
function LobbyScrollHead:getMaxPos()
    return WIDTH* math.ceil(self.recommend_max/3)+BOUNDARY_OFF_X
end
-- 大厅bigwin
function LobbyScrollHead:updateBigWin()
    local rand = math.random(1, self.data_max)
    local childs = self.content:getChildren()
    for _, v in ipairs(childs) do
        if v:getTag() == rand then
            v:showBigWin(1)
            return
        end
    end
end
--大厅聊天动画
function LobbyScrollHead:updateChat()
    local num=10
    bole:randSort(self.randList)
    local childs = self.content:getChildren()
    for _, v in ipairs(childs) do
        for i = 1, num do
            if v:getTag() == self.randList[i] then
                v:setRandomShowChat()
                break
            end
        end
    end
end
--初始化头像
function LobbyScrollHead:initHead()
    for i = 1, MAX do
        local data = self.recommend_users[i]
        local head = bole:getNewHeadView(data)
        head:setTag(i)
        head:updatePos(head.POS_NONE)
        head:setSwallow(false)
        head:setScale(1)
        head:setPosition(cc.p(START_POS.x - WIDTH * math.floor((i - 1) / 3), START_POS.y - HEIGHT *((i - 1) % 3)))
        self.content:addChild(head)
    end
end
--重置头像到初始位置
function LobbyScrollHead:reset()
    local childs = self.content:getChildren()
    local i=1
    for _, head in ipairs(childs) do
        local data = self.recommend_users[i]
        head:updateInfo(data)
        head:setTag(i)
        head:setPosition(cc.p(START_POS.x - WIDTH * math.floor((i - 1) / 3), START_POS.y - HEIGHT *((i - 1) % 3)))
        i=i+1
    end
end
--刷新头像逻辑
function LobbyScrollHead:step(position)
    self.dir = self.position - position
    self.position = position
    local index = self:getLeftIndex(position)
    if self.targetIndex == index then
        return
    end
    self:updateShowHead(index)
end

function LobbyScrollHead:getLeftIndex(cur_x)
    local index = math.ceil((cur_x - INDEX_OFF_X-BOUNDARY_OFF_X) / WIDTH-1)
    if index < 0 then
        return 0
    else
        return index
    end
end

function LobbyScrollHead:updateShowHead(index)
    if self.curIndex == index then
        self.targetIndex=self.curIndex
        return
    end
    self.targetIndex=index
    print("---------------------------------self.curIndex="..self.curIndex)
    if self.dir < 0 then
        self:moveLeft()
    else
        self:moveRight()
    end
end

function LobbyScrollHead:moveLeft()
    self.curIndex=self.curIndex+1
    for i = 1, 3 do
        local curIndex = i + 3 *(self.curIndex - 1)
        local newIndex = MAX + curIndex
        if newIndex <= self.data_max then
            self:changeHeadForIndex(curIndex, newIndex)
        end
    end
    self:updateShowHead(self.targetIndex)
end

function LobbyScrollHead:moveRight()
    self.curIndex=self.curIndex-1
    for i = 1, 3 do
        local curIndex = MAX + self.curIndex * 3 +i
        local newIndex = i + 3 *(self.curIndex)
        if newIndex >= 1 then
            self:changeHeadForIndex(curIndex, newIndex)
        end
    end
    self:updateShowHead(self.targetIndex)
end

function LobbyScrollHead:changeHeadForIndex(curIndex, NewIndex)
    print("changeHeadForIndex  =" .. curIndex .. "--" .. NewIndex)
    local node = self.content:getChildByTag(curIndex)
    if not node then
        return
    end
    local data = self.recommend_users[NewIndex]
    node:updateInfo(data)
    node:setTag(NewIndex)
    node:setPosition(cc.p(START_POS.x - WIDTH * math.floor((NewIndex - 1) / 3), START_POS.y - HEIGHT *((NewIndex - 1) % 3)))
    self:changeHeadVisible(node)
end
function LobbyScrollHead:changeHeadVisible(head)
    if head:getTag() <= self.recommend_max then
        if not head:isVisible() then
            head:setScale(0.1)
            head:runAction(cc.ScaleTo:create(0.3, 1))
            head:setVisible(true)
        end
    else
        head:setVisible(false)
    end
end
return LobbyScrollHead
-- endregion
