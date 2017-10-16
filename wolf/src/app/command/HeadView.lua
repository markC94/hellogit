-- region *.lua
-- Date
-- 此文件由[BabeLua]插件自动生成
local HeadView = class("HeadView", cc.Node)
-- 1.大厅自己 2.大厅好友 3.升级 4.spin自己 5.spin好友 6 聊天自己 7 聊天好友
HeadView.POS_TEST = -10 -- 测试的头像
HeadView.POS_NONE = 0 -- 正常的头像
HeadView.POS_ONLY_HEAD = 1 -- 隐藏其他只显示头像
HeadView.POS_LOBBY_SELF = 2
HeadView.POS_SPIN_SELF = 4
HeadView.POS_SPIN_FRIEND = 5
HeadView.POS_CHAT_SELF = 6
HeadView.POS_CHAT_FRIEND = 7
HeadView.POS_SPIN_INTIVE = 8
HeadView.POS_INFO_SELF = 9
HeadView.POS_INFO_FRIEND = 10
HeadView.POS_EDIT_SELF = 11
HeadView.POS_CLUB_FRIEND = 12
HeadView.POS_CLUB_LEADER = 13
HeadView.POS_CLUB_MEMBER = 14
HeadView.POS_CLUB_REQUEST = 15
HeadView.POS_INTIVE_FRIEND = 16    --邀请加入游戏界面头像
HeadView.POS_FB_FRIEND = 17        --facebook好友头像
HeadView.POS_NOTICE = 18
HeadView.POS_FRIEND_INTIVE = 19    --好友申请(id申请)
HeadView.POS_SCALE_FRIEND = 20     
HeadView.POS_FRIEND = 21           --好友主界面头像
HeadView.POS_CLUB_SELF = 22        --clubmember中自己的头像
HeadView.POS_SALE_SELF = 23        --sale中自己的头像
HeadView.POS_CLUB_TASKINFO = 24    --club任务排行详细信息头像
HeadView.POS_LOYALSALE = 25        --活动忠诚奖励的头像

HeadView.GOTO_INFO = 1 -- 点击显示个人信息
HeadView.GOTO_INTIVE = 2 -- 点击跳转邀请
HeadView.GOTO_EDIT = 3 -- 点击跳转编辑个人信息
HeadView.GOTO_NOTHING = 4 -- 点击头像无响应
HeadView.GOTO_SLOTFUNC = 5 -- 老虎机内菜单
HeadView.GOTO_FRIEND_SEARCH = 6 -- 点击跳转搜索好友

function HeadView:ctor(data)
    if not data then
        data = { }
        data.name = "none"
        data.user_id = -1
    end

    self:registerScriptHandler( function(tag)
        if "enter" == tag then
            self:onEnter()
        elseif "exit" == tag then
            self:onExit()
        end
    end )

    self.loadHead = false

    self.scrollEnable = false
    self:initUI()
    self.goto_type = self.GOTO_INFO
    self.isSelf = false
    self.info = { }
    local tempName = "none"
    self:initName(data.name or tempName)
    self:updateInfo(data)
    self.isClick = false

end


