-- region *.lua
-- Date
-- 此文件由[BabeLua]插件自动生成

local SpinModel = class("SpinModel", cc.load("mvc").ModelBase)

function SpinModel:ctor(app)
    SpinModel.super.ctor(self)

    self.app = app

    self.row = 3
    self.column = 5
end

function SpinModel:getColumn()
    return self.column
end

function SpinModel:getRow()
    return self.row
end

return SpinModel

-- endregion
