-- region *.lua
-- Date
-- 此文件由[BabeLua]插件自动生成
local LoadingNode = class("LoadingNode", cc.Node)
function LoadingNode:ctor(data, updateFunc, finishFunc)
    self._baseTextures = { }
    self._baseIndex = 1
    self.updateFunc = updateFunc
    self.finishFunc = finishFunc
    self.progress = 0
    self.newProgress = 0
    self:autoLoading(data)
end
-- 添加资源开始加载
function LoadingNode:autoLoading(data)
    if data then
        local plists = data.plist
        local pngs = data.png
        if plists then
            dump(plists, "autoLoading-plists")
            for _, v in ipairs(plists) do
                self:addLoadingImg(v, true)
            end
        end
        if pngs then
            dump(pngs, "autoLoading-pngs")
            for _, v in ipairs(pngs) do
                self:addLoadingImg(v)
            end
        end
    end
    self:startLoading()
end

-- 添加资源 不需要加后缀 例:self:addLoadingImg("plist/Common",true)
function LoadingNode:addLoadingImg(path, isPlist)
    self._baseTextures[#self._baseTextures + 1] = { path = path, isPlist = isPlist }
end

-- 开始异步加载资源 需要加载完资源调用
function LoadingNode:startLoading()
    dump(self._baseTextures, "self._baseTextures")
    if #self._baseTextures == 0 then
        self:baseFinish()
        return
    end
    self:baseLoadTexture()
end

-- 更新进度 progress[0,100] 文件路径
function LoadingNode:updateLoading(progress, path)
    if self.updateFunc then
        self.updateFunc(progress, path)
    end
end


-- 完成异步加载资源回调函数
function LoadingNode:finishLoading()
    if self.finishFunc then
        self.finishFunc()
    end
end


function LoadingNode:baseFinish()
    self:updateLoading(100, "done")
    self:finishLoading()
    self:unscheduleUpdate()
end


-- 加载图片
function LoadingNode:toLoadPng(texture)
    if self._baseIndex > #self._baseTextures then
        return
    end
    self:updateLoading(math.floor(100 * self._baseIndex / #self._baseTextures), self._baseTextures[self._baseIndex].path)
    if self._baseIndex == #self._baseTextures then
        self:baseFinish()
    end
    self._baseIndex = self._baseIndex + 1
end

-- 加载Plist图片
function LoadingNode:toLoadPlist(texture)
    if self._baseIndex > #self._baseTextures then
        return
    end
    local frameCache = cc.SpriteFrameCache:getInstance()
    frameCache:addSpriteFrames(self._baseTextures[self._baseIndex].path .. ".plist")
    local progress = math.floor(100 * self._baseIndex / #self._baseTextures)
    local path = self._baseTextures[self._baseIndex].path
    self:updateLoading(progress, path)
    if self._baseIndex == #self._baseTextures then
        self:baseFinish()
    end
    self._baseIndex = self._baseIndex + 1
end

-- 异步加载图片
function LoadingNode:baseLoadTexture()
    local frameCache = cc.SpriteFrameCache:getInstance()
    -- 加载图片
    local function loadPng(texture)
       if self.toLoadPng then
          self:toLoadPng(texture)
       end
    end

    -- 加载Plist图片
    local function loadPlist(texture)
        if self.toLoadPlist then
          self:toLoadPlist(texture)
       end
    end

    local textureCache = cc.Director:getInstance():getTextureCache()
    for i = 1, #self._baseTextures do
        local isPlist = self._baseTextures[i].isPlist
        if isPlist then
            textureCache:addImageAsync(self._baseTextures[i].path .. ".png", loadPlist)
        else
            textureCache:addImageAsync(self._baseTextures[i].path .. ".png", loadPng)
        end
    end
end
return LoadingNode
-- endregion