function HeadView:initUI()
    self.headCSB = cc.CSLoader:createNode("csb/Head.csb")
    self:addChild(self.headCSB)


    self.sp_chat = self.headCSB:getChildByName("sp_chat")
    self.sp_dian1 = self.sp_chat:getChildByName("sp_dian1")
    self.sp_dian2 = self.sp_chat:getChildByName("sp_dian2")
    self.sp_dian3 = self.sp_chat:getChildByName("sp_dian3")
    self.sp_chat:setVisible(false)
    self.sp_dian1:setVisible(false)
    self.sp_dian2:setVisible(false)
    self.sp_dian3:setVisible(false)
    self.clip_name = self.headCSB:getChildByName("clip_name")
    self.sp_name = self.headCSB:getChildByName("sp_name")

    self.node_head = self.headCSB:getChildByName("node_head")
    self.img_nationality = self.headCSB:getChildByName("img_nationality")
    self.img_nationality:setVisible(false)
    self.img_level = self.headCSB:getChildByName("img_level")
    self.img_level:setVisible(false)
    self.img_namebg = self.headCSB:getChildByName("img_namebg")
    self.img_namebg:setVisible(false)
    
    self.txt_level = self.headCSB:getChildByName("txt_level")
    self.sp_money = self.headCSB:getChildByName("sp_money")
    self.txt_money = self.sp_money:getChildByName("txt_money")
    self.sp_money:setVisible(false)
    local function touchEvent(sender, eventType)
        local name = sender:getName()
        if eventType == ccui.TouchEventType.began then
            if name == "touch" then
                self.isClick = true
            end
            if self.goto_type ~= self.GOTO_NOTHING then
                bole:clickScale(self,0.1,0.9)
            end
        elseif eventType == ccui.TouchEventType.moved then
            if name == "touch" then
                local bPos = sender:getTouchBeganPosition()
                local ePos = sender:getTouchEndPosition()
                if self.scrollEnable then
                    if math.abs(bPos.y - ePos.y) > 50 or math.abs(bPos.x - ePos.x) > 50 then
                        self.isClick = false
                        if self.goto_type ~= self.GOTO_NOTHING then
                            self:resetClick()
                        end
                    end
                end
            end
        elseif eventType == ccui.TouchEventType.ended then
            if not self.isClick then
                return
            end
            self.isClick = false
            local bPos = sender:getTouchBeganPosition()
            local ePos = sender:getTouchEndPosition()
            if self.scrollEnable then
                if math.abs(bPos.y - ePos.y) > 50 or math.abs(bPos.x - ePos.x) > 50 then
                    if self.goto_type ~= self.GOTO_NOTHING then
                        self:resetClick()
                    end
                    return
                end
            end
            if name == "touch" then
                if self.goto_type ~= self.GOTO_NOTHING then
                    bole:clickScale(self,0.15,nil,function()
                        self:gotoView()
                    end)
                end
            end
            
        elseif eventType == ccui.TouchEventType.canceled then
            self.isClick = false
            if self.goto_type ~= self.GOTO_NOTHING then
                self:resetClick()
            end
        end
    end

    self.Img_headbg = self.headCSB:getChildByName("Img_headbg")
    self.touch = self.headCSB:getChildByName("touch")
    self.touch:setTouchEnabled(true)
    self.touch:addTouchEventListener(touchEvent)
end

function HeadView:resetClick()
    bole:clickScale(self,0.1)
end

function HeadView:gotoView()
    print("---------------show_UserInfo:" .. self.info.user_id)
    if self.goto_type == self.GOTO_INFO then
        bole:getUIManage():openInfoView(self)
    elseif self.goto_type == self.GOTO_INTIVE then
        bole:getUIManage():popInvitationInput()
    elseif self.goto_type == self.GOTO_EDIT then
        bole:getUIManage():openEditView(self.info)
    elseif self.goto_type == self.GOTO_NOTHING then
        print("HeadView:gotoView---nothing")
    elseif self.goto_type == self.GOTO_SLOTFUNC then
        bole:postEvent("openSlotFuncView", { self.Img_headbg, self })
    elseif self.goto_type == HeadView.GOTO_FRIEND_SEARCH then
        bole:getUIManage():openNewUI("FriendSearchLayer",true,"friend","app.views.friend")
    end
end

function HeadView:getInfo()
    return self.info
end
-- 是否启用滑动点击无效
function HeadView:setScrollEnable(flag)
    self.scrollEnable = flag
end

function HeadView:setSwallow(flag)
    self.touch:setSwallowTouches(flag)
    -- 默认不吞噬监听既开启滑动
    self:setScrollEnable(not flag)
end
-- 初始化名字信息
function HeadView:initName(name)
    self.img_namebg:setVisible(true)
    local ttfConfig = {fontFilePath="font/bole_ttf.ttf",fontSize=26}
    self.txt_name = cc.Label:createWithTTF(ttfConfig,"99")
    local node = cc.Node:create()
    node:addChild(self.txt_name)
    node:setPosition(50.0000, 13.0000)
    self.clip_name:addChild(node)
    --    local clipNode = cc.ClippingNode:create()
    --    local mask = display.newSprite("#head/common_strager_name_onlineMASK.png")
    --    clipNode:setAlphaThreshold(0)
    --    clipNode:setStencil(mask)
    --    clipNode:setScale(1)
    --    clipNode:setPosition(57.0000, 17.0000)
    --    clipNode:addChild(self.txt_name)
    --    self.img_namebg:addChild(clipNode)
    self.txt_name:setPosition(0, 0)
    bole:moveStr(self.txt_name, 100)
end 

