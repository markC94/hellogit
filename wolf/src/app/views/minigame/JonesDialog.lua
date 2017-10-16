-- region *.lua
-- Date
-- 此文件由[BabeLua]插件自动生成
local JonesDialog = class("JonesDialog", bole:getTable("app.views.minigame.FreeSpinDialog"))
function JonesDialog:ctor(name,feature_id)
    JonesDialog.super.ctor(self,name,feature_id)
    self.feature_id=feature_id
    self.name_=name
    self.node_start_weild = self.root:getChildByName("node_start_weild")
    self.node_more = self.root:getChildByName("node_more")
    self.node_start_weild:setVisible(false)
    self.node_more:setVisible(false)
end

function JonesDialog:updateUI(data)
    dump(data, "JonesDialog:updateUI")
    data = data.result
    if not data.msg then return end
    self.chose = data.chose
    if data.msg == "more" then
        self:initMore(self.chose[1])
        performWithDelay(self, function()
           self:toStart()
       end , 2)
    elseif data.msg == "start" then
        if self.chose[2] then
            self:initStartWild(self.chose[1])
        else
            self:initStart(self.chose[1])
        end
        bole:getAudioManage():playMusic("fs", true)
        if data.autoSpinning then
            performWithDelay(self, function()
                self:toStart()
            end , 6)
        end
    elseif data.msg == "over" then
       self:initOver(self.chose)
       if data.autoSpinning then
            performWithDelay(self, function()
                self:toOver()
            end , 6)
        end
    end
end


function JonesDialog:initMore(num)
    self.node_more:setVisible(true)
    self.csbAct:play("start", false)
    local bg = self.node_more:getChildByName("bg")
    local label_count = bg:getChildByName("label_count")
    label_count:setString(num)
end

function JonesDialog:initStart(num)
    self.node_start:setVisible(true)
    self.csbAct:play("start", false)
    local bg = self.node_start:getChildByName("bg")
    local btn_start = bg:getChildByName("btn_start")
    btn_start:addTouchEventListener(handler(self, self.touchEvent))
    local label_count = bg:getChildByName("label_count")
    label_count:setString(num)

    bole:getAudioManage():playFeatureForKey(self.feature_id,"feature_resource")
    bole:flash(btn_start,"free_spin/ui/anniu2.png")
    self:addTitleEff(bg)
end

function JonesDialog:initStartWild(num)
    self.node_start_weild:setVisible(true)
    self.csbAct:play("start", false)
    local bg = self.node_start_weild:getChildByName("bg")
    local btn_start = bg:getChildByName("btn_start")
    btn_start:addTouchEventListener(handler(self, self.touchEvent))
    local label_count1 = bg:getChildByName("label_count1")
    label_count1:setString(num)
    local label_count2 = bg:getChildByName("label_count2")
    label_count2:setString(2)
    bole:getAudioManage():playFeatureForKey(self.feature_id,"feature_resource")
    bole:flash(btn_start,"free_spin/ui/anniu2.png")
    self:addTitleEff(bg)
end

function JonesDialog:initOver(chose)
    self.node_collect:setVisible(true)
    self.csbAct:play("start", false)
    local bg = self.node_collect:getChildByName("bg")
    local btn_collect = bg:getChildByName("btn_collect")
    btn_collect:addTouchEventListener(handler(self, self.touchEvent))
    local label_coins = bg:getChildByName("label_coins")
    label_coins:setString(chose[2])
    bole:getAudioManage():playFeatureForKey(self.feature_id, "feature_end")
    bole:flash(btn_collect,"free_spin/ui/anniu2.png")
    self:addTitleEff(bg)
end
function JonesDialog:addTitleEff(bg)
    local Node_1 = bg:getChildByName("Node_1")
    self.skeletonOver = sp.SkeletonAnimation:create("util_act/congratylaions.json", "util_act/congratylaions.atlas")
    Node_1:addChild(self.skeletonOver, 1)
    self.skeletonOver:setBlendFunc( { src = 770, dst = 1 })

    performWithDelay(self, function()
        self.skeletonOver:setAnimation(0, "animation", false)
    end , 1)
end

return JonesDialog
-- endregion
