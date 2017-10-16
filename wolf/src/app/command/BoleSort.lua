-- region *.lua
-- Date
-- 此文件由[BabeLua]插件自动生成
--[[--
-   partition: 获得快排中介值位置
-   @param: list, low, high - 参数描述
-   @return: pivotKeyIndex - 中介值索引
]]
local BoleSort = class("BoleSort")
function BoleSort:ctor()
    local t = { 5, 2, 5, 4, - 100, 25, 76, - 10, - 100, 46, 5, 2, 5, 4, - 100, 25, 76, - 10, - 100, 46, 5, 2, 5, 4, - 100, 25, 76, - 10, - 100, 46, 5, 2, 5, 4, - 100, 25, 76, - 10, - 100, 46, 5, 2, 5, 4, - 100, 25, 76, - 10, - 100, 46, 5, 2, 5, 4, - 100, 25, 76, - 10, - 100, 46, 5, 2, 5, 4, - 100, 25, 76, - 10, - 100, 46, 5, 2, 5, 4, - 100, 25, 76, - 10, - 100, 46 }
    -- local t = {5,2,5,4}
    local num = table.nums(t)
    self:orderByQuick(t, 1, num)
    --  总结，快拍bushi
--    self:orderByBubbling(t)
    print("after order--------")
    self:printT(t)
end
function BoleSort:swap(t,i,j)
    if not t or not i or not j or not t[i] or not t[j] then
        return
    end
    t[i],t[j]=t[j],t[i]
end
function BoleSort:printT(t)
    print("printT ---------------")
    table.walk(t, function(v, k)
        print(k, v)
    end )
    print("---------------")
end

--[[--
-   orderByBubbling: 冒泡排序
-   @param: t, 
-    @return: list - table
]]
function BoleSort:orderByBubbling(t)
    for i = 1, #t do
        for j = #t, i + 1, -1 do
            if t[j - 1] > t[j] then
                self:swap(t, j, j - 1)
            end
        end
    end
    return t
end

function BoleSort:partition(list, low, high)
    local low = low
    local high = high
    local pivotKey = list[low]
    -- 定义一个中介值

    -- 下面将中介值移动到列表的中间
    -- 当左索引与右索引相邻时停止循环
    while low < high do
        -- 假如当前右值大于等于中介值则右索引左移
        -- 否则交换中介值和右值位置
        while low < high and list[high] >= pivotKey do
            high = high - 1
        end
        self:swap(list, low, high)

        -- 假如当前左值小于等于中介值则左索引右移
        -- 否则交换中介值和左值位置
        while low < high and list[low] <= pivotKey do
            low = low + 1
        end
        self:swap(list, low, high)
    end
    return low
end

--[[--
-   orderByQuick: 快速排序
-   @param: list, low, high - 参数描述
-    @return: list - table
]]
function BoleSort:orderByQuick(list, low, high)
    if low < high then
        -- 返回列表中中介值所在的位置，该位置左边的值都小于等于中介值，右边的值都大于等于中介值
        local pivotKeyIndex = self:partition(list, low, high)
        -- 分别将中介值左右两边的列表递归快排
        self:orderByQuick(list, low, pivotKeyIndex - 1)
        self:orderByQuick(list, pivotKeyIndex + 1, high)
    end
end
return BoleSort

-- endregion