-- 更新人头头像信息有几条更新几条
function HeadView:updateInfo(data)
    if not data then return end
    -- id不能更改唯一性,头像根据user_id生成
    if data.user_id then
        self:updateUserId(data.user_id, data.icon)
    end
    -- 获取网络头像 head_url存在只读取网络头像
    if data.head_url then
        self.info.head_url = data.head_url
        -- 网络头像默认开启裁切功能目前只有fb好友在使用
        self:setClipHead(true)
        self:updateHead()
    end
    if data.name then
        self:updateName(data.name)
    end

    if data.coins then
        self:updateCoins(data.coins)
    end

    if data.level then
        self:updateLevel(data.level)
    end

    if data.country then
        self:updateCountry(data.country)
    end
    if data.pos then
        self:updatePos(data.pos)
    elseif self.info.pos then
        self:updatePos(self.info.pos)
    end
    -- 这里开始显示特效
    if data.win_type then
        self:showBigWin(data.win_type)
    end
    -- 这里加载数据
    for k, v in pairs(data) do
        self.info[k] = v
    end
end
function HeadView:setRandomBigWin()
    local rand_time = math.random(3, 20) * 0.1
    performWithDelay(self, function()
        self:showBigWin(flag)
    end , rand_time)
end
function HeadView:setRandomShowChat()
    local rand_time = math.random(2, 7) * 0.1
    performWithDelay(self, function()
        self:showChat()
    end , rand_time)
end

local time_chat1=0.2 --放大时间
local time_chat2=0.3 --缩小时间
local time_dian_show=0.2 --点显示时间
local time_dian_delay=0.2 --点等待时间时间
local time_dian_hide=0.2 -- 点小时时间
local time_dian_hide_sp=0.1 -- 点小时时间
function HeadView:showChat()
    self.sp_dian1:setVisible(true)
    self.sp_dian2:setVisible(true)
    self.sp_dian3:setVisible(true)
    self.sp_dian1:setOpacity(0)
    self.sp_dian2:setOpacity(0)
    self.sp_dian3:setOpacity(0)

    self.sp_chat:setVisible(true)
    self.sp_chat:setOpacity(0)
    self.sp_chat:setScale(0.1)

    local sp=cc.FadeIn:create(0.8)
    self.sp_chat:runAction(sp)
    local seq = cc.Sequence:create(cc.ScaleTo:create(time_chat1, 1.1), cc.ScaleTo:create(time_chat2, 1))
    self.sp_chat:runAction(seq)
    local time1=time_chat1+time_chat2+0.2
    local time2=time1+time_dian_delay*2+time_dian_show*3+0.5
    local time3=time2+time_dian_hide+0.2
    local time4=time3+time_dian_delay*2+time_dian_show*3+0.5
    performWithDelay(self, function()
        --time_dian_delay*2+time_dian_show*3
        self:showDian()
    end , time1)

    performWithDelay(self, function()
        self:hideDian()
    end , time2)

    performWithDelay(self, function()
        self:showDian()
    end , time3)
    performWithDelay(self, function()
        self.sp_chat:runAction(cc.FadeOut:create(0.4))
    end , time4)
end

function HeadView:showDian()
    self.sp_dian1:setVisible(true)
    self.sp_dian2:setVisible(true)
    self.sp_dian3:setVisible(true)
    self.sp_dian1:setOpacity(0)
    self.sp_dian2:setOpacity(0)
    self.sp_dian3:setOpacity(0)
    local seq1 = cc.Sequence:create(cc.FadeIn:create(time_dian_show))
    self.sp_dian1:runAction(seq1)

    local seq2 = cc.Sequence:create(cc.DelayTime:create(time_dian_delay+time_dian_show), cc.FadeIn:create(time_dian_show))
    self.sp_dian2:runAction(seq2)

    local seq3 = cc.Sequence:create(cc.DelayTime:create(time_dian_delay*2+time_dian_show*2), cc.FadeIn:create(time_dian_show))
    self.sp_dian3:runAction(seq3)
end

function HeadView:hideDian()
    self.sp_dian1:runAction(cc.FadeOut:create(time_dian_hide))
    self.sp_dian2:runAction(cc.FadeOut:create(time_dian_hide))
    self.sp_dian3:runAction(cc.FadeOut:create(time_dian_hide))
end

