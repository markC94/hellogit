
local MainScene = class("MainScene", cc.load("mvc").ViewBase)

MainScene.RESOURCE_FILENAME = "MainScene.csb"

function MainScene:onCreate()
    --父节点
    self.root_ = self:getResourceNode()

    --创建蛇
    self:createSnake()

    --刷新函数
    self:getScheduler():scheduleScriptFunc(function(dt) self:updatePos(dt) end , 0.5, false)

    --键盘监听
    local listener = cc.EventListenerKeyboard:create()
    listener:registerScriptHandler(function(keyCode, event) self:updateDir(keyCode, event) end, cc.Handler.EVENT_KEYBOARD_PRESSED)
    self:getEventDispatcher():addEventListenerWithSceneGraphPriority(listener,self)
end


function MainScene:createSnake()
    self.snake = {}
    self.snake[1] = cc.Sprite:create("head.png")
    self.root_ :addChild(self.snake[1],100)
    self.snake[1].x = 10
    self.snake[1].y = 10
   
    for i = 2, 4 do
        self.snake[i] = cc.Sprite:create("body.png")
        self.root_ :addChild(self.snake[i],100)
        self.snake[i].x = 9 + i
        self.snake[i].y = 10
    end
  
    self.dir = "left"
    self.dirX = -1
    self.dirY = 0

    for i= 1,# self.snake do
        self.snake[i]:setPosition(self.snake[i].x * 80, self.snake[i].y * 80)
    end
end


function MainScene:updatePos(dt)
        for i =  # self.snake, 2, - 1 do
            self.snake[i].x = self.snake[i - 1].x 
            self.snake[i].y = self.snake[i - 1].y
        end

        self.snake[1].x = self.snake[1].x + self.dirX
        self.snake[1].y = self.snake[1].y + self.dirY

        for i = 1,  # self.snake do
            self.snake[i]:setPosition(self.snake[i].x * 80, self.snake[i].y * 80)
        end

        self:isDead()
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
    self.snake[1]:setRotationSkewX(degree)
    self.snake[1]:setRotationSkewY(degree)
end

function MainScene:isDead()
    


end

return MainScene
