-- region *.lua
-- Date
-- 此文件由[BabeLua]插件自动生成

local LobbyStarAct = class("LobbyStarAct", cc.Node)
--大厅背景动画
function LobbyStarAct:ctor()
    self.bgActs = { }
    for i = 1, 21 do
        local node_act = sp.SkeletonAnimation:create("common_act/datinglizi_1.json", "common_act/datinglizi_1.atlas")
        self:addChild(node_act)
        self.bgActs[i] = node_act
        node_act:setPosition(-500,-500)
    end
    self.delayTime = 1
    self.bg_act_index = 0
    local function update(dt)
        self:updateTime(dt)
    end
    self:onUpdate(update)
end

function LobbyStarAct:runAct()
    local act_names = { "dian", "xingxing1", "xingxing2you", "xingxing2zuo" }
    local act_pos = { cc.p(0, 0), cc.p(444, 0), cc.p(888, 0), cc.p(0, 375), cc.p(444, 375), cc.p(888, 375)}
    for i = 1, 6 do
        local j = math.random(1, 10)
        if j < 6 then
            local temp = act_pos[i]
            act_pos[i] = act_pos[j]
            act_pos[j] = temp
        end
    end
    local index_pos=1
    local name_pos=1
    for i = 1, 3 do
       self:runCell(self.bgActs[i+self.bg_act_index],act_names[1],act_pos[i])
    end
    for i = 4, 6 do
       self:runCell(self.bgActs[i+self.bg_act_index],act_names[2],act_pos[i])
    end
    local rand=math.random(3,4)
    self:runCell(self.bgActs[7+self.bg_act_index],act_names[rand],act_pos[rand])

    if self.bg_act_index == 0 then
        self.bg_act_index = 7
    elseif self.bg_act_index == 7 then
        self.bg_act_index = 14
    else
        self.bg_act_index = 0
    end
end

function LobbyStarAct:runCell(cell,name, pos)
    performWithDelay(self, function()
        cell:setVisible(true)
        cell:setAnimation(0, name, false)
        cell:setPosition(pos.x + math.random(1, 444), pos.y + math.random(1, 375))
    end , math.random(1,5) * 0.1)
end

function LobbyStarAct:updateTime(dt)
    if self.delayTime == -1 then return end
    self.delayTime = self.delayTime - dt
    if self.delayTime <= 0 then
        self.delayTime = 1
        self:runAct()
    end
end
return LobbyStarAct

-- endregion