function HeadView:showBigWin(flag)
    if flag == 0 then
        return
    end
    local skeletonNode = sp.SkeletonAnimation:create("util_act/skeleton.json", "util_act/skeleton.atlas")
    skeletonNode:setScale(0.95)
    performWithDelay(skeletonNode, function()
        skeletonNode:removeFromParent()
    end , 2.5)
    if self.isSelf then
        skeletonNode:setAnimation(0, "animation2", false)
    else
        skeletonNode:setAnimation(0, "animation", false)
    end
    skeletonNode:setPosition(cc.p(0, -75))
    self:addChild(skeletonNode, 1)
end

----更新唯一id
function HeadView:updateUserId(user_id, icon)
    self.info.user_id = user_id
    self.info.icon = icon
    if user_id == -1 then
        self:updateHead()
    else
        if not icon then
            -- 没有设置icon 优先从资源服务器下载
            icon = "self"

            -- 没有设置icon 读本地默认头像
            icon = "0"
        end
        -- 机器人头像处理
        if user_id < 11000 then
            local native = false
            if native then
                local robot_index = user_id % 40 + 1
                local native_path = string.format("head_icon/101_%02d.png", robot_index)
                self:updateHead(native_path)
            else
                local robot_index = user_id % 100 + 1
                local file = self:getHeadImg(robot_index)
                if file then
                    self:updateHead(file)
                else
                    if self.loadHead then
                        return
                    end
                    self.loadHead = true
                    self:updateHead(self:getIconPath(icon), true)
                    local function funcSaveImg(fileName, eventCode)
                        if self.saveRobotImgPath then
                            self:saveRobotImgPath(fileName, robot_index, eventCode)
                        end
                    end
                    bole:loadUserHead("robot_" .. robot_index, true, funcSaveImg)
                end
            end
            return
        end
        local file = self:getHeadImg(user_id)
        if file then
            self:updateHead(file)
        else
            if icon == "self" then
                -- 这里是加载中图片
                if self.loadHead then
                    return
                end
                self.loadHead = true
                self:updateHead(self:getIconPath(icon), true)
                local function funcSaveImg(fileName, eventCode)
                    if self.saveImgPath then
                        self:saveImgPath(fileName, eventCode)
                    end
                end
                bole:loadUserHead(user_id, self.isSelf, funcSaveImg)
            else
                -- 这里是选择默认头像逻辑
                self:updateHead(self:getIconPath(icon))
            end
        end
    end
end

function HeadView:getHeadImg(index)
    return bole.headImgs[index]
end
function HeadView:setHeadImg(index, file)
    bole.headImgs[index] = file
end

function HeadView:getIconPath(index)
    return "head/common_default_portrait.png"
end
function HeadView:saveImgPath(path, code)
    print("HeadView:saveImgPath=" .. path)
    print("HeadView:code=" .. code)
    self.loadHead = false
    if code ~= 6 then
        self:updateHead(self:getIconPath(icon))
        return
    end
    self:setHeadImg(self.info.user_id, path)
    local file = self:getHeadImg(self.info.user_id)
    self:updateHead(file)
end
function HeadView:saveRobotImgPath(path, robot_index, code)
    print("HeadView:saveRobotImgPath=" .. path)
    print("HeadView:code=" .. code)
    self.loadHead = false
    if code ~= 6 then
        self:updateHead(self:getIconPath(icon))
        return
    end
    self:setHeadImg(robot_index, path)
    local file = self:getHeadImg(robot_index)
    self:updateHead(file)
end
-- 更新名字 名字相同不刷新
function HeadView:updateName(name)
    self.img_namebg:setVisible(true)
    self.txt_name:setVisible(true)
    self.info.name = name
    self.txt_name:setString(name)
    self.txt_name:setPosition(0, 0)
    bole:moveStr(self.txt_name, 100)
end

-- 更新金币
function HeadView:updateCoins(coins)
    if self.info.pos == self.POS_SPIN_FRIEND then
        self.info.coins = coins
        self.sp_money:setVisible(true)
        self.txt_money:setString(bole:formatCoins(coins, 5))
    end
end

-- 更新等级
function HeadView:updateLevel(level)
    self.img_level:setVisible(true)
    self.txt_level:setVisible(true)
    self.info.level = level
    self.txt_level:setString(level)
end
function HeadView:setClipHead(flag)
    self.node_head:removeAllChildren()
    if flag then
        self.clip_head_node = cc.ClippingNode:create()
        local mask = display.newSprite("head/potrait_mask.png")
        self.mask_width = mask:getContentSize().width
        self.clip_head_node:setAlphaThreshold(0)
        self.clip_head_node:setStencil(mask)
        self.node_head:addChild(self.clip_head_node)
    else
        self.clip_head_node = nil
    end
