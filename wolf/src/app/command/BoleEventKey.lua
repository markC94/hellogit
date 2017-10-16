--region *.lua
--Date
--此文件由[BabeLua]插件自动生成
local  BoleEventKey =class("BoleEventKey")
function  BoleEventKey:ctor()
    self.KeyBacks={}
end
function BoleEventKey:getKeyBack(isRemove)
    local count=#self.KeyBacks
    if  count<=0 then
        return
    end
    if isRemove then
        return table.remove(self.KeyBacks)
    else
        return self.KeyBacks[count]
    end
end

function BoleEventKey:onKeyBack()
    local item=self:getKeyBack()
    if item then
        if item.onKeyBack then
           item:onKeyBack()
        else
           --删除无用返回键寻找下一个
           self:removeKeyBack()
           self:onKeyBack()
        end
    end
end

function BoleEventKey:addKeyBack(item)
    self:removeKeyBack(item)
    table.insert(self.KeyBacks, item)
end

function BoleEventKey:removeKeyBack(item)
    if #self.KeyBacks == 0 then
        return
    end

    if item then
        return table.removebyvalue(self.KeyBacks, item)
    else
        return table.remove(self.KeyBacks)
    end
end

function BoleEventKey:clearKeyBack()
    self.KeyBacks={}
end
return BoleEventKey
--endregion
