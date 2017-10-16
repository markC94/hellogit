--region *.lua
--Date
--此文件由[BabeLua]插件自动生成

local Theme_longhorn = class("Theme_longhorn", bole:getTable("app.theme.BaseTheme"))

function Theme_longhorn:ctor(themeId, app)
    print("Theme_longhorn:ctor")
    Theme_longhorn.super.ctor(self, themeId, app)
    self.weild_index={1,1,1,1,1}
    self.weild_list={}
    self.weild_anim_list={}
end

function Theme_longhorn:onDataFilter(data)
    print("Theme_longhorn:onDataFilter")
    if data then
        self.weild_index={1,1,1,1,1}
        self.weild_list={}
        self.weild_anim_list={}

        if data.fast_cash then
            local pos=1
            local anim_index=1
            for colum,cell in ipairs(data.view_reels) do
                self.weild_list[colum]={}
                self.weild_anim_list[colum]={}
                local count=0
                for row,id in ipairs(cell) do
                    if id ==0 or id==13 then
                        count=count+1
                        self.weild_anim_list[colum][row]=data.fast_cash[anim_index]*self:getCurBetValue()
                        anim_index=anim_index+1
                    end
                end
                local index=1
                for i=1,count do
                    local num=pos+count-i
                    self.weild_list[colum][index]=data.fast_cash[num]*self:getCurBetValue()
                    index=index+1
                end
                pos=pos+count
            end
        end
    end
    Theme_longhorn.super.onDataFilter(self, data)
end

local function genOneLabel()
--    local label = cc.Label:createWithTTF("0", "font/bole_ttf.ttf", 45)
--    label:setTextColor(cc.c3b(255, 255, 255))
--    label:enableShadow(cc.c4b(0, 0, 0, 255), {width = -1, height = - 2}, 0)
--    label:enableOutline(cc.c4b(255, 255, 255, 255), 1)
    local label = cc.LabelBMFont:create("", "common_fnt/ziti0405.fnt") 
    label:setScale(0.45)
    return label
end

local function runLabelAct(label)
    local sp1 = cc.ScaleTo:create(0.6, 0.52)
    local sp2 = cc.DelayTime:create(0.2)
    local sp3 = cc.ScaleTo:create(0.6, 0.45)
    local seq = cc.Sequence:create(sp1, sp2, sp3)
    label:runAction(cc.RepeatForever:create(seq))
end

function Theme_longhorn:createAnimNode(column, row, key, loop, isHideSymRunning, isHideAnimEnd, endCallback)
    local node, sp = Theme_longhorn.super.createAnimNode(self, column, row, key, loop, isHideSymRunning, isHideAnimEnd, endCallback)

    local symbolId = self.stopReels[column][row]
    local label = node:getChildByName("weild_name")
    if symbolId == 0 or symbolId == 13 then
        if not label then
            label = genOneLabel()
            label:setName("weild_name")
            node:addChild(label)
        end
        label:setPosition(0,0)
        label:setString("$"..bole:formatCoins(self.weild_anim_list[column][row], 3))
        runLabelAct(label)
    elseif label then
        label:removeFromParent(true)
    end

    --中weild 时win音效 这里先特殊处理
    if symbolId==2 or symbolId == 0 or symbolId == 13 then
        bole:getAudioManage():setWeild(true)
    end

    return node,sp
end

function Theme_longhorn:onMiniEffect(data)
    print("Theme_longhorn:onMiniEffect")
    Theme_longhorn.super.onMiniEffect(self, data)

    for column, item in ipairs(self.stopReels) do
        for row, symbolId in ipairs(item) do
            if symbolId == 0 or symbolId == 13 then
                local node = self:getAnimNodeByPos(column, row)
                if not node then
                    self:createAnimNode(column, row, "trigger", true, true, false)
                end
            end
        end
    end
end

function Theme_longhorn:setWeildNum(label,colum)
    if not colum then
        return
    end
    local weild_num=10
    if self.weild_list[colum] and #self.weild_list[colum]>=self.weild_index[colum] then
        weild_num=self.weild_list[colum][self.weild_index[colum]]
        self.weild_index[colum]=self.weild_index[colum]+1
    end 
    label:setString("$"..bole:formatCoins(weild_num,3))
end

function Theme_longhorn:getSymbolInfo(info)
    local isNew = Theme_longhorn.super.getSymbolInfo(self, info)
    local sp = info.node

    local label = sp:getChildByTag(3)
    if info.symbol == 0 or info.symbol == 13 then --添加分数
        if not label then
            label = genOneLabel()
            sp:addChild(label, 3, 3)
        end
        self:setWeildNum(label, info.colum)

        label:setPosition(sp:getContentSize().width/2, sp:getContentSize().height/2)
    elseif label then
        label:removeFromParent(true)
    end
    return isNew
end

function Theme_longhorn:addOtherAsyncImage(weights)
    table.insert(weights, self.app:getSymbolAnimImg(self.themeId, "longhorn_tishi"))
    table.insert(weights, self.app:getSymbolAnimImg(self.themeId, "longhorn_run2"))
    table.insert(weights, self.app:getSymbolAnimImg(self.themeId, "longhorn_run3"))
    table.insert(weights, self.app:getSymbolAnimImg(self.themeId, "longhorn_run4"))
end

return Theme_longhorn

--endregion