end
-- 更新头像 头像相同不刷新
function HeadView:updateHead(imgPath, isAnima)
    if self.clip_head_node then
        self.clip_head_node:removeAllChildren()
    else
        self.node_head:removeAllChildren()
    end

    local head = nil
    -- 优先获取url头像(目前只有fb好友使用)
    if self.info.head_url then
        head = bole:newNetSprite(self.info.head_url)
    elseif isAnima then
        head = sp.SkeletonAnimation:create("util_act/loadingHead.json", "util_act/loadingHead.atlas")
        head:setAnimation(0, "animation", true)
    elseif imgPath then
        head = display.newSprite(imgPath)
    end
    if not head then
        return
    end

    if not isAnima then
        -- 邀请加号不缩放
        if self.info.pos ~= self.POS_SPIN_INTIVE and self.info.pos ~= self.POS_FRIEND_INTIVE then
            head:setScale(114.0 / head:getContentSize().width)
        end
    end
    if self.clip_head_node then
        self.clip_head_node:addChild(head)
    else
        self.node_head:addChild(head)
    end
end

-- 大厅测试头像
function HeadView:randTestHead()
    local str = string.format("head_icon/101_%02d.png", math.random(1, 40))
    return str
end
function HeadView:testHead()
    self.node_head:removeAllChildren()
    local file = self:randTestHead()
    local head = display.newSprite(file)
    self.node_head:addChild(head)
end
--

function HeadView:hideName()
    self.img_namebg:setVisible(false)
    self.txt_name:setVisible(false)
    self.clip_name:setVisible(false)
    self.sp_name:setVisible(false)
end

function HeadView:setNamePos(posX,posY)
    self.img_namebg:setPosition(posX,posY)
    self.clip_name:setPosition(posX,posY)
    self.sp_name:setPosition(posX,posY)
end

function HeadView:setNameScale(scale)
    self.img_namebg:setScale(scale)
    self.clip_name:setScale(scale)
    self.sp_name:setScale(scale)
end

function HeadView:hideLevel()
    self.img_level:setVisible(false)
    self.txt_level:setVisible(false)
end
function HeadView:hideCountry()
    self.img_nationality:setVisible(false)
end
function HeadView:changeLevelPos(index)
    if index == 1 then
        self.img_nationality:setPosition(-57, -2)
        self.img_level:setPosition(57, -2)
        self.txt_level:setPosition(58, -2 - 1)
    elseif index == 2 then
        self.img_nationality:setPosition(-50, -30)
        self.img_level:setPosition(57, -26)
        self.txt_level:setPosition(58, -26 - 1)
    end
end
-- 更新位置状态
function HeadView:updatePos(pos)
    self.info.pos = pos
    if pos == self.POS_TEST then
        self:randTestHead()
        self:hideName()
        self:hideLevel()
        --        self.goto_type = self.GOTO_NOTHING
    elseif pos == self.POS_NONE then
