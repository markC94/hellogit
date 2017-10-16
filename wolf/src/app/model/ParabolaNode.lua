--region *.lua
--Date
--此文件由[BabeLua]插件自动生成
local ParabolaNode = class("ParabolaNode")
function ParabolaNode:ctor(node, a, vx0, vy0, x, y, overFunc)
    self.node = node
    self.a = a
    self.vx0 = vx0
    self.vy0 = vy0
    self.sx0 = x
    self.sy0 = y
    self.overFunc = overFunc

    self.elapsed = 0
    self.dead = false
    self.maxHeight = vy0*vy0/(2*a)

    node:setPosition(x, y)
    node:setVisible(true)
end

function ParabolaNode:step(dt)
    if self.dead then return end
    self.elapsed = self.elapsed + dt
    local syt = self.vy0*self.elapsed - 0.5*self.a*self.elapsed*self.elapsed
    if syt < 0 then
        self.node:setVisible(false)
        if self.overFunc then
            self.overFunc()
        end
        self.dead = true
        return
    end

    local sxt = self.vx0*self.elapsed
    self.node:setPosition(self.sx0+sxt, self.sy0+syt)
    self.node:setScale(1+(syt/self.maxHeight)*1.2)
end

function ParabolaNode:isDead()
    return self.dead
end

function ParabolaNode:reset(vx0, vy0, x, y)
    if self.dead then
        self:ctor(self.node, self.a, vx0, vy0, x, y, self.overFunc)
    end
end

return ParabolaNode
--endregion
