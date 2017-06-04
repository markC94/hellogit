
local MainScene = class("MainScene", cc.load("mvc").ViewBase)

MainScene.RESOURCE_FILENAME = "MainScene.csb"

local ROCKERPOS = cc.p(240,240)   --摇杆初始位置
local ROCKERPOS_RADIUS = 190      --摇杆半径


function MainScene:onCreate()
    --父节点
    self.root_ = self:getResourceNode()

    --创建蛇
    self:createSnake()
    
    --创建虚拟摇杆
    self:createRocker()

    --刷新函数
    self:getScheduler():scheduleScriptFunc(function(dt) self:update(dt) end , 0, false)

    --键盘监听
    local listener = cc.EventListenerKeyboard:create()
    listener:registerScriptHandler(function(keyCode, event) self:updateDir(keyCode, event) end, cc.Handler.EVENT_KEYBOARD_PRESSED)
    self:getEventDispatcher():addEventListenerWithSceneGraphPriority(listener,self)
end


function MainScene:createSnake()
    self.snake = {}
    self.snake.len = 40   --初始长度
    self.snake.speed = 3   --速度
    self.snake.interval = math.ceil(25 / self.snake.speed)

    for i = 1, (self.snake.len - 1) * self.snake.interval + 1 do
        self.snake[i] = {}
        if i == 1 then
            self.snake[1].point = cc.Sprite:create("head.png")
            self.root_ :addChild(self.snake[1].point)
            self.snake[1].x = 500 + i * self.snake.speed 
            self.snake[1].y = 500
        elseif i % self.snake.interval == 1 then
            self.snake[i].point = cc.Sprite:create("body.png")
            self.root_ :addChild(self.snake[i].point)
            self.snake[i].x = 500 + i * self.snake.speed 
            self.snake[i].y = 500 
        else
            self.snake[i].point = nil
            self.snake[i].x = 500 + i * self.snake.speed 
            self.snake[i].y = 500
        end
    end

    for i= 1,# self.snake do
        if  self.snake[i].point ~= nil then
            self.snake[i].point:setPosition(self.snake[i].x , self.snake[i].y )
        end
    end

    self.dirX = - 1
    self.dirY = 0
    self.dir = "left" 
end

function MainScene:createRocker()
    local rockerBg = cc.Sprite:create("yaogan1.png")
    local rocker = cc.Sprite:create("yaogan2.png")
    rockerBg:setPosition(ROCKERPOS.x,ROCKERPOS.y)
    rocker:setPosition(ROCKERPOS.x,ROCKERPOS.y)
    self.root_ :addChild(rockerBg,1)
    self.root_ :addChild(rocker,1)

    --创建单击事件
    local listener = cc.EventListenerTouchOneByOne:create()
    listener:setSwallowTouches(true)

    local function touchBegan(touch, event)
        local touchPos = touch:getLocation()
        --限制触发摇杆的位置
        if touchPos.x < 700 and touchPos.y < 600 then
            local posX = math.abs(touchPos.x - ROCKERPOS.x)   --水平位移量
            local posY = math.abs(touchPos.y - ROCKERPOS.y)   --垂直位移量

            local conVector =  cc.pNormalize(cc.p(touchPos.x - ROCKERPOS.x, touchPos.y - ROCKERPOS.y))  --获取常向量
            self:updateSnakeDir(conVector)
            if posX * posX + posY * posY > ROCKERPOS_RADIUS * ROCKERPOS_RADIUS then   --摇杆圈内
                rocker:setPosition(ROCKERPOS.x + ROCKERPOS_RADIUS * conVector.x, ROCKERPOS.y + ROCKERPOS_RADIUS * conVector.y)  --设置位置
            else   --摇杆圈外
                rocker:setPosition(touchPos.x, touchPos.y)
            end
            self.openRocker = true
        end
        
        return true
    end

    local function touchMoved(touch, event)
        local touchPos = touch:getLocation()
        if  self.openRocker then
            local posX = math.abs(touchPos.x - ROCKERPOS.x)
            local posY = math.abs(touchPos.y - ROCKERPOS.y)
            local conVector =  cc.pNormalize(cc.p(touchPos.x - ROCKERPOS.x, touchPos.y - ROCKERPOS.y))
            self:updateSnakeDir(conVector)
            if posX * posX + posY * posY > ROCKERPOS_RADIUS * ROCKERPOS_RADIUS then   
                rocker:setPosition(ROCKERPOS.x + ROCKERPOS_RADIUS * conVector.x, ROCKERPOS.y + ROCKERPOS_RADIUS * conVector.y)
            else   
                rocker:setPosition(touchPos.x, touchPos.y)
            end
        end
    end

    local function touchEnded(touch, event)
        rockerBg:setPosition(ROCKERPOS.x,ROCKERPOS.y)
        rocker:setPosition(ROCKERPOS.x,ROCKERPOS.y)
        self.openRocker = false
    end
    listener:registerScriptHandler(touchBegan, cc.Handler.EVENT_TOUCH_BEGAN)
    listener:registerScriptHandler(touchMoved, cc.Handler.EVENT_TOUCH_MOVED)
    listener:registerScriptHandler(touchEnded, cc.Handler.EVENT_TOUCH_ENDED)
    cc.Director:getInstance():getEventDispatcher():addEventListenerWithSceneGraphPriority(listener,rockerBg)