--        self:hideName()
    elseif pos == self.POS_ONLY_HEAD then
        self:hideName()
        self:hideLevel()
        self:hideCountry()
        self.goto_type = self.GOTO_NOTHING
    elseif pos == self.POS_LOBBY_SELF then
        self:hideName()
        self:changeLevelPos(1)
        self:setSelf()
    elseif pos == self.POS_SPIN_SELF then
        self:hideName()
        self:setSelf()
    elseif pos == self.POS_SPIN_FRIEND then
        self.goto_type = self.GOTO_SLOTFUNC
        self:updateCoins(self.info.coins)
    elseif pos == self.POS_CHAT_SELF then
        self:hideName()
        self:hideLevel()
        self:hideCountry()
        self:setSelf()
    elseif pos == self.POS_CHAT_FRIEND then
        self:hideName()
        self:hideLevel()
        self:hideCountry()
    elseif pos == self.POS_SPIN_INTIVE then
        self.goto_type = self.GOTO_INTIVE
        self:updateUserId(-1)
        self:updateName("INTIVE")
        self.Img_headbg:loadTexture("head/common_invite_portrait.png")
        self:hideLevel()
        self:hideCountry()
    elseif pos == self.POS_INFO_SELF then
        self.goto_type = self.GOTO_EDIT
        self:hideName()
        self:setSelf()
        self:changeLevelPos(2)
    elseif pos == self.POS_INFO_FRIEND then
        self.goto_type = self.GOTO_NOTHING
        self:hideName()
        self:changeLevelPos(2)
    elseif pos == self.POS_EDIT_SELF then
        self.touch:setTouchEnabled(false)
        self.goto_type = self.GOTO_NOTHING
        self:hideName()
        self:hideLevel()
        self:hideCountry()
        self:setSelf()
    elseif pos == self.POS_CLUB_FRIEND then
        self:hideLevel()
        self:hideCountry()
    elseif pos == self.POS_CLUB_LEADER then
        self:hideName()
        self:hideLevel()
        self:hideCountry()
        self.goto_type = self.GOTO_NOTHING
    elseif pos == self.POS_CLUB_MEMBER then
        --self.touch:setTouchEnabled(false)
        self.cannotOpenClubInfo = true
    elseif pos == self.POS_CLUB_REQUEST then
        self:setNamePos(180,0)
        self:setNameScale(1.2)
    elseif pos == self.POS_INTIVE_FRIEND then
        self.goto_type = self.GOTO_NOTHING
    elseif pos == self.POS_FB_FRIEND then
        --self:setNamePos(180,0)
        --self:setNameScale(1.2)
        self:hideLevel()
        self:hideCountry()
        self.goto_type = self.GOTO_NOTHING
    elseif pos == self.POS_NOTICE then
        self:hideName()
        self:hideLevel()
        self:hideCountry()
        self.goto_type = self.GOTO_NOTHING
    elseif pos == self.POS_SCALE_FRIEND then
        self:hideLevel()
        self:hideCountry()
        self.goto_type = self.GOTO_NOTHING
    elseif pos == self.POS_FRIEND_INTIVE then
        self.goto_type = self.GOTO_FRIEND_SEARCH
        self:updateUserId(-1)
        self:updateName("INTIVE")
        self.Img_headbg:loadTexture("head/common_invite_portrait.png")
        self:hideLevel()
        self:hideCountry()
        self:hideName()
    elseif pos == self.POS_CLUB_SELF then
        self.isSelf = true
    elseif pos == self.POS_SALE_SELF then
        self.Img_headbg:loadTexture("head/specialOffer_Portrait_big.png")
        self.Img_headbg:setScale(1)
        self:hideName()
        self:hideLevel()
        self:hideCountry()
        self.goto_type = self.GOTO_NOTHING
    elseif pos == self.POS_CLUB_TASKINFO then
        self:setNamePos(180,0)
        self:setNameScale(1.2)
        self.touch:setTouchEnabled(false)
    elseif pos == self.POS_LOYALSALE then
        self.Img_headbg:loadTexture("head/common_strager_portrait.png")
        self.touch:setTouchEnabled(false)
    end

    self:registerScriptHandler( function(state)
        if state == "enter" then
            self:onEnter()
        elseif state == "exit" then
            self:onExit()
        end
    end )
end

function HeadView:setSelf()
    self.Img_headbg:loadTexture("head/common_self_portrait.png")
    self.isSelf = true
    self:onEnter()
end

function HeadView:onEnter()
    if self.isSelf then
        if self.listener then
            return
        end
        self.listener = true
        bole:addListener("levelChanged", self.eventLevel, self, nil, true)
        bole:addListener("eventInfo", self.eventInfo, self, nil, true)
        bole:addListener("eventImgPath", self.eventImgPath, self, nil, true)
    end
end

function HeadView:onExit()
    if self.listener then
        self.listener = false
        bole:getEventCenter():removeEventWithTarget("levelChanged", self)
        bole:getEventCenter():removeEventWithTarget("eventInfo", self)
        bole:getEventCenter():removeEventWithTarget("eventImgPath", self)
    end
end

function HeadView:eventInfo(event)
    if self.updateInfo then
        self:updateInfo(event.result)
    end
end

-- 更新国籍
function HeadView:updateCountry(country)
    self.img_nationality:setVisible(true)
    self.info.country = country
    self.img_nationality:loadTexture("flag/flag_" .. country .. ".png")
end

function HeadView:eventLevel(event)
    if self.updateLevel then
        self:updateLevel(bole:getUserDataByKey("level"))
    end
end

function HeadView:eventImgPath(event)
    local data = event.result
    if self.saveImgPath then
        self:saveImgPath(data[1], data[2])
    end
end

return HeadView

-- endregion