end

function MainScene:update(dt)
    self:updatePos(dt)
    self:updateFood(dt)
end

function MainScene:updatePos(dt)
        for i =  # self.snake, 2, - 1 do
            self.snake[i].x = self.snake[i - 1].x 
            self.snake[i].y = self.snake[i - 1].y
        end

        self.snake[1].x = self.snake[1].x + self.dirX * self.snake.speed 
        self.snake[1].y = self.snake[1].y + self.dirY * self.snake.speed 

        for i= 1,# self.snake do
            if  self.snake[i].point ~= nil then
                self.snake[i].point:setPosition(self.snake[i].x , self.snake[i].y )
            end
        end

        self:isDead()
end


function MainScene:updateFood(dt)
    if self.food == nil then
        self.food = cc.Sprite:create("body.png")
        local posX = math.random(20,1900)
        local posY = math.random(20,1050)
        self.food:setPosition(posX,posY)
        self.root_ :addChild(self.food)
    end

   
    local snakePosX ,snakePosY = self.snake[1].point:getPosition()
    local foodPosX, foodPosY = self.food:getPosition()


    if snakePosX > foodPosX - 20 and snakePosX < foodPosX + 20 and snakePosY > foodPosY - 20 and snakePosY < foodPosY + 20 then
        self.food:removeFromParent()
        self.food = nil
        local len = # self.snake

        for i = len + 1, len + self.snake.interval do
             self.snake[i] = {}
            if i % self.snake.interval == 1 then
                self.snake[i].point = cc.Sprite:create("body.png")
                self.root_ :addChild(self.snake[i].point)
                self.snake[i].x = -50
                self.snake[i].y = -50 
            else
                self.snake[i].point = nil
                self.snake[i].x = -50
                self.snake[i].y = -50
            end
        end
    end
   
end

function MainScene:updateSnakeDir(conVector)
    local p = math.abs(180 / math.pi * cc.pToAngleSelf(conVector) - 180)
    self:headDir(p)
    self.dirX = conVector.x
    self.dirY = conVector.y
end

function MainScene:updateDir(keyCode, event)
    if keyCode == 26 and self.dir ~= "right" then   --左
        self.dir = "left"
        self.dirX = -1
        self.dirY = 0
        self:headDir(0)
    elseif keyCode == 27 and self.dir ~= "left" then  --右
        self.dir = "right"
        self.dirX = 1
        self.dirY = 0
        self:headDir(180)
    elseif keyCode == 28 and self.dir ~= "down" then   --上
        self.dir = "up"
        self.dirX = 0
        self.dirY = 1
        self:headDir(90)
    elseif keyCode == 29 and self.dir ~= "up" then  --下
        self.dir = "down"
        self.dirX = 0
        self.dirY = -1
        self:headDir(270)
    end
end

--旋转图片
function MainScene:headDir(degree)
    self.snake[1].point:setRotationSkewX(degree)
    self.snake[1].point:setRotationSkewY(degree)
end

function MainScene:isDead()
    


end

return MainScene
